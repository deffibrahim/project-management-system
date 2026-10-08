<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.pms.model.User" %>
<%@ page import="com.pms.model.Project" %>
<%@ page import="com.pms.model.Task" %>
<%@ page import="com.pms.util.HtmlUtil" %>
<%@ page import="com.pms.util.TaskUi" %>
<%@ page import="java.util.List" %>

<%
    /*
     * If this page is opened directly, the dashboard servlet has
     * not loaded the data. Go through the servlet instead.
     */
    if (request.getAttribute("projects") == null) {
        response.sendRedirect(
                request.getContextPath() + "/dashboard/project-manager"
        );
        return;
    }

    User user = (User) session.getAttribute("user");

    List<Project> projects =
            (List<Project>) request.getAttribute("projects");

    List<Task> tasks =
            (List<Task>) request.getAttribute("tasks");


    int totalProjects =
            projects != null ? projects.size() : 0;

    int activeProjects = 0;


    int totalTasks =
            tasks != null ? tasks.size() : 0;

    int completedTasks = 0;
    int pendingTasks = 0;
    int inProgressTasks = 0;


    if (projects != null) {

        for (Project project : projects) {

            if ("ACTIVE".equals(project.getStatus())) {
                activeProjects++;
            }

        }

    }


    if (tasks != null) {

        for (Task task : tasks) {

            if ("PENDING".equals(task.getStatus())) {
                pendingTasks++;
            }

            if ("IN_PROGRESS".equals(task.getStatus())) {
                inProgressTasks++;
            }

            if ("COMPLETED".equals(task.getStatus())) {
                completedTasks++;
            }

        }

    }


    int taskCompletionPercent = 0;

    if (totalTasks > 0) {

        taskCompletionPercent =
                (int) Math.round(
                        ((double) completedTasks / totalTasks) * 100
                );

    }
%>


<!DOCTYPE html>
<html lang="en">


<head>

    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>Project Manager Dashboard</title>

    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/dashboard.css">


    <style>

        /* =====================================================
           PM DASHBOARD
           ===================================================== */

        .pm-dashboard {
            max-width: 1200px;
            margin: 0 auto;
        }


        /* =====================================================
           WELCOME
           ===================================================== */

        .pm-welcome {

            margin-bottom: 24px;

        }

        .pm-welcome h2 {

            margin: 0 0 6px;

            font-size: 22px;

        }

        .pm-welcome p {

            margin: 0;

            color: var(--text-muted);

            font-size: 13px;

            line-height: 1.5;

        }


        /* =====================================================
           STAT CARDS
           ===================================================== */

        .pm-stats {

            display: grid;

            grid-template-columns:
                repeat(4, 1fr);

            gap: 14px;

            margin-bottom: 20px;

        }


        .pm-stat {

            position: relative;

            padding: 18px;

            overflow: hidden;

            background: var(--surface);

            border: 1px solid var(--border);

            border-radius: var(--radius);

            box-shadow: var(--shadow);

        }


        .pm-stat::after {

            content: "";

            position: absolute;

            width: 55px;
            height: 55px;

            right: -20px;
            bottom: -20px;

            border-radius: 50%;

            background: var(--primary-soft);

        }


        .pm-stat-label {

            display: block;

            margin-bottom: 7px;

            color: var(--text-muted);

            font-size: 11px;

            font-weight: 600;

            text-transform: uppercase;

            letter-spacing: 0.04em;

        }


        .pm-stat-number {

            position: relative;

            z-index: 1;

            color: var(--text);

            font-size: 27px;

            font-weight: 700;

        }


        .pm-stat-note {

            position: relative;

            z-index: 1;

            margin-top: 3px;

            color: var(--text-light);

            font-size: 10px;

        }


        /* =====================================================
           DASHBOARD GRID
           ===================================================== */

        .pm-main-grid {

            display: grid;

            grid-template-columns:
                minmax(0, 1.4fr)
                minmax(280px, 0.8fr);

            gap: 20px;

            margin-bottom: 20px;

        }


        /* =====================================================
           DASHBOARD CARD
           ===================================================== */

        .pm-card {

            min-width: 0;

            padding: 21px;

            background: var(--surface);

            border: 1px solid var(--border);

            border-radius: var(--radius);

            box-shadow: var(--shadow);

        }


        .pm-card-header {

            display: flex;

            align-items: center;

            justify-content: space-between;

            gap: 12px;

            margin-bottom: 18px;

        }


        .pm-card-header h2 {

            margin: 0 0 4px;

            font-size: 17px;

        }


        .pm-card-header p {

            margin: 0;

            color: var(--text-muted);

            font-size: 11px;

        }


        .pm-card-link {

            flex-shrink: 0;

            color: var(--primary);

            font-size: 11px;

            font-weight: 600;

            text-decoration: none;

        }


        .pm-card-link:hover {
            text-decoration: underline;
        }


        /* =====================================================
           TASK PROGRESS
           ===================================================== */

        .task-progress-card {

            display: flex;

            flex-direction: column;

            justify-content: space-between;

        }


        .progress-number-row {

            display: flex;

            align-items: flex-end;

            justify-content: space-between;

            margin-bottom: 10px;

        }


        .progress-number {

            color: var(--text);

            font-size: 34px;

            font-weight: 700;

            line-height: 1;

        }


        .progress-label {

            color: var(--text-muted);

            font-size: 11px;

        }


        .pm-progress-track {

            width: 100%;

            height: 9px;

            overflow: hidden;

            border-radius: 20px;

            background: var(--surface-soft);

            border: 1px solid var(--border-light);

        }


        .pm-progress-fill {

            height: 100%;

            width: <%= taskCompletionPercent %>%;

            border-radius: inherit;

            background: var(--primary);

            transition: width 0.3s ease;

        }


        .task-breakdown {

            display: grid;

            grid-template-columns:
                1fr 1fr 1fr;

            gap: 7px;

            margin-top: 16px;

        }


        .task-breakdown-item {

            padding: 10px 8px;

            text-align: center;

            border-radius: 8px;

            background: var(--surface-soft);

            border: 1px solid var(--border-light);

        }


        .task-breakdown-item strong {

            display: block;

            margin-bottom: 3px;

            color: var(--text);

            font-size: 15px;

        }


        .task-breakdown-item span {

            color: var(--text-light);

            font-size: 9px;

            text-transform: uppercase;

        }


        /* =====================================================
           PROJECT LIST
           ===================================================== */

        .pm-project-list {

            display: flex;

            flex-direction: column;

            gap: 9px;

        }


        .pm-project-item {

            display: grid;

            grid-template-columns:
                1fr auto;

            gap: 12px;

            padding: 12px;

            border: 1px solid var(--border-light);

            border-radius: 9px;

            background: var(--surface-soft);

        }


        .pm-project-title {

            margin: 0 0 5px;

            color: var(--text);

            font-size: 12px;

            font-weight: 700;

        }


        .pm-project-meta {

            display: flex;

            flex-wrap: wrap;

            gap: 8px;

            color: var(--text-light);

            font-size: 10px;

        }


        .pm-project-status {

            align-self: center;

        }


        /* =====================================================
           TASK LIST
           ===================================================== */

        .pm-task-list {

            display: flex;

            flex-direction: column;

            gap: 9px;

        }


        .pm-task-item {

            display: grid;

            grid-template-columns:
                1fr auto;

            gap: 12px;

            padding: 12px;

            border: 1px solid var(--border-light);

            border-radius: 9px;

            background: var(--surface-soft);

        }


        .pm-task-title {

            margin: 0 0 5px;

            color: var(--text);

            font-size: 12px;

            font-weight: 700;

        }


        .pm-task-meta {

            display: flex;

            flex-wrap: wrap;

            gap: 8px;

            color: var(--text-light);

            font-size: 10px;

        }


        .pm-task-status {

            align-self: center;

        }


        /* =====================================================
           EMPTY STATE
           ===================================================== */

        .pm-empty {

            padding: 28px 15px;

            text-align: center;

            border: 1px dashed var(--border);

            border-radius: 9px;

            background: var(--surface-soft);

        }


        .pm-empty-icon {

            margin-bottom: 7px;

            font-size: 24px;

        }


        .pm-empty h3 {

            margin: 0 0 4px;

            font-size: 14px;

        }


        .pm-empty p {

            margin: 0;

            color: var(--text-muted);

            font-size: 11px;

        }


        /* =====================================================
           MANAGEMENT
           ===================================================== */

        .pm-management-grid {

            display: grid;

            grid-template-columns:
                repeat(4, 1fr);

            gap: 10px;

        }


        .pm-management-link {

            display: flex;

            align-items: center;

            justify-content: center;

            min-height: 52px;

            padding: 10px;

            border: 1px solid var(--border);

            border-radius: 9px;

            background: var(--surface);

            color: var(--text);

            font-size: 11px;

            font-weight: 600;

            text-align: center;

            text-decoration: none;

            transition:
                border-color 0.2s ease,
                background 0.2s ease,
                transform 0.2s ease;

        }


        .pm-management-link:hover {

            border-color: var(--primary);

            background: var(--primary-soft);

            transform: translateY(-1px);

        }


        .pm-management-link.primary {

            background: var(--primary);

            border-color: var(--primary);

            color: #ffffff;

        }


        .pm-management-link.primary:hover {

            background: var(--primary-hover);

            border-color: var(--primary-hover);

        }


        /* =====================================================
           RESPONSIVE
           ===================================================== */

        @media (max-width: 1000px) {

            .pm-stats {

                grid-template-columns:
                    1fr 1fr;

            }


            .pm-main-grid {

                grid-template-columns:
                    1fr;

            }


            .pm-management-grid {

                grid-template-columns:
                    1fr 1fr;

            }

        }


        @media (max-width: 600px) {

            .pm-stats {

                grid-template-columns:
                    1fr 1fr;

            }


            .pm-card {

                padding: 17px;

            }


            .pm-card-header {

                align-items: flex-start;

            }


            .pm-project-item,
            .pm-task-item {

                grid-template-columns:
                    1fr;

            }


            .pm-project-status,
            .pm-task-status {

                justify-self: start;

            }


            .pm-management-grid {

                grid-template-columns:
                    1fr;

            }

        }


        @media (max-width: 420px) {

            .pm-stats {

                grid-template-columns:
                    1fr;

            }


            .task-breakdown {

                grid-template-columns:
                    1fr;

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


            <a href="${pageContext.request.contextPath}/dashboard/project-manager"
               class="sidebar-link active">

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
               class="sidebar-link">

                <span class="sidebar-icon">
                    &#9745;
                </span>

                Tasks

            </a>

            <a href="${pageContext.request.contextPath}/workload"
               class="sidebar-link">

                <span class="sidebar-icon">
                    &#128202;
                </span>

                Workload

            </a>



        </nav>

        <p class="sidebar-label"
           style="margin-top: 28px;">

            Account

        </p>

        <nav class="sidebar-nav">

            <a href="${pageContext.request.contextPath}/settings"
               class="sidebar-link">

                <span class="sidebar-icon">
                    &#9881;
                </span>

                Settings

            </a>

        </nav>




        <div class="sidebar-bottom">


            <div class="sidebar-user">

                <p class="sidebar-user-name">

                    <%= HtmlUtil.escape(
                            user.getName()
                    ) %>

                </p>

                <p class="sidebar-user-role">
                    PROJECT MANAGER
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
                        PM Dashboard
                    </h1>

                    <p>
                        Welcome,
                        <strong>
                            <%= HtmlUtil.escape(
                                    user.getName()
                            ) %>
                        </strong>.
                        Here's your management overview.
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


            <div class="pm-dashboard">


                <!-- =================================================
                     WELCOME
                     ================================================= -->

                <div class="pm-welcome">

                    <h2>
                        Your workspace at a glance
                    </h2>

                    <p>
                        Keep track of your projects, tasks and
                        overall progress from one place.
                    </p>

                </div>


                <!-- =================================================
                     STATISTICS
                     ================================================= -->

                <section class="pm-stats">


                    <div class="pm-stat">

                        <span class="pm-stat-label">
                            Total Projects
                        </span>

                        <div class="pm-stat-number">
                            <%= totalProjects %>
                        </div>

                        <div class="pm-stat-note">
                            Projects assigned to you
                        </div>

                    </div>


                    <div class="pm-stat">

                        <span class="pm-stat-label">
                            Active Projects
                        </span>

                        <div class="pm-stat-number">
                            <%= activeProjects %>
                        </div>

                        <div class="pm-stat-note">
                            Currently in progress
                        </div>

                    </div>


                    <div class="pm-stat">

                        <span class="pm-stat-label">
                            Total Tasks
                        </span>

                        <div class="pm-stat-number">
                            <%= totalTasks %>
                        </div>

                        <div class="pm-stat-note">
                            Across your projects
                        </div>

                    </div>


                    <div class="pm-stat">

                        <span class="pm-stat-label">
                            Completed Tasks
                        </span>

                        <div class="pm-stat-number">
                            <%= completedTasks %>
                        </div>

                        <div class="pm-stat-note">
                            <%= taskCompletionPercent %>% of all tasks
                        </div>

                    </div>


                </section>


                <!-- =================================================
                     OVERVIEW GRID
                     ================================================= -->

                <div class="pm-main-grid">


                    <!-- =================================================
                         PROJECTS
                         ================================================= -->

                    <section class="pm-card">


                        <div class="pm-card-header">


                            <div>

                                <h2>
                                    My Projects
                                </h2>

                                <p>
                                    Projects currently assigned to you.
                                </p>

                            </div>


                            <a class="pm-card-link"
                               href="${pageContext.request.contextPath}/projects">

                                View all

                            </a>


                        </div>


                        <% if (projects == null || projects.isEmpty()) { %>


                            <div class="pm-empty">

                                <div class="pm-empty-icon">
                                    &#128193;
                                </div>

                                <h3>
                                    No projects yet
                                </h3>

                                <p>
                                    You currently have no projects
                                    assigned to you.
                                </p>

                            </div>


                        <% } else { %>


                            <div class="pm-project-list">


                                <% for (Project project : projects) {

                                    String pStatus =
                                            project.getStatus() != null
                                                    ? project.getStatus()
                                                    : "";

                                    String badgeClass =
                                            pStatus
                                                    .toLowerCase()
                                                    .replace("_", "-");

                                %>


                                    <div class="pm-project-item">


                                        <div>

                                            <p class="pm-project-title">

                                                <%= HtmlUtil.escape(
                                                        project.getTitle()
                                                ) %>

                                            </p>


                                            <div class="pm-project-meta">

                                                <span>
                                                    ID #<%= project.getProjectId() %>
                                                </span>


                                                <span>
                                                    Start:
                                                    <%= project.getStartDate() == null
                                                            ? "-"
                                                            : project.getStartDate().toString() %>
                                                </span>


                                                <span>
                                                    End:
                                                    <%= project.getEndDate() == null
                                                            ? "-"
                                                            : project.getEndDate().toString() %>
                                                </span>

                                            </div>

                                        </div>


                                        <div class="pm-project-status">

                                            <span class="badge badge-<%= badgeClass %>">

                                                <%= HtmlUtil.escape(
                                                        pStatus
                                                ) %>

                                            </span>

                                        </div>


                                    </div>


                                <% } %>


                            </div>


                        <% } %>


                    </section>


                    <!-- =================================================
                         TASK PROGRESS
                         ================================================= -->

                    <section class="pm-card task-progress-card">


                        <div>


                            <div class="pm-card-header">

                                <div>

                                    <h2>
                                        Task Progress
                                    </h2>

                                    <p>
                                        Completion across your tasks.
                                    </p>

                                </div>

                            </div>


                            <div class="progress-number-row">

                                <div class="progress-number">
                                    <%= taskCompletionPercent %>%
                                </div>

                                <div class="progress-label">
                                    completed
                                </div>

                            </div>


                            <div class="pm-progress-track">

                                <div class="pm-progress-fill">
                                </div>

                            </div>


                            <div class="task-breakdown">


                                <div class="task-breakdown-item">

                                    <strong>
                                        <%= pendingTasks %>
                                    </strong>

                                    <span>
                                        Pending
                                    </span>

                                </div>


                                <div class="task-breakdown-item">

                                    <strong>
                                        <%= inProgressTasks %>
                                    </strong>

                                    <span>
                                        In Progress
                                    </span>

                                </div>


                                <div class="task-breakdown-item">

                                    <strong>
                                        <%= completedTasks %>
                                    </strong>

                                    <span>
                                        Completed
                                    </span>

                                </div>


                            </div>


                        </div>


                    </section>


                </div>


                <!-- =================================================
                     PROJECT TASKS
                     ================================================= -->

                <section class="pm-card"
                         style="margin-bottom:20px;">


                    <div class="pm-card-header">


                        <div>

                            <h2>
                                Project Tasks
                            </h2>

                            <p>
                                Tasks belonging to your projects.
                            </p>

                        </div>


                        <a class="pm-card-link"
                           href="${pageContext.request.contextPath}/tasks">

                            View all

                        </a>


                    </div>


                    <% if (tasks == null || tasks.isEmpty()) { %>


                        <div class="pm-empty">

                            <div class="pm-empty-icon">
                                &#9745;
                            </div>

                            <h3>
                                No tasks yet
                            </h3>

                            <p>
                                There are currently no tasks in your
                                projects.
                            </p>

                        </div>


                    <% } else { %>


                        <div class="pm-task-list">


                            <% for (Task task : tasks) {

                                String tStatus =
                                        task.getStatus() != null
                                                ? task.getStatus()
                                                : "";

                                String badgeClass =
                                        tStatus
                                                .toLowerCase()
                                                .replace("_", "-");

                            %>


                                <div class="pm-task-item">


                                    <div>

                                        <p class="pm-task-title">

                                            <a href="${pageContext.request.contextPath}/tasks/view?id=<%= task.getTaskId() %>"
                                               style="color: inherit; text-decoration: none;"
                                               title="Open task and comments">
                                                <%= HtmlUtil.escape(
                                                        task.getTitle()
                                                ) %>
                                            </a>

                                        </p>


                                        <div class="pm-task-meta">

                                            <span>
                                                Task #<%= task.getTaskId() %>
                                            </span>


                                            <span>
                                                Project #<%= task.getProjectId() %>
                                            </span>


                                            <span>
                                                Due:
                                                <%= task.getDueDate() == null
                                                        ? "-"
                                                        : task.getDueDate().toString() %>
                                                <%= TaskUi.overdueBadge(task) %>
                                            </span>


                                            <span>
                                                <%= TaskUi.priorityBadge(task) %>
                                            </span>

                                        </div>

                                    </div>


                                    <div class="pm-task-status">

                                        <span class="badge badge-<%= badgeClass %>">

                                            <%= HtmlUtil.escape(
                                                    tStatus
                                            ) %>

                                        </span>

                                    </div>


                                </div>


                            <% } %>


                        </div>


                    <% } %>


                </section>


                <!-- =================================================
                     MANAGEMENT
                     ================================================= -->

                <section class="pm-card">


                    <div class="pm-card-header">

                        <div>

                            <h2>
                                Management
                            </h2>

                            <p>
                                Quick access to your main workspace
                                actions.
                            </p>

                        </div>

                    </div>


                    <div class="pm-management-grid">


                        <a class="pm-management-link"
                           href="${pageContext.request.contextPath}/projects">

                            &#128193;&nbsp; Manage Projects

                        </a>


                        <a class="pm-management-link"
                           href="${pageContext.request.contextPath}/tasks">

                            &#9745;&nbsp; Manage Tasks

                        </a>


                        <a class="pm-management-link primary"
                           href="${pageContext.request.contextPath}/projects/create">

                            +&nbsp; Create Project

                        </a>


                        <a class="pm-management-link"
                           href="${pageContext.request.contextPath}/tasks/create">

                            +&nbsp; Create Task

                        </a>


                    </div>


                </section>


            </div>


        </div>


    </main>


</div>


<!-- =====================================================
     THEME + SIDEBAR SCRIPT
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


    })();

</script>


</body>

</html>