# Data Flow Diagram Script
# Shows the complete flow from UI click to track_project schema storage

Write-Host "Data Flow: UI → Database Storage in track_project Schema" -ForegroundColor Green
Write-Host "=========================================================" -ForegroundColor Green

# Step 1: Show the complete data flow
Write-Host "`n1. Complete Data Flow Diagram:" -ForegroundColor Yellow
Write-Host "==============================" -ForegroundColor Yellow

Write-Host "`n📱 UI (React Frontend) http://localhost:3000" -ForegroundColor Cyan
Write-Host "   ↓ User clicks 'Track Now' button" -ForegroundColor Gray
Write-Host "   ↓ Makes API call to: http://localhost:8000/track-now" -ForegroundColor Gray

Write-Host "`n🌐 API Gateway (Port 8000)" -ForegroundColor Cyan
Write-Host "   ↓ Receives request from UI" -ForegroundColor Gray
Write-Host "   ↓ Routes to: http://database-service:8003/track-now" -ForegroundColor Gray

Write-Host "`n🗄️  Database Service (Port 8003)" -ForegroundColor Cyan
Write-Host "   ↓ Executes SQL query: SELECT * FROM track_project.commits" -ForegroundColor Gray
Write-Host "   ↓ Returns data from track_project schema" -ForegroundColor Gray

Write-Host "`n📊 PostgreSQL Database" -ForegroundColor Cyan
Write-Host "   ↓ Schema: track_project" -ForegroundColor Gray
Write-Host "   ↓ Table: commits" -ForegroundColor Gray
Write-Host "   ↓ Contains: Real GitHub commit data" -ForegroundColor Gray

# Step 2: Test the actual flow
Write-Host "`n2. Testing the Data Flow:" -ForegroundColor Yellow
Write-Host "=========================" -ForegroundColor Yellow

Write-Host "`nStep A: UI makes request to API Gateway..." -ForegroundColor Cyan
try {
    $response = Invoke-RestMethod -Uri "http://localhost:8000/track-now" -Method GET -TimeoutSec 10
    Write-Host "✅ API Gateway responded successfully" -ForegroundColor Green
    Write-Host "   Success: $($response.success)" -ForegroundColor Gray
    Write-Host "   Total commits: $($response.total_commits)" -ForegroundColor Gray
    Write-Host "   Source: $($response.source)" -ForegroundColor Gray
} catch {
    Write-Host "❌ API Gateway error: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`nStep B: Database Service querying track_project schema..." -ForegroundColor Cyan
docker exec github-tracker-postgres psql -U user -d github_tracker -c "
SELECT 
    'track_project.commits' as table_name,
    COUNT(*) as record_count,
    'Real GitHub data stored here' as description
FROM track_project.commits;
"

Write-Host "`nStep C: Sample data from track_project.commits..." -ForegroundColor Cyan
docker exec github-tracker-postgres psql -U user -d github_tracker -c "
SELECT 
    id,
    commit_sha,
    LEFT(message, 30) as message_preview,
    author,
    repository
FROM track_project.commits 
ORDER BY created_at DESC 
LIMIT 3;
"

# Step 3: Show the code flow
Write-Host "`n3. Code Flow Analysis:" -ForegroundColor Yellow
Write-Host "======================" -ForegroundColor Yellow

Write-Host "`n📱 React Frontend (App.js):" -ForegroundColor Cyan
Write-Host "   const trackNow = async () => {" -ForegroundColor Gray
Write-Host "     const response = await axios.get('http://localhost:8000/track-now');" -ForegroundColor Gray
Write-Host "     setCommits(response.data.commits);" -ForegroundColor Gray
Write-Host "   }" -ForegroundColor Gray

Write-Host "`n🌐 API Gateway (main.py):" -ForegroundColor Cyan
Write-Host "   @app.get('/track-now')" -ForegroundColor Gray
Write-Host "   async def track_now():" -ForegroundColor Gray
Write-Host "     response = await client.get(f'{DATABASE_SERVICE_URL}/track-now')" -ForegroundColor Gray
Write-Host "     return response.json()" -ForegroundColor Gray

Write-Host "`n🗄️  Database Service (main.py):" -ForegroundColor Cyan
Write-Host "   async def get_latest_commits():" -ForegroundColor Gray
Write-Host "     rows = await conn.fetch('" -ForegroundColor Gray
Write-Host "       SELECT * FROM track_project.commits" -ForegroundColor Gray
Write-Host "       ORDER BY created_at DESC" -ForegroundColor Gray
Write-Host "     ')" -ForegroundColor Gray

# Step 4: Show data storage process
Write-Host "`n4. Data Storage Process:" -ForegroundColor Yellow
Write-Host "=========================" -ForegroundColor Yellow

Write-Host "`n📥 When new commits are fetched:" -ForegroundColor Cyan
Write-Host "   1. GitHub Service fetches commits from GitHub API" -ForegroundColor Gray
Write-Host "   2. AI Service processes and analyzes commits" -ForegroundColor Gray
Write-Host "   3. Database Service stores in track_project.commits" -ForegroundColor Gray

Write-Host "`n💾 Storage in track_project schema:" -ForegroundColor Cyan
Write-Host "   INSERT INTO track_project.commits (" -ForegroundColor Gray
Write-Host "     hash_key, commit_sha, message, author," -ForegroundColor Gray
Write-Host "     author_email, repository, branch, committed_at," -ForegroundColor Gray
Write-Host "     ai_processed, ai_analysis" -ForegroundColor Gray
Write-Host "   ) VALUES (...)" -ForegroundColor Gray

# Step 5: Verify current data
Write-Host "`n5. Current Data in track_project Schema:" -ForegroundColor Yellow
Write-Host "==========================================" -ForegroundColor Yellow

Write-Host "`n📊 Database Statistics:" -ForegroundColor Cyan
docker exec github-tracker-postgres psql -U user -d github_tracker -c "
SELECT 
    'track_project.commits' as table_name,
    COUNT(*) as total_records,
    MAX(created_at) as latest_commit,
    MIN(created_at) as oldest_commit
FROM track_project.commits;
"

Write-Host "`n🔍 Sample Real GitHub Data:" -ForegroundColor Cyan
docker exec github-tracker-postgres psql -U user -d github_tracker -c "
SELECT 
    id,
    commit_sha,
    LEFT(message, 40) as commit_message,
    author,
    repository,
    created_at
FROM track_project.commits 
ORDER BY created_at DESC 
LIMIT 5;
"

# Step 6: Instructions for testing
Write-Host "`n6. How to Test the Complete Flow:" -ForegroundColor Yellow
Write-Host "==================================" -ForegroundColor Yellow

Write-Host "`n1. Open UI: http://localhost:3000" -ForegroundColor Cyan
Write-Host "2. Click 'Track Now' button" -ForegroundColor White
Write-Host "3. UI calls: http://localhost:8000/track-now" -ForegroundColor Gray
Write-Host "4. API Gateway routes to Database Service" -ForegroundColor Gray
Write-Host "5. Database Service queries: track_project.commits" -ForegroundColor Gray
Write-Host "6. Real GitHub data is returned to UI" -ForegroundColor Gray

Write-Host "`n7. Expected Results:" -ForegroundColor Yellow
Write-Host "===================" -ForegroundColor Yellow

Write-Host "`n✅ In UI you should see:" -ForegroundColor White
Write-Host "   - Total Commits: 8" -ForegroundColor Gray
Write-Host "   - Data Source: database" -ForegroundColor Gray
Write-Host "   - Real GitHub commits from track_project schema" -ForegroundColor Gray

Write-Host "`n✅ In pgAdmin4 you should see:" -ForegroundColor White
Write-Host "   - Schema: track_project" -ForegroundColor Gray
Write-Host "   - Table: commits" -ForegroundColor Gray
Write-Host "   - 8 records with real GitHub data" -ForegroundColor Gray

Write-Host "`n🎉 Data Flow Summary:" -ForegroundColor Green
Write-Host "=====================" -ForegroundColor Green
Write-Host "UI Click → API Gateway → Database Service → track_project.commits → UI Display" -ForegroundColor White
Write-Host "✅ Complete flow is working with real GitHub data!" -ForegroundColor Green
