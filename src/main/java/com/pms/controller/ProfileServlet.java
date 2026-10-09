package com.pms.controller;

import com.pms.dao.UserDAO;
import com.pms.model.User;
import com.pms.util.AppSettings;
import com.pms.util.PasswordUtil;
import java.util.Locale;
import java.util.regex.Pattern;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet("/profile")
public class ProfileServlet extends BaseServlet {

    private final UserDAO userDAO = new UserDAO();
    private static final Pattern EMAIL_PATTERN =
            Pattern.compile("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+$");

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        var user = getLoggedInUser(request);

        if (user == null) {
            response.sendRedirect(
                    request.getContextPath() + "/index.html"
            );
            return;
        }

        // Refresh user from database in case of recent changes
        User fresh = userDAO.getUserById(user.getUserId());

        if (fresh == null) {
            response.sendError(
                    HttpServletResponse.SC_NOT_FOUND,
                    "User profile not found."
            );
            return;
        }

        request.setAttribute("user", fresh);

        request.getRequestDispatcher(
                "/dashboard/profile.jsp"
        ).forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        if (!validateCsrf(request)) {
            denyCsrf(response);
            return;
        }

        var user = getLoggedInUser(request);

        if (user == null) {
            response.sendRedirect(
                    request.getContextPath() + "/index.html"
            );
            return;
        }

        User updated = userDAO.getUserById(user.getUserId());

        if (updated == null) {
            response.sendError(
                    HttpServletResponse.SC_NOT_FOUND,
                    "User profile not found."
            );
            return;
        }

        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String newPassword = request.getParameter("password");
        String currentPassword = request.getParameter("currentPassword");

        if (name == null || name.trim().isEmpty() || name.trim().length() > 100) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Name is required (maximum 100 characters).");
            return;
        }
        if (email == null || email.trim().isEmpty() || email.trim().length() > 100
                || !EMAIL_PATTERN.matcher(email.trim()).matches()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "A valid email address is required.");
            return;
        }
        email = email.trim().toLowerCase(Locale.ROOT);
        for (User other : userDAO.getAllUsers()) {
            if (other.getUserId() != updated.getUserId()
                    && email.equalsIgnoreCase(other.getEmail())) {
                response.sendError(HttpServletResponse.SC_CONFLICT, "That email address is already in use.");
                return;
            }
        }

        updated.setName(name.trim());
        updated.setEmail(email);

        if (newPassword != null && !newPassword.isBlank()) {
            if (currentPassword == null || currentPassword.isEmpty()) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Enter your current password to change it.");
                return;
            }
            String stored = updated.getPassword();
            boolean matches = false;
            try {
                if (stored != null && (stored.startsWith("$2a$") || stored.startsWith("$2b$") || stored.startsWith("$2y$"))) {
                    matches = PasswordUtil.checkPassword(currentPassword, stored);
                } else {
                    matches = stored != null && stored.equals(currentPassword);
                }
            } catch (IllegalArgumentException malformedHash) {
                matches = false;
            }
            if (!matches) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN, "Current password is incorrect.");
                return;
            }
            if (newPassword.length() < AppSettings.getMinPasswordLength() || newPassword.length() > 72) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "New password must be between "
                        + AppSettings.getMinPasswordLength() + " and 72 characters.");
                return;
            }
            updated.setPassword(newPassword);
        } else {
            updated.setPassword(null);
        }

        boolean success = userDAO.updateUser(updated);

        if (success) {
            // Refresh the session copy so the updated name/email appears immediately.
            updated.setPassword(null);
            request.getSession(false).setAttribute("user", updated);
            response.sendRedirect(
                    request.getContextPath()
                            + "/profile?updated=true"
            );
        } else {
            response.sendError(
                    HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    "Profile could not be updated."
            );
        }
    }
}