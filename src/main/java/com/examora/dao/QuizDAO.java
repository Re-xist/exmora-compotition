package com.examora.dao;

import com.examora.model.Quiz;
import com.examora.util.DBUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * Quiz Data Access Object - Handles database operations for quizzes
 */
public class QuizDAO {

    // Common column list for SELECT queries (without target_tag for backward compatibility)
    private static final String QUIZ_COLUMNS = "q.id, q.title, q.description, q.duration, q.is_active, q.deadline, " +
                                               "q.created_by, q.created_at, q.updated_at";

    /**
     * Create a new quiz
     */
    public Quiz create(Quiz quiz) throws SQLException {
        String sql = "INSERT INTO quiz (title, description, duration, is_active, created_by, deadline) VALUES (?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            stmt.setString(1, quiz.getTitle());
            stmt.setString(2, quiz.getDescription());
            stmt.setInt(3, quiz.getDuration());
            stmt.setBoolean(4, quiz.getIsActive() != null ? quiz.getIsActive() : false);
            stmt.setInt(5, quiz.getCreatedBy());
            stmt.setTimestamp(6, quiz.getDeadline() != null ? Timestamp.valueOf(quiz.getDeadline()) : null);

            int affectedRows = stmt.executeUpdate();

            if (affectedRows == 0) {
                throw new SQLException("Creating quiz failed, no rows affected.");
            }

            try (ResultSet generatedKeys = stmt.getGeneratedKeys()) {
                if (generatedKeys.next()) {
                    quiz.setId(generatedKeys.getInt(1));
                } else {
                    throw new SQLException("Creating quiz failed, no ID obtained.");
                }
            }

            return quiz;
        }
    }

    /**
     * Find quiz by ID
     */
    public Quiz findById(Integer id) throws SQLException {
        String sql = "SELECT " + QUIZ_COLUMNS + ", u.name as created_by_name, " +
                     "(SELECT COUNT(*) FROM questions WHERE quiz_id = q.id) as question_count " +
                     "FROM quiz q LEFT JOIN users u ON q.created_by = u.id WHERE q.id = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, id);

            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToQuiz(rs);
                }
            }
        }
        return null;
    }

    /**
     * Get all quizzes
     */
    public List<Quiz> findAll() throws SQLException {
        String sql = "SELECT " + QUIZ_COLUMNS + ", u.name as created_by_name, " +
                     "(SELECT COUNT(*) FROM questions WHERE quiz_id = q.id) as question_count " +
                     "FROM quiz q LEFT JOIN users u ON q.created_by = u.id " +
                     "ORDER BY q.created_at DESC";
        List<Quiz> quizzes = new ArrayList<>();

        try (Connection conn = DBUtil.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {

            while (rs.next()) {
                quizzes.add(mapResultSetToQuiz(rs));
            }
        }
        return quizzes;
    }

    /**
     * Get active quizzes (for participants) - only those not expired
     */
    public List<Quiz> findActive() throws SQLException {
        String sql = "SELECT " + QUIZ_COLUMNS + ", u.name as created_by_name, " +
                     "(SELECT COUNT(*) FROM questions WHERE quiz_id = q.id) as question_count " +
                     "FROM quiz q LEFT JOIN users u ON q.created_by = u.id " +
                     "WHERE q.is_active = true AND (q.deadline IS NULL OR q.deadline > NOW()) " +
                     "ORDER BY q.deadline ASC, q.created_at DESC";
        List<Quiz> quizzes = new ArrayList<>();

        try (Connection conn = DBUtil.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {

            while (rs.next()) {
                quizzes.add(mapResultSetToQuiz(rs));
            }
        }
        return quizzes;
    }

    /**
     * Get quizzes by creator
     */
    public List<Quiz> findByCreator(Integer createdBy) throws SQLException {
        String sql = "SELECT " + QUIZ_COLUMNS + ", u.name as created_by_name, " +
                     "(SELECT COUNT(*) FROM questions WHERE quiz_id = q.id) as question_count " +
                     "FROM quiz q LEFT JOIN users u ON q.created_by = u.id " +
                     "WHERE q.created_by = ? " +
                     "ORDER BY q.created_at DESC";
        List<Quiz> quizzes = new ArrayList<>();

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, createdBy);

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    quizzes.add(mapResultSetToQuiz(rs));
                }
            }
        }
        return quizzes;
    }

    /**
     * Update quiz
     */
    public boolean update(Quiz quiz) throws SQLException {
        String sql = "UPDATE quiz SET title = ?, description = ?, duration = ?, is_active = ?, deadline = ? WHERE id = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, quiz.getTitle());
            stmt.setString(2, quiz.getDescription());
            stmt.setInt(3, quiz.getDuration());
            stmt.setBoolean(4, quiz.getIsActive());
            stmt.setTimestamp(5, quiz.getDeadline() != null ? Timestamp.valueOf(quiz.getDeadline()) : null);
            stmt.setInt(6, quiz.getId());

            return stmt.executeUpdate() > 0;
        }
    }

    /**
     * Update quiz status (publish/unpublish)
     */
    public boolean updateStatus(Integer id, boolean isActive) throws SQLException {
        String sql = "UPDATE quiz SET is_active = ? WHERE id = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setBoolean(1, isActive);
            stmt.setInt(2, id);

            return stmt.executeUpdate() > 0;
        }
    }

    /**
     * Delete quiz
     */
    public boolean delete(Integer id) throws SQLException {
        String sql = "DELETE FROM quiz WHERE id = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, id);
            return stmt.executeUpdate() > 0;
        }
    }

    /**
     * Count total quizzes
     */
    public int countAll() throws SQLException {
        String sql = "SELECT COUNT(*) FROM quiz";

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
     * Count active quizzes
     */
    public int countActive() throws SQLException {
        String sql = "SELECT COUNT(*) FROM quiz WHERE is_active = true";

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
     * Get active quizzes for a specific tag (or all if tag is null/empty)
     * Note: target_tag filtering disabled for backward compatibility
     */
    public List<Quiz> findActiveByTag(String userTag) throws SQLException {
        // For backward compatibility, just return all active quizzes
        return findActive();
    }

    /**
     * Map ResultSet to Quiz object
     */
    private Quiz mapResultSetToQuiz(ResultSet rs) throws SQLException {
        Quiz quiz = new Quiz();
        quiz.setId(rs.getInt("id"));
        quiz.setTitle(rs.getString("title"));
        quiz.setDescription(rs.getString("description"));
        quiz.setDuration(rs.getInt("duration"));
        quiz.setIsActive(rs.getBoolean("is_active"));
        quiz.setCreatedBy(rs.getInt("created_by"));
        quiz.setCreatedByName(rs.getString("created_by_name"));

        Timestamp deadline = rs.getTimestamp("deadline");
        if (deadline != null) {
            quiz.setDeadline(deadline.toLocalDateTime());
        }

        // target_tag not selected in queries for backward compatibility
        quiz.setTargetTag(null);

        Timestamp createdAt = rs.getTimestamp("created_at");
        if (createdAt != null) {
            quiz.setCreatedAt(createdAt.toLocalDateTime());
        }

        Timestamp updatedAt = rs.getTimestamp("updated_at");
        if (updatedAt != null) {
            quiz.setUpdatedAt(updatedAt.toLocalDateTime());
        }

        quiz.setQuestionCount(rs.getInt("question_count"));
        return quiz;
    }
}
