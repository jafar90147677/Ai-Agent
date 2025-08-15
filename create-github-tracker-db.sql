-- Create GitHub Tracker Database Schema for PostgreSQL17
-- Run this script in your new github_tracker_db database

-- Create track_project schema
CREATE SCHEMA IF NOT EXISTS track_project;

-- Set the search path to use track_project schema
SET search_path TO track_project, public;

-- Create commits table in track_project schema
CREATE TABLE IF NOT EXISTS track_project.commits (
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

-- Create commit_files table in track_project schema
CREATE TABLE IF NOT EXISTS track_project.commit_files (
    id SERIAL PRIMARY KEY,
    commit_id INTEGER REFERENCES track_project.commits(id) ON DELETE CASCADE,
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

-- Create ai_analysis table in track_project schema
CREATE TABLE IF NOT EXISTS track_project.ai_analysis (
    id SERIAL PRIMARY KEY,
    commit_id INTEGER REFERENCES track_project.commits(id) ON DELETE CASCADE,
    analysis_type VARCHAR(50),
    results JSON,
    confidence_score DECIMAL(3,2),
    created_at TIMESTAMP DEFAULT NOW()
);

-- Create tracking_config table in track_project schema
CREATE TABLE IF NOT EXISTS track_project.tracking_config (
    id SERIAL PRIMARY KEY,
    repository VARCHAR(255) NOT NULL,
    enabled BOOLEAN DEFAULT TRUE,
    last_checked TIMESTAMP,
    check_interval INTEGER DEFAULT 300, -- seconds
    created_at TIMESTAMP DEFAULT NOW()
);

-- Insert default tracking configuration in track_project schema
INSERT INTO track_project.tracking_config (repository, enabled, check_interval) 
VALUES ('jafar90147677/Ai-Agent', true, 300)
ON CONFLICT DO NOTHING;

-- Create indexes for better performance in track_project schema
CREATE INDEX IF NOT EXISTS idx_commits_hash_key ON track_project.commits(hash_key);
CREATE INDEX IF NOT EXISTS idx_commits_commit_sha ON track_project.commits(commit_sha);
CREATE INDEX IF NOT EXISTS idx_commits_created_at ON track_project.commits(created_at);
CREATE INDEX IF NOT EXISTS idx_commits_repository ON track_project.commits(repository);
CREATE INDEX IF NOT EXISTS idx_commit_files_commit_id ON track_project.commit_files(commit_id);
CREATE INDEX IF NOT EXISTS idx_ai_analysis_commit_id ON track_project.ai_analysis(commit_id);

-- Grant permissions on track_project schema (adjust as needed)
-- GRANT USAGE ON SCHEMA track_project TO your_username;
-- GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA track_project TO your_username;
-- GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA track_project TO your_username;

-- Display table creation confirmation
SELECT 'GitHub Tracker Database Schema Created Successfully in track_project schema!' as status;
