<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.pms.model.User,com.pms.util.HtmlUtil" %>
<%
    User profileUser = (User) request.getAttribute("user");
    if (profileUser == null) { response.sendError(404); return; }
    String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>My Profile</title>
<link rel="stylesheet" href="<%= ctx %>/css/dashboard.css"><link rel="stylesheet" href="<%= ctx %>/css/ui-polish.css"></head>
<body><main class="main-content" style="max-width:900px;margin:3rem auto;padding:2rem;">
<h1>My Profile</h1><p>Account details</p>
<div class="form-card" style="max-width:620px;padding:1.5rem;">
<form action="<%= ctx %>/profile" method="post">
<input type="hidden" name="csrfToken" value="<%= HtmlUtil.escape((String)session.getAttribute("csrfToken")) %>">
<div class="form-group"><label for="name">Name</label><input id="name" name="name" maxlength="100" required value="<%= HtmlUtil.escape(profileUser.getName()) %>"></div>
<div class="form-group"><label for="email">Email</label><input id="email" name="email" type="email" maxlength="100" required value="<%= HtmlUtil.escape(profileUser.getEmail()) %>"></div>
<div class="form-group"><label for="currentPassword">Current password (required to change password)</label><input id="currentPassword" name="currentPassword" type="password" autocomplete="current-password"></div>
<div class="form-group"><label for="password">New password (optional)</label><input id="password" name="password" type="password" minlength="6" maxlength="72" autocomplete="new-password"><small>Leave both password fields blank to keep your current password.</small></div>
<button type="submit" class="form-button">Save profile</button> <a href="<%= ctx %>/settings">Settings</a>
</form></div></main></body></html>
