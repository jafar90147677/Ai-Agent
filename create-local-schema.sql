-- Create track_project schema
CREATE SCHEMA IF NOT EXISTS track_project;

-- Create commits table
CREATE TABLE IF NOT EXISTS track_project.commits (
    id SERIAL PRIMARY KEY,
    hash_key VARCHAR(255) UNIQUE NOT NULL,
    commit_sha VARCHAR(255) NOT NULL,
    message TEXT,
    author VARCHAR(255),
    repository VARCHAR(255),
    committed_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create commit_files table
CREATE TABLE IF NOT EXISTS track_project.commit_files (
    id SERIAL PRIMARY KEY,
    commit_id INTEGER REFERENCES track_project.commits(id) ON DELETE CASCADE,
    filename VARCHAR(500),
    status VARCHAR(50),
    additions INTEGER,
    deletions INTEGER,
    changes INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create ai_analysis table
CREATE TABLE IF NOT EXISTS track_project.ai_analysis (
    id SERIAL PRIMARY KEY,
    commit_id INTEGER REFERENCES track_project.commits(id) ON DELETE CASCADE,
    analysis_type VARCHAR(100),
    analysis_data JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create tracking_config table
CREATE TABLE IF NOT EXISTS track_project.tracking_config (
    id SERIAL PRIMARY KEY,
    repository VARCHAR(255) UNIQUE,
    last_commit_sha VARCHAR(255),
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
