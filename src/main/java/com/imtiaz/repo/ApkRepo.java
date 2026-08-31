package com.imtiaz.repo;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Repository;

@Repository
public class ApkRepo {

    @Autowired
    NamedParameterJdbcTemplate jdbcTmp;

    public Long save(String originalName, Long fileSize, byte[] fileData, Long uploadedBy, String version) {
        String sql = "INSERT INTO apk_master (ORIGINAL_NAME, FILE_SIZE, FILE_DATA, UPLOADED_BY, VERSION) VALUES (:originalName, :fileSize, :fileData, :uploadedBy, :version)";
        Map<String, Object> params = new HashMap<>();
        params.put("originalName", originalName);
        params.put("fileSize", fileSize);
        params.put("fileData", fileData);
        params.put("uploadedBy", uploadedBy);
        params.put("version", version != null ? version : "");
        jdbcTmp.update(sql, params);
        return jdbcTmp.queryForObject("SELECT LAST_INSERT_ID()", new HashMap<>(), Long.class);
    }

    public List<Map<String, Object>> findAll() {
        String sql = "SELECT APK_ID, ORIGINAL_NAME, FILE_SIZE, VERSION, UPLOADED_BY, UPLOADED_AT FROM apk_master ORDER BY APK_ID DESC";
        return jdbcTmp.queryForList(sql, new HashMap<>());
    }

    public Map<String, Object> findById(Long id) {
        String sql = "SELECT APK_ID, ORIGINAL_NAME, FILE_SIZE, VERSION, UPLOADED_BY, UPLOADED_AT FROM apk_master WHERE APK_ID=:id";
        Map<String, Object> params = new HashMap<>();
        params.put("id", id);
        List<Map<String, Object>> rows = jdbcTmp.queryForList(sql, params);
        return rows.isEmpty() ? null : rows.get(0);
    }

    public byte[] findFileDataById(Long id) {
        String sql = "SELECT FILE_DATA FROM apk_master WHERE APK_ID=:id";
        Map<String, Object> params = new HashMap<>();
        params.put("id", id);
        return jdbcTmp.queryForObject(sql, params, byte[].class);
    }

    public Map<String, Object> findLatest() {
        String sql = "SELECT APK_ID, ORIGINAL_NAME, FILE_SIZE, VERSION, UPLOADED_AT FROM apk_master ORDER BY APK_ID DESC LIMIT 1";
        List<Map<String, Object>> rows = jdbcTmp.queryForList(sql, new HashMap<>());
        return rows.isEmpty() ? null : rows.get(0);
    }

    public boolean deleteById(Long id) {
        String sql = "DELETE FROM apk_master WHERE APK_ID=:id";
        Map<String, Object> params = new HashMap<>();
        params.put("id", id);
        return jdbcTmp.update(sql, params) == 1;
    }
}
