package com.examora.model;

import java.time.LocalDateTime;

/**
 * User Model - Represents a user in the Examora system
 */
public class User {
    private Integer id;
    private String name;
    private String email;
    private String password;
    private String role;
    private String tag; // Tag/kelompok user (contoh: Kelas A, Divisi IT, dll)
    private String photo; // Profile photo path
    private String gdriveLink; // Google Drive link

    // Achievement statistics
    private Integer totalPoints;
    private Integer totalQuizzes;
    private Integer perfectScores;

    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    // Constructors
    public User() {}

    public User(String name, String email, String password, String role) {
        this.name = name;
        this.email = email;
        this.password = password;
        this.role = role;
    }

    public User(String name, String email, String password, String role, String tag) {
        this.name = name;
        this.email = email;
        this.password = password;
        this.role = role;
        this.tag = tag;
    }

    // Getters and Setters
    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getRole() {
        return role;
    }

    public void setRole(String role) {
        this.role = role;
    }

    public String getTag() {
        return tag;
    }

    public void setTag(String tag) {
        this.tag = tag;
    }

    public String getPhoto() {
        return photo;
    }

    public void setPhoto(String photo) {
        this.photo = photo;
    }

    public String getGdriveLink() {
        return gdriveLink;
    }

    public void setGdriveLink(String gdriveLink) {
        this.gdriveLink = gdriveLink;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }

    public Integer getTotalPoints() {
        return totalPoints;
    }

    public void setTotalPoints(Integer totalPoints) {
        this.totalPoints = totalPoints;
    }

    public Integer getTotalQuizzes() {
        return totalQuizzes;
    }

    public void setTotalQuizzes(Integer totalQuizzes) {
        this.totalQuizzes = totalQuizzes;
    }

    public Integer getPerfectScores() {
        return perfectScores;
    }

    public void setPerfectScores(Integer perfectScores) {
        this.perfectScores = perfectScores;
    }

    // Helper methods
    public boolean isAdmin() {
        return "admin".equals(this.role);
    }

    public boolean isPeserta() {
        return "peserta".equals(this.role);
    }

    @Override
    public String toString() {
        return "User{" +
                "id=" + id +
                ", name='" + name + '\'' +
                ", email='" + email + '\'' +
                ", role='" + role + '\'' +
                '}';
    }
}
