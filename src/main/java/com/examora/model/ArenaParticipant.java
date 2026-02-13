package com.examora.model;

import java.time.LocalDateTime;

/**
 * ArenaParticipant Model - Represents a participant in an arena session
 */
public class ArenaParticipant {
    private Integer id;
    private Integer sessionId;
    private Integer userId;
    private String userName;               // For display purposes
    private String userPhoto;              // For display purposes
    private Integer score;
    private LocalDateTime joinedAt;
    private Boolean isConnected;

    // Constructors
    public ArenaParticipant() {
        this.score = 0;
        this.isConnected = true;
    }

    public ArenaParticipant(Integer sessionId, Integer userId) {
        this();
        this.sessionId = sessionId;
        this.userId = userId;
    }

    // Getters and Setters
    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public Integer getSessionId() {
        return sessionId;
    }

    public void setSessionId(Integer sessionId) {
        this.sessionId = sessionId;
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

    public String getUserPhoto() {
        return userPhoto;
    }

    public void setUserPhoto(String userPhoto) {
        this.userPhoto = userPhoto;
    }

    public Integer getScore() {
        return score;
    }

    public void setScore(Integer score) {
        this.score = score;
    }

    public LocalDateTime getJoinedAt() {
        return joinedAt;
    }

    public void setJoinedAt(LocalDateTime joinedAt) {
        this.joinedAt = joinedAt;
    }

    public Boolean getIsConnected() {
        return isConnected;
    }

    public void setIsConnected(Boolean isConnected) {
        this.isConnected = isConnected;
    }

    // Helper methods
    public void addScore(int points) {
        this.score = (this.score != null ? this.score : 0) + points;
    }

    @Override
    public String toString() {
        return "ArenaParticipant{" +
                "id=" + id +
                ", sessionId=" + sessionId +
                ", userId=" + userId +
                ", userName='" + userName + '\'' +
                ", score=" + score +
                ", isConnected=" + isConnected +
                '}';
    }
}
