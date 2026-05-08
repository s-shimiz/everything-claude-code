# Secrets Scan Hook (PowerShell)
# Write/Edit 対象ファイルにハードコードされたシークレットがないかスキャン
# Copilot Hooks: preToolUse で実行

$ErrorActionPreference = 'Continue'

$inputJson = [Console]::In.ReadToEnd()

$patterns = @(
    # AWS
    'AKIA[0-9A-Z]{16}',
    'aws_secret_access_key\s*=\s*[A-Za-z0-9/+=]{40}',
    # GitHub
    'ghp_[A-Za-z0-9]{36}',
    'github_pat_[A-Za-z0-9_]{82}',
    'ghs_[A-Za-z0-9]{36}',
    # OpenAI / Anthropic
    'sk-proj-[A-Za-z0-9]{20,}',
    'sk-ant-[A-Za-z0-9-]{20,}',
    # Slack
    'xox[baprs]-[A-Za-z0-9-]{10,}',
    # Stripe
    'sk_live_[A-Za-z0-9]{24,}',
    'rk_live_[A-Za-z0-9]{24,}',
    # Generic
    'BEGIN (RSA|OPENSSH|EC|DSA|PGP) PRIVATE KEY'
)

$content = $null
$filePath = $null
if ($inputJson) {
    try {
        $obj = $inputJson | ConvertFrom-Json -ErrorAction SilentlyContinue
        if ($obj.toolArgs) {
            try {
                $args = $obj.toolArgs | ConvertFrom-Json -ErrorAction SilentlyContinue
                $content = $args.content
                if (-not $content) { $content = $args.new_content }
                if (-not $content) { $content = $args.new_string }
                $filePath = $args.file_path
                if (-not $filePath) { $filePath = $args.file }
            } catch { }
        }
    } catch { }
}

if (-not $content) { exit 0 }

# テスト / 例ファイルは除外
if ($filePath -and ($filePath -match '\.example$|\.test\.|\.spec\.|/test/|/tests/|/__tests__/|/fixtures/|/__mocks__/')) {
    exit 0
}

foreach ($pattern in $patterns) {
    if ($content -match $pattern) {
        [Console]::Error.WriteLine("BLOCKED: Hardcoded secret detected in $filePath")
        [Console]::Error.WriteLine("Pattern matched: $pattern")
        [Console]::Error.WriteLine("")
        [Console]::Error.WriteLine("Use environment variables or a secret manager instead:")
        [Console]::Error.WriteLine("  - process.env.SECRET_NAME (Node.js)")
        [Console]::Error.WriteLine("  - os.environ['SECRET_NAME'] (Python)")
        [Console]::Error.WriteLine("  - std::env::var(`"SECRET_NAME`") (Rust)")
        [Console]::Error.WriteLine("")
        [Console]::Error.WriteLine("If this is a test fixture or example, place it in test/fixtures/ or *.example file.")
        exit 2
    }
}

exit 0
