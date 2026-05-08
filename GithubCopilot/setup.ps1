# GithubCopilot セットアップスクリプト（Windows PowerShell）
#
# このスクリプトは ECC リポジトリのスキル / エージェント / コマンドを
# .github/ 配下に一括変換コピーします。

[CmdletBinding()]
param(
    [Parameter()]
    [string]$EccRoot = (Resolve-Path "$PSScriptRoot\..").Path,

    [Parameter()]
    [string]$DestRoot = $PSScriptRoot,

    [Parameter()]
    [switch]$IncludeAllAgents = $false,

    [Parameter()]
    [switch]$IncludeAllCommands = $false,

    [Parameter()]
    [switch]$Force = $false
)

$ErrorActionPreference = 'Stop'

Write-Host "=== ECC → GitHub Copilot 変換スクリプト ===" -ForegroundColor Cyan
Write-Host "ECC Root: $EccRoot"
Write-Host "Dest Root: $DestRoot"
Write-Host ""

# ──────────────────────────────────────────────
# 1. Skills を .github/skills/ にコピー
# ──────────────────────────────────────────────

$skillsSrc = Join-Path $EccRoot 'skills'
$skillsDst = Join-Path $DestRoot '.github\skills'

if (Test-Path $skillsSrc) {
    Write-Host "[1/4] Skills を .github/skills/ にコピー中..." -ForegroundColor Green

    if (-not (Test-Path $skillsDst)) {
        New-Item -ItemType Directory -Path $skillsDst -Force | Out-Null
    }

    $skillCount = 0
    Get-ChildItem -Path $skillsSrc -Directory | ForEach-Object {
        $skillDir = $_
        $destDir = Join-Path $skillsDst $skillDir.Name

        if ((Test-Path $destDir) -and -not $Force) {
            Write-Host "  - $($skillDir.Name) (既存、スキップ)" -ForegroundColor DarkGray
            return
        }

        Copy-Item -Path $skillDir.FullName -Destination $destDir -Recurse -Force

        # SKILL.md から `origin: ECC` 行を削除（Copilot 仕様外）
        $skillFile = Join-Path $destDir 'SKILL.md'
        if (Test-Path $skillFile) {
            $content = Get-Content $skillFile -Raw
            $cleaned = $content -replace '(?m)^origin:\s*ECC\s*$\r?\n?', ''
            if ($cleaned -ne $content) {
                Set-Content -Path $skillFile -Value $cleaned -NoNewline
            }
        }

        $skillCount++
        Write-Host "  - $($skillDir.Name)" -ForegroundColor Gray
    }
    Write-Host "  → $skillCount skills コピー完了" -ForegroundColor Green
} else {
    Write-Host "[1/4] skills/ ディレクトリが見つかりません — スキップ" -ForegroundColor Yellow
}

Write-Host ""

# ──────────────────────────────────────────────
# 2. .agents/skills と .claude/skills もコピー（Copilot ネイティブパス）
# ──────────────────────────────────────────────

$nativeSkillPaths = @(
    @{ Src = Join-Path $EccRoot '.agents\skills'; Label = '.agents/skills' }
    @{ Src = Join-Path $EccRoot '.claude\skills'; Label = '.claude/skills' }
)

foreach ($pathInfo in $nativeSkillPaths) {
    if (Test-Path $pathInfo.Src) {
        Write-Host "[2/4] $($pathInfo.Label) もコピー中..." -ForegroundColor Green
        Get-ChildItem -Path $pathInfo.Src -Directory | ForEach-Object {
            $destDir = Join-Path $skillsDst $_.Name
            if (-not (Test-Path $destDir) -or $Force) {
                Copy-Item -Path $_.FullName -Destination $destDir -Recurse -Force
                Write-Host "  - $($_.Name) ($($pathInfo.Label) より)" -ForegroundColor Gray
            }
        }
    }
}

Write-Host ""

# ──────────────────────────────────────────────
# 3. 残りの Agents を変換（オプション）
# ──────────────────────────────────────────────

if ($IncludeAllAgents) {
    Write-Host "[3/4] 全エージェントを .github/agents/ に変換コピー中..." -ForegroundColor Green

    $agentsSrc = Join-Path $EccRoot 'agents'
    $agentsDst = Join-Path $DestRoot '.github\agents'

    if (-not (Test-Path $agentsDst)) {
        New-Item -ItemType Directory -Path $agentsDst -Force | Out-Null
    }

    $agentCount = 0
    Get-ChildItem -Path $agentsSrc -File -Filter '*.md' | ForEach-Object {
        $agentName = $_.BaseName
        $destFile = Join-Path $agentsDst "$agentName.agent.md"

        if ((Test-Path $destFile) -and -not $Force) {
            return
        }

        $content = Get-Content $_.FullName -Raw

        # フロントマターのツール名を Copilot 形式に変換
        $content = $content -replace '"Read"', '"read"'
        $content = $content -replace '"Write"', '"edit"'
        $content = $content -replace '"Edit"', '"edit"'
        $content = $content -replace '"MultiEdit"', '"edit"'
        $content = $content -replace '"Grep"', '"search"'
        $content = $content -replace '"Glob"', '"search"'
        $content = $content -replace '"Bash"', '"shell"'

        # model 行を削除
        $content = $content -replace '(?m)^model:\s*\w+\s*$\r?\n?', ''

        # name 行を削除（ファイル名から取得されるため任意）
        # description はそのまま残す

        Set-Content -Path $destFile -Value $content -NoNewline
        $agentCount++
    }
    Write-Host "  → $agentCount エージェント変換完了" -ForegroundColor Green
} else {
    Write-Host "[3/4] エージェント自動変換スキップ（-IncludeAllAgents で有効化）" -ForegroundColor DarkGray
    Write-Host "  ※ 主要エージェントは既に .github/agents/ に手動変換済み" -ForegroundColor DarkGray
}

Write-Host ""

# ──────────────────────────────────────────────
# 4. 残りの Commands を Prompts に変換（オプション）
# ──────────────────────────────────────────────

if ($IncludeAllCommands) {
    Write-Host "[4/4] 全コマンドを .github/prompts/ に変換コピー中..." -ForegroundColor Green

    $commandsSrc = Join-Path $EccRoot 'commands'
    $promptsDst = Join-Path $DestRoot '.github\prompts'

    if (-not (Test-Path $promptsDst)) {
        New-Item -ItemType Directory -Path $promptsDst -Force | Out-Null
    }

    $cmdCount = 0
    Get-ChildItem -Path $commandsSrc -File -Filter '*.md' | ForEach-Object {
        $cmdName = $_.BaseName
        $destFile = Join-Path $promptsDst "$cmdName.prompt.md"

        if ((Test-Path $destFile) -and -not $Force) {
            return
        }

        Copy-Item -Path $_.FullName -Destination $destFile -Force
        $cmdCount++
    }
    Write-Host "  → $cmdCount コマンド変換完了" -ForegroundColor Green
} else {
    Write-Host "[4/4] コマンド自動変換スキップ（-IncludeAllCommands で有効化）" -ForegroundColor DarkGray
    Write-Host "  ※ 主要コマンドは既に .github/prompts/ に手動変換済み" -ForegroundColor DarkGray
}

Write-Host ""
Write-Host "=== 完了 ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "次のステップ:" -ForegroundColor White
Write-Host "  1. .github/ ディレクトリを既存リポジトリに統合"
Write-Host "  2. .github/copilot-instructions.md を確認・カスタマイズ"
Write-Host "  3. .github/instructions/ の言語別ルールを必要に応じて編集"
Write-Host "  4. mcp/mcp.json を VS Code settings.json に統合（必要なら）"
Write-Host ""
Write-Host "オプション:"
Write-Host "  -IncludeAllAgents   全 48 エージェントを自動変換"
Write-Host "  -IncludeAllCommands 全 68 コマンドを自動変換"
Write-Host "  -Force              既存ファイルを上書き"
