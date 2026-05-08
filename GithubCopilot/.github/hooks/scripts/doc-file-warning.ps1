# Doc File Warning Hook (PowerShell)
# 構造化されていない場所への ad-hoc ドキュメントファイル作成を警告
# Copilot Hooks: preToolUse で実行

$ErrorActionPreference = 'Continue'

$inputJson = [Console]::In.ReadToEnd()

$adhocPattern = '^(NOTES|TODO|SCRATCH|TEMP|DRAFT|BRAINSTORM|SPIKE|DEBUG|WIP)\.(md|txt)$'
$structuredDirs = '(^|/)(docs|\.claude|\.github|commands|skills|benchmarks|templates|\.history|memory)/'

$filePath = $null
if ($inputJson) {
    try {
        $obj = $inputJson | ConvertFrom-Json -ErrorAction SilentlyContinue
        $filePath = $obj.tool_input.file_path
        if (-not $filePath) { $filePath = $obj.tool_input.file }
        if (-not $filePath -and $obj.toolArgs) {
            try {
                $args = $obj.toolArgs | ConvertFrom-Json -ErrorAction SilentlyContinue
                $filePath = $args.file_path
                if (-not $filePath) { $filePath = $args.file }
                if (-not $filePath) { $filePath = $args.path }
            } catch { $filePath = $obj.toolArgs }
        }
    } catch { }
}

if (-not $filePath) { exit 0 }

$normalized = $filePath -replace '\\', '/'
$basename = Split-Path $normalized -Leaf

# 構造化ディレクトリ内なら OK
if ($normalized -match $structuredDirs) {
    exit 0
}

if ($basename -match $adhocPattern) {
    [Console]::Error.WriteLine("[Hook] WARNING: Ad-hoc documentation filename detected")
    [Console]::Error.WriteLine("[Hook] File: $filePath")
    [Console]::Error.WriteLine("[Hook] Consider using a structured path (e.g. docs/, .github/, skills/, benchmarks/, templates/)")
}

exit 0
