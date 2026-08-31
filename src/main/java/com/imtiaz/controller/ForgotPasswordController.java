package com.imtiaz.controller;

import com.imtiaz.config.AppProperty;
import com.imtiaz.config.AppResponse;
import com.imtiaz.model.SecUser;
import com.imtiaz.repo.SecUserRepo;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;
import javax.mail.internet.MimeMessage;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.servlet.ModelAndView;

@RestController
public class ForgotPasswordController extends AppProperty {

    private static final Logger log = LoggerFactory.getLogger(ForgotPasswordController.class);

    @Autowired
    private SecUserRepo secUserRepo;

    @Autowired
    private JavaMailSender mailSender;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Value("${app.mail.from:noreply@surveymaster.local}")
    private String mailFrom;

    @RequestMapping(value = "/forgot-password", method = RequestMethod.GET)
    public ModelAndView forgotPasswordPage() {
        return new ModelAndView("forgot_password");
    }

    @RequestMapping(value = "/forgot-password", method = RequestMethod.POST)
    public AppResponse<String> forgotPassword(@RequestBody Map<String, Object> request,
                                              javax.servlet.http.HttpServletRequest httpRequest) {
        try {
            String username = request.get("username") != null ? request.get("username").toString().trim() : "";
            if (username.isEmpty()) {
                return AppResponse.build(HttpStatus.BAD_REQUEST).message("Username is required");
            }

            SecUser user = secUserRepo.findByUsername(username);
            if (user == null) {
                return AppResponse.build(HttpStatus.BAD_REQUEST).message("Username not found");
            }
            if (user.getEmail() == null || user.getEmail().isEmpty()) {
                return AppResponse.build(HttpStatus.BAD_REQUEST).message("No email address associated with this account");
            }

            String token = UUID.randomUUID().toString().replace("-", "");
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
            String expiryAt = sdf.format(new Date(System.currentTimeMillis() + 30 * 60 * 1000));
            secUserRepo.setResetToken(user.getId(), token, expiryAt);

            String resetLink = resolveBaseUrl(httpRequest) + "/reset-password?token=" + token;

            MimeMessage mimeMessage = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(mimeMessage, true, "UTF-8");
            helper.setFrom(mailFrom);
            helper.setTo(user.getEmail());
            helper.setSubject("SurveyMaster - Password Reset Request");
            String htmlBody = "<div style='font-family:Arial,sans-serif;max-width:500px;margin:0 auto;'>"
                + "<h2 style='color:#667eea;'>Password Reset Request</h2>"
                + "<p>Hello <b>" + user.getUsername() + "</b>,</p>"
                + "<p>You requested a password reset. Click the button below to set a new password:</p>"
                + "<p style='text-align:center;margin:25px 0;'>"
                + "<a href='" + resetLink + "' style='background:#667eea;color:#fff;padding:12px 30px;border-radius:8px;text-decoration:none;font-weight:600;'>Reset Password</a>"
                + "</p>"
                + "<p style='color:#6b7280;font-size:0.85rem;'>This link expires in 30 minutes. If you did not request this, ignore this email.</p>"
                + "<hr style='border:none;border-top:1px solid #e5e7eb;margin:20px 0;'>"
                + "<p style='color:#9ca3af;font-size:0.8rem;'>SurveyMaster</p>"
                + "</div>";
            helper.setText(htmlBody, true);
            mailSender.send(mimeMessage);

            log.info("Password reset email sent to {} for user {}", user.getEmail(), user.getUsername());
            String maskedEmail = maskEmail(user.getEmail());
            return AppResponse.build(HttpStatus.OK).body("Reset link has been sent to " + maskedEmail);
        } catch (Exception ex) {
            log.error("Error in forgot-password", ex);
            return AppResponse.build(HttpStatus.INTERNAL_SERVER_ERROR).message("An error occurred. Please try again.");
        }
    }

    private String maskEmail(String email) {
        int at = email.indexOf('@');
        if (at <= 2) return email;
        StringBuilder sb = new StringBuilder();
        sb.append(email.substring(0, 2));
        for (int i = 2; i < at; i++) sb.append('*');
        sb.append(email.substring(at));
        return sb.toString();
    }

    @RequestMapping(value = "/reset-password", method = RequestMethod.GET)
    public ModelAndView resetPasswordPage(@RequestParam("token") String token) {
        Map<String, Object> model = new HashMap<>();
        model.put("token", token);

        SecUser user = secUserRepo.findByResetToken(token);
        if (user == null) {
            model.put("valid", false);
            model.put("errorMsg", "Invalid or expired reset link.");
        } else if (user.getResetTokenExpiry() == null || new Timestamp(System.currentTimeMillis()).after(user.getResetTokenExpiry())) {
            model.put("valid", false);
            model.put("errorMsg", "This reset link has expired. Please request a new one.");
        } else {
            model.put("valid", true);
        }

        return new ModelAndView("reset-password", model);
    }

    @RequestMapping(value = "/reset-password", method = RequestMethod.POST)
    public AppResponse<String> resetPassword(@RequestBody Map<String, Object> request) {
        try {
            String token = request.get("token") != null ? request.get("token").toString().trim() : "";
            String password = request.get("password") != null ? request.get("password").toString().trim() : "";
            String confirmPassword = request.get("confirmPassword") != null ? request.get("confirmPassword").toString().trim() : "";

            if (token.isEmpty()) {
                return AppResponse.build(HttpStatus.BAD_REQUEST).message("Token is required");
            }
            if (password.isEmpty()) {
                return AppResponse.build(HttpStatus.BAD_REQUEST).message("Password is required");
            }
            if (!password.equals(confirmPassword)) {
                return AppResponse.build(HttpStatus.BAD_REQUEST).message("Passwords do not match");
            }
            if (password.length() < 3) {
                return AppResponse.build(HttpStatus.BAD_REQUEST).message("Password must be at least 3 characters");
            }

            SecUser user = secUserRepo.findByResetToken(token);
            if (user == null) {
                return AppResponse.build(HttpStatus.BAD_REQUEST).message("Invalid or expired reset link");
            }
            if (user.getResetTokenExpiry() == null || new Timestamp(System.currentTimeMillis()).after(user.getResetTokenExpiry())) {
                return AppResponse.build(HttpStatus.BAD_REQUEST).message("This reset link has expired. Please request a new one.");
            }

            String encodedPassword = passwordEncoder.encode(password);
            secUserRepo.updatePassword(user.getId(), encodedPassword);
            secUserRepo.clearResetToken(user.getId());

            log.info("Password reset successful for user {}", user.getUsername());
            return AppResponse.build(HttpStatus.OK).body("Password reset successful. You can now login.");
        } catch (Exception ex) {
            log.error("Error in reset-password", ex);
            return AppResponse.build(HttpStatus.INTERNAL_SERVER_ERROR).message("An error occurred. Please try again.");
        }
    }
}
