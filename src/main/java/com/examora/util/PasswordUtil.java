package com.examora.util;

import org.mindrot.jbcrypt.BCrypt;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.util.Base64;

/**
 * Password Utility Class - Handles password hashing and verification
 * Uses BCrypt for secure password hashing
 */
public class PasswordUtil {
    private static final int SALT_LENGTH = 16;
    private static final int ITERATIONS = 10000;
    private static final String ALGORITHM = "SHA-256";
    private static final int BCRYPT_ROUNDS = 12;

    /**
     * Hash a password using BCrypt
     */
    public static String hashPassword(String password) {
        // Use BCrypt for new passwords
        return BCrypt.hashpw(password, BCrypt.gensalt(BCRYPT_ROUNDS));
    }

    /**
     * Verify a password against a hash
     * Supports both BCrypt and legacy SHA-256 hashes
     */
    public static boolean verifyPassword(String password, String storedHash) {
        if (password == null || storedHash == null || storedHash.isEmpty()) {
            return false;
        }

        try {
            // Handle BCrypt hashes
            if (storedHash.startsWith("$2a$") || storedHash.startsWith("$2b$")) {
                return BCrypt.checkpw(password, storedHash);
            }

            // Handle legacy SHA-256 hashes (format: iterations:salt:hash)
            String[] parts = storedHash.split(":");
            if (parts.length != 3) {
                return false;
            }

            int iterations = Integer.parseInt(parts[0]);
            byte[] salt = Base64.getDecoder().decode(parts[1]);
            byte[] hash = Base64.getDecoder().decode(parts[2]);

            byte[] testHash = hashWithSalt(password, salt, iterations);

            return MessageDigest.isEqual(hash, testHash);
        } catch (Exception e) {
            System.err.println("Error verifying password: " + e.getMessage());
            return false;
        }
    }

    /**
     * Hash password with salt using PBKDF2-like approach (legacy support)
     */
    private static byte[] hashWithSalt(String password, byte[] salt, int iterations)
            throws NoSuchAlgorithmException {
        MessageDigest digest = MessageDigest.getInstance(ALGORITHM);

        // Combine password and salt
        digest.update(salt);
        byte[] hash = digest.digest(password.getBytes());

        // Multiple iterations for security
        for (int i = 0; i < iterations; i++) {
            digest.reset();
            hash = digest.digest(hash);
        }

        return hash;
    }

    /**
     * Generate a random token for session/CSRF
     */
    public static String generateToken() {
        SecureRandom random = new SecureRandom();
        byte[] token = new byte[32];
        random.nextBytes(token);
        return Base64.getUrlEncoder().withoutPadding().encodeToString(token);
    }

    /**
     * Check if a hash needs to be rehashed (for migration to BCrypt)
     */
    public static boolean needsRehash(String storedHash) {
        // If it's not a BCrypt hash, it needs rehashing
        return !storedHash.startsWith("$2a$") && !storedHash.startsWith("$2b$");
    }
}
