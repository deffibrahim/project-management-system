package com.pms.controller;

import com.pms.dao.ProjectDAO;
import com.pms.dao.TaskDAO;
import com.pms.dao.UserDAO;
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

@WebServlet("/dashboard/admin")
public class AdminDashboardServlet extends HttpServlet {

    private final ProjectDAO projectDAO = new ProjectDAO();
    private final TaskDAO taskDAO = new TaskDAO();
    private final UserDAO userDAO = new UserDAO();

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

        if (!"ADMIN".equals(user.getRole())) {
            response.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "Access denied."
            );
            return;
        }

        List<User> users = userDAO.getAllUsers();
        List<Project> projects = projectDAO.getAllProjects();
        List<Task> tasks = taskDAO.getAllTasks();

        int totalAdmins = 0;
        int totalProjectManagers = 0;
        int totalTeamMembers = 0;

        for (User currentUser : users) {

            if ("ADMIN".equals(currentUser.getRole())) {
                totalAdmins++;
            } else if ("PROJECT_MANAGER".equals(currentUser.getRole())) {
                totalProjectManagers++;
            } else if ("TEAM_MEMBER".equals(currentUser.getRole())) {
                totalTeamMembers++;
            }
        }

        int totalPlannedProjects = 0;
        int totalActiveProjects = 0;
        int totalCompletedProjects = 0;

        for (Project project : projects) {

            if ("PLANNED".equals(project.getStatus())) {
                totalPlannedProjects++;
            } else if ("ACTIVE".equals(project.getStatus())) {
                totalActiveProjects++;
            } else if ("COMPLETED".equals(project.getStatus())) {
                totalCompletedProjects++;
            }
        }

        int totalPendingTasks = 0;
        int totalInProgressTasks = 0;
        int totalCompletedTasks = 0;

        for (Task task : tasks) {

            if ("PENDING".equals(task.getStatus())) {
                totalPendingTasks++;
            } else if ("IN_PROGRESS".equals(task.getStatus())) {
                totalInProgressTasks++;
            } else if ("COMPLETED".equals(task.getStatus())) {
                totalCompletedTasks++;
            }
        }

        request.setAttribute("totalUsers", users.size());
        request.setAttribute("totalAdmins", totalAdmins);
        request.setAttribute("totalProjectManagers", totalProjectManagers);
        request.setAttribute("totalTeamMembers", totalTeamMembers);

        request.setAttribute("totalProjects", projects.size());
        request.setAttribute("totalPlannedProjects", totalPlannedProjects);
        request.setAttribute("totalActiveProjects", totalActiveProjects);
        request.setAttribute("totalCompletedProjects", totalCompletedProjects);

        request.setAttribute("totalTasks", tasks.size());
        request.setAttribute("totalPendingTasks", totalPendingTasks);
        request.setAttribute("totalInProgressTasks", totalInProgressTasks);
        request.setAttribute("totalCompletedTasks", totalCompletedTasks);

        request.getRequestDispatcher(
                "/dashboard/admin.jsp"
        ).forward(request, response);
    }
}