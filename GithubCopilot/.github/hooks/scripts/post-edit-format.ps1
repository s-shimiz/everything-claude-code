# Post-Edit Format Hook (PowerShell)
# ファイル編集後に自動フォーマット
# Copilot Hooks: postToolUse で実行

$ErrorActionPreference = 'Continue'

$inputJson = [Console]::In.ReadToEnd()

$filePath = $null
if ($inputJson) {
    try {
        $obj = $inputJson | ConvertFrom-Json -ErrorAction SilentlyContinue
        if ($obj.toolArgs) {
            try {
                $args = $obj.toolArgs | ConvertFrom-Json -ErrorAction SilentlyContinue
                $filePath = $args.file_path
                if (-not $filePath) { $filePath = $args.file }
            } catch { }
        }
    } catch { }
}

if (-not $filePath -or -not (Test-Path $filePath)) { exit 0 }

$ext = [System.IO.Path]::GetExtension($filePath).TrimStart('.')

function Test-Cmd($cmd) {
    return [bool](Get-Command $cmd -ErrorAction SilentlyContinue)
}

try {
    switch -Regex ($ext) {
        '^(js|jsx|ts|tsx|mjs|cjs)$' {
            if ((Test-Path 'biome.json') -or (Test-Path 'biome.jsonc')) {
                if (Test-Cmd 'npx') {
                    & npx --no-install biome format --write $filePath 2>$null
                }
            } elseif ((Test-Path '.prettierrc') -or (Test-Path '.prettierrc.json') -or (Test-Path 'prettier.config.js')) {
                if (Test-Cmd 'npx') {
                    & npx --no-install prettier --write $filePath 2>$null
                }
            }
        }
        '^py$' {
            if (Test-Cmd 'ruff') {
                & ruff format $filePath 2>$null
            } elseif (Test-Cmd 'black') {
                & black --quiet $filePath 2>$null
            }
        }
        '^go$' {
            if (Test-Cmd 'gofmt') { & gofmt -w $filePath 2>$null }
        }
        '^rs$' {
            if (Test-Cmd 'rustfmt') { & rustfmt $filePath 2>$null }
        }
        '^java$' {
            if (Test-Cmd 'google-java-format') { & google-java-format -i $filePath 2>$null }
        }
        '^(kt|kts)$' {
            if (Test-Cmd 'ktlint') { & ktlint --format $filePath 2>$null }
        }
    }
} catch {
    # フォーマット失敗はセッションを止めない
}

exit 0
