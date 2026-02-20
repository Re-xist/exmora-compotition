package com.examora.controller;

import com.examora.model.Question;
import com.examora.model.QuestionCategory;
import com.examora.model.User;
import com.examora.service.QuestionBankService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

/**
 * QuestionBankServlet - Handles question bank operations
 */
@WebServlet("/QuestionBankServlet")
public class QuestionBankServlet extends HttpServlet {
    private QuestionBankService questionBankService;

    @Override
    public void init() throws ServletException {
        questionBankService = new QuestionBankService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");

        try {
            switch (action != null ? action : "categories") {
                case "categories":
                    listCategories(request, response);
                    break;
                case "createCategory":
                    showCreateCategoryForm(request, response);
                    break;
                case "editCategory":
                    showEditCategoryForm(request, response);
                    break;
                case "questions":
                    listBankQuestions(request, response);
                    break;
                case "createQuestion":
                    showCreateQuestionForm(request, response);
                    break;
                case "editQuestion":
                    showEditQuestionForm(request, response);
                    break;
                case "deleteCategory":
                    deleteCategory(request, response);
                    break;
                case "deleteQuestion":
                    deleteQuestion(request, response);
                    break;
                default:
                    listCategories(request, response);
            }
        } catch (QuestionBankService.ServiceException e) {
            request.setAttribute("error", e.getMessage());
            try {
                listCategories(request, response);
            } catch (QuestionBankService.ServiceException ex) {
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
                case "createCategory":
                    createCategory(request, response);
                    break;
                case "updateCategory":
                    updateCategory(request, response);
                    break;
                case "createQuestion":
                    createQuestion(request, response);
                    break;
                case "updateQuestion":
                    updateQuestion(request, response);
                    break;
                case "addToQuiz":
                    addQuestionsToQuiz(request, response);
                    break;
                default:
                    listCategories(request, response);
            }
        } catch (QuestionBankService.ServiceException e) {
            request.setAttribute("error", e.getMessage());
            try {
                if ("createCategory".equals(action) || "updateCategory".equals(action)) {
                    listCategories(request, response);
                } else {
                    showCreateQuestionForm(request, response);
                }
            } catch (QuestionBankService.ServiceException ex) {
                throw new ServletException(ex);
            }
        }
    }

    private void listCategories(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, QuestionBankService.ServiceException {
        List<QuestionCategory> categories = questionBankService.getAllCategories();
        request.setAttribute("categories", categories);
        request.getRequestDispatcher("/admin/question-categories.jsp").forward(request, response);
    }

    private void showCreateCategoryForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, QuestionBankService.ServiceException {
        List<QuestionCategory> categories = questionBankService.getAllCategories();
        request.setAttribute("categories", categories);
        request.getRequestDispatcher("/admin/question-category-form.jsp").forward(request, response);
    }

    private void showEditCategoryForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, QuestionBankService.ServiceException {
        String idStr = request.getParameter("id");
        if (idStr == null || idStr.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/QuestionBankServlet?action=categories");
            return;
        }

        Integer id = Integer.parseInt(idStr);
        QuestionCategory category = questionBankService.getCategoryById(id);
        request.setAttribute("category", category);
        request.getRequestDispatcher("/admin/question-category-form.jsp").forward(request, response);
    }

    private void createCategory(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, QuestionBankService.ServiceException {
        String name = request.getParameter("name");
        String description = request.getParameter("description");
        User user = (User) request.getSession().getAttribute("user");

        questionBankService.createCategory(name, description, user.getId());
        request.setAttribute("success", "Kategori berhasil dibuat");
        response.sendRedirect(request.getContextPath() + "/QuestionBankServlet?action=categories");
    }

    private void updateCategory(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, QuestionBankService.ServiceException {
        String idStr = request.getParameter("id");
        String name = request.getParameter("name");
        String description = request.getParameter("description");

        Integer id = Integer.parseInt(idStr);
        questionBankService.updateCategory(id, name, description);
        request.setAttribute("success", "Kategori berhasil diupdate");
        response.sendRedirect(request.getContextPath() + "/QuestionBankServlet?action=categories");
    }

    private void deleteCategory(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, QuestionBankService.ServiceException {
        String idStr = request.getParameter("id");
        if (idStr != null && !idStr.isEmpty()) {
            Integer id = Integer.parseInt(idStr);
            questionBankService.deleteCategory(id);
            request.setAttribute("success", "Kategori berhasil dihapus");
        }
        response.sendRedirect(request.getContextPath() + "/QuestionBankServlet?action=categories");
    }

    private void listBankQuestions(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, QuestionBankService.ServiceException {
        String categoryIdStr = request.getParameter("categoryId");
        String searchTerm = request.getParameter("search");

        List<Question> questions;
        if (searchTerm != null && !searchTerm.trim().isEmpty()) {
            Integer categoryId = categoryIdStr != null && !categoryIdStr.isEmpty() ?
                    Integer.parseInt(categoryIdStr) : null;
            questions = questionBankService.searchBankQuestions(searchTerm, categoryId);
        } else if (categoryIdStr != null && !categoryIdStr.isEmpty()) {
            questions = questionBankService.getBankQuestionsByCategory(Integer.parseInt(categoryIdStr));
        } else {
            questions = questionBankService.getAllBankQuestions();
        }

        List<QuestionCategory> categories = questionBankService.getAllCategories();
        request.setAttribute("questions", questions);
        request.setAttribute("categories", categories);
        request.getRequestDispatcher("/admin/question-bank.jsp").forward(request, response);
    }

    private void showCreateQuestionForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, QuestionBankService.ServiceException {
        List<QuestionCategory> categories = questionBankService.getAllCategories();
        request.setAttribute("categories", categories);
        request.getRequestDispatcher("/admin/bank-question-form.jsp").forward(request, response);
    }

    private void showEditQuestionForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, QuestionBankService.ServiceException {
        String idStr = request.getParameter("id");
        if (idStr == null || idStr.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/QuestionBankServlet?action=questions");
            return;
        }

        Integer id = Integer.parseInt(idStr);
        Question question = questionBankService.getQuestionById(id);
        List<QuestionCategory> categories = questionBankService.getAllCategories();
        request.setAttribute("question", question);
        request.setAttribute("categories", categories);
        request.getRequestDispatcher("/admin/bank-question-form.jsp").forward(request, response);
    }

    private void createQuestion(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, QuestionBankService.ServiceException {
        String questionText = request.getParameter("questionText");
        String optionA = request.getParameter("optionA");
        String optionB = request.getParameter("optionB");
        String optionC = request.getParameter("optionC");
        String optionD = request.getParameter("optionD");
        String correctAnswer = request.getParameter("correctAnswer");
        String categoryIdStr = request.getParameter("categoryId");

        Integer categoryId = categoryIdStr != null && !categoryIdStr.isEmpty() ?
                Integer.parseInt(categoryIdStr) : null;

        questionBankService.addQuestionToBank(questionText, optionA, optionB, optionC, optionD,
                correctAnswer, categoryId);
        request.setAttribute("success", "Soal berhasil ditambahkan ke bank");
        response.sendRedirect(request.getContextPath() + "/QuestionBankServlet?action=questions");
    }

    private void updateQuestion(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, QuestionBankService.ServiceException {
        String idStr = request.getParameter("id");
        String questionText = request.getParameter("questionText");
        String optionA = request.getParameter("optionA");
        String optionB = request.getParameter("optionB");
        String optionC = request.getParameter("optionC");
        String optionD = request.getParameter("optionD");
        String correctAnswer = request.getParameter("correctAnswer");
        String categoryIdStr = request.getParameter("categoryId");

        Integer id = Integer.parseInt(idStr);
        Integer categoryId = categoryIdStr != null && !categoryIdStr.isEmpty() ?
                Integer.parseInt(categoryIdStr) : null;

        questionBankService.updateBankQuestion(id, questionText, optionA, optionB, optionC, optionD,
                correctAnswer, categoryId);
        request.setAttribute("success", "Soal berhasil diupdate");
        response.sendRedirect(request.getContextPath() + "/QuestionBankServlet?action=questions");
    }

    private void deleteQuestion(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, QuestionBankService.ServiceException {
        String idStr = request.getParameter("id");
        if (idStr != null && !idStr.isEmpty()) {
            Integer id = Integer.parseInt(idStr);
            questionBankService.deleteBankQuestion(id);
            request.setAttribute("success", "Soal berhasil dihapus");
        }
        response.sendRedirect(request.getContextPath() + "/QuestionBankServlet?action=questions");
    }

    private void addQuestionsToQuiz(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, QuestionBankService.ServiceException {
        String quizIdStr = request.getParameter("quizId");
        String[] questionIdStrs = request.getParameterValues("questionIds");

        if (quizIdStr == null || quizIdStr.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/QuizServlet?action=list");
            return;
        }

        Integer quizId = Integer.parseInt(quizIdStr);
        int addedCount = 0;

        if (questionIdStrs != null && questionIdStrs.length > 0) {
            int order = 0;
            for (String qIdStr : questionIdStrs) {
                try {
                    Integer questionId = Integer.parseInt(qIdStr);
                    questionBankService.addQuestionToQuiz(quizId, questionId, order++);
                    addedCount++;
                } catch (NumberFormatException e) {
                    // Skip invalid IDs
                }
            }
        }

        response.sendRedirect(request.getContextPath() + "/QuestionServlet?action=list&quizId=" + quizId +
                (addedCount > 0 ? "&success=" + java.net.URLEncoder.encode(addedCount + " soal berhasil ditambahkan dari bank", "UTF-8") : ""));
    }
}
