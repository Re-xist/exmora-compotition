-- Add gdrive_link column to users table
-- Run this SQL to update existing database

ALTER TABLE users ADD COLUMN gdrive_link VARCHAR(500) DEFAULT NULL COMMENT 'Google Drive link for user' AFTER photo;
