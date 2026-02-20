package com.examora.controller;

import com.examora.model.User;
import com.examora.service.AuditService;
import com.examora.service.UserService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

/**
 * Login Servlet - Handles user authentication
 */
@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {
    private UserService userService;
    private AuditService auditService;

    @Override
    public void init() throws ServletException {
        userService = new UserService();
        auditService = new AuditService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("user") != null) {
            User user = (User) session.getAttribute("user");
            redirectToDashboard(request, response, user);
            return;
        }

        request.getRequestDispatcher("/common/login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String email = request.getParameter("email");
        String password = request.getParameter("password");

        if (email == null || email.trim().isEmpty() ||
            password == null || password.trim().isEmpty()) {
            request.setAttribute("error", "Email dan password harus diisi");
            request.getRequestDispatcher("/common/login.jsp").forward(request, response);
            return;
        }

        try {
            User user = userService.authenticate(email, password);

            // Invalidate old session to prevent session fixation attacks
            HttpSession oldSession = request.getSession(false);
            if (oldSession != null) {
                oldSession.invalidate();
            }

            // Create new session with new ID
            HttpSession session = request.getSession(true);
            session.setAttribute("user", user);
            session.setAttribute("userId", user.getId());
            session.setAttribute("userName", user.getName());
            session.setAttribute("userRole", user.getRole());
            session.setAttribute("csrfToken", com.examora.util.PasswordUtil.generateToken());

            // Audit log for successful login
            auditService.logLogin(user, request, true, null);

            redirectToDashboard(request, response, user);

        } catch (UserService.ServiceException e) {
            // Audit log for failed login (create temporary user object for logging)
            User failedUser = new User();
            failedUser.setEmail(email);
            auditService.logLogin(failedUser, request, false, e.getMessage());

            request.setAttribute("error", e.getMessage());
            request.setAttribute("email", email);
            request.getRequestDispatcher("/common/login.jsp").forward(request, response);
        }
    }

    private void redirectToDashboard(HttpServletRequest request, HttpServletResponse response, User user)
            throws IOException {
        String contextPath = request.getContextPath();
        if (user.isAdmin()) {
            response.sendRedirect(contextPath + "/AdminServlet?action=dashboard");
        } else {
            response.sendRedirect(contextPath + "/ExamServlet?action=dashboard");
        }
    }
}
