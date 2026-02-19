package com.examora.dao;

import com.examora.model.Answer;
import com.examora.model.Submission;
import com.examora.util.DBUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Submission Data Access Object - Handles database operations for submissions
 */
public class SubmissionDAO {

    /**
     * Create a new submission
     */
    public Submission create(Submission submission) throws SQLException {
        String sql = "INSERT INTO submissions (quiz_id, user_id, score, total_questions, correct_answers, started_at, status) VALUES (?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            stmt.setInt(1, submission.getQuizId());
            stmt.setInt(2, submission.getUserId());
            stmt.setDouble(3, submission.getScore());
            stmt.setInt(4, submission.getTotalQuestions());
            stmt.setInt(5, submission.getCorrectAnswers());
            stmt.setTimestamp(6, Timestamp.valueOf(submission.getStartedAt()));
            stmt.setString(7, submission.getStatus());

            int affectedRows = stmt.executeUpdate();

            if (affectedRows == 0) {
                throw new SQLException("Creating submission failed, no rows affected.");
            }

            try (ResultSet generatedKeys = stmt.getGeneratedKeys()) {
                if (generatedKeys.next()) {
                    submission.setId(generatedKeys.getInt(1));
                } else {
                    throw new SQLException("Creating submission failed, no ID obtained.");
                }
            }

            return submission;
        }
    }

    /**
     * Find submission by ID
     */
    public Submission findById(Integer id) throws SQLException {
        String sql = "SELECT s.*, u.name as user_name, q.title as quiz_title " +
                     "FROM submissions s " +
                     "LEFT JOIN users u ON s.user_id = u.id " +
                     "LEFT JOIN quiz q ON s.quiz_id = q.id " +
                     "WHERE s.id = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, id);

            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToSubmission(rs);
                }
            }
        }
        return null;
    }

    /**
     * Find submission by user and quiz
     */
    public Submission findByUserAndQuiz(Integer userId, Integer quizId) throws SQLException {
        String sql = "SELECT s.*, u.name as user_name, q.title as quiz_title " +
                     "FROM submissions s " +
                     "LEFT JOIN users u ON s.user_id = u.id " +
                     "LEFT JOIN quiz q ON s.quiz_id = q.id " +
                     "WHERE s.user_id = ? AND s.quiz_id = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, userId);
            stmt.setInt(2, quizId);

            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToSubmission(rs);
                }
            }
        }
        return null;
    }

    /**
     * Get all submissions for a quiz
     */
    public List<Submission> findByQuizId(Integer quizId) throws SQLException {
        String sql = "SELECT s.*, u.name as user_name, q.title as quiz_title " +
                     "FROM submissions s " +
                     "LEFT JOIN users u ON s.user_id = u.id " +
                     "LEFT JOIN quiz q ON s.quiz_id = q.id " +
                     "WHERE s.quiz_id = ? " +
                     "ORDER BY s.submitted_at DESC";
        List<Submission> submissions = new ArrayList<>();

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, quizId);

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    submissions.add(mapResultSetToSubmission(rs));
                }
            }
        }
        return submissions;
    }

    /**
     * Get all submissions for a user
     */
    public List<Submission> findByUserId(Integer userId) throws SQLException {
        String sql = "SELECT s.*, u.name as user_name, q.title as quiz_title " +
                     "FROM submissions s " +
                     "LEFT JOIN users u ON s.user_id = u.id " +
                     "LEFT JOIN quiz q ON s.quiz_id = q.id " +
                     "WHERE s.user_id = ? " +
                     "ORDER BY s.submitted_at DESC";
        List<Submission> submissions = new ArrayList<>();

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, userId);

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    submissions.add(mapResultSetToSubmission(rs));
                }
            }
        }
        return submissions;
    }

    /**
     * Get all submissions
     */
    public List<Submission> findAll() throws SQLException {
        String sql = "SELECT s.*, u.name as user_name, q.title as quiz_title " +
                     "FROM submissions s " +
                     "LEFT JOIN users u ON s.user_id = u.id " +
                     "LEFT JOIN quiz q ON s.quiz_id = q.id " +
                     "ORDER BY s.submitted_at DESC";
        List<Submission> submissions = new ArrayList<>();

        try (Connection conn = DBUtil.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {

            while (rs.next()) {
                submissions.add(mapResultSetToSubmission(rs));
            }
        }
        return submissions;
    }

    /**
     * Update submission (for completing)
     */
    public boolean update(Submission submission) throws SQLException {
        String sql = "UPDATE submissions SET score = ?, total_questions = ?, correct_answers = ?, submitted_at = ?, time_spent = ?, status = ? WHERE id = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setDouble(1, submission.getScore());
            stmt.setInt(2, submission.getTotalQuestions());
            stmt.setInt(3, submission.getCorrectAnswers());
            stmt.setTimestamp(4, submission.getSubmittedAt() != null ? Timestamp.valueOf(submission.getSubmittedAt()) : null);
            stmt.setInt(5, submission.getTimeSpent() != null ? submission.getTimeSpent() : 0);
            stmt.setString(6, submission.getStatus());
            stmt.setInt(7, submission.getId());

            return stmt.executeUpdate() > 0;
        }
    }

    /**
     * Save an answer
     */
    public boolean saveAnswer(Answer answer) throws SQLException {
        String sql = "INSERT INTO answers (submission_id, question_id, selected_answer, is_correct) VALUES (?, ?, ?, ?) " +
                     "ON DUPLICATE KEY UPDATE selected_answer = VALUES(selected_answer), is_correct = VALUES(is_correct)";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, answer.getSubmissionId());
            stmt.setInt(2, answer.getQuestionId());
            stmt.setString(3, answer.getSelectedAnswer());
            stmt.setBoolean(4, answer.getIsCorrect());

            return stmt.executeUpdate() > 0;
        }
    }

    /**
     * Get answers for a submission
     */
    public List<Answer> getAnswers(Integer submissionId) throws SQLException {
        String sql = "SELECT a.*, q.question_text, q.correct_answer " +
                     "FROM answers a " +
                     "LEFT JOIN questions q ON a.question_id = q.id " +
                     "WHERE a.submission_id = ?";
        List<Answer> answers = new ArrayList<>();

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, submissionId);

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Answer answer = new Answer();
                    answer.setId(rs.getInt("id"));
                    answer.setSubmissionId(rs.getInt("submission_id"));
                    answer.setQuestionId(rs.getInt("question_id"));
                    answer.setSelectedAnswer(rs.getString("selected_answer"));
                    answer.setIsCorrect(rs.getBoolean("is_correct"));
                    answer.setQuestionText(rs.getString("question_text"));
                    answer.setCorrectAnswer(rs.getString("correct_answer"));

                    Timestamp answeredAt = rs.getTimestamp("answered_at");
                    if (answeredAt != null) {
                        answer.setAnsweredAt(answeredAt.toLocalDateTime());
                    }

                    answers.add(answer);
                }
            }
        }
        return answers;
    }

    /**
     * Get submission statistics for a quiz
     */
    public Map<String, Object> getStatistics(Integer quizId) throws SQLException {
        Map<String, Object> stats = new HashMap<>();

        // Initialize default values
        stats.put("totalSubmissions", 0);
        stats.put("averageScore", 0.0);
        stats.put("highestScore", 0.0);
        stats.put("lowestScore", 0.0);
        stats.put("averageTimeSpent", 0);
        stats.put("minTimeSpent", 0);
        stats.put("maxTimeSpent", 0);

        // Basic statistics
        String basicSql = "SELECT COUNT(*) as total, AVG(score) as avg_score, MAX(score) as max_score, MIN(score) as min_score, " +
                          "AVG(time_spent) as avg_time, MIN(time_spent) as min_time, MAX(time_spent) as max_time " +
                          "FROM submissions WHERE quiz_id = ? AND status = 'completed'";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(basicSql)) {

            stmt.setInt(1, quizId);

            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    stats.put("totalSubmissions", rs.getInt("total"));
                    stats.put("averageScore", rs.getDouble("avg_score"));
                    stats.put("highestScore", rs.getDouble("max_score"));
                    stats.put("lowestScore", rs.getDouble("min_score"));
                    stats.put("averageTimeSpent", rs.getInt("avg_time"));
                    stats.put("minTimeSpent", rs.getInt("min_time"));
                    stats.put("maxTimeSpent", rs.getInt("max_time"));
                }
            }
        }

        // Score distribution - initialize defaults
        stats.put("scoreRange0_40", 0);
        stats.put("scoreRange41_60", 0);
        stats.put("scoreRange61_75", 0);
        stats.put("scoreRange76_85", 0);
        stats.put("scoreRange86_100", 0);
        stats.put("passedCount", 0);
        stats.put("failedCount", 0);
        stats.put("passRate", 0.0);

        // Score distribution
        String distSql = "SELECT " +
                         "SUM(CASE WHEN score BETWEEN 0 AND 40 THEN 1 ELSE 0 END) as range_0_40, " +
                         "SUM(CASE WHEN score BETWEEN 41 AND 60 THEN 1 ELSE 0 END) as range_41_60, " +
                         "SUM(CASE WHEN score BETWEEN 61 AND 75 THEN 1 ELSE 0 END) as range_61_75, " +
                         "SUM(CASE WHEN score BETWEEN 76 AND 85 THEN 1 ELSE 0 END) as range_76_85, " +
                         "SUM(CASE WHEN score BETWEEN 86 AND 100 THEN 1 ELSE 0 END) as range_86_100, " +
                         "SUM(CASE WHEN score >= 60 THEN 1 ELSE 0 END) as passed, " +
                         "SUM(CASE WHEN score < 60 THEN 1 ELSE 0 END) as failed " +
                         "FROM submissions WHERE quiz_id = ? AND status = 'completed'";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(distSql)) {

            stmt.setInt(1, quizId);

            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    stats.put("scoreRange0_40", rs.getInt("range_0_40"));
                    stats.put("scoreRange41_60", rs.getInt("range_41_60"));
                    stats.put("scoreRange61_75", rs.getInt("range_61_75"));
                    stats.put("scoreRange76_85", rs.getInt("range_76_85"));
                    stats.put("scoreRange86_100", rs.getInt("range_86_100"));
                    stats.put("passedCount", rs.getInt("passed"));
                    stats.put("failedCount", rs.getInt("failed"));

                    // Calculate pass rate
                    Integer total = (Integer) stats.get("totalSubmissions");
                    int passed = rs.getInt("passed");
                    double passRate = (total != null && total > 0) ? (passed * 100.0 / total) : 0;
                    stats.put("passRate", passRate);
                }
            }
        }

        return stats;
    }

    /**
     * Count submissions by quiz
     */
    public int countByQuizId(Integer quizId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM submissions WHERE quiz_id = ? AND status = 'completed'";

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
     * Check if user has already submitted a quiz
     */
    public boolean hasSubmitted(Integer userId, Integer quizId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM submissions WHERE user_id = ? AND quiz_id = ? AND status IN ('completed', 'timeout')";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, userId);
            stmt.setInt(2, quizId);

            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        }
        return false;
    }

    /**
     * Get detailed submissions with answers for a quiz
     * Returns list of maps containing submission info and user details
     */
    public List<Map<String, Object>> getDetailedSubmissionsByQuiz(Integer quizId) throws SQLException {
        String sql = "SELECT s.*, u.name as user_name, u.email as user_email, u.tag as user_tag, q.title as quiz_title " +
                     "FROM submissions s " +
                     "LEFT JOIN users u ON s.user_id = u.id " +
                     "LEFT JOIN quiz q ON s.quiz_id = q.id " +
                     "WHERE s.quiz_id = ? AND s.status = 'completed' " +
                     "ORDER BY s.score DESC, s.time_spent ASC";
        List<Map<String, Object>> detailedSubmissions = new ArrayList<>();

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, quizId);

            try (ResultSet rs = stmt.executeQuery()) {
                int rank = 1;
                while (rs.next()) {
                    Map<String, Object> detail = new HashMap<>();
                    detail.put("id", rs.getInt("id"));
                    detail.put("quizId", rs.getInt("quiz_id"));
                    detail.put("userId", rs.getInt("user_id"));
                    detail.put("score", rs.getDouble("score"));
                    detail.put("totalQuestions", rs.getInt("total_questions"));
                    detail.put("correctAnswers", rs.getInt("correct_answers"));
                    detail.put("timeSpent", rs.getInt("time_spent"));
                    detail.put("status", rs.getString("status"));
                    detail.put("userName", rs.getString("user_name"));
                    detail.put("userEmail", rs.getString("user_email"));
                    detail.put("userTag", rs.getString("user_tag"));
                    detail.put("quizTitle", rs.getString("quiz_title"));
                    detail.put("rank", rank++);

                    Timestamp submittedAt = rs.getTimestamp("submitted_at");
                    if (submittedAt != null) {
                        detail.put("submittedAt", submittedAt.toLocalDateTime());
                    }

                    // Calculate unanswered questions
                    int unanswered = rs.getInt("total_questions") - rs.getInt("correct_answers");
                    // Note: We need to get actual answered count from answers table for accurate unanswered count
                    detail.put("unanswered", unanswered);

                    detailedSubmissions.add(detail);
                }
            }
        }
        return detailedSubmissions;
    }

    /**
     * Get submission with all questions and answers for detailed view
     */
    public Map<String, Object> getSubmissionDetailWithAnswers(Integer submissionId) throws SQLException {
        Map<String, Object> result = new HashMap<>();

        // Get submission info
        Submission submission = findById(submissionId);
        if (submission == null) {
            return null;
        }

        result.put("submission", submission);

        // Get all questions for this quiz with user's answers
        String sql = "SELECT q.id, q.question_text, q.option_a, q.option_b, q.option_c, q.option_d, " +
                     "q.correct_answer, q.question_order, a.selected_answer, a.is_correct " +
                     "FROM questions q " +
                     "LEFT JOIN answers a ON q.id = a.question_id AND a.submission_id = ? " +
                     "WHERE q.quiz_id = ? " +
                     "ORDER BY q.question_order, q.id";

        List<Map<String, Object>> questionsWithAnswers = new ArrayList<>();
        int correctCount = 0;
        int wrongCount = 0;
        int unansweredCount = 0;

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, submissionId);
            stmt.setInt(2, submission.getQuizId());

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> qa = new HashMap<>();
                    qa.put("questionId", rs.getInt("id"));
                    qa.put("questionText", rs.getString("question_text"));
                    qa.put("optionA", rs.getString("option_a"));
                    qa.put("optionB", rs.getString("option_b"));
                    qa.put("optionC", rs.getString("option_c"));
                    qa.put("optionD", rs.getString("option_d"));
                    qa.put("correctAnswer", rs.getString("correct_answer"));
                    qa.put("questionOrder", rs.getInt("question_order"));

                    String selectedAnswer = rs.getString("selected_answer");
                    Boolean isCorrect = rs.getBoolean("is_correct");

                    qa.put("selectedAnswer", selectedAnswer);
                    qa.put("isCorrect", isCorrect);
                    qa.put("answered", selectedAnswer != null);

                    if (selectedAnswer == null) {
                        unansweredCount++;
                    } else if (isCorrect != null && isCorrect) {
                        correctCount++;
                    } else {
                        wrongCount++;
                    }

                    questionsWithAnswers.add(qa);
                }
            }
        }

        result.put("questions", questionsWithAnswers);
        result.put("correctCount", correctCount);
        result.put("wrongCount", wrongCount);
        result.put("unansweredCount", unansweredCount);

        return result;
    }

    /**
     * Get unanswered count for a submission (actual count from answers table)
     */
    public int getAnsweredCount(Integer submissionId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM answers WHERE submission_id = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, submissionId);

            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }
        return 0;
    }

    /**
     * Map ResultSet to Submission object
     */
    private Submission mapResultSetToSubmission(ResultSet rs) throws SQLException {
        Submission submission = new Submission();
        submission.setId(rs.getInt("id"));
        submission.setQuizId(rs.getInt("quiz_id"));
        submission.setUserId(rs.getInt("user_id"));
        submission.setScore(rs.getDouble("score"));
        submission.setTotalQuestions(rs.getInt("total_questions"));
        submission.setCorrectAnswers(rs.getInt("correct_answers"));

        Timestamp startedAt = rs.getTimestamp("started_at");
        if (startedAt != null) {
            submission.setStartedAt(startedAt.toLocalDateTime());
        }

        Timestamp submittedAt = rs.getTimestamp("submitted_at");
        if (submittedAt != null) {
            submission.setSubmittedAt(submittedAt.toLocalDateTime());
        }

        submission.setTimeSpent(rs.getInt("time_spent"));
        submission.setStatus(rs.getString("status"));
        submission.setUserName(rs.getString("user_name"));
        submission.setQuizTitle(rs.getString("quiz_title"));

        return submission;
    }
}
