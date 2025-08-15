# 🔧 Troubleshooting Guide - GitHub Commit Tracker

## Issues Fixed ✅

### 1. UI Connection Issue (ERR_EMPTY_RESPONSE)
**Problem**: React frontend couldn't connect to API gateway
**Solution**: Updated API base URL to use relative paths in production

**Files Modified**:
- `react-frontend/src/App.js` - Fixed API base URL
- `react-frontend/nginx.conf` - Added timeout settings

### 2. Docker Services
**Problem**: Docker containers weren't running properly
**Solution**: Rebuilt and restarted all containers

**Commands Used**:
```bash
docker-compose down
docker-compose up --build -d
```

## Current Status ✅

All services are now running:
- ✅ React Frontend: http://localhost:3000
- ✅ API Gateway: http://localhost:8000
- ✅ Database: localhost:5432
- ✅ pgAdmin: http://localhost:5050

## Next Steps for GitHub Integration 🚀

### Option 1: Use the Setup Script (Recommended)
```powershell
.\setup-github.ps1
```

### Option 2: Manual Setup

1. **Get GitHub Token**:
   - Go to: https://github.com/settings/tokens
   - Click "Generate new token (classic)"
   - Select scopes: `repo` (private) or `public_repo` (public)
   - Copy the token

2. **Update .env file**:
   ```env
   GITHUB_TOKEN=your_actual_token_here
   GITHUB_REPO=your-username/your-repository-name
   ```

3. **Restart Services**:
   ```bash
   docker-compose restart github-service ai-service database-service api-gateway-service react-frontend
   ```

## Testing the Application 🧪

1. **Open the UI**: http://localhost:3000
2. **Click "Track Now"** to fetch data
3. **Expected Results**:
   - If GitHub is configured: Real commits with AI analysis
   - If not configured: Sample data with fallback message

## Troubleshooting Commands 🔍

### Check Service Status
```bash
docker-compose ps
```

### View Service Logs
```bash
docker-compose logs [service-name]
# Examples:
docker-compose logs react-frontend
docker-compose logs api-gateway-service
docker-compose logs github-service
```

### Test API Endpoints
```bash
# Test API Gateway
curl http://localhost:8000/health

# Test Frontend
curl http://localhost:3000
```

### Restart Specific Service
```bash
docker-compose restart [service-name]
```

## Common Issues & Solutions 🛠️

### Issue: "ERR_EMPTY_RESPONSE" on localhost:3000
**Solution**: 
1. Check if Docker is running
2. Run: `docker-compose ps`
3. If containers are down: `docker-compose up -d`

### Issue: "GitHub token not configured"
**Solution**:
1. Update `.env` file with real GitHub token
2. Restart services: `docker-compose restart github-service`

### Issue: "Repository not found"
**Solution**:
1. Check repository name format: `username/repository-name`
2. Ensure repository is accessible with your token
3. Verify token has correct permissions

### Issue: Still seeing sample data
**Solution**:
1. Check GitHub service logs: `docker-compose logs github-service`
2. Verify `.env` file has correct values
3. Restart all services: `docker-compose restart`

## File Structure 📁

```
Ai Agent/
├── .env                          # GitHub configuration (needs your token)
├── docker-compose.yml            # Service orchestration
├── setup-github.ps1             # GitHub setup script
├── fix-docker.ps1               # Docker troubleshooting script
├── react-frontend/              # React UI
├── api-gateway-service/         # Main API
├── github-service/              # GitHub integration
├── ai-service/                  # AI analysis
├── database-service/            # Data storage
└── github-analysis-service/     # Advanced analysis
```

## Support 🆘

If you're still having issues:
1. Check service logs for error messages
2. Verify all ports (3000, 8000, 5432, 5050) are available
3. Ensure Docker Desktop is running
4. Try the fix scripts: `.\fix-docker.ps1`

## Success Indicators ✅

You'll know everything is working when:
- ✅ http://localhost:3000 loads without errors
- ✅ "Track Now" button fetches data
- ✅ You see real GitHub commits (not sample data)
- ✅ AI analysis is performed on commits
- ✅ Statistics show actual commit counts
