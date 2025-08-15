# GitHub Integration Setup Script
Write-Host "GitHub Integration Setup" -ForegroundColor Green
Write-Host "================================" -ForegroundColor Green

# Get GitHub Token
Write-Host "`n1. GitHub Personal Access Token:" -ForegroundColor Yellow
Write-Host "   - Go to: https://github.com/settings/tokens" -ForegroundColor Cyan
Write-Host "   - Click 'Generate new token (classic)'" -ForegroundColor Cyan
Write-Host "   - Select scopes: 'repo' (private) or 'public_repo' (public)" -ForegroundColor Cyan
Write-Host "   - Copy the token and paste it below:" -ForegroundColor Cyan

$githubToken = Read-Host "   Enter your GitHub token"

# Get Repository
Write-Host "`n2. GitHub Repository:" -ForegroundColor Yellow
Write-Host "   Format: username/repository-name" -ForegroundColor Cyan
Write-Host "   Example: john/my-awesome-project" -ForegroundColor Cyan

$githubRepo = Read-Host "   Enter your repository (username/repo)"

# Update .env file
Write-Host "`n3. Updating .env file..." -ForegroundColor Yellow

$envContent = @"
# GitHub Configuration
GITHUB_TOKEN=$githubToken
GITHUB_REPO=$githubRepo

# Database Configuration
DATABASE_URL=postgresql://user:password@postgres:5432/github_tracker

# Application Configuration
DEBUG=False
AI_CHECK_INTERVAL=300
AI_CONFIDENCE_THRESHOLD=0.7
"@

$envContent | Out-File -FilePath ".env" -Encoding UTF8

Write-Host "   .env file updated successfully!" -ForegroundColor Green

# Restart services
Write-Host "`n4. Restarting services..." -ForegroundColor Yellow
Write-Host "   This will restart the Docker containers with new configuration" -ForegroundColor Cyan

$restart = Read-Host "   Do you want to restart services now? (y/n)"

if ($restart -eq 'y' -or $restart -eq 'Y') {
    Write-Host "   Restarting Docker containers..." -ForegroundColor Cyan
    docker-compose restart github-service ai-service database-service api-gateway-service react-frontend
    Write-Host "   Services restarted!" -ForegroundColor Green
}

Write-Host "`nSetup Complete!" -ForegroundColor Green
Write-Host "================================" -ForegroundColor Green
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Open http://localhost:3000 in your browser" -ForegroundColor Cyan
Write-Host "2. Click 'Track Now' to fetch your real commits" -ForegroundColor Cyan
Write-Host "3. You should see your actual GitHub data with AI analysis!" -ForegroundColor Cyan

Write-Host "`nNote: If you see sample data, check that:" -ForegroundColor Yellow
Write-Host "   - Your GitHub token is valid" -ForegroundColor Cyan
Write-Host "   - Your repository name is correct" -ForegroundColor Cyan
Write-Host "   - The repository is accessible with your token" -ForegroundColor Cyan
