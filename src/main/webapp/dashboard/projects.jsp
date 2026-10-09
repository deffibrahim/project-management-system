<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.pms.model.Project" %>
<%@ page import="com.pms.model.User" %>
<%@ page import="com.pms.util.HtmlUtil" %>

<%
    List<Project> projects = (List<Project>) request.getAttribute("projects");
    User user = (User) session.getAttribute("user");
    String role = user != null ? user.getRole() : "";

    String pageTitle = "Projects";
    String dashboardUrl = "/dashboard/team-member";
    String roleDisplay = "TEAM MEMBER";

    if ("PROJECT_MANAGER".equals(role)) {
        pageTitle = "My Projects";
        dashboardUrl = "/dashboard/project-manager";
        roleDisplay = "PROJECT MANAGER";
    } else if ("TEAM_MEMBER".equals(role)) {
        pageTitle = "Projects";
        dashboardUrl = "/dashboard/team-member";
        roleDisplay = "TEAM MEMBER";
    } else if ("ADMIN".equals(role)) {
        pageTitle = "All Projects";
        dashboardUrl = "/dashboard/admin";
        roleDisplay = "ADMIN";
    }

    int totalProjects = projects != null ? projects.size() : 0;

    int plannedProjects = 0;
    int activeProjects = 0;
    int completedProjects = 0;

    if (projects != null) {
        for (Project project : projects) {

            String status = project.getStatus();

            if ("PLANNED".equalsIgnoreCase(status)) {
                plannedProjects++;
            } else if ("ACTIVE".equalsIgnoreCase(status)) {
                activeProjects++;
            } else if ("COMPLETED".equalsIgnoreCase(status)) {
                completedProjects++;
            }
        }
    }
%>

<!DOCTYPE html>
<html lang="en">

<head>

    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title><%= HtmlUtil.escape(pageTitle) %></title>

    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/dashboard.css">


    <style>

        /* =====================================================
           PROJECTS PAGE
           ===================================================== */

        .projects-page {
            max-width: 1400px;
            margin: 0 auto;
        }


        /* =====================================================
           PAGE HEADING
           ===================================================== */

        .projects-heading {
            display: flex;

            align-items: flex-end;
            justify-content: space-between;

            gap: 20px;

            margin-bottom: 24px;
        }

        .projects-heading-text h1 {
            margin: 0 0 5px;

            font-size: 30px;
        }

        .projects-heading-text p {
            margin: 0;

            font-size: 14px;
        }

        .projects-heading-actions {
            display: flex;

            align-items: center;

            gap: 10px;
        }


        /* =====================================================
           SUMMARY CARDS
           ===================================================== */

        .project-summary {
            display: grid;

            grid-template-columns:
                repeat(4, minmax(0, 1fr));

            gap: 14px;

            margin-bottom: 24px;
        }

        .project-summary-card {
            position: relative;

            overflow: hidden;

            padding: 18px 19px;

            background: var(--surface);

            border: 1px solid var(--border);

            border-radius: var(--radius);

            box-shadow: var(--shadow);
        }

        .project-summary-card::before {
            content: "";

            position: absolute;

            top: 0;
            left: 0;

            width: 4px;
            height: 100%;

            background: var(--primary);
        }

        .project-summary-card.planned::before {
            background: var(--mustard);
        }

        .project-summary-card.active::before {
            background: var(--primary);
        }

        .project-summary-card.completed::before {
            background: var(--sage);
        }

        .project-summary-label {
            margin: 0 0 5px;

            color: var(--text-muted);

            font-size: 12px;
            font-weight: bold;

            text-transform: uppercase;

            letter-spacing: 0.4px;
        }

        .project-summary-number {
            margin: 0;

            color: var(--text);

            font-size: 28px;
            font-weight: bold;

            line-height: 1.2;
        }


        /* =====================================================
           PROJECT TOOLBAR
           ===================================================== */

        .project-toolbar {
            display: flex;

            align-items: center;
            justify-content: space-between;

            gap: 14px;

            margin-bottom: 18px;
        }

        .project-toolbar-left {
            display: flex;

            align-items: center;

            gap: 10px;

            flex: 1;
        }

        .project-search {
            width: 100%;
            max-width: 430px;

            padding: 11px 13px;

            border: 1px solid var(--border);

            border-radius: 8px;

            background: var(--surface);

            color: var(--text);

            font-size: 14px;

            outline: none;

            transition:
                border-color 0.2s ease,
                box-shadow 0.2s ease;
        }

        .project-search:focus {
            border-color: var(--primary);

            box-shadow:
                0 0 0 3px
                rgba(47, 127, 120, 0.11);
        }

        .project-search::placeholder {
            color: var(--text-light);
        }

        .project-filter {
            min-width: 165px;

            padding: 11px 12px;

            border: 1px solid var(--border);

            border-radius: 8px;

            background: var(--surface);

            color: var(--text);

            font-size: 14px;

            outline: none;

            cursor: pointer;
        }

        .project-filter:focus {
            border-color: var(--primary);
        }

        .project-results-count {
            color: var(--text-muted);

            font-size: 13px;

            white-space: nowrap;
        }


        /* =====================================================
           PROJECT GRID
           ===================================================== */

        .projects-grid {
            display: grid;

            grid-template-columns:
                repeat(3, minmax(0, 1fr));

            gap: 17px;
        }


        /* =====================================================
           PROJECT CARD
           ===================================================== */

        .project-card {
            display: flex;

            flex-direction: column;

            min-height: 285px;

            padding: 20px;

            background: var(--surface);

            border: 1px solid var(--border);

            border-radius: var(--radius);

            box-shadow: var(--shadow);

            transition:
                transform 0.18s ease,
                box-shadow 0.18s ease,
                border-color 0.18s ease;
        }

        .project-card:hover {
            transform: translateY(-2px);

            box-shadow: var(--shadow-hover);

            border-color: #cfc9bd;
        }

        .project-card.hidden {
            display: none;
        }


        /* =====================================================
           CARD TOP
           ===================================================== */

        .project-card-top {
            display: flex;

            align-items: flex-start;
            justify-content: space-between;

            gap: 12px;

            margin-bottom: 15px;
        }

        .project-number {
            display: inline-flex;

            align-items: center;

            padding: 5px 8px;

            border-radius: 6px;

            background: var(--surface-soft);

            color: var(--text-muted);

            font-size: 10px;

            font-weight: bold;
        }


        /* =====================================================
           PROJECT TITLE
           ===================================================== */

        .project-title {
            margin: 0 0 6px;

            color: var(--text);

            font-size: 18px;

            line-height: 1.3;

            word-break: break-word;
        }

        .project-description {
            margin: 0;

            min-height: 40px;

            color: var(--text-muted);

            font-size: 13px;

            line-height: 1.5;

            display: -webkit-box;

            -webkit-line-clamp: 2;
            -webkit-box-orient: vertical;

            overflow: hidden;
        }


        /* =====================================================
           STATUS BADGES
           ===================================================== */

        .project-status {
            display: inline-flex;

            align-items: center;

            padding: 5px 9px;

            border-radius: 20px;

            font-size: 10px;

            font-weight: bold;

            white-space: nowrap;
        }

        .project-status-planned {
            background: var(--mustard-soft);

            color: #80601c;
        }

        .project-status-active {
            background: var(--primary-soft);

            color: var(--primary);
        }

        .project-status-completed {
            background: var(--sage-soft);

            color: #4d7048;
        }

        .project-status-default {
            background: var(--surface-soft);

            color: var(--text-muted);
        }


        /* =====================================================
           PROJECT DETAILS
           ===================================================== */

        .project-details {
            display: grid;

            grid-template-columns:
                1fr 1fr;

            gap: 10px;

            margin-top: 19px;

            padding-top: 15px;

            border-top: 1px solid var(--border-light);
        }

        .project-detail {
            min-width: 0;
        }

        .project-detail-label {
            margin: 0 0 4px;

            color: var(--text-light);

            font-size: 10px;

            font-weight: bold;

            text-transform: uppercase;

            letter-spacing: 0.4px;
        }

        .project-detail-value {
            margin: 0;

            color: var(--text);

            font-size: 12px;

            word-break: break-word;
        }


        /* =====================================================
           PROJECT ACTIONS
           ===================================================== */

        .project-actions {
            display: flex;

            align-items: stretch;

            gap: 8px;

            margin-top: auto;

            padding-top: 18px;
        }

        .project-edit {
            flex: 1;

            display: inline-flex;

            align-items: center;
            justify-content: center;

            padding: 9px 12px;

            border-radius: 7px;

            background: var(--primary);

            color: #ffffff;

            text-decoration: none;

            font-size: 12px;

            font-weight: bold;

            transition:
                background-color 0.2s ease,
                transform 0.15s ease;
        }

        .project-edit:hover {
            background: var(--primary-hover);

            color: #ffffff;

            transform: translateY(-1px);
        }

        .project-delete {
            padding: 9px 12px;

            border: none;

            border-radius: 7px;

            background: var(--danger-soft);

            color: var(--danger);

            font-size: 12px;

            font-weight: bold;

            cursor: pointer;

            transition:
                background-color 0.2s ease,
                color 0.2s ease;
        }

        .project-delete:hover {
            background: var(--danger);

            color: #ffffff;
        }

        .project-view-only {
            width: 100%;

            display: flex;

            align-items: center;
            justify-content: center;

            padding: 9px 12px;

            border-radius: 7px;

            background: var(--surface-soft);

            color: var(--text-muted);

            font-size: 12px;

            font-weight: bold;
        }


        /* =====================================================
           EMPTY STATES
           ===================================================== */

        .projects-empty {
            display: flex;

            flex-direction: column;

            align-items: center;
            justify-content: center;

            min-height: 280px;

            padding: 35px;

            background: var(--surface);

            border: 1px dashed var(--border);

            border-radius: var(--radius);

            text-align: center;
        }

        .projects-empty-icon {
            width: 56px;
            height: 56px;

            display: flex;

            align-items: center;
            justify-content: center;

            margin-bottom: 13px;

            border-radius: 16px;

            background: var(--primary-soft);

            color: var(--primary);

            font-size: 24px;
        }

        .projects-empty h3 {
            margin: 0 0 6px;

            font-size: 17px;
        }

        .projects-empty p {
            margin: 0;

            max-width: 420px;

            font-size: 13px;
        }

        .no-project-results {
            display: none;

            padding: 35px;

            background: var(--surface);

            border: 1px dashed var(--border);

            border-radius: var(--radius);

            text-align: center;
        }

        .no-project-results.visible {
            display: block;
        }

        .no-project-results h3 {
            margin: 0 0 6px;

            font-size: 17px;
        }

        .no-project-results p {
            margin: 0;

            font-size: 13px;
        }


        /* =====================================================
           RESPONSIVE
           ===================================================== */

        @media (max-width: 1100px) {

            .projects-grid {
                grid-template-columns:
                    repeat(2, minmax(0, 1fr));
            }

        }


        @media (max-width: 900px) {

            .project-summary {
                grid-template-columns:
                    repeat(2, minmax(0, 1fr));
            }

            .project-toolbar {
                align-items: stretch;

                flex-direction: column;
            }

            .project-toolbar-left {
                align-items: stretch;

                flex-direction: column;
            }

            .project-search {
                max-width: none;
            }

            .project-filter {
                width: 100%;
            }

            .project-results-count {
                text-align: left;
            }

        }


        @media (max-width: 700px) {

            .projects-heading {
                align-items: flex-start;

                flex-direction: column;
            }

            .projects-heading-actions {
                width: 100%;
            }

            .projects-heading-actions .btn {
                width: 100%;

                justify-content: center;
            }

            .projects-grid {
                grid-template-columns: 1fr;
            }

        }


        @media (max-width: 480px) {

            .project-summary {
                grid-template-columns: 1fr 1fr;

                gap: 10px;
            }

            .project-summary-card {
                padding: 15px;
            }

            .project-summary-number {
                font-size: 24px;
            }

            .project-card {
                padding: 17px;
            }

            .project-details {
                grid-template-columns: 1fr;
            }

        }


        @media (max-width: 360px) {

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


            <% if (!"TEAM_MEMBER".equals(role)) { %>
            <a href="${pageContext.request.contextPath}/workload"
               class="sidebar-link">

                <span class="sidebar-icon">
                    &#128202;
                </span>

                Workload

            </a>
            <% } %>



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

        <% if (!"ADMIN".equals(role)) { %>

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

        <% } %>




        <div class="sidebar-bottom">


            <div class="sidebar-user">

                <p class="sidebar-user-name">

                    <%= user != null
                            ? HtmlUtil.escape(user.getName())
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
                        <%= HtmlUtil.escape(pageTitle) %>
                    </h1>

                    <p>
                        Manage and view your workspace projects.
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


            <div class="projects-page">


                <!-- =================================================
                     PAGE HEADING
                     ================================================= -->

                <div class="projects-heading">


                    <div class="projects-heading-text">

                        <h1>
                            <%= HtmlUtil.escape(pageTitle) %>
                        </h1>

                        <p>
                            Keep track of your projects, deadlines,
                            managers and current status.
                        </p>

                    </div>


                    <% if (
                            "ADMIN".equals(role) ||
                            "PROJECT_MANAGER".equals(role)
                    ) { %>


                        <div class="projects-heading-actions">

                            <a href="${pageContext.request.contextPath}/projects/create"
                               class="btn btn-primary">

                                + Create Project

                            </a>

                        </div>


                    <% } %>


                </div>


                <!-- =================================================
                     SUMMARY
                     ================================================= -->

                <div class="project-summary">


                    <div class="project-summary-card">

                        <p class="project-summary-label">
                            Total Projects
                        </p>

                        <p class="project-summary-number">
                            <%= totalProjects %>
                        </p>

                    </div>


                    <div class="project-summary-card planned">

                        <p class="project-summary-label">
                            Planned
                        </p>

                        <p class="project-summary-number">
                            <%= plannedProjects %>
                        </p>

                    </div>


                    <div class="project-summary-card active">

                        <p class="project-summary-label">
                            Active
                        </p>

                        <p class="project-summary-number">
                            <%= activeProjects %>
                        </p>

                    </div>


                    <div class="project-summary-card completed">

                        <p class="project-summary-label">
                            Completed
                        </p>

                        <p class="project-summary-number">
                            <%= completedProjects %>
                        </p>

                    </div>


                </div>


                <!-- =================================================
                     SEARCH + FILTER
                     ================================================= -->

                <div class="project-toolbar">


                    <div class="project-toolbar-left">


                        <input type="text"
                               id="projectSearch"
                               class="project-search"
                               placeholder="Search projects by title or description...">


                        <select id="projectFilter"
                                class="project-filter">

                            <option value="ALL">
                                All Statuses
                            </option>

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


                    </div>


                    <div class="project-results-count"
                         id="projectResultsCount">

                        <%= totalProjects %>
                        <%= totalProjects == 1
                                ? "project"
                                : "projects" %>

                    </div>


                </div>


                <!-- =================================================
                     PROJECTS
                     ================================================= -->

                <% if (projects == null || projects.isEmpty()) { %>


                    <div class="projects-empty">


                        <div class="projects-empty-icon">
                            &#128193;
                        </div>


                        <h3>
                            No projects found
                        </h3>


                        <p>
                            There are currently no projects available
                            for your account.
                        </p>


                    </div>


                <% } else { %>


                    <div class="projects-grid"
                         id="projectsGrid">


                        <% for (Project project : projects) {


                            String pStatus =
                                    project.getStatus() != null
                                            ? project.getStatus()
                                            : "";


                            String normalizedStatus =
                                    pStatus.toUpperCase();


                            String statusClass =
                                    "project-status-default";


                            if ("PLANNED".equals(normalizedStatus)) {

                                statusClass =
                                        "project-status-planned";

                            } else if (
                                    "ACTIVE".equals(normalizedStatus)
                            ) {

                                statusClass =
                                        "project-status-active";

                            } else if (
                                    "COMPLETED".equals(normalizedStatus)
                            ) {

                                statusClass =
                                        "project-status-completed";

                            }


                            String description =
                                    project.getDescription();


                            if (
                                    description == null ||
                                    description.trim().isEmpty()
                            ) {

                                description =
                                        "No description provided.";

                            }


                            String startDate =
                                    project.getStartDate() == null
                                            ? "-"
                                            : project.getStartDate()
                                                    .toString();


                            String endDate =
                                    project.getEndDate() == null
                                            ? "-"
                                            : project.getEndDate()
                                                    .toString();


                            String manager =
                                    project.getManagerId() > 0
                                            ? String.valueOf(
                                                    project.getManagerId()
                                              )
                                            : "None";

                        %>


                            <article class="project-card"
                                     data-title="<%= HtmlUtil.escape(
                                             project.getTitle()
                                                     .toLowerCase()
                                     ) %>"
                                     data-description="<%= HtmlUtil.escape(
                                             description
                                                     .toLowerCase()
                                     ) %>"
                                     data-status="<%= normalizedStatus %>">


                                <!-- ===============================
                                     CARD TOP
                                     =============================== -->

                                <div class="project-card-top">


                                    <span class="project-number">

                                        PROJECT #<%= project.getProjectId() %>

                                    </span>


                                    <span class="project-status <%= statusClass %>">

                                        <%= HtmlUtil.escape(pStatus) %>

                                    </span>


                                </div>


                                <!-- ===============================
                                     TITLE
                                     =============================== -->

                                <h2 class="project-title">

                                    <%= HtmlUtil.escape(
                                            project.getTitle()
                                    ) %>

                                </h2>


                                <p class="project-description">

                                    <%= HtmlUtil.escape(
                                            description
                                    ) %>

                                </p>


                                <!-- ===============================
                                     DETAILS
                                     =============================== -->

                                <div class="project-details">


                                    <div class="project-detail">

                                        <p class="project-detail-label">
                                            Start Date
                                        </p>

                                        <p class="project-detail-value">
                                            <%= startDate %>
                                        </p>

                                    </div>


                                    <div class="project-detail">

                                        <p class="project-detail-label">
                                            End Date
                                        </p>

                                        <p class="project-detail-value">
                                            <%= endDate %>
                                        </p>

                                    </div>


                                    <div class="project-detail">

                                        <p class="project-detail-label">
                                            Manager ID
                                        </p>

                                        <p class="project-detail-value">
                                            <%= manager %>
                                        </p>

                                    </div>


                                    <div class="project-detail">

                                        <p class="project-detail-label">
                                            Status
                                        </p>

                                        <p class="project-detail-value">
                                            <%= HtmlUtil.escape(pStatus) %>
                                        </p>

                                    </div>


                                </div>


                                <!-- ===============================
                                     ACTIONS
                                     =============================== -->

                                <div class="project-actions">


                                    <% if ("ADMIN".equals(role)) { %>


                                        <a class="project-edit"
                                           href="${pageContext.request.contextPath}/projects/edit?id=<%= project.getProjectId() %>">

                                            Edit Project

                                        </a>


                                        <form action="${pageContext.request.contextPath}/projects/delete"
                                              method="post"
                                              style="display: contents;"
                                              onsubmit="return confirm('Are you sure you want to delete this project?');">


                                            <input type="hidden"
                                                   name="csrfToken"
                                                   value="${sessionScope.csrfToken}">


                                            <input type="hidden"
                                                   name="id"
                                                   value="<%= project.getProjectId() %>">


                                            <button class="project-delete"
                                                    type="submit">

                                                Delete

                                            </button>


                                        </form>


                                    <% } else if (
                                            "PROJECT_MANAGER".equals(role)
                                    ) { %>


                                        <a class="project-edit"
                                           href="${pageContext.request.contextPath}/projects/edit?id=<%= project.getProjectId() %>">

                                            Edit Project

                                        </a>


                                    <% } else if (
                                            "TEAM_MEMBER".equals(role)
                                    ) { %>


                                        <span class="project-view-only">

                                            View Only

                                        </span>


                                    <% } %>


                                </div>


                            </article>


                        <% } %>


                    </div>


                    <!-- =================================================
                         SEARCH EMPTY STATE
                         ================================================= -->

                    <div class="no-project-results"
                         id="noProjectResults">


                        <h3>
                            No matching projects
                        </h3>


                        <p>
                            Try changing your search or status filter.
                        </p>


                    </div>


                <% } %>


                <!-- =================================================
                     BACK
                     ================================================= -->

                <div style="margin-top: 22px;">

                    <a class="back-link"
                       href="${pageContext.request.contextPath}<%= dashboardUrl %>">

                        ← Back to Dashboard

                    </a>

                </div>


            </div>


        </div>


    </main>


</div>


<!-- =====================================================
     THEME + SIDEBAR + PROJECT FILTER SCRIPT
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
           PROJECT SEARCH + FILTER
           ================================================= */

        const searchInput =
            document.getElementById(
                "projectSearch"
            );

        const statusFilter =
            document.getElementById(
                "projectFilter"
            );

        const projectCards =
            document.querySelectorAll(
                ".project-card"
            );

        const resultCount =
            document.getElementById(
                "projectResultsCount"
            );

        const noResults =
            document.getElementById(
                "noProjectResults"
            );


        function filterProjects() {

            const searchValue =
                searchInput
                    ? searchInput.value
                        .trim()
                        .toLowerCase()
                    : "";


            const selectedStatus =
                statusFilter
                    ? statusFilter.value
                    : "ALL";


            let visibleCount =
                0;


            projectCards.forEach(
                function (card) {

                    const title =
                        card.dataset.title
                            || "";

                    const description =
                        card.dataset.description
                            || "";

                    const status =
                        card.dataset.status
                            || "";


                    const matchesSearch =
                        title.includes(
                            searchValue
                        ) ||
                        description.includes(
                            searchValue
                        );


                    const matchesStatus =
                        selectedStatus === "ALL" ||
                        status === selectedStatus;


                    if (
                        matchesSearch &&
                        matchesStatus
                    ) {

                        card.classList.remove(
                            "hidden"
                        );

                        visibleCount++;

                    } else {

                        card.classList.add(
                            "hidden"
                        );

                    }

                }
            );


            if (resultCount) {

                resultCount.textContent =
                    visibleCount +
                    (
                        visibleCount === 1
                            ? " project"
                            : " projects"
                    );

            }


            if (noResults) {

                if (
                    visibleCount === 0
                ) {

                    noResults.classList.add(
                        "visible"
                    );

                } else {

                    noResults.classList.remove(
                        "visible"
                    );

                }

            }

        }


        if (searchInput) {

            searchInput.addEventListener(
                "input",
                filterProjects
            );

        }


        if (statusFilter) {

            statusFilter.addEventListener(
                "change",
                filterProjects
            );

        }


    })();

</script>


</body>

</html>