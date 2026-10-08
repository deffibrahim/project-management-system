package com.pms.controller;

import com.pms.dao.TaskDAO;
import com.pms.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet("/tasks/delete")
public class DeleteTaskServlet extends HttpServlet {

    private final TaskDAO taskDAO = new TaskDAO();

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

        User user = (User) session.getAttribute("user");

        if (user == null) {
            response.sendError(
                    HttpServletResponse.SC_UNAUTHORIZED,
                    "You must be logged in."
            );
            return;
        }

        /*
         * Only ADMIN can delete tasks.
         */
        if (!"ADMIN".equals(user.getRole())) {

            response.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "You do not have permission to delete tasks."
            );

            return;
        }

        String taskIdParameter = request.getParameter("id");

        if (taskIdParameter == null) {
            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Task ID is required."
            );
            return;
        }

        int taskId;

        try {
            taskId = Integer.parseInt(taskIdParameter);
        } catch (NumberFormatException e) {
            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Invalid task ID."
            );
            return;
        }

        boolean deleted = taskDAO.deleteTask(taskId);

        if (deleted) {

            response.sendRedirect(
                    request.getContextPath() + "/tasks"
            );

        } else {

            response.sendError(
                    HttpServletResponse.SC_NOT_FOUND,
                    "Task not found or could not be deleted."
            );
        }
    }
}