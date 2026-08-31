package com.imtiaz.config;

import java.io.ByteArrayInputStream;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.Statement;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.CommandLineRunner;
import org.springframework.core.io.ClassPathResource;
import org.springframework.core.io.InputStreamResource;
import org.springframework.jdbc.datasource.init.ResourceDatabasePopulator;
import org.springframework.stereotype.Component;
import org.springframework.util.FileCopyUtils;
import org.springframework.util.StringUtils;

@Component
public class SchemaInitializer implements CommandLineRunner {

    private static final Logger log = LoggerFactory.getLogger(SchemaInitializer.class);

    private final javax.sql.DataSource dataSource;
    private final boolean initSchema;
    private final boolean migrationSchema;
    private final String datasourceUrl;
    private final String datasourceUser;
    private final String datasourcePassword;

    public SchemaInitializer(javax.sql.DataSource dataSource,
                             @org.springframework.beans.factory.annotation.Value("${app.db.init-schema:false}") boolean initSchema,
                             @org.springframework.beans.factory.annotation.Value("${app.db.migration-schema:false}") boolean migrationSchema,
                             @org.springframework.beans.factory.annotation.Value("${spring.datasource.url}") String datasourceUrl,
                             @org.springframework.beans.factory.annotation.Value("${spring.datasource.username}") String datasourceUser,
                             @org.springframework.beans.factory.annotation.Value("${spring.datasource.password}") String datasourcePassword) {
        this.dataSource = dataSource;
        this.initSchema = initSchema;
        this.migrationSchema = migrationSchema;
        this.datasourceUrl = datasourceUrl;
        this.datasourceUser = datasourceUser;
        this.datasourcePassword = datasourcePassword;
    }

    @Override
    public void run(String... args) {
        if (initSchema) {
            // Create the database itself if it does not yet exist, so the schema
            // script below has somewhere to run.
            ensureDatabase();
            log.info("app.db.init-schema is true — running db-schema.sql");
            try {
                ResourceDatabasePopulator populator = new ResourceDatabasePopulator();
                populator.addScript(new ClassPathResource("db-schema.sql"));
                populator.setSeparator(";");
                populator.setContinueOnError(false);
                populator.execute(dataSource);
                log.info("Schema initialization complete");
            } catch (Exception ex) {
                log.warn("Schema initialization failed: {}", ex.getMessage());
            }
        } else {
            log.info("app.db.init-schema is false — skipping schema initialization");
        }

        // Incremental migrations (safe to re-run) — driven entirely by db-migration.sql.
        if (migrationSchema) {
            applyMigrations();
        } else {
            log.info("app.db.migration-schema is false — skipping migration initialization");
        }
    }

    private void applyMigrations() {
        try {
            ClassPathResource resource = new ClassPathResource("db-migration.sql");
            if (!resource.exists()) {
                log.info("db-migration.sql not found — skipping migrations");
                return;
            }
            String content = FileCopyUtils.copyToString(
                    new InputStreamReader(resource.getInputStream(), StandardCharsets.UTF_8));
            if (!StringUtils.hasText(content)) {
                log.info("db-migration.sql is empty — skipping migrations");
                return;
            }
            // Drop a single trailing separator so an empty trailing fragment does not
            // make the populator reject the script.
            content = content.trim();
            if (content.endsWith(";")) {
                content = content.substring(0, content.length() - 1);
            }
            ResourceDatabasePopulator populator = new ResourceDatabasePopulator();
            populator.addScript(new InputStreamResource(
                    new ByteArrayInputStream(content.getBytes(StandardCharsets.UTF_8)), "db-migration.sql"));
            populator.setSeparator(";");
            populator.setContinueOnError(true);
            populator.execute(dataSource);
            log.info("Migrations complete");
        } catch (Exception ex) {
            log.warn("Could not apply migrations: {}", ex.getMessage());
        }
    }

    /**
     * Connects to the MySQL server (without selecting a database) and runs
     * CREATE DATABASE IF NOT EXISTS for the configured schema name.
     */
    private void ensureDatabase() {
        try {
            Matcher m = Pattern.compile("^jdbc:mysql://([^/?]+)(/([^?]*))?(\\?.*)?$").matcher(datasourceUrl);
            if (!m.matches()) {
                log.warn("Could not parse database name from URL — skipping database creation");
                return;
            }
            String hostPort = m.group(1);
            String dbName = m.group(3);
            String query = m.group(4) == null ? "" : m.group(4);
            if (dbName == null || dbName.trim().isEmpty()) {
                log.info("No database name in URL — skipping database creation");
                return;
            }
            String noDbUrl = "jdbc:mysql://" + hostPort + "/" + query;
            try (Connection conn = DriverManager.getConnection(noDbUrl, datasourceUser, datasourcePassword);
                 Statement st = conn.createStatement()) {
                st.execute("CREATE DATABASE IF NOT EXISTS " + dbName
                        + " CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci");
                log.info("Ensured database '{}' exists", dbName);
            }
        } catch (Exception ex) {
            log.warn("Could not create database: {}", ex.getMessage());
        }
    }
}
