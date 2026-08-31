<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<html lang="en">
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
        <meta charset="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <link rel="icon" type="image/x-icon" href="${STATIC_RES}/images/x-diamond.svg" />
        <title>APK Management - ${APP_NAME}</title>
        <%@include file="common/resoucelink_css.jsp" %>
        <style>
            .sm-progress-wrap { background:#e9ecef; border-radius:6px; height:24px; overflow:hidden; margin-top:0.5rem; }
            .sm-progress-bar { background:#28a745; height:100%; width:0%; transition:width 0.3s; text-align:center; color:#fff; font-size:0.8rem; line-height:24px; }
            .sm-upload-status { margin-top:0.5rem; font-size:0.85rem; }
        </style>
    </head>

    <body>
        <%@include file="common/header_panel.jsp" %>

        <div class="sm-wrap">
            <div class="sm-toolbar">
                <span class="sm-title">APK Management</span>
                <span class="sm-actions">
                    <button type="button" class="btn btn-success btn-sm" id="btn-upload-open">+ Upload APK</button>
                </span>
            </div>

            <div class="sm-table-card p-1">
                <table class="table table-hover align-middle mb-0 sm-stack">
                    <thead class="table-light d-none-m">
                        <tr>
                            <th>File Name</th>
                            <th>Version</th>
                            <th>Size</th>
                            <th>Uploaded At</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody id="list-body">
                        <tr><td colspan="5" class="sm-empty">Loading...</td></tr>
                    </tbody>
                </table>
            </div>
        </div>

        <!-- Upload Modal -->
        <div class="sm-modal" id="sm-modal-upload">
            <div class="sm-modal-head"><h5>Upload APK</h5><button type="button" class="btn-close sm-modal-close"></button></div>
            <div class="sm-modal-body">
                <div id="upload-form-area">
                    <div class="mb-3">
                        <label class="form-label fw-semibold">Select APK File</label>
                        <input type="file" class="form-control" id="file-input" accept=".apk" />
                        <div class="form-text">Only .apk files are allowed.</div>
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-semibold">Version</label>
                        <input type="text" class="form-control" id="version-input" placeholder="e.g. 1.0.0" maxlength="20" />
                        <div class="form-text">Optional version string displayed to users.</div>
                    </div>
                    <div id="upload-progress-area" style="display:none;">
                        <div class="sm-progress-wrap">
                            <div class="sm-progress-bar" id="progress-bar">0%</div>
                        </div>
                        <div class="sm-upload-status" id="upload-status">Uploading...</div>
                    </div>
                </div>
            </div>
            <div class="sm-modal-foot">
                <button type="button" class="btn btn-outline-secondary sm-modal-close" id="btn-upload-cancel">Cancel</button>
                <button type="button" class="btn btn-primary" id="btn-upload-save">Upload</button>
            </div>
        </div>

        <%@include file="common/footer.jsp" %>
        <%@include file="common/resoucelink_scripts.jsp" %>

        <script type="text/javascript">
            var BASE = '${BASE_URL}';

            function formatSize(bytes) {
                if (!bytes || bytes === 0) return '0 B';
                var units = ['B', 'KB', 'MB', 'GB'];
                var i = Math.floor(Math.log(bytes) / Math.log(1024));
                return (bytes / Math.pow(1024, i)).toFixed(1) + ' ' + units[i];
            }

            function formatDate(d) {
                if (!d) return '-';
                var dt = new Date(d);
                if (isNaN(dt.getTime())) return '-';
                return dt.getFullYear() + '-' + String(dt.getMonth()+1).padStart(2,'0') + '-' + String(dt.getDate()).padStart(2,'0') + ' ' + String(dt.getHours()).padStart(2,'0') + ':' + String(dt.getMinutes()).padStart(2,'0');
            }

            function loadList() {
                SM.get(BASE + '/apk/get/all').then(function (resp) {
                    var tbody = document.getElementById("list-body");
                    tbody.innerHTML = "";
                    if (resp.code !== 200 || !resp.body || !resp.body.length) {
                        tbody.innerHTML = '<tr><td colspan="5" class="sm-empty">No APK files uploaded yet.</td></tr>';
                        return;
                    }
                    resp.body.forEach(function (item) {
                        var tr = document.createElement("tr");
                        tr.innerHTML =
                            '<td>' + SM.escapeHtml(item.ORIGINAL_NAME || '-') + '</td>' +
                            '<td>' + SM.escapeHtml(item.VERSION || '-') + '</td>' +
                            '<td>' + formatSize(item.FILE_SIZE) + '</td>' +
                            '<td>' + formatDate(item.UPLOADED_AT) + '</td>' +
                            '<td>' +
                            '<a class="btn btn-sm btn-outline-primary me-1" href="' + BASE + '/apk/download/' + item.APK_ID + '">Download</a>' +
                            '<button type="button" class="btn btn-sm btn-danger btn-delete" data-id="' + item.APK_ID + '" data-name="' + SM.escapeHtml(item.ORIGINAL_NAME || '') + '">Delete</button>' +
                            '</td>';
                        tbody.appendChild(tr);
                    });
                }).catch(function () {
                    SM.toast("Error fetching APK list.", true);
                });
            }

            // --- Upload Modal ---
            document.getElementById("btn-upload-open").addEventListener("click", function () {
                document.getElementById("file-input").value = '';
                document.getElementById("version-input").value = '';
                document.getElementById("upload-progress-area").style.display = 'none';
                document.getElementById("btn-upload-save").style.display = '';
                document.getElementById("btn-upload-cancel").textContent = 'Cancel';
                SM.openModal("sm-modal-upload");
            });

            document.getElementById("btn-upload-save").addEventListener("click", function () {
                var fileInput = document.getElementById("file-input");
                if (!fileInput.files.length) {
                    SM.toast("Please select an APK file.", true);
                    return;
                }
                var file = fileInput.files[0];
                if (!file.name.toLowerCase().endsWith('.apk')) {
                    SM.toast("Only .apk files are allowed.", true);
                    return;
                }

                var formData = new FormData();
                formData.append("file", file);
                formData.append("version", document.getElementById("version-input").value.trim());

                document.getElementById("upload-progress-area").style.display = 'block';
                document.getElementById("btn-upload-save").style.display = 'none';
                document.getElementById("btn-upload-cancel").textContent = 'Close';
                var progressBar = document.getElementById("progress-bar");
                var statusText = document.getElementById("upload-status");
                progressBar.style.width = '0%';
                progressBar.textContent = '0%';
                statusText.textContent = 'Uploading...';
                statusText.style.color = '';

                var xhr = new XMLHttpRequest();
                xhr.open("POST", BASE + "/apk/upload", true);

                xhr.upload.onprogress = function (e) {
                    if (e.lengthComputable) {
                        var pct = Math.round((e.loaded / e.total) * 100);
                        progressBar.style.width = pct + '%';
                        progressBar.textContent = pct + '%';
                    }
                };

                xhr.onload = function () {
                    var resp;
                    try { resp = JSON.parse(xhr.responseText); } catch (ev) { resp = { code: xhr.status }; }
                    if (resp.code === 200) {
                        progressBar.style.width = '100%';
                        progressBar.textContent = '100%';
                        progressBar.style.background = '#28a745';
                        statusText.textContent = resp.body || 'Upload complete!';
                        statusText.style.color = '#28a745';
                        loadList();
                    } else {
                        progressBar.style.background = '#dc3545';
                        statusText.textContent = resp.message || 'Upload failed.';
                        statusText.style.color = '#dc3545';
                    }
                };

                xhr.onerror = function () {
                    progressBar.style.background = '#dc3545';
                    statusText.textContent = 'Upload failed. Network error.';
                    statusText.style.color = '#dc3545';
                };

                xhr.send(formData);
            });

            // --- Delete ---
            document.addEventListener("click", function (e) {
                var delBtn = e.target.closest(".btn-delete");
                if (delBtn) {
                    var id = delBtn.dataset.id;
                    var name = delBtn.dataset.name;
                    SM.confirm("Delete APK", "Delete <strong>" + name + "</strong>? This cannot be undone!", function () {
                        SM.post(BASE + '/apk/delete/' + id, {}).then(function (resp) {
                            if (resp.code === 200) { SM.toast(resp.body); loadList(); }
                            else { SM.toast(resp.message || "Delete failed.", true); }
                        }).catch(function () { SM.toast("Delete failed.", true); });
                    });
                }
            });

            loadList();
        </script>
    </body>
</html>
