package com.pms.controller;

import com.pms.dao.ProjectDAO;
import com.pms.dao.TaskDAO;
import com.pms.model.Project;
import com.pms.model.Task;
import com.pms.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

@WebServlet("/dashboard/project-manager")
public class ProjectManagerDashboardServlet extends HttpServlet {

    private final ProjectDAO projectDAO = new ProjectDAO();
    private final TaskDAO taskDAO = new TaskDAO();

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null) {
            response.sendRedirect(
                    request.getContextPath() + "/index.html"
            );
            return;
        }

        User user = (User) session.getAttribute("user");

        if (user == null) {
            response.sendRedirect(
                    request.getContextPath() + "/index.html"
            );
            return;
        }

        if (!"PROJECT_MANAGER".equals(user.getRole())) {
            response.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "Access denied."
            );
            return;
        }

        int managerId = user.getUserId();

        List<Project> projects =
                projectDAO.getProjectsByManagerId(managerId);

        List<Task> tasks =
                taskDAO.getTasksByProjectManagerId(managerId);

        request.setAttribute("projects", projects);
        request.setAttribute("tasks", tasks);

        request.getRequestDispatcher(
                "/dashboard/project-manager.jsp"
        ).forward(request, response);
    }
}