# Simple Setup for Local PostgreSQL 17 Live Data Storage

Write-Host "Setting up Local PostgreSQL 17 for Live Data Storage" -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Green

# Step 1: Update .env file to use local PostgreSQL 17
Write-Host "`nStep 1: Updating .env file to use local PostgreSQL 17..." -ForegroundColor Yellow

$envContent = @"
# GitHub Configuration
GITHUB_TOKEN=your_github_personal_access_token_here
GITHUB_REPO=jafar90147677/Ai-Agent

# Database Configuration - Local PostgreSQL 17
DATABASE_URL=postgresql://postgres:root@localhost:5433/tracker_project_db

# Service Ports
DATABASE_SERVICE_PORT=8001
API_GATEWAY_PORT=8000
REACT_FRONTEND_PORT=3000
"@

$envContent | Out-File -FilePath .env -Encoding UTF8
Write-Host "OK - .env file updated to use local PostgreSQL 17" -ForegroundColor Green

# Step 2: Ensure python-dotenv is in requirements.txt
Write-Host "`nStep 2: Ensuring python-dotenv dependency..." -ForegroundColor Yellow

if (Test-Path "database-service/requirements.txt") {
    $requirements = Get-Content "database-service/requirements.txt"
    if ($requirements -notcontains "python-dotenv") {
        Add-Content "database-service/requirements.txt" "python-dotenv"
        Write-Host "OK - Added python-dotenv to requirements.txt" -ForegroundColor Green
    } else {
        Write-Host "OK - python-dotenv already in requirements.txt" -ForegroundColor Green
    }
} else {
    @"
fastapi
uvicorn
asyncpg
python-dotenv
"@ | Out-File -FilePath "database-service/requirements.txt" -Encoding UTF8
    Write-Host "OK - Created requirements.txt with python-dotenv" -ForegroundColor Green
}

# Step 3: Create SQL file for manual schema creation
Write-Host "`nStep 3: Creating SQL schema file..." -ForegroundColor Yellow

$schemaSQL = @"
-- Create track_project schema
CREATE SCHEMA IF NOT EXISTS track_project;

-- Create commits table
CREATE TABLE IF NOT EXISTS track_project.commits (
    id SERIAL PRIMARY KEY,
    hash_key VARCHAR(255) UNIQUE NOT NULL,
    commit_sha VARCHAR(255) NOT NULL,
    message TEXT,
    author VARCHAR(255),
    repository VARCHAR(255),
    committed_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create commit_files table
CREATE TABLE IF NOT EXISTS track_project.commit_files (
    id SERIAL PRIMARY KEY,
    commit_id INTEGER REFERENCES track_project.commits(id) ON DELETE CASCADE,
    filename VARCHAR(500),
    status VARCHAR(50),
    additions INTEGER,
    deletions INTEGER,
    changes INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create ai_analysis table
CREATE TABLE IF NOT EXISTS track_project.ai_analysis (
    id SERIAL PRIMARY KEY,
    commit_id INTEGER REFERENCES track_project.commits(id) ON DELETE CASCADE,
    analysis_type VARCHAR(100),
    analysis_data JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create tracking_config table
CREATE TABLE IF NOT EXISTS track_project.tracking_config (
    id SERIAL PRIMARY KEY,
    repository VARCHAR(255) UNIQUE,
    last_commit_sha VARCHAR(255),
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
"@

$schemaSQL | Out-File -FilePath "create-local-schema.sql" -Encoding UTF8
Write-Host "OK - Created create-local-schema.sql file" -ForegroundColor Green

Write-Host "`nSetup Complete!" -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Green
Write-Host "OK - Local PostgreSQL 17 configuration ready" -ForegroundColor Green
Write-Host "OK - Database service updated to use local PostgreSQL 17" -ForegroundColor Green
Write-Host "OK - Schema SQL file created" -ForegroundColor Green
Write-Host "`nNext Steps:" -ForegroundColor Yellow
Write-Host "1. Add your GitHub token to .env file" -ForegroundColor White
Write-Host "2. In pgAdmin4, connect to localhost:5433 and run create-local-schema.sql" -ForegroundColor White
Write-Host "3. Start the services: docker-compose up -d" -ForegroundColor White
Write-Host "4. Click 'Track Now' in the UI to fetch live data" -ForegroundColor White
Write-Host "5. Data will be stored in your local PostgreSQL 17" -ForegroundColor White
Write-Host "6. View data in pgAdmin4 connected to localhost:5433" -ForegroundColor White
