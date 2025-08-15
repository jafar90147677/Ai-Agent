# Test Track Project Schema
# This script tests the track_project schema and verifies data storage

Write-Host "Testing Track Project Schema..." -ForegroundColor Green

# Test 1: Check if track_project schema exists
Write-Host "`n1. Checking if track_project schema exists..." -ForegroundColor Cyan
docker exec github-tracker-postgres psql -U user -d github_tracker -c "
SELECT schema_name 
FROM information_schema.schemata 
WHERE schema_name = 'track_project';
"

# Test 2: Check if tables exist in track_project schema
Write-Host "`n2. Checking tables in track_project schema..." -ForegroundColor Cyan
docker exec github-tracker-postgres psql -U user -d github_tracker -c "
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'track_project' 
ORDER BY table_name;
"

# Test 3: Check commits table structure
Write-Host "`n3. Checking track_project.commits table structure..." -ForegroundColor Cyan
docker exec github-tracker-postgres psql -U user -d github_tracker -c "
\d track_project.commits;
"

# Test 4: Check if any data exists in commits table
Write-Host "`n4. Checking for data in track_project.commits..." -ForegroundColor Cyan
docker exec github-tracker-postgres psql -U user -d github_tracker -c "
SELECT COUNT(*) as total_commits FROM track_project.commits;
"

# Test 5: Show sample data if exists
Write-Host "`n5. Sample data from track_project.commits..." -ForegroundColor Cyan
docker exec github-tracker-postgres psql -U user -d github_tracker -c "
SELECT id, commit_sha, message, author, created_at 
FROM track_project.commits 
ORDER BY created_at DESC 
LIMIT 5;
"

# Test 6: Check tracking_config table
Write-Host "`n6. Checking track_project.tracking_config..." -ForegroundColor Cyan
docker exec github-tracker-postgres psql -U user -d github_tracker -c "
SELECT * FROM track_project.tracking_config;
"

# Test 7: Test database service connection
Write-Host "`n7. Testing database service health..." -ForegroundColor Cyan
try {
    $response = Invoke-RestMethod -Uri "http://localhost:8003/health" -Method GET
    Write-Host "Database service status: $($response.status)" -ForegroundColor Green
} catch {
    Write-Host "Database service not responding: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 8: Test track-now endpoint
Write-Host "`n8. Testing track-now endpoint..." -ForegroundColor Cyan
try {
    $response = Invoke-RestMethod -Uri "http://localhost:8003/track-now" -Method GET
    Write-Host "Track-now response: $($response.message)" -ForegroundColor Green
    Write-Host "Source: $($response.source)" -ForegroundColor Yellow
    Write-Host "Total commits: $($response.total_commits)" -ForegroundColor Yellow
} catch {
    Write-Host "Track-now endpoint error: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`nSchema test completed!" -ForegroundColor Green
Write-Host "`nTo view data in pgAdmin4:" -ForegroundColor Yellow
Write-Host "1. Open http://localhost:5050" -ForegroundColor White
Write-Host "2. Login with admin@example.com / admin" -ForegroundColor White
Write-Host "3. Connect to postgres server" -ForegroundColor White
Write-Host "4. Navigate to: github_tracker > track_project > Tables" -ForegroundColor White
Write-Host "5. Right-click on commits table and select 'View/Edit Data'" -ForegroundColor White
