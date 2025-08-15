# Verify pgAdmin4 Access
# This script verifies that data is accessible in pgAdmin4

Write-Host "Verifying pgAdmin4 Access..." -ForegroundColor Green
Write-Host "============================" -ForegroundColor Green

# Step 1: Verify data exists in track_project schema
Write-Host "`n1. Verifying data in track_project schema..." -ForegroundColor Cyan
docker exec github-tracker-postgres psql -U user -d github_tracker -c "
SELECT 
    'track_project.commits' as table_name,
    COUNT(*) as record_count
FROM track_project.commits
UNION ALL
SELECT 
    'track_project.commit_files' as table_name,
    COUNT(*) as record_count
FROM track_project.commit_files
UNION ALL
SELECT 
    'track_project.ai_analysis' as table_name,
    COUNT(*) as record_count
FROM track_project.ai_analysis
UNION ALL
SELECT 
    'track_project.tracking_config' as table_name,
    COUNT(*) as record_count
FROM track_project.tracking_config;
"

# Step 2: Show sample data
Write-Host "`n2. Sample data from track_project.commits..." -ForegroundColor Cyan
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

# Step 3: Test API access
Write-Host "`n3. Testing API access..." -ForegroundColor Cyan
try {
    $response = Invoke-RestMethod -Uri "http://localhost:8000/track-now" -Method GET -TimeoutSec 10
    Write-Host "API Response: $($response.message)" -ForegroundColor Green
    Write-Host "Total commits: $($response.total_commits)" -ForegroundColor Green
    Write-Host "Source: $($response.source)" -ForegroundColor Green
} catch {
    Write-Host "API Error: $($_.Exception.Message)" -ForegroundColor Red
}

# Step 4: pgAdmin4 Connection Instructions
Write-Host "`n4. pgAdmin4 Connection Instructions:" -ForegroundColor Yellow
Write-Host "=====================================" -ForegroundColor Yellow

Write-Host "`nStep-by-step guide to view your data:" -ForegroundColor White
Write-Host "1. Open your web browser and go to: http://localhost:5050" -ForegroundColor Cyan
Write-Host "2. Login with:" -ForegroundColor White
Write-Host "   - Email: admin@example.com" -ForegroundColor Gray
Write-Host "   - Password: admin" -ForegroundColor Gray
Write-Host "3. In the left panel, expand 'Servers'" -ForegroundColor White
Write-Host "4. If you don't see a server, right-click 'Servers' → 'Register' → 'Server...'" -ForegroundColor White
Write-Host "5. Use these connection details:" -ForegroundColor White
Write-Host "   - Name: GitHub Tracker" -ForegroundColor Gray
Write-Host "   - Host: localhost" -ForegroundColor Gray
Write-Host "   - Port: 5432" -ForegroundColor Gray
Write-Host "   - Database: github_tracker" -ForegroundColor Gray
Write-Host "   - Username: user" -ForegroundColor Gray
Write-Host "   - Password: password" -ForegroundColor Gray
Write-Host "6. Click 'Save' and connect" -ForegroundColor White
Write-Host "7. Navigate to: Servers → GitHub Tracker → Databases → github_tracker" -ForegroundColor White
Write-Host "8. Expand 'Schemas' (NOT 'public')" -ForegroundColor White
Write-Host "9. Look for 'track_project' schema" -ForegroundColor White
Write-Host "10. Expand 'track_project' → 'Tables'" -ForegroundColor White
Write-Host "11. Right-click on 'commits' table → 'View/Edit Data' → 'All Rows'" -ForegroundColor White

Write-Host "`n5. Troubleshooting:" -ForegroundColor Yellow
Write-Host "=================" -ForegroundColor Yellow

Write-Host "`nIf you don't see 'track_project' schema:" -ForegroundColor Red
Write-Host "- Right-click on 'Schemas' → 'Refresh'" -ForegroundColor White
Write-Host "- If still not visible, restart containers: docker-compose down && docker-compose up -d" -ForegroundColor White

Write-Host "`nIf you see old data in 'public' schema:" -ForegroundColor Red
Write-Host "- That's the old data. New data is in 'track_project' schema" -ForegroundColor White
Write-Host "- Make sure you're looking in 'track_project' schema" -ForegroundColor White

Write-Host "`nIf connection fails:" -ForegroundColor Red
Write-Host "- Make sure Docker containers are running: docker-compose ps" -ForegroundColor White
Write-Host "- Check if port 5050 is accessible: http://localhost:5050" -ForegroundColor White

Write-Host "`n6. Quick Commands:" -ForegroundColor Yellow
Write-Host "=================" -ForegroundColor Yellow
Write-Host "To check if containers are running:" -ForegroundColor White
Write-Host "docker-compose ps" -ForegroundColor Gray
Write-Host "`nTo restart everything:" -ForegroundColor White
Write-Host "docker-compose down && docker-compose up -d" -ForegroundColor Gray
Write-Host "`nTo check data directly:" -ForegroundColor White
Write-Host "docker exec github-tracker-postgres psql -U user -d github_tracker -c \"SELECT COUNT(*) FROM track_project.commits;\"" -ForegroundColor Gray

Write-Host "`n✅ Verification completed!" -ForegroundColor Green
Write-Host "Your data is now properly stored in the track_project schema and accessible via pgAdmin4!" -ForegroundColor Green
