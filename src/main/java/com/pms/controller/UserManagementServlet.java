package com.pms.controller;

import com.pms.dao.UserDAO;
import com.pms.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

/**
 * Admin‑only servlet for managing user accounts (list, create, edit, delete).
 * All POST actions validate the CSRF token via {@link BaseServlet#validateCsrf(HttpServletRequest)}.
 */
@WebServlet("/admin/users/*")
public class UserManagementServlet extends BaseServlet {
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // Verify admin role
        User admin = getLoggedInUser(req);
        if (admin == null || !"ADMIN".equals(admin.getRole())) {
            resp.sendRedirect(req.getContextPath() + "/index.html?error=unauthorized");
            return;
        }

        String path = req.getPathInfo(); // e.g. "/list", "/create", "/edit"
        if (path == null || "/list".equals(path) || "/".equals(path)) {
            List<User> users = userDAO.getAllUsers();
            req.setAttribute("users", users);
            req.getRequestDispatcher("/dashboard/admin.jsp").forward(req, resp);
        } else if ("/create".equals(path)) {
            req.getRequestDispatcher("/dashboard/user-create.jsp").forward(req, resp);
        } else if ("/edit".equals(path)) {
            int id = Integer.parseInt(req.getParameter("id"));
            User user = userDAO.getUserById(id);
            req.setAttribute("editUser", user);
            req.getRequestDispatcher("/dashboard/user-edit.jsp").forward(req, resp);
        } else {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // Verify admin role
        User admin = getLoggedInUser(req);
        if (admin == null || !"ADMIN".equals(admin.getRole())) {
            resp.sendRedirect(req.getContextPath() + "/index.html?error=unauthorized");
            return;
        }
        if (!validateCsrf(req)) {
            denyCsrf(resp);
            return;
        }
        String action = req.getParameter("action");
        if ("create".equals(action)) {
            String name = req.getParameter("name");
            String email = req.getParameter("email");
            String password = req.getParameter("password");
            String role = req.getParameter("role");
            User user = new User();
            user.setName(name);
            user.setEmail(email);
            user.setPassword(password); // DAO will hash it
            user.setRole(role);
            userDAO.createUser(user);
            resp.sendRedirect(req.getContextPath() + "/admin/users/list?success=1");
        } else if ("edit".equals(action)) {
            int id = Integer.parseInt(req.getParameter("id"));
            User user = userDAO.getUserById(id);
            if (user != null) {
                user.setName(req.getParameter("name"));
                user.setEmail(req.getParameter("email"));
                String newPass = req.getParameter("password");
                if (newPass != null && !newPass.isEmpty()) {
                    user.setPassword(newPass); // DAO will hash if needed
                }
                user.setRole(req.getParameter("role"));
                userDAO.updateUser(user);
            }
            resp.sendRedirect(req.getContextPath() + "/admin/users/list?success=1");
        } else if ("delete".equals(action)) {
            int id = Integer.parseInt(req.getParameter("id"));
            userDAO.deleteUser(id);
            resp.sendRedirect(req.getContextPath() + "/admin/users/list?success=1");
        } else {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST);
        }
    }
}
