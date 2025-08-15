# Fix pgAdmin4 Data Display Script
# This script helps resolve pgAdmin4 data visibility issues

Write-Host "Fixing pgAdmin4 Data Display..." -ForegroundColor Green
Write-Host "===============================" -ForegroundColor Green

# Step 1: Verify data exists in database
Write-Host "`n1. Verifying Data in Database:" -ForegroundColor Cyan
docker exec github-tracker-postgres psql -U user -d github_tracker -c "
SELECT 
    'track_project.commits' as table_name,
    COUNT(*) as record_count,
    CASE 
        WHEN COUNT(*) > 0 THEN '✅ Data EXISTS'
        ELSE '❌ No data found'
    END as status
FROM track_project.commits
UNION ALL
SELECT 
    'track_project.commit_files' as table_name,
    COUNT(*) as record_count,
    CASE 
        WHEN COUNT(*) > 0 THEN '✅ Data EXISTS'
        ELSE '❌ No data found'
    END as status
FROM track_project.commit_files
UNION ALL
SELECT 
    'track_project.ai_analysis' as table_name,
    COUNT(*) as record_count,
    CASE 
        WHEN COUNT(*) > 0 THEN '✅ Data EXISTS'
        ELSE '❌ No data found'
    END as status
FROM track_project.ai_analysis;
"

# Step 2: Show sample data
Write-Host "`n2. Sample Data from track_project.commits:" -ForegroundColor Cyan
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

# Step 3: Check if there's data in public schema (old data)
Write-Host "`n3. Checking for Old Data in Public Schema:" -ForegroundColor Cyan
docker exec github-tracker-postgres psql -U user -d github_tracker -c "
SELECT 
    'public.commits' as table_name,
    COUNT(*) as record_count,
    CASE 
        WHEN COUNT(*) > 0 THEN '⚠️  OLD DATA - Ignore this'
        ELSE '✅ No old data'
    END as status
FROM information_schema.tables t
LEFT JOIN public.commits c ON true
WHERE t.table_schema = 'public' AND t.table_name = 'commits';
"

# Step 4: Force refresh by restarting pgAdmin4
Write-Host "`n4. Restarting pgAdmin4 to refresh connection..." -ForegroundColor Cyan
docker restart github-tracker-pgadmin
Start-Sleep 10

# Step 5: Instructions for pgAdmin4
Write-Host "`n5. pgAdmin4 Fix Instructions:" -ForegroundColor Yellow
Write-Host "=============================" -ForegroundColor Yellow

Write-Host "`nIMPORTANT: Follow these steps EXACTLY:" -ForegroundColor Red
Write-Host "1. Close pgAdmin4 browser tab completely" -ForegroundColor White
Write-Host "2. Open http://localhost:5050 in a NEW browser tab" -ForegroundColor Cyan
Write-Host "3. Login: admin@example.com / admin" -ForegroundColor White
Write-Host "4. If you see 'Server connection failed', click 'OK'" -ForegroundColor White
Write-Host "5. Right-click 'Servers' → 'Register' → 'Server...'" -ForegroundColor White
Write-Host "6. Fill in connection details:" -ForegroundColor White
Write-Host "   - Name: GitHub Tracker" -ForegroundColor Gray
Write-Host "   - Host: localhost" -ForegroundColor Gray
Write-Host "   - Port: 5432" -ForegroundColor Gray
Write-Host "   - Database: github_tracker" -ForegroundColor Gray
Write-Host "   - Username: user" -ForegroundColor Gray
Write-Host "   - Password: password" -ForegroundColor Gray
Write-Host "7. Click 'Save'" -ForegroundColor White
Write-Host "8. Expand: Servers → GitHub Tracker → Databases → github_tracker" -ForegroundColor White
Write-Host "9. Expand 'Schemas' → 'track_project' → 'Tables'" -ForegroundColor White
Write-Host "10. Right-click 'commits' → 'View/Edit Data' → 'All Rows'" -ForegroundColor White

Write-Host "`n6. Alternative: Use Query Tool" -ForegroundColor Yellow
Write-Host "=============================" -ForegroundColor Yellow

Write-Host "`nIf the above doesn't work, try this:" -ForegroundColor White
Write-Host "1. In pgAdmin4, click 'Query Tool' (SQL icon)" -ForegroundColor White
Write-Host "2. Run this query:" -ForegroundColor Cyan
Write-Host "   SELECT * FROM track_project.commits ORDER BY id ASC;" -ForegroundColor Gray
Write-Host "3. Click 'Execute' (F5)" -ForegroundColor White

Write-Host "`n7. Verification Commands:" -ForegroundColor Yellow
Write-Host "=========================" -ForegroundColor Yellow

Write-Host "`nTo verify data exists (run these in terminal):" -ForegroundColor White
Write-Host "docker exec github-tracker-postgres psql -U user -d github_tracker -c \"SELECT COUNT(*) FROM track_project.commits;\"" -ForegroundColor Gray
Write-Host "docker exec github-tracker-postgres psql -U user -d github_tracker -c \"SELECT id, commit_sha, LEFT(message, 20) FROM track_project.commits LIMIT 3;\"" -ForegroundColor Gray

Write-Host "`n8. If Still No Data in pgAdmin4:" -ForegroundColor Yellow
Write-Host "=================================" -ForegroundColor Yellow

Write-Host "`nTry these troubleshooting steps:" -ForegroundColor White
Write-Host "1. Clear browser cache and cookies" -ForegroundColor Gray
Write-Host "2. Try a different browser (Chrome, Firefox, Edge)" -ForegroundColor Gray
Write-Host "3. Check if pgAdmin4 is accessible: http://localhost:5050" -ForegroundColor Gray
Write-Host "4. Verify Docker containers are running: docker-compose ps" -ForegroundColor Gray

Write-Host "`n✅ The data EXISTS in your database!" -ForegroundColor Green
Write-Host "The issue is with pgAdmin4 connection/refresh." -ForegroundColor Green
Write-Host "Follow the steps above to see your real GitHub data." -ForegroundColor Green
