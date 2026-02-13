package com.examora.model;

import java.time.LocalDateTime;
import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.time.format.DateTimeFormatter;

/**
 * Quiz Model - Represents a quiz/exam in the Examora system
 */
public class Quiz {
    private Integer id;
    private String title;
    private String description;
    private Integer duration; // in minutes
    private Boolean isActive;
    private Integer createdBy;
    private String createdByName; // for display purposes
    private LocalDateTime deadline; // deadline for taking the quiz
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private Integer questionCount; // for display purposes

    // Constructors
    public Quiz() {}

    public Quiz(String title, String description, Integer duration, Integer createdBy) {
        this.title = title;
        this.description = description;
        this.duration = duration;
        this.createdBy = createdBy;
        this.isActive = false;
    }

    // Getters and Setters
    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public Integer getDuration() {
        return duration;
    }

    public void setDuration(Integer duration) {
        this.duration = duration;
    }

    public Boolean getIsActive() {
        return isActive;
    }

    public void setIsActive(Boolean isActive) {
        this.isActive = isActive;
    }

    public Integer getCreatedBy() {
        return createdBy;
    }

    public void setCreatedBy(Integer createdBy) {
        this.createdBy = createdBy;
    }

    public String getCreatedByName() {
        return createdByName;
    }

    public void setCreatedByName(String createdByName) {
        this.createdByName = createdByName;
    }

    public LocalDateTime getDeadline() {
        return deadline;
    }

    public void setDeadline(LocalDateTime deadline) {
        this.deadline = deadline;
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

    public Integer getQuestionCount() {
        return questionCount;
    }

    public void setQuestionCount(Integer questionCount) {
        this.questionCount = questionCount;
    }

    // Check if quiz is expired (past deadline) using WIB timezone
    public boolean isExpired() {
        if (deadline == null) {
            return false;
        }
        // Compare using WIB (Asia/Jakarta) timezone for consistency
        ZonedDateTime now = ZonedDateTime.now(ZoneId.of("Asia/Jakarta"));
        ZonedDateTime deadlineWib = deadline.atZone(ZoneId.of("Asia/Jakarta"));
        return now.isAfter(deadlineWib);
    }

    // Check if quiz is available (active and not expired)
    public boolean isAvailable() {
        return isActive != null && isActive && !isExpired();
    }

    // Get formatted deadline for display with WIB (Jakarta time)
    public String getFormattedDeadline() {
        if (deadline == null) {
            return "Tidak ada deadline";
        }
        // Convert to WIB (Asia/Jakarta) timezone
        ZonedDateTime wibTime = deadline.atZone(ZoneId.of("Asia/Jakarta"));
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd MMM yyyy HH:mm");
        return wibTime.format(formatter) + " WIB";
    }

    // Get deadline for datetime-local input (yyyy-MM-ddTHH:mm format)
    public String getDeadlineForInput() {
        if (deadline == null) {
            return "";
        }
        return deadline.format(DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm"));
    }

    // Get formatted deadline short version (without year if same year)
    public String getFormattedDeadlineShort() {
        if (deadline == null) {
            return "-";
        }
        ZonedDateTime wibTime = deadline.atZone(ZoneId.of("Asia/Jakarta"));
        ZonedDateTime now = ZonedDateTime.now(ZoneId.of("Asia/Jakarta"));

        DateTimeFormatter formatter;
        if (wibTime.getYear() == now.getYear()) {
            formatter = DateTimeFormatter.ofPattern("dd MMM HH:mm");
        } else {
            formatter = DateTimeFormatter.ofPattern("dd MMM yy HH:mm");
        }
        return wibTime.format(formatter) + " WIB";
    }

    @Override
    public String toString() {
        return "Quiz{" +
                "id=" + id +
                ", title='" + title + '\'' +
                ", duration=" + duration +
                ", isActive=" + isActive +
                ", deadline=" + deadline +
                '}';
    }
}
