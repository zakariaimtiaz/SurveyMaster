<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<html lang="en">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <link rel="icon" type="image/x-icon" href="${STATIC_RES}/images/x-diamond.svg" />
    <title>User Guide - ${APP_NAME}</title>
    <%@include file="common/resoucelink_css.jsp" %>
    <style>
        body { background: #f8fafc; }
        .guide-wrap { max-width: 860px; margin: 0 auto; padding: 2rem 1.5rem; }
        .guide-header { text-align: center; margin-bottom: 2rem; }
        .guide-header h1 { font-size: 2rem; font-weight: 800; color: #1a1a2e; margin-bottom: .25rem; }
        .guide-header p { color: #6b7280; font-size: .95rem; }
        .guide-header .version { display: inline-block; background: #eef2ff; color: #4f46e5; font-size: .75rem; font-weight: 600; padding: .2rem .6rem; border-radius: 20px; margin-top: .5rem; }
        .guide-actions { text-align: center; margin-bottom: 2rem; }
        .guide-actions .btn { margin: 0 .25rem; }

        .toc { background: #fff; border: 1px solid #e5e7eb; border-radius: 12px; padding: 1.5rem; margin-bottom: 2.5rem; }
        .toc h3 { font-size: 1rem; font-weight: 700; color: #1e293b; margin-bottom: .75rem; }
        .toc ol { padding-left: 1.25rem; margin: 0; }
        .toc li { margin-bottom: .35rem; }
        .toc a { color: #4f46e5; text-decoration: none; font-size: .9rem; }
        .toc a:hover { text-decoration: underline; }

        .section { background: #fff; border: 1px solid #e5e7eb; border-radius: 12px; padding: 1.75rem; margin-bottom: 1.5rem; page-break-inside: avoid; }
        .section h2 { font-size: 1.25rem; font-weight: 700; color: #1e293b; border-bottom: 2px solid #4f46e5; padding-bottom: .4rem; margin-bottom: 1rem; }
        .section h3 { font-size: 1.05rem; font-weight: 600; color: #334155; margin: 1.25rem 0 .5rem; }
        .section p, .section li { font-size: .9rem; color: #374151; line-height: 1.6; }
        .section ol, .section ul { padding-left: 1.25rem; }
        .section li { margin-bottom: .4rem; }

        .tip { background: #f0fdf4; border-left: 4px solid #22c55e; padding: .75rem 1rem; border-radius: 0 8px 8px 0; margin: .75rem 0; font-size: .85rem; color: #166534; }
        .warn { background: #fefce8; border-left: 4px solid #eab308; padding: .75rem 1rem; border-radius: 0 8px 8px 0; margin: .75rem 0; font-size: .85rem; color: #854d0e; }
        .info { background: #eff6ff; border-left: 4px solid #3b82f6; padding: .75rem 1rem; border-radius: 0 8px 8px 0; margin: .75rem 0; font-size: .85rem; color: #1e40af; }
        code { background: #f1f5f9; padding: .15rem .4rem; border-radius: 4px; font-size: .85rem; color: #be185d; }
        .step-num { display: inline-block; width: 24px; height: 24px; background: #4f46e5; color: #fff; border-radius: 50%; text-align: center; line-height: 24px; font-size: .75rem; font-weight: 700; margin-right: .4rem; }
        .field-table { width: 100%; border-collapse: collapse; margin: .75rem 0; font-size: .85rem; }
        .field-table th { background: #f1f5f9; text-align: left; padding: .5rem .75rem; font-weight: 600; color: #334155; border: 1px solid #e2e8f0; }
        .field-table td { padding: .5rem .75rem; border: 1px solid #e2e8f0; color: #475569; }
        .two-col { display: flex; gap: 1.5rem; flex-wrap: wrap; }
        .two-col > div { flex: 1 1 320px; }
        .flow-diagram { background: #f8fafc; border: 1px dashed #cbd5e1; border-radius: 10px; padding: 1.25rem; text-align: center; margin: 1rem 0; font-size: .85rem; color: #475569; }
        .flow-diagram .arrow { color: #4f46e5; font-weight: 700; margin: 0 .3rem; }

        @media print {
            body { background: #fff; }
            .no-print { display: none !important; }
            .guide-actions { display: none !important; }
            .section { border: 1px solid #ddd; box-shadow: none; page-break-inside: avoid; }
            .toc { page-break-after: always; }
        }
    </style>
</head>

<body>
<%@include file="common/header_panel.jsp" %>

<div class="guide-wrap">
    <div class="guide-header">
        <h1>Survey Master User Guide</h1>
        <p>Complete guide to setting up and using Survey Master &mdash; from account creation to field data collection.</p>
        <span class="version">v1.0</span>
    </div>

    <div class="guide-actions no-print">
        <a href="${BASE_URL}/" class="btn btn-outline-secondary btn-sm">&larr; Back to Home</a>
        <button type="button" class="btn btn-primary btn-sm" onclick="window.print();">&#128424; Print / Save as PDF</button>
    </div>

    <!-- Table of Contents -->
    <div class="toc">
        <h3>Table of Contents</h3>
        <ol>
            <li><a href="#overview">Overview</a></li>
            <li><a href="#create-account">Create Account</a></li>
            <li><a href="#sign-in">Sign In</a></li>
            <li><a href="#company">Company Setup</a></li>
            <li><a href="#agents">Agents</a></li>
            <li><a href="#questionnaire">Building a Questionnaire</a></li>
            <li><a href="#questionnaire-qr">Questionnaire QR Code</a></li>
            <li><a href="#mobile-setup">Mobile App &mdash; First-Time Setup</a></li>
            <li><a href="#mobile-login">Mobile App &mdash; Sign In</a></li>
            <li><a href="#mobile-load">Loading Questionnaires on Mobile</a></li>
            <li><a href="#mobile-fill">Filling a Form on Mobile</a></li>
            <li><a href="#mobile-responses">Drafts &amp; Sent Responses</a></li>
            <li><a href="#mobile-settings">Mobile Settings</a></li>
            <li><a href="#data-export">Data Collection &amp; CSV Export</a></li>
            <li><a href="#faq">FAQ</a></li>
        </ol>
    </div>

    <!-- 1. Overview -->
    <div class="section" id="overview">
        <h2>1. Overview</h2>
        <p>Survey Master is a two-part system for designing, deploying and collecting data with questionnaires:</p>
        <div class="two-col">
            <div>
                <h3>Web App (Admin)</h3>
                <ul>
                    <li>Create and manage companies</li>
                    <li>Design questionnaires with conditional logic and branching</li>
                    <li>Create agent accounts for field collectors</li>
                    <li>View and export collected responses as CSV</li>
                    <li>Upload and distribute the mobile APK</li>
                </ul>
            </div>
            <div>
                <h3>Mobile App (Field)</h3>
                <ul>
                    <li>Offline-first: fill forms without internet</li>
                    <li>Sync responses to the server when online</li>
                    <li>Supports text, numbers, dates, selects, checkboxes, file uploads and calculated fields</li>
                    <li>Conditional visibility and branching jumps</li>
                    <li>Per-agent data tagging</li>
                </ul>
            </div>
        </div>
        <div class="flow-diagram">
            <strong>Web App:</strong> Create Account <span class="arrow">&rarr;</span> Create Company <span class="arrow">&rarr;</span> Create Agents <span class="arrow">&rarr;</span> Build Questionnaire <span class="arrow">&rarr;</span> Generate QR
            <br/><br/>
            <strong>Mobile App:</strong> Scan Company QR <span class="arrow">&rarr;</span> Sign In <span class="arrow">&rarr;</span> Load Questionnaires <span class="arrow">&rarr;</span> Fill Forms <span class="arrow">&rarr;</span> Sync to Server
        </div>
    </div>

    <!-- 2. Create Account -->
    <div class="section" id="create-account">
        <h2>2. Create Account</h2>
        <p>Before using Survey Master you need a web admin account. This account is used to manage companies, questionnaires and agents through the web interface.</p>
        <ol>
            <li>Open the Survey Master web app in your browser.</li>
            <li>On the login page, click <strong>Create one</strong> (below the Sign In button).</li>
            <li>Fill in the <strong>Create Account</strong> form:
                <table class="field-table">
                    <tr><th>Field</th><th>Description</th></tr>
                    <tr><td><strong>Username</strong></td><td>Choose a unique username for login.</td></tr>
                    <tr><td><strong>Email</strong></td><td>Your email address (used for password reset).</td></tr>
                    <tr><td><strong>Password</strong></td><td>Minimum 3 characters. Must match the confirm field.</td></tr>
                    <tr><td><strong>Confirm Password</strong></td><td>Re-enter your password to confirm.</td></tr>
                </table>
            </li>
            <li>Click <strong>Create Account</strong>. On success you are redirected to the login page.</li>
        </ol>
        <div class="tip"><strong>Tip:</strong> The first account created has ADMIN privileges. Subsequent accounts are USER role by default.</div>
    </div>

    <!-- 3. Sign In -->
    <div class="section" id="sign-in">
        <h2>3. Sign In (Web)</h2>
        <ol>
            <li>Enter your <strong>Username</strong> and <strong>Password</strong>.</li>
            <li>Click <strong>Sign In</strong>.</li>
            <li>If you forgot your password, click <strong>Forgot Password?</strong>, enter your username, and a reset link will be emailed to you.</li>
        </ol>
        <h3>User Roles</h3>
        <table class="field-table">
            <tr><th>Role</th><th>Access</th></tr>
            <tr><td><strong>ADMIN</strong></td><td>Home, Companies, Questionnaires, APK</td></tr>
            <tr><td><strong>USER</strong></td><td>Home, Questionnaires, Agents</td></tr>
        </table>
    </div>

    <!-- 4. Company Setup -->
    <div class="section" id="company">
        <h2>4. Company Setup</h2>
        <p>A company is the top-level entity. All questionnaires, agents and responses belong to a company. Each company has a unique <strong>Company Key</strong> used by the mobile app to authenticate.</p>

        <h3>Creating a Company</h3>
        <ol>
            <li>Navigate to <strong>Companies</strong> (ADMIN) or <strong>Agents</strong> (USER) from the navigation bar.</li>
            <li>If no company exists yet, you will see the <strong>Create Your Company</strong> form.
                <table class="field-table">
                    <tr><th>Field</th><th>Required</th><th>Description</th></tr>
                    <tr><td><strong>Name</strong></td><td>Yes</td><td>Company name (max 200 characters).</td></tr>
                    <tr><td><strong>Description</strong></td><td>No</td><td>Brief description of the company.</td></tr>
                    <tr><td><strong>Company Key</strong></td><td>Auto</td><td>Auto-generated 6-character uppercase alphanumeric key. Click <strong>Regenerate</strong> to get a new one before creating.</td></tr>
                </table>
            </li>
            <li>Click <strong>Create Company</strong>.</li>
        </ol>

        <h3>Company Info</h3>
        <p>After creation you can view and edit the company name and description. The Company Key is displayed here.</p>

        <h3>Company QR Code</h3>
        <p>A QR code is generated automatically for your company. It encodes the <strong>server URL</strong> and <strong>Company Key</strong> so the mobile app can be configured by scanning it.</p>
        <ul>
            <li><strong>View</strong> &mdash; opens the QR code in a larger modal.</li>
            <li><strong>Regenerate</strong> &mdash; generates a new Company Key and QR code. Any mobile device using the old key will need to re-scan the new QR code.</li>
        </ul>
        <div class="warn"><strong>Warning:</strong> Regenerating the company key invalidates the old key. Mobile devices using the old key will lose access until they scan the new QR code or are reconfigured.</div>
    </div>

    <!-- 5. Agents -->
    <div class="section" id="agents">
        <h2>5. Agents</h2>
        <p>Agents are field data collectors. Each agent is assigned to a company and receives a unique <strong>Agent Key</strong> used for mobile login and response tagging.</p>

        <h3>Creating an Agent</h3>
        <ol>
            <li>On the company page, click <strong>+ Create</strong> in the Agents section.</li>
            <li>Fill in the agent details:
                <table class="field-table">
                    <tr><th>Field</th><th>Required</th><th>Description</th></tr>
                    <tr><td><strong>Key</strong></td><td>Auto</td><td>Auto-generated 4-character uppercase alphanumeric token. Click <strong>Regenerate</strong> for a new one.</td></tr>
                    <tr><td><strong>Name</strong></td><td>Yes</td><td>Agent's name or label (e.g. collector's name).</td></tr>
                    <tr><td><strong>Expiration</strong></td><td>Yes</td><td>Date when the agent key expires.</td></tr>
                </table>
            </li>
            <li>Click <strong>Create</strong>.</li>
        </ol>

        <h3>Managing Agents</h3>
        <ul>
            <li><strong>Copy Key</strong> &mdash; click the copy icon next to an agent key to copy it to clipboard.</li>
            <li><strong>Edit</strong> &mdash; change the name, expiration, or active/inactive status.</li>
            <li><strong>Delete</strong> &mdash; permanently remove the agent. Previously collected responses are preserved.</li>
        </ul>
        <div class="info"><strong>Note:</strong> Deactivating an agent prevents new mobile logins with that key but does not affect previously collected data.</div>
    </div>

    <!-- 6. Building a Questionnaire -->
    <div class="section" id="questionnaire">
        <h2>6. Building a Questionnaire</h2>

        <h3>Creating a Questionnaire</h3>
        <ol>
            <li>Navigate to <strong>Questionnaires</strong> from the navigation bar.</li>
            <li>Click <strong>Create Questionnaire</strong>.</li>
            <li>Enter a <strong>Name</strong> (required) and optional Caption and Description.</li>
            <li>Click <strong>Save</strong>. The new questionnaire appears in the list.</li>
        </ol>

        <h3>Adding Questions</h3>
        <ol>
            <li>Click <strong>Build</strong> on the questionnaire to open the form editor.</li>
            <li>Click <strong>+ Add Question</strong> and choose a question type:</li>
        </ol>
        <table class="field-table">
            <tr><th>Type</th><th>Description</th></tr>
            <tr><td><strong>String</strong></td><td>Single-line text input.</td></tr>
            <tr><td><strong>Integer</strong></td><td>Whole number input.</td></tr>
            <tr><td><strong>Text Area</strong></td><td>Multi-line text input.</td></tr>
            <tr><td><strong>Date</strong></td><td>Date picker.</td></tr>
            <tr><td><strong>Time</strong></td><td>Time picker.</td></tr>
            <tr><td><strong>Select</strong></td><td>Multi-choice dropdown (select multiple options).</td></tr>
            <tr><td><strong>Select1 / Radio</strong></td><td>Single-choice radio buttons.</td></tr>
            <tr><td><strong>Checkbox</strong></td><td>Multi-choice checkboxes.</td></tr>
            <tr><td><strong>Binary</strong></td><td>File upload field.</td></tr>
            <tr><td><strong>Section</strong></td><td>Visual divider / section header (not an input).</td></tr>
            <tr><td><strong>Calculation</strong></td><td>Auto-computed value from other numeric fields (sum, avg, count, min, max).</td></tr>
        </table>

        <h3>Question Settings</h3>
        <p>For each question you can configure:</p>
        <ul>
            <li><strong>Caption</strong> &mdash; the label shown to the user.</li>
            <li><strong>Question Name (qname)</strong> &mdash; internal identifier used in CSV export and branching logic.</li>
            <li><strong>Hint</strong> &mdash; helper text shown below the caption.</li>
            <li><strong>Required</strong> &mdash; if checked, the user must answer before proceeding.</li>
            <li><strong>Read Only</strong> &mdash; displays the field but prevents editing.</li>
            <li><strong>Options</strong> &mdash; for Select, Select1, Radio, and Checkbox types. Each option has a Value and a Caption.</li>
        </ul>

        <h3>Branching &amp; Visibility</h3>
        <p>Use the <strong>Branching &amp; Visibility</strong> tab to add conditional logic:</p>
        <ul>
            <li><strong>Visibility Rule</strong> &mdash; show or hide this question based on the answer to another question. E.g. show "Other" text field only when "Other" is selected in a checkbox.</li>
            <li><strong>Jump To</strong> &mdash; when this question is answered, jump to a specific question (skip irrelevant sections).</li>
        </ul>
        <div class="tip"><strong>Tip:</strong> Use the <strong>Test</strong> button on the questionnaire list to preview the form with conditional logic in the browser before deploying.</div>

        <h3>Activating &amp; Publishing</h3>
        <ul>
            <li><strong>Activate / Deactivate</strong> &mdash; only active questionnaires are available for mobile data collection.</li>
            <li><strong>Published</strong> &mdash; published &amp; active questionnaires appear when the mobile app loads from the server. Unpublished questionnaires are hidden from the mobile app.</li>
        </ul>
    </div>

    <!-- 7. Questionnaire QR Code -->
    <div class="section" id="questionnaire-qr">
        <h2>7. Questionnaire QR Code</h2>
        <p>Each questionnaire has its own QR code that encodes the questionnaire ID. Scanning it with the mobile app loads that specific questionnaire for offline data collection.</p>
        <ol>
            <li>On the questionnaire list, click the <strong>&#8942;</strong> (More Actions) dropdown.</li>
            <li>Click <strong>QR Code</strong>.</li>
            <li>A modal shows the QR code. You can print it or share the image with field collectors.</li>
        </ol>
    </div>

    <!-- 8. Mobile App - First-Time Setup -->
    <div class="section" id="mobile-setup">
        <h2>8. Mobile App &mdash; First-Time Setup</h2>
        <p>On first launch the app shows a <strong>First-time setup</strong> screen. You need the server URL and Company Key from the web app.</p>

        <h3>Option A: Scan Company QR Code (Recommended)</h3>
        <ol>
            <li>Tap <strong>Configure with QR or Manual setup</strong> (or the gear icon in the app bar).</li>
            <li>Grant camera permission when prompted.</li>
            <li>Point the camera at the <strong>Company QR Code</strong> displayed on the web app (from the Agents / Company page).</li>
            <li>The app automatically fills in the Server URL and Company Key.</li>
        </ol>

        <h3>Option B: Manual Entry</h3>
        <ol>
            <li>Tap <strong>Configure with QR or Manual setup</strong> (or the gear icon).</li>
            <li>Enter the <strong>Server URL</strong> (e.g. <code>http://192.168.1.100:8080/SurveyMaster</code>).</li>
            <li>Enter the <strong>Company Key</strong> (6-character code from the web app).</li>
            <li>Optionally enter a <strong>Company Name</strong> for display.</li>
            <li>Tap <strong>Connect &amp; Save</strong>.</li>
        </ol>
        <div class="warn"><strong>Important:</strong> The mobile device must be on the same network as the server, or the server must be accessible over the internet.</div>
    </div>

    <!-- 9. Mobile App - Sign In -->
    <div class="section" id="mobile-login">
        <h2>9. Mobile App &mdash; Sign In</h2>
        <p>After setup, the login screen appears. Enter credentials to access the app.</p>
        <table class="field-table">
            <tr><th>Field</th><th>Required</th><th>Description</th></tr>
            <tr><td><strong>Company Key</strong></td><td>Yes</td><td>The 6-character key from the web app. Must match the configured company.</td></tr>
            <tr><td><strong>Agent Key</strong></td><td>No</td><td>The 4-character agent token. If assigned, your responses will be tagged with your agent key. Leave blank if not assigned.</td></tr>
        </table>
        <ol>
            <li>Enter the <strong>Company Key</strong>.</li>
            <li>If you are a designated field collector, enter your <strong>Agent Key</strong>.</li>
            <li>Tap <strong>Sign In</strong>.</li>
        </ol>
        <div class="info"><strong>Note:</strong> The login session persists across app relaunches. You only need to sign in again after tapping <strong>Sign out</strong>.</div>
    </div>

    <!-- 10. Loading Questionnaires on Mobile -->
    <div class="section" id="mobile-load">
        <h2>10. Loading Questionnaires on Mobile</h2>
        <p>Before filling forms you need to load questionnaires from the server. There are two ways:</p>

        <h3>Load All (Recommended)</h3>
        <ol>
            <li>Tap the <strong>download icon</strong> (&#8615;) in the app bar.</li>
            <li>Confirm the load. The app fetches all published &amp; active questionnaires and their configurations from the server.</li>
            <li>It also pulls any existing responses for your company/agent from the server and merges them into local storage.</li>
        </ol>

        <h3>Load Single Questionnaire (QR Scan)</h3>
        <ol>
            <li>On the main screen, tap the <strong>QR scanner icon</strong> in the header.</li>
            <li>Scan the questionnaire's QR code (from the web app's questionnaire list).</li>
            <li>The specific questionnaire is loaded and added to your list.</li>
        </ol>
        <div class="tip"><strong>Tip:</strong> The header shows your Company name, Agent name (if set), and when questionnaires were last cached.</div>
    </div>

    <!-- 11. Filling a Form on Mobile -->
    <div class="section" id="mobile-fill">
        <h2>11. Filling a Form on Mobile</h2>
        <ol>
            <li>Tap a questionnaire from the list to open the form.</li>
            <li>Fill in the questions. Required fields are marked with <strong>*</strong>.</li>
            <li>Use <strong>Next</strong> / <strong>Back</strong> buttons if the form is set to display one question at a time or custom page size (configurable in Settings).</li>
            <li>When finished, tap <strong>Save Locally</strong> to store the response on the device.</li>
        </ol>

        <h3>Form Display Modes</h3>
        <p>Configured in <strong>Settings &gt; Form display</strong>:</p>
        <table class="field-table">
            <tr><th>Mode</th><th>Description</th></tr>
            <tr><td><strong>All at once</strong></td><td>Every question on one scrolling page (default).</td></tr>
            <tr><td><strong>One by one</strong></td><td>A single question per screen with Next / Back.</td></tr>
            <tr><td><strong>Custom (N at a time)</strong></td><td>A fixed number of questions per screen (configurable page size).</td></tr>
        </table>

        <h3>Supported Field Types</h3>
        <ul>
            <li><strong>Text / Integer / Text Area</strong> &mdash; standard input fields.</li>
            <li><strong>Date / Time</strong> &mdash; date and time pickers.</li>
            <li><strong>Select / Checkbox / Radio</strong> &mdash; single and multi-choice options.</li>
            <li><strong>Binary</strong> &mdash; file upload (selects a file from the device).</li>
            <li><strong>Calculation</strong> &mdash; auto-computed from other fields (read-only).</li>
            <li><strong>Section</strong> &mdash; visual header / divider.</li>
        </ul>
        <div class="info"><strong>Note:</strong> Conditional visibility and branching rules defined in the web app are fully enforced on mobile.</div>
    </div>

    <!-- 12. Drafts & Sent Responses -->
    <div class="section" id="mobile-responses">
        <h2>12. Drafts &amp; Sent Responses</h2>
        <p>Tap the <strong>cloud upload icon</strong> (&#9729;) in the app bar to open the Responses screen.</p>

        <h3>Drafts Tab</h3>
        <p>Shows locally saved responses that have not yet been synced to the server.</p>
        <ul>
            <li><strong>Send All</strong> &mdash; uploads all unsynced drafts to the server.</li>
            <li><strong>Edit</strong> &mdash; opens the response in the form editor for changes.</li>
            <li><strong>View Details</strong> &mdash; shows all answers in a bottom sheet.</li>
            <li><strong>Delete</strong> &mdash; permanently removes the local draft.</li>
        </ul>

        <h3>Sent Tab</h3>
        <p>Shows responses that have been synced to the server. Each entry displays:</p>
        <ul>
            <li><strong>Recorded</strong> &mdash; when the interview was conducted (on the device).</li>
            <li><strong>Submitted</strong> &mdash; when the response reached the server.</li>
        </ul>

        <h3>Locked Responses</h3>
        <p>If a draft was created with a different agent key than the one currently active, it is <strong>locked</strong> and cannot be edited or synced. This prevents agents from accidentally modifying another agent's data.</p>
        <div class="warn"><strong>Warning:</strong> Locked responses show a lock icon. To edit them, sign in with the original agent key, or revoke the current agent from the main screen.</div>
    </div>

    <!-- 13. Mobile Settings -->
    <div class="section" id="mobile-settings">
        <h2>13. Mobile Settings</h2>
        <p>Tap the <strong>gear icon</strong> (&#9881;) in the app bar to open Settings. Settings are split into sections visible only when logged in.</p>

        <h3>Server Connection (always visible)</h3>
        <table class="field-table">
            <tr><th>Field</th><th>Description</th></tr>
            <tr><td><strong>Server URL</strong></td><td>The backend server address (e.g. <code>http://192.168.1.100:8080/SurveyMaster</code>).</td></tr>
            <tr><td><strong>Company Key</strong></td><td>The 6-character company key.</td></tr>
            <tr><td><strong>Company Name</strong></td><td>Optional display name for the company.</td></tr>
        </table>
        <p>Tap <strong>Connect &amp; Save</strong> to verify the server connection and save settings.</p>

        <h3>Form Display (logged in only)</h3>
        <p>Choose how questions are presented while filling a form (see <a href="#mobile-fill">Filling a Form</a>).</p>

        <h3>Data Management (logged in only)</h3>
        <table class="field-table">
            <tr><th>Action</th><th>Description</th></tr>
            <tr><td><strong>Clear current agent data</strong></td><td>Deletes all responses tagged with the current agent key. Enabled only when an agent is assigned.</td></tr>
            <tr><td><strong>Clear company data</strong></td><td>Deletes all responses for the current company. Disabled when an agent is assigned (revoke agent first).</td></tr>
            <tr><td><strong>Clear database</strong></td><td>Wipes all local data (responses, questionnaires, settings). The app resets to first-time setup. Disabled when an agent is assigned.</td></tr>
        </table>
        <div class="warn"><strong>Warning:</strong> Data clearing is permanent and cannot be undone. Unsynced responses will be lost.</div>
    </div>

    <!-- 14. Data Collection & CSV Export -->
    <div class="section" id="data-export">
        <h2>14. Data Collection &amp; CSV Export</h2>

        <h3>Data Flow</h3>
        <div class="flow-diagram">
            Mobile: Fill Form <span class="arrow">&rarr;</span> Save Locally (Draft) <span class="arrow">&rarr;</span> Sync / Send All <span class="arrow">&rarr;</span> Server
            <br/><br/>
            Web: View Responses <span class="arrow">&rarr;</span> Filter by Questionnaire / Date / Agent <span class="arrow">&rarr;</span> Export CSV
        </div>

        <h3>Syncing Responses</h3>
        <ol>
            <li>On the mobile app, open the <strong>Responses</strong> screen (cloud icon).</li>
            <li>Ensure you have an internet connection.</li>
            <li>Tap <strong>Send All</strong> to upload all drafts to the server.</li>
            <li>Successful uploads move from the <strong>Drafts</strong> tab to the <strong>Sent</strong> tab.</li>
        </ol>

        <h3>Exporting CSV (Web)</h3>
        <ol>
            <li>Navigate to <strong>Questionnaires</strong> on the web app.</li>
            <li>Click the <strong>&#8942;</strong> dropdown on the target questionnaire.</li>
            <li>Click <strong>Export CSV</strong>.</li>
            <li>A CSV file downloads with columns: Agent Key, Record Date, Submitted At, and every question answer.</li>
        </ol>
        <div class="tip"><strong>Tip:</strong> You can also filter responses by date range and agent from the Responses section on the web app.</div>
    </div>

    <!-- 15. FAQ -->
    <div class="section" id="faq">
        <h2>15. FAQ</h2>

        <h3>Q: Can I use the mobile app without internet?</h3>
        <p>Yes. The app is offline-first. You can fill and save forms without a connection. Sync (Send All) requires internet to upload to the server.</p>

        <h3>Q: What happens if two agents collect data for the same questionnaire?</h3>
        <p>Each agent's responses are tagged with their Agent Key. Data is never mixed between agents. On the web app you can filter and export by agent.</p>

        <h3>Q: Can I edit a synced response?</h3>
        <p>Synced responses are read-only on the mobile app. To make corrections, edit the response directly on the web app or re-collect on mobile.</p>

        <h3>Q: What if I scan the wrong QR code?</h3>
        <p>If you scan a company QR code for a different company, the Company Key will not match and sign-in will fail. Go to Settings and reconfigure.</p>

        <h3>Q: How do I switch companies on the mobile app?</h3>
        <p>Go to Settings (gear icon) &gt; change the Server URL and Company Key &gt; tap Connect &amp; Save. This clears cached questionnaires for the previous company.</p>

        <h3>Q: Can I use the mobile app for multiple agents on the same device?</h3>
        <p>Yes. Each agent signs in with their own Agent Key. Responses are tagged per agent. Data from different agents never overlaps.</p>

        <h3>Q: What if I forgot my web password?</h3>
        <p>On the login page, click <strong>Forgot Password?</strong>, enter your username, and a reset link will be sent to your registered email.</p>

        <h3>Q: How do I distribute the mobile APK?</h3>
        <p>Upload the APK through the web app (ADMIN &gt; APK section). The latest APK is displayed on the home page for download. Share the download link or the APK file directly with field collectors.</p>
    </div>
</div>

<%@include file="common/footer.jsp" %>
<%@include file="common/resoucelink_scripts.jsp" %>
</body>
</html>
