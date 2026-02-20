package com.examora.model;

import java.time.LocalDateTime;

/**
 * QuestionCategory Model - Represents a category for question bank
 */
public class QuestionCategory {
    private Integer id;
    private String name;
    private String description;
    private Integer createdBy;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    // Additional field for display
    private String createdByName;
    private Integer questionCount;

    // Constructors
    public QuestionCategory() {}

    public QuestionCategory(String name, String description, Integer createdBy) {
        this.name = name;
        this.description = description;
        this.createdBy = createdBy;
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

    public Integer getCreatedBy() {
        return createdBy;
    }

    public void setCreatedBy(Integer createdBy) {
        this.createdBy = createdBy;
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

    public String getCreatedByName() {
        return createdByName;
    }

    public void setCreatedByName(String createdByName) {
        this.createdByName = createdByName;
    }

    public Integer getQuestionCount() {
        return questionCount;
    }

    public void setQuestionCount(Integer questionCount) {
        this.questionCount = questionCount;
    }

    @Override
    public String toString() {
        return "QuestionCategory{" +
                "id=" + id +
                ", name='" + name + '\'' +
                ", questionCount=" + questionCount +
                '}';
    }
}
