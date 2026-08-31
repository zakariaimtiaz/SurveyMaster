package com.imtiaz.security;

import com.imtiaz.model.SecUser;
import com.imtiaz.repo.CompanyRepo;
import com.imtiaz.repo.SecUserRepo;
import java.io.IOException;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.web.authentication.AuthenticationSuccessHandler;
import org.springframework.stereotype.Component;

@Component
public class LoginSuccessHandler implements AuthenticationSuccessHandler {

    @Autowired
    private SecUserRepo secUserRepo;

    @Autowired
    private CompanyRepo companyRepo;

    @Override
    public void onAuthenticationSuccess(HttpServletRequest request, HttpServletResponse response,
                                        Authentication authentication) throws IOException, ServletException {

        boolean isAdmin = authentication.getAuthorities().stream()
                .anyMatch(grantedAuthority -> grantedAuthority.getAuthority().equals("ROLE_ADMIN"));

        // Non-admin users without a company are forced to setup a company first
        if (!isAdmin) {
            UserDetails user = (UserDetails) authentication.getPrincipal();
            SecUser secUser = secUserRepo.findByUsername(user.getUsername());

            if (secUser != null) {
                Map<String, Object> company = companyRepo.findByUserId(secUser.getId());
                if (company == null) {
                    response.sendRedirect(request.getContextPath() + "/company");
                    return;
                }
            }
        }

        response.sendRedirect(request.getContextPath() + "/");
    }
}
