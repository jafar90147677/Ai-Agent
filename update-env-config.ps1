# Update .env Configuration for Live GitHub Data
Write-Host "Updating .env Configuration..." -ForegroundColor Cyan
Write-Host "=============================" -ForegroundColor Cyan

# Read current .env content
if (Test-Path ".env") {
    $envContent = Get-Content ".env"
    Write-Host "✅ .env file found" -ForegroundColor Green
} else {
    Write-Host "❌ .env file not found - creating from template" -ForegroundColor Red
    Copy-Item "env.example" ".env"
    $envContent = Get-Content ".env"
}

# Update the content
$updatedContent = $envContent | ForEach-Object {
    if ($_ -match "GITHUB_REPO=") {
        "GITHUB_REPO=jafar90147677/Ai-Agent"
    } elseif ($_ -match "DATABASE_URL=") {
        "DATABASE_URL=postgresql://user:password@postgres:5432/github_tracker_db"
    } else {
        $_
    }
}

# Write updated content
$updatedContent | Out-File ".env" -Encoding UTF8
Write-Host "✅ .env file updated successfully!" -ForegroundColor Green

# Show the updated configuration
Write-Host "`nUpdated Configuration:" -ForegroundColor Yellow
Write-Host "=====================" -ForegroundColor Yellow
Get-Content ".env" | ForEach-Object {
    if ($_ -match "GITHUB_TOKEN|GITHUB_REPO|DATABASE_URL") {
        Write-Host $_ -ForegroundColor White
    }
}

Write-Host "`n🎯 Next Steps:" -ForegroundColor Green
Write-Host "=============" -ForegroundColor Green
Write-Host "1. Get your GitHub Personal Access Token from GitHub.com" -ForegroundColor White
Write-Host "2. Open .env file and replace 'your_github_token_here' with your token" -ForegroundColor White
Write-Host "3. Run: docker-compose down && docker-compose up -d" -ForegroundColor White
Write-Host "4. Open http://localhost:3000 and click 'Track Now'" -ForegroundColor White

Write-Host "`n📝 To get your GitHub token:" -ForegroundColor Cyan
Write-Host "1. Go to GitHub.com → Settings → Developer settings → Personal access tokens" -ForegroundColor Gray
Write-Host "2. Click Generate new token classic" -ForegroundColor Gray
Write-Host "3. Select repo scope" -ForegroundColor Gray
Write-Host "4. Copy the token and update .env file" -ForegroundColor Gray

Write-Host "`n✅ Configuration ready for live GitHub data!" -ForegroundColor Green
