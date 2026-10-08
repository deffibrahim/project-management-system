package com.pms.controller;

import com.pms.dao.UserDAO;
import com.pms.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet("/profile")
public class ProfileServlet extends BaseServlet {

    private final UserDAO userDAO = new UserDAO();

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

        updated.setName(request.getParameter("name"));
        updated.setEmail(request.getParameter("email"));

        String pwd = request.getParameter("password");

        if (pwd != null && !pwd.isBlank()) {
            updated.setPassword(pwd);
        } else {
            // Keep the existing password
            updated.setPassword(null);
        }

        boolean success = userDAO.updateUser(updated);

        if (success) {
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