[1mdiff --git a/README.md b/README.md[m
[1mindex e21648d..45b983b 100644[m
[1m--- a/README.md[m
[1m+++ b/README.md[m
[36m@@ -1,279 +1 @@[m
[31m-# GitHub Commit Tracker - AI Agent[m
[31m-[m
[31m-A microservice-based AI agent that continuously tracks GitHub commits, analyzes them using AI, and stores data in PostgreSQL with JSON backup.[m
[31m-[m
[31m-## 🚀 Features[m
[31m-[m
[31m-- **Continuous GitHub Monitoring**: AI agent runs continuously to fetch commits[m
[31m-- **AI-Powered Analysis**: Sentiment analysis, categorization, and priority assessment[m
[31m-- **Dual Storage**: PostgreSQL database + JSON file storage[m
[31m-- **Real-time UI**: Beautiful interface with "Track Now" button[m
[31m-- **Unique Hash Keys**: Prevents duplicate commit entries[m
[31m-- **Docker Deployment**: Easy deployment with Docker Desktop[m
[31m-[m
[31m-## 🏗️ Architecture[m
[31m-[m
[31m-```[m
[31m-┌─────────────┐    ┌─────────────┐    ┌─────────────┐[m
[31m-│   Your      │    │  AI Agent   │    │  PostgreSQL │[m
[31m-│  GitHub     │◄──►│  Service    │◄──►│  Database   │[m
[31m-│ Repository  │    │ (FastAPI)   │    │             │[m
[31m-└─────────────┘    └─────────────┘    └─────────────┘[m
[31m-                           │                   │[m
[31m-                           ▼                   ▼[m
[31m-                    ┌─────────────┐    ┌─────────────┐[m
[31m-                    │  JSON File  │    │     UI      │[m
[31m-                    │ (commit.json)│   │ (Track Now) │[m
[31m-                    └─────────────┘    └─────────────┘[m
[31m-```[m
[31m-[m
[31m-## 📋 Prerequisites[m
[31m-[m
[31m-- Docker Desktop[m
[31m-- GitHub Personal Access Token[m
[31m-- Your GitHub repository[m
[31m-[m
[31m-## 🚀 Quick Start[m
[31m-[m
[31m-### 1. Clone and Setup[m
[31m-[m
[31m-```bash[m
[31m-git clone <your-repo>[m
[31m-cd github-commit-tracker-microservices[m
[31m-```[m
[31m-[m
[31m-### 2. Configure Environment[m
[31m-[m
[31m-```bash[m
[31m-# Copy environment template[m
[31m-cp env.example .env[m
[31m-[m
[31m-# Edit .env file with your GitHub details[m
[31m-GITHUB_TOKEN=your_github_token_here[m
[31m-GITHUB_REPO=your-username/your-repository[m
[31m-```[m
[31m-[m
[31m-### 3. Deploy with Docker[m
[31m-[m
[31m-```bash[m
[31m-# Build and start all services[m
[31m-docker-compose up -d --build[m
[31m-[m
[31m-# Check service status[m
[31m-docker-compose ps[m
[31m-```[m
[31m-[m
[31m-### 4. Access the Application[m
[31m-[m
[31m-- **Frontend UI**: http://localhost:3000[m
[31m-- **AI Agent API**: http://localhost:8001[m
[31m-- **pgAdmin4**: http://localhost:5050[m
[31m-- **PostgreSQL**: localhost:5432[m
[31m-[m
[31m-## 🎯 Usage[m
[31m-[m
[31m-### Track Commits[m
[31m-[m
[31m-1. Open http://localhost:3000[m
[31m-2. Click the **"Track Now"** button[m
[31m-3. View commits with AI analysis[m
[31m-4. Check JSON data section[m
[31m-[m
[31m-### API Endpoints[m
[31m-[m
[31m-- `GET /track-now` - Get latest commits with AI analysis[m
[31m-- `GET /commits` - Get all commits[m
[31m-- `GET /health` - Health check[m
[31m-- `GET /stats` - System statistics[m
[31m-- `POST /fetch-commits` - Manually trigger commit fetching[m
[31m-[m
[31m-## 🔧 Configuration[m
[31m-[m
[31m-### Environment Variables[m
[31m-[m
[31m-| Variable | Description | Default |[m
[31m-|----------|-------------|---------|[m
[31m-| `GITHUB_TOKEN` | GitHub Personal Access Token | Required |[m
[31m-| `GITHUB_REPO` | Repository to track (user/repo) | Required |[m
[31m-| `DATABASE_URL` | PostgreSQL connection string | Auto-configured |[m
[31m-| `AI_CHECK_INTERVAL` | Fetch interval (seconds) | 300 |[m
[31m-| `AI_CONFIDENCE_THRESHOLD` | AI confidence threshold | 0.7 |[m
[31m-[m
[31m-### GitHub Token Setup[m
[31m-[m
[31m-1. Go to GitHub Settings → Developer settings → Personal access tokens[m
[31m-2. Generate new token with `repo` scope[m
[31m-3. Add token to `.env` file[m
[31m-[m
[31m-## 📊 AI Analysis Features[m
[31m-[m
[31m-### Commit Analysis[m
[31m-- **Sentiment Analysis**: Positive, negative, neutral[m
[31m-- **Category Detection**: Bug fix, feature, documentation, etc.[m
[31m-- **Priority Assessment**: High, medium, normal[m
[31m-- **Confidence Scoring**: AI confidence in analysis[m
[31m-- **Insights Generation**: Automated insights and recommendations[m
[31m-[m
[31m-### Categories Detected[m
[31m-- Bug fixes[m
[31m-- New features[m
[31m-- Documentation updates[m
[31m-- Code refactoring[m
[31m-- Security updates[m
[31m-- Performance improvements[m
[31m-[m
[31m-## 🗄️ Database Schema[m
[31m-[m
[31m-### Commits Table[m
[31m-```sql[m
[31m-CREATE TABLE commits ([m
[31m-    id SERIAL PRIMARY KEY,[m
[31m-    hash_key VARCHAR(255) UNIQUE NOT NULL,[m
[31m-    commit_sha VARCHAR(255) NOT NULL,[m
[31m-    message TEXT,[m
[31m-    author VARCHAR(255),[m
[31m-    author_email VARCHAR(255),[m
[31m-    repository VARCHAR(255),[m
[31m-    branch VARCHAR(255),[m
[31m-    created_at TIMESTAMP DEFAULT NOW(),[m
[31m-    committed_at TIMESTAMP,[m
[31m-    ai_processed BOOLEAN DEFAULT FALSE,[m
[31m-    ai_analysis JSON,[m
[31m-    event_status VARCHAR(50) DEFAULT 'pending'[m
[31m-);[m
[31m-```[m
[31m-[m
[31m-### Commit Files Table[m
[31m-```sql[m
[31m-CREATE TABLE commit_files ([m
[31m-    id SERIAL PRIMARY KEY,[m
[31m-    commit_id INTEGER REFERENCES commits(id) ON DELETE CASCADE,[m
[31m-    file_path VARCHAR(500) NOT NULL,[m
[31m-    file_name VARCHAR(255),[m
[31m-    file_extension VARCHAR(50),[m
[31m-    change_type VARCHAR(20), -- 'added', 'modified', 'deleted', 'renamed'[m
[31m-    additions INTEGER DEFAULT 0,[m
[31m-    deletions INTEGER DEFAULT 0,[m
[31m-    changes INTEGER DEFAULT 0,[m
[31m-    patch TEXT,[m
[31m-    created_at TIMESTAMP DEFAULT NOW()[m
[31m-);[m
[31m-```[m
[31m-[m
[31m-### Fallback System[m
[31m-The system implements a robust fallback mechanism:[m
[31m-1. **Primary**: PostgreSQL database[m
[31m-2. **Fallback**: `commit.json` file when database is unavailable[m
[31m-3. **Error Fallback**: JSON file when database connection fails[m
[31m-[m
[31m-**Data Source Indicators:**[m
[31m-- 🟢 **Database**: Data from PostgreSQL[m
[31m-- 🟡 **JSON Fallback**: Data from commit.json (no database data)[m
[31m-- 🟠 **Error Fallback**: Data from commit.json (database error)[m
[31m-[m
[31m-## 📁 Project Structure[m
[31m-[m
[31m-```[m
[31m-github-commit-tracker-microservices/[m
[31m-├── ai-agent-service/          # AI Agent (FastAPI)[m
[31m-├── frontend/                  # UI Interface[m
[31m-├── database/                  # Database setup[m
[31m-├── docker-compose.yml         # Docker orchestration[m
[31m-└── README.md                  # This file[m
[31m-```[m
[31m-[m
[31m-## 🔍 Monitoring[m
[31m-[m
[31m-### Service Health[m
[31m-```bash[m
[31m-# Check all services[m
[31m-docker-compose ps[m
[31m-[m
[31m-# View logs[m
[31m-docker-compose logs ai-agent-service[m
[31m-docker-compose logs frontend[m
[31m-[m
[31m-# Health check[m
[31m-curl http://localhost:8001/health[m
[31m-```[m
[31m-[m
[31m-### Database Access[m
[31m-- **pgAdmin4**: http://localhost:5050[m
[31m-  - Email: admin@example.com[m
[31m-  - Password: admin[m
[31m-[m
[31m-## 🛠️ Development[m
[31m-[m
[31m-### Local Development[m
[31m-```bash[m
[31m-# Start services[m
[31m-docker-compose up -d[m
[31m-[m
[31m-# View logs[m
[31m-docker-compose logs -f[m
[31m-[m
[31m-# Restart service[m
[31m-docker-compose restart ai-agent-service[m
[31m-```[m
[31m-[m
[31m-### Adding Features[m
[31m-1. Modify AI agent service in `ai-agent-service/`[m
[31m-2. Update frontend in `frontend/public/`[m
[31m-3. Rebuild and restart: `docker-compose up -d --build`[m
[31m-[m
[31m-## 🐛 Troubleshooting[m
[31m-[m
[31m-### Common Issues[m
[31m-[m
[31m-**Service won't start:**[m
[31m-```bash[m
[31m-# Check logs[m
[31m-docker-compose logs ai-agent-service[m
[31m-[m
[31m-# Check environment variables[m
[31m-docker-compose config[m
[31m-```[m
[31m-[m
[31m-**GitHub API errors:**[m
[31m-- Verify GitHub token is valid[m
[31m-- Check repository name format (user/repo)[m
[31m-- Ensure token has `repo` scope[m
[31m-[m
[31m-**Database connection issues:**[m
[31m-```bash[m
[31m-# Check PostgreSQL container[m
[31m-docker-compose logs postgres[m
[31m-[m
[31m-# Test connection[m
[31m-docker exec -it github-tracker-postgres psql -U user -d github_tracker[m
[31m-```[m
[31m-[m
[31m-## 📈 Performance[m
[31m-[m
[31m-- **Fetch Interval**: 5 minutes (configurable)[m
[31m-- **AI Processing**: Real-time analysis[m
[31m-- **Storage**: PostgreSQL + JSON backup[m
[31m-- **UI Updates**: Auto-refresh every 30 seconds[m
[31m-[m
[31m-## 🤝 Contributing[m
[31m-[m
[31m-1. Fork the repository[m
[31m-2. Create feature branch[m
[31m-3. Make changes[m
[31m-4. Test with Docker[m
[31m-5. Submit pull request[m
[31m-[m
[31m-## 📄 License[m
[31m-[m
[31m-This project is licensed under the MIT License.[m
[31m-[m
[31m-## 🆘 Support[m
[31m-[m
[31m-For issues and questions:[m
[31m-1. Check troubleshooting section[m
[31m-2. Review logs: `docker-compose logs`[m
[31m-3. Open GitHub issue[m
[31m-[m
[31m----[m
[31m-[m
[31m-**Happy Tracking! 🚀**[m
[32m+[m[32mhi[m
