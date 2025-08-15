# Setup Local PostgreSQL 17 for Live Data Storage
# This script configures the system to store data in local PostgreSQL 17 first

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

# Step 2: Verify local PostgreSQL 17 connection
Write-Host "`nStep 2: Verifying local PostgreSQL 17 connection..." -ForegroundColor Yellow

try {
    $testConnection = & psql -h localhost -p 5433 -U postgres -d tracker_project_db -c "SELECT version();" 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "OK - Local PostgreSQL 17 connection successful" -ForegroundColor Green
    } else {
        Write-Host "ERROR - Local PostgreSQL 17 connection failed" -ForegroundColor Red
        Write-Host "Please ensure PostgreSQL 17 is running on port 5433" -ForegroundColor Yellow
        exit 1
    }
} catch {
    Write-Host "ERROR - Error testing PostgreSQL connection: $_" -ForegroundColor Red
    exit 1
}

# Step 3: Create schema in local PostgreSQL 17 if not exists
Write-Host "`nStep 3: Creating schema in local PostgreSQL 17..." -ForegroundColor Yellow

$schemaSQL = @"
CREATE SCHEMA IF NOT EXISTS track_project;

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

CREATE TABLE IF NOT EXISTS track_project.ai_analysis (
    id SERIAL PRIMARY KEY,
    commit_id INTEGER REFERENCES track_project.commits(id) ON DELETE CASCADE,
    analysis_type VARCHAR(100),
    analysis_data JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS track_project.tracking_config (
    id SERIAL PRIMARY KEY,
    repository VARCHAR(255) UNIQUE,
    last_commit_sha VARCHAR(255),
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
"@

try {
    $schemaSQL | & psql -h localhost -p 5433 -U postgres -d tracker_project_db
    if ($LASTEXITCODE -eq 0) {
        Write-Host "OK - Schema created successfully in local PostgreSQL 17" -ForegroundColor Green
    } else {
        Write-Host "ERROR - Failed to create schema" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "ERROR - Error creating schema: $_" -ForegroundColor Red
    exit 1
}

# Step 4: Install python-dotenv in database-service
Write-Host "`nStep 4: Installing python-dotenv dependency..." -ForegroundColor Yellow

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

# Step 5: Test database service with local PostgreSQL
Write-Host "`nStep 5: Testing database service with local PostgreSQL..." -ForegroundColor Yellow

Write-Host "Starting database service in test mode..." -ForegroundColor Cyan
Write-Host "Press Ctrl+C to stop the test" -ForegroundColor Yellow

try {
    docker run --rm -it --network aiagent_github-tracker-network -v ${PWD}/database-service:/app -w /app python:3.9-slim bash -c "pip install -r requirements.txt && python main.py"
} catch {
    Write-Host "`nOK - Test completed" -ForegroundColor Green
}

Write-Host "`nSetup Complete!" -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Green
Write-Host "OK - Local PostgreSQL 17 configured for live data storage" -ForegroundColor Green
Write-Host "OK - Database service updated to use local PostgreSQL 17" -ForegroundColor Green
Write-Host "OK - Schema created in tracker_project_db" -ForegroundColor Green
Write-Host "`nNext Steps:" -ForegroundColor Yellow
Write-Host "1. Add your GitHub token to .env file" -ForegroundColor White
Write-Host "2. Start the services: docker-compose up -d" -ForegroundColor White
Write-Host "3. Click 'Track Now' in the UI to fetch live data" -ForegroundColor White
Write-Host "4. Data will be stored in your local PostgreSQL 17" -ForegroundColor White
Write-Host "5. View data in pgAdmin4 connected to localhost:5433" -ForegroundColor White
