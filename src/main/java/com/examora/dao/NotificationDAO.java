package com.examora.dao;

import com.examora.model.NotificationTemplate;
import com.examora.model.NotificationQueue;
import com.examora.util.DBUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * NotificationDAO - Database operations for notifications
 */
public class NotificationDAO {

    // ==================== Template Methods ====================

    /**
     * Create a new notification template
     */
    public NotificationTemplate createTemplate(NotificationTemplate template) throws SQLException {
        String sql = "INSERT INTO notification_templates (name, subject, body, type, is_active) " +
                     "VALUES (?, ?, ?, ?, ?)";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            stmt.setString(1, template.getName());
            stmt.setString(2, template.getSubject());
            stmt.setString(3, template.getBody());
            stmt.setString(4, template.getType());
            stmt.setBoolean(5, template.getIsActive());

            int affectedRows = stmt.executeUpdate();

            if (affectedRows == 0) {
                throw new SQLException("Creating template failed, no rows affected.");
            }

            try (ResultSet generatedKeys = stmt.getGeneratedKeys()) {
                if (generatedKeys.next()) {
                    template.setId(generatedKeys.getInt(1));
                }
            }

            return template;
        }
    }

    /**
     * Find template by ID
     */
    public NotificationTemplate findTemplateById(Integer id) throws SQLException {
        String sql = "SELECT * FROM notification_templates WHERE id = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, id);

            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToTemplate(rs);
                }
            }
        }
        return null;
    }

    /**
     * Find template by type
     */
    public NotificationTemplate findTemplateByType(String type) throws SQLException {
        String sql = "SELECT * FROM notification_templates WHERE type = ? AND is_active = TRUE LIMIT 1";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, type);

            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToTemplate(rs);
                }
            }
        }
        return null;
    }

    /**
     * Find all templates
     */
    public List<NotificationTemplate> findAllTemplates() throws SQLException {
        String sql = "SELECT * FROM notification_templates ORDER BY type, name";
        List<NotificationTemplate> templates = new ArrayList<>();

        try (Connection conn = DBUtil.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {

            while (rs.next()) {
                templates.add(mapResultSetToTemplate(rs));
            }
        }
        return templates;
    }

    /**
     * Update template
     */
    public boolean updateTemplate(NotificationTemplate template) throws SQLException {
        String sql = "UPDATE notification_templates SET name = ?, subject = ?, body = ?, " +
                     "type = ?, is_active = ? WHERE id = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, template.getName());
            stmt.setString(2, template.getSubject());
            stmt.setString(3, template.getBody());
            stmt.setString(4, template.getType());
            stmt.setBoolean(5, template.getIsActive());
            stmt.setInt(6, template.getId());

            return stmt.executeUpdate() > 0;
        }
    }

    /**
     * Delete template
     */
    public boolean deleteTemplate(Integer id) throws SQLException {
        String sql = "DELETE FROM notification_templates WHERE id = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, id);
            return stmt.executeUpdate() > 0;
        }
    }

    // ==================== Queue Methods ====================

    /**
     * Add notification to queue
     */
    public NotificationQueue addToQueue(NotificationQueue notification) throws SQLException {
        String sql = "INSERT INTO notification_queue (user_id, subject, body, status) VALUES (?, ?, ?, 'pending')";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            stmt.setInt(1, notification.getUserId());
            stmt.setString(2, notification.getSubject());
            stmt.setString(3, notification.getBody());

            int affectedRows = stmt.executeUpdate();

            if (affectedRows == 0) {
                throw new SQLException("Adding to queue failed, no rows affected.");
            }

            try (ResultSet generatedKeys = stmt.getGeneratedKeys()) {
                if (generatedKeys.next()) {
                    notification.setId(generatedKeys.getInt(1));
                }
            }

            return notification;
        }
    }

    /**
     * Get pending notifications
     */
    public List<NotificationQueue> getPendingNotifications(int limit) throws SQLException {
        String sql = "SELECT nq.*, u.name as user_name, u.email as user_email " +
                     "FROM notification_queue nq " +
                     "JOIN users u ON nq.user_id = u.id " +
                     "WHERE nq.status = 'pending' " +
                     "ORDER BY nq.created_at ASC " +
                     "LIMIT ?";
        List<NotificationQueue> notifications = new ArrayList<>();

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, limit);

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    notifications.add(mapResultSetToQueue(rs));
                }
            }
        }
        return notifications;
    }

    /**
     * Update notification status
     */
    public boolean updateQueueStatus(Integer id, String status, String errorMessage) throws SQLException {
        String sql = "UPDATE notification_queue SET status = ?, error_message = ?, " +
                     "sent_at = CASE WHEN ? = 'sent' THEN NOW() ELSE sent_at END " +
                     "WHERE id = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, status);
            stmt.setString(2, errorMessage);
            stmt.setString(3, status);
            stmt.setInt(4, id);

            return stmt.executeUpdate() > 0;
        }
    }

    /**
     * Get queue with filters
     */
    public List<NotificationQueue> getQueueWithFilters(String status, int limit, int offset) throws SQLException {
        StringBuilder sql = new StringBuilder(
            "SELECT nq.*, u.name as user_name, u.email as user_email " +
            "FROM notification_queue nq " +
            "JOIN users u ON nq.user_id = u.id " +
            "WHERE 1=1");

        if (status != null && !status.isEmpty()) {
            sql.append(" AND nq.status = ?");
        }

        sql.append(" ORDER BY nq.created_at DESC LIMIT ? OFFSET ?");

        List<NotificationQueue> notifications = new ArrayList<>();

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql.toString())) {

            int paramIndex = 1;
            if (status != null && !status.isEmpty()) {
                stmt.setString(paramIndex++, status);
            }
            stmt.setInt(paramIndex++, limit);
            stmt.setInt(paramIndex, offset);

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    notifications.add(mapResultSetToQueue(rs));
                }
            }
        }
        return notifications;
    }

    /**
     * Count queue with filters
     */
    public int countQueueWithFilters(String status) throws SQLException {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM notification_queue WHERE 1=1");

        if (status != null && !status.isEmpty()) {
            sql.append(" AND status = ?");
        }

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql.toString())) {

            if (status != null && !status.isEmpty()) {
                stmt.setString(1, status);
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
     * Delete old notifications (cleanup)
     */
    public int deleteOldNotifications(int daysToKeep) throws SQLException {
        String sql = "DELETE FROM notification_queue WHERE status IN ('sent', 'failed') " +
                     "AND created_at < DATE_SUB(NOW(), INTERVAL ? DAY)";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, daysToKeep);
            return stmt.executeUpdate();
        }
    }

    /**
     * Map ResultSet to NotificationTemplate object
     */
    private NotificationTemplate mapResultSetToTemplate(ResultSet rs) throws SQLException {
        NotificationTemplate template = new NotificationTemplate();
        template.setId(rs.getInt("id"));
        template.setName(rs.getString("name"));
        template.setSubject(rs.getString("subject"));
        template.setBody(rs.getString("body"));
        template.setType(rs.getString("type"));
        template.setIsActive(rs.getBoolean("is_active"));

        Timestamp createdAt = rs.getTimestamp("created_at");
        if (createdAt != null) {
            template.setCreatedAt(createdAt.toLocalDateTime());
        }

        Timestamp updatedAt = rs.getTimestamp("updated_at");
        if (updatedAt != null) {
            template.setUpdatedAt(updatedAt.toLocalDateTime());
        }

        return template;
    }

    /**
     * Map ResultSet to NotificationQueue object
     */
    private NotificationQueue mapResultSetToQueue(ResultSet rs) throws SQLException {
        NotificationQueue queue = new NotificationQueue();
        queue.setId(rs.getInt("id"));
        queue.setUserId(rs.getInt("user_id"));
        queue.setSubject(rs.getString("subject"));
        queue.setBody(rs.getString("body"));
        queue.setStatus(rs.getString("status"));
        queue.setErrorMessage(rs.getString("error_message"));

        Timestamp sentAt = rs.getTimestamp("sent_at");
        if (sentAt != null) {
            queue.setSentAt(sentAt.toLocalDateTime());
        }

        Timestamp createdAt = rs.getTimestamp("created_at");
        if (createdAt != null) {
            queue.setCreatedAt(createdAt.toLocalDateTime());
        }

        // Additional fields
        try {
            queue.setUserName(rs.getString("user_name"));
            queue.setUserEmail(rs.getString("user_email"));
        } catch (SQLException e) {
            // Ignore if column doesn't exist
        }

        return queue;
    }
}
