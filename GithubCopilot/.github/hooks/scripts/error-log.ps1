# Error Log Hook (PowerShell)
# エージェント実行中のエラーをログに記録

$ErrorActionPreference = 'Continue'

$inputJson = [Console]::In.ReadToEnd()

$logDir = Join-Path (Get-Location) 'logs'
if (-not (Test-Path $logDir)) {
    New-Item -ItemType Directory -Path $logDir -Force | Out-Null
}

$logFile = Join-Path $logDir 'errors.log'
$timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'

@"
═══ Error: $timestamp ═══
$inputJson

"@ | Add-Content -Path $logFile

exit 0
