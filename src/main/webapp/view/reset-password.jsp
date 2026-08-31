<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<html lang="en">
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
        <meta charset="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <link rel="icon" type="image/x-icon" href="${STATIC_RES}/images/x-diamond.svg" />
        <title>Reset Password - ${APP_NAME}</title>
        <%@include file="common/resoucelink_css.jsp" %>
        <style>
            body {
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                min-height: 100vh;
                display: flex;
                align-items: center;
                justify-content: center;
                padding: 2rem 1rem;
            }
            .sm-reset-container { width: 100%; max-width: 420px; }
            .sm-reset-card {
                background: #fff; border-radius: 16px; box-shadow: 0 20px 60px rgba(0,0,0,0.3);
                padding: 2.5rem 2rem 2rem; position: relative; overflow: hidden;
            }
            .sm-reset-card::before {
                content: ''; position: absolute; top: 0; left: 0; right: 0; height: 4px;
                background: linear-gradient(90deg, #667eea, #764ba2);
            }
            .sm-reset-title { text-align: center; font-size: 1.5rem; font-weight: 700; color: #1a1a2e; margin-bottom: 0.25rem; }
            .sm-reset-subtitle { text-align: center; color: #6c757d; font-size: 0.9rem; margin-bottom: 1.75rem; }
            .sm-form-group { margin-bottom: 1.25rem; }
            .sm-form-group label { display: block; font-size: 0.85rem; font-weight: 600; color: #374151; margin-bottom: 0.4rem; }
            .sm-form-group .sm-input-wrapper { position: relative; }
            .sm-form-group .sm-input-icon {
                position: absolute; left: 14px; top: 50%; transform: translateY(-50%);
                color: #9ca3af; font-size: 1rem; pointer-events: none;
            }
            .sm-form-group input[type="password"] {
                width: 100%; padding: 0.7rem 0.75rem 0.7rem 2.5rem;
                border: 1.5px solid #e5e7eb; border-radius: 10px; font-size: 0.95rem;
                color: #1f2937; background: #f9fafb; outline: none; box-sizing: border-box;
                transition: border-color 0.2s, box-shadow 0.2s, background 0.2s;
            }
            .sm-form-group input:focus { border-color: #667eea; box-shadow: 0 0 0 3px rgba(102,126,234,0.15); background: #fff; }
            .sm-btn-reset {
                width: 100%; padding: 0.75rem; border: none; border-radius: 10px;
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                color: #fff; font-size: 1rem; font-weight: 600; cursor: pointer;
                transition: transform 0.15s, box-shadow 0.15s; margin-top: 0.5rem;
            }
            .sm-btn-reset:hover { transform: translateY(-1px); box-shadow: 0 6px 20px rgba(102,126,234,0.4); }
            .sm-alert { padding: 0.65rem 1rem; border-radius: 8px; font-size: 0.88rem; margin-bottom: 1rem; display: none; }
            .sm-alert-danger { background: #fef2f2; color: #dc2626; border: 1px solid #fecaca; }
            .sm-alert-success { background: #f0fdf4; color: #16a34a; border: 1px solid #bbf7d0; }
            .sm-login-link { text-align: center; margin-top: 1.25rem; font-size: 0.9rem; color: #6b7280; }
            .sm-login-link a { color: #667eea; text-decoration: none; font-weight: 600; }
            .sm-login-link a:hover { text-decoration: underline; }
            .sm-expired-card { text-align: center; padding: 2rem; }
            .sm-expired-card h3 { color: #dc2626; margin-bottom: 1rem; }
            .sm-expired-card p { color: #6b7280; margin-bottom: 1.5rem; }
        </style>
    </head>

    <body>
        <div class="sm-reset-container">
            <c:choose>
                <c:when test="${valid}">
                    <div class="sm-reset-card">
                        <h2 class="sm-reset-title">Set New Password</h2>
                        <p class="sm-reset-subtitle">Enter your new password below</p>

                        <div id="alert-box" class="sm-alert"></div>

                        <form id="resetForm">
                            <input type="hidden" id="token" value="${token}" />

                            <div class="sm-form-group">
                                <label for="password">New Password</label>
                                <div class="sm-input-wrapper">
                                    <span class="sm-input-icon">&#128274;</span>
                                    <input type="password" id="password" placeholder="Min 3 characters" required />
                                </div>
                            </div>

                            <div class="sm-form-group">
                                <label for="confirmPassword">Confirm Password</label>
                                <div class="sm-input-wrapper">
                                    <span class="sm-input-icon">&#128273;</span>
                                    <input type="password" id="confirmPassword" placeholder="Repeat password" required />
                                </div>
                            </div>

                            <button type="submit" id="btnReset" class="sm-btn-reset">Reset Password</button>
                        </form>

                        <div class="sm-login-link">
                            <a href="${BASE_URL}/login">Back to Login</a>
                        </div>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="sm-reset-card sm-expired-card">
                        <h3>&#9888; ${errorMsg}</h3>
                        <p>The reset link is invalid or has expired.</p>
                        <a href="${BASE_URL}/forgot-password" style="display:inline-block;padding:10px 24px;background:linear-gradient(135deg,#667eea 0%,#764ba2 100%);color:#fff;border-radius:10px;text-decoration:none;font-weight:600;">Request New Link</a>
                        <div class="sm-login-link" style="margin-top:1rem;">
                            <a href="${BASE_URL}/login">Back to Login</a>
                        </div>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>

        <script>
            document.getElementById('resetForm').addEventListener('submit', function(e) {
                e.preventDefault();
                var btn = document.getElementById('btnReset');
                var alertBox = document.getElementById('alert-box');
                alertBox.style.display = 'none';

                var token = document.getElementById('token').value;
                var password = document.getElementById('password').value;
                var confirmPassword = document.getElementById('confirmPassword').value;

                if (password !== confirmPassword) {
                    alertBox.className = 'sm-alert sm-alert-danger';
                    alertBox.textContent = 'Passwords do not match';
                    alertBox.style.display = 'block';
                    return;
                }
                if (password.length < 3) {
                    alertBox.className = 'sm-alert sm-alert-danger';
                    alertBox.textContent = 'Password must be at least 3 characters';
                    alertBox.style.display = 'block';
                    return;
                }

                btn.disabled = true;
                btn.textContent = 'Resetting...';

                var xhr = new XMLHttpRequest();
                xhr.open('POST', '${BASE_URL}/reset-password', true);
                xhr.setRequestHeader('Content-Type', 'application/json');
                xhr.onreadystatechange = function() {
                    if (xhr.readyState === 4) {
                        btn.disabled = false;
                        btn.textContent = 'Reset Password';
                        try {
                            var resp = JSON.parse(xhr.responseText);
                            if (resp.code === 200) {
                                alertBox.className = 'sm-alert sm-alert-success';
                                alertBox.textContent = resp.body + ' Redirecting...';
                                alertBox.style.display = 'block';
                                setTimeout(function() { window.location.href = '${BASE_URL}/login'; }, 2000);
                            } else {
                                alertBox.className = 'sm-alert sm-alert-danger';
                                alertBox.textContent = resp.message || 'Failed to reset password.';
                                alertBox.style.display = 'block';
                            }
                        } catch(ex) {
                            alertBox.className = 'sm-alert sm-alert-danger';
                            alertBox.textContent = 'An error occurred. Please try again.';
                            alertBox.style.display = 'block';
                        }
                    }
                };
                xhr.onerror = function() {
                    btn.disabled = false;
                    btn.textContent = 'Reset Password';
                    alertBox.className = 'sm-alert sm-alert-danger';
                    alertBox.textContent = 'Network error. Please try again.';
                    alertBox.style.display = 'block';
                };
                xhr.send(JSON.stringify({token: token, password: password, confirmPassword: confirmPassword}));
            });
        </script>
    </body>
</html>
