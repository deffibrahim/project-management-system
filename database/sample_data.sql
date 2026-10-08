-- =======================================================
-- Project Management System (PMS)
-- Seed & Sample Data (Review 1)
-- =======================================================

USE pms_db;

-- -------------------------------------------------------
-- 1. Default Users
-- Passwords:
--   admin@pms.com   -> admin123
--   manager@pms.com -> manager123
--   john@pms.com    -> member123
--   sarah@pms.com   -> member123
-- -------------------------------------------------------
INSERT INTO users (user_id, name, email, password, role) VALUES
(1, 'System Administrator', 'admin@pms.com', 'admin123', 'ADMIN'),
(2, 'Alex Carter (Project Manager)', 'manager@pms.com', '$2a$10$vWhng8lKtKVO7ImNLBhkCOnzWIdQ.m7je97p4eLfGMbtgOabpEOZ.', 'PROJECT_MANAGER'),
(3, 'John Miller', 'john@pms.com', '$2a$10$SSin8IXB14ejlG8bOA9j1.DvqiyZz9Q/8aZxdhckHT4lNB2z5ITJG', 'TEAM_MEMBER'),
(4, 'Sarah Connor', 'sarah@pms.com', '$2a$10$SSin8IXB14ejlG8bOA9j1.DvqiyZz9Q/8aZxdhckHT4lNB2z5ITJG', 'TEAM_MEMBER')
ON DUPLICATE KEY UPDATE name=VALUES(name), role=VALUES(role);

-- -------------------------------------------------------
-- 2. Sample Projects
-- -------------------------------------------------------
INSERT INTO projects (project_id, title, description, start_date, end_date, manager_id, status) VALUES
(1, 'Enterprise ERP Portal', 'Modern cloud-based Enterprise Resource Planning portal migration and UI/UX modernization.', '2026-09-01', '2026-12-15', 2, 'ACTIVE'),
(2, 'Mobile Client API 2.0', 'High performance RESTful APIs for iOS and Android native clients with token caching.', '2026-10-01', '2026-11-30', 2, 'PLANNED'),
(3, 'Infrastructure Security Hardening', 'Database indexing, penetration test remediations, and CSRF token layer integration.', '2026-08-10', '2026-09-28', 2, 'COMPLETED')
ON DUPLICATE KEY UPDATE title=VALUES(title), description=VALUES(description), status=VALUES(status);

-- -------------------------------------------------------
-- 3. Sample Tasks
-- -------------------------------------------------------
INSERT INTO tasks (task_id, project_id, title, description, assignee_id, status, priority, due_date) VALUES
(1, 1, 'Design Dashboard Wireframes', 'Create responsive wireframes and layout structures for desktop and tablet screens.', 3, 'COMPLETED', 'HIGH', '2026-09-15'),
(2, 1, 'Implement Role-Based Access Filter', 'Enforce URL interception and session authorization for Admin, Manager, and Member routes.', 3, 'COMPLETED', 'HIGH', '2026-09-25'),
(3, 1, 'Construct Project CRUD Servlets', 'Build servlets handling creation, editing, status changes, and deletion of projects.', 4, 'IN_PROGRESS', 'URGENT', '2026-10-15'),
(4, 1, 'Design Task Status Toggle UI', 'Add quick status update actions on member dashboards to transition pending tasks.', 4, 'IN_PROGRESS', 'MEDIUM', '2026-10-20'),
(5, 2, 'Draft API Specification Document', 'Define OpenAPI / Swagger schemas for client authentication and project endpoints.', 3, 'PENDING', 'MEDIUM', '2026-11-05'),
(6, 2, 'Database Connection Pool Integration', 'Benchmark and evaluate HikariCP connection pooling for production readiness.', 4, 'PENDING', 'LOW', '2026-11-12'),
(7, 3, 'Remediate OWASP Top 10 Vulnerabilities', 'Ensure CSRF token coverage and input sanitization against SQL injection and XSS.', 3, 'COMPLETED', 'HIGH', '2026-09-20')
ON DUPLICATE KEY UPDATE title=VALUES(title), status=VALUES(status), priority=VALUES(priority);

-- -------------------------------------------------------
-- 4. Sample System Settings
-- -------------------------------------------------------
INSERT INTO system_settings (setting_id, setting_name, setting_value) VALUES
(1, 'Application Name', 'Project Management System (PMS)'),
(2, 'Version', '1.0.0-REVIEW-1'),
(3, 'Default Page Size', '10'),
(4, 'Support Email', 'support@pms.internal'),
(5, 'Review Milestone', 'Review 1 - Architecture, CRUD & Security Hardening')
ON DUPLICATE KEY UPDATE setting_value=VALUES(setting_value);
