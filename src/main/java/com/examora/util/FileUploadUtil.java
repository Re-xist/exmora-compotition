package com.examora.util;

import jakarta.servlet.http.Part;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;
import java.util.UUID;

/**
 * File Upload Utility - Handles secure file uploads
 */
public class FileUploadUtil {

    // Allowed image extensions
    private static final Set<String> ALLOWED_EXTENSIONS = new HashSet<>(
            Arrays.asList("jpg", "jpeg", "png", "gif", "webp")
    );

    // Allowed MIME types
    private static final Set<String> ALLOWED_MIME_TYPES = new HashSet<>(
            Arrays.asList("image/jpeg", "image/png", "image/gif", "image/webp")
    );

    // Max file size: 2MB
    private static final long MAX_FILE_SIZE = 2 * 1024 * 1024;

    /**
     * Validate and upload an image file
     * @param filePart The uploaded file part
     * @param uploadDir The directory to save the file
     * @return The relative path to the saved file
     * @throws FileUploadException if validation fails
     */
    public static String uploadImage(Part filePart, String uploadDir) throws FileUploadException {
        // Check if file is provided
        if (filePart == null || filePart.getSize() == 0) {
            throw new FileUploadException("Tidak ada file yang dipilih");
        }

        // Check file size
        if (filePart.getSize() > MAX_FILE_SIZE) {
            throw new FileUploadException("Ukuran file maksimal 2MB");
        }

        // Get file name and extension
        String fileName = getFileName(filePart);
        String extension = getFileExtension(fileName);

        // Validate extension
        if (extension == null || !ALLOWED_EXTENSIONS.contains(extension.toLowerCase())) {
            throw new FileUploadException("Format file tidak didukung. Gunakan: JPG, PNG, GIF, WEBP");
        }

        // Validate MIME type
        String contentType = filePart.getContentType();
        if (contentType == null || !ALLOWED_MIME_TYPES.contains(contentType.toLowerCase())) {
            throw new FileUploadException("Tipe file tidak valid");
        }

        // Generate unique filename
        String newFileName = UUID.randomUUID().toString() + "." + extension.toLowerCase();
        String relativePath = "uploads/photos/" + newFileName;

        try {
            // Create directory if not exists
            Path dirPath = Paths.get(uploadDir, "uploads", "photos");
            if (!Files.exists(dirPath)) {
                Files.createDirectories(dirPath);
            }

            // Save file
            Path filePath = dirPath.resolve(newFileName);
            try (InputStream input = filePart.getInputStream()) {
                Files.copy(input, filePath, StandardCopyOption.REPLACE_EXISTING);
            }

            return relativePath;

        } catch (IOException e) {
            throw new FileUploadException("Gagal menyimpan file: " + e.getMessage(), e);
        }
    }

    /**
     * Extract filename from Part header
     */
    private static String getFileName(Part part) {
        String contentDisp = part.getHeader("content-disposition");
        if (contentDisp == null) return "";

        String[] items = contentDisp.split(";");
        for (String item : items) {
            if (item.trim().startsWith("filename")) {
                return item.substring(item.indexOf("=") + 2, item.length() - 1);
            }
        }
        return "";
    }

    /**
     * Get file extension
     */
    private static String getFileExtension(String fileName) {
        if (fileName == null || fileName.isEmpty()) return null;
        int dotIndex = fileName.lastIndexOf('.');
        if (dotIndex > 0 && dotIndex < fileName.length() - 1) {
            return fileName.substring(dotIndex + 1);
        }
        return null;
    }

    /**
     * Delete a file if it exists
     */
    public static boolean deleteFile(String relativePath, String uploadDir) {
        if (relativePath == null || relativePath.isEmpty()) return false;

        try {
            Path filePath = Paths.get(uploadDir, relativePath);
            if (Files.exists(filePath)) {
                Files.delete(filePath);
                return true;
            }
        } catch (IOException e) {
            System.err.println("Failed to delete file: " + e.getMessage());
        }
        return false;
    }

    /**
     * File Upload Exception
     */
    public static class FileUploadException extends Exception {
        public FileUploadException(String message) {
            super(message);
        }

        public FileUploadException(String message, Throwable cause) {
            super(message, cause);
        }
    }
}
