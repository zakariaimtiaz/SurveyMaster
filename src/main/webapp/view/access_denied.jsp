<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<html lang="en">
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
        <meta charset="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <link rel="icon" type="image/x-icon" href="${STATIC_RES}/images/x-diamond.svg" />
        <title>Access Denied - ${APP_NAME}</title>
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
            .sm-access-card {
                background: #fff;
                border-radius: 16px;
                box-shadow: 0 20px 60px rgba(0,0,0,0.3);
                padding: 3rem 2rem;
                text-align: center;
                max-width: 420px;
                width: 100%;
            }
            .sm-access-icon {
                font-size: 4rem;
                margin-bottom: 1rem;
            }
            .sm-access-title {
                font-size: 1.4rem;
                font-weight: 700;
                color: #1a1a2e;
                margin-bottom: 0.5rem;
            }
            .sm-access-text {
                color: #6c757d;
                font-size: 0.95rem;
                margin-bottom: 1.5rem;
            }
            .sm-btn-back {
                display: inline-block;
                padding: 0.65rem 1.5rem;
                border: none;
                border-radius: 10px;
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                color: #fff;
                font-size: 0.95rem;
                font-weight: 600;
                text-decoration: none;
                transition: transform 0.15s, box-shadow 0.15s;
            }
            .sm-btn-back:hover {
                transform: translateY(-1px);
                box-shadow: 0 6px 20px rgba(102,126,234,0.4);
                color: #fff;
            }
            .sm-btn-logout {
                display: inline-block;
                padding: 0.65rem 1.5rem;
                border: 2px solid #dc3545;
                border-radius: 10px;
                background: transparent;
                color: #dc3545;
                font-size: 0.95rem;
                font-weight: 600;
                text-decoration: none;
                margin-left: 0.75rem;
                transition: background 0.15s, color 0.15s, transform 0.15s;
            }
            .sm-btn-logout:hover {
                background: #dc3545;
                color: #fff;
                transform: translateY(-1px);
            }
        </style>
    </head>

    <body>
        <div class="sm-access-card">
            <div class="sm-access-icon">&#128683;</div>
            <h2 class="sm-access-title">Access Denied</h2>
            <p class="sm-access-text">You do not have permission to access this page. Please contact your administrator.</p>
            <a href="${BASE_URL}/" class="sm-btn-back">Go to Home</a>
            <a href="${BASE_URL}/logout" class="sm-btn-logout">Logout</a>
        </div>
    </body>
</html>
