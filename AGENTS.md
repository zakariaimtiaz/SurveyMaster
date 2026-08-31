# AGENTS.md — SurveyMaster

Spring Boot 2.0.2 (war packaging) questionnaire form-builder: JSP views + vanilla JS frontend (Bootstrap 5, no jQuery, no build step). Includes a Flutter mobile client (`mobile/`) for offline data collection.

## Commands

```bash
mvn clean package -DskipTests   # build war -> target/SurveyMaster-1.0.1.war
mvn clean compile               # compile check only
```

- No test suite in use (`-DskipTests` is normal; `AppTests` exists but is not maintained).
- Run: **JDK 1.8 required** (`C:\Program Files\Java\jdk1.8.0_121`). Spring Boot 2.0.2 + CGLIB hard-fails on JDK 11+ ("Cannot load configuration class").
- Dev run (IntelliJ or CLI) uses profile `dev`: add `--spring.profiles.active=dev`. Without it, production caching applies (12h static cache, no JSP hot-reload).
- Port 8080 with context path `/SurveyMaster` (e.g. `http://localhost:8080/SurveyMaster/`).

## Hot reload (dev profile only)

- JSPs recompile automatically (`server.servlet.jsp.init-parameters.development=true`) — just refresh browser.
- CSS/JS/images under `src/main/webapp/resources/` are served straight from source via `WebConfig` (`file:` location + `no-store`) — edit and refresh; no rebuild.
- Java changes need a rebuild to trigger devtools restart.

## Architecture

- `src/main/java/com/imtiaz/` — `App` (entry), controllers (`LoginController`, `RegistrationController`, `AuthController`, `QuestionnaireController`, `CompanyController`, `ResponseController`), repos (`QuestionnaireRepo`, `CompanyRepo`, `AgentRepo`, `ApkRepo`, `ResponseRepo`, `SecUserRepo`, `SecRoleRepo`), shared `AppProperty` (injects `BASE_URL`/`STATIC_RES` into all views), `AppResponse` (JSON envelope `{code, message, body}`), `SchemaInitializer` (runs `db-schema.sql` on startup when `app.db.init-schema=true`).
- Security: `com.imtiaz.security` — `SecurityConfig` (hardcoded 2-role URL auth), `CustomUserDetailsService` (loads users from `sec_user`/`sec_role` tables). Model classes in `com.imtiaz.model` (`SecUser`, `SecRole`).
- Views are **JSPs** in `src/main/webapp/view/` served through ViewResolver (`/view/*.jsp`). Shared includes in `view/common/`.
- Static assets: `resources/js/`, `resources/css/`, `resources/images/` — keep this split (a legacy `js-css/` folder was purged twice; never reintroduce it). Only these files exist and are used:
  - js: `bootstrap.bundle.min.js`, `jsplumb.min.js`, `survey.js`
  - css: `bootstrap.min.css`, `survey.css`
  - images: `logo.png`, `ui-checks-grid.svg`, `x-diamond.svg`
- DB: MySQL 8 via `mysql-connector-java:8.0.33` (`com.mysql.cj.jdbc.Driver`). Config in `application.properties`; tables: `questionnaire_master` (`QUESTIONNAIRE_ID, NAME, CAPTION, DESCRIPTION, CONF_DATA, COMPANY_ID`), `company_master` (`COMPANY_ID, NAME, DESCRIPTION, STATE, USER_ID`), `agent_master` (`AGENT_ID, COMPANY_ID, KEY_VALUE, NAME, EXPIRATION, STATUS`), `response_master` (`RESPONSE_ID, QUESTIONNAIRE_ID, COMPANY_ID, AGENT_ID, RESPONSE_DATA, SUBMITTED_AT`), `apk_master` (`APK_ID, ORIGINAL_NAME, FILE_SIZE, FILE_DATA, UPLOADED_BY, UPLOADED_AT`), `sec_user` (`id, username, email, password, enabled, account_expired, account_locked, password_expired, default_target_url`), `sec_role` (`id, authority, name, active`), `sec_user_sec_role` (`sec_user_id, sec_role_id`).
- Schema init: `src/main/resources/db-schema.sql` contains all CREATE TABLE + seed data. Toggle with `app.db.init-schema=true|false` in `application.properties` (default false). `SchemaInitializer` (`CommandLineRunner`) executes the SQL on startup when enabled. Uses `IF NOT EXISTS` / `INSERT IGNORE` so it's safe to re-run.
- Multi-tenancy: `company_master.USER_ID` links each company to exactly one user (UNIQUE constraint). All controllers scope queries to the logged-in user's company via `currentCompanyId()` resolving through SecurityContext → SecUserRepo → CompanyRepo.

## Flutter mobile client (`mobile/`)

- Flutter 3.x project for Android + iOS, offline-first questionnaire client.
- Dependencies: `http`, `sqflite`, `shared_preferences`, `intl`.
- Flow: Settings (URL + API Key) → Questionnaire List → Fill Form (dynamic fields from JSON config) → Save locally (SQLite) → Send to server (POST /response/submit).
- Key files: `lib/services/api_service.dart` (HTTP layer), `lib/services/database_service.dart` (SQLite), `lib/screens/form_fill_screen.dart` (dynamic form renderer), `lib/widgets/dynamic_field.dart` (field builder per qtype).
- Build: `flutter pub get && flutter run` (requires Flutter SDK installed).
- API key validation: `POST /response/submit` with `{ apiKey, questionnaireId, responses[] }`.

## Questionnaire builder (the core feature)

- All question config lives as JSON in `CONF_DATA`: keys `question1..N` → `{qtype, caption, hint, qname, required, hidden, readonly, savable, options[], mediaType, placeholder/min/max/step/pattern/minlength/maxlength/value/title, visibleIf{target,op,value}, jump{target,op,value,elseTarget}, pos{top,left}}`.
- `target` indexes in `visibleIf`/`jump` are **numeric question positions**, not names — when reordering/deleting questions, remap them or null the rule (see `moveQ`/delete handler in `questionnaire.jsp`).
- Builder page = List View ⇄ Flow View sharing ONE property panel and ONE card renderer (`questionCardHtml(i, opts)` in `questionnaire.jsp`) — never fork card markup between views.
- Flow View uses **jsPlumb**: gray bezier = sequential chain, red = jumps, green dashed = conditions (show-if). Node HTML must be passed as the **8th argument** of `addNode(name,in,out,x,y,class,data,html)` (passing earlier silently renders blank nodes — past bug).
- Fill/test engine lives in `resources/js/survey.js` (`SM.*`): sequential evaluation where a matching `jump` skips to target (backward jumps rewind, cycle-guarded at 25); hidden questions render as invisible inputs so rule indexes stay stable.
- Shared helpers (escape, AJAX, modals, confirm, toast) are in `survey.js`; use them instead of adding libraries.

## Gotchas

- `AppResponse.build(...)` returns the envelope; clients check `resp.code === 200`.
- Repo methods may return `null` for missing rows (`findByQuestionnaireId`) — controllers must handle it (redirect home), else 500.
- Spring Security hardcodes URL rules in `SecurityConfig`: login/register/access-denied/response/submit = permitAll, /admin/** = ROLE_ADMIN, everything else = authenticated. Login page at `/login`, registration at `/register`.
- Two roles only: `ROLE_ADMIN` (full access) and `ROLE_USER` (own company data, enforced at controller level via `currentCompanyId()`).
- Existing `admin` user uses BCrypt password hash (DelegatingPasswordEncoder handles it). New registrations also use BCrypt. Admin password: `123`.
- `/response/submit` is anonymous (for Flutter API key auth) but other `/response/**` endpoints require authentication.
- Boot 2.0 property names differ from modern Spring: `spring.resources.cache.period` (not `cache-period`), `server.servlet.jsp.init-parameters.*` (not `server.jsp-servlet.*`).
- `logging.file=F:/LOGS/SurveyMaster/surveyMaster.log` in application.properties assumes an F: drive.
- When testing REST endpoints live, always create a throwaway questionnaire and delete it afterwards — do not write test data into real records.
- QR codes are generated using ZXing (`com.google.zxing:core:3.5.1`). Download endpoint: `GET /company/{companyId}/qrcode` (PNG). Base64 endpoint: `GET /company/{companyId}/qrcode/base64`.
- API key tokens are auto-generated as 4-character uppercase alphanumeric strings (e.g. `X9B2`). Server-side generation via `GET /company/{companyId}/apikey/generate-token`. Uniqueness guaranteed within the company.
- Each user can create exactly one company (enforced by `UNIQUE(USER_ID)` on `company_master` + `hasCompany()` check). Company is auto-linked to the creating user.
- All questionnaire, API key, and response endpoints are scoped to the logged-in user's company. Cross-tenant access is blocked at the controller level.
- Per-questionnaire QR codes reuse ZXing: `GET /questionnaire/{id}/qrcode` (PNG) and `/questionnaire/{id}/qrcode/base64`. Content is a JSON descriptor `{"url","questionnaireId","type":"questionnaire"}` for the Flutter client (there is no anonymous web-fill URL in this app).
- CSV export: `GET /response/export/csv?questionnaireId=...` (authenticated, company-scoped) returns a `text/csv` download. Columns = `Response ID, Submitted At` + one column per question `qname` (ordered from CONF_DATA).
- JSON import/export in the builder: Export downloads `questionnaire_{id}.json` (the questions object); Import reads a file and replaces the builder's `questions` via `SM.parseConfig` (user must Save).
- Builder question types now include `section` (read-only heading, no value, excluded from progress/validation/CSV) and `calc` (read-only computed field: `sources` = list of qnames, `op` = sum|avg|count|min|max, optional `unit`). The score recomputes live on every input.

## Questionnaire builder (the core feature)

- All question config lives as JSON in `CONF_DATA`: keys `question1..N` → `{qtype, caption, hint, qname, required, hidden, readonly, savable, mediaType, placeholder/min/max/step/pattern/minlength/maxlength/value/title, visibleIf{target,op,value}, jump{target,op,value,elseTarget}, nextStep, errMsg, sources, op, unit}`.
- `nextStep` semantics: integer index = explicit flow target; `-1` = "None" (no connector); `null` = legacy sequential. The Next Step dropdown in the property panel lists every other question (default = real next sequential) plus a `None` option. On move/delete/duplicate, rules (visibleIf/jump/nextStep) are remapped by index. A natural-default guard in `syncFromForm` prevents silently materializing `null`→index on unrelated edits.
- `errMsg` overrides the default "This field is required." message on an invalid required field.
- Bulk option entry: type `value|caption` lines in the property panel "Bulk add" box and click Apply; options are stored as `{value, caption}`.
- Flow View connectors: gray `#adb5bd` = sequential next (default), red `#DA4F49` = jump, green dashed `#5BB75B` = condition (show-if). The helper hint with colored swatches shows on initial load.
- A live progress bar (Test Form only) counts visible, non-hidden, non-section, non-calc questions that have a value.
- `SM.*` helpers (escape, AJAX, modals, confirm, toast, `parseConfig`, `buildConfig`, `renderForm`, `hasOptions`, `opsForType`, `typeLabel`, `parseSources`) live in `survey.js`; use them instead of adding libraries.

## Working Rules

1. **Rephrase before acting**: When the user asks to do something, first rephrase what you understand from their request and seek permission to proceed before making any changes.
2. **Explain then do**: At every step, briefly explain what you are about to do, then do it. This keeps the user informed with clear understanding of each action.
3. **No silent changes**: Never make changes without the user seeing what changed and why.

## Conventions

- Frontend is vanilla ES5-style JS with explicit DOM sync (state ↔ DOM via `syncFromForm` / render functions); do not reintroduce jQuery or add frameworks/build tooling.
- Escape all user data with `SM.escapeHtml` before injecting into DOM strings.
- New endpoints follow `AppResponse` envelope pattern and live in `QuestionnaireController`, `CompanyController`, or `ResponseController`.
- Security: use `<sec:authorize>` tags in JSPs for role-based UI; never expose admin-only links to regular users.
- Update `WORKLOG.md` after completing a task (append task summary: changes, root causes, verification).
