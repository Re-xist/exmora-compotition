package com.examora.service;

import com.examora.dao.ArenaAnswerDAO;
import com.examora.dao.ArenaParticipantDAO;
import com.examora.dao.ArenaSessionDAO;
import com.examora.dao.QuestionDAO;
import com.examora.dao.QuizDAO;
import com.examora.model.ArenaAnswer;
import com.examora.model.ArenaParticipant;
import com.examora.model.ArenaSession;
import com.examora.model.Question;
import com.examora.model.Quiz;
import com.examora.util.ValidationUtil;

import java.sql.SQLException;
import java.util.List;
import java.util.Random;

/**
 * Arena Service - Business logic for arena operations
 */
public class ArenaService {

    private ArenaSessionDAO sessionDAO;
    private ArenaParticipantDAO participantDAO;
    private ArenaAnswerDAO answerDAO;
    private QuizDAO quizDAO;
    private QuestionDAO questionDAO;

    // Scoring constants
    private static final int BASE_POINT = 100;

    public ArenaService() {
        this.sessionDAO = new ArenaSessionDAO();
        this.participantDAO = new ArenaParticipantDAO();
        this.answerDAO = new ArenaAnswerDAO();
        this.quizDAO = new QuizDAO();
        this.questionDAO = new QuestionDAO();
    }

    /**
     * Create a new arena session
     */
    public ArenaSession createSession(Integer quizId, Integer hostId, Integer questionTime)
            throws ServiceException {
        // Validate inputs
        if (quizId == null) {
            throw new ServiceException("Quiz harus dipilih");
        }
        if (hostId == null) {
            throw new ServiceException("Host tidak valid");
        }

        try {
            // Check if quiz exists and has questions
            Quiz quiz = quizDAO.findById(quizId);
            if (quiz == null) {
                throw new ServiceException("Quiz tidak ditemukan");
            }

            int questionCount = questionDAO.countByQuizId(quizId);
            if (questionCount == 0) {
                throw new ServiceException("Quiz harus memiliki minimal 1 soal");
            }

            // Generate unique code
            String code = generateUniqueCode();

            // Create session
            ArenaSession session = new ArenaSession(quizId, hostId, questionTime);
            session.setCode(code);

            return sessionDAO.create(session);
        } catch (SQLException e) {
            throw new ServiceException("Gagal membuat arena session: " + e.getMessage(), e);
        }
    }

    /**
     * Generate unique arena code (AR-XXXXX format)
     */
    private String generateUniqueCode() throws SQLException {
        Random random = new Random();
        String code;
        int attempts = 0;
        int maxAttempts = 100;

        do {
            // Generate 5-character alphanumeric code
            StringBuilder sb = new StringBuilder("AR-");
            for (int i = 0; i < 5; i++) {
                int type = random.nextInt(3);
                if (type == 0) {
                    sb.append((char) ('A' + random.nextInt(26)));
                } else if (type == 1) {
                    sb.append((char) ('0' + random.nextInt(10)));
                } else {
                    sb.append((char) ('A' + random.nextInt(26)));
                }
            }
            code = sb.toString();
            attempts++;
        } while (sessionDAO.codeExists(code) && attempts < maxAttempts);

        if (attempts >= maxAttempts) {
            throw new SQLException("Failed to generate unique code after " + maxAttempts + " attempts");
        }

        return code;
    }

    /**
     * Join an arena session
     */
    public ArenaParticipant joinSession(String code, Integer userId) throws ServiceException {
        if (ValidationUtil.isEmpty(code)) {
            throw new ServiceException("Kode arena harus diisi");
        }
        if (userId == null) {
            throw new ServiceException("User tidak valid");
        }

        try {
            // Find session by code
            ArenaSession session = sessionDAO.findByCode(code.toUpperCase());
            if (session == null) {
                throw new ServiceException("Arena dengan kode tersebut tidak ditemukan");
            }

            // Check if session can be joined
            if (!session.canJoin()) {
                throw new ServiceException("Arena sudah dimulai, tidak bisa bergabung");
            }

            // Check if user is already in session
            if (participantDAO.isUserInSession(session.getId(), userId)) {
                throw new ServiceException("Anda sudah bergabung di arena ini");
            }

            // Create participant
            ArenaParticipant participant = new ArenaParticipant(session.getId(), userId);
            return participantDAO.create(participant);
        } catch (SQLException e) {
            throw new ServiceException("Gagal bergabung ke arena: " + e.getMessage(), e);
        }
    }

    /**
     * Get session by ID
     */
    public ArenaSession getSessionById(Integer id) throws ServiceException {
        try {
            ArenaSession session = sessionDAO.findById(id);
            if (session == null) {
                throw new ServiceException("Arena session tidak ditemukan");
            }
            return session;
        } catch (SQLException e) {
            throw new ServiceException("Gagal mengambil data session: " + e.getMessage(), e);
        }
    }

    /**
     * Get session by code
     */
    public ArenaSession getSessionByCode(String code) throws ServiceException {
        try {
            ArenaSession session = sessionDAO.findByCode(code.toUpperCase());
            if (session == null) {
                throw new ServiceException("Arena dengan kode tersebut tidak ditemukan");
            }
            return session;
        } catch (SQLException e) {
            throw new ServiceException("Gagal mengambil data session: " + e.getMessage(), e);
        }
    }

    /**
     * Get all arena sessions
     */
    public List<ArenaSession> getAllSessions() throws ServiceException {
        try {
            return sessionDAO.findAll();
        } catch (SQLException e) {
            throw new ServiceException("Gagal mengambil data sessions: " + e.getMessage(), e);
        }
    }

    /**
     * Get sessions by host
     */
    public List<ArenaSession> getSessionsByHost(Integer hostId) throws ServiceException {
        try {
            return sessionDAO.findByHost(hostId);
        } catch (SQLException e) {
            throw new ServiceException("Gagal mengambil data sessions: " + e.getMessage(), e);
        }
    }

    /**
     * Start an arena session
     */
    public void startSession(Integer sessionId, Integer hostId) throws ServiceException {
        try {
            ArenaSession session = sessionDAO.findById(sessionId);
            if (session == null) {
                throw new ServiceException("Arena session tidak ditemukan");
            }

            // Verify host
            if (!session.getHostId().equals(hostId)) {
                throw new ServiceException("Hanya host yang bisa memulai arena");
            }

            // Check if session can be started
            if (!session.isWaiting()) {
                throw new ServiceException("Arena sudah dimulai atau selesai");
            }

            // Check if there are participants
            int participantCount = participantDAO.countBySession(sessionId);
            if (participantCount == 0) {
                throw new ServiceException("Arena harus memiliki minimal 1 peserta");
            }

            sessionDAO.startSession(sessionId);
        } catch (SQLException e) {
            throw new ServiceException("Gagal memulai arena: " + e.getMessage(), e);
        }
    }

    /**
     * Pause an arena session
     */
    public void pauseSession(Integer sessionId, Integer hostId) throws ServiceException {
        try {
            ArenaSession session = sessionDAO.findById(sessionId);
            if (session == null) {
                throw new ServiceException("Arena session tidak ditemukan");
            }

            if (!session.getHostId().equals(hostId)) {
                throw new ServiceException("Hanya host yang bisa menghentikan arena");
            }

            if (!session.isActive()) {
                throw new ServiceException("Hanya arena yang sedang berjalan yang bisa di-pause");
            }

            sessionDAO.updateStatus(sessionId, ArenaSession.STATUS_PAUSED);
        } catch (SQLException e) {
            throw new ServiceException("Gagal menghentikan arena: " + e.getMessage(), e);
        }
    }

    /**
     * Resume a paused arena session
     */
    public void resumeSession(Integer sessionId, Integer hostId) throws ServiceException {
        try {
            ArenaSession session = sessionDAO.findById(sessionId);
            if (session == null) {
                throw new ServiceException("Arena session tidak ditemukan");
            }

            if (!session.getHostId().equals(hostId)) {
                throw new ServiceException("Hanya host yang bisa melanjutkan arena");
            }

            if (!session.isPaused()) {
                throw new ServiceException("Hanya arena yang di-pause yang bisa dilanjutkan");
            }

            sessionDAO.updateStatus(sessionId, ArenaSession.STATUS_ACTIVE);
        } catch (SQLException e) {
            throw new ServiceException("Gagal melanjutkan arena: " + e.getMessage(), e);
        }
    }

    /**
     * End an arena session
     */
    public void endSession(Integer sessionId, Integer hostId) throws ServiceException {
        try {
            ArenaSession session = sessionDAO.findById(sessionId);
            if (session == null) {
                throw new ServiceException("Arena session tidak ditemukan");
            }

            if (!session.getHostId().equals(hostId)) {
                throw new ServiceException("Hanya host yang bisa mengakhiri arena");
            }

            if (session.isCompleted()) {
                throw new ServiceException("Arena sudah selesai");
            }

            sessionDAO.endSession(sessionId);
        } catch (SQLException e) {
            throw new ServiceException("Gagal mengakhiri arena: " + e.getMessage(), e);
        }
    }

    /**
     * Advance to next question
     */
    public void nextQuestion(Integer sessionId, Integer hostId) throws ServiceException {
        try {
            ArenaSession session = sessionDAO.findById(sessionId);
            if (session == null) {
                throw new ServiceException("Arena session tidak ditemukan");
            }

            if (!session.getHostId().equals(hostId)) {
                throw new ServiceException("Hanya host yang bisa melanjutkan ke soal berikutnya");
            }

            if (!session.isInProgress()) {
                throw new ServiceException("Arena tidak sedang berjalan");
            }

            // Check if there are more questions
            List<Question> questions = questionDAO.findByQuizId(session.getQuizId());
            if (session.getCurrentQuestion() >= questions.size() - 1) {
                // No more questions, end session
                sessionDAO.endSession(sessionId);
            } else {
                sessionDAO.advanceQuestion(sessionId);
            }
        } catch (SQLException e) {
            throw new ServiceException("Gagal melanjutkan ke soal berikutnya: " + e.getMessage(), e);
        }
    }

    /**
     * Submit an answer
     */
    public ArenaAnswer submitAnswer(Integer sessionId, Integer participantId, Integer questionId,
                                    String selectedAnswer, Integer timeTaken) throws ServiceException {
        try {
            ArenaSession session = sessionDAO.findById(sessionId);
            if (session == null) {
                throw new ServiceException("Arena session tidak ditemukan");
            }

            if (!session.isInProgress()) {
                throw new ServiceException("Arena tidak sedang berjalan");
            }

            // Check if participant belongs to this session
            ArenaParticipant participant = participantDAO.findById(participantId);
            if (participant == null || !participant.getSessionId().equals(sessionId)) {
                throw new ServiceException("Peserta tidak valid");
            }

            // Check if already answered
            if (answerDAO.hasAnswered(participantId, questionId)) {
                throw new ServiceException("Soal sudah dijawab");
            }

            // Get the correct answer
            Question question = questionDAO.findById(questionId);
            if (question == null) {
                throw new ServiceException("Soal tidak ditemukan");
            }

            // Calculate score
            int scoreEarned = calculateScore(selectedAnswer, question.getCorrectAnswer(),
                                            timeTaken, session.getQuestionTime());

            // Create answer
            ArenaAnswer answer = new ArenaAnswer(sessionId, participantId, questionId,
                                                 selectedAnswer, timeTaken);
            answer.setScoreEarned(scoreEarned);
            answer.setCorrectAnswer(question.getCorrectAnswer());

            answerDAO.create(answer);

            // Update participant score
            if (scoreEarned > 0) {
                participantDAO.addScore(participantId, scoreEarned);
            }

            return answer;
        } catch (SQLException e) {
            throw new ServiceException("Gagal menyimpan jawaban: " + e.getMessage(), e);
        }
    }

    /**
     * Calculate score based on correctness and speed
     * Formula: Base Point * (remaining_time / total_time) if correct, 0 if wrong
     */
    public int calculateScore(String selectedAnswer, String correctAnswer,
                              Integer timeTakenMs, Integer totalTimeSeconds) {
        // Check if answer is correct
        if (selectedAnswer == null || correctAnswer == null ||
            !selectedAnswer.equalsIgnoreCase(correctAnswer)) {
            return 0;
        }

        // Convert time to same unit (milliseconds)
        long totalTimeMs = totalTimeSeconds * 1000L;
        long timeTaken = timeTakenMs != null ? timeTakenMs : 0;

        // Calculate remaining time
        long remainingTime = totalTimeMs - timeTaken;
        if (remainingTime < 0) {
            remainingTime = 0;
        }

        // Calculate speed multiplier (0.0 - 1.0)
        double speedMultiplier = (double) remainingTime / totalTimeMs;

        // Calculate final score
        int score = (int) (BASE_POINT * speedMultiplier);

        // Minimum score for correct answer (10 points)
        return Math.max(score, 10);
    }

    /**
     * Get current question for a session
     */
    public Question getCurrentQuestion(Integer sessionId) throws ServiceException {
        try {
            ArenaSession session = sessionDAO.findById(sessionId);
            if (session == null) {
                throw new ServiceException("Arena session tidak ditemukan");
            }

            List<Question> questions = questionDAO.findByQuizId(session.getQuizId());
            int currentIndex = session.getCurrentQuestion();

            if (currentIndex >= 0 && currentIndex < questions.size()) {
                Question question = questions.get(currentIndex);
                // Remove correct answer for participants (don't reveal until after)
                Question displayQuestion = new Question();
                displayQuestion.setId(question.getId());
                displayQuestion.setQuestionText(question.getQuestionText());
                displayQuestion.setOptionA(question.getOptionA());
                displayQuestion.setOptionB(question.getOptionB());
                displayQuestion.setOptionC(question.getOptionC());
                displayQuestion.setOptionD(question.getOptionD());
                displayQuestion.setQuestionOrder(question.getQuestionOrder());
                return displayQuestion;
            }

            return null;
        } catch (SQLException e) {
            throw new ServiceException("Gagal mengambil soal: " + e.getMessage(), e);
        }
    }

    /**
     * Get all questions for a session (for host)
     */
    public List<Question> getQuestions(Integer sessionId) throws ServiceException {
        try {
            ArenaSession session = sessionDAO.findById(sessionId);
            if (session == null) {
                throw new ServiceException("Arena session tidak ditemukan");
            }

            return questionDAO.findByQuizId(session.getQuizId());
        } catch (SQLException e) {
            throw new ServiceException("Gagal mengambil soal: " + e.getMessage(), e);
        }
    }

    /**
     * Get leaderboard for a session
     */
    public List<ArenaParticipant> getLeaderboard(Integer sessionId) throws ServiceException {
        try {
            return participantDAO.getLeaderboard(sessionId);
        } catch (SQLException e) {
            throw new ServiceException("Gagal mengambil leaderboard: " + e.getMessage(), e);
        }
    }

    /**
     * Get participant by session and user
     */
    public ArenaParticipant getParticipant(Integer sessionId, Integer userId) throws ServiceException {
        try {
            return participantDAO.findBySessionAndUser(sessionId, userId);
        } catch (SQLException e) {
            throw new ServiceException("Gagal mengambil data peserta: " + e.getMessage(), e);
        }
    }

    /**
     * Get all participants for a session
     */
    public List<ArenaParticipant> getParticipants(Integer sessionId) throws ServiceException {
        try {
            return participantDAO.findBySession(sessionId);
        } catch (SQLException e) {
            throw new ServiceException("Gagal mengambil data peserta: " + e.getMessage(), e);
        }
    }

    /**
     * Get participant's answers for review
     */
    public List<ArenaAnswer> getParticipantAnswers(Integer participantId) throws ServiceException {
        try {
            return answerDAO.findByParticipant(participantId);
        } catch (SQLException e) {
            throw new ServiceException("Gagal mengambil jawaban: " + e.getMessage(), e);
        }
    }

    /**
     * Delete an arena session
     */
    public void deleteSession(Integer sessionId, Integer hostId) throws ServiceException {
        try {
            ArenaSession session = sessionDAO.findById(sessionId);
            if (session == null) {
                throw new ServiceException("Arena session tidak ditemukan");
            }

            if (!session.getHostId().equals(hostId)) {
                throw new ServiceException("Hanya host yang bisa menghapus arena");
            }

            sessionDAO.delete(sessionId);
        } catch (SQLException e) {
            throw new ServiceException("Gagal menghapus arena: " + e.getMessage(), e);
        }
    }

    /**
     * Update participant connection status
     */
    public void updateConnectionStatus(Integer participantId, boolean isConnected) throws ServiceException {
        try {
            participantDAO.updateConnectionStatus(participantId, isConnected);
        } catch (SQLException e) {
            throw new ServiceException("Gagal update status koneksi: " + e.getMessage(), e);
        }
    }

    /**
     * Get session statistics
     */
    public ArenaStats getSessionStats(Integer sessionId) throws ServiceException {
        try {
            ArenaSession session = sessionDAO.findById(sessionId);
            if (session == null) {
                throw new ServiceException("Arena session tidak ditemukan");
            }

            List<ArenaParticipant> participants = participantDAO.findBySession(sessionId);
            List<Question> questions = questionDAO.findByQuizId(session.getQuizId());

            ArenaStats stats = new ArenaStats();
            stats.setTotalParticipants(participants.size());
            stats.setTotalQuestions(questions.size());
            stats.setSession(session);

            if (!participants.isEmpty()) {
                // Calculate average score
                double avgScore = participants.stream()
                    .mapToInt(p -> p.getScore() != null ? p.getScore() : 0)
                    .average()
                    .orElse(0.0);
                stats.setAverageScore(avgScore);

                // Find highest score
                int highestScore = participants.stream()
                    .mapToInt(p -> p.getScore() != null ? p.getScore() : 0)
                    .max()
                    .orElse(0);
                stats.setHighestScore(highestScore);
            }

            return stats;
        } catch (SQLException e) {
            throw new ServiceException("Gagal mengambil statistik: " + e.getMessage(), e);
        }
    }

    /**
     * Arena Statistics class
     */
    public static class ArenaStats {
        private ArenaSession session;
        private int totalParticipants;
        private int totalQuestions;
        private double averageScore;
        private int highestScore;

        public ArenaSession getSession() { return session; }
        public void setSession(ArenaSession session) { this.session = session; }

        public int getTotalParticipants() { return totalParticipants; }
        public void setTotalParticipants(int totalParticipants) { this.totalParticipants = totalParticipants; }

        public int getTotalQuestions() { return totalQuestions; }
        public void setTotalQuestions(int totalQuestions) { this.totalQuestions = totalQuestions; }

        public double getAverageScore() { return averageScore; }
        public void setAverageScore(double averageScore) { this.averageScore = averageScore; }

        public int getHighestScore() { return highestScore; }
        public void setHighestScore(int highestScore) { this.highestScore = highestScore; }
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
