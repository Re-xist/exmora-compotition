package com.examora.controller;

import com.examora.model.NotificationTemplate;
import com.examora.model.NotificationQueue;
import com.examora.service.NotificationService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

/**
 * NotificationServlet - Handles notification management
 */
@WebServlet("/NotificationServlet")
public class NotificationServlet extends HttpServlet {
    private NotificationService notificationService;
    private static final int PAGE_SIZE = 20;

    @Override
    public void init() throws ServletException {
        notificationService = new NotificationService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");

        try {
            switch (action != null ? action : "templates") {
                case "templates":
                    listTemplates(request, response);
                    break;
                case "createTemplate":
                    showCreateTemplateForm(request, response);
                    break;
                case "editTemplate":
                    showEditTemplateForm(request, response);
                    break;
                case "deleteTemplate":
                    deleteTemplate(request, response);
                    break;
                case "queue":
                    listQueue(request, response);
                    break;
                case "process":
                    processQueue(request, response);
                    break;
                case "cleanup":
                    cleanupQueue(request, response);
                    break;
                default:
                    listTemplates(request, response);
            }
        } catch (NotificationService.ServiceException e) {
            request.setAttribute("error", e.getMessage());
            try {
                listTemplates(request, response);
            } catch (NotificationService.ServiceException ex) {
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
                case "createTemplate":
                    createTemplate(request, response);
                    break;
                case "updateTemplate":
                    updateTemplate(request, response);
                    break;
                case "sendTest":
                    sendTestNotification(request, response);
                    break;
                default:
                    listTemplates(request, response);
            }
        } catch (NotificationService.ServiceException e) {
            request.setAttribute("error", e.getMessage());
            try {
                if ("createTemplate".equals(action)) {
                    showCreateTemplateForm(request, response);
                } else {
                    showEditTemplateForm(request, response);
                }
            } catch (NotificationService.ServiceException ex) {
                throw new ServletException(ex);
            }
        }
    }

    private void listTemplates(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, NotificationService.ServiceException {
        List<NotificationTemplate> templates = notificationService.getAllTemplates();
        request.setAttribute("templates", templates);
        request.getRequestDispatcher("/admin/notification-templates.jsp").forward(request, response);
    }

    private void showCreateTemplateForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, NotificationService.ServiceException {
        request.getRequestDispatcher("/admin/notification-template-form.jsp").forward(request, response);
    }

    private void showEditTemplateForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, NotificationService.ServiceException {
        String idStr = request.getParameter("id");
        if (idStr == null || idStr.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/NotificationServlet?action=templates");
            return;
        }

        Integer id = Integer.parseInt(idStr);
        NotificationTemplate template = notificationService.getTemplateById(id);
        request.setAttribute("template", template);
        request.getRequestDispatcher("/admin/notification-template-form.jsp").forward(request, response);
    }

    private void createTemplate(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, NotificationService.ServiceException {
        String name = request.getParameter("name");
        String subject = request.getParameter("subject");
        String body = request.getParameter("body");
        String type = request.getParameter("type");

        notificationService.createTemplate(name, subject, body, type);
        request.setAttribute("success", "Template berhasil dibuat");
        response.sendRedirect(request.getContextPath() + "/NotificationServlet?action=templates");
    }

    private void updateTemplate(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, NotificationService.ServiceException {
        String idStr = request.getParameter("id");
        String name = request.getParameter("name");
        String subject = request.getParameter("subject");
        String body = request.getParameter("body");
        String type = request.getParameter("type");
        String isActiveStr = request.getParameter("isActive");

        Integer id = Integer.parseInt(idStr);
        Boolean isActive = "on".equals(isActiveStr) || "true".equals(isActiveStr);

        notificationService.updateTemplate(id, name, subject, body, type, isActive);
        request.setAttribute("success", "Template berhasil diupdate");
        response.sendRedirect(request.getContextPath() + "/NotificationServlet?action=templates");
    }

    private void deleteTemplate(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, NotificationService.ServiceException {
        String idStr = request.getParameter("id");
        if (idStr != null && !idStr.isEmpty()) {
            Integer id = Integer.parseInt(idStr);
            notificationService.deleteTemplate(id);
            request.setAttribute("success", "Template berhasil dihapus");
        }
        response.sendRedirect(request.getContextPath() + "/NotificationServlet?action=templates");
    }

    private void listQueue(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, NotificationService.ServiceException {
        String status = request.getParameter("status");
        String pageStr = request.getParameter("page");

        int page = 1;
        if (pageStr != null && !pageStr.isEmpty()) {
            try {
                page = Integer.parseInt(pageStr);
                if (page < 1) page = 1;
            } catch (NumberFormatException e) {
                page = 1;
            }
        }

        List<NotificationQueue> queue = notificationService.getQueueWithFilters(status, page, PAGE_SIZE);
        int totalCount = notificationService.countQueueWithFilters(status);
        int totalPages = (int) Math.ceil((double) totalCount / PAGE_SIZE);

        // Count by status
        int pendingCount = notificationService.countQueueWithFilters("pending");
        int sentCount = notificationService.countQueueWithFilters("sent");
        int failedCount = notificationService.countQueueWithFilters("failed");

        request.setAttribute("queue", queue);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalCount", totalCount);
        request.setAttribute("status", status);
        request.setAttribute("pendingCount", pendingCount);
        request.setAttribute("sentCount", sentCount);
        request.setAttribute("failedCount", failedCount);

        request.getRequestDispatcher("/admin/notification-queue.jsp").forward(request, response);
    }

    private void processQueue(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, NotificationService.ServiceException {
        String batchSizeStr = request.getParameter("batchSize");
        int batchSize = batchSizeStr != null ? Integer.parseInt(batchSizeStr) : 10;

        int sentCount = notificationService.processPendingNotifications(batchSize);
        request.setAttribute("success", sentCount + " notifikasi berhasil dikirim");
        response.sendRedirect(request.getContextPath() + "/NotificationServlet?action=queue");
    }

    private void cleanupQueue(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, NotificationService.ServiceException {
        String daysStr = request.getParameter("days");
        int days = daysStr != null ? Integer.parseInt(daysStr) : 30;

        int deleted = notificationService.cleanupOldNotifications(days);
        request.setAttribute("success", deleted + " notifikasi lama berhasil dihapus");
        response.sendRedirect(request.getContextPath() + "/NotificationServlet?action=queue");
    }

    private void sendTestNotification(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, NotificationService.ServiceException {
        // This would send a test notification to the admin
        // For now, just show success message
        request.setAttribute("success", "Fitur test notification akan segera tersedia");
        response.sendRedirect(request.getContextPath() + "/NotificationServlet?action=templates");
    }
}
