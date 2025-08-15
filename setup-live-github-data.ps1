# Setup Live GitHub Data Fetching
Write-Host "Setting up Live GitHub Data Fetching..." -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan

# Check current status
Write-Host "`n1. Current Status:" -ForegroundColor Yellow
Write-Host "==================" -ForegroundColor Yellow

# Check if .env exists and show config
if (Test-Path ".env") {
    Write-Host "✅ .env file exists" -ForegroundColor Green
    Write-Host "`nCurrent Configuration:" -ForegroundColor White
    Get-Content ".env" | Where-Object { $_ -match "GITHUB_TOKEN|GITHUB_REPO|DATABASE_URL" }
} else {
    Write-Host "❌ .env file missing" -ForegroundColor Red
}

# Check if JSON fallback file is removed
if (Test-Path "data/commit.json") {
    Write-Host "❌ JSON fallback file still exists" -ForegroundColor Red
} else {
    Write-Host "✅ JSON fallback file removed" -ForegroundColor Green
}

# Check Docker services
Write-Host "`n2. Docker Services Status:" -ForegroundColor Yellow
Write-Host "=========================" -ForegroundColor Yellow
docker-compose ps | findstr "database-service\|github-service\|api-gateway"

# Instructions for GitHub setup
Write-Host "`n3. GitHub Setup Instructions:" -ForegroundColor Yellow
Write-Host "=============================" -ForegroundColor Yellow
Write-Host "To get live data from your GitHub repository:" -ForegroundColor White

Write-Host "`nStep 1: Create GitHub Personal Access Token" -ForegroundColor Cyan
Write-Host "1. Go to GitHub.com → Settings → Developer settings → Personal access tokens" -ForegroundColor Gray
Write-Host "2. Click 'Generate new token (classic)'" -ForegroundColor Gray
Write-Host "3. Give it a name like 'GitHub Tracker'" -ForegroundColor Gray
Write-Host "4. Select scopes: 'repo' (for private repos) or 'public_repo' (for public repos)" -ForegroundColor Gray
Write-Host "5. Copy the generated token" -ForegroundColor Gray

Write-Host "`nStep 2: Update .env File" -ForegroundColor Cyan
Write-Host "1. Open the .env file in your project" -ForegroundColor Gray
Write-Host "2. Replace 'your_github_token_here' with your actual token" -ForegroundColor Gray
Write-Host "3. Make sure GITHUB_REPO=jafar90147677/Ai-Agent" -ForegroundColor Gray

Write-Host "`nStep 3: Restart Services" -ForegroundColor Cyan
Write-Host "1. Run: docker-compose down" -ForegroundColor Gray
Write-Host "2. Run: docker-compose up -d" -ForegroundColor Gray

Write-Host "`nStep 4: Test Live Data" -ForegroundColor Cyan
Write-Host "1. Open: http://localhost:3000" -ForegroundColor Gray
Write-Host "2. Click 'Track Now' button" -ForegroundColor Gray
Write-Host "3. Check that Data Source shows 'github_api' instead of 'json_fallback'" -ForegroundColor Gray

# Show expected results
Write-Host "`n4. Expected Results:" -ForegroundColor Yellow
Write-Host "===================" -ForegroundColor Yellow
Write-Host "✅ Data Source: github_api (instead of json_fallback)" -ForegroundColor Green
Write-Host "✅ Repository: jafar90147677/Ai-Agent (instead of your-username/your-repo)" -ForegroundColor Green
Write-Host "✅ Real commits from your GitHub repository" -ForegroundColor Green
Write-Host "✅ Live data that updates when you make new commits" -ForegroundColor Green

# Test current API
Write-Host "`n5. Testing Current API:" -ForegroundColor Yellow
Write-Host "======================" -ForegroundColor Yellow
Write-Host "Testing /track-now endpoint..." -ForegroundColor White

try {
    $response = Invoke-RestMethod -Uri "http://localhost:8000/track-now" -Method Get -TimeoutSec 10
    Write-Host "✅ API is responding" -ForegroundColor Green
    Write-Host "Data Source: $($response.source)" -ForegroundColor White
    Write-Host "Total Commits: $($response.total_commits)" -ForegroundColor White
    Write-Host "Message: $($response.message)" -ForegroundColor White
} catch {
    Write-Host "❌ API not responding: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n🎯 Next Steps:" -ForegroundColor Green
Write-Host "=============" -ForegroundColor Green
Write-Host "1. Get your GitHub Personal Access Token" -ForegroundColor White
Write-Host "2. Update the .env file with your token" -ForegroundColor White
Write-Host "3. Restart Docker containers" -ForegroundColor White
Write-Host "4. Test the UI to see live GitHub data" -ForegroundColor White

Write-Host "`n✅ JSON fallback removed - system will now fetch live data from GitHub!" -ForegroundColor Green
