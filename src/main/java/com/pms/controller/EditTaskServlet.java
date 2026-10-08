package com.pms.controller;

import com.pms.dao.ProjectDAO;
import com.pms.dao.TaskDAO;
import com.pms.dao.UserDAO;
import com.pms.model.Project;
import com.pms.model.Task;
import com.pms.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/tasks/edit")
public class EditTaskServlet extends HttpServlet {

    private final TaskDAO taskDAO = new TaskDAO();
    private final ProjectDAO projectDAO = new ProjectDAO();
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null) {
            response.sendError(
                    HttpServletResponse.SC_UNAUTHORIZED,
                    "You must be logged in."
            );
            return;
        }

        User user = (User) session.getAttribute("user");

        if (user == null) {
            response.sendError(
                    HttpServletResponse.SC_UNAUTHORIZED,
                    "You must be logged in."
            );
            return;
        }

        String taskIdParameter = request.getParameter("id");

        if (taskIdParameter == null
                || taskIdParameter.trim().isEmpty()) {
            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Task ID is required."
            );
            return;
        }

        int taskId;

        try {
            taskId = Integer.parseInt(taskIdParameter.trim());

            if (taskId <= 0) {
                response.sendError(
                        HttpServletResponse.SC_BAD_REQUEST,
                        "Invalid task ID."
                );
                return;
            }

        } catch (NumberFormatException e) {
            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Invalid task ID."
            );
            return;
        }

        Task task = taskDAO.getTaskById(taskId);

        if (task == null) {
            response.sendError(
                    HttpServletResponse.SC_NOT_FOUND,
                    "Task not found."
            );
            return;
        }

        String role = user.getRole();

        // ADMIN can edit any task.
        if ("ADMIN".equals(role)) {

            // Allowed.

            // PROJECT_MANAGER can edit tasks in their projects.
        } else if ("PROJECT_MANAGER".equals(role)) {

            Project project =
                    projectDAO.getProjectById(task.getProjectId());

            if (project == null
                    || project.getManagerId() != user.getUserId()) {

                response.sendError(
                        HttpServletResponse.SC_FORBIDDEN,
                        "You do not have permission to edit this task."
                );
                return;
            }

            // TEAM_MEMBER can edit only their assigned tasks.
        } else if ("TEAM_MEMBER".equals(role)) {

            if (task.getAssigneeId() != user.getUserId()) {
                response.sendError(
                        HttpServletResponse.SC_FORBIDDEN,
                        "You do not have permission to edit this task."
                );
                return;
            }

        } else {
            response.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "You do not have permission to edit tasks."
            );
            return;
        }

        // Load dropdown data depending on the role.
        List<Project> projects;
        List<User> users;

        if ("ADMIN".equals(role)) {

            projects = projectDAO.getAllProjects();
            users = userDAO.getAllUsers();

        } else if ("PROJECT_MANAGER".equals(role)) {

            projects = projectDAO.getProjectsByManagerId(
                    user.getUserId()
            );
            users = userDAO.getAllUsers();

        } else {

            // TEAM_MEMBER cannot change project or assignee,
            // so offer only the current values.
            projects = new ArrayList<>();

            Project currentProject =
                    projectDAO.getProjectById(task.getProjectId());

            if (currentProject != null) {
                projects.add(currentProject);
            }

            users = new ArrayList<>();
            users.add(user);
        }

        // Send data to the JSP.
        request.setAttribute("task", task);
        request.setAttribute("projects", projects);
        request.setAttribute("users", users);

        request.getRequestDispatcher(
                "/dashboard/edit-task.jsp"
        ).forward(request, response);
    }
}