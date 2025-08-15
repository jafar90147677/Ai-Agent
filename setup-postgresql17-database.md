# Setup GitHub Tracker Database in PostgreSQL17

## 🎯 **Step-by-Step Guide to Create New Database**

### **Step 1: Open pgAdmin4 and Connect to PostgreSQL17**

1. **Launch pgAdmin4 Desktop Application**
2. **Connect to your PostgreSQL17 server** (password: `9014`)
3. **Right-click on "PostgreSQL17"** → **"Connect Server"**

### **Step 2: Create New Database**

1. **Right-click on "Databases"** under PostgreSQL17
2. **Select "Create" → "Database..."**
3. **Fill in the details:**
   - **Database**: `github_tracker_db`
   - **Owner**: `postgres` (or your default user)
   - **Template**: `template0` (or leave default)
4. **Click "Save"**

### **Step 3: Create Database Schema**

1. **Expand the new `github_tracker_db` database**
2. **Right-click on "github_tracker_db"** → **"Query Tool"**
3. **Copy and paste the contents of `create-github-tracker-db.sql`**
4. **Click the "Execute" button** (or press F5)

### **Step 4: Verify Database Creation**

Run these queries to verify everything is set up:

```sql
-- Check if tables were created
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
ORDER BY table_name;

-- Check table structure
\d commits
\d commit_files
\d ai_analysis
\d tracking_config
```

## 📊 **Database Schema Overview**

### **Tables Created:**

1. **`commits`** - Stores GitHub commit information
   - commit_sha, message, author, repository
   - committed_at (with timezone conversion)
   - ai_analysis (JSON data)

2. **`commit_files`** - Files changed in commits
   - file_path, change_type, additions/deletions
   - Links to commits table

3. **`ai_analysis`** - AI analysis results
   - analysis_type, results, confidence_score
   - Links to commits table

4. **`tracking_config`** - Configuration settings
   - repository, enabled, check_interval

## 🔧 **Update Application Configuration**

After creating the database, you'll need to update your application to use the new database:

### **Option 1: Update Docker Environment**
Update your `.env` file:
```bash
DATABASE_URL=postgresql://postgres:9014@localhost:5432/github_tracker_db
```

### **Option 2: Update PostgreSQL17 Connection**
In your application, change the connection to:
- **Host**: `localhost`
- **Port**: `5432`
- **Database**: `github_tracker_db`
- **Username**: `postgres`
- **Password**: `9014`

## 🎯 **Next Steps**

1. **Run the SQL script** to create tables
2. **Update your application** to connect to the new database
3. **Test the connection** by fetching some commits
4. **View your data** in pgAdmin4

## 📋 **Useful SQL Queries**

```sql
-- View all commits
SELECT * FROM track_project.commits ORDER BY created_at DESC;

-- View AI analysis
SELECT c.commit_sha, c.message, c.ai_analysis 
FROM track_project.commits c 
WHERE c.ai_analysis IS NOT NULL;

-- View commit statistics
SELECT 
    COUNT(*) as total_commits,
    COUNT(CASE WHEN ai_processed = true THEN 1 END) as ai_processed
FROM track_project.commits;
```

## ✅ **Verification Checklist**

- [ ] Database `github_tracker_db` created
- [ ] All 4 tables created successfully
- [ ] Indexes created for performance
- [ ] Default tracking config inserted
- [ ] Application updated to use new database
- [ ] Connection tested successfully
