package com.examora.controller;

import com.examora.model.User;
import com.examora.service.AuditService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

/**
 * Logout Servlet - Handles user logout
 */
@WebServlet("/LogoutServlet")
public class LogoutServlet extends HttpServlet {
    private AuditService auditService;

    @Override
    public void init() throws ServletException {
        auditService = new AuditService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processLogout(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processLogout(request, response);
    }

    private void processLogout(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        HttpSession session = request.getSession(false);

        if (session != null) {
            // Get user before invalidating session for audit log
            User user = (User) session.getAttribute("user");
            if (user != null) {
                auditService.logLogout(user, request);
            }
            session.invalidate();
        }

        response.sendRedirect(request.getContextPath() + "/LoginServlet");
    }
}
