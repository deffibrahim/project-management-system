<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.pms.model.User" %>
<%@ page import="com.pms.util.HtmlUtil" %>

<%
    List<User> users = (List<User>) request.getAttribute("users");

    User loggedInUser = (User) session.getAttribute("user");

    int loggedInUserId =
            loggedInUser != null ? loggedInUser.getUserId() : -1;

    int totalUsers = users != null ? users.size() : 0;

    int totalAdmins = 0;
    int totalProjectManagers = 0;
    int totalTeamMembers = 0;

    if (users != null) {
        for (User u : users) {

            if ("ADMIN".equalsIgnoreCase(u.getRole())) {
                totalAdmins++;
            }

            if ("PROJECT_MANAGER".equalsIgnoreCase(u.getRole())) {
                totalProjectManagers++;
            }

            if ("TEAM_MEMBER".equalsIgnoreCase(u.getRole())) {
                totalTeamMembers++;
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

    <title>Users | Project Management Tool</title>

    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/dashboard.css">

    <style>

        /* =====================================================
           USERS PAGE
           ===================================================== */

        .users-page {
            max-width: 1400px;
            margin: 0 auto;
        }


        /* ================= PAGE HEADER ================= */

        .users-heading {
            display: flex;
            align-items: flex-end;
            justify-content: space-between;
            gap: 20px;

            margin-bottom: 24px;
        }

        .users-heading-text h1 {
            margin: 0 0 5px;

            font-size: 30px;
        }

        .users-heading-text p {
            margin: 0;

            font-size: 14px;
        }

        .users-heading-actions {
            display: flex;
            gap: 10px;
            align-items: center;
        }


        /* ================= USER SUMMARY ================= */

        .user-summary {
            display: grid;

            grid-template-columns:
                repeat(4, minmax(0, 1fr));

            gap: 14px;

            margin-bottom: 22px;
        }

        .user-summary-card {
            position: relative;

            background: var(--surface);

            border: 1px solid var(--border);

            border-radius: var(--radius);

            padding: 18px 19px;

            box-shadow: var(--shadow);

            overflow: hidden;
        }

        .user-summary-card::before {
            content: "";

            position: absolute;

            left: 0;
            top: 0;

            width: 4px;
            height: 100%;

            background: var(--primary);
        }

        .user-summary-card.admin::before {
            background: var(--mustard);
        }

        .user-summary-card.pm::before {
            background: var(--purple);
        }

        .user-summary-card.member::before {
            background: var(--sage);
        }

        .user-summary-label {
            margin: 0 0 5px;

            color: var(--text-muted);

            font-size: 12px;
            font-weight: bold;

            text-transform: uppercase;
            letter-spacing: 0.4px;
        }

        .user-summary-number {
            margin: 0;

            color: var(--text);

            font-size: 28px;
            font-weight: bold;

            line-height: 1.2;
        }


        /* ================= USER TOOLBAR ================= */

        .users-toolbar {
            display: flex;

            align-items: center;
            justify-content: space-between;

            gap: 14px;

            margin-bottom: 18px;
        }

        .users-toolbar-left {
            display: flex;

            align-items: center;

            gap: 10px;

            flex: 1;
        }

        .users-search {
            width: 100%;
            max-width: 420px;

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

        .users-search:focus {
            border-color: var(--primary);

            box-shadow:
                0 0 0 3px
                rgba(47, 127, 120, 0.11);
        }

        .users-search::placeholder {
            color: var(--text-light);
        }

        .role-filter {
            min-width: 175px;

            padding: 11px 12px;

            border: 1px solid var(--border);

            border-radius: 8px;

            background: var(--surface);
            color: var(--text);

            font-size: 14px;

            outline: none;

            cursor: pointer;
        }

        .role-filter:focus {
            border-color: var(--primary);
        }


        /* ================= USER COUNT ================= */

        .results-count {
            color: var(--text-muted);

            font-size: 13px;

            white-space: nowrap;
        }


        /* ================= USER GRID ================= */

        .users-grid {
            display: grid;

            grid-template-columns:
                repeat(3, minmax(0, 1fr));

            gap: 16px;
        }


        /* ================= USER CARD ================= */

        .user-card {
            position: relative;

            display: flex;

            flex-direction: column;

            min-height: 215px;

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

        .user-card:hover {
            transform: translateY(-2px);

            box-shadow: var(--shadow-hover);

            border-color: #cfc9bd;
        }


        /* ================= USER TOP ================= */

        .user-card-top {
            display: flex;

            align-items: flex-start;
            justify-content: space-between;

            gap: 12px;

            margin-bottom: 17px;
        }

        .user-identity {
            display: flex;

            align-items: center;

            gap: 12px;

            min-width: 0;
        }

        .user-avatar {
            width: 46px;
            height: 46px;

            min-width: 46px;

            display: flex;

            align-items: center;
            justify-content: center;

            border-radius: 12px;

            background: var(--primary-soft);

            color: var(--primary);

            font-size: 18px;
            font-weight: bold;

            text-transform: uppercase;
        }

        .user-card:nth-child(3n + 2)
        .user-avatar {
            background: var(--mustard-soft);

            color: #86641e;
        }

        .user-card:nth-child(3n)
        .user-avatar {
            background: var(--sage-soft);

            color: #4d7048;
        }

        .user-name {
            margin: 0;

            color: var(--text);

            font-size: 16px;
            font-weight: bold;

            line-height: 1.3;

            word-break: break-word;
        }

        .user-email {
            margin: 3px 0 0;

            color: var(--text-muted);

            font-size: 12px;

            word-break: break-word;
        }


        /* ================= CURRENT USER ================= */

        .current-user {
            display: inline-flex;

            align-items: center;

            padding: 4px 8px;

            border-radius: 20px;

            background: var(--primary-soft);

            color: var(--primary);

            font-size: 10px;

            font-weight: bold;

            white-space: nowrap;
        }


        /* ================= USER INFO ================= */

        .user-card-info {
            display: flex;

            align-items: center;
            justify-content: space-between;

            gap: 10px;

            padding-top: 14px;

            border-top: 1px solid var(--border-light);
        }


        /* ================= ROLE BADGES ================= */

        .user-role {
            display: inline-flex;

            align-items: center;

            padding: 5px 9px;

            border-radius: 20px;

            font-size: 10px;

            font-weight: bold;

            letter-spacing: 0.2px;
        }

        .user-role-admin {
            background: var(--mustard-soft);

            color: #80601c;
        }

        .user-role-pm {
            background: var(--purple-soft);

            color: #71327e;
        }

        .user-role-member {
            background: var(--sage-soft);

            color: #4d7048;
        }


        /* ================= USER ID ================= */

        .user-id {
            color: var(--text-light);

            font-size: 11px;
        }


        /* ================= USER ACTIONS ================= */

        .user-card-actions {
            display: flex;

            gap: 8px;

            margin-top: auto;

            padding-top: 17px;
        }

        .user-edit {
            flex: 1;

            display: inline-flex;

            align-items: center;
            justify-content: center;

            padding: 8px 12px;

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

        .user-edit:hover {
            background: var(--primary-hover);

            color: #ffffff;

            transform: translateY(-1px);
        }

        .user-delete {
            padding: 8px 12px;

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

        .user-delete:hover {
            background: var(--danger);

            color: #ffffff;
        }

        .user-current-label {
            width: 100%;

            display: flex;

            align-items: center;
            justify-content: center;

            padding: 8px 12px;

            border-radius: 7px;

            background: var(--surface-soft);

            color: var(--text-muted);

            font-size: 12px;

            font-weight: bold;
        }


        /* ================= EMPTY STATE ================= */

        .users-empty {
            display: flex;

            flex-direction: column;

            align-items: center;
            justify-content: center;

            min-height: 270px;

            padding: 35px;

            background: var(--surface);

            border: 1px dashed var(--border);

            border-radius: var(--radius);

            text-align: center;
        }

        .users-empty-icon {
            width: 54px;
            height: 54px;

            display: flex;

            align-items: center;
            justify-content: center;

            margin-bottom: 12px;

            border-radius: 15px;

            background: var(--surface-soft);

            color: var(--text-muted);

            font-size: 23px;
        }

        .users-empty h3 {
            margin: 0 0 5px;

            font-size: 17px;
        }

        .users-empty p {
            margin: 0;

            max-width: 400px;

            font-size: 13px;
        }


        /* ================= HIDDEN SEARCH RESULT ================= */

        .user-card.hidden {
            display: none;
        }

        .no-search-results {
            display: none;

            padding: 35px;

            background: var(--surface);

            border: 1px dashed var(--border);

            border-radius: var(--radius);

            text-align: center;
        }

        .no-search-results.visible {
            display: block;
        }

        .no-search-results h3 {
            margin: 0 0 5px;

            font-size: 17px;
        }

        .no-search-results p {
            margin: 0;

            font-size: 13px;
        }


        /* ================= RESPONSIVE ================= */

        @media (max-width: 1050px) {

            .users-grid {
                grid-template-columns:
                    repeat(2, minmax(0, 1fr));
            }

            .user-summary {
                grid-template-columns:
                    repeat(2, minmax(0, 1fr));
            }

        }


        @media (max-width: 800px) {

            .users-heading {
                align-items: flex-start;

                flex-direction: column;
            }

            .users-heading-actions {
                width: 100%;
            }

            .users-toolbar {
                align-items: stretch;

                flex-direction: column;
            }

            .users-toolbar-left {
                flex-direction: column;

                align-items: stretch;
            }

            .users-search {
                max-width: none;
            }

            .role-filter {
                width: 100%;
            }

            .results-count {
                text-align: left;
            }

        }


        @media (max-width: 600px) {

            .users-grid {
                grid-template-columns: 1fr;
            }

            .user-summary {
                grid-template-columns: 1fr 1fr;
            }

            .user-summary-card {
                padding: 15px;
            }

            .user-summary-number {
                font-size: 24px;
            }

        }


        @media (max-width: 420px) {

            .user-summary {
                grid-template-columns: 1fr;
            }

            .user-card {
                padding: 17px;
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


            <a href="${pageContext.request.contextPath}/dashboard/admin"
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


            <a href="${pageContext.request.contextPath}/workload"
               class="sidebar-link">

                <span class="sidebar-icon">
                    &#128202;
                </span>

                Workload

            </a>



        </nav>


        <p class="sidebar-label">

            Administration

        </p>


        <nav class="sidebar-nav">


            <a href="${pageContext.request.contextPath}/users"
               class="sidebar-link active">

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
                        Users
                    </h1>

                    <p>
                        Manage the people who use your workspace.
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


            <div class="users-page">


                <!-- =================================================
                     PAGE HEADING
                     ================================================= -->

                <div class="users-heading">


                    <div class="users-heading-text">

                        <h1>
                            Workspace Users
                        </h1>

                        <p>
                            View and manage everyone in the system.
                        </p>

                    </div>


                    <div class="users-heading-actions">

                        <a class="btn btn-primary"
                           href="${pageContext.request.contextPath}/users/create">

                            + Add User

                        </a>

                    </div>


                </div>


                <!-- =================================================
                     USER SUMMARY
                     ================================================= -->

                <div class="user-summary">


                    <div class="user-summary-card">

                        <p class="user-summary-label">
                            Total Users
                        </p>

                        <p class="user-summary-number">
                            <%= totalUsers %>
                        </p>

                    </div>


                    <div class="user-summary-card admin">

                        <p class="user-summary-label">
                            Admins
                        </p>

                        <p class="user-summary-number">
                            <%= totalAdmins %>
                        </p>

                    </div>


                    <div class="user-summary-card pm">

                        <p class="user-summary-label">
                            Project Managers
                        </p>

                        <p class="user-summary-number">
                            <%= totalProjectManagers %>
                        </p>

                    </div>


                    <div class="user-summary-card member">

                        <p class="user-summary-label">
                            Team Members
                        </p>

                        <p class="user-summary-number">
                            <%= totalTeamMembers %>
                        </p>

                    </div>


                </div>


                <!-- =================================================
                     SEARCH + FILTER
                     ================================================= -->

                <div class="users-toolbar">


                    <div class="users-toolbar-left">


                        <input type="text"
                               id="userSearch"
                               class="users-search"
                               placeholder="Search by name or email...">


                        <select id="roleFilter"
                                class="role-filter">

                            <option value="ALL">
                                All Roles
                            </option>

                            <option value="ADMIN">
                                Admin
                            </option>

                            <option value="PROJECT_MANAGER">
                                Project Manager
                            </option>

                            <option value="TEAM_MEMBER">
                                Team Member
                            </option>

                        </select>


                    </div>


                    <div class="results-count"
                         id="resultsCount">

                        <%= totalUsers %>
                        <%= totalUsers == 1 ? "user" : "users" %>

                    </div>


                </div>


                <!-- =================================================
                     USERS
                     ================================================= -->

                <% if (users == null || users.isEmpty()) { %>


                    <div class="users-empty">


                        <div class="users-empty-icon">
                            &#128101;
                        </div>


                        <h3>
                            No users yet
                        </h3>


                        <p>
                            Add your first user to start building
                            your project team.
                        </p>


                    </div>


                <% } else { %>


                    <div class="users-grid"
                         id="usersGrid">


                        <% for (User u : users) { %>


                            <%
                                String safeName =
                                        HtmlUtil.escape(u.getName());

                                String safeEmail =
                                        HtmlUtil.escape(u.getEmail());

                                String safeRole =
                                        HtmlUtil.escape(u.getRole());

                                String role =
                                        u.getRole() != null
                                                ? u.getRole().toUpperCase()
                                                : "";

                                String roleClass = "";

                                String roleLabel =
                                        safeRole;

                                if ("ADMIN".equals(role)) {

                                    roleClass =
                                            "user-role-admin";

                                    roleLabel =
                                            "ADMIN";

                                } else if (
                                        "PROJECT_MANAGER".equals(role)
                                ) {

                                    roleClass =
                                            "user-role-pm";

                                    roleLabel =
                                            "PROJECT MANAGER";

                                } else if (
                                        "TEAM_MEMBER".equals(role)
                                ) {

                                    roleClass =
                                            "user-role-member";

                                    roleLabel =
                                            "TEAM MEMBER";

                                }

                                String initial = "?";

                                if (
                                        u.getName() != null &&
                                        !u.getName().trim().isEmpty()
                                ) {

                                    initial =
                                            String.valueOf(
                                                    u.getName()
                                                            .trim()
                                                            .charAt(0)
                                            ).toUpperCase();

                                }
                            %>


                            <div class="user-card"
                                 data-name="<%= safeName.toLowerCase() %>"
                                 data-email="<%= safeEmail.toLowerCase() %>"
                                 data-role="<%= role %>">


                                <!-- User heading -->

                                <div class="user-card-top">


                                    <div class="user-identity">


                                        <div class="user-avatar">

                                            <%= HtmlUtil.escape(initial) %>

                                        </div>


                                        <div>

                                            <p class="user-name">
                                                <%= safeName %>
                                            </p>

                                            <p class="user-email">
                                                <%= safeEmail %>
                                            </p>

                                        </div>


                                    </div>


                                    <% if (
                                            u.getUserId()
                                                    == loggedInUserId
                                    ) { %>

                                        <span class="current-user">
                                            You
                                        </span>

                                    <% } %>


                                </div>


                                <!-- Role + ID -->

                                <div class="user-card-info">


                                    <span class="user-role <%= roleClass %>">

                                        <%= roleLabel %>

                                    </span>


                                    <span class="user-id">

                                        ID #<%= u.getUserId() %>

                                    </span>


                                </div>


                                <!-- Actions -->

                                <div class="user-card-actions">


                                    <a class="user-edit"
                                       href="${pageContext.request.contextPath}/users/edit?id=<%= u.getUserId() %>">

                                        Edit User

                                    </a>


                                    <% if (
                                            u.getUserId()
                                                    == loggedInUserId
                                    ) { %>


                                        <div class="user-current-label">

                                            Current User

                                        </div>


                                    <% } else { %>


                                        <form action="${pageContext.request.contextPath}/users/delete"
                                              method="post"
                                              style="display: contents;"
                                              onsubmit="return confirm('Are you sure you want to delete this user?');">


                                            <input type="hidden"
                                                   name="csrfToken"
                                                   value="${sessionScope.csrfToken}">


                                            <input type="hidden"
                                                   name="id"
                                                   value="<%= u.getUserId() %>">


                                            <button class="user-delete"
                                                    type="submit">

                                                Delete

                                            </button>


                                        </form>


                                    <% } %>


                                </div>


                            </div>


                        <% } %>


                    </div>


                    <!-- No search result -->

                    <div class="no-search-results"
                         id="noSearchResults">

                        <h3>
                            No users found
                        </h3>

                        <p>
                            Try changing your search or role filter.
                        </p>

                    </div>


                <% } %>


                <!-- =================================================
                     BACK TO DASHBOARD
                     ================================================= -->

                <div style="margin-top: 22px;">

                    <a class="back-link"
                       href="${pageContext.request.contextPath}/dashboard/admin">

                        ← Back to Dashboard

                    </a>

                </div>


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


        /* =================================================
           USER SEARCH + FILTER
           ================================================= */

        const searchInput =
            document.getElementById(
                "userSearch"
            );

        const roleFilter =
            document.getElementById(
                "roleFilter"
            );

        const userCards =
            document.querySelectorAll(
                ".user-card"
            );

        const resultsCount =
            document.getElementById(
                "resultsCount"
            );

        const noSearchResults =
            document.getElementById(
                "noSearchResults"
            );


        function filterUsers() {

            const searchValue =
                searchInput
                    ? searchInput.value
                        .trim()
                        .toLowerCase()
                    : "";


            const selectedRole =
                roleFilter
                    ? roleFilter.value
                    : "ALL";


            let visibleCount =
                0;


            userCards.forEach(
                function (card) {

                    const name =
                        card.dataset.name
                            || "";

                    const email =
                        card.dataset.email
                            || "";

                    const role =
                        card.dataset.role
                            || "";


                    const matchesSearch =
                        name.includes(
                            searchValue
                        ) ||
                        email.includes(
                            searchValue
                        );


                    const matchesRole =
                        selectedRole === "ALL" ||
                        role === selectedRole;


                    if (
                        matchesSearch &&
                        matchesRole
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


            if (resultsCount) {

                resultsCount.textContent =
                    visibleCount +
                    (
                        visibleCount === 1
                            ? " user"
                            : " users"
                    );

            }


            if (noSearchResults) {

                if (
                    visibleCount === 0
                ) {

                    noSearchResults.classList.add(
                        "visible"
                    );

                } else {

                    noSearchResults.classList.remove(
                        "visible"
                    );

                }

            }

        }


        if (searchInput) {

            searchInput.addEventListener(
                "input",
                filterUsers
            );

        }


        if (roleFilter) {

            roleFilter.addEventListener(
                "change",
                filterUsers
            );

        }


    })();

</script>


</body>

</html>