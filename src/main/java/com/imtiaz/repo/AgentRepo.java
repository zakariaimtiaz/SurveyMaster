package com.imtiaz.repo;

import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Repository;

@Repository
public class AgentRepo {

    @Autowired
    NamedParameterJdbcTemplate jdbcTmp;

    public Long save(Long companyId, String keyValue, String label, Date expiration) {
        String sql = "INSERT INTO agent_master (COMPANY_ID, KEY_VALUE, NAME, EXPIRATION) VALUES (:companyId, :keyValue, :name, :expiration)";
        Map<String, Object> params = new HashMap<>();
        params.put("companyId", companyId);
        params.put("keyValue", keyValue);
        params.put("name", label);
        params.put("expiration", expiration);
        jdbcTmp.update(sql, params);
        return jdbcTmp.queryForObject("SELECT LAST_INSERT_ID()", new HashMap<>(), Long.class);
    }

    public boolean update(Long id, String keyValue, String label, Date expiration, boolean status) {
        String sql = "UPDATE agent_master SET KEY_VALUE=:keyValue, NAME=:name, EXPIRATION=:expiration, STATUS=:status WHERE AGENT_ID=:id";
        Map<String, Object> params = new HashMap<>();
        params.put("id", id);
        params.put("keyValue", keyValue);
        params.put("name", label);
        params.put("expiration", expiration);
        params.put("status", status ? 1 : 0);
        return jdbcTmp.update(sql, params) == 1;
    }

    public boolean deleteById(Long id) {
        String sql = "DELETE FROM agent_master WHERE AGENT_ID=:id";
        Map<String, Object> params = new HashMap<>();
        params.put("id", id);
        return jdbcTmp.update(sql, params) == 1;
    }

    public Map<String, Object> findById(Long id) {
        String sql = "SELECT AGENT_ID, COMPANY_ID, KEY_VALUE, NAME, EXPIRATION, STATUS FROM agent_master WHERE AGENT_ID=:id";
        Map<String, Object> params = new HashMap<>();
        params.put("id", id);
        List<Map<String, Object>> rows = jdbcTmp.queryForList(sql, params);
        return rows.isEmpty() ? null : rows.get(0);
    }

  public List<Map<String, Object>> findByCompanyId(Long companyId) {
    String sql = "SELECT AGENT_ID, COMPANY_ID, KEY_VALUE, NAME, EXPIRATION, STATUS FROM agent_master WHERE COMPANY_ID=:companyId ORDER BY AGENT_ID DESC";
    Map<String, Object> params = new HashMap<>();
    params.put("companyId", companyId);
    return jdbcTmp.queryForList(sql, params);
  }

  public List<Map<String, Object>> findActiveByCompanyId(Long companyId) {
    String sql = "SELECT AGENT_ID, COMPANY_ID, KEY_VALUE, NAME, EXPIRATION, STATUS " +
                 "FROM agent_master WHERE COMPANY_ID=:companyId AND STATUS=1 ORDER BY AGENT_ID DESC";
    Map<String, Object> params = new HashMap<>();
    params.put("companyId", companyId);
    return jdbcTmp.queryForList(sql, params);
  }

  public Map<String, Object> findByKeyValue(String keyValue) {
    String sql = "SELECT AGENT_ID, COMPANY_ID, KEY_VALUE, NAME, EXPIRATION, STATUS " +
                 "FROM agent_master WHERE KEY_VALUE=:kv";
    Map<String, Object> params = new HashMap<>();
    params.put("kv", keyValue);
    List<Map<String, Object>> rows = jdbcTmp.queryForList(sql, params);
    return rows.isEmpty() ? null : rows.get(0);
  }

    public boolean keyValueExists(String keyValue, Long excludeId) {
        String sql = "SELECT COUNT(*) FROM agent_master WHERE KEY_VALUE=:keyValue";
        Map<String, Object> params = new HashMap<>();
        params.put("keyValue", keyValue);
        if (excludeId != null) {
            sql += " AND AGENT_ID!=:excludeId";
            params.put("excludeId", excludeId);
        }
        return jdbcTmp.queryForObject(sql, params, Integer.class) > 0;
    }
}
