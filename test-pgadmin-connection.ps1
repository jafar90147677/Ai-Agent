# Test pgAdmin4 Connection Script
Write-Host "Testing PostgreSQL Connection for pgAdmin4..." -ForegroundColor Cyan

# Check if Docker containers are running
Write-Host "`nChecking Docker containers..." -ForegroundColor Yellow
docker-compose ps | findstr postgres

# Test PostgreSQL connection
Write-Host "`nTesting PostgreSQL connection..." -ForegroundColor Yellow
try {
    $result = docker exec github-tracker-postgres psql -U user -d github_tracker -c "SELECT version();"
    if ($LASTEXITCODE -eq 0) {
        Write-Host "PostgreSQL connection successful!" -ForegroundColor Green
    } else {
        Write-Host "PostgreSQL connection failed!" -ForegroundColor Red
        Write-Host $result -ForegroundColor Red
    }
} catch {
    Write-Host "Error testing connection: $_" -ForegroundColor Red
}

# Show connection details
Write-Host "`npgAdmin4 Connection Details:" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan
Write-Host "Host name/address: localhost" -ForegroundColor White
Write-Host "Port: 5432" -ForegroundColor White
Write-Host "Maintenance database: github_tracker" -ForegroundColor White
Write-Host "Username: user" -ForegroundColor White
Write-Host "Password: password" -ForegroundColor White
Write-Host "=================================" -ForegroundColor Cyan

# Show sample data
Write-Host "`nSample Data Available:" -ForegroundColor Cyan
docker exec github-tracker-postgres psql -U user -d github_tracker -c "SELECT id, commit_sha, message, author FROM track_project.commits LIMIT 3;"

Write-Host "`nNext Steps:" -ForegroundColor Green
Write-Host "1. Open pgAdmin4 Desktop Application" -ForegroundColor White
Write-Host "2. Right-click on 'Servers' -> 'Register' -> 'Server...'" -ForegroundColor White
Write-Host "3. Use the connection details above" -ForegroundColor White
Write-Host "4. Test connection and save" -ForegroundColor White
Write-Host "5. Browse to: Servers -> GitHub Tracker -> Databases -> github_tracker -> Schemas -> track_project -> Tables" -ForegroundColor White
Write-Host "6. Right-click on 'commits' table -> 'View/Edit Data' -> 'All Rows'" -ForegroundColor White

Write-Host "`nSee 'pgadmin-connection-guide.md' for detailed instructions" -ForegroundColor Yellow
