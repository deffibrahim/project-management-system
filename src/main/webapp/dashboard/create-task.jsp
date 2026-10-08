<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.pms.model.Project" %>
<%@ page import="com.pms.model.User" %>
<%@ page import="com.pms.util.HtmlUtil" %>
<%@ page import="java.util.List" %>

<%
    User currentUser = (User) session.getAttribute("user");

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

    List<Project> projects =
            (List<Project>) request.getAttribute("projects");

    List<User> users =
            (List<User>) request.getAttribute("users");
%>

<!DOCTYPE html>
<html lang="en">

<head>

    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>Create New Task</title>

    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/dashboard.css">


    <style>

        /* =====================================================
           CREATE TASK PAGE
           ===================================================== */

        .create-task-page {
            max-width: 1100px;
            margin: 0 auto;
        }


        /* =====================================================
           PAGE INTRO
           ===================================================== */

        .create-task-heading {
            margin-bottom: 24px;
        }

        .create-task-heading h1 {
            margin: 0 0 6px;

            font-size: 30px;
        }

        .create-task-heading p {
            margin: 0;

            max-width: 680px;

            color: var(--text-muted);

            font-size: 14px;

            line-height: 1.5;
        }


        /* =====================================================
           LAYOUT
           ===================================================== */

        .create-task-layout {
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

        .task-form-card {
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
           FORM GROUP
           ===================================================== */

        .task-form-group {
            margin-bottom: 19px;
        }

        .task-form-group:last-of-type {
            margin-bottom: 0;
        }

        .task-form-group label {
            display: block;

            margin-bottom: 7px;

            color: var(--text);

            font-size: 12px;

            font-weight: bold;
        }

        .task-form-group input,
        .task-form-group textarea,
        .task-form-group select {

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

        .task-form-group textarea {

            min-height: 125px;

            resize: vertical;

            line-height: 1.5;
        }

        .task-form-group input:focus,
        .task-form-group textarea:focus,
        .task-form-group select:focus {

            border-color: var(--primary);

            box-shadow:
                0 0 0 3px
                rgba(47, 127, 120, 0.11);

        }

        .task-form-group input::placeholder,
        .task-form-group textarea::placeholder {

            color: var(--text-light);

        }

        .field-hint {

            margin: 6px 0 0;

            color: var(--text-light);

            font-size: 11px;

            line-height: 1.4;
        }


        /* =====================================================
           TWO COLUMN ROW
           ===================================================== */

        .form-row {

            display: grid;

            grid-template-columns:
                1fr 1fr;

            gap: 14px;
        }


        /* =====================================================
           PROJECT / ASSIGNEE BOX
           ===================================================== */

        .assignment-box {

            padding: 15px;

            border: 1px solid var(--border);

            border-radius: 9px;

            background: var(--surface-soft);
        }


        /* =====================================================
           STATUS INFO
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

        .task-form-actions {

            display: flex;

            align-items: center;

            gap: 10px;

            margin-top: 25px;

            padding-top: 20px;

            border-top: 1px solid var(--border-light);

        }

        .task-form-actions .btn {

            min-width: 135px;

            justify-content: center;
        }


        /* =====================================================
           SIDE INFORMATION
           ===================================================== */

        .task-info-column {

            display: flex;

            flex-direction: column;

            gap: 14px;
        }

        .task-info-card {

            padding: 20px;

            background: var(--surface);

            border: 1px solid var(--border);

            border-radius: var(--radius);

            box-shadow: var(--shadow);
        }

        .task-info-card.accent {

            background:
                linear-gradient(
                    135deg,
                    var(--primary-soft),
                    var(--surface)
                );
        }

        .task-info-icon {

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

        .task-info-card h3 {

            margin: 0 0 7px;

            font-size: 15px;
        }

        .task-info-card p {

            margin: 0;

            color: var(--text-muted);

            font-size: 12px;

            line-height: 1.55;
        }


        /* =====================================================
           TIPS
           ===================================================== */

        .task-tips {

            margin: 15px 0 0;

            padding: 0;

            list-style: none;
        }

        .task-tips li {

            position: relative;

            padding-left: 17px;

            margin-bottom: 10px;

            color: var(--text-muted);

            font-size: 11px;

            line-height: 1.45;
        }

        .task-tips li:last-child {
            margin-bottom: 0;
        }

        .task-tips li::before {

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

            .create-task-layout {

                grid-template-columns: 1fr;

            }

            .task-info-column {

                display: grid;

                grid-template-columns:
                    1fr 1fr;

            }

        }


        @media (max-width: 650px) {

            .create-task-heading h1 {
                font-size: 26px;
            }

            .task-form-card {
                padding: 20px;
            }

            .form-row {
                grid-template-columns: 1fr;
            }

            .task-info-column {
                grid-template-columns: 1fr;
            }

        }


        @media (max-width: 450px) {

            .task-form-actions {

                flex-direction: column;

                align-items: stretch;

            }

            .task-form-actions .btn {
                width: 100%;
            }

        }

    </style>

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
               class="sidebar-link">

                <span class="sidebar-icon">
                    &#128193;
                </span>

                Projects

            </a>


            <a href="${pageContext.request.contextPath}/tasks"
               class="sidebar-link active">

                <span class="sidebar-icon">
                    &#9745;
                </span>

                Tasks

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


            <a href="${pageContext.request.contextPath}/logout"
               class="sidebar-logout">

                &#10140; Logout

            </a>


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
                        Create New Task
                    </h1>

                    <p>
                        Create a task and assign it to a team member.
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


            <div class="create-task-page">


                <!-- =================================================
                     PAGE INTRO
                     ================================================= -->

                <div class="create-task-heading">

                    <h1>
                        Add a New Task
                    </h1>

                    <p>
                        Break project work into a clear task,
                        choose the project it belongs to and set
                        its current status and deadline.
                    </p>

                </div>


                <!-- =================================================
                     FORM + INFORMATION
                     ================================================= -->

                <div class="create-task-layout">


                    <!-- =================================================
                         FORM
                         ================================================= -->

                    <div class="task-form-card">


                        <div class="form-card-heading">

                            <h2>
                                Task Details
                            </h2>

                            <p>
                                Fill in the information needed to
                                create the task.
                            </p>

                        </div>


                        <form action="${pageContext.request.contextPath}/tasks/create"
                              method="post">


                            <!-- CSRF -->

                            <input type="hidden"
                                   name="csrfToken"
                                   value="${sessionScope.csrfToken}">


                            <!-- PROJECT -->

                            <div class="task-form-group assignment-box">

                                <label for="projectId">
                                    Project
                                </label>


                                <select id="projectId"
                                        name="projectId"
                                        required>


                                    <option value="">
                                        Select Project
                                    </option>


                                    <%
                                        if (projects != null) {

                                            for (Project project : projects) {
                                    %>


                                        <option value="<%= project.getProjectId() %>">

                                            <%= HtmlUtil.escape(
                                                    project.getTitle()
                                            ) %>

                                        </option>


                                    <%
                                            }

                                        }
                                    %>


                                </select>


                                <p class="field-hint">
                                    Choose the project this task
                                    belongs to.
                                </p>

                            </div>


                            <!-- TITLE -->

                            <div class="task-form-group">

                                <label for="title">
                                    Task Title
                                </label>


                                <input type="text"
                                       id="title"
                                       name="title"
                                       maxlength="150"
                                       placeholder="e.g. Design login page"
                                       required>


                                <p class="field-hint">
                                    Use a short, action-oriented
                                    title when possible.
                                </p>

                            </div>


                            <!-- DESCRIPTION -->

                            <div class="task-form-group">

                                <label for="description">
                                    Description
                                </label>


                                <textarea id="description"
                                          name="description"
                                          maxlength="2000"
                                          placeholder="Describe what needs to be completed..."></textarea>


                                <p class="field-hint">
                                    Add useful details so the
                                    assignee knows what is expected.
                                </p>

                            </div>


                            <!-- ASSIGNEE -->

                            <div class="task-form-group assignment-box">

                                <label for="assigneeId">
                                    Assignee
                                </label>


                                <select id="assigneeId"
                                        name="assigneeId">


                                    <option value="">
                                        Unassigned
                                    </option>


                                    <%
                                        if (users != null) {

                                            for (User member : users) {

                                                if ("TEAM_MEMBER".equals(
                                                        member.getRole()
                                                )) {
                                    %>


                                        <option value="<%= member.getUserId() %>">

                                            <%= HtmlUtil.escape(
                                                    member.getName()
                                            ) %>

                                        </option>


                                    <%
                                                }

                                            }

                                        }
                                    %>


                                </select>


                                <p class="field-hint">
                                    You can leave the task unassigned
                                    and assign it later.
                                </p>

                            </div>


                            <!-- STATUS + DUE DATE -->

                            <div class="form-row">


                                <div class="task-form-group">

                                    <label for="status">
                                        Status
                                    </label>


                                    <select id="status"
                                            name="status"
                                            required>


                                        <option value="PENDING">
                                            Pending
                                        </option>

                                        <option value="IN_PROGRESS">
                                            In Progress
                                        </option>

                                        <option value="COMPLETED">
                                            Completed
                                        </option>


                                    </select>


                                    <div class="status-note">

                                        <span class="status-dot"
                                              id="statusDot">
                                        </span>

                                        <span id="statusHint">
                                            This task is waiting
                                            to be started.
                                        </span>

                                    </div>

                                </div>


                                <div class="task-form-group">

                                    <label for="dueDate">
                                        Due Date
                                    </label>


                                    <input type="date"
                                           id="dueDate"
                                           name="dueDate">


                                    <p class="field-hint">
                                        Set a deadline if the task
                                        has one.
                                    </p>

                                </div>


                            </div>


                            <div class="form-row">

                                <div class="task-form-group">

                                    <label for="priority">
                                        Priority
                                    </label>

                                    <select id="priority"
                                            name="priority">

                                        <option value="LOW">Low</option>
                                        <option value="MEDIUM" selected>Medium</option>
                                        <option value="HIGH">High</option>
                                        <option value="URGENT">Urgent</option>

                                    </select>

                                    <p class="field-hint">
                                        How important is this task?
                                    </p>

                                </div>

                            </div>


                            <!-- ACTIONS -->

                            <div class="task-form-actions">


                                <button type="submit"
                                        class="btn btn-primary">

                                    Create Task

                                </button>


                                <a href="${pageContext.request.contextPath}/tasks"
                                   class="btn btn-secondary">

                                    Cancel

                                </a>


                            </div>


                        </form>


                    </div>


                    <!-- =================================================
                         INFORMATION COLUMN
                         ================================================= -->

                    <div class="task-info-column">


                        <div class="task-info-card accent">


                            <div class="task-info-icon">
                                &#9745;
                            </div>


                            <h3>
                                Keep tasks clear
                            </h3>


                            <p>
                                A good task tells the team what needs
                                to be done without requiring them to
                                guess what the expected result is.
                            </p>


                            <ul class="task-tips">

                                <li>
                                    Give the task a specific title.
                                </li>

                                <li>
                                    Add useful context in the
                                    description.
                                </li>

                                <li>
                                    Assign it to the right team
                                    member when possible.
                                </li>

                                <li>
                                    Set a due date for deadline-driven
                                    work.
                                </li>

                            </ul>


                        </div>


                        <div class="task-info-card">


                            <h3>
                                Task status
                            </h3>


                            <p>
                                New work normally starts as Pending.
                                Move it to In Progress when work begins
                                and Completed once it is finished.
                            </p>


                        </div>


                        <div class="task-info-card">


                            <h3>
                                Assignment
                            </h3>


                            <p>
                                Tasks can be created without an
                                assignee. If you already know who will
                                handle the work, assign it now.
                            </p>


                        </div>


                    </div>


                </div>


                <!-- =================================================
                     BACK LINK
                     ================================================= -->

                <div style="margin-top: 22px;">

                    <a class="back-link"
                       href="${pageContext.request.contextPath}/tasks">

                        ← Back to Tasks

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


            if (status === "PENDING") {

                statusHint.textContent =
                    "This task is waiting to be started.";

                statusDot.style.background =
                    "var(--mustard)";


            } else if (status === "IN_PROGRESS") {

                statusHint.textContent =
                    "This task is currently being worked on.";

                statusDot.style.background =
                    "var(--primary)";


            } else if (status === "COMPLETED") {

                statusHint.textContent =
                    "This task has been completed.";

                statusDot.style.background =
                    "var(--sage)";

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