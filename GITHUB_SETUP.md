# 🚀 GitHub Integration Setup

## **Step 1: Get Your GitHub Token**

1. Go to **GitHub.com** → **Settings** → **Developer settings** → **Personal access tokens** → **Tokens (classic)**
2. Click **"Generate new token (classic)"**
3. Give it a name like "GitHub Commit Tracker"
4. Select scopes:
   - **`repo`** (for private repositories)
   - **`public_repo`** (for public repositories only)
5. Click **"Generate token"**
6. **Copy the token** (you won't see it again!)

## **Step 2: Update Configuration**

Edit the `.env` file in your project and replace:

```env
GITHUB_TOKEN=your_actual_token_here
GITHUB_REPO=your-username/your-repository-name
```

**Example:**
```env
GITHUB_TOKEN=ghp_1234567890abcdef1234567890abcdef12345678
GITHUB_REPO=john/my-awesome-project
```

## **Step 3: Restart Services**

```bash
docker-compose restart github-service ai-service database-service
```

## **Step 4: Test**

1. Open **http://localhost:3000**
2. Click **"Track Now"**
3. You should see your real commits with AI analysis!

## **🎯 What You'll Get:**

- ✅ **Real commits** from your GitHub repository
- ✅ **AI analysis** of commit messages
- ✅ **File change tracking** with statistics
- ✅ **Sentiment analysis** and categorization
- ✅ **Priority assessment** of commits

## **🔧 Troubleshooting:**

- **If you see "GitHub token not configured"**: Check your `.env` file
- **If you see "Repository not found"**: Check your repository name format
- **If you see sample data**: GitHub integration isn't working yet

**Need help? Just provide your GitHub username and repository name!**
