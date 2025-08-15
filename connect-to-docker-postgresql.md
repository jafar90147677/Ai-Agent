# Connect pgAdmin4 to Docker PostgreSQL

## 🐳 **The Issue**
Your PostgreSQL17 server is connected to a different PostgreSQL instance. The `github_tracker` database is running in the Docker container.

## 🎯 **Solution: Connect to Docker PostgreSQL**

### **Option 1: Add New Server (Recommended)**

1. **In pgAdmin4**, right-click on **"Servers"**
2. **Select "Register" → "Server..."**
3. **Fill in connection details:**

**General Tab:**
- **Name**: `Docker GitHub Tracker`

**Connection Tab:**
- **Host name/address**: `localhost`
- **Port**: `5432`
- **Maintenance database**: `github_tracker`
- **Username**: `user`
- **Password**: `password`
- **Save password**: ✅ (check this box)

4. **Click "Test Connection"** (should show green checkmark)
5. **Click "Save"**

### **Option 2: Update PostgreSQL17 Connection**

1. **Right-click on "PostgreSQL17"**
2. **Select "Properties"**
3. **Go to "Connection" tab**
4. **Update settings:**
   - **Host name/address**: `localhost`
   - **Port**: `5432`
   - **Maintenance database**: `github_tracker`
   - **Username**: `user`
   - **Password**: `password`
5. **Click "Save"**

## 📊 **After Connection**

Navigate to:
**Docker GitHub Tracker** → **Databases** → **github_tracker** → **Schemas** → **public** → **Tables**

**Right-click on `commits` table** → **"View/Edit Data" → "All Rows"**

## 🔑 **Docker PostgreSQL Credentials**
- **Host**: localhost
- **Port**: 5432
- **Database**: github_tracker
- **Username**: user
- **Password**: password

## 📋 **Available Tables**
- **`commits`** - Your GitHub commits with AI analysis
- **`commit_files`** - Files changed in commits
- **`ai_analysis`** - AI analysis results
- **`tracking_config`** - Configuration settings

## 🎯 **Expected Data**
- **Commit SHA**: `3f82507a64ed3969234f43b33ff48eda291a404f`
- **Message**: "at ok"
- **Author**: `jafar90147677`
- **Repository**: `jafar90147677/Ai-Agent`
