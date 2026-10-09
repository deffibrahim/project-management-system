<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.pms.model.Project" %>
<%@ page import="com.pms.model.User" %>
<%@ page import="com.pms.util.HtmlUtil" %>
<%@ page import="java.util.List" %>

<%
    Project project = (Project) request.getAttribute("project");

    if (project == null) {
        response.sendRedirect(request.getContextPath() + "/projects");
        return;
    }

    List<User> managers =
            (List<User>) request.getAttribute("managers");

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

    <title>Edit Project</title>

    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/dashboard.css">


    <style>

        /* =====================================================
           EDIT PROJECT PAGE
           ===================================================== */

        .edit-project-page {
            max-width: 1100px;
            margin: 0 auto;
        }


        /* =====================================================
           PAGE INTRO
           ===================================================== */

        .edit-project-heading {
            margin-bottom: 24px;
        }

        .edit-project-heading h1 {
            margin: 0 0 6px;

            font-size: 30px;
        }

        .edit-project-heading p {
            margin: 0;

            max-width: 650px;

            color: var(--text-muted);

            font-size: 14px;

            line-height: 1.5;
        }


        /* =====================================================
           PROJECT IDENTIFIER
           ===================================================== */

        .project-id-label {
            display: inline-flex;

            align-items: center;

            gap: 6px;

            margin-top: 12px;

            padding: 5px 10px;

            border-radius: 20px;

            background: var(--surface-soft);

            border: 1px solid var(--border);

            color: var(--text-muted);

            font-size: 11px;

            font-weight: 600;
        }

        .project-id-label strong {
            color: var(--text);
        }


        /* =====================================================
           MAIN LAYOUT
           ===================================================== */

        .edit-project-layout {
            display: grid;

            grid-template-columns:
                minmax(0, 1fr)
                300px;

            gap: 20px;

            align-items: start;
        }


        /* =====================================================
           FORM CARD
           ===================================================== */

        .project-form-card {
            padding: 26px;

            background: var(--surface);

            border: 1px solid var(--border);

            border-radius: var(--radius);

            box-shadow: var(--shadow);
        }


        .form-card-heading {
            margin-bottom: 23px;

            padding-bottom: 17px;

            border-bottom: 1px solid var(--border-light);
        }

        .form-card-heading h2 {
            margin: 0 0 5px;

            font-size: 19px;
        }

        .form-card-heading p {
            margin: 0;

            color: var(--text-muted);

            font-size: 12px;
        }


        /* =====================================================
           FORM
           ===================================================== */

        .project-form-group {
            margin-bottom: 19px;
        }

        .project-form-group:last-of-type {
            margin-bottom: 0;
        }

        .project-form-group label {
            display: block;

            margin-bottom: 7px;

            color: var(--text);

            font-size: 12px;

            font-weight: bold;
        }

        .project-form-group input,
        .project-form-group textarea,
        .project-form-group select {

            width: 100%;

            box-sizing: border-box;

            padding: 11px 12px;

            border: 1px solid var(--border);

            border-radius: 8px;

            background: var(--surface);

            color: var(--text);

            font-family: inherit;

            font-size: 13px;

            outline: none;

            transition:
                border-color 0.2s ease,
                box-shadow 0.2s ease,
                background-color 0.2s ease;
        }

        .project-form-group textarea {
            min-height: 125px;

            resize: vertical;

            line-height: 1.5;
        }

        .project-form-group input:focus,
        .project-form-group textarea:focus,
        .project-form-group select:focus {

            border-color: var(--primary);

            box-shadow:
                0 0 0 3px
                rgba(47, 127, 120, 0.11);

        }

        .project-form-group input::placeholder,
        .project-form-group textarea::placeholder {

            color: var(--text-light);

        }

        .field-hint {
            margin: 6px 0 0;

            color: var(--text-light);

            font-size: 11px;

            line-height: 1.4;
        }


        /* =====================================================
           DATE ROW
           ===================================================== */

        .form-row {
            display: grid;

            grid-template-columns:
                1fr 1fr;

            gap: 14px;
        }


        /* =====================================================
           MANAGER BOX
           ===================================================== */

        .manager-box {
            padding: 15px;

            border: 1px solid var(--border);

            border-radius: 9px;

            background: var(--surface-soft);
        }


        /* =====================================================
           STATUS
           ===================================================== */

        .status-note {
            display: flex;

            align-items: center;

            gap: 7px;

            margin-top: 8px;

            color: var(--text-muted);

            font-size: 11px;
        }

        .status-dot {
            width: 7px;
            height: 7px;

            flex-shrink: 0;

            border-radius: 50%;

            background: var(--mustard);
        }


        /* =====================================================
           ACTIONS
           ===================================================== */

        .project-form-actions {

            display: flex;

            align-items: center;

            gap: 10px;

            margin-top: 25px;

            padding-top: 20px;

            border-top: 1px solid var(--border-light);

        }

        .project-form-actions .btn {
            min-width: 140px;

            justify-content: center;
        }


        /* =====================================================
           SIDE CARDS
           ===================================================== */

        .project-info-column {
            display: flex;

            flex-direction: column;

            gap: 14px;
        }

        .project-info-card {

            padding: 20px;

            background: var(--surface);

            border: 1px solid var(--border);

            border-radius: var(--radius);

            box-shadow: var(--shadow);

        }

        .project-info-card.accent {

            background:
                linear-gradient(
                    135deg,
                    var(--primary-soft),
                    var(--surface)
                );

        }

        .project-info-icon {

            width: 40px;
            height: 40px;

            display: flex;

            align-items: center;
            justify-content: center;

            margin-bottom: 13px;

            border-radius: 11px;

            background: var(--primary);

            color: #ffffff;

            font-size: 18px;

        }

        .project-info-card h3 {

            margin: 0 0 7px;

            font-size: 15px;

        }

        .project-info-card p {

            margin: 0;

            color: var(--text-muted);

            font-size: 12px;

            line-height: 1.55;

        }


        /* =====================================================
           PROJECT SUMMARY
           ===================================================== */

        .project-summary {

            display: grid;

            grid-template-columns:
                1fr 1fr;

            gap: 8px;

            margin-top: 15px;

        }

        .summary-item {

            padding: 10px;

            border-radius: 8px;

            background: var(--surface-soft);

            border: 1px solid var(--border-light);

        }

        .summary-label {

            display: block;

            margin-bottom: 4px;

            color: var(--text-light);

            font-size: 10px;

            text-transform: uppercase;

            letter-spacing: 0.04em;

        }

        .summary-value {

            color: var(--text);

            font-size: 12px;

            font-weight: 600;

            word-break: break-word;

        }


        /* =====================================================
           TIPS
           ===================================================== */

        .project-tips {

            margin: 15px 0 0;

            padding: 0;

            list-style: none;

        }

        .project-tips li {

            position: relative;

            padding-left: 17px;

            margin-bottom: 10px;

            color: var(--text-muted);

            font-size: 11px;

            line-height: 1.45;

        }

        .project-tips li:last-child {
            margin-bottom: 0;
        }

        .project-tips li::before {

            content: "•";

            position: absolute;

            left: 2px;
            top: 0;

            color: var(--primary);

            font-size: 15px;

            line-height: 1;

        }


        /* =====================================================
           RESPONSIVE
           ===================================================== */

        @media (max-width: 900px) {

            .edit-project-layout {
                grid-template-columns: 1fr;
            }

            .project-info-column {

                display: grid;

                grid-template-columns:
                    1fr 1fr;

            }

        }


        @media (max-width: 650px) {

            .edit-project-heading h1 {
                font-size: 26px;
            }

            .project-form-card {
                padding: 20px;
            }

            .form-row {
                grid-template-columns: 1fr;
            }

            .project-info-column {
                grid-template-columns: 1fr;
            }

        }


        @media (max-width: 450px) {

            .project-form-actions {

                flex-direction: column;

                align-items: stretch;

            }

            .project-form-actions .btn {
                width: 100%;
            }

            .project-summary {
                grid-template-columns: 1fr;
            }

        }

    </style>

    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/ui-polish.css">

</head>


<body>


<div class="app-layout">


    <!-- =================================================
         MOBILE SIDEBAR OVERLAY
         ================================================= -->

    <div class="sidebar-overlay"
         id="sidebarOverlay">
    </div>


    <!-- =================================================
         SIDEBAR
         ================================================= -->

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


    <!-- =================================================
         MAIN CONTENT
         ================================================= -->

    <main class="main-content">


        <!-- =================================================
             TOPBAR
             ================================================= -->

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
                        Edit Project
                    </h1>

                    <p>
                        Update project details and assignments.
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


        <!-- =================================================
             PAGE CONTENT
             ================================================= -->

        <div class="page-content">


            <div class="edit-project-page">


                <!-- =================================================
                     PAGE INTRO
                     ================================================= -->

                <div class="edit-project-heading">

                    <h1>
                        Update Project
                    </h1>

                    <p>
                        Make changes to the project information below.
                        Your existing project details have been loaded
                        for you.
                    </p>


                    <div class="project-id-label">

                        Project ID

                        <strong>
                            #<%= project.getProjectId() %>
                        </strong>

                    </div>

                </div>


                <!-- =================================================
                     FORM + INFO
                     ================================================= -->

                <div class="edit-project-layout">


                    <!-- =================================================
                         FORM
                         ================================================= -->

                    <div class="project-form-card">


                        <div class="form-card-heading">

                            <h2>
                                Project Details
                            </h2>

                            <p>
                                Update the fields you want to change.
                            </p>

                        </div>


                        <form action="${pageContext.request.contextPath}/projects/update"
                              method="post">


                            <!-- CSRF -->

                            <input type="hidden"
                                   name="csrfToken"
                                   value="${sessionScope.csrfToken}">


                            <!-- PROJECT ID -->

                            <input type="hidden"
                                   name="projectId"
                                   value="<%= project.getProjectId() %>">


                            <!-- TITLE -->

                            <div class="project-form-group">

                                <label for="title">
                                    Project Title
                                </label>

                                <input type="text"
                                       id="title"
                                       name="title"
                                       maxlength="150"
                                       value="<%= HtmlUtil.escape(project.getTitle()) %>"
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
                                          maxlength="2000"><%= HtmlUtil.escape(project.getDescription()) %></textarea>

                                <p class="field-hint">
                                    Keep the description useful for
                                    everyone working on the project.
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
                                           name="startDate"
                                           value="<%= project.getStartDate() != null
                                                   ? project.getStartDate().toString()
                                                   : "" %>">

                                </div>


                                <div class="project-form-group">

                                    <label for="endDate">
                                        End Date
                                    </label>

                                    <input type="date"
                                           id="endDate"
                                           name="endDate"
                                           value="<%= project.getEndDate() != null
                                                   ? project.getEndDate().toString()
                                                   : "" %>">

                                </div>


                            </div>


                            <!-- MANAGER -->

                            <% if (isAdmin) { %>


                                <div class="project-form-group manager-box">

                                    <label for="managerId">
                                        Project Manager
                                    </label>


                                    <select id="managerId"
                                            name="managerId">


                                        <option value="">
                                            -- Keep current / none --
                                        </option>


                                        <% if (managers != null) {

                                            for (User manager : managers) {

                                                boolean selected =
                                                        manager.getUserId()
                                                                == project.getManagerId();

                                        %>


                                            <option value="<%= manager.getUserId() %>"
                                                    <%= selected
                                                            ? "selected"
                                                            : "" %>>

                                                <%= HtmlUtil.escape(
                                                        manager.getName()
                                                ) %>

                                            </option>


                                        <%
                                            }

                                        }
                                        %>


                                    </select>


                                    <p class="field-hint">
                                        Change the person responsible
                                        for managing this project, or
                                        keep the current assignment.
                                    </p>

                                </div>


                            <% } %>


                            <!-- STATUS -->

                            <div class="project-form-group">

                                <label for="status">
                                    Status
                                </label>


                                <select id="status"
                                        name="status"
                                        required>


                                    <option value="PLANNED"
                                            <%= "PLANNED".equals(
                                                    project.getStatus()
                                            )
                                                    ? "selected"
                                                    : "" %>>

                                        Planned

                                    </option>


                                    <option value="ACTIVE"
                                            <%= "ACTIVE".equals(
                                                    project.getStatus()
                                            )
                                                    ? "selected"
                                                    : "" %>>

                                        Active

                                    </option>


                                    <option value="COMPLETED"
                                            <%= "COMPLETED".equals(
                                                    project.getStatus()
                                            )
                                                    ? "selected"
                                                    : "" %>>

                                        Completed

                                    </option>


                                </select>


                                <div class="status-note">

                                    <span class="status-dot"
                                          id="statusDot">
                                    </span>

                                    <span id="statusHint">
                                    </span>

                                </div>

                            </div>


                            <!-- ACTIONS -->

                            <div class="project-form-actions">


                                <button type="submit"
                                        class="btn btn-primary">

                                    Update Project

                                </button>


                                <a href="${pageContext.request.contextPath}/projects"
                                   class="btn btn-secondary">

                                    Cancel

                                </a>


                            </div>


                        </form>


                    </div>


                    <!-- =================================================
                         INFORMATION COLUMN
                         ================================================= -->

                    <div class="project-info-column">


                        <div class="project-info-card accent">


                            <div class="project-info-icon">
                                &#9998;
                            </div>


                            <h3>
                                Editing project
                            </h3>


                            <p>
                                You are updating an existing project.
                                Changes made here will be reflected
                                throughout the workspace.
                            </p>


                            <div class="project-summary">


                                <div class="summary-item">

                                    <span class="summary-label">
                                        Project
                                    </span>

                                    <span class="summary-value">

                                        <%= HtmlUtil.escape(
                                                project.getTitle()
                                        ) %>

                                    </span>

                                </div>


                                <div class="summary-item">

                                    <span class="summary-label">
                                        Status
                                    </span>

                                    <span class="summary-value"
                                          id="summaryStatus">

                                        <%= project.getStatus() != null
                                                ? project.getStatus()
                                                : "—" %>

                                    </span>

                                </div>


                            </div>


                        </div>


                        <div class="project-info-card">


                            <h3>
                                Before changing dates
                            </h3>


                            <p>
                                Make sure the start and end dates still
                                match the expected project timeline.
                                Keeping dates realistic makes project
                                tracking more useful.
                            </p>


                        </div>


                        <% if (isAdmin) { %>


                            <div class="project-info-card">


                                <h3>
                                    Manager assignment
                                </h3>


                                <p>
                                    Administrators can change the
                                    project manager from the selector.
                                    Leave it unchanged if the current
                                    assignment should remain.
                                </p>


                            </div>


                        <% } else { %>


                            <div class="project-info-card">


                                <h3>
                                    Keep it clear
                                </h3>


                                <p>
                                    Update the description or status
                                    whenever the project's direction
                                    changes so the rest of the team
                                    has accurate information.
                                </p>


                            </div>


                        <% } %>


                    </div>


                </div>


                <!-- =================================================
                     BACK LINK
                     ================================================= -->

                <div style="margin-top: 22px;">

                    <a class="back-link"
                       href="${pageContext.request.contextPath}/projects">

                        ← Back to Projects

                    </a>

                </div>


            </div>


        </div>


    </main>


</div>


<!-- =====================================================
     THEME + SIDEBAR + STATUS SCRIPT
     ===================================================== -->

<script>

    (function () {

        "use strict";


        /* =================================================
           THEME
           ================================================= */

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


        let savedTheme =
            "light";


        try {

            const storedTheme =
                localStorage.getItem(
                    "pms-theme"
                );


            if (
                storedTheme === "dark" ||
                storedTheme === "light"
            ) {

                savedTheme =
                    storedTheme;

            }

        } catch (error) {

            // Keep light mode.

        }


        applyTheme(
            savedTheme
        );


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


                    applyTheme(
                        nextTheme
                    );


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


        /* =================================================
           SIDEBAR
           ================================================= */

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

            sidebar.classList.add(
                "open"
            );

            sidebarOverlay.classList.add(
                "visible"
            );

            sidebarToggle.setAttribute(
                "aria-expanded",
                "true"
            );

        }


        function closeSidebar() {

            sidebar.classList.remove(
                "open"
            );

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

                if (
                    event.key === "Escape"
                ) {

                    closeSidebar();

                }

            }
        );


        /* =================================================
           STATUS HELPER
           ================================================= */

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

        const summaryStatus =
            document.getElementById(
                "summaryStatus"
            );


        function updateStatusInfo() {

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
                    "var(--mustard)";


            } else if (status === "ACTIVE") {

                statusHint.textContent =
                    "Active projects are currently being worked on.";

                statusDot.style.background =
                    "var(--primary)";


            } else if (status === "COMPLETED") {

                statusHint.textContent =
                    "Completed projects have finished their work.";

                statusDot.style.background =
                    "var(--sage)";

            }


            if (summaryStatus) {

                summaryStatus.textContent =
                    status;

            }

        }


        if (statusSelect) {

            statusSelect.addEventListener(
                "change",
                updateStatusInfo
            );

            updateStatusInfo();

        }


    })();

</script>


</body>

</html>