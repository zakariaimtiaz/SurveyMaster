<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<html lang="en">
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
        <meta charset="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <link rel="icon" type="image/x-icon" href="${STATIC_RES}/images/x-diamond.svg" />
        <title>Agents - ${APP_NAME}</title>
        <%@include file="common/resoucelink_css.jsp" %>
        <style>
            .sm-top-row { display: flex; gap: 1.5rem; flex-wrap: wrap; margin-bottom: 1.5rem; }
            .sm-top-left { flex: 1 1 380px; }
            .sm-top-right { flex: 0 0 260px; display: flex; flex-direction: column; align-items: center; }
            .sm-qr-box {
                width: 220px; height: 220px; border: 2px dashed #cbd5e1; border-radius: 12px;
                display: flex; align-items: center; justify-content: center;
                background: #f8fafc; margin-bottom: 0.75rem; overflow: hidden;
            }
            .sm-qr-box img { max-width: 100%; max-height: 100%; }
            .sm-qr-placeholder { color: #94a3b8; font-size: 0.85rem; text-align: center; padding: 1rem; }
            .sm-qr-actions { display: flex; gap: 0.5rem; }
            .sm-section-title { font-size: 1rem; font-weight: 700; color: #1e293b; margin-bottom: 0.75rem; }
            .sm-card-panel {
                background: #fff; border: 1px solid #e5e7eb; border-radius: 10px;
                padding: 1.25rem; margin-bottom: 1.5rem;
            }
        </style>
    </head>

    <body>
        <%@include file="common/header_panel.jsp" %>

        <div class="sm-wrap">

            <div class="sm-top-row">
                <div class="sm-top-left">
                    <!-- Create company form (shown when no company) -->
                    <div id="panel-create" class="sm-card-panel" style="display:none;">
                        <div class="sm-section-title">Create Your Company</div>
                        <form id="company-create-form" novalidate>
                            <div class="mb-3">
                                <label class="form-label fw-semibold">Name <span style="color:#dc3545;">*</span></label>
                                <input type="text" class="form-control" name="name" maxlength="200" required />
                            </div>
                            <div class="mb-3">
                                <label class="form-label fw-semibold">Description</label>
                                <textarea class="form-control" name="description" rows="2"></textarea>
                            </div>
                            <div class="mb-3">
                                <label class="form-label fw-semibold">Company Key</label>
                                <div class="input-group">
                                    <input type="text" class="form-control" name="companyKey" id="create-companyKey" readonly />
                                    <button type="button" class="btn btn-outline-secondary" id="btn-regen-key">Regenerate</button>
                                </div>
                                <div class="form-text">Auto-generated 6-character uppercase alphanumeric key (unique).</div>
                            </div>
                        </form>
                        <button type="button" class="btn btn-primary btn-sm" id="btn-create-company">Create Company</button>
                    </div>

                    <!-- Company info form (shown when company exists) -->
                    <div id="panel-info" class="sm-card-panel" style="display:none;">
                        <div class="d-flex justify-content-between align-items-center mb-2">
                            <div class="sm-section-title mb-0">Company Info</div>
                            <button type="button" class="btn btn-outline-primary btn-sm" id="btn-edit-company">Edit</button>
                        </div>
                        <div id="company-view">
                            <div class="mb-2"><strong>Name:</strong> <span id="view-name"></span></div>
                            <div class="mb-2"><strong>Description:</strong> <span id="view-desc"></span></div>
                            <div class="mb-2"><strong>Company Key:</strong> <code id="view-key"></code></div>
                        </div>
                        <div id="company-edit" style="display:none;">
                            <form id="company-edit-form" novalidate>
                                <div class="mb-2">
                                    <label class="form-label fw-semibold small">Name</label>
                                    <input type="text" class="form-control form-control-sm" name="name" maxlength="200" required />
                                </div>
                                <div class="mb-2">
                                    <label class="form-label fw-semibold small">Description</label>
                                    <textarea class="form-control form-control-sm" name="description" rows="2"></textarea>
                                </div>
                                <div class="mb-2">
                                    <label class="form-label fw-semibold small">Company Key</label>
                                    <input type="text" class="form-control form-control-sm" name="companyKey" id="edit-companyKey" readonly />
                                </div>
                            </form>
                            <div class="d-flex gap-2">
                                <button type="button" class="btn btn-outline-secondary btn-sm" id="btn-cancel-edit">Cancel</button>
                                <button type="button" class="btn btn-primary btn-sm" id="btn-save-company">Save</button>
                            </div>
                        </div>
                    </div>

                    <!-- Agents table -->
                    <div id="panel-keys" class="sm-card-panel" style="display:none;">
                        <div class="d-flex justify-content-between align-items-center mb-2">
                            <div class="sm-section-title mb-0">Agents</div>
                            <button type="button" class="btn btn-success btn-sm" id="btn-new-key">+ Create</button>
                        </div>
                        <table class="table table-hover align-middle mb-0 sm-stack">
                            <thead class="table-light">
                                <tr>
                                    <th>Name</th>
                                    <th>Key</th>
                                    <th>Expiration</th>
                                    <th>Status</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody id="key-list-body">
                                <tr><td colspan="5" class="sm-empty">Loading...</td></tr>
                            </tbody>
                        </table>
                    </div>
                </div>

                <div class="sm-top-right">
                    <div class="sm-qr-box" id="qr-box">
                        <div class="sm-qr-placeholder">QR code will appear here</div>
                    </div>
                    <div class="sm-qr-actions" id="qr-actions" style="display:none;">
                        <button type="button" class="btn btn-outline-primary btn-sm" id="btn-qr-view">View</button>
                        <button type="button" class="btn btn-outline-secondary btn-sm" id="btn-qr-regen">Regenerate</button>
                    </div>
                </div>
            </div>
        </div>

        <!-- Create Agent Modal -->
        <div class="sm-modal" id="sm-modal-create">
            <div class="sm-modal-head"><h5>Create Agent</h5><button type="button" class="btn-close sm-modal-close"></button></div>
            <div class="sm-modal-body">
                <form id="create-form" novalidate>
                    <div class="mb-3">
                        <label class="form-label fw-semibold">Key</label>
                        <div class="input-group">
                            <input type="text" class="form-control" name="keyValue" id="create-keyValue" readonly />
                            <button type="button" class="btn btn-outline-secondary" id="btn-regenerate">Regenerate</button>
                        </div>
                        <div class="form-text">Auto-generated 4-character uppercase alphanumeric token.</div>
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-semibold">Name</label>
                        <input type="text" class="form-control" name="name" maxlength="200" required />
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-semibold">Expiration</label>
                        <input type="date" class="form-control" name="expiration" required />
                    </div>
                </form>
            </div>
            <div class="sm-modal-foot">
                <button type="button" class="btn btn-outline-secondary sm-modal-close">Cancel</button>
                <button type="button" class="btn btn-primary" id="btn-create-save">Create</button>
            </div>
        </div>

        <!-- Edit Agent Modal -->
        <div class="sm-modal" id="sm-modal-edit">
            <div class="sm-modal-head"><h5>Edit Agent</h5><button type="button" class="btn-close sm-modal-close"></button></div>
            <div class="sm-modal-body">
                <form id="edit-form" novalidate>
                    <input type="hidden" name="id" />
                    <div class="mb-3">
                        <label class="form-label fw-semibold">Key</label>
                        <input type="text" class="form-control" name="keyValue" maxlength="200" required readonly />
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-semibold">Name</label>
                        <input type="text" class="form-control" name="name" maxlength="200" required />
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-semibold">Expiration</label>
                        <input type="date" class="form-control" name="expiration" required />
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-semibold">Status</label>
                        <div class="form-check form-switch">
                            <input class="form-check-input" type="checkbox" id="edit-status" checked />
                            <label class="form-check-label" for="edit-status">Active</label>
                        </div>
                    </div>
                </form>
            </div>
            <div class="sm-modal-foot">
                <button type="button" class="btn btn-outline-secondary sm-modal-close">Cancel</button>
                <button type="button" class="btn btn-primary" id="btn-edit-save">Save</button>
            </div>
        </div>

        <!-- QR View Modal -->
        <div class="sm-modal" id="sm-modal-qr">
            <div class="sm-modal-head"><h5>QR Code</h5><button type="button" class="btn-close sm-modal-close"></button></div>
            <div class="sm-modal-body text-center">
                <img id="qr-view-img" src="" alt="QR Code" style="max-width:100%;border:1px solid #e5e7eb;border-radius:8px;" />
            </div>
            <div class="sm-modal-foot">
                <button type="button" class="btn btn-outline-secondary sm-modal-close">Close</button>
                <a class="btn btn-info" id="qr-view-download" href="#" target="_blank">Download</a>
            </div>
        </div>

        <%@include file="common/footer.jsp" %>
        <%@include file="common/resoucelink_scripts.jsp" %>

        <script type="text/javascript">
            var BASE = '${BASE_URL}';
            var CID = '${COMPANY_ID}';
            var CNAME = '${COMPANY_NAME}';
            var CKEY = '${COMPANY_KEY}';
            var hasCompany = CID && CID !== '' && CID !== 'null';

            function formatDate(d) {
                if (!d) return '-';
                var dt = new Date(d);
                if (isNaN(dt.getTime())) return '-';
                return dt.getFullYear() + '-' + String(dt.getMonth()+1).padStart(2,'0') + '-' + String(dt.getDate()).padStart(2,'0');
            }
            function toInputDate(d) {
                if (!d) return '';
                var dt = new Date(d);
                if (isNaN(dt.getTime())) return '';
                return dt.getFullYear() + '-' + String(dt.getMonth()+1).padStart(2,'0') + '-' + String(dt.getDate()).padStart(2,'0');
            }

            // --- QR Code ---
            function loadQR() {
                if (!hasCompany) return;
                var box = document.getElementById('qr-box');
                box.innerHTML = '<img src="' + BASE + '/company/' + CID + '/qrcode?t=' + Date.now() + '" alt="QR Code" />';
                document.getElementById('qr-actions').style.display = 'flex';
            }

            // --- Company Info ---
            function showCompanyView(name, desc) {
                document.getElementById('view-name').textContent = name || '-';
                document.getElementById('view-desc').textContent = desc || '-';
                document.getElementById('view-key').textContent = (CKEY && CKEY !== 'null' && CKEY !== '') ? CKEY : '-';
                document.getElementById('company-view').style.display = 'block';
                document.getElementById('company-edit').style.display = 'none';
                document.getElementById('btn-edit-company').style.display = 'inline-block';
            }

            document.getElementById('btn-edit-company').addEventListener('click', function() {
                var f = document.getElementById('company-edit-form');
                f.name.value = document.getElementById('view-name').textContent;
                f.description.value = document.getElementById('view-desc').textContent;
                f.companyKey.value = (CKEY && CKEY !== 'null' && CKEY !== '') ? CKEY : '';
                document.getElementById('company-view').style.display = 'none';
                document.getElementById('company-edit').style.display = 'block';
                document.getElementById('btn-edit-company').style.display = 'none';
            });

            document.getElementById('btn-cancel-edit').addEventListener('click', function() {
                document.getElementById('company-view').style.display = 'block';
                document.getElementById('company-edit').style.display = 'none';
                document.getElementById('btn-edit-company').style.display = 'inline-block';
            });

            document.getElementById('btn-save-company').addEventListener('click', function() {
                var f = document.getElementById('company-edit-form');
                if (!f.name.value.trim()) { SM.toast("Name is required.", true); return; }
                SM.post(BASE + '/company/update', {
                    id: CID, name: f.name.value.trim(), description: f.description.value.trim(), state: true
                }).then(function(resp) {
                    if (resp.code === 200) { SM.toast(resp.body); showCompanyView(f.name.value.trim(), f.description.value.trim()); }
                    else { SM.toast(resp.message || "Save failed.", true); }
                }).catch(function() { SM.toast("Save failed.", true); });
            });

            // --- Create Company ---
            function populateCreateKey() {
                var inp = document.getElementById('create-companyKey');
                inp.value = 'Generating...';
                SM.get(BASE + '/company/generate-key').then(function(resp) {
                    inp.value = (resp.code === 200 && resp.body) ? resp.body : genCompanyKey();
                }).catch(function() { inp.value = genCompanyKey(); });
            }
            document.getElementById('btn-regen-key').addEventListener('click', populateCreateKey);

            document.getElementById('btn-create-company').addEventListener('click', function() {
                var f = document.getElementById('company-create-form');
                if (!f.name.value.trim()) { SM.toast("Name is required.", true); f.name.focus(); return; }
                SM.post(BASE + '/company/create', {
                    name: f.name.value.trim(), description: f.description.value.trim(),
                    companyKey: (f.companyKey.value || '').trim()
                }).then(function(resp) {
                    if (resp.code === 200) { SM.toast(resp.body); window.location.reload(); }
                    else { SM.toast(resp.message || "Create failed.", true); }
                }).catch(function() { SM.toast("Create failed.", true); });
            });

            // --- API Keys ---
            function loadList() {
                if (!hasCompany) return;
                SM.get(BASE + '/company/' + CID + '/agent/get/all').then(function(resp) {
                    var tbody = document.getElementById("key-list-body");
                    tbody.innerHTML = "";
                    if (resp.code !== 200 || !resp.body || !resp.body.length) {
                        tbody.innerHTML = '<tr><td colspan="5" class="sm-empty">No agents yet. Click "+ Create Agent".</td></tr>';
                        return;
                    }
                    resp.body.forEach(function(item) {
                        var id = item.AGENT_ID;
                        var active = item.STATUS == 1;
                        var tr = document.createElement("tr");
                        tr.innerHTML =
                            '<td>' + SM.escapeHtml(item.NAME || '-') + '</td>' +
                            '<td><code>' + SM.escapeHtml(item.KEY_VALUE) + '</code> <button type="button" class="btn btn-sm btn-link p-0 btn-copy-key" data-key="' + SM.escapeHtml(item.KEY_VALUE) + '" title="Copy">&#128203;</button></td>' +
                            '<td>' + formatDate(item.EXPIRATION) + '</td>' +
                            '<td><span class="badge ' + (active ? 'bg-success' : 'bg-secondary') + '">' + (active ? 'Active' : 'Inactive') + '</span></td>' +
                            '<td>' +
                            '<button type="button" class="btn btn-sm btn-outline-info me-1 btn-edit" data-id="' + id + '" data-key="' + SM.escapeHtml(item.KEY_VALUE) + '" data-name="' + SM.escapeHtml(item.NAME || '') + '" data-exp="' + toInputDate(item.EXPIRATION) + '" data-status="' + active + '">Edit</button>' +
                            '<button type="button" class="btn btn-sm btn-danger btn-delete" data-id="' + id + '" data-key="' + SM.escapeHtml(item.KEY_VALUE) + '">Delete</button>' +
                            '</td>';
                        tbody.appendChild(tr);
                    });
                }).catch(function() { SM.toast("Error fetching keys.", true); });
            }

            document.addEventListener("click", function(e) {
                var copyBtn = e.target.closest(".btn-copy-key");
                if (copyBtn) {
                    var key = copyBtn.dataset.key;
                    if (navigator.clipboard) { navigator.clipboard.writeText(key).then(function(){ SM.toast("Agent copied."); }); }
                    else { var ta=document.createElement("textarea"); ta.value=key; ta.style.position="fixed"; ta.style.left="-9999px"; document.body.appendChild(ta); ta.select(); document.execCommand("copy"); document.body.removeChild(ta); SM.toast("Agent copied."); }
                    return;
                }
                var editBtn = e.target.closest(".btn-edit");
                if (editBtn) {
                    var f = document.getElementById("edit-form");
                    f.id.value = editBtn.dataset.id;
                    f.keyValue.value = editBtn.dataset.key;
                    f.name.value = editBtn.dataset.name;
                    f.expiration.value = editBtn.dataset.exp;
                    document.getElementById("edit-status").checked = editBtn.dataset.status === "true";
                    SM.openModal("sm-modal-edit");
                }
                var delBtn = e.target.closest(".btn-delete");
                if (delBtn) {
                    var id = delBtn.dataset.id, key = delBtn.dataset.key;
                    SM.confirm("Delete Agent", "Delete agent <strong>" + key + "</strong>?", function() {
                        SM.post(BASE + '/company/' + CID + '/agent/delete/' + id, {}).then(function(resp) {
                            if (resp.code === 200) { SM.toast(resp.body); loadList(); }
                            else { SM.toast(resp.message || "Failed.", true); }
                        }).catch(function() { SM.toast("Failed.", true); });
                    });
                }
            });

            function openCreateKey() {
                document.getElementById("create-form").reset();
                document.getElementById("create-keyValue").value = 'Generating...';
                SM.openModal("sm-modal-create");
                generateServerKey();
            }
            document.getElementById("btn-new-key").addEventListener("click", openCreateKey);
            document.getElementById("btn-regenerate").addEventListener("click", generateServerKey);

            function generateServerKey() {
                SM.get(BASE + '/company/' + CID + '/agent/generate-token').then(function(resp) {
                    document.getElementById("create-keyValue").value = (resp.code===200 && resp.body) ? resp.body : genKey();
                }).catch(function(){ document.getElementById("create-keyValue").value = genKey(); });
            }
            function genKey() { var c='ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789',k=''; for(var i=0;i<4;i++) k+=c.charAt(Math.floor(Math.random()*c.length)); return k; }
            function genCompanyKey() { var c='ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789',k=''; for(var i=0;i<6;i++) k+=c.charAt(Math.floor(Math.random()*c.length)); return k; }

            document.getElementById("btn-create-save").addEventListener("click", function() {
                var f = document.getElementById("create-form");
                var kv = f.keyValue.value.trim();
                if (!kv || kv==='Generating...') { SM.toast("Wait for generation.", true); return; }
                if (!f.name.value.trim()) { SM.toast("Name is required.", true); f.name.focus(); return; }
                if (!f.expiration.value) { SM.toast("Expiration is required.", true); f.expiration.focus(); return; }
                SM.post(BASE + '/company/' + CID + '/agent/create', { keyValue:kv, label:f.name.value.trim(), expiration:f.expiration.value||null }).then(function(resp) {
                    if (resp.code===200) { SM.closeModals(); SM.toast(resp.body||'Agent created'); loadList(); }
                    else { SM.toast(resp.message||"Failed.",true); }
                }).catch(function(){ SM.toast("Failed.",true); });
            });

            document.getElementById("btn-edit-save").addEventListener("click", function() {
                var f = document.getElementById("edit-form");
                if (!f.name.value.trim()) { SM.toast("Name is required.",true); f.name.focus(); return; }
                if (!f.expiration.value) { SM.toast("Expiration is required.",true); f.expiration.focus(); return; }
                SM.post(BASE + '/company/' + CID + '/agent/update', {
                    id:f.id.value, label:f.name.value.trim(),
                    expiration:f.expiration.value||null, status:document.getElementById("edit-status").checked
                }).then(function(resp) {
                    if (resp.code===200) { SM.closeModals(); SM.toast(resp.body); loadList(); }
                    else { SM.toast(resp.message||"Failed.",true); }
                }).catch(function(){ SM.toast("Failed.",true); });
            });

            // --- QR View ---
            document.getElementById('btn-qr-view').addEventListener('click', function() {
                document.getElementById('qr-view-img').src = BASE + '/company/' + CID + '/qrcode';
                document.getElementById('qr-view-download').href = BASE + '/company/' + CID + '/qrcode';
                SM.openModal('sm-modal-qr');
            });

            document.getElementById('btn-qr-regen').addEventListener('click', function() {
                SM.confirm("Regenerate QR Code",
                    "This generates a new company key and QR code. Any already-scanned QR / mobile client using the old key will stop working until they scan the new code. Continue?",
                    function() {
                        SM.post(BASE + '/company/regenerate-key', {}).then(function(resp) {
                            if (resp.code === 200 && resp.body) {
                                CKEY = resp.body;
                                document.getElementById('view-key').textContent = resp.body;
                                var ek = document.getElementById('edit-companyKey');
                                if (ek) { ek.value = resp.body; }
                                loadQR();
                                SM.toast("QR code regenerated.");
                            } else {
                                SM.toast(resp.message || "Regenerate failed.", true);
                            }
                        }).catch(function() { SM.toast("Regenerate failed.", true); });
                    });
            });

            // --- Init ---
            if (hasCompany) {
                document.getElementById('panel-info').style.display = 'block';
                document.getElementById('panel-keys').style.display = 'block';
                showCompanyView(CNAME, '${COMPANY_DESC}');
                loadQR();
                loadList();
            } else {
                document.getElementById('panel-create').style.display = 'block';
                populateCreateKey();
            }
        </script>
    </body>
</html>
