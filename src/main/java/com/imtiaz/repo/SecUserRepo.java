package com.imtiaz.repo;

import com.imtiaz.model.SecUser;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Repository;

@Repository
public class SecUserRepo {

    @Autowired
    NamedParameterJdbcTemplate jdbcTmp;

    public SecUser findByUsername(String username) {
        String sql = "SELECT * FROM sec_user WHERE username = :username";
        Map<String, Object> params = new HashMap<>();
        params.put("username", username);
        List<SecUser> users = jdbcTmp.query(sql, params, (rs, rowNum) -> {
            SecUser u = new SecUser();
            u.setId(rs.getLong("id"));
            u.setVersion(rs.getLong("version"));
            u.setUsername(rs.getString("username"));
            u.setEmail(rs.getString("email"));
            u.setEnabled(rs.getBoolean("enabled"));
            u.setPassword(rs.getString("password"));
            u.setAccountExpired(rs.getBoolean("account_expired"));
            u.setAccountLocked(rs.getBoolean("account_locked"));
            u.setPasswordExpired(rs.getBoolean("password_expired"));
            u.setDefaultTargetUrl(rs.getString("default_target_url"));
            u.setResetToken(rs.getString("reset_token"));
            u.setResetTokenExpiry(rs.getTimestamp("reset_token_expiry"));
            return u;
        });
        return users.isEmpty() ? null : users.get(0);
    }

    public boolean usernameExists(String username) {
        String sql = "SELECT COUNT(*) FROM sec_user WHERE username = :username";
        Map<String, Object> params = new HashMap<>();
        params.put("username", username);
        Integer count = jdbcTmp.queryForObject(sql, params, Integer.class);
        return count != null && count > 0;
    }

    public boolean emailExists(String email) {
        String sql = "SELECT COUNT(*) FROM sec_user WHERE email = :email";
        Map<String, Object> params = new HashMap<>();
        params.put("email", email);
        Integer count = jdbcTmp.queryForObject(sql, params, Integer.class);
        return count != null && count > 0;
    }

    public Long save(String username, String email, String password) {
        String sql = "INSERT INTO sec_user (version, username, email, password, enabled, account_expired, account_locked, password_expired, default_target_url) " +
                     "VALUES (0, :username, :email, :password, 1, 0, 0, 0, '/')";
        Map<String, Object> params = new HashMap<>();
        params.put("username", username);
        params.put("email", email);
        params.put("password", password);
        jdbcTmp.update(sql, params);

        String idSql = "SELECT id FROM sec_user WHERE username = :username";
        return jdbcTmp.queryForObject(idSql, params, Long.class);
    }

    public void assignRole(Long userId, Long roleId) {
        String sql = "INSERT INTO sec_user_sec_role (sec_user_id, sec_role_id) VALUES (:userId, :roleId)";
        Map<String, Object> params = new HashMap<>();
        params.put("userId", userId);
        params.put("roleId", roleId);
        jdbcTmp.update(sql, params);
    }

    public void updatePassword(Long userId, String encodedPassword) {
        String sql = "UPDATE sec_user SET password = :password WHERE id = :id";
        Map<String, Object> params = new HashMap<>();
        params.put("id", userId);
        params.put("password", encodedPassword);
        jdbcTmp.update(sql, params);
    }

    public SecUser findByResetToken(String token) {
        String sql = "SELECT * FROM sec_user WHERE reset_token = :token";
        Map<String, Object> params = new HashMap<>();
        params.put("token", token);
        List<SecUser> users = jdbcTmp.query(sql, params, (rs, rowNum) -> {
            SecUser u = new SecUser();
            u.setId(rs.getLong("id"));
            u.setVersion(rs.getLong("version"));
            u.setUsername(rs.getString("username"));
            u.setEmail(rs.getString("email"));
            u.setEnabled(rs.getBoolean("enabled"));
            u.setPassword(rs.getString("password"));
            u.setAccountExpired(rs.getBoolean("account_expired"));
            u.setAccountLocked(rs.getBoolean("account_locked"));
            u.setPasswordExpired(rs.getBoolean("password_expired"));
            u.setDefaultTargetUrl(rs.getString("default_target_url"));
            u.setResetToken(rs.getString("reset_token"));
            u.setResetTokenExpiry(rs.getTimestamp("reset_token_expiry"));
            return u;
        });
        return users.isEmpty() ? null : users.get(0);
    }

    public void setResetToken(Long userId, String token, String expiryAt) {
        String sql = "UPDATE sec_user SET reset_token = :token, reset_token_expiry = :expiry WHERE id = :id";
        Map<String, Object> params = new HashMap<>();
        params.put("id", userId);
        params.put("token", token);
        params.put("expiry", expiryAt);
        jdbcTmp.update(sql, params);
    }

    public void clearResetToken(Long userId) {
        String sql = "UPDATE sec_user SET reset_token = NULL, reset_token_expiry = NULL WHERE id = :id";
        Map<String, Object> params = new HashMap<>();
        params.put("id", userId);
        jdbcTmp.update(sql, params);
    }
}
