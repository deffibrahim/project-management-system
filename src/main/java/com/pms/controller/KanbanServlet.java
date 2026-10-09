package com.pms.controller;

import com.pms.dao.TaskDAO;
import com.pms.model.Task;
import com.pms.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

/** Read-only Kanban board built from the user's existing, authorized task list. */
@WebServlet("/kanban")
public class KanbanServlet extends BaseServlet {
    private final TaskDAO taskDAO = new TaskDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = getLoggedInUser(request);
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/index.html");
            return;
        }

        List<Task> visibleTasks;
        switch (user.getRole()) {
            case "ADMIN":
                visibleTasks = taskDAO.getAllTasks();
                break;
            case "PROJECT_MANAGER":
                visibleTasks = taskDAO.getTasksByProjectManagerId(user.getUserId());
                break;
            case "TEAM_MEMBER":
                visibleTasks = taskDAO.getTasksByAssigneeId(user.getUserId());
                break;
            default:
                response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied.");
                return;
        }

        List<Task> pending = new ArrayList<>();
        List<Task> inProgress = new ArrayList<>();
        List<Task> completed = new ArrayList<>();
        for (Task task : visibleTasks) {
            String status = task.getStatus() == null ? "PENDING" : task.getStatus().toUpperCase();
            if ("COMPLETED".equals(status)) completed.add(task);
            else if ("IN_PROGRESS".equals(status)) inProgress.add(task);
            else pending.add(task); // Unknown legacy values stay visible instead of disappearing.
        }

        request.setAttribute("pendingTasks", pending);
        request.setAttribute("inProgressTasks", inProgress);
        request.setAttribute("completedTasks", completed);
        request.setAttribute("kanbanTotal", visibleTasks.size());
        request.getRequestDispatcher("/dashboard/kanban.jsp").forward(request, response);
    }
}
