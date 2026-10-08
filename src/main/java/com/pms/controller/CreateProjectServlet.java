package com.pms.controller;

import com.pms.dao.ProjectDAO;
import com.pms.dao.UserDAO;
import com.pms.model.Project;
import com.pms.model.User;
import com.pms.util.AppSettings;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.Date;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/projects/create")
public class CreateProjectServlet extends HttpServlet {

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
                    "You do not have permission to create projects."
            );
            return;
        }

        // Admin can switch this off in Settings > System.
        if ("PROJECT_MANAGER".equals(role)
                && !AppSettings.isPmCanCreateProjects()) {

            response.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "Creating projects is turned off for project managers. "
                            + "Ask an administrator."
            );
            return;
        }

        /*
         * Only ADMIN chooses the manager, so only ADMIN
         * receives the list of project managers.
         */
        List<User> managers = new ArrayList<>();

        if ("ADMIN".equals(role)) {

            for (User candidate : userDAO.getAllUsers()) {

                if ("PROJECT_MANAGER".equals(candidate.getRole())) {
                    managers.add(candidate);
                }
            }
        }

        request.setAttribute("managers", managers);

        request.getRequestDispatcher(
                "/dashboard/create-project.jsp"
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
         * Only ADMIN and PROJECT_MANAGER can create projects.
         */
        if (!"ADMIN".equals(role)
                && !"PROJECT_MANAGER".equals(role)) {

            response.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "You do not have permission to create projects."
            );
            return;
        }

        // Admin can switch this off in Settings > System.
        if ("PROJECT_MANAGER".equals(role)
                && !AppSettings.isPmCanCreateProjects()) {

            response.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "Creating projects is turned off for project managers. "
                            + "Ask an administrator."
            );
            return;
        }

        String title = request.getParameter("title");
        String description = request.getParameter("description");
        String startDate = request.getParameter("startDate");
        String endDate = request.getParameter("endDate");
        String managerIdParameter = request.getParameter("managerId");
        String status = request.getParameter("status");

        /*
         * Validate title.
         */
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

        /*
         * Normalize description.
         */
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

        /*
         * Validate status.
         */
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

        Project project = new Project();

        project.setTitle(title);
        project.setDescription(description);

        Date parsedStartDate = null;
        Date parsedEndDate = null;

        /*
         * Validate start date.
         */
        if (startDate != null && !startDate.trim().isEmpty()) {

            try {
                parsedStartDate = Date.valueOf(startDate.trim());
                project.setStartDate(parsedStartDate);

            } catch (IllegalArgumentException e) {

                response.sendError(
                        HttpServletResponse.SC_BAD_REQUEST,
                        "Invalid start date."
                );
                return;
            }
        }

        /*
         * Validate end date.
         */
        if (endDate != null && !endDate.trim().isEmpty()) {

            try {
                parsedEndDate = Date.valueOf(endDate.trim());
                project.setEndDate(parsedEndDate);

            } catch (IllegalArgumentException e) {

                response.sendError(
                        HttpServletResponse.SC_BAD_REQUEST,
                        "Invalid end date."
                );
                return;
            }
        }

        /*
         * End date cannot be before start date.
         */
        if (parsedStartDate != null
                && parsedEndDate != null
                && parsedEndDate.before(parsedStartDate)) {

            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "End date cannot be before start date."
            );
            return;
        }

        /*
         * ADMIN must choose an existing project manager.
         */
        if ("ADMIN".equals(role)) {

            if (managerIdParameter == null
                    || managerIdParameter.trim().isEmpty()) {

                response.sendError(
                        HttpServletResponse.SC_BAD_REQUEST,
                        "Project manager is required."
                );
                return;
            }

            int managerId;

            try {

                managerId =
                        Integer.parseInt(managerIdParameter.trim());

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

            User manager = userDAO.getUserById(managerId);

            if (manager == null
                    || !"PROJECT_MANAGER".equals(manager.getRole())) {

                response.sendError(
                        HttpServletResponse.SC_BAD_REQUEST,
                        "Manager must be an existing project manager."
                );
                return;
            }

            project.setManagerId(managerId);

        } else {

            /*
             * PROJECT_MANAGER must create projects
             * under their own user ID.
             */
            project.setManagerId(currentUser.getUserId());
        }

        project.setStatus(status);

        boolean created = projectDAO.createProject(project);

        if (created) {

            response.sendRedirect(
                    request.getContextPath() + "/projects"
            );

        } else {

            response.sendError(
                    HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    "Failed to create project."
            );
        }
    }
}