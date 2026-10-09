package com.pms.controller;

import com.pms.dao.TaskDAO;
import com.pms.model.Task;
import com.pms.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

/** Live deadline alerts derived from real task due dates; no fake or persisted notifications. */
@WebServlet("/deadlines")
public class DeadlineServlet extends BaseServlet {
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

        LocalDate today = LocalDate.now();
        LocalDate soonLimit = today.plusDays(3);
        List<Task> overdue = new ArrayList<>();
        List<Task> dueSoon = new ArrayList<>();
        List<Task> missingDate = new ArrayList<>();

        for (Task task : visibleTasks) {
            if ("COMPLETED".equalsIgnoreCase(task.getStatus())) continue;
            if (task.getDueDate() == null) {
                missingDate.add(task);
                continue;
            }
            LocalDate due = task.getDueDate().toLocalDate();
            if (due.isBefore(today)) overdue.add(task);
            else if (!due.isAfter(soonLimit)) dueSoon.add(task);
        }

        request.setAttribute("overdueTasks", overdue);
        request.setAttribute("dueSoonTasks", dueSoon);
        request.setAttribute("missingDateTasks", missingDate);
        request.setAttribute("deadlineToday", today);
        request.setAttribute("deadlineSoonLimit", soonLimit);
        request.getRequestDispatcher("/dashboard/deadlines.jsp").forward(request, response);
    }
}
