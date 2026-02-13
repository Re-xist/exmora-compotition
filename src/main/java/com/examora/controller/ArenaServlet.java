package com.examora.controller;

import com.examora.model.ArenaAnswer;
import com.examora.model.ArenaParticipant;
import com.examora.model.ArenaSession;
import com.examora.model.Question;
import com.examora.model.Quiz;
import com.examora.model.User;
import com.examora.service.ArenaService;
import com.examora.service.QuizService;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.JsonObject;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

/**
 * Arena Servlet - Handles HTTP endpoints for arena operations
 */
@WebServlet("/ArenaServlet")
public class ArenaServlet extends HttpServlet {
    private ArenaService arenaService;
    private QuizService quizService;
    private Gson gson;

    @Override
    public void init() throws ServletException {
        arenaService = new ArenaService();
        quizService = new QuizService();
        gson = new GsonBuilder().create();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");

        try {
            switch (action != null ? action : "list") {
                case "list":
                    listArenas(request, response);
                    break;
                case "create":
                    showCreateForm(request, response);
                    break;
                case "host":
                    showHostPanel(request, response);
                    break;
                case "join":
                    showJoinForm(request, response);
                    break;
                case "lobby":
                    showLobby(request, response);
                    break;
                case "play":
                    showPlayView(request, response);
                    break;
                case "result":
                    showResult(request, response);
                    break;
                case "delete":
                    deleteArena(request, response);
                    break;
                // API endpoints
                case "api/session":
                    apiGetSession(request, response);
                    break;
                case "api/leaderboard":
                    apiGetLeaderboard(request, response);
                    break;
                case "api/question":
                    apiGetQuestion(request, response);
                    break;
                case "api/participant":
                    apiGetParticipant(request, response);
                    break;
                default:
                    listArenas(request, response);
            }
        } catch (ArenaService.ServiceException e) {
            if (isApiRequest(action)) {
                sendJsonError(response, e.getMessage());
            } else {
                request.setAttribute("error", e.getMessage());
                try {
                    listArenas(request, response);
                } catch (ArenaService.ServiceException ex) {
                    throw new ServletException(ex);
                }
            }
        } catch (QuizService.ServiceException e) {
            request.setAttribute("error", e.getMessage());
            try {
                listArenas(request, response);
            } catch (ArenaService.ServiceException ex) {
                throw new ServletException(ex);
            }
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");

        try {
            switch (action != null ? action : "") {
                case "create":
                    createArena(request, response);
                    break;
                case "join":
                    joinArena(request, response);
                    break;
                case "start":
                    startArena(request, response);
                    break;
                case "pause":
                    pauseArena(request, response);
                    break;
                case "resume":
                    resumeArena(request, response);
                    break;
                case "end":
                    endArena(request, response);
                    break;
                case "next":
                    nextQuestion(request, response);
                    break;
                case "answer":
                    submitAnswer(request, response);
                    break;
                default:
                    listArenas(request, response);
            }
        } catch (ArenaService.ServiceException e) {
            if (isApiRequest(action)) {
                sendJsonError(response, e.getMessage());
            } else {
                request.setAttribute("error", e.getMessage());
                if ("create".equals(action)) {
                    try {
                        showCreateForm(request, response);
                    } catch (ArenaService.ServiceException | QuizService.ServiceException ex) {
                        throw new ServletException(ex);
                    }
                } else if ("join".equals(action)) {
                    showJoinForm(request, response);
                } else {
                    try {
                        listArenas(request, response);
                    } catch (ArenaService.ServiceException ex) {
                        throw new ServletException(ex);
                    }
                }
            }
        }
    }

    // ================== Page Handlers ==================

    private void listArenas(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, ArenaService.ServiceException {
        User user = (User) request.getSession().getAttribute("user");
        List<ArenaSession> arenas;

        if (user.isAdmin()) {
            arenas = arenaService.getAllSessions();
        } else {
            arenas = arenaService.getSessionsByHost(user.getId());
        }

        request.setAttribute("arenas", arenas);
        request.getRequestDispatcher("/admin/arena-list.jsp").forward(request, response);
    }

    private void showCreateForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, ArenaService.ServiceException, QuizService.ServiceException {
        User user = (User) request.getSession().getAttribute("user");

        // Get quizzes for selection
        List<Quiz> quizzes;
        if (user.isAdmin()) {
            quizzes = quizService.getAllQuizzes();
        } else {
            quizzes = quizService.getQuizzesByCreator(user.getId());
        }

        request.setAttribute("quizzes", quizzes);
        request.getRequestDispatcher("/admin/arena-create.jsp").forward(request, response);
    }

    private void showHostPanel(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, ArenaService.ServiceException {
        String idStr = request.getParameter("id");
        if (idStr == null || idStr.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/ArenaServlet?action=list");
            return;
        }

        Integer id = Integer.parseInt(idStr);
        ArenaSession session = arenaService.getSessionById(id);
        List<ArenaParticipant> participants = arenaService.getParticipants(id);
        List<Question> questions = arenaService.getQuestions(id);

        request.setAttribute("arenaSession", session);
        request.setAttribute("participants", participants);
        request.setAttribute("questions", questions);
        request.getRequestDispatcher("/admin/arena-host.jsp").forward(request, response);
    }

    private void showJoinForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/user/arena-join.jsp").forward(request, response);
    }

    private void showLobby(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, ArenaService.ServiceException {
        String sessionIdStr = request.getParameter("sessionId");
        if (sessionIdStr == null || sessionIdStr.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/ArenaServlet?action=join");
            return;
        }

        Integer sessionId = Integer.parseInt(sessionIdStr);
        ArenaSession session = arenaService.getSessionById(sessionId);
        User user = (User) request.getSession().getAttribute("user");
        ArenaParticipant participant = arenaService.getParticipant(sessionId, user.getId());

        if (participant == null) {
            response.sendRedirect(request.getContextPath() + "/ArenaServlet?action=join");
            return;
        }

        List<ArenaParticipant> participants = arenaService.getParticipants(sessionId);

        request.setAttribute("arenaSession", session);
        request.setAttribute("participant", participant);
        request.setAttribute("participants", participants);
        request.getRequestDispatcher("/user/arena-lobby.jsp").forward(request, response);
    }

    private void showPlayView(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, ArenaService.ServiceException {
        String sessionIdStr = request.getParameter("sessionId");
        if (sessionIdStr == null || sessionIdStr.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/ArenaServlet?action=join");
            return;
        }

        Integer sessionId = Integer.parseInt(sessionIdStr);
        ArenaSession session = arenaService.getSessionById(sessionId);

        if (!session.isInProgress()) {
            // If session is not in progress, redirect to lobby or result
            if (session.isCompleted()) {
                response.sendRedirect(request.getContextPath() + "/ArenaServlet?action=result&id=" + sessionId);
            } else {
                response.sendRedirect(request.getContextPath() + "/ArenaServlet?action=lobby&sessionId=" + sessionId);
            }
            return;
        }

        User user = (User) request.getSession().getAttribute("user");
        ArenaParticipant participant = arenaService.getParticipant(sessionId, user.getId());

        if (participant == null) {
            response.sendRedirect(request.getContextPath() + "/ArenaServlet?action=join");
            return;
        }

        Question currentQuestion = arenaService.getCurrentQuestion(sessionId);
        List<ArenaParticipant> leaderboard = arenaService.getLeaderboard(sessionId);

        request.setAttribute("arenaSession", session);
        request.setAttribute("participant", participant);
        request.setAttribute("currentQuestion", currentQuestion);
        request.setAttribute("leaderboard", leaderboard);
        request.getRequestDispatcher("/user/arena-play.jsp").forward(request, response);
    }

    private void showResult(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, ArenaService.ServiceException {
        String idStr = request.getParameter("id");
        if (idStr == null || idStr.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/");
            return;
        }

        Integer sessionId = Integer.parseInt(idStr);
        ArenaSession session = arenaService.getSessionById(sessionId);
        List<ArenaParticipant> leaderboard = arenaService.getLeaderboard(sessionId);

        User user = (User) request.getSession().getAttribute("user");
        ArenaParticipant participant = arenaService.getParticipant(sessionId, user.getId());

        ArenaService.ArenaStats stats = arenaService.getSessionStats(sessionId);

        request.setAttribute("arenaSession", session);
        request.setAttribute("leaderboard", leaderboard);
        request.setAttribute("participant", participant);
        request.setAttribute("stats", stats);

        // Determine which view to show based on user role
        if (user.isAdmin() || (participant != null && session.getHostId().equals(user.getId()))) {
            request.getRequestDispatcher("/admin/arena-result.jsp").forward(request, response);
        } else {
            request.getRequestDispatcher("/arena-result.jsp").forward(request, response);
        }
    }

    // ================== Action Handlers ==================

    private void createArena(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, ArenaService.ServiceException {
        String quizIdStr = request.getParameter("quizId");
        String questionTimeStr = request.getParameter("questionTime");

        if (quizIdStr == null || quizIdStr.isEmpty()) {
            throw new ArenaService.ServiceException("Quiz harus dipilih");
        }

        Integer quizId = Integer.parseInt(quizIdStr);
        Integer questionTime = questionTimeStr != null && !questionTimeStr.isEmpty() ?
                Integer.parseInt(questionTimeStr) : 30;

        User user = (User) request.getSession().getAttribute("user");

        ArenaSession session = arenaService.createSession(quizId, user.getId(), questionTime);

        request.setAttribute("success", "Arena berhasil dibuat dengan kode: " + session.getCode());
        response.sendRedirect(request.getContextPath() + "/ArenaServlet?action=host&id=" + session.getId());
    }

    private void joinArena(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, ArenaService.ServiceException {
        String code = request.getParameter("code");

        if (code == null || code.trim().isEmpty()) {
            throw new ArenaService.ServiceException("Kode arena harus diisi");
        }

        User user = (User) request.getSession().getAttribute("user");
        ArenaParticipant participant = arenaService.joinSession(code.trim(), user.getId());

        request.setAttribute("success", "Berhasil bergabung ke arena!");
        response.sendRedirect(request.getContextPath() + "/ArenaServlet?action=lobby&sessionId=" + participant.getSessionId());
    }

    private void startArena(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, ArenaService.ServiceException {
        String idStr = request.getParameter("id");
        if (idStr == null || idStr.isEmpty()) {
            sendJsonError(response, "Arena ID diperlukan");
            return;
        }
        Integer id = Integer.parseInt(idStr);

        User user = (User) request.getSession().getAttribute("user");
        arenaService.startSession(id, user.getId());

        sendJsonSuccess(response, "Arena started");
    }

    private void pauseArena(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, ArenaService.ServiceException {
        String idStr = request.getParameter("id");
        if (idStr == null || idStr.isEmpty()) {
            sendJsonError(response, "Arena ID diperlukan");
            return;
        }
        Integer id = Integer.parseInt(idStr);

        User user = (User) request.getSession().getAttribute("user");
        arenaService.pauseSession(id, user.getId());

        sendJsonSuccess(response, "Arena paused");
    }

    private void resumeArena(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, ArenaService.ServiceException {
        String idStr = request.getParameter("id");
        if (idStr == null || idStr.isEmpty()) {
            sendJsonError(response, "Arena ID diperlukan");
            return;
        }
        Integer id = Integer.parseInt(idStr);

        User user = (User) request.getSession().getAttribute("user");
        arenaService.resumeSession(id, user.getId());

        sendJsonSuccess(response, "Arena resumed");
    }

    private void endArena(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, ArenaService.ServiceException {
        String idStr = request.getParameter("id");
        if (idStr == null || idStr.isEmpty()) {
            sendJsonError(response, "Arena ID diperlukan");
            return;
        }
        Integer id = Integer.parseInt(idStr);

        User user = (User) request.getSession().getAttribute("user");
        arenaService.endSession(id, user.getId());

        sendJsonSuccess(response, "Arena ended");
    }

    private void nextQuestion(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, ArenaService.ServiceException {
        String idStr = request.getParameter("id");
        if (idStr == null || idStr.isEmpty()) {
            sendJsonError(response, "Arena ID diperlukan");
            return;
        }
        Integer id = Integer.parseInt(idStr);

        User user = (User) request.getSession().getAttribute("user");
        arenaService.nextQuestion(id, user.getId());

        sendJsonSuccess(response, "Next question");
    }

    private void submitAnswer(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, ArenaService.ServiceException {
        String sessionIdStr = request.getParameter("sessionId");
        String participantIdStr = request.getParameter("participantId");
        String questionIdStr = request.getParameter("questionId");
        String answer = request.getParameter("answer");
        String timeTakenStr = request.getParameter("timeTaken");

        // Validate required parameters
        if (sessionIdStr == null || sessionIdStr.isEmpty()) {
            sendJsonError(response, "Session ID diperlukan");
            return;
        }
        if (participantIdStr == null || participantIdStr.isEmpty()) {
            sendJsonError(response, "Participant ID diperlukan");
            return;
        }
        if (questionIdStr == null || questionIdStr.isEmpty()) {
            sendJsonError(response, "Question ID diperlukan");
            return;
        }
        if (answer == null || answer.isEmpty()) {
            sendJsonError(response, "Jawaban diperlukan");
            return;
        }

        Integer sessionId = Integer.parseInt(sessionIdStr);
        Integer participantId = Integer.parseInt(participantIdStr);
        Integer questionId = Integer.parseInt(questionIdStr);
        Integer timeTaken = timeTakenStr != null && !timeTakenStr.isEmpty() ? Integer.parseInt(timeTakenStr) : 0;

        ArenaAnswer arenaAnswer = arenaService.submitAnswer(sessionId, participantId, questionId, answer, timeTaken);

        JsonObject result = new JsonObject();
        result.addProperty("success", true);
        result.addProperty("isCorrect", arenaAnswer.getIsCorrect());
        result.addProperty("scoreEarned", arenaAnswer.getScoreEarned());
        result.addProperty("correctAnswer", arenaAnswer.getCorrectAnswer());

        sendJsonResponse(response, result);
    }

    private void deleteArena(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, ArenaService.ServiceException {
        String idStr = request.getParameter("id");
        if (idStr != null && !idStr.isEmpty()) {
            Integer id = Integer.parseInt(idStr);
            User user = (User) request.getSession().getAttribute("user");
            arenaService.deleteSession(id, user.getId());
            request.setAttribute("success", "Arena berhasil dihapus");
        }
        response.sendRedirect(request.getContextPath() + "/ArenaServlet?action=list");
    }

    // ================== API Handlers ==================

    private void apiGetSession(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, ArenaService.ServiceException {
        String idStr = request.getParameter("id");
        String code = request.getParameter("code");

        ArenaSession session;
        if (idStr != null && !idStr.isEmpty()) {
            session = arenaService.getSessionById(Integer.parseInt(idStr));
        } else if (code != null && !code.isEmpty()) {
            session = arenaService.getSessionByCode(code);
        } else {
            sendJsonError(response, "Session ID or code required");
            return;
        }

        sendJsonResponse(response, gson.toJsonTree(session));
    }

    private void apiGetLeaderboard(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, ArenaService.ServiceException {
        String sessionIdStr = request.getParameter("sessionId");
        if (sessionIdStr == null || sessionIdStr.isEmpty()) {
            sendJsonError(response, "Session ID required");
            return;
        }

        List<ArenaParticipant> leaderboard = arenaService.getLeaderboard(Integer.parseInt(sessionIdStr));
        sendJsonResponse(response, gson.toJsonTree(leaderboard));
    }

    private void apiGetQuestion(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, ArenaService.ServiceException {
        String sessionIdStr = request.getParameter("sessionId");
        if (sessionIdStr == null || sessionIdStr.isEmpty()) {
            sendJsonError(response, "Session ID required");
            return;
        }

        Question question = arenaService.getCurrentQuestion(Integer.parseInt(sessionIdStr));
        sendJsonResponse(response, gson.toJsonTree(question));
    }

    private void apiGetParticipant(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, ArenaService.ServiceException {
        String sessionIdStr = request.getParameter("sessionId");
        String userIdStr = request.getParameter("userId");

        if (sessionIdStr == null || userIdStr == null) {
            sendJsonError(response, "Session ID and User ID required");
            return;
        }

        ArenaParticipant participant = arenaService.getParticipant(
            Integer.parseInt(sessionIdStr),
            Integer.parseInt(userIdStr)
        );
        sendJsonResponse(response, gson.toJsonTree(participant));
    }

    // ================== Utility Methods ==================

    private boolean isApiRequest(String action) {
        return action != null && action.startsWith("api/");
    }

    private void sendJsonResponse(HttpServletResponse response, Object data) throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        out.print(gson.toJson(data));
        out.flush();
    }

    private void sendJsonSuccess(HttpServletResponse response, String message) throws IOException {
        JsonObject result = new JsonObject();
        result.addProperty("success", true);
        result.addProperty("message", message);
        sendJsonResponse(response, result);
    }

    private void sendJsonError(HttpServletResponse response, String message) throws IOException {
        response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
        JsonObject result = new JsonObject();
        result.addProperty("success", false);
        result.addProperty("error", message);
        sendJsonResponse(response, result);
    }
}
