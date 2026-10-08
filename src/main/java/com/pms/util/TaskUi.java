package com.pms.util;

import com.pms.model.Task;

import java.time.LocalDate;

/**
 * Small helpers that turn task data into the badges shown on the pages.
 */
public final class TaskUi {

    private TaskUi() {
    }

    /** True when the task has a due date in the past and is not completed. */
    public static boolean isOverdue(Task task) {

        if (task == null
                || task.getDueDate() == null
                || "COMPLETED".equalsIgnoreCase(task.getStatus())) {
            return false;
        }

        return task.getDueDate().toLocalDate().isBefore(LocalDate.now());
    }

    /** HTML for the red "Overdue" badge, or an empty string. */
    public static String overdueBadge(Task task) {

        return isOverdue(task)
                ? "<span class=\"badge badge-overdue\">Overdue</span>"
                : "";
    }

    /** HTML for the priority badge (Low / Medium / High / Urgent). */
    public static String priorityBadge(Task task) {

        String priority = (task == null || task.getPriority() == null)
                ? "MEDIUM"
                : task.getPriority().toUpperCase();

        String label;
        String css;

        switch (priority) {
            case "URGENT": label = "Urgent"; css = "badge-urgent"; break;
            case "HIGH":   label = "High";   css = "badge-high";   break;
            case "LOW":    label = "Low";    css = "badge-low";    break;
            default:       label = "Medium"; css = "badge-medium"; break;
        }

        return "<span class=\"badge " + css + "\">" + label + "</span>";
    }
}
