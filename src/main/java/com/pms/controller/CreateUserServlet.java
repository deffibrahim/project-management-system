package com.pms.controller;

import com.pms.dao.UserDAO;
import com.pms.model.User;
import com.pms.util.AppSettings;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.Locale;
import java.util.regex.Pattern;

@WebServlet("/users/create")
public class CreateUserServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    private static final Pattern EMAIL_PATTERN =
            Pattern.compile("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+$");

    private boolean emailExists(String email) {

        for (User existing : userDAO.getAllUsers()) {

            if (email.equalsIgnoreCase(existing.getEmail())) {
                return true;
            }
        }

        return false;
    }

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        User currentUser = session != null
                ? (User) session.getAttribute("user")
                : null;

        if (currentUser == null) {
            response.sendError(
                    HttpServletResponse.SC_UNAUTHORIZED,
                    "You must be logged in."
            );
            return;
        }

        if (!"ADMIN".equals(currentUser.getRole())) {
            response.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "You do not have permission to create users."
            );
            return;
        }

        request.getRequestDispatcher(
                "/dashboard/user-create.jsp"
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

        /*
         * Only ADMIN can create users.
         */
        if (!"ADMIN".equals(currentUser.getRole())) {
            response.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "You do not have permission to create users."
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
         * Validate password (BCrypt only uses the first 72 characters).
         */
        if (password == null || password.isEmpty()) {
            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Password is required."
            );
            return;
        }

        int minPasswordLength = AppSettings.getMinPasswordLength();

        if (password.length() < minPasswordLength) {
            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Password must be at least " + minPasswordLength
                            + " characters long."
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
         * Email must be unique.
         */
        if (emailExists(email)) {
            response.sendError(
                    HttpServletResponse.SC_CONFLICT,
                    "A user with this email already exists."
            );
            return;
        }

        User user = new User();

        user.setName(name);
        user.setEmail(email);
        user.setPassword(password);
        user.setRole(role);

        boolean created = userDAO.createUser(user);

        if (created) {

            response.sendRedirect(
                    request.getContextPath() + "/users"
            );

        } else {

            response.sendError(
                    HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    "Failed to create user."
            );
        }
    }
}