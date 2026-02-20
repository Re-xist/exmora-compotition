-- Examora - Question Bank Feature
-- Migration Script

USE examora_db;

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
ALTER TABLE questions ADD CONSTRAINT fk_category FOREIGN KEY (category_id) REFERENCES question_categories(id) ON DELETE SET NULL;
ALTER TABLE questions ADD INDEX idx_category_id (category_id);
ALTER TABLE questions ADD INDEX idx_is_bank_question (is_bank_question);

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

-- Insert default categories
INSERT INTO question_categories (name, description, created_by) VALUES
('Networking', 'Pertanyaan terkait jaringan komputer dan infrastruktur jaringan', 1),
('Security', 'Pertanyaan terkait keamanan siber dan perlindungan data', 1),
('Programming', 'Pertanyaan terkait pemrograman dan pengembangan software', 1),
('Database', 'Pertanyaan terkait database dan SQL', 1),
('General IT', 'Pertanyaan umum terkait teknologi informasi', 1);
