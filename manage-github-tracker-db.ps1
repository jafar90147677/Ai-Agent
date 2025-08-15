# GitHub Tracker Database Management Script
# This script provides commands to manage your github_tracker_db database

param(
    [Parameter(Mandatory=$false)]
    [string]$Action = "help"
)

Write-Host "GitHub Tracker Database Management" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan

switch ($Action.ToLower()) {
    "help" {
        Write-Host "`nAvailable Commands:" -ForegroundColor Yellow
        Write-Host "===================" -ForegroundColor Yellow
        Write-Host "1. status     - Show database status and record counts" -ForegroundColor White
        Write-Host "2. commits    - View all commits" -ForegroundColor White
        Write-Host "3. files      - View commit files" -ForegroundColor White
        Write-Host "4. analysis   - View AI analysis" -ForegroundColor White
        Write-Host "5. config     - View tracking configuration" -ForegroundColor White
        Write-Host "6. recent     - View recent commits (last 5)" -ForegroundColor White
        Write-Host "7. connect    - Connect to database interactively" -ForegroundColor White
        Write-Host "8. backup     - Create backup of current data" -ForegroundColor White
        Write-Host "9. clear      - Clear all data (WARNING: destructive)" -ForegroundColor Red
        Write-Host "10. pgadmin   - Show pgAdmin4 connection details" -ForegroundColor White
        
        Write-Host "`nUsage Examples:" -ForegroundColor Green
        Write-Host "===============" -ForegroundColor Green
        Write-Host ".\manage-github-tracker-db.ps1 -Action status" -ForegroundColor Gray
        Write-Host ".\manage-github-tracker-db.ps1 -Action commits" -ForegroundColor Gray
        Write-Host ".\manage-github-tracker-db.ps1 -Action recent" -ForegroundColor Gray
    }
    
    "status" {
        Write-Host "`nDatabase Status:" -ForegroundColor Yellow
        Write-Host "================" -ForegroundColor Yellow
        docker exec github-tracker-postgres psql -U user -d github_tracker_db -c "SELECT 'commits' as table_name, COUNT(*) as count FROM track_project.commits UNION ALL SELECT 'commit_files', COUNT(*) FROM track_project.commit_files UNION ALL SELECT 'ai_analysis', COUNT(*) FROM track_project.ai_analysis UNION ALL SELECT 'tracking_config', COUNT(*) FROM track_project.tracking_config;"
    }
    
    "commits" {
        Write-Host "`nAll Commits:" -ForegroundColor Yellow
        Write-Host "============" -ForegroundColor Yellow
        docker exec github-tracker-postgres psql -U user -d github_tracker_db -c "SELECT id, commit_sha, message, author, created_at FROM track_project.commits ORDER BY created_at DESC;"
    }
    
    "files" {
        Write-Host "`nCommit Files:" -ForegroundColor Yellow
        Write-Host "=============" -ForegroundColor Yellow
        docker exec github-tracker-postgres psql -U user -d github_tracker_db -c "SELECT cf.id, cf.file_path, cf.change_type, cf.additions, cf.deletions, c.commit_sha FROM track_project.commit_files cf JOIN track_project.commits c ON cf.commit_id = c.id ORDER BY cf.id DESC;"
    }
    
    "analysis" {
        Write-Host "`nAI Analysis:" -ForegroundColor Yellow
        Write-Host "============" -ForegroundColor Yellow
        docker exec github-tracker-postgres psql -U user -d github_tracker_db -c "SELECT aa.id, aa.analysis_type, aa.confidence_score, c.commit_sha FROM track_project.ai_analysis aa JOIN track_project.commits c ON aa.commit_id = c.id ORDER BY aa.id DESC;"
    }
    
    "config" {
        Write-Host "`nTracking Configuration:" -ForegroundColor Yellow
        Write-Host "======================" -ForegroundColor Yellow
        docker exec github-tracker-postgres psql -U user -d github_tracker_db -c "SELECT * FROM track_project.tracking_config;"
    }
    
    "recent" {
        Write-Host "`nRecent Commits (Last 5):" -ForegroundColor Yellow
        Write-Host "=========================" -ForegroundColor Yellow
        docker exec github-tracker-postgres psql -U user -d github_tracker_db -c "SELECT id, commit_sha, message, author, created_at FROM track_project.commits ORDER BY created_at DESC LIMIT 5;"
    }
    
    "connect" {
        Write-Host "`nConnecting to database interactively..." -ForegroundColor Yellow
        Write-Host "Use \q to exit" -ForegroundColor Gray
        docker exec -it github-tracker-postgres psql -U user -d github_tracker_db
    }
    
    "backup" {
        Write-Host "`nCreating backup..." -ForegroundColor Yellow
        $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
        $backupFile = "github_tracker_db_backup_$timestamp.sql"
        docker exec github-tracker-postgres pg_dump -U user -d github_tracker_db > $backupFile
        Write-Host "Backup created: $backupFile" -ForegroundColor Green
    }
    
    "clear" {
        Write-Host "`nWARNING: This will delete ALL data!" -ForegroundColor Red
        $confirm = Read-Host "Type 'YES' to confirm deletion"
        if ($confirm -eq "YES") {
            Write-Host "Clearing all data..." -ForegroundColor Yellow
            docker exec github-tracker-postgres psql -U user -d github_tracker_db -c "TRUNCATE track_project.commits, track_project.commit_files, track_project.ai_analysis CASCADE;"
            Write-Host "Data cleared successfully!" -ForegroundColor Green
        } else {
            Write-Host "Operation cancelled." -ForegroundColor Yellow
        }
    }
    
    "pgadmin" {
        Write-Host "`nLocal pgAdmin4 Desktop App Connection Details:" -ForegroundColor Yellow
        Write-Host "=============================================" -ForegroundColor Yellow
        Write-Host "Host name/address: localhost" -ForegroundColor White
        Write-Host "Port: 5432" -ForegroundColor White
        Write-Host "Maintenance database: github_tracker_db" -ForegroundColor White
        Write-Host "Username: user" -ForegroundColor White
        Write-Host "Password: password" -ForegroundColor White
        Write-Host "Save password: ✅ (check this box)" -ForegroundColor White
        Write-Host "`nSteps to connect:" -ForegroundColor Cyan
        Write-Host "1. Open pgAdmin4 Desktop Application" -ForegroundColor Gray
        Write-Host "2. Right-click on 'Servers' → 'Register' → 'Server...'" -ForegroundColor Gray
        Write-Host "3. General Tab: Name = 'GitHub Tracker'" -ForegroundColor Gray
        Write-Host "4. Connection Tab: Use details above" -ForegroundColor Gray
        Write-Host "5. Test connection and save" -ForegroundColor Gray
        Write-Host "6. Browse: Servers → GitHub Tracker → Databases → github_tracker_db → Schemas → track_project → Tables" -ForegroundColor Gray
    }
    
    default {
        Write-Host "Unknown action: $Action" -ForegroundColor Red
        Write-Host "Use -Action help to see available commands" -ForegroundColor Yellow
    }
}

Write-Host "`nScript completed!" -ForegroundColor Green
