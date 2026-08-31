<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<html lang="en">
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
        <meta charset="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <link rel="icon" type="image/x-icon" href="${STATIC_RES}/images/x-diamond.svg" />
        <title>All Questionnaires - ${APP_NAME}</title>
        <%@include file="common/resoucelink_css.jsp" %>
    </head>

    <body>
        <%@include file="common/header_panel.jsp" %>

        <div class="sm-wrap">
            <div class="sm-toolbar">
                <span class="sm-title">All Questionnaires</span>
                <span class="sm-actions">
                    <input type="text" class="form-control form-control-sm" id="search-input" placeholder="Search..." style="width:220px;" />
                </span>
            </div>

            <div class="sm-table-card p-1">
                <table class="table table-hover align-middle mb-0 sm-stack">
                    <thead class="table-light d-none-m">
                        <tr>
                            <th>Company</th>
                            <th>Name</th>
                            <th>Caption</th>
                            <th>Description</th>
                        </tr>
                    </thead>
                    <tbody id="list-body">
                        <tr><td colspan="4" class="sm-empty">Loading...</td></tr>
                    </tbody>
                </table>
            </div>
        </div>

        <%@include file="common/footer.jsp" %>
        <%@include file="common/resoucelink_scripts.jsp" %>

        <script type="text/javascript">
            var BASE = '${BASE_URL}';
            var allData = [];

            function renderList(data) {
                var tbody = document.getElementById("list-body");
                tbody.innerHTML = "";
                if (!data.length) {
                    tbody.innerHTML = '<tr><td colspan="4" class="sm-empty">No active questionnaires found.</td></tr>';
                    return;
                }
                data.forEach(function (item) {
                    var tr = document.createElement("tr");
                    tr.innerHTML =
                        '<td>' + SM.escapeHtml(item.COMPANY_NAME || '-') + '</td>' +
                        '<td>' + SM.escapeHtml(item.NAME || '-') + '</td>' +
                        '<td>' + SM.escapeHtml(item.CAPTION || '-') + '</td>' +
                        '<td>' + SM.escapeHtml(item.DESCRIPTION || '-') + '</td>';
                    tbody.appendChild(tr);
                });
            }

            function filterList() {
                var q = document.getElementById("search-input").value.toLowerCase();
                if (!q) { renderList(allData); return; }
                var filtered = allData.filter(function (item) {
                    return (item.COMPANY_NAME || '').toLowerCase().indexOf(q) !== -1 ||
                           (item.NAME || '').toLowerCase().indexOf(q) !== -1 ||
                           (item.CAPTION || '').toLowerCase().indexOf(q) !== -1 ||
                           (item.DESCRIPTION || '').toLowerCase().indexOf(q) !== -1;
                });
                renderList(filtered);
            }

            function loadList() {
                SM.get(BASE + '/questionnaire/get/all').then(function (resp) {
                    if (resp.code !== 200 || !resp.body) { allData = []; renderList(allData); return; }
                    allData = resp.body;
                    renderList(allData);
                }).catch(function () {
                    SM.toast("Error fetching questionnaires.", true);
                });
            }

            document.getElementById("search-input").addEventListener("input", filterList);

            loadList();
        </script>
    </body>
</html>
