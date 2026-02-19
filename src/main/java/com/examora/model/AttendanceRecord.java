package com.examora.model;

import java.sql.Timestamp;
import java.text.SimpleDateFormat;

public class AttendanceRecord {
    private int id;
    private int sessionId;
    private int userId;
    private Timestamp attendanceTime;
    private String status;
    private String notes;

    // Related fields
    private String userName;
    private String userEmail;
    private String userTag;
    private String sessionName;

    public AttendanceRecord() {}

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getSessionId() {
        return sessionId;
    }

    public void setSessionId(int sessionId) {
        this.sessionId = sessionId;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public Timestamp getAttendanceTime() {
        return attendanceTime;
    }

    public void setAttendanceTime(Timestamp attendanceTime) {
        this.attendanceTime = attendanceTime;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getNotes() {
        return notes;
    }

    public void setNotes(String notes) {
        this.notes = notes;
    }

    public String getUserName() {
        return userName;
    }

    public void setUserName(String userName) {
        this.userName = userName;
    }

    public String getUserEmail() {
        return userEmail;
    }

    public void setUserEmail(String userEmail) {
        this.userEmail = userEmail;
    }

    public String getUserTag() {
        return userTag;
    }

    public void setUserTag(String userTag) {
        this.userTag = userTag;
    }

    public String getSessionName() {
        return sessionName;
    }

    public void setSessionName(String sessionName) {
        this.sessionName = sessionName;
    }

    // Helper methods
    public String getStatusBadgeClass() {
        switch (status) {
            case "present":
                return "bg-success";
            case "late":
                return "bg-warning text-dark";
            case "absent":
            default:
                return "bg-danger";
        }
    }

    public String getStatusLabel() {
        switch (status) {
            case "present":
                return "Hadir";
            case "late":
                return "Terlambat";
            case "absent":
            default:
                return "Tidak Hadir";
        }
    }

    public String getFormattedAttendanceTime() {
        if (attendanceTime == null) return "-";
        SimpleDateFormat format = new SimpleDateFormat("dd MMM yyyy HH:mm:ss");
        return format.format(attendanceTime);
    }

    public String getFormattedTime() {
        if (attendanceTime == null) return "-";
        SimpleDateFormat format = new SimpleDateFormat("HH:mm:ss");
        return format.format(attendanceTime);
    }
}
