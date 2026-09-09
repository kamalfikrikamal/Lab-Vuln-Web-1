-- PT Nusantara Logistik - skema database
CREATE DATABASE IF NOT EXISTS nusalog CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE nusalog;

CREATE TABLE IF NOT EXISTS customers (
  id INT AUTO_INCREMENT PRIMARY KEY,
  full_name VARCHAR(100) NOT NULL,
  email VARCHAR(150) NOT NULL UNIQUE,
  phone VARCHAR(30),
  password_hash VARCHAR(255) NOT NULL,
  company VARCHAR(150),
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS shipments (
  id INT AUTO_INCREMENT PRIMARY KEY,
  tracking_id INT NOT NULL UNIQUE,
  customer_id INT NOT NULL,
  sender_name VARCHAR(100) NOT NULL,
  sender_address VARCHAR(255) NOT NULL,
  recipient_name VARCHAR(100) NOT NULL,
  recipient_address VARCHAR(255) NOT NULL,
  recipient_city VARCHAR(100) NOT NULL,
  package_description VARCHAR(255) NOT NULL,
  weight_kg DECIMAL(6,2) NOT NULL DEFAULT 1.00,
  status ENUM('diproses','dikirim','transit','terkirim','gagal') NOT NULL DEFAULT 'diproses',
  courier VARCHAR(50) NOT NULL DEFAULT 'NusaLog Express',
  internal_remarks TEXT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_shipments_customer FOREIGN KEY (customer_id) REFERENCES customers(id)
) ENGINE=InnoDB;

CREATE INDEX idx_shipments_tracking ON shipments (tracking_id);
CREATE INDEX idx_shipments_customer ON shipments (customer_id);

CREATE TABLE IF NOT EXISTS staff (
  id INT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(50) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  full_name VARCHAR(100) NOT NULL,
  role VARCHAR(50) NOT NULL DEFAULT 'staff',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;
