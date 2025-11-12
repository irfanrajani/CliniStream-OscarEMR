-- NextScript Integration Tables
-- Database schema for RingCentral, Ocean, SMS, and other integrations

-- System configuration table
CREATE TABLE IF NOT EXISTS system_config (
    id INT PRIMARY KEY AUTO_INCREMENT,
    config_key VARCHAR(100) UNIQUE NOT NULL,
    config_value TEXT,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_config_key (config_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Integration configuration table
CREATE TABLE IF NOT EXISTS integration_config (
    id INT PRIMARY KEY AUTO_INCREMENT,
    integration_name VARCHAR(50) NOT NULL,
    config_key VARCHAR(100) NOT NULL,
    config_value TEXT,
    encrypted BOOLEAN DEFAULT FALSE,
    enabled BOOLEAN DEFAULT TRUE,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY unique_config (integration_name, config_key),
    INDEX idx_integration (integration_name),
    INDEX idx_enabled (enabled)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Fax queue table
CREATE TABLE IF NOT EXISTS fax_queue (
    id INT PRIMARY KEY AUTO_INCREMENT,
    to_number VARCHAR(20) NOT NULL,
    document_path VARCHAR(500) NOT NULL,
    cover_page TEXT,
    status ENUM('pending', 'sent', 'failed') DEFAULT 'pending',
    external_id VARCHAR(100),
    retry_count INT DEFAULT 0,
    last_error TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    sent_at TIMESTAMP NULL,
    INDEX idx_status (status),
    INDEX idx_created (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Fax log table
CREATE TABLE IF NOT EXISTS fax_log (
    id INT PRIMARY KEY AUTO_INCREMENT,
    external_id VARCHAR(100),
    direction ENUM('inbound', 'outbound') NOT NULL,
    from_number VARCHAR(20),
    to_number VARCHAR(20),
    file_path VARCHAR(500),
    status VARCHAR(50),
    received_date TIMESTAMP NULL,
    sent_date TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_external (external_id),
    INDEX idx_direction (direction),
    INDEX idx_created (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- SMS queue table
CREATE TABLE IF NOT EXISTS sms_queue (
    id INT PRIMARY KEY AUTO_INCREMENT,
    to_number VARCHAR(20) NOT NULL,
    message_text TEXT NOT NULL,
    patient_id INT,
    provider_id VARCHAR(6),
    scheduled_for TIMESTAMP NULL,
    status ENUM('pending', 'sent', 'failed') DEFAULT 'pending',
    external_id VARCHAR(100),
    retry_count INT DEFAULT 0,
    last_error TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    sent_at TIMESTAMP NULL,
    INDEX idx_status (status),
    INDEX idx_scheduled (scheduled_for),
    INDEX idx_patient (patient_id),
    FOREIGN KEY (patient_id) REFERENCES demographic(demographic_no) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- SMS log table
CREATE TABLE IF NOT EXISTS sms_log (
    id INT PRIMARY KEY AUTO_INCREMENT,
    external_id VARCHAR(100),
    to_number VARCHAR(20) NOT NULL,
    message_text TEXT NOT NULL,
    patient_id INT,
    provider_id VARCHAR(6),
    status VARCHAR(50),
    sent_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_external (external_id),
    INDEX idx_patient (patient_id),
    INDEX idx_created (created_at),
    FOREIGN KEY (patient_id) REFERENCES demographic(demographic_no) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Ocean referrals table
CREATE TABLE IF NOT EXISTS ocean_referrals (
    id INT PRIMARY KEY AUTO_INCREMENT,
    patient_id INT NOT NULL,
    specialist_id INT,
    ocean_referral_id VARCHAR(100),
    reason TEXT,
    priority ENUM('routine', 'urgent', 'emergent') DEFAULT 'routine',
    clinical_info TEXT,
    status VARCHAR(50) DEFAULT 'sent',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_patient (patient_id),
    INDEX idx_ocean_id (ocean_referral_id),
    INDEX idx_status (status),
    FOREIGN KEY (patient_id) REFERENCES demographic(demographic_no) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Patient portal users table
CREATE TABLE IF NOT EXISTS portal_users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    patient_id INT NOT NULL UNIQUE,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    activated BOOLEAN DEFAULT FALSE,
    activation_token VARCHAR(100),
    reset_token VARCHAR(100),
    reset_token_expires TIMESTAMP NULL,
    last_login TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_email (email),
    INDEX idx_patient (patient_id),
    INDEX idx_activation (activation_token),
    FOREIGN KEY (patient_id) REFERENCES demographic(demographic_no) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Patient portal messages table
CREATE TABLE IF NOT EXISTS portal_messages (
    id INT PRIMARY KEY AUTO_INCREMENT,
    patient_id INT NOT NULL,
    provider_id VARCHAR(6),
    subject VARCHAR(255),
    message_text TEXT NOT NULL,
    direction ENUM('to_patient', 'from_patient') NOT NULL,
    read_status BOOLEAN DEFAULT FALSE,
    read_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_patient (patient_id),
    INDEX idx_provider (provider_id),
    INDEX idx_unread (read_status, patient_id),
    INDEX idx_created (created_at),
    FOREIGN KEY (patient_id) REFERENCES demographic(demographic_no) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Appointment reminders table
CREATE TABLE IF NOT EXISTS appointment_reminders (
    id INT PRIMARY KEY AUTO_INCREMENT,
    appointment_id INT NOT NULL,
    patient_id INT NOT NULL,
    reminder_type ENUM('sms', 'email') NOT NULL,
    sent_at TIMESTAMP NULL,
    status ENUM('pending', 'sent', 'failed') DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_appointment (appointment_id),
    INDEX idx_patient (patient_id),
    INDEX idx_status (status),
    FOREIGN KEY (patient_id) REFERENCES demographic(demographic_no) ON DELETE CASCADE,
    FOREIGN KEY (appointment_id) REFERENCES appointment(appointment_no) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Insert default configuration
INSERT IGNORE INTO system_config (config_key, config_value) VALUES
    ('setup_complete', 'false'),
    ('clinic_timezone', 'America/Vancouver'),
    ('enable_sms_reminders', 'true'),
    ('enable_patient_portal', 'true');
