# Test Local pgAdmin4 Desktop App Connection
Write-Host "Testing PostgreSQL Connection for Local pgAdmin4 Desktop App..." -ForegroundColor Cyan

# Check if Docker containers are running
Write-Host "`nChecking Docker containers..." -ForegroundColor Yellow
docker-compose ps | findstr postgres

# Test PostgreSQL connection
Write-Host "`nTesting PostgreSQL connection..." -ForegroundColor Yellow
try {
    $result = docker exec github-tracker-postgres psql -U user -d github_tracker_db -c "SELECT version();"
    if ($LASTEXITCODE -eq 0) {
        Write-Host "PostgreSQL connection successful!" -ForegroundColor Green
    } else {
        Write-Host "PostgreSQL connection failed!" -ForegroundColor Red
        Write-Host $result -ForegroundColor Red
    }
} catch {
    Write-Host "Error testing connection: $_" -ForegroundColor Red
}

# Show connection details for local pgAdmin4
Write-Host "`nLocal pgAdmin4 Desktop App Connection Details:" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "Host name/address: localhost" -ForegroundColor White
Write-Host "Port: 5432" -ForegroundColor White
Write-Host "Maintenance database: github_tracker_db" -ForegroundColor White
Write-Host "Username: user" -ForegroundColor White
Write-Host "Password: password" -ForegroundColor White
Write-Host "Save password: ✅ (check this box)" -ForegroundColor White

# Show sample data
Write-Host "`nSample Data Available:" -ForegroundColor Cyan
docker exec github-tracker-postgres psql -U user -d github_tracker_db -c "SELECT id, commit_sha, message, author FROM track_project.commits LIMIT 3;"

Write-Host "`nStep-by-Step Connection Guide:" -ForegroundColor Green
Write-Host "=============================" -ForegroundColor Green
Write-Host "1. Open pgAdmin4 Desktop Application" -ForegroundColor White
Write-Host "2. Right-click on 'Servers' → 'Register' → 'Server...'" -ForegroundColor White
Write-Host "3. General Tab:" -ForegroundColor White
Write-Host "   - Name: GitHub Tracker" -ForegroundColor Gray
Write-Host "4. Connection Tab:" -ForegroundColor White
Write-Host "   - Host name/address: localhost" -ForegroundColor Gray
Write-Host "   - Port: 5432" -ForegroundColor Gray
Write-Host "   - Maintenance database: github_tracker_db" -ForegroundColor Gray
Write-Host "   - Username: user" -ForegroundColor Gray
Write-Host "   - Password: password" -ForegroundColor Gray
Write-Host "   - Save password: ✅ (check this box)" -ForegroundColor Gray
Write-Host "5. Click 'Test Connection' button" -ForegroundColor White
Write-Host "6. If successful, click 'Save'" -ForegroundColor White
Write-Host "7. Browse to: Servers → GitHub Tracker → Databases → github_tracker_db → Schemas → track_project → Tables" -ForegroundColor White
Write-Host "8. Right-click on 'commits' table → 'View/Edit Data' → 'All Rows'" -ForegroundColor White

Write-Host "`nExpected Data:" -ForegroundColor Yellow
Write-Host "==============" -ForegroundColor Yellow
Write-Host "You should see 7 commits from your GitHub repository:" -ForegroundColor White
Write-Host "- Recent commits from jafar90147677/Ai-Agent" -ForegroundColor Gray
Write-Host "- Including 'Create readme.md', 'at ok', 'test', etc." -ForegroundColor Gray

Write-Host "`nTroubleshooting:" -ForegroundColor Yellow
Write-Host "===============" -ForegroundColor Yellow
Write-Host "If connection fails:" -ForegroundColor White
Write-Host "1. Make sure Docker containers are running: docker-compose ps" -ForegroundColor Gray
Write-Host "2. Check if port 5432 is not blocked by firewall" -ForegroundColor Gray
Write-Host "3. Try restarting Docker Desktop if needed" -ForegroundColor Gray
Write-Host "4. Verify PostgreSQL is accessible: docker exec github-tracker-postgres psql -U user -d github_tracker_db -c 'SELECT 1;'" -ForegroundColor Gray

Write-Host "`n✅ Ready to connect with your local pgAdmin4 Desktop App!" -ForegroundColor Green
