package com.examora.service;

import com.examora.dao.QuestionDAO;
import com.examora.dao.QuizDAO;
import com.examora.dao.SubmissionDAO;
import com.examora.model.Answer;
import com.examora.model.Question;
import com.examora.model.Quiz;
import com.examora.model.Submission;
import com.examora.util.ValidationUtil;

import java.sql.SQLException;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Submission Service - Business logic for quiz submissions
 */
public class SubmissionService {
    private SubmissionDAO submissionDAO;
    private QuizDAO quizDAO;
    private QuestionDAO questionDAO;

    public SubmissionService() {
        this.submissionDAO = new SubmissionDAO();
        this.quizDAO = new QuizDAO();
        this.questionDAO = new QuestionDAO();
    }

    /**
     * Start a quiz (create submission)
     */
    public Submission startQuiz(Integer quizId, Integer userId) throws ServiceException {
        try {
            // Check if quiz exists and is active
            Quiz quiz = quizDAO.findById(quizId);
            if (quiz == null) {
                throw new ServiceException("Quiz tidak ditemukan");
            }
            if (!quiz.getIsActive()) {
                throw new ServiceException("Quiz belum dipublish");
            }

            // Check if quiz has expired (past deadline)
            if (quiz.isExpired()) {
                throw new ServiceException("Quiz sudah melewati deadline (" + quiz.getFormattedDeadline() + ")");
            }

            // Check if user has already submitted
            if (submissionDAO.hasSubmitted(userId, quizId)) {
                throw new ServiceException("Anda sudah mengerjakan quiz ini");
            }

            // Check if there's an in-progress submission
            Submission existing = submissionDAO.findByUserAndQuiz(userId, quizId);
            if (existing != null && existing.isInProgress()) {
                return existing;
            }

            // Create new submission
            Submission submission = new Submission(quizId, userId);
            submission.setTotalQuestions(questionDAO.countByQuizId(quizId));
            return submissionDAO.create(submission);

        } catch (SQLException e) {
            throw new ServiceException("Gagal memulai quiz: " + e.getMessage(), e);
        }
    }

    /**
     * Get questions for taking quiz
     */
    public List<Question> getQuestionsForExam(Integer quizId) throws ServiceException {
        try {
            return questionDAO.findByQuizIdForExam(quizId);
        } catch (SQLException e) {
            throw new ServiceException("Gagal mengambil soal: " + e.getMessage(), e);
        }
    }

    /**
     * Save an answer during exam
     */
    public void saveAnswer(Integer submissionId, Integer questionId, String selectedAnswer)
            throws ServiceException {
        // Validate inputs
        if (submissionId == null || submissionId <= 0) {
            throw new ServiceException("Submission ID tidak valid");
        }
        if (questionId == null || questionId <= 0) {
            throw new ServiceException("Question ID tidak valid");
        }
        if (!ValidationUtil.isValidAnswer(selectedAnswer)) {
            throw new ServiceException("Jawaban tidak valid (harus A, B, C, atau D)");
        }

        try {
            // Verify submission exists and is in progress
            Submission submission = submissionDAO.findById(submissionId);
            if (submission == null) {
                throw new ServiceException("Submission tidak ditemukan");
            }
            if (submission.isCompleted()) {
                throw new ServiceException("Quiz sudah selesai, tidak dapat mengubah jawaban");
            }

            // Get question and verify it belongs to the quiz
            Question question = questionDAO.findById(questionId);
            if (question == null) {
                throw new ServiceException("Pertanyaan tidak ditemukan");
            }

            // Verify question belongs to this quiz
            if (!question.getQuizId().equals(submission.getQuizId())) {
                throw new ServiceException("Pertanyaan tidak termasuk dalam quiz ini");
            }

            // Calculate correctness
            boolean isCorrect = selectedAnswer.equalsIgnoreCase(question.getCorrectAnswer());

            // Save answer (will update if exists due to unique constraint)
            Answer answer = new Answer(submissionId, questionId, selectedAnswer.toUpperCase());
            answer.setIsCorrect(isCorrect);

            submissionDAO.saveAnswer(answer);

        } catch (SQLException e) {
            throw new ServiceException("Gagal menyimpan jawaban: " + e.getMessage(), e);
        }
    }

    /**
     * Submit quiz and calculate score
     */
    public Submission submitQuiz(Integer submissionId, Integer timeSpent) throws ServiceException {
        // Validate inputs
        if (submissionId == null || submissionId <= 0) {
            throw new ServiceException("Submission ID tidak valid");
        }
        if (timeSpent != null && timeSpent < 0) {
            timeSpent = 0; // Default to 0 if negative
        }

        try {
            Submission submission = submissionDAO.findById(submissionId);
            if (submission == null) {
                throw new ServiceException("Submission tidak ditemukan");
            }

            if (submission.isCompleted()) {
                throw new ServiceException("Quiz sudah disubmit");
            }

            // Get all answers for this submission
            List<Answer> answers = submissionDAO.getAnswers(submissionId);
            int correctCount = 0;

            for (Answer answer : answers) {
                if (answer.getIsCorrect() != null && answer.getIsCorrect()) {
                    correctCount++;
                }
            }

            // Get total questions from quiz
            int totalQuestions = questionDAO.countByQuizId(submission.getQuizId());
            if (totalQuestions <= 0) {
                totalQuestions = submission.getTotalQuestions();
            }

            // Calculate score (0-100)
            double score = totalQuestions > 0 ? (correctCount * 100.0 / totalQuestions) : 0;
            score = Math.min(100.0, Math.max(0.0, score)); // Ensure score is between 0-100

            // Update submission
            submission.setTotalQuestions(totalQuestions);
            submission.setCorrectAnswers(correctCount);
            submission.setScore(Math.round(score * 100.0) / 100.0); // Round to 2 decimal places
            submission.setSubmittedAt(LocalDateTime.now());
            submission.setTimeSpent(timeSpent != null ? timeSpent : 0);
            submission.setStatus("completed");

            if (!submissionDAO.update(submission)) {
                throw new ServiceException("Gagal mengupdate submission");
            }

            // Set answers for display
            submission.setAnswers(answers);

            return submission;

        } catch (SQLException e) {
            throw new ServiceException("Gagal submit quiz: " + e.getMessage(), e);
        }
    }

    /**
     * Get submission result
     */
    public Submission getResult(Integer submissionId) throws ServiceException {
        try {
            Submission submission = submissionDAO.findById(submissionId);
            if (submission == null) {
                throw new ServiceException("Submission tidak ditemukan");
            }

            // Get answers
            List<Answer> answers = submissionDAO.getAnswers(submissionId);
            submission.setAnswers(answers);

            return submission;
        } catch (SQLException e) {
            throw new ServiceException("Gagal mengambil hasil: " + e.getMessage(), e);
        }
    }

    /**
     * Get user's submission for a quiz
     */
    public Submission getUserSubmission(Integer userId, Integer quizId) throws ServiceException {
        try {
            return submissionDAO.findByUserAndQuiz(userId, quizId);
        } catch (SQLException e) {
            throw new ServiceException("Gagal mengambil data submission: " + e.getMessage(), e);
        }
    }

    /**
     * Get all submissions for a quiz (admin)
     */
    public List<Submission> getQuizSubmissions(Integer quizId) throws ServiceException {
        try {
            return submissionDAO.findByQuizId(quizId);
        } catch (SQLException e) {
            throw new ServiceException("Gagal mengambil data submissions: " + e.getMessage(), e);
        }
    }

    /**
     * Get all submissions for a user
     */
    public List<Submission> getUserSubmissions(Integer userId) throws ServiceException {
        try {
            return submissionDAO.findByUserId(userId);
        } catch (SQLException e) {
            throw new ServiceException("Gagal mengambil data submissions: " + e.getMessage(), e);
        }
    }

    /**
     * Get all submissions (admin)
     */
    public List<Submission> getAllSubmissions() throws ServiceException {
        try {
            return submissionDAO.findAll();
        } catch (SQLException e) {
            throw new ServiceException("Gagal mengambil data submissions: " + e.getMessage(), e);
        }
    }

    /**
     * Get quiz statistics
     */
    public Map<String, Object> getQuizStatistics(Integer quizId) throws ServiceException {
        try {
            return submissionDAO.getStatistics(quizId);
        } catch (SQLException e) {
            throw new ServiceException("Gagal mengambil statistik: " + e.getMessage(), e);
        }
    }

    /**
     * Check if user can take quiz
     */
    public boolean canTakeQuiz(Integer userId, Integer quizId) throws ServiceException {
        try {
            Quiz quiz = quizDAO.findById(quizId);
            if (quiz == null || !quiz.getIsActive()) {
                return false;
            }

            return !submissionDAO.hasSubmitted(userId, quizId);
        } catch (SQLException e) {
            throw new ServiceException("Gagal mengecek status quiz: " + e.getMessage(), e);
        }
    }

    /**
     * Get detailed quiz results with participant list
     */
    public List<Map<String, Object>> getDetailedQuizResults(Integer quizId) throws ServiceException {
        try {
            List<Map<String, Object>> submissions = submissionDAO.getDetailedSubmissionsByQuiz(quizId);

            // Update unanswered count for each submission
            for (Map<String, Object> sub : submissions) {
                Integer submissionId = (Integer) sub.get("id");
                if (submissionId == null) continue;

                int answeredCount = submissionDAO.getAnsweredCount(submissionId);
                int totalQuestions = sub.get("totalQuestions") != null ? (Integer) sub.get("totalQuestions") : 0;
                int correctAnswers = sub.get("correctAnswers") != null ? (Integer) sub.get("correctAnswers") : 0;
                int wrongCount = answeredCount - correctAnswers;
                int unanswered = totalQuestions - answeredCount;

                sub.put("answeredCount", answeredCount);
                sub.put("wrongCount", wrongCount);
                sub.put("unanswered", unanswered);
            }

            return submissions;
        } catch (SQLException e) {
            throw new ServiceException("Gagal mengambil hasil quiz: " + e.getMessage(), e);
        }
    }

    /**
     * Get submission detail with all questions and answers
     */
    public Map<String, Object> getSubmissionDetail(Integer submissionId) throws ServiceException {
        try {
            return submissionDAO.getSubmissionDetailWithAnswers(submissionId);
        } catch (SQLException e) {
            throw new ServiceException("Gagal mengambil detail submission: " + e.getMessage(), e);
        }
    }

    /**
     * Service Exception
     */
    public static class ServiceException extends Exception {
        public ServiceException(String message) {
            super(message);
        }

        public ServiceException(String message, Throwable cause) {
            super(message, cause);
        }
    }
}
