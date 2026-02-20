-- Examora - Achievements & Badges Feature
-- Migration Script

USE examora_db;

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
ALTER TABLE users ADD INDEX idx_total_points (total_points);

-- Insert default achievements
INSERT INTO achievements (name, description, icon, color, category, condition_type, condition_value, points) VALUES
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
