# No-Verify Block Hook (PowerShell)
# git commit/push --no-verify をブロック
# Copilot Hooks: preToolUse で実行

$ErrorActionPreference = 'Continue'

$inputJson = [Console]::In.ReadToEnd()

$cmd = $null
if ($inputJson) {
    try {
        $obj = $inputJson | ConvertFrom-Json -ErrorAction SilentlyContinue
        if ($obj.toolArgs) {
            try {
                $args = $obj.toolArgs | ConvertFrom-Json -ErrorAction SilentlyContinue
                $cmd = $args.command
            } catch {
                $cmd = $obj.toolArgs
            }
        }
    } catch { }
}

if (-not $cmd) { exit 0 }

if ($cmd -match '\bgit\s+(commit|push)\b.*--no-verify\b') {
    [Console]::Error.WriteLine("BLOCKED: --no-verify flag detected")
    [Console]::Error.WriteLine("Command: $cmd")
    [Console]::Error.WriteLine("")
    [Console]::Error.WriteLine("Pre-commit / pre-push hooks exist to enforce quality and security.")
    [Console]::Error.WriteLine("If hooks are failing, fix the underlying issue rather than bypassing them.")
    exit 2
}

exit 0
