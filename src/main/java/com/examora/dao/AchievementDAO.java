package com.examora.dao;

import com.examora.model.Achievement;
import com.examora.model.UserAchievement;
import com.examora.util.DBUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * AchievementDAO - Database operations for achievements
 */
public class AchievementDAO {

    /**
     * Create a new achievement
     */
    public Achievement create(Achievement achievement) throws SQLException {
        String sql = "INSERT INTO achievements (name, description, icon, color, category, " +
                     "condition_type, condition_value, points, is_active) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            stmt.setString(1, achievement.getName());
            stmt.setString(2, achievement.getDescription());
            stmt.setString(3, achievement.getIcon());
            stmt.setString(4, achievement.getColor());
            stmt.setString(5, achievement.getCategory());
            stmt.setString(6, achievement.getConditionType());
            stmt.setInt(7, achievement.getConditionValue());
            stmt.setInt(8, achievement.getPoints());
            stmt.setBoolean(9, achievement.getIsActive());

            int affectedRows = stmt.executeUpdate();

            if (affectedRows == 0) {
                throw new SQLException("Creating achievement failed, no rows affected.");
            }

            try (ResultSet generatedKeys = stmt.getGeneratedKeys()) {
                if (generatedKeys.next()) {
                    achievement.setId(generatedKeys.getInt(1));
                } else {
                    throw new SQLException("Creating achievement failed, no ID obtained.");
                }
            }

            return achievement;
        }
    }

    /**
     * Find achievement by ID
     */
    public Achievement findById(Integer id) throws SQLException {
        String sql = "SELECT * FROM achievements WHERE id = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, id);

            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToAchievement(rs);
                }
            }
        }
        return null;
    }

    /**
     * Find all achievements
     */
    public List<Achievement> findAll() throws SQLException {
        String sql = "SELECT * FROM achievements ORDER BY category, points";
        List<Achievement> achievements = new ArrayList<>();

        try (Connection conn = DBUtil.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {

            while (rs.next()) {
                achievements.add(mapResultSetToAchievement(rs));
            }
        }
        return achievements;
    }

    /**
     * Find active achievements
     */
    public List<Achievement> findActive() throws SQLException {
        String sql = "SELECT * FROM achievements WHERE is_active = TRUE ORDER BY category, points";
        List<Achievement> achievements = new ArrayList<>();

        try (Connection conn = DBUtil.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {

            while (rs.next()) {
                achievements.add(mapResultSetToAchievement(rs));
            }
        }
        return achievements;
    }

    /**
     * Find achievements by category
     */
    public List<Achievement> findByCategory(String category) throws SQLException {
        String sql = "SELECT * FROM achievements WHERE category = ? AND is_active = TRUE ORDER BY points";
        List<Achievement> achievements = new ArrayList<>();

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, category);

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    achievements.add(mapResultSetToAchievement(rs));
                }
            }
        }
        return achievements;
    }

    /**
     * Find achievements by condition type
     */
    public List<Achievement> findByConditionType(String conditionType) throws SQLException {
        String sql = "SELECT * FROM achievements WHERE condition_type = ? AND is_active = TRUE";
        List<Achievement> achievements = new ArrayList<>();

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, conditionType);

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    achievements.add(mapResultSetToAchievement(rs));
                }
            }
        }
        return achievements;
    }

    /**
     * Update achievement
     */
    public boolean update(Achievement achievement) throws SQLException {
        String sql = "UPDATE achievements SET name = ?, description = ?, icon = ?, color = ?, " +
                     "category = ?, condition_type = ?, condition_value = ?, points = ?, is_active = ? " +
                     "WHERE id = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, achievement.getName());
            stmt.setString(2, achievement.getDescription());
            stmt.setString(3, achievement.getIcon());
            stmt.setString(4, achievement.getColor());
            stmt.setString(5, achievement.getCategory());
            stmt.setString(6, achievement.getConditionType());
            stmt.setInt(7, achievement.getConditionValue());
            stmt.setInt(8, achievement.getPoints());
            stmt.setBoolean(9, achievement.getIsActive());
            stmt.setInt(10, achievement.getId());

            return stmt.executeUpdate() > 0;
        }
    }

    /**
     * Delete achievement
     */
    public boolean delete(Integer id) throws SQLException {
        String sql = "DELETE FROM achievements WHERE id = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, id);
            return stmt.executeUpdate() > 0;
        }
    }

    // ==================== User Achievement Methods ====================

    /**
     * Award achievement to user
     */
    public UserAchievement awardAchievement(Integer userId, Integer achievementId) throws SQLException {
        String sql = "INSERT INTO user_achievements (user_id, achievement_id) VALUES (?, ?)";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            stmt.setInt(1, userId);
            stmt.setInt(2, achievementId);

            int affectedRows = stmt.executeUpdate();

            if (affectedRows == 0) {
                throw new SQLException("Awarding achievement failed, no rows affected.");
            }

            try (ResultSet generatedKeys = stmt.getGeneratedKeys()) {
                if (generatedKeys.next()) {
                    UserAchievement ua = new UserAchievement(userId, achievementId);
                    ua.setId(generatedKeys.getInt(1));
                    return ua;
                }
            }
        }
        return null;
    }

    /**
     * Check if user has achievement
     */
    public boolean hasAchievement(Integer userId, Integer achievementId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM user_achievements WHERE user_id = ? AND achievement_id = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, userId);
            stmt.setInt(2, achievementId);

            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        }
        return false;
    }

    /**
     * Get user's achievements
     */
    public List<UserAchievement> getUserAchievements(Integer userId) throws SQLException {
        String sql = "SELECT ua.*, a.name, a.description, a.icon, a.color, a.category, a.points " +
                     "FROM user_achievements ua " +
                     "JOIN achievements a ON ua.achievement_id = a.id " +
                     "WHERE ua.user_id = ? " +
                     "ORDER BY ua.earned_at DESC";
        List<UserAchievement> userAchievements = new ArrayList<>();

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, userId);

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    userAchievements.add(mapResultSetToUserAchievement(rs));
                }
            }
        }
        return userAchievements;
    }

    /**
     * Count user's achievements
     */
    public int countUserAchievements(Integer userId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM user_achievements WHERE user_id = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, userId);

            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }
        return 0;
    }

    /**
     * Get user's total points from achievements
     */
    public int getUserTotalPoints(Integer userId) throws SQLException {
        String sql = "SELECT COALESCE(SUM(a.points), 0) " +
                     "FROM user_achievements ua " +
                     "JOIN achievements a ON ua.achievement_id = a.id " +
                     "WHERE ua.user_id = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, userId);

            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }
        return 0;
    }

    /**
     * Map ResultSet to Achievement object
     */
    private Achievement mapResultSetToAchievement(ResultSet rs) throws SQLException {
        Achievement achievement = new Achievement();
        achievement.setId(rs.getInt("id"));
        achievement.setName(rs.getString("name"));
        achievement.setDescription(rs.getString("description"));
        achievement.setIcon(rs.getString("icon"));
        achievement.setColor(rs.getString("color"));
        achievement.setCategory(rs.getString("category"));
        achievement.setConditionType(rs.getString("condition_type"));
        achievement.setConditionValue(rs.getInt("condition_value"));
        achievement.setPoints(rs.getInt("points"));
        achievement.setIsActive(rs.getBoolean("is_active"));

        Timestamp createdAt = rs.getTimestamp("created_at");
        if (createdAt != null) {
            achievement.setCreatedAt(createdAt.toLocalDateTime());
        }

        return achievement;
    }

    /**
     * Map ResultSet to UserAchievement object
     */
    private UserAchievement mapResultSetToUserAchievement(ResultSet rs) throws SQLException {
        UserAchievement ua = new UserAchievement();
        ua.setId(rs.getInt("id"));
        ua.setUserId(rs.getInt("user_id"));
        ua.setAchievementId(rs.getInt("achievement_id"));

        Timestamp earnedAt = rs.getTimestamp("earned_at");
        if (earnedAt != null) {
            ua.setEarnedAt(earnedAt.toLocalDateTime());
        }

        // Create embedded achievement
        Achievement achievement = new Achievement();
        achievement.setId(rs.getInt("achievement_id"));
        achievement.setName(rs.getString("name"));
        achievement.setDescription(rs.getString("description"));
        achievement.setIcon(rs.getString("icon"));
        achievement.setColor(rs.getString("color"));
        achievement.setCategory(rs.getString("category"));
        achievement.setPoints(rs.getInt("points"));
        ua.setAchievement(achievement);

        return ua;
    }
}
