package com.examora.model;

import java.time.LocalDateTime;

/**
 * NotificationQueue Model - Represents a queued email notification
 */
public class NotificationQueue {
    private Integer id;
    private Integer userId;
    private String subject;
    private String body;
    private String status; // pending, sent, failed
    private String errorMessage;
    private LocalDateTime sentAt;
    private LocalDateTime createdAt;

    // Additional fields for display
    private String userName;
    private String userEmail;

    // Constructors
    public NotificationQueue() {}

    public NotificationQueue(Integer userId, String subject, String body) {
        this.userId = userId;
        this.subject = subject;
        this.body = body;
        this.status = "pending";
    }

    // Getters and Setters
    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public Integer getUserId() {
        return userId;
    }

    public void setUserId(Integer userId) {
        this.userId = userId;
    }

    public String getSubject() {
        return subject;
    }

    public void setSubject(String subject) {
        this.subject = subject;
    }

    public String getBody() {
        return body;
    }

    public void setBody(String body) {
        this.body = body;
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

    public LocalDateTime getSentAt() {
        return sentAt;
    }

    public void setSentAt(LocalDateTime sentAt) {
        this.sentAt = sentAt;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public String getUserName() {
        return userName;
    }

    public void setUserName(String userName) {
        this.userName = userName;
    }

    public String getUserEmail() {
        return userEmail;
    }

    public void setUserEmail(String userEmail) {
        this.userEmail = userEmail;
    }

    // Helper method to get status badge class
    public String getStatusBadgeClass() {
        switch (status) {
            case "pending": return "bg-warning";
            case "sent": return "bg-success";
            case "failed": return "bg-danger";
            default: return "bg-secondary";
        }
    }

    @Override
    public String toString() {
        return "NotificationQueue{" +
                "id=" + id +
                ", userId=" + userId +
                ", subject='" + subject + '\'' +
                ", status='" + status + '\'' +
                '}';
    }
}
