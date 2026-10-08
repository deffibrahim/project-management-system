package com.pms.util;

import com.pms.dao.ProjectDAO;
import com.pms.model.Project;
import com.pms.model.Task;
import com.pms.model.User;

/**
 * Decides who may open a task and take part in its discussion.
 * Same rule as editing a task:
 *   ADMIN           - every task
 *   PROJECT_MANAGER - tasks in projects they manage
 *   TEAM_MEMBER     - tasks assigned to them
 */
public final class TaskAccess {

    private static final ProjectDAO PROJECT_DAO = new ProjectDAO();

    private TaskAccess() {
    }

    public static boolean canAccess(User user, Task task) {

        if (user == null || task == null) {
            return false;
        }

        String role = user.getRole();

        if ("ADMIN".equals(role)) {
            return true;
        }

        if ("PROJECT_MANAGER".equals(role)) {

            Project project = PROJECT_DAO.getProjectById(task.getProjectId());

            return project != null
                    && project.getManagerId() == user.getUserId();
        }

        if ("TEAM_MEMBER".equals(role)) {
            return task.getAssigneeId() == user.getUserId();
        }

        return false;
    }
}
