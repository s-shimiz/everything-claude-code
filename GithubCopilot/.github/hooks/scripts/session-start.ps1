# Session Start Hook (PowerShell)
# セッション開始時刻と作業ディレクトリをログに記録
# Copilot Hooks: sessionStart で実行

$ErrorActionPreference = 'Stop'

# stdin から JSON 入力を読む
$Input | Out-Null
$inputJson = [Console]::In.ReadToEnd()

# ログディレクトリを作成
$logDir = Join-Path (Get-Location) 'logs'
if (-not (Test-Path $logDir)) {
    New-Item -ItemType Directory -Path $logDir -Force | Out-Null
}

# セッション情報をログに追加
$logFile = Join-Path $logDir 'session.log'
$timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
$cwd = (Get-Location).Path

@"
════════════════════════════════════════
Session started: $timestamp
Working directory: $cwd
"@ | Add-Content -Path $logFile

if ($inputJson) {
    "Input: $inputJson" | Add-Content -Path $logFile
}

exit 0
