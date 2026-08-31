package com.imtiaz.security;

import com.imtiaz.model.SecUser;
import com.imtiaz.repo.SecRoleRepo;
import com.imtiaz.repo.SecUserRepo;
import java.util.ArrayList;
import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.User;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

@Service
public class CustomUserDetailsService implements UserDetailsService {

    @Autowired
    private SecUserRepo secUserRepo;

    @Autowired
    private SecRoleRepo secRoleRepo;

    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        SecUser secUser = secUserRepo.findByUsername(username);
        if (secUser == null) {
            throw new UsernameNotFoundException("User not found: " + username);
        }

        List<String> authorities = secRoleRepo.findAuthoritiesByUserId(secUser.getId());
        if (authorities.isEmpty()) {
            throw new UsernameNotFoundException("Access denied: No role assigned. Contact administrator.");
        }

        List<GrantedAuthority> grantedAuthorities = new ArrayList<>();
        for (String authority : authorities) {
            grantedAuthorities.add(new SimpleGrantedAuthority(authority));
        }

        return new User(
            secUser.getUsername(),
            secUser.getPassword(),
            secUser.isEnabled(),
            !secUser.isAccountExpired(),
            !secUser.isPasswordExpired(),
            !secUser.isAccountLocked(),
            grantedAuthorities
        );
    }
}
