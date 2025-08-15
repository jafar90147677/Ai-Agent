# Connect to PostgreSQL17 Server in pgAdmin4

## 🖥️ **Using Your Existing PostgreSQL17 Server**

Since you already have a PostgreSQL17 server configured in pgAdmin4, you can connect to the GitHub tracker database directly.

### **Step 1: Open pgAdmin4 Desktop Application**
- Launch your pgAdmin4 application
- You should see "PostgreSQL17" in your servers list

### **Step 2: Connect to PostgreSQL17 Server**
1. **Expand "PostgreSQL17"** in the left panel
2. **Right-click on "PostgreSQL17"**
3. **Select "Connect Server"** (if not already connected)
4. **Enter your password**: `9014`

### **Step 3: Browse to the GitHub Tracker Database**
Once connected to PostgreSQL17, navigate to:
- **PostgreSQL17** → **Databases** → **github_tracker** → **Schemas** → **public** → **Tables**

### **Step 4: View Your Real Data**
- **Right-click on `commits` table**
- Select **"View/Edit Data" → "All Rows"**

## 📊 **Expected Data in Your PostgreSQL17 Server**

You should see your GitHub commit:
- **Commit SHA**: `3f82507a64ed3969234f43b33ff48eda291a404f`
- **Message**: "at ok"
- **Author**: `jafar90147677`
- **Repository**: `jafar90147677/Ai-Agent`

## 🔧 **If github_tracker Database is Not Visible**

If you don't see the `github_tracker` database in your PostgreSQL17 server:

### **Option 1: Check Connection Details**
Your PostgreSQL17 server should be connected to:
- **Host**: `localhost`
- **Port**: `5432`
- **Username**: `user`
- **Password**: `9014` (your PostgreSQL17 password)

### **Option 2: Refresh the Server**
1. **Right-click on "PostgreSQL17"**
2. **Select "Refresh"**
3. Check if `github_tracker` database appears

### **Option 3: Check Server Properties**
1. **Right-click on "PostgreSQL17"**
2. **Select "Properties"**
3. **Go to "Connection" tab**
4. Verify the connection details match the Docker PostgreSQL

## 📋 **Available Tables in github_tracker Database**

- **`commits`** - Your GitHub commits with AI analysis
- **`commit_files`** - Files changed in commits
- **`ai_analysis`** - AI analysis results
- **`tracking_config`** - Configuration settings

## 🎯 **Quick Navigation Path**
PostgreSQL17 → Databases → github_tracker → Schemas → public → Tables → commits → View/Edit Data → All Rows

## 🔑 **Your PostgreSQL17 Credentials**
- **Password**: `9014`
- **Host**: `localhost`
- **Port**: `5432`
