package com.examora.controller;

import com.examora.model.AuditLog;
import com.examora.model.User;
import com.examora.service.AuditService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.List;

/**
 * AuditServlet - Handles audit log viewing
 */
@WebServlet("/AuditServlet")
public class AuditServlet extends HttpServlet {
    private AuditService auditService;
    private static final int PAGE_SIZE = 50;

    @Override
    public void init() throws ServletException {
        auditService = new AuditService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");

        try {
            if ("detail".equals(action)) {
                showDetail(request, response);
            } else if ("cleanup".equals(action)) {
                cleanupLogs(request, response);
            } else {
                listLogs(request, response);
            }
        } catch (AuditService.ServiceException e) {
            request.setAttribute("error", e.getMessage());
            try {
                listLogs(request, response);
            } catch (AuditService.ServiceException ex) {
                throw new ServletException(ex);
            }
        }
    }

    private void listLogs(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, AuditService.ServiceException {
        // Get filter parameters
        String actionType = request.getParameter("actionType");
        String entityType = request.getParameter("entityType");
        String status = request.getParameter("status");
        String startDateStr = request.getParameter("startDate");
        String endDateStr = request.getParameter("endDate");
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

        LocalDateTime startDate = parseDateTime(startDateStr);
        LocalDateTime endDate = parseDateTime(endDateStr);

        // Get filtered logs
        List<AuditLog> logs = auditService.getFilteredLogs(actionType, entityType, status,
                startDate, endDate, page, PAGE_SIZE);
        int totalCount = auditService.countFilteredLogs(actionType, entityType, status,
                startDate, endDate);
        int totalPages = (int) Math.ceil((double) totalCount / PAGE_SIZE);

        request.setAttribute("logs", logs);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalCount", totalCount);
        request.setAttribute("actionType", actionType);
        request.setAttribute("entityType", entityType);
        request.setAttribute("status", status);
        request.setAttribute("startDate", startDateStr);
        request.setAttribute("endDate", endDateStr);

        request.getRequestDispatcher("/admin/audit-log.jsp").forward(request, response);
    }

    private void showDetail(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, AuditService.ServiceException {
        String idStr = request.getParameter("id");
        if (idStr == null || idStr.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/AuditServlet");
            return;
        }

        Integer id = Integer.parseInt(idStr);
        AuditLog log = auditService.getAllLogs(1, 1000).stream()
                .filter(l -> l.getId().equals(id))
                .findFirst()
                .orElse(null);

        if (log == null) {
            request.setAttribute("error", "Log tidak ditemukan");
            response.sendRedirect(request.getContextPath() + "/AuditServlet");
            return;
        }

        request.setAttribute("log", log);
        request.getRequestDispatcher("/admin/audit-log-detail.jsp").forward(request, response);
    }

    private void cleanupLogs(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, AuditService.ServiceException {
        String daysStr = request.getParameter("days");
        int days = 90; // Default: keep logs for 90 days

        if (daysStr != null && !daysStr.isEmpty()) {
            try {
                days = Integer.parseInt(daysStr);
            } catch (NumberFormatException e) {
                days = 90;
            }
        }

        int deleted = auditService.cleanupOldLogs(days);
        request.setAttribute("success", deleted + " log lama berhasil dihapus");
        response.sendRedirect(request.getContextPath() + "/AuditServlet");
    }

    private LocalDateTime parseDateTime(String dateStr) {
        if (dateStr == null || dateStr.trim().isEmpty()) {
            return null;
        }

        try {
            return LocalDateTime.parse(dateStr + "T00:00:00");
        } catch (DateTimeParseException e) {
            try {
                return LocalDateTime.parse(dateStr, DateTimeFormatter.ISO_LOCAL_DATE_TIME);
            } catch (DateTimeParseException e2) {
                return null;
            }
        }
    }
}
