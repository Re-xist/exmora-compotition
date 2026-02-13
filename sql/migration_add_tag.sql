-- Migration: Add tag and photo columns to users table
-- Run this if you already have existing data

ALTER TABLE users ADD COLUMN tag VARCHAR(50) DEFAULT NULL COMMENT 'Tag/kelompok untuk user' AFTER role;
ALTER TABLE users ADD INDEX idx_tag (tag);

ALTER TABLE users ADD COLUMN photo VARCHAR(255) DEFAULT NULL COMMENT 'Profile photo path' AFTER tag;
