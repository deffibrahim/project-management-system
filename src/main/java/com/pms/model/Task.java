    package com.pms.model;

    import java.sql.Date;

    public class Task {
        private int taskId;
        private int projectId;
        private String title;
        private String description;
        private int assigneeId;
        private String status; // PENDING, IN_PROGRESS, COMPLETED
    private String priority; // LOW, MEDIUM, HIGH, URGENT
        private Date dueDate;

        public Task() {}

        public int getTaskId() { return taskId; }
        public void setTaskId(int taskId) { this.taskId = taskId; }

        public int getProjectId() { return projectId; }
        public void setProjectId(int projectId) { this.projectId = projectId; }

        public String getTitle() { return title; }
        public void setTitle(String title) { this.title = title; }

        public String getDescription() { return description; }
        public void setDescription(String description) { this.description = description; }

        public int getAssigneeId() { return assigneeId; }
        public void setAssigneeId(int assigneeId) { this.assigneeId = assigneeId; }

        public String getStatus() { return status; }
        public void setStatus(String status) { this.status = status; }

        public String getPriority() { return priority; }
        public void setPriority(String priority) { this.priority = priority; }

        public Date getDueDate() { return dueDate; }
        public void setDueDate(Date dueDate) { this.dueDate = dueDate; }
    }