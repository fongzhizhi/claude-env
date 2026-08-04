# claude-env
Claude Code 完整环境配置 · 技能库 · 智能体 · 一键部署 环境即代码 —— 跨设备同步你的 AI 编程工作流。

## 快速开始

```bash
git clone <仓库地址>
cd claude-env
npm run deploy
```

`npm run deploy` 会依次执行：
1. `deploy:claude` — 部署 Claude Code 环境配置
2. `deploy:vscode` — 部署 VSCode 配置

### 模型切换

```bash
npm run switch:deepseek
npm run switch:zhipu
npm run switch:company
```

### VSCode 配置

本仓库同步管理 VSCode 的 Claude Code 插件配置。

**一键部署 VSCode 配置：**
```bash
npm run deploy:vscode
```

该命令会：
1. 备份你当前的 VSCode 用户配置
2. 将仓库中的 `.config/vscode/settings.json` 部署到 `%APPDATA%/Code/User/settings.json`
3. 提示重新加载 VSCode

**手动部署：** 参考 `.config/vscode/README.md`
