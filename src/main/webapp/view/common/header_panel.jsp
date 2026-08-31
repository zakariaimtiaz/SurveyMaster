<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<nav class="navbar navbar-expand bg-white shadow-sm mb-1 px-3 py-1">
    <a class="navbar-brand p-0" href="${BASE_URL}/">
        <img style="max-height: 42px;" alt="Survey Master" src="${STATIC_RES}/images/logo.png">
    </a>
    <div class="ms-auto d-flex align-items-center gap-3">
        <sec:authorize access="isAuthenticated()">
            <sec:authorize access="hasRole('USER')">
                <a href="${BASE_URL}/" class="btn btn-sm btn-outline-primary <c:if test="${!HAS_COMPANY}">disabled</c:if>">Home</a>
                <a href="${BASE_URL}/questionnaire/list" class="btn btn-sm btn-outline-primary <c:if test="${!HAS_COMPANY}">disabled</c:if>">Questionnaires</a>
                <a href="${BASE_URL}/company" class="btn btn-sm btn-outline-primary">Agents</a>
            </sec:authorize>
            <sec:authorize access="hasRole('ADMIN')">
                <a href="${BASE_URL}/" class="btn btn-sm btn-outline-primary">Home</a>
                <a href="${BASE_URL}/company/list" class="btn btn-sm btn-outline-primary">Companies</a>
                <a href="${BASE_URL}/questionnaire/all" class="btn btn-sm btn-outline-primary">Questionnaires</a>
                <a href="${BASE_URL}/apk" class="btn btn-sm btn-outline-primary">APK</a>
            </sec:authorize>
            <span class="text-muted" style="font-size:.85rem;">
                <sec:authentication property="name" />
            </span>
            <div class="dropdown">
                <button class="btn btn-sm btn-outline-secondary dropdown-toggle" type="button" data-bs-toggle="dropdown" aria-expanded="false" style="padding:.25rem .5rem;">
                    &#8942;
                </button>
                <ul class="dropdown-menu dropdown-menu-end" style="min-width:160px;">
                    <li><a class="dropdown-item" href="#" id="btn-header-about">&#128100; About</a></li>
                    <li><hr class="dropdown-divider"></li>
                    <li>
                        <form method="POST" action="${BASE_URL}/logout" style="margin:0;">
                            <button type="submit" class="dropdown-item text-danger">&#10140; Sign Out</button>
                        </form>
                    </li>
                </ul>
            </div>
        </sec:authorize>
    </div>
</nav>
