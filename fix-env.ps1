# Fix .env Configuration
Write-Host "Fixing .env Configuration..." -ForegroundColor Cyan

# Create .env file if it doesn't exist
if (-not (Test-Path ".env")) {
    Copy-Item "env.example" ".env"
    Write-Host "Created .env file from template" -ForegroundColor Green
}

# Read and update content
$content = Get-Content ".env"
$newContent = @()

foreach ($line in $content) {
    if ($line -match "GITHUB_REPO=") {
        $newContent += "GITHUB_REPO=jafar90147677/Ai-Agent"
    } elseif ($line -match "DATABASE_URL=") {
        $newContent += "DATABASE_URL=postgresql://user:password@postgres:5432/github_tracker_db"
    } else {
        $newContent += $line
    }
}

# Write updated content
$newContent | Out-File ".env" -Encoding UTF8
Write-Host "Updated .env file successfully!" -ForegroundColor Green

# Show current config
Write-Host "`nCurrent Configuration:" -ForegroundColor Yellow
Get-Content ".env" | Where-Object { $_ -match "GITHUB_TOKEN|GITHUB_REPO|DATABASE_URL" }

Write-Host "`nNext Steps:" -ForegroundColor Green
Write-Host "1. Get GitHub token from GitHub.com" -ForegroundColor White
Write-Host "2. Update GITHUB_TOKEN in .env file" -ForegroundColor White
Write-Host "3. Run: docker-compose down && docker-compose up -d" -ForegroundColor White
Write-Host "4. Open http://localhost:3000 and click Track Now" -ForegroundColor White
