-- Migration 01: add task priority
-- Run once against an existing pms_db (new installs get this from schema.sql).
USE pms_db;

ALTER TABLE tasks
    ADD COLUMN priority VARCHAR(20) NOT NULL DEFAULT 'MEDIUM' AFTER status;

ALTER TABLE tasks
    ADD CONSTRAINT chk_task_priority
    CHECK (priority IN ('LOW', 'MEDIUM', 'HIGH', 'URGENT'));
