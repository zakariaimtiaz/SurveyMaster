<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<html lang="en">
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
        <meta charset="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <link rel="icon" type="image/x-icon" href="${STATIC_RES}/images/x-diamond.svg" />
        <title>Register - ${APP_NAME}</title>
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
            .sm-register-container {
                width: 100%;
                max-width: 460px;
            }
            .sm-register-card {
                background: #fff;
                border-radius: 16px;
                box-shadow: 0 20px 60px rgba(0,0,0,0.3);
                padding: 2.5rem 2rem 2rem;
                position: relative;
                overflow: hidden;
            }
            .sm-register-card::before {
                content: '';
                position: absolute;
                top: 0;
                left: 0;
                right: 0;
                height: 4px;
                background: linear-gradient(90deg, #667eea, #764ba2);
            }
            .sm-register-logo {
                text-align: center;
                margin-bottom: 1.5rem;
            }
            .sm-register-logo img {
                height: 56px;
                margin-bottom: 0.5rem;
            }
            .sm-register-title {
                text-align: center;
                font-size: 1.5rem;
                font-weight: 700;
                color: #1a1a2e;
                margin-bottom: 0.25rem;
            }
            .sm-register-subtitle {
                text-align: center;
                color: #6c757d;
                font-size: 0.9rem;
                margin-bottom: 1.75rem;
            }
            .sm-form-group {
                margin-bottom: 1.1rem;
            }
            .sm-form-group label {
                display: block;
                font-size: 0.85rem;
                font-weight: 600;
                color: #374151;
                margin-bottom: 0.35rem;
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
            .sm-form-group input[type="email"],
            .sm-form-group input[type="password"] {
                width: 100%;
                padding: 0.65rem 0.75rem 0.65rem 2.5rem;
                border: 1.5px solid #e5e7eb;
                border-radius: 10px;
                font-size: 0.93rem;
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
            .sm-form-row {
                display: flex;
                gap: 1rem;
            }
            .sm-form-row .sm-form-group {
                flex: 1;
            }
            .sm-btn-register {
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
            .sm-btn-register:hover {
                transform: translateY(-1px);
                box-shadow: 0 6px 20px rgba(102,126,234,0.4);
            }
            .sm-btn-register:active {
                transform: translateY(0);
            }
            .sm-btn-register:disabled {
                opacity: 0.6;
                cursor: not-allowed;
                transform: none;
                box-shadow: none;
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
            .sm-login-link {
                text-align: center;
                margin-top: 1.25rem;
                font-size: 0.9rem;
                color: #6b7280;
            }
            .sm-login-link a {
                color: #667eea;
                text-decoration: none;
                font-weight: 600;
            }
            .sm-login-link a:hover {
                text-decoration: underline;
            }
        </style>
    </head>

    <body>
        <div class="sm-register-container">
            <div class="sm-register-card">
                <div class="sm-register-logo">
                    <img alt="Survey Master" src="${STATIC_RES}/images/logo.png">
                </div>
                <h2 class="sm-register-title">Create Account</h2>
                <p class="sm-register-subtitle">Fill in the details to get started</p>

                <div id="alert-box" class="sm-alert"></div>

                <form id="registerForm">
                    <div class="sm-form-group">
                        <label for="username">Username</label>
                        <div class="sm-input-wrapper">
                            <span class="sm-input-icon">&#128100;</span>
                            <input type="text" id="username" name="username" placeholder="Choose a username" required />
                        </div>
                    </div>

                    <div class="sm-form-group">
                        <label for="email">Email</label>
                        <div class="sm-input-wrapper">
                            <span class="sm-input-icon">&#9993;</span>
                            <input type="email" id="email" name="email" placeholder="Enter your email" required />
                        </div>
                    </div>

                    <div class="sm-form-row">
                        <div class="sm-form-group">
                            <label for="password">Password</label>
                            <div class="sm-input-wrapper">
                                <span class="sm-input-icon">&#128274;</span>
                                <input type="password" id="password" name="password" placeholder="Min 6 characters" required />
                            </div>
                        </div>
                        <div class="sm-form-group">
                            <label for="confirmPassword">Confirm Password</label>
                            <div class="sm-input-wrapper">
                                <span class="sm-input-icon">&#128273;</span>
                                <input type="password" id="confirmPassword" name="confirmPassword" placeholder="Repeat password" required />
                            </div>
                        </div>
                    </div>

                    <button type="submit" id="btnRegister" class="sm-btn-register">Create Account</button>
                </form>

                <div class="sm-login-link">
                    Already have an account? <a href="${BASE_URL}/login">Sign in</a>
                </div>
            </div>
        </div>

        <script>
            document.getElementById('registerForm').addEventListener('submit', function(e) {
                e.preventDefault();
                var btn = document.getElementById('btnRegister');
                var alertBox = document.getElementById('alert-box');
                alertBox.style.display = 'none';

                var username = document.getElementById('username').value.trim();
                var email = document.getElementById('email').value.trim();
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
                    alertBox.textContent = 'Password must be at least 6 characters';
                    alertBox.style.display = 'block';
                    return;
                }

                btn.disabled = true;
                btn.textContent = 'Creating Account...';

                var xhr = new XMLHttpRequest();
                xhr.open('POST', '${BASE_URL}/register', true);
                xhr.setRequestHeader('Content-Type', 'application/json');
                xhr.onreadystatechange = function() {
                    if (xhr.readyState === 4) {
                        btn.disabled = false;
                        btn.textContent = 'Create Account';
                        try {
                            var resp = JSON.parse(xhr.responseText);
                            if (resp.code === 200) {
                                alertBox.className = 'sm-alert sm-alert-success';
                                alertBox.textContent = resp.body + ' Redirecting to login...';
                                alertBox.style.display = 'block';
                                setTimeout(function() {
                                    window.location.href = '${BASE_URL}/login';
                                }, 1500);
                            } else {
                                alertBox.className = 'sm-alert sm-alert-danger';
                                alertBox.textContent = resp.message || 'Registration failed';
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
                    btn.textContent = 'Create Account';
                    alertBox.className = 'sm-alert sm-alert-danger';
                    alertBox.textContent = 'Network error. Please try again.';
                    alertBox.style.display = 'block';
                };
                xhr.send(JSON.stringify({
                    username: username,
                    email: email,
                    password: password,
                    confirmPassword: confirmPassword
                }));
            });
        </script>
    </body>
</html>
