package com.imtiaz.controller;

import com.google.zxing.BarcodeFormat;
import com.google.zxing.EncodeHintType;
import com.google.zxing.client.j2se.MatrixToImageWriter;
import com.google.zxing.common.BitMatrix;
import com.google.zxing.qrcode.QRCodeWriter;
import com.imtiaz.config.AppProperty;
import com.imtiaz.config.AppResponse;
import com.imtiaz.model.SecUser;
import com.imtiaz.repo.AgentRepo;
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
@RequestMapping("company")
public class CompanyController extends AppProperty {

    private static final Logger log = LoggerFactory.getLogger(CompanyController.class);

    @Autowired
    CompanyRepo companyRepo;
    @Autowired
    AgentRepo agentRepo;
    @Autowired
    QuestionnaireRepo questionnaireRepo;
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

    @RequestMapping(value = {"", "/"}, method = {RequestMethod.GET})
    public ModelAndView index() {
        Long userId = currentUserId();
        if (userId != null) {
            Map<String, Object> company = companyRepo.findByUserId(userId);
            if (company != null) {
                return new ModelAndView("company")
                        .addObject("COMPANY_ID", company.get("COMPANY_ID"))
                        .addObject("COMPANY_NAME", company.get("NAME"))
                        .addObject("COMPANY_DESC", company.get("DESCRIPTION"))
                        .addObject("COMPANY_KEY", company.get("COMPANY_KEY"));
            }
        }
        return new ModelAndView("company");
    }

    @RequestMapping(value = "/list", method = RequestMethod.GET)
    public ModelAndView list() {
        return new ModelAndView("admin_companies");
    }

    @RequestMapping(value = "/get/all-admin", method = RequestMethod.GET)
    public AppResponse<List<Map<String, Object>>> getAllAdmin() {
        log.info("GET /company/get/all-admin");
        try {
            Long userId = currentUserId();
            if (userId == null) {
                return AppResponse.build(HttpStatus.FORBIDDEN).message("Not authenticated");
            }
            return AppResponse.build(HttpStatus.OK).body(companyRepo.findAllWithAgentCount());
        } catch (Exception ex) {
            return AppResponse.build(HttpStatus.INTERNAL_SERVER_ERROR).message(ex.getMessage());
        }
    }

    @RequestMapping(value = "/toggle-state", method = RequestMethod.POST)
    public AppResponse<String> toggleState(@RequestBody Map<String, Object> request) {
        try {
            Long userId = currentUserId();
            if (userId == null) {
                return AppResponse.build(HttpStatus.FORBIDDEN).message("Not authenticated");
            }
            Long id = Long.parseLong(request.get("id").toString());
            boolean state = Boolean.parseBoolean(request.get("state").toString());
            companyRepo.updateState(id, state);
            return AppResponse.build(HttpStatus.OK).body("Company " + (state ? "activated" : "inactivated") + " successfully");
        } catch (Exception ex) {
            return AppResponse.build(HttpStatus.INTERNAL_SERVER_ERROR).message(ex.getMessage());
        }
    }

    @RequestMapping(value = "/get/all", method = RequestMethod.GET)
    public AppResponse<List<Map<String, Object>>> getAll() {
        log.info("GET /company/get/all");
        try {
            Long userId = currentUserId();
            if (userId == null) {
                return AppResponse.build(HttpStatus.FORBIDDEN).message("Not authenticated");
            }
            Map<String, Object> company = companyRepo.findByUserId(userId);
            if (company == null) {
                return AppResponse.build(HttpStatus.OK).body(Collections.emptyList());
            }
            return AppResponse.build(HttpStatus.OK).body(Collections.singletonList(company));
        } catch (Exception ex) {
            return AppResponse.build(HttpStatus.INTERNAL_SERVER_ERROR).message(ex.getMessage());
        }
    }

    @RequestMapping(value = "/get/my", method = RequestMethod.GET)
    public AppResponse<Map<String, Object>> getMyCompany() {
        try {
            Long userId = currentUserId();
            if (userId == null) {
                return AppResponse.build(HttpStatus.FORBIDDEN).message("Not authenticated");
            }
            Map<String, Object> company = companyRepo.findByUserId(userId);
            if (company == null) {
                return AppResponse.build(HttpStatus.NOT_FOUND).message("No company associated with your account");
            }
            return AppResponse.build(HttpStatus.OK).body(company);
        } catch (Exception ex) {
            return AppResponse.build(HttpStatus.INTERNAL_SERVER_ERROR).message(ex.getMessage());
        }
    }

    @RequestMapping(value = "/get/{id}", method = RequestMethod.GET)
    public AppResponse<Map<String, Object>> getById(@PathVariable("id") Long id) {
        try {
            Long userId = currentUserId();
            if (userId == null) {
                return AppResponse.build(HttpStatus.FORBIDDEN).message("Not authenticated");
            }
            Map<String, Object> company = companyRepo.findById(id);
            if (company == null) {
                return AppResponse.build(HttpStatus.NOT_FOUND).message("Company not found");
            }
            if (!userId.equals(company.get("USER_ID"))) {
                return AppResponse.build(HttpStatus.FORBIDDEN).message("Access denied");
            }
            return AppResponse.build(HttpStatus.OK).body(company);
        } catch (Exception ex) {
            return AppResponse.build(HttpStatus.INTERNAL_SERVER_ERROR).message(ex.getMessage());
        }
    }

    @RequestMapping(value = "/create", method = RequestMethod.POST)
    public AppResponse<String> create(@RequestBody Map<String, Object> request) {
        try {
            Long userId = currentUserId();
            if (userId == null) {
                return AppResponse.build(HttpStatus.FORBIDDEN).message("Not authenticated");
            }
            if (companyRepo.hasCompany(userId)) {
                return AppResponse.build(HttpStatus.BAD_REQUEST)
                        .message("You already have a company. Each user can create only one company.");
            }
            String name = str(request.get("name")).trim();
            String description = str(request.get("description")).trim();
            if (name.isEmpty()) {
                return AppResponse.build(HttpStatus.BAD_REQUEST).message("Company name is required");
            }
            if (companyRepo.nameExists(name, null)) {
                return AppResponse.build(HttpStatus.BAD_REQUEST).message("Company name already exists");
            }
            String companyKey = str(request.get("companyKey")).trim().toUpperCase();
            if (companyKey.isEmpty() || companyRepo.companyKeyExists(companyKey)) {
                companyKey = generateCompanyKeyValue();
                int attempts = 0;
                while (companyRepo.companyKeyExists(companyKey) && attempts < 200) {
                    companyKey = generateCompanyKeyValue();
                    attempts++;
                }
            }
            companyRepo.save(name, description, userId, companyKey);
            return AppResponse.build(HttpStatus.OK).body("Company created successfully");
        } catch (Exception ex) {
            return AppResponse.build(HttpStatus.INTERNAL_SERVER_ERROR).message(ex.getMessage());
        }
    }

    @RequestMapping(value = "/update", method = RequestMethod.POST)
    public AppResponse<String> update(@RequestBody Map<String, Object> request) {
        try {
            Long userId = currentUserId();
            if (userId == null) {
                return AppResponse.build(HttpStatus.FORBIDDEN).message("Not authenticated");
            }
            Long id = Long.parseLong(request.get("id").toString());
            Map<String, Object> company = companyRepo.findById(id);
            if (company == null) {
                return AppResponse.build(HttpStatus.NOT_FOUND).message("Company not found");
            }
            if (!userId.equals(company.get("USER_ID"))) {
                return AppResponse.build(HttpStatus.FORBIDDEN).message("Access denied");
            }
            String name = str(request.get("name")).trim();
            String description = str(request.get("description")).trim();
            boolean state = Boolean.parseBoolean(request.get("state").toString());
            if (name.isEmpty()) {
                return AppResponse.build(HttpStatus.BAD_REQUEST).message("Company name is required");
            }
            if (companyRepo.nameExists(name, id)) {
                return AppResponse.build(HttpStatus.BAD_REQUEST).message("Company name already exists");
            }
            companyRepo.update(id, name, description, state);
            return AppResponse.build(HttpStatus.OK).body("Company updated successfully");
        } catch (Exception ex) {
            return AppResponse.build(HttpStatus.INTERNAL_SERVER_ERROR).message(ex.getMessage());
        }
    }

    @RequestMapping(value = "/delete/{id}", method = {RequestMethod.POST, RequestMethod.DELETE})
    public AppResponse<String> delete(@PathVariable("id") Long id) {
        try {
            Long userId = currentUserId();
            if (userId == null) {
                return AppResponse.build(HttpStatus.FORBIDDEN).message("Not authenticated");
            }
            Map<String, Object> company = companyRepo.findById(id);
            if (company == null) {
                return AppResponse.build(HttpStatus.NOT_FOUND).message("Company not found");
            }
            if (!userId.equals(company.get("USER_ID"))) {
                return AppResponse.build(HttpStatus.FORBIDDEN).message("Access denied");
            }
            companyRepo.deleteById(id);
            return AppResponse.build(HttpStatus.OK).body("Company deleted successfully");
        } catch (Exception ex) {
            return AppResponse.build(HttpStatus.INTERNAL_SERVER_ERROR).message(ex.getMessage());
        }
    }

    @RequestMapping(value = "/generate-key", method = RequestMethod.GET)
    public AppResponse<String> generateKey() {
        try {
            Long userId = currentUserId();
            if (userId == null) {
                return AppResponse.build(HttpStatus.FORBIDDEN).message("Not authenticated");
            }
            String key = generateCompanyKeyValue();
            int attempts = 0;
            while (companyRepo.companyKeyExists(key) && attempts < 200) {
                key = generateCompanyKeyValue();
                attempts++;
            }
            return AppResponse.build(HttpStatus.OK).body(key);
        } catch (Exception ex) {
            return AppResponse.build(HttpStatus.INTERNAL_SERVER_ERROR).message(ex.getMessage());
        }
    }

    @RequestMapping(value = "/regenerate-key", method = RequestMethod.POST)
    public AppResponse<String> regenerateKey() {
        try {
            Long userId = currentUserId();
            if (userId == null) {
                return AppResponse.build(HttpStatus.FORBIDDEN).message("Not authenticated");
            }
            Map<String, Object> company = companyRepo.findByUserId(userId);
            if (company == null) {
                return AppResponse.build(HttpStatus.NOT_FOUND).message("No company associated with your account");
            }
            Long id = ((Number) company.get("COMPANY_ID")).longValue();
            String key = generateCompanyKeyValue();
            int attempts = 0;
            while (companyRepo.companyKeyExists(key) && attempts < 200) {
                key = generateCompanyKeyValue();
                attempts++;
            }
            companyRepo.updateCompanyKey(id, key);
            return AppResponse.build(HttpStatus.OK).body(key);
        } catch (Exception ex) {
            return AppResponse.build(HttpStatus.INTERNAL_SERVER_ERROR).message(ex.getMessage());
        }
    }

    // --- QR Code ---

    @RequestMapping(value = "/{companyId}/qrcode", method = RequestMethod.GET)
    public void downloadQRCode(@PathVariable("companyId") Long companyId, HttpServletRequest request, HttpServletResponse response) {
        try {
            Long userId = currentUserId();
            if (userId == null) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN, "Not authenticated");
                return;
            }
            Map<String, Object> company = companyRepo.findById(companyId);
            if (company == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Company not found");
                return;
            }
            if (!userId.equals(company.get("USER_ID"))) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied");
                return;
            }
            String baseUrl = resolveBaseUrl(request);
            String qrContent = "{\"url\":\"" + baseUrl + "\",\"companyId\":" + companyId + ",\"userId\":" + userId + ",\"companyKey\":\"" + str(company.get("COMPANY_KEY")) + "\"}";
            BitMatrix bitMatrix = generateQRBitMatrix(qrContent);
            response.setContentType("image/png");
            response.setHeader("Content-Disposition", "attachment; filename=\"company_" + companyId + "_qr.png\"");
            MatrixToImageWriter.writeToStream(bitMatrix, "PNG", response.getOutputStream());
        } catch (Exception ex) {
            log.error("Error generating QR code for company {}", companyId, ex);
            try {
                response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error generating QR code");
            } catch (Exception ignored) {
            }
        }
    }

    @RequestMapping(value = "/{companyId}/qrcode/base64", method = RequestMethod.GET)
    public AppResponse<String> getQRCodeBase64(@PathVariable("companyId") Long companyId, HttpServletRequest request) {
        try {
            Long userId = currentUserId();
            if (userId == null) {
                return AppResponse.build(HttpStatus.FORBIDDEN).message("Not authenticated");
            }
            Map<String, Object> company = companyRepo.findById(companyId);
            if (company == null) {
                return AppResponse.build(HttpStatus.NOT_FOUND).message("Company not found");
            }
            if (!userId.equals(company.get("USER_ID"))) {
                return AppResponse.build(HttpStatus.FORBIDDEN).message("Access denied");
            }
            String baseUrl = resolveBaseUrl(request);
            String qrContent = "{\"url\":\"" + baseUrl + "\",\"companyId\":" + companyId + ",\"userId\":" + userId + ",\"companyKey\":\"" + str(company.get("COMPANY_KEY")) + "\"}";
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

    // --- Public, QR-scoped endpoints for the Flutter offline client ---
    // No login required; access is gated by the companyId + companyKey pair from
    // the company QR code.

    @RequestMapping(value = "/public/by-id/{companyId}", method = RequestMethod.GET)
    public AppResponse<Map<String, Object>> publicById(
            @PathVariable("companyId") Long companyId,
            @RequestParam(value = "companyKey", required = false) String companyKey) {
        try {
            Map<String, Object> company = companyRepo.findById(companyId);
            if (company == null) {
                return AppResponse.build(HttpStatus.NOT_FOUND).message("Company not found");
            }
            if (!isCompanyKeyValid(company, companyKey)) {
                return AppResponse.build(HttpStatus.FORBIDDEN).message("Invalid company key");
            }
            Map<String, Object> out = new HashMap<>();
            out.put("COMPANY_ID", company.get("COMPANY_ID"));
            out.put("NAME", company.get("NAME"));
            out.put("COMPANY_KEY", company.get("COMPANY_KEY"));
            return AppResponse.build(HttpStatus.OK).body(out);
        } catch (Exception ex) {
            return AppResponse.build(HttpStatus.INTERNAL_SERVER_ERROR).message(ex.getMessage());
        }
    }

    @RequestMapping(value = "/public/agents/{companyId}", method = RequestMethod.GET)
    public AppResponse<List<Map<String, Object>>> publicAgents(
            @PathVariable("companyId") Long companyId,
            @RequestParam(value = "companyKey", required = false) String companyKey) {
        try {
            Map<String, Object> company = companyRepo.findById(companyId);
            if (company == null) {
                return AppResponse.build(HttpStatus.NOT_FOUND).message("Company not found");
            }
            if (!isCompanyKeyValid(company, companyKey)) {
                return AppResponse.build(HttpStatus.FORBIDDEN).message("Invalid company key");
            }
            return AppResponse.build(HttpStatus.OK).body(agentRepo.findActiveByCompanyId(companyId));
        } catch (Exception ex) {
            return AppResponse.build(HttpStatus.INTERNAL_SERVER_ERROR).message(ex.getMessage());
        }
    }

    private boolean isCompanyKeyValid(Map<String, Object> company, String companyKey) {
        String expected = company.get("COMPANY_KEY") == null ? "" : company.get("COMPANY_KEY").toString().trim();
        if (expected.isEmpty()) {
            return true; // company has no key set -> open access
        }
        return companyKey != null && expected.equals(companyKey.trim());
    }

    // --- Agents ---

    @RequestMapping(value = "/public/agent/validate", method = RequestMethod.POST)
    public AppResponse<Map<String, Object>> publicValidateAgent(@RequestBody Map<String, Object> request) {
        try {
            Object cidObj = request.get("companyId");
            if (cidObj == null) {
                return AppResponse.build(HttpStatus.BAD_REQUEST).message("companyId is required");
            }
            Long companyId;
            try {
                companyId = Long.valueOf(cidObj.toString().trim());
            } catch (Exception e) {
                return AppResponse.build(HttpStatus.BAD_REQUEST).message("Invalid companyId");
            }
            String userId = str(request.get("userId"));
            String agentKey = str(request.get("agentKey"));
            String companyKey = str(request.get("companyKey"));

            if (agentKey.isEmpty()) {
                return AppResponse.build(HttpStatus.BAD_REQUEST).message("agentKey is required");
            }

            Map<String, Object> company = companyRepo.findById(companyId);
            if (company == null) {
                return AppResponse.build(HttpStatus.NOT_FOUND).message("Company not found");
            }
            if (!isCompanyKeyValid(company, companyKey)) {
                return AppResponse.build(HttpStatus.FORBIDDEN).message("Invalid company key");
            }
            if (!userId.isEmpty() && company.get("USER_ID") != null
                    && !userId.equals(company.get("USER_ID").toString())) {
                return AppResponse.build(HttpStatus.FORBIDDEN).message("Agent does not belong to this company user");
            }

            Map<String, Object> agent = agentRepo.findByKeyValue(agentKey);
            if (agent == null) {
                return AppResponse.build(HttpStatus.FORBIDDEN).message("Invalid agent key");
            }
            Object statusObj = agent.get("STATUS");
            boolean active = statusObj instanceof Boolean ? (Boolean) statusObj
                    : ((Number) statusObj).intValue() != 0;
            if (!active) {
                return AppResponse.build(HttpStatus.FORBIDDEN).message("Agent is inactive");
            }
            Long agentCompanyId = ((Number) agent.get("COMPANY_ID")).longValue();
            if (!agentCompanyId.equals(companyId)) {
                return AppResponse.build(HttpStatus.FORBIDDEN).message("Agent does not belong to this company");
            }

            Map<String, Object> out = new HashMap<>();
            out.put("AGENT_ID", agent.get("AGENT_ID"));
            out.put("KEY_VALUE", agent.get("KEY_VALUE"));
            out.put("NAME", agent.get("NAME"));
            out.put("EXPIRATION", agent.get("EXPIRATION"));
            return AppResponse.build(HttpStatus.OK).body(out);
        } catch (Exception ex) {
            return AppResponse.build(HttpStatus.INTERNAL_SERVER_ERROR).message(ex.getMessage());
        }
    }

    // --- Agents ---

    @RequestMapping(value = "/{companyId}/agents", method = RequestMethod.GET)
    public ModelAndView agents(@PathVariable("companyId") Long companyId) {
        return new ModelAndView("redirect:/company");
    }

    @RequestMapping(value = "/{companyId}/agent/get/all", method = RequestMethod.GET)
    public AppResponse<List<Map<String, Object>>> getAgents(@PathVariable("companyId") Long companyId) {
        try {
            Long userId = currentUserId();
            if (userId == null) {
                return AppResponse.build(HttpStatus.FORBIDDEN).message("Not authenticated");
            }
            Map<String, Object> company = companyRepo.findById(companyId);
            if (company == null || !userId.equals(company.get("USER_ID"))) {
                return AppResponse.build(HttpStatus.FORBIDDEN).message("Access denied");
            }
            return AppResponse.build(HttpStatus.OK).body(agentRepo.findByCompanyId(companyId));
        } catch (Exception ex) {
            return AppResponse.build(HttpStatus.INTERNAL_SERVER_ERROR).message(ex.getMessage());
        }
    }

    @RequestMapping(value = "/{companyId}/agent/generate-token", method = RequestMethod.GET)
    public AppResponse<String> generateToken(@PathVariable("companyId") Long companyId) {
        try {
            Long userId = currentUserId();
            if (userId == null) {
                return AppResponse.build(HttpStatus.FORBIDDEN).message("Not authenticated");
            }
            Map<String, Object> company = companyRepo.findById(companyId);
            if (company == null || !userId.equals(company.get("USER_ID"))) {
                return AppResponse.build(HttpStatus.FORBIDDEN).message("Access denied");
            }
            String token = generateTokenValue();
            int attempts = 0;
            while (agentRepo.keyValueExists(token, null) && attempts < 100) {
                token = generateTokenValue();
                attempts++;
            }
            return AppResponse.build(HttpStatus.OK).body(token);
        } catch (Exception ex) {
            return AppResponse.build(HttpStatus.INTERNAL_SERVER_ERROR).message(ex.getMessage());
        }
    }

    @RequestMapping(value = "/{companyId}/agent/create", method = RequestMethod.POST)
    public AppResponse<Map<String, String>> createAgent(
            @PathVariable("companyId") Long companyId,
            @RequestBody Map<String, Object> request) {
        try {
            Long userId = currentUserId();
            if (userId == null) {
                return AppResponse.build(HttpStatus.FORBIDDEN).message("Not authenticated");
            }
            Map<String, Object> company = companyRepo.findById(companyId);
            if (company == null || !userId.equals(company.get("USER_ID"))) {
                return AppResponse.build(HttpStatus.FORBIDDEN).message("Access denied");
            }
            String label = str(request.get("label")).trim();
            String expirationStr = str(request.get("expiration")).trim();

            String keyValue = str(request.get("keyValue")).trim().toUpperCase();
            if (keyValue.isEmpty() || agentRepo.keyValueExists(keyValue, null)) {
                keyValue = generateTokenValue();
                while (agentRepo.keyValueExists(keyValue, null)) {
                    keyValue = generateTokenValue();
                }
            }

            java.sql.Date expiration = null;
            if (!expirationStr.isEmpty()) {
                expiration = java.sql.Date.valueOf(expirationStr);
            }
            agentRepo.save(companyId, keyValue, label, expiration);
            Map<String, String> result = new HashMap<>();
            result.put("keyValue", keyValue);
            result.put("label", label);
            return AppResponse.build(HttpStatus.OK).body("Agent created successfully").body(result);
        } catch (Exception ex) {
            return AppResponse.build(HttpStatus.INTERNAL_SERVER_ERROR).message(ex.getMessage());
        }
    }

    @RequestMapping(value = "/{companyId}/agent/update", method = RequestMethod.POST)
    public AppResponse<String> updateAgent(
            @PathVariable("companyId") Long companyId,
            @RequestBody Map<String, Object> request) {
        try {
            Long userId = currentUserId();
            if (userId == null) {
                return AppResponse.build(HttpStatus.FORBIDDEN).message("Not authenticated");
            }
            Map<String, Object> company = companyRepo.findById(companyId);
            if (company == null || !userId.equals(company.get("USER_ID"))) {
                return AppResponse.build(HttpStatus.FORBIDDEN).message("Access denied");
            }
            Long id = Long.parseLong(request.get("id").toString());
            String label = str(request.get("label")).trim();
            String expirationStr = str(request.get("expiration")).trim();
            boolean status = Boolean.parseBoolean(request.get("status").toString());
            Map<String, Object> existing = agentRepo.findById(id);
            if (existing == null) {
                return AppResponse.build(HttpStatus.NOT_FOUND).message("Agent not found");
            }
            String keyValue = str(existing.get("KEY_VALUE"));
            java.sql.Date expiration = null;
            if (!expirationStr.isEmpty()) {
                expiration = java.sql.Date.valueOf(expirationStr);
            }
            agentRepo.update(id, keyValue, label, expiration, status);
            return AppResponse.build(HttpStatus.OK).body("Agent updated successfully");
        } catch (Exception ex) {
            return AppResponse.build(HttpStatus.INTERNAL_SERVER_ERROR).message(ex.getMessage());
        }
    }

    @RequestMapping(value = "/{companyId}/agent/delete/{id}", method = {RequestMethod.POST, RequestMethod.DELETE})
    public AppResponse<String> deleteAgent(
            @PathVariable("companyId") Long companyId,
            @PathVariable("id") Long id) {
        try {
            Long userId = currentUserId();
            if (userId == null) {
                return AppResponse.build(HttpStatus.FORBIDDEN).message("Not authenticated");
            }
            Map<String, Object> company = companyRepo.findById(companyId);
            if (company == null || !userId.equals(company.get("USER_ID"))) {
                return AppResponse.build(HttpStatus.FORBIDDEN).message("Access denied");
            }
            agentRepo.deleteById(id);
            return AppResponse.build(HttpStatus.OK).body("Agent deleted successfully");
        } catch (Exception ex) {
            return AppResponse.build(HttpStatus.INTERNAL_SERVER_ERROR).message(ex.getMessage());
        }
    }

    private String generateTokenValue() {
        String chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
        StringBuilder sb = new StringBuilder(4);
        for (int i = 0; i < 4; i++) {
            sb.append(chars.charAt((int) (Math.random() * chars.length())));
        }
        return sb.toString();
    }

    private String generateCompanyKeyValue() {
        String chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
        StringBuilder sb = new StringBuilder(6);
        for (int i = 0; i < 6; i++) {
            sb.append(chars.charAt((int) (Math.random() * chars.length())));
        }
        return sb.toString();
    }

    private static String str(Object value) {
        return value == null ? "" : value.toString();
    }
}
