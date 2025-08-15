-- Database initialization script
-- This will be run when PostgreSQL container starts

-- Create database if it doesn't exist
SELECT 'CREATE DATABASE github_tracker'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'github_tracker')\gexec

-- Connect to the database
\c github_tracker;

-- Create track_project schema
CREATE SCHEMA IF NOT EXISTS track_project;

-- Set the search path to use track_project schema
SET search_path TO track_project, public;

-- Commits table in track_project schema
CREATE TABLE track_project.commits (
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

-- Commit Files table in track_project schema
CREATE TABLE track_project.commit_files (
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

-- AI Analysis results table in track_project schema
CREATE TABLE track_project.ai_analysis (
    id SERIAL PRIMARY KEY,
    commit_id INTEGER REFERENCES track_project.commits(id),
    analysis_type VARCHAR(100),
    results JSON,
    confidence_score DECIMAL(3,2),
    created_at TIMESTAMP DEFAULT NOW()
);

-- Tracking configuration table in track_project schema
CREATE TABLE track_project.tracking_config (
    id SERIAL PRIMARY KEY,
    repository VARCHAR(255) UNIQUE NOT NULL,
    enabled BOOLEAN DEFAULT TRUE,
    last_checked TIMESTAMP,
    check_interval INTEGER DEFAULT 300,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Create indexes for performance in track_project schema
CREATE INDEX idx_commits_hash_key ON track_project.commits(hash_key);
CREATE INDEX idx_commits_created_at ON track_project.commits(created_at);
CREATE INDEX idx_commits_status ON track_project.commits(event_status);
CREATE INDEX idx_commits_repository ON track_project.commits(repository);
CREATE INDEX idx_commit_files_commit_id ON track_project.commit_files(commit_id);
CREATE INDEX idx_commit_files_file_path ON track_project.commit_files(file_path);
CREATE INDEX idx_commit_files_change_type ON track_project.commit_files(change_type);
CREATE INDEX idx_ai_analysis_commit_id ON track_project.ai_analysis(commit_id);
CREATE INDEX idx_tracking_config_repository ON track_project.tracking_config(repository);

-- Insert default tracking configuration in track_project schema
INSERT INTO track_project.tracking_config (repository, enabled, check_interval) 
VALUES ('jafar90147677/Ai-Agent', TRUE, 300)
ON CONFLICT (repository) DO NOTHING;
