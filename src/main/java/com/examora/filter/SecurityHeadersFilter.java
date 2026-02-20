package com.examora.filter;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 * Security Headers Filter - Adds security-related HTTP headers to all responses
 */
@WebFilter("/*")
public class SecurityHeadersFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        // Initialization
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletResponse httpResponse = (HttpServletResponse) response;
        HttpServletRequest httpRequest = (HttpServletRequest) request;

        // Content Security Policy - Prevents XSS attacks
        // Adjust as needed for your application
        httpResponse.setHeader("Content-Security-Policy",
            "default-src 'self'; " +
            "script-src 'self' 'unsafe-inline' 'unsafe-eval' https://cdn.jsdelivr.net; " +
            "style-src 'self' 'unsafe-inline' https://cdn.jsdelivr.net https://fonts.googleapis.com; " +
            "font-src 'self' https://cdn.jsdelivr.net https://fonts.gstatic.com; " +
            "img-src 'self' data: https:; " +
            "connect-src 'self'; " +
            "frame-ancestors 'none'; " +
            "base-uri 'self'; " +
            "form-action 'self'");

        // X-Frame-Options - Prevents clickjacking
        httpResponse.setHeader("X-Frame-Options", "DENY");

        // X-Content-Type-Options - Prevents MIME type sniffing
        httpResponse.setHeader("X-Content-Type-Options", "nosniff");

        // X-XSS-Protection - Enables browser XSS filter (legacy but still useful)
        httpResponse.setHeader("X-XSS-Protection", "1; mode=block");

        // Referrer-Policy - Controls referrer information
        httpResponse.setHeader("Referrer-Policy", "strict-origin-when-cross-origin");

        // Permissions-Policy - Restricts browser features
        httpResponse.setHeader("Permissions-Policy",
            "geolocation=(), " +
            "microphone=(), " +
            "camera=(), " +
            "payment=(), " +
            "usb=()");

        // Cache-Control - Prevents caching of sensitive pages
        String path = httpRequest.getRequestURI();
        if (path.contains("/admin/") || path.contains("/user/") || path.contains("Servlet")) {
            httpResponse.setHeader("Cache-Control", "no-store, no-cache, must-revalidate, max-age=0");
            httpResponse.setHeader("Pragma", "no-cache");
            httpResponse.setHeader("Expires", "0");
        }

        // Continue with the request
        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {
        // Cleanup
    }
}
