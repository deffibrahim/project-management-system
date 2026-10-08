<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.pms.model.Task" %>
<%@ page import="com.pms.model.User" %>
<%@ page import="com.pms.util.HtmlUtil" %>
<%@ page import="com.pms.util.TaskUi" %>

<%
    List<Task> tasks = (List<Task>) request.getAttribute("tasks");
    User user = (User) session.getAttribute("user");
    String role = user != null ? user.getRole() : "";

    String pageTitle = "Tasks";
    String dashboardUrl = "/dashboard/team-member";
    String roleDisplay = "TEAM MEMBER";

    if ("ADMIN".equals(role)) {
        pageTitle = "All Tasks";
        dashboardUrl = "/dashboard/admin";
        roleDisplay = "ADMIN";
    } else if ("PROJECT_MANAGER".equals(role)) {
        pageTitle = "Project Tasks";
        dashboardUrl = "/dashboard/project-manager";
        roleDisplay = "PROJECT MANAGER";
    } else if ("TEAM_MEMBER".equals(role)) {
        pageTitle = "My Tasks";
        dashboardUrl = "/dashboard/team-member";
        roleDisplay = "TEAM MEMBER";
    }

    int totalTasks = tasks != null ? tasks.size() : 0;

    int pendingTasks = 0;
    int inProgressTasks = 0;
    int completedTasks = 0;

    if (tasks != null) {
        for (Task task : tasks) {

            String status = task.getStatus();

            if ("PENDING".equalsIgnoreCase(status)) {
                pendingTasks++;
            } else if ("IN_PROGRESS".equalsIgnoreCase(status)) {
                inProgressTasks++;
            } else if ("COMPLETED".equalsIgnoreCase(status)) {
                completedTasks++;
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
           TASKS PAGE
           ===================================================== */

        .tasks-page {
            max-width: 1400px;
            margin: 0 auto;
        }


        /* =====================================================
           PAGE HEADING
           ===================================================== */

        .tasks-heading {
            display: flex;

            align-items: flex-end;
            justify-content: space-between;

            gap: 20px;

            margin-bottom: 24px;
        }

        .tasks-heading-text h1 {
            margin: 0 0 5px;

            font-size: 30px;
        }

        .tasks-heading-text p {
            margin: 0;

            font-size: 14px;
        }

        .tasks-heading-actions {
            display: flex;

            align-items: center;

            gap: 10px;
        }


        /* =====================================================
           SUMMARY CARDS
           ===================================================== */

        .task-summary {
            display: grid;

            grid-template-columns:
                repeat(4, minmax(0, 1fr));

            gap: 14px;

            margin-bottom: 24px;
        }

        .task-summary-card {
            position: relative;

            overflow: hidden;

            padding: 18px 19px;

            background: var(--surface);

            border: 1px solid var(--border);

            border-radius: var(--radius);

            box-shadow: var(--shadow);
        }

        .task-summary-card::before {
            content: "";

            position: absolute;

            top: 0;
            left: 0;

            width: 4px;
            height: 100%;

            background: var(--primary);
        }

        .task-summary-card.pending::before {
            background: var(--mustard);
        }

        .task-summary-card.progress::before {
            background: var(--primary);
        }

        .task-summary-card.completed::before {
            background: var(--sage);
        }

        .task-summary-label {
            margin: 0 0 5px;

            color: var(--text-muted);

            font-size: 12px;
            font-weight: bold;

            text-transform: uppercase;

            letter-spacing: 0.4px;
        }

        .task-summary-number {
            margin: 0;

            color: var(--text);

            font-size: 28px;
            font-weight: bold;

            line-height: 1.2;
        }


        /* =====================================================
           TOOLBAR
           ===================================================== */

        .task-toolbar {
            display: flex;

            align-items: center;
            justify-content: space-between;

            gap: 14px;

            margin-bottom: 18px;
        }

        .task-toolbar-left {
            display: flex;

            align-items: center;

            gap: 10px;

            flex: 1;
        }

        .task-search {
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

        .task-search:focus {
            border-color: var(--primary);

            box-shadow:
                0 0 0 3px
                rgba(47, 127, 120, 0.11);
        }

        .task-search::placeholder {
            color: var(--text-light);
        }

        .task-filter {
            min-width: 170px;

            padding: 11px 12px;

            border: 1px solid var(--border);

            border-radius: 8px;

            background: var(--surface);

            color: var(--text);

            font-size: 14px;

            outline: none;

            cursor: pointer;
        }

        .task-filter:focus {
            border-color: var(--primary);
        }

        .task-results-count {
            color: var(--text-muted);

            font-size: 13px;

            white-space: nowrap;
        }


        /* =====================================================
           TASK GRID
           ===================================================== */

        .tasks-grid {
            display: grid;

            grid-template-columns:
                repeat(3, minmax(0, 1fr));

            gap: 17px;
        }


        /* =====================================================
           TASK CARD
           ===================================================== */

        .task-card {
            display: flex;

            flex-direction: column;

            min-height: 280px;

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

        .task-card:hover {
            transform: translateY(-2px);

            box-shadow: var(--shadow-hover);

            border-color: #cfc9bd;
        }

        .task-card.hidden {
            display: none;
        }


        /* =====================================================
           TASK TOP
           ===================================================== */

        .task-card-top {
            display: flex;

            align-items: flex-start;
            justify-content: space-between;

            gap: 12px;

            margin-bottom: 15px;
        }

        .task-number {
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
           STATUS
           ===================================================== */

        .task-status {
            display: inline-flex;

            align-items: center;

            padding: 5px 9px;

            border-radius: 20px;

            font-size: 10px;

            font-weight: bold;

            white-space: nowrap;
        }

        .task-status-pending {
            background: var(--mustard-soft);

            color: #80601c;
        }

        .task-status-in-progress {
            background: var(--primary-soft);

            color: var(--primary);
        }

        .task-status-completed {
            background: var(--sage-soft);

            color: #4d7048;
        }

        .task-status-default {
            background: var(--surface-soft);

            color: var(--text-muted);
        }


        /* =====================================================
           TASK TITLE
           ===================================================== */

        .task-title {
            margin: 0 0 6px;

            color: var(--text);

            font-size: 18px;

            line-height: 1.3;

            word-break: break-word;
        }

        .task-description {
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
           TASK DETAILS
           ===================================================== */

        .task-details {
            display: grid;

            grid-template-columns:
                1fr 1fr;

            gap: 10px;

            margin-top: 19px;

            padding-top: 15px;

            border-top: 1px solid var(--border-light);
        }

        .task-detail {
            min-width: 0;
        }

        .task-detail-label {
            margin: 0 0 4px;

            color: var(--text-light);

            font-size: 10px;

            font-weight: bold;

            text-transform: uppercase;

            letter-spacing: 0.4px;
        }

        .task-detail-value {
            margin: 0;

            color: var(--text);

            font-size: 12px;

            word-break: break-word;
        }


        /* =====================================================
           TASK ACTIONS
           ===================================================== */

        .task-actions {
            display: flex;

            align-items: stretch;

            gap: 8px;

            margin-top: auto;

            padding-top: 18px;
        }

        .task-edit {
            width: 100%;

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

        .task-edit:hover {
            background: var(--primary-hover);

            color: #ffffff;

            transform: translateY(-1px);
        }

        .task-delete {
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

        .task-delete:hover {
            background: var(--danger);

            color: #ffffff;
        }


        /* =====================================================
           EMPTY STATES
           ===================================================== */

        .tasks-empty {
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

        .tasks-empty-icon {
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

        .tasks-empty h3 {
            margin: 0 0 6px;

            font-size: 17px;
        }

        .tasks-empty p {
            margin: 0;

            max-width: 420px;

            font-size: 13px;
        }

        .no-task-results {
            display: none;

            padding: 35px;

            background: var(--surface);

            border: 1px dashed var(--border);

            border-radius: var(--radius);

            text-align: center;
        }

        .no-task-results.visible {
            display: block;
        }

        .no-task-results h3 {
            margin: 0 0 6px;

            font-size: 17px;
        }

        .no-task-results p {
            margin: 0;

            font-size: 13px;
        }


        /* =====================================================
           RESPONSIVE
           ===================================================== */

        @media (max-width: 1100px) {

            .tasks-grid {
                grid-template-columns:
                    repeat(2, minmax(0, 1fr));
            }

        }


        @media (max-width: 900px) {

            .task-summary {
                grid-template-columns:
                    repeat(2, minmax(0, 1fr));
            }

            .task-toolbar {
                align-items: stretch;

                flex-direction: column;
            }

            .task-toolbar-left {
                align-items: stretch;

                flex-direction: column;
            }

            .task-search {
                max-width: none;
            }

            .task-filter {
                width: 100%;
            }

            .task-results-count {
                text-align: left;
            }

        }


        @media (max-width: 700px) {

            .tasks-heading {
                align-items: flex-start;

                flex-direction: column;
            }

            .tasks-heading-actions {
                width: 100%;
            }

            .tasks-heading-actions .btn {
                width: 100%;

                justify-content: center;
            }

            .tasks-grid {
                grid-template-columns: 1fr;
            }

        }


        @media (max-width: 480px) {

            .task-summary {
                grid-template-columns: 1fr 1fr;

                gap: 10px;
            }

            .task-summary-card {
                padding: 15px;
            }

            .task-summary-number {
                font-size: 24px;
            }

            .task-card {
                padding: 17px;
            }

            .task-details {
                grid-template-columns: 1fr;
            }

        }


        @media (max-width: 360px) {

            .task-summary {
                grid-template-columns: 1fr;
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
                        <%= HtmlUtil.escape(pageTitle) %>
                    </h1>

                    <p>
                        Manage and view tasks across your projects.
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


            <div class="tasks-page">


                <!-- =================================================
                     PAGE HEADING
                     ================================================= -->

                <div class="tasks-heading">


                    <div class="tasks-heading-text">

                        <h1>
                            <%= HtmlUtil.escape(pageTitle) %>
                        </h1>

                        <p>
                            Keep track of work, assignments,
                            due dates and task progress.
                        </p>

                    </div>


                    <% if (
                            "ADMIN".equals(role) ||
                            "PROJECT_MANAGER".equals(role)
                    ) { %>


                        <div class="tasks-heading-actions">

                            <a href="${pageContext.request.contextPath}/tasks/create"
                               class="btn btn-primary">

                                + Create Task

                            </a>

                        </div>


                    <% } %>


                </div>


                <!-- =================================================
                     SUMMARY
                     ================================================= -->

                <div class="task-summary">


                    <div class="task-summary-card">

                        <p class="task-summary-label">
                            Total Tasks
                        </p>

                        <p class="task-summary-number">
                            <%= totalTasks %>
                        </p>

                    </div>


                    <div class="task-summary-card pending">

                        <p class="task-summary-label">
                            Pending
                        </p>

                        <p class="task-summary-number">
                            <%= pendingTasks %>
                        </p>

                    </div>


                    <div class="task-summary-card progress">

                        <p class="task-summary-label">
                            In Progress
                        </p>

                        <p class="task-summary-number">
                            <%= inProgressTasks %>
                        </p>

                    </div>


                    <div class="task-summary-card completed">

                        <p class="task-summary-label">
                            Completed
                        </p>

                        <p class="task-summary-number">
                            <%= completedTasks %>
                        </p>

                    </div>


                </div>


                <!-- =================================================
                     SEARCH + FILTER
                     ================================================= -->

                <%
                    Boolean hidePrefAttr = (Boolean) request.getAttribute("hideCompletedPref");
                    Boolean showingCompletedAttr = (Boolean) request.getAttribute("showingCompleted");
                    Integer hiddenCompletedAttr = (Integer) request.getAttribute("hiddenCompleted");

                    boolean hidePref = hidePrefAttr != null && hidePrefAttr;
                    boolean showingCompleted = showingCompletedAttr != null && showingCompletedAttr;
                    int hiddenCompleted = hiddenCompletedAttr != null ? hiddenCompletedAttr : 0;
                %>

                <% if (request.getAttribute("assigneeFilter") != null) { %>

                    <p style="margin: 0 0 14px; color: var(--text-muted); font-size: 0.9rem;">
                        Showing tasks for
                        <strong><%= HtmlUtil.escape((String) request.getAttribute("assigneeFilterLabel")) %></strong>
                        only.
                        <a href="${pageContext.request.contextPath}/tasks">Clear filter</a>
                        &middot;
                        <a href="${pageContext.request.contextPath}/workload">Back to workload</a>
                    </p>

                <% } %>

                <% if (hidePref && !showingCompleted) { %>

                    <p style="margin: 0 0 14px; color: var(--text-muted); font-size: 0.9rem;">
                        <%= hiddenCompleted %> completed
                        <%= hiddenCompleted == 1 ? "task is" : "tasks are" %> hidden
                        (your preference).
                        <a href="${pageContext.request.contextPath}/tasks?showCompleted=1">Show completed</a>
                    </p>

                <% } else if (hidePref) { %>

                    <p style="margin: 0 0 14px; color: var(--text-muted); font-size: 0.9rem;">
                        Showing completed tasks.
                        <a href="${pageContext.request.contextPath}/tasks">Hide completed</a>
                    </p>

                <% } %>

                <div class="task-toolbar">


                    <div class="task-toolbar-left">


                        <input type="text"
                               id="taskSearch"
                               class="task-search"
                               placeholder="Search tasks by title or description...">


                        <select id="taskFilter"
                                class="task-filter">

                            <option value="ALL">
                                All Statuses
                            </option>

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


                    </div>


                    <div class="task-results-count"
                         id="taskResultsCount">

                        <%= totalTasks %>
                        <%= totalTasks == 1
                                ? "task"
                                : "tasks" %>

                    </div>


                </div>


                <!-- =================================================
                     TASKS
                     ================================================= -->

                <% if (tasks == null || tasks.isEmpty()) { %>


                    <div class="tasks-empty">


                        <div class="tasks-empty-icon">
                            &#9745;
                        </div>


                        <h3>
                            No tasks found
                        </h3>


                        <p>
                            There are currently no tasks available
                            for your account.
                        </p>


                    </div>


                <% } else { %>


                    <div class="tasks-grid"
                         id="tasksGrid">


                        <% for (Task task : tasks) {


                            String tStatus =
                                    task.getStatus() != null
                                            ? task.getStatus()
                                            : "";


                            String normalizedStatus =
                                    tStatus.toUpperCase();


                            String statusClass =
                                    "task-status-default";


                            if ("PENDING".equals(normalizedStatus)) {

                                statusClass =
                                        "task-status-pending";

                            } else if (
                                    "IN_PROGRESS".equals(
                                            normalizedStatus
                                    )
                            ) {

                                statusClass =
                                        "task-status-in-progress";

                            } else if (
                                    "COMPLETED".equals(
                                            normalizedStatus
                                    )
                            ) {

                                statusClass =
                                        "task-status-completed";

                            }


                            String description =
                                    task.getDescription();


                            if (
                                    description == null ||
                                    description.trim().isEmpty()
                            ) {

                                description =
                                        "No description provided.";

                            }


                            String dueDate =
                                    task.getDueDate() == null
                                            ? "-"
                                            : task.getDueDate()
                                                    .toString();


                            String assignee =
                                    task.getAssigneeId() > 0
                                            ? String.valueOf(
                                                    task.getAssigneeId()
                                              )
                                            : "Unassigned";

                        %>


                            <article class="task-card"
                                     data-title="<%= HtmlUtil.escape(
                                             task.getTitle()
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

                                <div class="task-card-top">


                                    <span class="task-number">

                                        TASK #<%= task.getTaskId() %>

                                    </span>


                                    <span class="task-status <%= statusClass %>">

                                        <%= HtmlUtil.escape(tStatus) %>

                                    </span>


                                </div>


                                <!-- ===============================
                                     TITLE
                                     =============================== -->

                                <h2 class="task-title">

                                    <a href="${pageContext.request.contextPath}/tasks/view?id=<%= task.getTaskId() %>"
                                       style="color: inherit; text-decoration: none;"
                                       title="Open task and comments">
                                        <%= HtmlUtil.escape(
                                                task.getTitle()
                                        ) %>
                                    </a>

                                </h2>


                                <p class="task-description">

                                    <%= HtmlUtil.escape(
                                            description
                                    ) %>

                                </p>


                                <!-- ===============================
                                     DETAILS
                                     =============================== -->

                                <div class="task-details">


                                    <div class="task-detail">

                                        <p class="task-detail-label">
                                            Project ID
                                        </p>

                                        <p class="task-detail-value">
                                            <%= task.getProjectId() %>
                                        </p>

                                    </div>


                                    <div class="task-detail">

                                        <p class="task-detail-label">
                                            Assignee ID
                                        </p>

                                        <p class="task-detail-value">
                                            <%= assignee %>
                                        </p>

                                    </div>


                                    <div class="task-detail">

                                        <p class="task-detail-label">
                                            Due Date
                                        </p>

                                        <p class="task-detail-value">
                                            <%= dueDate %>
                                            <%= TaskUi.overdueBadge(task) %>
                                        </p>

                                    </div>


                                    <div class="task-detail">

                                        <p class="task-detail-label">
                                            Priority
                                        </p>

                                        <p class="task-detail-value">
                                            <%= TaskUi.priorityBadge(task) %>
                                        </p>

                                    </div>


                                    <div class="task-detail">

                                        <p class="task-detail-label">
                                            Status
                                        </p>

                                        <p class="task-detail-value">
                                            <%= HtmlUtil.escape(tStatus) %>
                                        </p>

                                    </div>


                                </div>


                                <!-- ===============================
                                     ACTIONS
                                     =============================== -->

                                <div class="task-actions">


                                    <% if ("ADMIN".equals(role)) { %>


                                        <a class="task-edit"
                                           href="${pageContext.request.contextPath}/tasks/edit?id=<%= task.getTaskId() %>">

                                            Edit Task

                                        </a>


                                        <form action="${pageContext.request.contextPath}/tasks/delete"
                                              method="post"
                                              style="display: contents;"
                                              onsubmit="return confirm('Are you sure you want to delete this task?');">


                                            <input type="hidden"
                                                   name="csrfToken"
                                                   value="${sessionScope.csrfToken}">


                                            <input type="hidden"
                                                   name="id"
                                                   value="<%= task.getTaskId() %>">


                                            <button class="task-delete"
                                                    type="submit">

                                                Delete

                                            </button>


                                        </form>


                                    <% } else if (
                                            "PROJECT_MANAGER".equals(role) ||
                                            "TEAM_MEMBER".equals(role)
                                    ) { %>


                                        <a class="task-edit"
                                           href="${pageContext.request.contextPath}/tasks/edit?id=<%= task.getTaskId() %>">

                                            Edit Task

                                        </a>


                                    <% } %>


                                </div>


                            </article>


                        <% } %>


                    </div>


                    <!-- =================================================
                         SEARCH EMPTY STATE
                         ================================================= -->

                    <div class="no-task-results"
                         id="noTaskResults">


                        <h3>
                            No matching tasks
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
     THEME + SIDEBAR + TASK FILTER SCRIPT
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
           TASK SEARCH + FILTER
           ================================================= */

        const searchInput =
            document.getElementById(
                "taskSearch"
            );

        const statusFilter =
            document.getElementById(
                "taskFilter"
            );

        const taskCards =
            document.querySelectorAll(
                ".task-card"
            );

        const resultCount =
            document.getElementById(
                "taskResultsCount"
            );

        const noResults =
            document.getElementById(
                "noTaskResults"
            );


        function filterTasks() {

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


            taskCards.forEach(
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
                            ? " task"
                            : " tasks"
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
                filterTasks
            );

        }


        if (statusFilter) {

            statusFilter.addEventListener(
                "change",
                filterTasks
            );

        }


    })();

</script>


</body>

</html>