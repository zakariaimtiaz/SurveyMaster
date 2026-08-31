<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<html lang="en">
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
        <meta charset="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <link rel="icon" type="image/x-icon" href="${STATIC_RES}/images/x-diamond.svg" />
        <title>Companies - ${APP_NAME}</title>
        <%@include file="common/resoucelink_css.jsp" %>
        <style>.form-check-input.btn-toggle-state { cursor: pointer; }</style>
    </head>

    <body>
        <%@include file="common/header_panel.jsp" %>

        <div class="sm-wrap">
            <div class="sm-toolbar">
                <span class="sm-title">All Companies</span>
                <span class="sm-actions">
                    <input type="text" class="form-control form-control-sm" id="search-input" placeholder="Search..." style="width:220px;" />
                </span>
            </div>

            <div class="sm-table-card p-1">
                <table class="table table-hover align-middle mb-0 sm-stack">
                    <thead class="table-light d-none-m">
                        <tr>
                            <th>Name</th>
                            <th>Key</th>
                            <th>Description</th>
                            <th>Agents</th>
                            <th>Status</th>
                        </tr>
                    </thead>
                    <tbody id="list-body">
                        <tr><td colspan="5" class="sm-empty">Loading...</td></tr>
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
                    tbody.innerHTML = '<tr><td colspan="5" class="sm-empty">No companies found.</td></tr>';
                    return;
                }
                data.forEach(function (item) {
                    var active = item.STATE == 1;
                    var id = item.COMPANY_ID;
                    var tr = document.createElement("tr");
                    tr.innerHTML =
                        '<td>' + SM.escapeHtml(item.NAME || '-') + '</td>' +
                        '<td><code>' + SM.escapeHtml(item.COMPANY_KEY || '-') + '</code></td>' +
                        '<td>' + SM.escapeHtml(item.DESCRIPTION || '-') + '</td>' +
                        '<td>' + (item.AGENT_COUNT || 0) + '</td>' +
                        '<td>' +
                        '<div class="form-check form-switch">' +
                        '<input class="form-check-input btn-toggle-state" type="checkbox" data-id="' + id + '" ' + (active ? 'checked' : '') + ' />' +
                        '<label class="form-check-label">' + (active ? 'Active' : 'Inactive') + '</label>' +
                        '</div></td>';
                    tbody.appendChild(tr);
                });
            }

            function filterList() {
                var q = document.getElementById("search-input").value.toLowerCase();
                if (!q) { renderList(allData); return; }
                var filtered = allData.filter(function (item) {
                    return (item.NAME || '').toLowerCase().indexOf(q) !== -1 ||
                           (item.DESCRIPTION || '').toLowerCase().indexOf(q) !== -1 ||
                           (item.COMPANY_KEY || '').toLowerCase().indexOf(q) !== -1;
                });
                renderList(filtered);
            }

            function loadList() {
                SM.get(BASE + '/company/get/all-admin').then(function (resp) {
                    if (resp.code !== 200 || !resp.body) { allData = []; renderList(allData); return; }
                    allData = resp.body;
                    renderList(allData);
                }).catch(function () {
                    SM.toast("Error fetching companies.", true);
                });
            }

            document.getElementById("search-input").addEventListener("input", filterList);

            document.addEventListener("change", function (e) {
                var toggle = e.target.closest(".btn-toggle-state");
                if (toggle) {
                    var id = toggle.dataset.id;
                    var state = toggle.checked;
                    var label = toggle.nextElementSibling;
                    var action = state ? 'activate' : 'inactivate';
                    var prevState = !state;
                    toggle.checked = prevState;
                    label.textContent = prevState ? 'Active' : 'Inactive';
                    SM.confirm('Confirm', 'Are you sure you want to ' + action + ' this company?', function () {
                        toggle.checked = state;
                        label.textContent = state ? 'Active' : 'Inactive';
                        SM.post(BASE + '/company/toggle-state', { id: id, state: state }).then(function (resp) {
                            if (resp.code === 200) {
                                SM.toast(resp.body);
                            } else {
                                toggle.checked = prevState;
                                label.textContent = prevState ? 'Active' : 'Inactive';
                                SM.toast(resp.message || "Failed.", true);
                            }
                        }).catch(function () {
                            toggle.checked = prevState;
                            label.textContent = prevState ? 'Active' : 'Inactive';
                            SM.toast("Failed.", true);
                        });
                    });
                }
            });

            loadList();
        </script>
    </body>
</html>
