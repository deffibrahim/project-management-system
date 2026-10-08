<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.pms.model.User" %>
<%@ page import="com.pms.model.Task" %>
<%@ page import="com.pms.util.HtmlUtil" %>
<%@ page import="com.pms.util.TaskUi" %>
<%@ page import="java.util.List" %>

<%
    /*
     * If this page is opened directly, the dashboard servlet has
     * not loaded the tasks. Go through the servlet instead.
     */
    if (request.getAttribute("tasks") == null) {
        response.sendRedirect(
                request.getContextPath() + "/dashboard/team-member"
        );
        return;
    }

    User user = (User) session.getAttribute("user");

    List<Task> tasks =
            (List<Task>) request.getAttribute("tasks");

    int totalTasks = tasks != null ? tasks.size() : 0;
    int pendingTasks = 0;
    int inProgressTasks = 0;
    int completedTasks = 0;

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

    int completionPercent = totalTasks > 0
            ? (completedTasks * 100 / totalTasks)
            : 0;
%>

<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>Team Member Dashboard</title>

    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/dashboard.css">

    <style>
        /*
         * Small dashboard-specific additions.
         * Main styling comes from dashboard.css.
         */

        .team-hero {
            display: grid;
            grid-template-columns: minmax(0, 1.5fr) minmax(260px, 0.8fr);
            gap: 22px;
            margin-bottom: 28px;
        }

        .welcome-card {
            position: relative;
            overflow: hidden;
            padding: 28px;
            border-radius: 18px;
            background: linear-gradient(135deg, #2f7f78 0%, #3d8d84 100%);
            color: #ffffff;
            box-shadow: 0 10px 25px rgba(47, 127, 120, 0.18);
        }

        .welcome-card::after {
            content: "";
            position: absolute;
            width: 150px;
            height: 150px;
            right: -45px;
            top: -55px;
            border-radius: 50%;
            background: rgba(255, 255, 255, 0.10);
        }

        .welcome-card .eyebrow {
            margin: 0 0 8px;
            font-size: 0.78rem;
            font-weight: 700;
            letter-spacing: 0.12em;
            text-transform: uppercase;
            opacity: 0.82;
        }

        .welcome-card h2 {
            margin: 0 0 9px;
            font-size: 1.65rem;
            line-height: 1.2;
            color: #ffffff;
        }

        .welcome-card p {
            max-width: 650px;
            margin: 0;
            line-height: 1.65;
            color: rgba(255, 255, 255, 0.88);
        }

        .completion-card {
            padding: 24px;
            border-radius: 18px;
            background: #ffffff;
            border: 1px solid rgba(41, 39, 36, 0.08);
            box-shadow: 0 8px 22px rgba(41, 39, 36, 0.07);
        }

        .completion-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 15px;
            margin-bottom: 16px;
        }

        .completion-header h3 {
            margin: 0;
            font-size: 0.95rem;
        }

        .completion-percent {
            font-size: 1.55rem;
            font-weight: 800;
            color: #2f7f78;
        }

        .completion-track {
            height: 10px;
            overflow: hidden;
            border-radius: 999px;
            background: #e8e2d6;
        }

        .completion-fill {
            height: 100%;
            width: <%= completionPercent %>%;
            border-radius: inherit;
            background: #2f7f78;
            transition: width 0.25s ease;
        }

        .completion-note {
            margin: 13px 0 0;
            color: #746e65;
            font-size: 0.85rem;
        }

        .stat-card:nth-child(1) {
            border-top: 4px solid #2f7f78;
        }

        .stat-card:nth-child(2) {
            border-top: 4px solid #c39432;
        }

        .stat-card:nth-child(3) {
            border-top: 4px solid #b45149;
        }

        .stat-card:nth-child(4) {
            border-top: 4px solid #5d8a52;
        }

        .status-breakdown {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 12px;
        }

        .status-item {
            padding: 16px;
            border-radius: 13px;
            background: #f8f5ed;
            border: 1px solid rgba(41, 39, 36, 0.06);
        }

        .status-item span {
            display: block;
            margin-bottom: 7px;
            font-size: 0.78rem;
            color: #746e65;
        }

        .status-item strong {
            font-size: 1.35rem;
            color: #292724;
        }

        .status-dot {
            display: inline-block;
            width: 8px;
            height: 8px;
            margin-right: 5px;
            border-radius: 50%;
        }

        .status-dot.pending {
            background: #c39432;
        }

        .status-dot.progress {
            background: #2f7f78;
        }

        .status-dot.completed {
            background: #5d8a52;
        }

        .tasks-heading {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 15px;
            margin-bottom: 16px;
        }

        .tasks-heading h2 {
            margin-bottom: 0;
        }

        .task-count-label {
            padding: 7px 11px;
            border-radius: 999px;
            background: #eee9dd;
            color: #5e584f;
            font-size: 0.78rem;
            font-weight: 700;
        }

        .empty-state {
            padding: 42px 25px;
            text-align: center;
            border-radius: 16px;
            background: #ffffff;
            border: 1px dashed #cfc7b8;
        }

        .empty-icon {
            display: flex;
            align-items: center;
            justify-content: center;
            width: 52px;
            height: 52px;
            margin: 0 auto 14px;
            border-radius: 14px;
            background: #e5f0ed;
            color: #2f7f78;
            font-size: 1.35rem;
        }

        .empty-state h3 {
            margin: 0 0 6px;
        }

        .empty-state p {
            margin: 0;
            color: #746e65;
        }

        .task-title-cell {
            min-width: 180px;
            font-weight: 650;
            color: #292724;
        }

        .workspace-card {
            position: relative;
            overflow: hidden;
        }

        .workspace-card::before {
            content: "";
            position: absolute;
            left: 0;
            top: 0;
            bottom: 0;
            width: 4px;
            background: #2f7f78;
        }

        .workspace-card:nth-child(2)::before {
            background: #c39432;
        }

        @media (max-width: 900px) {
            .team-hero {
                grid-template-columns: 1fr;
            }

            .status-breakdown {
                grid-template-columns: 1fr;
            }
        }

        @media (max-width: 600px) {
            .welcome-card,
            .completion-card {
                padding: 21px;
            }

            .welcome-card h2 {
                font-size: 1.35rem;
            }

            .tasks-heading {
                align-items: flex-start;
                flex-direction: column;
            }

            .table-container {
                overflow-x: auto;
            }
        }

        body[data-theme="dark"] .completion-card,
        body[data-theme="dark"] .empty-state {
            background: var(--card-bg, #302e2a);
        }

        body[data-theme="dark"] .status-item {
            background: rgba(255, 255, 255, 0.05);
        }

        body[data-theme="dark"] .status-item strong,
        body[data-theme="dark"] .task-title-cell {
            color: #f4f0e8;
        }

        body[data-theme="dark"] .completion-track {
            background: rgba(255, 255, 255, 0.10);
        }

        body[data-theme="dark"] .task-count-label {
            background: rgba(255, 255, 255, 0.08);
            color: #d9d2c7;
        }

        body[data-theme="dark"] .empty-state {
            border-color: rgba(255, 255, 255, 0.15);
        }

        body[data-theme="dark"] .empty-state p,
        body[data-theme="dark"] .completion-note,
        body[data-theme="dark"] .status-item span {
            color: #aaa39a;
        }
    </style>
</head>

<body>

<div class="app-layout">

    <!-- Mobile sidebar overlay -->
    <div class="sidebar-overlay" id="sidebarOverlay"></div>

    <!-- ================= SIDEBAR ================= -->
    <aside class="sidebar" id="sidebar">

        <div class="sidebar-brand">
            <div class="brand-mark">P</div>

            <div>
                <p class="brand-name">Project Management</p>
                <p class="brand-subtitle">Workspace</p>
            </div>
        </div>

        <p class="sidebar-label">Workspace</p>

        <nav class="sidebar-nav">

            <a href="${pageContext.request.contextPath}/dashboard/team-member"
               class="sidebar-link active">
                <span class="sidebar-icon">&#9632;</span>
                Dashboard
            </a>

            <a href="${pageContext.request.contextPath}/projects"
               class="sidebar-link">
                <span class="sidebar-icon">&#128193;</span>
                Projects
            </a>

            <a href="${pageContext.request.contextPath}/tasks"
               class="sidebar-link">
                <span class="sidebar-icon">&#9745;</span>
                Tasks
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
                    <%= HtmlUtil.escape(user.getName()) %>
                </p>

                <p class="sidebar-user-role">
                    TEAM MEMBER
                </p>
            </div>

            <a href="${pageContext.request.contextPath}/logout"
               class="sidebar-logout">
                &#10140; Logout
            </a>

        </div>

    </aside>

    <!-- ================= MAIN CONTENT ================= -->
    <main class="main-content">

        <!-- Topbar -->
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
                    <h1>Team Dashboard</h1>

                    <p>
                        Welcome,
                        <strong>
                            <%= HtmlUtil.escape(user.getName()) %>
                        </strong>.
                        Here's what needs your attention.
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

        <div class="page-content">

            <!-- ================= WELCOME ================= -->
            <section class="team-hero">

                <div class="welcome-card">

                    <p class="eyebrow">Your Workspace</p>

                    <h2>Keep things moving.</h2>

                    <p>
                        Your assigned tasks are all in one place.
                        Check what's pending, continue work in progress,
                        and keep an eye on upcoming deadlines.
                    </p>

                </div>

                <div class="completion-card">

                    <div class="completion-header">
                        <h3>Task Completion</h3>

                        <span class="completion-percent">
                            <%= completionPercent %>%
                        </span>
                    </div>

                    <div class="completion-track">
                        <div class="completion-fill"></div>
                    </div>

                    <p class="completion-note">
                        <%= completedTasks %> of <%= totalTasks %> tasks completed
                    </p>

                </div>

            </section>

            <!-- ================= STATISTICS ================= -->
            <section class="stats-grid">

                <div class="stat-card">
                    <h3>Total Tasks</h3>

                    <div class="stat-number">
                        <%= totalTasks %>
                    </div>
                </div>

                <div class="stat-card">
                    <h3>Pending Tasks</h3>

                    <div class="stat-number">
                        <%= pendingTasks %>
                    </div>
                </div>

                <div class="stat-card">
                    <h3>In Progress</h3>

                    <div class="stat-number">
                        <%= inProgressTasks %>
                    </div>
                </div>

                <div class="stat-card">
                    <h3>Completed Tasks</h3>

                    <div class="stat-number">
                        <%= completedTasks %>
                    </div>
                </div>

            </section>

            <!-- ================= TASK OVERVIEW ================= -->
            <section class="section">

                <div class="section-heading">
                    <h2>My Task Overview</h2>
                </div>

                <div class="breakdown-grid">

                    <div class="breakdown-card">

                        <h3>Task Status</h3>

                        <div class="status-breakdown">

                            <div class="status-item">
                                <span>
                                    <i class="status-dot pending"></i>
                                    Pending
                                </span>

                                <strong>
                                    <%= pendingTasks %>
                                </strong>
                            </div>

                            <div class="status-item">
                                <span>
                                    <i class="status-dot progress"></i>
                                    In Progress
                                </span>

                                <strong>
                                    <%= inProgressTasks %>
                                </strong>
                            </div>

                            <div class="status-item">
                                <span>
                                    <i class="status-dot completed"></i>
                                    Completed
                                </span>

                                <strong>
                                    <%= completedTasks %>
                                </strong>
                            </div>

                        </div>

                    </div>

                </div>

            </section>

            <!-- ================= MY TASKS ================= -->
            <section class="section">

                <div class="tasks-heading">

                    <h2>My Tasks</h2>

                    <span class="task-count-label">
                        <%= totalTasks %> task<%= totalTasks == 1 ? "" : "s" %>
                    </span>

                </div>

                <% if (tasks == null || tasks.isEmpty()) { %>

                    <div class="empty-state">

                        <div class="empty-icon">
                            &#10003;
                        </div>

                        <h3>No tasks assigned</h3>

                        <p>
                            You currently have no tasks assigned to you.
                        </p>

                    </div>

                <% } else { %>

                    <div class="table-container">

                        <table class="data-table">

                            <thead>

                            <tr>
                                <th>Task ID</th>
                                <th>Project ID</th>
                                <th>Title</th>
                                <th>Status</th>
                                <th>Due Date</th>
                                <th>Action</th>
                            </tr>

                            </thead>

                            <tbody>

                            <% for (Task task : tasks) {

                                String tStatus =
                                        task.getStatus() != null
                                                ? task.getStatus()
                                                : "";

                                String badgeClass =
                                        tStatus.toLowerCase()
                                                .replace("_", "-");
                            %>

                            <tr>

                                <td>
                                    <%= task.getTaskId() %>
                                </td>

                                <td>
                                    <%= task.getProjectId() %>
                                </td>

                                <td class="task-title-cell">
                                    <a href="${pageContext.request.contextPath}/tasks/view?id=<%= task.getTaskId() %>"
                                       style="color: inherit; text-decoration: none;"
                                       title="Open task and comments">
                                        <%= HtmlUtil.escape(task.getTitle()) %>
                                    </a>
                                    <%= TaskUi.priorityBadge(task) %>
                                </td>

                                <td>
                                    <span class="badge badge-<%= badgeClass %>">
                                        <%= HtmlUtil.escape(tStatus) %>
                                    </span>
                                </td>

                                <td>
                                    <%= task.getDueDate() == null
                                            ? "-"
                                            : task.getDueDate().toString() %>
                                    <%= TaskUi.overdueBadge(task) %>
                                </td>

                                <td>
                                    <a class="btn btn-primary" style="padding: 5px 12px; font-size: 12.5px; border-radius: 6px; text-decoration: none;"
                                       href="${pageContext.request.contextPath}/tasks/edit?id=<%= task.getTaskId() %>">
                                        Update Status
                                    </a>
                                </td>

                            </tr>

                            <% } %>

                            </tbody>

                        </table>

                    </div>

                <% } %>

            </section>

            <!-- ================= WORKSPACE ================= -->
            <section class="section">

                <h2>Workspace</h2>

                <div class="management-grid">

                    <a class="management-link workspace-card"
                       href="${pageContext.request.contextPath}/tasks">
                        &#9745;
                        <span>View My Tasks</span>
                    </a>

                    <a class="management-link workspace-card"
                       href="${pageContext.request.contextPath}/projects">
                        &#128193;
                        <span>View Projects</span>
                    </a>

                </div>

            </section>

        </div>

    </main>

</div>

<!-- ================= THEME AND SIDEBAR SCRIPT ================= -->
<script>
    (function () {
        "use strict";

        const body = document.body;
        const themeToggle = document.getElementById("themeToggle");

        const sidebar = document.getElementById("sidebar");
        const sidebarToggle = document.getElementById("sidebarToggle");
        const sidebarOverlay = document.getElementById("sidebarOverlay");

        function applyTheme(theme) {

            body.setAttribute("data-theme", theme);

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
                    localStorage.getItem("pms-theme");

            if (
                    storedTheme === "dark" ||
                    storedTheme === "light"
            ) {
                savedTheme = storedTheme;
            }

        } catch (error) {
            // Ignore localStorage errors.
        }

        applyTheme(savedTheme);

        if (themeToggle) {

            themeToggle.addEventListener("click", function () {

                const currentTheme =
                        body.getAttribute("data-theme") || "light";

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
                    // Ignore localStorage errors.
                }

            });
        }

        function openSidebar() {

            sidebar.classList.add("open");
            sidebarOverlay.classList.add("visible");

            sidebarToggle.setAttribute(
                    "aria-expanded",
                    "true"
            );
        }

        function closeSidebar() {

            sidebar.classList.remove("open");
            sidebarOverlay.classList.remove("visible");

            sidebarToggle.setAttribute(
                    "aria-expanded",
                    "false"
            );
        }

        if (sidebarToggle) {

            sidebarToggle.addEventListener("click", function () {

                if (sidebar.classList.contains("open")) {
                    closeSidebar();
                } else {
                    openSidebar();
                }

            });
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

    })();
</script>

</body>
</html>