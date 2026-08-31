package com.imtiaz.repo;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Repository;

@Repository
public class CompanyRepo {

    @Autowired
    NamedParameterJdbcTemplate jdbcTmp;

    public Long save(String name, String description, Long userId, String companyKey) {
        String sql = "INSERT INTO company_master (NAME, DESCRIPTION, USER_ID, COMPANY_KEY) VALUES (:name, :description, :userId, :companyKey)";
        Map<String, Object> params = new HashMap<>();
        params.put("name", name);
        params.put("description", description);
        params.put("userId", userId);
        params.put("companyKey", companyKey);
        jdbcTmp.update(sql, params);
        return jdbcTmp.queryForObject("SELECT LAST_INSERT_ID()", new HashMap<>(), Long.class);
    }

    public boolean update(Long id, String name, String description, boolean state) {
        String sql = "UPDATE company_master SET NAME=:name, DESCRIPTION=:description, STATE=:state WHERE COMPANY_ID=:id";
        Map<String, Object> params = new HashMap<>();
        params.put("id", id);
        params.put("name", name);
        params.put("description", description);
        params.put("state", state ? 1 : 0);
        return jdbcTmp.update(sql, params) == 1;
    }

    public boolean deleteById(Long id) {
        String sql = "DELETE FROM company_master WHERE COMPANY_ID=:id";
        Map<String, Object> params = new HashMap<>();
        params.put("id", id);
        return jdbcTmp.update(sql, params) == 1;
    }

    public Map<String, Object> findById(Long id) {
        String sql = "SELECT COMPANY_ID, NAME, COALESCE(DESCRIPTION,'') DESCRIPTION, STATE, USER_ID, COMPANY_KEY FROM company_master WHERE COMPANY_ID=:id";
        Map<String, Object> params = new HashMap<>();
        params.put("id", id);
        List<Map<String, Object>> rows = jdbcTmp.queryForList(sql, params);
        return rows.isEmpty() ? null : rows.get(0);
    }

    public Map<String, Object> findByUserId(Long userId) {
        String sql = "SELECT COMPANY_ID, NAME, COALESCE(DESCRIPTION,'') DESCRIPTION, STATE, USER_ID, COMPANY_KEY FROM company_master WHERE USER_ID=:userId";
        Map<String, Object> params = new HashMap<>();
        params.put("userId", userId);
        List<Map<String, Object>> rows = jdbcTmp.queryForList(sql, params);
        return rows.isEmpty() ? null : rows.get(0);
    }

    public Map<String, Object> findByKey(String companyKey) {
        String sql = "SELECT COMPANY_ID, NAME, COALESCE(DESCRIPTION,'') DESCRIPTION, STATE, USER_ID, COMPANY_KEY FROM company_master WHERE COMPANY_KEY=:companyKey";
        Map<String, Object> params = new HashMap<>();
        params.put("companyKey", companyKey);
        List<Map<String, Object>> rows = jdbcTmp.queryForList(sql, params);
        return rows.isEmpty() ? null : rows.get(0);
    }

    public boolean hasCompany(Long userId) {
        String sql = "SELECT COUNT(*) FROM company_master WHERE USER_ID=:userId";
        Map<String, Object> params = new HashMap<>();
        params.put("userId", userId);
        return jdbcTmp.queryForObject(sql, params, Integer.class) > 0;
    }

    public List<Map<String, Object>> findAll() {
        String sql = "SELECT COMPANY_ID, NAME, COALESCE(DESCRIPTION,'') DESCRIPTION, STATE, USER_ID, COMPANY_KEY FROM company_master ORDER BY COMPANY_ID DESC";
        return jdbcTmp.queryForList(sql, new HashMap<>());
    }

    public List<Map<String, Object>> findAllWithAgentCount() {
        String sql = "SELECT c.COMPANY_ID, c.NAME, COALESCE(c.DESCRIPTION,'') DESCRIPTION, c.STATE, c.USER_ID, c.COMPANY_KEY, " +
                     "COALESCE(a.AGENT_COUNT, 0) AGENT_COUNT " +
                     "FROM company_master c " +
                     "LEFT JOIN (SELECT COMPANY_ID, COUNT(*) AGENT_COUNT FROM agent_master GROUP BY COMPANY_ID) a " +
                     "ON c.COMPANY_ID = a.COMPANY_ID " +
                     "ORDER BY c.COMPANY_ID DESC";
        return jdbcTmp.queryForList(sql, new HashMap<>());
    }

    public boolean updateState(Long id, boolean state) {
        String sql = "UPDATE company_master SET STATE=:state WHERE COMPANY_ID=:id";
        Map<String, Object> params = new HashMap<>();
        params.put("id", id);
        params.put("state", state ? 1 : 0);
        return jdbcTmp.update(sql, params) == 1;
    }

    public boolean updateCompanyKey(Long id, String companyKey) {
        String sql = "UPDATE company_master SET COMPANY_KEY=:companyKey WHERE COMPANY_ID=:id";
        Map<String, Object> params = new HashMap<>();
        params.put("id", id);
        params.put("companyKey", companyKey);
        return jdbcTmp.update(sql, params) == 1;
    }

    public boolean nameExists(String name, Long excludeId) {
        String sql = "SELECT COUNT(*) FROM company_master WHERE NAME=:name";
        Map<String, Object> params = new HashMap<>();
        params.put("name", name);
        if (excludeId != null) {
            sql += " AND COMPANY_ID!=:excludeId";
            params.put("excludeId", excludeId);
        }
        return jdbcTmp.queryForObject(sql, params, Integer.class) > 0;
    }

    public boolean companyKeyExists(String companyKey) {
        String sql = "SELECT COUNT(*) FROM company_master WHERE COMPANY_KEY=:companyKey";
        Map<String, Object> params = new HashMap<>();
        params.put("companyKey", companyKey);
        return jdbcTmp.queryForObject(sql, params, Integer.class) > 0;
    }
}
