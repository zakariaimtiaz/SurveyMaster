package com.imtiaz.repo;

import com.imtiaz.model.SecRole;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Repository;

@Repository
public class SecRoleRepo {

    @Autowired
    NamedParameterJdbcTemplate jdbcTmp;

    public List<String> findAuthoritiesByUserId(Long userId) {
        String sql = "SELECT r.authority FROM sec_role r " +
                     "INNER JOIN sec_user_sec_role ur ON ur.sec_role_id = r.id " +
                     "WHERE ur.sec_user_id = :userId AND r.active = 1";
        Map<String, Object> params = new HashMap<>();
        params.put("userId", userId);
        return jdbcTmp.queryForList(sql, params, String.class);
    }

    public SecRole findByAuthority(String authority) {
        String sql = "SELECT * FROM sec_role WHERE authority = :authority";
        Map<String, Object> params = new HashMap<>();
        params.put("authority", authority);
        List<SecRole> roles = jdbcTmp.query(sql, params, (rs, rowNum) -> {
            SecRole r = new SecRole();
            r.setId(rs.getLong("id"));
            r.setVersion(rs.getLong("version"));
            r.setAuthority(rs.getString("authority"));
            r.setName(rs.getString("name"));
            r.setActive(rs.getBoolean("active"));
            return r;
        });
        return roles.isEmpty() ? null : roles.get(0);
    }

    public List<SecRole> findAllActive() {
        String sql = "SELECT * FROM sec_role WHERE active = 1 ORDER BY name";
        return jdbcTmp.query(sql, new HashMap<>(), (rs, rowNum) -> {
            SecRole r = new SecRole();
            r.setId(rs.getLong("id"));
            r.setVersion(rs.getLong("version"));
            r.setAuthority(rs.getString("authority"));
            r.setName(rs.getString("name"));
            r.setActive(rs.getBoolean("active"));
            return r;
        });
    }
}
