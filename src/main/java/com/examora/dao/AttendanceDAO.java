package com.examora.dao;

import com.examora.model.AttendanceSession;
import com.examora.model.AttendanceRecord;
import com.examora.util.DBUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class AttendanceDAO {

    // Session Operations
    public boolean createSession(AttendanceSession session) throws SQLException {
        String sql = "INSERT INTO attendance_sessions (session_name, session_code, session_date, " +
                     "start_time, end_time, target_tag, created_by, status, late_threshold) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            stmt.setString(1, session.getSessionName());
            stmt.setString(2, session.getSessionCode());
            stmt.setDate(3, session.getSessionDate());
            stmt.setTime(4, session.getStartTime());
            stmt.setTime(5, session.getEndTime());
            stmt.setString(6, session.getTargetTag());
            stmt.setInt(7, session.getCreatedBy());
            stmt.setString(8, session.getStatus());
            stmt.setInt(9, session.getLateThreshold());

            int affected = stmt.executeUpdate();

            if (affected > 0) {
                ResultSet rs = stmt.getGeneratedKeys();
                if (rs.next()) {
                    session.setId(rs.getInt(1));
                }
                return true;
            }
        }
        return false;
    }

    public AttendanceSession findSessionById(int id) throws SQLException {
        String sql = "SELECT s.*, u.name as created_by_name FROM attendance_sessions s " +
                     "LEFT JOIN users u ON s.created_by = u.id WHERE s.id = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, id);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                return mapResultSetToSession(rs);
            }
        }
        return null;
    }

    public AttendanceSession findSessionByCode(String code) throws SQLException {
        String sql = "SELECT s.*, u.name as created_by_name FROM attendance_sessions s " +
                     "LEFT JOIN users u ON s.created_by = u.id WHERE s.session_code = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, code);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                return mapResultSetToSession(rs);
            }
        }
        return null;
    }

    public List<AttendanceSession> findAllSessions() throws SQLException {
        String sql = "SELECT s.*, u.name as created_by_name FROM attendance_sessions s " +
                     "LEFT JOIN users u ON s.created_by = u.id ORDER BY s.session_date DESC, s.start_time DESC";
        List<AttendanceSession> sessions = new ArrayList<>();

        try (Connection conn = DBUtil.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {

            while (rs.next()) {
                sessions.add(mapResultSetToSession(rs));
            }
        }
        return sessions;
    }

    public List<AttendanceSession> findActiveSessionsByTag(String userTag) throws SQLException {
        String sql = "SELECT s.*, u.name as created_by_name FROM attendance_sessions s " +
                     "LEFT JOIN users u ON s.created_by = u.id " +
                     "WHERE s.status = 'active' AND (s.target_tag IS NULL OR s.target_tag = '' OR s.target_tag = ?) " +
                     "ORDER BY s.session_date DESC, s.start_time DESC";
        List<AttendanceSession> sessions = new ArrayList<>();

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, userTag);
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                sessions.add(mapResultSetToSession(rs));
            }
        }
        return sessions;
    }

    public boolean updateSession(AttendanceSession session) throws SQLException {
        String sql = "UPDATE attendance_sessions SET session_name = ?, session_date = ?, " +
                     "start_time = ?, end_time = ?, target_tag = ?, late_threshold = ? WHERE id = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, session.getSessionName());
            stmt.setDate(2, session.getSessionDate());
            stmt.setTime(3, session.getStartTime());
            stmt.setTime(4, session.getEndTime());
            stmt.setString(5, session.getTargetTag());
            stmt.setInt(6, session.getLateThreshold());
            stmt.setInt(7, session.getId());

            return stmt.executeUpdate() > 0;
        }
    }

    public boolean updateSessionStatus(int sessionId, String status) throws SQLException {
        String sql = "UPDATE attendance_sessions SET status = ? WHERE id = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, status);
            stmt.setInt(2, sessionId);

            return stmt.executeUpdate() > 0;
        }
    }

    public boolean deleteSession(int sessionId) throws SQLException {
        String sql = "DELETE FROM attendance_sessions WHERE id = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, sessionId);
            return stmt.executeUpdate() > 0;
        }
    }

    // Record Operations
    public boolean createRecord(AttendanceRecord record) throws SQLException {
        String sql = "INSERT INTO attendance_records (session_id, user_id, attendance_time, status, notes) " +
                     "VALUES (?, ?, ?, ?, ?)";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            stmt.setInt(1, record.getSessionId());
            stmt.setInt(2, record.getUserId());
            stmt.setTimestamp(3, record.getAttendanceTime());
            stmt.setString(4, record.getStatus());
            stmt.setString(5, record.getNotes());

            int affected = stmt.executeUpdate();

            if (affected > 0) {
                ResultSet rs = stmt.getGeneratedKeys();
                if (rs.next()) {
                    record.setId(rs.getInt(1));
                }
                return true;
            }
        }
        return false;
    }

    public AttendanceRecord findRecordBySessionAndUser(int sessionId, int userId) throws SQLException {
        String sql = "SELECT * FROM attendance_records WHERE session_id = ? AND user_id = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, sessionId);
            stmt.setInt(2, userId);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                return mapResultSetToRecord(rs);
            }
        }
        return null;
    }

    public List<AttendanceRecord> findRecordsBySession(int sessionId) throws SQLException {
        String sql = "SELECT r.*, u.name as user_name, u.email as user_email, u.tag as user_tag, " +
                     "s.session_name FROM attendance_records r " +
                     "LEFT JOIN users u ON r.user_id = u.id " +
                     "LEFT JOIN attendance_sessions s ON r.session_id = s.id " +
                     "WHERE r.session_id = ? ORDER BY r.attendance_time ASC";
        List<AttendanceRecord> records = new ArrayList<>();

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, sessionId);
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                records.add(mapResultSetToRecord(rs));
            }
        }
        return records;
    }

    public List<AttendanceRecord> findRecordsByUser(int userId) throws SQLException {
        String sql = "SELECT r.*, s.session_name, s.session_date, s.start_time, s.end_time " +
                     "FROM attendance_records r " +
                     "LEFT JOIN attendance_sessions s ON r.session_id = s.id " +
                     "WHERE r.user_id = ? ORDER BY s.session_date DESC, s.start_time DESC";
        List<AttendanceRecord> records = new ArrayList<>();

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, userId);
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                AttendanceRecord record = new AttendanceRecord();
                record.setId(rs.getInt("id"));
                record.setSessionId(rs.getInt("session_id"));
                record.setUserId(rs.getInt("user_id"));
                record.setAttendanceTime(rs.getTimestamp("attendance_time"));
                record.setStatus(rs.getString("status"));
                record.setNotes(rs.getString("notes"));
                record.setSessionName(rs.getString("session_name"));
                records.add(record);
            }
        }
        return records;
    }

    public boolean updateRecordStatus(int recordId, String status, String notes) throws SQLException {
        String sql = "UPDATE attendance_records SET status = ?, notes = ? WHERE id = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, status);
            stmt.setString(2, notes);
            stmt.setInt(3, recordId);

            return stmt.executeUpdate() > 0;
        }
    }

    public int[] getSessionStatistics(int sessionId) throws SQLException {
        String sql = "SELECT " +
                     "COUNT(*) as total, " +
                     "SUM(CASE WHEN status = 'present' THEN 1 ELSE 0 END) as present, " +
                     "SUM(CASE WHEN status = 'late' THEN 1 ELSE 0 END) as late " +
                     "FROM attendance_records WHERE session_id = ?";
        int[] stats = new int[3]; // [present, late, total]

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, sessionId);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                stats[0] = rs.getInt("present");
                stats[1] = rs.getInt("late");
                stats[2] = rs.getInt("total");
            }
        }
        return stats;
    }

    public List<AttendanceRecord> getDetailedRecordsBySession(int sessionId) throws SQLException {
        return findRecordsBySession(sessionId);
    }

    // Helper methods
    private AttendanceSession mapResultSetToSession(ResultSet rs) throws SQLException {
        AttendanceSession session = new AttendanceSession();
        session.setId(rs.getInt("id"));
        session.setSessionName(rs.getString("session_name"));
        session.setSessionCode(rs.getString("session_code"));
        session.setSessionDate(rs.getDate("session_date"));
        session.setStartTime(rs.getTime("start_time"));
        session.setEndTime(rs.getTime("end_time"));
        session.setTargetTag(rs.getString("target_tag"));
        session.setCreatedBy(rs.getInt("created_by"));
        session.setCreatedByName(rs.getString("created_by_name"));
        session.setStatus(rs.getString("status"));
        session.setLateThreshold(rs.getInt("late_threshold"));
        return session;
    }

    private AttendanceRecord mapResultSetToRecord(ResultSet rs) throws SQLException {
        AttendanceRecord record = new AttendanceRecord();
        record.setId(rs.getInt("id"));
        record.setSessionId(rs.getInt("session_id"));
        record.setUserId(rs.getInt("user_id"));
        record.setAttendanceTime(rs.getTimestamp("attendance_time"));
        record.setStatus(rs.getString("status"));
        record.setNotes(rs.getString("notes"));

        try {
            record.setUserName(rs.getString("user_name"));
            record.setUserEmail(rs.getString("user_email"));
            record.setUserTag(rs.getString("user_tag"));
            record.setSessionName(rs.getString("session_name"));
        } catch (SQLException e) {
            // Columns may not exist in some queries
        }

        return record;
    }
}
