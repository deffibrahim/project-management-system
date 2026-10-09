<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    /*
     * Admin dashboard statistics are loaded by AdminDashboardServlet.
     * Direct access to this JSP is redirected through the servlet.
     */
    if (request.getAttribute("totalUsers") == null) {
        response.sendRedirect(
                request.getContextPath() + "/dashboard/admin"
        );
        return;
    }

    Integer totalUsers = (Integer) request.getAttribute("totalUsers");
    Integer totalAdmins = (Integer) request.getAttribute("totalAdmins");
    Integer totalProjectManagers = (Integer) request.getAttribute("totalProjectManagers");
    Integer totalTeamMembers = (Integer) request.getAttribute("totalTeamMembers");

    Integer totalProjects = (Integer) request.getAttribute("totalProjects");
    Integer totalPlannedProjects = (Integer) request.getAttribute("totalPlannedProjects");
    Integer totalActiveProjects = (Integer) request.getAttribute("totalActiveProjects");
    Integer totalCompletedProjects = (Integer) request.getAttribute("totalCompletedProjects");

    Integer totalTasks = (Integer) request.getAttribute("totalTasks");
    Integer totalPendingTasks = (Integer) request.getAttribute("totalPendingTasks");
    Integer totalInProgressTasks = (Integer) request.getAttribute("totalInProgressTasks");
    Integer totalCompletedTasks = (Integer) request.getAttribute("totalCompletedTasks");

    String contextPath = request.getContextPath();
%>

<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>Admin Dashboard | Project Management Tool</title>

    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/dashboard.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/ui-polish.css">

</head>

<body>

<div class="app-layout">

    <!-- =================================================
         MOBILE SIDEBAR OVERLAY
         ================================================= -->

    <div class="sidebar-overlay" id="sidebarOverlay"></div>


    <!-- =================================================
         SIDEBAR
         ================================================= -->

    <aside class="sidebar" id="sidebar">

        <!-- Brand -->

        <div class="sidebar-brand">

            <div class="brand-mark">P</div>

            <div>
                <p class="brand-name">Project Management</p>
                <p class="brand-subtitle">Workspace</p>
            </div>

        </div>


        <!-- Workspace navigation -->

        <p class="sidebar-label">Workspace</p>

        <nav class="sidebar-nav">

            <a href="${pageContext.request.contextPath}/dashboard/admin"
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
            <a href="${pageContext.request.contextPath}/kanban" class="sidebar-link">
                <span class="sidebar-icon">&#9638;</span>
                Kanban board
            </a>

            <a href="${pageContext.request.contextPath}/deadlines" class="sidebar-link">
                <span class="sidebar-icon">&#9200;</span>
                Due-date alerts
            </a>


            <a href="${pageContext.request.contextPath}/workload"
               class="sidebar-link">

                <span class="sidebar-icon">
                    &#128202;
                </span>

                Workload

            </a>


        </nav>


        <!-- Administration navigation -->

        <p class="sidebar-label">
            Administration
        </p>

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


        <!-- Sidebar bottom -->

        <div class="sidebar-bottom">

            <div class="sidebar-user">

                <p class="sidebar-user-name">
                    Administrator
                </p>

                <p class="sidebar-user-role">
                    ADMIN
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
             TOP BAR
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

                    <h1>Admin Dashboard</h1>

                    <p>
                        Here's what's happening in your workspace.
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


            <!-- =================================================
                 MAIN STATISTICS
                 ================================================= -->

            <section class="stats-grid">


                <div class="stat-card purple">

                    <h3>Total Users</h3>

                    <div class="stat-number">
                        <%= totalUsers %>
                    </div>

                </div>


                <div class="stat-card">

                    <h3>Total Projects</h3>

                    <div class="stat-number">
                        <%= totalProjects %>
                    </div>

                </div>


                <div class="stat-card warning">

                    <h3>Total Tasks</h3>

                    <div class="stat-number">
                        <%= totalTasks %>
                    </div>

                </div>


            </section>

            <!-- =================================================
                 PROGRESS METERS & STATISTICS
                 ================================================= -->
            <%
                int taskCompletionRate = totalTasks > 0 ? (totalCompletedTasks * 100 / totalTasks) : 0;
                int taskInProgressRate = totalTasks > 0 ? (totalInProgressTasks * 100 / totalTasks) : 0;
                int taskPendingRate = totalTasks > 0 ? (100 - taskCompletionRate - taskInProgressRate) : 0;

                int projCompletionRate = totalProjects > 0 ? (totalCompletedProjects * 100 / totalProjects) : 0;
                int projActiveRate = totalProjects > 0 ? (totalActiveProjects * 100 / totalProjects) : 0;
                int projPlannedRate = totalProjects > 0 ? (100 - projCompletionRate - projActiveRate) : 0;
            %>

            <div class="progress-meter-card">
                <div class="meter-header">
                    <div class="meter-title">
                        <span>📊 Workspace Task Velocity & Completion</span>
                    </div>
                    <div class="meter-percent-badge">
                        <%= taskCompletionRate %>% Completed
                    </div>
                </div>
                <div class="meter-bar">
                    <div class="meter-segment completed" style="width: <%= taskCompletionRate %>%;" title="Completed: <%= totalCompletedTasks %>"></div>
                    <div class="meter-segment in-progress" style="width: <%= taskInProgressRate %>%;" title="In Progress: <%= totalInProgressTasks %>"></div>
                    <div class="meter-segment pending" style="width: <%= taskPendingRate %>%;" title="Pending: <%= totalPendingTasks %>"></div>
                </div>
                <div class="meter-legend">
                    <div class="meter-legend-item">
                        <span class="meter-dot completed"></span>
                        <span>Completed: <strong><%= totalCompletedTasks %></strong></span>
                    </div>
                    <div class="meter-legend-item">
                        <span class="meter-dot in-progress"></span>
                        <span>In Progress: <strong><%= totalInProgressTasks %></strong></span>
                    </div>
                    <div class="meter-legend-item">
                        <span class="meter-dot pending"></span>
                        <span>Pending: <strong><%= totalPendingTasks %></strong></span>
                    </div>
                </div>
            </div>

            <div class="progress-meter-card">
                <div class="meter-header">
                    <div class="meter-title">
                        <span>📁 Project Delivery Pipeline</span>
                    </div>
                    <div class="meter-percent-badge">
                        <%= projCompletionRate %>% Delivered
                    </div>
                </div>
                <div class="meter-bar">
                    <div class="meter-segment completed" style="width: <%= projCompletionRate %>%;" title="Completed: <%= totalCompletedProjects %>"></div>
                    <div class="meter-segment in-progress" style="width: <%= projActiveRate %>%;" title="Active: <%= totalActiveProjects %>"></div>
                    <div class="meter-segment pending" style="width: <%= projPlannedRate %>%;" title="Planned: <%= totalPlannedProjects %>"></div>
                </div>
                <div class="meter-legend">
                    <div class="meter-legend-item">
                        <span class="meter-dot completed"></span>
                        <span>Delivered: <strong><%= totalCompletedProjects %></strong></span>
                    </div>
                    <div class="meter-legend-item">
                        <span class="meter-dot in-progress"></span>
                        <span>Active: <strong><%= totalActiveProjects %></strong></span>
                    </div>
                    <div class="meter-legend-item">
                        <span class="meter-dot pending"></span>
                        <span>Planned: <strong><%= totalPlannedProjects %></strong></span>
                    </div>
                </div>
            </div>


            <!-- =================================================
                 QUICK MANAGEMENT
                 ================================================= -->

            <section class="section">

                <h2>Quick Management</h2>

                <p style="margin-top: -10px; margin-bottom: 18px;">
                    Manage the main parts of your workspace.
                </p>


                <div class="management-grid">

                    <a class="management-link"
                       href="${pageContext.request.contextPath}/projects">

                        &#128193; Projects

                    </a>


                    <a class="management-link"
                       href="${pageContext.request.contextPath}/tasks">

                        &#9745; Tasks

                    </a>


                    <a class="management-link"
                       href="${pageContext.request.contextPath}/users">

                        &#128101; Users

                    </a>


                    <a class="management-link"
                       href="${pageContext.request.contextPath}/settings">

                        &#9881; Settings

                    </a>


                    <a class="management-link"
                       href="${pageContext.request.contextPath}/projects/create">

                        + Create Project

                    </a>


                    <a class="management-link"
                       href="${pageContext.request.contextPath}/tasks/create">

                        + Create Task

                    </a>

                </div>

            </section>


            <!-- =================================================
                 WORKSPACE OVERVIEW
                 ================================================= -->

            <section class="section">

                <h2>Workspace Overview</h2>

                <div class="breakdown-grid">


                    <!-- User overview -->

                    <div class="breakdown-card">

                        <h3>Users</h3>

                        <ul>

                            <li>
                                <span>Administrators</span>
                                <strong><%= totalAdmins %></strong>
                            </li>

                            <li>
                                <span>Project Managers</span>
                                <strong><%= totalProjectManagers %></strong>
                            </li>

                            <li>
                                <span>Team Members</span>
                                <strong><%= totalTeamMembers %></strong>
                            </li>

                        </ul>

                    </div>


                    <!-- Project overview -->

                    <div class="breakdown-card">

                        <h3>Projects</h3>

                        <ul>

                            <li>
                                <span>Planned</span>
                                <strong><%= totalPlannedProjects %></strong>
                            </li>

                            <li>
                                <span>Active</span>
                                <strong><%= totalActiveProjects %></strong>
                            </li>

                            <li>
                                <span>Completed</span>
                                <strong><%= totalCompletedProjects %></strong>
                            </li>

                        </ul>

                    </div>


                    <!-- Task overview -->

                    <div class="breakdown-card">

                        <h3>Tasks</h3>

                        <ul>

                            <li>
                                <span>Pending</span>
                                <strong><%= totalPendingTasks %></strong>
                            </li>

                            <li>
                                <span>In Progress</span>
                                <strong><%= totalInProgressTasks %></strong>
                            </li>

                            <li>
                                <span>Completed</span>
                                <strong><%= totalCompletedTasks %></strong>
                            </li>

                        </ul>

                    </div>


                </div>

            </section>


        </div>

    </main>

</div>


<!-- =================================================
     THEME + SIDEBAR SCRIPT
     ================================================= -->

<script>

    (function () {

        "use strict";


        const body = document.body;

        const themeToggle =
            document.getElementById("themeToggle");

        const sidebar =
            document.getElementById("sidebar");

        const sidebarToggle =
            document.getElementById("sidebarToggle");

        const sidebarOverlay =
            document.getElementById("sidebarOverlay");


        /* =================================================
           THEME
           ================================================= */

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

            /*
             * If browser storage is unavailable,
             * light mode will be used.
             */

        }


        applyTheme(savedTheme);


        if (themeToggle) {

            themeToggle.addEventListener(
                "click",
                function () {

                    const currentTheme =
                        body.getAttribute("data-theme")
                        || "light";


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

                        /*
                         * Theme still works for
                         * the current page.
                         */

                    }

                }
            );

        }


        /* =================================================
           MOBILE SIDEBAR
           ================================================= */

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

            sidebarToggle.addEventListener(
                "click",
                function () {

                    if (
                        sidebar.classList.contains("open")
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


    })();

</script>


</body>

</html>