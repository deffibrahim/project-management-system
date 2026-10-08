package com.pms.controller;

import com.pms.dao.CommentDAO;
import com.pms.dao.ProjectDAO;
import com.pms.dao.TaskDAO;
import com.pms.dao.UserDAO;
import com.pms.model.Task;
import com.pms.model.User;
import com.pms.util.AppSettings;
import com.pms.util.TaskAccess;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

/**
 * GET /tasks/view?id=...  - one task with its comments.
 */
@WebServlet("/tasks/view")
public class TaskDetailServlet extends BaseServlet {

    private final TaskDAO taskDAO = new TaskDAO();
    private final ProjectDAO projectDAO = new ProjectDAO();
    private final UserDAO userDAO = new UserDAO();
    private final CommentDAO commentDAO = new CommentDAO();

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        User user = getLoggedInUser(request);

        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/index.html");
            return;
        }

        int taskId;

        try {
            taskId = Integer.parseInt(request.getParameter("id"));
        } catch (NumberFormatException e) {
            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Valid task id is required."
            );
            return;
        }

        Task task = taskDAO.getTaskById(taskId);

        if (task == null) {
            response.sendError(
                    HttpServletResponse.SC_NOT_FOUND,
                    "Task not found."
            );
            return;
        }

        if (!TaskAccess.canAccess(user, task)) {
            response.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "You do not have permission to view this task."
            );
            return;
        }

        request.setAttribute("task", task);
        request.setAttribute("project", projectDAO.getProjectById(task.getProjectId()));
        request.setAttribute("assignee",
                task.getAssigneeId() > 0 ? userDAO.getUserById(task.getAssigneeId()) : null);
        request.setAttribute("comments", commentDAO.getCommentsByTaskId(taskId));
        request.setAttribute("canComment",
                !"TEAM_MEMBER".equals(user.getRole())
                        || AppSettings.isMembersCanComment());

        request.getRequestDispatcher(
                "/dashboard/task-detail.jsp"
        ).forward(request, response);
    }
}
