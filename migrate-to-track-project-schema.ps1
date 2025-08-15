# Migrate to Track Project Schema
# This script migrates existing data from public schema to track_project schema

Write-Host "Migrating to Track Project Schema..." -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Green

# Step 1: Check current state
Write-Host "`n1. Checking current database state..." -ForegroundColor Cyan
docker exec github-tracker-postgres psql -U user -d github_tracker -c "
SELECT 
    'Current schemas:' as info,
    schema_name 
FROM information_schema.schemata 
WHERE schema_name IN ('public', 'track_project')
ORDER BY schema_name;
"

# Step 2: Check tables in public schema
Write-Host "`n2. Checking tables in public schema..." -ForegroundColor Cyan
docker exec github-tracker-postgres psql -U user -d github_tracker -c "
SELECT 
    table_name,
    'Table exists in public' as status
FROM information_schema.tables 
WHERE table_schema = 'public' 
ORDER BY table_name;
"

# Step 3: Check data count in public schema
Write-Host "`n3. Checking data count in public schema..." -ForegroundColor Cyan
docker exec github-tracker-postgres psql -U user -d github_tracker -c "
SELECT 
    'commits' as table_name,
    COUNT(*) as record_count
FROM public.commits
UNION ALL
SELECT 
    'commit_files' as table_name,
    COUNT(*) as record_count
FROM public.commit_files
UNION ALL
SELECT 
    'ai_analysis' as table_name,
    COUNT(*) as record_count
FROM public.ai_analysis
UNION ALL
SELECT 
    'tracking_config' as table_name,
    COUNT(*) as record_count
FROM public.tracking_config;
"

# Step 4: Create track_project schema
Write-Host "`n4. Creating track_project schema..." -ForegroundColor Cyan
docker exec github-tracker-postgres psql -U user -d github_tracker -c "
CREATE SCHEMA IF NOT EXISTS track_project;
"

# Step 5: Create tables in track_project schema
Write-Host "`n5. Creating tables in track_project schema..." -ForegroundColor Cyan
docker exec github-tracker-postgres psql -U user -d github_tracker -c "
-- Create commits table in track_project schema
CREATE TABLE track_project.commits (
    id SERIAL PRIMARY KEY,
    hash_key VARCHAR(255) UNIQUE NOT NULL,
    commit_sha VARCHAR(255) NOT NULL,
    message TEXT,
    author VARCHAR(255),
    author_email VARCHAR(255),
    repository VARCHAR(255),
    branch VARCHAR(255),
    created_at TIMESTAMP DEFAULT NOW(),
    committed_at TIMESTAMP,
    ai_processed BOOLEAN DEFAULT FALSE,
    ai_analysis JSON,
    event_status VARCHAR(50) DEFAULT 'pending'
);

-- Create commit_files table in track_project schema
CREATE TABLE track_project.commit_files (
    id SERIAL PRIMARY KEY,
    commit_id INTEGER REFERENCES track_project.commits(id) ON DELETE CASCADE,
    file_path VARCHAR(500) NOT NULL,
    file_name VARCHAR(255),
    file_extension VARCHAR(50),
    change_type VARCHAR(20),
    additions INTEGER DEFAULT 0,
    deletions INTEGER DEFAULT 0,
    changes INTEGER DEFAULT 0,
    patch TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Create ai_analysis table in track_project schema
CREATE TABLE track_project.ai_analysis (
    id SERIAL PRIMARY KEY,
    commit_id INTEGER REFERENCES track_project.commits(id) ON DELETE CASCADE,
    analysis_type VARCHAR(50),
    results JSON,
    confidence_score DECIMAL(3,2),
    created_at TIMESTAMP DEFAULT NOW()
);

-- Create tracking_config table in track_project schema
CREATE TABLE track_project.tracking_config (
    id SERIAL PRIMARY KEY,
    repository VARCHAR(255) NOT NULL,
    enabled BOOLEAN DEFAULT TRUE,
    last_checked TIMESTAMP,
    check_interval INTEGER DEFAULT 300,
    created_at TIMESTAMP DEFAULT NOW()
);
"

# Step 6: Create indexes in track_project schema
Write-Host "`n6. Creating indexes in track_project schema..." -ForegroundColor Cyan
docker exec github-tracker-postgres psql -U user -d github_tracker -c "
CREATE INDEX idx_commits_hash_key ON track_project.commits(hash_key);
CREATE INDEX idx_commits_commit_sha ON track_project.commits(commit_sha);
CREATE INDEX idx_commits_created_at ON track_project.commits(created_at);
CREATE INDEX idx_commits_repository ON track_project.commits(repository);
CREATE INDEX idx_commit_files_commit_id ON track_project.commit_files(commit_id);
CREATE INDEX idx_ai_analysis_commit_id ON track_project.ai_analysis(commit_id);
"

# Step 7: Migrate data from public to track_project schema
Write-Host "`n7. Migrating data from public to track_project schema..." -ForegroundColor Cyan

# Migrate commits
Write-Host "Migrating commits..." -ForegroundColor White
docker exec github-tracker-postgres psql -U user -d github_tracker -c "
INSERT INTO track_project.commits (
    id, hash_key, commit_sha, message, author, author_email,
    repository, branch, created_at, committed_at, ai_processed, ai_analysis, event_status
)
SELECT 
    id, hash_key, commit_sha, message, author, author_email,
    repository, branch, created_at, committed_at, ai_processed, ai_analysis, event_status
FROM public.commits
ON CONFLICT (id) DO NOTHING;
"

# Migrate commit_files
Write-Host "Migrating commit_files..." -ForegroundColor White
docker exec github-tracker-postgres psql -U user -d github_tracker -c "
INSERT INTO track_project.commit_files (
    id, commit_id, file_path, file_name, file_extension,
    change_type, additions, deletions, changes, patch, created_at
)
SELECT 
    cf.id, cf.commit_id, cf.file_path, cf.file_name, cf.file_extension,
    cf.change_type, cf.additions, cf.deletions, cf.changes, cf.patch, cf.created_at
FROM public.commit_files cf
JOIN track_project.commits c ON cf.commit_id = c.id
ON CONFLICT (id) DO NOTHING;
"

# Migrate ai_analysis
Write-Host "Migrating ai_analysis..." -ForegroundColor White
docker exec github-tracker-postgres psql -U user -d github_tracker -c "
INSERT INTO track_project.ai_analysis (
    id, commit_id, analysis_type, results, confidence_score, created_at
)
SELECT 
    aa.id, aa.commit_id, aa.analysis_type, aa.results, aa.confidence_score, aa.created_at
FROM public.ai_analysis aa
JOIN track_project.commits c ON aa.commit_id = c.id
ON CONFLICT (id) DO NOTHING;
"

# Migrate tracking_config
Write-Host "Migrating tracking_config..." -ForegroundColor White
docker exec github-tracker-postgres psql -U user -d github_tracker -c "
INSERT INTO track_project.tracking_config (
    id, repository, enabled, last_checked, check_interval, created_at
)
SELECT 
    id, repository, enabled, last_checked, check_interval, created_at
FROM public.tracking_config
ON CONFLICT (id) DO NOTHING;
"

# Step 8: Verify migration
Write-Host "`n8. Verifying migration..." -ForegroundColor Cyan
docker exec github-tracker-postgres psql -U user -d github_tracker -c "
SELECT 
    'track_project.commits' as table_name,
    COUNT(*) as record_count
FROM track_project.commits
UNION ALL
SELECT 
    'track_project.commit_files' as table_name,
    COUNT(*) as record_count
FROM track_project.commit_files
UNION ALL
SELECT 
    'track_project.ai_analysis' as table_name,
    COUNT(*) as record_count
FROM track_project.ai_analysis
UNION ALL
SELECT 
    'track_project.tracking_config' as table_name,
    COUNT(*) as record_count
FROM track_project.tracking_config;
"

# Step 9: Show sample data
Write-Host "`n9. Sample data from track_project.commits..." -ForegroundColor Cyan
docker exec github-tracker-postgres psql -U user -d github_tracker -c "
SELECT 
    id, 
    commit_sha, 
    LEFT(message, 50) as message_preview,
    author, 
    created_at 
FROM track_project.commits 
ORDER BY created_at DESC 
LIMIT 3;
"

Write-Host "`n✅ Migration completed successfully!" -ForegroundColor Green
Write-Host "`nNow you can view the data in pgAdmin4:" -ForegroundColor Yellow
Write-Host "1. Open http://localhost:5050" -ForegroundColor White
Write-Host "2. Login: admin@example.com / admin" -ForegroundColor White
Write-Host "3. Navigate to: Servers -> [Your Server] -> Databases -> github_tracker" -ForegroundColor White
Write-Host "4. Expand 'Schemas' -> 'track_project' -> 'Tables'" -ForegroundColor White
Write-Host "5. Right-click on 'commits' table -> 'View/Edit Data'" -ForegroundColor White

Write-Host "`nTo verify data exists:" -ForegroundColor Cyan
Write-Host "docker exec github-tracker-postgres psql -U user -d github_tracker -c \"SELECT COUNT(*) FROM track_project.commits;\"" -ForegroundColor Gray
