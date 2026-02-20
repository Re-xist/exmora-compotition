package com.examora.model;

import java.time.LocalDateTime;

/**
 * Achievement Model - Represents an achievement/badge
 */
public class Achievement {
    private Integer id;
    private String name;
    private String description;
    private String icon;
    private String color;
    private String category; // score, speed, quantity, special
    private String conditionType;
    private Integer conditionValue;
    private Integer points;
    private Boolean isActive;
    private LocalDateTime createdAt;

    // Constructors
    public Achievement() {}

    public Achievement(String name, String description, String icon, String color,
                       String category, String conditionType, Integer conditionValue, Integer points) {
        this.name = name;
        this.description = description;
        this.icon = icon;
        this.color = color;
        this.category = category;
        this.conditionType = conditionType;
        this.conditionValue = conditionValue;
        this.points = points;
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

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getIcon() {
        return icon;
    }

    public void setIcon(String icon) {
        this.icon = icon;
    }

    public String getColor() {
        return color;
    }

    public void setColor(String color) {
        this.color = color;
    }

    public String getCategory() {
        return category;
    }

    public void setCategory(String category) {
        this.category = category;
    }

    public String getConditionType() {
        return conditionType;
    }

    public void setConditionType(String conditionType) {
        this.conditionType = conditionType;
    }

    public Integer getConditionValue() {
        return conditionValue;
    }

    public void setConditionValue(Integer conditionValue) {
        this.conditionValue = conditionValue;
    }

    public Integer getPoints() {
        return points;
    }

    public void setPoints(Integer points) {
        this.points = points;
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

    // Helper method to get category display name
    public String getCategoryDisplayName() {
        switch (category) {
            case "score": return "Nilai";
            case "speed": return "Kecepatan";
            case "quantity": return "Kuantitas";
            case "special": return "Spesial";
            default: return category;
        }
    }

    @Override
    public String toString() {
        return "Achievement{" +
                "id=" + id +
                ", name='" + name + '\'' +
                ", category='" + category + '\'' +
                ", points=" + points +
                '}';
    }
}
