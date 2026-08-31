<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<html lang="en">
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
        <meta charset="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <link rel="icon" type="image/x-icon" href="${STATIC_RES}/images/x-diamond.svg" />
        <title>Build Form - ${APP_NAME}</title>
        <%@include file="common/resoucelink_css.jsp" %>
    </head>

    <body>
        <%@include file="common/header_panel.jsp" %>

        <div class="sm-wrap">
            <div class="sm-toolbar">
                <span class="sm-title">Build: ${NAME}</span>
                <span class="sm-actions">
                    <button type="button" class="btn btn-outline-info btn-sm" id="btn-export-json">Export JSON</button>
                    <button type="button" class="btn btn-outline-info btn-sm" id="btn-import-json">Import JSON</button>
                    <input type="file" id="file-import-json" accept="application/json,.json" style="display:none;" />
                </span>
            </div>

            <div class="sm-toolbar justify-content-start">
                <span class="sm-actions" id="field-buttons">
                    <button type="button" class="btn btn-outline-primary btn-sm btn-add" data-type="string">+ Text</button>
                    <button type="button" class="btn btn-outline-primary btn-sm btn-add" data-type="textarea">+ Paragraph</button>
                    <button type="button" class="btn btn-outline-primary btn-sm btn-add" data-type="int">+ Number</button>
                    <button type="button" class="btn btn-outline-primary btn-sm btn-add" data-type="select1">+ Select</button>
                    <button type="button" class="btn btn-outline-primary btn-sm btn-add" data-type="select">+ Multi-Select</button>
                    <button type="button" class="btn btn-outline-primary btn-sm btn-add" data-type="radio">+ Radio</button>
                    <button type="button" class="btn btn-outline-primary btn-sm btn-add" data-type="checkbox">+ Checkbox</button>
                    <button type="button" class="btn btn-outline-primary btn-sm btn-add" data-type="binary">+ Media</button>
                    <button type="button" class="btn btn-outline-primary btn-sm btn-add" data-type="date">+ Date</button>
                    <button type="button" class="btn btn-outline-primary btn-sm btn-add" data-type="time">+ Time</button>
                    <button type="button" class="btn btn-outline-primary btn-sm btn-add" data-type="section">+ Section</button>
                    <button type="button" class="btn btn-outline-primary btn-sm btn-add" data-type="calc">+ Score</button>
                </span>
                <span class="sm-sep" aria-hidden="true"></span>
                <span class="sm-actions ms-auto" id="action-buttons">
                    <button type="button" class="btn btn-primary" id="btn-test">Test Form</button>
                    <button type="button" class="btn btn-success" id="btn-save">Save</button>
                    <button type="button" class="btn btn-success" id="btn-save-quit">Save &amp; Quit</button>
                    <a class="btn btn-outline-secondary" href="${BASE_URL}/<c:choose><c:when test="${IS_ADMIN}">questionnaire/all</c:when><c:otherwise>questionnaire/list</c:otherwise></c:choose>">Quit</a>
                </span>
            </div>

            <div class="sm-toolbar justify-content-start">
                <div class="btn-group btn-group-sm" role="group">
                <button type="button" class="btn btn-outline-secondary active" id="btn-view-flow">Flow View</button>
                <button type="button" class="btn btn-outline-secondary" id="btn-view-list">List View</button>
                </div>
                <span class="sm-actions ms-2" id="flow-tools" style="display:none;">
                    <small class="text-muted align-self-center ms-2 d-flex flex-wrap gap-2 align-items-center">
                        <span>Drag cards anywhere to arrange</span>
                        <span class="sm-legend"><i class="sm-dot" style="background:#adb5bd"></i> sequential next</span>
                        <span class="sm-legend"><i class="sm-dot" style="background:#DA4F49"></i> jump</span>
                        <span class="sm-legend"><i class="sm-dot sm-dot-dashed" style="background:#5BB75B"></i> condition (dashed)</span>
                        <span>click a card to edit it</span>
                    </small>
                </span>
            </div>

            <div class="sm-builder">
                <div class="sm-questions-pane">
                    <div id="list-view" style="display:none;">
                        <div id="questions-holder"></div>
                    </div>
                    <div id="flow-view">
                        <div id="flow-canvas-wrap">
                            <div id="flow-canvas"></div>
                        </div>
                    </div>
                </div>

                <div class="sm-property-pane">
                    <div class="sm-panel" id="property-panel" style="display:none;">
                        <h5 class="mb-3" id="prop-title">Question Properties</h5>
                        <form id="prop-form">
                            <div class="mb-3">
                                <label class="form-label fw-semibold">Question Text (Caption)</label>
                                <input type="text" class="form-control" id="prop-caption" placeholder="e.g. What is your full name?" />
                            </div>
                            <div class="mb-3">
                                <label class="form-label fw-semibold">Hint</label>
                                <input type="text" class="form-control" id="prop-hint" placeholder="small help text shown below the caption" />
                                <div class="form-text">Displayed under the caption in smaller text.</div>
                            </div>
                            <div class="mb-3">
                                <label class="form-label fw-semibold">Variable Name</label>
                                <input type="text" class="form-control" id="prop-qname" placeholder="question_1" />
                                <div class="form-text">Must be unique. Used as the field name in saved responses.</div>
                            </div>
                            <div class="mb-3">
                                <label class="form-label fw-semibold">Type</label>
                                <select class="form-select" id="prop-typelabel"></select>
                            </div>
                            <div class="d-flex gap-4 mb-3 flex-wrap" id="toggle-box">
                                <div class="form-check mb-0">
                                    <input class="form-check-input" type="checkbox" id="prop-required" />
                                    <label class="form-check-label fw-semibold" for="prop-required">Required</label>
                                </div>
                                <div class="form-check mb-0">
                                    <input class="form-check-input" type="checkbox" id="prop-hidden" />
                                    <label class="form-check-label fw-semibold" for="prop-hidden">Hidden</label>
                                </div>
                                <div class="form-check mb-0">
                                    <input class="form-check-input" type="checkbox" id="prop-readonly" />
                                    <label class="form-check-label fw-semibold" for="prop-readonly">Readonly</label>
                                </div>
                                <div class="form-check mb-0">
                                    <input class="form-check-input" type="checkbox" id="prop-savable" checked />
                                    <label class="form-check-label fw-semibold" for="prop-savable">Savable</label>
                                </div>
                            </div>
                            <div class="mb-3">
                                <label class="form-label fw-semibold">Validation Message (optional)</label>
                                <input type="text" class="form-control" id="prop-errmsg" placeholder="Shown when this required field is left empty" />
                                <div class="form-text">Overrides the default &quot;This field is required.&quot; message.</div>
                            </div>
                            <div class="mb-3" id="media-field" style="display:none;">
                                <label class="form-label fw-semibold">Accepted Media Types (optional)</label>
                                <input type="text" class="form-control" name="mediatype" id="prop-mediatype" placeholder="image/*,.pdf" />
                            </div>
                            <div class="sm-cond-box mb-3" id="attrs-box">
                                <label class="form-label fw-semibold mb-2">HTML Input Attributes (validation)</label>
                                <input type="hidden" id="prop-placeholder" />
                                <div class="row g-2">
                                    <div class="col-12" id="attr-placeholder-wrap">
                                        <input type="text" class="form-control form-control-sm" id="attr-placeholder" placeholder="placeholder text" />
                                    </div>
                                    <div class="col-12" id="attr-title-wrap">
                                        <input type="text" class="form-control form-control-sm" id="attr-title" placeholder="tooltip text (title)" />
                                    </div>
                                    <div class="col-12" id="attr-value-wrap">
                                        <input type="text" class="form-control form-control-sm" id="attr-value" placeholder="default value (pre-filled)" />
                                    </div>
                                    <div class="col-4" id="attr-minlength-wrap">
                                        <input type="number" class="form-control form-control-sm" id="attr-minlength" placeholder="minlen" min="0" />
                                    </div>
                                    <div class="col-4" id="attr-maxlength-wrap">
                                        <input type="number" class="form-control form-control-sm" id="attr-maxlength" placeholder="maxlen" min="0" />
                                    </div>
                                    <div class="col-4" id="attr-min-wrap">
                                        <input type="text" class="form-control form-control-sm" id="attr-min" placeholder="min" />
                                    </div>
                                    <div class="col-4" id="attr-max-wrap">
                                        <input type="text" class="form-control form-control-sm" id="attr-max" placeholder="max" />
                                    </div>
                                    <div class="col-4" id="attr-step-wrap">
                                        <input type="text" class="form-control form-control-sm" id="attr-step" placeholder="step" />
                                    </div>
                                    <div class="col-12" id="attr-pattern-wrap">
                                        <input type="text" class="form-control form-control-sm" id="attr-pattern" placeholder="regex pattern, e.g. [A-Za-z ]+" />
                                    </div>
                                </div>
                                <div class="form-text">Valid HTML attributes applied to the rendered field. Browser enforces them on form submit.</div>
                            </div>
                            <div class="mb-3" id="options-field" style="display:none;">
                                <label class="form-label fw-semibold">Options (value + caption)</label>
                                <div id="options-holder"></div>
                                <button type="button" class="btn btn-outline-secondary btn-sm mt-1" id="btn-add-option">+ Add Option</button>
                                <details class="mt-2">
                                    <summary class="small text-muted">Bulk add (one per line, value|caption)</summary>
                                    <textarea class="form-control form-control-sm mt-1" id="prop-bulk-options" rows="3" placeholder="yes|Yes&#10;no|No&#10;maybe|Maybe"></textarea>
                                    <button type="button" class="btn btn-outline-primary btn-sm mt-1" id="btn-bulk-options">Apply</button>
                                </details>
                            </div>

                            <div class="mb-3" id="calc-field" style="display:none;">
                                <label class="form-label fw-semibold">Calculated field</label>
                                <label class="form-label small">Source questions (comma-separated qnames)</label>
                                <input type="text" class="form-control form-control-sm" id="calc-sources" placeholder="e.g. num_1, num_2" />
                                <label class="form-label small mt-2">Operation</label>
                                <select class="form-select form-select-sm" id="calc-op">
                                    <option value="sum">Sum</option>
                                    <option value="avg">Average</option>
                                    <option value="count">Count</option>
                                    <option value="min">Minimum</option>
                                    <option value="max">Maximum</option>
                                </select>
                                <label class="form-label small mt-2">Unit (optional)</label>
                                <input type="text" class="form-control form-control-sm" id="calc-unit" placeholder="e.g. pts" />
                                <div class="form-text">Read-only value computed from the numeric source questions you reference.</div>
                            </div>

                            <div class="mb-3">
                                <label class="form-label fw-semibold">Next Step</label>
                                <select class="form-select" id="prop-nextstep"></select>
                                <div class="form-text">Green flow connector target. Defaults to the next sequential question.</div>
                            </div>

                            <div class="sm-cond-box mb-3" id="cond-box" style="display:none;">
                                <div class="form-check">
                                    <input class="form-check-input" type="checkbox" id="cond-enabled" />
                                    <label class="form-check-label fw-semibold" for="cond-enabled">Show conditionally</label>
                                </div>
                                <div id="cond-editor" style="display:none;" class="mt-2">
                                    <select class="form-select form-select-sm mb-2" id="cond-target"></select>
                                    <select class="form-select form-select-sm mb-2" id="cond-op"></select>
                                    <input type="text" class="form-control form-control-sm" id="cond-value" placeholder="value" />
                                    <div class="form-text">Question appears only when the condition on the selected earlier question is true.</div>
                                </div>
                            </div>

                            <div class="sm-cond-box mb-3" id="jump-box">
                                <div class="form-check">
                                    <input class="form-check-input" type="checkbox" id="jump-enabled" />
                                    <label class="form-check-label fw-semibold" for="jump-enabled">Jump / Step into</label>
                                </div>
                                <div id="jump-editor" style="display:none;" class="mt-2">
                                    <div id="jump-branches"></div>
                                    <button type="button" class="btn btn-sm btn-outline-secondary mb-2" id="jump-add-branch">+ Add else if</button>
                                    <label class="form-label fw-semibold small">Else &rarr; jump to</label>
                                    <select class="form-select form-select-sm mb-2" id="jump-else-target">
                                        <option value="">No action (continue sequentially)</option>
                                    </select>
                                    <div class="form-text">Branches are evaluated top-down (if, else if, ...). The first matching branch wins; otherwise the form jumps to the "else" target (or continues normally if empty).</div>
                                </div>
                            </div>
                        </form>
                    </div>
                    <div class="sm-panel" id="property-empty">
                        <p class="text-muted m-0">Select a question to edit its properties, or add a new one using the buttons above.</p>
                    </div>
                </div>
            </div><!-- /sm-builder -->
        </div>

        <div id="sm-flow-ctx" class="sm-flow-ctx" style="display:none;">
            <button type="button" class="sm-flow-ctx-item" id="ctx-dup">&#10697; Duplicate</button>
            <button type="button" class="sm-flow-ctx-item sm-flow-ctx-danger" id="ctx-del">&times; Delete</button>
        </div>

        <div class="sm-modal" id="sm-modal-jump">
            <div class="sm-modal-head"><h5 id="jump-edge-title">Jump Rule</h5><button type="button" class="btn-close sm-modal-close"></button></div>
            <div class="sm-modal-body">
                <p class="mb-2" id="jump-edge-info"></p>
                <select class="form-select form-select-sm mb-2" id="edge-op"></select>
                <input type="text" class="form-control form-control-sm mb-2" id="edge-value" placeholder="value" />
                <label class="form-label fw-semibold small">Else &rarr; jump to</label>
                <select class="form-select form-select-sm mb-2" id="edge-else-target">
                    <option value="">No action (continue sequentially)</option>
                </select>
                <div class="form-text">If the answer matches, the form jumps to the target. Otherwise it jumps to the "else" target (or continues normally if empty).</div>
            </div>
            <div class="sm-modal-foot">
                <button type="button" class="btn btn-outline-danger me-auto" id="edge-remove">Remove rule</button>
                <button type="button" class="btn btn-outline-secondary" id="edge-cancel">Cancel</button>
                <button type="button" class="btn btn-primary" id="edge-apply">Apply</button>
            </div>
        </div>

        <%@include file="common/footer.jsp" %>
        <script src="${STATIC_RES}/js/jsplumb.min.js"></script>
        <%@include file="common/resoucelink_scripts.jsp" %>

        <script type="text/javascript">
            var BASE = '${BASE_URL}';
            var LIST_URL = BASE + (<c:out value="${IS_ADMIN}" default="false"/> ? '/questionnaire/all' : '/questionnaire/list');
            var QID = ${QUESTIONNAIRE_ID};
            var questions = [];
            var selected = -1;

            /* ================= state -> DOM ================= */

            function defaultQ(type) {
                var q = {
                    qname: SM.uniqueName(questions, type),
                    qtype: type,
                    caption: "",
                    hint: "",
                    required: false,
                    savable: true,
                    options: [],
                    mediaType: "",
                    visibleIf: null,
                    jump: null
                };
                if (type === "calc") {
                    q.sources = [];
                    q.op = "sum";
                    q.unit = "";
                }
                return q;
            }

            function hasOpts(i) {
                return i >= 0 && i < questions.length && SM.hasOptions(questions[i].qtype);
            }

            /* Shared single source for question cards - used by BOTH list view and flow view */
            function questionCardHtml(i, opts) {
                opts = opts || {};
                var q = questions[i];
                var caption = SM.escapeHtml(q.caption || "(untitled question)");
                if (!opts.forFlow && caption.length > 220) {
                    caption = caption.substring(0, 220) + '...';
                }
                var preview = caption;
                if (SM.hasOptions(q.qtype)) {
                    preview += ' <em style="color:#aaa;">[' + q.options.length + " options]</em>";
                }
                var cond = "";
                if (q.visibleIf) {
                    var ti = parseInt(q.visibleIf.target, 10);
                    var tOk = !isNaN(ti) && ti >= 0 && ti < questions.length;
                    cond = ' &middot; <em>if Q' + (ti + 1) + " " + SM.opLabel(tOk ? questions[ti].qtype : "", q.visibleIf.op) +
                        (q.visibleIf.value ? ' "' + SM.escapeHtml(q.visibleIf.value) + '"' : "") + '</em>';
                }
                var jump = "";
                if (q.jump) {
                    normalizeJump(q);
                    var brs = Array.isArray(q.jump.branches) ? q.jump.branches : [];
                    brs.forEach(function (br, bi) {
                        var jt = parseInt(br.target, 10);
                        if (isNaN(jt) || jt === i || jt < 0 || jt >= questions.length) { return; }
                        var backward = jt < i;
                        var cond = (br.op && br.op !== "notEmpty")
                            ? ' when ' + SM.opLabel(q.qtype, br.op) + ' "' + SM.escapeHtml(br.value) + '"' : "";
                        jump += '<div class="sm-jump-line">' + (bi === 0 ? "if" : "else if") +
                            (backward ? " &#8634; back to Q" : " &rarr; jump to Q") + (jt + 1) + cond + '</div>';
                    });
                    var et = q.jump.elseTarget != null ? parseInt(q.jump.elseTarget, 10) : null;
                    if (et != null && !isNaN(et) && et !== i && et >= 0 && et < questions.length) {
                        jump += '<div class="sm-jump-line">else &rarr; Q' + (et + 1) + '</div>';
                    }
                }
                var btns = "";
                var handle = "";
                if (!opts.forFlow) {
                    btns =
                        '<span class="sm-qbtns">' +
                        '<button type="button" class="btn btn-sm btn-outline-secondary q-up"' + (i === 0 ? " disabled" : "") + '>&uarr;</button>' +
                        '<button type="button" class="btn btn-sm btn-outline-secondary q-down"' + (i === questions.length - 1 ? " disabled" : "") + '>&darr;</button>' +
                        '<button type="button" class="btn btn-sm btn-outline-secondary q-dup" title="Duplicate question">&#10697;</button>' +
                        '<button type="button" class="btn btn-sm btn-danger q-del">&times;</button>' +
                        '</span>';
                } else {
                    /* flow view: actions via right-click context menu */
                }
                var badges = (q.hidden ? '<span class="sm-qtype-badge">hidden</span> ' : '') +
                    (q.readonly ? '<span class="sm-qtype-badge">readonly</span> ' : '') +
                    '<span class="sm-qtype-badge">' + SM.typeLabel(q.qtype) + '</span>';
                return '<div class="sm-qcard' + (opts.active ? " active" : "") + (q.hidden ? " hidden-q" : "") + '" data-idx="' + i + '">' +
                    '<div class="sm-qhead">' +
                    '<span class="sm-qnum">' + (i + 1) + '</span>' +
                    '<span class="sm-qtitle">' + preview + '</span>' +
                    btns +
                    '</div>' +
                    '<div class="sm-qpreview">' + badges + ' variable: ' + SM.escapeHtml(q.qname) +
                    (q.required ? ' &middot; <strong style="color:#dc3545;">required</strong>' : '') +
                    (q.readonly ? ' &middot; readonly' : '') +
                    (q.savable === false ? ' &middot; <em style="color:#6c757d;">not saved</em>' : '') +
                    cond + '</div>' + jump +
                    '</div>';
            }

            function renderQuestions() {
                var holder = document.getElementById("questions-holder");
                if (!questions.length) {
                    holder.innerHTML = '<div class="sm-placeholder">No questions yet.<br/>Add fields using the "+ Text", "+ Number", ... buttons above.</div>';
                    return;
                }
                var html = "";
                questions.forEach(function (q, i) {
                    html += questionCardHtml(i, { active: i === selected, forFlow: false });
                });
                holder.innerHTML = html;
            }

            // Renders ONE option row and binds its listeners directly (no delegation, no stale indexes).
            function renderOptionRow(q, i) {
                var opt = q.options[i];
                var row = document.createElement("div");
                row.className = "sm-opt-row";

                var valInput = document.createElement("input");
                valInput.type = "text";
                valInput.className = "form-control form-control-sm";
                valInput.placeholder = "value";
                valInput.value = opt.value || "";

                var capInput = document.createElement("input");
                capInput.type = "text";
                capInput.className = "form-control form-control-sm";
                capInput.placeholder = "caption";
                capInput.value = opt.caption || "";

                var delBtn = document.createElement("button");
                delBtn.type = "button";
                delBtn.className = "btn btn-sm btn-outline-danger";
                delBtn.textContent = "\u00D7";

                function sync() {
                    q.options[i].value = valInput.value.trim();
                    q.options[i].caption = capInput.value;
                    renderQuestions();
                    if (isFlowView()) { refreshFlowCard(selected); }
                }
                valInput.addEventListener("input", sync);
                capInput.addEventListener("input", sync);
                delBtn.addEventListener("click", function () {
                    syncFromForm();
                    q.options.splice(i, 1);
                    renderOptions();
                    renderQuestions();
                    if (isFlowView()) { refreshFlowCard(selected); }
                });

                row.appendChild(valInput);
                row.appendChild(capInput);
                row.appendChild(delBtn);
                return row;
            }

            function renderOptions() {
                var hold = document.getElementById("options-holder");
                hold.innerHTML = "";
                if (selected < 0) { return; }
                var q = questions[selected];
                for (var i = 0; i < q.options.length; i++) {
                    hold.appendChild(renderOptionRow(q, i));
                }
            }

            function renderPropertyPanel() {
                if (selected < 0) {
                    document.getElementById("property-panel").style.display = "none";
                    document.getElementById("property-empty").style.display = "";
                    document.getElementById("prop-title").textContent = "Question Properties";
                    return;
                }
                var q = questions[selected];
                document.getElementById("property-empty").style.display = "none";
                document.getElementById("property-panel").style.display = "";
                document.getElementById("prop-title").textContent = "Question Properties - Q" + (selected + 1);

                document.getElementById("prop-caption").value = q.caption;
                document.getElementById("prop-hint").value = q.hint || "";
                document.getElementById("prop-qname").value = q.qname;
                var TYPE_GROUPS = {
                    select1: ["select1", "radio"], radio: ["select1", "radio"],
                    select: ["select", "checkbox"], checkbox: ["select", "checkbox"],
                    string: ["string", "int"], int: ["string", "int"]
                };
                var typeSelect = document.getElementById("prop-typelabel");
                typeSelect.innerHTML = "";
                var group = TYPE_GROUPS[q.qtype];
                if (group) {
                    group.forEach(function (t) {
                        var opt = document.createElement("option");
                        opt.value = t;
                        opt.textContent = SM.typeLabel(t);
                        opt.selected = t === q.qtype;
                        typeSelect.appendChild(opt);
                    });
                    typeSelect.disabled = false;
                } else {
                    var ALL_TYPES = ["string", "textarea", "int", "select1", "select", "radio", "checkbox", "binary", "date", "time", "section", "calc"];
                    ALL_TYPES.forEach(function (t) {
                        var opt = document.createElement("option");
                        opt.value = t;
                        opt.textContent = SM.typeLabel(t);
                        opt.selected = (t === q.qtype);
                        typeSelect.appendChild(opt);
                    });
                    typeSelect.disabled = false;
                }
                document.getElementById("prop-required").checked = !!q.required;
                document.getElementById("prop-hidden").checked = !!q.hidden;
                document.getElementById("prop-readonly").checked = !!q.readonly;
                document.getElementById("prop-savable").checked = q.savable !== false;
                document.getElementById("prop-errmsg").value = q.errMsg || "";

                var nsSel = document.getElementById("prop-nextstep");
                nsSel.innerHTML = "";
                var noneOpt = document.createElement("option");
                noneOpt.value = "none";
                noneOpt.textContent = "None";
                nsSel.appendChild(noneOpt);
                for (var ni = 0; ni < questions.length; ni++) {
                    if (ni === selected) { continue; }
                    var no = document.createElement("option");
                    no.value = String(ni);
                    no.textContent = "Q" + (ni + 1) + ". " + (questions[ni].caption || questions[ni].qname || questions[ni].qtype);
                    nsSel.appendChild(no);
                }
                var nsStored = q.nextStep;
                var nsVal;
                if (nsStored === -1) {
                    nsVal = "none";
                } else if (nsStored != null && !isNaN(parseInt(nsStored, 10))
                    && parseInt(nsStored, 10) !== selected
                    && parseInt(nsStored, 10) >= 0 && parseInt(nsStored, 10) < questions.length) {
                    nsVal = String(parseInt(nsStored, 10));
                } else if (selected + 1 < questions.length) {
                    nsVal = String(selected + 1); /* default selected = real next sequential question */
                } else {
                    nsVal = "none"; /* last question -> none */
                }
                nsSel.value = nsVal;
                document.getElementById("prop-mediatype").value = q.mediaType || "";
                document.getElementById("media-field").style.display = q.qtype === "binary" ? "" : "none";
                document.getElementById("options-field").style.display = SM.hasOptions(q.qtype) ? "" : "none";

                var isSection = q.qtype === "section";
                var isCalc = q.qtype === "calc";
                document.getElementById("toggle-box").style.display = (isSection || isCalc) ? "none" : "";
                document.getElementById("attrs-box").style.display = (isSection || isCalc) ? "none" : "";
                document.getElementById("prop-errmsg").parentElement.style.display = (isSection || isCalc) ? "none" : "";
                document.getElementById("calc-field").style.display = isCalc ? "" : "none";
                if (isCalc) {
                    document.getElementById("calc-sources").value = Array.isArray(q.sources) ? q.sources.join(", ") : (q.sources || "");
                    document.getElementById("calc-op").value = q.op || "sum";
                    document.getElementById("calc-unit").value = q.unit || "";
                }

                ["placeholder", "minlength", "maxlength", "pattern", "min", "max", "step", "value", "title"].forEach(function (k) {
                    document.getElementById("attr-" + k).value = q[k] != null ? q[k] : "";
                });
                var t = q.qtype;
                var isTextual = t === "string" || t === "textarea";
                var isNumericish = t === "int" || t === "date" || t === "time";
                var hasValueInput = isTextual || isNumericish;
                showIf("attr-placeholder-wrap", isTextual || t === "int");
                showIf("attr-title-wrap", true);
                showIf("attr-value-wrap", hasValueInput);
                showIf("attr-minlength-wrap", isTextual);
                showIf("attr-maxlength-wrap", isTextual);
                showIf("attr-pattern-wrap", isTextual);
                showIf("attr-min-wrap", isNumericish);
                showIf("attr-max-wrap", isNumericish);
                showIf("attr-step-wrap", t === "int");

                document.getElementById("cond-box").style.display = selected > 0 ? "" : "none";
                // checkbox reflects stored state ONLY here (on selection change), never after user interaction
                document.getElementById("cond-enabled").checked = !!q.visibleIf;

                var jumpEnabled = document.getElementById("jump-enabled");
                jumpEnabled.checked = !!q.jump;
                renderJumpEditor();

                renderOptions();
                renderCondEditor();
            }

            function normalizeJump(q) {
                if (!q.jump) { return; }
                if (Array.isArray(q.jump.branches)) { return; }
                var br = [];
                if (q.jump.target != null && q.jump.target !== "" && !isNaN(parseInt(q.jump.target, 10))) {
                    br.push({
                        target: parseInt(q.jump.target, 10),
                        op: q.jump.op || "notEmpty",
                        value: (q.jump.op && q.jump.op !== "notEmpty") ? (q.jump.value || "") : ""
                    });
                }
                var et = (q.jump.elseTarget != null && q.jump.elseTarget !== "") ? parseInt(q.jump.elseTarget, 10) : null;
                q.jump = (br.length || et !== null) ? { branches: br, elseTarget: et } : null;
            }

            function jumpValuePlaceholder(qtype) {
                if (SM.hasOptions(qtype)) {
                    return "one of: " + questions[selected].options.map(function (o) { return o.value; }).join(", ");
                }
                if (qtype === "int") { return "a number, e.g. 5"; }
                if (qtype === "date") { return "a date, e.g. 2026-01-31"; }
                if (qtype === "time") { return "a time, e.g. 14:30"; }
                return "text to match";
            }

            function buildBranchRow(q, bi, br) {
                var row = document.createElement("div");
                row.className = "sm-branch-row mb-2 p-2 border rounded";

                var label = document.createElement("div");
                label.className = "form-label fw-semibold small mb-1";
                label.textContent = bi === 0 ? "If" : "Else if";
                row.appendChild(label);

                var opSel = document.createElement("select");
                opSel.className = "form-select form-select-sm mb-1 jump-br-op";
                SM.opsForType(q.qtype).forEach(function (o) {
                    var opt = document.createElement("option");
                    opt.value = o.v; opt.textContent = o.l;
                    opSel.appendChild(opt);
                });
                opSel.value = br.op || "notEmpty";
                row.appendChild(opSel);

                var valInput = document.createElement("input");
                valInput.type = "text";
                valInput.className = "form-control form-control-sm mb-1 jump-br-value";
                valInput.placeholder = jumpValuePlaceholder(q.qtype);
                valInput.value = (br.op && br.op !== "notEmpty") ? (br.value || "") : "";
                valInput.style.display = (br.op === "notEmpty") ? "none" : "";
                row.appendChild(valInput);

                var tgtSel = document.createElement("select");
                tgtSel.className = "form-select form-select-sm mb-1 jump-br-target";
                tgtSel.appendChild(new Option("-- then jump to --", ""));
                for (var i = 0; i < questions.length; i++) {
                    if (i === selected) { continue; }
                    tgtSel.appendChild(new Option((i < selected ? "\u21BA back to Q" : "go to Q") + (i + 1) + ". " + (questions[i].caption || questions[i].qname), String(i)));
                }
                tgtSel.value = (br.target != null && !isNaN(parseInt(br.target, 10))) ? String(br.target) : "";
                row.appendChild(tgtSel);

                if (bi > 0) {
                    var rm = document.createElement("button");
                    rm.type = "button";
                    rm.className = "btn btn-sm btn-outline-danger";
                    rm.textContent = "Remove";
                    rm.addEventListener("click", function () {
                        var qq = questions[selected];
                        if (qq.jump && Array.isArray(qq.jump.branches)) { qq.jump.branches.splice(bi, 1); }
                        renderJumpEditor();
                        afterPropChange(true);
                    });
                    row.appendChild(rm);
                }

                opSel.addEventListener("change", function () {
                    valInput.style.display = opSel.value === "notEmpty" ? "none" : "";
                    valInput.placeholder = jumpValuePlaceholder(q.qtype);
                    syncFromForm(); afterPropChange(true);
                });
                valInput.addEventListener("input", function () { syncFromForm(); afterPropChange(true); });
                tgtSel.addEventListener("change", function () { syncFromForm(); afterPropChange(true); });
                return row;
            }

            function renderJumpEditor() {
                var q = questions[selected];
                if (!q) { return; }
                normalizeJump(q);
                var enabledBox = document.getElementById("jump-enabled");
                var editor = document.getElementById("jump-editor");
                editor.style.display = enabledBox.checked ? "" : "none";
                if (!enabledBox.checked) { return; }

                var branches = (q.jump && Array.isArray(q.jump.branches)) ? q.jump.branches : [];
                var elseTarget = (q.jump && q.jump.elseTarget != null) ? parseInt(q.jump.elseTarget, 10) : null;

                var branchesEl = document.getElementById("jump-branches");
                branchesEl.innerHTML = "";
                branches.forEach(function (br, bi) {
                    branchesEl.appendChild(buildBranchRow(q, bi, br));
                });

                var elseSel = document.getElementById("jump-else-target");
                elseSel.innerHTML = '<option value="">No action (continue sequentially)</option>';
                for (var i = 0; i < questions.length; i++) {
                    if (i === selected) { continue; }
                    var eopt = document.createElement("option");
                    eopt.value = String(i);
                    eopt.textContent = (i < selected ? "\u21BA back to Q" : "go to Q") + (i + 1) + ". " + (questions[i].caption || questions[i].qname);
                    elseSel.appendChild(eopt);
                }
                elseSel.value = (elseTarget != null && !isNaN(elseTarget)) ? String(elseTarget) : "";
            }

            function renderCondEditor() {
                if (selected <= 0) { return; }
                var q = questions[selected];
                var editor = document.getElementById("cond-editor");
                var targetSel = document.getElementById("cond-target");
                var opSel = document.getElementById("cond-op");
                var valueInput = document.getElementById("cond-value");

                editor.style.display = document.getElementById("cond-enabled").checked ? "" : "none";

                var domSelection = targetSel.value;
                var stored = q.visibleIf;
                var storedTarget = stored ? String(stored.target) : "";

                targetSel.innerHTML = '<option value="">-- when this question answers --</option>';
                for (var i = 0; i < selected; i++) {
                    var opt = document.createElement("option");
                    opt.value = String(i);
                    opt.textContent = (i + 1) + ". " + (questions[i].caption || questions[i].qname) + " [" + SM.typeLabel(questions[i].qtype) + "]";
                    targetSel.appendChild(opt);
                }

                if (domSelection && domSelection !== "") {
                    targetSel.value = domSelection;
                } else if (storedTarget !== "") {
                    targetSel.value = storedTarget;
                } else {
                    targetSel.selectedIndex = targetSel.options.length > 1 ? 1 : 0;
                }

                renderCondOps(stored ? stored.op : null);

                var resolvedTarget = parseInt(targetSel.value, 10);
                if (!isNaN(resolvedTarget)) {
                    var sameAsStored = stored && parseInt(storedTarget, 10) === resolvedTarget;
                    valueInput.value = sameAsStored ? (stored.value || "") : "";
                    updateCondValueField();
                }
            }

            function renderCondOps(selectedOp) {
                var opSel = document.getElementById("cond-op");
                var t = parseInt(document.getElementById("cond-target").value, 10);
                var ops = SM.opsForType(isNaN(t) ? "string" : questions[t].qtype);
                opSel.innerHTML = "";
                ops.forEach(function (o) {
                    var opt = document.createElement("option");
                    opt.value = o.v;
                    opt.textContent = o.l;
                    opSel.appendChild(opt);
                });
                if (selectedOp && ops.some(function (o) { return o.v === selectedOp; })) {
                    opSel.value = selectedOp;
                } else {
                    opSel.selectedIndex = 0;
                }
            }

            function updateCondValueField() {
                var t = parseInt(document.getElementById("cond-target").value, 10);
                var op = document.getElementById("cond-op").value;
                var valueInput = document.getElementById("cond-value");
                var noValueNeeded = op === "notEmpty";
                valueInput.style.display = noValueNeeded ? "none" : "";
                if (noValueNeeded || isNaN(t)) { return; }

                var qtype = questions[t].qtype;
                if (SM.hasOptions(qtype)) {
                    valueInput.placeholder = "one of: " + questions[t].options.map(function (o) { return o.value; }).join(", ") + " (comma-separate for multiple)";
                } else if (qtype === "int") {
                    valueInput.placeholder = { gt: "greater than, e.g. 5", gte: "greater or equal, e.g. 5", lt: "less than, e.g. 5", lte: "less or equal, e.g. 5" }[op] || "a number";
                } else if (qtype === "date") {
                    valueInput.placeholder = "a date, e.g. 2026-01-31";
                } else if (qtype === "time") {
                    valueInput.placeholder = "a time, e.g. 14:30";
                } else {
                    valueInput.placeholder = "text to compare";
                }
            }

            /* ================= DOM -> state (explicit sync) ================= */

            function showIf(id, show) {
                document.getElementById(id).style.display = show ? "" : "none";
            }

            function syncFromForm() {
                if (selected < 0) { return; }
                var q = questions[selected];
                q.caption = document.getElementById("prop-caption").value;
                q.hint = document.getElementById("prop-hint").value;
                q.qname = document.getElementById("prop-qname").value.trim();
                if (q.qtype === "section" || q.qtype === "calc") {
                    q.required = false;
                    q.readonly = (q.qtype === "calc");
                    q.savable = (q.qtype !== "section");
                } else {
                    q.required = document.getElementById("prop-required").checked;
                    q.hidden = document.getElementById("prop-hidden").checked;
                    q.readonly = document.getElementById("prop-readonly").checked;
                    q.savable = document.getElementById("prop-savable").checked;
                }
                q.errMsg = document.getElementById("prop-errmsg").value.trim();
                var nsRaw = document.getElementById("prop-nextstep").value;
                var naturalNext = (selected + 1 < questions.length) ? String(selected + 1) : "none";
                if (q.nextStep === -1 || (q.nextStep != null && q.nextStep !== -1)) {
                    q.nextStep = nsRaw === "none" ? -1 : (nsRaw !== "" ? parseInt(nsRaw, 10) : null);
                } else {
                    /* legacy sequential (null): don't materialize an index unless the user
                       explicitly diverged from the natural next question / chose None */
                    if (nsRaw === naturalNext) { q.nextStep = null; }
                    else if (nsRaw === "none") { q.nextStep = -1; }
                    else { q.nextStep = parseInt(nsRaw, 10); }
                }
                q.mediaType = document.getElementById("prop-mediatype").value;

                if (q.qtype === "calc") {
                    q.sources = SM.parseSources(document.getElementById("calc-sources").value);
                    q.op = document.getElementById("calc-op").value;
                    q.unit = document.getElementById("calc-unit").value.trim();
                }

                ["placeholder", "minlength", "maxlength", "pattern", "min", "max", "step", "value", "title"].forEach(function (k) {
                    var v = document.getElementById("attr-" + k).value.trim();
                    if (v !== "") { q[k] = v; } else { delete q[k]; }
                });

                var enabled = document.getElementById("cond-enabled").checked;
                var target = parseInt(document.getElementById("cond-target").value, 10);
                var op = document.getElementById("cond-op").value || "in";
                var value = document.getElementById("cond-value").value.trim();
                q.visibleIf = (enabled && !isNaN(target) && target >= 0 && target < selected)
                    ? { target: target, op: op === "notEmpty" ? "notEmpty" : op, value: op === "notEmpty" ? "" : value }
                    : null;

                var jEnabled = document.getElementById("jump-enabled").checked;
                var branchEls = document.querySelectorAll("#jump-branches .sm-branch-row");
                var branches = [];
                Array.prototype.forEach.call(branchEls, function (rowEl) {
                    var op = rowEl.querySelector(".jump-br-op").value || "notEmpty";
                    var val = rowEl.querySelector(".jump-br-value").value.trim();
                    var tgt = parseInt(rowEl.querySelector(".jump-br-target").value, 10);
                    if (isNaN(tgt) || tgt < 0 || tgt === selected || tgt >= questions.length) { return; }
                    branches.push({ target: tgt, op: op === "notEmpty" ? "notEmpty" : op, value: op === "notEmpty" ? "" : val });
                });
                var jElseRaw = document.getElementById("jump-else-target").value;
                var jElse = jElseRaw !== "" ? parseInt(jElseRaw, 10) : null;
                if (jElse !== null && (isNaN(jElse) || jElse < 0 || jElse === selected || jElse >= questions.length)) { jElse = null; }
                q.jump = (jEnabled && (branches.length || jElse !== null))
                    ? { branches: branches, elseTarget: jElse }
                    : null;
            }

            /* ================= actions ================= */

            function selectQuestion(idx) {
                var old = selected;
                if (old >= 0 && old !== idx) { syncFromForm(); }
                selected = idx;
                renderQuestions();
                renderPropertyPanel();
                if (isFlowView()) {
                    if (old >= 0 && old !== idx) { refreshFlowCard(old, false); }
                    if (idx >= 0) { refreshFlowCard(idx, true); }
                }
            }

            function moveQ(i, dir) {
                syncFromForm();
                var j = i + dir;
                if (j < 0 || j >= questions.length) { return; }
                var t = questions[i]; questions[i] = questions[j]; questions[j] = t;

                // remap conditional targets (stored as indexes) after the swap
                questions.forEach(function (q) {
                    var own = questions.indexOf(q);
                    if (q.visibleIf) {
                        var ti = parseInt(q.visibleIf.target, 10);
                        if (ti === i) { ti = j; } else if (ti === j) { ti = i; }
                        q.visibleIf = (ti >= 0 && ti < own)
                            ? { target: ti, op: q.visibleIf.op, value: q.visibleIf.value }
                            : null;
                    }
                    if (q.jump) {
                        normalizeJump(q);
                        var brs = Array.isArray(q.jump.branches) ? q.jump.branches : [];
                        brs.forEach(function (br) {
                            var tj = parseInt(br.target, 10);
                            if (tj === i) { br.target = j; }
                            else if (tj === j) { br.target = i; }
                        });
                        var ej = q.jump.elseTarget != null ? parseInt(q.jump.elseTarget, 10) : null;
                        if (ej != null) { if (ej === i) { ej = j; } else if (ej === j) { ej = i; } }
                        var validBranches = brs.filter(function (br) {
                            var t = parseInt(br.target, 10);
                            return t >= 0 && t < questions.length && t !== own;
                        }).map(function (br) {
                            return { target: parseInt(br.target, 10), op: br.op || "notEmpty", value: (br.op && br.op !== "notEmpty") ? (br.value || "") : "" };
                        });
                        if (ej != null && (ej < 0 || ej >= questions.length || ej === own)) { ej = null; }
                        q.jump = (validBranches.length || ej !== null)
                            ? { branches: validBranches, elseTarget: ej }
                            : null;
                    }
                    if (q.nextStep === -1) {
                        /* explicit "None" - stays */
                    } else if (q.nextStep != null) {
                        var tn = parseInt(q.nextStep, 10);
                        if (!isNaN(tn)) {
                            if (tn === i) { tn = j; } else if (tn === j) { tn = i; }
                            q.nextStep = (tn >= 0 && tn < questions.length && tn !== own) ? tn : null;
                        } else { q.nextStep = null; }
                    }
                });

                if (selected === i) { selected = j; } else if (selected === j) { selected = i; }
                renderQuestions();
                renderPropertyPanel();
            }

            document.addEventListener("click", function (e) {
                var addBtn = e.target.closest(".btn-add");
                if (addBtn) {
                    if (selected >= 0) { syncFromForm(); }
                    questions.push(defaultQ(addBtn.dataset.type));
                    selected = questions.length - 1;
                    renderQuestions();
                    renderPropertyPanel();
                    /* new question must appear on the canvas immediately when Flow View is active */
                    if (isFlowView()) {
                        reloadFlow();
                        selectQuestion(selected);
                    }
                    return;
                }

                var up = e.target.closest(".q-up");
                if (up) { moveQ(parseInt(up.closest(".sm-qcard").dataset.idx, 10), -1); return; }
                var down = e.target.closest(".q-down");
                if (down) { moveQ(parseInt(down.closest(".sm-qcard").dataset.idx, 10), 1); return; }

                var del = e.target.closest(".q-del");
                if (del) {
                    var di = parseInt(del.closest(".sm-qcard").dataset.idx, 10);
                    SM.confirm("Remove question", "Remove question " + (di + 1) + "?", function () {
                        deleteQuestion(di);
                    });
                    return;
                }

                var dup = e.target.closest(".q-dup");
                if (dup) {
                    duplicateQuestion(parseInt(dup.closest(".sm-qcard").dataset.idx, 10));
                    return;
                }

                var card = e.target.closest(".sm-qcard");
                if (card && parseInt(card.dataset.idx, 10) >= 0) {
                    selectQuestion(parseInt(card.dataset.idx, 10));
                }
            });

            /* keep Flow View cards + edges in sync while editing properties */
            function refreshFlowCard(i, active) {
                var el = document.getElementById("card-" + i);
                if (!el) { return; }
                el.innerHTML = questionCardHtml(i, { forFlow: true, active: !!active });
                if (window.plumb) { plumb.revalidate("card-" + i); }
            }

            /* shared by List + Flow delete buttons - remaps numeric rule targets */
            function deleteQuestion(di) {
                if (selected === di) { syncFromForm(); }
                questions.splice(di, 1);
                questions.forEach(function (q) {
                    var own = questions.indexOf(q);
                    if (q.visibleIf) {
                        var ti = parseInt(q.visibleIf.target, 10);
                        if (ti === di) { q.visibleIf = null; }
                        else {
                            if (ti > di) { ti--; }
                            q.visibleIf = (ti >= 0 && ti < own)
                                ? { target: ti, op: q.visibleIf.op, value: q.visibleIf.value }
                                : null;
                        }
                    }
                    if (q.jump) {
                        normalizeJump(q);
                        var brs = Array.isArray(q.jump.branches) ? q.jump.branches : [];
                        var newBranches = [];
                        brs.forEach(function (br) {
                            var tj = parseInt(br.target, 10);
                            if (tj === di) { return; }
                            if (tj > di) { tj--; }
                            newBranches.push({ target: tj, op: br.op || "notEmpty", value: (br.op && br.op !== "notEmpty") ? (br.value || "") : "" });
                        });
                        var ej = q.jump.elseTarget != null ? parseInt(q.jump.elseTarget, 10) : null;
                        if (ej === di) { ej = null; }
                        else if (ej != null && ej > di) { ej--; }
                        if (ej != null && (ej < 0 || ej >= questions.length || ej === own)) { ej = null; }
                        q.jump = (newBranches.length || ej !== null) ? { branches: newBranches, elseTarget: ej } : null;
                    }
                    if (q.nextStep === -1) {
                        /* explicit "None" - stays */
                    } else if (q.nextStep != null) {
                        var tn = parseInt(q.nextStep, 10);
                        if (tn === di) { q.nextStep = null; }
                        else {
                            if (tn > di) { tn--; }
                            q.nextStep = (tn >= 0 && tn < questions.length && tn !== own) ? tn : null;
                        }
                    }
                });
                selected = Math.min(selected >= di ? selected - 1 : selected, questions.length - 1);
                renderQuestions();
                renderPropertyPanel();
                scheduleFlowReload();
            }

            /* duplicate question i: deep copy right after it, unique qname,
               rules on the copy cleared, later rule targets shifted +1 */
            function duplicateQuestion(i) {
                if (selected === i) { syncFromForm(); }
                var copy = JSON.parse(JSON.stringify(questions[i]));
                var names = {};
                questions.forEach(function (q) { names[q.qname] = true; });
                var base = copy.qname || "question";
                var nn = base, s = 2;
                while (names[nn]) { nn = base + "_" + s++; }
                copy.qname = nn;
                copy.visibleIf = null;
                copy.jump = null;
                if (copy.pos && typeof copy.pos.top === "number") {
                    copy.pos = { top: copy.pos.top + 36, left: copy.pos.left + 36 };
                }
                questions.splice(i + 1, 0, copy);
                questions.forEach(function (q) {
                    if (q.visibleIf) {
                        var ti = parseInt(q.visibleIf.target, 10);
                        if (ti >= i + 1) { ti++; }
                        var own = questions.indexOf(q);
                        q.visibleIf = (ti >= 0 && ti < own)
                            ? { target: ti, op: q.visibleIf.op, value: q.visibleIf.value }
                            : null;
                    }
                    if (q.jump) {
                        normalizeJump(q);
                        var brs = Array.isArray(q.jump.branches) ? q.jump.branches : [];
                        var newBranches = brs.map(function (br) {
                            var tj = parseInt(br.target, 10);
                            if (tj >= i + 1) { tj++; }
                            return { target: tj, op: br.op || "notEmpty", value: (br.op && br.op !== "notEmpty") ? (br.value || "") : "" };
                        });
                        var ej = q.jump.elseTarget != null ? parseInt(q.jump.elseTarget, 10) : null;
                        if (ej != null && ej >= i + 1) { ej++; }
                        var own2 = questions.indexOf(q);
                        newBranches = newBranches.filter(function (br) {
                            var t = parseInt(br.target, 10);
                            return t >= 0 && t < questions.length && t !== own2;
                        });
                        if (ej != null && (ej < 0 || ej >= questions.length || ej === own2)) { ej = null; }
                        q.jump = (newBranches.length || ej !== null) ? { branches: newBranches, elseTarget: ej } : null;
                    }
                    if (q.nextStep === -1) {
                        /* explicit "None" - stays */
                    } else if (q.nextStep != null) {
                        var tn = parseInt(q.nextStep, 10);
                        if (tn >= i + 1) { tn++; }
                        var own3 = questions.indexOf(q);
                        q.nextStep = (tn >= 0 && tn < questions.length && tn !== own3) ? tn : null;
                    }
                });
                selected = i + 1;
                renderQuestions();
                renderPropertyPanel();
                scheduleFlowReload();
            }

            /* flow card right-click context menu */
            var flowCtxIdx = -1;
            function showFlowContextMenu(x, y, idx) {
                var menu = document.getElementById("sm-flow-ctx");
                flowCtxIdx = idx;
                menu.style.left = x + "px";
                menu.style.top = y + "px";
                menu.style.display = "block";
            }
            function hideFlowContextMenu() {
                document.getElementById("sm-flow-ctx").style.display = "none";
                flowCtxIdx = -1;
            }
            document.getElementById("ctx-dup").addEventListener("click", function () {
                var idx = flowCtxIdx; hideFlowContextMenu();
                if (idx >= 0) { duplicateQuestion(idx); }
            });
            document.getElementById("ctx-del").addEventListener("click", function () {
                var idx = flowCtxIdx; hideFlowContextMenu();
                if (idx >= 0) {
                    SM.confirm("Remove question", "Remove question " + (idx + 1) + "?", function () {
                        deleteQuestion(idx);
                    });
                }
            });
            document.addEventListener("click", hideFlowContextMenu);

            var flowReloadTimer = null;
            function scheduleFlowReload() {
                if (!isFlowView()) { return; }
                window.clearTimeout(flowReloadTimer);
                flowReloadTimer = window.setTimeout(function () { reloadFlow(); }, 400);
            }
            function afterPropChange(edgeChanged) {
                renderQuestions();
                if (isFlowView()) {
                    if (edgeChanged && selected >= 0) { scheduleFlowReload(); }
                    else if (selected >= 0) { refreshFlowCard(selected, true); }
                }
            }

            ["prop-caption", "prop-qname", "prop-mediatype", "prop-hint",
             "attr-placeholder", "attr-minlength", "attr-maxlength", "attr-pattern", "attr-min", "attr-max", "attr-step",
             "attr-value", "attr-title"].forEach(function (id) {
                document.getElementById(id).addEventListener("input", function () {
                    if (selected < 0) { return; }
                    syncFromForm();
                    afterPropChange(false);
                });
            });
            document.getElementById("prop-required").addEventListener("change", function () {
                if (selected >= 0) {
                    questions[selected].required = this.checked;
                    afterPropChange(false);
                }
            });
            document.getElementById("prop-typelabel").addEventListener("change", function () {
                if (selected >= 0) {
                    var newType = this.value;
                    var oldType = questions[selected].qtype;
                    if (newType !== oldType) {
                        questions[selected].qtype = newType;
                        if (SM.hasOptions(newType) && !SM.hasOptions(oldType)) {
                            if (!questions[selected].options.length) {
                                questions[selected].options = [{value: "opt1", caption: "Option 1"}];
                            }
                        }
                        if (newType === "calc") {
                            questions[selected].sources = questions[selected].sources || [];
                            questions[selected].op = questions[selected].op || "sum";
                            questions[selected].unit = questions[selected].unit || "";
                        }
                        if (newType === "section" || newType === "calc") {
                            questions[selected].options = [];
                        }
                        document.getElementById("options-field").style.display = SM.hasOptions(newType) ? "" : "none";
                        document.getElementById("media-field").style.display = newType === "binary" ? "" : "none";
                        afterPropChange(false);
                    }
                }
            });
            document.getElementById("prop-hidden").addEventListener("change", function () {
                if (selected >= 0) {
                    questions[selected].hidden = this.checked;
                    afterPropChange(false);
                }
            });
            document.getElementById("prop-readonly").addEventListener("change", function () {
                if (selected >= 0) {
                    questions[selected].readonly = this.checked;
                    afterPropChange(false);
                }
            });
            document.getElementById("prop-savable").addEventListener("change", function () {
                if (selected >= 0) {
                    questions[selected].savable = this.checked;
                    afterPropChange(false);
                }
            });
            document.getElementById("prop-nextstep").addEventListener("change", function () {
                if (selected >= 0) {
                    var v = this.value;
                    var naturalNext = (selected + 1 < questions.length) ? String(selected + 1) : "none";
                    var q = questions[selected];
                    if (q.nextStep === -1 || (q.nextStep != null && q.nextStep !== -1)) {
                        q.nextStep = v === "none" ? -1 : (v !== "" ? parseInt(v, 10) : null);
                    } else {
                        if (v === naturalNext) { q.nextStep = null; }
                        else if (v === "none") { q.nextStep = -1; }
                        else { q.nextStep = parseInt(v, 10); }
                    }
                    afterPropChange(true);
                }
            });

            document.getElementById("cond-enabled").addEventListener("change", function () {
                document.getElementById("cond-editor").style.display = this.checked ? "" : "none";
                if (this.checked) {
                    renderCondEditor();
                    syncFromForm();
                    afterPropChange(true);
                } else if (selected >= 0) {
                    questions[selected].visibleIf = null;
                    document.getElementById("cond-target").value = "";
                    afterPropChange(true);
                }
            });
            document.getElementById("cond-target").addEventListener("change", function () {
                renderCondOps(null);
                updateCondValueField();
                if (selected >= 0) { syncFromForm(); afterPropChange(true); }
            });
            document.getElementById("cond-op").addEventListener("change", function () {
                updateCondValueField();
                if (selected >= 0) { syncFromForm(); afterPropChange(true); }
            });
            document.getElementById("cond-value").addEventListener("input", function () {
                if (selected >= 0) { syncFromForm(); afterPropChange(true); }
            });

            document.getElementById("jump-enabled").addEventListener("change", function () {
                document.getElementById("jump-editor").style.display = this.checked ? "" : "none";
                if (this.checked) {
                    renderJumpEditor();
                    syncFromForm();
                    afterPropChange(true);
                } else if (selected >= 0) {
                    questions[selected].jump = null;
                    afterPropChange(true);
                }
            });
            document.getElementById("jump-add-branch").addEventListener("click", function () {
                if (selected < 0) { return; }
                var q = questions[selected];
                if (!q.jump) { q.jump = { branches: [], elseTarget: null }; }
                if (!Array.isArray(q.jump.branches)) { q.jump.branches = []; }
                q.jump.branches.push({ target: "", op: "notEmpty", value: "" });
                renderJumpEditor();
                afterPropChange(true);
            });
            document.getElementById("jump-else-target").addEventListener("change", function () {
                if (selected < 0) { return; }
                syncFromForm();
                afterPropChange(true);
            });

            ["calc-sources", "calc-op", "calc-unit"].forEach(function (id) {
                document.getElementById(id).addEventListener("input", function () {
                    if (selected >= 0) { syncFromForm(); afterPropChange(false); }
                });
                document.getElementById(id).addEventListener("change", function () {
                    if (selected >= 0) { syncFromForm(); afterPropChange(false); }
                });
            });

            document.getElementById("btn-add-option").addEventListener("click", function () {
                if (selected < 0 || !SM.hasOptions(questions[selected].qtype)) { return; }
                syncFromForm();
                var opts = questions[selected].options;
                var maxNum = 0;
                opts.forEach(function (o) {
                    var m = String(o.value).match(/^opt(\d+)$/);
                    if (m) { maxNum = Math.max(maxNum, parseInt(m[1], 10)); }
                });
                opts.push({ value: "opt" + (maxNum + 1), caption: "" });
                renderOptions();
                renderQuestions();
                if (isFlowView()) { refreshFlowCard(selected); }
            });

            document.getElementById("btn-bulk-options").addEventListener("click", function () {
                if (selected < 0 || !SM.hasOptions(questions[selected].qtype)) { return; }
                syncFromForm();
                var ta = document.getElementById("prop-bulk-options");
                var lines = ta.value.split(/\r?\n/);
                var opts = [];
                lines.forEach(function (ln) {
                    ln = ln.trim();
                    if (!ln) { return; }
                    var idx = ln.indexOf("|");
                    var value, caption;
                    if (idx >= 0) { value = ln.substring(0, idx).trim(); caption = ln.substring(idx + 1).trim(); }
                    else { value = ln; caption = ln; }
                    if (!value) { return; }
                    opts.push({ value: value, caption: caption });
                });
                if (!opts.length) { SM.toast("No valid options found.", true); return; }
                questions[selected].options = (questions[selected].options || []).concat(opts);
                renderOptions();
                renderQuestions();
                if (isFlowView()) { refreshFlowCard(selected); }
                ta.value = '';
                SM.toast("Applied " + opts.length + " options.");
            });

            /* ================= validation / save / test ================= */

            function validateAll() {
                if (selected >= 0) { syncFromForm(); }
                var bad = SM.validateQuestions(questions);
                if (bad >= 0) {
                    SM.toast('Please complete question ' + (bad + 1) + ' (caption, variable name and option values).', true);
                    selectQuestion(bad);
                    return false;
                }
                var dups = SM.duplicateNames(questions);
                if (dups.length) {
                    SM.toast("Duplicate variable names: " + dups.join(", ") + ". Each question needs a unique name.", true);
                    return false;
                }
                return true;
            }

            function saveQuestionnaire(onSaved) {
                if (!validateAll()) { return; }
                SM.post(BASE + '/questionnaire/update-config', {
                    id: QID,
                    question: SM.buildConfig(questions)
                }).then(function (resp) {
                    if (resp.code === 200) {
                        SM.toast(resp.body || "Saved.");
                        if (onSaved) { onSaved(); }
                    } else {
                        SM.toast(resp.message || "Save failed.", true);
                    }
                }).catch(function () { SM.toast("Save failed.", true); });
            }

            document.getElementById("btn-test").addEventListener("click", function () {
                if (selected >= 0) { syncFromForm(); }
                if (!questions.length) { SM.toast("Add at least one question before testing.", true); return; }
                var bad = SM.validateQuestions(questions);
                if (bad >= 0) { SM.toast('Note: question ' + (bad + 1) + ' is incomplete, testing current state anyway.', true); }
                SM.renderForm(SM.parseConfig(SM.buildConfig(questions)), document.getElementById("sm-test-form-holder"), true);
                document.querySelector("#sm-modal-test .sm-modal-head h5").textContent = "${NAME}";
                SM.openModal("sm-modal-test");
            });
            document.getElementById("btn-save").addEventListener("click", function () { saveQuestionnaire(null); });
            document.getElementById("btn-save-quit").addEventListener("click", function () {
                saveQuestionnaire(function () { window.location = LIST_URL; });
            });

            SM.get(BASE + '/questionnaire/get/config/' + QID).then(function (resp) {
                questions = resp.code === 200 ? SM.parseConfig(resp.body) : [];
                renderQuestions();
                renderPropertyPanel();
                if (isFlowView()) { reloadFlow(); document.getElementById("flow-tools").style.display = ""; }
            }).catch(function () {
                SM.toast("Could not load existing configuration.", true);
                renderQuestions();
            });

            /* ===== Phase B: data & sharing ===== */
            document.getElementById("btn-export-json").addEventListener("click", function () {
                try {
                    var payload = SM.buildConfig(questions);
                    var blob = new Blob([JSON.stringify(payload, null, 2)], { type: "application/json" });
                    var url = URL.createObjectURL(blob);
                    var a = document.createElement("a");
                    a.href = url;
                    a.download = "questionnaire_" + QID + ".json";
                    document.body.appendChild(a);
                    a.click();
                    document.body.removeChild(a);
                    URL.revokeObjectURL(url);
                } catch (e) {
                    SM.toast("Export failed: " + e.message, true);
                }
            });

            document.getElementById("btn-import-json").addEventListener("click", function () {
                document.getElementById("file-import-json").click();
            });
            document.getElementById("file-import-json").addEventListener("change", function (ev) {
                var file = ev.target.files && ev.target.files[0];
                if (!file) { return; }
                var reader = new FileReader();
                reader.onload = function () {
                    try {
                        var obj = JSON.parse(reader.result);
                        questions = SM.parseConfig(obj);
                        selected = -1;
                        renderQuestions();
                        renderPropertyPanel();
                        if (isFlowView()) { reloadFlow(); }
                        SM.toast("Imported " + questions.length + " question(s). Remember to Save.", false);
                    } catch (e) {
                        SM.toast("Import failed: " + e.message, true);
                    }
                };
                reader.readAsText(file);
                ev.target.value = "";
            });

        </script>
        <script type="text/javascript">
            /* ================= Flow View (jsPlumb, SM2-style design) ================= */

            var plumb = null;
            var rebuildingFlow = false;
            var pendingEdge = null;

            function isFlowView() {
                return document.getElementById("flow-view").style.display !== "none";
            }

            function paintFor(type) {
                if (type === "jump") { return { strokeWidth: 2.5, stroke: "#DA4F49" }; }
                if (type === "elsejump") { return { strokeWidth: 2.5, stroke: "#DA4F49", dashstyle: "7 5" }; }
                if (type === "cond") { return { strokeWidth: 1.5, stroke: "#5BB75B", dashstyle: "7 5" }; }
                return { strokeWidth: 1.5, stroke: "#adb5bd" };
            }

            function ensurePlumb() {
                var canvas = document.getElementById("flow-canvas");
                canvas.innerHTML = "";
                // canvas.style.minHeight = "62vh";

                plumb = jsPlumb.getInstance({
                    Connector: ["Bezier", { curviness: 80 }],
                    PaintStyle: { strokeWidth: 1.5, stroke: "#adb5bd" },
                    HoverPaintStyle: { strokeWidth: 2.5 },
                    Endpoint: ["Dot", { radius: 5 }],
                    EndpointStyle: { fill: "#337ab7", stroke: "#fff" },
                    Anchor: "Continuous",
                    ConnectionOverlays: [["Arrow", { width: 10, length: 10, location: 0.5 }]]
                });

                var startX = 30, startY = 40, colW = 310, rowH = 200, perRow = 3;
                questions.forEach(function (q, i) {
                    var pos = (q.pos && typeof q.pos.top === "number" && typeof q.pos.left === "number")
                        ? q.pos
                        : { top: startY + rowH * Math.floor(i / perRow), left: startX + colW * (i % perRow) };

                    var el = document.createElement("div");
                    el.id = "card-" + i;
                    el.className = "sm-flow-node";
                    el.style.left = pos.left + "px";
                    el.style.top = pos.top + "px";
                    el.innerHTML = questionCardHtml(i, { forFlow: true, active: i === selected });
                    canvas.appendChild(el);

                    /* click to select -> property panel */
                    el.addEventListener("click", function () {
                        if (!rebuildingFlow) { selectQuestion(i); }
                    });

                    /* right-click context menu for flow cards */
                    el.addEventListener("contextmenu", function (e) {
                        if (rebuildingFlow) { return; }
                        e.preventDefault();
                        selectQuestion(i);
                        showFlowContextMenu(e.pageX, e.pageY, i);
                    });

                    /* select/move on MOUSEDOWN - never mid-gesture */
                    el.addEventListener("mousedown", function (e) {
                        if (rebuildingFlow) { return; }

                        /* body press -> click selects, movement drags anywhere */
                        var moved = false;
                        var sx = e.pageX, sy = e.pageY, ol = el.offsetLeft, ot = el.offsetTop;

                        function mm(ev) {
                            var dx = ev.pageX - sx, dy = ev.pageY - sy;
                            if (!moved && Math.abs(dx) + Math.abs(dy) > 4) { moved = true; }
                            if (moved) {
                                el.style.left = (ol + dx) + "px";
                                el.style.top = (ot + dy) + "px";
                                if (plumb) { plumb.revalidate("card-" + i); }
                            }
                            ev.preventDefault();
                        }
                        function mu() {
                            document.removeEventListener("mousemove", mm);
                            document.removeEventListener("mouseup", mu);
                            questions[i].pos = { top: el.offsetTop, left: el.offsetLeft };
                            if (!moved) { selectQuestion(i); }
                        }
                        document.addEventListener("mousemove", mm);
                        document.addEventListener("mouseup", mu);
                        e.preventDefault();
                    });
                    /* interactive creation is handled by the handle-drop logic above;
                       jsPlumb only renders the connections */
                    questions[i].pos = pos;
                });

                plumb.bind("connection", onConnCreated);
                plumb.bind("connectionDetached", onConnDetached);
                plumb.bind("click", onConnClick);
            }

            function connectCards(fromI, toI, type) {
                try {
                    plumb.connect({
                        source: "card-" + fromI,
                        target: "card-" + toI,
                        paintStyle: paintFor(type),
                        overlays: [["Arrow", { width: 10, length: 10, location: 0.5 }]]
                    });
                } catch (e) { console.error("connect failed", e); }
            }

            function reloadFlow() {
                if (!isFlowView()) { return; }
                if (!questions.length) {
                    rebuildingFlow = true;
                    plumb = null;
                    var c = document.getElementById("flow-canvas");
                    c.innerHTML = '<div class="sm-flow-placeholder">No questions yet.<br/>Switch to List View and add fields \u2014 the flow will appear here automatically.</div>';
                    window.setTimeout(function () { rebuildingFlow = false; }, 50);
                    return;
                }
                rebuildingFlow = true;
                ensurePlumb();

                /* sequential chain - follows each question's Next Step (default: next sequential).
                   nextStep === -1 ("None") draws no connector; null keeps legacy sequential behaviour.
                   skip the chain where the target question's visibleIf already links the pair. */
                questions.forEach(function (q, ci) {
                    if (q.nextStep === -1) { return; }
                    var t = (q.nextStep != null && !isNaN(parseInt(q.nextStep, 10)))
                        ? parseInt(q.nextStep, 10)
                        : ci + 1;
                    if (t < 0 || t >= questions.length || t === ci) { return; }
                    if (questions[t].visibleIf && parseInt(questions[t].visibleIf.target, 10) === ci) { return; }
                    connectCards(ci, t, "chain");
                });
                /* rule edges */
                questions.forEach(function (q, i) {
                    if (q.jump) {
                        normalizeJump(q);
                        var brs = Array.isArray(q.jump.branches) ? q.jump.branches : [];
                        brs.forEach(function (br) {
                            var t = parseInt(br.target, 10);
                            if (!isNaN(t) && t >= 0 && t < questions.length && t !== i) {
                                connectCards(i, t, "jump");
                            }
                        });
                        var et = q.jump.elseTarget != null ? parseInt(q.jump.elseTarget, 10) : null;
                        if (et != null && et >= 0 && et < questions.length && et !== i) {
                            connectCards(i, et, "elsejump");
                        }
                    }
                    if (q.visibleIf) {
                        var v = parseInt(q.visibleIf.target, 10);
                        if (!isNaN(v) && v >= 0 && v < i) {
                            connectCards(v, i, "cond");
                        }
                    }
                });

                plumb.repaintEverything();
                window.setTimeout(function () { rebuildingFlow = false; }, 120);
            }

            function findEdgeType(fromI, toI) {
                var q = questions[fromI];
                if (q && q.jump) {
                    if (Array.isArray(q.jump.branches) && q.jump.branches.some(function (br) {
                        return parseInt(br.target, 10) === toI;
                    })) { return "jump"; }
                    if (q.jump.elseTarget != null && parseInt(q.jump.elseTarget, 10) === toI) { return "elsejump"; }
                }
                if (questions[toI] && questions[toI].visibleIf &&
                    parseInt(questions[toI].visibleIf.target, 10) === fromI) { return "cond"; }
                if (toI === fromI + 1) { return "chain"; }
                return "";
            }

            function onConnCreated(info) {
                if (rebuildingFlow || !plumb) { return; }
                var f = parseInt(String(info.sourceId).replace("card-", ""), 10);
                var t = parseInt(String(info.targetId).replace("card-", ""), 10);
                if (isNaN(f) || isNaN(t) || f === t) { reloadFlow(); return; }
                if (findEdgeType(f, t) === "cond") { reloadFlow(); return; }
                var q = questions[f];
                var bidx = -1;
                if (q.jump && Array.isArray(q.jump.branches)) {
                    for (var b = 0; b < q.jump.branches.length; b++) {
                        if (parseInt(q.jump.branches[b].target, 10) === t) { bidx = b; break; }
                    }
                }
                openJumpModal(f, t, bidx);
            }

            function onConnDetached(info) {
                if (rebuildingFlow) { return; }
                reloadFlow();
            }

            function onConnClick(conn) {
                if (rebuildingFlow) { return; }
                var f = parseInt(String(conn.sourceId).replace("card-", ""), 10);
                var t = parseInt(String(conn.targetId).replace("card-", ""), 10);
                var type = findEdgeType(f, t);
                if (type === "jump" || type === "elsejump") {
                    var label = type === "elsejump" ? "else branch" : "jump branch";
                    SM.confirm("Remove " + label,
                        "Remove the jump branch from <strong>Q" + (f + 1) + "</strong> to <strong>Q" + (t + 1) + "</strong>?",
                        function () {
                            var q = questions[f];
                            if (!q.jump) { return; }
                            if (type === "elsejump") {
                                q.jump.elseTarget = null;
                            } else {
                                q.jump.branches = q.jump.branches.filter(function (br) {
                                    return parseInt(br.target, 10) !== t;
                                });
                            }
                            if ((!q.jump.branches || !q.jump.branches.length) && q.jump.elseTarget == null) {
                                q.jump = null;
                            }
                            renderQuestions();
                            reloadFlow();
                        });
                } else {
                    /* chain/condition edges are config-managed - restore visuals */
                    reloadFlow();
                }
            }

            function openJumpModal(fromI, toI, branchIdx) {
                pendingEdge = { from: fromI, to: toI, branchIdx: branchIdx };
                var q = questions[fromI];
                normalizeJump(q);
                document.getElementById("jump-edge-title").textContent =
                    "Jump Rule: Q" + (fromI + 1) + " \u2192 Q" + (toI + 1);
                document.getElementById("jump-edge-info").innerHTML =
                    "<strong>" + SM.escapeHtml(q.caption || q.qname) + "</strong>" +
                    (toI > fromI ? " skips everything up to " : " rewinds back to ") +
                    "<strong>" + SM.escapeHtml(questions[toI].caption || questions[toI].qname) + "</strong>";

                var opSel = document.getElementById("edge-op");
                opSel.innerHTML = "";
                SM.opsForType(q.qtype).forEach(function (o) {
                    var opt = document.createElement("option");
                    opt.value = o.v;
                    opt.textContent = o.l;
                    opSel.appendChild(opt);
                });

                var existing = (q.jump && Array.isArray(q.jump.branches) && branchIdx >= 0 && branchIdx < q.jump.branches.length)
                    ? q.jump.branches[branchIdx] : null;
                if (existing) {
                    opSel.value = existing.op || "notEmpty";
                    document.getElementById("edge-value").value = (existing.op && existing.op !== "notEmpty") ? (existing.value || "") : "";
                } else {
                    opSel.selectedIndex = 0;
                    document.getElementById("edge-value").value = "";
                }

                var elseSel = document.getElementById("edge-else-target");
                elseSel.innerHTML = '<option value="">No action (continue sequentially)</option>';
                for (var ei = 0; ei < questions.length; ei++) {
                    if (ei === fromI) { continue; }
                    var eopt = document.createElement("option");
                    eopt.value = String(ei);
                    eopt.textContent = (ei < fromI ? "\u21BA back to Q" : "go to Q") + (ei + 1) + ". " + (questions[ei].caption || questions[ei].qname);
                    elseSel.appendChild(eopt);
                }
                elseSel.value = (q.jump && q.jump.elseTarget != null) ? String(q.jump.elseTarget) : "";

                document.getElementById("edge-remove").style.display =
                    (q.jump && (Array.isArray(q.jump.branches) && q.jump.branches.length || q.jump.elseTarget != null)) ? "" : "none";

                updateEdgeValueField();
                SM.openModal("sm-modal-jump");
            }

            function updateEdgeValueField() {
                var op = document.getElementById("edge-op").value;
                document.getElementById("edge-value").style.display = op === "notEmpty" ? "none" : "";
            }

            document.getElementById("edge-op").addEventListener("change", updateEdgeValueField);
            document.getElementById("edge-cancel").addEventListener("click", function () {
                SM.closeModals();
                pendingEdge = null;
                reloadFlow();
            });
            document.getElementById("edge-remove").addEventListener("click", function () {
                if (!pendingEdge) { SM.closeModals(); reloadFlow(); return; }
                var f = pendingEdge.from, t = pendingEdge.to, bidx = pendingEdge.branchIdx;
                var q = questions[f];
                if (q.jump) {
                    if (bidx >= 0 && Array.isArray(q.jump.branches) && bidx < q.jump.branches.length) {
                        q.jump.branches.splice(bidx, 1);
                    }
                    if ((!q.jump.branches || !q.jump.branches.length) && q.jump.elseTarget == null) {
                        q.jump = null;
                    }
                }
                SM.closeModals();
                pendingEdge = null;
                renderQuestions();
                reloadFlow();
            });
            document.getElementById("edge-apply").addEventListener("click", function () {
                if (!pendingEdge) { SM.closeModals(); reloadFlow(); return; }
                var f = pendingEdge.from, t = pendingEdge.to, bidx = pendingEdge.branchIdx;
                var op = document.getElementById("edge-op").value;
                var val = document.getElementById("edge-value").value.trim();
                var elseRaw = document.getElementById("edge-else-target").value;
                var elseTarget = elseRaw !== "" ? parseInt(elseRaw, 10) : null;
                if (elseTarget !== null && (isNaN(elseTarget) || elseTarget < 0 || elseTarget === f || elseTarget >= questions.length)) { elseTarget = null; }

                var q = questions[f];
                if (!q.jump) { q.jump = { branches: [], elseTarget: null }; }
                if (!Array.isArray(q.jump.branches)) { q.jump.branches = []; }
                var branch = { target: t, op: op === "notEmpty" ? "notEmpty" : op, value: op === "notEmpty" ? "" : val };
                if (bidx >= 0 && bidx < q.jump.branches.length) {
                    q.jump.branches[bidx] = branch;
                } else {
                    q.jump.branches.push(branch);
                }
                q.jump.elseTarget = elseTarget;
                SM.closeModals();
                pendingEdge = null;
                renderQuestions();
                reloadFlow();
            });

            function showListView() {
                document.getElementById("flow-view").style.display = "none";
                document.getElementById("list-view").style.display = "";
                document.getElementById("btn-view-list").classList.add("active");
                document.getElementById("btn-view-flow").classList.remove("active");
                document.getElementById("flow-tools").style.display = "none";
                renderQuestions();
            }

            function showFlowView() {
                syncFromForm();
                document.getElementById("list-view").style.display = "none";
                document.getElementById("flow-view").style.display = "";
                document.getElementById("btn-view-flow").classList.add("active");
                document.getElementById("btn-view-list").classList.remove("active");
                document.getElementById("flow-tools").style.display = "";
                reloadFlow();
            }
            document.getElementById("btn-view-list").addEventListener("click", showListView);
            document.getElementById("btn-view-flow").addEventListener("click", function () {
                if (!isFlowView()) { showFlowView(); }
            });

            /* drag background to pan */
            (function () {
                var wrap = document.getElementById("flow-canvas-wrap");
                var dragging = false, sx = 0, sy = 0, sl = 0, st = 0;
                wrap.addEventListener("mousedown", function (e) {
                    if (e.target.closest(".sm-flow-node")) { return; }
                    dragging = true; sx = e.pageX; sy = e.pageY; sl = wrap.scrollLeft; st = wrap.scrollTop;
                });
                window.addEventListener("mousemove", function (e) {
                    if (!dragging) { return; }
                    wrap.scrollLeft = sl - (e.pageX - sx);
                    wrap.scrollTop = st - (e.pageY - sy);
                });
                window.addEventListener("mouseup", function () { dragging = false; });
            })();
        </script>
    </body>
</html>
