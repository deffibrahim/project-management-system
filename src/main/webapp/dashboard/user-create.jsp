<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.pms.model.User" %>
<%@ page import="com.pms.util.HtmlUtil" %>
<%@ page import="com.pms.util.AppSettings" %>

<%
    String formError = (String) request.getAttribute("formError");
    String formName = (String) request.getAttribute("formName");
    String formEmail = (String) request.getAttribute("formEmail");
    String formRole = (String) request.getAttribute("formRole");

    if (formName == null) formName = "";
    if (formEmail == null) formEmail = "";
    if (formRole == null) formRole = "TEAM_MEMBER";
%>

<!DOCTYPE html>
<html lang="en">

<head>

    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>Add User | Project Management Tool</title>

    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/dashboard.css">

    <style>

        .create-user-page {
            max-width: 760px;
            margin: 0 auto;
        }

        .create-user-page .form-card {
            max-width: none;
            padding: 27px;
        }

        .create-user-page .form-section {
            display: block;
        }

        .form-error {
            margin: 0 0 18px;
            padding: 11px 14px;
            border-radius: 9px;
            border: 1px solid #e0a39c;
            background: #fbeceb;
            color: #8a2c22;
            font-size: 0.92rem;
        }

        .form-actions {
            display: flex;
            gap: 12px;
            align-items: center;
            flex-wrap: wrap;
        }

        .form-actions .back-link {
            text-decoration: none;
        }

    </style>

</head>

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
                        Add User
                    </h1>

                    <p>
                        Create a new account for your workspace.
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

            <div class="create-user-page">

                <div class="form-section">

                    <div class="form-card">

                        <h3>User Information</h3>

                        <% if (formError != null) { %>
                        <p class="form-error" role="alert"><%= HtmlUtil.escape(formError) %></p>
                        <% } %>

                        <form action="${pageContext.request.contextPath}/users/create"
                              method="post">

                            <input type="hidden"
                                   name="csrfToken"
                                   value="${sessionScope.csrfToken}">

                            <div class="form-group">
                                <label for="name">Full Name</label>
                                <input type="text" id="name" name="name"
                                       maxlength="100"
                                       placeholder="Enter full name"
                                       autocomplete="name"
                                       value="<%= HtmlUtil.escape(formName) %>"
                                       required>
                            </div>

                            <div class="form-group">
                                <label for="email">Email Address</label>
                                <input type="email" id="email" name="email"
                                       maxlength="100"
                                       placeholder="name@example.com"
                                       autocomplete="email"
                                       value="<%= HtmlUtil.escape(formEmail) %>"
                                       required>
                            </div>

                            <div class="form-group">
                                <label for="password">Temporary Password</label>
                                <input type="password" id="password" name="password"
                                       minlength="<%= AppSettings.getMinPasswordLength() %>" maxlength="72"
                                       placeholder="Enter a password"
                                       autocomplete="new-password"
                                       required>
                            </div>

                            <div class="form-group">
                                <label for="role">User Role</label>
                                <select id="role" name="role" required>
                                    <option value="PROJECT_MANAGER" <%= "PROJECT_MANAGER".equals(formRole) ? "selected" : "" %>>Project Manager</option>
                                    <option value="TEAM_MEMBER" <%= "TEAM_MEMBER".equals(formRole) ? "selected" : "" %>>Team Member</option>
                                    <option value="ADMIN" <%= "ADMIN".equals(formRole) ? "selected" : "" %>>Admin</option>
                                </select>
                            </div>

                            <div class="form-actions">
                                <button class="form-button" type="submit">+ Create User</button>
                                <a class="back-link"
                                   href="${pageContext.request.contextPath}/users">&larr; Back to Users</a>
                            </div>

                        </form>

                    </div>

                </div>

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



    })();

</script>

</body>
</html>
