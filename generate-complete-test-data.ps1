# Generate Complete Test Data
# This script generates complete test data with commit files and AI analysis

Write-Host "Generating Complete Test Data..." -ForegroundColor Green
Write-Host "=================================" -ForegroundColor Green

# Step 1: Check current state
Write-Host "`n1. Checking current data state..." -ForegroundColor Cyan
docker exec github-tracker-postgres psql -U user -d github_tracker -c "
SELECT 
    'commits' as table_name,
    COUNT(*) as record_count
FROM track_project.commits
UNION ALL
SELECT 
    'commit_files' as table_name,
    COUNT(*) as record_count
FROM track_project.commit_files
UNION ALL
SELECT 
    'ai_analysis' as table_name,
    COUNT(*) as record_count
FROM track_project.ai_analysis;
"

# Step 2: Generate sample commit files for existing commits
Write-Host "`n2. Generating sample commit files..." -ForegroundColor Cyan
docker exec github-tracker-postgres psql -U user -d github_tracker -c "
INSERT INTO track_project.commit_files (
    commit_id, file_path, file_name, file_extension,
    change_type, additions, deletions, changes, patch
)
SELECT 
    c.id,
    'src/main.py' as file_path,
    'main.py' as file_name,
    'py' as file_extension,
    'modified' as change_type,
    15 as additions,
    5 as deletions,
    20 as changes,
    '@@ -1,5 +1,15 @@\n+ # Updated main.py\n+ def main():\n+     print(\"Hello World\")\n+     return True\n' as patch
FROM track_project.commits c
WHERE c.id IN (SELECT id FROM track_project.commits ORDER BY created_at DESC LIMIT 3)
ON CONFLICT DO NOTHING;
"

# Step 3: Generate sample AI analysis for existing commits
Write-Host "`n3. Generating sample AI analysis..." -ForegroundColor Cyan
docker exec github-tracker-postgres psql -U user -d github_tracker -c "
INSERT INTO track_project.ai_analysis (
    commit_id, analysis_type, results, confidence_score
)
SELECT 
    c.id,
    'commit_classification' as analysis_type,
    '{\"category\": \"feature\", \"confidence\": 0.85, \"tags\": [\"enhancement\", \"new-feature\"]}'::json as results,
    0.85 as confidence_score
FROM track_project.commits c
WHERE c.id IN (SELECT id FROM track_project.commits ORDER BY created_at DESC LIMIT 3)
ON CONFLICT DO NOTHING;
"

# Step 4: Add more commit files for variety
Write-Host "`n4. Adding more variety to commit files..." -ForegroundColor Cyan
docker exec github-tracker-postgres psql -U user -d github_tracker -c "
INSERT INTO track_project.commit_files (
    commit_id, file_path, file_name, file_extension,
    change_type, additions, deletions, changes, patch
)
SELECT 
    c.id,
    'README.md' as file_path,
    'README.md' as file_name,
    'md' as file_extension,
    'added' as change_type,
    25 as additions,
    0 as deletions,
    25 as changes,
    '@@ -0,0 +1,25 @@\n+ # Project Title\n+ \n+ This is a sample README file.\n+ \n+ ## Features\n+ - Feature 1\n+ - Feature 2\n+ \n+ ## Installation\n+ \n+ ```bash\n+ npm install\n+ ```\n' as patch
FROM track_project.commits c
WHERE c.id IN (SELECT id FROM track_project.commits ORDER BY created_at DESC LIMIT 2)
ON CONFLICT DO NOTHING;
"

# Step 5: Add different types of AI analysis
Write-Host "`n5. Adding different types of AI analysis..." -ForegroundColor Cyan
docker exec github-tracker-postgres psql -U user -d github_tracker -c "
INSERT INTO track_project.ai_analysis (
    commit_id, analysis_type, results, confidence_score
)
SELECT 
    c.id,
    'bug_detection' as analysis_type,
    '{\"bugs_found\": 0, \"potential_issues\": 1, \"severity\": \"low\"}'::json as results,
    0.72 as confidence_score
FROM track_project.commits c
WHERE c.id IN (SELECT id FROM track_project.commits ORDER BY created_at DESC LIMIT 2)
ON CONFLICT DO NOTHING;
"

# Step 6: Verify the generated data
Write-Host "`n6. Verifying generated data..." -ForegroundColor Cyan
docker exec github-tracker-postgres psql -U user -d github_tracker -c "
SELECT 
    'commits' as table_name,
    COUNT(*) as record_count
FROM track_project.commits
UNION ALL
SELECT 
    'commit_files' as table_name,
    COUNT(*) as record_count
FROM track_project.commit_files
UNION ALL
SELECT 
    'ai_analysis' as table_name,
    COUNT(*) as record_count
FROM track_project.ai_analysis;
"

# Step 7: Show sample data with relationships
Write-Host "`n7. Sample data with relationships..." -ForegroundColor Cyan
docker exec github-tracker-postgres psql -U user -d github_tracker -c "
SELECT 
    c.id,
    c.commit_sha,
    LEFT(c.message, 30) as message_preview,
    c.author,
    COUNT(cf.id) as file_count,
    COUNT(aa.id) as analysis_count
FROM track_project.commits c
LEFT JOIN track_project.commit_files cf ON c.id = cf.commit_id
LEFT JOIN track_project.ai_analysis aa ON c.id = aa.commit_id
GROUP BY c.id, c.commit_sha, c.message, c.author
ORDER BY c.created_at DESC
LIMIT 5;
"

# Step 8: Show detailed commit files
Write-Host "`n8. Sample commit files..." -ForegroundColor Cyan
docker exec github-tracker-postgres psql -U user -d github_tracker -c "
SELECT 
    cf.id,
    cf.commit_id,
    cf.file_path,
    cf.file_name,
    cf.change_type,
    cf.additions,
    cf.deletions,
    cf.changes
FROM track_project.commit_files cf
ORDER BY cf.commit_id DESC, cf.id
LIMIT 5;
"

# Step 9: Show detailed AI analysis
Write-Host "`n9. Sample AI analysis..." -ForegroundColor Cyan
docker exec github-tracker-postgres psql -U user -d github_tracker -c "
SELECT 
    aa.id,
    aa.commit_id,
    aa.analysis_type,
    aa.confidence_score,
    aa.results
FROM track_project.ai_analysis aa
ORDER BY aa.commit_id DESC, aa.id
LIMIT 5;
"

Write-Host "`n✅ Complete test data generated successfully!" -ForegroundColor Green
Write-Host "`nNow you should see data in all tables in pgAdmin4:" -ForegroundColor Yellow
Write-Host "- track_project.commits (7+ records)" -ForegroundColor White
Write-Host "- track_project.commit_files (multiple records)" -ForegroundColor White
Write-Host "- track_project.ai_analysis (multiple records)" -ForegroundColor White

Write-Host "`nTo view in pgAdmin4:" -ForegroundColor Cyan
Write-Host "1. Open http://localhost:5050" -ForegroundColor White
Write-Host "2. Navigate to: Servers → GitHub Tracker → Databases → github_tracker" -ForegroundColor White
Write-Host "3. Expand 'Schemas' → 'track_project' → 'Tables'" -ForegroundColor White
Write-Host "4. Right-click each table → 'View/Edit Data' → 'All Rows'" -ForegroundColor White

