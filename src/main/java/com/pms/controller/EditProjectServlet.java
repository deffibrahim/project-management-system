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
import java.util.ArrayList;
import java.util.List;

@WebServlet("/projects/edit")
public class EditProjectServlet extends HttpServlet {

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

        String projectIdParameter = request.getParameter("id");

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
            projectId = Integer.parseInt(projectIdParameter.trim());

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

        Project project = projectDAO.getProjectById(projectId);

        if (project == null) {
            response.sendError(
                    HttpServletResponse.SC_NOT_FOUND,
                    "Project not found."
            );
            return;
        }

        String role = user.getRole();

        boolean allowed = false;

        /*
         * ADMIN can edit any project.
         */
        if ("ADMIN".equals(role)) {

            allowed = true;

            /*
             * PROJECT_MANAGER can edit only
             * projects they manage.
             */
        } else if ("PROJECT_MANAGER".equals(role)) {

            allowed = project.getManagerId() == user.getUserId();
        }

        /*
         * TEAM_MEMBER and all other roles are denied.
         */
        if (!allowed) {
            response.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "You do not have permission to edit this project."
            );
            return;
        }

        /*
         * Only ADMIN can change the manager,
         * so only ADMIN receives the manager list.
         */
        List<User> managers = new ArrayList<>();

        if ("ADMIN".equals(role)) {

            for (User candidate : userDAO.getAllUsers()) {

                if ("PROJECT_MANAGER".equals(candidate.getRole())) {
                    managers.add(candidate);
                }
            }
        }

        request.setAttribute("project", project);
        request.setAttribute("managers", managers);

        request.getRequestDispatcher(
                "/dashboard/edit-project.jsp"
        ).forward(request, response);
    }
}