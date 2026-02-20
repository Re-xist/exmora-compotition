package com.examora.service;

import com.examora.dao.AuditDAO;
import com.examora.model.AuditLog;
import com.examora.model.User;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import jakarta.servlet.http.HttpServletRequest;

import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * AuditService - Business logic for audit logging
 */
public class AuditService {
    private AuditDAO auditDAO;
    private static final Gson gson = new GsonBuilder().create();

    public AuditService() {
        this.auditDAO = new AuditDAO();
    }

    /**
     * Log an action
     */
    public void log(String actionType, String entityType, Integer entityId, String entityName,
                    User user, HttpServletRequest request) {
        log(actionType, entityType, entityId, entityName, null, user, request, "SUCCESS", null);
    }

    /**
     * Log an action with data
     */
    public void log(String actionType, String entityType, Integer entityId, String entityName,
                    Map<String, Object> actionData, User user, HttpServletRequest request) {
        log(actionType, entityType, entityId, entityName, actionData, user, request, "SUCCESS", null);
    }

    /**
     * Log an action with full details
     */
    public void log(String actionType, String entityType, Integer entityId, String entityName,
                    Map<String, Object> actionData, User user, HttpServletRequest request,
                    String status, String errorMessage) {
        try {
            AuditLog log = new AuditLog(actionType, entityType, entityId, entityName,
                    user.getId(), user.getName());

            if (actionData != null && !actionData.isEmpty()) {
                log.setActionData(gson.toJson(actionData));
            }

            if (request != null) {
                log.setIpAddress(getClientIpAddress(request));
                log.setUserAgent(truncate(request.getHeader("User-Agent"), 255));
            }

            log.setStatus(status);
            log.setErrorMessage(errorMessage);

            auditDAO.create(log);
        } catch (SQLException e) {
            // Don't throw exception - audit logging should not break the main flow
            System.err.println("Failed to create audit log: " + e.getMessage());
        }
    }

    /**
     * Log CREATE action
     */
    public void logCreate(String entityType, Integer entityId, String entityName,
                          Map<String, Object> data, User user, HttpServletRequest request) {
        log("CREATE", entityType, entityId, entityName, data, user, request);
    }

    /**
     * Log UPDATE action
     */
    public void logUpdate(String entityType, Integer entityId, String entityName,
                          Map<String, Object> changes, User user, HttpServletRequest request) {
        log("UPDATE", entityType, entityId, entityName, changes, user, request);
    }

    /**
     * Log DELETE action
     */
    public void logDelete(String entityType, Integer entityId, String entityName,
                          User user, HttpServletRequest request) {
        log("DELETE", entityType, entityId, entityName, null, user, request);
    }

    /**
     * Log LOGIN action
     */
    public void logLogin(User user, HttpServletRequest request, boolean success, String errorMessage) {
        log("LOGIN", "USER", user.getId(), user.getEmail(), null, user, request,
                success ? "SUCCESS" : "FAILED", errorMessage);
    }

    /**
     * Log LOGOUT action
     */
    public void logLogout(User user, HttpServletRequest request) {
        log("LOGOUT", "USER", user.getId(), user.getEmail(), null, user, request);
    }

    /**
     * Get all audit logs with pagination
     */
    public List<AuditLog> getAllLogs(int page, int pageSize) throws ServiceException {
        try {
            int offset = (page - 1) * pageSize;
            return auditDAO.findAll(pageSize, offset);
        } catch (SQLException e) {
            throw new ServiceException("Gagal mengambil audit logs: " + e.getMessage(), e);
        }
    }

    /**
     * Get audit logs with filters
     */
    public List<AuditLog> getFilteredLogs(String actionType, String entityType, String status,
                                           LocalDateTime startDate, LocalDateTime endDate,
                                           int page, int pageSize) throws ServiceException {
        try {
            int offset = (page - 1) * pageSize;
            Timestamp startTs = startDate != null ? Timestamp.valueOf(startDate) : null;
            Timestamp endTs = endDate != null ? Timestamp.valueOf(endDate) : null;
            return auditDAO.findWithFilters(actionType, entityType, status, startTs, endTs, pageSize, offset);
        } catch (SQLException e) {
            throw new ServiceException("Gagal mengambil audit logs: " + e.getMessage(), e);
        }
    }

    /**
     * Get audit logs for a specific user
     */
    public List<AuditLog> getUserLogs(Integer userId, int limit) throws ServiceException {
        try {
            return auditDAO.findByUserId(userId, limit);
        } catch (SQLException e) {
            throw new ServiceException("Gagal mengambil audit logs: " + e.getMessage(), e);
        }
    }

    /**
     * Get audit logs for a specific entity
     */
    public List<AuditLog> getEntityLogs(String entityType, Integer entityId) throws ServiceException {
        try {
            return auditDAO.findByEntity(entityType, entityId);
        } catch (SQLException e) {
            throw new ServiceException("Gagal mengambil audit logs: " + e.getMessage(), e);
        }
    }

    /**
     * Count total logs
     */
    public int countAllLogs() throws ServiceException {
        try {
            return auditDAO.countAll();
        } catch (SQLException e) {
            throw new ServiceException("Gagal menghitung audit logs: " + e.getMessage(), e);
        }
    }

    /**
     * Count filtered logs
     */
    public int countFilteredLogs(String actionType, String entityType, String status,
                                  LocalDateTime startDate, LocalDateTime endDate) throws ServiceException {
        try {
            Timestamp startTs = startDate != null ? Timestamp.valueOf(startDate) : null;
            Timestamp endTs = endDate != null ? Timestamp.valueOf(endDate) : null;
            return auditDAO.countWithFilters(actionType, entityType, status, startTs, endTs);
        } catch (SQLException e) {
            throw new ServiceException("Gagal menghitung audit logs: " + e.getMessage(), e);
        }
    }

    /**
     * Clean up old logs
     */
    public int cleanupOldLogs(int daysToKeep) throws ServiceException {
        try {
            return auditDAO.deleteOldLogs(daysToKeep);
        } catch (SQLException e) {
            throw new ServiceException("Gagal menghapus log lama: " + e.getMessage(), e);
        }
    }

    /**
     * Get client IP address from request
     */
    private String getClientIpAddress(HttpServletRequest request) {
        String ip = request.getHeader("X-Forwarded-For");
        if (ip == null || ip.isEmpty() || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getHeader("Proxy-Client-IP");
        }
        if (ip == null || ip.isEmpty() || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getHeader("WL-Proxy-Client-IP");
        }
        if (ip == null || ip.isEmpty() || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getRemoteAddr();
        }
        // Handle multiple IPs in X-Forwarded-For
        if (ip != null && ip.contains(",")) {
            ip = ip.split(",")[0].trim();
        }
        return truncate(ip, 45);
    }

    /**
     * Truncate string to specified length
     */
    private String truncate(String str, int maxLength) {
        if (str == null) return null;
        return str.length() > maxLength ? str.substring(0, maxLength) : str;
    }

    /**
     * Helper method to create change map
     */
    public static Map<String, Object> createChangeMap(String field, Object oldValue, Object newValue) {
        Map<String, Object> map = new HashMap<>();
        map.put("field", field);
        map.put("oldValue", oldValue);
        map.put("newValue", newValue);
        return map;
    }

    /**
     * Service Exception
     */
    public static class ServiceException extends Exception {
        public ServiceException(String message) {
            super(message);
        }

        public ServiceException(String message, Throwable cause) {
            super(message, cause);
        }
    }
}
