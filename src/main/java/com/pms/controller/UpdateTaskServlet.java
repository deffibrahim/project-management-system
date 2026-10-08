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

@WebServlet("/tasks/update")
public class UpdateTaskServlet extends HttpServlet {

    private final TaskDAO taskDAO = new TaskDAO();
    private final ProjectDAO projectDAO = new ProjectDAO();
    private final UserDAO userDAO = new UserDAO();

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
         * Validate task ID.
         */
        String taskIdParameter =
                request.getParameter("taskId");

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
            taskId =
                    Integer.parseInt(taskIdParameter.trim());

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

        /*
         * Get the existing task first.
         */
        Task existingTask =
                taskDAO.getTaskById(taskId);

        if (existingTask == null) {
            response.sendError(
                    HttpServletResponse.SC_NOT_FOUND,
                    "Task not found."
            );
            return;
        }

        /*
         * ADMIN can update any task.
         */
        if ("ADMIN".equals(role)) {

            // Allowed.

            /*
             * PROJECT_MANAGER can update only tasks
             * belonging to their own projects.
             */
        } else if ("PROJECT_MANAGER".equals(role)) {

            Project project =
                    projectDAO.getProjectById(
                            existingTask.getProjectId()
                    );

            if (project == null
                    || project.getManagerId()
                    != currentUser.getUserId()) {

                response.sendError(
                        HttpServletResponse.SC_FORBIDDEN,
                        "You do not have permission to update this task."
                );
                return;
            }

            /*
             * TEAM_MEMBER can update only their assigned task.
             */
        } else if ("TEAM_MEMBER".equals(role)) {

            if (existingTask.getAssigneeId()
                    != currentUser.getUserId()) {

                response.sendError(
                        HttpServletResponse.SC_FORBIDDEN,
                        "You do not have permission to update this task."
                );
                return;
            }

        } else {

            response.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "You do not have permission to update tasks."
            );
            return;
        }

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
         * Make sure the target project exists.
         */
        Project targetProject =
                projectDAO.getProjectById(projectId);

        if (targetProject == null) {

            response.sendError(
                    HttpServletResponse.SC_NOT_FOUND,
                    "Project not found."
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

        /*
         * Assignee: an empty value means "Unassigned".
         * TaskDAO stores 0 as NULL.
         */
        int assigneeId = 0;

        if (assigneeIdParameter != null
                && !assigneeIdParameter.trim().isEmpty()) {

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

            /*
             * A newly chosen assignee must be an existing team member.
             * An unchanged assignee is not re-checked, so older data
             * keeps working.
             */
            if (assigneeId != existingTask.getAssigneeId()) {

                User assignee = userDAO.getUserById(assigneeId);

                if (assignee == null
                        || !"TEAM_MEMBER".equals(assignee.getRole())) {

                    response.sendError(
                            HttpServletResponse.SC_BAD_REQUEST,
                            "Assignee must be an existing team member."
                    );
                    return;
                }
            }
        }

        /*
         * TEAM_MEMBER cannot move the task to another project
         * or assign it to another user.
         */
        if ("TEAM_MEMBER".equals(role)) {

            if (projectId != existingTask.getProjectId()) {

                response.sendError(
                        HttpServletResponse.SC_FORBIDDEN,
                        "Team members cannot move tasks between projects."
                );
                return;
            }

            if (assigneeId != existingTask.getAssigneeId()) {

                response.sendError(
                        HttpServletResponse.SC_FORBIDDEN,
                        "Team members cannot reassign tasks."
                );
                return;
            }

            // Team members may only update status; priority stays as set.
            priority = existingTask.getPriority();
        }

        /*
         * PROJECT_MANAGER can move a task only
         * into a project they manage.
         */
        if ("PROJECT_MANAGER".equals(role)) {

            if (targetProject.getManagerId()
                    != currentUser.getUserId()) {

                response.sendError(
                        HttpServletResponse.SC_FORBIDDEN,
                        "You do not have permission to move the task to this project."
                );
                return;
            }
        }

        /*
         * Validate due date.
         */
        Date parsedDueDate = null;

        if (dueDate != null
                && !dueDate.trim().isEmpty()) {

            try {

                parsedDueDate =
                        Date.valueOf(dueDate.trim());

            } catch (IllegalArgumentException e) {

                response.sendError(
                        HttpServletResponse.SC_BAD_REQUEST,
                        "Invalid due date."
                );
                return;
            }
        }

        Task task = new Task();

        task.setTaskId(taskId);
        task.setProjectId(projectId);
        task.setTitle(title);
        task.setDescription(description);
        task.setAssigneeId(assigneeId);
        task.setStatus(status);
        task.setPriority(priority);
        task.setDueDate(parsedDueDate);

        boolean updated =
                taskDAO.updateTask(task);

        if (updated) {

            response.sendRedirect(
                    request.getContextPath() + "/tasks"
            );

        } else {

            response.sendError(
                    HttpServletResponse.SC_NOT_FOUND,
                    "Task not found or could not be updated."
            );
        }
    }
}