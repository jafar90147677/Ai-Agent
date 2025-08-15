# Configure Local pgAdmin4 Database Connection
# This script helps configure the system to use your local pgAdmin4 database

Write-Host "Configuring Local pgAdmin4 Database Connection..." -ForegroundColor Green
Write-Host "=================================================" -ForegroundColor Green

# Step 1: Check current database connection
Write-Host "`n1. Current Database Configuration:" -ForegroundColor Cyan
Write-Host "Current DATABASE_URL: postgresql://user:password@postgres:5432/github_tracker" -ForegroundColor Yellow
Write-Host "Target DATABASE_URL: postgresql://user:password@localhost:5432/github_tracker_db" -ForegroundColor Green

# Step 2: Instructions for configuration
Write-Host "`n2. Configuration Steps:" -ForegroundColor Yellow
Write-Host "=======================" -ForegroundColor Yellow

Write-Host "`nStep A: Update Environment Variables" -ForegroundColor Cyan
Write-Host "1. Create a .env file in the root directory:" -ForegroundColor White
Write-Host "   Copy env.example to .env" -ForegroundColor Gray
Write-Host "2. Update the DATABASE_URL in .env:" -ForegroundColor White
Write-Host "   DATABASE_URL=postgresql://user:password@localhost:5432/github_tracker_db" -ForegroundColor Gray

Write-Host "`nStep B: Verify Local Database Connection" -ForegroundColor Cyan
Write-Host "1. Make sure your local PostgreSQL is running" -ForegroundColor White
Write-Host "2. Verify database 'github_tracker_db' exists" -ForegroundColor White
Write-Host "3. Verify schema 'track_project' exists" -ForegroundColor White
Write-Host "4. Verify tables exist:" -ForegroundColor White
Write-Host "   - ai_analysis" -ForegroundColor Gray
Write-Host "   - commit_files" -ForegroundColor Gray
Write-Host "   - commits" -ForegroundColor Gray
Write-Host "   - tracking_config" -ForegroundColor Gray

Write-Host "`nStep C: Test Local Connection" -ForegroundColor Cyan
Write-Host "1. Test connection to local database:" -ForegroundColor White
Write-Host "   psql -h localhost -U user -d github_tracker_db" -ForegroundColor Gray
Write-Host "2. Check if track_project schema exists:" -ForegroundColor White
Write-Host "   SELECT schema_name FROM information_schema.schemata WHERE schema_name = 'track_project';" -ForegroundColor Gray

# Step 3: Create .env file
Write-Host "`n3. Creating .env file..." -ForegroundColor Yellow
Write-Host "=========================" -ForegroundColor Yellow

$envContent = @"
# GitHub Configuration
GITHUB_TOKEN=your_github_token_here
GITHUB_REPO=jafar90147677/Ai-Agent

# Database Configuration - Local pgAdmin4 Database
DATABASE_URL=postgresql://user:password@localhost:5432/github_tracker_db

# Application Configuration
DEBUG=False
AI_CHECK_INTERVAL=300
AI_CONFIDENCE_THRESHOLD=0.7
"@

try {
    $envContent | Out-File -FilePath ".env" -Encoding UTF8
    Write-Host "✅ .env file created successfully" -ForegroundColor Green
} catch {
    Write-Host "❌ Error creating .env file: $($_.Exception.Message)" -ForegroundColor Red
}

# Step 4: Instructions for restarting services
Write-Host "`n4. Restart Services:" -ForegroundColor Yellow
Write-Host "====================" -ForegroundColor Yellow

Write-Host "`nAfter updating the configuration:" -ForegroundColor White
Write-Host "1. Stop Docker containers: docker-compose down" -ForegroundColor Gray
Write-Host "2. Start Docker containers: docker-compose up -d" -ForegroundColor Gray
Write-Host "3. Services will now connect to your local pgAdmin4 database" -ForegroundColor Gray

Write-Host "`n5. Verification Steps:" -ForegroundColor Yellow
Write-Host "=====================" -ForegroundColor Yellow

Write-Host "`nAfter restarting services:" -ForegroundColor White
Write-Host "1. Open pgAdmin4 and check github_tracker_db" -ForegroundColor Gray
Write-Host "2. Look in track_project schema" -ForegroundColor Gray
Write-Host "3. Check if data is being stored in the tables" -ForegroundColor Gray
Write-Host "4. Test the UI: http://localhost:3000" -ForegroundColor Gray
Write-Host "5. Click 'Track Now' and verify data appears in pgAdmin4" -ForegroundColor Gray

Write-Host "`n6. Expected Results:" -ForegroundColor Yellow
Write-Host "===================" -ForegroundColor Yellow

Write-Host "`n✅ In your local pgAdmin4:" -ForegroundColor White
Write-Host "   - Database: github_tracker_db" -ForegroundColor Gray
Write-Host "   - Schema: track_project" -ForegroundColor Gray
Write-Host "   - Tables: ai_analysis, commit_files, commits, tracking_config" -ForegroundColor Gray
Write-Host "   - Data: Real GitHub commits from your Ai-Agent repository" -ForegroundColor Gray

Write-Host "`n✅ In your UI:" -ForegroundColor White
Write-Host "   - Click 'Track Now' button" -ForegroundColor Gray
Write-Host "   - Data will be stored in your local pgAdmin4 database" -ForegroundColor Gray
Write-Host "   - You can see the data directly in pgAdmin4" -ForegroundColor Gray

Write-Host "`n🎉 Configuration Summary:" -ForegroundColor Green
Write-Host "=========================" -ForegroundColor Green
Write-Host "System will now store data in your local pgAdmin4 database!" -ForegroundColor White
Write-Host "Database: github_tracker_db" -ForegroundColor White
Write-Host "Schema: track_project" -ForegroundColor White
Write-Host "Tables: ai_analysis, commit_files, commits, tracking_config" -ForegroundColor White
