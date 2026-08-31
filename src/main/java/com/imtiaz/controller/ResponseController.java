package com.imtiaz.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.imtiaz.config.AppResponse;
import com.imtiaz.model.SecUser;
import com.imtiaz.repo.AgentRepo;
import com.imtiaz.repo.CompanyRepo;
import com.imtiaz.repo.ResponseRepo;
import com.imtiaz.repo.SecUserRepo;

import java.nio.charset.StandardCharsets;
import java.util.*;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("response")
public class ResponseController {

    private static final Logger log = LoggerFactory.getLogger(ResponseController.class);

    @Autowired
    ResponseRepo responseRepo;
    @Autowired
    NamedParameterJdbcTemplate jdbcTmp;
    @Autowired
    CompanyRepo companyRepo;
    @Autowired
    AgentRepo agentRepo;
    @Autowired
    SecUserRepo secUserRepo;

    private Long currentUserId() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth == null || !(auth.getPrincipal() instanceof UserDetails)) {
            return null;
        }
        UserDetails user = (UserDetails) auth.getPrincipal();
        SecUser secUser = secUserRepo.findByUsername(user.getUsername());
        return secUser != null ? secUser.getId() : null;
    }

    private Long currentCompanyId() {
        Long userId = currentUserId();
        if (userId == null) return null;
        Map<String, Object> company = companyRepo.findByUserId(userId);
        return company != null ? ((Number) company.get("COMPANY_ID")).longValue() : null;
    }

    /**
     * POST /response/submit (anonymous - API key auth for Flutter client)
     */
    @RequestMapping(value = "/submit", method = RequestMethod.POST)
    public AppResponse<String> submit(@RequestBody Map<String, Object> request) {
        log.info("POST /response/submit - received submission request");
        try {
            // The company is identified by its secret company key (not a numeric id).
            Object ckObj = request.get("companyKey");
            String companyKey = ckObj instanceof String ? ((String) ckObj).trim() : null;
            Long questionnaireId = parseLong(request.get("questionnaireId"));

            if (companyKey == null || companyKey.isEmpty()) {
                return AppResponse.build(HttpStatus.BAD_REQUEST).message("companyKey is required");
            }
            if (questionnaireId == null) {
                return AppResponse.build(HttpStatus.BAD_REQUEST).message("questionnaireId is required");
            }
            Map<String, Object> company = companyRepo.findByKey(companyKey);
            if (company == null) {
                return AppResponse.build(HttpStatus.BAD_REQUEST).message("Unknown companyKey");
            }
            Object cStateObj = company.get("STATE");
            boolean companyActive = cStateObj instanceof Boolean ? (Boolean) cStateObj
                    : ((Number) cStateObj).intValue() != 0;
            if (!companyActive) {
                return AppResponse.build(HttpStatus.FORBIDDEN).message("Company is inactive");
            }
            Long companyId = ((Number) company.get("COMPANY_ID")).longValue();

            // The agent is identified by its secret agent key (optional). When supplied
            // it is resolved to an agent id and validated (active and belonging to this
            // company); the response is then tagged with that AGENT_ID. When omitted the
            // response is stored company-scoped (AGENT_ID NULL) so it stays visible and
            // editable to every agent ("untagged" shared data). The server never trusts a
            // client-supplied numeric id for ownership.
            Long agentId = null;
            Object agentKeyObj = request.get("agentKey");
            String agentKey = agentKeyObj instanceof String ? ((String) agentKeyObj).trim() : null;
            if (agentKey != null && !agentKey.isEmpty()) {
                Map<String, Object> agent = agentRepo.findByKeyValue(agentKey);
                if (agent == null) {
                    return AppResponse.build(HttpStatus.BAD_REQUEST).message("Invalid agent key");
                }
                Object statusObj = agent.get("STATUS");
                boolean active = statusObj instanceof Boolean ? (Boolean) statusObj
                        : ((Number) statusObj).intValue() != 0;
                if (!active) {
                    return AppResponse.build(HttpStatus.FORBIDDEN).message("Agent is inactive");
                }
                Long aCompany = ((Number) agent.get("COMPANY_ID")).longValue();
                if (!aCompany.equals(companyId)) {
                    return AppResponse.build(HttpStatus.FORBIDDEN)
                            .message("Agent does not belong to this company");
                }
                agentId = ((Number) agent.get("AGENT_ID")).longValue();
            }

            List<Map<String, Object>> responses = (List<Map<String, Object>>) request.get("responses");
            if (responses == null || responses.isEmpty()) {
                return AppResponse.build(HttpStatus.BAD_REQUEST).message("Responses list is required and cannot be empty");
            }

            ObjectMapper mapper = new ObjectMapper();
            int saved = 0;

            for (Map<String, Object> resp : responses) {
                Object answers = resp.get("answers");
                if (answers != null) {
                    String json = (answers instanceof String) ? (String) answers : mapper.writeValueAsString(answers);
                    // Record date = when the interview was actually conducted (mobile local
                    // time). Falls back to the server time if the client didn't send one.
                    java.sql.Timestamp recordedAt = parseRecordedAt(resp.get("recordDate"));
                    responseRepo.save(questionnaireId, companyId, agentId, json, recordedAt);
                    saved++;
                }
            }

            log.info("POST /response/submit - {} response(s) saved successfully", saved);
            return AppResponse.build(HttpStatus.OK).body(saved + " response(s) submitted successfully");

        } catch (Exception ex) {
            log.error("POST /response/submit - error", ex);
            return AppResponse.build(HttpStatus.INTERNAL_SERVER_ERROR).message(ex.getMessage());
        }
    }

    /**
     * GET /response/get/all (authenticated - scoped to user's company)
     */
    @RequestMapping(value = "/get/all", method = RequestMethod.GET)
    public AppResponse<List<Map<String, Object>>> getAll() {
        log.info("GET /response/get/all");
        try {
            Long companyId = currentCompanyId();
            if (companyId == null) {
                return AppResponse.build(HttpStatus.OK).body(java.util.Collections.emptyList());
            }
            List<Map<String, Object>> result = responseRepo.findByCompanyId(companyId);
            log.info("GET /response/get/all - returning {} response(s)", result.size());
            return AppResponse.build(HttpStatus.OK).body(result);
        } catch (Exception ex) {
            log.error("GET /response/get/all - error", ex);
            return AppResponse.build(HttpStatus.INTERNAL_SERVER_ERROR).message(ex.getMessage());
        }
    }

    /**
     * GET /response/get/by-questionnaire (authenticated - scoped to user's company)
     */
    @RequestMapping(value = "/get/by-questionnaire", method = RequestMethod.GET)
    public AppResponse<List<Map<String, Object>>> getByQuestionnaire(@RequestParam("questionnaireId") Long questionnaireId) {
        log.info("GET /response/get/by-questionnaire - questionnaireId={}", questionnaireId);
        try {
            Long companyId = currentCompanyId();
            if (companyId == null) {
                return AppResponse.build(HttpStatus.OK).body(java.util.Collections.emptyList());
            }
            List<Map<String, Object>> result = responseRepo.findByQuestionnaireIdAndCompanyId(questionnaireId, companyId);
            log.info("GET /response/get/by-questionnaire - returning {} response(s)", result.size());
            return AppResponse.build(HttpStatus.OK).body(result);
        } catch (Exception ex) {
            log.error("GET /response/get/by-questionnaire - error", ex);
            return AppResponse.build(HttpStatus.INTERNAL_SERVER_ERROR).message(ex.getMessage());
        }
    }

    /**
     * DELETE /response/delete/{id} (authenticated - scoped to user's company)
     */
    @RequestMapping(value = "/delete/{id}", method = {RequestMethod.POST, RequestMethod.DELETE})
    public AppResponse<String> delete(@PathVariable("id") Long id) {
        log.info("DELETE /response/delete/{}", id);
        try {
            Long companyId = currentCompanyId();
            if (companyId == null) {
                return AppResponse.build(HttpStatus.FORBIDDEN).message("Access denied");
            }
            Map<String, Object> response = responseRepo.findById(id);
            if (response == null) {
                return AppResponse.build(HttpStatus.NOT_FOUND).message("Response not found");
            }
            if (!companyId.equals(response.get("COMPANY_ID"))) {
                return AppResponse.build(HttpStatus.FORBIDDEN).message("Access denied");
            }
            responseRepo.deleteById(id);
            log.info("DELETE /response/delete/{} - deleted", id);
            return AppResponse.build(HttpStatus.OK).body("Response deleted successfully");
        } catch (Exception ex) {
            log.error("DELETE /response/delete/{} - error", id, ex);
            return AppResponse.build(HttpStatus.INTERNAL_SERVER_ERROR).message(ex.getMessage());
        }
    }

    /**
     * POST /response/delete-by-questionnaire (authenticated - scoped to user's company)
     * Clears all stored responses for a questionnaire without deleting the questionnaire itself.
     */
    @RequestMapping(value = "/delete-by-questionnaire", method = RequestMethod.POST)
    public AppResponse<String> deleteByQuestionnaire(@RequestBody Map<String, Object> request) {
        log.info("POST /response/delete-by-questionnaire");
        try {
            Long companyId = currentCompanyId();
            if (companyId == null) {
                return AppResponse.build(HttpStatus.FORBIDDEN).message("Access denied");
            }
            Long questionnaireId = Long.parseLong(request.get("questionnaireId").toString());
            int deleted = responseRepo.deleteByQuestionnaireAndCompany(questionnaireId, companyId);
            log.info("POST /response/delete-by-questionnaire - deleted {} response(s)", deleted);
            return AppResponse.build(HttpStatus.OK).body(deleted + " response(s) cleared successfully");
        } catch (Exception ex) {
            log.error("POST /response/delete-by-questionnaire - error", ex);
            return AppResponse.build(HttpStatus.INTERNAL_SERVER_ERROR).message(ex.getMessage());
        }
    }

    /**
     * GET /response/export/csv?questionnaireId=... (authenticated - scoped to user's company)
     * Exports all responses for a questionnaire as a CSV download.
     */
    @RequestMapping(value = "/export/csv", method = RequestMethod.GET)
    public ResponseEntity<byte[]> exportCsv(@RequestParam("questionnaireId") Long questionnaireId) {
        log.info("GET /response/export/csv - questionnaireId={}", questionnaireId);
        try {
            Long companyId = currentCompanyId();
            if (companyId == null) {
                return new ResponseEntity<>(HttpStatus.FORBIDDEN);
            }
            Map<String, Object> q = jdbcTmp.queryForList(
                    "SELECT COMPANY_ID, NAME FROM questionnaire_master WHERE QUESTIONNAIRE_ID = :qid",
                    Collections.singletonMap("qid", questionnaireId)).stream().findFirst().orElse(null);
            if (q == null || !companyId.equals(((Number) q.get("COMPANY_ID")).longValue())) {
                return new ResponseEntity<>(HttpStatus.FORBIDDEN);
            }
            String qName = q.get("NAME") != null ? q.get("NAME").toString() : "";
            String slug = toSlug(qName);

            List<Map<String, Object>> rows = responseRepo.findByQuestionnaireIdAndCompanyId(questionnaireId, companyId);

            List<String> qnames = new ArrayList<>();
            Map<String, Object> cfgRow = jdbcTmp.queryForList(
                    "SELECT CONF_DATA FROM questionnaire_master WHERE QUESTIONNAIRE_ID = :qid",
                    Collections.singletonMap("qid", questionnaireId)).stream().findFirst().orElse(null);
            if (cfgRow != null && cfgRow.get("CONF_DATA") != null) {
                ObjectMapper mapper = new ObjectMapper();
                Map<String, Map<String, Object>> conf = mapper.readValue(cfgRow.get("CONF_DATA").toString(), Map.class);
                List<String> keys = new ArrayList<>(conf.keySet());
                keys.sort((a, b) -> num(a) - num(b));
                for (String k : keys) {
                    Map<String, Object> qq = conf.get(k);
                    String qn = qq != null && qq.get("qname") != null ? qq.get("qname").toString() : k;
                    qnames.add(qn);
                }
            }

            List<String> header = new ArrayList<>();
            header.add("Agent Key");
            header.add("Record Date");
            header.add("Submitted At");
            header.addAll(qnames);

            StringBuilder sb = new StringBuilder();
            sb.append(csvLine(header)).append("\n");
            ObjectMapper dataMapper = new ObjectMapper();
            for (Map<String, Object> row : rows) {
                List<String> line = new ArrayList<>();
                line.add(str(row.get("AGENT_KEY")));
                line.add(str(row.get("RECORDED_AT")));
                line.add(str(row.get("SUBMITTED_AT")));
                Map<String, Object> data = new HashMap<>();
                if (row.get("RESPONSE_DATA") != null) {
                    try {
                        data = dataMapper.readValue(row.get("RESPONSE_DATA").toString(), Map.class);
                    } catch (Exception ignore) {
                    }
                }
                for (String qn : qnames) {
                    Object v = data.get(qn);
                    line.add(v == null ? "" : v.toString());
                }
                sb.append(csvLine(line)).append("\n");
            }

            byte[] bytes = sb.toString().getBytes(StandardCharsets.UTF_8);
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.parseMediaType("text/csv"));
            headers.setContentDispositionFormData("attachment", (slug.isEmpty() ? "questionnaire" : slug) + ".csv");
            log.info("GET /response/export/csv - returned {} row(s)", rows.size());
            return new ResponseEntity<>(bytes, headers, HttpStatus.OK);
        } catch (Exception ex) {
            log.error("GET /response/export/csv - error", ex);
            return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }


    // Private helper to clean up null-safe Long parsing
    /**
     * Parses the mobile-supplied record date (ISO local timestamp) into a JDBC
     * Timestamp. Falls back to the server's current time when missing/invalid.
     */
    private java.sql.Timestamp parseRecordedAt(Object value) {
        if (value != null) {
            String s = value.toString().trim();
            if (!s.isEmpty()) {
                try {
                    String ts = s.replace('T', ' ');
                    int dot = ts.indexOf('.');
                    if (dot >= 0) {
                        int end = Math.min(ts.length(), dot + 4); // keep 3 fractional digits
                        ts = ts.substring(0, end);
                    }
                    return java.sql.Timestamp.valueOf(ts);
                } catch (Exception ignore) {
                    // fall through to the default below
                }
            }
        }
        return new java.sql.Timestamp(System.currentTimeMillis());
    }

    private Long parseLong(Object obj) {
        return Optional.ofNullable(obj)
                .map(Object::toString)
                .map(String::trim)
                .filter(s -> !s.isEmpty())
                .map(s -> {
                    try {
                        return Long.valueOf(s);
                    } catch (NumberFormatException e) {
                        return null;
                    }
                })
                .orElse(null);
    }

    /**
     * GET /response/public/by-company?companyKey=...&agentKey=... (anonymous)
     * Loads responses owned by the company identified by its secret company key,
     * optionally narrowed to a single agent when an agent key is supplied. Used by
     * the mobile client to pull its own data (local-first: the app displays local
     * data and only calls this on an explicit Load). The company key and (optional)
     * agent key are validated; the agent key must be active and belong to the
     * company. When no agent key is supplied all of the company's responses are
     * returned (admin/company-wide view).
     */
    @RequestMapping(value = "/public/by-company", method = RequestMethod.GET)
    public AppResponse<List<Map<String, Object>>> getPublicByCompany(
            @RequestParam("companyKey") String companyKey,
            @RequestParam(value = "agentKey", required = false) String agentKey) {
        try {
            Map<String, Object> company = companyRepo.findByKey(companyKey == null ? "" : companyKey.trim());
            if (company == null) {
                return AppResponse.build(HttpStatus.BAD_REQUEST).message("Unknown companyKey");
            }
            Object stateObj = company.get("STATE");
            boolean companyActive = stateObj instanceof Boolean ? (Boolean) stateObj
                    : ((Number) stateObj).intValue() != 0;
            if (!companyActive) {
                return AppResponse.build(HttpStatus.FORBIDDEN).message("Company is inactive");
            }
            Long companyId = ((Number) company.get("COMPANY_ID")).longValue();

            Long resolvedAgentId = null;
            if (agentKey != null && !agentKey.trim().isEmpty()) {
                Map<String, Object> agent = agentRepo.findByKeyValue(agentKey.trim());
                if (agent == null) {
                    return AppResponse.build(HttpStatus.BAD_REQUEST).message("Invalid agent key");
                }
                Object statusObj = agent.get("STATUS");
                boolean active = statusObj instanceof Boolean ? (Boolean) statusObj
                        : ((Number) statusObj).intValue() != 0;
                if (!active) {
                    return AppResponse.build(HttpStatus.FORBIDDEN).message("Agent is inactive");
                }
                Long aCompany = ((Number) agent.get("COMPANY_ID")).longValue();
                if (!aCompany.equals(companyId)) {
                    return AppResponse.build(HttpStatus.FORBIDDEN)
                            .message("Agent does not belong to this company");
                }
                resolvedAgentId = ((Number) agent.get("AGENT_ID")).longValue();
            }

            List<Map<String, Object>> rows = (resolvedAgentId != null)
                    ? responseRepo.findByCompanyIdAndAgentId(companyId, resolvedAgentId)
                    : responseRepo.findByCompanyId(companyId);
            return AppResponse.build(HttpStatus.OK).body(rows);
        } catch (Exception ex) {
            log.error("GET /response/public/by-company - error", ex);
            return AppResponse.build(HttpStatus.INTERNAL_SERVER_ERROR).message(ex.getMessage());
        }
    }

    private static int num(String s) {
        String d = s.replaceAll("\\D+", "");
        return d.isEmpty() ? 0 : Integer.parseInt(d);
    }

    private static String csvLine(List<String> cells) {
        StringBuilder b = new StringBuilder();
        for (int i = 0; i < cells.size(); i++) {
            if (i > 0) {
                b.append(",");
            }
            String c = cells.get(i) == null ? "" : cells.get(i);
            if (c.indexOf('"') >= 0 || c.indexOf(',') >= 0 || c.indexOf('\n') >= 0 || c.indexOf('\r') >= 0) {
                c = "\"" + c.replace("\"", "\"\"") + "\"";
            }
            b.append(c);
        }
        return b.toString();
    }

    private static String str(Object value) {
        return value == null ? "" : value.toString();
    }

    // Build a safe lowercase filename stem from a questionnaire name:
    // lowercases, replaces whitespace with underscores, strips anything that
    // is not a letter/digit/underscore, and collapses repeated/leading/trailing underscores.
    private static String toSlug(String name) {
        if (name == null) {
            return "";
        }
        String s = name.toLowerCase().trim()
                .replaceAll("\\s+", "_")
                .replaceAll("[^a-z0-9_]", "")
                .replaceAll("_+", "_")
                .replaceAll("^_|_$", "");
        return s;
    }
}
