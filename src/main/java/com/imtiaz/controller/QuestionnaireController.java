package com.imtiaz.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.SerializationFeature;
import com.google.zxing.BarcodeFormat;
import com.google.zxing.EncodeHintType;
import com.google.zxing.common.BitMatrix;
import com.google.zxing.qrcode.QRCodeWriter;
import com.google.zxing.client.j2se.MatrixToImageWriter;
import com.imtiaz.config.AppProperty;
import com.imtiaz.config.AppResponse;
import com.imtiaz.model.SecUser;
import com.imtiaz.repo.CompanyRepo;
import com.imtiaz.repo.QuestionnaireRepo;
import com.imtiaz.repo.SecUserRepo;

import java.io.ByteArrayOutputStream;
import java.util.Base64;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.ModelAndView;

@RestController
@RequestMapping("questionnaire")
public class QuestionnaireController extends AppProperty {

    private static final Logger log = LoggerFactory.getLogger(QuestionnaireController.class);

    @Autowired
    QuestionnaireRepo questionnaireRepo;
    @Autowired
    CompanyRepo companyRepo;
    @Autowired
    SecUserRepo secUserRepo;

    private Boolean isCurrentUserAdmin(){
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth == null || !(auth.getPrincipal() instanceof UserDetails)) {
            return null;
        }
        return auth.getAuthorities().stream()
                .anyMatch(a -> a.getAuthority().equals("ROLE_ADMIN"));
    }

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

    @GetMapping("/get/all")
    public AppResponse<List<Map<String, Object>>> index() {
        log.info("GET /questionnaire/get/all");
        try {
            if (isCurrentUserAdmin()) {
                return AppResponse.build(HttpStatus.OK).body(questionnaireRepo.findActiveQuestionnaire());
            }

            Long companyId = currentCompanyId();
            List<Map<String, Object>> result = (companyId != null)
                    ? questionnaireRepo.findAllByCompanyId(companyId)
                    : Collections.emptyList();

            return AppResponse.build(HttpStatus.OK).body(result);
        } catch (Exception ex) {
            log.error("Failed to fetch questionnaires", ex);
            return AppResponse.build(HttpStatus.INTERNAL_SERVER_ERROR).message(ex.getMessage());
        }
    }

    @RequestMapping(value = "/list", method = RequestMethod.GET)
    public ModelAndView list() {
        return new ModelAndView("questionnaire_list");
    }

    @RequestMapping(value = "/all", method = RequestMethod.GET)
    public ModelAndView all() {
        return new ModelAndView("admin_questionnaires");
    }

    @RequestMapping(value = "/create", method = RequestMethod.POST)
    public AppResponse<String> create(@RequestBody Map<String, Object> request) {
        try {
            Long companyId = currentCompanyId();
            if (companyId == null) {
                return AppResponse.build(HttpStatus.BAD_REQUEST)
                        .message("You must create a company before creating questionnaires");
            }
            Map<String, Object> questionnaire = new HashMap<>();
            questionnaire.put("name", str(request.get("name")));
            questionnaire.put("caption", str(request.get("caption")));
            questionnaire.put("description", str(request.get("description")));
            questionnaire.put("companyId", companyId);

            if (questionnaire.get("name").toString().trim().isEmpty()) {
                return AppResponse.build(HttpStatus.BAD_REQUEST).message("Name is required");
            }

            boolean saved = questionnaireRepo.saveQuestionnaire(questionnaire);
            if (saved) {
                return AppResponse.build(HttpStatus.OK).body("Questionnaire created successfully");
            }
            return AppResponse.build(HttpStatus.INTERNAL_SERVER_ERROR).message("Could not create questionnaire");
        } catch (Exception ex) {
            return AppResponse.build(HttpStatus.INTERNAL_SERVER_ERROR).message(ex.getMessage());
        }
    }

    @RequestMapping(value = "/update-details", method = RequestMethod.POST)
    public AppResponse<String> updateDetails(@RequestBody Map<String, Object> request) {
        try {
            Long companyId = currentCompanyId();
            if (companyId == null) {
                return AppResponse.build(HttpStatus.FORBIDDEN).message("Access denied");
            }
            Long id = Long.parseLong(request.get("id").toString());
            Map<String, Object> q = questionnaireRepo.findByQuestionnaireId(id);
            if (q == null) {
                return AppResponse.build(HttpStatus.NOT_FOUND).message("Questionnaire not found");
            }
            if (!companyId.equals(q.get("COMPANY_ID"))) {
                return AppResponse.build(HttpStatus.FORBIDDEN).message("Access denied");
            }
            String name = str(request.get("name"));
            if (name.trim().isEmpty()) {
                return AppResponse.build(HttpStatus.BAD_REQUEST).message("Name is required");
            }
            String version = str(request.get("version")).trim();
            Integer published = null;
            String publishedStr = str(request.get("published")).trim();
            if (!publishedStr.isEmpty()) {
                published = "1".equals(publishedStr) || "true".equalsIgnoreCase(publishedStr) ? 1 : 0;
            }
            boolean updated = questionnaireRepo.updateDetails(id, name, str(request.get("caption")),
                    str(request.get("description")), published, version);

            String stateStr = str(request.get("state")).trim();
            if (!stateStr.isEmpty()) {
                int state = "0".equals(stateStr) ? 0 : 1;
                questionnaireRepo.updateState(id, state);
            }

            if (updated) {
                return AppResponse.build(HttpStatus.OK).body("Questionnaire updated successfully");
            }
            return AppResponse.build(HttpStatus.INTERNAL_SERVER_ERROR).message("Could not update questionnaire");
        } catch (Exception ex) {
            return AppResponse.build(HttpStatus.INTERNAL_SERVER_ERROR).message(ex.getMessage());
        }
    }

    @RequestMapping(value = "/update-state", method = RequestMethod.POST)
    public AppResponse<String> updateState(@RequestBody Map<String, Object> request) {
        try {
            Long id = Long.parseLong(request.get("id").toString());
            Map<String, Object> q = questionnaireRepo.findByQuestionnaireId(id);
            if (q == null) {
                return AppResponse.build(HttpStatus.NOT_FOUND).message("Questionnaire not found");
            }
            Long companyId = currentCompanyId();
            if (companyId == null || !companyId.equals(q.get("COMPANY_ID"))) {
                return AppResponse.build(HttpStatus.FORBIDDEN).message("Access denied");
            }
            int state = "0".equals(str(request.get("state")).trim()) ? 0 : 1;
            boolean updated = questionnaireRepo.updateState(id, state);
            if (updated) {
                return AppResponse.build(HttpStatus.OK).body("State updated to " + (state == 1 ? "active" : "inactive"));
            }
            return AppResponse.build(HttpStatus.INTERNAL_SERVER_ERROR).message("Could not update state");
        } catch (Exception ex) {
            return AppResponse.build(HttpStatus.INTERNAL_SERVER_ERROR).message(ex.getMessage());
        }
    }

    @RequestMapping(value = "/update-published", method = RequestMethod.POST)
    public AppResponse<String> updatePublished(@RequestBody Map<String, Object> request) {
        try {
            Long id = Long.parseLong(request.get("id").toString());
            Map<String, Object> q = questionnaireRepo.findByQuestionnaireId(id);
            if (q == null) {
                return AppResponse.build(HttpStatus.NOT_FOUND).message("Questionnaire not found");
            }
            Long companyId = currentCompanyId();
            if (companyId == null || !companyId.equals(q.get("COMPANY_ID"))) {
                return AppResponse.build(HttpStatus.FORBIDDEN).message("Access denied");
            }
            int published = "0".equals(str(request.get("published")).trim()) ? 0 : 1;
            boolean updated = questionnaireRepo.updatePublished(id, published);
            if (updated) {
                return AppResponse.build(HttpStatus.OK).body("Questionnaire " + (published == 1 ? "published" : "unpublished") + " successfully");
            }
            return AppResponse.build(HttpStatus.INTERNAL_SERVER_ERROR).message("Could not update published state");
        } catch (Exception ex) {
            return AppResponse.build(HttpStatus.INTERNAL_SERVER_ERROR).message(ex.getMessage());
        }
    }

    @RequestMapping(value = "/delete/{id}", method = {RequestMethod.POST, RequestMethod.DELETE})
    public AppResponse<String> delete(@PathVariable("id") Long id) {
        try {
            Long companyId = currentCompanyId();
            if (companyId == null) {
                return AppResponse.build(HttpStatus.FORBIDDEN).message("Access denied");
            }
            Map<String, Object> q = questionnaireRepo.findByQuestionnaireId(id);
            if (q == null) {
                return AppResponse.build(HttpStatus.NOT_FOUND).message("Questionnaire not found");
            }
            if (!companyId.equals(q.get("COMPANY_ID"))) {
                return AppResponse.build(HttpStatus.FORBIDDEN).message("Access denied");
            }
            boolean deleted = questionnaireRepo.deleteById(id);
            if (deleted) {
                return AppResponse.build(HttpStatus.OK).body("Questionnaire deleted successfully");
            }
            return AppResponse.build(HttpStatus.NOT_FOUND).message("Questionnaire not found");
        } catch (Exception ex) {
            return AppResponse.build(HttpStatus.INTERNAL_SERVER_ERROR).message(ex.getMessage());
        }
    }

    @RequestMapping(value = "/get/config/{id}", method = RequestMethod.GET)
    public AppResponse<String> getConfig(@PathVariable("id") Long id) {
        log.info("GET /questionnaire/get/config/{}", id);
        try {
            Long companyId = currentCompanyId();
            if (companyId == null) {
                return AppResponse.build(HttpStatus.FORBIDDEN).message("Access denied");
            }
            Map<String, Object> result = questionnaireRepo.findByQuestionnaireId(id);
            if (result == null) {
                log.warn("GET /questionnaire/get/config/{} - not found", id);
                return AppResponse.build(HttpStatus.NOT_FOUND).message("Questionnaire not found");
            }
            if (!companyId.equals(result.get("COMPANY_ID"))) {
                return AppResponse.build(HttpStatus.FORBIDDEN).message("Access denied");
            }
            Object confData = result.get("CONF_DATA");
            String config = confData == null ? "{}" : confData.toString();
            if (config.trim().isEmpty()) {
                config = "{}";
            }
            return AppResponse.build(HttpStatus.OK).body(config);
        } catch (Exception ex) {
            return AppResponse.build(HttpStatus.INTERNAL_SERVER_ERROR).message(ex.getMessage());
        }
    }

    // --- Public, QR-scoped endpoints for the Flutter offline client ---
    // These require no login. Access is gated by the companyId + companyKey pair
    // that is embedded in the company QR code generated by the web app.

    @RequestMapping(value = "/public/by-company/{companyId}", method = RequestMethod.GET)
    public AppResponse<List<Map<String, Object>>> publicByCompany(
            @PathVariable("companyId") Long companyId,
            @RequestParam(value = "companyKey", required = false) String companyKey) {
        log.info("GET /questionnaire/public/by-company/{}", companyId);
        try {
            Map<String, Object> company = companyRepo.findById(companyId);
            if (company == null) {
                return AppResponse.build(HttpStatus.NOT_FOUND).message("Company not found");
            }
            if (!isCompanyKeyValid(company, companyKey)) {
                return AppResponse.build(HttpStatus.FORBIDDEN).message("Invalid company key");
            }
            Object stateObj = company.get("STATE");
            boolean companyActive = stateObj instanceof Boolean ? (Boolean) stateObj
                    : ((Number) stateObj).intValue() != 0;
            if (!companyActive) {
                return AppResponse.build(HttpStatus.FORBIDDEN).message("Company is inactive");
            }
            List<Map<String, Object>> result = questionnaireRepo.findByCompanyId(companyId);
            return AppResponse.build(HttpStatus.OK).body(result);
        } catch (Exception ex) {
            log.error("GET /questionnaire/public/by-company/{} failed", companyId, ex);
            return AppResponse.build(HttpStatus.INTERNAL_SERVER_ERROR).message(ex.getMessage());
        }
    }

    @RequestMapping(value = "/public/config/{id}", method = RequestMethod.GET)
    public AppResponse<String> publicConfig(
            @PathVariable("id") Long id,
            @RequestParam("companyId") Long companyId,
            @RequestParam(value = "companyKey", required = false) String companyKey) {
        log.info("GET /questionnaire/public/config/{}", id);
        try {
            Map<String, Object> company = companyRepo.findById(companyId);
            if (company == null) {
                return AppResponse.build(HttpStatus.NOT_FOUND).message("Company not found");
            }
            if (!isCompanyKeyValid(company, companyKey)) {
                return AppResponse.build(HttpStatus.FORBIDDEN).message("Invalid company key");
            }
            Map<String, Object> result = questionnaireRepo.findByQuestionnaireId(id);
            if (result == null) {
                return AppResponse.build(HttpStatus.NOT_FOUND).message("Questionnaire not found");
            }
            if (!companyId.equals(result.get("COMPANY_ID"))) {
                return AppResponse.build(HttpStatus.FORBIDDEN).message("Access denied");
            }
            Object companyStateObj = company.get("STATE");
            boolean companyActive = companyStateObj instanceof Boolean ? (Boolean) companyStateObj
                    : ((Number) companyStateObj).intValue() != 0;
            if (!companyActive) {
                return AppResponse.build(HttpStatus.FORBIDDEN).message("Company is inactive");
            }
            Object qStateObj = result.get("STATE");
            boolean qActive = qStateObj instanceof Boolean ? (Boolean) qStateObj
                    : ((Number) qStateObj).intValue() != 0;
            Object qPubObj = result.get("PUBLISHED");
            boolean qPublished = qPubObj instanceof Boolean ? (Boolean) qPubObj
                    : ((Number) qPubObj).intValue() != 0;
            if (!qActive || !qPublished) {
                return AppResponse.build(HttpStatus.NOT_FOUND)
                        .message("Questionnaire is not available");
            }
            Object confData = result.get("CONF_DATA");
            String config = confData == null ? "{}" : confData.toString();
            if (config.trim().isEmpty()) {
                config = "{}";
            }
            return AppResponse.build(HttpStatus.OK).body(config);
        } catch (Exception ex) {
            log.error("GET /questionnaire/public/config/{} failed", id, ex);
            return AppResponse.build(HttpStatus.INTERNAL_SERVER_ERROR).message(ex.getMessage());
        }
    }

    private boolean isCompanyKeyValid(Map<String, Object> company, String companyKey) {
        String expected = company.get("COMPANY_KEY") == null ? "" : company.get("COMPANY_KEY").toString().trim();
        if (expected.isEmpty()) {
            // Company has no key set -> open access.
            return true;
        }
        return companyKey != null && expected.equals(companyKey.trim());
    }

    @RequestMapping(value = "/get/details/{id}", method = RequestMethod.GET)
    public ModelAndView findQuestionnaire(@PathVariable("id") Long id) {
        Map<String, Object> result = questionnaireRepo.findByQuestionnaireId(id);
        if (result == null) {
            return new ModelAndView("redirect:/");
        }
        Long companyId = currentCompanyId();
        if (companyId == null || !companyId.equals(result.get("COMPANY_ID"))) {
            return new ModelAndView("redirect:/");
        }
        return new ModelAndView("questionnaire")
                .addObject("QUESTIONNAIRE_ID", result.get("QUESTIONNAIRE_ID"))
                .addObject("NAME", result.get("NAME"))
                .addObject("CAPTION", result.get("CAPTION"))
                .addObject("CONF_DATA", "")
                .addObject("DESCRIPTION", result.get("DESCRIPTION"));
    }

    @RequestMapping(value = "/edit/{id}", method = RequestMethod.GET)
    public ModelAndView editQuestionnaire(@PathVariable("id") Long id) {
        Map<String, Object> result = questionnaireRepo.findByQuestionnaireId(id);
        if (result == null) {
            return new ModelAndView("redirect:/");
        }
        Long companyId = currentCompanyId();
        if (companyId == null || !companyId.equals(result.get("COMPANY_ID"))) {
            return new ModelAndView("redirect:/");
        }
        return new ModelAndView("questionnaire_edit")
                .addObject("QUESTIONNAIRE_ID", result.get("QUESTIONNAIRE_ID"))
                .addObject("NAME", result.get("NAME"))
                .addObject("CAPTION", result.get("CAPTION"))
                .addObject("DESCRIPTION", result.get("DESCRIPTION"))
                .addObject("STATE", result.get("STATE"))
                .addObject("PUBLISHED", result.get("PUBLISHED"))
                .addObject("VERSION", result.get("VERSION"));
    }

    @RequestMapping(value = "/update-config", method = RequestMethod.POST)
    public AppResponse<String> saveUpdateConfigData(@RequestBody Map<String, Object> request) {
        try {
            Long companyId = currentCompanyId();
            if (companyId == null) {
                return AppResponse.build(HttpStatus.FORBIDDEN).message("Access denied");
            }
            Long questionnaireId = Long.parseLong(request.get("id").toString());
            Map<String, Object> q = questionnaireRepo.findByQuestionnaireId(questionnaireId);
            if (q == null) {
                return AppResponse.build(HttpStatus.NOT_FOUND).message("Questionnaire not found");
            }
            if (!companyId.equals(q.get("COMPANY_ID"))) {
                return AppResponse.build(HttpStatus.FORBIDDEN).message("Access denied");
            }
            ObjectMapper mapper = new ObjectMapper();
            mapper.enable(SerializationFeature.ORDER_MAP_ENTRIES_BY_KEYS);
            String json = mapper.writeValueAsString(request.get("question"));
            boolean saved = questionnaireRepo.updateQuestionnaireConfigData(json, questionnaireId);
            if (saved) {
                return AppResponse.build(HttpStatus.OK).body("Configuration saved successfully");
            }
            return AppResponse.build(HttpStatus.INTERNAL_SERVER_ERROR).message("Could not save configuration");
        } catch (Exception ex) {
            return AppResponse.build(HttpStatus.INTERNAL_SERVER_ERROR).message(ex.getMessage());
        }
    }

    // --- Per-questionnaire QR Code (shareable descriptor for the Flutter client) ---

    @RequestMapping(value = "/{id}/qrcode", method = RequestMethod.GET)
    public void downloadQuestionnaireQR(@PathVariable("id") Long id, HttpServletRequest request, HttpServletResponse response) {
        try {
            Long companyId = currentCompanyId();
            if (companyId == null) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN, "Not authenticated");
                return;
            }
            Map<String, Object> q = questionnaireRepo.findByQuestionnaireId(id);
            if (q == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Questionnaire not found");
                return;
            }
            if (!companyId.equals(q.get("COMPANY_ID"))) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied");
                return;
            }
            String baseUrl = resolveBaseUrl(request);
            String qrContent = "{\"url\":\"" + baseUrl + "\",\"questionnaireId\":" + id + ",\"type\":\"questionnaire\"}";
            BitMatrix bitMatrix = generateQRBitMatrix(qrContent);
            response.setContentType("image/png");
            response.setHeader("Content-Disposition", "attachment; filename=\"questionnaire_" + id + "_qr.png\"");
            MatrixToImageWriter.writeToStream(bitMatrix, "PNG", response.getOutputStream());
        } catch (Exception ex) {
            log.error("Error generating QR code for questionnaire {}", id, ex);
            try {
                response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error generating QR code");
            } catch (Exception ignored) {
            }
        }
    }

    @RequestMapping(value = "/{id}/qrcode/base64", method = RequestMethod.GET)
    public AppResponse<String> getQuestionnaireQRBase64(@PathVariable("id") Long id, HttpServletRequest request) {
        try {
            Long companyId = currentCompanyId();
            if (companyId == null) {
                return AppResponse.build(HttpStatus.FORBIDDEN).message("Not authenticated");
            }
            Map<String, Object> q = questionnaireRepo.findByQuestionnaireId(id);
            if (q == null) {
                return AppResponse.build(HttpStatus.NOT_FOUND).message("Questionnaire not found");
            }
            if (!companyId.equals(q.get("COMPANY_ID"))) {
                return AppResponse.build(HttpStatus.FORBIDDEN).message("Access denied");
            }
            String baseUrl = resolveBaseUrl(request);
            String qrContent = "{\"url\":\"" + baseUrl + "\",\"questionnaireId\":" + id + ",\"type\":\"questionnaire\"}";
            BitMatrix bitMatrix = generateQRBitMatrix(qrContent);
            ByteArrayOutputStream baos = new ByteArrayOutputStream();
            MatrixToImageWriter.writeToStream(bitMatrix, "PNG", baos);
            String base64 = Base64.getEncoder().encodeToString(baos.toByteArray());
            return AppResponse.build(HttpStatus.OK).body("data:image/png;base64," + base64);
        } catch (Exception ex) {
            return AppResponse.build(HttpStatus.INTERNAL_SERVER_ERROR).message(ex.getMessage());
        }
    }

    private BitMatrix generateQRBitMatrix(String content) throws Exception {
        QRCodeWriter writer = new QRCodeWriter();
        Map<EncodeHintType, Object> hints = new HashMap<>();
        hints.put(EncodeHintType.MARGIN, 1);
        return writer.encode(content, BarcodeFormat.QR_CODE, 300, 300, hints);
    }

    private static String str(Object value) {
        return value == null ? "" : value.toString();
    }
}
