# Force Fetch Fresh Data Script
# This script forces fresh data from GitHub and ensures it's stored properly

Write-Host "Force Fetching Fresh Data from GitHub..." -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green

# Step 1: Check current data
Write-Host "`n1. Current Data Status:" -ForegroundColor Cyan
docker exec github-tracker-postgres psql -U user -d github_tracker -c "
SELECT 
    'track_project.commits' as table_name,
    COUNT(*) as record_count
FROM track_project.commits;
"

# Step 2: Show current commits
Write-Host "`n2. Current Commits in Database:" -ForegroundColor Cyan
docker exec github-tracker-postgres psql -U user -d github_tracker -c "
SELECT 
    id,
    commit_sha,
    LEFT(message, 40) as message_preview,
    author,
    created_at
FROM track_project.commits 
ORDER BY created_at DESC 
LIMIT 5;
"

# Step 3: Force fetch from GitHub
Write-Host "`n3. Force Fetching from GitHub..." -ForegroundColor Cyan
try {
    $response = Invoke-RestMethod -Uri "http://localhost:8000/fetch-commits" -Method POST -TimeoutSec 30
    Write-Host "GitHub Response: $($response.message)" -ForegroundColor Green
    Write-Host "Timestamp: $($response.timestamp)" -ForegroundColor Green
} catch {
    Write-Host "Error fetching from GitHub: $($_.Exception.Message)" -ForegroundColor Red
}

# Step 4: Wait for processing
Write-Host "`n4. Waiting for data processing..." -ForegroundColor Cyan
Start-Sleep 20

# Step 5: Check updated data
Write-Host "`n5. Updated Data Status:" -ForegroundColor Cyan
docker exec github-tracker-postgres psql -U user -d github_tracker -c "
SELECT 
    'track_project.commits' as table_name,
    COUNT(*) as record_count
FROM track_project.commits;
"

# Step 6: Show updated commits
Write-Host "`n6. Updated Commits in Database:" -ForegroundColor Cyan
docker exec github-tracker-postgres psql -U user -d github_tracker -c "
SELECT 
    id,
    commit_sha,
    LEFT(message, 40) as message_preview,
    author,
    created_at
FROM track_project.commits 
ORDER BY created_at DESC 
LIMIT 10;
"

# Step 7: Test API response
Write-Host "`n7. Testing API Response:" -ForegroundColor Cyan
try {
    $apiResponse = Invoke-RestMethod -Uri "http://localhost:8000/track-now" -Method GET -TimeoutSec 10
    Write-Host "API Response: $($apiResponse.message)" -ForegroundColor Green
    Write-Host "Total commits: $($apiResponse.total_commits)" -ForegroundColor Green
    Write-Host "Source: $($apiResponse.source)" -ForegroundColor Green
} catch {
    Write-Host "API Error: $($_.Exception.Message)" -ForegroundColor Red
}

# Step 8: Instructions for pgAdmin4
Write-Host "`n8. How to See Data in pgAdmin4:" -ForegroundColor Yellow
Write-Host "=================================" -ForegroundColor Yellow

Write-Host "`nIn your existing pgAdmin4:" -ForegroundColor White
Write-Host "1. Right-click on 'track_project' schema → 'Refresh'" -ForegroundColor Cyan
Write-Host "2. Right-click on 'commits' table → 'View/Edit Data' → 'All Rows'" -ForegroundColor White
Write-Host "3. OR use Query Tool and run:" -ForegroundColor White
Write-Host "   SELECT * FROM track_project.commits ORDER BY created_at DESC;" -ForegroundColor Gray

Write-Host "`n9. What You Should See:" -ForegroundColor Yellow
Write-Host "=======================" -ForegroundColor Yellow

Write-Host "`nIn pgAdmin4:" -ForegroundColor White
Write-Host "- Real GitHub commits with commit messages" -ForegroundColor Gray
Write-Host "- Author information and timestamps" -ForegroundColor Gray
Write-Host "- Commit SHAs from your repository" -ForegroundColor Gray
Write-Host "- AI analysis results (if available)" -ForegroundColor Gray

Write-Host "`nIn Your UI:" -ForegroundColor White
Write-Host "- Open http://localhost:3000" -ForegroundColor Cyan
Write-Host "- Click 'Track Now' button" -ForegroundColor White
Write-Host "- You should see the same data!" -ForegroundColor White

Write-Host "`n✅ Fresh data fetch completed!" -ForegroundColor Green
Write-Host "Now refresh pgAdmin4 to see your real GitHub data!" -ForegroundColor Green
