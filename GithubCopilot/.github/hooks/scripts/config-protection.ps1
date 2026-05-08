# Config Protection Hook (PowerShell)
# linter/formatter 設定ファイルの改変をブロック
# Copilot Hooks: preToolUse で実行

$ErrorActionPreference = 'Stop'

$inputJson = [Console]::In.ReadToEnd()

# 保護対象ファイル名
$protectedFiles = @(
    # ESLint
    '.eslintrc', '.eslintrc.js', '.eslintrc.cjs', '.eslintrc.json',
    '.eslintrc.yml', '.eslintrc.yaml',
    'eslint.config.js', 'eslint.config.mjs', 'eslint.config.cjs',
    'eslint.config.ts', 'eslint.config.mts', 'eslint.config.cts',
    # Prettier
    '.prettierrc', '.prettierrc.js', '.prettierrc.cjs', '.prettierrc.json',
    '.prettierrc.yml', '.prettierrc.yaml',
    'prettier.config.js', 'prettier.config.cjs', 'prettier.config.mjs',
    # Biome
    'biome.json', 'biome.jsonc',
    # Ruff
    '.ruff.toml', 'ruff.toml',
    # Shell / Style / Markdown
    '.shellcheckrc', '.stylelintrc', '.stylelintrc.json', '.stylelintrc.yml',
    '.markdownlint.json', '.markdownlint.yaml', '.markdownlintrc'
)

# JSON 入力をパース
$filePath = $null
if ($inputJson) {
    try {
        $obj = $inputJson | ConvertFrom-Json -ErrorAction SilentlyContinue
        # toolArgs が JSON 文字列、または tool_input.file_path 等の形式
        $filePath = $obj.tool_input.file_path
        if (-not $filePath) { $filePath = $obj.tool_input.file }
        if (-not $filePath -and $obj.toolArgs) {
            try {
                $args = $obj.toolArgs | ConvertFrom-Json -ErrorAction SilentlyContinue
                $filePath = $args.file_path
                if (-not $filePath) { $filePath = $args.file }
                if (-not $filePath) { $filePath = $args.path }
            } catch {
                # toolArgs が JSON 文字列でなければ文字列として使う
                $filePath = $obj.toolArgs
            }
        }
    } catch {
        # パース失敗はスキップ
    }
}

if (-not $filePath) { exit 0 }

$basename = Split-Path $filePath -Leaf

if ($protectedFiles -contains $basename) {
    [Console]::Error.WriteLine("BLOCKED: Modifying $basename is not allowed.")
    [Console]::Error.WriteLine("Linter/formatter config files protect code quality.")
    [Console]::Error.WriteLine("Fix the source code instead of weakening the config.")
    [Console]::Error.WriteLine("If you genuinely need to update this config, do so manually outside the agent.")
    exit 2
}

exit 0
