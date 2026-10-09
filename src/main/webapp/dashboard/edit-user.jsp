<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.pms.model.User" %>
<%@ page import="com.pms.util.HtmlUtil" %>

<%
    User editUser = (User) request.getAttribute("user");

    if (editUser == null) {
        response.sendRedirect(request.getContextPath() + "/users");
        return;
    }

    User currentUser = (User) session.getAttribute("user");

    String currentRole =
            currentUser != null
                    ? currentUser.getRole()
                    : "ADMIN";

    String dashboardUrl = "/dashboard/admin";
    String roleDisplay = "ADMIN";

    if ("PROJECT_MANAGER".equals(currentRole)) {
        dashboardUrl = "/dashboard/project-manager";
        roleDisplay = "PROJECT MANAGER";
    } else if ("TEAM_MEMBER".equals(currentRole)) {
        dashboardUrl = "/dashboard/team-member";
        roleDisplay = "TEAM MEMBER";
    }
%>

<!DOCTYPE html>
<html lang="en">

<head>

    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>Edit User</title>

    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/dashboard.css">


    <style>

        /* =====================================================
           EDIT USER PAGE
           ===================================================== */

        .edit-user-page {
            max-width: 1050px;
            margin: 0 auto;
        }


        /* =====================================================
           PAGE INTRO
           ===================================================== */

        .edit-user-heading {
            margin-bottom: 24px;
        }

        .edit-user-heading h1 {
            margin: 0 0 6px;
            font-size: 30px;
        }

        .edit-user-heading p {
            margin: 0;
            max-width: 650px;
            color: var(--text-muted);
            font-size: 14px;
            line-height: 1.5;
        }


        .user-id-label {
            display: inline-flex;
            align-items: center;
            gap: 6px;

            margin-top: 12px;
            padding: 5px 10px;

            border: 1px solid var(--border);
            border-radius: 20px;

            background: var(--surface-soft);

            color: var(--text-muted);
            font-size: 11px;
            font-weight: 600;
        }

        .user-id-label strong {
            color: var(--text);
        }


        /* =====================================================
           MAIN LAYOUT
           ===================================================== */

        .edit-user-layout {
            display: grid;

            grid-template-columns:
                minmax(0, 1fr)
                290px;

            gap: 20px;

            align-items: start;
        }


        /* =====================================================
           FORM CARD
           ===================================================== */

        .user-form-card {
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

        .user-form-group {
            margin-bottom: 19px;
        }

        .user-form-group:last-of-type {
            margin-bottom: 0;
        }

        .user-form-group label {
            display: block;

            margin-bottom: 7px;

            color: var(--text);

            font-size: 12px;
            font-weight: bold;
        }

        .user-form-group input,
        .user-form-group select {

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
                box-shadow 0.2s ease;
        }

        .user-form-group input:focus,
        .user-form-group select:focus {

            border-color: var(--primary);

            box-shadow:
                0 0 0 3px
                rgba(47, 127, 120, 0.11);
        }

        .user-form-group input::placeholder {
            color: var(--text-light);
        }

        .field-hint {
            margin: 6px 0 0;

            color: var(--text-light);

            font-size: 11px;

            line-height: 1.4;
        }


        /* =====================================================
           PASSWORD BOX
           ===================================================== */

        .password-box {

            padding: 15px;

            border: 1px solid var(--border);

            border-radius: 9px;

            background: var(--surface-soft);
        }


        /* =====================================================
           ROLE SECTION
           ===================================================== */

        .role-box {

            padding: 15px;

            border: 1px solid var(--border);

            border-radius: 9px;

            background: var(--surface-soft);
        }


        .role-description {

            display: flex;

            align-items: center;

            gap: 8px;

            margin-top: 8px;

            color: var(--text-muted);

            font-size: 11px;

            line-height: 1.4;
        }

        .role-dot {

            width: 7px;
            height: 7px;

            flex-shrink: 0;

            border-radius: 50%;

            background: var(--primary);
        }


        /* =====================================================
           FORM ACTIONS
           ===================================================== */

        .user-form-actions {

            display: flex;

            align-items: center;

            gap: 10px;

            margin-top: 25px;

            padding-top: 20px;

            border-top: 1px solid var(--border-light);
        }

        .user-form-actions .btn {
            min-width: 130px;
            justify-content: center;
        }


        /* =====================================================
           INFORMATION CARDS
           ===================================================== */

        .user-info-column {

            display: flex;

            flex-direction: column;

            gap: 14px;
        }

        .user-info-card {

            padding: 20px;

            background: var(--surface);

            border: 1px solid var(--border);

            border-radius: var(--radius);

            box-shadow: var(--shadow);
        }

        .user-info-card.accent {

            background:
                linear-gradient(
                    135deg,
                    var(--primary-soft),
                    var(--surface)
                );
        }

        .user-info-icon {

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

        .user-info-card h3 {
            margin: 0 0 7px;
            font-size: 15px;
        }

        .user-info-card p {
            margin: 0;

            color: var(--text-muted);

            font-size: 12px;

            line-height: 1.55;
        }


        /* =====================================================
           USER SUMMARY
           ===================================================== */

        .user-summary {
            display: grid;

            grid-template-columns:
                1fr 1fr;

            gap: 8px;

            margin-top: 15px;
        }

        .summary-item {

            padding: 10px;

            border: 1px solid var(--border-light);

            border-radius: 8px;

            background: var(--surface-soft);
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

        .user-tips {

            margin: 15px 0 0;

            padding: 0;

            list-style: none;
        }

        .user-tips li {

            position: relative;

            padding-left: 17px;

            margin-bottom: 10px;

            color: var(--text-muted);

            font-size: 11px;

            line-height: 1.45;
        }

        .user-tips li:last-child {
            margin-bottom: 0;
        }

        .user-tips li::before {

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

            .edit-user-layout {
                grid-template-columns: 1fr;
            }

            .user-info-column {

                display: grid;

                grid-template-columns:
                    1fr 1fr;
            }
        }


        @media (max-width: 650px) {

            .edit-user-heading h1 {
                font-size: 26px;
            }

            .user-form-card {
                padding: 20px;
            }

            .user-info-column {
                grid-template-columns: 1fr;
            }

        }


        @media (max-width: 450px) {

            .user-form-actions {

                flex-direction: column;

                align-items: stretch;
            }

            .user-form-actions .btn {
                width: 100%;
            }

            .user-summary {
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


        <% if ("ADMIN".equals(currentRole)) { %>


            <p class="sidebar-label"
               style="margin-top: 28px;">

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
                        Edit User
                    </h1>

                    <p>
                        Update account details, password or role.
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


            <div class="edit-user-page">


                <!-- =================================================
                     PAGE INTRO
                     ================================================= -->

                <div class="edit-user-heading">

                    <h1>
                        Update User
                    </h1>

                    <p>
                        Change the selected user's account information
                        below. Leave the password blank if it should
                        remain unchanged.
                    </p>


                    <div class="user-id-label">

                        User ID

                        <strong>
                            #<%= editUser.getUserId() %>
                        </strong>

                    </div>

                </div>


                <!-- =================================================
                     FORM + INFORMATION
                     ================================================= -->

                <div class="edit-user-layout">


                    <!-- =================================================
                         FORM
                         ================================================= -->

                    <div class="user-form-card">


                        <div class="form-card-heading">

                            <h2>
                                User Details
                            </h2>

                            <p>
                                Update only the information that needs
                                to be changed.
                            </p>

                        </div>


                        <form action="${pageContext.request.contextPath}/users/update"
                              method="post">


                            <!-- CSRF -->

                            <input type="hidden"
                                   name="csrfToken"
                                   value="${sessionScope.csrfToken}">


                            <!-- USER ID -->

                            <input type="hidden"
                                   name="userId"
                                   value="<%= editUser.getUserId() %>">


                            <!-- NAME -->

                            <div class="user-form-group">

                                <label for="name">
                                    Name
                                </label>


                                <input type="text"
                                       id="name"
                                       name="name"
                                       maxlength="100"
                                       value="<%= HtmlUtil.escape(editUser.getName()) %>"
                                       required>


                                <p class="field-hint">
                                    Maximum 100 characters.
                                </p>

                            </div>


                            <!-- EMAIL -->

                            <div class="user-form-group">

                                <label for="email">
                                    Email
                                </label>


                                <input type="email"
                                       id="email"
                                       name="email"
                                       maxlength="100"
                                       value="<%= HtmlUtil.escape(editUser.getEmail()) %>"
                                       required>


                                <p class="field-hint">
                                    This email is used for the user's
                                    account.
                                </p>

                            </div>


                            <!-- PASSWORD -->

                            <div class="user-form-group password-box">

                                <label for="password">
                                    New Password
                                </label>


                                <input type="password"
                                       id="password"
                                       name="password"
                                       maxlength="72"
                                       autocomplete="new-password"
                                       placeholder="Leave blank to keep current password">


                                <p class="field-hint">
                                    Leave this field empty to keep the
                                    user's current password.
                                </p>

                            </div>


                            <!-- ROLE -->

                            <div class="user-form-group role-box">

                                <label for="role">
                                    Role
                                </label>


                                <select id="role"
                                        name="role"
                                        required>


                                    <option value="ADMIN"
                                            <%= "ADMIN".equals(
                                                    editUser.getRole()
                                            )
                                                    ? "selected"
                                                    : "" %>>

                                        Admin

                                    </option>


                                    <option value="PROJECT_MANAGER"
                                            <%= "PROJECT_MANAGER".equals(
                                                    editUser.getRole()
                                            )
                                                    ? "selected"
                                                    : "" %>>

                                        Project Manager

                                    </option>


                                    <option value="TEAM_MEMBER"
                                            <%= "TEAM_MEMBER".equals(
                                                    editUser.getRole()
                                            )
                                                    ? "selected"
                                                    : "" %>>

                                        Team Member

                                    </option>


                                </select>


                                <div class="role-description">

                                    <span class="role-dot"
                                          id="roleDot">
                                    </span>

                                    <span id="roleHint">
                                    </span>

                                </div>

                            </div>


                            <!-- ACTIONS -->

                            <div class="user-form-actions">


                                <button type="submit"
                                        class="btn btn-primary">

                                    Update User

                                </button>


                                <a href="${pageContext.request.contextPath}/users"
                                   class="btn btn-secondary">

                                    Back to Users

                                </a>


                            </div>


                        </form>


                    </div>


                    <!-- =================================================
                         INFORMATION COLUMN
                         ================================================= -->

                    <div class="user-info-column">


                        <div class="user-info-card accent">


                            <div class="user-info-icon">
                                &#9998;
                            </div>


                            <h3>
                                Editing account
                            </h3>


                            <p>
                                You are updating an existing user.
                                Changes to their role can affect which
                                parts of the workspace they can access.
                            </p>


                            <div class="user-summary">


                                <div class="summary-item">

                                    <span class="summary-label">
                                        User
                                    </span>

                                    <span class="summary-value">

                                        <%= HtmlUtil.escape(
                                                editUser.getName()
                                        ) %>

                                    </span>

                                </div>


                                <div class="summary-item">

                                    <span class="summary-label">
                                        Role
                                    </span>

                                    <span class="summary-value"
                                          id="summaryRole">

                                        <%= editUser.getRole() != null
                                                ? editUser.getRole()
                                                : "—" %>

                                    </span>

                                </div>


                            </div>


                        </div>


                        <div class="user-info-card">


                            <h3>
                                Password
                            </h3>


                            <p>
                                You do not need to enter a password
                                unless you actually want to change it.
                                The existing password is never displayed
                                here.
                            </p>


                        </div>


                        <div class="user-info-card">


                            <h3>
                                Roles matter
                            </h3>


                            <p>
                                Admins manage the system, project
                                managers work with projects and tasks,
                                and team members primarily work on
                                assigned tasks.
                            </p>


                            <ul class="user-tips">

                                <li>
                                    Choose the role carefully.
                                </li>

                                <li>
                                    Keep the email address accurate.
                                </li>

                                <li>
                                    Avoid changing account details
                                    unnecessarily.
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
                       href="${pageContext.request.contextPath}/users">

                        ← Back to Users

                    </a>

                </div>


            </div>


        </div>


    </main>


</div>


<!-- =====================================================
     THEME + SIDEBAR + ROLE SCRIPT
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
           ROLE HELPER
           ================================================= */

        const roleSelect =
            document.getElementById(
                "role"
            );

        const roleHint =
            document.getElementById(
                "roleHint"
            );

        const roleDot =
            document.getElementById(
                "roleDot"
            );

        const summaryRole =
            document.getElementById(
                "summaryRole"
            );


        function updateRoleInfo() {

            if (
                !roleSelect ||
                !roleHint ||
                !roleDot
            ) {

                return;

            }


            const role =
                roleSelect.value;


            if (role === "ADMIN") {

                roleHint.textContent =
                    "Full administrative access.";

                roleDot.style.background =
                    "var(--terracotta)";


            } else if (role === "PROJECT_MANAGER") {

                roleHint.textContent =
                    "Can manage projects and related tasks.";

                roleDot.style.background =
                    "var(--mustard)";


            } else if (role === "TEAM_MEMBER") {

                roleHint.textContent =
                    "Works with assigned project tasks.";

                roleDot.style.background =
                    "var(--primary)";

            }


            if (summaryRole) {

                summaryRole.textContent =
                    role;

            }

        }


        if (roleSelect) {

            roleSelect.addEventListener(
                "change",
                updateRoleInfo
            );

            updateRoleInfo();

        }


    })();

</script>


</body>

</html>