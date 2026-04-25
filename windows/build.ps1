$ErrorActionPreference = "Stop"
Write-Host "Building pvm.exe..." -ForegroundColor Cyan

go build -ldflags "-s -w" -o pvm.exe pvm.go

if ($LASTEXITCODE -eq 0) {
    Write-Host "Build successful: pvm.exe" -ForegroundColor Green
} else {
    Write-Host "Build failed!" -ForegroundColor Red
    exit $LASTEXITCODE
}
