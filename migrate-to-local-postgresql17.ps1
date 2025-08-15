# Migrate Data to Local PostgreSQL 17
Write-Host "Migrating Data to Local PostgreSQL 17..." -ForegroundColor Cyan
Write-Host "=======================================" -ForegroundColor Cyan

# Check Docker data
Write-Host "`n1. Docker Database Data:" -ForegroundColor Yellow
Write-Host "=========================" -ForegroundColor Yellow
docker exec github-tracker-postgres psql -U user -d github_tracker_db -c "SELECT COUNT(*) as total_commits FROM track_project.commits;"

# Export data from Docker
Write-Host "`n2. Exporting Data from Docker..." -ForegroundColor Yellow
Write-Host "=================================" -ForegroundColor Yellow
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$exportFile = "github_tracker_export_$timestamp.sql"

try {
    docker exec github-tracker-postgres pg_dump -U user -d github_tracker_db > $exportFile
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Data exported successfully to: $exportFile" -ForegroundColor Green
        Write-Host "File size: $((Get-Item $exportFile).Length) bytes" -ForegroundColor White
    } else {
        Write-Host "❌ Export failed!" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "❌ Error exporting data: $_" -ForegroundColor Red
    exit 1
}

# Show local PostgreSQL connection details
Write-Host "`n3. Local PostgreSQL 17 Connection Details:" -ForegroundColor Yellow
Write-Host "===========================================" -ForegroundColor Yellow
Write-Host "Host name: localhost" -ForegroundColor White
Write-Host "Port: 5433" -ForegroundColor White
Write-Host "Maintenance database: postgres" -ForegroundColor White
Write-Host "Username: postgres" -ForegroundColor White
Write-Host "Password: root" -ForegroundColor White

# Instructions for importing
Write-Host "`n4. Steps to Import to Local PostgreSQL 17:" -ForegroundColor Yellow
Write-Host "===========================================" -ForegroundColor Yellow
Write-Host "1. Open pgAdmin4 Desktop Application" -ForegroundColor White
Write-Host "2. Connect to your local PostgreSQL 17 server" -ForegroundColor White
Write-Host "3. Create a new database called 'github_tracker_db'" -ForegroundColor White
Write-Host "4. Right-click on 'github_tracker_db' → 'Query Tool'" -ForegroundColor White
Write-Host "5. Copy the contents of: $exportFile" -ForegroundColor White
Write-Host "6. Paste and execute the SQL" -ForegroundColor White
Write-Host "7. Your data will be imported!" -ForegroundColor White

# Show the export file location
Write-Host "`n5. Export File Location:" -ForegroundColor Yellow
Write-Host "=======================" -ForegroundColor Yellow
$fullPath = (Get-Location).Path + "\" + $exportFile
Write-Host "File: $fullPath" -ForegroundColor White

# Show sample of exported data
Write-Host "`n6. Sample of Exported Data:" -ForegroundColor Yellow
Write-Host "===========================" -ForegroundColor Yellow
Get-Content $exportFile | Select-Object -First 20

# Alternative: Direct import using psql
Write-Host "`n7. Alternative: Direct Import using psql:" -ForegroundColor Yellow
Write-Host "=========================================" -ForegroundColor Yellow
Write-Host "If you have psql in your PATH, you can run:" -ForegroundColor White
Write-Host "psql -h localhost -p 5433 -U postgres -d postgres -c \"CREATE DATABASE github_tracker_db;\"" -ForegroundColor Gray
Write-Host "psql -h localhost -p 5433 -U postgres -d github_tracker_db -f $exportFile" -ForegroundColor Gray

Write-Host "`n✅ Migration file created successfully!" -ForegroundColor Green
Write-Host "Now import this file into your local PostgreSQL 17 database." -ForegroundColor Green
Write-Host "After import, you can connect pgAdmin4 to your local database to see the data." -ForegroundColor Green
