package com.examora.filter;

import com.examora.model.User;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

/**
 * Authentication Filter - Protects pages that require login
 */
@WebFilter("/*")
public class AuthFilter implements Filter {

    private static final String[] PUBLIC_PATHS = {
            "/", "/index.jsp", "/login", "/register", "/LoginServlet", "/RegisterServlet",
            "/assets/", "/css/", "/js/", "/images/"
    };

    private static final String[] ADMIN_PATHS = {
            "/admin/", "/AdminServlet", "/QuizServlet", "/QuestionServlet", "/ArenaServlet",
            "/QuestionBankServlet", "/AchievementServlet", "/AuditServlet", "/NotificationServlet",
            "/AttendanceServlet"
    };

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        // Initialization
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;

        String path = httpRequest.getRequestURI().substring(httpRequest.getContextPath().length());

        // Check if path is public
        if (isPublicPath(path)) {
            chain.doFilter(request, response);
            return;
        }

        // Check if user is logged in
        HttpSession session = httpRequest.getSession(false);
        User user = session != null ? (User) session.getAttribute("user") : null;

        if (user == null) {
            // Not logged in, redirect to login
            String loginUrl = httpRequest.getContextPath() + "/login";
            httpResponse.sendRedirect(loginUrl);
            return;
        }

        // Check admin access
        if (isAdminPath(path) && !user.isAdmin()) {
            httpResponse.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied");
            return;
        }

        // User is authenticated, continue
        chain.doFilter(request, response);
    }

    private boolean isPublicPath(String path) {
        if (path == null || path.isEmpty()) {
            return true;
        }

        for (String publicPath : PUBLIC_PATHS) {
            if (path.startsWith(publicPath) || path.equals(publicPath)) {
                return true;
            }
        }

        // Allow static resources
        if (path.contains("/assets/") || path.endsWith(".css") || path.endsWith(".js") ||
                path.endsWith(".png") || path.endsWith(".jpg") || path.endsWith(".gif")) {
            return true;
        }

        return false;
    }

    private boolean isAdminPath(String path) {
        if (path == null) {
            return false;
        }

        for (String adminPath : ADMIN_PATHS) {
            if (path.startsWith(adminPath)) {
                return true;
            }
        }

        return false;
    }

    @Override
    public void destroy() {
        // Cleanup
    }
}
