# GitHub Commit Tracker - AI Agent

A microservice-based AI agent that continuously tracks GitHub commits, analyzes them using AI, and stores data in PostgreSQL with JSON backup.

## 🚀 Features

- **Continuous GitHub Monitoring**: AI agent runs continuously to fetch commits
- **AI-Powered Analysis**: Sentiment analysis, categorization, and priority assessment
- **Dual Storage**: PostgreSQL database + JSON file storage
- **Real-time UI**: Beautiful interface with "Track Now" button
- **Unique Hash Keys**: Prevents duplicate commit entries
- **Docker Deployment**: Easy deployment with Docker Desktop

## 🏗️ Architecture

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   Your      │    │  AI Agent   │    │  PostgreSQL │
│  GitHub     │◄──►│  Service    │◄──►│  Database   │
│ Repository  │    │ (FastAPI)   │    │             │
└─────────────┘    └─────────────┘    └─────────────┘
                           │                   │
                           ▼                   ▼
                    ┌─────────────┐    ┌─────────────┐
                    │  JSON File  │    │     UI      │
                    │ (commit.json)│   │ (Track Now) │
                    └─────────────┘    └─────────────┘
```

## 📋 Prerequisites

- Docker Desktop
- GitHub Personal Access Token
- Your GitHub repository

## 🚀 Quick Start

### 1. Clone and Setup

```bash
git clone <your-repo>
cd github-commit-tracker-microservices
```

### 2. Configure Environment

```bash
# Copy environment template
cp env.example .env

# Edit .env file with your GitHub details
GITHUB_TOKEN=your_github_token_here
GITHUB_REPO=your-username/your-repository
```

### 3. Deploy with Docker

```bash
# Build and start all services
docker-compose up -d --build

# Check service status
docker-compose ps
```

### 4. Access the Application

- **Frontend UI**: http://localhost:3000
- **AI Agent API**: http://localhost:8001
- **pgAdmin4**: http://localhost:5050
- **PostgreSQL**: localhost:5432

## 🎯 Usage

### Track Commits

1. Open http://localhost:3000
2. Click the **"Track Now"** button
3. View commits with AI analysis
4. Check JSON data section

### API Endpoints

- `GET /track-now` - Get latest commits with AI analysis
- `GET /commits` - Get all commits
- `GET /health` - Health check
- `GET /stats` - System statistics
- `POST /fetch-commits` - Manually trigger commit fetching

## 🔧 Configuration

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `GITHUB_TOKEN` | GitHub Personal Access Token | Required |
| `GITHUB_REPO` | Repository to track (user/repo) | Required |
| `DATABASE_URL` | PostgreSQL connection string | Auto-configured |
| `AI_CHECK_INTERVAL` | Fetch interval (seconds) | 300 |
| `AI_CONFIDENCE_THRESHOLD` | AI confidence threshold | 0.7 |

### GitHub Token Setup

1. Go to GitHub Settings → Developer settings → Personal access tokens
2. Generate new token with `repo` scope
3. Add token to `.env` file

## 📊 AI Analysis Features

### Commit Analysis
- **Sentiment Analysis**: Positive, negative, neutral
- **Category Detection**: Bug fix, feature, documentation, etc.
- **Priority Assessment**: High, medium, normal
- **Confidence Scoring**: AI confidence in analysis
- **Insights Generation**: Automated insights and recommendations

### Categories Detected
- Bug fixes
- New features
- Documentation updates
- Code refactoring
- Security updates
- Performance improvements

## 🗄️ Database Schema

### Commits Table
```sql
CREATE TABLE commits (
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
```

### Commit Files Table
```sql
CREATE TABLE commit_files (
    id SERIAL PRIMARY KEY,
    commit_id INTEGER REFERENCES commits(id) ON DELETE CASCADE,
    file_path VARCHAR(500) NOT NULL,
    file_name VARCHAR(255),
    file_extension VARCHAR(50),
    change_type VARCHAR(20), -- 'added', 'modified', 'deleted', 'renamed'
    additions INTEGER DEFAULT 0,
    deletions INTEGER DEFAULT 0,
    changes INTEGER DEFAULT 0,
    patch TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);
```

### Fallback System
The system implements a robust fallback mechanism:
1. **Primary**: PostgreSQL database
2. **Fallback**: `commit.json` file when database is unavailable
3. **Error Fallback**: JSON file when database connection fails

**Data Source Indicators:**
- 🟢 **Database**: Data from PostgreSQL
- 🟡 **JSON Fallback**: Data from commit.json (no database data)
- 🟠 **Error Fallback**: Data from commit.json (database error)

## 📁 Project Structure

```
github-commit-tracker-microservices/
├── ai-agent-service/          # AI Agent (FastAPI)
├── frontend/                  # UI Interface
├── database/                  # Database setup
├── docker-compose.yml         # Docker orchestration
└── README.md                  # This file
```

## 🔍 Monitoring

### Service Health
```bash
# Check all services
docker-compose ps

# View logs
docker-compose logs ai-agent-service
docker-compose logs frontend

# Health check
curl http://localhost:8001/health
```

### Database Access
- **pgAdmin4**: http://localhost:5050
  - Email: admin@example.com
  - Password: admin

## 🛠️ Development

### Local Development
```bash
# Start services
docker-compose up -d

# View logs
docker-compose logs -f

# Restart service
docker-compose restart ai-agent-service
```

### Adding Features
1. Modify AI agent service in `ai-agent-service/`
2. Update frontend in `frontend/public/`
3. Rebuild and restart: `docker-compose up -d --build`

## 🐛 Troubleshooting

### Common Issues

**Service won't start:**
```bash
# Check logs
docker-compose logs ai-agent-service

# Check environment variables
docker-compose config
```

**GitHub API errors:**
- Verify GitHub token is valid
- Check repository name format (user/repo)
- Ensure token has `repo` scope

**Database connection issues:**
```bash
# Check PostgreSQL container
docker-compose logs postgres

# Test connection
docker exec -it github-tracker-postgres psql -U user -d github_tracker
```

## 📈 Performance

- **Fetch Interval**: 5 minutes (configurable)
- **AI Processing**: Real-time analysis
- **Storage**: PostgreSQL + JSON backup
- **UI Updates**: Auto-refresh every 30 seconds

## 🤝 Contributing

1. Fork the repository
2. Create feature branch
3. Make changes
4. Test with Docker
5. Submit pull request

## 📄 License

This project is licensed under the MIT License.

## 🆘 Support

For issues and questions:
1. Check troubleshooting section
2. Review logs: `docker-compose logs`
3. Open GitHub issue

---

**Happy Tracking! 🚀**
