package com.pms.controller;

import com.pms.dao.UserDAO;
import com.pms.dao.UserPreferencesDAO;
import com.pms.model.UserPreferences;
import com.pms.model.User;
import com.pms.util.AppSettings;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req,
                          HttpServletResponse resp)
            throws ServletException, IOException {

        String email = req.getParameter("email");
        String password = req.getParameter("password");

        UserDAO userDAO = new UserDAO();
        User user = userDAO.loginUser(email, password);

        if (user != null) {

            /*
             * Maintenance mode (Settings > System): only admins may log in.
             */
            if (!"ADMIN".equals(user.getRole())
                    && AppSettings.isMaintenanceMode()) {

                resp.sendRedirect(
                        req.getContextPath() + "/index.html?error=maintenance"
                );
                return;
            }

            /*
             * Session Fixation Protection:
             * Invalidate the existing session after successful authentication
             * and create a completely new session.
             */
            HttpSession oldSession = req.getSession(false);

            if (oldSession != null) {
                oldSession.invalidate();
            }

            HttpSession session = req.getSession(true);

            // Session timeout comes from Settings > System.
            session.setMaxInactiveInterval(
                    AppSettings.getSessionTimeoutMinutes() * 60
            );

            session.setAttribute("user", user);
            session.setAttribute("role", user.getRole());

            String role = user.getRole();

            String dashboard;

            if ("ADMIN".equals(role)) {
                dashboard = "/dashboard/admin";
            } else if ("PROJECT_MANAGER".equals(role)) {
                dashboard = "/dashboard/project-manager";
            } else if ("TEAM_MEMBER".equals(role)) {
                dashboard = "/dashboard/team-member";
            } else {

                resp.sendRedirect(
                        req.getContextPath() + "/index.html?error=invalid_role"
                );
                return;
            }

            // Start page chosen in Settings > Preferences.
            UserPreferences prefs =
                    new UserPreferencesDAO().getPreferences(user.getUserId());

            String target = dashboard;

            if (UserPreferences.LANDING_TASKS.equals(prefs.getLandingPage())) {
                target = "/tasks";
            } else if (UserPreferences.LANDING_PROJECTS.equals(prefs.getLandingPage())) {
                target = "/projects";
            }

            resp.sendRedirect(req.getContextPath() + target);

        } else {

            resp.sendRedirect(
                    req.getContextPath() + "/index.html?error=invalid_credentials"
            );
        }
    }
}