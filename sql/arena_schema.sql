-- Examora Arena Schema
-- Real-time Competitive Quiz Feature

-- Arena Sessions (rooms)
CREATE TABLE IF NOT EXISTS arena_sessions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(10) NOT NULL UNIQUE,           -- Kode unik untuk join (AR-XXXXX)
    quiz_id INT NOT NULL,                        -- Reference ke quiz yang ada
    host_id INT NOT NULL,                        -- User yang membuat session
    status ENUM('waiting', 'active', 'paused', 'completed') DEFAULT 'waiting',
    current_question INT DEFAULT 0,              -- Index soal saat ini
    question_time INT DEFAULT 30,                -- Waktu per soal (detik)
    started_at DATETIME,
    ended_at DATETIME,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (quiz_id) REFERENCES quiz(id) ON DELETE CASCADE,
    FOREIGN KEY (host_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Arena Participants
CREATE TABLE IF NOT EXISTS arena_participants (
    id INT AUTO_INCREMENT PRIMARY KEY,
    session_id INT NOT NULL,
    user_id INT NOT NULL,
    score INT DEFAULT 0,
    joined_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    is_connected BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (session_id) REFERENCES arena_sessions(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY unique_session_user (session_id, user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Arena Answers
CREATE TABLE IF NOT EXISTS arena_answers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    session_id INT NOT NULL,
    participant_id INT NOT NULL,
    question_id INT NOT NULL,
    selected_answer CHAR(1),
    time_taken INT DEFAULT 0,                    -- Waktu untuk menjawab (ms)
    score_earned INT DEFAULT 0,
    answered_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (session_id) REFERENCES arena_sessions(id) ON DELETE CASCADE,
    FOREIGN KEY (participant_id) REFERENCES arena_participants(id) ON DELETE CASCADE,
    FOREIGN KEY (question_id) REFERENCES questions(id) ON DELETE CASCADE,
    UNIQUE KEY unique_participant_question (participant_id, question_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Index for faster lookups
CREATE INDEX idx_arena_sessions_code ON arena_sessions(code);
CREATE INDEX idx_arena_sessions_status ON arena_sessions(status);
CREATE INDEX idx_arena_participants_session ON arena_participants(session_id);
CREATE INDEX idx_arena_participants_user ON arena_participants(user_id);
CREATE INDEX idx_arena_answers_session ON arena_answers(session_id);
CREATE INDEX idx_arena_answers_participant ON arena_answers(participant_id);
