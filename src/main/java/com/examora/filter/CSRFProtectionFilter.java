package com.examora.filter;

import com.examora.util.PasswordUtil;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

/**
 * CSRF Protection Filter - Validates CSRF tokens for state-changing requests
 */
@WebFilter("/*")
public class CSRFProtectionFilter implements Filter {

    private static final String CSRF_TOKEN_PARAM = "csrfToken";
    private static final String CSRF_TOKEN_HEADER = "X-CSRF-Token";

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        // Initialization
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;

        String method = httpRequest.getMethod();
        String path = httpRequest.getRequestURI();

        // Only check CSRF for state-changing methods (POST, PUT, DELETE, PATCH)
        if ("POST".equalsIgnoreCase(method) || "PUT".equalsIgnoreCase(method) ||
            "DELETE".equalsIgnoreCase(method) || "PATCH".equalsIgnoreCase(method)) {

            // Skip CSRF for login/register (no session yet)
            if (path.contains("/LoginServlet") || path.contains("/RegisterServlet")) {
                chain.doFilter(request, response);
                return;
            }

            HttpSession session = httpRequest.getSession(false);

            if (session != null) {
                String sessionToken = (String) session.getAttribute("csrfToken");
                String requestToken = getCSRFToken(httpRequest);

                if (sessionToken == null || requestToken == null || !sessionToken.equals(requestToken)) {
                    httpResponse.sendError(HttpServletResponse.SC_FORBIDDEN, "Invalid CSRF token");
                    return;
                }
            }
        }

        chain.doFilter(request, response);
    }

    private String getCSRFToken(HttpServletRequest request) {
        // Check header first (for AJAX requests)
        String token = request.getHeader(CSRF_TOKEN_HEADER);
        if (token != null && !token.isEmpty()) {
            return token;
        }

        // Then check parameter
        token = request.getParameter(CSRF_TOKEN_PARAM);
        return token;
    }

    @Override
    public void destroy() {
        // Cleanup
    }
}
