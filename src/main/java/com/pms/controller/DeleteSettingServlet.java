package com.pms.controller;

import com.pms.dao.SystemSettingsDAO;
import com.pms.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet("/settings/delete")
public class DeleteSettingServlet extends HttpServlet {

    private final SystemSettingsDAO settingsDAO = new SystemSettingsDAO();

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
         * Only ADMIN can delete system settings.
         */
        if (!"ADMIN".equals(currentUser.getRole())) {
            response.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "You do not have permission to delete system settings."
            );
            return;
        }

        String idParameter = request.getParameter("id");

        if (idParameter == null || idParameter.trim().isEmpty()) {
            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Setting ID is required."
            );
            return;
        }

        int settingId;

        try {
            settingId = Integer.parseInt(idParameter);
        } catch (NumberFormatException e) {
            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Invalid setting ID."
            );
            return;
        }

        boolean success = settingsDAO.deleteSetting(settingId);

        if (success) {

            response.sendRedirect(
                    request.getContextPath() + "/settings"
            );

        } else {

            response.sendError(
                    HttpServletResponse.SC_NOT_FOUND,
                    "Setting not found or could not be deleted."
            );
        }
    }
}