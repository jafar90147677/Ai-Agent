# Fix pgAdmin4 Connection Issues
Write-Host "Fixing pgAdmin4 Connection Issues..." -ForegroundColor Cyan
Write-Host "====================================" -ForegroundColor Cyan

# Test database connection
Write-Host "`n1. Testing Database Connection..." -ForegroundColor Yellow
try {
    $result = docker exec github-tracker-postgres psql -U user -d github_tracker_db -c "SELECT 'Connection successful' as status, current_user, current_database();"
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Database connection successful!" -ForegroundColor Green
        Write-Host $result -ForegroundColor White
    } else {
        Write-Host "❌ Database connection failed!" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Error: $_" -ForegroundColor Red
}

# Check Docker containers
Write-Host "`n2. Checking Docker Containers..." -ForegroundColor Yellow
docker-compose ps | findstr postgres

# Show correct connection details
Write-Host "`n3. CORRECT Connection Details for pgAdmin4:" -ForegroundColor Yellow
Write-Host "===========================================" -ForegroundColor Yellow
Write-Host "Host name/address: localhost" -ForegroundColor White
Write-Host "Port: 5432" -ForegroundColor White
Write-Host "Maintenance database: github_tracker_db" -ForegroundColor White
Write-Host "Username: user" -ForegroundColor Green
Write-Host "Password: password" -ForegroundColor White
Write-Host "Save password: ✅ (check this box)" -ForegroundColor White

# Common mistakes
Write-Host "`n4. Common Mistakes to Avoid:" -ForegroundColor Red
Write-Host "============================" -ForegroundColor Red
Write-Host "❌ Username: 'users' (WRONG - should be 'user')" -ForegroundColor Red
Write-Host "❌ Username: 'postgres' (WRONG - should be 'user')" -ForegroundColor Red
Write-Host "❌ Database: 'postgres' (WRONG - should be 'github_tracker_db')" -ForegroundColor Red
Write-Host "❌ Host: '127.0.0.1' (use 'localhost' instead)" -ForegroundColor Red

Write-Host "`n✅ Correct Settings:" -ForegroundColor Green
Write-Host "===================" -ForegroundColor Green
Write-Host "✅ Username: 'user' (singular)" -ForegroundColor Green
Write-Host "✅ Database: 'github_tracker_db'" -ForegroundColor Green
Write-Host "✅ Host: 'localhost'" -ForegroundColor Green

# Step-by-step fix
Write-Host "`n5. Step-by-Step Fix:" -ForegroundColor Yellow
Write-Host "====================" -ForegroundColor Yellow
Write-Host "1. Open pgAdmin4 Desktop Application" -ForegroundColor White
Write-Host "2. If you have an existing 'GitHub Tracker' server, DELETE it first" -ForegroundColor Red
Write-Host "3. Right-click on 'Servers' → 'Register' → 'Server...'" -ForegroundColor White
Write-Host "4. General Tab:" -ForegroundColor White
Write-Host "   - Name: GitHub Tracker" -ForegroundColor Gray
Write-Host "5. Connection Tab:" -ForegroundColor White
Write-Host "   - Host name/address: localhost" -ForegroundColor Gray
Write-Host "   - Port: 5432" -ForegroundColor Gray
Write-Host "   - Maintenance database: github_tracker_db" -ForegroundColor Gray
Write-Host "   - Username: user" -ForegroundColor Green
Write-Host "   - Password: password" -ForegroundColor Gray
Write-Host "   - Save password: ✅ (check this box)" -ForegroundColor Gray
Write-Host "6. Click 'Test Connection' button" -ForegroundColor White
Write-Host "7. If successful, click 'Save'" -ForegroundColor White

# Test connection from command line
Write-Host "`n6. Testing Connection from Command Line..." -ForegroundColor Yellow
Write-Host "This should work (copy this command to test):" -ForegroundColor White
Write-Host "docker exec github-tracker-postgres psql -U user -d github_tracker_db -c \"SELECT 'Hello from database!' as message;\"" -ForegroundColor Gray

# Show sample data
Write-Host "`n7. Sample Data Available:" -ForegroundColor Yellow
docker exec github-tracker-postgres psql -U user -d github_tracker_db -c "SELECT id, commit_sha, message, author FROM track_project.commits LIMIT 3;"

Write-Host "`n8. Troubleshooting Steps:" -ForegroundColor Yellow
Write-Host "========================" -ForegroundColor Yellow
Write-Host "If still having issues:" -ForegroundColor White
Write-Host "1. Make sure Docker Desktop is running" -ForegroundColor Gray
Write-Host "2. Restart Docker Desktop if needed" -ForegroundColor Gray
Write-Host "3. Check if port 5432 is not blocked by firewall" -ForegroundColor Gray
Write-Host "4. Try restarting the containers: docker-compose restart" -ForegroundColor Gray
Write-Host "5. Verify the exact username is 'user' (not 'users' or 'postgres')" -ForegroundColor Gray

Write-Host "`n🎯 Key Points:" -ForegroundColor Green
Write-Host "=============" -ForegroundColor Green
Write-Host "• Username MUST be 'user' (singular)" -ForegroundColor Green
Write-Host "• Database MUST be 'github_tracker_db'" -ForegroundColor Green
Write-Host "• Host MUST be 'localhost'" -ForegroundColor Green
Write-Host "• Password is 'password'" -ForegroundColor Green

Write-Host "`n✅ Try connecting again with these exact settings!" -ForegroundColor Green
