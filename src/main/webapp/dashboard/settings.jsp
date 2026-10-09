<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.pms.model.User" %>
<%@ page import="com.pms.model.UserPreferences" %>
<%@ page import="com.pms.util.HtmlUtil" %>
<%@ page import="com.pms.util.AppSettings" %>

<%
    User account = (User) request.getAttribute("account");

    if (account == null) {
        response.sendRedirect(request.getContextPath() + "/settings");
        return;
    }

    User currentUser = (User) session.getAttribute("user");

    String role = currentUser != null ? currentUser.getRole() : "";
    boolean isAdmin = "ADMIN".equals(role);

    String dashboardUrl = "/dashboard/team-member";
    String roleLabel = "TEAM MEMBER";

    if (isAdmin) {
        dashboardUrl = "/dashboard/admin";
        roleLabel = "ADMIN";
    } else if ("PROJECT_MANAGER".equals(role)) {
        dashboardUrl = "/dashboard/project-manager";
        roleLabel = "PROJECT MANAGER";
    }

    UserPreferences preferences = (UserPreferences) request.getAttribute("preferences");

    if (preferences == null) {
        preferences = new UserPreferences();
    }

    Integer minPasswordLength = (Integer) request.getAttribute("minPasswordLength");

    if (minPasswordLength == null) minPasswordLength = AppSettings.DEFAULT_MIN_PASSWORD_LENGTH;

    Integer sessionTimeout = (Integer) request.getAttribute("sessionTimeout");

    if (sessionTimeout == null) sessionTimeout = AppSettings.DEFAULT_SESSION_TIMEOUT_MINUTES;

    Boolean pmCanCreateProjects = (Boolean) request.getAttribute("pmCanCreateProjects");
    Boolean membersCanComment = (Boolean) request.getAttribute("membersCanComment");
    Boolean maintenanceMode = (Boolean) request.getAttribute("maintenanceMode");

    if (pmCanCreateProjects == null) pmCanCreateProjects = Boolean.TRUE;
    if (membersCanComment == null) membersCanComment = Boolean.TRUE;
    if (maintenanceMode == null) maintenanceMode = Boolean.FALSE;

    String tab = (String) request.getAttribute("tab");

    if (!"preferences".equals(tab) && !("system".equals(tab) && isAdmin)) {
        tab = "account";
    }

    String savedMessage = request.getParameter("saved");
    String errorMessage = request.getParameter("error");
%>

<!DOCTYPE html>
<html lang="en">

<head>

    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>Settings | Project Management Tool</title>

    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/dashboard.css">

    <style>


        .settings-page {
            max-width: 760px;
            margin: 0 auto;
        }

        .settings-tabs {
            display: flex;
            gap: 6px;
            margin-bottom: 18px;
            border-bottom: 1px solid var(--border);
        }

        .settings-tab {
            appearance: none;
            border: none;
            background: none;
            padding: 11px 16px;
            font: inherit;
            font-weight: 600;
            color: var(--text-muted);
            cursor: pointer;
            border-bottom: 3px solid transparent;
            margin-bottom: -1px;
        }

        .settings-tab:hover {
            color: var(--text);
        }

        .settings-tab.active {
            color: var(--primary);
            border-bottom-color: var(--primary);
        }

        .settings-panel {
            display: none;
        }

        .settings-panel.active {
            display: block;
        }

        .settings-page .form-section {
            display: block;
        }

        .settings-page .form-card {
            max-width: none;
            padding: 27px;
            margin-bottom: 18px;
        }

        .settings-page .form-card p.hint,
        .settings-page .form-group small {
            color: var(--text-muted);
            font-size: 0.86rem;
            line-height: 1.5;
        }

        .settings-page .form-group small {
            display: block;
            margin-top: 6px;
        }

        .settings-page .form-card p.hint {
            margin: -8px 0 18px;
        }

        .settings-notice {
            margin: 0 0 16px;
            padding: 11px 14px;
            border-radius: 9px;
            font-size: 0.92rem;
        }

        .settings-notice.success {
            background: var(--success-soft);
            color: var(--success-hover);
            border: 1px solid var(--success);
        }

        .settings-notice.error {
            background: var(--danger-soft);
            color: var(--danger-hover);
            border: 1px solid var(--danger);
        }

    
        .check-row {
            display: flex;
            gap: 12px;
            align-items: flex-start;
            padding: 12px 0;
            border-top: 1px solid var(--border-light);
        }

        .check-row:first-of-type {
            border-top: none;
        }

        .check-row input[type="checkbox"] {
            width: 18px;
            height: 18px;
            margin-top: 3px;
            flex: none;
            accent-color: var(--primary);
        }

        .check-row label {
            font-weight: 600;
            cursor: pointer;
        }

        .check-row small {
            display: block;
            margin-top: 3px;
            font-weight: 400;
            color: var(--text-muted);
            line-height: 1.5;
        }

        .role-chip {
            display: inline-block;
            padding: 3px 10px;
            border-radius: 999px;
            font-size: 0.74rem;
            font-weight: 700;
            letter-spacing: 0.05em;
            background: var(--primary-soft);
            color: var(--primary);
        }

        .theme-options {
            display: flex;
            gap: 10px;
            flex-wrap: wrap;
        }

        .theme-option {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 9px 14px;
            border: 1px solid var(--border);
            border-radius: 9px;
            background: var(--surface-soft);
            cursor: pointer;
            font-weight: 600;
        }

        .theme-option input {
            accent-color: var(--primary);
        }

        .warning-note {
            margin: 14px 0 0;
            padding: 10px 14px;
            border-radius: 9px;
            background: var(--warning-soft);
            color: var(--warning-hover);
            font-size: 0.88rem;
        }

    </style>

    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/ui-polish.css">

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

        <% if (isAdmin) { %>

        <p class="sidebar-label">Administration</p>

        <nav class="sidebar-nav">

            <a href="${pageContext.request.contextPath}/users"
               class="sidebar-link">
                <span class="sidebar-icon">&#128101;</span>
                Users
            </a>

            <a href="${pageContext.request.contextPath}/settings"
               class="sidebar-link active">
                <span class="sidebar-icon">&#9881;</span>
                Settings
            </a>

        </nav>

        <% } else { %>

        <p class="sidebar-label">Account</p>

        <nav class="sidebar-nav">

            <a href="${pageContext.request.contextPath}/settings"
               class="sidebar-link active">
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

            <form action="${pageContext.request.contextPath}/logout" method="post" class="sidebar-logout-form" style="margin:0;"><input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}"><button type="submit" class="sidebar-logout" style="border:0;background:transparent;width:100%;font:inherit;text-align:left;cursor:pointer;">
                &#10140; Logout
            </button></form>

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
                    <h1>Settings</h1>
                    <p>Manage your account, preferences and (for admins) the system.</p>
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

            <div class="settings-page">

                <% if (savedMessage != null && !savedMessage.isEmpty()) { %>
                <p class="settings-notice success" role="status"><%= HtmlUtil.escape(savedMessage) %></p>
                <% } %>

                <% if (errorMessage != null && !errorMessage.isEmpty()) { %>
                <p class="settings-notice error" role="alert"><%= HtmlUtil.escape(errorMessage) %></p>
                <% } %>

                <div class="settings-tabs" role="tablist">
                    <button type="button"
                            class="settings-tab <%= "account".equals(tab) ? "active" : "" %>"
                            data-tab="account" role="tab">Account</button>
                    <button type="button"
                            class="settings-tab <%= "preferences".equals(tab) ? "active" : "" %>"
                            data-tab="preferences" role="tab">Preferences</button>
                    <% if (isAdmin) { %>
                    <button type="button"
                            class="settings-tab <%= "system".equals(tab) ? "active" : "" %>"
                            data-tab="system" role="tab">System</button>
                    <% } %>
                </div>


                <!-- ================= ACCOUNT ================= -->

                <div class="settings-panel <%= "account".equals(tab) ? "active" : "" %>"
                     id="panel-account">

                    <div class="form-section">

                        <div class="form-card">

                            <h3>Your Account</h3>

                            <p class="hint">
                                Your role: <span class="role-chip"><%= roleLabel %></span>
                                &nbsp;(only an administrator can change roles)
                            </p>

                            <form action="${pageContext.request.contextPath}/settings/account"
                                  method="post">

                                <input type="hidden" name="csrfToken"
                                       value="${sessionScope.csrfToken}">

                                <div class="form-group">
                                    <label for="name">Full Name</label>
                                    <input type="text" id="name" name="name"
                                           maxlength="100" autocomplete="name"
                                           value="<%= HtmlUtil.escape(account.getName()) %>"
                                           required>
                                </div>

                                <div class="form-group">
                                    <label for="email">Email Address</label>
                                    <input type="email" id="email" name="email"
                                           maxlength="100" autocomplete="email"
                                           value="<%= HtmlUtil.escape(account.getEmail()) %>"
                                           required>
                                </div>

                                <h3 style="margin-top: 26px;">Change Password</h3>

                                <p class="hint">
                                    Leave these blank to keep your current password.
                                </p>

                                <div class="form-group">
                                    <label for="currentPassword">Current Password</label>
                                    <input type="password" id="currentPassword"
                                           name="currentPassword"
                                           autocomplete="current-password">
                                </div>

                                <div class="form-group">
                                    <label for="newPassword">New Password</label>
                                    <input type="password" id="newPassword"
                                           name="newPassword"
                                           minlength="<%= minPasswordLength %>"
                                           maxlength="72"
                                           autocomplete="new-password">
                                    <small>At least <%= minPasswordLength %> characters.</small>
                                </div>

                                <div class="form-group">
                                    <label for="confirmPassword">Confirm New Password</label>
                                    <input type="password" id="confirmPassword"
                                           name="confirmPassword"
                                           autocomplete="new-password">
                                </div>

                                <button class="form-button" type="submit">
                                    Save Account
                                </button>

                            </form>

                        </div>

                    </div>

                </div>


                <!-- ================= PREFERENCES ================= -->

                <div class="settings-panel <%= "preferences".equals(tab) ? "active" : "" %>"
                     id="panel-preferences">

                    <div class="form-section">

                        <div class="form-card">

                            <h3>Appearance</h3>

                            <p class="hint">
                                Applies instantly. Saved in this browser only.
                            </p>

                            <div class="theme-options">

                                <label class="theme-option">
                                    <input type="radio" name="themeChoice" value="light">
                                    &#9728; Light
                                </label>

                                <label class="theme-option">
                                    <input type="radio" name="themeChoice" value="dark">
                                    &#9790; Dark
                                </label>

                            </div>

                        </div>

                        <div class="form-card">

                            <h3>Your Workspace</h3>

                            <p class="hint">
                                These follow your account on any device.
                            </p>

                            <form action="${pageContext.request.contextPath}/settings/preferences"
                                  method="post">

                                <input type="hidden" name="csrfToken"
                                       value="${sessionScope.csrfToken}">

                                <div class="form-group">
                                    <label for="landingPage">Start page after login</label>
                                    <select id="landingPage" name="landingPage">
                                        <option value="DASHBOARD"
                                                <%= UserPreferences.LANDING_DASHBOARD.equals(preferences.getLandingPage()) ? "selected" : "" %>>
                                            My dashboard
                                        </option>
                                        <option value="TASKS"
                                                <%= UserPreferences.LANDING_TASKS.equals(preferences.getLandingPage()) ? "selected" : "" %>>
                                            Tasks
                                        </option>
                                        <option value="PROJECTS"
                                                <%= UserPreferences.LANDING_PROJECTS.equals(preferences.getLandingPage()) ? "selected" : "" %>>
                                            Projects
                                        </option>
                                    </select>
                                    <small>The page you land on right after signing in.</small>
                                </div>

                                <div class="check-row">
                                    <input type="checkbox" id="hideCompleted" name="hideCompleted"
                                           <%= preferences.isHideCompleted() ? "checked" : "" %>>
                                    <label for="hideCompleted">
                                        Hide completed tasks in my task list
                                        <small>
                                            Finished tasks are tucked away on the Tasks page,
                                            with a link to show them when you need them.
                                        </small>
                                    </label>
                                </div>

                                <button class="form-button" type="submit" style="margin-top: 10px;">
                                    Save Preferences
                                </button>

                            </form>

                        </div>

                    </div>

                </div>


                <% if (isAdmin) { %>

                <!-- ================= SYSTEM (admin) ================= -->

                <div class="settings-panel <%= "system".equals(tab) ? "active" : "" %>"
                     id="panel-system">

                    <div class="form-section">

                        <div class="form-card">

                            <h3>System Settings</h3>

                            <p class="hint">
                                These apply to everyone who uses the workspace.
                            </p>

                            <form action="${pageContext.request.contextPath}/settings/system"
                                  method="post">

                                <input type="hidden" name="csrfToken"
                                       value="${sessionScope.csrfToken}">

                                <div class="form-group">
                                    <label for="sessionTimeout">Session Timeout (minutes)</label>
                                    <input type="number" id="sessionTimeout"
                                           name="sessionTimeout"
                                           min="<%= AppSettings.MIN_TIMEOUT %>"
                                           max="<%= AppSettings.MAX_TIMEOUT %>"
                                           value="<%= sessionTimeout %>"
                                           required>
                                    <small>
                                        Users are logged out after this much inactivity
                                        (<%= AppSettings.MIN_TIMEOUT %>&ndash;<%= AppSettings.MAX_TIMEOUT %>).
                                        Applies to logins from now on.
                                    </small>
                                </div>

                                <div class="form-group">
                                    <label for="minPasswordLength">Minimum Password Length</label>
                                    <input type="number" id="minPasswordLength"
                                           name="minPasswordLength"
                                           min="<%= AppSettings.MIN_PASSWORD_FLOOR %>"
                                           max="<%= AppSettings.MAX_PASSWORD %>"
                                           value="<%= minPasswordLength %>"
                                           required>
                                    <small>
                                        Enforced when creating users and changing passwords
                                        (<%= AppSettings.MIN_PASSWORD_FLOOR %>&ndash;<%= AppSettings.MAX_PASSWORD %>).
                                    </small>
                                </div>

                                <div class="check-row">
                                    <input type="checkbox" id="pmCanCreateProjects" name="pmCanCreateProjects"
                                           <%= pmCanCreateProjects ? "checked" : "" %>>
                                    <label for="pmCanCreateProjects">
                                        Project managers can create projects
                                        <small>Turn off to let only admins create projects.</small>
                                    </label>
                                </div>

                                <div class="check-row">
                                    <input type="checkbox" id="membersCanComment" name="membersCanComment"
                                           <%= membersCanComment ? "checked" : "" %>>
                                    <label for="membersCanComment">
                                        Team members can comment on tasks
                                        <small>Turn off to make comments read-only for team members.</small>
                                    </label>
                                </div>

                                <div class="check-row">
                                    <input type="checkbox" id="maintenanceMode" name="maintenanceMode"
                                           <%= maintenanceMode ? "checked" : "" %>>
                                    <label for="maintenanceMode">
                                        Maintenance mode
                                        <small>
                                            While on, only administrators can sign in.
                                            People already signed in are not logged out.
                                        </small>
                                    </label>
                                </div>

                                <% if (maintenanceMode) { %>
                                <p class="warning-note">
                                    Maintenance mode is currently ON.
                                </p>
                                <% } %>

                                <button class="form-button" type="submit" style="margin-top: 14px;">
                                    Save System Settings
                                </button>

                            </form>

                        </div>

                    </div>

                </div>

                <% } %>

            </div>

        </div>

    </main>

</div>

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
           SETTINGS TABS
           ================================================= */

        const tabButtons = document.querySelectorAll(".settings-tab");

        tabButtons.forEach(function (button) {

            button.addEventListener("click", function () {

                const target = button.getAttribute("data-tab");

                tabButtons.forEach(function (b) {
                    b.classList.toggle("active", b === button);
                });

                document.querySelectorAll(".settings-panel").forEach(function (panel) {
                    panel.classList.toggle("active", panel.id === "panel-" + target);
                });

            });

        });


        /* =================================================
           THEME CHOICE (same storage key as the top-bar toggle)
           ================================================= */

        const themeRadios = document.querySelectorAll('input[name="themeChoice"]');

        function currentTheme() {
            return document.body.getAttribute("data-theme") === "dark" ? "dark" : "light";
        }

        themeRadios.forEach(function (radio) {

            radio.checked = radio.value === currentTheme();

            radio.addEventListener("change", function () {

                document.body.setAttribute("data-theme", radio.value);

                try {
                    localStorage.setItem("pms-theme", radio.value);
                } catch (error) {
                    // Theme still applies for this page view.
                }

                const toggle = document.getElementById("themeToggle");

                if (toggle) {
                    toggle.innerHTML = radio.value === "dark" ? "&#9728;" : "&#9790;";
                }

            });

        });

    })();

</script>

</body>
</html>
