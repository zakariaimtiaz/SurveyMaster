<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<html lang="en">
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
        <meta charset="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <link rel="icon" type="image/x-icon" href="${STATIC_RES}/images/x-diamond.svg" />
        <title>Edit Questionnaire - ${APP_NAME}</title>
        <%@include file="common/resoucelink_css.jsp" %>
    </head>

    <body>
        <%@include file="common/header_panel.jsp" %>

        <div class="sm-wrap">
            <div class="sm-toolbar">
                <span class="sm-title">Edit Questionnaire: ${NAME}</span>
                <span class="sm-actions">
                    <a class="btn btn-outline-secondary" href="${BASE_URL}/">Back to List</a>
                </span>
            </div>

            <div class="sm-panel mx-auto" style="max-width: 640px;">
                <form id="edit-form" novalidate>
                    <input type="hidden" name="id" value="${QUESTIONNAIRE_ID}" />
                    <div class="mb-3">
                        <label class="form-label fw-semibold">Name <span style="color:#dc3545;">*</span></label>
                        <input type="text" class="form-control" name="name" value="${NAME}" maxlength="200" required />
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-semibold">Caption</label>
                        <input type="text" class="form-control" name="caption" value="${CAPTION}" maxlength="255" />
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-semibold">Description</label>
                        <textarea class="form-control" name="description" rows="4">${DESCRIPTION}</textarea>
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-semibold">Status</label>
                        <select class="form-select" name="state">
                            <option value="1" ${STATE == 1 || STATE == '1' ? 'selected' : ''}>Active</option>
                            <option value="0" ${STATE == 0 || STATE == '0' ? 'selected' : ''}>Inactive</option>
                        </select>
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-semibold">Published</label>
                        <div class="form-check">
                            <input class="form-check-input" type="checkbox" name="published" value="1"
                                ${PUBLISHED == 1 || PUBLISHED == '1' ? 'checked' : ''} />
                            <label class="form-check-label">Visible to the mobile app (only published &amp; active questionnaires are loaded)</label>
                        </div>
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-semibold">Version</label>
                        <input type="text" class="form-control" name="version" value="${VERSION}" maxlength="20" placeholder="e.g. 1.0" />
                    </div>
                    <button type="submit" class="btn btn-primary me-2">Save</button>
                    <a class="btn btn-warning me-2" href="${BASE_URL}/questionnaire/get/details/${QUESTIONNAIRE_ID}">Build Form</a>
                    <a class="btn btn-outline-secondary" href="${BASE_URL}/">Close</a>
                </form>
            </div>
        </div>

        <%@include file="common/footer.jsp" %>
        <%@include file="common/resoucelink_scripts.jsp" %>

        <script type="text/javascript">
            document.getElementById("edit-form").addEventListener("submit", function (e) {
                e.preventDefault();
                var f = this;
                if (!f.name.value.trim()) { SM.toast("Name is required.", true); f.name.focus(); return; }
                SM.post('${BASE_URL}/questionnaire/update-details', {
                    id: f.id.value,
                    name: f.name.value.trim(),
                    caption: f.caption.value.trim(),
                    description: f.description.value.trim(),
                    state: f.state.value,
                    published: f.published.checked ? "1" : "0",
                    version: f.version.value.trim()
                }).then(function (resp) {
                    if (resp.code === 200) { SM.toast(resp.body); }
                    else { SM.toast(resp.message || "Save failed.", true); }
                }).catch(function () { SM.toast("Save failed.", true); });
            });
        </script>
    </body>
</html>
