package com.pms.controller;

import com.pms.dao.TaskDAO;
import com.pms.dao.UserDAO;
import com.pms.model.Task;
import com.pms.model.User;
import com.pms.model.WorkloadRow;
import com.pms.util.TaskUi;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * GET /workload - how much work each team member is carrying.
 *
 *   ADMIN           - counts every task
 *   PROJECT_MANAGER - counts tasks in the projects they manage
 *                     (all team members are still listed, so they can see
 *                      who has room for the next task)
 */
@WebServlet("/workload")
public class WorkloadServlet extends BaseServlet {

    private final TaskDAO taskDAO = new TaskDAO();
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        User user = getLoggedInUser(request);

        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/index.html");
            return;
        }

        String role = user.getRole();

        List<Task> tasks;

        if ("ADMIN".equals(role)) {
            tasks = taskDAO.getAllTasks();
        } else if ("PROJECT_MANAGER".equals(role)) {
            tasks = taskDAO.getTasksByProjectManagerId(user.getUserId());
        } else {
            response.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "Only admins and project managers can view the workload board."
            );
            return;
        }

        // One row per team member, even those with no tasks yet.
        Map<Integer, WorkloadRow> rows = new LinkedHashMap<>();

        for (User member : userDAO.getAllUsers()) {
            if ("TEAM_MEMBER".equals(member.getRole())) {
                rows.put(member.getUserId(),
                        new WorkloadRow(member.getUserId(), member.getName(), member.getEmail()));
            }
        }

        WorkloadRow unassigned = new WorkloadRow(0, "Unassigned", "");

        for (Task task : tasks) {

            WorkloadRow row = task.getAssigneeId() > 0
                    ? rows.get(task.getAssigneeId())
                    : unassigned;

            // Assigned to someone who is no longer a team member: count as unassigned.
            if (row == null) {
                row = unassigned;
            }

            String status = task.getStatus() == null ? "" : task.getStatus();

            if ("COMPLETED".equalsIgnoreCase(status)) {

                row.addCompleted();

            } else {

                if ("IN_PROGRESS".equalsIgnoreCase(status)) {
                    row.addInProgress();
                } else {
                    row.addPending();
                }

                if (TaskUi.isOverdue(task)) {
                    row.addOverdue();
                }

                if ("URGENT".equalsIgnoreCase(task.getPriority())) {
                    row.addUrgent();
                }
            }
        }

        // Heaviest workload first.
        List<WorkloadRow> sorted = new ArrayList<>(rows.values());

        sorted.sort((a, b) -> {
            int byOpen = Integer.compare(b.getOpen(), a.getOpen());
            return byOpen != 0
                    ? byOpen
                    : a.getName().compareToIgnoreCase(b.getName());
        });

        request.setAttribute("rows", sorted);
        request.setAttribute("unassigned", unassigned);

        request.getRequestDispatcher(
                "/dashboard/workload.jsp"
        ).forward(request, response);
    }
}
