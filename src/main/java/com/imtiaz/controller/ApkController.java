package com.imtiaz.controller;

import com.imtiaz.config.AppProperty;
import com.imtiaz.config.AppResponse;
import com.imtiaz.model.SecUser;
import com.imtiaz.repo.ApkRepo;
import com.imtiaz.repo.SecUserRepo;
import java.io.OutputStream;
import java.util.List;
import java.util.Map;
import javax.servlet.http.HttpServletResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.ModelAndView;

@RestController
@RequestMapping("apk")
public class ApkController extends AppProperty {

    private static final Logger log = LoggerFactory.getLogger(ApkController.class);

    @Autowired
    ApkRepo apkRepo;
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

    @RequestMapping(value = {"", "/"}, method = RequestMethod.GET)
    public ModelAndView index() {
        return new ModelAndView("admin_apk");
    }

    @RequestMapping(value = "/get/all", method = RequestMethod.GET)
    public AppResponse<List<Map<String, Object>>> getAll() {
        try {
            Long userId = currentUserId();
            if (userId == null) {
                return AppResponse.build(HttpStatus.FORBIDDEN).message("Not authenticated");
            }
            return AppResponse.build(HttpStatus.OK).body(apkRepo.findAll());
        } catch (Exception ex) {
            return AppResponse.build(HttpStatus.INTERNAL_SERVER_ERROR).message(ex.getMessage());
        }
    }

    @RequestMapping(value = "/get/latest", method = RequestMethod.GET)
    public AppResponse<Map<String, Object>> getLatest() {
        try {
            return AppResponse.build(HttpStatus.OK).body(apkRepo.findLatest());
        } catch (Exception ex) {
            return AppResponse.build(HttpStatus.INTERNAL_SERVER_ERROR).message(ex.getMessage());
        }
    }

    @RequestMapping(value = "/upload", method = RequestMethod.POST)
    public AppResponse<String> upload(@RequestParam("file") MultipartFile file,
                                      @RequestParam(value = "version", required = false, defaultValue = "") String version) {
        try {
            Long userId = currentUserId();
            if (userId == null) {
                return AppResponse.build(HttpStatus.FORBIDDEN).message("Not authenticated");
            }
            if (file.isEmpty()) {
                return AppResponse.build(HttpStatus.BAD_REQUEST).message("No file selected");
            }
            String originalName = file.getOriginalFilename();
            if (originalName == null || !originalName.toLowerCase().endsWith(".apk")) {
                return AppResponse.build(HttpStatus.BAD_REQUEST).message("Only APK files are allowed");
            }
            byte[] fileData = file.getBytes();
            apkRepo.save(originalName, file.getSize(), fileData, userId, version);
            return AppResponse.build(HttpStatus.OK).body("APK uploaded successfully");
        } catch (Exception ex) {
            log.error("Error uploading APK", ex);
            return AppResponse.build(HttpStatus.INTERNAL_SERVER_ERROR).message(ex.getMessage());
        }
    }

    @RequestMapping(value = "/download/{id}", method = RequestMethod.GET)
    public void download(@PathVariable("id") Long id, HttpServletResponse response) {
        try {
            Map<String, Object> apk = apkRepo.findById(id);
            if (apk == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "APK not found");
                return;
            }
            byte[] fileData = apkRepo.findFileDataById(id);
            if (fileData == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "APK file data not found");
                return;
            }
            String originalName = (String) apk.get("ORIGINAL_NAME");
            response.setContentType("application/vnd.android.package-archive");
            response.setHeader("Content-Disposition", "attachment; filename=\"" + originalName + "\"");
            response.setContentLengthLong(fileData.length);
            try (OutputStream os = response.getOutputStream()) {
                os.write(fileData);
            }
        } catch (Exception ex) {
            log.error("Error downloading APK {}", id, ex);
        }
    }

    @RequestMapping(value = "/delete/{id}", method = {RequestMethod.POST, RequestMethod.DELETE})
    public AppResponse<String> delete(@PathVariable("id") Long id) {
        try {
            Long userId = currentUserId();
            if (userId == null) {
                return AppResponse.build(HttpStatus.FORBIDDEN).message("Not authenticated");
            }
            Map<String, Object> apk = apkRepo.findById(id);
            if (apk == null) {
                return AppResponse.build(HttpStatus.NOT_FOUND).message("APK not found");
            }
            apkRepo.deleteById(id);
            return AppResponse.build(HttpStatus.OK).body("APK deleted successfully");
        } catch (Exception ex) {
            return AppResponse.build(HttpStatus.INTERNAL_SERVER_ERROR).message(ex.getMessage());
        }
    }
}
