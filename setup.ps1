param (
    [switch]$NoPause
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host "==============================================================" -ForegroundColor Cyan
Write-Host "   GEMINI WEB TO API -> CLAUDE CODE (VS CODE) SETUP TOOL     " -ForegroundColor Yellow
Write-Host "==============================================================" -ForegroundColor Cyan
Write-Host ""

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
Set-Location $scriptDir

# 1. Kiem tra Go
$goCmd = Get-Command go -ErrorAction SilentlyContinue
if (-not $goCmd) {
    Write-Host "[CANH BAO] Khong tim thay Go tren may cua ban!" -ForegroundColor Red
    Write-Host "  De chay server, ban can cai dat Go tu: https://go.dev/dl/" -ForegroundColor Yellow
    Write-Host "  (Ban van co the tiep tuc cau hinh cookie & settings.json truoc)" -ForegroundColor Gray
    Write-Host ""
} else {
    $goVer = go version
    Write-Host "[OK] Da tim thay: $goVer" -ForegroundColor Green
    Write-Host ""
}

# 2. Nhap Cookies
Write-Host "--------------------------------------------------------------" -ForegroundColor DarkGray
Write-Host "BUOC 1: NHAP GEMINI COOKIES" -ForegroundColor Green
Write-Host "--------------------------------------------------------------" -ForegroundColor DarkGray
Write-Host "Cach lay Cookie:" -ForegroundColor Gray
Write-Host "  1. Mo https://gemini.google.com va dang nhap tai khoan Google." -ForegroundColor Gray
Write-Host "  2. Nhan F12 -> Chon tab 'Network' -> F5 tai lai trang." -ForegroundColor Gray
Write-Host "  3. Tim mot request ten 'batchexecute', bam vao do." -ForegroundColor Gray
Write-Host "  4. Copy toan bo gia tri cua muc 'Cookie' trong phan Request Headers." -ForegroundColor Gray
Write-Host ""

$envPath = Join-Path $scriptDir ".env"
$cookie = ""
if (Test-Path $envPath) {
    $existingContent = Get-Content $envPath -Raw -ErrorAction SilentlyContinue
    if ($existingContent -match "GEMINI_COOKIES=(.+)") {
        $keep = Read-Host "Da tim thay Cookie trong .env co san. Ban co muon giu lai Cookie nay khong? (Y/N) [Mac dinh: Y]"
        if ($keep -eq "" -or $keep -match "^[Yy]") {
            $cookie = $matches[1].Trim()
            Write-Host "-> Su dung Cookie co san." -ForegroundColor DarkGreen
        }
    }
}

while ([string]::IsNullOrWhiteSpace($cookie)) {
    $cookie = Read-Host "Dan toan bo chuoi Cookie vao day (nhan chuot phai hoac Ctrl+V)"
    $cookie = $cookie.Trim()
    if ([string]::IsNullOrWhiteSpace($cookie)) {
        Write-Host "Cookie khong duoc de trong! Vui long nhap lai." -ForegroundColor Red
    }
}

$authUser = Read-Host "Nhap slot tai khoan Google (GEMINI_AUTH_USER, vi du: 1 neu URL la /u/1/app, mac dinh: 1)"
if ([string]::IsNullOrWhiteSpace($authUser)) {
    $authUser = "1"
}

# 3. Chon Model
Write-Host ""
Write-Host "--------------------------------------------------------------" -ForegroundColor DarkGray
Write-Host "BUOC 2: CHON MODEL CHO CLAUDE CODE" -ForegroundColor Green
Write-Host "--------------------------------------------------------------" -ForegroundColor DarkGray
Write-Host " [1] gemini-4-argon        (Khuyen dung - Mo hinh suy luan sau, thong minh nhat)" -ForegroundColor Yellow
Write-Host " [2] gemini-3.8-flash      (Phan hoi sieu nhanh ~3-5 giay)" -ForegroundColor White
Write-Host " [3] gemini-3.1-pro        (Can bang thong minh cao ~7 giay)" -ForegroundColor White
Write-Host " [4] gemini-3.5-flash-lite (Sieu nhe)" -ForegroundColor White
Write-Host " [5] Tu nhap ten model tuy chinh" -ForegroundColor White
Write-Host ""

$modelChoice = Read-Host "Chon model (1-5) [Mac dinh: 1]"
$selectedModel = "gemini-4-argon"
switch ($modelChoice) {
    "2" { $selectedModel = "gemini-3.8-flash" }
    "3" { $selectedModel = "gemini-3.1-pro" }
    "4" { $selectedModel = "gemini-3.5-flash-lite" }
    "5" { 
        $custom = Read-Host "Nhap ten model ban muon dung"
        if (-not [string]::IsNullOrWhiteSpace($custom)) { $selectedModel = $custom.Trim() }
    }
    Default { $selectedModel = "gemini-4-argon" }
}
Write-Host "-> Da chon model: $selectedModel" -ForegroundColor Cyan

# 4. Chon Effort Level
$effortLevel = "high"
if ($selectedModel -eq "gemini-4-argon") {
    Write-Host ""
    Write-Host "--------------------------------------------------------------" -ForegroundColor DarkGray
    Write-Host "BUOC 3: CHON MUC DO SUY NGHI (EFFORT LEVEL) CHO GEMINI 4 ARGON" -ForegroundColor Green
    Write-Host "--------------------------------------------------------------" -ForegroundColor DarkGray
    Write-Host " [1] Low    (Nhanh nhat ~10-15s, khuyen dung hang ngay)" -ForegroundColor Yellow
    Write-Host " [2] Medium (~20-25s)" -ForegroundColor White
    Write-Host " [3] High   (Suy nghi sau nhat ~30s+)" -ForegroundColor White
    Write-Host ""
    $effortChoice = Read-Host "Chon Effort (1-3) [Mac dinh: 1]"
    switch ($effortChoice) {
        "2" { $effortLevel = "medium" }
        "3" { $effortLevel = "high" }
        Default { $effortLevel = "low" }
    }
    Write-Host "-> Muc do suy nghi mac dinh: $effortLevel" -ForegroundColor Cyan
}

# 5. Ghi file .env
$envData = @"
GEMINI_COOKIES=$cookie
GEMINI_AUTH_USER=$authUser
GEMINI_REFRESH_INTERVAL=1440
GEMINI_MAX_RETRIES=3
GEMINI_TEMPORARY=false
APP_ENV=production
RATE_LIMIT_ENABLED=true
RATE_LIMIT_WINDOW_MS=60000
RATE_LIMIT_MAX_REQUESTS=10
"@

[System.IO.File]::WriteAllText($envPath, $envData, [System.Text.Encoding]::UTF8)
Write-Host ""
Write-Host "[OK] Da tao thanh cong file .env" -ForegroundColor Green

# 6. Cau hinh VS Code settings.json
$appData = [System.Environment]::GetFolderPath('ApplicationData')
$vscodeSettingsDir = Join-Path $appData "Code\User"
$vscodeSettingsFile = Join-Path $vscodeSettingsDir "settings.json"

if (-not (Test-Path $vscodeSettingsDir)) {
    New-Item -ItemType Directory -Path $vscodeSettingsDir -Force | Out-Null
}

$vscodeConfig = @{}
if (Test-Path $vscodeSettingsFile) {
    try {
        $raw = Get-Content $vscodeSettingsFile -Raw -ErrorAction SilentlyContinue
        if (-not [string]::IsNullOrWhiteSpace($raw)) {
            $vscodeConfig = $raw | ConvertFrom-Json -AsHashtable
        }
    } catch {
        $vscodeConfig = @{}
    }
}

$vscodeConfig["claudeCode.preferredLocation"] = "panel"
$vscodeConfig["claudeCode.disableLoginPrompt"] = $true
$vscodeConfig["claudeCode.environmentVariables"] = @(
    @{ name = "ANTHROPIC_BASE_URL"; value = "http://localhost:4981/claude" },
    @{ name = "ANTHROPIC_AUTH_TOKEN"; value = "sk-ant-api03-gemini-web-to-api-local-key" },
    @{ name = "ANTHROPIC_DEFAULT_SONNET_MODEL"; value = $selectedModel },
    @{ name = "ANTHROPIC_DEFAULT_OPUS_MODEL"; value = $selectedModel },
    @{ name = "ANTHROPIC_DEFAULT_HAIKU_MODEL"; value = "gemini-3.5-flash-lite" },
    @{ name = "CLAUDE_CODE_SUBAGENT_MODEL"; value = $selectedModel },
    @{ name = "CLAUDE_CODE_DISABLE_UNKNOWN_MODEL_WINDOW_ENFORCEMENT"; value = "1" }
)

$vscodeJson = $vscodeConfig | ConvertTo-Json -Depth 10
[System.IO.File]::WriteAllText($vscodeSettingsFile, $vscodeJson, [System.Text.Encoding]::UTF8)
Write-Host "[OK] Da cap nhat cai dat VS Code: $vscodeSettingsFile" -ForegroundColor Green

# 7. Cau hinh ~/.claude/settings.json
$userProfile = [System.Environment]::GetFolderPath('UserProfile')
$claudeDir = Join-Path $userProfile ".claude"
$claudeSettingsFile = Join-Path $claudeDir "settings.json"

if (-not (Test-Path $claudeDir)) {
    New-Item -ItemType Directory -Path $claudeDir -Force | Out-Null
}

$claudeConfig = @{}
if (Test-Path $claudeSettingsFile) {
    try {
        $raw = Get-Content $claudeSettingsFile -Raw -ErrorAction SilentlyContinue
        if (-not [string]::IsNullOrWhiteSpace($raw)) {
            $claudeConfig = $raw | ConvertFrom-Json -AsHashtable
        }
    } catch {
        $claudeConfig = @{}
    }
}

if (-not $claudeConfig.ContainsKey("env") -or -not ($claudeConfig["env"] -is [hashtable])) {
    $claudeConfig["env"] = @{}
}

$claudeConfig["env"]["ANTHROPIC_AUTH_TOKEN"] = "sk-ant-api03-gemini-web-to-api-local-key"
$claudeConfig["env"]["ANTHROPIC_BASE_URL"] = "http://localhost:4981/claude"
$claudeConfig["env"]["ANTHROPIC_DEFAULT_OPUS_MODEL"] = $selectedModel
$claudeConfig["env"]["ANTHROPIC_DEFAULT_SONNET_MODEL"] = $selectedModel
$claudeConfig["env"]["ANTHROPIC_DEFAULT_HAIKU_MODEL"] = "gemini-3.5-flash-lite"
$claudeConfig["env"]["CLAUDE_CODE_SUBAGENT_MODEL"] = $selectedModel
$claudeConfig["env"]["CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC"] = "1"
$claudeConfig["env"]["API_TIMEOUT_MS"] = "3000000"
$claudeConfig["env"]["CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS"] = "0"
$claudeConfig["env"]["CLAUDE_CODE_DISABLE_1M_CONTEXT"] = "1"
$claudeConfig["env"]["CLAUDE_CODE_NO_FLICKER"] = "1"
$claudeConfig["env"]["CLAUDE_CODE_DISABLE_UNKNOWN_MODEL_WINDOW_ENFORCEMENT"] = "1"

$claudeConfig["model"] = "sonnet"
if (-not $claudeConfig.ContainsKey("modelSettings") -or -not ($claudeConfig["modelSettings"] -is [hashtable])) {
    $claudeConfig["modelSettings"] = @{}
}
$claudeConfig["modelSettings"][$selectedModel] = @{
    effortLevel = $effortLevel
}
$claudeConfig["autoUpdatesChannel"] = "latest"
$claudeConfig["skipDangerousModePermissionPrompt"] = $false

$claudeJson = $claudeConfig | ConvertTo-Json -Depth 10
[System.IO.File]::WriteAllText($claudeSettingsFile, $claudeJson, [System.Text.Encoding]::UTF8)
Write-Host "[OK] Da cap nhat cai dat Claude Code Core: $claudeSettingsFile" -ForegroundColor Green

Write-Host ""
Write-Host "==============================================================" -ForegroundColor Green
Write-Host "               HOAN TAT CAI DAT 100%!                         " -ForegroundColor Green
Write-Host "==============================================================" -ForegroundColor Green
Write-Host ""
Write-Host "Cac buoc su dung:" -ForegroundColor Yellow
Write-Host " 1. Khoi dong server nay (cong 4981)." -ForegroundColor White
Write-Host " 2. Mo VS Code -> cai extension 'Claude Code' (neu chua cai)." -ForegroundColor White
Write-Host " 3. Bam vao tab Claude Code -> Bat dau chat voi Gemini 4 Argon!" -ForegroundColor White
Write-Host "    (Luu y: Gemini 4 Argon suy nghi sau, mat khoang 10-25 giay/cau hoi)" -ForegroundColor Gray
Write-Host ""

if ($goCmd) {
    $startNow = Read-Host "Ban co muon khoi dong Server ngay bay gio khong? (Y/N) [Mac dinh: Y]"
    if ($startNow -eq "" -or $startNow -match "^[Yy]") {
        Write-Host ""
        Write-Host "-> Dang khoi dong Server tren http://127.0.0.1:4981 ..." -ForegroundColor Cyan
        Write-Host "   (Nhan Ctrl+C de dung server bat cu luc nao)" -ForegroundColor Gray
        Write-Host ""
        go run cmd/server/main.go
    } else {
        Write-Host "De chay server sau nay, ban chi can nhan dup vao file 'Start_Server.bat'." -ForegroundColor Yellow
    }
} else {
    Write-Host "Sau khi ban cai Go xong, hay nhan dup vao 'Start_Server.bat' de chay." -ForegroundColor Yellow
}

if (-not $NoPause) {
    Write-Host ""
    Write-Host "Nhan Enter de thoat..."
    Read-Host | Out-Null
}
