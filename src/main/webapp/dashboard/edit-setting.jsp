<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.pms.model.SystemSetting" %>
<%@ page import="com.pms.model.User" %>
<%@ page import="com.pms.util.HtmlUtil" %>

<%
    SystemSetting setting =
            (SystemSetting) request.getAttribute("setting");

    if (setting == null) {
        response.sendRedirect(request.getContextPath() + "/settings");
        return;
    }

    User currentUser =
            (User) session.getAttribute("user");

    String role =
            currentUser != null
                    ? currentUser.getRole()
                    : "ADMIN";

    String dashboardUrl =
            "/dashboard/admin";

    String roleDisplay =
            "ADMIN";

    if ("PROJECT_MANAGER".equals(role)) {

        dashboardUrl =
                "/dashboard/project-manager";

        roleDisplay =
                "PROJECT MANAGER";

    } else if ("TEAM_MEMBER".equals(role)) {

        dashboardUrl =
                "/dashboard/team-member";

        roleDisplay =
                "TEAM MEMBER";
    }
%>

<!DOCTYPE html>
<html lang="en">

<head>

    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>Edit System Setting</title>

    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/dashboard.css">


    <style>

        /* =====================================================
           EDIT SETTING PAGE
           ===================================================== */

        .edit-setting-page {
            max-width: 1050px;
            margin: 0 auto;
        }


        /* =====================================================
           PAGE INTRO
           ===================================================== */

        .edit-setting-heading {
            margin-bottom: 24px;
        }

        .edit-setting-heading h1 {
            margin: 0 0 6px;

            font-size: 30px;
        }

        .edit-setting-heading p {
            margin: 0;

            max-width: 650px;

            color: var(--text-muted);

            font-size: 14px;

            line-height: 1.5;
        }


        /* =====================================================
           SETTING ID
           ===================================================== */

        .setting-id-label {

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

        .setting-id-label strong {
            color: var(--text);
        }


        /* =====================================================
           MAIN LAYOUT
           ===================================================== */

        .edit-setting-layout {

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

        .setting-form-card {

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

        .setting-form-group {
            margin-bottom: 20px;
        }

        .setting-form-group:last-of-type {
            margin-bottom: 0;
        }

        .setting-form-group label {

            display: block;

            margin-bottom: 7px;

            color: var(--text);

            font-size: 12px;

            font-weight: bold;
        }

        .setting-form-group input {

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

        .setting-form-group input:focus {

            border-color: var(--primary);

            box-shadow:
                0 0 0 3px
                rgba(47, 127, 120, 0.11);
        }

        .setting-form-group input::placeholder {
            color: var(--text-light);
        }

        .field-hint {

            margin: 6px 0 0;

            color: var(--text-light);

            font-size: 11px;

            line-height: 1.4;
        }


        /* =====================================================
           SETTING VALUE BOX
           ===================================================== */

        .value-box {

            padding: 15px;

            border: 1px solid var(--border);

            border-radius: 9px;

            background: var(--surface-soft);
        }


        /* =====================================================
           FORM ACTIONS
           ===================================================== */

        .setting-form-actions {

            display: flex;

            align-items: center;

            gap: 10px;

            margin-top: 25px;

            padding-top: 20px;

            border-top: 1px solid var(--border-light);
        }

        .setting-form-actions .btn {

            min-width: 140px;

            justify-content: center;
        }


        /* =====================================================
           INFORMATION COLUMN
           ===================================================== */

        .setting-info-column {

            display: flex;

            flex-direction: column;

            gap: 14px;
        }

        .setting-info-card {

            padding: 20px;

            background: var(--surface);

            border: 1px solid var(--border);

            border-radius: var(--radius);

            box-shadow: var(--shadow);
        }

        .setting-info-card.accent {

            background:
                linear-gradient(
                    135deg,
                    var(--primary-soft),
                    var(--surface)
                );
        }

        .setting-info-icon {

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

        .setting-info-card h3 {

            margin: 0 0 7px;

            font-size: 15px;
        }

        .setting-info-card p {

            margin: 0;

            color: var(--text-muted);

            font-size: 12px;

            line-height: 1.55;
        }


        /* =====================================================
           SETTING SUMMARY
           ===================================================== */

        .setting-summary {

            margin-top: 15px;
        }

        .summary-item {

            padding: 11px;

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

        .setting-tips {

            margin: 15px 0 0;

            padding: 0;

            list-style: none;
        }

        .setting-tips li {

            position: relative;

            padding-left: 17px;

            margin-bottom: 10px;

            color: var(--text-muted);

            font-size: 11px;

            line-height: 1.45;
        }

        .setting-tips li:last-child {
            margin-bottom: 0;
        }

        .setting-tips li::before {

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

            .edit-setting-layout {

                grid-template-columns: 1fr;

            }

            .setting-info-column {

                display: grid;

                grid-template-columns:
                    1fr 1fr;

            }

        }


        @media (max-width: 650px) {

            .edit-setting-heading h1 {
                font-size: 26px;
            }

            .setting-form-card {
                padding: 20px;
            }

            .setting-info-column {
                grid-template-columns: 1fr;
            }

        }


        @media (max-width: 450px) {

            .setting-form-actions {

                flex-direction: column;

                align-items: stretch;

            }

            .setting-form-actions .btn {
                width: 100%;
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
               class="sidebar-link">

                <span class="sidebar-icon">
                    &#9745;
                </span>

                Tasks

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
                   class="sidebar-link active">

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
                        Edit System Setting
                    </h1>

                    <p>
                        Update a configuration value used by the system.
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


            <div class="edit-setting-page">


                <!-- =================================================
                     PAGE INTRO
                     ================================================= -->

                <div class="edit-setting-heading">

                    <h1>
                        Update Setting
                    </h1>

                    <p>
                        Change the setting information below. Be careful
                        when modifying configuration values because they
                        may affect how parts of the application behave.
                    </p>


                    <div class="setting-id-label">

                        Setting ID

                        <strong>
                            #<%= setting.getSettingId() %>
                        </strong>

                    </div>

                </div>


                <!-- =================================================
                     FORM + INFORMATION
                     ================================================= -->

                <div class="edit-setting-layout">


                    <!-- =================================================
                         FORM
                         ================================================= -->

                    <div class="setting-form-card">


                        <div class="form-card-heading">

                            <h2>
                                Setting Details
                            </h2>

                            <p>
                                Update the setting name or its stored
                                value.
                            </p>

                        </div>


                        <form action="${pageContext.request.contextPath}/settings/update"
                              method="post">


                            <!-- CSRF -->

                            <input type="hidden"
                                   name="csrfToken"
                                   value="${sessionScope.csrfToken}">


                            <!-- SETTING ID -->

                            <input type="hidden"
                                   name="settingId"
                                   value="<%= setting.getSettingId() %>">


                            <!-- SETTING NAME -->

                            <div class="setting-form-group">

                                <label for="settingName">
                                    Setting Name
                                </label>


                                <input type="text"
                                       id="settingName"
                                       name="settingName"
                                       maxlength="100"
                                       value="<%= HtmlUtil.escape(setting.getSettingName()) %>"
                                       required>


                                <p class="field-hint">
                                    Maximum 100 characters.
                                </p>

                            </div>


                            <!-- SETTING VALUE -->

                            <div class="setting-form-group value-box">

                                <label for="settingValue">
                                    Setting Value
                                </label>


                                <input type="text"
                                       id="settingValue"
                                       name="settingValue"
                                       maxlength="255"
                                       value="<%= HtmlUtil.escape(setting.getSettingValue()) %>"
                                       required>


                                <p class="field-hint">
                                    Enter the value that should be
                                    stored for this setting.
                                </p>

                            </div>


                            <!-- ACTIONS -->

                            <div class="setting-form-actions">


                                <button type="submit"
                                        class="btn btn-primary">

                                    Update Setting

                                </button>


                                <a href="${pageContext.request.contextPath}/settings"
                                   class="btn btn-secondary">

                                    Back to Settings

                                </a>


                            </div>


                        </form>


                    </div>


                    <!-- =================================================
                         INFORMATION COLUMN
                         ================================================= -->

                    <div class="setting-info-column">


                        <div class="setting-info-card accent">


                            <div class="setting-info-icon">
                                &#9881;
                            </div>


                            <h3>
                                Editing configuration
                            </h3>


                            <p>
                                This setting is stored as a name and
                                value. Update it carefully so the
                                application continues to use the
                                expected configuration.
                            </p>


                            <div class="setting-summary">


                                <div class="summary-item">

                                    <span class="summary-label">
                                        Setting
                                    </span>

                                    <span class="summary-value">

                                        <%= HtmlUtil.escape(
                                                setting.getSettingName()
                                        ) %>

                                    </span>

                                </div>


                            </div>


                        </div>


                        <div class="setting-info-card">


                            <h3>
                                Keep values intentional
                            </h3>


                            <p>
                                Before saving, make sure the new value
                                matches the format expected by the
                                application.
                            </p>


                            <ul class="setting-tips">

                                <li>
                                    Check the setting name before
                                    changing it.
                                </li>

                                <li>
                                    Keep the value within the allowed
                                    255-character limit.
                                </li>

                                <li>
                                    Avoid changing configuration
                                    values without a reason.
                                </li>

                            </ul>


                        </div>


                        <div class="setting-info-card">


                            <h3>
                                Administrator area
                            </h3>


                            <p>
                                System settings are part of the
                                administration section and should
                                normally only be changed when you know
                                what the setting controls.
                            </p>


                        </div>


                    </div>


                </div>


                <!-- =================================================
                     BACK LINK
                     ================================================= -->

                <div style="margin-top: 22px;">

                    <a class="back-link"
                       href="${pageContext.request.contextPath}/settings">

                        ← Back to Settings

                    </a>

                </div>


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