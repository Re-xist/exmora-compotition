-- Examora - Audit Log Feature
-- Migration Script

USE examora_db;

-- Audit Log Table
CREATE TABLE IF NOT EXISTS audit_log (
    id INT AUTO_INCREMENT PRIMARY KEY,
    action_type VARCHAR(50) NOT NULL COMMENT 'CREATE, UPDATE, DELETE, LOGIN, LOGOUT',
    entity_type VARCHAR(50) NOT NULL COMMENT 'USER, QUIZ, QUESTION, ATTENDANCE, ARENA',
    entity_id INT DEFAULT 0,
    entity_name VARCHAR(255) DEFAULT NULL,
    action_data TEXT COMMENT 'JSON data of changes',
    user_id INT NOT NULL,
    user_name VARCHAR(100) NOT NULL,
    ip_address VARCHAR(45),
    user_agent VARCHAR(255),
    status VARCHAR(20) DEFAULT 'SUCCESS' COMMENT 'SUCCESS, FAILED',
    error_message TEXT DEFAULT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_action_type (action_type),
    INDEX idx_entity (entity_type, entity_id),
    INDEX idx_user_id (user_id),
    INDEX idx_status (status),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB;
