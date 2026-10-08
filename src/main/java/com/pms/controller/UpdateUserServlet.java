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
import java.util.Locale;
import java.util.regex.Pattern;

@WebServlet("/users/update")
public class UpdateUserServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();
    private final ProjectDAO projectDAO = new ProjectDAO();
    private final TaskDAO taskDAO = new TaskDAO();

    private static final Pattern EMAIL_PATTERN =
            Pattern.compile("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+$");

    private boolean emailUsedByAnotherUser(String email,
                                           int userId) {

        for (User existing : userDAO.getAllUsers()) {

            if (existing.getUserId() != userId
                    && email.equalsIgnoreCase(existing.getEmail())) {
                return true;
            }
        }

        return false;
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

        /*
         * Only ADMIN can update users.
         */
        if (!"ADMIN".equals(currentUser.getRole())) {
            response.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "You do not have permission to update users."
            );
            return;
        }

        /*
         * Validate user ID.
         */
        String userIdParameter =
                request.getParameter("userId");

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
            userId =
                    Integer.parseInt(userIdParameter.trim());

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
         * The user must exist.
         */
        User existingUser = userDAO.getUserById(userId);

        if (existingUser == null) {
            response.sendError(
                    HttpServletResponse.SC_NOT_FOUND,
                    "User not found."
            );
            return;
        }

        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String role = request.getParameter("role");

        /*
         * Validate name.
         */
        if (name == null || name.trim().isEmpty()) {

            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Name is required."
            );
            return;
        }

        name = name.trim();

        if (name.length() > 100) {

            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Name is too long."
            );
            return;
        }

        /*
         * Validate email (database column allows 100 characters).
         */
        if (email == null || email.trim().isEmpty()) {

            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Email is required."
            );
            return;
        }

        email = email.trim().toLowerCase(Locale.ROOT);

        if (email.length() > 100
                || !EMAIL_PATTERN.matcher(email).matches()) {

            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Invalid email address."
            );
            return;
        }

        /*
         * Password is optional during an update.
         *
         * Empty password means:
         * keep the existing password.
         */
        if (password != null
                && !password.isEmpty()) {

            if (password.length() < 6) {

                response.sendError(
                        HttpServletResponse.SC_BAD_REQUEST,
                        "Password must be at least 6 characters long."
                );
                return;
            }

            if (password.length() > 72) {

                response.sendError(
                        HttpServletResponse.SC_BAD_REQUEST,
                        "Password must be at most 72 characters long."
                );
                return;
            }
        }

        /*
         * Validate role.
         */
        if (role == null
                || (!"ADMIN".equals(role)
                && !"PROJECT_MANAGER".equals(role)
                && !"TEAM_MEMBER".equals(role))) {

            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Invalid user role."
            );
            return;
        }

        /*
         * Email must not belong to a different user.
         */
        if (emailUsedByAnotherUser(email, userId)) {

            response.sendError(
                    HttpServletResponse.SC_CONFLICT,
                    "Another user already uses this email."
            );
            return;
        }

        /*
         * Role change rules.
         */
        if (!role.equals(existingUser.getRole())) {

            /*
             * An admin cannot change their own role,
             * otherwise they could lock themselves out.
             */
            if (userId == currentUser.getUserId()) {

                response.sendError(
                        HttpServletResponse.SC_CONFLICT,
                        "You cannot change your own role."
                );
                return;
            }

            /*
             * A project manager who still manages projects
             * cannot be given another role.
             */
            if ("PROJECT_MANAGER".equals(existingUser.getRole())
                    && !projectDAO
                    .getProjectsByManagerId(userId)
                    .isEmpty()) {

                response.sendError(
                        HttpServletResponse.SC_CONFLICT,
                        "This user still manages projects. "
                                + "Reassign those projects first."
                );
                return;
            }

            /*
             * A team member who still has assigned tasks
             * cannot be given another role.
             */
            if ("TEAM_MEMBER".equals(existingUser.getRole())
                    && !taskDAO
                    .getTasksByAssigneeId(userId)
                    .isEmpty()) {

                response.sendError(
                        HttpServletResponse.SC_CONFLICT,
                        "This user still has assigned tasks. "
                                + "Reassign those tasks first."
                );
                return;
            }
        }

        User user = new User();

        user.setUserId(userId);
        user.setName(name);
        user.setEmail(email);
        user.setRole(role);

        /*
         * Only send a password when the admin
         * actually entered a new password.
         */
        if (password != null
                && !password.isEmpty()) {

            user.setPassword(password);

        } else {

            user.setPassword(null);
        }

        boolean updated =
                userDAO.updateUser(user);

        if (updated) {

            response.sendRedirect(
                    request.getContextPath() + "/users"
            );

        } else {

            response.sendError(
                    HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    "User could not be updated."
            );
        }
    }
}