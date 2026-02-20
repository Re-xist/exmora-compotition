<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="com.examora.model.User" %>
<%
    // currentUser should be defined by the including page
    // Just get request info for active link highlighting
    String requestURI = request.getRequestURI();
    String queryString = request.getQueryString();
    User sidebarUser = (User) session.getAttribute("user");
%>
<!-- Sidebar -->
<nav class="sidebar">
    <a href="../AdminServlet?action=dashboard" class="sidebar-brand">
        <i class="bi bi-journal-check me-2"></i>Examora
    </a>
    <hr class="sidebar-divider bg-white opacity-25">
    <ul class="sidebar-menu">
        <li>
            <a href="../AdminServlet?action=dashboard" <%= requestURI.contains("AdminServlet") && (queryString == null || queryString.contains("dashboard")) ? "class=\"active\"" : "" %>>
                <i class="bi bi-speedometer2"></i>Dashboard
            </a>
        </li>
        <li>
            <a href="../QuizServlet?action=list" <%= requestURI.contains("QuizServlet") ? "class=\"active\"" : "" %>>
                <i class="bi bi-journal-text"></i>Kelola Quiz
            </a>
        </li>
        <li>
            <a href="../QuestionServlet?action=list" <%= requestURI.contains("QuestionServlet") ? "class=\"active\"" : "" %>>
                <i class="bi bi-question-circle"></i>Kelola Soal
            </a>
        </li>
        <li>
            <a href="../ArenaServlet?action=list" <%= requestURI.contains("ArenaServlet") ? "class=\"active\"" : "" %>>
                <i class="bi bi-controller"></i>Kelola Arena
            </a>
        </li>
        <li>
            <a href="../AdminServlet?action=users" <%= requestURI.contains("AdminServlet") && queryString != null && queryString.contains("users") ? "class=\"active\"" : "" %>>
                <i class="bi bi-people"></i>Kelola User
            </a>
        </li>
        <li>
            <a href="../AttendanceServlet?action=list" <%= requestURI.contains("AttendanceServlet") ? "class=\"active\"" : "" %>>
                <i class="bi bi-check2-square"></i>Absensi
            </a>
        </li>
        <hr class="sidebar-divider bg-white opacity-25">
        <li class="sidebar-heading text-white-50 small">FITUR BARU</li>
        <li>
            <a href="../QuestionBankServlet?action=categories" <%= requestURI.contains("QuestionBankServlet") ? "class=\"active\"" : "" %>>
                <i class="bi bi-collection"></i>Bank Soal
            </a>
        </li>
        <li>
            <a href="../AchievementServlet?action=list" <%= requestURI.contains("AchievementServlet") ? "class=\"active\"" : "" %>>
                <i class="bi bi-trophy"></i>Achievements
            </a>
        </li>
        <li>
            <a href="../NotificationServlet?action=templates" <%= requestURI.contains("NotificationServlet") ? "class=\"active\"" : "" %>>
                <i class="bi bi-envelope"></i>Notifikasi
            </a>
        </li>
        <li>
            <a href="../AuditServlet" <%= requestURI.contains("AuditServlet") ? "class=\"active\"" : "" %>>
                <i class="bi bi-clipboard-data"></i>Audit Log
            </a>
        </li>
        <hr class="sidebar-divider bg-white opacity-25">
        <li>
            <a href="../AdminServlet?action=statistics" <%= requestURI.contains("AdminServlet") && queryString != null && queryString.contains("statistics") ? "class=\"active\"" : "" %>>
                <i class="bi bi-graph-up"></i>Statistik
            </a>
        </li>
        <li class="mt-auto">
            <a href="../LogoutServlet">
                <i class="bi bi-box-arrow-left"></i>Logout
            </a>
        </li>
    </ul>
    <div class="sidebar-footer text-white-50 small p-3">
        <div><%= sidebarUser != null ? sidebarUser.getName() : "User" %></div>
        <div class="text-white-50"><%= sidebarUser != null ? sidebarUser.getEmail() : "" %></div>
    </div>
</nav>
