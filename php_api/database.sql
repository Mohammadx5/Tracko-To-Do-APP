CREATE DATABASE IF NOT EXISTS todo_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE todo_db;

DROP TABLE IF EXISTS tasks;

CREATE TABLE tasks (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    title       VARCHAR(255)                  NOT NULL,
    is_done     TINYINT(1)                    NOT NULL DEFAULT 0,
    priority    ENUM('low','medium','high')   NOT NULL DEFAULT 'medium',
    deadline    DATE                          NULL,
    created_at  DATETIME                      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at  DATETIME                      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO tasks (title, is_done, priority, deadline) VALUES
    ('Study for the exam 📚',      0, 'high',   DATE_ADD(CURDATE(), INTERVAL 2 DAY)),
    ('Team meeting preparation 👥', 0, 'medium', DATE_ADD(CURDATE(), INTERVAL 1 DAY)),
    ('Review pull requests 💻',     1, 'high',   CURDATE()),
    ('Read a new book 📖',          0, 'low',    DATE_ADD(CURDATE(), INTERVAL 7 DAY)),
    ('Finish project tasks 🚀',     0, 'high',   DATE_ADD(CURDATE(), INTERVAL 3 DAY));
