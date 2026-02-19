package com.examora.model;

import java.time.LocalDateTime;

/**
 * Answer Model - Represents a user's answer to a question
 */
public class Answer {
    private Integer id;
    private Integer submissionId;
    private Integer questionId;
    private String selectedAnswer; // A, B, C, or D
    private Boolean isCorrect;
    private LocalDateTime answeredAt;

    // Related data for display
    private String questionText;
    private String correctAnswer;

    // Option texts for display
    private String optionA;
    private String optionB;
    private String optionC;
    private String optionD;

    // Constructors
    public Answer() {}

    public Answer(Integer submissionId, Integer questionId, String selectedAnswer) {
        this.submissionId = submissionId;
        this.questionId = questionId;
        this.selectedAnswer = selectedAnswer;
    }

    // Getters and Setters
    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public Integer getSubmissionId() {
        return submissionId;
    }

    public void setSubmissionId(Integer submissionId) {
        this.submissionId = submissionId;
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

    public Boolean getIsCorrect() {
        return isCorrect;
    }

    public void setIsCorrect(Boolean isCorrect) {
        this.isCorrect = isCorrect;
    }

    public LocalDateTime getAnsweredAt() {
        return answeredAt;
    }

    public void setAnsweredAt(LocalDateTime answeredAt) {
        this.answeredAt = answeredAt;
    }

    public String getQuestionText() {
        return questionText;
    }

    public void setQuestionText(String questionText) {
        this.questionText = questionText;
    }

    public String getCorrectAnswer() {
        return correctAnswer;
    }

    public void setCorrectAnswer(String correctAnswer) {
        this.correctAnswer = correctAnswer;
    }

    public String getOptionA() {
        return optionA;
    }

    public void setOptionA(String optionA) {
        this.optionA = optionA;
    }

    public String getOptionB() {
        return optionB;
    }

    public void setOptionB(String optionB) {
        this.optionB = optionB;
    }

    public String getOptionC() {
        return optionC;
    }

    public void setOptionC(String optionC) {
        this.optionC = optionC;
    }

    public String getOptionD() {
        return optionD;
    }

    public void setOptionD(String optionD) {
        this.optionD = optionD;
    }

    // Helper method to get option text by letter
    public String getOptionText(String option) {
        if (option == null) return null;
        switch (option.toUpperCase()) {
            case "A": return optionA;
            case "B": return optionB;
            case "C": return optionC;
            case "D": return optionD;
            default: return null;
        }
    }

    // Helper method to get selected answer text
    public String getSelectedAnswerText() {
        return getOptionText(selectedAnswer);
    }

    // Helper method to get correct answer text
    public String getCorrectAnswerText() {
        return getOptionText(correctAnswer);
    }

    @Override
    public String toString() {
        return "Answer{" +
                "id=" + id +
                ", submissionId=" + submissionId +
                ", questionId=" + questionId +
                ", selectedAnswer='" + selectedAnswer + '\'' +
                ", isCorrect=" + isCorrect +
                '}';
    }
}
