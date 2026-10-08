package com.pms.model;

public class UserPreferences {

    public static final String LANDING_DASHBOARD = "DASHBOARD";
    public static final String LANDING_TASKS = "TASKS";
    public static final String LANDING_PROJECTS = "PROJECTS";

    private int userId;
    private String landingPage = LANDING_DASHBOARD;
    private boolean hideCompleted = false;

    public UserPreferences() {}

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public String getLandingPage() { return landingPage; }
    public void setLandingPage(String landingPage) { this.landingPage = landingPage; }

    public boolean isHideCompleted() { return hideCompleted; }
    public void setHideCompleted(boolean hideCompleted) { this.hideCompleted = hideCompleted; }

    public static boolean isValidLanding(String value) {
        return LANDING_DASHBOARD.equals(value)
                || LANDING_TASKS.equals(value)
                || LANDING_PROJECTS.equals(value);
    }
}
