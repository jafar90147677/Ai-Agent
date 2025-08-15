# Connect pgAdmin4 to Docker Database
Write-Host "Connecting pgAdmin4 to Docker Database..." -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan

# Check Docker database status
Write-Host "`n1. Docker Database Status:" -ForegroundColor Yellow
Write-Host "=========================" -ForegroundColor Yellow
docker exec github-tracker-postgres psql -U user -d github_tracker_db -c "SELECT COUNT(*) as total_commits FROM track_project.commits;"

# Show sample data
Write-Host "`n2. Sample Data in Database:" -ForegroundColor Yellow
Write-Host "===========================" -ForegroundColor Yellow
docker exec github-tracker-postgres psql -U user -d github_tracker_db -c "SELECT id, commit_sha, message, author FROM track_project.commits ORDER BY created_at DESC LIMIT 3;"

# pgAdmin4 Connection Details
Write-Host "`n3. pgAdmin4 Connection Details:" -ForegroundColor Yellow
Write-Host "==============================" -ForegroundColor Yellow
Write-Host "Host name/address: localhost" -ForegroundColor White
Write-Host "Port: 5432" -ForegroundColor White
Write-Host "Maintenance database: github_tracker_db" -ForegroundColor White
Write-Host "Username: user" -ForegroundColor White
Write-Host "Password: password" -ForegroundColor White
Write-Host "Save password: ✅ (check this box)" -ForegroundColor White

# Step-by-step instructions
Write-Host "`n4. Step-by-Step Connection Guide:" -ForegroundColor Green
Write-Host "=================================" -ForegroundColor Green
Write-Host "1. Open pgAdmin4 Desktop Application" -ForegroundColor White
Write-Host "2. Right-click on 'Servers' → 'Register' → 'Server...'" -ForegroundColor White
Write-Host "3. General Tab:" -ForegroundColor White
Write-Host "   - Name: GitHub Tracker Docker" -ForegroundColor Gray
Write-Host "4. Connection Tab:" -ForegroundColor White
Write-Host "   - Host name/address: localhost" -ForegroundColor Gray
Write-Host "   - Port: 5432" -ForegroundColor Gray
Write-Host "   - Maintenance database: github_tracker_db" -ForegroundColor Gray
Write-Host "   - Username: user" -ForegroundColor Gray
Write-Host "   - Password: password" -ForegroundColor Gray
Write-Host "   - Save password: ✅ (check this box)" -ForegroundColor Gray
Write-Host "5. Click 'Test Connection' button" -ForegroundColor White
Write-Host "6. If successful, click 'Save'" -ForegroundColor White

# Navigation guide
Write-Host "`n5. How to View Data in pgAdmin4:" -ForegroundColor Green
Write-Host "=================================" -ForegroundColor Green
Write-Host "1. Expand: Servers → GitHub Tracker Docker → Databases → github_tracker_db" -ForegroundColor White
Write-Host "2. Expand: Schemas → track_project" -ForegroundColor White
Write-Host "3. Expand: Tables" -ForegroundColor White
Write-Host "4. Right-click on 'commits' table → 'View/Edit Data' → 'All Rows'" -ForegroundColor White
Write-Host "5. You'll see the same data as in your UI!" -ForegroundColor White

# Expected data
Write-Host "`n6. Expected Data in pgAdmin4:" -ForegroundColor Yellow
Write-Host "=============================" -ForegroundColor Yellow
Write-Host "✅ 10 commits from jafar90147677/Ai-Agent repository" -ForegroundColor Green
Write-Host "✅ Recent commits like 'Create readme45.md', 'Create readme2.md'" -ForegroundColor Green
Write-Host "✅ Same data as shown in your UI at http://localhost:3000" -ForegroundColor Green
Write-Host "✅ Real-time data that updates when you fetch new commits" -ForegroundColor Green

# Troubleshooting
Write-Host "`n7. Troubleshooting:" -ForegroundColor Yellow
Write-Host "==================" -ForegroundColor Yellow
Write-Host "If connection fails:" -ForegroundColor White
Write-Host "1. Make sure Docker containers are running: docker-compose ps" -ForegroundColor Gray
Write-Host "2. Check if port 5432 is not blocked by firewall" -ForegroundColor Gray
Write-Host "3. Try restarting Docker Desktop if needed" -ForegroundColor Gray
Write-Host "4. Verify the exact username is 'user' (not 'users' or 'postgres')" -ForegroundColor Gray

Write-Host "`n🎯 Key Points:" -ForegroundColor Green
Write-Host "=============" -ForegroundColor Green
Write-Host "• Username MUST be 'user' (singular)" -ForegroundColor Green
Write-Host "• Database MUST be 'github_tracker_db'" -ForegroundColor Green
Write-Host "• Host MUST be 'localhost'" -ForegroundColor Green
Write-Host "• Password is 'password'" -ForegroundColor Green

Write-Host "`n✅ Once connected, you'll see the same live GitHub data in pgAdmin4!" -ForegroundColor Green
