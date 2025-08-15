# Migrate Data from Docker to Local PostgreSQL 17
Write-Host "Migrating Data from Docker to Local PostgreSQL 17..." -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan

# Step 1: Export data from Docker
Write-Host "`n1. Exporting data from Docker PostgreSQL..." -ForegroundColor Yellow
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$exportFile = "github_tracker_export_$timestamp.sql"

try {
    docker exec github-tracker-postgres pg_dump -U user -d github_tracker_db > $exportFile
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Data exported successfully to: $exportFile" -ForegroundColor Green
    } else {
        Write-Host "❌ Export failed!" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "❌ Error exporting data: $_" -ForegroundColor Red
    exit 1
}

# Step 2: Instructions for importing to local PostgreSQL
Write-Host "`n2. Next Steps to Import to Local PostgreSQL 17:" -ForegroundColor Yellow
Write-Host "===============================================" -ForegroundColor Yellow

Write-Host "`nIn your pgAdmin4 PostgreSQL 17 server:" -ForegroundColor White
Write-Host "1. Create database 'github_tracker_db' if it doesn't exist" -ForegroundColor Gray
Write-Host "2. Right-click on 'github_tracker_db' → 'Query Tool'" -ForegroundColor Gray
Write-Host "3. Copy the contents of: $exportFile" -ForegroundColor Gray
Write-Host "4. Paste and execute the SQL" -ForegroundColor Gray
Write-Host "5. Your data will be imported!" -ForegroundColor Gray

# Step 3: Show the export file location
Write-Host "`n3. Export File Location:" -ForegroundColor Yellow
Write-Host "=======================" -ForegroundColor Yellow
$fullPath = (Get-Location).Path + "\" + $exportFile
Write-Host "File: $fullPath" -ForegroundColor White
Write-Host "Size: $((Get-Item $exportFile).Length) bytes" -ForegroundColor White

# Step 4: Show sample of exported data
Write-Host "`n4. Sample of Exported Data:" -ForegroundColor Yellow
Write-Host "===========================" -ForegroundColor Yellow
Get-Content $exportFile | Select-Object -First 20

Write-Host "`n✅ Migration file created successfully!" -ForegroundColor Green
Write-Host "Now import this file into your local PostgreSQL 17 database." -ForegroundColor Green
