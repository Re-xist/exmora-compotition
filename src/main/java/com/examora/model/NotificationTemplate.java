package com.examora.model;

import java.time.LocalDateTime;

/**
 * NotificationTemplate Model - Represents an email notification template
 */
public class NotificationTemplate {
    private Integer id;
    private String name;
    private String subject;
    private String body;
    private String type; // new_quiz, deadline_reminder, result, achievement, general
    private Boolean isActive;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    // Constructors
    public NotificationTemplate() {}

    public NotificationTemplate(String name, String subject, String body, String type) {
        this.name = name;
        this.subject = subject;
        this.body = body;
        this.type = type;
        this.isActive = true;
    }

    // Getters and Setters
    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
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

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public Boolean getIsActive() {
        return isActive;
    }

    public void setIsActive(Boolean isActive) {
        this.isActive = isActive;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }

    // Helper method to get type display name
    public String getTypeDisplayName() {
        switch (type) {
            case "new_quiz": return "Quiz Baru";
            case "deadline_reminder": return "Pengingat Deadline";
            case "result": return "Hasil Quiz";
            case "achievement": return "Achievement";
            case "general": return "Umum";
            default: return type;
        }
    }

    @Override
    public String toString() {
        return "NotificationTemplate{" +
                "id=" + id +
                ", name='" + name + '\'' +
                ", type='" + type + '\'' +
                '}';
    }
}
