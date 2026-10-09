<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.pms.model.User" %>
<%@ page import="com.pms.util.HtmlUtil" %>
<%@ page import="java.util.List" %>

<%
    List<User> managers =
            (List<User>) request.getAttribute("managers");

    if (managers == null) {
        response.sendRedirect(
                request.getContextPath() + "/projects/create"
        );
        return;
    }

    User currentUser =
            (User) session.getAttribute("user");

    boolean isAdmin =
            currentUser != null &&
            "ADMIN".equals(currentUser.getRole());

    String role =
            currentUser != null
                    ? currentUser.getRole()
                    : "";

    String dashboardUrl =
            "/dashboard/team-member";

    String roleDisplay =
            "TEAM MEMBER";

    if ("PROJECT_MANAGER".equals(role)) {

        dashboardUrl =
                "/dashboard/project-manager";

        roleDisplay =
                "PROJECT MANAGER";

    } else if ("ADMIN".equals(role)) {

        dashboardUrl =
                "/dashboard/admin";

        roleDisplay =
                "ADMIN";
    }
%>

<!DOCTYPE html>
<html lang="en">

<head>

    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>Create New Project</title>

    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/dashboard.css">

    <style>

        /* ================================
           CREATE PROJECT
           ================================ */

        .create-project-page {
            max-width: 1080px;
            margin: 0 auto;
        }

        .create-intro {
            margin-bottom: 24px;
        }

        .create-intro .eyebrow {
            margin: 0 0 7px;
            color: #2f7f78;
            font-size: 0.76rem;
            font-weight: 800;
            letter-spacing: 0.11em;
            text-transform: uppercase;
        }

        .create-intro h2 {
            margin: 0 0 8px;
            font-size: 1.7rem;
        }

        .create-intro p {
            max-width: 680px;
            margin: 0;
            color: #746e65;
            line-height: 1.6;
        }

        .create-layout {
            display: grid;
            grid-template-columns: minmax(0, 1fr) 290px;
            gap: 22px;
            align-items: start;
        }

        .create-form-card,
        .info-card {
            background: #ffffff;
            border: 1px solid rgba(41, 39, 36, 0.08);
            border-radius: 18px;
            box-shadow: 0 8px 22px rgba(41, 39, 36, 0.07);
        }

        .create-form-card {
            padding: 27px;
        }

        .form-card-header {
            display: flex;
            align-items: flex-start;
            justify-content: space-between;
            gap: 15px;
            margin-bottom: 25px;
            padding-bottom: 18px;
            border-bottom: 1px solid #e8e2d6;
        }

        .form-card-header h3 {
            margin: 0 0 5px;
            font-size: 1.15rem;
        }

        .form-card-header p {
            margin: 0;
            color: #746e65;
            font-size: 0.82rem;
        }

        .form-card-icon {
            display: flex;
            align-items: center;
            justify-content: center;
            width: 42px;
            height: 42px;
            flex: 0 0 42px;
            border-radius: 12px;
            background: #e5f0ed;
            color: #2f7f78;
            font-size: 1.15rem;
        }

        .project-form-group {
            margin-bottom: 20px;
        }

        .project-form-group label {
            display: block;
            margin-bottom: 7px;
            color: #292724;
            font-size: 0.82rem;
            font-weight: 750;
        }

        .required-mark {
            color: #b45149;
        }

        .project-form-group input,
        .project-form-group textarea,
        .project-form-group select {
            width: 100%;
            box-sizing: border-box;
            padding: 11px 13px;
            border: 1px solid #d7d0c4;
            border-radius: 10px;
            outline: none;
            background: #ffffff;
            color: #292724;
            font-family: inherit;
            font-size: 0.88rem;
            transition:
                    border-color 0.18s ease,
                    box-shadow 0.18s ease;
        }

        .project-form-group textarea {
            min-height: 125px;
            resize: vertical;
            line-height: 1.55;
        }

        .project-form-group input:focus,
        .project-form-group textarea:focus,
        .project-form-group select:focus {
            border-color: #2f7f78;
            box-shadow: 0 0 0 3px rgba(47, 127, 120, 0.11);
        }

        .project-form-group input::placeholder,
        .project-form-group textarea::placeholder {
            color: #aaa39a;
        }

        .field-hint {
            margin: 6px 0 0;
            color: #8b8479;
            font-size: 0.73rem;
            line-height: 1.4;
        }

        .form-row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 15px;
        }

        .manager-box {
            padding: 16px;
            border: 1px solid #ded7cb;
            border-radius: 12px;
            background: #faf8f3;
        }

        .manager-box label {
            margin-bottom: 8px;
        }

        .status-preview {
            display: flex;
            align-items: center;
            gap: 8px;
            margin-top: 8px;
            color: #746e65;
            font-size: 0.73rem;
        }

        .status-preview-dot {
            width: 8px;
            height: 8px;
            flex: 0 0 8px;
            border-radius: 50%;
            background: #c39432;
        }

        .form-actions {
            display: flex;
            align-items: center;
            gap: 10px;
            margin-top: 27px;
            padding-top: 20px;
            border-top: 1px solid #e8e2d6;
        }

        .form-actions .btn {
            min-width: 135px;
            justify-content: center;
        }

        .info-column {
            display: flex;
            flex-direction: column;
            gap: 14px;
        }

        .info-card {
            padding: 21px;
        }

        .info-card.accent {
            background: linear-gradient(
                    135deg,
                    #e5f0ed,
                    #ffffff
            );
        }

        .info-icon {
            display: flex;
            align-items: center;
            justify-content: center;
            width: 42px;
            height: 42px;
            margin-bottom: 14px;
            border-radius: 12px;
            background: #2f7f78;
            color: #ffffff;
            font-size: 1.1rem;
        }

        .info-card h3 {
            margin: 0 0 7px;
            font-size: 0.98rem;
        }

        .info-card p {
            margin: 0;
            color: #746e65;
            font-size: 0.78rem;
            line-height: 1.6;
        }

        .project-tips {
            margin: 15px 0 0;
            padding: 0;
            list-style: none;
        }

        .project-tips li {
            position: relative;
            margin-bottom: 10px;
            padding-left: 16px;
            color: #746e65;
            font-size: 0.75rem;
            line-height: 1.5;
        }

        .project-tips li:last-child {
            margin-bottom: 0;
        }

        .project-tips li::before {
            content: "•";
            position: absolute;
            left: 1px;
            color: #2f7f78;
            font-size: 1rem;
        }

        .back-row {
            margin-top: 20px;
        }

        /* ================================
           DARK MODE
           ================================ */

        body[data-theme="dark"] .create-form-card,
        body[data-theme="dark"] .info-card {
            background: var(--card-bg, #302e2a);
            border-color: rgba(255, 255, 255, 0.08);
        }

        body[data-theme="dark"] .form-card-header {
            border-color: rgba(255, 255, 255, 0.09);
        }

        body[data-theme="dark"] .project-form-group label,
        body[data-theme="dark"] .form-card-header h3,
        body[data-theme="dark"] .info-card h3 {
            color: #f4f0e8;
        }

        body[data-theme="dark"] .project-form-group input,
        body[data-theme="dark"] .project-form-group textarea,
        body[data-theme="dark"] .project-form-group select {
            background: #282622;
            border-color: #4a463f;
            color: #f4f0e8;
        }

        body[data-theme="dark"] .manager-box {
            background: rgba(255, 255, 255, 0.04);
            border-color: rgba(255, 255, 255, 0.10);
        }

        body[data-theme="dark"] .form-card-header p,
        body[data-theme="dark"] .field-hint,
        body[data-theme="dark"] .info-card p,
        body[data-theme="dark"] .project-tips li,
        body[data-theme="dark"] .status-preview,
        body[data-theme="dark"] .create-intro p {
            color: #aaa39a;
        }

        body[data-theme="dark"] .form-actions {
            border-color: rgba(255, 255, 255, 0.09);
        }

        body[data-theme="dark"] .info-card.accent {
            background: #293a37;
        }

        /* ================================
           RESPONSIVE
           ================================ */

        @media (max-width: 900px) {

            .create-layout {
                grid-template-columns: 1fr;
            }

            .info-column {
                display: grid;
                grid-template-columns: repeat(2, 1fr);
            }

        }

        @media (max-width: 650px) {

            .create-intro h2 {
                font-size: 1.4rem;
            }

            .create-form-card {
                padding: 21px;
            }

            .form-row {
                grid-template-columns: 1fr;
            }

            .info-column {
                grid-template-columns: 1fr;
            }

        }

        @media (max-width: 450px) {

            .form-actions {
                flex-direction: column;
                align-items: stretch;
            }

            .form-actions .btn {
                width: 100%;
            }

        }

    </style>

    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/ui-polish.css">

</head>

<body>

<div class="app-layout">

    <!-- Mobile sidebar overlay -->
    <div class="sidebar-overlay"
         id="sidebarOverlay">
    </div>

    <!-- ================= SIDEBAR ================= -->

    <aside class="sidebar"
           id="sidebar">

        <div class="sidebar-brand">

            <div class="brand-mark">
                P
            </div>

            <div>
                <p class="brand-name">
                    Project Management
                </p>

                <p class="brand-subtitle">
                    Workspace
                </p>
            </div>

        </div>

        <p class="sidebar-label">
            Workspace
        </p>

        <nav class="sidebar-nav">

            <a href="${pageContext.request.contextPath}<%= dashboardUrl %>"
               class="sidebar-link">

                <span class="sidebar-icon">
                    &#9632;
                </span>

                Dashboard

            </a>

            <a href="${pageContext.request.contextPath}/projects"
               class="sidebar-link active">

                <span class="sidebar-icon">
                    &#128193;
                </span>

                Projects

            </a>

            <a href="${pageContext.request.contextPath}/tasks"
               class="sidebar-link">

                <span class="sidebar-icon">
                    &#9745;
                </span>

                Tasks

            </a>
            <a href="${pageContext.request.contextPath}/kanban" class="sidebar-link">
                <span class="sidebar-icon">&#9638;</span>
                Kanban board
            </a>

            <a href="${pageContext.request.contextPath}/deadlines" class="sidebar-link">
                <span class="sidebar-icon">&#9200;</span>
                Due-date alerts
            </a>


        </nav>

        <% if ("ADMIN".equals(role)) { %>

            <p class="sidebar-label"
               style="margin-top: 28px;">
                Administration
            </p>

            <nav class="sidebar-nav">

                <a href="${pageContext.request.contextPath}/users"
                   class="sidebar-link">

                    <span class="sidebar-icon">
                        &#128101;
                    </span>

                    Users

                </a>

                <a href="${pageContext.request.contextPath}/settings"
                   class="sidebar-link">

                    <span class="sidebar-icon">
                        &#9881;
                    </span>

                    Settings

                </a>

            </nav>

        <% } %>

        <div class="sidebar-bottom">

            <div class="sidebar-user">

                <p class="sidebar-user-name">

                    <%= currentUser != null
                            ? HtmlUtil.escape(
                                    currentUser.getName()
                              )
                            : "User" %>

                </p>

                <p class="sidebar-user-role">
                    <%= roleDisplay %>
                </p>

            </div>

            <form action="${pageContext.request.contextPath}/logout" method="post" class="sidebar-logout-form" style="margin:0;"><input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}"><button type="submit" class="sidebar-logout" style="border:0;background:transparent;width:100%;font:inherit;text-align:left;cursor:pointer;">

                &#10140; Logout

            </button></form>

        </div>

    </aside>

    <!-- ================= MAIN CONTENT ================= -->

    <main class="main-content">

        <!-- TOPBAR -->

        <header class="topbar">

            <div class="topbar-left">

                <button type="button"
                        class="sidebar-toggle"
                        id="sidebarToggle"
                        aria-label="Toggle navigation"
                        aria-expanded="false">

                    &#9776;

                </button>

                <div>

                    <h1>
                        Create New Project
                    </h1>

                    <p>
                        Add a new project to your workspace.
                    </p>

                </div>

            </div>

            <div class="topbar-actions">

                <button type="button"
                        class="theme-toggle"
                        id="themeToggle"
                        aria-label="Switch theme"
                        title="Switch theme">

                    &#9790;

                </button>

            </div>

        </header>

        <!-- PAGE CONTENT -->

        <div class="page-content">

            <div class="create-project-page">

                <!-- INTRO -->

                <div class="create-intro">

                    <p class="eyebrow">
                        Project Setup
                    </p>

                    <h2>
                        Start a New Project
                    </h2>

                    <p>
                        Add the basic project information below.
                        You can update the project later as the work
                        progresses.
                    </p>

                </div>

                <!-- FORM + INFORMATION -->

                <div class="create-layout">

                    <!-- FORM -->

                    <div class="create-form-card">

                        <div class="form-card-header">

                            <div>
                                <h3>
                                    Project Details
                                </h3>

                                <p>
                                    Fill in the information needed
                                    to create your project.
                                </p>
                            </div>

                            <div class="form-card-icon">
                                &#128193;
                            </div>

                        </div>

                        <form action="${pageContext.request.contextPath}/projects/create"
                              method="post">

                            <!-- CSRF -->

                            <input type="hidden"
                                   name="csrfToken"
                                   value="${sessionScope.csrfToken}">

                            <!-- TITLE -->

                            <div class="project-form-group">

                                <label for="title">
                                    Project Title
                                    <span class="required-mark">*</span>
                                </label>

                                <input type="text"
                                       id="title"
                                       name="title"
                                       maxlength="150"
                                       placeholder="Enter a clear project name"
                                       required>

                                <p class="field-hint">
                                    Maximum 150 characters.
                                </p>

                            </div>

                            <!-- DESCRIPTION -->

                            <div class="project-form-group">

                                <label for="description">
                                    Description
                                </label>

                                <textarea id="description"
                                          name="description"
                                          maxlength="2000"
                                          placeholder="Briefly describe what this project is about..."></textarea>

                                <p class="field-hint">
                                    Give your team a quick understanding
                                    of the project's purpose.
                                </p>

                            </div>

                            <!-- DATES -->

                            <div class="form-row">

                                <div class="project-form-group">

                                    <label for="startDate">
                                        Start Date
                                    </label>

                                    <input type="date"
                                           id="startDate"
                                           name="startDate">

                                </div>

                                <div class="project-form-group">

                                    <label for="endDate">
                                        End Date
                                    </label>

                                    <input type="date"
                                           id="endDate"
                                           name="endDate">

                                </div>

                            </div>

                            <!-- ADMIN MANAGER -->

                            <% if (isAdmin) { %>

                                <div class="project-form-group manager-box">

                                    <label for="managerId">
                                        Project Manager
                                        <span class="required-mark">*</span>
                                    </label>

                                    <select id="managerId"
                                            name="managerId"
                                            required>

                                        <option value="">
                                            Select Project Manager
                                        </option>

                                        <% for (User manager : managers) { %>

                                            <option value="<%= manager.getUserId() %>">
                                                <%= HtmlUtil.escape(
                                                        manager.getName()
                                                ) %>
                                            </option>

                                        <% } %>

                                    </select>

                                    <p class="field-hint">
                                        Choose the user responsible
                                        for managing this project.
                                    </p>

                                </div>

                            <% } %>

                            <!-- STATUS -->

                            <div class="project-form-group">

                                <label for="status">
                                    Status
                                    <span class="required-mark">*</span>
                                </label>

                                <select id="status"
                                        name="status"
                                        required>

                                    <option value="PLANNED">
                                        Planned
                                    </option>

                                    <option value="ACTIVE">
                                        Active
                                    </option>

                                    <option value="COMPLETED">
                                        Completed
                                    </option>

                                </select>

                                <div class="status-preview">

                                    <span class="status-preview-dot"
                                          id="statusDot">
                                    </span>

                                    <span id="statusHint">
                                        Planned projects have not
                                        started yet.
                                    </span>

                                </div>

                            </div>

                            <!-- ACTIONS -->

                            <div class="form-actions">

                                <button type="submit"
                                        class="btn btn-primary">

                                    Create Project

                                </button>

                                <a href="${pageContext.request.contextPath}/projects"
                                   class="btn btn-secondary">

                                    Cancel

                                </a>

                            </div>

                        </form>

                    </div>

                    <!-- INFORMATION -->

                    <div class="info-column">

                        <div class="info-card accent">

                            <div class="info-icon">
                                &#128193;
                            </div>

                            <h3>
                                Build the foundation
                            </h3>

                            <p>
                                A good project starts with a clear
                                name, useful description and realistic
                                dates.
                            </p>

                            <ul class="project-tips">

                                <li>
                                    Use a short and recognizable
                                    project title.
                                </li>

                                <li>
                                    Add enough description for the
                                    team to understand the goal.
                                </li>

                                <li>
                                    Set dates that reflect the
                                    expected project timeline.
                                </li>

                            </ul>

                        </div>

                        <div class="info-card">

                            <h3>
                                Project status
                            </h3>

                            <p>
                                Start with Planned if work has not
                                begun. You can change the status later
                                as the project moves forward.
                            </p>

                        </div>

                        <% if (isAdmin) { %>

                            <div class="info-card">

                                <h3>
                                    Project manager
                                </h3>

                                <p>
                                    As an administrator, you can assign
                                    this project to one of the available
                                    project managers.
                                </p>

                            </div>

                        <% } %>

                    </div>

                </div>

                <!-- BACK -->

                <div class="back-row">

                    <a class="back-link"
                       href="${pageContext.request.contextPath}/projects">

                        ← Back to Projects

                    </a>

                </div>

            </div>

        </div>

    </main>

</div>

<!-- ================= THEME + SIDEBAR + STATUS SCRIPT ================= -->

<script>

    (function () {

        "use strict";

        /* ================================
           THEME
           ================================ */

        const body =
                document.body;

        const themeToggle =
                document.getElementById(
                        "themeToggle"
                );

        function applyTheme(theme) {

            body.setAttribute(
                    "data-theme",
                    theme
            );

            if (themeToggle) {

                themeToggle.innerHTML =
                        theme === "dark"
                                ? "&#9728;"
                                : "&#9790;";

                themeToggle.setAttribute(
                        "aria-label",
                        theme === "dark"
                                ? "Switch to light mode"
                                : "Switch to dark mode"
                );
            }
        }

        let savedTheme = "light";

        try {

            const storedTheme =
                    localStorage.getItem(
                            "pms-theme"
                    );

            if (
                    storedTheme === "dark" ||
                    storedTheme === "light"
            ) {
                savedTheme = storedTheme;
            }

        } catch (error) {
            // Keep light mode.
        }

        applyTheme(savedTheme);

        if (themeToggle) {

            themeToggle.addEventListener(
                    "click",
                    function () {

                        const currentTheme =
                                body.getAttribute(
                                        "data-theme"
                                ) || "light";

                        const nextTheme =
                                currentTheme === "dark"
                                        ? "light"
                                        : "dark";

                        applyTheme(nextTheme);

                        try {

                            localStorage.setItem(
                                    "pms-theme",
                                    nextTheme
                            );

                        } catch (error) {
                            // Theme still works.
                        }

                    }
            );
        }

        /* ================================
           SIDEBAR
           ================================ */

        const sidebar =
                document.getElementById(
                        "sidebar"
                );

        const sidebarToggle =
                document.getElementById(
                        "sidebarToggle"
                );

        const sidebarOverlay =
                document.getElementById(
                        "sidebarOverlay"
                );

        function openSidebar() {

            sidebar.classList.add("open");

            sidebarOverlay.classList.add(
                    "visible"
            );

            sidebarToggle.setAttribute(
                    "aria-expanded",
                    "true"
            );
        }

        function closeSidebar() {

            sidebar.classList.remove("open");

            sidebarOverlay.classList.remove(
                    "visible"
            );

            sidebarToggle.setAttribute(
                    "aria-expanded",
                    "false"
            );
        }

        if (sidebarToggle) {

            sidebarToggle.addEventListener(
                    "click",
                    function () {

                        if (
                                sidebar.classList.contains(
                                        "open"
                                )
                        ) {
                            closeSidebar();
                        } else {
                            openSidebar();
                        }

                    }
            );
        }

        if (sidebarOverlay) {

            sidebarOverlay.addEventListener(
                    "click",
                    closeSidebar
            );

        }

        document.addEventListener(
                "keydown",
                function (event) {

                    if (event.key === "Escape") {
                        closeSidebar();
                    }

                }
        );

        /* ================================
           STATUS HELPER
           ================================ */

        const statusSelect =
                document.getElementById(
                        "status"
                );

        const statusHint =
                document.getElementById(
                        "statusHint"
                );

        const statusDot =
                document.getElementById(
                        "statusDot"
                );

        function updateStatusHint() {

            if (
                    !statusSelect ||
                    !statusHint ||
                    !statusDot
            ) {
                return;
            }

            const status =
                    statusSelect.value;

            if (status === "PLANNED") {

                statusHint.textContent =
                        "Planned projects have not started yet.";

                statusDot.style.background =
                        "#c39432";

            } else if (status === "ACTIVE") {

                statusHint.textContent =
                        "Active projects are currently being worked on.";

                statusDot.style.background =
                        "#2f7f78";

            } else if (status === "COMPLETED") {

                statusHint.textContent =
                        "Completed projects have finished their work.";

                statusDot.style.background =
                        "#5d8a52";

            }

        }

        if (statusSelect) {

            statusSelect.addEventListener(
                    "change",
                    updateStatusHint
            );

            updateStatusHint();

        }

    })();

</script>

</body>
</html>