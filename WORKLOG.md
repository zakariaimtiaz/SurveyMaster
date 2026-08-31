# WORKLOG — SurveyMaster builder hardening & feature work

## Goal
Fix questionnaire skip/branching logic in the builder, then add three phases of
useful, easy-to-adopt features (UX polish, data/sharing, structure/computed fields).

## Deliverables
1. Branching/visibility bug fix + Flow View connector semantics + Next Step property.
2. Phase A (UX/polish): live progress bar, custom required-message (errMsg), bulk option entry, reminder hint with colored swatches.
3. Phase B (data & sharing): CSV export endpoint, per-questionnaire QR (PNG + base64), JSON import/export, toolbar buttons.
4. Phase C (structure/computed): section header question type, calc (score) computed field.

## Steps taken
- survey.js
  - Fixed inputValue() so radio/checkbox fieldset returns the checked value (was always ""), repairing jumps/visibleIf driven by option questions.
  - Re-established sequential chain connectors in Flow View; reversed colors (sequential=gray #adb5bd, condition=green dashed #5BB75B, jump=red).
  - Added nextStep (index | -1 = None | null = legacy sequential) honored by the engine as the default next target; remapped on move/delete/duplicate; dropdown in property panel (default = real next sequential).
  - Fixed a silent bug where syncFromForm materialized nextStep from null to index on any edit (natural-default guard + change listener).
  - Added live progress bar (Test Form) excluding hidden/section/calc; errMsg shown on invalid required fields.
  - Added section and calc rendering: section = read-only heading (no value, skipped in validation/progress/CSV); calc = read-only computed field summing/averaging/etc. numeric sources, recomputed live.
  - parseConfig persists nextStep, errMsg, sources/op/unit; parseSources helper added; typeLabel/typePrefix include section/calc.
- questionnaire.jsp
  - Property panel: Validation Message field, Bulk add options box, Next Step dropdown (real next default + None), section/calc visibility handling, calc sources/op/unit fields, toggle-box hidden for section/calc.
  - Toolbar: Section + Score (+ calc) buttons; Data & Share group (Export JSON, Import JSON, Export CSV, QR Code).
  - JSON import/export + QR modal wired; removed undefined collectProps() calls (pre-existing latent bug).
  - Type dropdown allows converting to/from section/calc.
- survey.css: .sm-section-head / .sm-section-title, readonly calc styling.
- ResponseController.java: GET /response/export/csv (company-scoped, qname-ordered columns).
- QuestionnaireController.java: GET /questionnaire/{id}/qrcode + /qrcode/base64 (reuses ZXing, JSON descriptor).
- AGENTS.md: documented new semantics, endpoints, qtypes.

## Key decisions / findings
- There is no anonymous web-fill URL, so the per-questionnaire QR encodes a JSON descriptor for the Flutter client (mirrors the existing company QR pattern) rather than a clickable respondent link.
- A pre-existing bug: collectProps() was referenced but never defined; both calls removed (would throw at runtime).
- The nextStep null to index materialization was the root cause of "my questionnaire's values changed after an edit" - fixed with a guard.
- Java compiled offline with JDK 1.8 (mvn -o clean compile, exit 0).
- Logic verified with a Node harness loading the real survey.js under a minimal DOM mock: 14/14 checks passed (progress, custom errMsg, section render, calc sum/recompute, progress excludes section/calc, validation skips them, parseConfig round-trip, jump hides target and shows destination).

## Verification
- mvn -o clean compile -> exit 0.
- Node harness survey_phase_test.js -> 14/14 pass.

## Temp files deleted
- C:\Users\Imtiaz\AppData\Local\Temp\opencode\survey_phase_test.js (ephemeral verification harness).

## Follow-up fix: section header hidden in Test Form
- Symptom: the 2nd section header did not appear in Test Form.
- Root cause: `reevaluate` in survey.js hides any question whose index falls inside a
  branching skip range (jump / nextStep). A section placed after such a question was
  being hidden as part of the skipped range.
- Fix: in `reevaluate`, a `section` group's visibility now ignores `skipUntil`
  (branching skips) so the heading always renders as a persistent visual divider;
  it still respects `hidden` and `visibleIf`. Normal questions continue to be skipped
  correctly by jumps/nextStep.
- Verified with Node harness (sec_test.js): with a jump from Q1->Q4 over two sections,
  both sections stay visible while the skipped question (Q3) and the target (Q4) behave
  correctly. (Harness deleted after verification.)

## Feature: questionnaire status (active / inactive)
- Goal: add a `status` field to `questionnaire_master` with values `active`/`inactive`,
  surfaced in the builder list, admin list, and edit forms, with a quick toggle.
- db-schema.sql: added `STATUS VARCHAR(20) NOT NULL DEFAULT 'active'` to
  `questionnaire_master`.
- SchemaInitializer.java: added an always-run, idempotent `ALTER TABLE ... ADD COLUMN`
  migration (tolerates duplicate-column SQLState 1060) so existing databases also gain
  the column without re-init.
- QuestionnaireRepo.java: `STATUS` (COALESCE default 'active') added to all three SELECTs;
  new `updateStatus(id, status)`.
- QuestionnaireController.java: new `POST /questionnaire/update-status` (admin = any
  company; user = own company only; validates active|inactive). `update-details` now also
  persists `status` when supplied. `editQuestionnaire` passes `STATUS` to the view.
- questionnaire_list.jsp: Status column + badge, Activate/Deactivate toggle in actions,
  Status select in edit modal (posted via update-details).
- questionnaire_edit.jsp: Status select pre-selected from model; posted via update-details.
- admin_questionnaires.jsp: Status column + badge + Activate/Deactivate toggle (admin).
- Verification: `mvn -o clean compile` -> BUILD SUCCESS.
- Note: new questionnaires default to `active`; existing rows become `active` via COALESCE
  until toggled (column exists after the migration runs on startup).

## Change: status -> state (boolean), admin cannot toggle
- Renamed questionnaire `STATUS` (VARCHAR) to `STATE TINYINT(1) NOT NULL DEFAULT 1`
  (1=active, 0=inactive) in db-schema.sql to match company_master/agent_master convention.
- SchemaInitializer migration: adds `STATE`, then drops any leftover `STATUS` column
  (idempotent; tolerates missing column on DROP).
- QuestionnaireRepo: SELECTs now use `COALESCE(q.STATE,1) STATE`; `updateStatus(String)` ->
  `updateState(int)` setting `STATE`.
- QuestionnaireController: `POST /questionnaire/update-status` -> `POST /questionnaire/update-state`,
  now **requires ownership** (company match) so admin cannot change it; accepts `state` 0/1.
  `update-details` persists `state` (0/1) when supplied; edit view passes `STATE`.
- questionnaire_list.jsp: boolean `stateBadge`, Activate/Deactivate toggle (owner only) posting
  `update-state`; edit modal Status select uses values 1/0.
- questionnaire_edit.jsp: Status select values 1/0, pre-selected from `STATE`.
- admin_questionnaires.jsp: removed the Activate/Deactivate toggle and its handler entirely
  (admin has no option to change state); Status column now shows a read-only badge only.
- Verification: `mvn -o clean compile` -> BUILD SUCCESS.

## Change: admin sees only active questionnaires
- QuestionnaireRepo: added `findActiveQuestionnaire()` (WHERE STATE = 1).
- QuestionnaireController.index() (/questionnaire/get/all): admin now returns
  `findActiveQuestionnaire()` instead of all rows, so the admin "All Questionnaires"
  view lists only active questionnaires.
- admin_questionnaires.jsp: empty-state text changed to "No active questionnaires found."
- Verification: `mvn -o clean compile` -> BUILD SUCCESS.

## Change: remove Status column from admin view
- admin_questionnaires.jsp: removed the Status column (header, badge cell, and the now
  unused `stateBadge` helper); colspans adjusted to 4. Admin view shows only Company /
  Name / Caption / Description, listing active questionnaires only.
- Verification: frontend-only change (no Java recompile required).

## Feature: unique auto-generated 6-char company key + QR inclusion
- Goal: each company gets a unique 6-character alphanumeric `COMPANY_KEY`, generated on
  creation, backfilled for existing companies, and embedded in the company QR code.
- db-schema.sql: added `COMPANY_KEY VARCHAR(6) DEFAULT NULL` and `UNIQUE KEY UK_COMPANY_KEY`
  to `company_master`.
- SchemaInitializer.java: migration adds `COMPANY_KEY` (idempotent) and `backfillCompanyKeys()`
  generates a unique key for any row with NULL/empty key. Added `keyExists()` +
  `generateCompanyKey()` helpers.
- CompanyRepo.java: `save(name,description,userId,companyKey)` inserts the key;
  `companyKeyExists(key)` for uniqueness; `COMPANY_KEY` added to all SELECTs
  (findById, findByUserId, findAll, findAllWithAgentCount).
- CompanyController.java: `create()` generates a unique 6-char key (retries on collision)
  before saving. `generateCompanyKeyValue()` (6 chars) added. Both QR endpoints
  (`/company/{id}/qrcode`, `/qrcode/base64`) now include `companyKey` in the JSON payload.
  `index()` passes `COMPANY_KEY` to the view.
- company.jsp: exposes `CKEY`, shows "Company Key" in the Company Info panel.
- admin_companies.jsp: added a Key column (and key to search filter); colspan adjusted to 5.
- Verification: `mvn -o clean compile` -> BUILD SUCCESS.

## Feature: auto-create the database if missing (init-schema)
- Goal: when `app.db.init-schema=true`, also CREATE DATABASE IF NOT EXISTS for the
  configured schema name, so a fresh server can be bootstrapped from scratch.
- SchemaInitializer.java: injected `spring.datasource.url/username/password`; new
  `ensureDatabase()` parses host:port + db name from the JDBC URL, opens a server-level
  connection (no database selected), and runs `CREATE DATABASE IF NOT EXISTS <db>
  CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci` before the schema script runs.
- application.properties: added `spring.datasource.hikari.initialization-fail-timeout=0`
  so Hikari does not fail fast at startup (allowing SchemaInitializer to create the DB
  before the pool opens its first connection).
- Verification: `mvn -o clean compile` -> BUILD SUCCESS.

## Change: externalize migrations into db-migration.sql
- Goal: schema migrations should live in a SQL file that `applyMigrations()` simply
  executes — no Java changes needed for future migrations.
- Added `src/main/resources/db-migration.sql` containing idempotent, guarded statements:
  add `questionnaire_master.STATE` (if missing), drop old `STATUS` (if present),
  add `company_master.COMPANY_KEY` (if missing), and backfill missing company keys
  (derived uniquely from `COMPANY_ID` via HEX, zero-padded to 6 uppercase chars).
  Guarding uses `information_schema.COLUMNS` + prepared `ALTER`/`DO 1` so re-runs are safe.
- SchemaInitializer.java: `applyMigrations()` now just runs `db-migration.sql` via
  ResourceDatabasePopulator (separator `;`). Removed the hardcoded helpers
  (addColumnIfMissing, dropColumnIfPresent, backfillCompanyKeys, keyExists,
  generateCompanyKey, isDuplicateColumn) and the `NamedParameterJdbcTemplate` field.
  DB auto-creation (`ensureDatabase`) retained.
- Verification: `mvn -o clean compile` -> BUILD SUCCESS.

## Fix: "script must not be null or empty" crash on startup
- Root cause: `db-migration.sql` had only comment lines (no statements); Spring's
  populator asserts the script is non-empty and aborted startup with
  `IllegalArgumentException: 'script' must not be null or empty`.
- Restored the migration body in `db-migration.sql`; removed the trailing `;` so a
  trailing empty fragment cannot be produced.
- SchemaInitializer.applyMigrations(): now tolerant — skips when the file is missing or
  blank, trims a trailing separator, runs with `setContinueOnError(true)`, and is fully
  wrapped in try/catch so a migration failure (or an empty/comment-only script) can never
  abort application startup. Same safety wrap applied to the db-schema execution.
- Verification: `mvn -o clean compile` -> BUILD SUCCESS.

## Feature: show generated company key in the create form
- Goal: when creating a company, surface the auto-generated 6-char company key in the
  form (read-only, with a Regenerate button) and apply the chosen key on create.
- CompanyController.java: added `GET /company/generate-key` returning a unique 6-char key
  (reuses `generateCompanyKeyValue()` + `companyKeyExists`). `create()` now accepts an
  optional `companyKey`; if provided, unique and non-empty it is used, otherwise a fresh
  unique key is generated server-side.
- company.jsp: "Create Your Company" form now has a read-only Company Key field pre-filled
  via `/company/generate-key` when the panel opens, plus a Regenerate button. The create
  submit posts `companyKey` so the displayed key is applied. Added `genCompanyKey()` client
  fallback (6-char). The key is already shown in the Company Info panel (after reload),
  included in the QR code, and listed in the admin companies view.
- company.jsp: the Company edit form now also shows a read-only Company Key field, populated
  from `CKEY` when "Edit" is clicked (key remains immutable — not submitted on save).
- Verification: `mvn -o clean compile` -> BUILD SUCCESS.

## Change: QR codes use app.base-url instead of request-derived URL
- Goal: the QR code payloads should embed the configured `app.base-url` (e.g.
  http://192.168.0.105:8080/SurveyMaster) rather than reconstructing the URL from the
  incoming request (which is unreliable behind proxies / wrong host).
- CompanyController.java & QuestionnaireController.java: injected `@Value("${app.base-url}")`
  and replaced the `request.getScheme()+...` baseUrl construction with `appBaseUrl` in both
  QR endpoints (PNG + base64) of each controller.
- Verification: `mvn -o clean compile` -> BUILD SUCCESS.

## Change: base-URL fallback to request when app.base-url unset
- Goal: if `app.base-url` is not configured, reconstruct the base URL from the request
  instead of using a hardcoded localhost default. Applies to QR codes AND the forgot-
  password reset email link.
- AppProperty.java: added `@Value("${app.base-url:}")` field and a `protected
  resolveBaseUrl(HttpServletRequest)` helper — returns the configured `app.base-url` when
  present, otherwise rebuilds it from the request (scheme/host/port/contextPath).
- CompanyController.java & QuestionnaireController.java: removed their own `appBaseUrl`
  field; QR endpoints now call `resolveBaseUrl(request)`.
- ForgotPasswordController.java: removed the hardcoded `http://localhost:8080/SurveyMaster`
  default; the reset link now uses `resolveBaseUrl(httpRequest)` (with the request injected
  into the forgot-password POST).
- Verification: `mvn -o clean compile` -> BUILD SUCCESS.

## Fix: agent create used a different key than the one shown in the form
- Symptom: the Create Agent modal displayed a server-generated key (via
  `/agent/generate-token`), but `createAgent` always regenerated a new key on save, so the
  stored key differed from what the user saw.
- CompanyController.createAgent(): now reads `keyValue` from the request; if it is present,
  non-empty and not already in use it is kept, otherwise a fresh unique 4-char key is
  generated. This matches the displayed form key (the modal already posts it).
- Verification: `mvn -o clean compile` -> BUILD SUCCESS.

## UI: kebab (⋮) menu for questionnaire list actions
- questionnaire_list.jsp: replaced the inline Edit / Build / Activate-Deactivate / Delete
  buttons with a Bootstrap dropdown ("⋮" toggle) containing Edit, Build, Activate/Deactivate
  and Delete. The Test button remains a standalone primary button in the Actions cell.
  Buttons keep their original classes (btn-edit / btn-toggle / btn-delete) so the existing
  delegated click handlers still fire from within the menu.
- survey.css: changed `.sm-table-card` from `overflow-x: auto` to `overflow: visible` so
  the dropdown menu is not clipped by the card's overflow box.
- Note: frontend-only change (no Java recompile required). Bootstrap bundle (loaded in the
  page) provides the dropdown behavior.

## UI: move Export CSV & QR Code into the questionnaire list kebab
- questionnaire_list.jsp: added "Export CSV" (`<a class="dropdown-item" href=".../response/export/csv?questionnaireId=ID">`)
  and "QR Code" (`<button class="dropdown-item btn-qr" data-id>`) items into the kebab menu,
  alongside Edit / Build / Activate-Deactivate / Delete. Test remains a standalone button.
  Added an `openQR(id)` helper (fetches `/questionnaire/{id}/qrcode/base64`) plus a delegated
  `.btn-qr` click handler and a `#sm-modal-list-qr` modal.
- questionnaire.jsp: removed the "Export CSV" and "QR Code" toolbar buttons from the builder
  (Export JSON / Import JSON kept). Also removed the now-orphaned `btn-qr` click handler and
  the `#sm-modal-qr` modal from the builder. Verified no remaining references to those ids.
- Note: frontend-only change. QR/CSV are now reached from the list kebab instead of the builder.
