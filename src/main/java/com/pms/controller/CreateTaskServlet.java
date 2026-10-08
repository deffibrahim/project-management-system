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
import java.sql.Date;
import java.util.List;

@WebServlet("/tasks/create")
public class CreateTaskServlet extends HttpServlet {

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

        User currentUser = (User) session.getAttribute("user");

        if (currentUser == null) {
            response.sendError(
                    HttpServletResponse.SC_UNAUTHORIZED,
                    "You must be logged in."
            );
            return;
        }

        String role = currentUser.getRole();

        if (!"ADMIN".equals(role)
                && !"PROJECT_MANAGER".equals(role)) {

            response.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "You do not have permission to create tasks."
            );
            return;
        }

        List<Project> projects;

        if ("PROJECT_MANAGER".equals(role)) {
            projects = projectDAO.getProjectsByManagerId(
                    currentUser.getUserId()
            );
        } else {
            projects = projectDAO.getAllProjects();
        }

        List<User> users = userDAO.getAllUsers();

        request.setAttribute("projects", projects);
        request.setAttribute("users", users);

        request.getRequestDispatcher(
                "/dashboard/create-task.jsp"
        ).forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request,
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

        User currentUser = (User) session.getAttribute("user");

        if (currentUser == null) {
            response.sendError(
                    HttpServletResponse.SC_UNAUTHORIZED,
                    "You must be logged in."
            );
            return;
        }

        String role = currentUser.getRole();

        /*
         * Only ADMIN and PROJECT_MANAGER can create tasks.
         */
        if (!"ADMIN".equals(role)
                && !"PROJECT_MANAGER".equals(role)) {

            response.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "You do not have permission to create tasks."
            );
            return;
        }

        /*
         * Validate project ID.
         */
        String projectIdParameter =
                request.getParameter("projectId");

        if (projectIdParameter == null
                || projectIdParameter.trim().isEmpty()) {

            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Project ID is required."
            );
            return;
        }

        int projectId;

        try {
            projectId =
                    Integer.parseInt(projectIdParameter.trim());

            if (projectId <= 0) {
                response.sendError(
                        HttpServletResponse.SC_BAD_REQUEST,
                        "Invalid project ID."
                );
                return;
            }

        } catch (NumberFormatException e) {

            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Invalid project ID."
            );
            return;
        }

        /*
         * Load the project before creating the task.
         */
        Project project =
                projectDAO.getProjectById(projectId);

        if (project == null) {
            response.sendError(
                    HttpServletResponse.SC_NOT_FOUND,
                    "Project not found."
            );
            return;
        }

        /*
         * PROJECT_MANAGER can create tasks only
         * inside projects they manage.
         */
        if ("PROJECT_MANAGER".equals(role)
                && project.getManagerId()
                != currentUser.getUserId()) {

            response.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "You do not have permission to create tasks in this project."
            );
            return;
        }

        String title = request.getParameter("title");
        String description = request.getParameter("description");
        String assigneeIdParameter =
                request.getParameter("assigneeId");
        String status = request.getParameter("status");
        String dueDate = request.getParameter("dueDate");

        /*
         * Validate title.
         */
        if (title == null || title.trim().isEmpty()) {

            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Task title is required."
            );
            return;
        }

        title = title.trim();

        if (title.length() > 150) {

            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Task title is too long."
            );
            return;
        }

        /*
         * Validate description.
         */
        if (description != null) {

            description = description.trim();

            if (description.length() > 2000) {

                response.sendError(
                        HttpServletResponse.SC_BAD_REQUEST,
                        "Task description is too long."
                );
                return;
            }
        }

        /*
         * Validate status.
         */
        if (status == null
                || (!"PENDING".equals(status)
                && !"IN_PROGRESS".equals(status)
                && !"COMPLETED".equals(status))) {

            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Invalid task status."
            );
            return;
        }

        /*
         * Validate priority (defaults to MEDIUM when not supplied).
         */
        String priority = request.getParameter("priority");

        if (priority == null || priority.trim().isEmpty()) {
            priority = "MEDIUM";
        }

        priority = priority.trim();

        if (!"LOW".equals(priority)
                && !"MEDIUM".equals(priority)
                && !"HIGH".equals(priority)
                && !"URGENT".equals(priority)) {

            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Invalid task priority."
            );
            return;
        }

        Task task = new Task();

        task.setProjectId(projectId);
        task.setTitle(title);
        task.setDescription(description);

        /*
         * Validate assignee ID. An empty value means "Unassigned".
         * The assignee must be an existing team member.
         */
        if (assigneeIdParameter != null
                && !assigneeIdParameter.trim().isEmpty()) {

            int assigneeId;

            try {

                assigneeId =
                        Integer.parseInt(
                                assigneeIdParameter.trim()
                        );

                if (assigneeId <= 0) {

                    response.sendError(
                            HttpServletResponse.SC_BAD_REQUEST,
                            "Invalid assignee ID."
                    );
                    return;
                }

            } catch (NumberFormatException e) {

                response.sendError(
                        HttpServletResponse.SC_BAD_REQUEST,
                        "Invalid assignee ID."
                );
                return;
            }

            User assignee = userDAO.getUserById(assigneeId);

            if (assignee == null
                    || !"TEAM_MEMBER".equals(assignee.getRole())) {

                response.sendError(
                        HttpServletResponse.SC_BAD_REQUEST,
                        "Assignee must be an existing team member."
                );
                return;
            }

            task.setAssigneeId(assigneeId);
        }

        task.setStatus(status);
        task.setPriority(priority);

        /*
         * Validate due date.
         */
        if (dueDate != null
                && !dueDate.trim().isEmpty()) {

            try {

                task.setDueDate(
                        Date.valueOf(dueDate.trim())
                );

            } catch (IllegalArgumentException e) {

                response.sendError(
                        HttpServletResponse.SC_BAD_REQUEST,
                        "Invalid due date."
                );
                return;
            }
        }

        boolean created =
                taskDAO.createTask(task);

        if (created) {

            response.sendRedirect(
                    request.getContextPath() + "/tasks"
            );

        } else {

            response.sendError(
                    HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    "Failed to create task."
            );
        }
    }
}