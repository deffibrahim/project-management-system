package com.pms.controller;

import com.pms.dao.ProjectDAO;
import com.pms.model.Project;
import com.pms.model.Task;
import com.pms.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

/** Handles legacy project routes with the same ownership rules as the primary routes. */
@WebServlet("/projects/*")
public class ProjectServlet extends BaseServlet {
    private final ProjectDAO projectDAO = new ProjectDAO();

    private boolean canView(User user, Project project) {
        return project != null && ("ADMIN".equals(user.getRole())
                || "TEAM_MEMBER".equals(user.getRole())
                || ("PROJECT_MANAGER".equals(user.getRole())
                    && project.getManagerId() == user.getUserId()));
    }

    private boolean canManage(User user, Project project) {
        return project != null && ("ADMIN".equals(user.getRole())
                || ("PROJECT_MANAGER".equals(user.getRole())
                    && project.getManagerId() == user.getUserId()));
    }

    private Integer positiveId(String value) {
        try {
            int id = Integer.parseInt(value);
            return id > 0 ? id : null;
        } catch (Exception ex) {
            return null;
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        User user = getLoggedInUser(request);
        if (user == null) { response.sendRedirect(request.getContextPath() + "/index.html"); return; }
        String action = request.getPathInfo();
        if (action == null || "/".equals(action) || "/list".equals(action)) {
            List<Project> projects;
            if ("ADMIN".equals(user.getRole()) || "TEAM_MEMBER".equals(user.getRole())) projects = projectDAO.getAllProjects();
            else if ("PROJECT_MANAGER".equals(user.getRole())) projects = projectDAO.getProjectsByManagerId(user.getUserId());
            else { response.sendError(HttpServletResponse.SC_FORBIDDEN); return; }
            request.setAttribute("projects", projects);
            request.getRequestDispatcher("/dashboard/projects.jsp").forward(request, response);
            return;
        }
        if ("/detail".equals(action)) {
            Integer id = positiveId(request.getParameter("id"));
            if (id == null) { response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid project ID."); return; }
            Project project = projectDAO.getProjectById(id);
            if (project == null) { response.sendError(HttpServletResponse.SC_NOT_FOUND, "Project not found."); return; }
            if (!canView(user, project)) { response.sendError(HttpServletResponse.SC_FORBIDDEN); return; }
            List<Task> tasks = new com.pms.dao.TaskDAO().getTasksByProjectId(id);
            if ("TEAM_MEMBER".equals(user.getRole())) {
                tasks.removeIf(task -> task.getAssigneeId() != user.getUserId());
            }
            request.setAttribute("project", project);
            request.setAttribute("tasks", tasks);
            request.getRequestDispatcher("/dashboard/project-detail.jsp").forward(request, response);
            return;
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
            if (!("ADMIN".equals(user.getRole()) || "PROJECT_MANAGER".equals(user.getRole()))) { response.sendError(HttpServletResponse.SC_FORBIDDEN); return; }
            if ("PROJECT_MANAGER".equals(user.getRole()) && !com.pms.util.AppSettings.isPmCanCreateProjects()) { response.sendError(HttpServletResponse.SC_FORBIDDEN, "Project managers cannot create projects."); return; }
            String title = request.getParameter("title");
            String description = request.getParameter("description");
            if (title == null || title.trim().isEmpty() || title.trim().length() > 150 || (description != null && description.length() > 2000)) { response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid project details."); return; }
            Project project = new Project(); project.setTitle(title.trim()); project.setDescription(description == null ? "" : description.trim());
            project.setManagerId(user.getUserId()); project.setStatus("PLANNED");
            if (!projectDAO.createProject(project)) { response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Project could not be created."); return; }
            response.sendRedirect(request.getContextPath() + "/projects"); return;
        }
        Integer id = positiveId(request.getParameter("id"));
        if (id == null) { response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid project ID."); return; }
        Project project = projectDAO.getProjectById(id);
        if (project == null) { response.sendError(HttpServletResponse.SC_NOT_FOUND, "Project not found."); return; }
        if (!canManage(user, project)) { response.sendError(HttpServletResponse.SC_FORBIDDEN); return; }
        if ("edit".equals(action)) {
            String title = request.getParameter("title"); String description = request.getParameter("description");
            if (title == null || title.trim().isEmpty() || title.trim().length() > 150 || (description != null && description.length() > 2000)) { response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid project details."); return; }
            project.setTitle(title.trim()); project.setDescription(description == null ? "" : description.trim());
            if (!projectDAO.updateProject(project)) { response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Project could not be updated."); return; }
        } else if ("delete".equals(action)) {
            if (!"ADMIN".equals(user.getRole())) { response.sendError(HttpServletResponse.SC_FORBIDDEN, "Only administrators can delete projects."); return; }
            if (!projectDAO.deleteProject(id)) { response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Project could not be deleted."); return; }
        } else { response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Unknown action."); return; }
        response.sendRedirect(request.getContextPath() + "/projects");
    }
}
