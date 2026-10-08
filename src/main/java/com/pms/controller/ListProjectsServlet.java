package com.pms.controller;

import com.pms.dao.ProjectDAO;
import com.pms.model.Project;
import com.pms.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

@WebServlet("/projects")
public class ListProjectsServlet extends HttpServlet {

    private final ProjectDAO projectDAO = new ProjectDAO();

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null) {
            response.sendError(
                    HttpServletResponse.SC_UNAUTHORIZED,
                    "Login required."
            );
            return;
        }

        User user = (User) session.getAttribute("user");

        if (user == null) {
            response.sendError(
                    HttpServletResponse.SC_UNAUTHORIZED,
                    "Login required."
            );
            return;
        }

        List<Project> projects;

        if ("PROJECT_MANAGER".equals(user.getRole())) {

            // Project managers can only see their own projects
            projects = projectDAO.getProjectsByManagerId(
                    user.getUserId()
            );

        } else {

            // ADMIN and TEAM_MEMBER can see all projects
            projects = projectDAO.getAllProjects();
        }

        request.setAttribute("projects", projects);

        request.getRequestDispatcher(
                "/dashboard/projects.jsp"
        ).forward(request, response);
    }
}