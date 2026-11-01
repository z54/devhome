# 中文化术语表与禁译清单

> 关联原子需求：**DOC-01**（基线与规则，P0）
> 本文件是「文档与代码注释中文化」的**单一事实来源**：所有 DOC-05 ~ DOC-16、CMT-05 ~ CMT-16 的翻译与评审都以此为准。
> 版本：v1（2026-11-01）

## 1. 排版规则（决策 5）

| 规则 | 正确 | 错误 |
| --- | --- | --- |
| 中文与英文/数字之间加**一个半角空格** | `Dev Home 的扩展`、`共 12 个文件`、`使用 WinGet 安装` | `DevHome的扩展`、`共12个文件` |
| 纯中文之间不加空格 | `这是设置界面左侧的导航` | `这是 设置 界面 左侧 的 导航` |
| 英文术语（见第 2 节术语表）与相邻中文之间加空格 | `创建一个新的 Widget` | `创建一个新的Widget` |
| 标点用中文全角 | 用「，。：；？！」和引号「」 | 用英文逗号句号 |
| 括号例外：代码/标识符内的括号保持半角 | `GetLocalized(key)`、`SetupFlow` | `GetLocalized（key）` |
| 数字与单位之间加空格 | `800 行`、`20 KB` | `800行` |
| 百分号、摄氏度不加空格 | `88.4%` | `88.4 %` |
| 代码块中的一切内容（含注释）不在此「自动加空格」之列，按代码规则处理 | | |

> 例外：`x:Uid`、`resw` 里的 `{0}`、`ms-resource` 之类的标记**整体保留**，前后照常加空格。

## 2. 术语表

### 2.1 产品与组件名（不翻译）

| 英文 | 处理 | 说明 |
| --- | --- | --- |
| Dev Home | 保留 | 产品名称，前后加空格 |
| PowerToys | 保留 | 外部产品名称 |
| Windows Sandbox | 保留 | 产品名 |
| Hyper-V | 保留 | 连字符与大小写保持原样 |
| WSL / Windows Subsystem for Linux | 首次出现写全称，之后可用 WSL | |
| Visual Studio | 保留 | |
| GitHub | 保留 | |
| Microsoft Store | 保留 | |

### 2.2 核心概念

| 英文 | 中文 | 备注 |
| --- | --- | --- |
| extension | 扩展 | |
| provider / provider type | 提供程序 / 提供程序类型 | 代码里指 `ProviderType` 时用「提供程序类型」 |
| compute system | 计算系统 | 本机、虚拟机、远程计算机、容器的统称 |
| compute system provider | 计算系统提供程序 | |
| environment | 环境 | 指 Environments 工具创建与管理的一个环境实例；统一译「环境」 |
| widget | Widget（首字母大写，不译） | 界面控件品牌名 |
| dashboard | 仪表板 | |
| repository | 仓库 | 与 Git 仓库同义；不要译成「存储库」 |
| clone / cloning | 克隆 / 克隆操作 | |
| source control | 源代码管理 | 不要译「源码控制」混用 |
| file explorer integration | 文件资源管理器集成 | |
| local repository | 本地仓库 | |
| configuration file | 配置文件 | |
| DSC / Desired State Configuration | DSC / Desired State Configuration | 首次出现写全称 |
| DSC resource | DSC 资源 | |
| WinGet / Windows Package Manager | WinGet / Windows Package Manager | 首次出现写全称 |
| package | 包 | 安装包、NuGet 包 |
| app install | 应用安装 | |
| setup flow | 安装配置流程 | 指 SetupFlow 工具；代码里 `ISetupFlowService` 之类标识符不译 |
| flow page | 流程页 | |
| review view | 复核视图 | |
| summary view | 摘要视图 | |
| Dev Drive | Dev Drive（不译） | 产品特性名 |
| Dev Drive insights | Dev Drive 洞察 | |
| optimization / optimize | 优化 | |
| pinned / unpinned | 已固定 / 未固定 | 指 assembly pinning → 「（程序集）固定」 |
| elevation / elevated | 提权 / 已提权 | |
| elevated server | 提权服务端 | DevHome.SetupFlow.ElevatedServer |
| IPC | IPC | 进程间通信，保留缩写 |
| shell page | 外壳页 | `ShellPage` 内的 Shell → 外壳 |
| navigation view | 导航视图 | |
| nav config | 导航配置 | `NavConfig.jsonc` |
| infobar | 信息栏 | `InfoBar` |
| breadcrumb | 面包屑 | |
| adaptive card | 自适应卡片 | |
| telemetry | 遥测 | |
| telemetry event | 遥测事件 | |
| SDK | SDK | |
| SDK contract | SDK 契约 | `.idl` 里的 `apicontract` |
| interface | 接口 | |
| enumeration / enum | 枚举 | |
| delegate | 委托 | |
| worker thread | 工作线程 | |
| async / await | 异步 / 等待 | 注释里写「异步」即可 |
| cancellation token | 取消令牌 | |
| event args | 事件参数 | `EventArgs` |
| throw / exception | 抛出 / 异常 | |
| log / logger | 日志 / 日志记录器 | |
| fallback | 回退 | |
| retry | 重试 | |
| discovery | 发现 | 指 UI automation discovery → 「发现（元素）」 |
| smoke test | 冒烟测试 | |
| permission | 权限 | |
| file dialog | 文件对话框 | |
| secondary window | 辅助窗口 | |
| GPO / Group Policy | GPO / 组策略 | |
| MSIX | MSIX | |
| sideload | 旁加载 | |
| dark mode / light mode | 深色模式 / 浅色模式 | |
| theme | 主题 | |
| accessibility label | 无障碍标签 | |
| AutomationId | AutomationId | 保留原样 |
| sign / authenticode | 签名 | 动词统一译「签名」，名词「code signing」译「代码签名」 |
| roll back | 回滚 | |
| rollout | 推出 | |

> 规则：同一英文在本表中只有一种译法；发现同义词（如「存储库」vs「仓库」）一律以本表为准。

## 3. 禁译清单（Do-Not-Translate）

以下内容一律保留原文，包括大小写：

1. **产品与商标名**：Dev Home、PowerToys、Windows Sandbox、Hyper-V、Visual Studio、Microsoft Store、GitHub、WinGet、MSIX、NuGet。
2. **代码标识符**：类名、接口名（`IComputeSystem`、`IComputeSystemProvider`）、枚举值、方法名、属性名、变量名、命名空间、资源键、resw 键名。
3. **命令行与工具**：`winget`、`pwsh`、`dotnet`、`msbuild`、`git`、`midl`、`clang-format`；命令行开关 `-WhatIf`、`--check`。
4. **路径、环境变量、注册表路径**：`%LOCALAPPDATA%`、`HKEY_LOCAL_MACHINE\...`、`C:\Program Files\...`。
5. **URL 与邮箱**：GitHub 链接、MSRC 邮箱、`aka.ms/...`。
6. **语言与区域标记**：`en-US`、`zh-CN`、`ar-SA`（BCP-47 大小写形式必须保留）。
7. **格式化占位符与正则**：`{0}`、`%s`、正则式、`x:Uid`、`ms-resource`、`x-generate`。
8. **许可与第三方声明**：MIT 许可正文、`NOTICE.txt`、第三方 copyright。
9. **`TODO` / `FIXME` / `HACK` / `BUG` 前缀与工单号**（`#2072`）。
10. **Issue/PR/Milestone 编号与标题中的标识符**。

## 4. 句式风格

- 使用陈述句与主动语态，避免「被…所」式翻译腔。
- 可以补出英文省略的主语时要补出（例：`Returns true if...` → `如果……，则返回 true。`）。
- 一句话表达一个动作；原文被动语态可改为中文习惯表达（如 `The dialog is shown` → `显示对话框`）。
- 保持与原文相同的时态语义（将来/可能/必须），`must` 译为「必须」、`should` 译为「建议」、`may` 译为「可能」。
- 不要添加原文没有的技术信息；也不要省略条件句。
