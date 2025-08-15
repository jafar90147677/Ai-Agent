# Test UI Data Display Script
# This script tests if the UI is receiving and displaying real GitHub data

Write-Host "Testing UI Data Display..." -ForegroundColor Green
Write-Host "===========================" -ForegroundColor Green

# Step 1: Check if React frontend is accessible
Write-Host "`n1. Testing React Frontend Access:" -ForegroundColor Cyan
try {
    $response = Invoke-WebRequest -Uri "http://localhost:3000" -Method GET -TimeoutSec 10
    Write-Host "✅ React frontend is accessible" -ForegroundColor Green
} catch {
    Write-Host "❌ React frontend is not accessible: $($_.Exception.Message)" -ForegroundColor Red
}

# Step 2: Test API Gateway
Write-Host "`n2. Testing API Gateway:" -ForegroundColor Cyan
try {
    $response = Invoke-RestMethod -Uri "http://localhost:8000/" -Method GET -TimeoutSec 10
    Write-Host "✅ API Gateway is running" -ForegroundColor Green
    Write-Host "   Status: $($response.status)" -ForegroundColor Gray
} catch {
    Write-Host "❌ API Gateway error: $($_.Exception.Message)" -ForegroundColor Red
}

# Step 3: Test track-now endpoint
Write-Host "`n3. Testing Track-Now Endpoint:" -ForegroundColor Cyan
try {
    $response = Invoke-RestMethod -Uri "http://localhost:8000/track-now" -Method GET -TimeoutSec 10
    Write-Host "✅ Track-now endpoint is working" -ForegroundColor Green
    Write-Host "   Success: $($response.success)" -ForegroundColor Gray
    Write-Host "   Total commits: $($response.total_commits)" -ForegroundColor Gray
    Write-Host "   Source: $($response.source)" -ForegroundColor Gray
    Write-Host "   Message: $($response.message)" -ForegroundColor Gray
} catch {
    Write-Host "❌ Track-now endpoint error: $($_.Exception.Message)" -ForegroundColor Red
}

# Step 4: Show sample data that should appear in UI
Write-Host "`n4. Sample Data That Should Appear in UI:" -ForegroundColor Cyan
try {
    $response = Invoke-RestMethod -Uri "http://localhost:8000/track-now" -Method GET -TimeoutSec 10
    if ($response.success -and $response.commits) {
        Write-Host "✅ Found $($response.commits.Count) commits" -ForegroundColor Green
        Write-Host "`nFirst 3 commits that should appear in UI:" -ForegroundColor White
        for ($i = 0; $i -lt [Math]::Min(3, $response.commits.Count); $i++) {
            $commit = $response.commits[$i]
            Write-Host "   Commit $($i + 1):" -ForegroundColor Cyan
            Write-Host "     Message: $($commit.message)" -ForegroundColor White
            Write-Host "     Author: $($commit.author)" -ForegroundColor Gray
            Write-Host "     SHA: $($commit.commit_sha)" -ForegroundColor Gray
            Write-Host "     Repository: $($commit.repository)" -ForegroundColor Gray
            Write-Host ""
        }
    } else {
        Write-Host "❌ No commits found in response" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Error getting sample data: $($_.Exception.Message)" -ForegroundColor Red
}

# Step 5: Instructions for testing UI
Write-Host "`n5. How to Test Your UI:" -ForegroundColor Yellow
Write-Host "=========================" -ForegroundColor Yellow

Write-Host "`nStep-by-step testing:" -ForegroundColor White
Write-Host "1. Open http://localhost:3000 in your browser" -ForegroundColor Cyan
Write-Host "2. Click the '🚀 Track Now' button" -ForegroundColor White
Write-Host "3. You should see:" -ForegroundColor White
Write-Host "   - Total Commits: 8" -ForegroundColor Gray
Write-Host "   - Data Source: database" -ForegroundColor Gray
Write-Host "   - Recent commits list with real GitHub data" -ForegroundColor Gray
Write-Host "4. Check the commits list for:" -ForegroundColor White
Write-Host "   - 'Create readme1.md' by Mohammed jafar sadiqe" -ForegroundColor Gray
Write-Host "   - 'Create readme.md' by Mohammed jafar sadiqe" -ForegroundColor Gray
Write-Host "   - 'at ok' by jafar90147677" -ForegroundColor Gray
Write-Host "   - 'test' by jafar90147677" -ForegroundColor Gray

Write-Host "`n6. Troubleshooting:" -ForegroundColor Yellow
Write-Host "===================" -ForegroundColor Yellow

Write-Host "`nIf you don't see data in UI:" -ForegroundColor White
Write-Host "1. Open browser Developer Tools (F12)" -ForegroundColor Gray
Write-Host "2. Check Console tab for errors" -ForegroundColor Gray
Write-Host "3. Check Network tab to see API calls" -ForegroundColor Gray
Write-Host "4. Verify the API call to http://localhost:8000/track-now" -ForegroundColor Gray
Write-Host "5. Check if the response contains commits data" -ForegroundColor Gray

Write-Host "`n7. Expected UI Behavior:" -ForegroundColor Yellow
Write-Host "=========================" -ForegroundColor Yellow

Write-Host "`nWhen you click 'Track Now':" -ForegroundColor White
Write-Host "- Button should show '🔄 Fetching...'" -ForegroundColor Gray
Write-Host "- Statistics should update with real numbers" -ForegroundColor Gray
Write-Host "- Commits list should populate with GitHub data" -ForegroundColor Gray
Write-Host "- Each commit should show message, author, date" -ForegroundColor Gray
Write-Host "- AI analysis should be visible (if available)" -ForegroundColor Gray

Write-Host "`n✅ UI testing completed!" -ForegroundColor Green
Write-Host "Now test your UI and let me know what you see!" -ForegroundColor Green
