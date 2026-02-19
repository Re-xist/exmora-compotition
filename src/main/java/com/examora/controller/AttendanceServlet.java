package com.examora.controller;

import com.examora.model.AttendanceSession;
import com.examora.model.AttendanceRecord;
import com.examora.model.User;
import com.examora.service.AttendanceService;
import com.examora.service.UserService;
import com.examora.service.UserService.ServiceException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.List;
import java.util.Map;
import java.util.HashMap;
import com.google.gson.Gson;

@WebServlet("/AttendanceServlet")
public class AttendanceServlet extends HttpServlet {
    private AttendanceService attendanceService;
    private UserService userService;
    private Gson gson;

    @Override
    public void init() throws ServletException {
        attendanceService = new AttendanceService();
        userService = new UserService();
        gson = new Gson();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        if (user == null) {
            response.sendRedirect("LoginServlet");
            return;
        }

        try {
            if ("admin".equals(user.getRole())) {
                handleAdminGet(request, response, action, user);
            } else {
                handleUserGet(request, response, action, user);
            }
        } catch (Exception e) {
            e.printStackTrace();
            if ("admin".equals(user.getRole())) {
                request.setAttribute("error", "Error: " + e.getMessage());
                request.getRequestDispatcher("/admin/attendance.jsp").forward(request, response);
            } else {
                request.setAttribute("error", "Error: " + e.getMessage());
                request.getRequestDispatcher("/user/attendance.jsp").forward(request, response);
            }
        }
    }

    private void handleAdminGet(HttpServletRequest request, HttpServletResponse response, String action, User user)
            throws ServletException, IOException, SQLException {
        switch (action == null ? "list" : action) {
            case "list":
                listSessions(request, response);
                break;
            case "view":
                viewSession(request, response);
                break;
            case "export":
                exportRecords(request, response);
                break;
            default:
                listSessions(request, response);
        }
    }

    private void handleUserGet(HttpServletRequest request, HttpServletResponse response, String action, User user)
            throws ServletException, IOException, SQLException {
        switch (action == null ? "view" : action) {
            case "view":
                showAttendancePage(request, response, user);
                break;
            case "history":
                showAttendanceHistory(request, response, user);
                break;
            default:
                showAttendancePage(request, response, user);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        if (user == null) {
            sendJsonResponse(response, false, "Sesi telah berakhir");
            return;
        }

        try {
            if ("admin".equals(user.getRole())) {
                handleAdminPost(request, response, action, user);
            } else {
                handleUserPost(request, response, action, user);
            }
        } catch (Exception e) {
            e.printStackTrace();
            sendJsonResponse(response, false, e.getMessage());
        }
    }

    private void handleAdminPost(HttpServletRequest request, HttpServletResponse response, String action, User user)
            throws ServletException, IOException, SQLException {
        if (action == null || action.isEmpty()) {
            sendJsonResponse(response, false, "Action tidak valid");
            return;
        }
        switch (action) {
            case "create":
                createSession(request, response, user);
                break;
            case "activate":
                activateSession(request, response);
                break;
            case "close":
                closeSession(request, response);
                break;
            case "delete":
                deleteSession(request, response);
                break;
            case "updateRecord":
                updateRecord(request, response);
                break;
            default:
                sendJsonResponse(response, false, "Action tidak valid");
        }
    }

    private void handleUserPost(HttpServletRequest request, HttpServletResponse response, String action, User user)
            throws ServletException, IOException, SQLException {
        if ("join".equals(action)) {
            joinAttendance(request, response, user);
        } else {
            sendJsonResponse(response, false, "Action tidak valid");
        }
    }

    // Admin GET Methods
    private void listSessions(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {
        List<AttendanceSession> sessions = attendanceService.getAllSessions();
        List<String> tags = null;
        try {
            tags = userService.getAllTags();
        } catch (ServiceException e) {
            // Ignore error, tags will be null
        }
        request.setAttribute("sessions", sessions);
        request.setAttribute("tags", tags);
        request.getRequestDispatcher("/admin/attendance.jsp").forward(request, response);
    }

    private void viewSession(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {
        String sessionIdStr = request.getParameter("sessionId");
        if (sessionIdStr == null || sessionIdStr.isEmpty()) {
            response.sendRedirect("AttendanceServlet?action=list");
            return;
        }

        int sessionId = Integer.parseInt(sessionIdStr);
        AttendanceSession session = attendanceService.getSessionById(sessionId);

        if (session == null) {
            request.setAttribute("error", "Sesi tidak ditemukan");
            listSessions(request, response);
            return;
        }

        List<AttendanceRecord> records = attendanceService.getSessionRecords(sessionId);
        int[] stats = attendanceService.getSessionStatistics(sessionId);

        request.setAttribute("session", session);
        request.setAttribute("records", records);
        request.setAttribute("statsPresent", stats[0]);
        request.setAttribute("statsLate", stats[1]);
        request.setAttribute("statsTotal", stats[2]);
        request.getRequestDispatcher("/admin/attendance-records.jsp").forward(request, response);
    }

    private void exportRecords(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {
        String sessionIdStr = request.getParameter("sessionId");
        String format = request.getParameter("format");

        if (sessionIdStr == null || sessionIdStr.isEmpty()) {
            response.sendRedirect("AttendanceServlet?action=list");
            return;
        }

        int sessionId = Integer.parseInt(sessionIdStr);
        AttendanceSession session = attendanceService.getSessionById(sessionId);
        List<AttendanceRecord> records = attendanceService.getDetailedRecordsForExport(sessionId);

        if ("csv".equals(format)) {
            exportToCSV(response, session, records);
        } else {
            exportToPDF(response, session, records);
        }
    }

    // Admin POST Methods
    private void createSession(HttpServletRequest request, HttpServletResponse response, User user)
            throws ServletException, IOException, SQLException {
        String sessionName = request.getParameter("sessionName");
        String sessionDateStr = request.getParameter("sessionDate");
        String startTimeStr = request.getParameter("startTime");
        String endTimeStr = request.getParameter("endTime");
        String targetTag = request.getParameter("targetTag");
        String lateThresholdStr = request.getParameter("lateThreshold");

        // Validate required fields
        if (sessionName == null || sessionName.trim().isEmpty()) {
            sendJsonResponse(response, false, "Nama sesi tidak boleh kosong");
            return;
        }
        if (sessionDateStr == null || sessionDateStr.isEmpty()) {
            sendJsonResponse(response, false, "Tanggal tidak boleh kosong");
            return;
        }
        if (startTimeStr == null || startTimeStr.isEmpty()) {
            sendJsonResponse(response, false, "Waktu mulai tidak boleh kosong");
            return;
        }
        if (endTimeStr == null || endTimeStr.isEmpty()) {
            sendJsonResponse(response, false, "Waktu selesai tidak boleh kosong");
            return;
        }

        try {
            java.sql.Date sessionDate = java.sql.Date.valueOf(sessionDateStr);
            java.sql.Time startTime = java.sql.Time.valueOf(startTimeStr + ":00");
            java.sql.Time endTime = java.sql.Time.valueOf(endTimeStr + ":00");

            // Validate time
            if (!endTime.after(startTime)) {
                sendJsonResponse(response, false, "Waktu selesai harus setelah waktu mulai");
                return;
            }

            int lateThreshold = lateThresholdStr != null && !lateThresholdStr.isEmpty() ?
                    Integer.parseInt(lateThresholdStr) : 15;

            AttendanceSession session = attendanceService.createSession(
                    sessionName, sessionDate, startTime, endTime, targetTag, user.getId(), lateThreshold);

            Map<String, Object> data = new HashMap<>();
            data.put("sessionId", session.getId());
            data.put("sessionCode", session.getSessionCode());

            sendJsonResponse(response, true, "Sesi berhasil dibuat dengan kode: " + session.getSessionCode(), data);

        } catch (IllegalArgumentException e) {
            sendJsonResponse(response, false, e.getMessage());
        } catch (SQLException e) {
            sendJsonResponse(response, false, "Database error: " + e.getMessage());
        } catch (Exception e) {
            sendJsonResponse(response, false, "Error: " + e.getMessage());
        }
    }

    private void activateSession(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {
        String sessionIdStr = request.getParameter("sessionId");

        if (sessionIdStr == null || sessionIdStr.isEmpty()) {
            sendJsonResponse(response, false, "Session ID tidak valid");
            return;
        }

        int sessionId = Integer.parseInt(sessionIdStr);
        boolean success = attendanceService.updateSessionStatus(sessionId, "active");

        sendJsonResponse(response, success, success ? "Sesi berhasil diaktifkan" : "Gagal mengaktifkan sesi");
    }

    private void closeSession(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {
        String sessionIdStr = request.getParameter("sessionId");

        if (sessionIdStr == null || sessionIdStr.isEmpty()) {
            sendJsonResponse(response, false, "Session ID tidak valid");
            return;
        }

        int sessionId = Integer.parseInt(sessionIdStr);
        boolean success = attendanceService.updateSessionStatus(sessionId, "closed");

        sendJsonResponse(response, success, success ? "Sesi berhasil ditutup" : "Gagal menutup sesi");
    }

    private void deleteSession(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {
        String sessionIdStr = request.getParameter("sessionId");

        if (sessionIdStr == null || sessionIdStr.isEmpty()) {
            sendJsonResponse(response, false, "Session ID tidak valid");
            return;
        }

        int sessionId = Integer.parseInt(sessionIdStr);
        boolean success = attendanceService.deleteSession(sessionId);

        sendJsonResponse(response, success, success ? "Sesi berhasil dihapus" : "Gagal menghapus sesi");
    }

    private void updateRecord(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {
        String recordIdStr = request.getParameter("recordId");
        String status = request.getParameter("status");
        String notes = request.getParameter("notes");

        if (recordIdStr == null || recordIdStr.isEmpty()) {
            sendJsonResponse(response, false, "Record ID tidak valid");
            return;
        }

        int recordId = Integer.parseInt(recordIdStr);
        boolean success = attendanceService.updateRecordStatus(recordId, status, notes);

        sendJsonResponse(response, success, success ? "Record berhasil diupdate" : "Gagal mengupdate record");
    }

    // User GET Methods
    private void showAttendancePage(HttpServletRequest request, HttpServletResponse response, User user)
            throws ServletException, IOException, SQLException {
        List<AttendanceSession> activeSessions = attendanceService.getActiveSessionsForTag(user.getTag());
        request.setAttribute("activeSessions", activeSessions);
        request.getRequestDispatcher("/user/attendance.jsp").forward(request, response);
    }

    private void showAttendanceHistory(HttpServletRequest request, HttpServletResponse response, User user)
            throws ServletException, IOException, SQLException {
        List<AttendanceRecord> history = attendanceService.getUserAttendanceHistory(user.getId());
        request.setAttribute("history", history);
        request.getRequestDispatcher("/user/attendance-history.jsp").forward(request, response);
    }

    // User POST Methods
    private void joinAttendance(HttpServletRequest request, HttpServletResponse response, User user)
            throws ServletException, IOException, SQLException {
        String sessionCode = request.getParameter("sessionCode");

        if (sessionCode == null || sessionCode.trim().isEmpty()) {
            sendJsonResponse(response, false, "Kode sesi tidak boleh kosong");
            return;
        }

        try {
            AttendanceRecord record = attendanceService.markAttendance(sessionCode.trim().toUpperCase(), user.getId(), user.getTag());

            Map<String, Object> data = new HashMap<>();
            data.put("sessionName", record.getSessionName());
            data.put("status", record.getStatus());
            data.put("statusLabel", record.getStatusLabel());

            String message = "Absensi berhasil! Status: " + record.getStatusLabel();
            sendJsonResponse(response, true, message, data);

        } catch (IllegalArgumentException e) {
            sendJsonResponse(response, false, "Kode sesi tidak ditemukan");
        } catch (IllegalStateException e) {
            sendJsonResponse(response, false, e.getMessage());
        } catch (SecurityException e) {
            sendJsonResponse(response, false, "Anda tidak memiliki akses ke sesi ini");
        }
    }

    // Export Methods
    private void exportToCSV(HttpServletResponse response, AttendanceSession session, List<AttendanceRecord> records)
            throws IOException {
        response.setContentType("text/csv; charset=UTF-8");
        String fileName = sanitizeFileName(session.getSessionName()) + "_" + session.getSessionCode();
        response.setHeader("Content-Disposition", "attachment; filename=\"" + fileName + ".csv\"");

        PrintWriter writer = response.getWriter();
        writer.write('\ufeff'); // BOM for UTF-8

        // Header
        writer.println("No,Nama,Email,Tag,Waktu Absensi,Status,Catatan");

        // Data
        SimpleDateFormat dateFormat = new SimpleDateFormat("dd/MM/yyyy HH:mm:ss");
        int no = 1;
        for (AttendanceRecord record : records) {
            writer.println(String.format("%d,%s,%s,%s,%s,%s,%s",
                    no++,
                    escapeCSV(record.getUserName()),
                    escapeCSV(record.getUserEmail()),
                    escapeCSV(record.getUserTag() != null ? record.getUserTag() : "-"),
                    dateFormat.format(record.getAttendanceTime()),
                    record.getStatusLabel(),
                    escapeCSV(record.getNotes() != null ? record.getNotes() : "")
            ));
        }

        writer.flush();
        writer.close();
    }

    private void exportToPDF(HttpServletResponse response, AttendanceSession session, List<AttendanceRecord> records)
            throws IOException, SQLException {
        // For simplicity, we'll export as a formatted HTML that can be printed as PDF
        // A proper implementation would use iText or similar library

        response.setContentType("text/html; charset=UTF-8");
        String fileName = sanitizeFileName(session.getSessionName()) + "_" + session.getSessionCode();
        response.setHeader("Content-Disposition", "attachment; filename=\"" + fileName + ".html\"");

        PrintWriter writer = response.getWriter();

        SimpleDateFormat dateFormat = new SimpleDateFormat("dd MMMM yyyy");
        SimpleDateFormat timeFormat = new SimpleDateFormat("HH:mm");

        writer.println("<!DOCTYPE html>");
        writer.println("<html><head>");
        writer.println("<meta charset=\"UTF-8\">");
        writer.println("<title>Rekap Absensi - " + session.getSessionName() + "</title>");
        writer.println("<style>");
        writer.println("body { font-family: Arial, sans-serif; padding: 20px; }");
        writer.println("h1 { text-align: center; }");
        writer.println(".info { margin-bottom: 20px; }");
        writer.println("table { width: 100%; border-collapse: collapse; }");
        writer.println("th, td { border: 1px solid #333; padding: 8px; text-align: left; }");
        writer.println("th { background-color: #f0f0f0; }");
        writer.println(".present { color: green; }");
        writer.println(".late { color: orange; }");
        writer.println(".absent { color: red; }");
        writer.println("@media print { button { display: none; } }");
        writer.println("</style>");
        writer.println("</head><body>");

        writer.println("<h1>REKAP ABSENSI</h1>");
        writer.println("<div class=\"info\">");
        writer.println("<p><strong>Nama Sesi:</strong> " + escapeHTML(session.getSessionName()) + "</p>");
        writer.println("<p><strong>Kode Sesi:</strong> " + session.getSessionCode() + "</p>");
        writer.println("<p><strong>Tanggal:</strong> " + dateFormat.format(session.getSessionDate()) + "</p>");
        writer.println("<p><strong>Waktu:</strong> " + timeFormat.format(session.getStartTime()) + " - " + timeFormat.format(session.getEndTime()) + "</p>");
        writer.println("<p><strong>Target Tag:</strong> " + (session.getTargetTag() != null ? session.getTargetTag() : "Semua") + "</p>");

        int[] stats = attendanceService.getSessionStatistics(session.getId());
        writer.println("<p><strong>Total Hadir:</strong> " + stats[0] + " | <strong>Terlambat:</strong> " + stats[1] + " | <strong>Total:</strong> " + stats[2] + "</p>");
        writer.println("</div>");

        writer.println("<button onclick=\"window.print()\">Print / Save as PDF</button>");
        writer.println("<br><br>");

        writer.println("<table>");
        writer.println("<tr><th>No</th><th>Nama</th><th>Email</th><th>Tag</th><th>Waktu Absensi</th><th>Status</th><th>Catatan</th></tr>");

        SimpleDateFormat dateTimeFormat = new SimpleDateFormat("dd/MM/yyyy HH:mm:ss");
        int no = 1;
        for (AttendanceRecord record : records) {
            writer.println("<tr>");
            writer.println("<td>" + no++ + "</td>");
            writer.println("<td>" + escapeHTML(record.getUserName()) + "</td>");
            writer.println("<td>" + escapeHTML(record.getUserEmail()) + "</td>");
            writer.println("<td>" + escapeHTML(record.getUserTag() != null ? record.getUserTag() : "-") + "</td>");
            writer.println("<td>" + dateTimeFormat.format(record.getAttendanceTime()) + "</td>");
            writer.println("<td class=\"" + record.getStatus() + "\">" + record.getStatusLabel() + "</td>");
            writer.println("<td>" + escapeHTML(record.getNotes() != null ? record.getNotes() : "") + "</td>");
            writer.println("</tr>");
        }

        writer.println("</table>");
        writer.println("<p style=\"text-align: right; margin-top: 20px;\">Dicetak pada: " + new SimpleDateFormat("dd/MM/yyyy HH:mm").format(new java.util.Date()) + "</p>");
        writer.println("</body></html>");

        writer.flush();
        writer.close();
    }

    // Utility Methods
    private void sendJsonResponse(HttpServletResponse response, boolean success, String message)
            throws IOException {
        sendJsonResponse(response, success, message, null);
    }

    private void sendJsonResponse(HttpServletResponse response, boolean success, String message, Map<String, Object> data)
            throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        Map<String, Object> result = new HashMap<>();
        result.put("success", success);
        result.put("message", message);
        if (data != null) {
            result.putAll(data);
        }

        PrintWriter out = response.getWriter();
        out.print(gson.toJson(result));
        out.flush();
    }

    private String sanitizeFileName(String name) {
        if (name == null) return "absensi";
        // Remove or replace invalid filename characters
        return name.replaceAll("[\\\\/:*?\"<>|]", "")
                   .replaceAll("\\s+", "_")
                   .trim();
    }

    private String escapeCSV(String value) {
        if (value == null) return "";
        if (value.contains(",") || value.contains("\"") || value.contains("\n")) {
            return "\"" + value.replace("\"", "\"\"") + "\"";
        }
        return value;
    }

    private String escapeHTML(String value) {
        if (value == null) return "";
        return value.replace("&", "&amp;")
                    .replace("<", "&lt;")
                    .replace(">", "&gt;")
                    .replace("\"", "&quot;")
                    .replace("'", "&#39;");
    }
}
