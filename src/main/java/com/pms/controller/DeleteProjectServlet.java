package com.pms.controller;

import com.pms.dao.ProjectDAO;
import com.pms.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet("/projects/delete")
public class DeleteProjectServlet extends HttpServlet {

    private final ProjectDAO projectDAO = new ProjectDAO();

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

        User user = (User) session.getAttribute("user");

        if (user == null) {
            response.sendError(
                    HttpServletResponse.SC_UNAUTHORIZED,
                    "You must be logged in."
            );
            return;
        }

        /*
         * Only ADMIN can delete projects.
         */
        if (!"ADMIN".equals(user.getRole())) {

            response.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "You do not have permission to delete projects."
            );

            return;
        }

        String projectIdParameter = request.getParameter("id");

        if (projectIdParameter == null) {
            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Project ID is required."
            );
            return;
        }

        int projectId;

        try {
            projectId = Integer.parseInt(projectIdParameter);
        } catch (NumberFormatException e) {
            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Invalid project ID."
            );
            return;
        }

        boolean deleted = projectDAO.deleteProject(projectId);

        if (deleted) {

            response.sendRedirect(
                    request.getContextPath() + "/projects"
            );

        } else {

            response.sendError(
                    HttpServletResponse.SC_NOT_FOUND,
                    "Project not found or could not be deleted."
            );
        }
    }
}