<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List,java.util.Collections,com.pms.model.Task,com.pms.model.User,com.pms.util.HtmlUtil" %>
<%
    User currentUser = (User) session.getAttribute("user");
    List<Task> pendingTasks = (List<Task>) request.getAttribute("pendingTasks");
    if (pendingTasks == null) pendingTasks = Collections.emptyList();
    List<Task> inProgressTasks = (List<Task>) request.getAttribute("inProgressTasks");
    if (inProgressTasks == null) inProgressTasks = Collections.emptyList();
    List<Task> completedTasks = (List<Task>) request.getAttribute("completedTasks");
    if (completedTasks == null) completedTasks = Collections.emptyList();
    String ctx = request.getContextPath();
    String activeFeature = "kanban";
%>
<!DOCTYPE html><html lang="en"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Kanban Board · Project Management</title>
<link rel="stylesheet" href="<%=ctx%>/css/dashboard.css"><link rel="stylesheet" href="<%=ctx%>/css/ui-polish.css"></head>
<body><div class="app-layout">
<%@ include file="feature-sidebar.jspf" %>
<main class="main-content">
<header class="topbar">
  <div class="topbar-left">
    <button type="button" class="sidebar-toggle" id="sidebarToggle" aria-label="Toggle navigation" aria-expanded="false">&#9776;</button>
    <div><h1>Workspace</h1><p>Kanban board</p></div>
  </div>
  <div class="topbar-actions">
    <button type="button" class="theme-toggle" id="themeToggle" aria-label="Switch theme" title="Switch theme">&#9790;</button>
  </div>
</header>
<div class="page-content"><div class="feature-page">
<header class="feature-header"><div><p class="feature-eyebrow">WORKSPACE / VISUAL BOARD</p><h1>Kanban board</h1><p class="feature-subtitle">See work move from pending to in progress to completed. Only tasks you are allowed to view appear here.</p></div><div class="feature-header-actions"><a class="feature-button feature-button-secondary" href="<%=ctx%>/tasks">List view</a><a class="feature-button" href="<%=ctx%>/deadlines">Due-date alerts <span aria-hidden="true">↗</span></a></div></header>
<section class="feature-summary"><div><span class="feature-summary-label">Visible tasks</span><strong><%= request.getAttribute("kanbanTotal") %></strong></div><div><span class="feature-summary-label">Pending</span><strong><%= pendingTasks.size() %></strong></div><div><span class="feature-summary-label">In progress</span><strong><%= inProgressTasks.size() %></strong></div><div><span class="feature-summary-label">Completed</span><strong><%= completedTasks.size() %></strong></div></section>
<section class="kanban-grid" aria-label="Tasks grouped by status">
<% String[] titles = {"Pending", "In progress", "Completed"}; String[] keys = {"pending", "progress", "completed"}; List<Task>[] groups = new List[]{pendingTasks, inProgressTasks, completedTasks}; for (int g=0; g<groups.length; g++) { %>
<div class="kanban-column kanban-<%=keys[g]%>"><div class="kanban-column-head"><div><span class="kanban-dot"></span><h2><%=titles[g]%></h2></div><span class="kanban-count"><%=groups[g].size()%></span></div><div class="kanban-cards">
<% if (groups[g].isEmpty()) { %><div class="feature-empty feature-empty-small"><span class="feature-empty-mark">✓</span><strong>Nothing here yet</strong><p>Tasks will appear here when their status matches this column.</p></div><% } else { for (Task task : groups[g]) { String priority = task.getPriority() == null ? "MEDIUM" : task.getPriority().toUpperCase(); String priorityClass = ("LOW".equals(priority)||"MEDIUM".equals(priority)||"HIGH".equals(priority)||"URGENT".equals(priority)) ? priority.toLowerCase() : "medium"; %>
<article class="kanban-card"><div class="kanban-card-meta"><span class="priority-pill priority-<%=priorityClass%>"><%=HtmlUtil.escape(priority)%></span><span class="kanban-task-id">#<%=task.getTaskId()%></span></div><h3><a href="<%=ctx%>/tasks/view?id=<%=task.getTaskId()%>"><%=HtmlUtil.escape(task.getTitle())%></a></h3><p class="kanban-card-description"><%=HtmlUtil.escape(task.getDescription() == null || task.getDescription().trim().isEmpty() ? "No description provided." : task.getDescription())%></p><div class="kanban-card-footer"><span>Project #<%=task.getProjectId()%></span><span class="kanban-due"><% if (task.getDueDate() != null) { %>Due <%=task.getDueDate()%><% } else { %>No due date<% } %></span></div></article>
<% } } %></div></div><% } %>
</section><footer class="feature-footer"><span>Showing database tasks visible to <%=HtmlUtil.escape(currentUser == null ? "your account" : (currentUser.getRole() == null ? "user" : currentUser.getRole().replace('_',' ')))%>.</span><a href="<%=ctx%>/tasks">Open task list →</a></footer>
</div></div></main></div><script src="<%=ctx%>/js/feature-shell.js" defer></script><script src="<%=ctx%>/js/theme-toggle.js" defer></script></body></html>
