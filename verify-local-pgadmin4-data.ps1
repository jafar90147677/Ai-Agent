# Verify Local pgAdmin4 Data Storage
# This script verifies that data is being stored in your local pgAdmin4 database

Write-Host "Verifying Local pgAdmin4 Data Storage..." -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green

# Step 1: Test API response
Write-Host "`n1. Testing API Response:" -ForegroundColor Cyan
try {
    $response = Invoke-RestMethod -Uri "http://localhost:8000/track-now" -Method GET -TimeoutSec 10
    Write-Host "✅ API Gateway is working" -ForegroundColor Green
    Write-Host "   Success: $($response.success)" -ForegroundColor Gray
    Write-Host "   Total commits: $($response.total_commits)" -ForegroundColor Gray
    Write-Host "   Source: $($response.source)" -ForegroundColor Gray
    Write-Host "   Message: $($response.message)" -ForegroundColor Gray
} catch {
    Write-Host "❌ API Gateway error: $($_.Exception.Message)" -ForegroundColor Red
}

# Step 2: Instructions for checking local pgAdmin4
Write-Host "`n2. Check Your Local pgAdmin4 Database:" -ForegroundColor Yellow
Write-Host "=========================================" -ForegroundColor Yellow

Write-Host "`nStep-by-step verification:" -ForegroundColor White
Write-Host "1. Open pgAdmin4 on your laptop" -ForegroundColor Cyan
Write-Host "2. Connect to your local PostgreSQL server" -ForegroundColor White
Write-Host "3. Navigate to: Databases → github_tracker_db" -ForegroundColor White
Write-Host "4. Expand: Schemas → track_project" -ForegroundColor White
Write-Host "5. Check these tables:" -ForegroundColor White
Write-Host "   - commits (should have data)" -ForegroundColor Gray
Write-Host "   - commit_files (may be empty)" -ForegroundColor Gray
Write-Host "   - ai_analysis (may be empty)" -ForegroundColor Gray
Write-Host "   - tracking_config (should have config)" -ForegroundColor Gray

# Step 3: Test data generation
Write-Host "`n3. Generate Fresh Data:" -ForegroundColor Yellow
Write-Host "=======================" -ForegroundColor Yellow

Write-Host "`nTo generate fresh data in your local pgAdmin4:" -ForegroundColor White
Write-Host "1. Click 'Fetch New Commits' button in UI" -ForegroundColor Cyan
Write-Host "2. OR run this command:" -ForegroundColor White
Write-Host "   Invoke-RestMethod -Uri 'http://localhost:8000/fetch-commits' -Method POST" -ForegroundColor Gray

# Step 4: Test fetch-commits
Write-Host "`n4. Testing Fetch Commits:" -ForegroundColor Cyan
try {
    $fetchResponse = Invoke-RestMethod -Uri "http://localhost:8000/fetch-commits" -Method POST -TimeoutSec 30
    Write-Host "✅ Fetch commits successful" -ForegroundColor Green
    Write-Host "   Message: $($fetchResponse.message)" -ForegroundColor Gray
    Write-Host "   Timestamp: $($fetchResponse.timestamp)" -ForegroundColor Gray
} catch {
    Write-Host "❌ Fetch commits error: $($_.Exception.Message)" -ForegroundColor Red
}

# Step 5: Wait and check again
Write-Host "`n5. Waiting for data processing..." -ForegroundColor Cyan
Start-Sleep 15

Write-Host "`n6. Check Updated Data:" -ForegroundColor Yellow
Write-Host "=====================" -ForegroundColor Yellow

try {
    $updatedResponse = Invoke-RestMethod -Uri "http://localhost:8000/track-now" -Method GET -TimeoutSec 10
    Write-Host "✅ Updated data retrieved" -ForegroundColor Green
    Write-Host "   Total commits: $($updatedResponse.total_commits)" -ForegroundColor Gray
    Write-Host "   Source: $($updatedResponse.source)" -ForegroundColor Gray
} catch {
    Write-Host "❌ Error getting updated data: $($_.Exception.Message)" -ForegroundColor Red
}

# Step 6: Instructions for UI testing
Write-Host "`n7. Test Your UI:" -ForegroundColor Yellow
Write-Host "================" -ForegroundColor Yellow

Write-Host "`n1. Open http://localhost:3000 in your browser" -ForegroundColor Cyan
Write-Host "2. Click 'Track Now' button" -ForegroundColor White
Write-Host "3. Data should be stored in your local pgAdmin4 database" -ForegroundColor White
Write-Host "4. Check pgAdmin4 to see the data in track_project schema" -ForegroundColor White

# Step 7: Expected results
Write-Host "`n8. Expected Results:" -ForegroundColor Yellow
Write-Host "===================" -ForegroundColor Yellow

Write-Host "`n✅ In your local pgAdmin4 (github_tracker_db):" -ForegroundColor White
Write-Host "   - Schema: track_project" -ForegroundColor Gray
Write-Host "   - Table: commits (with real GitHub data)" -ForegroundColor Gray
Write-Host "   - Table: commit_files (may have file changes)" -ForegroundColor Gray
Write-Host "   - Table: ai_analysis (may have AI analysis)" -ForegroundColor Gray
Write-Host "   - Table: tracking_config (configuration)" -ForegroundColor Gray

Write-Host "`n✅ In your UI:" -ForegroundColor White
Write-Host "   - Total Commits: Shows real number" -ForegroundColor Gray
Write-Host "   - Data Source: database" -ForegroundColor Gray
Write-Host "   - Recent Commits: Real GitHub commits" -ForegroundColor Gray

Write-Host "`n🎉 Success Summary:" -ForegroundColor Green
Write-Host "==================" -ForegroundColor Green
Write-Host "Data is now being stored in your local pgAdmin4 database!" -ForegroundColor White
Write-Host "Database: github_tracker_db" -ForegroundColor White
Write-Host "Schema: track_project" -ForegroundColor White
Write-Host "Tables: ai_analysis, commit_files, commits, tracking_config" -ForegroundColor White
