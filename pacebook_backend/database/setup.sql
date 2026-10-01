CREATE DATABASE IF NOT EXISTS uts_pacebook
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE uts_pacebook;

-- Sequelize akan auto-sync tabel saat server start (sync: alter)
-- Script ini hanya create database dan grant privileges

-- Jika menggunakan user selain root:
-- CREATE USER IF NOT EXISTS 'pacebook_user'@'localhost' IDENTIFIED BY 'your_password';
-- GRANT ALL PRIVILEGES ON uts_pacebook.* TO 'pacebook_user'@'localhost';
-- FLUSH PRIVILEGES;

SELECT 'Database uts_pacebook siap digunakan!' AS status;