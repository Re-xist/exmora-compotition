package com.examora.model;

import java.time.LocalDateTime;

/**
 * ArenaAnswer Model - Represents an answer submitted during an arena session
 */
public class ArenaAnswer {
    private Integer id;
    private Integer sessionId;
    private Integer participantId;
    private Integer questionId;
    private String selectedAnswer;         // A, B, C, or D
    private Integer timeTaken;             // Time taken to answer in milliseconds
    private Integer scoreEarned;           // Points earned for this answer
    private LocalDateTime answeredAt;

    // Additional fields for display
    private String correctAnswer;          // Correct answer for the question
    private String questionText;           // Question text for review
    private Boolean isCorrect;             // Whether the answer is correct

    // Constructors
    public ArenaAnswer() {
        this.timeTaken = 0;
        this.scoreEarned = 0;
    }

    public ArenaAnswer(Integer sessionId, Integer participantId, Integer questionId,
                       String selectedAnswer, Integer timeTaken) {
        this();
        this.sessionId = sessionId;
        this.participantId = participantId;
        this.questionId = questionId;
        this.selectedAnswer = selectedAnswer;
        this.timeTaken = timeTaken;
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

    public Integer getParticipantId() {
        return participantId;
    }

    public void setParticipantId(Integer participantId) {
        this.participantId = participantId;
    }

    public Integer getQuestionId() {
        return questionId;
    }

    public void setQuestionId(Integer questionId) {
        this.questionId = questionId;
    }

    public String getSelectedAnswer() {
        return selectedAnswer;
    }

    public void setSelectedAnswer(String selectedAnswer) {
        this.selectedAnswer = selectedAnswer;
    }

    public Integer getTimeTaken() {
        return timeTaken;
    }

    public void setTimeTaken(Integer timeTaken) {
        this.timeTaken = timeTaken;
    }

    public Integer getScoreEarned() {
        return scoreEarned;
    }

    public void setScoreEarned(Integer scoreEarned) {
        this.scoreEarned = scoreEarned;
    }

    public LocalDateTime getAnsweredAt() {
        return answeredAt;
    }

    public void setAnsweredAt(LocalDateTime answeredAt) {
        this.answeredAt = answeredAt;
    }

    public String getCorrectAnswer() {
        return correctAnswer;
    }

    public void setCorrectAnswer(String correctAnswer) {
        this.correctAnswer = correctAnswer;
    }

    public String getQuestionText() {
        return questionText;
    }

    public void setQuestionText(String questionText) {
        this.questionText = questionText;
    }

    public Boolean getIsCorrect() {
        return isCorrect;
    }

    public void setIsCorrect(Boolean isCorrect) {
        this.isCorrect = isCorrect;
    }

    // Helper method to check if answer is correct
    public boolean checkCorrect(String correctAnswer) {
        this.correctAnswer = correctAnswer;
        this.isCorrect = selectedAnswer != null && selectedAnswer.equalsIgnoreCase(correctAnswer);
        return this.isCorrect;
    }

    @Override
    public String toString() {
        return "ArenaAnswer{" +
                "id=" + id +
                ", sessionId=" + sessionId +
                ", participantId=" + participantId +
                ", questionId=" + questionId +
                ", selectedAnswer='" + selectedAnswer + '\'' +
                ", timeTaken=" + timeTaken +
                ", scoreEarned=" + scoreEarned +
                '}';
    }
}
