# Doaya server: one-time install on the pharmacy's Windows PC.
# Run in PowerShell *as Administrator*, from anywhere:
#   powershell -ExecutionPolicy Bypass -File backend\deploy\windows\install.ps1
# Needs first: Python 3.11+ (python.org, "Add to PATH") and PostgreSQL 16
# (postgresql.org installer; remember the 'postgres' password it asks for).
# Safe to run again (keeps the existing database and settings).
#Requires -RunAsAdministrator
param(
    [string]$PgBin = "C:\Program Files\PostgreSQL\16\bin",
    [int]$Port = 8000
)
$ErrorActionPreference = "Stop"
$Backend = (Resolve-Path "$PSScriptRoot\..\..").Path
Set-Location $Backend
Write-Host "Doaya server install in $Backend" -ForegroundColor Green
if ($Backend -match "[^\x00-\x7F]") {
    throw "Move the project to a folder with English letters only (e.g. C:\Doaya) and run again."
}

# 1) Python environment and the server's packages.
if (-not (Get-Command py -ErrorAction SilentlyContinue)) {
    throw "Python not found. Install Python 3.11+ from python.org (tick 'Add python.exe to PATH')."
}
if (-not (Test-Path "$PgBin\psql.exe")) {
    throw "PostgreSQL not found in $PgBin. Install PostgreSQL 16, or pass -PgBin <its bin folder>."
}
if (-not (Test-Path ".venv")) { & py -3 -m venv .venv }
& .\.venv\Scripts\python.exe -m pip install --upgrade pip
& .\.venv\Scripts\python.exe -m pip install .
if ($LASTEXITCODE -ne 0) { throw "pip install failed" }

# 2) Database and settings (only the first time).
if (-not (Test-Path ".env")) {
    $secure = Read-Host "Password of the PostgreSQL 'postgres' user (chosen during its install)" -AsSecureString
    $env:PGPASSWORD = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
        [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure))
    $dbPass = [guid]::NewGuid().ToString("N")
    $psql = "$PgBin\psql.exe"
    $exists = & $psql -U postgres -h localhost -tAc "SELECT 1 FROM pg_roles WHERE rolname='doaya'"
    if ($exists -eq "1") {
        & $psql -U postgres -h localhost -v ON_ERROR_STOP=1 -c "ALTER ROLE doaya WITH LOGIN PASSWORD '$dbPass';"
    } else {
        & $psql -U postgres -h localhost -v ON_ERROR_STOP=1 -c "CREATE ROLE doaya LOGIN PASSWORD '$dbPass';"
    }
    $db = & $psql -U postgres -h localhost -tAc "SELECT 1 FROM pg_database WHERE datname='doaya'"
    if ($db -ne "1") {
        & $psql -U postgres -h localhost -v ON_ERROR_STOP=1 -c "CREATE DATABASE doaya OWNER doaya;"
    }
    Remove-Item Env:\PGPASSWORD
    @(
        "DOAYA_DATABASE_URL=postgresql+psycopg://doaya:$dbPass@localhost:5432/doaya",
        "DOAYA_PG_BIN_DIR=$PgBin",
        "DOAYA_DATA_DIR=$Backend\data",
        "DOAYA_HTTP_PORT=$Port"
    ) | Set-Content -Path ".env" -Encoding ascii
    Write-Host "Settings written to $Backend\.env"
}
New-Item -ItemType Directory -Force -Path "$Backend\data" | Out-Null

# 3) Database tables (and later upgrades).
& .\.venv\Scripts\alembic.exe upgrade head
if ($LASTEXITCODE -ne 0) { throw "database migration failed" }

# 4) Firewall: the app talks to the server on these ports, local network.
foreach ($rule in @(
    @{ Name = "Doaya server (TCP $Port)"; Protocol = "TCP"; Port = $Port },
    @{ Name = "Doaya discovery (UDP 47800)"; Protocol = "UDP"; Port = 47800 }
)) {
    Get-NetFirewallRule -DisplayName $rule.Name -ErrorAction SilentlyContinue | Remove-NetFirewallRule
    New-NetFirewallRule -DisplayName $rule.Name -Direction Inbound -Action Allow `
        -Protocol $rule.Protocol -LocalPort $rule.Port -Profile Any | Out-Null
}

# 5) Start with Windows, restart if it stops.
$run = "$Backend\deploy\windows\run-server.ps1"
$action = New-ScheduledTaskAction -Execute "powershell.exe" `
    -Argument "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$run`"" `
    -WorkingDirectory $Backend
$trigger = New-ScheduledTaskTrigger -AtStartup
$settings = New-ScheduledTaskSettingsSet -RestartCount 999 -RestartInterval (New-TimeSpan -Minutes 1) `
    -ExecutionTimeLimit ([TimeSpan]::Zero) -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries
$principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
Register-ScheduledTask -TaskName "DoayaServer" -Action $action -Trigger $trigger `
    -Settings $settings -Principal $principal -Force | Out-Null
Stop-ScheduledTask -TaskName "DoayaServer" -ErrorAction SilentlyContinue
Start-ScheduledTask -TaskName "DoayaServer"

# 6) Check it answers, and show the address to type in the app if needed.
Start-Sleep -Seconds 8
try {
    $h = Invoke-RestMethod "http://localhost:$Port/health"
    Write-Host "Server is running: $($h.status)" -ForegroundColor Green
} catch {
    Write-Host "Server did not answer yet; see $Backend\data\server.log" -ForegroundColor Yellow
}
Get-NetIPAddress -AddressFamily IPv4 |
    Where-Object { $_.IPAddress -notlike "127.*" -and $_.IPAddress -notlike "169.254.*" } |
    ForEach-Object { Write-Host "Address for the app: $($_.IPAddress):$Port" }
