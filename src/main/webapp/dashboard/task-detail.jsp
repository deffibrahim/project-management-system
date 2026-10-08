<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="com.pms.model.Task" %>
<%@ page import="com.pms.model.Project" %>
<%@ page import="com.pms.model.User" %>
<%@ page import="com.pms.model.Comment" %>
<%@ page import="com.pms.util.HtmlUtil" %>
<%@ page import="com.pms.util.TaskUi" %>

<%
    Task task = (Task) request.getAttribute("task");

    if (task == null) {
        response.sendRedirect(request.getContextPath() + "/tasks");
        return;
    }

    Project project = (Project) request.getAttribute("project");
    User assignee = (User) request.getAttribute("assignee");
    List<Comment> comments = (List<Comment>) request.getAttribute("comments");

    Boolean canCommentAttr = (Boolean) request.getAttribute("canComment");
    boolean canComment = canCommentAttr == null || canCommentAttr;

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

    String status = task.getStatus() != null ? task.getStatus() : "";
    String statusClass = "pending";

    if ("IN_PROGRESS".equals(status)) {
        statusClass = "in-progress";
    } else if ("COMPLETED".equals(status)) {
        statusClass = "completed";
    }

    String description = task.getDescription();

    if (description == null || description.trim().isEmpty()) {
        description = "No description provided.";
    }

    String errorMessage = request.getParameter("error");

    SimpleDateFormat dateFormat = new SimpleDateFormat("dd MMM yyyy, HH:mm");
%>

<!DOCTYPE html>
<html lang="en">

<head>

    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title><%= HtmlUtil.escape(task.getTitle()) %> | Project Management Tool</title>

    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/dashboard.css">

    <style>

        .task-detail-page {
            max-width: 860px;
            margin: 0 auto;
        }

        .detail-card {
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: 12px;
            padding: 24px;
            margin-bottom: 20px;
            box-shadow: var(--shadow);
        }

        .detail-head {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            gap: 16px;
            flex-wrap: wrap;
            margin-bottom: 6px;
        }

        .detail-head h2 {
            margin: 0;
            font-size: 1.5rem;
        }

        .detail-badges {
            display: flex;
            gap: 8px;
            flex-wrap: wrap;
            align-items: center;
        }

        .detail-description {
            color: var(--text-muted);
            line-height: 1.65;
            margin: 14px 0 20px;
            white-space: pre-wrap;
        }

        .detail-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
            gap: 16px;
            padding-top: 18px;
            border-top: 1px solid var(--border);
        }

        .detail-label {
            margin: 0 0 4px;
            font-size: 0.74rem;
            font-weight: 700;
            letter-spacing: 0.06em;
            text-transform: uppercase;
            color: var(--text-light);
        }

        .detail-value {
            margin: 0;
            font-weight: 600;
        }

        .detail-actions {
            display: flex;
            gap: 12px;
            flex-wrap: wrap;
            margin-top: 22px;
        }

        .comments-title {
            margin: 0 0 16px;
            font-size: 1.15rem;
        }

        .comment {
            padding: 14px 0;
            border-top: 1px solid var(--border-light);
        }

        .comment:first-of-type {
            border-top: none;
        }

        .comment-meta {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 10px;
            flex-wrap: wrap;
            margin-bottom: 6px;
            font-size: 0.86rem;
            color: var(--text-muted);
        }

        .comment-author {
            font-weight: 700;
            color: var(--text);
        }

        .comment-role {
            font-size: 0.72rem;
            font-weight: 700;
            letter-spacing: 0.05em;
            padding: 2px 8px;
            border-radius: 999px;
            background: var(--surface-hover);
            color: var(--text-muted);
            margin-left: 6px;
        }

        .comment-body {
            margin: 0;
            line-height: 1.6;
            word-break: break-word;
        }

        .comment-delete {
            appearance: none;
            border: none;
            background: none;
            color: var(--danger);
            font: inherit;
            font-size: 0.82rem;
            font-weight: 600;
            cursor: pointer;
            padding: 0;
        }

        .comment-delete:hover {
            text-decoration: underline;
        }

        .no-comments {
            color: var(--text-muted);
            margin: 0 0 8px;
        }

        .comment-form textarea {
            width: 100%;
            min-height: 90px;
            resize: vertical;
            padding: 11px 13px;
            border: 1px solid var(--border);
            border-radius: 9px;
            background: var(--surface-soft);
            color: var(--text);
            font: inherit;
            box-sizing: border-box;
        }

        .comment-form textarea:focus {
            outline: none;
            border-color: var(--primary);
            box-shadow: 0 0 0 3px var(--primary-soft);
        }

        .comment-form-footer {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 12px;
            margin-top: 10px;
            flex-wrap: wrap;
        }

        .comment-count {
            font-size: 0.82rem;
            color: var(--text-light);
        }

        .detail-error {
            margin: 0 0 14px;
            padding: 11px 14px;
            border-radius: 9px;
            border: 1px solid var(--danger);
            background: var(--danger-soft);
            color: var(--danger-hover);
            font-size: 0.92rem;
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
               class="sidebar-link active">
                <span class="sidebar-icon">&#9745;</span>
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
                    <h1>Task #<%= task.getTaskId() %></h1>
                    <p>Details and discussion</p>
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

            <div class="task-detail-page">

                <!-- ================= TASK ================= -->

                <div class="detail-card">

                    <div class="detail-head">

                        <h2><%= HtmlUtil.escape(task.getTitle()) %></h2>

                        <div class="detail-badges">
                            <span class="badge badge-<%= statusClass %>">
                                <%= HtmlUtil.escape(status) %>
                            </span>
                            <%= TaskUi.priorityBadge(task) %>
                            <%= TaskUi.overdueBadge(task) %>
                        </div>

                    </div>

                    <p class="detail-description"><%= HtmlUtil.escape(description) %></p>

                    <div class="detail-grid">

                        <div>
                            <p class="detail-label">Project</p>
                            <p class="detail-value">
                                <%= project != null
                                        ? HtmlUtil.escape(project.getTitle())
                                        : "Project #" + task.getProjectId() %>
                            </p>
                        </div>

                        <div>
                            <p class="detail-label">Assignee</p>
                            <p class="detail-value">
                                <%= assignee != null
                                        ? HtmlUtil.escape(assignee.getName())
                                        : "Unassigned" %>
                            </p>
                        </div>

                        <div>
                            <p class="detail-label">Due Date</p>
                            <p class="detail-value">
                                <%= task.getDueDate() == null
                                        ? "-"
                                        : task.getDueDate().toString() %>
                            </p>
                        </div>

                    </div>

                    <div class="detail-actions">

                        <a class="btn btn-primary"
                           href="${pageContext.request.contextPath}/tasks/edit?id=<%= task.getTaskId() %>">
                            Edit Task
                        </a>

                        <a class="back-link"
                           href="${pageContext.request.contextPath}/tasks">
                            &larr; Back to Tasks
                        </a>

                    </div>

                </div>

                <!-- ================= COMMENTS ================= -->

                <div class="detail-card" id="comments">

                    <h3 class="comments-title">
                        Comments (<%= comments != null ? comments.size() : 0 %>)
                    </h3>

                    <% if (comments == null || comments.isEmpty()) { %>

                    <p class="no-comments">
                        No comments yet. Start the conversation below.
                    </p>

                    <% } else {

                        for (Comment comment : comments) {

                            String author = comment.getAuthorName() != null
                                    ? comment.getAuthorName()
                                    : "Deleted user";

                            String authorRole = comment.getAuthorRole() != null
                                    ? comment.getAuthorRole().replace('_', ' ')
                                    : "";

                            boolean canDelete =
                                    isAdmin
                                    || (currentUser != null
                                        && comment.getUserId() == currentUser.getUserId());
                    %>

                    <div class="comment">

                        <div class="comment-meta">

                            <span>
                                <span class="comment-author"><%= HtmlUtil.escape(author) %></span>
                                <% if (!authorRole.isEmpty()) { %>
                                <span class="comment-role"><%= HtmlUtil.escape(authorRole) %></span>
                                <% } %>
                                &middot;
                                <%= comment.getCreatedAt() != null
                                        ? dateFormat.format(comment.getCreatedAt())
                                        : "" %>
                            </span>

                            <% if (canDelete) { %>

                            <form action="${pageContext.request.contextPath}/tasks/comment"
                                  method="post"
                                  onsubmit="return confirm('Delete this comment?');">

                                <input type="hidden" name="csrfToken"
                                       value="${sessionScope.csrfToken}">
                                <input type="hidden" name="action" value="delete">
                                <input type="hidden" name="commentId"
                                       value="<%= comment.getCommentId() %>">

                                <button type="submit" class="comment-delete">Delete</button>

                            </form>

                            <% } %>

                        </div>

                        <p class="comment-body"><%= HtmlUtil.escape(comment.getBody()).replace("\n", "<br>") %></p>

                    </div>

                    <% } } %>

                    <% if (!canComment) { %>

                    <p class="no-comments" style="margin-top: 14px;">
                        Commenting is turned off for team members.
                    </p>

                    <% } else { %>

                    <form class="comment-form"
                          action="${pageContext.request.contextPath}/tasks/comment"
                          method="post"
                          style="margin-top: 18px;">

                        <% if (errorMessage != null && !errorMessage.isEmpty()) { %>
                        <p class="detail-error" role="alert"><%= HtmlUtil.escape(errorMessage) %></p>
                        <% } %>

                        <input type="hidden" name="csrfToken"
                               value="${sessionScope.csrfToken}">
                        <input type="hidden" name="action" value="add">
                        <input type="hidden" name="taskId" value="<%= task.getTaskId() %>">

                        <textarea name="body"
                                  id="commentBody"
                                  maxlength="1000"
                                  placeholder="Write a comment..."
                                  aria-label="Write a comment"
                                  required></textarea>

                        <div class="comment-form-footer">

                            <span class="comment-count" id="commentCount">0 / 1000</span>

                            <button type="submit" class="btn btn-primary">
                                Post Comment
                            </button>

                        </div>

                    </form>

                    <% } %>

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



        /* Comment character counter */

        const commentBody = document.getElementById("commentBody");
        const commentCount = document.getElementById("commentCount");

        if (commentBody && commentCount) {

            commentBody.addEventListener("input", function () {
                commentCount.textContent = commentBody.value.length + " / 1000";
            });

        }

    })();

</script>

</body>
</html>
