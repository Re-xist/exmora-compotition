package com.examora.service;

import com.examora.dao.NotificationDAO;
import com.examora.dao.UserDAO;
import com.examora.dao.QuizDAO;
import com.examora.model.NotificationTemplate;
import com.examora.model.NotificationQueue;
import com.examora.model.User;
import com.examora.model.Quiz;

import java.sql.SQLException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * NotificationService - Business logic for notifications
 */
public class NotificationService {
    private NotificationDAO notificationDAO;
    private UserDAO userDAO;
    private QuizDAO quizDAO;
    private EmailService emailService;

    public NotificationService() {
        this.notificationDAO = new NotificationDAO();
        this.userDAO = new UserDAO();
        this.quizDAO = new QuizDAO();
        this.emailService = new EmailService();
    }

    // ==================== Template Methods ====================

    /**
     * Create a notification template
     */
    public NotificationTemplate createTemplate(String name, String subject, String body, String type)
            throws ServiceException {
        validateTemplate(name, subject, body, type);

        try {
            NotificationTemplate template = new NotificationTemplate(name, subject, body, type);
            return notificationDAO.createTemplate(template);
        } catch (SQLException e) {
            throw new ServiceException("Gagal membuat template: " + e.getMessage(), e);
        }
    }

    /**
     * Get template by ID
     */
    public NotificationTemplate getTemplateById(Integer id) throws ServiceException {
        try {
            NotificationTemplate template = notificationDAO.findTemplateById(id);
            if (template == null) {
                throw new ServiceException("Template tidak ditemukan");
            }
            return template;
        } catch (SQLException e) {
            throw new ServiceException("Gagal mengambil template: " + e.getMessage(), e);
        }
    }

    /**
     * Get all templates
     */
    public List<NotificationTemplate> getAllTemplates() throws ServiceException {
        try {
            return notificationDAO.findAllTemplates();
        } catch (SQLException e) {
            throw new ServiceException("Gagal mengambil daftar template: " + e.getMessage(), e);
        }
    }

    /**
     * Update template
     */
    public NotificationTemplate updateTemplate(Integer id, String name, String subject, String body,
                                                String type, Boolean isActive) throws ServiceException {
        validateTemplate(name, subject, body, type);

        try {
            NotificationTemplate template = notificationDAO.findTemplateById(id);
            if (template == null) {
                throw new ServiceException("Template tidak ditemukan");
            }

            template.setName(name);
            template.setSubject(subject);
            template.setBody(body);
            template.setType(type);
            template.setIsActive(isActive);

            if (!notificationDAO.updateTemplate(template)) {
                throw new ServiceException("Gagal mengupdate template");
            }

            return template;
        } catch (SQLException e) {
            throw new ServiceException("Gagal mengupdate template: " + e.getMessage(), e);
        }
    }

    /**
     * Delete template
     */
    public void deleteTemplate(Integer id) throws ServiceException {
        try {
            if (!notificationDAO.deleteTemplate(id)) {
                throw new ServiceException("Gagal menghapus template");
            }
        } catch (SQLException e) {
            throw new ServiceException("Gagal menghapus template: " + e.getMessage(), e);
        }
    }

    // ==================== Queue Methods ====================

    /**
     * Queue notification for a user
     */
    public void queueNotification(Integer userId, String subject, String body) throws ServiceException {
        try {
            NotificationQueue notification = new NotificationQueue(userId, subject, body);
            notificationDAO.addToQueue(notification);
        } catch (SQLException e) {
            throw new ServiceException("Gagal menambahkan notifikasi ke antrian: " + e.getMessage(), e);
        }
    }

    /**
     * Queue notification for multiple users
     */
    public void queueNotificationForUsers(List<Integer> userIds, String subject, String body)
            throws ServiceException {
        for (Integer userId : userIds) {
            queueNotification(userId, subject, body);
        }
    }

    /**
     * Queue notification for users by tag
     */
    public void queueNotificationForTag(String tag, String subject, String body) throws ServiceException {
        try {
            List<User> users = userDAO.findByTag(tag);
            for (User user : users) {
                queueNotification(user.getId(), subject, body);
            }
        } catch (SQLException e) {
            throw new ServiceException("Gagal mengirim notifikasi: " + e.getMessage(), e);
        }
    }

    /**
     * Queue notification for all peserta users
     */
    public void queueNotificationForAllPeserta(String subject, String body) throws ServiceException {
        try {
            List<User> users = userDAO.findByRole("peserta");
            for (User user : users) {
                queueNotification(user.getId(), subject, body);
            }
        } catch (SQLException e) {
            throw new ServiceException("Gagal mengirim notifikasi: " + e.getMessage(), e);
        }
    }

    /**
     * Get pending notifications
     */
    public List<NotificationQueue> getPendingNotifications(int limit) throws ServiceException {
        try {
            return notificationDAO.getPendingNotifications(limit);
        } catch (SQLException e) {
            throw new ServiceException("Gagal mengambil notifikasi pending: " + e.getMessage(), e);
        }
    }

    /**
     * Get queue with filters
     */
    public List<NotificationQueue> getQueueWithFilters(String status, int page, int pageSize)
            throws ServiceException {
        try {
            int offset = (page - 1) * pageSize;
            return notificationDAO.getQueueWithFilters(status, pageSize, offset);
        } catch (SQLException e) {
            throw new ServiceException("Gagal mengambil antrian notifikasi: " + e.getMessage(), e);
        }
    }

    /**
     * Count queue with filters
     */
    public int countQueueWithFilters(String status) throws ServiceException {
        try {
            return notificationDAO.countQueueWithFilters(status);
        } catch (SQLException e) {
            throw new ServiceException("Gagal menghitung antrian: " + e.getMessage(), e);
        }
    }

    // ==================== Process Notifications ====================

    /**
     * Process pending notifications (send emails)
     */
    public int processPendingNotifications(int batchSize) throws ServiceException {
        try {
            List<NotificationQueue> pending = notificationDAO.getPendingNotifications(batchSize);
            int sentCount = 0;

            for (NotificationQueue notification : pending) {
                try {
                    User user = userDAO.findById(notification.getUserId());
                    if (user != null && user.getEmail() != null) {
                        boolean sent = emailService.sendEmail(user.getEmail(), notification.getSubject(), notification.getBody());
                        if (sent) {
                            notificationDAO.updateQueueStatus(notification.getId(), "sent", null);
                            sentCount++;
                        } else {
                            notificationDAO.updateQueueStatus(notification.getId(), "failed", "Failed to send email");
                        }
                    } else {
                        notificationDAO.updateQueueStatus(notification.getId(), "failed", "User not found or no email");
                    }
                } catch (Exception e) {
                    notificationDAO.updateQueueStatus(notification.getId(), "failed", e.getMessage());
                }
            }

            return sentCount;
        } catch (SQLException e) {
            throw new ServiceException("Gagal memproses notifikasi: " + e.getMessage(), e);
        }
    }

    // ==================== Notification Triggers ====================

    /**
     * Send new quiz notification
     */
    public void sendNewQuizNotification(Integer quizId) throws ServiceException {
        try {
            Quiz quiz = quizDAO.findById(quizId);
            if (quiz == null) {
                throw new ServiceException("Quiz tidak ditemukan");
            }

            NotificationTemplate template = notificationDAO.findTemplateByType("new_quiz");
            if (template == null) {
                return; // No template configured
            }

            String subject = replaceVariables(template.getSubject(), createQuizVariables(quiz));
            String body = replaceVariables(template.getBody(), createQuizVariables(quiz));

            // Send to target tag or all peserta
            if (quiz.getTargetTag() != null && !quiz.getTargetTag().isEmpty()) {
                String[] tags = quiz.getTargetTag().split(",");
                for (String tag : tags) {
                    queueNotificationForTag(tag.trim(), subject, body);
                }
            } else {
                queueNotificationForAllPeserta(subject, body);
            }
        } catch (SQLException e) {
            throw new ServiceException("Gagal mengirim notifikasi quiz baru: " + e.getMessage(), e);
        }
    }

    /**
     * Send result notification
     */
    public void sendResultNotification(Integer userId, Integer quizId, double score,
                                        int correctAnswers, int totalQuestions, int timeSpent)
            throws ServiceException {
        try {
            User user = userDAO.findById(userId);
            Quiz quiz = quizDAO.findById(quizId);

            if (user == null || quiz == null) {
                return;
            }

            NotificationTemplate template = notificationDAO.findTemplateByType("result");
            if (template == null) {
                return;
            }

            Map<String, String> variables = createQuizVariables(quiz);
            variables.put("user_name", user.getName());
            variables.put("score", String.format("%.0f", score));
            variables.put("correct_answers", String.valueOf(correctAnswers));
            variables.put("total_questions", String.valueOf(totalQuestions));
            variables.put("time_spent", formatTimeSpent(timeSpent));

            String subject = replaceVariables(template.getSubject(), variables);
            String body = replaceVariables(template.getBody(), variables);

            queueNotification(userId, subject, body);
        } catch (SQLException e) {
            throw new ServiceException("Gagal mengirim notifikasi hasil: " + e.getMessage(), e);
        }
    }

    /**
     * Send achievement notification
     */
    public void sendAchievementNotification(Integer userId, String achievementName,
                                             String achievementDescription, int points)
            throws ServiceException {
        try {
            User user = userDAO.findById(userId);
            if (user == null) {
                return;
            }

            NotificationTemplate template = notificationDAO.findTemplateByType("achievement");
            if (template == null) {
                return;
            }

            Map<String, String> variables = new HashMap<>();
            variables.put("user_name", user.getName());
            variables.put("achievement_name", achievementName);
            variables.put("achievement_description", achievementDescription);
            variables.put("points", String.valueOf(points));

            String subject = replaceVariables(template.getSubject(), variables);
            String body = replaceVariables(template.getBody(), variables);

            queueNotification(userId, subject, body);
        } catch (SQLException e) {
            throw new ServiceException("Gagal mengirim notifikasi achievement: " + e.getMessage(), e);
        }
    }

    /**
     * Send deadline reminder
     */
    public void sendDeadlineReminders() throws ServiceException {
        try {
            // Get quizzes with deadline in next 24 hours
            List<Quiz> upcomingQuizzes = quizDAO.findUpcomingDeadlines(24);

            NotificationTemplate template = notificationDAO.findTemplateByType("deadline_reminder");
            if (template == null) {
                return;
            }

            for (Quiz quiz : upcomingQuizzes) {
                // Get users who haven't submitted
                List<User> pendingUsers = getPendingUsersForQuiz(quiz);

                for (User user : pendingUsers) {
                    Map<String, String> variables = createQuizVariables(quiz);
                    variables.put("user_name", user.getName());
                    variables.put("time_remaining", calculateTimeRemaining(quiz.getDeadline()));

                    String subject = replaceVariables(template.getSubject(), variables);
                    String body = replaceVariables(template.getBody(), variables);

                    queueNotification(user.getId(), subject, body);
                }
            }
        } catch (SQLException e) {
            throw new ServiceException("Gagal mengirim reminder deadline: " + e.getMessage(), e);
        }
    }

    // ==================== Helper Methods ====================

    /**
     * Validate template data
     */
    private void validateTemplate(String name, String subject, String body, String type)
            throws ServiceException {
        if (name == null || name.trim().isEmpty()) {
            throw new ServiceException("Nama template tidak boleh kosong");
        }
        if (subject == null || subject.trim().isEmpty()) {
            throw new ServiceException("Subject tidak boleh kosong");
        }
        if (body == null || body.trim().isEmpty()) {
            throw new ServiceException("Body tidak boleh kosong");
        }
        if (type == null || type.trim().isEmpty()) {
            throw new ServiceException("Type tidak boleh kosong");
        }
    }

    /**
     * Create quiz variables map
     */
    private Map<String, String> createQuizVariables(Quiz quiz) {
        Map<String, String> variables = new HashMap<>();
        variables.put("quiz_title", quiz.getTitle());
        variables.put("duration", String.valueOf(quiz.getDuration()));
        variables.put("question_count", String.valueOf(quiz.getQuestionCount()));
        variables.put("deadline", quiz.getFormattedDeadline() != null ? quiz.getFormattedDeadline() : "Tidak ada deadline");
        return variables;
    }

    /**
     * Replace variables in template
     */
    private String replaceVariables(String template, Map<String, String> variables) {
        if (template == null) return null;

        String result = template;
        for (Map.Entry<String, String> entry : variables.entrySet()) {
            result = result.replace("{{" + entry.getKey() + "}}", entry.getValue());
        }
        return result;
    }

    /**
     * Format time spent
     */
    private String formatTimeSpent(int seconds) {
        int minutes = seconds / 60;
        int secs = seconds % 60;
        if (minutes > 60) {
            int hours = minutes / 60;
            minutes = minutes % 60;
            return String.format("%d jam %d menit", hours, minutes);
        }
        return String.format("%d menit %d detik", minutes, secs);
    }

    /**
     * Calculate time remaining
     */
    private String calculateTimeRemaining(LocalDateTime deadline) {
        if (deadline == null) return "Unknown";

        LocalDateTime now = LocalDateTime.now();
        long hours = java.time.Duration.between(now, deadline).toHours();

        if (hours < 0) return "Sudah lewat";
        if (hours < 1) return "Kurang dari 1 jam";
        if (hours < 24) return hours + " jam";

        long days = hours / 24;
        return days + " hari";
    }

    /**
     * Get pending users for quiz
     */
    private List<User> getPendingUsersForQuiz(Quiz quiz) throws SQLException {
        List<User> allUsers;
        if (quiz.getTargetTag() != null && !quiz.getTargetTag().isEmpty()) {
            allUsers = userDAO.findByTag(quiz.getTargetTag());
        } else {
            allUsers = userDAO.findByRole("peserta");
        }

        // Filter out users who have already submitted
        List<User> pendingUsers = new ArrayList<>();
        for (User user : allUsers) {
            // Check if user has submitted
            // This would need a method in SubmissionDAO
            pendingUsers.add(user); // Simplified for now
        }

        return pendingUsers;
    }

    /**
     * Clean up old notifications
     */
    public int cleanupOldNotifications(int daysToKeep) throws ServiceException {
        try {
            return notificationDAO.deleteOldNotifications(daysToKeep);
        } catch (SQLException e) {
            throw new ServiceException("Gagal menghapus notifikasi lama: " + e.getMessage(), e);
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
