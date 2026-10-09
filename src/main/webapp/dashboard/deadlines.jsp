<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List,java.util.Collections,com.pms.model.Task,com.pms.model.User,com.pms.util.HtmlUtil" %>
<%
    User currentUser = (User) session.getAttribute("user");
    List<Task> overdueTasks = (List<Task>) request.getAttribute("overdueTasks");
    if (overdueTasks == null) overdueTasks = Collections.emptyList();
    List<Task> dueSoonTasks = (List<Task>) request.getAttribute("dueSoonTasks");
    if (dueSoonTasks == null) dueSoonTasks = Collections.emptyList();
    List<Task> missingDateTasks = (List<Task>) request.getAttribute("missingDateTasks");
    if (missingDateTasks == null) missingDateTasks = Collections.emptyList();
    String ctx = request.getContextPath();
    String activeFeature = "deadlines";
%>
<!DOCTYPE html><html lang="en"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Due-date alerts · Project Management</title>
<link rel="stylesheet" href="<%=ctx%>/css/dashboard.css"><link rel="stylesheet" href="<%=ctx%>/css/ui-polish.css"></head>
<body><div class="app-layout">
<%@ include file="feature-sidebar.jspf" %>
<main class="main-content">
<header class="topbar">
  <div class="topbar-left">
    <button type="button" class="sidebar-toggle" id="sidebarToggle" aria-label="Toggle navigation" aria-expanded="false">&#9776;</button>
    <div><h1>Workspace</h1><p>Due-date alerts</p></div>
  </div>
  <div class="topbar-actions">
    <button type="button" class="theme-toggle" id="themeToggle" aria-label="Switch theme" title="Switch theme">&#9790;</button>
  </div>
</header>
<div class="page-content"><div class="feature-page">
<header class="feature-header"><div><p class="feature-eyebrow">WORKSPACE / DEADLINES</p><h1>Due-date alerts</h1><p class="feature-subtitle">A live view of overdue work, tasks due within the next three days, and tasks that still need a deadline.</p></div><div class="feature-header-actions"><a class="feature-button feature-button-secondary" href="<%=ctx%>/tasks">All tasks</a><a class="feature-button" href="<%=ctx%>/kanban">Open Kanban board <span aria-hidden="true">↗</span></a></div></header>
<section class="feature-summary"><div class="summary-danger"><span class="feature-summary-label">Overdue</span><strong><%=overdueTasks.size()%></strong><small>Past due date</small></div><div class="summary-warning"><span class="feature-summary-label">Due soon</span><strong><%=dueSoonTasks.size()%></strong><small>Today through the next 3 days</small></div><div><span class="feature-summary-label">Missing due date</span><strong><%=missingDateTasks.size()%></strong><small>Open tasks without a deadline</small></div></section>
<section class="deadline-section"><div class="deadline-section-head"><div><span class="deadline-section-icon deadline-icon-danger">!</span><div><h2>Overdue</h2><p>Open tasks whose due date has passed.</p></div></div><span class="kanban-count"><%=overdueTasks.size()%></span></div>
<% if (overdueTasks.isEmpty()) { %><div class="feature-empty"><span class="feature-empty-mark">✓</span><strong>You're clear here</strong><p>No overdue open tasks in the tasks visible to your account.</p></div><% } else { %><div class="deadline-list"><% for (Task task : overdueTasks) { %><article class="deadline-item deadline-item-overdue"><div class="deadline-item-main"><span class="priority-pill priority-<%=(task.getPriority() != null && ("LOW".equalsIgnoreCase(task.getPriority()) || "MEDIUM".equalsIgnoreCase(task.getPriority()) || "HIGH".equalsIgnoreCase(task.getPriority()) || "URGENT".equalsIgnoreCase(task.getPriority())) ? task.getPriority().toLowerCase() : "medium")%>"><%=HtmlUtil.escape(task.getPriority() == null ? "MEDIUM" : task.getPriority())%></span><h3><a href="<%=ctx%>/tasks/view?id=<%=task.getTaskId()%>"><%=HtmlUtil.escape(task.getTitle())%></a></h3><p>Project #<%=task.getProjectId()%> · Task #<%=task.getTaskId()%></p></div><div class="deadline-date"><span>Due date</span><strong><%=task.getDueDate()%></strong></div><a class="deadline-open" href="<%=ctx%>/tasks/view?id=<%=task.getTaskId()%>" aria-label="Open task <%=task.getTaskId()%>">↗</a></article><% } %></div><% } %></section>
<section class="deadline-section"><div class="deadline-section-head"><div><span class="deadline-section-icon deadline-icon-warning">◷</span><div><h2>Due in the next 3 days</h2><p>Includes tasks due today.</p></div></div><span class="kanban-count"><%=dueSoonTasks.size()%></span></div>
<% if (dueSoonTasks.isEmpty()) { %><div class="feature-empty"><span class="feature-empty-mark">✓</span><strong>No upcoming deadlines</strong><p>There are no open tasks due between today and the next three days.</p></div><% } else { %><div class="deadline-list"><% for (Task task : dueSoonTasks) { %><article class="deadline-item"><div class="deadline-item-main"><span class="priority-pill priority-<%=(task.getPriority() != null && ("LOW".equalsIgnoreCase(task.getPriority()) || "MEDIUM".equalsIgnoreCase(task.getPriority()) || "HIGH".equalsIgnoreCase(task.getPriority()) || "URGENT".equalsIgnoreCase(task.getPriority())) ? task.getPriority().toLowerCase() : "medium")%>"><%=HtmlUtil.escape(task.getPriority() == null ? "MEDIUM" : task.getPriority())%></span><h3><a href="<%=ctx%>/tasks/view?id=<%=task.getTaskId()%>"><%=HtmlUtil.escape(task.getTitle())%></a></h3><p>Project #<%=task.getProjectId()%> · Task #<%=task.getTaskId()%></p></div><div class="deadline-date"><span>Due date</span><strong><%=task.getDueDate()%></strong></div><a class="deadline-open" href="<%=ctx%>/tasks/view?id=<%=task.getTaskId()%>" aria-label="Open task <%=task.getTaskId()%>">↗</a></article><% } %></div><% } %></section>
<section class="deadline-section"><div class="deadline-section-head"><div><span class="deadline-section-icon">○</span><div><h2>Missing due dates</h2><p>Open tasks that have no deadline assigned yet.</p></div></div><span class="kanban-count"><%=missingDateTasks.size()%></span></div>
<% if (missingDateTasks.isEmpty()) { %><div class="feature-empty feature-empty-compact"><strong>Every open task has a due date.</strong></div><% } else { %><div class="deadline-list"><% for (Task task : missingDateTasks) { %><article class="deadline-item"><div class="deadline-item-main"><span class="priority-pill priority-<%=(task.getPriority() != null && ("LOW".equalsIgnoreCase(task.getPriority()) || "MEDIUM".equalsIgnoreCase(task.getPriority()) || "HIGH".equalsIgnoreCase(task.getPriority()) || "URGENT".equalsIgnoreCase(task.getPriority())) ? task.getPriority().toLowerCase() : "medium")%>"><%=HtmlUtil.escape(task.getPriority() == null ? "MEDIUM" : task.getPriority())%></span><h3><a href="<%=ctx%>/tasks/view?id=<%=task.getTaskId()%>"><%=HtmlUtil.escape(task.getTitle())%></a></h3><p>Project #<%=task.getProjectId()%> · Task #<%=task.getTaskId()%></p></div><div class="deadline-date"><span>Due date</span><strong>Not set</strong></div><a class="deadline-open" href="<%=ctx%>/tasks/view?id=<%=task.getTaskId()%>" aria-label="Open task <%=task.getTaskId()%>">↗</a></article><% } %></div><% } %></section>
<footer class="feature-footer"><span>Live from your existing task records. Completed tasks are excluded.</span><span>Signed in as <%=HtmlUtil.escape(currentUser == null ? "user" : (currentUser.getRole() == null ? "user" : currentUser.getRole().replace('_',' ')))%></span></footer>
</div></div></main></div><script src="<%=ctx%>/js/feature-shell.js" defer></script><script src="<%=ctx%>/js/theme-toggle.js" defer></script></body></html>
