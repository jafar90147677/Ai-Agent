# Setup Live GitHub Data Fetching
Write-Host "Setting up Live GitHub Data Fetching..." -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan

# Check if .env file exists
Write-Host "`n1. Checking Environment Configuration..." -ForegroundColor Yellow
if (Test-Path ".env") {
    Write-Host "✅ .env file exists" -ForegroundColor Green
} else {
    Write-Host "❌ .env file not found - creating one..." -ForegroundColor Red
    Copy-Item "env.example" ".env"
    Write-Host "✅ .env file created from template" -ForegroundColor Green
}

# Show current configuration
Write-Host "`n2. Current Configuration:" -ForegroundColor Yellow
Write-Host "=========================" -ForegroundColor Yellow
if (Test-Path ".env") {
    Get-Content ".env" | ForEach-Object {
        if ($_ -match "GITHUB_TOKEN|GITHUB_REPO") {
            Write-Host $_ -ForegroundColor White
        }
    }
}

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
Write-Host "3. Replace 'your-username/your-repository' with 'jafar90147677/Ai-Agent'" -ForegroundColor Gray

Write-Host "`nStep 3: Restart Services" -ForegroundColor Cyan
Write-Host "1. Stop containers: docker-compose down" -ForegroundColor Gray
Write-Host "2. Start containers: docker-compose up -d" -ForegroundColor Gray
Write-Host "3. This will load your GitHub token and start fetching real data" -ForegroundColor Gray

# Show example .env content
Write-Host "`n4. Example .env Configuration:" -ForegroundColor Yellow
Write-Host "==============================" -ForegroundColor Yellow
$exampleEnv = @"
# GitHub Configuration
GITHUB_TOKEN=ghp_your_actual_token_here
GITHUB_REPO=jafar90147677/Ai-Agent

# Database Configuration
DATABASE_URL=postgresql://user:password@postgres:5432/github_tracker_db

# Application Configuration
DEBUG=False
AI_CHECK_INTERVAL=300
AI_CONFIDENCE_THRESHOLD=0.7
"@

Write-Host $exampleEnv -ForegroundColor Gray

# Test current setup
Write-Host "`n5. Testing Current Setup..." -ForegroundColor Yellow
Write-Host "===========================" -ForegroundColor Yellow

# Check if services are running
Write-Host "`nChecking Docker services..." -ForegroundColor White
docker-compose ps | findstr "github-service\|api-gateway"

# Show how to trigger data fetch
Write-Host "`n6. How to Fetch Live Data:" -ForegroundColor Yellow
Write-Host "=========================" -ForegroundColor Yellow
Write-Host "After setting up your GitHub token:" -ForegroundColor White
Write-Host "1. Open your UI: http://localhost:3000" -ForegroundColor Gray
Write-Host "2. Click 'Track Now' button" -ForegroundColor Gray
Write-Host "3. This will fetch the latest commits from your GitHub repository" -ForegroundColor Gray
Write-Host "4. Check pgAdmin4 to see the new data" -ForegroundColor Gray

Write-Host "`n7. Expected Results:" -ForegroundColor Yellow
Write-Host "===================" -ForegroundColor Yellow
Write-Host "✅ Real commits from jafar90147677/Ai-Agent repository" -ForegroundColor Green
Write-Host "✅ Latest commit messages, authors, timestamps" -ForegroundColor Green
Write-Host "✅ File changes, additions, deletions" -ForegroundColor Green
Write-Host "✅ AI analysis of commit patterns" -ForegroundColor Green

Write-Host "`n🎯 Next Steps:" -ForegroundColor Green
Write-Host "=============" -ForegroundColor Green
Write-Host "1. Get your GitHub Personal Access Token" -ForegroundColor White
Write-Host "2. Update the .env file with your token and repository" -ForegroundColor White
Write-Host "3. Restart the Docker containers" -ForegroundColor White
Write-Host "4. Use the UI to fetch live data" -ForegroundColor White

Write-Host "`n✅ Ready to fetch live GitHub data!" -ForegroundColor Green
