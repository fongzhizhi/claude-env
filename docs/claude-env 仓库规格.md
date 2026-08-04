# claude-env 仓库规格文档 (SPEC.md)

## 1. 项目概述

### 1.1 项目名称
`claude-env` — Claude Code 环境配置仓库

### 1.2 项目定位

> **环境即代码 (Environment as Code)**

这是一个用于**版本化管理 Claude Code 完整开发环境**的 Git 仓库。其核心目标是将分散在本地各处的配置、技能（Skills）、智能体（Agents）、提示词模板等资产集中管理，实现跨设备、跨项目的快速环境恢复与同步。

### 1.3 核心理念

- **配置是代码**：所有配置均可追溯、可回滚、可审查。
- **手段服务于本质**：一键部署、脚本切换是手段，核心是环境本身的可移植性和一致性。
- **安全第一**：敏感信息（API Key、Token）通过环境变量或 `.gitignore` 隔离，绝不硬编码进仓库。

### 1.4 核心能力

| 能力 | 说明 |
| :--- | :--- |
| **一键部署** | 新设备上 `git clone` + `npm run deploy` 即可恢复完整环境 |
| **多模型切换** | 通过脚本在 DeepSeek、智谱、Agnes 等模型间快速切换 |
| **Skill 版本管理** | 所有自定义 Skill 集中管理，可追溯变更历史 |
| **跨设备同步** | 台式机、笔记本、公司电脑保持一致的 AI 编程体验 |
| **配置分层** | 通用配置与私有配置分离，安全且灵活 |


## 2. 设计原则

| 原则 | 说明 |
| :--- | :--- |
| **模块化 (Modular)** | 配置按职责拆分：基础配置、Skill、Agent、项目级覆盖 |
| **可移植 (Portable)** | 仓库结构独立于操作系统，Windows/macOS/Linux 均可部署 |
| **可扩展 (Extensible)** | 新增 Skill / Agent 只需在对应目录添加文件，无需修改核心逻辑 |
| **零摩擦 (Zero Friction)** | 新设备上从 `git clone` 到 `npm run deploy` 即可投入使用 |
| **安全分层 (Security Layers)** | 敏感信息通过环境变量或本地覆盖文件隔离，Git 仓库仅存模板 |


## 3. 目录结构设计

```
claude-env/
├── .claude/                               # 核心配置目录（映射到 ~/.claude）
│   ├── settings.json                      # 主配置（不含敏感信息）
│   ├── profiles/                          # 配置模板目录（提交 Git）
│   │   ├── deepseek.template.json         # DeepSeek 配置模板
│   │   ├── zhipu.template.json            # 智谱配置模板
│   │   ├── agnes.template.json            # Agnes 配置模板
│   │   └── company.template.json          # 公司配置模板（可选）
│   ├── skills/                            # 技能库
│   │   ├── core/                          # 核心技能（通用）
│   │   │   ├── spec.SKILL.md              # 从0到1生成项目
│   │   │   ├── code-review.SKILL.md       # 代码审查
│   │   │   └── git-commit.SKILL.md        # 生成规范化提交信息
│   │   ├── project/                       # 项目特定技能
│   │   │   ├── fastapi.SKILL.md
│   │   │   ├── react.SKILL.md
│   │   │   └── python.SKILL.md
│   │   └── experimental/                  # 实验中的技能
│   │       └── test-gen.SKILL.md
│   ├── agents/                            # 智能体配置
│   │   ├── architect.SKILL.md             # 架构师模式
│   │   ├── debugger.SKILL.md              # 调试模式
│   │   └── doc-writer.SKILL.md            # 文档生成模式
│   └── templates/                         # 代码/文档模板
│       ├── README.md.template
│       └── api-endpoint.py.template
├── scripts/                               # 部署与工具脚本
│   ├── deploy.ps1                         # Windows 一键部署脚本
│   ├── deploy.sh                          # macOS/Linux 一键部署脚本
│   ├── switch-profile.ps1                 # 模型切换脚本（核心）
│   ├── switch-profile.bat                 # 双击运行的批处理入口
│   ├── backup.ps1                         # 备份当前配置
│   └── validate.ps1                       # 校验配置是否正确
├── docs/                                  # 文档
│   ├── SETUP.md                           # 详细安装指南
│   ├── SKILLS.md                          # Skill 编写与使用指南
│   └── TROUBLESHOOTING.md                 # 常见问题排查
├── .env.example                           # 环境变量模板
├── .gitignore                             # Git 忽略规则
├── package.json                           # npm 脚本入口
├── README.md                              # 项目首页
└── SPEC.md                                # 本文件（规格说明）
```


## 4. 核心文件规范

### 4.1 `settings.json` 结构

主配置文件，存放通用、非敏感的配置。可安全提交到 Git。

```json
{
  "env": {
    "ANTHROPIC_DEFAULT_OPUS_MODEL": "deepseek-v4-pro",
    "ANTHROPIC_DEFAULT_SONNET_MODEL": "deepseek-v4-flash",
    "ANTHROPIC_DEFAULT_HAIKU_MODEL": "deepseek-v4-flash",
    "CLAUDE_CODE_SUBAGENT_MODEL": "deepseek-v4-flash",
    "CLAUDE_CODE_EFFORT_LEVEL": "max",
    "DISABLE_INSTALLATION_CHECKS": "1",
    "MAX_THINKING_TOKENS": "10000",
    "CLAUDE_AUTOCOMPACT_PCT_OVERRIDE": "50"
  },
  "permissions": {
    "defaultMode": "acceptEdits"
  },
  "theme": "dark-ansi",
  "allowedTools": [
    "Read",
    "Write",
    "Edit",
    "Bash"
  ]
}
```

**关键设计**：
- 不包含任何真实的 API Key 或 Token
- 不包含 `ANTHROPIC_BASE_URL`（由 `settings.local.json` 提供）
- 不包含 `ANTHROPIC_AUTH_TOKEN`（由系统环境变量提供）
- 模型名称映射（`ANTHROPIC_DEFAULT_*_MODEL`）为通用偏好，不绑定具体提供商

### 4.2 `profiles/*.template.json` 模板文件

每个模板文件是一个**完整的 `settings.local.json`**，包含通用配置 + 提供商特有配置，**不含真实 API Key**，使用占位符。切换时整体替换目标文件。

**`profiles/deepseek.template.json`**：
```json
{
  "env": {
    "ANTHROPIC_BASE_URL": "https://api.deepseek.com/anthropic",
    "ANTHROPIC_AUTH_TOKEN": "YOUR_DEEPSEEK_API_KEY_HERE",
    "ANTHROPIC_MODEL": "deepseek-v4-flash",
    "ANTHROPIC_DEFAULT_OPUS_MODEL": "deepseek-v4-pro",
    "ANTHROPIC_DEFAULT_SONNET_MODEL": "deepseek-v4-flash",
    "ANTHROPIC_DEFAULT_HAIKU_MODEL": "deepseek-v4-flash",
    "CLAUDE_CODE_SUBAGENT_MODEL": "deepseek-v4-flash",
    "CLAUDE_CODE_EFFORT_LEVEL": "max",
    "DISABLE_INSTALLATION_CHECKS": "1",
    "MAX_THINKING_TOKENS": "10000",
    "CLAUDE_AUTOCOMPACT_PCT_OVERRIDE": "50"
  },
  "permissions": {
    "defaultMode": "acceptEdits"
  },
  "theme": "dark-ansi",
  "allowedTools": ["Read", "Write", "Edit", "Bash"]
}
```

**`profiles/zhipu.template.json`**：
```json
{
  "env": {
    "ANTHROPIC_BASE_URL": "https://open.bigmodel.cn/api/anthropic",
    "ANTHROPIC_AUTH_TOKEN": "YOUR_ZHIPU_API_KEY_HERE",
    "ANTHROPIC_MODEL": "glm-4-flash",
    "ANTHROPIC_DEFAULT_OPUS_MODEL": "glm-4-plus",
    "ANTHROPIC_DEFAULT_SONNET_MODEL": "glm-4-flash",
    "ANTHROPIC_DEFAULT_HAIKU_MODEL": "glm-4-flash",
    "CLAUDE_CODE_SUBAGENT_MODEL": "glm-4-flash",
    "CLAUDE_CODE_EFFORT_LEVEL": "max",
    "DISABLE_INSTALLATION_CHECKS": "1",
    "MAX_THINKING_TOKENS": "10000",
    "CLAUDE_AUTOCOMPACT_PCT_OVERRIDE": "50"
  },
  "permissions": {
    "defaultMode": "acceptEdits"
  },
  "theme": "dark-ansi",
  "allowedTools": ["Read", "Write", "Edit", "Bash"]
}
```

**`profiles/agnes.template.json`**：
```json
{
  "env": {
    "ANTHROPIC_BASE_URL": "https://api.agnes-ai.cn/v1",
    "ANTHROPIC_AUTH_TOKEN": "YOUR_AGNES_API_KEY_HERE",
    "ANTHROPIC_MODEL": "agnes-2.0-flash",
    "ANTHROPIC_DEFAULT_OPUS_MODEL": "agnes-2.5-flash",
    "ANTHROPIC_DEFAULT_SONNET_MODEL": "agnes-2.0-flash",
    "ANTHROPIC_DEFAULT_HAIKU_MODEL": "agnes-2.0-flash",
    "CLAUDE_CODE_SUBAGENT_MODEL": "agnes-2.0-flash",
    "CLAUDE_CODE_EFFORT_LEVEL": "max",
    "DISABLE_INSTALLATION_CHECKS": "1",
    "MAX_THINKING_TOKENS": "10000",
    "CLAUDE_AUTOCOMPACT_PCT_OVERRIDE": "50"
  },
  "permissions": {
    "defaultMode": "acceptEdits"
  },
  "theme": "dark-ansi",
  "allowedTools": ["Read", "Write", "Edit", "Bash"]
}
```

**`profiles/company.template.json`**（可选）：
```json
{
  "env": {
    "ANTHROPIC_BASE_URL": "YOUR_COMPANY_BASE_URL_HERE",
    "ANTHROPIC_AUTH_TOKEN": "YOUR_COMPANY_API_KEY_HERE",
    "ANTHROPIC_MODEL": "deepseek-v4-pro",
    "ANTHROPIC_DEFAULT_OPUS_MODEL": "deepseek-v4-pro",
    "ANTHROPIC_DEFAULT_SONNET_MODEL": "deepseek-v4-flash",
    "ANTHROPIC_DEFAULT_HAIKU_MODEL": "deepseek-v4-flash",
    "CLAUDE_CODE_SUBAGENT_MODEL": "deepseek-v4-flash",
    "CLAUDE_CODE_EFFORT_LEVEL": "max",
    "DISABLE_INSTALLATION_CHECKS": "1",
    "MAX_THINKING_TOKENS": "10000",
    "CLAUDE_AUTOCOMPACT_PCT_OVERRIDE": "50"
  },
  "permissions": {
    "defaultMode": "acceptEdits"
  },
  "theme": "dark-ansi",
  "allowedTools": ["Read", "Write", "Edit", "Bash"]
}
```

### 4.3 `settings.local.json` 运行时配置

由脚本从模板生成，**绝不提交到 Git**。位于仓库 `.claude/settings.local.json` 和用户目录 `~/.claude/settings.local.json`（脚本会同步更新两处）。

```json
{
  "env": {
    "ANTHROPIC_BASE_URL": "https://api.deepseek.com/anthropic",
    "ANTHROPIC_AUTH_TOKEN": "sk-真实的API Key",
    "ANTHROPIC_MODEL": "deepseek-v4-flash"
  }
}
```

### 4.4 `SKILL.md` 规范

所有 Skill 必须遵循以下格式：

```markdown
---
name: skill-name                    # 必填：唯一标识，小写+连字符
description: 技能的简短描述           # 必填：供Agent识别使用场景
compatibility: opencode|claude       # 可选：兼容性标注
version: 1.0.0                       # 可选：版本号
tags: [python, fastapi, backend]     # 可选：标签，便于搜索
---

## 工作流程

### 触发条件
描述什么情况下Agent应该调用此Skill。

### 执行步骤
1. 步骤一
2. 步骤二
3. 步骤三

### 注意事项
- 注意事项1
- 注意事项2

## 输出规范
描述生成的代码/文档应符合什么标准。
```


## 5. 部署流程设计

### 5.1 标准部署流程

```
git clone 仓库
    ↓
npm install (或直接运行脚本)
    ↓
npm run deploy
    ↓
检查 ~/.claude 是否已存在 → 是 → 备份到 .claude.backup.{timestamp}
    ↓ 否
复制配置到 ~/.claude
    ↓
检查 settings.local.json 是否存在 → 否 → 从 profiles/deepseek.template.json 生成
    ↓ 是
完成
```

### 5.2 部署脚本核心逻辑 (`deploy.ps1`)

1. **备份检查**：若 `~/.claude` 已存在，重命名为 `~/.claude.backup.{timestamp}`
2. **复制配置**：将仓库中的 `.claude/` 目录复制到 `~/.claude`（**跳过 `settings.local.json`**）
3. **首次配置**：检测 `settings.local.json` 是否存在，若不存在则从 `profiles/deepseek.template.json` 生成
4. **环境检测**：提示用户检查 API Key 是否已配置
5. **输出报告**：显示部署状态、下一步操作指引

### 5.3 模型切换脚本 (`switch-profile.ps1`)

**功能**：快速在 DeepSeek、智谱、Agnes 等模型间切换。

**核心逻辑**：
1. 从 `profiles/` 目录读取指定的 `.template` 文件
2. 如果 `settings.local.json` 已存在，**保留原有的 API Key**，只更新 `BASE_URL` 和 `MODEL`
3. 如果 `settings.local.json` 不存在，从模板生成并提示用户填写 API Key
4. 同步更新仓库目录和用户目录 (`~/.claude/`) 的 `settings.local.json`
5. 输出切换结果，提示重启 Claude Code

**用法**：
```powershell
# 切换到 DeepSeek
.\scripts\switch-profile.ps1 deepseek

# 切换到智谱
.\scripts\switch-profile.ps1 zhipu

# 切换到 Agnes
.\scripts\switch-profile.ps1 agnes

# 无参数运行：显示可用模板列表
.\scripts\switch-profile.ps1
```

或通过 npm：
```bash
npm run switch:deepseek
npm run switch:zhipu
npm run switch:agnes
npm run switch:company
```

或双击 `scripts/switch-profile.bat`，按菜单提示选择。

### 5.4 npm 脚本入口 (`package.json`)

```json
{
  "name": "claude-env",
  "version": "1.0.0",
  "description": "Claude Code 环境即代码 —— 技能、智能体、配置，一键跨设备同步",
  "scripts": {
    "deploy": "powershell -ExecutionPolicy Bypass -File scripts/deploy.ps1",
    "switch": "powershell -ExecutionPolicy Bypass -File scripts/switch-profile.ps1",
    "switch:deepseek": "npm run switch deepseek",
    "switch:zhipu": "npm run switch zhipu",
    "switch:agnes": "npm run switch agnes",
    "switch:company": "npm run switch company",
    "backup": "powershell -ExecutionPolicy Bypass -File scripts/backup.ps1",
    "validate": "powershell -ExecutionPolicy Bypass -File scripts/validate.ps1"
  },
  "keywords": ["claude-code", "skills", "ai-agent", "dotfiles", "environment-as-code"],
  "author": "",
  "license": "MIT"
}
```

**关键设计**：使用 PowerShell 脚本实现配置切换，同时提供 `.bat` 双击入口和 npm 命令两种使用方式。


## 6. .gitignore 配置

```gitignore
# Claude Code 本地配置（包含 API Key，绝不提交！）
.claude/settings.local.json
**/.claude/settings.local.json
*.secret.json

# 环境变量
.env
!.env.example

# 备份
.claude.backup.*
*.backup.*

# 系统文件
.DS_Store
Thumbs.db
*.log

# IDE 配置
.vscode/
.idea/
```

**关键点**：`settings.local.json` 被 Git 忽略，确保 API Key 永不泄漏。


## 7. 版本管理与迭代策略

### 7.1 版本号规范 (语义化版本)

| 版本号 | 说明 |
| :--- | :--- |
| **MAJOR** | 不兼容的目录结构调整或配置格式变更 |
| **MINOR** | 新增 Skill、Agent 或配置项 |
| **PATCH** | Bug 修复、文档更新、脚本优化 |

### 7.2 分支策略

- `main`：稳定版本，经过验证的配置
- `develop`：开发中，包含实验性 Skill
- `feature/*`：单功能分支

### 7.3 变更日志 (`CHANGELOG.md`)

每次发布记录：
- 新增的 Skill / Agent
- 配置变更
- 破坏性变更说明及迁移指南


## 8. 安全策略

### 8.1 绝对禁止提交的内容

以下内容**绝不**提交到仓库：
- 真实的 API Key / Token
- 包含敏感信息的 `settings.local.json`
- 包含个人项目路径的配置
- `.env` 文件
- 任何包含 `*.secret.json` 的文件

### 8.2 安全措施

- **`.gitignore` 防护**：明确忽略所有可能包含敏感信息的文件
- **模板占位符**：所有模板使用 `YOUR_*_HERE` 格式占位符
- **脚本保留 Key**：切换脚本保留已有的 API Key，不覆盖

### 8.3 安全扫描建议

建议配置：
- GitHub Secrets 扫描（自动检测提交的敏感信息）
- pre-commit hook（提交前检查是否包含 API Key）


## 9. 后续迭代方向

### v1.0.0 (MVP)
- [x] 基础目录结构设计
- [x] `settings.json` 核心配置
- [x] 3+ 核心 Skill (spec, code-review, git-commit)
- [x] 4+ 配置模板 (DeepSeek, 智谱, Agnes, 公司)
- [x] 跨平台部署脚本 (Node.js)
- [x] 模型切换脚本
- [x] README 文档

### v1.1.0
- [ ] 新增 5+ 常用 Skill
- [ ] 配置校验工具 (`validate.js`)
- [ ] Skill 依赖管理

### v1.2.0
- [ ] Skill 依赖管理 (如指定需要安装的 npm/pip 包)
- [ ] 多环境配置 (work/home 切换)
- [ ] 交互式部署向导

### v2.0.0
- [ ] 支持 OpenCode 配置 (双工具兼容)
- [ ] Skill 市场集成 (可拉取社区Skill)
- [ ] 配置变更自动检测与提示


## 10. 成功指标

| 指标 | 目标 |
| :--- | :--- |
| 新设备从0到可用 | < 3 分钟 |
| 配置同步成功率 | 100% (无人工干预) |
| Skill 复用率 | ≥ 80% (跨项目复用) |
| 模型切换耗时 | < 10 秒 |
| 仓库月活跃更新 | ≥ 4 次 |


## 11. 参考资源

- [Claude Code 官方文档](https://code.claude.com/docs)
- [Agent Skills 开放标准](https://agentskills.io)
- [DeepSeek API 文档](https://api-docs.deepseek.com)
- [智谱 AI API 文档](https://open.bigmodel.cn/doc)
- [语义化版本规范](https://semver.org/lang/zh-CN/)


*本文档将随仓库迭代更新。最新版请参考仓库根目录的 `SPEC.md`。*