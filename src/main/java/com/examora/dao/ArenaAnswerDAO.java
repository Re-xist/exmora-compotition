package com.examora.dao;

import com.examora.model.ArenaAnswer;
import com.examora.util.DBUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * ArenaAnswer Data Access Object - Handles database operations for arena answers
 */
public class ArenaAnswerDAO {

    /**
     * Create a new answer
     */
    public ArenaAnswer create(ArenaAnswer answer) throws SQLException {
        String sql = "INSERT INTO arena_answers (session_id, participant_id, question_id, " +
                     "selected_answer, time_taken, score_earned) VALUES (?, ?, ?, ?, ?, ?) " +
                     "ON DUPLICATE KEY UPDATE selected_answer = VALUES(selected_answer), " +
                     "time_taken = VALUES(time_taken), score_earned = VALUES(score_earned)";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            stmt.setInt(1, answer.getSessionId());
            stmt.setInt(2, answer.getParticipantId());
            stmt.setInt(3, answer.getQuestionId());
            stmt.setString(4, answer.getSelectedAnswer());
            stmt.setInt(5, answer.getTimeTaken() != null ? answer.getTimeTaken() : 0);
            stmt.setInt(6, answer.getScoreEarned() != null ? answer.getScoreEarned() : 0);

            int affectedRows = stmt.executeUpdate();

            if (affectedRows > 0) {
                try (ResultSet generatedKeys = stmt.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        answer.setId(generatedKeys.getInt(1));
                    }
                }
            }

            return answer;
        }
    }

    /**
     * Find answer by ID
     */
    public ArenaAnswer findById(Integer id) throws SQLException {
        String sql = "SELECT a.*, q.correct_answer, q.question_text " +
                     "FROM arena_answers a " +
                     "LEFT JOIN questions q ON a.question_id = q.id " +
                     "WHERE a.id = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, id);

            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToArenaAnswer(rs);
                }
            }
        }
        return null;
    }

    /**
     * Find answer by participant and question
     */
    public ArenaAnswer findByParticipantAndQuestion(Integer participantId, Integer questionId) throws SQLException {
        String sql = "SELECT a.*, q.correct_answer, q.question_text " +
                     "FROM arena_answers a " +
                     "LEFT JOIN questions q ON a.question_id = q.id " +
                     "WHERE a.participant_id = ? AND a.question_id = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, participantId);
            stmt.setInt(2, questionId);

            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToArenaAnswer(rs);
                }
            }
        }
        return null;
    }

    /**
     * Get all answers for a participant
     */
    public List<ArenaAnswer> findByParticipant(Integer participantId) throws SQLException {
        String sql = "SELECT a.*, q.correct_answer, q.question_text " +
                     "FROM arena_answers a " +
                     "LEFT JOIN questions q ON a.question_id = q.id " +
                     "WHERE a.participant_id = ? " +
                     "ORDER BY a.answered_at ASC";
        List<ArenaAnswer> answers = new ArrayList<>();

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, participantId);

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    answers.add(mapResultSetToArenaAnswer(rs));
                }
            }
        }
        return answers;
    }

    /**
     * Get all answers for a session
     */
    public List<ArenaAnswer> findBySession(Integer sessionId) throws SQLException {
        String sql = "SELECT a.*, q.correct_answer, q.question_text " +
                     "FROM arena_answers a " +
                     "LEFT JOIN questions q ON a.question_id = q.id " +
                     "WHERE a.session_id = ? " +
                     "ORDER BY a.answered_at ASC";
        List<ArenaAnswer> answers = new ArrayList<>();

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, sessionId);

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    answers.add(mapResultSetToArenaAnswer(rs));
                }
            }
        }
        return answers;
    }

    /**
     * Get answers for a specific question in a session (for showing results)
     */
    public List<ArenaAnswer> findBySessionAndQuestion(Integer sessionId, Integer questionId) throws SQLException {
        String sql = "SELECT a.*, q.correct_answer, q.question_text " +
                     "FROM arena_answers a " +
                     "LEFT JOIN questions q ON a.question_id = q.id " +
                     "WHERE a.session_id = ? AND a.question_id = ?";
        List<ArenaAnswer> answers = new ArrayList<>();

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, sessionId);
            stmt.setInt(2, questionId);

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    answers.add(mapResultSetToArenaAnswer(rs));
                }
            }
        }
        return answers;
    }

    /**
     * Check if participant has answered a question
     */
    public boolean hasAnswered(Integer participantId, Integer questionId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM arena_answers WHERE participant_id = ? AND question_id = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, participantId);
            stmt.setInt(2, questionId);

            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        }
        return false;
    }

    /**
     * Count correct answers for a participant
     */
    public int countCorrectByParticipant(Integer participantId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM arena_answers a " +
                     "JOIN questions q ON a.question_id = q.id " +
                     "WHERE a.participant_id = ? AND a.selected_answer = q.correct_answer";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, participantId);

            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }
        return 0;
    }

    /**
     * Count total answers for a participant
     */
    public int countByParticipant(Integer participantId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM arena_answers WHERE participant_id = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, participantId);

            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }
        return 0;
    }

    /**
     * Delete all answers for a session
     */
    public boolean deleteBySession(Integer sessionId) throws SQLException {
        String sql = "DELETE FROM arena_answers WHERE session_id = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, sessionId);
            return stmt.executeUpdate() > 0;
        }
    }

    /**
     * Map ResultSet to ArenaAnswer object
     */
    private ArenaAnswer mapResultSetToArenaAnswer(ResultSet rs) throws SQLException {
        ArenaAnswer answer = new ArenaAnswer();
        answer.setId(rs.getInt("id"));
        answer.setSessionId(rs.getInt("session_id"));
        answer.setParticipantId(rs.getInt("participant_id"));
        answer.setQuestionId(rs.getInt("question_id"));
        answer.setSelectedAnswer(rs.getString("selected_answer"));
        answer.setTimeTaken(rs.getInt("time_taken"));
        answer.setScoreEarned(rs.getInt("score_earned"));

        Timestamp answeredAt = rs.getTimestamp("answered_at");
        if (answeredAt != null) {
            answer.setAnsweredAt(answeredAt.toLocalDateTime());
        }

        // Additional fields
        answer.setCorrectAnswer(rs.getString("correct_answer"));
        answer.setQuestionText(rs.getString("question_text"));

        // Calculate if correct
        String selected = answer.getSelectedAnswer();
        String correct = answer.getCorrectAnswer();
        answer.setIsCorrect(selected != null && selected.equalsIgnoreCase(correct));

        return answer;
    }
}
