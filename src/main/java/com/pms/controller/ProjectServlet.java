package com.pms.controller;

import com.pms.dao.ProjectDAO;
import com.pms.model.Project;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

/**
 * Handles project management actions.
 */
@WebServlet("/projects/*")
public class ProjectServlet extends BaseServlet {
    private final ProjectDAO projectDAO = new ProjectDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        var user = getLoggedInUser(request);
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/index.html");
            return;
        }
        String action = request.getPathInfo(); // e.g. "/create", "/edit", "/detail"
        if (action == null || "/".equals(action) || "/list".equals(action)) {
            // List view
            List<Project> projects;
            if ("ADMIN".equals(user.getRole())) {
                projects = projectDAO.getAllProjects();
            } else if ("PROJECT_MANAGER".equals(user.getRole())) {
                projects = projectDAO.getProjectsByManagerId(user.getUserId());
            } else {
                // Team members see all projects for simplicity
                projects = projectDAO.getAllProjects();
            }
            request.setAttribute("projects", projects);
            request.getRequestDispatcher("/dashboard/project-manager.jsp").forward(request, response);
        } else if ("/detail".equals(action)) {
            String idParam = request.getParameter("id");
            if (idParam == null) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Project id missing");
                return;
            }
            Project project = projectDAO.getProjectById(Integer.parseInt(idParam));
            request.setAttribute("project", project);
            request.getRequestDispatcher("/dashboard/project-detail.jsp").forward(request, response);
        } else {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        if (!validateCsrf(request)) {
            denyCsrf(response);
            return;
        }
        var user = getLoggedInUser(request);
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/index.html");
            return;
        }
        String action = request.getParameter("action");
        try {
            switch (action) {
                case "create":
                    if (!"PROJECT_MANAGER".equals(user.getRole()) && !"ADMIN".equals(user.getRole())) {
                        response.sendError(HttpServletResponse.SC_FORBIDDEN);
                        return;
                    }
                    Project newProj = new Project();
                    newProj.setTitle(request.getParameter("title"));
                    newProj.setDescription(request.getParameter("description"));
                    newProj.setManagerId(user.getUserId());
                    // dates omitted for brevity
                    projectDAO.createProject(newProj);
                    break;
                case "edit":
                    if (!"PROJECT_MANAGER".equals(user.getRole()) && !"ADMIN".equals(user.getRole())) {
                        response.sendError(HttpServletResponse.SC_FORBIDDEN);
                        return;
                    }
                    int editId = Integer.parseInt(request.getParameter("id"));
                    Project editProj = projectDAO.getProjectById(editId);
                    editProj.setTitle(request.getParameter("title"));
                    editProj.setDescription(request.getParameter("description"));
                    projectDAO.updateProject(editProj);
                    break;
                case "delete":
                    if (!"PROJECT_MANAGER".equals(user.getRole()) && !"ADMIN".equals(user.getRole())) {
                        response.sendError(HttpServletResponse.SC_FORBIDDEN);
                        return;
                    }
                    int delId = Integer.parseInt(request.getParameter("id"));
                    projectDAO.deleteProject(delId);
                    break;
                default:
                    response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Unknown action");
                    return;
            }
            response.sendRedirect(request.getContextPath() + "/projects");
        } catch (NumberFormatException e) {
            throw new ServletException(e);
        }
    }
}
