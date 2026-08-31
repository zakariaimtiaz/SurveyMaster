package com.imtiaz.controller;

import com.imtiaz.config.AppProperty;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

@Controller
public class LoginController extends AppProperty {

    @GetMapping("/login")
    public String login(
            @RequestParam(value = "error", required = false) String error,
            @RequestParam(value = "logout", required = false) String logout,
            Model model) {
        if (error != null) {
            model.addAttribute("errorMessage", "Invalid username or password");
        }
        if (logout != null) {
            model.addAttribute("successMessage", "You have been logged out successfully");
        }
        return "login";
    }

    @GetMapping("/access-denied")
    public String accessDenied(Model model) {
        model.addAttribute("errorMessage", "You do not have permission to access this page");
        return "access_denied";
    }
}
