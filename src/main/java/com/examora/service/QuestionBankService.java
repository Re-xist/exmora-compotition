package com.examora.service;

import com.examora.dao.QuestionCategoryDAO;
import com.examora.dao.QuestionDAO;
import com.examora.model.Question;
import com.examora.model.QuestionCategory;

import java.sql.SQLException;
import java.util.List;

/**
 * QuestionBankService - Business logic for question bank operations
 */
public class QuestionBankService {
    private QuestionCategoryDAO categoryDAO;
    private QuestionDAO questionDAO;

    public QuestionBankService() {
        this.categoryDAO = new QuestionCategoryDAO();
        this.questionDAO = new QuestionDAO();
    }

    // ==================== Category Methods ====================

    /**
     * Create a new category
     */
    public QuestionCategory createCategory(String name, String description, Integer createdBy)
            throws ServiceException {
        if (name == null || name.trim().isEmpty()) {
            throw new ServiceException("Nama kategori tidak boleh kosong");
        }

        try {
            QuestionCategory category = new QuestionCategory(name.trim(), description, createdBy);
            return categoryDAO.create(category);
        } catch (SQLException e) {
            throw new ServiceException("Gagal membuat kategori: " + e.getMessage(), e);
        }
    }

    /**
     * Get category by ID
     */
    public QuestionCategory getCategoryById(Integer id) throws ServiceException {
        try {
            QuestionCategory category = categoryDAO.findById(id);
            if (category == null) {
                throw new ServiceException("Kategori tidak ditemukan");
            }
            return category;
        } catch (SQLException e) {
            throw new ServiceException("Gagal mengambil kategori: " + e.getMessage(), e);
        }
    }

    /**
     * Get all categories
     */
    public List<QuestionCategory> getAllCategories() throws ServiceException {
        try {
            return categoryDAO.findAll();
        } catch (SQLException e) {
            throw new ServiceException("Gagal mengambil daftar kategori: " + e.getMessage(), e);
        }
    }

    /**
     * Update category
     */
    public QuestionCategory updateCategory(Integer id, String name, String description)
            throws ServiceException {
        if (name == null || name.trim().isEmpty()) {
            throw new ServiceException("Nama kategori tidak boleh kosong");
        }

        try {
            QuestionCategory category = categoryDAO.findById(id);
            if (category == null) {
                throw new ServiceException("Kategori tidak ditemukan");
            }

            category.setName(name.trim());
            category.setDescription(description);

            if (!categoryDAO.update(category)) {
                throw new ServiceException("Gagal mengupdate kategori");
            }

            return category;
        } catch (SQLException e) {
            throw new ServiceException("Gagal mengupdate kategori: " + e.getMessage(), e);
        }
    }

    /**
     * Delete category
     */
    public void deleteCategory(Integer id) throws ServiceException {
        try {
            int questionCount = categoryDAO.countQuestions(id);
            if (questionCount > 0) {
                throw new ServiceException("Tidak dapat menghapus kategori yang memiliki " + questionCount + " soal");
            }

            if (!categoryDAO.delete(id)) {
                throw new ServiceException("Gagal menghapus kategori");
            }
        } catch (SQLException e) {
            throw new ServiceException("Gagal menghapus kategori: " + e.getMessage(), e);
        }
    }

    // ==================== Bank Question Methods ====================

    /**
     * Add question to bank
     */
    public Question addQuestionToBank(String questionText, String optionA, String optionB,
                                       String optionC, String optionD, String correctAnswer,
                                       Integer categoryId) throws ServiceException {
        validateQuestion(questionText, optionA, optionB, optionC, optionD, correctAnswer);

        try {
            Question question = new Question();
            question.setQuestionText(questionText.trim());
            question.setOptionA(optionA.trim());
            question.setOptionB(optionB.trim());
            question.setOptionC(optionC.trim());
            question.setOptionD(optionD.trim());
            question.setCorrectAnswer(correctAnswer.toUpperCase());
            question.setCategoryId(categoryId);
            question.setIsBankQuestion(true);
            question.setQuizId(null);

            return questionDAO.create(question);
        } catch (SQLException e) {
            throw new ServiceException("Gagal menambahkan soal ke bank: " + e.getMessage(), e);
        }
    }

    /**
     * Update bank question
     */
    public Question updateBankQuestion(Integer id, String questionText, String optionA, String optionB,
                                        String optionC, String optionD, String correctAnswer,
                                        Integer categoryId) throws ServiceException {
        validateQuestion(questionText, optionA, optionB, optionC, optionD, correctAnswer);

        try {
            Question question = questionDAO.findById(id);
            if (question == null) {
                throw new ServiceException("Soal tidak ditemukan");
            }

            question.setQuestionText(questionText.trim());
            question.setOptionA(optionA.trim());
            question.setOptionB(optionB.trim());
            question.setOptionC(optionC.trim());
            question.setOptionD(optionD.trim());
            question.setCorrectAnswer(correctAnswer.toUpperCase());
            question.setCategoryId(categoryId);

            if (!questionDAO.update(question)) {
                throw new ServiceException("Gagal mengupdate soal");
            }

            return question;
        } catch (SQLException e) {
            throw new ServiceException("Gagal mengupdate soal: " + e.getMessage(), e);
        }
    }

    /**
     * Delete bank question
     */
    public void deleteBankQuestion(Integer id) throws ServiceException {
        try {
            if (!questionDAO.delete(id)) {
                throw new ServiceException("Gagal menghapus soal");
            }
        } catch (SQLException e) {
            throw new ServiceException("Gagal menghapus soal: " + e.getMessage(), e);
        }
    }

    /**
     * Get all bank questions
     */
    public List<Question> getAllBankQuestions() throws ServiceException {
        try {
            return questionDAO.findBankQuestions();
        } catch (SQLException e) {
            throw new ServiceException("Gagal mengambil soal dari bank: " + e.getMessage(), e);
        }
    }

    /**
     * Get bank questions by category
     */
    public List<Question> getBankQuestionsByCategory(Integer categoryId) throws ServiceException {
        try {
            return questionDAO.findBankQuestionsByCategory(categoryId);
        } catch (SQLException e) {
            throw new ServiceException("Gagal mengambil soal dari bank: " + e.getMessage(), e);
        }
    }

    /**
     * Search bank questions
     */
    public List<Question> searchBankQuestions(String searchTerm, Integer categoryId)
            throws ServiceException {
        try {
            return questionDAO.searchBankQuestions(searchTerm, categoryId);
        } catch (SQLException e) {
            throw new ServiceException("Gagal mencari soal: " + e.getMessage(), e);
        }
    }

    /**
     * Get question by ID
     */
    public Question getQuestionById(Integer id) throws ServiceException {
        try {
            Question question = questionDAO.findById(id);
            if (question == null) {
                throw new ServiceException("Soal tidak ditemukan");
            }
            return question;
        } catch (SQLException e) {
            throw new ServiceException("Gagal mengambil soal: " + e.getMessage(), e);
        }
    }

    /**
     * Add question to quiz
     */
    public void addQuestionToQuiz(Integer quizId, Integer questionId, Integer order)
            throws ServiceException {
        try {
            if (!questionDAO.addQuestionToQuiz(quizId, questionId, order)) {
                throw new ServiceException("Gagal menambahkan soal ke quiz");
            }
        } catch (SQLException e) {
            throw new ServiceException("Gagal menambahkan soal ke quiz: " + e.getMessage(), e);
        }
    }

    /**
     * Remove question from quiz
     */
    public void removeQuestionFromQuiz(Integer quizId, Integer questionId)
            throws ServiceException {
        try {
            if (!questionDAO.removeQuestionFromQuiz(quizId, questionId)) {
                throw new ServiceException("Gagal menghapus soal dari quiz");
            }
        } catch (SQLException e) {
            throw new ServiceException("Gagal menghapus soal dari quiz: " + e.getMessage(), e);
        }
    }

    /**
     * Get statistics
     */
    public int getTotalBankQuestions() throws ServiceException {
        try {
            return questionDAO.countBankQuestions();
        } catch (SQLException e) {
            throw new ServiceException("Gagal mengambil statistik: " + e.getMessage(), e);
        }
    }

    /**
     * Validate question data
     */
    private void validateQuestion(String questionText, String optionA, String optionB,
                                  String optionC, String optionD, String correctAnswer)
            throws ServiceException {
        if (questionText == null || questionText.trim().isEmpty()) {
            throw new ServiceException("Teks pertanyaan tidak boleh kosong");
        }
        if (optionA == null || optionA.trim().isEmpty()) {
            throw new ServiceException("Opsi A tidak boleh kosong");
        }
        if (optionB == null || optionB.trim().isEmpty()) {
            throw new ServiceException("Opsi B tidak boleh kosong");
        }
        if (optionC == null || optionC.trim().isEmpty()) {
            throw new ServiceException("Opsi C tidak boleh kosong");
        }
        if (optionD == null || optionD.trim().isEmpty()) {
            throw new ServiceException("Opsi D tidak boleh kosong");
        }
        if (correctAnswer == null || !correctAnswer.matches("[ABCDabcd]")) {
            throw new ServiceException("Jawaban benar harus A, B, C, atau D");
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
