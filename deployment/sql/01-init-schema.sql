-- ==========================================
-- OSCAR EMR Database Initialization
-- BC-Ready Configuration
-- ==========================================

-- This file initializes the OSCAR EMR database with:
-- 1. Core schema (tables, indexes, constraints)
-- 2. BC-specific data (billing codes, pharmacies, specialists)
-- 3. Integration tables (RingCentral, OceanMD, labs)

-- Database will be created by Docker environment variables
-- USE oscar_mcmaster; -- Already selected by docker-entrypoint

-- ==========================================
-- Core OSCAR Schema
-- ==========================================
-- Note: Actual schema files are loaded via separate SQL files
-- in this directory, processed alphabetically by MySQL

-- Create schema version table for tracking
CREATE TABLE IF NOT EXISTS schema_version (
    version VARCHAR(50) PRIMARY KEY,
    applied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    description TEXT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Record initial schema version
INSERT INTO schema_version (version, description)
VALUES ('1.0.0', 'Initial OSCAR EMR BC deployment with integrations')
ON DUPLICATE KEY UPDATE applied_at = CURRENT_TIMESTAMP;

-- ==========================================
-- Status Message
-- ==========================================
SELECT 'OSCAR EMR BC Database Initialization Started' AS status;
SELECT CONCAT('Database: ', DATABASE()) AS current_database;
SELECT CONCAT('Timestamp: ', NOW()) AS init_time;
