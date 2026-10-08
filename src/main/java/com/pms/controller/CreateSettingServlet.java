package com.pms.controller;

import com.pms.dao.SystemSettingsDAO;
import com.pms.model.SystemSetting;
import com.pms.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet("/settings/create")
public class CreateSettingServlet extends HttpServlet {

    private final SystemSettingsDAO settingsDAO =
            new SystemSettingsDAO();

    private boolean nameExists(String name) {

        for (SystemSetting existing : settingsDAO.getAllSettings()) {

            if (name.equalsIgnoreCase(existing.getSettingName())) {
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

        User currentUser =
                (User) session.getAttribute("user");

        if (currentUser == null) {
            response.sendError(
                    HttpServletResponse.SC_UNAUTHORIZED,
                    "You must be logged in."
            );
            return;
        }

        /*
         * Only ADMIN can create system settings.
         */
        if (!"ADMIN".equals(currentUser.getRole())) {
            response.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "You do not have permission to create system settings."
            );
            return;
        }

        String settingName =
                request.getParameter("settingName");

        String settingValue =
                request.getParameter("settingValue");

        /*
         * Validate setting name (database column allows 100 characters).
         */
        if (settingName == null
                || settingName.trim().isEmpty()) {

            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Setting name is required."
            );
            return;
        }

        settingName = settingName.trim();

        if (settingName.length() > 100) {

            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Setting name is too long."
            );
            return;
        }

        /*
         * Validate setting value (database column allows 255 characters).
         */
        if (settingValue == null
                || settingValue.trim().isEmpty()) {

            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Setting value is required."
            );
            return;
        }

        settingValue = settingValue.trim();

        if (settingValue.length() > 255) {

            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Setting value is too long."
            );
            return;
        }

        /*
         * Setting names must be unique.
         */
        if (nameExists(settingName)) {

            response.sendError(
                    HttpServletResponse.SC_CONFLICT,
                    "A setting with this name already exists."
            );
            return;
        }

        SystemSetting setting =
                new SystemSetting();

        setting.setSettingName(settingName);
        setting.setSettingValue(settingValue);

        boolean success =
                settingsDAO.createSetting(setting);

        if (success) {

            response.sendRedirect(
                    request.getContextPath() + "/settings"
            );

        } else {

            response.sendError(
                    HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    "Failed to create system setting."
            );
        }
    }
}