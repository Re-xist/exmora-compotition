package com.examora.controller;

import com.examora.model.User;
import com.examora.service.UserService;
import com.examora.util.ValidationUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;
import java.io.IOException;

/**
 * Settings Servlet - Handles user settings (profile, password, photo)
 */
@WebServlet("/SettingsServlet")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024,     // 1 MB
    maxFileSize = 1024 * 1024 * 2,       // 2 MB
    maxRequestSize = 1024 * 1024 * 10    // 10 MB
)
public class SettingsServlet extends HttpServlet {
    private UserService userService;

    @Override
    public void init() throws ServletException {
        userService = new UserService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Check authentication
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/LoginServlet");
            return;
        }

        // Get current user
        User currentUser = (User) session.getAttribute("user");

        // Refresh user data from database
        try {
            User freshUser = userService.getUserById(currentUser.getId());
            session.setAttribute("user", freshUser);
            request.setAttribute("user", freshUser);
        } catch (UserService.ServiceException e) {
            request.setAttribute("error", e.getMessage());
            request.setAttribute("user", currentUser);
        }

        // Forward to settings page based on role
        request.getRequestDispatcher("/common/settings.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Check authentication
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/LoginServlet");
            return;
        }

        User currentUser = (User) session.getAttribute("user");
        String action = request.getParameter("action");

        // Validate CSRF token
        String sessionToken = (String) session.getAttribute("csrfToken");
        String requestToken = request.getParameter("csrfToken");

        if (requestToken == null || !requestToken.equals(sessionToken)) {
            request.setAttribute("error", "Sesi tidak valid. Silakan coba lagi.");
            doGet(request, response);
            return;
        }

        try {
            switch (action) {
                case "updateProfile":
                    updateProfile(request, response, currentUser, session);
                    break;
                case "changePassword":
                    changePassword(request, response, currentUser);
                    break;
                case "updatePhoto":
                    updatePhoto(request, response, currentUser, session);
                    break;
                default:
                    request.setAttribute("error", "Aksi tidak valid");
                    doGet(request, response);
            }
        } catch (UserService.ServiceException e) {
            request.setAttribute("error", e.getMessage());
            doGet(request, response);
        }
    }

    private void updateProfile(HttpServletRequest request, HttpServletResponse response,
                                User currentUser, HttpSession session)
            throws ServletException, IOException, UserService.ServiceException {
        String name = request.getParameter("name");
        String email = request.getParameter("email");

        // Validate inputs
        if (ValidationUtil.isEmpty(name)) {
            request.setAttribute("error", "Nama tidak boleh kosong");
            doGet(request, response);
            return;
        }

        if (ValidationUtil.isEmpty(email)) {
            request.setAttribute("error", "Email tidak boleh kosong");
            doGet(request, response);
            return;
        }

        // Sanitize inputs
        name = ValidationUtil.sanitize(name.trim());
        email = email.trim().toLowerCase();

        // Get upload directory
        String uploadDir = getServletContext().getRealPath("/");

        // Check for photo upload
        Part photoPart = null;
        try {
            photoPart = request.getPart("photo");
        } catch (Exception e) {
            // No photo uploaded, ignore
        }

        // Update profile
        User updatedUser;
        if (photoPart != null && photoPart.getSize() > 0) {
            updatedUser = userService.updateProfileWithPhoto(currentUser.getId(), name, email, uploadDir, photoPart);
        } else {
            updatedUser = userService.updateProfileBasic(currentUser.getId(), name, email);
        }

        // Update session
        session.setAttribute("user", updatedUser);
        session.setAttribute("userName", updatedUser.getName());

        request.setAttribute("success", "Profil berhasil diperbarui");
        request.setAttribute("user", updatedUser);
        request.getRequestDispatcher("/common/settings.jsp").forward(request, response);
    }

    private void changePassword(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws ServletException, IOException, UserService.ServiceException {
        String currentPassword = request.getParameter("currentPassword");
        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");

        // Validate inputs
        if (ValidationUtil.isEmpty(currentPassword)) {
            request.setAttribute("error", "Password saat ini harus diisi");
            doGet(request, response);
            return;
        }

        if (ValidationUtil.isEmpty(newPassword)) {
            request.setAttribute("error", "Password baru harus diisi");
            doGet(request, response);
            return;
        }

        if (!newPassword.equals(confirmPassword)) {
            request.setAttribute("error", "Konfirmasi password tidak cocok");
            doGet(request, response);
            return;
        }

        if (newPassword.length() < 6) {
            request.setAttribute("error", "Password baru minimal 6 karakter");
            doGet(request, response);
            return;
        }

        // Change password
        userService.changePassword(currentUser.getId(), currentPassword, newPassword);

        request.setAttribute("success", "Password berhasil diubah");
        request.setAttribute("user", currentUser);
        request.getRequestDispatcher("/common/settings.jsp").forward(request, response);
    }

    private void updatePhoto(HttpServletRequest request, HttpServletResponse response,
                              User currentUser, HttpSession session)
            throws ServletException, IOException, UserService.ServiceException {
        Part photoPart = request.getPart("photo");

        if (photoPart == null || photoPart.getSize() == 0) {
            request.setAttribute("error", "Pilih foto untuk diunggah");
            doGet(request, response);
            return;
        }

        String uploadDir = getServletContext().getRealPath("/");
        User updatedUser = userService.updatePhoto(currentUser.getId(), uploadDir, photoPart);

        // Update session
        session.setAttribute("user", updatedUser);

        request.setAttribute("success", "Foto profil berhasil diperbarui");
        request.setAttribute("user", updatedUser);
        request.getRequestDispatcher("/common/settings.jsp").forward(request, response);
    }
}
