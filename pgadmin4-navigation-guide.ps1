# pgAdmin4 Navigation Guide
# This script helps you navigate pgAdmin4 to find your data

Write-Host "pgAdmin4 Navigation Guide" -ForegroundColor Green
Write-Host "=========================" -ForegroundColor Green

# Step 1: Show current data status
Write-Host "`n1. Current Data Status:" -ForegroundColor Cyan
docker exec github-tracker-postgres psql -U user -d github_tracker -c "
SELECT 
    'public.commits' as table_name,
    COUNT(*) as record_count
FROM public.commits
UNION ALL
SELECT 
    'track_project.commits' as table_name,
    COUNT(*) as record_count
FROM track_project.commits
ORDER BY table_name;
"

Write-Host "`n2. Sample Data from track_project.commits:" -ForegroundColor Cyan
docker exec github-tracker-postgres psql -U user -d github_tracker -c "
SELECT 
    id, 
    commit_sha, 
    LEFT(message, 30) as message_preview,
    author, 
    created_at 
FROM track_project.commits 
ORDER BY created_at DESC 
LIMIT 3;
"

Write-Host "`n3. Detailed pgAdmin4 Navigation Steps:" -ForegroundColor Yellow
Write-Host "=====================================" -ForegroundColor Yellow

Write-Host "`nIMPORTANT: You have data in TWO schemas!" -ForegroundColor Red
Write-Host "- public schema: OLD data (7 commits)" -ForegroundColor White
Write-Host "- track_project schema: NEW data (7 commits) - This is what you want!" -ForegroundColor Green

Write-Host "`nStep-by-step navigation:" -ForegroundColor White
Write-Host "1. Open http://localhost:5050 in your browser" -ForegroundColor Cyan
Write-Host "2. Login with admin@example.com / admin" -ForegroundColor White
Write-Host "3. In the left panel, expand 'Servers'" -ForegroundColor White
Write-Host "4. If no server exists, create one:" -ForegroundColor White
Write-Host "   - Right-click 'Servers' → 'Register' → 'Server...'" -ForegroundColor Gray
Write-Host "   - Name: GitHub Tracker" -ForegroundColor Gray
Write-Host "   - Host: localhost" -ForegroundColor Gray
Write-Host "   - Port: 5432" -ForegroundColor Gray
Write-Host "   - Database: github_tracker" -ForegroundColor Gray
Write-Host "   - Username: user" -ForegroundColor Gray
Write-Host "   - Password: password" -ForegroundColor Gray
Write-Host "5. Expand: Servers → GitHub Tracker → Databases → github_tracker" -ForegroundColor White
Write-Host "6. Expand 'Schemas' (this is crucial!)" -ForegroundColor White
Write-Host "7. You will see TWO schemas:" -ForegroundColor White
Write-Host "   - public (OLD data - ignore this)" -ForegroundColor Gray
Write-Host "   - track_project (NEW data - this is what you want!)" -ForegroundColor Green
Write-Host "8. Expand 'track_project' schema" -ForegroundColor White
Write-Host "9. Expand 'Tables'" -ForegroundColor White
Write-Host "10. You will see:" -ForegroundColor White
Write-Host "    - commits (7 records)" -ForegroundColor Green
Write-Host "    - commit_files (0 records)" -ForegroundColor Yellow
Write-Host "    - ai_analysis (0 records)" -ForegroundColor Yellow
Write-Host "    - tracking_config (1 record)" -ForegroundColor Green
Write-Host "11. Right-click on 'commits' → 'View/Edit Data' → 'All Rows'" -ForegroundColor White

Write-Host "`n4. Why you might not see data:" -ForegroundColor Yellow
Write-Host "=================================" -ForegroundColor Yellow

Write-Host "`nCommon Issues:" -ForegroundColor Red
Write-Host "1. Looking in 'public' schema instead of 'track_project' schema" -ForegroundColor White
Write-Host "2. Not expanding 'Schemas' folder" -ForegroundColor White
Write-Host "3. Schema not refreshed (right-click 'Schemas' → 'Refresh')" -ForegroundColor White
Write-Host "4. Wrong database connection" -ForegroundColor White

Write-Host "`n5. Quick Verification Commands:" -ForegroundColor Yellow
Write-Host "==============================" -ForegroundColor Yellow

Write-Host "`nTo verify data exists:" -ForegroundColor White
Write-Host "docker exec github-tracker-postgres psql -U user -d github_tracker -c \"SELECT COUNT(*) FROM track_project.commits;\"" -ForegroundColor Gray

Write-Host "`nTo see sample data:" -ForegroundColor White
Write-Host "docker exec github-tracker-postgres psql -U user -d github_tracker -c \"SELECT id, commit_sha, LEFT(message, 20) FROM track_project.commits LIMIT 3;\"" -ForegroundColor Gray

Write-Host "`n6. Visual Guide:" -ForegroundColor Yellow
Write-Host "===============" -ForegroundColor Yellow

Write-Host "`npgAdmin4 Structure:" -ForegroundColor White
Write-Host "Servers" -ForegroundColor Gray
Write-Host "└── GitHub Tracker" -ForegroundColor Gray
Write-Host "    └── Databases" -ForegroundColor Gray
Write-Host "        └── github_tracker" -ForegroundColor Gray
Write-Host "            └── Schemas" -ForegroundColor Gray
Write-Host "                ├── public (OLD - ignore)" -ForegroundColor Gray
Write-Host "                └── track_project (NEW - click here!)" -ForegroundColor Green
Write-Host "                    └── Tables" -ForegroundColor Gray
Write-Host "                        ├── commits (7 records)" -ForegroundColor Green
Write-Host "                        ├── commit_files (0 records)" -ForegroundColor Yellow
Write-Host "                        ├── ai_analysis (0 records)" -ForegroundColor Yellow
Write-Host "                        └── tracking_config (1 record)" -ForegroundColor Green

Write-Host "`n✅ Key Point: Look in 'track_project' schema, NOT 'public' schema!" -ForegroundColor Green
