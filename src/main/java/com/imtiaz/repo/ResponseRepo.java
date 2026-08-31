package com.imtiaz.repo;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Repository;

@Repository
public class ResponseRepo {

    @Autowired
    NamedParameterJdbcTemplate jdbcTmp;

    public Long save(Long questionnaireId, Long companyId, Long agentId, String responseData, java.sql.Timestamp recordedAt) {
        String sql = "INSERT INTO response_master (QUESTIONNAIRE_ID, COMPANY_ID, AGENT_ID, RESPONSE_DATA, RECORDED_AT) " +
                     "VALUES (:questionnaireId, :companyId, :agentId, :responseData, :recordedAt)";
        Map<String, Object> params = new HashMap<>();
        params.put("questionnaireId", questionnaireId);
        params.put("companyId", companyId);
        params.put("agentId", agentId);
        params.put("responseData", responseData);
        params.put("recordedAt", recordedAt);
        jdbcTmp.update(sql, params);
        return jdbcTmp.queryForObject("SELECT LAST_INSERT_ID()", new HashMap<>(), Long.class);
    }

    public List<Map<String, Object>> findByQuestionnaireId(Long questionnaireId) {
        String sql = "SELECT r.RESPONSE_ID, r.QUESTIONNAIRE_ID, r.COMPANY_ID, r.AGENT_ID, " +
                     "r.RESPONSE_DATA, r.SUBMITTED_AT, r.RECORDED_AT, " +
                     "COALESCE(q.NAME,'') QUESTIONNAIRE_NAME, " +
                     "COALESCE(c.NAME,'') COMPANY_NAME " +
                     "FROM response_master r " +
                     "LEFT JOIN questionnaire_master q ON r.QUESTIONNAIRE_ID = q.QUESTIONNAIRE_ID " +
                     "LEFT JOIN company_master c ON r.COMPANY_ID = c.COMPANY_ID " +
                     "WHERE r.QUESTIONNAIRE_ID = :questionnaireId " +
                     "ORDER BY r.SUBMITTED_AT DESC";
        Map<String, Object> params = new HashMap<>();
        params.put("questionnaireId", questionnaireId);
        return jdbcTmp.queryForList(sql, params);
    }

    public List<Map<String, Object>> findAll() {
        String sql = "SELECT r.RESPONSE_ID, r.QUESTIONNAIRE_ID, r.COMPANY_ID, r.AGENT_ID, " +
                     "r.RESPONSE_DATA, r.SUBMITTED_AT, r.RECORDED_AT, " +
                     "COALESCE(q.NAME,'') QUESTIONNAIRE_NAME, " +
                     "COALESCE(c.NAME,'') COMPANY_NAME " +
                     "FROM response_master r " +
                     "LEFT JOIN questionnaire_master q ON r.QUESTIONNAIRE_ID = q.QUESTIONNAIRE_ID " +
                     "LEFT JOIN company_master c ON r.COMPANY_ID = c.COMPANY_ID " +
                     "ORDER BY r.SUBMITTED_AT DESC";
        return jdbcTmp.queryForList(sql, new HashMap<>());
    }

    public Map<String, Object> findById(Long id) {
        String sql = "SELECT r.RESPONSE_ID, r.QUESTIONNAIRE_ID, r.COMPANY_ID, r.AGENT_ID, " +
                     "r.RESPONSE_DATA, r.SUBMITTED_AT, r.RECORDED_AT, " +
                     "COALESCE(q.NAME,'') QUESTIONNAIRE_NAME, " +
                     "COALESCE(c.NAME,'') COMPANY_NAME " +
                     "FROM response_master r " +
                     "LEFT JOIN questionnaire_master q ON r.QUESTIONNAIRE_ID = q.QUESTIONNAIRE_ID " +
                     "LEFT JOIN company_master c ON r.COMPANY_ID = c.COMPANY_ID " +
                     "WHERE r.RESPONSE_ID = :id";
        Map<String, Object> params = new HashMap<>();
        params.put("id", id);
        List<Map<String, Object>> rows = jdbcTmp.queryForList(sql, params);
        return rows.isEmpty() ? null : rows.get(0);
    }

    public List<Map<String, Object>> findByCompanyId(Long companyId) {
        String sql = "SELECT r.RESPONSE_ID, r.QUESTIONNAIRE_ID, r.COMPANY_ID, r.AGENT_ID, " +
                     "r.RESPONSE_DATA, r.SUBMITTED_AT, r.RECORDED_AT, " +
                     "COALESCE(q.NAME,'') QUESTIONNAIRE_NAME, " +
                     "COALESCE(c.NAME,'') COMPANY_NAME " +
                     "FROM response_master r " +
                     "LEFT JOIN questionnaire_master q ON r.QUESTIONNAIRE_ID = q.QUESTIONNAIRE_ID " +
                     "LEFT JOIN company_master c ON r.COMPANY_ID = c.COMPANY_ID " +
                     "WHERE r.COMPANY_ID = :companyId " +
                     "ORDER BY r.SUBMITTED_AT DESC";
        Map<String, Object> params = new HashMap<>();
        params.put("companyId", companyId);
        return jdbcTmp.queryForList(sql, params);
    }

    public List<Map<String, Object>> findByCompanyIdAndAgentId(Long companyId, Long agentId) {
        String sql = "SELECT r.RESPONSE_ID, r.QUESTIONNAIRE_ID, r.COMPANY_ID, r.AGENT_ID, " +
                     "r.RESPONSE_DATA, r.SUBMITTED_AT, r.RECORDED_AT, " +
                     "COALESCE(q.NAME,'') QUESTIONNAIRE_NAME, " +
                     "COALESCE(c.NAME,'') COMPANY_NAME " +
                     "FROM response_master r " +
                     "LEFT JOIN questionnaire_master q ON r.QUESTIONNAIRE_ID = q.QUESTIONNAIRE_ID " +
                     "LEFT JOIN company_master c ON r.COMPANY_ID = c.COMPANY_ID " +
                     // An agent sees their own responses AND any response that has no
                     // agent tag (company-shared data, editable by every agent).
                     "WHERE r.COMPANY_ID = :companyId AND (r.AGENT_ID = :agentId OR r.AGENT_ID IS NULL) " +
                     "ORDER BY r.SUBMITTED_AT DESC";
        Map<String, Object> params = new HashMap<>();
        params.put("companyId", companyId);
        params.put("agentId", agentId);
        return jdbcTmp.queryForList(sql, params);
    }

    public List<Map<String, Object>> findByQuestionnaireIdAndCompanyId(Long questionnaireId, Long companyId) {
        String sql = "SELECT r.RESPONSE_ID, r.QUESTIONNAIRE_ID, r.COMPANY_ID, r.AGENT_ID, " +
                     "r.RESPONSE_DATA, r.SUBMITTED_AT, r.RECORDED_AT, " +
                     "COALESCE(a.KEY_VALUE,'') AGENT_KEY, " +
                     "COALESCE(q.NAME,'') QUESTIONNAIRE_NAME, " +
                     "COALESCE(c.NAME,'') COMPANY_NAME " +
                     "FROM response_master r " +
                     "LEFT JOIN questionnaire_master q ON r.QUESTIONNAIRE_ID = q.QUESTIONNAIRE_ID " +
                     "LEFT JOIN company_master c ON r.COMPANY_ID = c.COMPANY_ID " +
                     "LEFT JOIN agent_master a ON r.AGENT_ID = a.AGENT_ID " +
                     "WHERE r.QUESTIONNAIRE_ID = :questionnaireId AND r.COMPANY_ID = :companyId " +
                     "ORDER BY r.SUBMITTED_AT DESC";
        Map<String, Object> params = new HashMap<>();
        params.put("questionnaireId", questionnaireId);
        params.put("companyId", companyId);
        return jdbcTmp.queryForList(sql, params);
    }

    public boolean deleteById(Long id) {
        String sql = "DELETE FROM response_master WHERE RESPONSE_ID = :id";
        Map<String, Object> params = new HashMap<>();
        params.put("id", id);
        return jdbcTmp.update(sql, params) == 1;
    }

    public int deleteByQuestionnaireAndCompany(Long questionnaireId, Long companyId) {
        String sql = "DELETE FROM response_master WHERE QUESTIONNAIRE_ID = :questionnaireId AND COMPANY_ID = :companyId";
        Map<String, Object> params = new HashMap<>();
        params.put("questionnaireId", questionnaireId);
        params.put("companyId", companyId);
        return jdbcTmp.update(sql, params);
    }
}
