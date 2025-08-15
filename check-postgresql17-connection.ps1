# Check PostgreSQL17 Connection Script
Write-Host "Checking PostgreSQL17 Connection to Docker PostgreSQL..." -ForegroundColor Cyan

# Check if Docker PostgreSQL is running
Write-Host "`nChecking Docker PostgreSQL container..." -ForegroundColor Yellow
docker-compose ps | findstr postgres

# Show available databases
Write-Host "`nAvailable databases in Docker PostgreSQL:" -ForegroundColor Yellow
docker exec github-tracker-postgres psql -U user -d github_tracker -c "\l"

# Show connection details for PostgreSQL17
Write-Host "`nPostgreSQL17 Connection Details:" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan
Write-Host "Host name/address: localhost" -ForegroundColor White
Write-Host "Port: 5432" -ForegroundColor White
Write-Host "Username: user" -ForegroundColor White
Write-Host "Password: 9014" -ForegroundColor White
Write-Host "=================================" -ForegroundColor Cyan

# Show sample data
Write-Host "`nSample Data in github_tracker Database:" -ForegroundColor Cyan
docker exec github-tracker-postgres psql -U user -d github_tracker -c "SELECT id, commit_sha, message, author FROM track_project.commits;"

Write-Host "`nInstructions for PostgreSQL17:" -ForegroundColor Green
Write-Host "1. Open pgAdmin4 Desktop Application" -ForegroundColor White
Write-Host "2. Connect to your PostgreSQL17 server" -ForegroundColor White
Write-Host "3. Navigate to: PostgreSQL17 -> Databases -> github_tracker -> Schemas -> track_project -> Tables" -ForegroundColor White
Write-Host "4. Right-click on 'commits' table -> 'View/Edit Data' -> 'All Rows'" -ForegroundColor White

Write-Host "`nIf github_tracker database is not visible:" -ForegroundColor Yellow
Write-Host "- Right-click on PostgreSQL17 -> 'Refresh'" -ForegroundColor White
Write-Host "- Check PostgreSQL17 properties to ensure it connects to localhost:5432" -ForegroundColor White
Write-Host "- Verify username 'user' and password '9014' are used" -ForegroundColor White

Write-Host "`nSee 'connect-to-postgresql17.md' for detailed instructions" -ForegroundColor Yellow
