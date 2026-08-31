package com.imtiaz.controller;

import com.imtiaz.config.AppProperty;
import com.imtiaz.config.AppResponse;
import com.imtiaz.repo.SecRoleRepo;
import com.imtiaz.repo.SecUserRepo;
import java.util.HashMap;
import java.util.Map;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.servlet.ModelAndView;

@RestController
public class RegistrationController extends AppProperty {

    @Autowired
    private SecUserRepo secUserRepo;

    @Autowired
    private SecRoleRepo secRoleRepo;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @RequestMapping(value = "/register", method = RequestMethod.GET)
    public ModelAndView registerPage() {
        return new ModelAndView("register");
    }

    @RequestMapping(value = "/register", method = RequestMethod.POST)
    public AppResponse<String> register(@RequestBody Map<String, Object> request) {
        try {
            String username = str(request.get("username")).trim();
            String email = str(request.get("email")).trim();
            String password = str(request.get("password")).trim();
            String confirmPassword = str(request.get("confirmPassword")).trim();

            if (username.isEmpty()) {
                return AppResponse.build(HttpStatus.BAD_REQUEST).message("Username is required");
            }
            if (email.isEmpty()) {
                return AppResponse.build(HttpStatus.BAD_REQUEST).message("Email is required");
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
            if (secUserRepo.usernameExists(username)) {
                return AppResponse.build(HttpStatus.BAD_REQUEST).message("Username already exists");
            }
            if (secUserRepo.emailExists(email)) {
                return AppResponse.build(HttpStatus.BAD_REQUEST).message("Email already exists");
            }

            String encodedPassword = passwordEncoder.encode(password);
            Long userId = secUserRepo.save(username, email, encodedPassword);

            // Assign default ROLE_USER
            com.imtiaz.model.SecRole userRole = secRoleRepo.findByAuthority("ROLE_USER");
            if (userRole != null) {
                secUserRepo.assignRole(userId, userRole.getId());
            }

            return AppResponse.build(HttpStatus.OK).body("Registration successful. You can now login.");
        } catch (Exception ex) {
            return AppResponse.build(HttpStatus.INTERNAL_SERVER_ERROR).message(ex.getMessage());
        }
    }

    private static String str(Object value) {
        return value == null ? "" : value.toString();
    }
}
