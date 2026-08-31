<%@page contentType="text/html" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<html lang="en">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta charset="utf-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <link rel="icon" type="image/x-icon" href="${STATIC_RES}/images/x-diamond.svg"/>
    <title>${APP_NAME}</title>
    <%@include file="common/resoucelink_css.jsp" %>
    <style>
        .sm-landing {
            max-width: 900px;
            margin: 0 auto;
            padding: .75rem 1rem;
        }

        .sm-landing-hero {
            text-align: center;
            margin-bottom: .75rem;
        }

        .sm-landing-hero h2 {
            font-weight: 700;
            font-size: 1.4rem;
            margin-bottom: .25rem;
            color: #1a1a2e;
        }

        .sm-landing-hero p {
            color: #6c757d;
            font-size: .85rem;
            max-width: 520px;
            margin: 0 auto;
        }

        .sm-hero-actions {
            margin-top: 3.5rem;
        }

        .sm-hero-actions .btn {
            padding: .4rem 1.4rem;
            font-weight: 600;
            font-size: .85rem;
        }

        .sm-features {
            display: flex;
            gap: 1rem;
            flex-wrap: wrap;
            justify-content: center;
        }

        .sm-feature-item {
            flex: 1 1 200px;
            max-width: 260px;
            text-align: center;
            padding: .6rem .5rem;
        }

        .sm-feature-img {
            width: 72px;
            height: 72px;
            margin: 0 auto .5rem;
            border: 2px dashed #cbd5e1;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            background: #f8fafc;
        }

        .sm-feature-img img {
            width: 36px;
            height: 36px;
            opacity: 0.7;
        }

        .sm-feature-item h6 {
            font-weight: 600;
            margin-bottom: .15rem;
            font-size: .8rem;
            color: #1e293b;
        }

        .sm-feature-item p {
            color: #6b7280;
            font-size: .72rem;
            margin: 0;
        }
    </style>
</head>

<body>
<%@include file="common/header_panel.jsp" %>

<div class="sm-wrap">
    <div class="sm-landing">
        <div class="sm-landing-hero">
            <h2>Survey Master</h2>
            <p>Design, configure and test questionnaire forms with conditional logic, branching jumps and a visual flow
                editor.</p>
            <div class="sm-hero-actions">
                <sec:authorize access="isAuthenticated()">
                    <button type="button" class="btn btn-primary" id="btn-readme">ReadMe</button>
                </sec:authorize>
            </div>
        </div>

        <div class="sm-features">
            <div class="sm-feature-item">
                <div class="sm-feature-img">
                    <img src="${STATIC_RES}/images/ui-checks-grid.svg" alt="Questionnaire"/>
                </div>
                <h6>Questionnaire Builder</h6>
                <p>Build forms with drag-and-drop, conditional logic and branching jumps.</p>
            </div>
            <div class="sm-feature-item">
                <div class="sm-feature-img">
                    <img src="${STATIC_RES}/images/x-diamond.svg" alt="Flow Editor"/>
                </div>
                <h6>Visual Flow Editor</h6>
                <p>Design question flows with a visual editor and real-time preview.</p>
            </div>
            <div class="sm-feature-item">
                <div class="sm-feature-img">
                    <img src="${STATIC_RES}/images/ui-checks-grid.svg" alt="Data Collection"/>
                </div>
                <h6>Data Collection</h6>
                <p>Collect responses via API keys, QR codes and mobile devices.</p>
            </div>
        </div>

        <div id="apk-section" style="display:none; max-width:400px; margin:2rem auto 0; text-align:center;">
            <div class="sm-card-panel" style="border:2px dashed #cbd5e1; border-radius:12px; padding:1.5rem;">
                <h6 style="font-weight:700; color:#1e293b; margin-bottom:0.5rem;">Mobile App</h6>
                <p id="apk-info" style="color:#6b7280; font-size:0.85rem; margin-bottom:1rem;"></p>
                <a id="apk-download-btn" class="btn btn-success" href="#" onclick="return handleApkDownload(this);">
                    <span id="apk-dl-text">Download APK</span>
                    <span id="apk-dl-spinner" style="display:none;">
                        <span class="spinner-border spinner-border-sm" role="status"></span> Downloading...
                    </span>
                </a>
            </div>
        </div>

    </div>
</div>

<!-- ReadMe / User Guide modal -->
<div class="sm-modal" id="sm-modal-readme">
    <div class="sm-modal-head"><h5>User Guide</h5><button type="button" class="btn-close sm-modal-close"></button></div>
    <div class="sm-modal-body" style="max-height:70vh; overflow-y:auto;">
        <p style="color:#6b7280; font-size:.85rem; margin-bottom:1rem;">
            A quick reference for setting up and using Survey Master. For the full guide with detailed instructions,
            <a href="${BASE_URL}/user-guide" target="_blank" style="color:#4f46e5;font-weight:600;">open the complete User Guide</a>.
        </p>

        <div style="margin-bottom:1rem; text-align:center;">
            <a href="${BASE_URL}/user-guide" target="_blank" class="btn btn-outline-primary btn-sm">&#128196; Open Full User Guide</a>
            <button type="button" class="btn btn-outline-secondary btn-sm" onclick="window.open('${BASE_URL}/user-guide','_blank').print();">&#128424; Print / Save as PDF</button>
        </div>

        <!-- 1. Create Account -->
        <div style="margin-bottom:1.25rem;">
            <h6 style="font-weight:700; color:#1e293b; border-bottom:2px solid #4f46e5; padding-bottom:4px; margin-bottom:0.5rem;">
                1. Create Account</h6>
            <ol style="font-size:.83rem; color:#374151; padding-left:1.2rem; margin:0;">
                <li>Open the web app and click <strong>Create one</strong> on the login page.</li>
                <li>Enter a username, email, password and confirm password.</li>
                <li>Click <strong>Create Account</strong>. You are redirected to the login page.</li>
            </ol>
        </div>

        <!-- 2. Company Setup -->
        <div style="margin-bottom:1.25rem;">
            <h6 style="font-weight:700; color:#1e293b; border-bottom:2px solid #4f46e5; padding-bottom:4px; margin-bottom:0.5rem;">
                2. Company Setup</h6>
            <ol style="font-size:.83rem; color:#374151; padding-left:1.2rem; margin:0;">
                <li>Navigate to <strong>Companies</strong> (Admin) or <strong>Agents</strong> (User).</li>
                <li>Click <strong>Create Company</strong>, enter a name and optional description.</li>
                <li>A <strong>Company Key</strong> (6-character code) is auto-generated &mdash; this is required for mobile login.</li>
                <li>The <strong>Company QR Code</strong> encodes the server URL + key &mdash; scan it with the mobile app to configure the device.</li>
            </ol>
        </div>

        <!-- 3. Agents -->
        <div style="margin-bottom:1.25rem;">
            <h6 style="font-weight:700; color:#1e293b; border-bottom:2px solid #4f46e5; padding-bottom:4px; margin-bottom:0.5rem;">
                3. Agents</h6>
            <ol style="font-size:.83rem; color:#374151; padding-left:1.2rem; margin:0;">
                <li>On the company page, click <strong>+ Create</strong> in the Agents section.</li>
                <li>An <strong>Agent Key</strong> (4-character token) is auto-generated. Enter a name and expiration date.</li>
                <li>Share the agent key with the collector &mdash; they enter it on the mobile login screen.</li>
                <li>Responses are tagged per agent for reporting and CSV export.</li>
            </ol>
        </div>

        <!-- 4. Build Questionnaire -->
        <div style="margin-bottom:1.25rem;">
            <h6 style="font-weight:700; color:#1e293b; border-bottom:2px solid #4f46e5; padding-bottom:4px; margin-bottom:0.5rem;">
                4. Build Questionnaire</h6>
            <ol style="font-size:.83rem; color:#374151; padding-left:1.2rem; margin:0;">
                <li>Go to <strong>Questionnaires</strong> and click <strong>Create Questionnaire</strong>.</li>
                <li>Click <strong>Build</strong> to open the form editor. Add questions (text, integer, select, checkbox, radio, date, time, binary, section, calculation).</li>
                <li>Use <strong>Branching &amp; Visibility</strong> for conditional logic.</li>
                <li>Click <strong>Test</strong> to preview. When ready, <strong>Activate</strong> and mark as <strong>Published</strong>.</li>
                <li>Generate a <strong>QR Code</strong> per questionnaire for mobile scanning.</li>
            </ol>
        </div>

        <!-- 5. Mobile App -->
        <div style="margin-bottom:1.25rem;">
            <h6 style="font-weight:700; color:#1e293b; border-bottom:2px solid #4f46e5; padding-bottom:4px; margin-bottom:0.5rem;">
                5. Mobile App</h6>
            <ol style="font-size:.83rem; color:#374151; padding-left:1.2rem; margin:0;">
                <li>Install the APK (download from this homepage or share the file).</li>
                <li>Tap the gear icon, scan the <strong>Company QR Code</strong> or enter server URL + key manually.</li>
                <li>Enter the <strong>Company Key</strong> and optional <strong>Agent Key</strong>, tap <strong>Sign In</strong>.</li>
                <li>Tap the download icon to <strong>Load</strong> questionnaires from the server.</li>
                <li>Tap a questionnaire to fill the form. Tap <strong>Save Locally</strong> when done.</li>
                <li>Open Responses (cloud icon), tap <strong>Send All</strong> to sync drafts to the server.</li>
            </ol>
        </div>

        <!-- 6. Data Export -->
        <div style="margin-bottom:0.5rem;">
            <h6 style="font-weight:700; color:#1e293b; border-bottom:2px solid #4f46e5; padding-bottom:4px; margin-bottom:0.5rem;">
                6. Data Export</h6>
            <ol style="font-size:.83rem; color:#374151; padding-left:1.2rem; margin:0;">
                <li>On the web app, go to <strong>Questionnaires</strong>.</li>
                <li>Click the <strong>&#8942;</strong> dropdown on a questionnaire, then <strong>Export CSV</strong>.</li>
                <li>CSV includes: Agent Key, Record Date, Submitted At, and all question answers.</li>
            </ol>
        </div>
    </div>
    <div class="sm-modal-foot">
        <a href="${BASE_URL}/user-guide" target="_blank" class="btn btn-outline-primary btn-sm">Open Full Guide</a>
        <button type="button" class="btn btn-primary sm-modal-close">Close</button>
    </div>
</div>

<!-- About Modal -->
<div class="sm-modal" id="sm-modal-about">
    <div class="sm-modal-head"><h5>About</h5><button type="button" class="btn-close sm-modal-close"></button></div>
    <div class="sm-modal-body" style="text-align:center;">
        <img src="${STATIC_RES}/images/author.jpg" alt="Zakaria Imtiaz"
             style="width:80px; height:80px; border-radius:50%; object-fit:cover; margin-bottom:0.75rem;" />
        <h6 style="font-weight:700; color:#1e293b; margin-bottom:0.15rem;">Zakaria Imtiaz</h6>
        <p style="color:#6b7280; font-size:.8rem; margin-bottom:0.75rem;">Software enthusiast &amp; digital automation practitioner</p>
        <div style="background:#f8f9fa; border-radius:10px; padding:0.85rem; margin-bottom:0.75rem;">
            <p style="color:#475569; font-size:.82rem; line-height:1.55; margin:0;">
                Full-stack developer and AI practitioner specializing in enterprise process automation,
                agentic coding workflows, and scalable retrieval-augmented generation (RAG) architectures.
                Expert in building intelligent backend solutions, orchestrating multi-agent systems,
                and delivering data-driven AI analytics to transform complex enterprise workflows
                into efficient, automated digital systems.
            </p>
        </div>
        <div style="font-size:.8rem; color:#6b7280; margin-bottom:0.75rem;">
            <div style="margin-bottom:0.3rem;">&#128188; Friendship NGO, Dhaka</div>
            <div style="margin-bottom:0.3rem;">&#128187; Java, Spring Boot, Grails, AI</div>
            <div>&#127891; MSCSE, United International University</div>
        </div>
        <div>
            <a href="https://www.linkedin.com/in/imtiaz71985/" target="_blank"
               class="btn btn-outline-primary btn-sm" style="margin-right:0.5rem; font-size:.78rem;">LinkedIn</a>
            <a href="mailto:imtiaz71985@gmail.com"
               class="btn btn-outline-secondary btn-sm" style="font-size:.78rem;">Email</a>
        </div>
    </div>
    <div class="sm-modal-foot">
        <button type="button" class="btn btn-primary sm-modal-close">Close</button>
    </div>
</div>

<%@include file="common/footer.jsp" %>
<%@include file="common/resoucelink_scripts.jsp" %>
<script type="text/javascript">
    document.getElementById("btn-readme").addEventListener("click", function () {
        SM.openModal("sm-modal-readme");
    });

    var headerAbout = document.getElementById("btn-header-about");
    if (headerAbout) {
        headerAbout.addEventListener("click", function (e) {
            e.preventDefault();
            SM.openModal("sm-modal-about");
        });
    }

    var apkDownloading = false;
    function handleApkDownload(el) {
        if (apkDownloading) return false;
        apkDownloading = true;
        document.getElementById('apk-dl-text').style.display = 'none';
        document.getElementById('apk-dl-spinner').style.display = '';
        el.classList.add('disabled');
        el.setAttribute('aria-disabled', 'true');
        setTimeout(function () {
            apkDownloading = false;
            document.getElementById('apk-dl-text').style.display = '';
            document.getElementById('apk-dl-spinner').style.display = 'none';
            el.classList.remove('disabled');
            el.removeAttribute('aria-disabled');
        }, 5000);
        return true;
    }
    (function () {
        var BASE = '${BASE_URL}';
        SM.get(BASE + '/apk/get/latest').then(function (resp) {
            if (resp.code === 200 && resp.body && resp.body.APK_ID) {
                var apk = resp.body;
                var size = apk.FILE_SIZE ? (apk.FILE_SIZE / (1024 * 1024)).toFixed(1) + ' MB' : '';
                var version = apk.VERSION ? ' v' + apk.VERSION : '';
                document.getElementById('apk-info').textContent = apk.ORIGINAL_NAME + version + (size ? ' (' + size + ')' : '');
                document.getElementById('apk-download-btn').href = BASE + '/apk/download/' + apk.APK_ID;
                document.getElementById('apk-section').style.display = 'block';
            }
        });
    })();
</script>
</body>
</html>
