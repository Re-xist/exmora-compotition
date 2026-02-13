package com.examora.service;

import com.examora.dao.QuestionDAO;
import com.examora.dao.QuizDAO;
import com.examora.dao.SubmissionDAO;
import com.examora.model.Question;
import com.examora.model.Quiz;
import com.examora.util.ValidationUtil;

import java.sql.SQLException;
import java.time.LocalDateTime;
import java.util.List;

/**
 * Quiz Service - Business logic for quiz operations
 */
public class QuizService {
    private QuizDAO quizDAO;
    private QuestionDAO questionDAO;
    private SubmissionDAO submissionDAO;

    public QuizService() {
        this.quizDAO = new QuizDAO();
        this.questionDAO = new QuestionDAO();
        this.submissionDAO = new SubmissionDAO();
    }

    /**
     * Create a new quiz
     */
    public Quiz createQuiz(String title, String description, Integer duration, Integer createdBy)
            throws ServiceException {
        return createQuiz(title, description, duration, createdBy, null, null);
    }

    /**
     * Create a new quiz with deadline
     */
    public Quiz createQuiz(String title, String description, Integer duration, Integer createdBy, LocalDateTime deadline)
            throws ServiceException {
        return createQuiz(title, description, duration, createdBy, deadline, null);
    }

    /**
     * Create a new quiz with deadline and target tag
     */
    public Quiz createQuiz(String title, String description, Integer duration, Integer createdBy,
                          LocalDateTime deadline, String targetTag)
            throws ServiceException {
        // Validate inputs
        if (ValidationUtil.isEmpty(title)) {
            throw new ServiceException("Judul quiz tidak boleh kosong");
        }
        if (duration == null || duration <= 0) {
            throw new ServiceException("Durasi harus lebih dari 0 menit");
        }
        if (deadline != null && deadline.isBefore(LocalDateTime.now())) {
            throw new ServiceException("Deadline tidak boleh di waktu yang sudah lewat");
        }

        try {
            Quiz quiz = new Quiz(title, description, duration, createdBy);
            quiz.setDeadline(deadline);
            quiz.setTargetTag(targetTag);
            return quizDAO.create(quiz);
        } catch (SQLException e) {
            throw new ServiceException("Gagal membuat quiz: " + e.getMessage(), e);
        }
    }

    /**
     * Get quiz by ID
     */
    public Quiz getQuizById(Integer id) throws ServiceException {
        try {
            Quiz quiz = quizDAO.findById(id);
            if (quiz == null) {
                throw new ServiceException("Quiz tidak ditemukan");
            }
            return quiz;
        } catch (SQLException e) {
            throw new ServiceException("Gagal mengambil data quiz: " + e.getMessage(), e);
        }
    }

    /**
     * Get all quizzes
     */
    public List<Quiz> getAllQuizzes() throws ServiceException {
        try {
            return quizDAO.findAll();
        } catch (SQLException e) {
            throw new ServiceException("Gagal mengambil data quizzes: " + e.getMessage(), e);
        }
    }

    /**
     * Get active quizzes
     */
    public List<Quiz> getActiveQuizzes() throws ServiceException {
        try {
            return quizDAO.findActive();
        } catch (SQLException e) {
            throw new ServiceException("Gagal mengambil data quizzes: " + e.getMessage(), e);
        }
    }

    /**
     * Get active quizzes for a specific tag
     */
    public List<Quiz> getActiveQuizzesByTag(String userTag) throws ServiceException {
        try {
            return quizDAO.findActiveByTag(userTag);
        } catch (SQLException e) {
            throw new ServiceException("Gagal mengambil data quizzes: " + e.getMessage(), e);
        }
    }

    /**
     * Get quizzes by creator
     */
    public List<Quiz> getQuizzesByCreator(Integer createdBy) throws ServiceException {
        try {
            return quizDAO.findByCreator(createdBy);
        } catch (SQLException e) {
            throw new ServiceException("Gagal mengambil data quizzes: " + e.getMessage(), e);
        }
    }

    /**
     * Update quiz
     */
    public Quiz updateQuiz(Integer id, String title, String description, Integer duration)
            throws ServiceException {
        return updateQuiz(id, title, description, duration, null, null);
    }

    /**
     * Update quiz with deadline
     */
    public Quiz updateQuiz(Integer id, String title, String description, Integer duration, LocalDateTime deadline)
            throws ServiceException {
        return updateQuiz(id, title, description, duration, deadline, null);
    }

    /**
     * Update quiz with deadline and target tag
     */
    public Quiz updateQuiz(Integer id, String title, String description, Integer duration,
                          LocalDateTime deadline, String targetTag)
            throws ServiceException {
        if (ValidationUtil.isEmpty(title)) {
            throw new ServiceException("Judul quiz tidak boleh kosong");
        }
        if (duration == null || duration <= 0) {
            throw new ServiceException("Durasi harus lebih dari 0 menit");
        }

        try {
            Quiz quiz = quizDAO.findById(id);
            if (quiz == null) {
                throw new ServiceException("Quiz tidak ditemukan");
            }

            quiz.setTitle(title);
            quiz.setDescription(description);
            quiz.setDuration(duration);
            quiz.setDeadline(deadline);
            quiz.setTargetTag(targetTag);

            if (!quizDAO.update(quiz)) {
                throw new ServiceException("Gagal mengupdate quiz");
            }

            return quiz;
        } catch (SQLException e) {
            throw new ServiceException("Gagal mengupdate quiz: " + e.getMessage(), e);
        }
    }

    /**
     * Publish quiz
     */
    public void publishQuiz(Integer id) throws ServiceException {
        try {
            Quiz quiz = quizDAO.findById(id);
            if (quiz == null) {
                throw new ServiceException("Quiz tidak ditemukan");
            }

            // Check if quiz has questions
            int questionCount = questionDAO.countByQuizId(id);
            if (questionCount == 0) {
                throw new ServiceException("Quiz harus memiliki minimal 1 soal sebelum dipublish");
            }

            if (!quizDAO.updateStatus(id, true)) {
                throw new ServiceException("Gagal mempublish quiz");
            }
        } catch (SQLException e) {
            throw new ServiceException("Gagal mempublish quiz: " + e.getMessage(), e);
        }
    }

    /**
     * Unpublish quiz
     */
    public void unpublishQuiz(Integer id) throws ServiceException {
        try {
            if (!quizDAO.updateStatus(id, false)) {
                throw new ServiceException("Gagal unpublish quiz");
            }
        } catch (SQLException e) {
            throw new ServiceException("Gagal unpublish quiz: " + e.getMessage(), e);
        }
    }

    /**
     * Delete quiz
     */
    public void deleteQuiz(Integer id) throws ServiceException {
        try {
            // Check if quiz has submissions
            int submissionCount = submissionDAO.countByQuizId(id);
            if (submissionCount > 0) {
                throw new ServiceException("Quiz tidak dapat dihapus karena sudah ada yang mengerjakan");
            }

            if (!quizDAO.delete(id)) {
                throw new ServiceException("Gagal menghapus quiz");
            }
        } catch (SQLException e) {
            throw new ServiceException("Gagal menghapus quiz: " + e.getMessage(), e);
        }
    }

    /**
     * Add question to quiz
     */
    public Question addQuestion(Integer quizId, String questionText, String optionA, String optionB,
                                String optionC, String optionD, String correctAnswer)
            throws ServiceException {
        // Validate inputs
        if (ValidationUtil.isEmpty(questionText)) {
            throw new ServiceException("Pertanyaan tidak boleh kosong");
        }
        if (ValidationUtil.isEmpty(optionA) || ValidationUtil.isEmpty(optionB) ||
            ValidationUtil.isEmpty(optionC) || ValidationUtil.isEmpty(optionD)) {
            throw new ServiceException("Semua opsi jawaban harus diisi");
        }
        if (!ValidationUtil.isValidAnswer(correctAnswer)) {
            throw new ServiceException("Jawaban benar harus A, B, C, atau D");
        }

        try {
            // Check if quiz exists
            Quiz quiz = quizDAO.findById(quizId);
            if (quiz == null) {
                throw new ServiceException("Quiz tidak ditemukan");
            }

            // Get next order number
            int order = questionDAO.countByQuizId(quizId);

            Question question = new Question(quizId, questionText, optionA, optionB, optionC, optionD, correctAnswer.toUpperCase());
            question.setQuestionOrder(order);

            return questionDAO.create(question);
        } catch (SQLException e) {
            throw new ServiceException("Gagal menambah pertanyaan: " + e.getMessage(), e);
        }
    }

    /**
     * Get questions for a quiz
     */
    public List<Question> getQuestions(Integer quizId) throws ServiceException {
        try {
            return questionDAO.findByQuizId(quizId);
        } catch (SQLException e) {
            throw new ServiceException("Gagal mengambil data pertanyaan: " + e.getMessage(), e);
        }
    }

    /**
     * Update question
     */
    public Question updateQuestion(Integer questionId, String questionText, String optionA,
                                   String optionB, String optionC, String optionD, String correctAnswer)
            throws ServiceException {
        if (ValidationUtil.isEmpty(questionText)) {
            throw new ServiceException("Pertanyaan tidak boleh kosong");
        }
        if (ValidationUtil.isEmpty(optionA) || ValidationUtil.isEmpty(optionB) ||
            ValidationUtil.isEmpty(optionC) || ValidationUtil.isEmpty(optionD)) {
            throw new ServiceException("Semua opsi jawaban harus diisi");
        }
        if (!ValidationUtil.isValidAnswer(correctAnswer)) {
            throw new ServiceException("Jawaban benar harus A, B, C, atau D");
        }

        try {
            Question question = questionDAO.findById(questionId);
            if (question == null) {
                throw new ServiceException("Pertanyaan tidak ditemukan");
            }

            question.setQuestionText(questionText);
            question.setOptionA(optionA);
            question.setOptionB(optionB);
            question.setOptionC(optionC);
            question.setOptionD(optionD);
            question.setCorrectAnswer(correctAnswer.toUpperCase());

            if (!questionDAO.update(question)) {
                throw new ServiceException("Gagal mengupdate pertanyaan");
            }

            return question;
        } catch (SQLException e) {
            throw new ServiceException("Gagal mengupdate pertanyaan: " + e.getMessage(), e);
        }
    }

    /**
     * Delete question
     */
    public void deleteQuestion(Integer questionId) throws ServiceException {
        try {
            if (!questionDAO.delete(questionId)) {
                throw new ServiceException("Gagal menghapus pertanyaan");
            }
        } catch (SQLException e) {
            throw new ServiceException("Gagal menghapus pertanyaan: " + e.getMessage(), e);
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
