package com.examora.controller;

import com.examora.model.Quiz;
import com.examora.model.User;
import com.examora.service.QuizService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.List;

/**
 * Quiz Servlet - Handles quiz CRUD operations for admin
 */
@WebServlet("/QuizServlet")
public class QuizServlet extends HttpServlet {
    private QuizService quizService;

    @Override
    public void init() throws ServletException {
        quizService = new QuizService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");

        try {
            switch (action != null ? action : "list") {
                case "list":
                    listQuizzes(request, response);
                    break;
                case "create":
                    showCreateForm(request, response);
                    break;
                case "edit":
                    showEditForm(request, response);
                    break;
                case "delete":
                    deleteQuiz(request, response);
                    break;
                case "publish":
                    publishQuiz(request, response);
                    break;
                case "unpublish":
                    unpublishQuiz(request, response);
                    break;
                case "view":
                    viewQuiz(request, response);
                    break;
                default:
                    listQuizzes(request, response);
            }
        } catch (QuizService.ServiceException e) {
            request.setAttribute("error", e.getMessage());
            try {
                listQuizzes(request, response);
            } catch (QuizService.ServiceException ex) {
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
                    createQuiz(request, response);
                    break;
                case "update":
                    updateQuiz(request, response);
                    break;
                default:
                    listQuizzes(request, response);
            }
        } catch (QuizService.ServiceException e) {
            request.setAttribute("error", e.getMessage());
            try {
                if ("create".equals(action)) {
                    showCreateForm(request, response);
                } else {
                    showEditForm(request, response);
                }
            } catch (QuizService.ServiceException ex) {
                throw new ServletException(ex);
            }
        }
    }

    private void listQuizzes(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, QuizService.ServiceException {
        User user = (User) request.getSession().getAttribute("user");
        List<Quiz> quizzes;

        if (user.isAdmin()) {
            quizzes = quizService.getAllQuizzes();
        } else {
            quizzes = quizService.getQuizzesByCreator(user.getId());
        }

        request.setAttribute("quizzes", quizzes);
        request.getRequestDispatcher("/admin/quiz-list.jsp").forward(request, response);
    }

    private void showCreateForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/admin/quiz-form.jsp").forward(request, response);
    }

    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, QuizService.ServiceException {
        String idStr = request.getParameter("id");
        if (idStr == null || idStr.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/QuizServlet?action=list");
            return;
        }

        Integer id = Integer.parseInt(idStr);
        Quiz quiz = quizService.getQuizById(id);
        request.setAttribute("quiz", quiz);
        request.getRequestDispatcher("/admin/quiz-form.jsp").forward(request, response);
    }

    private void createQuiz(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, QuizService.ServiceException {
        String title = request.getParameter("title");
        String description = request.getParameter("description");
        String durationStr = request.getParameter("duration");
        String deadlineStr = request.getParameter("deadline");
        String[] targetTags = request.getParameterValues("targetTags");

        Integer duration = durationStr != null && !durationStr.isEmpty() ?
                Integer.parseInt(durationStr) : 30;

        LocalDateTime deadline = parseDeadline(deadlineStr);

        // Handle target tags - join multiple tags with comma
        String targetTag = processTargetTags(targetTags);

        User user = (User) request.getSession().getAttribute("user");

        Quiz quiz = quizService.createQuiz(title, description, duration, user.getId(), deadline, targetTag);

        request.setAttribute("success", "Quiz berhasil dibuat");
        response.sendRedirect(request.getContextPath() + "/QuestionServlet?action=list&quizId=" + quiz.getId());
    }

    private void updateQuiz(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, QuizService.ServiceException {
        String idStr = request.getParameter("id");
        String title = request.getParameter("title");
        String description = request.getParameter("description");
        String durationStr = request.getParameter("duration");
        String deadlineStr = request.getParameter("deadline");
        String[] targetTags = request.getParameterValues("targetTags");

        Integer id = Integer.parseInt(idStr);
        Integer duration = durationStr != null && !durationStr.isEmpty() ?
                Integer.parseInt(durationStr) : 30;

        LocalDateTime deadline = parseDeadline(deadlineStr);

        // Handle target tags - join multiple tags with comma
        String targetTag = processTargetTags(targetTags);

        quizService.updateQuiz(id, title, description, duration, deadline, targetTag);

        request.setAttribute("success", "Quiz berhasil diupdate");
        response.sendRedirect(request.getContextPath() + "/QuizServlet?action=list");
    }

    private LocalDateTime parseDeadline(String deadlineStr) {
        if (deadlineStr == null || deadlineStr.trim().isEmpty()) {
            return null;
        }

        try {
            // Try parsing with datetime-local format: yyyy-MM-ddTHH:mm
            return LocalDateTime.parse(deadlineStr, DateTimeFormatter.ISO_LOCAL_DATE_TIME);
        } catch (DateTimeParseException e1) {
            try {
                // Try parsing with space separator: yyyy-MM-dd HH:mm
                return LocalDateTime.parse(deadlineStr.replace(" ", "T"),
                    DateTimeFormatter.ISO_LOCAL_DATE_TIME);
            } catch (DateTimeParseException e2) {
                return null;
            }
        }
    }

    /**
     * Process target tags from form - join multiple tags with comma
     * Returns null if "ALL" or no tags selected (means all users)
     */
    private String processTargetTags(String[] targetTags) {
        if (targetTags == null || targetTags.length == 0) {
            return null;
        }

        // Check if "ALL" is selected
        for (String tag : targetTags) {
            if ("ALL".equals(tag)) {
                return null;
            }
        }

        // Filter out empty strings and join with comma
        StringBuilder sb = new StringBuilder();
        for (String tag : targetTags) {
            if (tag != null && !tag.trim().isEmpty()) {
                if (sb.length() > 0) {
                    sb.append(",");
                }
                sb.append(tag.trim());
            }
        }

        return sb.length() > 0 ? sb.toString() : null;
    }

    private void deleteQuiz(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, QuizService.ServiceException {
        String idStr = request.getParameter("id");
        if (idStr != null && !idStr.isEmpty()) {
            Integer id = Integer.parseInt(idStr);
            quizService.deleteQuiz(id);
            request.setAttribute("success", "Quiz berhasil dihapus");
        }
        response.sendRedirect(request.getContextPath() + "/QuizServlet?action=list");
    }

    private void publishQuiz(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, QuizService.ServiceException {
        String idStr = request.getParameter("id");
        if (idStr != null && !idStr.isEmpty()) {
            Integer id = Integer.parseInt(idStr);
            quizService.publishQuiz(id);
            request.setAttribute("success", "Quiz berhasil dipublish");
        }
        response.sendRedirect(request.getContextPath() + "/QuizServlet?action=list");
    }

    private void unpublishQuiz(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, QuizService.ServiceException {
        String idStr = request.getParameter("id");
        if (idStr != null && !idStr.isEmpty()) {
            Integer id = Integer.parseInt(idStr);
            quizService.unpublishQuiz(id);
            request.setAttribute("success", "Quiz berhasil di-unpublish");
        }
        response.sendRedirect(request.getContextPath() + "/QuizServlet?action=list");
    }

    private void viewQuiz(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, QuizService.ServiceException {
        String idStr = request.getParameter("id");
        if (idStr == null || idStr.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/QuizServlet?action=list");
            return;
        }

        Integer id = Integer.parseInt(idStr);
        Quiz quiz = quizService.getQuizById(id);
        request.setAttribute("quiz", quiz);
        request.setAttribute("questions", quizService.getQuestions(id));
        request.getRequestDispatcher("/admin/quiz-view.jsp").forward(request, response);
    }
}
