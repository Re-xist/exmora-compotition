package com.examora.controller;

import com.examora.model.User;
import com.examora.service.QuizService;
import com.examora.service.SubmissionService;
import com.examora.service.UserService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * Admin Servlet - Handles admin dashboard and statistics
 */
@WebServlet("/AdminServlet")
@MultipartConfig(fileSizeThreshold = 1024 * 1024, maxFileSize = 5 * 1024 * 1024, maxRequestSize = 10 * 1024 * 1024)
public class AdminServlet extends HttpServlet {
    private UserService userService;
    private QuizService quizService;
    private SubmissionService submissionService;

    @Override
    public void init() throws ServletException {
        userService = new UserService();
        quizService = new QuizService();
        submissionService = new SubmissionService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");

        try {
            if ("dashboard".equals(action) || action == null) {
                showDashboard(request, response);
            } else if ("users".equals(action)) {
                listUsers(request, response);
            } else if ("statistics".equals(action)) {
                showStatistics(request, response);
            } else if ("userDetail".equals(action)) {
                showUserDetail(request, response);
            } else if ("downloadTemplate".equals(action)) {
                downloadCsvTemplate(request, response);
            } else {
                showDashboard(request, response);
            }
        } catch (Exception e) {
            request.setAttribute("error", "Error: " + e.getMessage());
            request.getRequestDispatcher("/admin/dashboard.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");

        try {
            if ("deleteUser".equals(action)) {
                deleteUser(request, response);
            } else if ("createUser".equals(action)) {
                createUser(request, response);
            } else if ("editUser".equals(action)) {
                editUser(request, response);
            } else if ("resetPassword".equals(action)) {
                resetPassword(request, response);
            } else if ("createTag".equals(action)) {
                createTag(request, response);
            } else if ("importUsers".equals(action)) {
                importUsersFromCsv(request, response);
            } else {
                response.sendRedirect("../AdminServlet?action=dashboard");
            }
        } catch (Exception e) {
            request.setAttribute("error", "Error: " + e.getMessage());
            listUsers(request, response);
        }
    }

    private void deleteUser(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            String userIdStr = request.getParameter("userId");
            if (userIdStr == null || userIdStr.isEmpty()) {
                request.setAttribute("error", "User ID tidak valid");
                listUsers(request, response);
                return;
            }

            Integer userId = Integer.parseInt(userIdStr);

            // Prevent deleting yourself
            User currentUser = (User) request.getSession().getAttribute("user");
            if (currentUser != null && currentUser.getId().equals(userId)) {
                request.setAttribute("error", "Tidak dapat menghapus akun Anda sendiri");
                listUsers(request, response);
                return;
            }

            userService.deleteUser(userId);
            request.setAttribute("success", "User berhasil dihapus");
            listUsers(request, response);

        } catch (NumberFormatException e) {
            request.setAttribute("error", "User ID tidak valid");
            listUsers(request, response);
        } catch (Exception e) {
            request.setAttribute("error", "Gagal menghapus user: " + e.getMessage());
            listUsers(request, response);
        }
    }

    private void createUser(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            String name = request.getParameter("name");
            String email = request.getParameter("email");
            String password = request.getParameter("password");
            String role = request.getParameter("role");
            String tag = request.getParameter("tag");

            if (name == null || name.trim().isEmpty()) {
                request.setAttribute("error", "Nama tidak boleh kosong");
                listUsers(request, response);
                return;
            }
            if (email == null || email.trim().isEmpty()) {
                request.setAttribute("error", "Email tidak boleh kosong");
                listUsers(request, response);
                return;
            }
            if (password == null || password.trim().isEmpty()) {
                request.setAttribute("error", "Password tidak boleh kosong");
                listUsers(request, response);
                return;
            }

            userService.register(name.trim(), email.trim(), password, role != null ? role : "peserta", tag);
            request.setAttribute("success", "User berhasil dibuat");
            listUsers(request, response);

        } catch (Exception e) {
            request.setAttribute("error", "Gagal membuat user: " + e.getMessage());
            listUsers(request, response);
        }
    }

    private void editUser(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            String userIdStr = request.getParameter("userId");
            String name = request.getParameter("name");
            String email = request.getParameter("email");
            String role = request.getParameter("role");
            String tag = request.getParameter("tag");

            if (userIdStr == null || userIdStr.isEmpty()) {
                request.setAttribute("error", "User ID tidak valid");
                listUsers(request, response);
                return;
            }

            Integer userId = Integer.parseInt(userIdStr);

            // Update user profile with tag
            userService.updateUserProfile(userId, name, email, role, tag);

            request.setAttribute("success", "User berhasil diupdate");
            listUsers(request, response);

        } catch (NumberFormatException e) {
            request.setAttribute("error", "User ID tidak valid");
            listUsers(request, response);
        } catch (Exception e) {
            request.setAttribute("error", "Gagal mengupdate user: " + e.getMessage());
            listUsers(request, response);
        }
    }

    private void resetPassword(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            String userIdStr = request.getParameter("userId");
            String newPassword = request.getParameter("newPassword");

            if (userIdStr == null || userIdStr.isEmpty()) {
                request.setAttribute("error", "User ID tidak valid");
                listUsers(request, response);
                return;
            }

            if (newPassword == null || newPassword.length() < 6) {
                request.setAttribute("error", "Password baru minimal 6 karakter");
                listUsers(request, response);
                return;
            }

            Integer userId = Integer.parseInt(userIdStr);
            userService.resetPasswordByAdmin(userId, newPassword);

            request.setAttribute("success", "Password berhasil direset");
            listUsers(request, response);

        } catch (NumberFormatException e) {
            request.setAttribute("error", "User ID tidak valid");
            listUsers(request, response);
        } catch (Exception e) {
            request.setAttribute("error", "Gagal mereset password: " + e.getMessage());
            listUsers(request, response);
        }
    }

    private void showDashboard(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            int totalUsers = userService.countByRole("peserta");
            int totalAdmins = userService.countByRole("admin");
            List<?> quizzes = quizService.getAllQuizzes();
            List<?> submissions = submissionService.getAllSubmissions();

            request.setAttribute("totalUsers", totalUsers);
            request.setAttribute("totalAdmins", totalAdmins);
            request.setAttribute("totalQuizzes", quizzes.size());
            request.setAttribute("totalSubmissions", submissions.size());
            request.setAttribute("quizzes", quizzes);
            request.setAttribute("submissions", submissions);

            request.getRequestDispatcher("/admin/dashboard.jsp").forward(request, response);

        } catch (Exception e) {
            throw new ServletException("Error loading dashboard", e);
        }
    }

    private void listUsers(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            String roleFilter = request.getParameter("role");
            String tagFilter = request.getParameter("tag");
            List<User> users;

            if ("admin".equals(roleFilter)) {
                users = userService.getUsersByRole("admin");
            } else if ("peserta".equals(roleFilter)) {
                users = userService.getUsersByRole("peserta");
            } else if (tagFilter != null && !tagFilter.isEmpty()) {
                users = userService.getUsersByTag(tagFilter);
            } else {
                users = userService.getAllUsers();
            }

            // Get all tags for filter dropdown
            List<String> tags = userService.getAllTags();

            request.setAttribute("users", users);
            request.setAttribute("roleFilter", roleFilter);
            request.setAttribute("tagFilter", tagFilter);
            request.setAttribute("tags", tags);
            request.getRequestDispatcher("/admin/users.jsp").forward(request, response);

        } catch (Exception e) {
            throw new ServletException("Error loading users", e);
        }
    }

    private void showStatistics(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            String quizIdStr = request.getParameter("quizId");
            Integer quizId = quizIdStr != null && !quizIdStr.isEmpty() ?
                    Integer.parseInt(quizIdStr) : null;

            if (quizId != null) {
                Map<String, Object> stats = submissionService.getQuizStatistics(quizId);
                request.setAttribute("statistics", stats);
                request.setAttribute("selectedQuizId", quizId);

                // Get detailed submissions list
                List<Map<String, Object>> submissions = submissionService.getDetailedQuizResults(quizId);
                request.setAttribute("submissions", submissions);
            }

            request.setAttribute("quizzes", quizService.getAllQuizzes());
            request.getRequestDispatcher("/admin/statistics.jsp").forward(request, response);

        } catch (Exception e) {
            throw new ServletException("Error loading statistics", e);
        }
    }

    private void showUserDetail(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            String submissionIdStr = request.getParameter("submissionId");
            if (submissionIdStr == null || submissionIdStr.isEmpty()) {
                request.setAttribute("error", "Submission ID tidak valid");
                request.getRequestDispatcher("/admin/user-detail.jsp").forward(request, response);
                return;
            }

            Integer submissionId = Integer.parseInt(submissionIdStr);
            Map<String, Object> detail = submissionService.getSubmissionDetail(submissionId);

            if (detail == null) {
                request.setAttribute("error", "Submission tidak ditemukan");
                request.getRequestDispatcher("/admin/user-detail.jsp").forward(request, response);
                return;
            }

            request.setAttribute("detail", detail);
            request.getRequestDispatcher("/admin/user-detail.jsp").forward(request, response);

        } catch (NumberFormatException e) {
            request.setAttribute("error", "Submission ID tidak valid");
            request.getRequestDispatcher("/admin/user-detail.jsp").forward(request, response);
        } catch (Exception e) {
            request.setAttribute("error", "Error loading user detail: " + e.getMessage());
            request.getRequestDispatcher("/admin/user-detail.jsp").forward(request, response);
        }
    }

    private void createTag(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        try {
            String tagName = request.getParameter("tagName");
            if (tagName == null || tagName.trim().isEmpty()) {
                response.getWriter().write("{\"success\": false, \"error\": \"Nama tag tidak boleh kosong\"}");
                return;
            }

            tagName = tagName.trim();

            // Check if tag already exists
            List<String> existingTags = userService.getAllTags();
            if (existingTags != null && existingTags.contains(tagName)) {
                response.getWriter().write("{\"success\": false, \"error\": \"Tag sudah ada\"}");
                return;
            }

            // Tag will be created when a user is assigned to it
            // For now, we just return success as tags are created on-demand
            response.getWriter().write("{\"success\": true, \"tagName\": \"" + tagName + "\"}");

        } catch (Exception e) {
            response.getWriter().write("{\"success\": false, \"error\": \"" + e.getMessage() + "\"}");
        }
    }

    /**
     * Download CSV template for user import
     */
    private void downloadCsvTemplate(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/csv; charset=UTF-8");
        response.setHeader("Content-Disposition", "attachment; filename=\"template_import_user.csv\"");

        PrintWriter writer = response.getWriter();

        // CSV Header
        writer.println("nama,email,password,role,tag");

        // Sample data rows (3 dummy users)
        writer.println("Ahmad Rizki,ahmad.rizki@email.com,Password123,peserta,TI-2024");
        writer.println("Siti Nurhaliza,siti.nur@email.com,Password123,peserta,SI-2024");
        writer.println("Budi Pratama,budi.pratama@email.com,Password123,peserta,TI-2024");

        writer.flush();
        writer.close();
    }

    /**
     * Import users from CSV file
     */
    private void importUsersFromCsv(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            Part filePart = request.getPart("csvFile");
            if (filePart == null || filePart.getSize() == 0) {
                request.setAttribute("error", "File CSV tidak ditemukan atau kosong");
                listUsers(request, response);
                return;
            }

            boolean skipHeader = "on".equals(request.getParameter("skipHeader"));
            boolean updateExisting = "on".equals(request.getParameter("updateExisting"));

            List<String[]> users = new ArrayList<>();
            List<String> errors = new ArrayList<>();
            int successCount = 0;
            int updateCount = 0;
            int errorCount = 0;

            // Read CSV file
            try (BufferedReader reader = new BufferedReader(
                    new InputStreamReader(filePart.getInputStream(), StandardCharsets.UTF_8))) {
                String line;
                int lineNumber = 0;

                while ((line = reader.readLine()) != null) {
                    lineNumber++;

                    // Skip header if requested
                    if (skipHeader && lineNumber == 1) {
                        continue;
                    }

                    // Skip empty lines
                    if (line.trim().isEmpty()) {
                        continue;
                    }

                    // Parse CSV line (handle quoted values)
                    String[] fields = parseCsvLine(line);

                    if (fields.length < 3) {
                        errors.add("Baris " + lineNumber + ": Data tidak lengkap (minimal: nama, email, password)");
                        errorCount++;
                        continue;
                    }

                    String name = fields[0].trim();
                    String email = fields[1].trim();
                    String password = fields[2].trim();
                    String role = fields.length > 3 ? fields[3].trim() : "peserta";
                    String tag = fields.length > 4 ? fields[4].trim() : null;

                    // Validate data
                    if (name.isEmpty()) {
                        errors.add("Baris " + lineNumber + ": Nama tidak boleh kosong");
                        errorCount++;
                        continue;
                    }
                    if (email.isEmpty()) {
                        errors.add("Baris " + lineNumber + ": Email tidak boleh kosong");
                        errorCount++;
                        continue;
                    }
                    if (password.isEmpty() || password.length() < 6) {
                        errors.add("Baris " + lineNumber + ": Password minimal 6 karakter");
                        errorCount++;
                        continue;
                    }
                    if (!role.equals("admin") && !role.equals("peserta")) {
                        role = "peserta"; // Default to peserta
                    }

                    try {
                        // Check if email already exists
                        User existingUser = userService.findByEmail(email);

                        if (existingUser != null) {
                            if (updateExisting) {
                                // Update existing user
                                userService.updateUserProfile(existingUser.getId(), name, email, role, tag);
                                userService.resetPasswordByAdmin(existingUser.getId(), password);
                                updateCount++;
                            } else {
                                errors.add("Baris " + lineNumber + ": Email '" + email + "' sudah terdaftar");
                                errorCount++;
                            }
                        } else {
                            // Create new user
                            userService.register(name, email, password, role, tag);
                            successCount++;
                        }
                    } catch (Exception e) {
                        errors.add("Baris " + lineNumber + ": " + e.getMessage());
                        errorCount++;
                    }
                }
            }

            // Build result message
            StringBuilder resultMsg = new StringBuilder();
            resultMsg.append("Import selesai!<br>");
            resultMsg.append("- Berhasil ditambah: ").append(successCount).append(" user<br>");
            resultMsg.append("- Berhasil diupdate: ").append(updateCount).append(" user<br>");
            resultMsg.append("- Gagal: ").append(errorCount).append(" user");

            if (!errors.isEmpty()) {
                request.setAttribute("importErrors", errors);
            }

            if (errorCount > 0 && successCount == 0 && updateCount == 0) {
                request.setAttribute("error", resultMsg.toString());
            } else {
                request.setAttribute("success", resultMsg.toString());
            }

            listUsers(request, response);

        } catch (Exception e) {
            request.setAttribute("error", "Gagal import: " + e.getMessage());
            listUsers(request, response);
        }
    }

    /**
     * Parse CSV line handling quoted values
     */
    private String[] parseCsvLine(String line) {
        List<String> fields = new ArrayList<>();
        StringBuilder field = new StringBuilder();
        boolean inQuotes = false;

        for (int i = 0; i < line.length(); i++) {
            char c = line.charAt(i);

            if (c == '"') {
                inQuotes = !inQuotes;
            } else if (c == ',' && !inQuotes) {
                fields.add(field.toString());
                field = new StringBuilder();
            } else {
                field.append(c);
            }
        }
        fields.add(field.toString());

        return fields.toArray(new String[0]);
    }
}
