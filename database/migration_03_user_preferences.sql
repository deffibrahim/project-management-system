-- Migration 03: per-user preferences (Settings > Preferences)
-- Run once against an existing pms_db (new installs get this from schema.sql).
USE pms_db;

CREATE TABLE IF NOT EXISTS user_preferences (
    user_id INT PRIMARY KEY,
    landing_page VARCHAR(20) NOT NULL DEFAULT 'DASHBOARD',
    hide_completed TINYINT(1) NOT NULL DEFAULT 0,
    CONSTRAINT fk_pref_user FOREIGN KEY (user_id)
        REFERENCES users(user_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT chk_pref_landing CHECK (landing_page IN ('DASHBOARD', 'TASKS', 'PROJECTS'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
