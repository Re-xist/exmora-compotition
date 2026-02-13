package com.examora.controller;

import com.examora.model.Answer;
import com.examora.model.Question;
import com.examora.model.Quiz;
import com.examora.model.Submission;
import com.examora.model.User;
import com.examora.service.QuizService;
import com.examora.service.SubmissionService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Exam Servlet - Handles exam taking for participants
 */
@WebServlet("/ExamServlet")
public class ExamServlet extends HttpServlet {
    private QuizService quizService;
    private SubmissionService submissionService;

    @Override
    public void init() throws ServletException {
        quizService = new QuizService();
        submissionService = new SubmissionService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");

        try {
            switch (action != null ? action : "list") {
                case "dashboard":
                    showUserDashboard(request, response);
                    break;
                case "list":
                    listAvailableQuizzes(request, response);
                    break;
                case "start":
                    startExam(request, response);
                    break;
                case "take":
                    showExam(request, response);
                    break;
                case "result":
                    showResult(request, response);
                    break;
                case "history":
                    showHistory(request, response);
                    break;
                default:
                    showUserDashboard(request, response);
            }
        } catch (Exception e) {
            request.setAttribute("error", "Error: " + e.getMessage());
            try {
                listAvailableQuizzes(request, response);
            } catch (Exception ex) {
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
                case "saveAnswer":
                    saveAnswer(request, response);
                    break;
                case "submit":
                    submitExam(request, response);
                    break;
                default:
                    listAvailableQuizzes(request, response);
            }
        } catch (Exception e) {
            response.setContentType("application/json");
            response.getWriter().write("{\"success\": false, \"message\": \"" + e.getMessage() + "\"}");
        }
    }

    private void listAvailableQuizzes(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, QuizService.ServiceException, SubmissionService.ServiceException {
        User user = (User) request.getSession().getAttribute("user");
        List<Quiz> quizzes = quizService.getActiveQuizzes();

        Map<Integer, Submission> userSubmissions = new HashMap<>();
        for (Quiz quiz : quizzes) {
            Submission submission = submissionService.getUserSubmission(user.getId(), quiz.getId());
            if (submission != null) {
                userSubmissions.put(quiz.getId(), submission);
            }
        }

        request.setAttribute("quizzes", quizzes);
        request.setAttribute("userSubmissions", userSubmissions);
        request.getRequestDispatcher("/user/quiz-list.jsp").forward(request, response);
    }

    private void showUserDashboard(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, QuizService.ServiceException, SubmissionService.ServiceException {
        User user = (User) request.getSession().getAttribute("user");
        List<Quiz> quizzes = quizService.getActiveQuizzes();

        Map<Integer, Submission> userSubmissions = new HashMap<>();
        for (Quiz quiz : quizzes) {
            Submission submission = submissionService.getUserSubmission(user.getId(), quiz.getId());
            if (submission != null) {
                userSubmissions.put(quiz.getId(), submission);
            }
        }

        // Get recent submissions for the user
        List<Submission> recentSubmissions = submissionService.getUserSubmissions(user.getId());

        request.setAttribute("quizzes", quizzes);
        request.setAttribute("userSubmissions", userSubmissions);
        request.setAttribute("recentSubmissions", recentSubmissions);
        request.getRequestDispatcher("/user/dashboard.jsp").forward(request, response);
    }

    private void startExam(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, QuizService.ServiceException, SubmissionService.ServiceException {
        String quizIdStr = request.getParameter("quizId");
        if (quizIdStr == null || quizIdStr.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/ExamServlet?action=list");
            return;
        }

        User user = (User) request.getSession().getAttribute("user");
        Integer quizId = Integer.parseInt(quizIdStr);

        Quiz quiz = quizService.getQuizById(quizId);
        Submission submission = submissionService.startQuiz(quizId, user.getId());

        request.getSession().setAttribute("currentSubmissionId", submission.getId());
        request.getSession().setAttribute("currentQuizId", quizId);
        request.getSession().setAttribute("examStartTime", System.currentTimeMillis());

        request.setAttribute("quiz", quiz);
        request.setAttribute("submission", submission);
        response.sendRedirect(request.getContextPath() + "/ExamServlet?action=take&quizId=" + quizId);
    }

    private void showExam(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, QuizService.ServiceException, SubmissionService.ServiceException {
        String quizIdStr = request.getParameter("quizId");
        if (quizIdStr == null || quizIdStr.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/ExamServlet?action=list");
            return;
        }

        Integer quizId = Integer.parseInt(quizIdStr);
        User user = (User) request.getSession().getAttribute("user");

        Quiz quiz = quizService.getQuizById(quizId);

        // Check if quiz has expired (past deadline)
        if (quiz.isExpired()) {
            request.setAttribute("error", "Quiz sudah melewati deadline (" + quiz.getFormattedDeadline() + ")");
            listAvailableQuizzes(request, response);
            return;
        }

        List<Question> questions = submissionService.getQuestionsForExam(quizId);
        Submission submission = submissionService.getUserSubmission(user.getId(), quizId);

        if (submission == null || submission.isCompleted()) {
            response.sendRedirect(request.getContextPath() + "/ExamServlet?action=list");
            return;
        }

        List<Answer> savedAnswers = submissionService.getResult(submission.getId()).getAnswers();
        Map<Integer, String> answerMap = new HashMap<>();
        for (Answer answer : savedAnswers) {
            answerMap.put(answer.getQuestionId(), answer.getSelectedAnswer());
        }

        request.setAttribute("quiz", quiz);
        request.setAttribute("questions", questions);
        request.setAttribute("submission", submission);
        request.setAttribute("savedAnswers", answerMap);
        request.getRequestDispatcher("/user/take-exam.jsp").forward(request, response);
    }

    private void saveAnswer(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SubmissionService.ServiceException {
        User user = (User) request.getSession().getAttribute("user");
        String submissionIdStr = request.getParameter("submissionId");
        String questionIdStr = request.getParameter("questionId");
        String selectedAnswer = request.getParameter("selectedAnswer");

        // Validate parameters
        if (submissionIdStr == null || submissionIdStr.isEmpty()) {
            response.setContentType("application/json");
            response.getWriter().write("{\"success\": false, \"message\": \"Submission ID required\"}");
            return;
        }
        if (questionIdStr == null || questionIdStr.isEmpty()) {
            response.setContentType("application/json");
            response.getWriter().write("{\"success\": false, \"message\": \"Question ID required\"}");
            return;
        }
        if (selectedAnswer == null || selectedAnswer.isEmpty()) {
            response.setContentType("application/json");
            response.getWriter().write("{\"success\": false, \"message\": \"Answer required\"}");
            return;
        }

        // Validate answer format
        if (!selectedAnswer.matches("[ABCD]")) {
            response.setContentType("application/json");
            response.getWriter().write("{\"success\": false, \"message\": \"Invalid answer format\"}");
            return;
        }

        try {
            Integer submissionId = Integer.parseInt(submissionIdStr);
            Integer questionId = Integer.parseInt(questionIdStr);

            // Verify submission belongs to current user
            Submission submission = submissionService.getUserSubmission(user.getId(),
                submissionService.getResult(submissionId).getQuizId());
            if (submission == null || !submission.getId().equals(submissionId)) {
                response.setContentType("application/json");
                response.getWriter().write("{\"success\": false, \"message\": \"Unauthorized\"}");
                return;
            }

            submissionService.saveAnswer(submissionId, questionId, selectedAnswer);

            response.setContentType("application/json");
            response.getWriter().write("{\"success\": true, \"message\": \"Answer saved\"}");

        } catch (NumberFormatException e) {
            response.setContentType("application/json");
            response.getWriter().write("{\"success\": false, \"message\": \"Invalid ID format\"}");
        } catch (SubmissionService.ServiceException e) {
            response.setContentType("application/json");
            response.getWriter().write("{\"success\": false, \"message\": \"" +
                e.getMessage().replace("\"", "\\\"") + "\"}");
        }
    }

    private void submitExam(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SubmissionService.ServiceException {
        User user = (User) request.getSession().getAttribute("user");
        String submissionIdStr = request.getParameter("submissionId");
        String timeSpentStr = request.getParameter("timeSpent");

        if (submissionIdStr == null || submissionIdStr.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/ExamServlet?action=list");
            return;
        }

        try {
            Integer submissionId = Integer.parseInt(submissionIdStr);
            Integer timeSpent = 0;

            if (timeSpentStr != null && !timeSpentStr.isEmpty()) {
                timeSpent = Integer.parseInt(timeSpentStr);
                if (timeSpent < 0) timeSpent = 0;
            }

            // Get submission and verify ownership
            Submission existingSubmission = submissionService.getResult(submissionId);
            if (existingSubmission == null) {
                response.sendRedirect(request.getContextPath() + "/ExamServlet?action=list");
                return;
            }

            // Verify submission belongs to current user
            if (!existingSubmission.getUserId().equals(user.getId())) {
                response.sendRedirect(request.getContextPath() + "/ExamServlet?action=list");
                return;
            }

            Submission submission = submissionService.submitQuiz(submissionId, timeSpent);

            request.getSession().removeAttribute("currentSubmissionId");
            request.getSession().removeAttribute("currentQuizId");
            request.getSession().removeAttribute("examStartTime");

            response.sendRedirect(request.getContextPath() + "/ExamServlet?action=result&submissionId=" + submissionId);

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/ExamServlet?action=list");
        }
    }

    private void showResult(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SubmissionService.ServiceException {
        User user = (User) request.getSession().getAttribute("user");
        String submissionIdStr = request.getParameter("submissionId");

        if (submissionIdStr == null || submissionIdStr.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/ExamServlet?action=list");
            return;
        }

        try {
            Integer submissionId = Integer.parseInt(submissionIdStr);
            Submission submission = submissionService.getResult(submissionId);

            if (submission == null) {
                response.sendRedirect(request.getContextPath() + "/ExamServlet?action=list");
                return;
            }

            // Verify submission belongs to current user (unless admin)
            if (!submission.getUserId().equals(user.getId()) && !user.isAdmin()) {
                response.sendRedirect(request.getContextPath() + "/ExamServlet?action=list");
                return;
            }

            request.setAttribute("submission", submission);
            request.getRequestDispatcher("/user/exam-result.jsp").forward(request, response);

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/ExamServlet?action=list");
        }
    }

    private void showHistory(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SubmissionService.ServiceException {
        User user = (User) request.getSession().getAttribute("user");
        List<Submission> submissions = submissionService.getUserSubmissions(user.getId());

        request.setAttribute("submissions", submissions);
        request.getRequestDispatcher("/user/exam-history.jsp").forward(request, response);
    }
}
