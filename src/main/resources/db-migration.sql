-- =============================================================================
-- SurveyMaster — Incremental migrations
-- Applied on every startup by SchemaInitializer.applyMigrations().
-- Safe to re-run: each change is guarded so it only runs when needed.
-- Add new migrations at the bottom; no Java changes required.
-- =============================================================================

-- Publish flag + version on questionnaires.
-- Default PUBLISHED = 1 so existing questionnaires remain visible to the mobile
-- client. New questionnaires are created unpublished (see QuestionnaireRepo) and
-- must be explicitly published from the edit page.
ALTER TABLE questionnaire_master ADD COLUMN PUBLISHED TINYINT(1) NOT NULL DEFAULT 1;
ALTER TABLE questionnaire_master ADD COLUMN VERSION VARCHAR(20) DEFAULT '';

-- Record date: when the interview was actually conducted (mobile local time),
-- distinct from SUBMITTED_AT (when the row was received by the server).
ALTER TABLE response_master ADD COLUMN RECORDED_AT DATETIME DEFAULT NULL;

-- APK version: so the admin can tag each uploaded APK with a version string
-- (e.g. "1.0.0") that is displayed to users on the web and mobile.
ALTER TABLE apk_master ADD COLUMN VERSION VARCHAR(20) DEFAULT '';

