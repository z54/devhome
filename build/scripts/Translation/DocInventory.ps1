<#
.SYNOPSIS
    文档盘点与中文覆盖率报告（原子需求 DOC-02）。
.DESCRIPTION
    枚举仓库内的 Markdown 文件，统计「待译行数」与「已中文化行数」，输出按目录汇总与明细，
    可导出 CSV，并支持 CI 模式（-Check）：覆盖率低于阈值或结构异常时返回非零退出码。
.PARAMETER Path
    仓库根目录，默认为脚本所在位置的上级两级。
.PARAMETER Threshold
    CI 模式下要求的单文件最低中文覆盖率百分比，默认 100。
.PARAMETER Check
    开启校验模式，不满足阈值时返回退出码 1。
.PARAMETER Csv
    可选，导出明细为 CSV 的路径。
.EXAMPLE
    .\DocInventory.ps1
.EXAMPLE
    .\DocInventory.ps1 -Check -Csv .\docs-inventory.csv
#>
param(
    [string]$Path = (Resolve-Path (Join-Path $PSScriptRoot '..\..\..')).Path,
    [int]$Threshold = 100,
    [switch]$Check,
    [string]$Csv
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# 排除掉构建产物与第三方目录
$excludeDirPattern = '\\(node_modules|obj|bin|\.git|x64|ARM64|Debug|Release|packages)\\'

<#
.SYNOPSIS
    收集仓库内所有需要统计的 Markdown 文件。
#>
function Get-DocumentFile {
    param([string]$Root)
    Get-ChildItem -LiteralPath $Root -Recurse -File -Filter *.md |
        Where-Object { $_.FullName -notmatch $excludeDirPattern }
}

<#
.SYNOPSIS
    统计单个文件的行数与中文覆盖率。
.DESCRIPTION
    待译行的定义：不在代码块围栏内、非空、且包含至少 3 个连续英文字母的行。
    该行若同时包含汉字即视为「已译」。表格里纯标识符的行、纯中文的行都不计入，
    这样覆盖率真正反映「残留英文」的比例。
#>
function Measure-Document {
    param([System.IO.FileInfo]$File, [string]$Root)

    $lines = [System.IO.File]::ReadAllLines($File.FullName)
    $inFence = $false
    $translatable = 0
    $translated = 0
    $untranslated = [System.Collections.Generic.List[string]]::new()

    foreach ($line in $lines) {
        # 切换代码围栏状态，围栏行本身也不计入待译量
        if ($line -match '^\s*```') {
            $inFence = -not $inFence
            continue
        }
        if ($inFence) { continue }

        $trimmed = $line.Trim()
        # 无英文连续字符的行（纯中文、纯符号、纯数字）不需要翻译
        if ($trimmed -notmatch '[A-Za-z]{3,}') { continue }

        $translatable++
        if ($trimmed -match '[\u4e00-\u9fff]') {
            $translated++
        }
        elseif ($untranslated.Count -lt 5) {
            # 记录前几条未译行，便于定位漏译位置
            $untranslated.Add($trimmed.Substring(0, [math]::Min(120, $trimmed.Length)))
        }
    }

    $percent = if ($translatable -gt 0) { [math]::Round(100.0 * $translated / $translatable, 1) } else { 100.0 }

    [pscustomobject]@{
        File         = $File.FullName.Substring($Root.Length).TrimStart('\')
        Lines        = $lines.Count
        Translatable = $translatable
        Translated   = $translated
        Percent      = $percent
        Sample       = (@($untranslated) -join ' | ')
    }
}

$root = (Resolve-Path -LiteralPath $Path).Path.TrimEnd('\') + '\'
$results = foreach ($file in (Get-DocumentFile -Root $root)) {
    Measure-Document -File $file -Root $root
}

# 输出汇总
$totalTranslatable = ($results | Measure-Object -Property Translatable -Sum).Sum
$totalTranslated = ($results | Measure-Object -Property Translated -Sum).Sum
$overall = if ($totalTranslatable -gt 0) { [math]::Round(100.0 * $totalTranslated / $totalTranslatable, 1) } else { 0 }

Write-Host ''
Write-Host ('文档文件数: {0}' -f $results.Count)
Write-Host ('待译行数: {0} / 已译行数: {1} / 整体覆盖率: {2}%' -f $totalTranslatable, $totalTranslated, $overall)
Write-Host ''

# 已完成的排在前面，未完成的排在后面
$results | Sort-Object -Property Percent -Descending | Format-Table -AutoSize | Out-Host

if ($Csv) {
    $results | Export-Csv -LiteralPath $Csv -NoTypeInformation -Encoding UTF8
    Write-Host ('明细已导出: {0}' -f $Csv)
}

if (-not $Check) { exit 0 }

# ===== CI 校验模式 =====
$failures = @($results | Where-Object { $_.Percent -lt $Threshold })
if ($failures.Count -gt 0) {
    Write-Host ''
    Write-Host ('以下 {0} 个文件的中文覆盖率低于 {1}%：' -f $failures.Count, $Threshold) -ForegroundColor Yellow
    $failures | Sort-Object -Property Percent | Select-Object -First 20 | ForEach-Object {
        Write-Host ('  {0}  {1}%' -f $_.File, $_.Percent)
    }
    exit 1
}

Write-Host '所有 Markdown 文件的中文覆盖率已达到要求。' -ForegroundColor Green
exit 0
