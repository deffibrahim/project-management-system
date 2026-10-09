<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.pms.model.Task" %>
<%@ page import="com.pms.model.Project" %>
<%@ page import="com.pms.model.User" %>
<%@ page import="com.pms.util.HtmlUtil" %>
<%@ page import="java.util.List" %>

<%
    Task task = (Task) request.getAttribute("task");

    if (task == null) {
        response.sendRedirect(request.getContextPath() + "/tasks");
        return;
    }

    List<Project> projects =
            (List<Project>) request.getAttribute("projects");

    List<User> users =
            (List<User>) request.getAttribute("users");

    User currentUser =
            (User) session.getAttribute("user");

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

    <title>Edit Task</title>

    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/dashboard.css">


    <style>

        /* =====================================================
           EDIT TASK PAGE
           ===================================================== */

        .edit-task-page {
            max-width: 1100px;
            margin: 0 auto;
        }


        /* =====================================================
           PAGE INTRO
           ===================================================== */

        .edit-task-heading {
            margin-bottom: 24px;
        }

        .edit-task-heading h1 {
            margin: 0 0 6px;

            font-size: 30px;
        }

        .edit-task-heading p {
            margin: 0;

            max-width: 680px;

            color: var(--text-muted);

            font-size: 14px;

            line-height: 1.5;
        }


        /* =====================================================
           TASK ID
           ===================================================== */

        .task-id-label {

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

        .task-id-label strong {
            color: var(--text);
        }


        /* =====================================================
           MAIN LAYOUT
           ===================================================== */

        .edit-task-layout {

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
           ASSIGNMENT BOX
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
           TASK SUMMARY
           ===================================================== */

        .task-summary {

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

            .edit-task-layout {

                grid-template-columns: 1fr;

            }

            .task-info-column {

                display: grid;

                grid-template-columns:
                    1fr 1fr;

            }

        }


        @media (max-width: 650px) {

            .edit-task-heading h1 {
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

            .task-summary {
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
                        Edit Task
                    </h1>

                    <p>
                        Update the task details and status.
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


            <div class="edit-task-page">


                <!-- =================================================
                     PAGE INTRO
                     ================================================= -->

                <div class="edit-task-heading">

                    <h1>
                        Update Task
                    </h1>

                    <p>
                        Make changes to the task information below.
                        The current task details have already been
                        loaded.
                    </p>


                    <div class="task-id-label">

                        Task ID

                        <strong>
                            #<%= task.getTaskId() %>
                        </strong>

                    </div>

                </div>


                <!-- =================================================
                     FORM + INFORMATION
                     ================================================= -->

                <div class="edit-task-layout">


                    <!-- =================================================
                         FORM
                         ================================================= -->

                    <div class="task-form-card">


                        <div class="form-card-heading">

                            <h2>
                                Task Details
                            </h2>

                            <p>
                                Update the fields you want to change.
                            </p>

                        </div>


                        <form action="${pageContext.request.contextPath}/tasks/update"
                              method="post">


                            <!-- CSRF -->

                            <input type="hidden"
                                   name="csrfToken"
                                   value="${sessionScope.csrfToken}">


                            <!-- TASK ID -->

                            <input type="hidden"
                                   name="taskId"
                                   value="<%= task.getTaskId() %>">


                            <!-- PROJECT -->

                            <div class="task-form-group assignment-box">

                                <label for="projectId">
                                    Project
                                </label>


                                <select id="projectId"
                                        name="projectId"
                                        required>


                                    <%
                                        if (projects != null) {

                                            for (Project project : projects) {

                                                boolean selected =
                                                        project.getProjectId()
                                                                == task.getProjectId();
                                    %>


                                        <option value="<%= project.getProjectId() %>"
                                                <%= selected
                                                        ? "selected"
                                                        : "" %>>

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
                                    Change the project this task
                                    belongs to if necessary.
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
                                       value="<%= HtmlUtil.escape(task.getTitle()) %>"
                                       required>


                                <p class="field-hint">
                                    Keep the task name short and
                                    action-oriented.
                                </p>

                            </div>


                            <!-- DESCRIPTION -->

                            <div class="task-form-group">

                                <label for="description">
                                    Description
                                </label>


                                <textarea id="description"
                                          name="description"
                                          maxlength="2000"><%= HtmlUtil.escape(task.getDescription()) %></textarea>


                                <p class="field-hint">
                                    Update the details whenever the
                                    task requirements change.
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

                                                    boolean selected =
                                                            member.getUserId()
                                                                    == task.getAssigneeId();
                                    %>


                                        <option value="<%= member.getUserId() %>"
                                                <%= selected
                                                        ? "selected"
                                                        : "" %>>

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
                                    Assign the task to a team member
                                    or leave it unassigned.
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


                                        <option value="PENDING"
                                                <%= "PENDING".equals(
                                                        task.getStatus()
                                                )
                                                        ? "selected"
                                                        : "" %>>

                                            Pending

                                        </option>


                                        <option value="IN_PROGRESS"
                                                <%= "IN_PROGRESS".equals(
                                                        task.getStatus()
                                                )
                                                        ? "selected"
                                                        : "" %>>

                                            In Progress

                                        </option>


                                        <option value="COMPLETED"
                                                <%= "COMPLETED".equals(
                                                        task.getStatus()
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


                                <div class="task-form-group">

                                    <label for="dueDate">
                                        Due Date
                                    </label>


                                    <input type="date"
                                           id="dueDate"
                                           name="dueDate"
                                           value="<%= task.getDueDate() == null
                                                   ? ""
                                                   : task.getDueDate() %>">


                                    <p class="field-hint">
                                        Update the deadline if the
                                        schedule has changed.
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

                                        <option value="LOW"
                                                <%= "LOW".equals(task.getPriority()) ? "selected" : "" %>>
                                            Low
                                        </option>
                                        <option value="MEDIUM"
                                                <%= "MEDIUM".equals(task.getPriority()) ? "selected" : "" %>>
                                            Medium
                                        </option>
                                        <option value="HIGH"
                                                <%= "HIGH".equals(task.getPriority()) ? "selected" : "" %>>
                                            High
                                        </option>
                                        <option value="URGENT"
                                                <%= "URGENT".equals(task.getPriority()) ? "selected" : "" %>>
                                            Urgent
                                        </option>

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

                                    Update Task

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
                                &#9998;
                            </div>


                            <h3>
                                Editing task
                            </h3>


                            <p>
                                You are updating an existing task.
                                Changes here will be reflected wherever
                                this task is displayed.
                            </p>


                            <div class="task-summary">


                                <div class="summary-item">

                                    <span class="summary-label">
                                        Task
                                    </span>

                                    <span class="summary-value">

                                        <%= HtmlUtil.escape(
                                                task.getTitle()
                                        ) %>

                                    </span>

                                </div>


                                <div class="summary-item">

                                    <span class="summary-label">
                                        Status
                                    </span>

                                    <span class="summary-value"
                                          id="summaryStatus">

                                        <%= task.getStatus() != null
                                                ? task.getStatus()
                                                : "—" %>

                                    </span>

                                </div>


                            </div>


                        </div>


                        <div class="task-info-card">


                            <h3>
                                Keep the task current
                            </h3>


                            <p>
                                Update the description, assignee,
                                status or deadline whenever the work
                                changes. Accurate task information makes
                                project tracking more useful.
                            </p>


                        </div>


                        <div class="task-info-card">


                            <h3>
                                Status progression
                            </h3>


                            <p>
                                Pending means the work has not started.
                                In Progress means someone is working on
                                it. Completed means the task is finished.
                            </p>


                            <ul class="task-tips">

                                <li>
                                    Keep the status accurate.
                                </li>

                                <li>
                                    Reassign the task if ownership
                                    changes.
                                </li>

                                <li>
                                    Update the deadline when necessary.
                                </li>

                            </ul>


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