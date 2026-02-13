-- Add target_tag column to quiz table
-- Run this SQL to update existing database

ALTER TABLE quiz ADD COLUMN target_tag VARCHAR(50) DEFAULT NULL COMMENT 'Target tag for quiz visibility (null = all users)' AFTER deadline;

-- Add index for better query performance
ALTER TABLE quiz ADD INDEX idx_target_tag (target_tag);
