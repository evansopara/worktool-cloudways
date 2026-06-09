-- ============================================================================
--  WC DIGITAL WORKTOOL — LARAVEL-COMPLIANT DATABASE SCHEMA (FRESH BUILD)
--  Target: https://phpstack-506002-6360796.cloudwaysapps.com
--  Database: bbxxanzmfx
--
--  This is a FRESH-BUILD schema rewritten to fully match Laravel conventions:
--    • All primary keys are BIGINT UNSIGNED AUTO_INCREMENT
--    • All foreign-key columns are BIGINT UNSIGNED to match users.id
--    • TEXT NOT NULL fields converted to VARCHAR where they're used as
--      lookups, identifiers or defaultable fields (TEXT cannot have defaults
--      and indexes poorly)
--    • created_at / updated_at / deleted_at follow Laravel's TIMESTAMP
--      conventions; soft deletes are added on user-data tables
--    • Laravel framework tables are included (migrations, password_reset_tokens,
--      personal_access_tokens, failed_jobs, jobs, sessions, cache, cache_locks)
--    • Foreign-key constraints with proper ON DELETE behaviour
--    • Indexes on every foreign-key column AND on common filter columns
--      (status, deadline, created_at, etc.) — fixes the slow-query issue
--    • The `created_by` column the app expected on `projects` is included
--    • A real `general_channel` row exists by default so /api/messages/general
--      doesn't crash on lookup
--
--  ----------------------------------------------------------------------------
--  HOW TO USE
--  ----------------------------------------------------------------------------
--  1. BACK UP THE EXISTING DATABASE FIRST (Cloudways panel → Backups → Take
--     Backup Now). This script DROPS every table.
--
--  2. If you want to migrate existing data after this fresh build, export
--     just the INSERT statements from your current dump and load them after
--     this schema is in place. The id columns and column names are mostly
--     identical, so existing data will load cleanly.
--
--  3. Run as:
--       mysql -u <user> -p bbxxanzmfx < laravel_schema.sql
--
--  4. After running, on the Laravel app:
--       php artisan config:clear
--       php artisan cache:clear
--       php artisan migrate:status   (should show "no migrations" — that's OK)
--       Optional: php artisan migrate:install   (creates migration tracking)
-- ============================================================================

SET FOREIGN_KEY_CHECKS = 0;
SET NAMES utf8mb4;
SET time_zone = '+00:00';

-- ============================================================================
-- DROP existing tables (in reverse-dependency order)
-- ============================================================================

DROP TABLE IF EXISTS `stop_gap_task_assignments`;
DROP TABLE IF EXISTS `stop_gap_allocations`;
DROP TABLE IF EXISTS `task_iterations`;
DROP TABLE IF EXISTS `task_sessions`;
DROP TABLE IF EXISTS `technical_support_requests`;
DROP TABLE IF EXISTS `staff_queries`;
DROP TABLE IF EXISTS `staff_complaints`;
DROP TABLE IF EXISTS `sop_segments`;
DROP TABLE IF EXISTS `sops`;
DROP TABLE IF EXISTS `review_requests`;
DROP TABLE IF EXISTS `review_links`;
DROP TABLE IF EXISTS `resources`;
DROP TABLE IF EXISTS `deliverables`;
DROP TABLE IF EXISTS `project_plans`;
DROP TABLE IF EXISTS `project_messages`;
DROP TABLE IF EXISTS `project_members`;
DROP TABLE IF EXISTS `project_briefings`;
DROP TABLE IF EXISTS `tasks`;
DROP TABLE IF EXISTS `projects`;
DROP TABLE IF EXISTS `performance`;
DROP TABLE IF EXISTS `notifications`;
DROP TABLE IF EXISTS `notes`;
DROP TABLE IF EXISTS `message_read_receipts`;
DROP TABLE IF EXISTS `messages`;
DROP TABLE IF EXISTS `memo_responses`;
DROP TABLE IF EXISTS `memo_reads`;
DROP TABLE IF EXISTS `memos`;
DROP TABLE IF EXISTS `leave_applications`;
DROP TABLE IF EXISTS `issue_reports`;
DROP TABLE IF EXISTS `general_channel_read_receipts`;
DROP TABLE IF EXISTS `general_channel_messages`;
DROP TABLE IF EXISTS `general_channel`;
DROP TABLE IF EXISTS `direct_messages`;
DROP TABLE IF EXISTS `deadline_extension_requests`;
DROP TABLE IF EXISTS `complaints`;
DROP TABLE IF EXISTS `client_sentiment`;
DROP TABLE IF EXISTS `client_invitations`;
DROP TABLE IF EXISTS `bookings`;
DROP TABLE IF EXISTS `users`;

-- Drop Replit/Drizzle leftover tables
DROP TABLE IF EXISTS `replit_database_migrations_v1`;
DROP TABLE IF EXISTS `__drizzle_migrations`;

-- Drop Laravel framework tables (recreated below)
DROP TABLE IF EXISTS `password_reset_tokens`;
DROP TABLE IF EXISTS `password_resets`;
DROP TABLE IF EXISTS `personal_access_tokens`;
DROP TABLE IF EXISTS `failed_jobs`;
DROP TABLE IF EXISTS `jobs`;
DROP TABLE IF EXISTS `job_batches`;
DROP TABLE IF EXISTS `sessions`;
DROP TABLE IF EXISTS `cache`;
DROP TABLE IF EXISTS `cache_locks`;
DROP TABLE IF EXISTS `migrations`;

-- ============================================================================
-- LARAVEL FRAMEWORK TABLES
-- ============================================================================

CREATE TABLE `migrations` (
    `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `migration` VARCHAR(255) NOT NULL,
    `batch` INT NOT NULL,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `password_reset_tokens` (
    `email` VARCHAR(255) NOT NULL,
    `token` VARCHAR(255) NOT NULL,
    `created_at` TIMESTAMP NULL DEFAULT NULL,
    PRIMARY KEY (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `personal_access_tokens` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `tokenable_type` VARCHAR(255) NOT NULL,
    `tokenable_id` BIGINT UNSIGNED NOT NULL,
    `name` VARCHAR(255) NOT NULL,
    `token` VARCHAR(64) NOT NULL,
    `abilities` TEXT NULL,
    `last_used_at` TIMESTAMP NULL DEFAULT NULL,
    `expires_at` TIMESTAMP NULL DEFAULT NULL,
    `created_at` TIMESTAMP NULL DEFAULT NULL,
    `updated_at` TIMESTAMP NULL DEFAULT NULL,
    PRIMARY KEY (`id`),
    UNIQUE KEY `personal_access_tokens_token_unique` (`token`),
    KEY `personal_access_tokens_tokenable_index` (`tokenable_type`, `tokenable_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `failed_jobs` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `uuid` VARCHAR(255) NOT NULL,
    `connection` TEXT NOT NULL,
    `queue` TEXT NOT NULL,
    `payload` LONGTEXT NOT NULL,
    `exception` LONGTEXT NOT NULL,
    `failed_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `failed_jobs_uuid_unique` (`uuid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `jobs` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `queue` VARCHAR(255) NOT NULL,
    `payload` LONGTEXT NOT NULL,
    `attempts` TINYINT UNSIGNED NOT NULL,
    `reserved_at` INT UNSIGNED NULL,
    `available_at` INT UNSIGNED NOT NULL,
    `created_at` INT UNSIGNED NOT NULL,
    PRIMARY KEY (`id`),
    KEY `jobs_queue_index` (`queue`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `job_batches` (
    `id` VARCHAR(255) NOT NULL,
    `name` VARCHAR(255) NOT NULL,
    `total_jobs` INT NOT NULL,
    `pending_jobs` INT NOT NULL,
    `failed_jobs` INT NOT NULL,
    `failed_job_ids` LONGTEXT NOT NULL,
    `options` MEDIUMTEXT NULL,
    `cancelled_at` INT NULL,
    `created_at` INT NOT NULL,
    `finished_at` INT NULL,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `sessions` (
    `id` VARCHAR(255) NOT NULL,
    `user_id` BIGINT UNSIGNED NULL,
    `ip_address` VARCHAR(45) NULL,
    `user_agent` TEXT NULL,
    `payload` LONGTEXT NOT NULL,
    `last_activity` INT NOT NULL,
    PRIMARY KEY (`id`),
    KEY `sessions_user_id_index` (`user_id`),
    KEY `sessions_last_activity_index` (`last_activity`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `cache` (
    `key` VARCHAR(255) NOT NULL,
    `value` MEDIUMTEXT NOT NULL,
    `expiration` INT NOT NULL,
    PRIMARY KEY (`key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `cache_locks` (
    `key` VARCHAR(255) NOT NULL,
    `owner` VARCHAR(255) NOT NULL,
    `expiration` INT NOT NULL,
    PRIMARY KEY (`key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- USERS  (parent of nearly every other table)
-- ============================================================================

CREATE TABLE `users` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `username` VARCHAR(100) NOT NULL,
    `name` VARCHAR(150) NOT NULL,
    `email` VARCHAR(180) NOT NULL,
    `email_verified_at` TIMESTAMP NULL DEFAULT NULL,
    `password` VARCHAR(255) NOT NULL,
    `role` VARCHAR(50) NOT NULL DEFAULT 'staff',
    `status` VARCHAR(30) NOT NULL DEFAULT 'offline',
    `specialization` VARCHAR(150) NULL,
    `work_status` VARCHAR(30) NOT NULL DEFAULT 'active',
    `gender` VARCHAR(20) NULL,
    `project_manager_type` ENUM('main', 'supervisor') NULL,
    `client_type` VARCHAR(50) NULL,
    `product_service` VARCHAR(150) NULL,
    `onboarding_status` VARCHAR(30) NOT NULL DEFAULT 'not_onboarded',
    `must_set_password` TINYINT(1) NOT NULL DEFAULT 0,
    `password_setup_token` VARCHAR(120) NULL,
    `verification_token` VARCHAR(120) NULL,
    `reset_password_token` VARCHAR(120) NULL,
    `reset_password_expires` TIMESTAMP NULL DEFAULT NULL,
    `is_active` TINYINT(1) NOT NULL DEFAULT 1,
    `current_task_id` BIGINT UNSIGNED NULL,
    `task_start_time` TIMESTAMP NULL DEFAULT NULL,
    `break_start_time` TIMESTAMP NULL DEFAULT NULL,
    `break_count` INT UNSIGNED NOT NULL DEFAULT 0,
    `break_one_time` VARCHAR(50) NULL,
    `absence_reason` VARCHAR(50) NOT NULL DEFAULT 'not_applicable',
    `absence_end_date` TIMESTAMP NULL DEFAULT NULL,
    `last_active` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    `last_seen` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    `remember_token` VARCHAR(100) NULL,
    `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `deleted_at` TIMESTAMP NULL DEFAULT NULL,
    PRIMARY KEY (`id`),
    UNIQUE KEY `users_username_unique` (`username`),
    UNIQUE KEY `users_email_unique` (`email`),
    KEY `users_role_index` (`role`),
    KEY `users_status_index` (`status`),
    KEY `users_is_active_index` (`is_active`),
    KEY `users_deleted_at_index` (`deleted_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- PROJECTS
-- ============================================================================

CREATE TABLE `projects` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `name` VARCHAR(200) NOT NULL,
    `description` TEXT NULL,
    `category` VARCHAR(100) NULL,
    `type` VARCHAR(100) NOT NULL,
    `status` VARCHAR(30) NOT NULL DEFAULT 'pending',
    `client_id` BIGINT UNSIGNED NULL,
    `manager_id` BIGINT UNSIGNED NOT NULL,
    `created_by` BIGINT UNSIGNED NULL,
    `progress` TINYINT UNSIGNED NOT NULL DEFAULT 0,
    `start_date` DATE NULL,
    `end_date` DATE NULL,
    `pending_client_email` VARCHAR(180) NULL,
    `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `deleted_at` TIMESTAMP NULL DEFAULT NULL,
    PRIMARY KEY (`id`),
    KEY `projects_client_id_index` (`client_id`),
    KEY `projects_manager_id_index` (`manager_id`),
    KEY `projects_created_by_index` (`created_by`),
    KEY `projects_status_index` (`status`),
    KEY `projects_deleted_at_index` (`deleted_at`),
    CONSTRAINT `projects_client_id_foreign` FOREIGN KEY (`client_id`) REFERENCES `users`(`id`) ON DELETE SET NULL,
    CONSTRAINT `projects_manager_id_foreign` FOREIGN KEY (`manager_id`) REFERENCES `users`(`id`) ON DELETE RESTRICT,
    CONSTRAINT `projects_created_by_foreign` FOREIGN KEY (`created_by`) REFERENCES `users`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- TASKS
-- ============================================================================

CREATE TABLE `tasks` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `title` VARCHAR(255) NOT NULL,
    `description` TEXT NULL,
    `project_id` BIGINT UNSIGNED NULL,
    `assignee_id` BIGINT UNSIGNED NULL,
    `assigned_by` BIGINT UNSIGNED NULL,
    `status` VARCHAR(30) NOT NULL DEFAULT 'todo',
    `priority` VARCHAR(20) NOT NULL DEFAULT 'medium',
    `progress` TINYINT UNSIGNED NOT NULL DEFAULT 0,
    `iteration_number` INT UNSIGNED NOT NULL DEFAULT 1,
    `start_date` DATETIME NULL,
    `deadline` DATETIME NULL,
    `actual_start_time` DATETIME NULL,
    `review_started_at` DATETIME NULL,
    `completed_at` DATETIME NULL,
    `working_hours` INT UNSIGNED NOT NULL DEFAULT 0,
    `working_minutes` INT UNSIGNED NOT NULL DEFAULT 0,
    `time_spent` INT UNSIGNED NOT NULL DEFAULT 0,
    `is_timer_running` TINYINT(1) NOT NULL DEFAULT 0,
    `timer_start_time` DATETIME NULL,
    `has_been_started` TINYINT(1) NOT NULL DEFAULT 0,
    `timer_sessions` JSON NULL,
    `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `deleted_at` TIMESTAMP NULL DEFAULT NULL,
    PRIMARY KEY (`id`),
    KEY `tasks_project_id_index` (`project_id`),
    KEY `tasks_assignee_id_index` (`assignee_id`),
    KEY `tasks_assigned_by_index` (`assigned_by`),
    KEY `tasks_status_index` (`status`),
    KEY `tasks_deadline_index` (`deadline`),
    KEY `tasks_is_timer_running_index` (`is_timer_running`),
    KEY `tasks_deleted_at_index` (`deleted_at`),
    CONSTRAINT `tasks_project_id_foreign` FOREIGN KEY (`project_id`) REFERENCES `projects`(`id`) ON DELETE CASCADE,
    CONSTRAINT `tasks_assignee_id_foreign` FOREIGN KEY (`assignee_id`) REFERENCES `users`(`id`) ON DELETE SET NULL,
    CONSTRAINT `tasks_assigned_by_foreign` FOREIGN KEY (`assigned_by`) REFERENCES `users`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Add the FK from users.current_task_id → tasks.id now that tasks exists
ALTER TABLE `users`
    ADD CONSTRAINT `users_current_task_id_foreign`
    FOREIGN KEY (`current_task_id`) REFERENCES `tasks`(`id`) ON DELETE SET NULL;

-- ============================================================================
-- TASK SESSIONS  (timer)
-- ============================================================================

CREATE TABLE `task_sessions` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `task_id` BIGINT UNSIGNED NOT NULL,
    `user_id` BIGINT UNSIGNED NOT NULL,
    `start_time` DATETIME NOT NULL,
    `end_time` DATETIME NULL,
    `duration` INT UNSIGNED NULL,
    `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `task_sessions_task_id_index` (`task_id`),
    KEY `task_sessions_user_id_index` (`user_id`),
    KEY `task_sessions_end_time_index` (`end_time`),
    CONSTRAINT `task_sessions_task_id_foreign` FOREIGN KEY (`task_id`) REFERENCES `tasks`(`id`) ON DELETE CASCADE,
    CONSTRAINT `task_sessions_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- TASK ITERATIONS
-- ============================================================================

CREATE TABLE `task_iterations` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `task_id` BIGINT UNSIGNED NOT NULL,
    `iteration_number` INT UNSIGNED NOT NULL,
    `assignee_id` BIGINT UNSIGNED NULL,
    `assigned_by` BIGINT UNSIGNED NULL,
    `reassigned_by` BIGINT UNSIGNED NULL,
    `description` TEXT NULL,
    `status` VARCHAR(30) NULL,
    `start_date` DATETIME NULL,
    `deadline` DATETIME NULL,
    `working_hours` INT UNSIGNED NOT NULL DEFAULT 0,
    `working_minutes` INT UNSIGNED NOT NULL DEFAULT 0,
    `time_spent` INT UNSIGNED NOT NULL DEFAULT 0,
    `notes` TEXT NULL,
    `completed_at` DATETIME NULL,
    `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `task_iter_task_id_index` (`task_id`),
    KEY `task_iter_assignee_id_index` (`assignee_id`),
    KEY `task_iter_assigned_by_index` (`assigned_by`),
    KEY `task_iter_reassigned_by_index` (`reassigned_by`),
    CONSTRAINT `task_iter_task_id_foreign` FOREIGN KEY (`task_id`) REFERENCES `tasks`(`id`) ON DELETE CASCADE,
    CONSTRAINT `task_iter_assignee_id_foreign` FOREIGN KEY (`assignee_id`) REFERENCES `users`(`id`) ON DELETE SET NULL,
    CONSTRAINT `task_iter_assigned_by_foreign` FOREIGN KEY (`assigned_by`) REFERENCES `users`(`id`) ON DELETE SET NULL,
    CONSTRAINT `task_iter_reassigned_by_foreign` FOREIGN KEY (`reassigned_by`) REFERENCES `users`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- DEADLINE EXTENSION REQUESTS
-- ============================================================================

CREATE TABLE `deadline_extension_requests` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `task_id` BIGINT UNSIGNED NOT NULL,
    `requester_id` BIGINT UNSIGNED NOT NULL,
    `project_manager_id` BIGINT UNSIGNED NOT NULL,
    `decided_by` BIGINT UNSIGNED NULL,
    `reason` TEXT NOT NULL,
    `requested_deadline` DATETIME NULL,
    `approved_deadline` DATETIME NULL,
    `approved_working_hours` INT UNSIGNED NULL,
    `decision_reason` TEXT NULL,
    `decided_at` DATETIME NULL,
    `status` VARCHAR(30) NOT NULL DEFAULT 'pending',
    `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `der_task_id_index` (`task_id`),
    KEY `der_requester_id_index` (`requester_id`),
    KEY `der_pm_id_index` (`project_manager_id`),
    KEY `der_decided_by_index` (`decided_by`),
    KEY `der_status_index` (`status`),
    CONSTRAINT `der_task_id_foreign` FOREIGN KEY (`task_id`) REFERENCES `tasks`(`id`) ON DELETE CASCADE,
    CONSTRAINT `der_requester_id_foreign` FOREIGN KEY (`requester_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
    CONSTRAINT `der_pm_id_foreign` FOREIGN KEY (`project_manager_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
    CONSTRAINT `der_decided_by_foreign` FOREIGN KEY (`decided_by`) REFERENCES `users`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- PROJECT MEMBERS
-- ============================================================================

CREATE TABLE `project_members` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `project_id` BIGINT UNSIGNED NOT NULL,
    `user_id` BIGINT UNSIGNED NOT NULL,
    `role` VARCHAR(50) NOT NULL DEFAULT 'member',
    `invitation_status` VARCHAR(30) NOT NULL DEFAULT 'pending',
    `invited_by` BIGINT UNSIGNED NULL,
    `invited_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    `joined_at` TIMESTAMP NULL DEFAULT NULL,
    `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `pm_project_user_unique` (`project_id`, `user_id`),
    KEY `pm_project_id_index` (`project_id`),
    KEY `pm_user_id_index` (`user_id`),
    KEY `pm_invited_by_index` (`invited_by`),
    CONSTRAINT `pm_project_id_foreign` FOREIGN KEY (`project_id`) REFERENCES `projects`(`id`) ON DELETE CASCADE,
    CONSTRAINT `pm_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
    CONSTRAINT `pm_invited_by_foreign` FOREIGN KEY (`invited_by`) REFERENCES `users`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- PROJECT BRIEFINGS
-- ============================================================================

CREATE TABLE `project_briefings` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `project_name` VARCHAR(200) NOT NULL,
    `client_name` VARCHAR(200) NOT NULL,
    `category` VARCHAR(100) NOT NULL,
    `project_details` TEXT NOT NULL,
    `created_by` BIGINT UNSIGNED NOT NULL,
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `pb_created_by_index` (`created_by`),
    CONSTRAINT `pb_created_by_foreign` FOREIGN KEY (`created_by`) REFERENCES `users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- PROJECT PLANS  &  DELIVERABLES
-- ============================================================================

CREATE TABLE `project_plans` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `project_id` BIGINT UNSIGNED NOT NULL,
    `name` VARCHAR(200) NOT NULL,
    `description` TEXT NULL,
    `start_date` DATETIME NULL,
    `end_date` DATETIME NULL,
    `status` VARCHAR(30) NOT NULL DEFAULT 'draft',
    `created_by` BIGINT UNSIGNED NOT NULL,
    `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `pp_project_id_index` (`project_id`),
    KEY `pp_created_by_index` (`created_by`),
    CONSTRAINT `pp_project_id_foreign` FOREIGN KEY (`project_id`) REFERENCES `projects`(`id`) ON DELETE CASCADE,
    CONSTRAINT `pp_created_by_foreign` FOREIGN KEY (`created_by`) REFERENCES `users`(`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `deliverables` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `project_plan_id` BIGINT UNSIGNED NOT NULL,
    `assignee_id` BIGINT UNSIGNED NULL,
    `name` VARCHAR(200) NOT NULL,
    `description` TEXT NULL,
    `start_date` DATETIME NOT NULL,
    `end_date` DATETIME NOT NULL,
    `duration` INT UNSIGNED NULL,
    `status` VARCHAR(30) NOT NULL DEFAULT 'pending',
    `order` INT UNSIGNED NOT NULL DEFAULT 0,
    `dependencies` JSON NULL,
    `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `del_plan_id_index` (`project_plan_id`),
    KEY `del_assignee_id_index` (`assignee_id`),
    CONSTRAINT `del_plan_id_foreign` FOREIGN KEY (`project_plan_id`) REFERENCES `project_plans`(`id`) ON DELETE CASCADE,
    CONSTRAINT `del_assignee_id_foreign` FOREIGN KEY (`assignee_id`) REFERENCES `users`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- MESSAGES (project-scoped chat)
-- ============================================================================

CREATE TABLE `messages` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `content` TEXT NOT NULL,
    `project_id` BIGINT UNSIGNED NULL,
    `user_id` BIGINT UNSIGNED NULL,
    `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `messages_project_id_index` (`project_id`),
    KEY `messages_user_id_index` (`user_id`),
    KEY `messages_created_at_index` (`created_at`),
    CONSTRAINT `messages_project_id_foreign` FOREIGN KEY (`project_id`) REFERENCES `projects`(`id`) ON DELETE CASCADE,
    CONSTRAINT `messages_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `message_read_receipts` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `message_id` BIGINT UNSIGNED NOT NULL,
    `user_id` BIGINT UNSIGNED NOT NULL,
    `read_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `mrr_message_user_unique` (`message_id`, `user_id`),
    KEY `mrr_user_id_index` (`user_id`),
    CONSTRAINT `mrr_message_id_foreign` FOREIGN KEY (`message_id`) REFERENCES `messages`(`id`) ON DELETE CASCADE,
    CONSTRAINT `mrr_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- PROJECT MESSAGES (separate channel-style chat per project)
-- ============================================================================

CREATE TABLE `project_messages` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `project_id` BIGINT UNSIGNED NOT NULL,
    `sender_id` BIGINT UNSIGNED NOT NULL,
    `content` TEXT NOT NULL,
    `is_edited` TINYINT(1) NOT NULL DEFAULT 0,
    `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `pmsg_project_id_index` (`project_id`),
    KEY `pmsg_sender_id_index` (`sender_id`),
    KEY `pmsg_created_at_index` (`created_at`),
    CONSTRAINT `pmsg_project_id_foreign` FOREIGN KEY (`project_id`) REFERENCES `projects`(`id`) ON DELETE CASCADE,
    CONSTRAINT `pmsg_sender_id_foreign` FOREIGN KEY (`sender_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- DIRECT MESSAGES
-- ============================================================================

CREATE TABLE `direct_messages` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `sender_id` BIGINT UNSIGNED NOT NULL,
    `receiver_id` BIGINT UNSIGNED NOT NULL,
    `content` TEXT NOT NULL,
    `read` TINYINT(1) NOT NULL DEFAULT 0,
    `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `dm_sender_id_index` (`sender_id`),
    KEY `dm_receiver_id_index` (`receiver_id`),
    KEY `dm_created_at_index` (`created_at`),
    KEY `dm_conversation_index` (`sender_id`, `receiver_id`, `created_at`),
    CONSTRAINT `dm_sender_id_foreign` FOREIGN KEY (`sender_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
    CONSTRAINT `dm_receiver_id_foreign` FOREIGN KEY (`receiver_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- GENERAL CHANNEL  (company-wide chat)
-- ============================================================================

CREATE TABLE `general_channel` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `name` VARCHAR(50) NOT NULL DEFAULT 'general',
    `description` VARCHAR(255) NULL,
    `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `gc_name_unique` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Seed the default 'general' channel so /api/messages/general doesn't 500
INSERT INTO `general_channel` (`name`, `description`) VALUES ('general', 'Company-wide channel');

CREATE TABLE `general_channel_messages` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `channel_id` BIGINT UNSIGNED NOT NULL DEFAULT 1,
    `sender_id` BIGINT UNSIGNED NOT NULL,
    `content` TEXT NOT NULL,
    `is_edited` TINYINT(1) NOT NULL DEFAULT 0,
    `is_pinned` TINYINT(1) NOT NULL DEFAULT 0,
    `reactions` JSON NULL,
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `gcm_channel_id_index` (`channel_id`),
    KEY `gcm_sender_id_index` (`sender_id`),
    KEY `gcm_created_at_index` (`created_at`),
    CONSTRAINT `gcm_channel_id_foreign` FOREIGN KEY (`channel_id`) REFERENCES `general_channel`(`id`) ON DELETE CASCADE,
    CONSTRAINT `gcm_sender_id_foreign` FOREIGN KEY (`sender_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `general_channel_read_receipts` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `message_id` BIGINT UNSIGNED NOT NULL,
    `user_id` BIGINT UNSIGNED NOT NULL,
    `read_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `gcrr_message_user_unique` (`message_id`, `user_id`),
    KEY `gcrr_user_id_index` (`user_id`),
    CONSTRAINT `gcrr_message_id_foreign` FOREIGN KEY (`message_id`) REFERENCES `general_channel_messages`(`id`) ON DELETE CASCADE,
    CONSTRAINT `gcrr_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- NOTIFICATIONS
-- ============================================================================

CREATE TABLE `notifications` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `user_id` BIGINT UNSIGNED NOT NULL,
    `type` VARCHAR(100) NOT NULL,
    `content` TEXT NOT NULL,
    `reference_id` BIGINT UNSIGNED NULL,
    `reference_type` VARCHAR(100) NULL,
    `read` TINYINT(1) NOT NULL DEFAULT 0,
    `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `notif_user_id_index` (`user_id`),
    KEY `notif_read_index` (`read`),
    KEY `notif_created_at_index` (`created_at`),
    KEY `notif_reference_index` (`reference_type`, `reference_id`),
    CONSTRAINT `notif_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- NOTES
-- ============================================================================

CREATE TABLE `notes` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `title` VARCHAR(255) NOT NULL DEFAULT '',
    `content` TEXT NOT NULL,
    `type` VARCHAR(30) NOT NULL DEFAULT 'freetext',
    `category` VARCHAR(50) NOT NULL DEFAULT 'general',
    `todo_items` JSON NULL,
    `created_by` BIGINT UNSIGNED NOT NULL,
    `user_id` BIGINT UNSIGNED NULL,
    `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `deleted_at` TIMESTAMP NULL DEFAULT NULL,
    PRIMARY KEY (`id`),
    KEY `notes_created_by_index` (`created_by`),
    KEY `notes_user_id_index` (`user_id`),
    KEY `notes_deleted_at_index` (`deleted_at`),
    CONSTRAINT `notes_created_by_foreign` FOREIGN KEY (`created_by`) REFERENCES `users`(`id`) ON DELETE CASCADE,
    CONSTRAINT `notes_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- MEMOS
-- ============================================================================

CREATE TABLE `memos` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `title` VARCHAR(255) NOT NULL,
    `content` TEXT NOT NULL,
    `type` VARCHAR(50) NOT NULL,
    `recipients` JSON NOT NULL,
    `sent_by` BIGINT UNSIGNED NOT NULL,
    `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `memos_sent_by_index` (`sent_by`),
    CONSTRAINT `memos_sent_by_foreign` FOREIGN KEY (`sent_by`) REFERENCES `users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `memo_reads` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `memo_id` BIGINT UNSIGNED NOT NULL,
    `user_id` BIGINT UNSIGNED NOT NULL,
    `read_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `memo_reads_memo_user_unique` (`memo_id`, `user_id`),
    KEY `memo_reads_user_id_index` (`user_id`),
    CONSTRAINT `memo_reads_memo_id_foreign` FOREIGN KEY (`memo_id`) REFERENCES `memos`(`id`) ON DELETE CASCADE,
    CONSTRAINT `memo_reads_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `memo_responses` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `memo_id` BIGINT UNSIGNED NOT NULL,
    `user_id` BIGINT UNSIGNED NOT NULL,
    `content` TEXT NOT NULL,
    `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `memo_resp_memo_id_index` (`memo_id`),
    KEY `memo_resp_user_id_index` (`user_id`),
    CONSTRAINT `memo_resp_memo_id_foreign` FOREIGN KEY (`memo_id`) REFERENCES `memos`(`id`) ON DELETE CASCADE,
    CONSTRAINT `memo_resp_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- BOOKINGS
-- ============================================================================

CREATE TABLE `bookings` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `title` VARCHAR(200) NOT NULL,
    `description` TEXT NULL,
    `type` VARCHAR(50) NOT NULL,
    `scheduled_by` BIGINT UNSIGNED NOT NULL,
    `participants` JSON NOT NULL,
    `start_time` DATETIME NOT NULL,
    `end_time` DATETIME NOT NULL,
    `meeting_link` VARCHAR(500) NULL,
    `notes` TEXT NULL,
    `status` VARCHAR(30) NOT NULL DEFAULT 'scheduled',
    `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `bookings_scheduled_by_index` (`scheduled_by`),
    KEY `bookings_start_time_index` (`start_time`),
    KEY `bookings_status_index` (`status`),
    CONSTRAINT `bookings_scheduled_by_foreign` FOREIGN KEY (`scheduled_by`) REFERENCES `users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- COMPLAINTS
-- ============================================================================

CREATE TABLE `complaints` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `name` VARCHAR(150) NOT NULL,
    `email` VARCHAR(180) NOT NULL,
    `product_manager_name` VARCHAR(150) NULL,
    `developer_name` VARCHAR(150) NULL,
    `technical_manager_name` VARCHAR(150) NULL,
    `valuable_things` JSON NULL,
    `detailed_explanation` TEXT NOT NULL,
    `screenshot_url` VARCHAR(500) NULL,
    `submitter_id` BIGINT UNSIGNED NULL,
    `reviewed_by` BIGINT UNSIGNED NULL,
    `review_comments` TEXT NULL,
    `reviewed_at` DATETIME NULL,
    `status` VARCHAR(30) NOT NULL DEFAULT 'pending',
    `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `complaints_submitter_id_index` (`submitter_id`),
    KEY `complaints_reviewed_by_index` (`reviewed_by`),
    KEY `complaints_status_index` (`status`),
    CONSTRAINT `complaints_submitter_id_foreign` FOREIGN KEY (`submitter_id`) REFERENCES `users`(`id`) ON DELETE SET NULL,
    CONSTRAINT `complaints_reviewed_by_foreign` FOREIGN KEY (`reviewed_by`) REFERENCES `users`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `staff_complaints` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `name` VARCHAR(150) NOT NULL,
    `email` VARCHAR(180) NOT NULL,
    `department` VARCHAR(100) NULL,
    `detailed_explanation` TEXT NOT NULL,
    `screenshot_url` VARCHAR(500) NULL,
    `submitter_id` BIGINT UNSIGNED NULL,
    `review_comments` TEXT NULL,
    `reviewed_at` DATETIME NULL,
    `status` VARCHAR(30) NOT NULL DEFAULT 'pending',
    `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `sc_submitter_id_index` (`submitter_id`),
    KEY `sc_status_index` (`status`),
    CONSTRAINT `sc_submitter_id_foreign` FOREIGN KEY (`submitter_id`) REFERENCES `users`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- STAFF QUERIES
-- ============================================================================

CREATE TABLE `staff_queries` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `staff_id` BIGINT UNSIGNED NOT NULL,
    `staff_name` VARCHAR(150) NOT NULL,
    `department` VARCHAR(100) NOT NULL,
    `staff_unique_value` VARCHAR(255) NOT NULL,
    `reason` TEXT NOT NULL,
    `why_query` TEXT NOT NULL,
    `attachment_path` VARCHAR(500) NULL,
    `likely_penalty` VARCHAR(255) NOT NULL,
    `additional_note` TEXT NULL,
    `sent_by` BIGINT UNSIGNED NOT NULL,
    `status` VARCHAR(30) NOT NULL DEFAULT 'pending',
    `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `sq_staff_id_index` (`staff_id`),
    KEY `sq_sent_by_index` (`sent_by`),
    KEY `sq_status_index` (`status`),
    CONSTRAINT `sq_staff_id_foreign` FOREIGN KEY (`staff_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
    CONSTRAINT `sq_sent_by_foreign` FOREIGN KEY (`sent_by`) REFERENCES `users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- ISSUE REPORTS
-- ============================================================================

CREATE TABLE `issue_reports` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `title` VARCHAR(255) NOT NULL,
    `description` TEXT NOT NULL,
    `suggestions` TEXT NULL,
    `reporter_name` VARCHAR(150) NOT NULL,
    `reporter_email` VARCHAR(180) NOT NULL,
    `priority` VARCHAR(20) NOT NULL DEFAULT 'medium',
    `category` VARCHAR(50) NOT NULL DEFAULT 'other',
    `screenshot_url` VARCHAR(500) NULL,
    `submitter_id` BIGINT UNSIGNED NULL,
    `reviewed_by` BIGINT UNSIGNED NULL,
    `reviewed_at` DATETIME NULL,
    `review_comments` TEXT NULL,
    `status` VARCHAR(30) NOT NULL DEFAULT 'pending',
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `ir_submitter_id_index` (`submitter_id`),
    KEY `ir_reviewed_by_index` (`reviewed_by`),
    KEY `ir_status_index` (`status`),
    KEY `ir_priority_index` (`priority`),
    CONSTRAINT `ir_submitter_id_foreign` FOREIGN KEY (`submitter_id`) REFERENCES `users`(`id`) ON DELETE SET NULL,
    CONSTRAINT `ir_reviewed_by_foreign` FOREIGN KEY (`reviewed_by`) REFERENCES `users`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- LEAVE APPLICATIONS
-- ============================================================================

CREATE TABLE `leave_applications` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `user_id` BIGINT UNSIGNED NOT NULL,
    `leave_type` VARCHAR(50) NOT NULL,
    `reason` TEXT NOT NULL,
    `start_date` DATETIME NOT NULL,
    `end_date` DATETIME NOT NULL,
    `total_days` INT UNSIGNED NOT NULL,
    `proof_image_url` VARCHAR(500) NULL,
    `applied_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    `reviewed_at` DATETIME NULL,
    `reviewed_by` BIGINT UNSIGNED NULL,
    `review_comments` TEXT NULL,
    `status` VARCHAR(30) NOT NULL DEFAULT 'pending',
    `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `la_user_id_index` (`user_id`),
    KEY `la_reviewed_by_index` (`reviewed_by`),
    KEY `la_status_index` (`status`),
    CONSTRAINT `la_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
    CONSTRAINT `la_reviewed_by_foreign` FOREIGN KEY (`reviewed_by`) REFERENCES `users`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- CLIENT INVITATIONS  &  CLIENT SENTIMENT
-- ============================================================================

CREATE TABLE `client_invitations` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `email` VARCHAR(180) NOT NULL,
    `project_id` BIGINT UNSIGNED NULL,
    `invited_by` BIGINT UNSIGNED NULL,
    `token` VARCHAR(120) NOT NULL,
    `status` VARCHAR(30) NOT NULL DEFAULT 'pending',
    `expires_at` DATETIME NOT NULL,
    `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `ci_token_unique` (`token`),
    KEY `ci_email_index` (`email`),
    KEY `ci_project_id_index` (`project_id`),
    KEY `ci_invited_by_index` (`invited_by`),
    KEY `ci_status_index` (`status`),
    CONSTRAINT `ci_project_id_foreign` FOREIGN KEY (`project_id`) REFERENCES `projects`(`id`) ON DELETE CASCADE,
    CONSTRAINT `ci_invited_by_foreign` FOREIGN KEY (`invited_by`) REFERENCES `users`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `client_sentiment` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `client_id` BIGINT UNSIGNED NOT NULL,
    `sentiment` VARCHAR(50) NOT NULL,
    `reason` TEXT NOT NULL,
    `week_start` DATE NOT NULL,
    `week_end` DATE NOT NULL,
    `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `cs_client_id_index` (`client_id`),
    KEY `cs_week_index` (`week_start`, `week_end`),
    CONSTRAINT `cs_client_id_foreign` FOREIGN KEY (`client_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- RESOURCES
-- ============================================================================

CREATE TABLE `resources` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `name` VARCHAR(255) NOT NULL,
    `type` VARCHAR(50) NOT NULL,
    `size` BIGINT UNSIGNED NULL,
    `path` VARCHAR(500) NULL,
    `link` VARCHAR(500) NULL,
    `project_id` BIGINT UNSIGNED NULL,
    `uploaded_by` BIGINT UNSIGNED NULL,
    `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `resources_project_id_index` (`project_id`),
    KEY `resources_uploaded_by_index` (`uploaded_by`),
    CONSTRAINT `resources_project_id_foreign` FOREIGN KEY (`project_id`) REFERENCES `projects`(`id`) ON DELETE CASCADE,
    CONSTRAINT `resources_uploaded_by_foreign` FOREIGN KEY (`uploaded_by`) REFERENCES `users`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- REVIEW LINKS  &  REVIEW REQUESTS
-- ============================================================================

CREATE TABLE `review_links` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `title` VARCHAR(255) NOT NULL,
    `link_url` VARCHAR(500) NOT NULL,
    `description` TEXT NULL,
    `sent_by` BIGINT UNSIGNED NOT NULL,
    `assigned_to` BIGINT UNSIGNED NOT NULL,
    `review_comment` TEXT NULL,
    `reviewed_at` DATETIME NULL,
    `commented_at` DATETIME NULL,
    `status` VARCHAR(30) NOT NULL DEFAULT 'pending',
    `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `rl_sent_by_index` (`sent_by`),
    KEY `rl_assigned_to_index` (`assigned_to`),
    KEY `rl_status_index` (`status`),
    CONSTRAINT `rl_sent_by_foreign` FOREIGN KEY (`sent_by`) REFERENCES `users`(`id`) ON DELETE CASCADE,
    CONSTRAINT `rl_assigned_to_foreign` FOREIGN KEY (`assigned_to`) REFERENCES `users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `review_requests` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `title` VARCHAR(255) NOT NULL,
    `description` TEXT NULL,
    `review_link` VARCHAR(500) NOT NULL,
    `project_manager_id` BIGINT UNSIGNED NOT NULL,
    `team_lead_id` BIGINT UNSIGNED NOT NULL,
    `review_notes` TEXT NULL,
    `completed_at` DATETIME NULL,
    `status` VARCHAR(30) NOT NULL DEFAULT 'pending',
    `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `rr_pm_id_index` (`project_manager_id`),
    KEY `rr_tl_id_index` (`team_lead_id`),
    KEY `rr_status_index` (`status`),
    CONSTRAINT `rr_pm_id_foreign` FOREIGN KEY (`project_manager_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
    CONSTRAINT `rr_tl_id_foreign` FOREIGN KEY (`team_lead_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- SOPs
-- ============================================================================

CREATE TABLE `sops` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `title` VARCHAR(255) NOT NULL,
    `department` VARCHAR(100) NOT NULL,
    `reference_link` VARCHAR(500) NULL,
    `created_by` BIGINT UNSIGNED NOT NULL,
    `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `sops_created_by_index` (`created_by`),
    KEY `sops_department_index` (`department`),
    CONSTRAINT `sops_created_by_foreign` FOREIGN KEY (`created_by`) REFERENCES `users`(`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `sop_segments` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `sop_id` BIGINT UNSIGNED NOT NULL,
    `title` VARCHAR(255) NOT NULL,
    `content` TEXT NOT NULL,
    `file_url` VARCHAR(500) NULL,
    `segment_order` INT UNSIGNED NOT NULL DEFAULT 0,
    `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `sop_seg_sop_id_index` (`sop_id`),
    KEY `sop_seg_order_index` (`sop_id`, `segment_order`),
    CONSTRAINT `sop_seg_sop_id_foreign` FOREIGN KEY (`sop_id`) REFERENCES `sops`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- TECHNICAL SUPPORT REQUESTS
-- ============================================================================

CREATE TABLE `technical_support_requests` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `title` VARCHAR(255) NOT NULL,
    `description` TEXT NOT NULL,
    `task_id` BIGINT UNSIGNED NULL,
    `requester_id` BIGINT UNSIGNED NOT NULL,
    `assigned_to_id` BIGINT UNSIGNED NULL,
    `priority` VARCHAR(20) NOT NULL DEFAULT 'medium',
    `resolution` TEXT NULL,
    `resolved_at` DATETIME NULL,
    `status` VARCHAR(30) NOT NULL DEFAULT 'pending',
    `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `tsr_task_id_index` (`task_id`),
    KEY `tsr_requester_id_index` (`requester_id`),
    KEY `tsr_assigned_to_id_index` (`assigned_to_id`),
    KEY `tsr_status_index` (`status`),
    KEY `tsr_priority_index` (`priority`),
    CONSTRAINT `tsr_task_id_foreign` FOREIGN KEY (`task_id`) REFERENCES `tasks`(`id`) ON DELETE SET NULL,
    CONSTRAINT `tsr_requester_id_foreign` FOREIGN KEY (`requester_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
    CONSTRAINT `tsr_assigned_to_id_foreign` FOREIGN KEY (`assigned_to_id`) REFERENCES `users`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- STOP-GAP ALLOCATIONS
-- ============================================================================

CREATE TABLE `stop_gap_allocations` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `user_id` BIGINT UNSIGNED NOT NULL,
    `month_year` VARCHAR(20) NOT NULL,
    `total_hours` INT UNSIGNED NOT NULL DEFAULT 5,
    `used_hours` DECIMAL(8,2) NOT NULL DEFAULT 0,
    `remaining_hours` DECIMAL(8,2) NOT NULL DEFAULT 5,
    `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `sga_user_month_unique` (`user_id`, `month_year`),
    KEY `sga_user_id_index` (`user_id`),
    CONSTRAINT `sga_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `stop_gap_task_assignments` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `task_id` BIGINT UNSIGNED NOT NULL,
    `user_id` BIGINT UNSIGNED NOT NULL,
    `stop_gap_hours` DECIMAL(8,2) NOT NULL,
    `month_year` VARCHAR(20) NOT NULL,
    `applied_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `sgta_task_id_index` (`task_id`),
    KEY `sgta_user_id_index` (`user_id`),
    KEY `sgta_month_year_index` (`month_year`),
    CONSTRAINT `sgta_task_id_foreign` FOREIGN KEY (`task_id`) REFERENCES `tasks`(`id`) ON DELETE CASCADE,
    CONSTRAINT `sgta_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- PERFORMANCE
-- ============================================================================

CREATE TABLE `performance` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `user_id` BIGINT UNSIGNED NULL,
    `metrics` JSON NOT NULL,
    `recorded_date` DATETIME NULL DEFAULT CURRENT_TIMESTAMP,
    `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `perf_user_id_index` (`user_id`),
    KEY `perf_recorded_date_index` (`recorded_date`),
    CONSTRAINT `perf_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- RESEED MIGRATIONS RECORD
-- ============================================================================
-- Mark schema as being at "fresh build" state. If you are running fresh
-- Laravel migrations on top of this, leave this empty and let artisan run.
-- ============================================================================

INSERT INTO `migrations` (`migration`, `batch`) VALUES
('0000_00_00_000000_create_initial_schema', 1);

SET FOREIGN_KEY_CHECKS = 1;

-- ============================================================================
-- DONE
-- ============================================================================
-- Verification queries to run after import:
--
--   SHOW TABLES;
--   SHOW CREATE TABLE projects;
--   SHOW INDEX FROM tasks;
--   SELECT * FROM general_channel;
--
-- Then on Laravel:
--   php artisan config:clear && php artisan cache:clear
-- ============================================================================
