#!/usr/bin/env pwsh
# Claude Code 模型切换脚本
# 用法: .\switch-profile.ps1 <profile_name>
# 示例: .\switch-profile.ps1 deepseek

$ErrorActionPreference = "Stop"

# 确保向 UTF-8 终端（Git Bash / VSCode 终端）输出中文不乱码
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

# 获取脚本所在目录的父目录（仓库根目录）
$RepoRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$TemplatesDir = Join-Path $RepoRoot ".claude\profiles"
$TargetFile = Join-Path $RepoRoot ".claude\settings.local.json"
$UserTargetFile = Join-Path $env:USERPROFILE ".claude\settings.local.json"

# 如果没有传入参数，显示菜单
if ($args.Count -eq 0) {
    Write-Host ""
    Write-Host "╔════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║   Claude Code 模型切换器              ║" -ForegroundColor Cyan
    Write-Host "╚════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""

    $Templates = Get-ChildItem -Path $TemplatesDir -Filter "*.template.json" | ForEach-Object { $_.BaseName -replace '\.template$', '' }

    if ($Templates.Count -eq 0) {
        Write-Host "❌ 没有找到配置模板！" -ForegroundColor Red
        Write-Host "请在 $TemplatesDir 下创建 .template.json 文件。" -ForegroundColor Yellow
        exit 1
    }

    Write-Host "📋 可用的配置模板：" -ForegroundColor Yellow
    for ($i = 0; $i -lt $Templates.Count; $i++) {
        Write-Host "  [$($i+1)] $($Templates[$i])"
    }
    Write-Host ""
    Write-Host "💡 用法: .\switch-profile.ps1 <模板名称>" -ForegroundColor Gray
    Write-Host "   例如: .\switch-profile.ps1 deepseek" -ForegroundColor Gray
    exit 0
}

$ProfileName = $args[0]
$TemplateFile = Join-Path $TemplatesDir "$ProfileName.template.json"

if (-not (Test-Path $TemplateFile)) {
    Write-Host "❌ 模板 '$ProfileName' 不存在！" -ForegroundColor Red
    Write-Host "可用的模板: " -ForegroundColor Yellow
    Get-ChildItem -Path $TemplatesDir -Filter "*.template.json" | ForEach-Object { Write-Host "  - $($_.BaseName -replace '\.template$', '')" }
    exit 1
}

# 读取模板内容
$TemplateContent = Get-Content -Path $TemplateFile -Raw | ConvertFrom-Json

# 如果仓库目标文件已存在，保留原有的 API Key
if (Test-Path $TargetFile) {
    $ExistingConfig = Get-Content -Path $TargetFile -Raw | ConvertFrom-Json
    if ($ExistingConfig.env.ANTHROPIC_AUTH_TOKEN -and $ExistingConfig.env.ANTHROPIC_AUTH_TOKEN -notmatch "YOUR_.*_HERE") {
        $TemplateContent.env.ANTHROPIC_AUTH_TOKEN = $ExistingConfig.env.ANTHROPIC_AUTH_TOKEN
        Write-Host "🔑 已保留原有的 API Key" -ForegroundColor Green
    } else {
        Write-Host "⚠️  请手动填写 API Key" -ForegroundColor Yellow
    }
} else {
    Write-Host "⚠️  首次使用，请填写真实的 API Key" -ForegroundColor Yellow
}

# 写入仓库目标文件
$TemplateContent | ConvertTo-Json -Depth 10 | Set-Content -Path $TargetFile -Encoding UTF8
Write-Host "✅ 仓库配置已切换到: $ProfileName" -ForegroundColor Green

# 同时更新用户级配置（如果存在）
if (Test-Path (Split-Path $UserTargetFile -Parent)) {
    # 如果用户级配置存在，也同步更新 Base URL 和 Model，保留 Key
    if (Test-Path $UserTargetFile) {
        $UserConfig = Get-Content -Path $UserTargetFile -Raw | ConvertFrom-Json
        $TemplateContent.env.ANTHROPIC_AUTH_TOKEN = $UserConfig.env.ANTHROPIC_AUTH_TOKEN
    }
    $TemplateContent | ConvertTo-Json -Depth 10 | Set-Content -Path $UserTargetFile -Encoding UTF8
    Write-Host "✅ 用户级配置已同步切换到: $ProfileName" -ForegroundColor Green
}

Write-Host ""
Write-Host "🔄 请重启 Claude Code 使配置生效" -ForegroundColor Cyan