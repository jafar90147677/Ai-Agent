# pgAdmin4 Desktop App Connection Guide

## 🖥️ **Step-by-Step Connection Instructions**

### **Step 1: Open pgAdmin4 Desktop Application**
- Launch pgAdmin4 from your Start Menu or Desktop shortcut
- Wait for the application to fully load

### **Step 2: Add New Server Connection**
1. In the left panel, **right-click on "Servers"**
2. Select **"Register" → "Server..."**
3. A new dialog box will open

### **Step 3: Fill in Connection Details**

**General Tab:**
- **Name**: `GitHub Tracker` (or any name you prefer)

**Connection Tab:**
- **Host name/address**: `localhost`
- **Port**: `5432`
- **Maintenance database**: `github_tracker`
- **Username**: `user`
- **Password**: `password`
- **Save password**: ✅ (check this box)

### **Step 4: Test and Save**
1. Click **"Test Connection"** button
2. If successful, you'll see a green checkmark
3. Click **"Save"** to add the server

### **Step 5: Browse Your Data**
Once connected, expand the tree:
- **Servers** → **GitHub Tracker** → **Databases** → **github_tracker** → **Schemas** → **public** → **Tables**

### **Step 6: View Your Real Data**
- **Right-click on `commits` table**
- Select **"View/Edit Data" → "All Rows"**

## 📊 **Expected Data**

You should see your GitHub commit:
- **Commit SHA**: `3f82507a64ed3969234f43b33ff48eda291a404f`
- **Message**: "at ok"
- **Author**: `jafar90147677`
- **Repository**: `jafar90147677/Ai-Agent`

## 🔧 **Troubleshooting**

**If connection fails:**
1. Make sure Docker containers are running: `docker-compose ps`
2. Check if PostgreSQL is accessible: `docker exec github-tracker-postgres psql -U user -d github_tracker -c "SELECT 1;"`
3. Verify port 5432 is not blocked by firewall
4. Try restarting Docker Desktop if needed

**Connection Details Summary:**
- **Host**: localhost
- **Port**: 5432
- **Database**: github_tracker
- **Username**: user
- **Password**: password
