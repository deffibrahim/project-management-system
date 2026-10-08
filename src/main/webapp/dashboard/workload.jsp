<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.pms.model.User" %>
<%@ page import="com.pms.model.WorkloadRow" %>
<%@ page import="com.pms.util.HtmlUtil" %>

<%
    List<WorkloadRow> rows = (List<WorkloadRow>) request.getAttribute("rows");
    WorkloadRow unassigned = (WorkloadRow) request.getAttribute("unassigned");

    if (rows == null || unassigned == null) {
        response.sendRedirect(request.getContextPath() + "/workload");
        return;
    }

    User currentUser = (User) session.getAttribute("user");

    String role = currentUser != null ? currentUser.getRole() : "";
    boolean isAdmin = "ADMIN".equals(role);

    String dashboardUrl = isAdmin ? "/dashboard/admin" : "/dashboard/project-manager";
    String roleLabel = isAdmin ? "ADMIN" : "PROJECT MANAGER";

    int maxOpen = 0;
    int totalOpen = 0;
    int totalOverdue = 0;

    for (WorkloadRow row : rows) {
        maxOpen = Math.max(maxOpen, row.getOpen());
        totalOpen += row.getOpen();
        totalOverdue += row.getOverdue();
    }

    totalOpen += unassigned.getOpen();
    totalOverdue += unassigned.getOverdue();
%>

<!DOCTYPE html>
<html lang="en">

<head>

    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>Workload | Project Management Tool</title>

    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/dashboard.css">

    <style>

        .workload-page {
            max-width: 980px;
            margin: 0 auto;
        }

        .workload-summary {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(170px, 1fr));
            gap: 14px;
            margin-bottom: 22px;
        }

        .summary-card {
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: 12px;
            padding: 16px 18px;
            box-shadow: var(--shadow);
        }

        .summary-card p {
            margin: 0;
        }

        .summary-label {
            font-size: 0.74rem;
            font-weight: 700;
            letter-spacing: 0.06em;
            text-transform: uppercase;
            color: var(--text-light);
        }

        .summary-number {
            margin-top: 6px !important;
            font-size: 1.9rem;
            font-weight: 800;
        }

        .summary-number.warn {
            color: var(--danger);
        }

        .workload-list {
            display: flex;
            flex-direction: column;
            gap: 12px;
        }

        .workload-row {
            display: grid;
            grid-template-columns: minmax(150px, 1.1fr) minmax(160px, 1.6fr) auto;
            gap: 18px;
            align-items: center;
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: 12px;
            padding: 16px 18px;
            box-shadow: var(--shadow);
        }

        .workload-row.unassigned {
            border-style: dashed;
        }

        .workload-name {
            margin: 0;
            font-weight: 700;
        }

        .workload-email {
            margin: 2px 0 0;
            font-size: 0.82rem;
            color: var(--text-muted);
            word-break: break-all;
        }

        .load-bar {
            height: 10px;
            border-radius: 999px;
            background: var(--surface-hover);
            overflow: hidden;
        }

        .load-bar-fill {
            height: 100%;
            border-radius: 999px;
            background: var(--primary);
        }

        .load-caption {
            margin: 6px 0 0;
            font-size: 0.82rem;
            color: var(--text-muted);
        }

        .load-chips {
            display: flex;
            gap: 6px;
            flex-wrap: wrap;
            margin-top: 8px;
        }

        .workload-actions {
            text-align: right;
        }

        .workload-actions a {
            font-weight: 600;
            text-decoration: none;
            white-space: nowrap;
        }

        .workload-empty {
            color: var(--text-muted);
            padding: 24px 0;
        }

        @media (max-width: 760px) {

            .workload-row {
                grid-template-columns: 1fr;
                gap: 10px;
            }

            .workload-actions {
                text-align: left;
            }

        }

    </style>

</head>

<body>

<div class="app-layout">

    <div class="sidebar-overlay"
         id="sidebarOverlay">
    </div>

    <aside class="sidebar"
           id="sidebar">

        <div class="sidebar-brand">

            <div class="brand-mark">P</div>

            <div>
                <p class="brand-name">Project Management</p>
                <p class="brand-subtitle">Workspace</p>
            </div>

        </div>

        <p class="sidebar-label">Workspace</p>

        <nav class="sidebar-nav">

            <a href="${pageContext.request.contextPath}<%= dashboardUrl %>"
               class="sidebar-link">
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

            <% if (!"TEAM_MEMBER".equals(role)) { %>
            <a href="${pageContext.request.contextPath}/workload"
               class="sidebar-link active">

                <span class="sidebar-icon">
                    &#128202;
                </span>

                Workload

            </a>
            <% } %>


        </nav>

        <% if (isAdmin) { %>

        <p class="sidebar-label">Administration</p>

        <nav class="sidebar-nav">

            <a href="${pageContext.request.contextPath}/users"
               class="sidebar-link">
                <span class="sidebar-icon">&#128101;</span>
                Users
            </a>

            <a href="${pageContext.request.contextPath}/settings"
               class="sidebar-link">
                <span class="sidebar-icon">&#9881;</span>
                Settings
            </a>

        </nav>

        <% } else { %>

        <p class="sidebar-label">Account</p>

        <nav class="sidebar-nav">

            <a href="${pageContext.request.contextPath}/settings"
               class="sidebar-link">
                <span class="sidebar-icon">&#9881;</span>
                Settings
            </a>

        </nav>

        <% } %>

        <div class="sidebar-bottom">

            <div class="sidebar-user">
                <p class="sidebar-user-name">
                    <%= HtmlUtil.escape(currentUser != null ? currentUser.getName() : "") %>
                </p>
                <p class="sidebar-user-role">
                    <%= roleLabel %>
                </p>
            </div>

            <a href="${pageContext.request.contextPath}/logout"
               class="sidebar-logout">
                &#10140; Logout
            </a>

        </div>

    </aside>

    <main class="main-content">

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
                    <h1>Workload</h1>
                    <p>Who is carrying how much work right now.</p>
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

            <div class="workload-page">

                <div class="workload-summary">

                    <div class="summary-card">
                        <p class="summary-label">Team Members</p>
                        <p class="summary-number"><%= rows.size() %></p>
                    </div>

                    <div class="summary-card">
                        <p class="summary-label">Open Tasks</p>
                        <p class="summary-number"><%= totalOpen %></p>
                    </div>

                    <div class="summary-card">
                        <p class="summary-label">Overdue</p>
                        <p class="summary-number <%= totalOverdue > 0 ? "warn" : "" %>"><%= totalOverdue %></p>
                    </div>

                    <div class="summary-card">
                        <p class="summary-label">Unassigned (open)</p>
                        <p class="summary-number <%= unassigned.getOpen() > 0 ? "warn" : "" %>"><%= unassigned.getOpen() %></p>
                    </div>

                </div>

                <% if (!isAdmin) { %>
                <p style="color: var(--text-muted); font-size: 0.9rem; margin: -6px 0 18px;">
                    Task counts include only the projects you manage.
                </p>
                <% } %>

                <% if (rows.isEmpty()) { %>

                <p class="workload-empty">
                    There are no team members yet. Add users with the Team Member
                    role and they will appear here.
                </p>

                <% } else { %>

                <div class="workload-list">

                    <% for (WorkloadRow row : rows) {

                        int percent = maxOpen > 0
                                ? (int) Math.round(row.getOpen() * 100.0 / maxOpen)
                                : 0;
                    %>

                    <div class="workload-row">

                        <div>
                            <p class="workload-name"><%= HtmlUtil.escape(row.getName()) %></p>
                            <p class="workload-email"><%= HtmlUtil.escape(row.getEmail()) %></p>
                        </div>

                        <div>

                            <div class="load-bar"
                                 role="img"
                                 aria-label="<%= row.getOpen() %> open tasks">
                                <div class="load-bar-fill"
                                     style="width: <%= percent %>%;"></div>
                            </div>

                            <p class="load-caption">
                                <strong><%= row.getOpen() %></strong> open
                                (<%= row.getInProgress() %> in progress,
                                <%= row.getPending() %> pending)
                                &middot; <%= row.getCompleted() %> completed
                            </p>

                            <div class="load-chips">
                                <% if (row.getOverdue() > 0) { %>
                                <span class="badge badge-overdue"><%= row.getOverdue() %> overdue</span>
                                <% } %>
                                <% if (row.getUrgent() > 0) { %>
                                <span class="badge badge-urgent"><%= row.getUrgent() %> urgent</span>
                                <% } %>
                                <% if (row.getOpen() == 0) { %>
                                <span class="badge badge-low">Free</span>
                                <% } %>
                            </div>

                        </div>

                        <div class="workload-actions">
                            <a href="${pageContext.request.contextPath}/tasks?assignee=<%= row.getUserId() %>">
                                View tasks &rarr;
                            </a>
                        </div>

                    </div>

                    <% } %>

                    <div class="workload-row unassigned">

                        <div>
                            <p class="workload-name">Unassigned</p>
                            <p class="workload-email">Tasks with nobody on them</p>
                        </div>

                        <div>
                            <p class="load-caption" style="margin-top: 0;">
                                <strong><%= unassigned.getOpen() %></strong> open
                                &middot; <%= unassigned.getCompleted() %> completed
                            </p>

                            <div class="load-chips">
                                <% if (unassigned.getOverdue() > 0) { %>
                                <span class="badge badge-overdue"><%= unassigned.getOverdue() %> overdue</span>
                                <% } %>
                                <% if (unassigned.getUrgent() > 0) { %>
                                <span class="badge badge-urgent"><%= unassigned.getUrgent() %> urgent</span>
                                <% } %>
                            </div>
                        </div>

                        <div class="workload-actions">
                            <a href="${pageContext.request.contextPath}/tasks?assignee=0">
                                View tasks &rarr;
                            </a>
                        </div>

                    </div>

                </div>

                <% } %>

            </div>

        </div>

    </main>

</div>

        </div>


    </main>

</div>


<!-- =====================================================
     PAGE SCRIPT
     ===================================================== -->

<script>

    (function () {

        "use strict";


        /* =================================================
           THEME + SIDEBAR
           ================================================= */

        const body =
            document.body;

        const themeToggle =
            document.getElementById("themeToggle");

        const sidebar =
            document.getElementById("sidebar");

        const sidebarToggle =
            document.getElementById("sidebarToggle");

        const sidebarOverlay =
            document.getElementById("sidebarOverlay");


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
                localStorage.getItem("pms-theme");


            if (
                storedTheme === "dark" ||
                storedTheme === "light"
            ) {

                savedTheme =
                    storedTheme;

            }

        } catch (error) {

            // Use light mode.

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
