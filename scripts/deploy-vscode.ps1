#!/usr/bin/env pwsh
# VSCode 配置一键部署脚本
# 用法: npm run deploy:vscode

$ErrorActionPreference = "Stop"

# 确保向 UTF-8 终端（Git Bash / VSCode 终端）输出中文不乱码
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$RepoRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$ConfigFile = Join-Path $RepoRoot ".config\vscode\settings.json"
$VSCodeConfigPath = "$env:APPDATA\Code\User\settings.json"

Write-Host "🚀 开始部署 VSCode 配置..." -ForegroundColor Cyan

# 检查目标文件是否存在，存在则备份
if (Test-Path $VSCodeConfigPath) {
    $BackupPath = "$env:APPDATA\Code\User\settings.json.backup.$(Get-Date -Format 'yyyyMMdd_HHmmss')"
    Copy-Item -Path $VSCodeConfigPath -Destination $BackupPath
    Write-Host "📦 已备份原配置到: $BackupPath" -ForegroundColor Green
}

# 复制新配置
Copy-Item -Path $ConfigFile -Destination $VSCodeConfigPath -Force
Write-Host "✅ VSCode 配置已部署！" -ForegroundColor Green
Write-Host "🔄 请重新加载 VSCode 窗口 (Ctrl+Shift+P -> Reload Window)" -ForegroundColor Cyan
