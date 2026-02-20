-- Examora - Email Notifications Feature
-- Migration Script

USE examora_db;

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

-- User Notification Settings (optional - for future use)
CREATE TABLE IF NOT EXISTS user_notification_settings (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    notify_new_quiz BOOLEAN DEFAULT TRUE,
    notify_deadline BOOLEAN DEFAULT TRUE,
    notify_result BOOLEAN DEFAULT TRUE,
    notify_achievement BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY unique_user_settings (user_id)
) ENGINE=InnoDB;

-- Insert default notification templates
INSERT INTO notification_templates (name, subject, body, type, is_active) VALUES
('New Quiz Available', 'Quiz Baru Tersedia: {{quiz_title}}', 'Halo {{user_name}},\n\nQuiz baru "{{quiz_title}}" telah tersedia untuk Anda.\n\nDetail Quiz:\n- Durasi: {{duration}} menit\n- Jumlah Soal: {{question_count}} soal\n- Deadline: {{deadline}}\n\nSilakan login ke Examora untuk mengerjakan quiz.\n\nTerima kasih,\nTim Examora', 'new_quiz', TRUE),
('Deadline Reminder', 'Pengingat: Quiz {{quiz_title}} akan segera berakhir', 'Halo {{user_name}},\n\nIni adalah pengingat bahwa quiz "{{quiz_title}}" akan berakhir dalam {{time_remaining}}.\n\nJika Anda belum mengerjakan quiz ini, segera login ke Examora.\n\nTerima kasih,\nTim Examora', 'deadline_reminder', TRUE),
('Quiz Result', 'Hasil Quiz: {{quiz_title}}', 'Halo {{user_name}},\n\nSelamat! Anda telah menyelesaikan quiz "{{quiz_title}}".\n\nHasil Anda:\n- Nilai: {{score}}\n- Jawaban Benar: {{correct_answers}}/{{total_questions}}\n- Waktu Pengerjaan: {{time_spent}}\n\nLogin ke Examora untuk melihat detail hasil.\n\nTerima kasih,\nTim Examora', 'result', TRUE),
('Achievement Earned', 'Selamat! Anda mendapatkan Achievement baru!', 'Halo {{user_name}},\n\nSelamat! Anda telah mendapatkan achievement baru!\n\n{{achievement_name}}\n{{achievement_description}}\n\nPoin yang didapat: +{{points}} poin\n\nTerus tingkatkan kemampuan Anda!\n\nTerima kasih,\nTim Examora', 'achievement', TRUE);
