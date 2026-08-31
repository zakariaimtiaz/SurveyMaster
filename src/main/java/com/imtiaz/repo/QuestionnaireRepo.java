package com.imtiaz.repo;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Repository;

/**
 *
 * @author Imtiaz
 */
@Repository
public class QuestionnaireRepo {

    @Autowired
    NamedParameterJdbcTemplate jdbcTmp;

    /**
     *
     * @param questionnaire
     * @return
     */
    public boolean saveQuestionnaire(Map<String, Object> questionnaire) {
        StringBuilder sql = new StringBuilder();
        sql.append(" INSERT INTO questionnaire_master( NAME, CAPTION, DESCRIPTION, COMPANY_ID, PUBLISHED, VERSION ) ");
        sql.append(" VALUES ( :name, :caption, :description, :companyId, :published, :version ) ");

        Map<String, Object> params = new HashMap<>();
        params.put("name", questionnaire.get("name"));
        params.put("caption", questionnaire.get("caption"));
        params.put("description", questionnaire.get("description"));
        params.put("companyId", questionnaire.get("companyId"));
        // New questionnaires are created unpublished; the user publishes them later.
        params.put("published", 0);
        params.put("version", "");
        return jdbcTmp.update(sql.toString(), params) == 1;
    }

    /**
     *
     * @param jsonObject
     * @param questionnaireId
     * @return
     */
    public boolean updateQuestionnaireConfigData(String jsonData, Long questionnaireId) {

        StringBuilder sql = new StringBuilder();
        sql.append(" UPDATE questionnaire_master SET CONF_DATA = :config_data ");
        sql.append(" WHERE questionnaire_id = :questionnaire_id ");

        Map<String, Object> params = new HashMap<>();
        params.put("config_data", jsonData);
        params.put("questionnaire_id", questionnaireId);
        return jdbcTmp.update(sql.toString(), params) == 1;
    }

    /**
     *
     * @param questionnaireId
     * @param name
     * @param caption
     * @param description
     * @return
     */
    public boolean updateDetails(Long questionnaireId, String name, String caption, String description,
            Integer published, String version) {
        StringBuilder sql = new StringBuilder();
        sql.append(" UPDATE questionnaire_master SET NAME = :name, CAPTION = :caption, DESCRIPTION = :description ");
        if (published != null) {
            sql.append(", PUBLISHED = :published ");
        }
        if (version != null) {
            sql.append(", VERSION = :version ");
        }
        sql.append(" WHERE questionnaire_id = :questionnaire_id ");

        Map<String, Object> params = new HashMap<>();
        params.put("name", name);
        params.put("caption", caption);
        params.put("description", description);
        if (published != null) {
            params.put("published", published);
        }
        if (version != null) {
            params.put("version", version);
        }
        params.put("questionnaire_id", questionnaireId);
        return jdbcTmp.update(sql.toString(), params) == 1;
    }

    /**
     *
     * @param questionnaireId
     * @param state 1 = active, 0 = inactive
     * @return
     */
    public boolean updateState(Long questionnaireId, int state) {
        StringBuilder sql = new StringBuilder();
        sql.append(" UPDATE questionnaire_master SET STATE = :state ");
        sql.append(" WHERE questionnaire_id = :questionnaire_id ");

        Map<String, Object> params = new HashMap<>();
        params.put("state", state);
        params.put("questionnaire_id", questionnaireId);
        return jdbcTmp.update(sql.toString(), params) == 1;
    }

    /**
     *
     * @param questionnaireId
     * @param published 1 = published, 0 = unpublished
     * @return
     */
    public boolean updatePublished(Long questionnaireId, int published) {
        StringBuilder sql = new StringBuilder();
        sql.append(" UPDATE questionnaire_master SET PUBLISHED = :published ");
        sql.append(" WHERE questionnaire_id = :questionnaire_id ");

        Map<String, Object> params = new HashMap<>();
        params.put("published", published);
        params.put("questionnaire_id", questionnaireId);
        return jdbcTmp.update(sql.toString(), params) == 1;
    }

    /**
     *
     * @param questionnaireId
     * @return
     */
    public boolean deleteById(Long questionnaireId) {
        StringBuilder sql = new StringBuilder();
        sql.append(" DELETE FROM questionnaire_master ");
        sql.append(" WHERE questionnaire_id = :questionnaire_id ");

        Map<String, Object> params = new HashMap<>();
        params.put("questionnaire_id", questionnaireId);
        return jdbcTmp.update(sql.toString(), params) == 1;
    }

    /**
     *
     * @param questionnaireId
     * @return map of columns or null when not found
     */
    public Map<String, Object> findByQuestionnaireId(Long questionnaireId) {
        StringBuilder sql = new StringBuilder();
        sql.append(" SELECT q.QUESTIONNAIRE_ID, q.NAME, q.CAPTION, q.CONF_DATA, COALESCE(q.DESCRIPTION,'') DESCRIPTION, q.COMPANY_ID, ");
        sql.append(" COALESCE(q.STATE,1) STATE, COALESCE(q.PUBLISHED,1) PUBLISHED, COALESCE(q.VERSION,'') VERSION, ");
        sql.append(" COALESCE(c.NAME,'') COMPANY_NAME ");
        sql.append(" FROM questionnaire_master q ");
        sql.append(" LEFT JOIN company_master c ON q.COMPANY_ID = c.COMPANY_ID ");
        sql.append(" WHERE q.questionnaire_id = :questionnaire_id ");

        Map<String, Object> params = new HashMap<>();
        params.put("questionnaire_id", questionnaireId);

        List<Map<String, Object>> rows = jdbcTmp.queryForList(sql.toString(), params);
        return rows.isEmpty() ? null : rows.get(0);
    }

    /**
     *
     * @return
     */
    public List<Map<String, Object>> findAllQuestionnaire() {
        StringBuilder sql = new StringBuilder();
        sql.append(" SELECT q.QUESTIONNAIRE_ID, q.NAME, q.CAPTION, COALESCE(q.DESCRIPTION,'') DESCRIPTION, q.COMPANY_ID, ");
        sql.append(" COALESCE(q.STATE,1) STATE, ");
        sql.append(" COALESCE(c.NAME,'') COMPANY_NAME ");
        sql.append(" FROM questionnaire_master q ");
        sql.append(" LEFT JOIN company_master c ON q.COMPANY_ID = c.COMPANY_ID ");
        sql.append(" ORDER BY q.QUESTIONNAIRE_ID DESC ");
        Map<String, Object> params = new HashMap<>();
        return jdbcTmp.queryForList(sql.toString(), params);
    }

    public List<Map<String, Object>> findByCompanyId(Long companyId) {
        StringBuilder sql = new StringBuilder();
        sql.append(" SELECT q.QUESTIONNAIRE_ID, q.NAME, q.CAPTION, COALESCE(q.DESCRIPTION,'') DESCRIPTION, q.COMPANY_ID, ");
        sql.append(" COALESCE(q.STATE,1) STATE, COALESCE(q.PUBLISHED,1) PUBLISHED, COALESCE(q.VERSION,'') VERSION, ");
        sql.append(" COALESCE(c.NAME,'') COMPANY_NAME ");
        sql.append(" FROM questionnaire_master q ");
        sql.append(" LEFT JOIN company_master c ON q.COMPANY_ID = c.COMPANY_ID ");
        sql.append(" WHERE q.COMPANY_ID = :companyId AND q.STATE = 1 AND q.PUBLISHED = 1 ");
        sql.append(" ORDER BY q.QUESTIONNAIRE_ID DESC ");
        Map<String, Object> params = new HashMap<>();
        params.put("companyId", companyId);
        return jdbcTmp.queryForList(sql.toString(), params);
    }

    /**
     * Admin listing: only active questionnaires.
     * @return
     */
    public List<Map<String, Object>> findActiveQuestionnaire() {
        StringBuilder sql = new StringBuilder();
        sql.append(" SELECT q.QUESTIONNAIRE_ID, q.NAME, q.CAPTION, COALESCE(q.DESCRIPTION,'') DESCRIPTION, q.COMPANY_ID, ");
        sql.append(" COALESCE(q.STATE,1) STATE, ");
        sql.append(" COALESCE(c.NAME,'') COMPANY_NAME ");
        sql.append(" FROM questionnaire_master q ");
        sql.append(" LEFT JOIN company_master c ON q.COMPANY_ID = c.COMPANY_ID ");
        sql.append(" WHERE q.STATE = 1 ");
        sql.append(" ORDER BY q.QUESTIONNAIRE_ID DESC ");
        Map<String, Object> params = new HashMap<>();
        return jdbcTmp.queryForList(sql.toString(), params);
    }

    /**
     * All questionnaires for a company (web listing). No PUBLISHED/STATE filter
     * so the user can see, edit, publish/unpublish every questionnaire they own.
     */
    public List<Map<String, Object>> findAllByCompanyId(Long companyId) {
        StringBuilder sql = new StringBuilder();
        sql.append(" SELECT q.QUESTIONNAIRE_ID, q.NAME, q.CAPTION, COALESCE(q.DESCRIPTION,'') DESCRIPTION, q.COMPANY_ID, ");
        sql.append(" COALESCE(q.STATE,1) STATE, COALESCE(q.PUBLISHED,1) PUBLISHED, COALESCE(q.VERSION,'') VERSION, ");
        sql.append(" COALESCE(c.NAME,'') COMPANY_NAME ");
        sql.append(" FROM questionnaire_master q ");
        sql.append(" LEFT JOIN company_master c ON q.COMPANY_ID = c.COMPANY_ID ");
        sql.append(" WHERE q.COMPANY_ID = :companyId ");
        sql.append(" ORDER BY q.QUESTIONNAIRE_ID DESC ");
        Map<String, Object> params = new HashMap<>();
        params.put("companyId", companyId);
        return jdbcTmp.queryForList(sql.toString(), params);
    }
}
