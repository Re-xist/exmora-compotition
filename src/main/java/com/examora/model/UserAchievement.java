package com.examora.model;

import java.time.LocalDateTime;

/**
 * UserAchievement Model - Represents a user's earned achievement
 */
public class UserAchievement {
    private Integer id;
    private Integer userId;
    private Integer achievementId;
    private LocalDateTime earnedAt;

    // Additional fields for display
    private Achievement achievement;
    private String userName;

    // Constructors
    public UserAchievement() {}

    public UserAchievement(Integer userId, Integer achievementId) {
        this.userId = userId;
        this.achievementId = achievementId;
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

    public Integer getAchievementId() {
        return achievementId;
    }

    public void setAchievementId(Integer achievementId) {
        this.achievementId = achievementId;
    }

    public LocalDateTime getEarnedAt() {
        return earnedAt;
    }

    public void setEarnedAt(LocalDateTime earnedAt) {
        this.earnedAt = earnedAt;
    }

    public Achievement getAchievement() {
        return achievement;
    }

    public void setAchievement(Achievement achievement) {
        this.achievement = achievement;
    }

    public String getUserName() {
        return userName;
    }

    public void setUserName(String userName) {
        this.userName = userName;
    }

    @Override
    public String toString() {
        return "UserAchievement{" +
                "id=" + id +
                ", userId=" + userId +
                ", achievementId=" + achievementId +
                ", earnedAt=" + earnedAt +
                '}';
    }
}
