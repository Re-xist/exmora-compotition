package com.examora.model;

import java.time.LocalDateTime;

/**
 * AuditLog Model - Represents an audit log entry
 */
public class AuditLog {
    private Integer id;
    private String actionType; // CREATE, UPDATE, DELETE, LOGIN, LOGOUT
    private String entityType; // USER, QUIZ, QUESTION, ATTENDANCE, ARENA
    private Integer entityId;
    private String entityName;
    private String actionData; // JSON data
    private Integer userId;
    private String userName;
    private String ipAddress;
    private String userAgent;
    private String status; // SUCCESS, FAILED
    private String errorMessage;
    private LocalDateTime createdAt;

    // Constructors
    public AuditLog() {}

    public AuditLog(String actionType, String entityType, Integer entityId, String entityName,
                    Integer userId, String userName) {
        this.actionType = actionType;
        this.entityType = entityType;
        this.entityId = entityId;
        this.entityName = entityName;
        this.userId = userId;
        this.userName = userName;
        this.status = "SUCCESS";
    }

    // Getters and Setters
    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public String getActionType() {
        return actionType;
    }

    public void setActionType(String actionType) {
        this.actionType = actionType;
    }

    public String getEntityType() {
        return entityType;
    }

    public void setEntityType(String entityType) {
        this.entityType = entityType;
    }

    public Integer getEntityId() {
        return entityId;
    }

    public void setEntityId(Integer entityId) {
        this.entityId = entityId;
    }

    public String getEntityName() {
        return entityName;
    }

    public void setEntityName(String entityName) {
        this.entityName = entityName;
    }

    public String getActionData() {
        return actionData;
    }

    public void setActionData(String actionData) {
        this.actionData = actionData;
    }

    public Integer getUserId() {
        return userId;
    }

    public void setUserId(Integer userId) {
        this.userId = userId;
    }

    public String getUserName() {
        return userName;
    }

    public void setUserName(String userName) {
        this.userName = userName;
    }

    public String getIpAddress() {
        return ipAddress;
    }

    public void setIpAddress(String ipAddress) {
        this.ipAddress = ipAddress;
    }

    public String getUserAgent() {
        return userAgent;
    }

    public void setUserAgent(String userAgent) {
        this.userAgent = userAgent;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getErrorMessage() {
        return errorMessage;
    }

    public void setErrorMessage(String errorMessage) {
        this.errorMessage = errorMessage;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    // Helper method to get action type badge class
    public String getActionBadgeClass() {
        switch (actionType) {
            case "CREATE": return "bg-success";
            case "UPDATE": return "bg-primary";
            case "DELETE": return "bg-danger";
            case "LOGIN": return "bg-info";
            case "LOGOUT": return "bg-secondary";
            default: return "bg-secondary";
        }
    }

    @Override
    public String toString() {
        return "AuditLog{" +
                "id=" + id +
                ", actionType='" + actionType + '\'' +
                ", entityType='" + entityType + '\'' +
                ", entityId=" + entityId +
                ", userName='" + userName + '\'' +
                '}';
    }
}
