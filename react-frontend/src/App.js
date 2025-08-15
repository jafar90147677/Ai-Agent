import React, { useState, useEffect } from 'react';
import axios from 'axios';
import './App.css';

// Add error handling for API calls
const API_BASE_URL = process.env.NODE_ENV === 'production' 
  ? '/api'  // Use relative path in production (nginx proxy)
  : 'http://localhost:8000';  // Use localhost in development

function App() {
  const [loading, setLoading] = useState(false);
  const [commits, setCommits] = useState([]);
  const [stats, setStats] = useState({});
  const [jsonData, setJsonData] = useState({});
  const [showJson, setShowJson] = useState(false);
  const [error, setError] = useState('');
  const [dataSource, setDataSource] = useState('');



  const trackNow = async () => {
    setLoading(true);
    setError('');
    
    try {
      const response = await axios.get(`${API_BASE_URL}/track-now`);
      const data = response.data;
      
      if (data.success) {
        setCommits(data.commits);
        setJsonData(data.json_data);
        setStats({
          totalCommits: data.total_commits
        });
        setDataSource(data.source || 'unknown');
      } else {
        setError('Failed to retrieve data');
      }
    } catch (err) {
      setError('Error connecting to server');
      console.error('Error:', err);
    } finally {
      setLoading(false);
    }
  };

  const fetchCommits = async () => {
    try {
      const response = await axios.post(`${API_BASE_URL}/fetch-commits`);
      if (response.data.success) {
        // Refresh data after fetching new commits
        await trackNow();
      }
    } catch (err) {
      setError('Error fetching commits');
      console.error('Error:', err);
    }
  };

  useEffect(() => {
    // Auto-refresh every 30 seconds
    const interval = setInterval(trackNow, 30000);
    return () => clearInterval(interval);
  }, []);

  const formatDateTime = (dateString) => {
    if (!dateString) return 'Never';
    try {
      const date = new Date(dateString);
      // Check if the date is valid
      if (isNaN(date.getTime())) {
        return 'Invalid Date';
      }
      // Format with local timezone (IST)
      const localTime = date.toLocaleString('en-US', {
        year: 'numeric',
        month: 'short',
        day: 'numeric',
        hour: '2-digit',
        minute: '2-digit',
        second: '2-digit',
        timeZoneName: 'short'
      });
      
      return localTime;
    } catch (error) {
      console.error('Error formatting date:', error);
      return 'Invalid Date';
    }
  };

  const getSentimentColor = (sentiment) => {
    switch (sentiment) {
      case 'positive': return '#4CAF50';
      case 'negative': return '#F44336';
      default: return '#FF9800';
    }
  };

  const getPriorityColor = (priority) => {
    switch (priority) {
      case 'high': return '#F44336';
      case 'medium': return '#FF9800';
      default: return '#4CAF50';
    }
  };

  return (
    <div className="App">
      <header className="App-header">
        <h1>🚀 GitHub Commit Tracker</h1>
        <p>AI-Powered Commit Analysis with Microservices</p>
      </header>

      <main className="App-main">
        {/* Control Section */}
        <section className="control-section">
          <button 
            className="track-btn"
            onClick={trackNow}
            disabled={loading}
          >
            {loading ? '🔄 Fetching...' : '🚀 Track Now'}
          </button>
          
          <button 
            className="fetch-btn"
            onClick={fetchCommits}
            disabled={loading}
          >
            📥 Fetch New Commits
          </button>
        </section>

        {/* Error Display */}
        {error && (
          <div className="error-message">
            ❌ {error}
          </div>
        )}

        {/* Statistics */}
        <section className="stats-section">
          <div className="stats-grid">
            <div className="stat-card">
              <h3>Total Commits</h3>
              <p>{stats.totalCommits || 0}</p>
            </div>
            <div className="stat-card">
              <h3>AI Processed</h3>
              <p>{stats.totalCommits || 0}</p>
            </div>

            <div className="stat-card">
              <h3>Data Source</h3>
              <p style={{ 
                color: dataSource === 'database' ? '#4CAF50' : 
                       dataSource.includes('fallback') ? '#FF9800' : '#666'
              }}>
                {dataSource || 'Unknown'}
              </p>
            </div>
          </div>
        </section>

        {/* Commits List */}
        <section className="commits-section">
          <h2>Recent Commits</h2>
          {commits.length === 0 ? (
            <p className="no-commits">No commits found. Click "Track Now" to fetch data.</p>
          ) : (
            <div className="commits-grid">
              {commits.map((commit, index) => (
                <div key={commit.hash_key || index} className="commit-card">
                  <div className="commit-header">
                    <h3>{commit.message}</h3>
                    <div className="commit-identifiers">
                      <span className="commit-sha">SHA: {commit.commit_sha?.substring(0, 8)}</span>
                      <span className="hash-key">Hash: {commit.hash_key?.substring(0, 16)}...</span>
                    </div>
                  </div>
                  
                  <div className="commit-details">
                    <p><strong>Author:</strong> {commit.author}</p>
                    <p><strong>Repository:</strong> {commit.repository}</p>
                    <p><strong>Date:</strong> {formatDateTime(commit.committed_at)}</p>
                    <p><strong>Unique Hash:</strong> <code className="full-hash">{commit.hash_key}</code></p>
                  </div>

                  {commit.ai_analysis && (
                    <div className="ai-analysis">
                      <h4>🤖 AI Analysis</h4>
                      <div className="analysis-grid">
                        <div className="analysis-item">
                          <span className="label">Sentiment:</span>
                          <span 
                            className="value"
                            style={{ color: getSentimentColor(commit.ai_analysis.sentiment_label) }}
                          >
                            {commit.ai_analysis.sentiment_label}
                          </span>
                        </div>
                        <div className="analysis-item">
                          <span className="label">Priority:</span>
                          <span 
                            className="value"
                            style={{ color: getPriorityColor(commit.ai_analysis.priority) }}
                          >
                            {commit.ai_analysis.priority}
                          </span>
                        </div>
                        <div className="analysis-item">
                          <span className="label">Confidence:</span>
                          <span className="value">
                            {Math.round((commit.ai_analysis.confidence_score || 0) * 100)}%
                          </span>
                        </div>
                      </div>
                      
                      {commit.ai_analysis.categories && commit.ai_analysis.categories.length > 0 && (
                        <div className="categories">
                          <span className="label">Categories:</span>
                          {commit.ai_analysis.categories.map((cat, idx) => (
                            <span key={idx} className="category-tag">{cat}</span>
                          ))}
                        </div>
                      )}
                      
                      {commit.ai_analysis.insights && commit.ai_analysis.insights.length > 0 && (
                        <div className="insights">
                          <span className="label">Insights:</span>
                          <ul>
                            {commit.ai_analysis.insights.map((insight, idx) => (
                              <li key={idx}>{insight}</li>
                            ))}
                          </ul>
                        </div>
                      )}
                    </div>
                  )}

                  {/* Commit Files Section */}
                  {commit.files && commit.files.length > 0 && (
                    <div className="commit-files">
                      <h4>📁 Files Changed ({commit.files.length})</h4>
                      <div className="files-grid">
                        {commit.files.slice(0, 5).map((file, idx) => (
                          <div key={idx} className="file-item">
                            <span className="file-name">{file.file_path || file.filename}</span>
                            <span className={`change-type ${file.change_type || file.status}`}>
                              {file.change_type || file.status}
                            </span>
                            {(file.additions || file.deletions) && (
                              <span className="file-stats">
                                +{file.additions || 0} -{file.deletions || 0}
                              </span>
                            )}
                          </div>
                        ))}
                        {commit.files.length > 5 && (
                          <div className="more-files">
                            +{commit.files.length - 5} more files
                          </div>
                        )}
                      </div>
                    </div>
                  )}
                </div>
              ))}
            </div>
          )}
        </section>

        {/* JSON Data Toggle */}
        <section className="json-section">
          <button 
            className="toggle-json-btn"
            onClick={() => setShowJson(!showJson)}
          >
            {showJson ? '📄 Hide JSON' : '📄 Show JSON'}
          </button>
          
          {showJson && (
            <pre className="json-data">
              {JSON.stringify(jsonData, null, 2)}
            </pre>
          )}
        </section>
      </main>

      <footer className="App-footer">
        <p>GitHub Commit Tracker - Microservices Architecture with AI Analysis</p>
      </footer>
    </div>
  );
}

export default App;
