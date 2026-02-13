package com.examora.dao;

import com.examora.model.ArenaSession;
import com.examora.util.DBUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * ArenaSession Data Access Object - Handles database operations for arena sessions
 */
public class ArenaSessionDAO {

    /**
     * Create a new arena session
     */
    public ArenaSession create(ArenaSession session) throws SQLException {
        String sql = "INSERT INTO arena_sessions (code, quiz_id, host_id, status, current_question, " +
                     "question_time, started_at, ended_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            stmt.setString(1, session.getCode());
            stmt.setInt(2, session.getQuizId());
            stmt.setInt(3, session.getHostId());
            stmt.setString(4, session.getStatus());
            stmt.setInt(5, session.getCurrentQuestion() != null ? session.getCurrentQuestion() : 0);
            stmt.setInt(6, session.getQuestionTime() != null ? session.getQuestionTime() : 30);
            stmt.setTimestamp(7, session.getStartedAt() != null ? Timestamp.valueOf(session.getStartedAt()) : null);
            stmt.setTimestamp(8, session.getEndedAt() != null ? Timestamp.valueOf(session.getEndedAt()) : null);

            int affectedRows = stmt.executeUpdate();

            if (affectedRows == 0) {
                throw new SQLException("Creating arena session failed, no rows affected.");
            }

            try (ResultSet generatedKeys = stmt.getGeneratedKeys()) {
                if (generatedKeys.next()) {
                    session.setId(generatedKeys.getInt(1));
                } else {
                    throw new SQLException("Creating arena session failed, no ID obtained.");
                }
            }

            return session;
        }
    }

    /**
     * Find arena session by ID
     */
    public ArenaSession findById(Integer id) throws SQLException {
        String sql = "SELECT s.*, u.name as host_name, q.title as quiz_title, " +
                     "(SELECT COUNT(*) FROM arena_participants WHERE session_id = s.id) as participant_count, " +
                     "(SELECT COUNT(*) FROM questions WHERE quiz_id = s.quiz_id) as total_questions " +
                     "FROM arena_sessions s " +
                     "LEFT JOIN users u ON s.host_id = u.id " +
                     "LEFT JOIN quiz q ON s.quiz_id = q.id " +
                     "WHERE s.id = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, id);

            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToArenaSession(rs);
                }
            }
        }
        return null;
    }

    /**
     * Find arena session by code
     */
    public ArenaSession findByCode(String code) throws SQLException {
        String sql = "SELECT s.*, u.name as host_name, q.title as quiz_title, " +
                     "(SELECT COUNT(*) FROM arena_participants WHERE session_id = s.id) as participant_count, " +
                     "(SELECT COUNT(*) FROM questions WHERE quiz_id = s.quiz_id) as total_questions " +
                     "FROM arena_sessions s " +
                     "LEFT JOIN users u ON s.host_id = u.id " +
                     "LEFT JOIN quiz q ON s.quiz_id = q.id " +
                     "WHERE s.code = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, code);

            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToArenaSession(rs);
                }
            }
        }
        return null;
    }

    /**
     * Get all arena sessions
     */
    public List<ArenaSession> findAll() throws SQLException {
        String sql = "SELECT s.*, u.name as host_name, q.title as quiz_title, " +
                     "(SELECT COUNT(*) FROM arena_participants WHERE session_id = s.id) as participant_count, " +
                     "(SELECT COUNT(*) FROM questions WHERE quiz_id = s.quiz_id) as total_questions " +
                     "FROM arena_sessions s " +
                     "LEFT JOIN users u ON s.host_id = u.id " +
                     "LEFT JOIN quiz q ON s.quiz_id = q.id " +
                     "ORDER BY s.created_at DESC";
        List<ArenaSession> sessions = new ArrayList<>();

        try (Connection conn = DBUtil.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {

            while (rs.next()) {
                sessions.add(mapResultSetToArenaSession(rs));
            }
        }
        return sessions;
    }

    /**
     * Get arena sessions by host
     */
    public List<ArenaSession> findByHost(Integer hostId) throws SQLException {
        String sql = "SELECT s.*, u.name as host_name, q.title as quiz_title, " +
                     "(SELECT COUNT(*) FROM arena_participants WHERE session_id = s.id) as participant_count, " +
                     "(SELECT COUNT(*) FROM questions WHERE quiz_id = s.quiz_id) as total_questions " +
                     "FROM arena_sessions s " +
                     "LEFT JOIN users u ON s.host_id = u.id " +
                     "LEFT JOIN quiz q ON s.quiz_id = q.id " +
                     "WHERE s.host_id = ? " +
                     "ORDER BY s.created_at DESC";
        List<ArenaSession> sessions = new ArrayList<>();

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, hostId);

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    sessions.add(mapResultSetToArenaSession(rs));
                }
            }
        }
        return sessions;
    }

    /**
     * Get active arena sessions (for browsing)
     */
    public List<ArenaSession> findWaiting() throws SQLException {
        String sql = "SELECT s.*, u.name as host_name, q.title as quiz_title, " +
                     "(SELECT COUNT(*) FROM arena_participants WHERE session_id = s.id) as participant_count, " +
                     "(SELECT COUNT(*) FROM questions WHERE quiz_id = s.quiz_id) as total_questions " +
                     "FROM arena_sessions s " +
                     "LEFT JOIN users u ON s.host_id = u.id " +
                     "LEFT JOIN quiz q ON s.quiz_id = q.id " +
                     "WHERE s.status = 'waiting' " +
                     "ORDER BY s.created_at DESC";
        List<ArenaSession> sessions = new ArrayList<>();

        try (Connection conn = DBUtil.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {

            while (rs.next()) {
                sessions.add(mapResultSetToArenaSession(rs));
            }
        }
        return sessions;
    }

    /**
     * Update arena session
     */
    public boolean update(ArenaSession session) throws SQLException {
        String sql = "UPDATE arena_sessions SET status = ?, current_question = ?, " +
                     "question_time = ?, started_at = ?, ended_at = ? WHERE id = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, session.getStatus());
            stmt.setInt(2, session.getCurrentQuestion() != null ? session.getCurrentQuestion() : 0);
            stmt.setInt(3, session.getQuestionTime() != null ? session.getQuestionTime() : 30);
            stmt.setTimestamp(4, session.getStartedAt() != null ? Timestamp.valueOf(session.getStartedAt()) : null);
            stmt.setTimestamp(5, session.getEndedAt() != null ? Timestamp.valueOf(session.getEndedAt()) : null);
            stmt.setInt(6, session.getId());

            return stmt.executeUpdate() > 0;
        }
    }

    /**
     * Update session status
     */
    public boolean updateStatus(Integer id, String status) throws SQLException {
        String sql = "UPDATE arena_sessions SET status = ? WHERE id = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, status);
            stmt.setInt(2, id);

            return stmt.executeUpdate() > 0;
        }
    }

    /**
     * Start session (set status to active and set started_at)
     */
    public boolean startSession(Integer id) throws SQLException {
        String sql = "UPDATE arena_sessions SET status = 'active', started_at = NOW() WHERE id = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, id);
            return stmt.executeUpdate() > 0;
        }
    }

    /**
     * End session (set status to completed and set ended_at)
     */
    public boolean endSession(Integer id) throws SQLException {
        String sql = "UPDATE arena_sessions SET status = 'completed', ended_at = NOW() WHERE id = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, id);
            return stmt.executeUpdate() > 0;
        }
    }

    /**
     * Advance to next question
     */
    public boolean advanceQuestion(Integer id) throws SQLException {
        String sql = "UPDATE arena_sessions SET current_question = current_question + 1 WHERE id = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, id);
            return stmt.executeUpdate() > 0;
        }
    }

    /**
     * Delete arena session
     */
    public boolean delete(Integer id) throws SQLException {
        String sql = "DELETE FROM arena_sessions WHERE id = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, id);
            return stmt.executeUpdate() > 0;
        }
    }

    /**
     * Check if code exists
     */
    public boolean codeExists(String code) throws SQLException {
        String sql = "SELECT COUNT(*) FROM arena_sessions WHERE code = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, code);

            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        }
        return false;
    }

    /**
     * Map ResultSet to ArenaSession object
     */
    private ArenaSession mapResultSetToArenaSession(ResultSet rs) throws SQLException {
        ArenaSession session = new ArenaSession();
        session.setId(rs.getInt("id"));
        session.setCode(rs.getString("code"));
        session.setQuizId(rs.getInt("quiz_id"));
        session.setHostId(rs.getInt("host_id"));
        session.setHostName(rs.getString("host_name"));
        session.setQuizTitle(rs.getString("quiz_title"));
        session.setStatus(rs.getString("status"));
        session.setCurrentQuestion(rs.getInt("current_question"));
        session.setQuestionTime(rs.getInt("question_time"));

        Timestamp startedAt = rs.getTimestamp("started_at");
        if (startedAt != null) {
            session.setStartedAt(startedAt.toLocalDateTime());
        }

        Timestamp endedAt = rs.getTimestamp("ended_at");
        if (endedAt != null) {
            session.setEndedAt(endedAt.toLocalDateTime());
        }

        Timestamp createdAt = rs.getTimestamp("created_at");
        if (createdAt != null) {
            session.setCreatedAt(createdAt.toLocalDateTime());
        }

        session.setParticipantCount(rs.getInt("participant_count"));
        session.setTotalQuestions(rs.getInt("total_questions"));

        return session;
    }
}
