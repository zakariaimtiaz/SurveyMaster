<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<html lang="en">
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
        <meta charset="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <link rel="icon" type="image/x-icon" href="${STATIC_RES}/images/x-diamond.svg" />
        <title>Questionnaires - ${APP_NAME}</title>
        <%@include file="common/resoucelink_css.jsp" %>
    </head>

    <body>
        <%@include file="common/header_panel.jsp" %>

        <div class="sm-wrap">
            <div class="sm-toolbar">
                <span class="sm-title">Questionnaire List</span>
                <span class="sm-actions">
                    <button type="button" class="btn btn-success" id="btn-new">+ Create</button>
                </span>
            </div>

            <div class="sm-table-card p-1">
                <table class="table table-hover align-middle mb-0 sm-stack">
                    <thead class="table-light d-none-m">
                        <tr>
                            <th>Name</th>
                            <th>Caption</th>
                            <th>Description</th>
                            <th>Status</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody id="list-body">
                        <tr><td colspan="5" class="sm-empty">Loading...</td></tr>
                    </tbody>
                </table>
            </div>
        </div>

        <div class="sm-modal" id="sm-modal-create">
            <div class="sm-modal-head"><h5>Create Questionnaire</h5><button type="button" class="btn-close sm-modal-close"></button></div>
            <div class="sm-modal-body">
                <form id="create-form" novalidate>
                    <div class="mb-3">
                        <label class="form-label fw-semibold">Name <span style="color:#dc3545;">*</span></label>
                        <input type="text" class="form-control" name="name" maxlength="200" required />
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-semibold">Caption</label>
                        <input type="text" class="form-control" name="caption" maxlength="255" />
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-semibold">Description</label>
                        <textarea class="form-control" name="description" rows="3"></textarea>
                    </div>
                </form>
            </div>
            <div class="sm-modal-foot">
                <button type="button" class="btn btn-outline-secondary sm-modal-close">Cancel</button>
                <button type="button" class="btn btn-primary" id="btn-create-save">Create</button>
            </div>
        </div>

        <div class="sm-modal" id="sm-modal-edit">
            <div class="sm-modal-head"><h5>Edit Questionnaire</h5><button type="button" class="btn-close sm-modal-close"></button></div>
            <div class="sm-modal-body">
                <form id="edit-form" novalidate>
                    <input type="hidden" name="id" />
                    <div class="mb-3">
                        <label class="form-label fw-semibold">Name <span style="color:#dc3545;">*</span></label>
                        <input type="text" class="form-control" name="name" maxlength="200" required />
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-semibold">Caption</label>
                        <input type="text" class="form-control" name="caption" maxlength="255" />
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-semibold">Description</label>
                        <textarea class="form-control" name="description" rows="3"></textarea>
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-semibold">Status</label>
                        <select class="form-select" name="state">
                            <option value="1">Active</option>
                            <option value="0">Inactive</option>
                        </select>
                    </div>
                </form>
            </div>
            <div class="sm-modal-foot">
                <button type="button" class="btn btn-outline-secondary sm-modal-close">Cancel</button>
                <button type="button" class="btn btn-primary" id="btn-edit-save">Save</button>
            </div>
        </div>

        <%@include file="common/footer.jsp" %>
        <%@include file="common/resoucelink_scripts.jsp" %>

        <script type="text/javascript">
            var BASE = '${BASE_URL}';

            function stateBadge(active) {
                if (active) {
                    return '<span class="badge bg-success">Active</span>';
                }
                return '<span class="badge bg-secondary">Inactive</span>';
            }

            function loadList() {
                SM.get(BASE + '/questionnaire/get/all').then(function (resp) {
                    var tbody = document.getElementById("list-body");
                    tbody.innerHTML = "";
                    if (resp.code !== 200 || !resp.body || !resp.body.length) {
                        tbody.innerHTML = '<tr><td colspan="5" class="sm-empty">No questionnaires found. Click "Create Questionnaire" to get started.</td></tr>';
                        return;
                    }
                    resp.body.forEach(function (item) {
                        var id = item.QUESTIONNAIRE_ID;
                        var isActive = (item.STATE === 1 || item.STATE === true || item.STATE === "1");
                        var isPublished = (item.PUBLISHED === 1 || item.PUBLISHED === true || item.PUBLISHED === "1");
                        var tr = document.createElement("tr");
                        tr.innerHTML =
                            '<td data-label="Name">' + SM.escapeHtml(item.NAME) + '</td>' +
                            '<td data-label="Caption">' + SM.escapeHtml(item.CAPTION || '-') + '</td>' +
                            '<td data-label="Description">' + SM.escapeHtml(item.DESCRIPTION || '-') + '</td>' +
                            '<td data-label="Status">' + stateBadge(isActive) + (isPublished ? ' <span class="badge bg-info">Published</span>' : '') + '</td>' +
                            '<td class="sm-actions-cell" data-label="Actions">' +
                            '<button type="button" class="btn btn-sm btn-primary me-1 btn-test" data-id="' + id + '" data-name="' + SM.escapeHtml(item.NAME) + '">Test</button>' +
                            '<div class="dropdown d-inline-block">' +
                            '<button type="button" class="btn btn-sm btn-outline-secondary dropdown-toggle" data-bs-toggle="dropdown" aria-expanded="false" title="More actions" aria-label="More actions">&#8942;</button>' +
                            '<ul class="dropdown-menu dropdown-menu-end">' +
                            '<li><button type="button" class="dropdown-item btn-edit" data-id="' + id + '" data-name="' + SM.escapeHtml(item.NAME) + '" data-caption="' + SM.escapeHtml(item.CAPTION || '') + '" data-desc="' + SM.escapeHtml(item.DESCRIPTION || '') + '" data-state="' + (isActive ? 1 : 0) + '">Edit</button></li>' +
                            '<li><a class="dropdown-item" href="' + BASE + '/questionnaire/get/details/' + id + '">Build</a></li>' +
                            '<li><a class="dropdown-item" href="' + BASE + '/response/export/csv?questionnaireId=' + id + '">Export CSV</a></li>' +
                            '<li><button type="button" class="dropdown-item btn-qr" data-id="' + id + '">QR Code</button></li>' +
                            '<li><button type="button" class="dropdown-item btn-toggle" data-id="' + id + '" data-state="' + (isActive ? 1 : 0) + '">' + (isActive ? 'Deactivate' : 'Activate') + '</button></li>' +
                            '<li><button type="button" class="dropdown-item btn-publish" data-id="' + id + '" data-published="' + (isPublished ? 1 : 0) + '">' + (isPublished ? 'Unpublish' : 'Publish') + '</button></li>' +
                            '<li><hr class="dropdown-divider"></li>' +
                            '<li><button type="button" class="dropdown-item text-warning btn-clear" data-id="' + id + '" data-name="' + SM.escapeHtml(item.NAME) + '">Clear responses</button></li>' +
                            '<li><button type="button" class="dropdown-item text-danger btn-delete" data-id="' + id + '" data-name="' + SM.escapeHtml(item.NAME) + '">Delete</button></li>' +
                            '</ul>' +
                            '</div>' +
                            '</td>';
                        tbody.appendChild(tr);
                    });
                }).catch(function () {
                    SM.toast("Error fetching questionnaire list.", true);
                });
            }

            function openTest(id, name) {
                SM.get(BASE + '/questionnaire/get/config/' + id).then(function (resp) {
                    if (resp.code !== 200) { SM.toast(resp.message || "Could not load form.", true); return; }
                    var questions = SM.parseConfig(resp.body);
                    if (!questions.length) {
                        SM.toast("This questionnaire has no questions yet. Build it first.", true);
                        return;
                    }
                    SM.renderForm(questions, document.getElementById("sm-test-form-holder"), true);
                    document.querySelector("#sm-modal-test .sm-modal-head h5").textContent = name || "Form Test";
                    SM.openModal("sm-modal-test");
                }).catch(function () { SM.toast("Could not load form config.", true); });
            }

            function openQR(id) {
                SM.get(BASE + '/questionnaire/' + id + '/qrcode/base64').then(function (r) {
                    if (r.code !== 200 || !r.body) { SM.toast("Could not generate QR code.", true); return; }
                    document.getElementById("sm-list-qr-img").src = r.body;
                    document.getElementById("sm-list-qr-link").href = BASE + '/questionnaire/' + id + '/qrcode';
                    SM.openModal("sm-modal-list-qr");
                }).catch(function () { SM.toast("Could not generate QR code.", true); });
            }

            document.addEventListener("click", function (e) {
                var testBtn = e.target.closest(".btn-test");
                if (testBtn) { openTest(testBtn.dataset.id, testBtn.dataset.name); }

                var qrBtn = e.target.closest(".btn-qr");
                if (qrBtn) { openQR(qrBtn.dataset.id); }

                var editBtn = e.target.closest(".btn-edit");
                if (editBtn) {
                    var f = document.getElementById("edit-form");
                    f.id.value = editBtn.dataset.id;
                    f.name.value = editBtn.dataset.name;
                    f.caption.value = editBtn.dataset.caption;
                    f.description.value = editBtn.dataset.desc;
                    f.state.value = editBtn.dataset.state === "1" ? "1" : "0";
                    SM.openModal("sm-modal-edit");
                }

                var toggleBtn = e.target.closest(".btn-toggle");
                if (toggleBtn) {
                    var id = toggleBtn.dataset.id;
                    var current = (toggleBtn.dataset.state === "1") ? 1 : 0;
                    var next = current === 1 ? 0 : 1;
                    SM.post(BASE + '/questionnaire/update-state', { id: id, state: next }).then(function (resp) {
                        if (resp.code === 200) { SM.toast(resp.body); loadList(); }
                        else { SM.toast(resp.message || "State update failed.", true); }
                    }).catch(function () { SM.toast("State update failed.", true); });
                }

                var pubBtn = e.target.closest(".btn-publish");
                if (pubBtn) {
                    var id = pubBtn.dataset.id;
                    var current = (pubBtn.dataset.published === "1") ? 1 : 0;
                    var next = current === 1 ? 0 : 1;
                    SM.post(BASE + '/questionnaire/update-published', { id: id, published: next }).then(function (resp) {
                        if (resp.code === 200) { SM.toast(resp.body); loadList(); }
                        else { SM.toast(resp.message || "Publish update failed.", true); }
                    }).catch(function () { SM.toast("Publish update failed.", true); });
                }

                var delBtn = e.target.closest(".btn-delete");
                if (delBtn) {
                    var id = delBtn.dataset.id;
                    var name = delBtn.dataset.name;
                    SM.confirm("Delete questionnaire", "Delete <strong>" + name + "</strong>? This cannot be undone!", function () {
                        SM.post(BASE + '/questionnaire/delete/' + id, {}).then(function (resp) {
                            if (resp.code === 200) { SM.toast(resp.body); loadList(); }
                            else { SM.toast(resp.message || "Delete failed.", true); }
                        }).catch(function () { SM.toast("Delete failed.", true); });
                    });
                }

                var clearBtn = e.target.closest(".btn-clear");
                if (clearBtn) {
                    var cid = clearBtn.dataset.id;
                    var cname = clearBtn.dataset.name;
                    SM.confirm("Clear responses", "Delete <strong>all stored responses</strong> for <strong>" + cname + "</strong>? The questionnaire itself is kept. This cannot be undone!", function () {
                        SM.post(BASE + '/response/delete-by-questionnaire', { questionnaireId: cid }).then(function (resp) {
                            if (resp.code === 200) { SM.toast(resp.body); }
                            else { SM.toast(resp.message || "Clear failed.", true); }
                        }).catch(function () { SM.toast("Clear failed.", true); });
                    });
                }
            });

            document.getElementById("btn-new").addEventListener("click", function () {
                document.getElementById("create-form").reset();
                SM.openModal("sm-modal-create");
            });

            document.getElementById("btn-create-save").addEventListener("click", function () {
                var f = document.getElementById("create-form");
                if (!f.name.value.trim()) { SM.toast("Name is required.", true); f.name.focus(); return; }
                SM.post(BASE + '/questionnaire/create', {
                    name: f.name.value.trim(),
                    caption: f.caption.value.trim(),
                    description: f.description.value.trim()
                }).then(function (resp) {
                    if (resp.code === 200) { SM.closeModals(); SM.toast(resp.body); loadList(); }
                    else { SM.toast(resp.message || "Create failed.", true); }
                }).catch(function () { SM.toast("Create failed.", true); });
            });

            document.getElementById("btn-edit-save").addEventListener("click", function () {
                var f = document.getElementById("edit-form");
                if (!f.name.value.trim()) { SM.toast("Name is required.", true); f.name.focus(); return; }
                SM.post(BASE + '/questionnaire/update-details', {
                    id: f.id.value,
                    name: f.name.value.trim(),
                    caption: f.caption.value.trim(),
                    description: f.description.value.trim(),
                    state: f.state.value
                }).then(function (resp) {
                    if (resp.code === 200) { SM.closeModals(); SM.toast(resp.body); loadList(); }
                    else { SM.toast(resp.message || "Save failed.", true); }
                }).catch(function () { SM.toast("Save failed.", true); });
            });

            loadList();
        </script>

        <div class="sm-modal" id="sm-modal-list-qr">
            <div class="sm-modal-head"><h5>Questionnaire QR Code</h5><button type="button" class="btn-close sm-modal-close"></button></div>
            <div class="sm-modal-body text-center">
                <img id="sm-list-qr-img" alt="Questionnaire QR" style="width:240px;height:240px;border:1px solid #dee2e6;" />
                <div class="form-text mt-2">Scan with the mobile app to load this questionnaire.</div>
                <a id="sm-list-qr-link" class="btn btn-sm btn-outline-secondary mt-2" target="_blank" href="#">Open QR image</a>
            </div>
            <div class="sm-modal-foot">
                <button type="button" class="btn btn-outline-secondary sm-modal-close">Close</button>
            </div>
        </div>
    </body>
</html>
