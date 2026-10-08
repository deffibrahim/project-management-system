package com.pms.util;

import com.pms.dao.SystemSettingsDAO;

/**
 * Typed access to the system settings that the application really uses.
 * Values live in the system_settings table; sensible defaults apply
 * when a setting has not been saved yet.
 */
public final class AppSettings {

    public static final String SESSION_TIMEOUT_MINUTES = "session_timeout_minutes";
    public static final String MIN_PASSWORD_LENGTH = "min_password_length";

    public static final String PM_CAN_CREATE_PROJECTS = "pm_can_create_projects";
    public static final String MEMBERS_CAN_COMMENT = "members_can_comment";
    public static final String MAINTENANCE_MODE = "maintenance_mode";

    public static final int DEFAULT_SESSION_TIMEOUT_MINUTES = 30;
    public static final int DEFAULT_MIN_PASSWORD_LENGTH = 6;

    public static final int MIN_TIMEOUT = 5;
    public static final int MAX_TIMEOUT = 480;

    public static final int MIN_PASSWORD_FLOOR = 6;
    /** BCrypt only uses the first 72 characters. */
    public static final int MAX_PASSWORD = 72;

    private static final SystemSettingsDAO DAO = new SystemSettingsDAO();

    private AppSettings() {
    }

    private static int readInt(String name, int defaultValue, int min, int max) {

        String raw = DAO.getValue(name);

        if (raw == null) {
            return defaultValue;
        }

        try {
            int value = Integer.parseInt(raw.trim());
            return Math.max(min, Math.min(max, value));
        } catch (NumberFormatException e) {
            return defaultValue;
        }
    }

    public static int getSessionTimeoutMinutes() {
        return readInt(SESSION_TIMEOUT_MINUTES,
                DEFAULT_SESSION_TIMEOUT_MINUTES, MIN_TIMEOUT, MAX_TIMEOUT);
    }

    public static int getMinPasswordLength() {
        return readInt(MIN_PASSWORD_LENGTH,
                DEFAULT_MIN_PASSWORD_LENGTH, MIN_PASSWORD_FLOOR, MAX_PASSWORD);
    }

    private static boolean readBool(String name, boolean defaultValue) {

        String raw = DAO.getValue(name);

        if (raw == null) {
            return defaultValue;
        }

        return "true".equalsIgnoreCase(raw.trim());
    }

    /** May project managers create projects? (default: yes) */
    public static boolean isPmCanCreateProjects() {
        return readBool(PM_CAN_CREATE_PROJECTS, true);
    }

    /** May team members post comments on tasks? (default: yes) */
    public static boolean isMembersCanComment() {
        return readBool(MEMBERS_CAN_COMMENT, true);
    }

    /** While on, only admins can log in. (default: off) */
    public static boolean isMaintenanceMode() {
        return readBool(MAINTENANCE_MODE, false);
    }
}
