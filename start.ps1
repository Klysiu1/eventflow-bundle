[CmdletBinding()]
param(
    [switch]$SkipInstall,
    [switch]$OnlyInstall,
    [switch]$NoBrowser,
    [switch]$Help
)

if ($Help) {
    Write-Host @"
Użycie: .\start.ps1 [opcje]

Opcje:
  -SkipInstall   Pomiń instalację zależności (npm/composer) i przejdź bezpośrednio do uruchomienia
  -OnlyInstall   Zainstaluj tylko zależności bez uruchamiania aplikacji
  -NoBrowser     Nie otwieraj automatycznie przeglądarki po uruchomieniu
  -Help          Wyświetl tę pomoc

Przykład:
  .\start.ps1
  .\start.ps1 -SkipInstall
"@
    exit 0
}

$ErrorActionPreference = "Stop"
$ScriptRoot = $PSScriptRoot
if (-not $ScriptRoot) { $ScriptRoot = Get-Location }

function Write-Step {
    param([string]$Text)
    Write-Host "`n>>> $Text" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Text)
    Write-Host " [OK] $Text" -ForegroundColor Green
}

function Write-ErrorMsg {
    param([string]$Text)
    Write-Host " [BŁĄD] $Text" -ForegroundColor Red
}

function Write-Info {
    param([string]$Text)
    Write-Host " $Text" -ForegroundColor Yellow
}

Write-Host "====================================================================" -ForegroundColor Cyan
Write-Host "  EventFlow - Instalator i Starter Aplikacji" -ForegroundColor White
Write-Host "  [Backend: Laravel :8000, Reverb :8080]" -ForegroundColor DarkGray
Write-Host "  [Web: React + Vite :5173]" -ForegroundColor DarkGray
Write-Host "  [Mobilne: Expo Metro :8081]" -ForegroundColor DarkGray
Write-Host "====================================================================" -ForegroundColor Cyan

# 1. Sprawdzanie narzędzi
Write-Step "Krok 1/4: Sprawdzanie narzędzi systemowych..."

$missing = @()
if (-not (Get-Command php -ErrorAction SilentlyContinue)) { $missing += "php (PHP 8.3+)" }
if (-not (Get-Command composer -ErrorAction SilentlyContinue)) { $missing += "composer (Composer)" }
if (-not (Get-Command node -ErrorAction SilentlyContinue)) { $missing += "node (Node.js LTS)" }

if ($missing.Count -gt 0) {
    Write-ErrorMsg "Brakuje wymaganych narzędzi: $($missing -join ', ')"
    Write-Host "Zainstaluj brakujące pakiety i uruchom skrypt ponownie." -ForegroundColor Red
    exit 1
}
Write-Success "PHP, Composer i Node.js są zainstalowane i dostępne w PATH."

# 2. Weryfikacja konfiguracji środowiska
Write-Step "Krok 2/4: Weryfikacja plików konfiguracyjnych i bazy danych..."

$serverDir = Join-Path $ScriptRoot "eventflow server"
$webDir = Join-Path $ScriptRoot "eventflow-webowe"
$mobileDir = Join-Path $ScriptRoot "eventflow-mobilna"

# Backend
$serverEnv = Join-Path $serverDir ".env"
$serverEnvExample = Join-Path $serverDir ".env.example"
$sqliteDb = Join-Path $serverDir "database\database.sqlite"

if (-not (Test-Path $serverEnv)) {
    Write-Info "Tworzenie pliku .env dla backendu..."
    Copy-Item $serverEnvExample $serverEnv
    Push-Location $serverDir
    try {
        php artisan key:generate
    } finally {
        Pop-Location
    }
}

if (-not (Test-Path $sqliteDb)) {
    Write-Info "Tworzenie bazy SQLite dla backendu..."
    New-Item -ItemType File -Path $sqliteDb -Force | Out-Null
}

# Web
$webEnv = Join-Path $webDir ".env"
$webEnvExample = Join-Path $webDir ".env.example"
if (-not (Test-Path $webEnv) -and (Test-Path $webEnvExample)) {
    Write-Info "Tworzenie pliku .env dla frontendu..."
    Copy-Item $webEnvExample $webEnv
}

# Mobile
$mobileEnv = Join-Path $mobileDir ".env"
$mobileEnvExample = Join-Path $mobileDir ".env.example"
if (-not (Test-Path $mobileEnv) -and (Test-Path $mobileEnvExample)) {
    Write-Info "Tworzenie pliku .env dla aplikacji mobilnej..."
    Copy-Item $mobileEnvExample $mobileEnv
}

Write-Success "Konfiguracja plików środowiskowych i bazy danych gotowa."

# 3. Instalacja zależności
if (-not $SkipInstall) {
    Write-Step "Krok 3/4: Instalacja zależności..."

    Write-Info "1/3 Backend (eventflow server): composer install, migracje, npm install..."
    Push-Location $serverDir
    try {
        cmd.exe /c "composer install --no-interaction"
        if ($LASTEXITCODE -ne 0) { throw "Błąd podczas composer install" }
        php artisan migrate --force
        php artisan db:seed --force
        cmd.exe /c "npm.cmd install --no-audit --no-fund"
    } finally {
        Pop-Location
    }

    Write-Info "2/3 Frontend Web (eventflow-webowe): npm install..."
    Push-Location $webDir
    try {
        cmd.exe /c "npm.cmd install --no-audit --no-fund"
        if ($LASTEXITCODE -ne 0) { throw "Błąd podczas npm install w eventflow-webowe" }
    } finally {
        Pop-Location
    }

    Write-Info "3/3 Aplikacja Mobilna (eventflow-mobilna): npm install..."
    Push-Location $mobileDir
    try {
        cmd.exe /c "npm.cmd install --no-audit --no-fund"
        if ($LASTEXITCODE -ne 0) { throw "Błąd podczas npm install w eventflow-mobilna" }
    } finally {
        Pop-Location
    }

    Write-Success "Wszystkie zależności zostały zainstalowane pomyślnie."
} else {
    Write-Step "Krok 3/4: Pominięto instalację zależności (-SkipInstall)."
}

if ($OnlyInstall) {
    Write-Host "`nZakończono instalację zależności (-OnlyInstall)." -ForegroundColor Green
    exit 0
}

# 4. Uruchamianie procesów
Write-Step "Krok 4/4: Uruchamianie usług w dedykowanych oknach..."

Write-Info "Uruchamianie Backend (Laravel API + Reverb WebSockets)..."
Start-Process cmd.exe -ArgumentList "/k title EventFlow - Backend [Laravel :8000 + Reverb :8080] && cd /d `"$serverDir`" && php artisan dev"

Start-Sleep -Seconds 2

Write-Info "Uruchamianie Frontend Web (React + Vite)..."
Start-Process cmd.exe -ArgumentList "/k title EventFlow - Web Frontend [Vite :5173] && cd /d `"$webDir`" && npm.cmd run dev"

Start-Sleep -Seconds 1

Write-Info "Uruchamianie Aplikacji Mobilnej (Expo)..."
Start-Process cmd.exe -ArgumentList "/k title EventFlow - Mobile App [Expo :8081] && cd /d `"$mobileDir`" && npx.cmd expo start"

Write-Host @"

====================================================================
  Wszystkie usługi EventFlow zostały uruchomione!

  - Frontend Web:        http://localhost:5173
  - Backend API:         http://127.0.0.1:8000/api/v1
  - Reverb WebSocket:    http://localhost:8080
  - Aplikacja Mobilna:   http://localhost:8081  (Expo DevTools / QR)

  Wskazówki dla aplikacji mobilnej:
  - W oknie konsoli Expo wciśnij 'w', aby otworzyć wersję web w przeglądarce.
  - Wciśnij 'a', aby uruchomić emulator Androida.
  - Zeskanuj kod QR aplikacją Expo Go na telefonie (w tej samej sieci Wi-Fi).

  Aby zatrzymać wszystkie usługi, uruchom: .\stop.ps1 lub stop.bat
====================================================================
"@ -ForegroundColor Green

if (-not $NoBrowser) {
    $open = Read-Host "Czy otworzyć frontend w przeglądarce? (T/n)"
    if ($open -eq "" -or $open.Trim().ToUpper() -eq "T") {
        Start-Process "http://localhost:5173"
    }
}
