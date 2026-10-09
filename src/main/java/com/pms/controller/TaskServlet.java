package com.pms.controller;

import com.pms.dao.ProjectDAO;
import com.pms.dao.TaskDAO;
import com.pms.model.Project;
import com.pms.model.Task;
import com.pms.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

/** Legacy task routes with explicit task/project authorization. */
@WebServlet("/tasks/*")
public class TaskServlet extends BaseServlet {
    private final TaskDAO taskDAO = new TaskDAO();
    private final ProjectDAO projectDAO = new ProjectDAO();

    private Integer positiveId(String value) {
        try { int id = Integer.parseInt(value); return id > 0 ? id : null; }
        catch (Exception ex) { return null; }
    }
    private boolean canViewProject(User user, Project project) {
        return project != null && ("ADMIN".equals(user.getRole()) || "TEAM_MEMBER".equals(user.getRole())
                || ("PROJECT_MANAGER".equals(user.getRole()) && project.getManagerId() == user.getUserId()));
    }
    private boolean canManageProject(User user, Project project) {
        return project != null && ("ADMIN".equals(user.getRole())
                || ("PROJECT_MANAGER".equals(user.getRole()) && project.getManagerId() == user.getUserId()));
    }
    private boolean canViewTask(User user, Task task) {
        if (task == null) return false;
        if ("ADMIN".equals(user.getRole())) return true;
        if ("TEAM_MEMBER".equals(user.getRole())) return task.getAssigneeId() == user.getUserId();
        Project project = projectDAO.getProjectById(task.getProjectId());
        return "PROJECT_MANAGER".equals(user.getRole()) && project != null && project.getManagerId() == user.getUserId();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        User user = getLoggedInUser(request);
        if (user == null) { response.sendRedirect(request.getContextPath() + "/index.html"); return; }
        String action = request.getPathInfo();
        if (action == null || "/".equals(action) || "/list".equals(action)) {
            Integer projectId = positiveId(request.getParameter("projectId"));
            if (projectId == null) { response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid project ID."); return; }
            Project project = projectDAO.getProjectById(projectId);
            if (project == null) { response.sendError(HttpServletResponse.SC_NOT_FOUND, "Project not found."); return; }
            if (!canViewProject(user, project)) { response.sendError(HttpServletResponse.SC_FORBIDDEN); return; }
            List<Task> tasks = taskDAO.getTasksByProjectId(projectId);
            if ("TEAM_MEMBER".equals(user.getRole())) tasks.removeIf(task -> task.getAssigneeId() != user.getUserId());
            request.setAttribute("project", project); request.setAttribute("tasks", tasks);
            request.getRequestDispatcher("/dashboard/task-list.jsp").forward(request, response); return;
        }
        if ("/detail".equals(action)) {
            Integer taskId = positiveId(request.getParameter("id"));
            if (taskId == null) { response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid task ID."); return; }
            Task task = taskDAO.getTaskById(taskId);
            if (task == null) { response.sendError(HttpServletResponse.SC_NOT_FOUND, "Task not found."); return; }
            if (!canViewTask(user, task)) { response.sendError(HttpServletResponse.SC_FORBIDDEN); return; }
            response.sendRedirect(request.getContextPath() + "/tasks/view?id=" + taskId); return;
        }
        response.sendError(HttpServletResponse.SC_NOT_FOUND);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        if (!validateCsrf(request)) { denyCsrf(response); return; }
        User user = getLoggedInUser(request);
        if (user == null) { response.sendRedirect(request.getContextPath() + "/index.html"); return; }
        String action = request.getParameter("action");
        if ("create".equals(action)) {
            Integer projectId = positiveId(request.getParameter("projectId"));
            Integer assigneeId = positiveId(request.getParameter("assigneeId"));
            Project project = projectId == null ? null : projectDAO.getProjectById(projectId);
            if (!canManageProject(user, project)) { response.sendError(project == null ? HttpServletResponse.SC_NOT_FOUND : HttpServletResponse.SC_FORBIDDEN); return; }
            String title = request.getParameter("title"); String description = request.getParameter("description");
            if (title == null || title.trim().isEmpty() || title.trim().length() > 150 || (description != null && description.length() > 2000)) { response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid task details."); return; }
            Task task = new Task(); task.setTitle(title.trim()); task.setDescription(description == null ? "" : description.trim());
            task.setProjectId(projectId); task.setAssigneeId(assigneeId == null ? 0 : assigneeId); task.setStatus("PENDING");
            if (!taskDAO.createTask(task)) { response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Task could not be created."); return; }
            response.sendRedirect(request.getContextPath() + "/tasks/list?projectId=" + projectId); return;
        }
        Integer taskId = positiveId(request.getParameter("id"));
        if (taskId == null) { response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid task ID."); return; }
        Task task = taskDAO.getTaskById(taskId);
        if (task == null) { response.sendError(HttpServletResponse.SC_NOT_FOUND, "Task not found."); return; }
        Project project = projectDAO.getProjectById(task.getProjectId());
        if (!canManageProject(user, project)) { response.sendError(HttpServletResponse.SC_FORBIDDEN); return; }
        if ("edit".equals(action)) {
            String title = request.getParameter("title"); String description = request.getParameter("description");
            Integer assigneeId = positiveId(request.getParameter("assigneeId")); String status = request.getParameter("status");
            if (title == null || title.trim().isEmpty() || title.trim().length() > 150 || (description != null && description.length() > 2000)
                    || (status != null && !List.of("PENDING", "IN_PROGRESS", "COMPLETED").contains(status))) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid task details."); return;
            }
            task.setTitle(title.trim()); task.setDescription(description == null ? "" : description.trim());
            if (assigneeId != null) task.setAssigneeId(assigneeId); if (status != null) task.setStatus(status);
            if (!taskDAO.updateTask(task)) { response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Task could not be updated."); return; }
        } else if ("delete".equals(action)) {
            if (!"ADMIN".equals(user.getRole())) { response.sendError(HttpServletResponse.SC_FORBIDDEN, "Only administrators can delete tasks."); return; }
            if (!taskDAO.deleteTask(taskId)) { response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Task could not be deleted."); return; }
        } else { response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Unknown action."); return; }
        response.sendRedirect(request.getContextPath() + "/tasks/list?projectId=" + task.getProjectId());
    }
}
