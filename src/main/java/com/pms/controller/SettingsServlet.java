package com.pms.controller;

import com.pms.dao.SystemSettingsDAO;
import com.pms.dao.UserDAO;
import com.pms.dao.UserPreferencesDAO;
import com.pms.model.User;
import com.pms.model.UserPreferences;
import com.pms.util.AppSettings;
import com.pms.util.PasswordUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.Locale;
import java.util.regex.Pattern;

/**
 * Handles saving of the Settings page forms:
 *   POST /settings/account      - own name, email and password   (every role)
 *   POST /settings/preferences  - landing page, hide completed   (every role)
 *   POST /settings/system       - system-wide options            (admin only)
 *
 * The CSRF token is also checked globally by CsrfFilter.
 */
@WebServlet("/settings/*")
public class SettingsServlet extends BaseServlet {

    private static final Pattern EMAIL_PATTERN =
            Pattern.compile("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+$");

    private final UserDAO userDAO = new UserDAO();
    private final SystemSettingsDAO settingsDAO = new SystemSettingsDAO();
    private final UserPreferencesDAO preferencesDAO = new UserPreferencesDAO();

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        // Nothing to show here; the page lives at /settings.
        response.sendRedirect(request.getContextPath() + "/settings");
    }

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        if (!validateCsrf(request)) {
            denyCsrf(response);
            return;
        }

        User sessionUser = getLoggedInUser(request);

        if (sessionUser == null) {
            response.sendRedirect(request.getContextPath() + "/index.html");
            return;
        }

        String path = request.getPathInfo();

        if ("/account".equals(path)) {
            saveAccount(request, response, sessionUser);
        } else if ("/preferences".equals(path)) {
            savePreferences(request, response, sessionUser);
        } else if ("/system".equals(path)) {

            if (!"ADMIN".equals(sessionUser.getRole())) {
                response.sendError(
                        HttpServletResponse.SC_FORBIDDEN,
                        "Only administrators can change system settings."
                );
                return;
            }

            saveSystem(request, response);

        } else {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    /* =====================================================
       ACCOUNT TAB
       ===================================================== */

    private void saveAccount(HttpServletRequest request,
                             HttpServletResponse response,
                             User sessionUser)
            throws IOException {

        User account = userDAO.getUserById(sessionUser.getUserId());

        if (account == null) {
            response.sendError(
                    HttpServletResponse.SC_NOT_FOUND,
                    "Account not found."
            );
            return;
        }

        String name = trim(request.getParameter("name"));
        String email = trim(request.getParameter("email")).toLowerCase(Locale.ROOT);
        String currentPassword = request.getParameter("currentPassword");
        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");

        if (name.isEmpty() || name.length() > 100) {
            redirect(request, response, "account", "error",
                    "Name is required (maximum 100 characters).");
            return;
        }

        if (email.isEmpty() || email.length() > 100
                || !EMAIL_PATTERN.matcher(email).matches()) {
            redirect(request, response, "account", "error",
                    "Please enter a valid email address.");
            return;
        }

        for (User other : userDAO.getAllUsers()) {
            if (other.getUserId() != account.getUserId()
                    && email.equalsIgnoreCase(other.getEmail())) {
                redirect(request, response, "account", "error",
                        "Another user already uses this email.");
                return;
            }
        }

        account.setName(name);
        account.setEmail(email);

        boolean changingPassword =
                newPassword != null && !newPassword.isEmpty();

        if (changingPassword) {

            if (currentPassword == null
                    || !passwordMatches(currentPassword, account.getPassword())) {
                redirect(request, response, "account", "error",
                        "Current password is incorrect.");
                return;
            }

            int minLength = AppSettings.getMinPasswordLength();

            if (newPassword.length() < minLength) {
                redirect(request, response, "account", "error",
                        "New password must be at least " + minLength + " characters.");
                return;
            }

            if (newPassword.length() > AppSettings.MAX_PASSWORD) {
                redirect(request, response, "account", "error",
                        "New password must be at most "
                                + AppSettings.MAX_PASSWORD + " characters.");
                return;
            }

            if (!newPassword.equals(confirmPassword)) {
                redirect(request, response, "account", "error",
                        "New password and confirmation do not match.");
                return;
            }

            account.setPassword(newPassword);   // DAO hashes it

        } else {
            account.setPassword(null);          // keep existing password
        }

        if (!userDAO.updateUser(account)) {
            redirect(request, response, "account", "error",
                    "Could not save your account. Please try again.");
            return;
        }

        // Keep the logged-in session in sync with the new details.
        User fresh = userDAO.getUserById(account.getUserId());

        if (fresh != null) {
            request.getSession().setAttribute("user", fresh);
        }

        redirect(request, response, "account", "saved",
                changingPassword
                        ? "Account and password updated."
                        : "Account updated.");
    }

    /* =====================================================
       PREFERENCES TAB
       ===================================================== */

    private void savePreferences(HttpServletRequest request,
                                 HttpServletResponse response,
                                 User sessionUser)
            throws IOException {

        String landing = trim(request.getParameter("landingPage"));

        if (!UserPreferences.isValidLanding(landing)) {
            redirect(request, response, "preferences", "error",
                    "Please choose a valid start page.");
            return;
        }

        UserPreferences prefs = new UserPreferences();

        prefs.setUserId(sessionUser.getUserId());
        prefs.setLandingPage(landing);
        prefs.setHideCompleted(request.getParameter("hideCompleted") != null);

        if (!preferencesDAO.savePreferences(prefs)) {
            redirect(request, response, "preferences", "error",
                    "Could not save your preferences. Please try again.");
            return;
        }

        redirect(request, response, "preferences", "saved",
                "Preferences saved.");
    }

    /* =====================================================
       SYSTEM TAB (admin)
       ===================================================== */

    private void saveSystem(HttpServletRequest request,
                            HttpServletResponse response)
            throws IOException {

        Integer timeout = parseInt(request.getParameter("sessionTimeout"));
        Integer minLength = parseInt(request.getParameter("minPasswordLength"));

        if (timeout == null
                || timeout < AppSettings.MIN_TIMEOUT
                || timeout > AppSettings.MAX_TIMEOUT) {
            redirect(request, response, "system", "error",
                    "Session timeout must be between "
                            + AppSettings.MIN_TIMEOUT + " and "
                            + AppSettings.MAX_TIMEOUT + " minutes.");
            return;
        }

        if (minLength == null
                || minLength < AppSettings.MIN_PASSWORD_FLOOR
                || minLength > AppSettings.MAX_PASSWORD) {
            redirect(request, response, "system", "error",
                    "Minimum password length must be between "
                            + AppSettings.MIN_PASSWORD_FLOOR + " and "
                            + AppSettings.MAX_PASSWORD + ".");
            return;
        }

        // Unticked checkboxes are not sent by the browser.
        boolean pmCanCreate = request.getParameter("pmCanCreateProjects") != null;
        boolean membersCanComment = request.getParameter("membersCanComment") != null;
        boolean maintenance = request.getParameter("maintenanceMode") != null;

        boolean ok =
                settingsDAO.saveValue(AppSettings.SESSION_TIMEOUT_MINUTES,
                        String.valueOf(timeout))
                && settingsDAO.saveValue(AppSettings.MIN_PASSWORD_LENGTH,
                        String.valueOf(minLength))
                && settingsDAO.saveValue(AppSettings.PM_CAN_CREATE_PROJECTS,
                        String.valueOf(pmCanCreate))
                && settingsDAO.saveValue(AppSettings.MEMBERS_CAN_COMMENT,
                        String.valueOf(membersCanComment))
                && settingsDAO.saveValue(AppSettings.MAINTENANCE_MODE,
                        String.valueOf(maintenance));

        if (!ok) {
            redirect(request, response, "system", "error",
                    "Could not save the settings. Please try again.");
            return;
        }

        redirect(request, response, "system", "saved",
                maintenance
                        ? "System settings saved. Maintenance mode is ON: only admins can log in."
                        : "System settings saved.");
    }

    /* =====================================================
       HELPERS
       ===================================================== */

    private static String trim(String value) {
        return value == null ? "" : value.trim();
    }

    private static Integer parseInt(String value) {
        try {
            return Integer.valueOf(value == null ? "" : value.trim());
        } catch (NumberFormatException e) {
            return null;
        }
    }

    /**
     * Passwords may still be plain text for very old accounts
     * (login upgrades them to BCrypt), so accept both.
     */
    private static boolean passwordMatches(String entered, String stored) {

        if (stored == null) {
            return false;
        }

        if (stored.startsWith("$2a$")
                || stored.startsWith("$2b$")
                || stored.startsWith("$2y$")) {
            return PasswordUtil.checkPassword(entered, stored);
        }

        return stored.equals(entered);
    }

    private void redirect(HttpServletRequest request,
                          HttpServletResponse response,
                          String tab,
                          String kind,
                          String message)
            throws IOException {

        response.sendRedirect(
                request.getContextPath()
                        + "/settings?tab=" + tab
                        + "&" + kind + "="
                        + URLEncoder.encode(message, StandardCharsets.UTF_8)
        );
    }
}
