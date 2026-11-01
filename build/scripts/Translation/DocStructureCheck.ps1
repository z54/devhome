<#
.SYNOPSIS
    Markdown 结构校验（原子需求 DOC-04）。
.DESCRIPTION
    翻译后最容易坏的是文档结构。本脚本检查六类问题：
    1) 标题层级跳级；2) 代码围栏未配对；3) 表格各行列数不一致；
    4) 相对链接指向的文件不存在；5) 图片路径不存在；6) 文内锚点指向的标题不存在。
.EXAMPLE
    .\DocStructureCheck.ps1
#>
param(
    [string]$Path = (Resolve-Path (Join-Path $PSScriptRoot '..\..\..')).Path
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$root = (Resolve-Path -LiteralPath $Path).Path.TrimEnd('\') + '\'
$excludeDirPattern = '\\(node_modules|obj|bin|\.git)\\'

$files = Get-ChildItem -LiteralPath $root -Recurse -File -Filter *.md |
    Where-Object { $_.FullName -notmatch $excludeDirPattern }

<#
.SYNOPSIS
    把 Markdown 标题文本转成 GitHub 的锚点 slug。
.DESCRIPTION
    规则：小写化；去掉除连字符与下划线以外的标点；空格替换为连字符；保留中文。
#>
function ConvertTo-Anchor {
    param([string]$Text)
    $slug = $Text.ToLowerInvariant()
    # 去掉 Markdown 的行内代码、链接、加粗等标记，只留纯文本
    $slug = $slug -replace '`([^`]*)`', '$1'
    $slug = $slug -replace '\[([^\]]*)\]\([^\)]*\)', '$1'
    $slug = $slug -replace '[*_~]', ''
    # 去掉标点符号（保留字母、数字、中日韩字符、连字符、下划线与空格）
    $slug = $slug -replace '[^\w\u4e00-\u9fff\- ]', ''
    $slug = $slug.Trim()
    $slug = $slug -replace '\s+', '-'
    return $slug
}

# 先全域收集每个文件的标题锚点，供文内锚点与跨文件锚点校验使用
$anchorMap = @{}
foreach ($file in $files) {
    $anchors = [System.Collections.Generic.HashSet[string]]::new()
    $fenceOpen = $false
    foreach ($raw in [System.IO.File]::ReadAllLines($file.FullName)) {
        if ($raw -match '^\s*```') { $fenceOpen = -not $fenceOpen; continue }
        if ($fenceOpen) { continue }
        if ($raw -match '^(#{1,6})\s+(.*)$') {
            [void]$anchors.Add((ConvertTo-Anchor -Text $Matches[2]))
        }
    }
    $anchorMap[$file.FullName] = $anchors
}

$problems = [System.Collections.Generic.List[string]]::new()
$warnings = [System.Collections.Generic.List[string]]::new()

foreach ($file in $files) {
    $rel = $file.FullName.Substring($root.Length).TrimStart('\')
    $lines = [System.IO.File]::ReadAllLines($file.FullName)

    $openFence = $false
    $previousHeadingLevel = 0
    $headingAnchors = [System.Collections.Generic.HashSet[string]]::new()

    for ($i = 0; $i -lt $lines.Count; $i++) {
        $line = $lines[$i]
        $lineNo = $i + 1

        # ---- 1. 代码围栏配对 ----
        if ($line -match '^\s*```') {
            $openFence = -not $openFence
            continue
        }
        if ($openFence) { continue }

        # ---- 2. 标题层级跳级 ----
        if ($line -match '^(#{1,6})\s+(.*)$') {
            $level = $Matches[1].Length
            if ($previousHeadingLevel -gt 0 -and $level -gt $previousHeadingLevel + 1) {
                $warnings.Add(('{0}:{1}  标题从 {2} 级跳到 {3} 级' -f $rel, $lineNo, $previousHeadingLevel, $level))
            }
            $previousHeadingLevel = $level
            [void]$headingAnchors.Add((ConvertTo-Anchor -Text $Matches[2]))
            continue
        }

        # ---- 3. 表格列数一致 ----
        if ($line.Trim() -like '|*') {
            $start = $i
            while ($i -lt $lines.Count -and $lines[$i].Trim() -like '|*') { $i++ }
            $first = $lines[$start].Split('|').Count
            for ($j = $start; $j -lt $i; $j++) {
                if ($lines[$j].Split('|').Count -ne $first) {
                    $problems.Add(('{0}:{1}  表格列数与表头不一致（{2} vs {3}）' -f $rel, ($j + 1), $lines[$j].Split('|').Count, $first))
                }
            }
            continue
        }

        # ---- 4/5. 相对链接与图片路径 ----
        foreach ($m in [regex]::Matches($line, '!?\[[^\]]*\]\(([^)\s]+)')) {
            $target = $m.Groups[1].Value
            # 外链、mailto、模板变量都不做文件存在性检查
            if ($target -match '^(https?://|mailto:|#)') { continue }
            if ($target -match '\{\{') { continue }
            $anchor = $null
            $pathOnly = ($target -split '#')[0]
            if ($pathOnly -eq '') {
                # 纯锚点：校验当前文件是否有该标题
                $anchor = $target.Substring(1)
                if (-not $anchorMap[$file.FullName].Contains($anchor)) {
                    $problems.Add(('{0}:{1}  锚点无对应标题: #{2}' -f $rel, $lineNo, $anchor))
                }
                continue
            }
            if ($target -match '#') { $anchor = ($target -split '#', 2)[1] }

            # 解析顺序：/ 开头从仓库根；否则先相对当前文件目录，失败且路径像仓库根路径时再从仓库根解析
            $resolved = $null
            if ($pathOnly.StartsWith('/')) {
                $resolved = Join-Path -Path $root -ChildPath $pathOnly.TrimStart('/')
            }
            else {
                $fileResolved = Join-Path -Path (Split-Path -Parent $file.FullName) -ChildPath $pathOnly
                if (Test-Path -LiteralPath $fileResolved) {
                    $resolved = $fileResolved
                }
                elseif ($pathOnly -notmatch '^(\.{1,2}/|\.{1,2}\\)') {
                    # 不含 ./ ../ 前缀，可能是仓库根相对路径（如 tools/Environments/...）
                    $rootResolved = Join-Path -Path $root -ChildPath $pathOnly
                    if (Test-Path -LiteralPath $rootResolved) { $resolved = $rootResolved }
                }
            }
            if ($null -eq $resolved) {
                $problems.Add(('{0}:{1}  链接目标不存在: {2}' -f $rel, $lineNo, $target))
                continue
            }
            # 跨文件锚点：校验目标文件是否包含该标题
            if ($null -ne $anchor) {
                if (-not $anchorMap[$resolved].Contains($anchor)) {
                    $problems.Add(('{0}:{1}  跨文件锚点无对应标题: {2}' -f $rel, $lineNo, $target))
                }
            }
        }
    }

    if ($openFence) {
        $problems.Add(('{0}  代码围栏未闭合' -f $rel))
    }
}

Write-Host ''
Write-Host ('检查 Markdown 文件数: {0}' -f $files.Count)

if ($warnings.Count -gt 0) {
    Write-Host ('提示（非致命，GitHub 可正常渲染）：{0} 处标题层级跳级' -f $warnings.Count) -ForegroundColor Cyan
}

if ($problems.Count -gt 0) {
    Write-Host ('发现 {0} 个结构问题：' -f $problems.Count) -ForegroundColor Yellow
    $problems | ForEach-Object { Write-Host ('  ' + $_) }
    exit 1
}

Write-Host '所有 Markdown 文件的结构检查通过。' -ForegroundColor Green
exit 0
