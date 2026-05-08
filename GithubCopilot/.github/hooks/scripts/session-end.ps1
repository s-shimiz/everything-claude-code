# Session End Hook (PowerShell)
# セッション終了時刻を記録 + 未コミット警告

$ErrorActionPreference = 'Continue'

$logDir = Join-Path (Get-Location) 'logs'
if (-not (Test-Path $logDir)) {
    New-Item -ItemType Directory -Path $logDir -Force | Out-Null
}

$logFile = Join-Path $logDir 'session.log'
$timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
"Session ended: $timestamp" | Add-Content -Path $logFile

if ((Get-Command git -ErrorAction SilentlyContinue) -and (Test-Path '.git')) {
    try {
        $statusOutput = & git status --porcelain 2>$null
        $uncommitted = if ($statusOutput) { @($statusOutput).Count } else { 0 }
        if ($uncommitted -gt 0) {
            [Console]::Error.WriteLine("[Hook] Reminder: $uncommitted uncommitted changes remain")
            [Console]::Error.WriteLine("[Hook] Consider committing before ending the session")
        }

        # 未プッシュコミット
        $upstream = & git rev-parse --abbrev-ref '@{u}' 2>$null
        if ($LASTEXITCODE -eq 0 -and $upstream) {
            $unpushedOutput = & git log --oneline '@{u}..HEAD' 2>$null
            $unpushed = if ($unpushedOutput) { @($unpushedOutput).Count } else { 0 }
            if ($unpushed -gt 0) {
                [Console]::Error.WriteLine("[Hook] Reminder: $unpushed unpushed commits")
            }
        }
    } catch { }
}

exit 0
