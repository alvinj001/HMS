-- Cleaned Hospital Management System schema
-- Drop existing tables if they exist (safe order)
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS reports;
DROP TABLE IF EXISTS audit_logs;
DROP TABLE IF EXISTS insurance_claims;
DROP TABLE IF EXISTS billing;
DROP TABLE IF EXISTS schedules;
DROP TABLE IF EXISTS appointments;
DROP TABLE IF EXISTS lab_tests;
DROP TABLE IF EXISTS prescriptions;
DROP TABLE IF EXISTS medical_records;
DROP TABLE IF EXISTS rooms;
DROP TABLE IF EXISTS staff;
DROP TABLE IF EXISTS patients;
DROP TABLE IF EXISTS pharmacy_inventory;
DROP TABLE IF EXISTS suppliers;
DROP TABLE IF EXISTS departments;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS roles;
SET FOREIGN_KEY_CHECKS = 1;

-- ========================================
-- 00. General defaults
-- ========================================
-- Use a sensible default engine & charset
-- (You can remove or change ENGINE/CHARSET if your environment requires it.)

-- ========================================
-- 01. USER ROLES & MANAGEMENT
-- ========================================
CREATE TABLE roles (
    role_id INT NOT NULL AUTO_INCREMENT,
    role_name ENUM('admin', 'doctor', 'nurse', 'patient', 'pharmacist', 'lab_tech', 'billing') NOT NULL,
    role_description TEXT,
    PRIMARY KEY (role_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE users (
    user_id INT NOT NULL AUTO_INCREMENT,
    username VARCHAR(150) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    phone VARCHAR(30),
    role_id INT NOT NULL,
    account_status ENUM('active', 'inactive') NOT NULL DEFAULT 'active',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id),
    UNIQUE KEY ux_users_username (username),
    UNIQUE KEY ux_users_email (email),
    CONSTRAINT fk_users_role FOREIGN KEY (role_id) REFERENCES roles(role_id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ======================================
-- 02. DEPARTMENTS & SUPPLIERS & PHARMACY (ordered so FK targets exist)
-- ======================================
CREATE TABLE departments (
    department_id INT NOT NULL AUTO_INCREMENT,
    department_name VARCHAR(255) NOT NULL,
    department_description VARCHAR(1000),
    PRIMARY KEY (department_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE suppliers (
    supplier_id INT NOT NULL AUTO_INCREMENT,
    supplier_name VARCHAR(255) NOT NULL,
    contact_person VARCHAR(255),
    phone VARCHAR(30),
    supplier_address TEXT,
    PRIMARY KEY (supplier_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE pharmacy_inventory (
    drug_id INT NOT NULL AUTO_INCREMENT,
    drug_name VARCHAR(255) NOT NULL,
    generic_name VARCHAR(255),
    category VARCHAR(255),
    stock INT NOT NULL DEFAULT 0,
    reorder_level INT NOT NULL DEFAULT 0,
    supplier_id INT,
    PRIMARY KEY (drug_id),
    CONSTRAINT fk_pharmacy_supplier FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ======================================
-- 03. PATIENTS & STAFF (patients reference users; staff references users & departments)
-- ======================================
CREATE TABLE patients (
    patient_id INT NOT NULL AUTO_INCREMENT,
    user_id INT NOT NULL,
    first_name VARCHAR(255) NOT NULL,
    last_name VARCHAR(255) NOT NULL,
    middle_name VARCHAR(255),
    gender ENUM('M', 'F', 'Other'),
    dob DATE,
    patient_address TEXT,
    emergency_contact VARCHAR(255),
    blood_type ENUM('A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'),
    allergies TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (patient_id),
    CONSTRAINT fk_patients_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE staff (
    staff_id INT NOT NULL AUTO_INCREMENT,
    user_id INT NOT NULL,
    first_name VARCHAR(255) NOT NULL,
    middle_name VARCHAR(255),
    last_name VARCHAR(255) NOT NULL,
    gender ENUM('M', 'F', 'Other'),
    dob DATE,
    department_id INT,
    designation VARCHAR(255),
    specialization VARCHAR(255),
    hire_date DATE,
    salary DECIMAL(12,2),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (staff_id),
    CONSTRAINT fk_staff_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_staff_dept FOREIGN KEY (department_id) REFERENCES departments(department_id) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =====================================
-- 04. ROOMS
-- =====================================
CREATE TABLE rooms (
    room_id INT NOT NULL AUTO_INCREMENT,
    department_id INT,
    room_type ENUM('ICU', 'General', 'Private', 'Operation') NOT NULL,
    capacity INT NOT NULL DEFAULT 1,
    room_status ENUM('available', 'occupied', 'maintenance') NOT NULL DEFAULT 'available',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (room_id),
    CONSTRAINT fk_rooms_dept FOREIGN KEY (department_id) REFERENCES departments(department_id) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =================================
-- 05. CLINICAL DATA (EHR/EMR)
-- =================================
CREATE TABLE medical_records (
    record_id INT NOT NULL AUTO_INCREMENT,
    patient_id INT NOT NULL,
    doctor_id INT,
    visit_date DATE NOT NULL,
    visit_time TIME,
    diagnosis TEXT,
    treatment TEXT,
    notes TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (record_id),
    CONSTRAINT fk_medrec_patient FOREIGN KEY (patient_id) REFERENCES patients(patient_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_medrec_doctor FOREIGN KEY (doctor_id) REFERENCES staff(staff_id) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE prescriptions (
    prescription_id INT NOT NULL AUTO_INCREMENT,
    record_id INT,
    patient_id INT NOT NULL,
    doctor_id INT,
    drug_id INT,
    dosage VARCHAR(255),
    frequency VARCHAR(255),
    duration VARCHAR(255),
    notes TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (prescription_id),
    CONSTRAINT fk_pres_record FOREIGN KEY (record_id) REFERENCES medical_records(record_id) ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT fk_pres_patient FOREIGN KEY (patient_id) REFERENCES patients(patient_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_pres_doctor FOREIGN KEY (doctor_id) REFERENCES staff(staff_id) ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT fk_pres_drug FOREIGN KEY (drug_id) REFERENCES pharmacy_inventory(drug_id) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE lab_tests (
    test_id INT NOT NULL AUTO_INCREMENT,
    patient_id INT NOT NULL,
    doctor_id INT,
    test_type VARCHAR(255),
    result TEXT,
    result_date DATETIME,
    lab_tech_id INT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (test_id),
    CONSTRAINT fk_lab_patient FOREIGN KEY (patient_id) REFERENCES patients(patient_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_lab_doctor FOREIGN KEY (doctor_id) REFERENCES staff(staff_id) ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT fk_lab_tech FOREIGN KEY (lab_tech_id) REFERENCES staff(staff_id) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =================================
-- 06. APPOINTMENTS & SCHEDULING
-- =================================
CREATE TABLE appointments (
    appointment_id INT NOT NULL AUTO_INCREMENT,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    appointment_date DATE NOT NULL,
    appointment_start_time TIME,
    appointment_end_time TIME,
    appointment_status ENUM('scheduled', 'completed', 'cancelled') NOT NULL DEFAULT 'scheduled',
    notes TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (appointment_id),
    CONSTRAINT fk_appt_patient FOREIGN KEY (patient_id) REFERENCES patients(patient_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_appt_doctor FOREIGN KEY (doctor_id) REFERENCES staff(staff_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE schedules (
    schedule_id INT NOT NULL AUTO_INCREMENT,
    staff_id INT NOT NULL,
    shift_date DATE NOT NULL,
    shift_start TIME,
    shift_end TIME,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (schedule_id),
    CONSTRAINT fk_schedule_staff FOREIGN KEY (staff_id) REFERENCES staff(staff_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ===============================
-- 07. BILLING & INSURANCE
-- ===============================
CREATE TABLE billing (
    bill_id INT NOT NULL AUTO_INCREMENT,
    patient_id INT NOT NULL,
    appointment_id INT,
    amount DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    payment_status ENUM('paid', 'pending', 'cancelled') NOT NULL DEFAULT 'pending',
    payment_date DATE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (bill_id),
    CONSTRAINT fk_billing_patient FOREIGN KEY (patient_id) REFERENCES patients(patient_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_billing_appointment FOREIGN KEY (appointment_id) REFERENCES appointments(appointment_id) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE insurance_claims (
    claim_id INT NOT NULL AUTO_INCREMENT,
    patient_id INT NOT NULL,
    insurance_provider VARCHAR(255),
    policy_number VARCHAR(255),
    claim_status ENUM('submitted', 'approved', 'denied', 'pending') NOT NULL DEFAULT 'submitted',
    claim_amount DECIMAL(12,2),
    submission_date DATE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (claim_id),
    CONSTRAINT fk_claims_patient FOREIGN KEY (patient_id) REFERENCES patients(patient_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ===========================
-- 08. ANALYTICS & LOGS / REPORTS
-- ===========================
CREATE TABLE audit_logs (
    log_id INT NOT NULL AUTO_INCREMENT,
    user_id INT,
    user_action VARCHAR(1000),
    action_timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ip_address VARCHAR(45),
    PRIMARY KEY (log_id),
    CONSTRAINT fk_audit_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE reports (
    report_id INT NOT NULL AUTO_INCREMENT,
    report_type VARCHAR(255),
    generated_by INT,
    content TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (report_id),
    CONSTRAINT fk_reports_staff FOREIGN KEY (generated_by) REFERENCES staff(staff_id) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
