package com.examora.dao;

import com.examora.model.AuditLog;
import com.examora.util.DBUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * AuditDAO - Database operations for audit logs
 */
public class AuditDAO {

    /**
     * Create a new audit log entry
     */
    public AuditLog create(AuditLog log) throws SQLException {
        String sql = "INSERT INTO audit_log (action_type, entity_type, entity_id, entity_name, " +
                     "action_data, user_id, user_name, ip_address, user_agent, status, error_message) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            stmt.setString(1, log.getActionType());
            stmt.setString(2, log.getEntityType());
            if (log.getEntityId() != null) {
                stmt.setInt(3, log.getEntityId());
            } else {
                stmt.setNull(3, Types.INTEGER);
            }
            stmt.setString(4, log.getEntityName());
            stmt.setString(5, log.getActionData());
            stmt.setInt(6, log.getUserId());
            stmt.setString(7, log.getUserName());
            stmt.setString(8, log.getIpAddress());
            stmt.setString(9, log.getUserAgent());
            stmt.setString(10, log.getStatus() != null ? log.getStatus() : "SUCCESS");
            stmt.setString(11, log.getErrorMessage());

            int affectedRows = stmt.executeUpdate();

            if (affectedRows == 0) {
                throw new SQLException("Creating audit log failed, no rows affected.");
            }

            try (ResultSet generatedKeys = stmt.getGeneratedKeys()) {
                if (generatedKeys.next()) {
                    log.setId(generatedKeys.getInt(1));
                }
            }

            return log;
        }
    }

    /**
     * Find audit log by ID
     */
    public AuditLog findById(Integer id) throws SQLException {
        String sql = "SELECT * FROM audit_log WHERE id = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, id);

            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToAuditLog(rs);
                }
            }
        }
        return null;
    }

    /**
     * Find all audit logs with pagination
     */
    public List<AuditLog> findAll(int limit, int offset) throws SQLException {
        String sql = "SELECT * FROM audit_log ORDER BY created_at DESC LIMIT ? OFFSET ?";
        List<AuditLog> logs = new ArrayList<>();

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, limit);
            stmt.setInt(2, offset);

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    logs.add(mapResultSetToAuditLog(rs));
                }
            }
        }
        return logs;
    }

    /**
     * Find audit logs by user ID
     */
    public List<AuditLog> findByUserId(Integer userId, int limit) throws SQLException {
        String sql = "SELECT * FROM audit_log WHERE user_id = ? ORDER BY created_at DESC LIMIT ?";
        List<AuditLog> logs = new ArrayList<>();

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, userId);
            stmt.setInt(2, limit);

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    logs.add(mapResultSetToAuditLog(rs));
                }
            }
        }
        return logs;
    }

    /**
     * Find audit logs by entity
     */
    public List<AuditLog> findByEntity(String entityType, Integer entityId) throws SQLException {
        String sql = "SELECT * FROM audit_log WHERE entity_type = ? AND entity_id = ? ORDER BY created_at DESC";
        List<AuditLog> logs = new ArrayList<>();

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, entityType);
            stmt.setInt(2, entityId);

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    logs.add(mapResultSetToAuditLog(rs));
                }
            }
        }
        return logs;
    }

    /**
     * Find audit logs by action type
     */
    public List<AuditLog> findByActionType(String actionType, int limit) throws SQLException {
        String sql = "SELECT * FROM audit_log WHERE action_type = ? ORDER BY created_at DESC LIMIT ?";
        List<AuditLog> logs = new ArrayList<>();

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, actionType);
            stmt.setInt(2, limit);

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    logs.add(mapResultSetToAuditLog(rs));
                }
            }
        }
        return logs;
    }

    /**
     * Find audit logs with filters
     */
    public List<AuditLog> findWithFilters(String actionType, String entityType, String status,
                                           Timestamp startDate, Timestamp endDate, int limit, int offset) throws SQLException {
        StringBuilder sql = new StringBuilder("SELECT * FROM audit_log WHERE 1=1");
        List<Object> params = new ArrayList<>();

        if (actionType != null && !actionType.isEmpty()) {
            sql.append(" AND action_type = ?");
            params.add(actionType);
        }
        if (entityType != null && !entityType.isEmpty()) {
            sql.append(" AND entity_type = ?");
            params.add(entityType);
        }
        if (status != null && !status.isEmpty()) {
            sql.append(" AND status = ?");
            params.add(status);
        }
        if (startDate != null) {
            sql.append(" AND created_at >= ?");
            params.add(startDate);
        }
        if (endDate != null) {
            sql.append(" AND created_at <= ?");
            params.add(endDate);
        }

        sql.append(" ORDER BY created_at DESC LIMIT ? OFFSET ?");
        params.add(limit);
        params.add(offset);

        List<AuditLog> logs = new ArrayList<>();

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) {
                stmt.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    logs.add(mapResultSetToAuditLog(rs));
                }
            }
        }
        return logs;
    }

    /**
     * Count all audit logs
     */
    public int countAll() throws SQLException {
        String sql = "SELECT COUNT(*) FROM audit_log";

        try (Connection conn = DBUtil.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {

            if (rs.next()) {
                return rs.getInt(1);
            }
        }
        return 0;
    }

    /**
     * Count audit logs with filters
     */
    public int countWithFilters(String actionType, String entityType, String status,
                                 Timestamp startDate, Timestamp endDate) throws SQLException {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM audit_log WHERE 1=1");
        List<Object> params = new ArrayList<>();

        if (actionType != null && !actionType.isEmpty()) {
            sql.append(" AND action_type = ?");
            params.add(actionType);
        }
        if (entityType != null && !entityType.isEmpty()) {
            sql.append(" AND entity_type = ?");
            params.add(entityType);
        }
        if (status != null && !status.isEmpty()) {
            sql.append(" AND status = ?");
            params.add(status);
        }
        if (startDate != null) {
            sql.append(" AND created_at >= ?");
            params.add(startDate);
        }
        if (endDate != null) {
            sql.append(" AND created_at <= ?");
            params.add(endDate);
        }

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) {
                stmt.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }
        return 0;
    }

    /**
     * Delete old audit logs (cleanup)
     */
    public int deleteOldLogs(int daysToKeep) throws SQLException {
        String sql = "DELETE FROM audit_log WHERE created_at < DATE_SUB(NOW(), INTERVAL ? DAY)";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, daysToKeep);
            return stmt.executeUpdate();
        }
    }

    /**
     * Map ResultSet to AuditLog object
     */
    private AuditLog mapResultSetToAuditLog(ResultSet rs) throws SQLException {
        AuditLog log = new AuditLog();
        log.setId(rs.getInt("id"));
        log.setActionType(rs.getString("action_type"));
        log.setEntityType(rs.getString("entity_type"));

        int entityId = rs.getInt("entity_id");
        if (!rs.wasNull()) {
            log.setEntityId(entityId);
        }

        log.setEntityName(rs.getString("entity_name"));
        log.setActionData(rs.getString("action_data"));
        log.setUserId(rs.getInt("user_id"));
        log.setUserName(rs.getString("user_name"));
        log.setIpAddress(rs.getString("ip_address"));
        log.setUserAgent(rs.getString("user_agent"));
        log.setStatus(rs.getString("status"));
        log.setErrorMessage(rs.getString("error_message"));

        Timestamp createdAt = rs.getTimestamp("created_at");
        if (createdAt != null) {
            log.setCreatedAt(createdAt.toLocalDateTime());
        }

        return log;
    }
}
