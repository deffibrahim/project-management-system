package com.pms.controller;

import com.pms.dao.TaskDAO;
import com.pms.dao.ProjectDAO;
import com.pms.model.Task;
import com.pms.model.Project;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

/**
 * Handles task management actions.
 * <ul>
 *   <li>GET  – list tasks for a project or show a single task.</li>
 *   <li>POST – create / edit / delete based on "action" parameter.</li>
 * </ul>
 */
@WebServlet("/tasks/*")
public class TaskServlet extends BaseServlet {
    private final TaskDAO taskDAO = new TaskDAO();
    private final ProjectDAO projectDAO = new ProjectDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        var user = getLoggedInUser(request);
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/index.html");
            return;
        }
        String action = request.getPathInfo(); // e.g. "/list", "/detail"
        if (action == null || "/".equals(action) || "/list".equals(action)) {
            // List tasks for a given project (projectId param required)
            String projIdStr = request.getParameter("projectId");
            if (projIdStr == null) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "projectId required");
                return;
            }
            int projId = Integer.parseInt(projIdStr);
            Project project = projectDAO.getProjectById(projId);
            List<Task> tasks = taskDAO.getAllTasks();
            // Filter tasks for this project
            tasks.removeIf(t -> t.getProjectId() != projId);
            request.setAttribute("project", project);
            request.setAttribute("tasks", tasks);
            request.getRequestDispatcher("/dashboard/task-list.jsp").forward(request, response);
        } else if ("/detail".equals(action)) {
            String taskIdStr = request.getParameter("id");
            if (taskIdStr == null) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Task id missing");
                return;
            }
            int taskId = Integer.parseInt(taskIdStr);
            Task task = taskDAO.getTaskById(taskId);
            request.setAttribute("task", task);
            request.getRequestDispatcher("/dashboard/task-edit.jsp").forward(request, response);
        } else {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // CSRF protection
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
                case "create": {
                    // Only managers or admin can create tasks
                    if (!"PROJECT_MANAGER".equals(user.getRole()) && !"ADMIN".equals(user.getRole())) {
                        response.sendError(HttpServletResponse.SC_FORBIDDEN);
                        return;
                    }
                    Task task = new Task();
                    task.setTitle(request.getParameter("title"));
                    task.setDescription(request.getParameter("description"));
                    task.setProjectId(Integer.parseInt(request.getParameter("projectId")));
                    task.setAssigneeId(Integer.parseInt(request.getParameter("assigneeId")));
                    task.setStatus("PENDING");
                    taskDAO.createTask(task);
                    break;
                }
                case "edit": {
                    if (!"PROJECT_MANAGER".equals(user.getRole()) && !"ADMIN".equals(user.getRole())) {
                        response.sendError(HttpServletResponse.SC_FORBIDDEN);
                        return;
                    }
                    int id = Integer.parseInt(request.getParameter("id"));
                    Task task = taskDAO.getTaskById(id);
                    task.setTitle(request.getParameter("title"));
                    task.setDescription(request.getParameter("description"));
                    task.setAssigneeId(Integer.parseInt(request.getParameter("assigneeId")));
                    task.setStatus(request.getParameter("status"));
                    taskDAO.updateTask(task);
                    break;
                }
                case "delete": {
                    if (!"PROJECT_MANAGER".equals(user.getRole()) && !"ADMIN".equals(user.getRole())) {
                        response.sendError(HttpServletResponse.SC_FORBIDDEN);
                        return;
                    }
                    int id = Integer.parseInt(request.getParameter("id"));
                    taskDAO.deleteTask(id);
                    break;
                }
                default:
                    response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Unknown action");
                    return;
            }
            // Redirect back to task list for the project
            String projectId = request.getParameter("projectId");
            response.sendRedirect(request.getContextPath() + "/tasks?projectId=" + projectId);
        } catch (NumberFormatException e) {
            throw new ServletException(e);
        }
    }
}
