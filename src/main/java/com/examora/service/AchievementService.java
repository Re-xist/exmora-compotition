package com.examora.service;

import com.examora.dao.AchievementDAO;
import com.examora.dao.SubmissionDAO;
import com.examora.dao.UserDAO;
import com.examora.model.Achievement;
import com.examora.model.User;
import com.examora.model.UserAchievement;
import com.examora.model.Submission;

import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * AchievementService - Business logic for achievements and badges
 */
public class AchievementService {
    private AchievementDAO achievementDAO;
    private SubmissionDAO submissionDAO;
    private UserDAO userDAO;

    public AchievementService() {
        this.achievementDAO = new AchievementDAO();
        this.submissionDAO = new SubmissionDAO();
        this.userDAO = new UserDAO();
    }

    /**
     * Check and award achievements after quiz submission
     * @return List of newly earned achievements
     */
    public List<Achievement> checkAndAwardAchievements(Integer userId, Integer quizId, double score, int timeSpent, int duration)
            throws ServiceException {
        List<Achievement> newAchievements = new ArrayList<>();

        try {
            // Get user's quiz statistics
            int totalQuizzes = submissionDAO.countCompletedByUserId(userId);
            int perfectScores = submissionDAO.countPerfectScoresByUserId(userId);

            // Check score achievements
            checkScoreAchievements(userId, score, newAchievements);

            // Check speed achievements
            checkSpeedAchievements(userId, timeSpent, duration, newAchievements);

            // Check quantity achievements
            checkQuantityAchievements(userId, totalQuizzes, newAchievements);

            // Check special achievements
            checkSpecialAchievements(userId, totalQuizzes, perfectScores, newAchievements);

            // Update user statistics
            updateUserStatistics(userId, totalQuizzes, perfectScores);

        } catch (SQLException e) {
            throw new ServiceException("Gagal memeriksa achievements: " + e.getMessage(), e);
        }

        return newAchievements;
    }

    /**
     * Check score-based achievements
     */
    private void checkScoreAchievements(Integer userId, double score, List<Achievement> newAchievements)
            throws SQLException {
        List<Achievement> scoreAchievements = achievementDAO.findByCategory("score");

        for (Achievement achievement : scoreAchievements) {
            if (achievementDAO.hasAchievement(userId, achievement.getId())) {
                continue;
            }

            boolean earned = false;

            switch (achievement.getConditionType()) {
                case "PERFECT_SCORE":
                    earned = score >= 100;
                    break;
                case "EXCELLENT_SCORE":
                    earned = score >= achievement.getConditionValue();
                    break;
                case "GREAT_SCORE":
                    earned = score >= achievement.getConditionValue();
                    break;
            }

            if (earned) {
                awardAchievement(userId, achievement.getId());
                newAchievements.add(achievement);
            }
        }
    }

    /**
     * Check speed-based achievements
     */
    private void checkSpeedAchievements(Integer userId, int timeSpent, int duration, List<Achievement> newAchievements)
            throws SQLException {
        if (duration <= 0) return;

        List<Achievement> speedAchievements = achievementDAO.findByCategory("speed");
        double timePercentage = (timeSpent / 60.0) / duration * 100; // timeSpent is in seconds

        for (Achievement achievement : speedAchievements) {
            if (achievementDAO.hasAchievement(userId, achievement.getId())) {
                continue;
            }

            boolean earned = false;

            switch (achievement.getConditionType()) {
                case "QUICK_TIME":
                    earned = timePercentage < achievement.getConditionValue();
                    break;
                case "VERY_QUICK_TIME":
                    earned = timePercentage < achievement.getConditionValue();
                    break;
            }

            if (earned) {
                awardAchievement(userId, achievement.getId());
                newAchievements.add(achievement);
            }
        }
    }

    /**
     * Check quantity-based achievements
     */
    private void checkQuantityAchievements(Integer userId, int totalQuizzes, List<Achievement> newAchievements)
            throws SQLException {
        List<Achievement> quantityAchievements = achievementDAO.findByCategory("quantity");

        for (Achievement achievement : quantityAchievements) {
            if (achievementDAO.hasAchievement(userId, achievement.getId())) {
                continue;
            }

            if ("QUIZ_COUNT".equals(achievement.getConditionType()) &&
                totalQuizzes >= achievement.getConditionValue()) {
                awardAchievement(userId, achievement.getId());
                newAchievements.add(achievement);
            }
        }
    }

    /**
     * Check special achievements
     */
    private void checkSpecialAchievements(Integer userId, int totalQuizzes, int perfectScores, List<Achievement> newAchievements)
            throws SQLException {
        List<Achievement> specialAchievements = achievementDAO.findByCategory("special");

        for (Achievement achievement : specialAchievements) {
            if (achievementDAO.hasAchievement(userId, achievement.getId())) {
                continue;
            }

            boolean earned = false;

            switch (achievement.getConditionType()) {
                case "FIRST_QUIZ":
                    earned = totalQuizzes >= 1;
                    break;
                case "PERFECT_STREAK":
                    // Check if user has required consecutive perfect scores
                    earned = checkPerfectStreak(userId, achievement.getConditionValue());
                    break;
            }

            if (earned) {
                awardAchievement(userId, achievement.getId());
                newAchievements.add(achievement);
            }
        }
    }

    /**
     * Check if user has consecutive perfect scores
     */
    private boolean checkPerfectStreak(Integer userId, int requiredStreak) throws SQLException {
        // Get recent submissions ordered by date
        List<Submission> recentSubmissions = submissionDAO.findByUserId(userId);

        int streak = 0;
        for (Submission sub : recentSubmissions) {
            if (sub.getScore() != null && sub.getScore() >= 100) {
                streak++;
                if (streak >= requiredStreak) {
                    return true;
                }
            } else {
                streak = 0;
            }
        }

        return false;
    }

    /**
     * Award an achievement to a user
     */
    public void awardAchievement(Integer userId, Integer achievementId) throws SQLException {
        if (!achievementDAO.hasAchievement(userId, achievementId)) {
            achievementDAO.awardAchievement(userId, achievementId);
        }
    }

    /**
     * Get user's achievements
     */
    public List<UserAchievement> getUserAchievements(Integer userId) throws ServiceException {
        try {
            return achievementDAO.getUserAchievements(userId);
        } catch (SQLException e) {
            throw new ServiceException("Gagal mengambil achievements: " + e.getMessage(), e);
        }
    }

    /**
     * Get all achievements (admin)
     */
    public List<Achievement> getAllAchievements() throws ServiceException {
        try {
            return achievementDAO.findAll();
        } catch (SQLException e) {
            throw new ServiceException("Gagal mengambil daftar achievements: " + e.getMessage(), e);
        }
    }

    /**
     * Get active achievements
     */
    public List<Achievement> getActiveAchievements() throws ServiceException {
        try {
            return achievementDAO.findActive();
        } catch (SQLException e) {
            throw new ServiceException("Gagal mengambil daftar achievements: " + e.getMessage(), e);
        }
    }

    /**
     * Create achievement (admin)
     */
    public Achievement createAchievement(String name, String description, String icon, String color,
                                          String category, String conditionType, Integer conditionValue, Integer points)
            throws ServiceException {
        try {
            Achievement achievement = new Achievement(name, description, icon, color, category, conditionType, conditionValue, points);
            return achievementDAO.create(achievement);
        } catch (SQLException e) {
            throw new ServiceException("Gagal membuat achievement: " + e.getMessage(), e);
        }
    }

    /**
     * Update achievement (admin)
     */
    public Achievement updateAchievement(Integer id, String name, String description, String icon, String color,
                                          String category, String conditionType, Integer conditionValue, Integer points, Boolean isActive)
            throws ServiceException {
        try {
            Achievement achievement = achievementDAO.findById(id);
            if (achievement == null) {
                throw new ServiceException("Achievement tidak ditemukan");
            }

            achievement.setName(name);
            achievement.setDescription(description);
            achievement.setIcon(icon);
            achievement.setColor(color);
            achievement.setCategory(category);
            achievement.setConditionType(conditionType);
            achievement.setConditionValue(conditionValue);
            achievement.setPoints(points);
            achievement.setIsActive(isActive);

            if (!achievementDAO.update(achievement)) {
                throw new ServiceException("Gagal mengupdate achievement");
            }

            return achievement;
        } catch (SQLException e) {
            throw new ServiceException("Gagal mengupdate achievement: " + e.getMessage(), e);
        }
    }

    /**
     * Delete achievement (admin)
     */
    public void deleteAchievement(Integer id) throws ServiceException {
        try {
            if (!achievementDAO.delete(id)) {
                throw new ServiceException("Gagal menghapus achievement");
            }
        } catch (SQLException e) {
            throw new ServiceException("Gagal menghapus achievement: " + e.getMessage(), e);
        }
    }

    /**
     * Toggle achievement active status (admin)
     */
    public void toggleAchievementStatus(Integer id) throws ServiceException {
        try {
            Achievement achievement = achievementDAO.findById(id);
            if (achievement == null) {
                throw new ServiceException("Achievement tidak ditemukan");
            }

            achievement.setIsActive(!achievement.getIsActive());
            achievementDAO.update(achievement);
        } catch (SQLException e) {
            throw new ServiceException("Gagal mengubah status achievement: " + e.getMessage(), e);
        }
    }

    /**
     * Update user statistics
     */
    private void updateUserStatistics(Integer userId, int totalQuizzes, int perfectScores) throws SQLException {
        int totalPoints = achievementDAO.getUserTotalPoints(userId);
        userDAO.updateStatistics(userId, totalPoints, totalQuizzes, perfectScores);
    }

    /**
     * Get user's total points
     */
    public int getUserTotalPoints(Integer userId) throws ServiceException {
        try {
            return achievementDAO.getUserTotalPoints(userId);
        } catch (SQLException e) {
            throw new ServiceException("Gagal mengambil total poin: " + e.getMessage(), e);
        }
    }

    /**
     * Count user's achievements
     */
    public int countUserAchievements(Integer userId) throws ServiceException {
        try {
            return achievementDAO.countUserAchievements(userId);
        } catch (SQLException e) {
            throw new ServiceException("Gagal menghitung achievements: " + e.getMessage(), e);
        }
    }

    /**
     * Get leaderboard (top users by points)
     */
    public List<Map<String, Object>> getLeaderboard(int limit) throws ServiceException {
        try {
            return userDAO.getTopUsersByPoints(limit);
        } catch (SQLException e) {
            throw new ServiceException("Gagal mengambil leaderboard: " + e.getMessage(), e);
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
