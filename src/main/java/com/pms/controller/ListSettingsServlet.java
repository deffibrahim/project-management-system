package com.pms.controller;

import com.pms.dao.UserDAO;
import com.pms.dao.UserPreferencesDAO;
import com.pms.model.User;
import com.pms.util.AppSettings;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

/**
 * Shows the Settings page. Every logged-in user gets the Account and
 * Preferences tabs; admins also get the System tab.
 */
@WebServlet("/settings")
public class ListSettingsServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();
    private final UserPreferencesDAO preferencesDAO = new UserPreferencesDAO();

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

        boolean isAdmin = "ADMIN".equals(currentUser.getRole());

        User fresh = userDAO.getUserById(currentUser.getUserId());

        request.setAttribute("account", fresh != null ? fresh : currentUser);
        request.setAttribute("preferences",
                preferencesDAO.getPreferences(currentUser.getUserId()));

        if (isAdmin) {
            request.setAttribute("sessionTimeout", AppSettings.getSessionTimeoutMinutes());
            request.setAttribute("minPasswordLength", AppSettings.getMinPasswordLength());
            request.setAttribute("pmCanCreateProjects", AppSettings.isPmCanCreateProjects());
            request.setAttribute("membersCanComment", AppSettings.isMembersCanComment());
            request.setAttribute("maintenanceMode", AppSettings.isMaintenanceMode());
        } else {
            request.setAttribute("minPasswordLength", AppSettings.getMinPasswordLength());
        }

        String tab = request.getParameter("tab");

        if ("preferences".equals(tab)) {
            request.setAttribute("tab", "preferences");
        } else if ("system".equals(tab) && isAdmin) {
            request.setAttribute("tab", "system");
        } else {
            request.setAttribute("tab", "account");
        }

        request.getRequestDispatcher(
                "/dashboard/settings.jsp"
        ).forward(request, response);
    }
}
