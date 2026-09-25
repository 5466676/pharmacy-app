# Started at boot by the "DoayaServer" scheduled task (see install.ps1).
$Backend = (Resolve-Path "$PSScriptRoot\..\..").Path
Set-Location $Backend
New-Item -ItemType Directory -Force -Path "$Backend\data" | Out-Null
# HTTPS with the server's own certificate; the port comes from .env.
& .\.venv\Scripts\python.exe -m app.serve *>> "$Backend\data\server.log"
