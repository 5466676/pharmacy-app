# Started at boot by the "DoayaServer" scheduled task (see install.ps1).
$Backend = (Resolve-Path "$PSScriptRoot\..\..").Path
Set-Location $Backend
$port = 8000
foreach ($line in Get-Content ".env" -ErrorAction SilentlyContinue) {
    if ($line -match "^DOAYA_HTTP_PORT=(\d+)") { $port = [int]$Matches[1] }
}
New-Item -ItemType Directory -Force -Path "$Backend\data" | Out-Null
& .\.venv\Scripts\python.exe -m uvicorn app.main:server_app --factory `
    --host 0.0.0.0 --port $port *>> "$Backend\data\server.log"
