-- =============================================================================
-- SurveyMaster — Single-file schema + seed data
-- Toggle via  app.db.init-schema=true|false  in application.properties
-- Safe to re-run: uses CREATE TABLE IF NOT EXISTS / INSERT IGNORE
-- =============================================================================

-- ----------------------------
-- 1. sec_user
-- ----------------------------
CREATE TABLE IF NOT EXISTS sec_user (
    id                  BIGINT       NOT NULL AUTO_INCREMENT,
    version             BIGINT       DEFAULT 0,
    username            VARCHAR(200) NOT NULL,
    email               VARCHAR(200) NOT NULL,
    password            VARCHAR(200) NOT NULL,
    enabled             TINYINT(1)   NOT NULL DEFAULT 1,
    account_expired     TINYINT(1)   NOT NULL DEFAULT 0,
    account_locked      TINYINT(1)   NOT NULL DEFAULT 0,
    password_expired    TINYINT(1)   NOT NULL DEFAULT 0,
    default_target_url  VARCHAR(200) DEFAULT '/',
    reset_token         VARCHAR(255) DEFAULT NULL,
    reset_token_expiry  DATETIME     DEFAULT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY UK_SEC_USER_USERNAME (username),
    UNIQUE KEY UK_SEC_USER_RESET_TOKEN (reset_token)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ----------------------------
-- 2. sec_role
-- ----------------------------
CREATE TABLE IF NOT EXISTS sec_role (
    id        BIGINT       NOT NULL AUTO_INCREMENT,
    version   BIGINT       DEFAULT 0,
    authority VARCHAR(100) NOT NULL,
    name      VARCHAR(100) NOT NULL,
    active    TINYINT(1)   NOT NULL DEFAULT 1,
    PRIMARY KEY (id),
    UNIQUE KEY UK_SEC_ROLE_AUTHORITY (authority)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ----------------------------
-- 3. sec_user_sec_role  (join table)
-- ----------------------------
CREATE TABLE IF NOT EXISTS sec_user_sec_role (
    sec_user_id BIGINT NOT NULL,
    sec_role_id BIGINT NOT NULL,
    PRIMARY KEY (sec_user_id, sec_role_id),
    CONSTRAINT FK_UR_USER FOREIGN KEY (sec_user_id) REFERENCES sec_user(id) ON DELETE CASCADE,
    CONSTRAINT FK_UR_ROLE FOREIGN KEY (sec_role_id) REFERENCES sec_role(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ----------------------------
-- 4. company_master
-- ----------------------------
CREATE TABLE IF NOT EXISTS company_master (
    COMPANY_ID  BIGINT       NOT NULL AUTO_INCREMENT,
    NAME        VARCHAR(200) NOT NULL,
    DESCRIPTION VARCHAR(500) DEFAULT '',
    STATE       TINYINT(1)   NOT NULL DEFAULT 1,
    USER_ID     BIGINT       DEFAULT NULL,
    COMPANY_KEY VARCHAR(6)   DEFAULT NULL,
    PRIMARY KEY (COMPANY_ID),
    UNIQUE KEY UK_COMPANY_NAME (NAME),
    UNIQUE KEY UK_COMPANY_USER (USER_ID),
    UNIQUE KEY UK_COMPANY_KEY (COMPANY_KEY),
    CONSTRAINT FK_COMPANY_USER FOREIGN KEY (USER_ID) REFERENCES sec_user(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ----------------------------
-- 5. questionnaire_master
-- ----------------------------
CREATE TABLE IF NOT EXISTS questionnaire_master (
    QUESTIONNAIRE_ID INT          NOT NULL AUTO_INCREMENT,
    NAME             VARCHAR(200) NOT NULL,
    CAPTION          VARCHAR(500) DEFAULT '',
    DESCRIPTION      VARCHAR(500) DEFAULT '',
    COMPANY_ID       BIGINT       DEFAULT NULL,
    CONF_DATA        LONGTEXT,
    STATE            TINYINT(1)   NOT NULL DEFAULT 1,
    PRIMARY KEY (QUESTIONNAIRE_ID),
    CONSTRAINT FK_Q_COMPANY FOREIGN KEY (COMPANY_ID) REFERENCES company_master(COMPANY_ID) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ----------------------------
-- 6. agent_master
-- ----------------------------
CREATE TABLE IF NOT EXISTS agent_master (
    AGENT_ID   BIGINT       NOT NULL AUTO_INCREMENT,
    COMPANY_ID BIGINT       NOT NULL,
    KEY_VALUE  VARCHAR(200) NOT NULL,
    NAME       VARCHAR(200) DEFAULT '',
    EXPIRATION DATE         DEFAULT NULL,
    STATUS     TINYINT(1)   NOT NULL DEFAULT 1,
    PRIMARY KEY (AGENT_ID),
    UNIQUE KEY UK_AGENT_KEY_VALUE (KEY_VALUE),
    CONSTRAINT FK_AGENT_COMPANY FOREIGN KEY (COMPANY_ID) REFERENCES company_master(COMPANY_ID) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ----------------------------
-- 7. response_master
-- ----------------------------
CREATE TABLE IF NOT EXISTS response_master (
    RESPONSE_ID      BIGINT   NOT NULL AUTO_INCREMENT,
    QUESTIONNAIRE_ID INT      NOT NULL,
    COMPANY_ID       BIGINT   DEFAULT NULL,
    AGENT_ID         BIGINT   DEFAULT NULL,
    RESPONSE_DATA    TEXT     NOT NULL,
    SUBMITTED_AT     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    RECORDED_AT      DATETIME DEFAULT NULL,
    PRIMARY KEY (RESPONSE_ID),
    CONSTRAINT FK_R_QUESTIONNAIRE FOREIGN KEY (QUESTIONNAIRE_ID) REFERENCES questionnaire_master(QUESTIONNAIRE_ID) ON DELETE CASCADE,
    CONSTRAINT FK_R_COMPANY       FOREIGN KEY (COMPANY_ID)       REFERENCES company_master(COMPANY_ID) ON DELETE SET NULL,
    CONSTRAINT FK_R_AGENT         FOREIGN KEY (AGENT_ID)         REFERENCES agent_master(AGENT_ID) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ----------------------------
-- 8. apk_master
-- ----------------------------
CREATE TABLE IF NOT EXISTS apk_master (
    APK_ID        BIGINT       NOT NULL AUTO_INCREMENT,
    ORIGINAL_NAME VARCHAR(255) NOT NULL,
    FILE_SIZE     BIGINT       DEFAULT 0,
    FILE_DATA     LONGBLOB,
    UPLOADED_BY   BIGINT       DEFAULT NULL,
    UPLOADED_AT   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (APK_ID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;




-- =============================================================================
-- SEED DATA
-- =============================================================================

-- Roles
INSERT IGNORE INTO sec_role (id, version, authority, name, active)
VALUES (1, 0, 'ROLE_ADMIN', 'Administrator', 1);

INSERT IGNORE INTO sec_role (id, version, authority, name, active)
VALUES (2, 0, 'ROLE_USER', 'User', 1);

-- Admin user  (password: 123  — {bcrypt} encoded)
INSERT IGNORE INTO sec_user (id, version, username, email, password, enabled, account_expired, account_locked, password_expired, default_target_url)
VALUES (1, 0, 'admin', 'admin@surveymaster.local',
        '{bcrypt}$2a$10$gpjgkZb2.WNp/.Bvj0ewg.qmsMEa/pamX3ii7vXtAcmYotkP3edwa',
        1, 0, 0, 0, '/');

-- Assign ROLE_ADMIN to admin user
INSERT IGNORE INTO sec_user_sec_role (sec_user_id, sec_role_id)
SELECT 1, 1 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM sec_user_sec_role WHERE sec_user_id = 1 AND sec_role_id = 1);

