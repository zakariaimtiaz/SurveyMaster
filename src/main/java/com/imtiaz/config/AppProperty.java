package com.imtiaz.config;

import com.imtiaz.model.SecUser;
import com.imtiaz.repo.CompanyRepo;
import com.imtiaz.repo.SecUserRepo;
import java.util.Map;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.ModelAttribute;

public class AppProperty {

    @Autowired
    private CompanyRepo companyRepo;

    @Autowired
    private SecUserRepo secUserRepo;

    @Value("${app.base-url:}")
    private String appBaseUrl;

    /**
     * Resolves the application base URL. Uses the configured {@code app.base-url} when
     * present; otherwise reconstructs it from the incoming request (e.g. behind a proxy
     * or when the property is unset). Applicable to QR codes and reset-email links.
     */
    protected String resolveBaseUrl(HttpServletRequest request) {
        if (appBaseUrl != null && !appBaseUrl.trim().isEmpty()) {
            return appBaseUrl.trim();
        }
        if (request != null) {
            return request.getScheme() + "://" + request.getServerName() + ":"
                    + request.getServerPort() + request.getContextPath();
        }
        return "";
    }


    @ModelAttribute
    public void addCommonObjects(Model model, HttpServletRequest request, HttpServletResponse resp, HttpSession httpSession) {
        model.addAttribute("BASE_URL", request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + request.getContextPath());
        model.addAttribute("STATIC_RES", request.getContextPath() + "/resources");
        model.addAttribute("APP_NAME", "Survey Master");

        boolean hasCompany = false;
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();

        if (auth != null && auth.getPrincipal() instanceof UserDetails) {
            // Check if the user has ROLE_ADMIN
            boolean isAdmin = auth.getAuthorities().stream()
                    .anyMatch(a -> a.getAuthority().equals("ROLE_ADMIN"));
            model.addAttribute("IS_ADMIN", isAdmin);
            if (isAdmin) {
                hasCompany = true;
            } else {
                UserDetails user = (UserDetails) auth.getPrincipal();
                SecUser secUser = secUserRepo.findByUsername(user.getUsername());
                if (secUser != null) {
                    Map<String, Object> company = companyRepo.findByUserId(secUser.getId());
                    hasCompany = (company != null);
                }
            }
        }
        model.addAttribute("HAS_COMPANY", hasCompany);
    }
}
