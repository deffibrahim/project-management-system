package com.pms.controller;

import com.pms.dao.TaskDAO;
import com.pms.dao.UserDAO;
import com.pms.dao.UserPreferencesDAO;
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

@WebServlet("/tasks")
public class ListTasksServlet extends HttpServlet {

    private final TaskDAO taskDAO = new TaskDAO();

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

        String role = user.getRole();

        List<Task> tasks;

        if ("TEAM_MEMBER".equals(role)) {

            // Team members can only see their assigned tasks.
            tasks = taskDAO.getTasksByAssigneeId(
                    user.getUserId()
            );

        } else if ("PROJECT_MANAGER".equals(role)) {

            // Project managers see tasks in projects they manage.
            tasks = taskDAO.getTasksByProjectManagerId(
                    user.getUserId()
            );

        } else if ("ADMIN".equals(role)) {

            // Admin sees all tasks.
            tasks = taskDAO.getAllTasks();

        } else {

            response.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "You do not have permission to view tasks."
            );
            return;
        }

        // Optional filter from the workload board: ?assignee=<user id> (0 = unassigned).
        String assigneeParam = request.getParameter("assignee");

        if (assigneeParam != null && !"TEAM_MEMBER".equals(role)) {

            try {

                final int assigneeId = Integer.parseInt(assigneeParam.trim());

                tasks.removeIf(t -> t.getAssigneeId() != assigneeId);

                String label = "Unassigned";

                if (assigneeId > 0) {

                    User assignee = new UserDAO().getUserById(assigneeId);

                    label = assignee != null ? assignee.getName() : "User #" + assigneeId;
                }

                request.setAttribute("assigneeFilter", assigneeId);
                request.setAttribute("assigneeFilterLabel", label);

            } catch (NumberFormatException e) {
                // Ignore a malformed filter and show everything.
            }
        }

        // Preference: hide completed tasks (can be overridden with ?showCompleted=1).
        boolean hidePref =
                new UserPreferencesDAO().getPreferences(user.getUserId()).isHideCompleted();

        boolean showCompleted = "1".equals(request.getParameter("showCompleted"));

        int hiddenCompleted = 0;

        if (hidePref && !showCompleted) {

            int before = tasks.size();

            tasks.removeIf(t -> "COMPLETED".equalsIgnoreCase(t.getStatus()));

            hiddenCompleted = before - tasks.size();
        }

        request.setAttribute("hideCompletedPref", hidePref);
        request.setAttribute("showingCompleted", showCompleted);
        request.setAttribute("hiddenCompleted", hiddenCompleted);

        request.setAttribute("tasks", tasks);

        request.getRequestDispatcher(
                "/dashboard/tasks.jsp"
        ).forward(request, response);
    }
}