# Generate Fresh Data Script
# This script fetches fresh commits from GitHub and shows you how to view them

Write-Host "Generating Fresh Data from GitHub..." -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Green

# Step 1: Check current data
Write-Host "`n1. Current Data Status:" -ForegroundColor Cyan
docker exec github-tracker-postgres psql -U user -d github_tracker -c "
SELECT 
    'commits' as table_name,
    COUNT(*) as record_count
FROM track_project.commits
UNION ALL
SELECT 
    'commit_files' as table_name,
    COUNT(*) as record_count
FROM track_project.commit_files
UNION ALL
SELECT 
    'ai_analysis' as table_name,
    COUNT(*) as record_count
FROM track_project.ai_analysis;
"

# Step 2: Fetch fresh commits from GitHub
Write-Host "`n2. Fetching fresh commits from GitHub..." -ForegroundColor Cyan
try {
    $response = Invoke-RestMethod -Uri "http://localhost:8000/fetch-commits" -Method POST -TimeoutSec 30
    Write-Host "GitHub Response: $($response.message)" -ForegroundColor Green
    Write-Host "Timestamp: $($response.timestamp)" -ForegroundColor Green
} catch {
    Write-Host "Error fetching from GitHub: $($_.Exception.Message)" -ForegroundColor Red
}

# Step 3: Wait for processing
Write-Host "`n3. Waiting for data processing..." -ForegroundColor Cyan
Start-Sleep 15

# Step 4: Check updated data
Write-Host "`n4. Updated Data Status:" -ForegroundColor Cyan
docker exec github-tracker-postgres psql -U user -d github_tracker -c "
SELECT 
    'commits' as table_name,
    COUNT(*) as record_count
FROM track_project.commits
UNION ALL
SELECT 
    'commit_files' as table_name,
    COUNT(*) as record_count
FROM track_project.commit_files
UNION ALL
SELECT 
    'ai_analysis' as table_name,
    COUNT(*) as record_count
FROM track_project.ai_analysis;
"

# Step 5: Show latest commits
Write-Host "`n5. Latest Commits:" -ForegroundColor Cyan
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

# Step 6: Test API response
Write-Host "`n6. Testing API Response:" -ForegroundColor Cyan
try {
    $apiResponse = Invoke-RestMethod -Uri "http://localhost:8000/track-now" -Method GET -TimeoutSec 10
    Write-Host "API Response: $($apiResponse.message)" -ForegroundColor Green
    Write-Host "Total commits: $($apiResponse.total_commits)" -ForegroundColor Green
    Write-Host "Source: $($apiResponse.source)" -ForegroundColor Green
} catch {
    Write-Host "API Error: $($_.Exception.Message)" -ForegroundColor Red
}

# Step 7: Instructions for viewing data
Write-Host "`n7. How to View Your Data:" -ForegroundColor Yellow
Write-Host "=========================" -ForegroundColor Yellow

Write-Host "`nIn Your UI (React Frontend):" -ForegroundColor White
Write-Host "1. Open http://localhost:3000 in your browser" -ForegroundColor Cyan
Write-Host "2. Click the 'Track Now' button" -ForegroundColor White
Write-Host "3. You should see the latest commits with AI analysis" -ForegroundColor White

Write-Host "`nIn pgAdmin4:" -ForegroundColor White
Write-Host "1. Open http://localhost:5050 in your browser" -ForegroundColor Cyan
Write-Host "2. Login: admin@example.com / admin" -ForegroundColor White
Write-Host "3. Navigate: Servers → GitHub Tracker → Databases → github_tracker" -ForegroundColor White
Write-Host "4. Expand 'Schemas' → 'track_project' → 'Tables'" -ForegroundColor White
Write-Host "5. Right-click on 'commits' → 'View/Edit Data' → 'All Rows'" -ForegroundColor White
Write-Host "6. You should see all your commits with real data!" -ForegroundColor Green

Write-Host "`n8. What You Should See:" -ForegroundColor Yellow
Write-Host "=====================" -ForegroundColor Yellow

Write-Host "`nIn the UI:" -ForegroundColor White
Write-Host "- List of commits with commit messages" -ForegroundColor Gray
Write-Host "- Author information" -ForegroundColor Gray
Write-Host "- Commit timestamps" -ForegroundColor Gray
Write-Host "- AI analysis results (if available)" -ForegroundColor Gray

Write-Host "`nIn pgAdmin4:" -ForegroundColor White
Write-Host "- commits table: All your GitHub commits" -ForegroundColor Gray
Write-Host "- commit_files table: Files changed in each commit" -ForegroundColor Gray
Write-Host "- ai_analysis table: AI analysis results" -ForegroundColor Gray
Write-Host "- tracking_config table: Configuration settings" -ForegroundColor Gray

Write-Host "`n✅ Data generation completed!" -ForegroundColor Green
Write-Host "Now you can view real data in both your UI and pgAdmin4!" -ForegroundColor Green
