-- Examora - Smart Assessment Platform
-- Database Schema

CREATE DATABASE IF NOT EXISTS examora_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE examora_db;

-- Users Table
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    role ENUM('admin', 'peserta') NOT NULL DEFAULT 'peserta',
    tag VARCHAR(50) DEFAULT NULL COMMENT 'Tag/kelompok untuk user (contoh: Kelas A, Divisi IT, dll)',
    photo VARCHAR(255) DEFAULT NULL COMMENT 'Profile photo path',
    gdrive_link VARCHAR(500) DEFAULT NULL COMMENT 'Google Drive link for user',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_email (email),
    INDEX idx_role (role),
    INDEX idx_tag (tag)
) ENGINE=InnoDB;

-- Quiz Table
CREATE TABLE quiz (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    duration INT NOT NULL DEFAULT 30 COMMENT 'Duration in minutes',
    is_active BOOLEAN DEFAULT FALSE,
    deadline DATETIME DEFAULT NULL COMMENT 'Deadline for taking the quiz',
    target_tag VARCHAR(50) DEFAULT NULL COMMENT 'Target tag for quiz visibility (null = all users)',
    created_by INT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_created_by (created_by),
    INDEX idx_is_active (is_active),
    INDEX idx_deadline (deadline),
    INDEX idx_target_tag (target_tag)
) ENGINE=InnoDB;

-- Questions Table
CREATE TABLE questions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    quiz_id INT NOT NULL,
    question_text TEXT NOT NULL,
    option_a TEXT NOT NULL,
    option_b TEXT NOT NULL,
    option_c TEXT NOT NULL,
    option_d TEXT NOT NULL,
    correct_answer CHAR(1) NOT NULL COMMENT 'A, B, C, or D',
    question_order INT DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (quiz_id) REFERENCES quiz(id) ON DELETE CASCADE,
    INDEX idx_quiz_id (quiz_id)
) ENGINE=InnoDB;

-- Submissions Table
CREATE TABLE submissions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    quiz_id INT NOT NULL,
    user_id INT NOT NULL,
    score DECIMAL(5,2) DEFAULT 0,
    total_questions INT DEFAULT 0,
    correct_answers INT DEFAULT 0,
    started_at DATETIME NOT NULL,
    submitted_at DATETIME DEFAULT NULL,
    time_spent INT DEFAULT 0 COMMENT 'Time spent in seconds',
    status ENUM('in_progress', 'completed', 'timeout') DEFAULT 'in_progress',
    FOREIGN KEY (quiz_id) REFERENCES quiz(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY unique_user_quiz (user_id, quiz_id),
    INDEX idx_quiz_id (quiz_id),
    INDEX idx_user_id (user_id),
    INDEX idx_status (status)
) ENGINE=InnoDB;

-- Answers Table
CREATE TABLE answers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    submission_id INT NOT NULL,
    question_id INT NOT NULL,
    selected_answer CHAR(1) COMMENT 'A, B, C, or D',
    is_correct BOOLEAN DEFAULT FALSE,
    answered_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (submission_id) REFERENCES submissions(id) ON DELETE CASCADE,
    FOREIGN KEY (question_id) REFERENCES questions(id) ON DELETE CASCADE,
    UNIQUE KEY unique_submission_question (submission_id, question_id),
    INDEX idx_submission_id (submission_id),
    INDEX idx_question_id (question_id)
) ENGINE=InnoDB;

-- Sessions Table (for tracking active quiz sessions)
CREATE TABLE quiz_sessions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    session_token VARCHAR(64) NOT NULL UNIQUE,
    quiz_id INT NOT NULL,
    user_id INT NOT NULL,
    started_at DATETIME NOT NULL,
    expires_at DATETIME NOT NULL,
    last_activity DATETIME DEFAULT CURRENT_TIMESTAMP,
    status ENUM('active', 'completed', 'expired') DEFAULT 'active',
    FOREIGN KEY (quiz_id) REFERENCES quiz(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_session_token (session_token),
    INDEX idx_expires_at (expires_at)
) ENGINE=InnoDB;

-- Insert default admin user (password: admin123)
-- Password is hashed with bcrypt
INSERT INTO users (name, email, password, role, tag) VALUES
('Administrator', 'admin@examora.com', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'admin', NULL);

-- Insert sample peserta user (password: user123)
INSERT INTO users (name, email, password, role, tag) VALUES
('Peserta Demo', 'user@examora.com', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'peserta', 'Kelas A');

-- Attendance Sessions Table
CREATE TABLE IF NOT EXISTS attendance_sessions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    session_name VARCHAR(255) NOT NULL,
    session_code VARCHAR(6) NOT NULL UNIQUE,
    session_date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    target_tag VARCHAR(50) DEFAULT NULL,
    created_by INT NOT NULL,
    status ENUM('scheduled', 'active', 'closed') DEFAULT 'scheduled',
    late_threshold INT DEFAULT 15,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_session_code (session_code),
    INDEX idx_session_date (session_date),
    INDEX idx_status (status)
) ENGINE=InnoDB;

-- Attendance Records Table
CREATE TABLE IF NOT EXISTS attendance_records (
    id INT AUTO_INCREMENT PRIMARY KEY,
    session_id INT NOT NULL,
    user_id INT NOT NULL,
    attendance_time DATETIME NOT NULL,
    status ENUM('present', 'late', 'absent') DEFAULT 'present',
    notes TEXT DEFAULT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (session_id) REFERENCES attendance_sessions(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY unique_session_user (session_id, user_id),
    INDEX idx_session_id (session_id),
    INDEX idx_user_id (user_id)
) ENGINE=InnoDB;
