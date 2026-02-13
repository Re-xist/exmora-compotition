package com.examora.model;

import java.time.LocalDateTime;

/**
 * ArenaSession Model - Represents a competitive quiz session/room
 */
public class ArenaSession {
    private Integer id;
    private String code;                   // Unique join code (AR-XXXXX)
    private Integer quizId;
    private Integer hostId;
    private String hostName;               // For display purposes
    private String quizTitle;              // For display purposes
    private String status;                 // waiting, active, paused, completed
    private Integer currentQuestion;       // Current question index (0-based)
    private Integer questionTime;          // Time per question in seconds
    private LocalDateTime startedAt;
    private LocalDateTime endedAt;
    private LocalDateTime createdAt;
    private Integer participantCount;      // For display purposes
    private Integer totalQuestions;        // For display purposes

    // Status constants
    public static final String STATUS_WAITING = "waiting";
    public static final String STATUS_ACTIVE = "active";
    public static final String STATUS_PAUSED = "paused";
    public static final String STATUS_COMPLETED = "completed";

    // Constructors
    public ArenaSession() {
        this.status = STATUS_WAITING;
        this.currentQuestion = 0;
        this.questionTime = 30;
    }

    public ArenaSession(Integer quizId, Integer hostId, Integer questionTime) {
        this();
        this.quizId = quizId;
        this.hostId = hostId;
        this.questionTime = questionTime != null ? questionTime : 30;
    }

    // Getters and Setters
    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public String getCode() {
        return code;
    }

    public void setCode(String code) {
        this.code = code;
    }

    public Integer getQuizId() {
        return quizId;
    }

    public void setQuizId(Integer quizId) {
        this.quizId = quizId;
    }

    public Integer getHostId() {
        return hostId;
    }

    public void setHostId(Integer hostId) {
        this.hostId = hostId;
    }

    public String getHostName() {
        return hostName;
    }

    public void setHostName(String hostName) {
        this.hostName = hostName;
    }

    public String getQuizTitle() {
        return quizTitle;
    }

    public void setQuizTitle(String quizTitle) {
        this.quizTitle = quizTitle;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Integer getCurrentQuestion() {
        return currentQuestion;
    }

    public void setCurrentQuestion(Integer currentQuestion) {
        this.currentQuestion = currentQuestion;
    }

    public Integer getQuestionTime() {
        return questionTime;
    }

    public void setQuestionTime(Integer questionTime) {
        this.questionTime = questionTime;
    }

    public LocalDateTime getStartedAt() {
        return startedAt;
    }

    public void setStartedAt(LocalDateTime startedAt) {
        this.startedAt = startedAt;
    }

    public LocalDateTime getEndedAt() {
        return endedAt;
    }

    public void setEndedAt(LocalDateTime endedAt) {
        this.endedAt = endedAt;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public Integer getParticipantCount() {
        return participantCount;
    }

    public void setParticipantCount(Integer participantCount) {
        this.participantCount = participantCount;
    }

    public Integer getTotalQuestions() {
        return totalQuestions;
    }

    public void setTotalQuestions(Integer totalQuestions) {
        this.totalQuestions = totalQuestions;
    }

    // Helper methods
    public boolean isWaiting() {
        return STATUS_WAITING.equals(status);
    }

    public boolean isActive() {
        return STATUS_ACTIVE.equals(status);
    }

    public boolean isPaused() {
        return STATUS_PAUSED.equals(status);
    }

    public boolean isCompleted() {
        return STATUS_COMPLETED.equals(status);
    }

    public boolean canJoin() {
        return isWaiting();
    }

    public boolean isInProgress() {
        return isActive() || isPaused();
    }

    @Override
    public String toString() {
        return "ArenaSession{" +
                "id=" + id +
                ", code='" + code + '\'' +
                ", quizId=" + quizId +
                ", hostId=" + hostId +
                ", status='" + status + '\'' +
                ", currentQuestion=" + currentQuestion +
                ", questionTime=" + questionTime +
                '}';
    }
}
