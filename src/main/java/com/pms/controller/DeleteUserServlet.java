package com.pms.controller;

import com.pms.dao.ProjectDAO;
import com.pms.dao.TaskDAO;
import com.pms.dao.UserDAO;
import com.pms.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet("/users/delete")
public class DeleteUserServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();
    private final ProjectDAO projectDAO = new ProjectDAO();
    private final TaskDAO taskDAO = new TaskDAO();

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

        /*
         * Only ADMIN can delete users.
         */
        if (!"ADMIN".equals(currentUser.getRole())) {
            response.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "You do not have permission to delete users."
            );
            return;
        }

        String userIdParameter = request.getParameter("id");

        if (userIdParameter == null
                || userIdParameter.trim().isEmpty()) {
            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "User ID is required."
            );
            return;
        }

        int userId;

        try {
            userId = Integer.parseInt(userIdParameter.trim());

            if (userId <= 0) {
                response.sendError(
                        HttpServletResponse.SC_BAD_REQUEST,
                        "Invalid user ID."
                );
                return;
            }

        } catch (NumberFormatException e) {
            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Invalid user ID."
            );
            return;
        }

        /*
         * An admin cannot delete their own account.
         */
        if (userId == currentUser.getUserId()) {
            response.sendError(
                    HttpServletResponse.SC_CONFLICT,
                    "You cannot delete your own account."
            );
            return;
        }

        /*
         * The user must exist.
         */
        User target = userDAO.getUserById(userId);

        if (target == null) {
            response.sendError(
                    HttpServletResponse.SC_NOT_FOUND,
                    "User not found."
            );
            return;
        }

        /*
         * The database does not allow deleting a user who
         * manages projects or has assigned tasks, so explain
         * that clearly instead of failing with a vague error.
         */
        if (!projectDAO.getProjectsByManagerId(userId).isEmpty()) {
            response.sendError(
                    HttpServletResponse.SC_CONFLICT,
                    "This user manages projects. "
                            + "Reassign those projects first."
            );
            return;
        }

        if (!taskDAO.getTasksByAssigneeId(userId).isEmpty()) {
            response.sendError(
                    HttpServletResponse.SC_CONFLICT,
                    "This user has assigned tasks. "
                            + "Reassign or delete those tasks first."
            );
            return;
        }

        boolean deleted = userDAO.deleteUser(userId);

        if (deleted) {

            response.sendRedirect(
                    request.getContextPath() + "/users"
            );

        } else {

            response.sendError(
                    HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    "User could not be deleted."
            );
        }
    }
}