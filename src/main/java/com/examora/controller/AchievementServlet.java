package com.examora.controller;

import com.examora.model.Achievement;
import com.examora.model.User;
import com.examora.model.UserAchievement;
import com.examora.service.AchievementService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;
import java.util.Map;

/**
 * AchievementServlet - Handles achievement operations
 */
@WebServlet("/AchievementServlet")
public class AchievementServlet extends HttpServlet {
    private AchievementService achievementService;

    @Override
    public void init() throws ServletException {
        achievementService = new AchievementService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        User user = (User) request.getSession().getAttribute("user");

        try {
            if (action == null) {
                action = user.isAdmin() ? "list" : "myAchievements";
            }

            switch (action) {
                case "list":
                    listAchievements(request, response);
                    break;
                case "myAchievements":
                    showMyAchievements(request, response);
                    break;
                case "create":
                    showCreateForm(request, response);
                    break;
                case "edit":
                    showEditForm(request, response);
                    break;
                case "delete":
                    deleteAchievement(request, response);
                    break;
                case "toggle":
                    toggleAchievement(request, response);
                    break;
                case "leaderboard":
                    showLeaderboard(request, response);
                    break;
                default:
                    if (user.isAdmin()) {
                        listAchievements(request, response);
                    } else {
                        showMyAchievements(request, response);
                    }
            }
        } catch (AchievementService.ServiceException e) {
            request.setAttribute("error", e.getMessage());
            try {
                if (user.isAdmin()) {
                    listAchievements(request, response);
                } else {
                    showMyAchievements(request, response);
                }
            } catch (AchievementService.ServiceException ex) {
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
                    createAchievement(request, response);
                    break;
                case "update":
                    updateAchievement(request, response);
                    break;
                default:
                    listAchievements(request, response);
            }
        } catch (AchievementService.ServiceException e) {
            request.setAttribute("error", e.getMessage());
            try {
                if ("create".equals(action)) {
                    showCreateForm(request, response);
                } else {
                    showEditForm(request, response);
                }
            } catch (AchievementService.ServiceException ex) {
                throw new ServletException(ex);
            }
        }
    }

    private void listAchievements(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, AchievementService.ServiceException {
        User user = (User) request.getSession().getAttribute("user");
        if (!user.isAdmin()) {
            response.sendRedirect(request.getContextPath() + "/AchievementServlet?action=myAchievements");
            return;
        }

        List<Achievement> achievements = achievementService.getAllAchievements();
        request.setAttribute("achievements", achievements);
        request.getRequestDispatcher("/admin/achievements.jsp").forward(request, response);
    }

    private void showMyAchievements(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, AchievementService.ServiceException {
        User user = (User) request.getSession().getAttribute("user");

        List<UserAchievement> userAchievements = achievementService.getUserAchievements(user.getId());
        List<Achievement> allAchievements = achievementService.getActiveAchievements();
        int totalPoints = achievementService.getUserTotalPoints(user.getId());
        int achievementCount = achievementService.countUserAchievements(user.getId());

        // Get leaderboard
        List<Map<String, Object>> leaderboard = achievementService.getLeaderboard(10);

        request.setAttribute("userAchievements", userAchievements);
        request.setAttribute("allAchievements", allAchievements);
        request.setAttribute("totalPoints", totalPoints);
        request.setAttribute("achievementCount", achievementCount);
        request.setAttribute("leaderboard", leaderboard);
        request.getRequestDispatcher("/user/achievements.jsp").forward(request, response);
    }

    private void showCreateForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, AchievementService.ServiceException {
        User user = (User) request.getSession().getAttribute("user");
        if (!user.isAdmin()) {
            response.sendRedirect(request.getContextPath() + "/AchievementServlet?action=myAchievements");
            return;
        }

        request.getRequestDispatcher("/admin/achievement-form.jsp").forward(request, response);
    }

    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, AchievementService.ServiceException {
        User user = (User) request.getSession().getAttribute("user");
        if (!user.isAdmin()) {
            response.sendRedirect(request.getContextPath() + "/AchievementServlet?action=myAchievements");
            return;
        }

        String idStr = request.getParameter("id");
        if (idStr == null || idStr.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/AchievementServlet?action=list");
            return;
        }

        Integer id = Integer.parseInt(idStr);
        Achievement achievement = achievementService.getAllAchievements().stream()
                .filter(a -> a.getId().equals(id))
                .findFirst()
                .orElse(null);

        if (achievement == null) {
            request.setAttribute("error", "Achievement tidak ditemukan");
            response.sendRedirect(request.getContextPath() + "/AchievementServlet?action=list");
            return;
        }

        request.setAttribute("achievement", achievement);
        request.getRequestDispatcher("/admin/achievement-form.jsp").forward(request, response);
    }

    private void createAchievement(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, AchievementService.ServiceException {
        String name = request.getParameter("name");
        String description = request.getParameter("description");
        String icon = request.getParameter("icon");
        String color = request.getParameter("color");
        String category = request.getParameter("category");
        String conditionType = request.getParameter("conditionType");
        String conditionValueStr = request.getParameter("conditionValue");
        String pointsStr = request.getParameter("points");

        Integer conditionValue = conditionValueStr != null ? Integer.parseInt(conditionValueStr) : 0;
        Integer points = pointsStr != null ? Integer.parseInt(pointsStr) : 10;

        achievementService.createAchievement(name, description, icon, color, category,
                conditionType, conditionValue, points);
        request.setAttribute("success", "Achievement berhasil dibuat");
        response.sendRedirect(request.getContextPath() + "/AchievementServlet?action=list");
    }

    private void updateAchievement(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, AchievementService.ServiceException {
        String idStr = request.getParameter("id");
        String name = request.getParameter("name");
        String description = request.getParameter("description");
        String icon = request.getParameter("icon");
        String color = request.getParameter("color");
        String category = request.getParameter("category");
        String conditionType = request.getParameter("conditionType");
        String conditionValueStr = request.getParameter("conditionValue");
        String pointsStr = request.getParameter("points");
        String isActiveStr = request.getParameter("isActive");

        Integer id = Integer.parseInt(idStr);
        Integer conditionValue = conditionValueStr != null ? Integer.parseInt(conditionValueStr) : 0;
        Integer points = pointsStr != null ? Integer.parseInt(pointsStr) : 10;
        Boolean isActive = "on".equals(isActiveStr) || "true".equals(isActiveStr);

        achievementService.updateAchievement(id, name, description, icon, color, category,
                conditionType, conditionValue, points, isActive);
        request.setAttribute("success", "Achievement berhasil diupdate");
        response.sendRedirect(request.getContextPath() + "/AchievementServlet?action=list");
    }

    private void deleteAchievement(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, AchievementService.ServiceException {
        String idStr = request.getParameter("id");
        if (idStr != null && !idStr.isEmpty()) {
            Integer id = Integer.parseInt(idStr);
            achievementService.deleteAchievement(id);
            request.setAttribute("success", "Achievement berhasil dihapus");
        }
        response.sendRedirect(request.getContextPath() + "/AchievementServlet?action=list");
    }

    private void toggleAchievement(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, AchievementService.ServiceException {
        String idStr = request.getParameter("id");
        if (idStr != null && !idStr.isEmpty()) {
            Integer id = Integer.parseInt(idStr);
            achievementService.toggleAchievementStatus(id);
            request.setAttribute("success", "Status achievement berhasil diubah");
        }
        response.sendRedirect(request.getContextPath() + "/AchievementServlet?action=list");
    }

    private void showLeaderboard(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, AchievementService.ServiceException {
        List<Map<String, Object>> leaderboard = achievementService.getLeaderboard(50);
        request.setAttribute("leaderboard", leaderboard);
        request.getRequestDispatcher("/user/leaderboard.jsp").forward(request, response);
    }
}
