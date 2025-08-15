# Troubleshoot pgAdmin4 Data Display Issues
# This script helps identify why data is not showing in pgAdmin4

Write-Host "Troubleshooting pgAdmin4 Data Display Issues..." -ForegroundColor Green
Write-Host "=================================================" -ForegroundColor Green

# Step 1: Check if Docker containers are running
Write-Host "`n1. Checking Docker containers..." -ForegroundColor Cyan
docker-compose ps

# Step 2: Check if database exists and has data
Write-Host "`n2. Checking database and schema..." -ForegroundColor Cyan
docker exec github-tracker-postgres psql -U user -d github_tracker -c "
SELECT 
    'Database exists' as status,
    current_database() as database_name;
"

# Step 3: Check if track_project schema exists
Write-Host "`n3. Checking track_project schema..." -ForegroundColor Cyan
docker exec github-tracker-postgres psql -U user -d github_tracker -c "
SELECT 
    schema_name,
    'Schema exists' as status
FROM information_schema.schemata 
WHERE schema_name = 'track_project';
"

# Step 4: Check if tables exist in track_project schema
Write-Host "`n4. Checking tables in track_project schema..." -ForegroundColor Cyan
docker exec github-tracker-postgres psql -U user -d github_tracker -c "
SELECT 
    table_name,
    'Table exists' as status
FROM information_schema.tables 
WHERE table_schema = 'track_project' 
ORDER BY table_name;
"

# Step 5: Check if there's any data in commits table
Write-Host "`n5. Checking data in track_project.commits..." -ForegroundColor Cyan
docker exec github-tracker-postgres psql -U user -d github_tracker -c "
SELECT 
    COUNT(*) as total_commits,
    CASE 
        WHEN COUNT(*) > 0 THEN 'Data exists'
        ELSE 'No data found'
    END as status
FROM track_project.commits;
"

# Step 6: Show sample data if exists
Write-Host "`n6. Sample data from track_project.commits..." -ForegroundColor Cyan
docker exec github-tracker-postgres psql -U user -d github_tracker -c "
SELECT 
    id, 
    commit_sha, 
    LEFT(message, 50) as message_preview,
    author, 
    created_at 
FROM track_project.commits 
ORDER BY created_at DESC 
LIMIT 3;
"

# Step 7: Check if there are any commits in public schema (old data)
Write-Host "`n7. Checking for old data in public schema..." -ForegroundColor Cyan
docker exec github-tracker-postgres psql -U user -d github_tracker -c "
SELECT 
    COUNT(*) as commits_in_public,
    CASE 
        WHEN COUNT(*) > 0 THEN 'Old data found in public schema'
        ELSE 'No old data in public schema'
    END as status
FROM information_schema.tables 
WHERE table_schema = 'public' AND table_name = 'commits';
"

# Step 8: Test database service
Write-Host "`n8. Testing database service..." -ForegroundColor Cyan
try {
    $response = Invoke-RestMethod -Uri "http://localhost:8003/health" -Method GET -TimeoutSec 5
    Write-Host "Database service status: $($response.status)" -ForegroundColor Green
    Write-Host "Database connection: $($response.database)" -ForegroundColor Green
} catch {
    Write-Host "Database service not responding: $($_.Exception.Message)" -ForegroundColor Red
}

# Step 9: Test track-now endpoint
Write-Host "`n9. Testing track-now endpoint..." -ForegroundColor Cyan
try {
    $response = Invoke-RestMethod -Uri "http://localhost:8003/track-now" -Method GET -TimeoutSec 10
    Write-Host "Track-now response: $($response.message)" -ForegroundColor Green
    Write-Host "Source: $($response.source)" -ForegroundColor Yellow
    Write-Host "Total commits: $($response.total_commits)" -ForegroundColor Yellow
} catch {
    Write-Host "Track-now endpoint error: $($_.Exception.Message)" -ForegroundColor Red
}

# Step 10: Check pgAdmin4 connection details
Write-Host "`n10. pgAdmin4 Connection Details:" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan
Write-Host "Host name/address: localhost" -ForegroundColor White
Write-Host "Port: 5432" -ForegroundColor White
Write-Host "Maintenance database: github_tracker" -ForegroundColor White
Write-Host "Username: user" -ForegroundColor White
Write-Host "Password: password" -ForegroundColor White
Write-Host "=================================" -ForegroundColor Cyan

# Step 11: Provide troubleshooting steps
Write-Host "`n11. Troubleshooting Steps:" -ForegroundColor Yellow
Write-Host "==========================" -ForegroundColor Yellow

Write-Host "`nIf no data is found:" -ForegroundColor Red
Write-Host "1. Click 'Track Now' button in your UI to generate data" -ForegroundColor White
Write-Host "2. Wait for the process to complete" -ForegroundColor White
Write-Host "3. Run this script again to verify data was created" -ForegroundColor White

Write-Host "`nIf data exists but not visible in pgAdmin4:" -ForegroundColor Red
Write-Host "1. In pgAdmin4, navigate to: Servers -> [Your Server] -> Databases -> github_tracker" -ForegroundColor White
Write-Host "2. Expand 'Schemas' (not 'public')" -ForegroundColor White
Write-Host "3. Look for 'track_project' schema" -ForegroundColor White
Write-Host "4. Expand 'track_project' -> 'Tables'" -ForegroundColor White
Write-Host "5. Right-click on 'commits' table -> 'View/Edit Data' -> 'All Rows'" -ForegroundColor White

Write-Host "`nIf track_project schema is not visible:" -ForegroundColor Red
Write-Host "1. Right-click on 'Schemas' -> 'Refresh'" -ForegroundColor White
Write-Host "2. If still not visible, restart your Docker containers:" -ForegroundColor White
Write-Host "   docker-compose down && docker-compose up -d" -ForegroundColor White

Write-Host "`nIf you see old data in public schema:" -ForegroundColor Red
Write-Host "1. The old data is in the wrong schema" -ForegroundColor White
Write-Host "2. New data will be stored in track_project schema" -ForegroundColor White
Write-Host "3. Click 'Track Now' to generate new data in the correct schema" -ForegroundColor White

Write-Host "`n12. Quick Fix Commands:" -ForegroundColor Yellow
Write-Host "=====================" -ForegroundColor Yellow
Write-Host "To restart everything:" -ForegroundColor White
Write-Host "docker-compose down" -ForegroundColor Gray
Write-Host "docker-compose up -d" -ForegroundColor Gray
Write-Host "Start-Sleep 30" -ForegroundColor Gray
Write-Host ".\test-track-project-schema.ps1" -ForegroundColor Gray

Write-Host "`nTo manually check data:" -ForegroundColor White
Write-Host "docker exec github-tracker-postgres psql -U user -d github_tracker -c \"SELECT COUNT(*) FROM track_project.commits;\"" -ForegroundColor Gray

Write-Host "`nTroubleshooting completed!" -ForegroundColor Green
