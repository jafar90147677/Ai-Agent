# Docker Fix and Restart Script
Write-Host "🔧 Docker Fix and Restart Script" -ForegroundColor Green
Write-Host "=================================" -ForegroundColor Green

# Check if Docker is running
Write-Host "`n1. Checking Docker status..." -ForegroundColor Yellow
try {
    $dockerVersion = docker --version
    Write-Host "   ✅ Docker is available: $dockerVersion" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Docker is not available or not running" -ForegroundColor Red
    Write-Host "   Please start Docker Desktop and try again" -ForegroundColor Yellow
    exit 1
}

# Check if docker-compose is available
Write-Host "`n2. Checking docker-compose..." -ForegroundColor Yellow
try {
    $composeVersion = docker-compose --version
    Write-Host "   ✅ Docker Compose is available: $composeVersion" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Docker Compose is not available" -ForegroundColor Red
    Write-Host "   Please install Docker Compose and try again" -ForegroundColor Yellow
    exit 1
}

# Stop existing containers
Write-Host "`n3. Stopping existing containers..." -ForegroundColor Yellow
docker-compose down
Write-Host "   ✅ Containers stopped" -ForegroundColor Green

# Rebuild and start containers
Write-Host "`n4. Rebuilding and starting containers..." -ForegroundColor Yellow
docker-compose up --build -d
Write-Host "   ✅ Containers started" -ForegroundColor Green

# Wait a moment for services to start
Write-Host "`n5. Waiting for services to start..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

# Check container status
Write-Host "`n6. Checking container status..." -ForegroundColor Yellow
docker-compose ps

Write-Host "`n🎉 Setup Complete!" -ForegroundColor Green
Write-Host "================================" -ForegroundColor Green
Write-Host "Services should now be running:" -ForegroundColor Yellow
Write-Host "• Frontend: http://localhost:3000" -ForegroundColor Cyan
Write-Host "• API Gateway: http://localhost:8000" -ForegroundColor Cyan
Write-Host "• Database: localhost:5432" -ForegroundColor Cyan
Write-Host "• pgAdmin: http://localhost:5050" -ForegroundColor Cyan

Write-Host "`n📝 If you still see issues:" -ForegroundColor Yellow
Write-Host "1. Check Docker Desktop is running" -ForegroundColor Cyan
Write-Host "2. Run: docker-compose logs [service-name]" -ForegroundColor Cyan
Write-Host "3. Make sure ports 3000, 8000, 5432, 5050 are not in use" -ForegroundColor Cyan
