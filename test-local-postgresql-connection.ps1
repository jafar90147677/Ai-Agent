# Test Local PostgreSQL 17 Connection and Schema

Write-Host "Testing Local PostgreSQL 17 Connection..." -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green

# Test connection to local PostgreSQL 17
Write-Host "`nStep 1: Testing connection to local PostgreSQL 17..." -ForegroundColor Yellow

try {
    # Try to connect using psql if available
    $testResult = & psql -h localhost -p 5433 -U postgres -d tracker_project_db -c "SELECT version();" 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "OK - Connection successful!" -ForegroundColor Green
        Write-Host "PostgreSQL version: $testResult" -ForegroundColor Cyan
    } else {
        Write-Host "WARNING - psql command not available or connection failed" -ForegroundColor Yellow
        Write-Host "This is OK - we'll use pgAdmin4 instead" -ForegroundColor Yellow
    }
} catch {
    Write-Host "WARNING - psql command not available" -ForegroundColor Yellow
    Write-Host "This is OK - we'll use pgAdmin4 instead" -ForegroundColor Yellow
}

# Check if schema exists
Write-Host "`nStep 2: Checking if track_project schema exists..." -ForegroundColor Yellow

try {
    $schemaCheck = & psql -h localhost -p 5433 -U postgres -d tracker_project_db -c "SELECT schema_name FROM information_schema.schemata WHERE schema_name = 'track_project';" 2>$null
    if ($LASTEXITCODE -eq 0 -and $schemaCheck -match "track_project") {
        Write-Host "OK - track_project schema exists!" -ForegroundColor Green
    } else {
        Write-Host "WARNING - track_project schema not found" -ForegroundColor Yellow
        Write-Host "You need to create the schema manually in pgAdmin4" -ForegroundColor Yellow
    }
} catch {
    Write-Host "WARNING - Could not check schema (psql not available)" -ForegroundColor Yellow
}

Write-Host "`nStep 3: Manual Setup Instructions" -ForegroundColor Yellow
Write-Host "=================================" -ForegroundColor Yellow
Write-Host "1. Open pgAdmin4" -ForegroundColor White
Write-Host "2. Connect to localhost:5433" -ForegroundColor White
Write-Host "3. Open tracker_project_db database" -ForegroundColor White
Write-Host "4. Open Query Tool" -ForegroundColor White
Write-Host "5. Copy and paste the contents of create-local-schema.sql" -ForegroundColor White
Write-Host "6. Execute the query" -ForegroundColor White
Write-Host "7. This will create the track_project schema and tables" -ForegroundColor White

Write-Host "`nStep 4: PostgreSQL Configuration (if needed)" -ForegroundColor Yellow
Write-Host "=============================================" -ForegroundColor Yellow
Write-Host "If you get authentication errors, you may need to:" -ForegroundColor White
Write-Host "1. Open pgAdmin4" -ForegroundColor White
Write-Host "2. Right-click on PostgreSQL 17 server" -ForegroundColor White
Write-Host "3. Select 'Properties' > 'Connection'" -ForegroundColor White
Write-Host "4. Ensure 'Host name' is set to 'localhost' or '127.0.0.1'" -ForegroundColor White
Write-Host "5. Ensure 'Port' is set to '5433'" -ForegroundColor White
Write-Host "6. Ensure 'Username' is 'postgres' and password is 'root'" -ForegroundColor White

Write-Host "`nStep 5: After Schema Creation" -ForegroundColor Yellow
Write-Host "=============================" -ForegroundColor Yellow
Write-Host "1. Start the services: docker-compose up -d" -ForegroundColor White
Write-Host "2. Go to http://localhost:3000" -ForegroundColor White
Write-Host "3. Click 'Track Now' to fetch live data" -ForegroundColor White
Write-Host "4. Data will be stored in your local PostgreSQL 17" -ForegroundColor White
Write-Host "5. View data in pgAdmin4" -ForegroundColor White
