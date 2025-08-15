# Generate Test Data Script
# This script helps generate test data by triggering the track-now functionality

Write-Host "Generating Test Data..." -ForegroundColor Green
Write-Host "=======================" -ForegroundColor Green

# Step 1: Check if services are running
Write-Host "`n1. Checking if services are running..." -ForegroundColor Cyan
try {
    $response = Invoke-RestMethod -Uri "http://localhost:8000/" -Method GET -TimeoutSec 5
    Write-Host "API Gateway: Running" -ForegroundColor Green
} catch {
    Write-Host "API Gateway: Not responding" -ForegroundColor Red
    Write-Host "Please start your Docker containers first:" -ForegroundColor Yellow
    Write-Host "docker-compose up -d" -ForegroundColor Gray
    exit 1
}

# Step 2: Check database service
Write-Host "`n2. Checking database service..." -ForegroundColor Cyan
try {
    $response = Invoke-RestMethod -Uri "http://localhost:8003/health" -Method GET -TimeoutSec 5
    Write-Host "Database Service: $($response.status)" -ForegroundColor Green
    Write-Host "Database Connection: $($response.database)" -ForegroundColor Green
} catch {
    Write-Host "Database Service: Not responding" -ForegroundColor Red
}

# Step 3: Check current data count
Write-Host "`n3. Checking current data count..." -ForegroundColor Cyan
try {
    $response = Invoke-RestMethod -Uri "http://localhost:8003/track-now" -Method GET -TimeoutSec 10
    Write-Host "Current commits: $($response.total_commits)" -ForegroundColor Yellow
    Write-Host "Data source: $($response.source)" -ForegroundColor Yellow
} catch {
    Write-Host "Error checking current data: $($_.Exception.Message)" -ForegroundColor Red
}

# Step 4: Trigger data generation
Write-Host "`n4. Triggering data generation..." -ForegroundColor Cyan
Write-Host "This will fetch commits from GitHub and process them with AI..." -ForegroundColor Yellow

try {
    # First, try to fetch commits from GitHub
    Write-Host "Fetching commits from GitHub..." -ForegroundColor White
    $githubResponse = Invoke-RestMethod -Uri "http://localhost:8001/commits" -Method GET -TimeoutSec 30
    Write-Host "GitHub commits fetched: $($githubResponse.total)" -ForegroundColor Green
    
    # Then trigger the full track-now process
    Write-Host "Processing commits with AI..." -ForegroundColor White
    $response = Invoke-RestMethod -Uri "http://localhost:8003/track-now" -Method GET -TimeoutSec 30
    Write-Host "Track-now completed successfully!" -ForegroundColor Green
    Write-Host "Total commits: $($response.total_commits)" -ForegroundColor Green
    Write-Host "Source: $($response.source)" -ForegroundColor Green
    
} catch {
    Write-Host "Error generating data: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Trying alternative approach..." -ForegroundColor Yellow
    
    # Try alternative approach - trigger fetch-commits
    try {
        Write-Host "Trying fetch-commits endpoint..." -ForegroundColor White
        $fetchResponse = Invoke-RestMethod -Uri "http://localhost:8001/fetch-commits" -Method POST -TimeoutSec 30
        Write-Host "Fetch-commits response: $($fetchResponse.message)" -ForegroundColor Green
        
        # Wait a moment for processing
        Start-Sleep 10
        
        # Check final result
        $finalResponse = Invoke-RestMethod -Uri "http://localhost:8003/track-now" -Method GET -TimeoutSec 10
        Write-Host "Final result - Total commits: $($finalResponse.total_commits)" -ForegroundColor Green
        
    } catch {
        Write-Host "Alternative approach also failed: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Step 5: Verify data was created
Write-Host "`n5. Verifying data creation..." -ForegroundColor Cyan
try {
    $verifyResponse = Invoke-RestMethod -Uri "http://localhost:8003/track-now" -Method GET -TimeoutSec 10
    Write-Host "Verification - Total commits: $($verifyResponse.total_commits)" -ForegroundColor Green
    Write-Host "Data source: $($verifyResponse.source)" -ForegroundColor Green
    
    if ($verifyResponse.total_commits -gt 0) {
        Write-Host "✅ Data generation successful!" -ForegroundColor Green
        Write-Host "`nNow you can view the data in pgAdmin4:" -ForegroundColor Yellow
        Write-Host "1. Open http://localhost:5050" -ForegroundColor White
        Write-Host "2. Login: admin@example.com / admin" -ForegroundColor White
        Write-Host "3. Navigate to: Servers -> [Your Server] -> Databases -> github_tracker" -ForegroundColor White
        Write-Host "4. Expand 'Schemas' -> 'track_project' -> 'Tables'" -ForegroundColor White
        Write-Host "5. Right-click on 'commits' table -> 'View/Edit Data'" -ForegroundColor White
    } else {
        Write-Host "❌ No data was generated" -ForegroundColor Red
        Write-Host "Check the logs for errors:" -ForegroundColor Yellow
        Write-Host "docker-compose logs database-service" -ForegroundColor Gray
    }
    
} catch {
    Write-Host "Error verifying data: $($_.Exception.Message)" -ForegroundColor Red
}

# Step 6: Show manual verification command
Write-Host "`n6. Manual verification commands:" -ForegroundColor Cyan
Write-Host "To check data directly in database:" -ForegroundColor White
Write-Host "docker exec github-tracker-postgres psql -U user -d github_tracker -c \"SELECT COUNT(*) FROM track_project.commits;\"" -ForegroundColor Gray
Write-Host "docker exec github-tracker-postgres psql -U user -d github_tracker -c \"SELECT id, commit_sha, LEFT(message, 30) FROM track_project.commits LIMIT 5;\"" -ForegroundColor Gray

Write-Host "`nData generation script completed!" -ForegroundColor Green
