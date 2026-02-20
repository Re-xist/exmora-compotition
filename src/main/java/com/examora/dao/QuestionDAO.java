package com.examora.dao;

import com.examora.model.Question;
import com.examora.util.DBUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * Question Data Access Object - Handles database operations for questions
 */
public class QuestionDAO {

    /**
     * Create a new question
     */
    public Question create(Question question) throws SQLException {
        String sql = "INSERT INTO questions (quiz_id, question_text, option_a, option_b, option_c, option_d, correct_answer, question_order, category_id, is_bank_question) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            if (question.getQuizId() != null) {
                stmt.setInt(1, question.getQuizId());
            } else {
                stmt.setNull(1, Types.INTEGER);
            }
            stmt.setString(2, question.getQuestionText());
            stmt.setString(3, question.getOptionA());
            stmt.setString(4, question.getOptionB());
            stmt.setString(5, question.getOptionC());
            stmt.setString(6, question.getOptionD());
            stmt.setString(7, question.getCorrectAnswer());
            stmt.setInt(8, question.getQuestionOrder() != null ? question.getQuestionOrder() : 0);
            if (question.getCategoryId() != null) {
                stmt.setInt(9, question.getCategoryId());
            } else {
                stmt.setNull(9, Types.INTEGER);
            }
            stmt.setBoolean(10, question.getIsBankQuestion() != null ? question.getIsBankQuestion() : false);

            int affectedRows = stmt.executeUpdate();

            if (affectedRows == 0) {
                throw new SQLException("Creating question failed, no rows affected.");
            }

            try (ResultSet generatedKeys = stmt.getGeneratedKeys()) {
                if (generatedKeys.next()) {
                    question.setId(generatedKeys.getInt(1));
                } else {
                    throw new SQLException("Creating question failed, no ID obtained.");
                }
            }

            return question;
        }
    }

    /**
     * Find question by ID
     */
    public Question findById(Integer id) throws SQLException {
        String sql = "SELECT * FROM questions WHERE id = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, id);

            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToQuestion(rs);
                }
            }
        }
        return null;
    }

    /**
     * Get all questions for a quiz
     */
    public List<Question> findByQuizId(Integer quizId) throws SQLException {
        String sql = "SELECT * FROM questions WHERE quiz_id = ? ORDER BY question_order, id";
        List<Question> questions = new ArrayList<>();

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, quizId);

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    questions.add(mapResultSetToQuestion(rs));
                }
            }
        }
        return questions;
    }

    /**
     * Get questions for a quiz (without correct answers - for taking exam)
     */
    public List<Question> findByQuizIdForExam(Integer quizId) throws SQLException {
        String sql = "SELECT id, quiz_id, question_text, option_a, option_b, option_c, option_d, question_order FROM questions WHERE quiz_id = ? ORDER BY RAND()";
        List<Question> questions = new ArrayList<>();

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, quizId);

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Question q = new Question();
                    q.setId(rs.getInt("id"));
                    q.setQuizId(rs.getInt("quiz_id"));
                    q.setQuestionText(rs.getString("question_text"));
                    q.setOptionA(rs.getString("option_a"));
                    q.setOptionB(rs.getString("option_b"));
                    q.setOptionC(rs.getString("option_c"));
                    q.setOptionD(rs.getString("option_d"));
                    q.setQuestionOrder(rs.getInt("question_order"));
                    questions.add(q);
                }
            }
        }
        return questions;
    }

    /**
     * Update question
     */
    public boolean update(Question question) throws SQLException {
        String sql = "UPDATE questions SET question_text = ?, option_a = ?, option_b = ?, option_c = ?, option_d = ?, correct_answer = ?, question_order = ?, category_id = ?, is_bank_question = ? WHERE id = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, question.getQuestionText());
            stmt.setString(2, question.getOptionA());
            stmt.setString(3, question.getOptionB());
            stmt.setString(4, question.getOptionC());
            stmt.setString(5, question.getOptionD());
            stmt.setString(6, question.getCorrectAnswer());
            stmt.setInt(7, question.getQuestionOrder() != null ? question.getQuestionOrder() : 0);
            if (question.getCategoryId() != null) {
                stmt.setInt(8, question.getCategoryId());
            } else {
                stmt.setNull(8, Types.INTEGER);
            }
            stmt.setBoolean(9, question.getIsBankQuestion() != null ? question.getIsBankQuestion() : false);
            stmt.setInt(10, question.getId());

            return stmt.executeUpdate() > 0;
        }
    }

    /**
     * Delete question
     */
    public boolean delete(Integer id) throws SQLException {
        String sql = "DELETE FROM questions WHERE id = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, id);
            return stmt.executeUpdate() > 0;
        }
    }

    /**
     * Delete all questions for a quiz
     */
    public boolean deleteByQuizId(Integer quizId) throws SQLException {
        String sql = "DELETE FROM questions WHERE quiz_id = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, quizId);
            return stmt.executeUpdate() > 0;
        }
    }

    /**
     * Count questions for a quiz
     */
    public int countByQuizId(Integer quizId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM questions WHERE quiz_id = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, quizId);

            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }
        return 0;
    }

    /**
     * Get correct answers for a quiz (for scoring)
     */
    public List<Question> getCorrectAnswers(Integer quizId) throws SQLException {
        String sql = "SELECT id, correct_answer FROM questions WHERE quiz_id = ?";
        List<Question> questions = new ArrayList<>();

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, quizId);

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Question q = new Question();
                    q.setId(rs.getInt("id"));
                    q.setCorrectAnswer(rs.getString("correct_answer"));
                    questions.add(q);
                }
            }
        }
        return questions;
    }

    /**
     * Map ResultSet to Question object
     */
    private Question mapResultSetToQuestion(ResultSet rs) throws SQLException {
        Question question = new Question();
        question.setId(rs.getInt("id"));

        int quizId = rs.getInt("quiz_id");
        if (!rs.wasNull()) {
            question.setQuizId(quizId);
        }

        question.setQuestionText(rs.getString("question_text"));
        question.setOptionA(rs.getString("option_a"));
        question.setOptionB(rs.getString("option_b"));
        question.setOptionC(rs.getString("option_c"));
        question.setOptionD(rs.getString("option_d"));
        question.setCorrectAnswer(rs.getString("correct_answer"));
        question.setQuestionOrder(rs.getInt("question_order"));

        int categoryId = rs.getInt("category_id");
        if (!rs.wasNull()) {
            question.setCategoryId(categoryId);
        }

        question.setIsBankQuestion(rs.getBoolean("is_bank_question"));

        Timestamp createdAt = rs.getTimestamp("created_at");
        if (createdAt != null) {
            question.setCreatedAt(createdAt.toLocalDateTime());
        }

        return question;
    }

    // ==================== Question Bank Methods ====================

    /**
     * Find all bank questions
     */
    public List<Question> findBankQuestions() throws SQLException {
        String sql = "SELECT q.*, c.name as category_name " +
                     "FROM questions q " +
                     "LEFT JOIN question_categories c ON q.category_id = c.id " +
                     "WHERE q.is_bank_question = TRUE " +
                     "ORDER BY c.name, q.created_at DESC";
        List<Question> questions = new ArrayList<>();

        try (Connection conn = DBUtil.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {

            while (rs.next()) {
                questions.add(mapResultSetToQuestionWithCategory(rs));
            }
        }
        return questions;
    }

    /**
     * Find bank questions by category
     */
    public List<Question> findBankQuestionsByCategory(Integer categoryId) throws SQLException {
        String sql = "SELECT q.*, c.name as category_name " +
                     "FROM questions q " +
                     "LEFT JOIN question_categories c ON q.category_id = c.id " +
                     "WHERE q.is_bank_question = TRUE AND q.category_id = ? " +
                     "ORDER BY q.created_at DESC";
        List<Question> questions = new ArrayList<>();

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, categoryId);

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    questions.add(mapResultSetToQuestionWithCategory(rs));
                }
            }
        }
        return questions;
    }

    /**
     * Search bank questions
     */
    public List<Question> searchBankQuestions(String searchTerm, Integer categoryId) throws SQLException {
        StringBuilder sql = new StringBuilder(
            "SELECT q.*, c.name as category_name " +
            "FROM questions q " +
            "LEFT JOIN question_categories c ON q.category_id = c.id " +
            "WHERE q.is_bank_question = TRUE");

        List<Object> params = new ArrayList<>();

        if (searchTerm != null && !searchTerm.trim().isEmpty()) {
            sql.append(" AND (q.question_text LIKE ? OR q.option_a LIKE ? OR q.option_b LIKE ?)");
            String likeTerm = "%" + searchTerm.trim() + "%";
            params.add(likeTerm);
            params.add(likeTerm);
            params.add(likeTerm);
        }

        if (categoryId != null) {
            sql.append(" AND q.category_id = ?");
            params.add(categoryId);
        }

        sql.append(" ORDER BY q.created_at DESC");

        List<Question> questions = new ArrayList<>();

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) {
                stmt.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    questions.add(mapResultSetToQuestionWithCategory(rs));
                }
            }
        }
        return questions;
    }

    /**
     * Add question to quiz (using junction table)
     */
    public boolean addQuestionToQuiz(Integer quizId, Integer questionId, Integer order) throws SQLException {
        String sql = "INSERT INTO quiz_questions (quiz_id, question_id, question_order) VALUES (?, ?, ?) " +
                     "ON DUPLICATE KEY UPDATE question_order = VALUES(question_order)";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, quizId);
            stmt.setInt(2, questionId);
            stmt.setInt(3, order != null ? order : 0);

            return stmt.executeUpdate() > 0;
        }
    }

    /**
     * Remove question from quiz
     */
    public boolean removeQuestionFromQuiz(Integer quizId, Integer questionId) throws SQLException {
        String sql = "DELETE FROM quiz_questions WHERE quiz_id = ? AND question_id = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, quizId);
            stmt.setInt(2, questionId);

            return stmt.executeUpdate() > 0;
        }
    }

    /**
     * Get questions for quiz from junction table (for exams with bank questions)
     */
    public List<Question> findByQuizIdFromJunction(Integer quizId) throws SQLException {
        String sql = "SELECT q.*, qq.question_order as qq_order " +
                     "FROM quiz_questions qq " +
                     "JOIN questions q ON qq.question_id = q.id " +
                     "WHERE qq.quiz_id = ? " +
                     "ORDER BY qq.question_order, q.id";
        List<Question> questions = new ArrayList<>();

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, quizId);

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Question q = mapResultSetToQuestion(rs);
                    q.setQuestionOrder(rs.getInt("qq_order"));
                    questions.add(q);
                }
            }
        }
        return questions;
    }

    /**
     * Count bank questions
     */
    public int countBankQuestions() throws SQLException {
        String sql = "SELECT COUNT(*) FROM questions WHERE is_bank_question = TRUE";

        try (Connection conn = DBUtil.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {

            if (rs.next()) {
                return rs.getInt(1);
            }
        }
        return 0;
    }

    /**
     * Count bank questions by category
     */
    public int countBankQuestionsByCategory(Integer categoryId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM questions WHERE is_bank_question = TRUE AND category_id = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, categoryId);

            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }
        return 0;
    }

    /**
     * Map ResultSet to Question object with category name
     */
    private Question mapResultSetToQuestionWithCategory(ResultSet rs) throws SQLException {
        Question question = mapResultSetToQuestion(rs);
        question.setCategoryName(rs.getString("category_name"));
        return question;
    }
}
