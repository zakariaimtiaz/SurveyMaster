<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<html lang="en">
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
        <meta charset="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <link rel="icon" type="image/x-icon" href="${STATIC_RES}/images/x-diamond.svg" />
        <title>Login - ${APP_NAME}</title>
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
            .sm-login-container {
                width: 100%;
                max-width: 420px;
            }
            .sm-login-card {
                background: #fff;
                border-radius: 16px;
                box-shadow: 0 20px 60px rgba(0,0,0,0.3);
                padding: 2.5rem 2rem 2rem;
                position: relative;
                overflow: hidden;
            }
            .sm-login-card::before {
                content: '';
                position: absolute;
                top: 0;
                left: 0;
                right: 0;
                height: 4px;
                background: linear-gradient(90deg, #667eea, #764ba2);
            }
            .sm-login-logo {
                text-align: center;
                margin-bottom: 1.5rem;
            }
            .sm-login-logo img {
                height: 56px;
                margin-bottom: 0.5rem;
            }
            .sm-login-title {
                text-align: center;
                font-size: 1.5rem;
                font-weight: 700;
                color: #1a1a2e;
                margin-bottom: 0.25rem;
            }
            .sm-login-subtitle {
                text-align: center;
                color: #6c757d;
                font-size: 0.9rem;
                margin-bottom: 1.75rem;
            }
            .sm-form-group {
                margin-bottom: 1.25rem;
            }
            .sm-form-group label {
                display: block;
                font-size: 0.85rem;
                font-weight: 600;
                color: #374151;
                margin-bottom: 0.4rem;
            }
            .sm-form-group .sm-input-wrapper {
                position: relative;
            }
            .sm-form-group .sm-input-icon {
                position: absolute;
                left: 14px;
                top: 50%;
                transform: translateY(-50%);
                color: #9ca3af;
                font-size: 1rem;
                pointer-events: none;
            }
            .sm-form-group input[type="text"],
            .sm-form-group input[type="password"] {
                width: 100%;
                padding: 0.7rem 0.75rem 0.7rem 2.5rem;
                border: 1.5px solid #e5e7eb;
                border-radius: 10px;
                font-size: 0.95rem;
                color: #1f2937;
                background: #f9fafb;
                transition: border-color 0.2s, box-shadow 0.2s, background 0.2s;
                outline: none;
            }
            .sm-form-group input:focus {
                border-color: #667eea;
                box-shadow: 0 0 0 3px rgba(102,126,234,0.15);
                background: #fff;
            }
            .sm-btn-login {
                width: 100%;
                padding: 0.75rem;
                border: none;
                border-radius: 10px;
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                color: #fff;
                font-size: 1rem;
                font-weight: 600;
                cursor: pointer;
                transition: transform 0.15s, box-shadow 0.15s;
                margin-top: 0.5rem;
            }
            .sm-btn-login:hover {
                transform: translateY(-1px);
                box-shadow: 0 6px 20px rgba(102,126,234,0.4);
            }
            .sm-btn-login:active {
                transform: translateY(0);
            }
            .sm-alert {
                padding: 0.65rem 1rem;
                border-radius: 8px;
                font-size: 0.88rem;
                margin-bottom: 1rem;
                display: none;
            }
            .sm-alert-danger {
                background: #fef2f2;
                color: #dc2626;
                border: 1px solid #fecaca;
            }
            .sm-alert-success {
                background: #f0fdf4;
                color: #16a34a;
                border: 1px solid #bbf7d0;
            }
            .sm-register-link {
                text-align: center;
                margin-top: 1.25rem;
                font-size: 0.9rem;
                color: #6b7280;
            }
            .sm-register-link a {
                color: #667eea;
                text-decoration: none;
                font-weight: 600;
            }
            .sm-register-link a:hover {
                text-decoration: underline;
            }
        </style>
    </head>

    <body>
        <div class="sm-login-container">
            <div class="sm-login-card">
                <div class="sm-login-logo">
                    <img alt="Survey Master" src="${STATIC_RES}/images/logo.png">
                </div>
                <h2 class="sm-login-title">Welcome Back</h2>
                <p class="sm-login-subtitle">Sign in to your account</p>

                <c:if test="${not empty errorMessage}">
                    <div class="sm-alert sm-alert-danger" style="display:block;">
                        <c:out value="${errorMessage}" />
                    </div>
                </c:if>
                <c:if test="${not empty successMessage}">
                    <div class="sm-alert sm-alert-success" style="display:block;">
                        <c:out value="${successMessage}" />
                    </div>
                </c:if>

                <form method="POST" action="${BASE_URL}/login">
                    <div class="sm-form-group">
                        <label for="username">Username</label>
                        <div class="sm-input-wrapper">
                            <span class="sm-input-icon">&#128100;</span>
                            <input type="text" id="username" name="username" placeholder="Enter your username" required autofocus />
                        </div>
                    </div>

                    <div class="sm-form-group">
                        <label for="password">Password</label>
                        <div class="sm-input-wrapper">
                            <span class="sm-input-icon">&#128274;</span>
                            <input type="password" id="password" name="password" placeholder="Enter your password" required />
                        </div>
                    </div>

                    <button type="submit" class="sm-btn-login">Sign In</button>
                </form>

                <div style="text-align:center;margin-top:0.75rem;">
                    <a href="#" id="forgotPasswordLink" style="color:#667eea;font-size:0.85rem;text-decoration:none;font-weight:600;">Forgot Password?</a>
                </div>

                <div class="sm-register-link">
                    Don't have an account? <a href="${BASE_URL}/register">Create one</a>
                </div>
                <div style="text-align:center;margin-top:0.75rem;">
                    <a href="${BASE_URL}/user-guide" target="_blank" style="color:#6b7280;font-size:0.82rem;text-decoration:none;font-weight:500;">&#128196; User Guide</a>
                </div>
            </div>
        </div>
        <!-- Forgot Password Modal -->
        <div id="forgotModal" style="display:none;position:fixed;top:0;left:0;width:100%;height:100%;background:rgba(0,0,0,0.5);z-index:1000;align-items:center;justify-content:center;">
            <div style="background:#fff;border-radius:16px;padding:2rem;width:100%;max-width:400px;margin:1rem;box-shadow:0 20px 60px rgba(0,0,0,0.3);position:relative;">
                <button id="closeForgotModal" style="position:absolute;top:12px;right:16px;background:none;border:none;font-size:1.5rem;color:#9ca3af;cursor:pointer;line-height:1;">&times;</button>
                <h3 style="font-size:1.25rem;font-weight:700;color:#1a1a2e;margin-bottom:0.5rem;">Forgot Password?</h3>
                <p style="color:#6b7280;font-size:0.88rem;margin-bottom:1.25rem;">Enter your username and we'll send you a reset link.</p>
                <div id="forgotAlert" style="padding:0.65rem 1rem;border-radius:8px;font-size:0.88rem;margin-bottom:1rem;display:none;"></div>
                <form id="forgotForm">
                    <div style="margin-bottom:1.25rem;">
                        <label style="display:block;font-size:0.85rem;font-weight:600;color:#374151;margin-bottom:0.4rem;">Username</label>
                        <input type="text" id="forgotUsername" placeholder="Enter your username" required
                            style="width:100%;padding:0.7rem 0.75rem;border:1.5px solid #e5e7eb;border-radius:10px;font-size:0.95rem;color:#1f2937;background:#f9fafb;outline:none;box-sizing:border-box;" />
                    </div>
                    <button type="submit" id="btnForgotSubmit"
                        style="width:100%;padding:0.75rem;border:none;border-radius:10px;background:linear-gradient(135deg,#667eea 0%,#764ba2 100%);color:#fff;font-size:1rem;font-weight:600;cursor:pointer;">Send Reset Link</button>
                </form>
            </div>
        </div>

        <script>
            (function() {
                var modal = document.getElementById('forgotModal');
                var link = document.getElementById('forgotPasswordLink');
                var closeBtn = document.getElementById('closeForgotModal');
                var form = document.getElementById('forgotForm');
                var alertBox = document.getElementById('forgotAlert');
                var btnSubmit = document.getElementById('btnForgotSubmit');

                link.addEventListener('click', function(e) {
                    e.preventDefault();
                    alertBox.style.display = 'none';
                    document.getElementById('forgotUsername').value = '';
                    modal.style.display = 'flex';
                });

                closeBtn.addEventListener('click', function() {
                    modal.style.display = 'none';
                });

                modal.addEventListener('click', function(e) {
                    if (e.target === modal) modal.style.display = 'none';
                });

                form.addEventListener('submit', function(e) {
                    e.preventDefault();
                    var username = document.getElementById('forgotUsername').value.trim();
                    if (!username) return;

                    btnSubmit.disabled = true;
                    btnSubmit.textContent = 'Sending...';
                    alertBox.style.display = 'none';

                    var xhr = new XMLHttpRequest();
                    xhr.open('POST', '${BASE_URL}/forgot-password', true);
                    xhr.setRequestHeader('Content-Type', 'application/json');
                    xhr.onreadystatechange = function() {
                        if (xhr.readyState === 4) {
                            btnSubmit.disabled = false;
                            btnSubmit.textContent = 'Send Reset Link';
                            try {
                                var resp = JSON.parse(xhr.responseText);
                                if (resp.code === 200) {
                                    alertBox.style.background = '#f0fdf4';
                                    alertBox.style.color = '#16a34a';
                                    alertBox.style.border = '1px solid #bbf7d0';
                                    alertBox.textContent = resp.body || 'Reset link sent.';
                                    alertBox.style.display = 'block';
                                } else {
                                    alertBox.style.background = '#fef2f2';
                                    alertBox.style.color = '#dc2626';
                                    alertBox.style.border = '1px solid #fecaca';
                                    alertBox.textContent = resp.message || 'Failed to send reset link.';
                                    alertBox.style.display = 'block';
                                }
                            } catch(ex) {
                                alertBox.style.background = '#fef2f2';
                                alertBox.style.color = '#dc2626';
                                alertBox.style.border = '1px solid #fecaca';
                                alertBox.textContent = 'An error occurred. Please try again.';
                                alertBox.style.display = 'block';
                            }
                        }
                    };
                    xhr.onerror = function() {
                        btnSubmit.disabled = false;
                        btnSubmit.textContent = 'Send Reset Link';
                        alertBox.style.background = '#fef2f2';
                        alertBox.style.color = '#dc2626';
                        alertBox.style.border = '1px solid #fecaca';
                        alertBox.textContent = 'Network error. Please try again.';
                        alertBox.style.display = 'block';
                    };
                    xhr.send(JSON.stringify({username: username}));
                });
            })();
        </script>
    </body>
</html>
