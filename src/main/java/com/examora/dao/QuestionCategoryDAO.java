package com.examora.dao;

import com.examora.model.QuestionCategory;
import com.examora.util.DBUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * QuestionCategoryDAO - Database operations for question categories
 */
public class QuestionCategoryDAO {

    /**
     * Create a new category
     */
    public QuestionCategory create(QuestionCategory category) throws SQLException {
        String sql = "INSERT INTO question_categories (name, description, created_by) VALUES (?, ?, ?)";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            stmt.setString(1, category.getName());
            stmt.setString(2, category.getDescription());
            stmt.setInt(3, category.getCreatedBy());

            int affectedRows = stmt.executeUpdate();

            if (affectedRows == 0) {
                throw new SQLException("Creating category failed, no rows affected.");
            }

            try (ResultSet generatedKeys = stmt.getGeneratedKeys()) {
                if (generatedKeys.next()) {
                    category.setId(generatedKeys.getInt(1));
                } else {
                    throw new SQLException("Creating category failed, no ID obtained.");
                }
            }

            return category;
        }
    }

    /**
     * Find category by ID
     */
    public QuestionCategory findById(Integer id) throws SQLException {
        String sql = "SELECT c.*, u.name as created_by_name " +
                     "FROM question_categories c " +
                     "LEFT JOIN users u ON c.created_by = u.id " +
                     "WHERE c.id = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, id);

            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToCategory(rs);
                }
            }
        }
        return null;
    }

    /**
     * Find all categories
     */
    public List<QuestionCategory> findAll() throws SQLException {
        String sql = "SELECT c.*, u.name as created_by_name, " +
                     "(SELECT COUNT(*) FROM questions WHERE category_id = c.id) as question_count " +
                     "FROM question_categories c " +
                     "LEFT JOIN users u ON c.created_by = u.id " +
                     "ORDER BY c.name";
        List<QuestionCategory> categories = new ArrayList<>();

        try (Connection conn = DBUtil.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {

            while (rs.next()) {
                categories.add(mapResultSetToCategory(rs));
            }
        }
        return categories;
    }

    /**
     * Update category
     */
    public boolean update(QuestionCategory category) throws SQLException {
        String sql = "UPDATE question_categories SET name = ?, description = ? WHERE id = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, category.getName());
            stmt.setString(2, category.getDescription());
            stmt.setInt(3, category.getId());

            return stmt.executeUpdate() > 0;
        }
    }

    /**
     * Delete category
     */
    public boolean delete(Integer id) throws SQLException {
        String sql = "DELETE FROM question_categories WHERE id = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, id);
            return stmt.executeUpdate() > 0;
        }
    }

    /**
     * Count questions in category
     */
    public int countQuestions(Integer categoryId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM questions WHERE category_id = ?";

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
     * Map ResultSet to QuestionCategory object
     */
    private QuestionCategory mapResultSetToCategory(ResultSet rs) throws SQLException {
        QuestionCategory category = new QuestionCategory();
        category.setId(rs.getInt("id"));
        category.setName(rs.getString("name"));
        category.setDescription(rs.getString("description"));
        category.setCreatedBy(rs.getInt("created_by"));

        Timestamp createdAt = rs.getTimestamp("created_at");
        if (createdAt != null) {
            category.setCreatedAt(createdAt.toLocalDateTime());
        }

        Timestamp updatedAt = rs.getTimestamp("updated_at");
        if (updatedAt != null) {
            category.setUpdatedAt(updatedAt.toLocalDateTime());
        }

        // Additional fields
        try {
            category.setCreatedByName(rs.getString("created_by_name"));
            category.setQuestionCount(rs.getInt("question_count"));
        } catch (SQLException e) {
            // Ignore if column doesn't exist
        }

        return category;
    }
}
