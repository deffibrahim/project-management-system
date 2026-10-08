
package com.pms.controller;

import com.pms.dao.ProjectDAO;
import com.pms.dao.UserDAO;
import com.pms.model.Project;
import com.pms.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.Date;

@WebServlet("/projects/update")
public class UpdateProjectServlet extends HttpServlet {

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

        // Only ADMIN and PROJECT_MANAGER can update projects.
        if (!"ADMIN".equals(role)
                && !"PROJECT_MANAGER".equals(role)) {

            response.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "You do not have permission to update projects."
            );
            return;
        }

        // Validate project ID.
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
            projectId = Integer.parseInt(
                    projectIdParameter.trim()
            );

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

        // Get the existing project.
        Project existingProject =
                projectDAO.getProjectById(projectId);

        if (existingProject == null) {
            response.sendError(
                    HttpServletResponse.SC_NOT_FOUND,
                    "Project not found."
            );
            return;
        }

        // Project managers can update only their own projects.
        if ("PROJECT_MANAGER".equals(role)
                && existingProject.getManagerId()
                != currentUser.getUserId()) {

            response.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "You do not have permission to update this project."
            );
            return;
        }

        String title = request.getParameter("title");
        String description = request.getParameter("description");
        String startDate = request.getParameter("startDate");
        String endDate = request.getParameter("endDate");
        String managerIdParameter =
                request.getParameter("managerId");
        String status = request.getParameter("status");

        // Validate title.
        if (title == null || title.trim().isEmpty()) {

            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Project title is required."
            );
            return;
        }

        title = title.trim();

        if (title.length() > 150) {

            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Project title is too long."
            );
            return;
        }

        // Validate description.
        if (description != null) {

            description = description.trim();

            if (description.length() > 2000) {

                response.sendError(
                        HttpServletResponse.SC_BAD_REQUEST,
                        "Project description is too long."
                );
                return;
            }
        }

        // Validate status.
        if (status == null
                || (!"PLANNED".equals(status)
                && !"ACTIVE".equals(status)
                && !"COMPLETED".equals(status))) {

            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Invalid project status."
            );
            return;
        }

        // Start with the existing dates.
        Date parsedStartDate = existingProject.getStartDate();
        Date parsedEndDate = existingProject.getEndDate();

        // Parse submitted start date if provided.
        if (startDate != null
                && !startDate.trim().isEmpty()) {

            try {
                parsedStartDate =
                        Date.valueOf(startDate.trim());

            } catch (IllegalArgumentException e) {

                response.sendError(
                        HttpServletResponse.SC_BAD_REQUEST,
                        "Invalid start date."
                );
                return;
            }
        } else {
            parsedStartDate = null;
        }

        // Parse submitted end date if provided.
        if (endDate != null
                && !endDate.trim().isEmpty()) {

            try {
                parsedEndDate =
                        Date.valueOf(endDate.trim());

            } catch (IllegalArgumentException e) {

                response.sendError(
                        HttpServletResponse.SC_BAD_REQUEST,
                        "Invalid end date."
                );
                return;
            }
        } else {
            parsedEndDate = null;
        }

        // Validate the final combination of dates.
        if (parsedStartDate != null
                && parsedEndDate != null
                && parsedEndDate.before(parsedStartDate)) {

            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "End date cannot be before start date."
            );
            return;
        }

        // Build the project object.
        Project project = new Project();

        project.setProjectId(projectId);
        project.setTitle(title);
        project.setDescription(description);
        project.setStartDate(parsedStartDate);
        project.setEndDate(parsedEndDate);
        project.setStatus(status);

        // ADMIN can change the project manager.
        if ("ADMIN".equals(role)) {

            int managerId = existingProject.getManagerId();

            if (managerIdParameter != null
                    && !managerIdParameter.trim().isEmpty()) {

                try {
                    managerId = Integer.parseInt(
                            managerIdParameter.trim()
                    );

                    if (managerId <= 0) {
                        response.sendError(
                                HttpServletResponse.SC_BAD_REQUEST,
                                "Invalid manager ID."
                        );
                        return;
                    }

                } catch (NumberFormatException e) {

                    response.sendError(
                            HttpServletResponse.SC_BAD_REQUEST,
                            "Invalid manager ID."
                    );
                    return;
                }

                // Validate a newly selected manager.
                if (managerId != existingProject.getManagerId()) {

                    User manager =
                            userDAO.getUserById(managerId);

                    if (manager == null
                            || !"PROJECT_MANAGER".equals(
                            manager.getRole())) {

                        response.sendError(
                                HttpServletResponse.SC_BAD_REQUEST,
                                "Manager must be an existing project manager."
                        );
                        return;
                    }
                }
            }

            project.setManagerId(managerId);

        } else {

            // A project manager cannot transfer ownership.
            project.setManagerId(currentUser.getUserId());
        }

        // Update project in the database.
        boolean updated =
                projectDAO.updateProject(project);

        if (updated) {

            response.sendRedirect(
                    request.getContextPath() + "/projects"
            );

        } else {

            response.sendError(
                    HttpServletResponse.SC_NOT_FOUND,
                    "Project not found or could not be updated."
            );
        }
    }
}
