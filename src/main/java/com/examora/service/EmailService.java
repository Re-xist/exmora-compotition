package com.examora.service;

import com.examora.util.DBUtil;

import jakarta.mail.*;
import jakarta.mail.internet.*;
import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;

/**
 * EmailService - Handles email sending via SMTP
 */
public class EmailService {
    private Properties emailConfig;
    private boolean configured;

    public EmailService() {
        loadConfiguration();
    }

    /**
     * Load email configuration from db.properties
     */
    private void loadConfiguration() {
        emailConfig = new Properties();

        try (InputStream is = DBUtil.class.getClassLoader().getResourceAsStream("db.properties")) {
            if (is != null) {
                Properties props = new Properties();
                props.load(is);

                // Load email configuration
                emailConfig.setProperty("mail.smtp.host", props.getProperty("email.smtp.host", "smtp.gmail.com"));
                emailConfig.setProperty("mail.smtp.port", props.getProperty("email.smtp.port", "587"));
                emailConfig.setProperty("mail.smtp.auth", props.getProperty("email.smtp.auth", "true"));
                emailConfig.setProperty("mail.smtp.starttls.enable", props.getProperty("email.smtp.starttls", "true"));
                emailConfig.setProperty("mail.username", props.getProperty("email.username", ""));
                emailConfig.setProperty("mail.password", props.getProperty("email.password", ""));
                emailConfig.setProperty("mail.from", props.getProperty("email.from", "noreply@examora.com"));

                configured = !props.getProperty("email.username", "").isEmpty() &&
                             !props.getProperty("email.password", "").isEmpty();
            }
        } catch (IOException e) {
            System.err.println("Failed to load email configuration: " + e.getMessage());
            configured = false;
        }
    }

    /**
     * Send an email
     * @param to Recipient email address
     * @param subject Email subject
     * @param body Email body (plain text)
     * @return true if email was sent successfully
     */
    public boolean sendEmail(String to, String subject, String body) {
        if (!configured) {
            System.out.println("Email not configured. Skipping email to: " + to);
            return false;
        }

        try {
            // Create mail session
            Session session = createSession();

            // Create message
            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(emailConfig.getProperty("mail.from")));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(to));
            message.setSubject(subject);
            message.setText(body);

            // Send message
            Transport.send(message);

            System.out.println("Email sent successfully to: " + to);
            return true;

        } catch (MessagingException e) {
            System.err.println("Failed to send email to " + to + ": " + e.getMessage());
            return false;
        }
    }

    /**
     * Send an HTML email
     * @param to Recipient email address
     * @param subject Email subject
     * @param htmlBody Email body (HTML)
     * @return true if email was sent successfully
     */
    public boolean sendHtmlEmail(String to, String subject, String htmlBody) {
        if (!configured) {
            System.out.println("Email not configured. Skipping email to: " + to);
            return false;
        }

        try {
            Session session = createSession();

            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(emailConfig.getProperty("mail.from")));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(to));
            message.setSubject(subject);
            message.setContent(htmlBody, "text/html; charset=utf-8");

            Transport.send(message);

            System.out.println("HTML email sent successfully to: " + to);
            return true;

        } catch (MessagingException e) {
            System.err.println("Failed to send HTML email to " + to + ": " + e.getMessage());
            return false;
        }
    }

    /**
     * Create mail session with authentication
     */
    private Session createSession() {
        Properties props = new Properties();
        props.putAll(emailConfig);

        // Remove non-JavaMail properties
        props.remove("mail.username");
        props.remove("mail.password");
        props.remove("mail.from");

        final String username = emailConfig.getProperty("mail.username");
        final String password = emailConfig.getProperty("mail.password");

        return Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(username, password);
            }
        });
    }

    /**
     * Check if email is configured
     */
    public boolean isConfigured() {
        return configured;
    }

    /**
     * Get configuration status message
     */
    public String getConfigStatus() {
        if (configured) {
            return "Email configured with " + emailConfig.getProperty("mail.smtp.host");
        } else {
            return "Email not configured. Add email.* properties to db.properties";
        }
    }

    /**
     * Test email configuration by sending a test email
     */
    public boolean testConfiguration(String testEmail) {
        if (!configured) {
            return false;
        }

        return sendEmail(testEmail, "Examora Test Email",
                "This is a test email from Examora.\n\nIf you received this, email configuration is working correctly.");
    }
}
