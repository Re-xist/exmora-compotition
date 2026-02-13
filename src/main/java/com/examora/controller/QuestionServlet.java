package com.examora.controller;

import com.examora.model.Question;
import com.examora.model.Quiz;
import com.examora.service.QuizService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

/**
 * Question Servlet - Handles question CRUD operations
 */
@WebServlet("/QuestionServlet")
public class QuestionServlet extends HttpServlet {
    private QuizService quizService;

    @Override
    public void init() throws ServletException {
        quizService = new QuizService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        String quizIdStr = request.getParameter("quizId");

        if (quizIdStr == null || quizIdStr.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/QuizServlet?action=list");
            return;
        }

        try {
            Integer quizId = Integer.parseInt(quizIdStr);
            Quiz quiz = quizService.getQuizById(quizId);
            request.setAttribute("quiz", quiz);

            switch (action != null ? action : "list") {
                case "list":
                    listQuestions(request, response, quizId);
                    break;
                case "create":
                    showCreateForm(request, response, quizId);
                    break;
                case "edit":
                    showEditForm(request, response, quizId);
                    break;
                case "delete":
                    deleteQuestion(request, response, quizId);
                    break;
                default:
                    listQuestions(request, response, quizId);
            }
        } catch (QuizService.ServiceException e) {
            request.setAttribute("error", e.getMessage());
            try {
                listQuestions(request, response, Integer.parseInt(quizIdStr));
            } catch (QuizService.ServiceException ex) {
                throw new ServletException(ex);
            }
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        String quizIdStr = request.getParameter("quizId");

        if (quizIdStr == null || quizIdStr.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/QuizServlet?action=list");
            return;
        }

        try {
            Integer quizId = Integer.parseInt(quizIdStr);
            Quiz quiz = quizService.getQuizById(quizId);
            request.setAttribute("quiz", quiz);

            switch (action != null ? action : "") {
                case "create":
                    createQuestion(request, response, quizId);
                    break;
                case "update":
                    updateQuestion(request, response, quizId);
                    break;
                default:
                    listQuestions(request, response, quizId);
            }
        } catch (QuizService.ServiceException e) {
            request.setAttribute("error", e.getMessage());
            try {
                listQuestions(request, response, Integer.parseInt(quizIdStr));
            } catch (QuizService.ServiceException ex) {
                throw new ServletException(ex);
            }
        }
    }

    private void listQuestions(HttpServletRequest request, HttpServletResponse response, Integer quizId)
            throws ServletException, IOException, QuizService.ServiceException {
        List<Question> questions = quizService.getQuestions(quizId);
        request.setAttribute("questions", questions);
        request.getRequestDispatcher("/admin/question-list.jsp").forward(request, response);
    }

    private void showCreateForm(HttpServletRequest request, HttpServletResponse response, Integer quizId)
            throws ServletException, IOException {
        request.getRequestDispatcher("/admin/question-form.jsp").forward(request, response);
    }

    private void showEditForm(HttpServletRequest request, HttpServletResponse response, Integer quizId)
            throws ServletException, IOException, QuizService.ServiceException {
        String idStr = request.getParameter("id");
        if (idStr == null || idStr.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/QuestionServlet?action=list&quizId=" + quizId);
            return;
        }

        Integer id = Integer.parseInt(idStr);
        List<Question> questions = quizService.getQuestions(quizId);
        Question question = questions.stream()
                .filter(q -> q.getId().equals(id))
                .findFirst()
                .orElse(null);

        if (question == null) {
            request.setAttribute("error", "Pertanyaan tidak ditemukan");
            listQuestions(request, response, quizId);
            return;
        }

        request.setAttribute("question", question);
        request.getRequestDispatcher("/admin/question-form.jsp").forward(request, response);
    }

    private void createQuestion(HttpServletRequest request, HttpServletResponse response, Integer quizId)
            throws ServletException, IOException, QuizService.ServiceException {
        String questionText = request.getParameter("questionText");
        String optionA = request.getParameter("optionA");
        String optionB = request.getParameter("optionB");
        String optionC = request.getParameter("optionC");
        String optionD = request.getParameter("optionD");
        String correctAnswer = request.getParameter("correctAnswer");
        String saveAndAdd = request.getParameter("saveAndAdd");

        quizService.addQuestion(quizId, questionText, optionA, optionB, optionC, optionD, correctAnswer);

        if ("true".equals(saveAndAdd)) {
            // Redirect back to create form for adding more questions
            response.sendRedirect(request.getContextPath() + "/QuestionServlet?action=create&quizId=" + quizId + "&success=true");
        } else {
            request.setAttribute("success", "Pertanyaan berhasil ditambahkan");
            response.sendRedirect(request.getContextPath() + "/QuestionServlet?action=list&quizId=" + quizId);
        }
    }

    private void updateQuestion(HttpServletRequest request, HttpServletResponse response, Integer quizId)
            throws ServletException, IOException, QuizService.ServiceException {
        String idStr = request.getParameter("id");
        String questionText = request.getParameter("questionText");
        String optionA = request.getParameter("optionA");
        String optionB = request.getParameter("optionB");
        String optionC = request.getParameter("optionC");
        String optionD = request.getParameter("optionD");
        String correctAnswer = request.getParameter("correctAnswer");

        Integer id = Integer.parseInt(idStr);

        quizService.updateQuestion(id, questionText, optionA, optionB, optionC, optionD, correctAnswer);

        request.setAttribute("success", "Pertanyaan berhasil diupdate");
        response.sendRedirect(request.getContextPath() + "/QuestionServlet?action=list&quizId=" + quizId);
    }

    private void deleteQuestion(HttpServletRequest request, HttpServletResponse response, Integer quizId)
            throws ServletException, IOException, QuizService.ServiceException {
        String idStr = request.getParameter("id");
        if (idStr != null && !idStr.isEmpty()) {
            Integer id = Integer.parseInt(idStr);
            quizService.deleteQuestion(id);
            request.setAttribute("success", "Pertanyaan berhasil dihapus");
        }
        response.sendRedirect(request.getContextPath() + "/QuestionServlet?action=list&quizId=" + quizId);
    }
}
