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

-- ==================== NEW FEATURES ====================

-- Question Categories Table
CREATE TABLE IF NOT EXISTS question_categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    created_by INT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_created_by (created_by)
) ENGINE=InnoDB;

-- Add columns to questions table for bank functionality
ALTER TABLE questions ADD COLUMN IF NOT EXISTS category_id INT DEFAULT NULL;
ALTER TABLE questions ADD COLUMN IF NOT EXISTS is_bank_question BOOLEAN DEFAULT FALSE;
ALTER TABLE questions MODIFY quiz_id INT DEFAULT NULL;

-- Quiz Questions Junction Table (many-to-many relationship)
CREATE TABLE IF NOT EXISTS quiz_questions (
    quiz_id INT NOT NULL,
    question_id INT NOT NULL,
    question_order INT DEFAULT 0,
    PRIMARY KEY (quiz_id, question_id),
    FOREIGN KEY (quiz_id) REFERENCES quiz(id) ON DELETE CASCADE,
    FOREIGN KEY (question_id) REFERENCES questions(id) ON DELETE CASCADE,
    INDEX idx_question_order (question_order)
) ENGINE=InnoDB;

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

-- Achievements Table
CREATE TABLE IF NOT EXISTS achievements (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    icon VARCHAR(50) NOT NULL DEFAULT 'bi-trophy',
    color VARCHAR(20) NOT NULL DEFAULT 'bg-warning',
    category ENUM('score', 'speed', 'quantity', 'special') NOT NULL,
    condition_type VARCHAR(50) NOT NULL COMMENT 'PERFECT_SCORE, EXCELLENT_SCORE, QUICK_TIME, QUIZ_COUNT, FIRST_QUIZ',
    condition_value INT NOT NULL,
    points INT DEFAULT 10,
    is_active BOOLEAN DEFAULT TRUE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_category (category),
    INDEX idx_condition_type (condition_type),
    INDEX idx_is_active (is_active)
) ENGINE=InnoDB;

-- User Achievements Table
CREATE TABLE IF NOT EXISTS user_achievements (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    achievement_id INT NOT NULL,
    earned_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY unique_user_achievement (user_id, achievement_id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (achievement_id) REFERENCES achievements(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_earned_at (earned_at)
) ENGINE=InnoDB;

-- Add columns to users table for statistics
ALTER TABLE users ADD COLUMN IF NOT EXISTS total_points INT DEFAULT 0;
ALTER TABLE users ADD COLUMN IF NOT EXISTS total_quizzes INT DEFAULT 0;
ALTER TABLE users ADD COLUMN IF NOT EXISTS perfect_scores INT DEFAULT 0;

-- Notification Templates Table
CREATE TABLE IF NOT EXISTS notification_templates (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    subject VARCHAR(255) NOT NULL,
    body TEXT NOT NULL,
    type ENUM('new_quiz', 'deadline_reminder', 'result', 'achievement', 'general') NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_type (type),
    INDEX idx_is_active (is_active)
) ENGINE=InnoDB;

-- Notification Queue Table
CREATE TABLE IF NOT EXISTS notification_queue (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    subject VARCHAR(255) NOT NULL,
    body TEXT NOT NULL,
    status ENUM('pending', 'sent', 'failed') DEFAULT 'pending',
    error_message TEXT DEFAULT NULL,
    sent_at DATETIME DEFAULT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_status (status),
    INDEX idx_user_id (user_id),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB;

-- ==================== DEFAULT DATA ====================

-- Insert default question categories
INSERT IGNORE INTO question_categories (name, description, created_by) VALUES
('Networking', 'Pertanyaan terkait jaringan komputer dan infrastruktur jaringan', 1),
('Security', 'Pertanyaan terkait keamanan siber dan perlindungan data', 1),
('Programming', 'Pertanyaan terkait pemrograman dan pengembangan software', 1),
('Database', 'Pertanyaan terkait database dan SQL', 1),
('General IT', 'Pertanyaan umum terkait teknologi informasi', 1);

-- Insert default achievements
INSERT IGNORE INTO achievements (name, description, icon, color, category, condition_type, condition_value, points) VALUES
('Perfect Score', 'Mendapatkan nilai sempurna 100 pada quiz', 'bi-star-fill', 'bg-warning', 'score', 'PERFECT_SCORE', 100, 50),
('Excellent', 'Mendapatkan nilai >= 95 pada quiz', 'bi-trophy-fill', 'bg-success', 'score', 'EXCELLENT_SCORE', 95, 30),
('Great Score', 'Mendapatkan nilai >= 80 pada quiz', 'bi-award-fill', 'bg-info', 'score', 'GREAT_SCORE', 80, 20),
('Quick Thinker', 'Menyelesaikan quiz dalam waktu kurang dari 50% batas waktu', 'bi-lightning-fill', 'bg-primary', 'speed', 'QUICK_TIME', 50, 25),
('Speed Demon', 'Menyelesaikan quiz dalam waktu kurang dari 30% batas waktu', 'bi-rocket-takeoff-fill', 'bg-danger', 'speed', 'VERY_QUICK_TIME', 30, 40),
('First Step', 'Menyelesaikan quiz pertama', 'bi-flag-fill', 'bg-secondary', 'special', 'FIRST_QUIZ', 1, 10),
('Quiz Enthusiast', 'Menyelesaikan 5 quiz', 'bi-journal-check', 'bg-info', 'quantity', 'QUIZ_COUNT', 5, 15),
('Quiz Master', 'Menyelesaikan 10 quiz', 'bi-mortarboard-fill', 'bg-primary', 'quantity', 'QUIZ_COUNT', 10, 30),
('Quiz Veteran', 'Menyelesaikan 25 quiz', 'bi-gem', 'bg-success', 'quantity', 'QUIZ_COUNT', 25, 50),
('Quiz Legend', 'Menyelesaikan 50 quiz', 'bi-stars', 'bg-warning', 'quantity', 'QUIZ_COUNT', 50, 100),
('Perfect Streak', 'Mendapatkan 3 perfect score berturut-turut', 'bi-fire', 'bg-danger', 'special', 'PERFECT_STREAK', 3, 75);

-- Insert default notification templates
INSERT IGNORE INTO notification_templates (name, subject, body, type, is_active) VALUES
('New Quiz Available', 'Quiz Baru Tersedia: {{quiz_title}}', 'Halo {{user_name}},\n\nQuiz baru "{{quiz_title}}" telah tersedia untuk Anda.\n\nDetail Quiz:\n- Durasi: {{duration}} menit\n- Jumlah Soal: {{question_count}} soal\n- Deadline: {{deadline}}\n\nSilakan login ke Examora untuk mengerjakan quiz.\n\nTerima kasih,\nTim Examora', 'new_quiz', TRUE),
('Deadline Reminder', 'Pengingat: Quiz {{quiz_title}} akan segera berakhir', 'Halo {{user_name}},\n\nIni adalah pengingat bahwa quiz "{{quiz_title}}" akan berakhir dalam {{time_remaining}}.\n\nJika Anda belum mengerjakan quiz ini, segera login ke Examora.\n\nTerima kasih,\nTim Examora', 'deadline_reminder', TRUE),
('Quiz Result', 'Hasil Quiz: {{quiz_title}}', 'Halo {{user_name}},\n\nSelamat! Anda telah menyelesaikan quiz "{{quiz_title}}".\n\nHasil Anda:\n- Nilai: {{score}}\n- Jawaban Benar: {{correct_answers}}/{{total_questions}}\n- Waktu Pengerjaan: {{time_spent}}\n\nLogin ke Examora untuk melihat detail hasil.\n\nTerima kasih,\nTim Examora', 'result', TRUE),
('Achievement Earned', 'Selamat! Anda mendapatkan Achievement baru!', 'Halo {{user_name}},\n\nSelamat! Anda telah mendapatkan achievement baru!\n\n{{achievement_name}}\n{{achievement_description}}\n\nPoin yang didapat: +{{points}} poin\n\nTerus tingkatkan kemampuan Anda!\n\nTerima kasih,\nTim Examora', 'achievement', TRUE);
