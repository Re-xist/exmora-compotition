package com.examora.service;

import com.examora.dao.AttendanceDAO;
import com.examora.model.AttendanceSession;
import com.examora.model.AttendanceRecord;

import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.Calendar;
import java.util.List;
import java.util.Random;

public class AttendanceService {
    private AttendanceDAO attendanceDAO;

    public AttendanceService() {
        this.attendanceDAO = new AttendanceDAO();
    }

    // Generate 6-character unique code
    public String generateSessionCode() throws SQLException {
        String chars = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";
        Random random = new Random();
        String code;

        do {
            StringBuilder sb = new StringBuilder();
            for (int i = 0; i < 6; i++) {
                sb.append(chars.charAt(random.nextInt(chars.length())));
            }
            code = sb.toString();
        } while (attendanceDAO.findSessionByCode(code) != null);

        return code;
    }

    // Create session with validation
    public AttendanceSession createSession(String sessionName, java.sql.Date sessionDate,
                                           java.sql.Time startTime, java.sql.Time endTime,
                                           String targetTag, int createdBy, int lateThreshold) throws SQLException {

        // Validate input
        if (sessionName == null || sessionName.trim().isEmpty()) {
            throw new IllegalArgumentException("Nama sesi tidak boleh kosong");
        }

        if (sessionDate == null) {
            throw new IllegalArgumentException("Tanggal sesi tidak boleh kosong");
        }

        if (startTime == null || endTime == null) {
            throw new IllegalArgumentException("Waktu mulai dan selesai tidak boleh kosong");
        }

        if (!endTime.after(startTime)) {
            throw new IllegalArgumentException("Waktu selesai harus setelah waktu mulai");
        }

        // Create session
        AttendanceSession session = new AttendanceSession();
        session.setSessionName(sessionName.trim());
        session.setSessionCode(generateSessionCode());
        session.setSessionDate(sessionDate);
        session.setStartTime(startTime);
        session.setEndTime(endTime);
        session.setTargetTag((targetTag == null || targetTag.trim().isEmpty()) ? null : targetTag.trim());
        session.setCreatedBy(createdBy);
        session.setStatus("scheduled");
        session.setLateThreshold(lateThreshold);

        if (!attendanceDAO.createSession(session)) {
            throw new SQLException("Gagal membuat sesi absensi");
        }

        return session;
    }

    // Mark attendance with validation
    public AttendanceRecord markAttendance(String sessionCode, int userId, String userTag) throws SQLException {
        // Find session by code
        AttendanceSession session = attendanceDAO.findSessionByCode(sessionCode);
        if (session == null) {
            throw new IllegalArgumentException("Kode sesi tidak ditemukan");
        }

        // Check if session is active
        if (!session.isActive()) {
            throw new IllegalStateException("Sesi absensi tidak aktif");
        }

        // Check tag restriction
        if (!session.isVisibleToTag(userTag)) {
            throw new SecurityException("Anda tidak memiliki akses ke sesi ini");
        }

        // Check if already attended
        AttendanceRecord existingRecord = attendanceDAO.findRecordBySessionAndUser(session.getId(), userId);
        if (existingRecord != null) {
            throw new IllegalStateException("Anda sudah melakukan absensi untuk sesi ini");
        }

        // Get current time
        Timestamp now = new Timestamp(System.currentTimeMillis());

        // Determine status (present or late)
        String status = "present";
        Calendar calendar = Calendar.getInstance();
        calendar.setTime(session.getSessionDate());

        Calendar timeCalendar = Calendar.getInstance();
        timeCalendar.setTime(session.getStartTime());
        calendar.set(Calendar.HOUR_OF_DAY, timeCalendar.get(Calendar.HOUR_OF_DAY));
        calendar.set(Calendar.MINUTE, timeCalendar.get(Calendar.MINUTE));
        calendar.set(Calendar.SECOND, 0);

        // Add late threshold
        calendar.add(Calendar.MINUTE, session.getLateThreshold());
        Timestamp lateTime = new Timestamp(calendar.getTimeInMillis());

        if (now.after(lateTime)) {
            status = "late";
        }

        // Create record
        AttendanceRecord record = new AttendanceRecord();
        record.setSessionId(session.getId());
        record.setUserId(userId);
        record.setAttendanceTime(now);
        record.setStatus(status);
        record.setNotes(null);

        if (!attendanceDAO.createRecord(record)) {
            throw new SQLException("Gagal mencatat absensi");
        }

        // Set session name for display
        record.setSessionName(session.getSessionName());

        return record;
    }

    // Get session by ID
    public AttendanceSession getSessionById(int id) throws SQLException {
        return attendanceDAO.findSessionById(id);
    }

    // Get session by code
    public AttendanceSession getSessionByCode(String code) throws SQLException {
        return attendanceDAO.findSessionByCode(code);
    }

    // Get all sessions
    public List<AttendanceSession> getAllSessions() throws SQLException {
        return attendanceDAO.findAllSessions();
    }

    // Get active sessions for a tag
    public List<AttendanceSession> getActiveSessionsForTag(String userTag) throws SQLException {
        return attendanceDAO.findActiveSessionsByTag(userTag);
    }

    // Update session status
    public boolean updateSessionStatus(int sessionId, String status) throws SQLException {
        if (!status.equals("scheduled") && !status.equals("active") && !status.equals("closed")) {
            throw new IllegalArgumentException("Status tidak valid");
        }
        return attendanceDAO.updateSessionStatus(sessionId, status);
    }

    // Delete session
    public boolean deleteSession(int sessionId) throws SQLException {
        return attendanceDAO.deleteSession(sessionId);
    }

    // Get user attendance history
    public List<AttendanceRecord> getUserAttendanceHistory(int userId) throws SQLException {
        return attendanceDAO.findRecordsByUser(userId);
    }

    // Get session records
    public List<AttendanceRecord> getSessionRecords(int sessionId) throws SQLException {
        return attendanceDAO.findRecordsBySession(sessionId);
    }

    // Get detailed records for export
    public List<AttendanceRecord> getDetailedRecordsForExport(int sessionId) throws SQLException {
        return attendanceDAO.getDetailedRecordsBySession(sessionId);
    }

    // Get session statistics
    public int[] getSessionStatistics(int sessionId) throws SQLException {
        return attendanceDAO.getSessionStatistics(sessionId);
    }

    // Update record status
    public boolean updateRecordStatus(int recordId, String status, String notes) throws SQLException {
        if (!status.equals("present") && !status.equals("late") && !status.equals("absent")) {
            throw new IllegalArgumentException("Status tidak valid");
        }
        return attendanceDAO.updateRecordStatus(recordId, status, notes);
    }
}
