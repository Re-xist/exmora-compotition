package com.examora.dao;

import com.examora.model.ArenaParticipant;
import com.examora.util.DBUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * ArenaParticipant Data Access Object - Handles database operations for arena participants
 */
public class ArenaParticipantDAO {

    /**
     * Create a new participant (join session)
     */
    public ArenaParticipant create(ArenaParticipant participant) throws SQLException {
        String sql = "INSERT INTO arena_participants (session_id, user_id, score, is_connected) VALUES (?, ?, ?, ?)";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            stmt.setInt(1, participant.getSessionId());
            stmt.setInt(2, participant.getUserId());
            stmt.setInt(3, participant.getScore() != null ? participant.getScore() : 0);
            stmt.setBoolean(4, participant.getIsConnected() != null ? participant.getIsConnected() : true);

            int affectedRows = stmt.executeUpdate();

            if (affectedRows == 0) {
                throw new SQLException("Creating participant failed, no rows affected.");
            }

            try (ResultSet generatedKeys = stmt.getGeneratedKeys()) {
                if (generatedKeys.next()) {
                    participant.setId(generatedKeys.getInt(1));
                } else {
                    throw new SQLException("Creating participant failed, no ID obtained.");
                }
            }

            return participant;
        }
    }

    /**
     * Find participant by ID
     */
    public ArenaParticipant findById(Integer id) throws SQLException {
        String sql = "SELECT p.*, u.name as user_name, u.photo as user_photo " +
                     "FROM arena_participants p " +
                     "LEFT JOIN users u ON p.user_id = u.id " +
                     "WHERE p.id = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, id);

            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToArenaParticipant(rs);
                }
            }
        }
        return null;
    }

    /**
     * Find participant by session and user
     */
    public ArenaParticipant findBySessionAndUser(Integer sessionId, Integer userId) throws SQLException {
        String sql = "SELECT p.*, u.name as user_name, u.photo as user_photo " +
                     "FROM arena_participants p " +
                     "LEFT JOIN users u ON p.user_id = u.id " +
                     "WHERE p.session_id = ? AND p.user_id = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, sessionId);
            stmt.setInt(2, userId);

            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToArenaParticipant(rs);
                }
            }
        }
        return null;
    }

    /**
     * Get all participants for a session (leaderboard)
     */
    public List<ArenaParticipant> findBySession(Integer sessionId) throws SQLException {
        String sql = "SELECT p.*, u.name as user_name, u.photo as user_photo " +
                     "FROM arena_participants p " +
                     "LEFT JOIN users u ON p.user_id = u.id " +
                     "WHERE p.session_id = ? " +
                     "ORDER BY p.score DESC, p.joined_at ASC";
        List<ArenaParticipant> participants = new ArrayList<>();

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, sessionId);

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    participants.add(mapResultSetToArenaParticipant(rs));
                }
            }
        }
        return participants;
    }

    /**
     * Get leaderboard (top participants) for a session
     */
    public List<ArenaParticipant> getLeaderboard(Integer sessionId) throws SQLException {
        return findBySession(sessionId);
    }

    /**
     * Update participant score
     */
    public boolean updateScore(Integer id, Integer score) throws SQLException {
        String sql = "UPDATE arena_participants SET score = ? WHERE id = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, score);
            stmt.setInt(2, id);

            return stmt.executeUpdate() > 0;
        }
    }

    /**
     * Add score to participant (increment)
     */
    public boolean addScore(Integer id, Integer pointsToAdd) throws SQLException {
        String sql = "UPDATE arena_participants SET score = score + ? WHERE id = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, pointsToAdd);
            stmt.setInt(2, id);

            return stmt.executeUpdate() > 0;
        }
    }

    /**
     * Update connection status
     */
    public boolean updateConnectionStatus(Integer id, boolean isConnected) throws SQLException {
        String sql = "UPDATE arena_participants SET is_connected = ? WHERE id = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setBoolean(1, isConnected);
            stmt.setInt(2, id);

            return stmt.executeUpdate() > 0;
        }
    }

    /**
     * Delete participant (leave session)
     */
    public boolean delete(Integer id) throws SQLException {
        String sql = "DELETE FROM arena_participants WHERE id = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, id);
            return stmt.executeUpdate() > 0;
        }
    }

    /**
     * Delete all participants for a session
     */
    public boolean deleteBySession(Integer sessionId) throws SQLException {
        String sql = "DELETE FROM arena_participants WHERE session_id = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, sessionId);
            return stmt.executeUpdate() > 0;
        }
    }

    /**
     * Count participants in a session
     */
    public int countBySession(Integer sessionId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM arena_participants WHERE session_id = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, sessionId);

            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }
        return 0;
    }

    /**
     * Check if user is already in session
     */
    public boolean isUserInSession(Integer sessionId, Integer userId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM arena_participants WHERE session_id = ? AND user_id = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, sessionId);
            stmt.setInt(2, userId);

            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        }
        return false;
    }

    /**
     * Map ResultSet to ArenaParticipant object
     */
    private ArenaParticipant mapResultSetToArenaParticipant(ResultSet rs) throws SQLException {
        ArenaParticipant participant = new ArenaParticipant();
        participant.setId(rs.getInt("id"));
        participant.setSessionId(rs.getInt("session_id"));
        participant.setUserId(rs.getInt("user_id"));
        participant.setUserName(rs.getString("user_name"));
        participant.setUserPhoto(rs.getString("user_photo"));
        participant.setScore(rs.getInt("score"));
        participant.setIsConnected(rs.getBoolean("is_connected"));

        Timestamp joinedAt = rs.getTimestamp("joined_at");
        if (joinedAt != null) {
            participant.setJoinedAt(joinedAt.toLocalDateTime());
        }

        return participant;
    }
}
