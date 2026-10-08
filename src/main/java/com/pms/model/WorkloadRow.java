package com.pms.model;

/**
 * One line of the workload board: a team member (or the "Unassigned" bucket)
 * and how many tasks of each kind they currently carry.
 */
public class WorkloadRow {

    private int userId;          // 0 = unassigned bucket
    private String name;
    private String email;

    private int pending;
    private int inProgress;
    private int completed;
    private int overdue;         // open tasks past their due date
    private int urgent;          // open tasks with URGENT priority

    public WorkloadRow() {}

    public WorkloadRow(int userId, String name, String email) {
        this.userId = userId;
        this.name = name;
        this.email = email;
    }

    public int getUserId() { return userId; }
    public String getName() { return name; }
    public String getEmail() { return email; }

    public int getPending() { return pending; }
    public int getInProgress() { return inProgress; }
    public int getCompleted() { return completed; }
    public int getOverdue() { return overdue; }
    public int getUrgent() { return urgent; }

    public void addPending() { pending++; }
    public void addInProgress() { inProgress++; }
    public void addCompleted() { completed++; }
    public void addOverdue() { overdue++; }
    public void addUrgent() { urgent++; }

    /** Tasks still to be done (pending + in progress). */
    public int getOpen() { return pending + inProgress; }

    public int getTotal() { return pending + inProgress + completed; }
}
