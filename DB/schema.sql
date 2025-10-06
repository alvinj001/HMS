-- ========================================
-- NEW HOSPITAL MANAGEMENT SYSTEM DATABASE
-- ========================================

-- ========================================

-- 01. USER ROLES & MANAGEMENT

-- ========================================

CREATE TABLE roles(
    role_id INT NOT NULL AUTO_INCREMENT,
    role_name ENUM('admin', 'doctor', 'nurse', 'patient', 'pharmacist', 'lab_tech', 'billing'),
    role_description TEXT,

    PRIMARY KEY (role_id)
)

CREATE TABLE users (
    user_id INT NOT NULL AUTO_INCREMENT,
    username VARCHAR(255),
    password_hash VARCHAR(255),
    email VARCHAR(255),
    phone VARCHAR(255),
    role_id INT,
    account_status ENUM('active', 'inactive'),
    created_at TIMESTAMP

    PRIMARY KEY (user_id)
    FOREIGN KEY (role_id) REFERENCES roles(role_id)

)

-- ======================================

-- 02. PATIENTS & STAFF

-- ======================================
 
CREATE TABLE patients(
    patient_id INT NOT NULL,
    user_id INT,
    first_name VARCHAR(255) NOT NULL,
    last_name VARCHAR(255) NOT NULL,
    middle_name VARCHAR(255),
    gender ENUM('M', 'F', 'Other'),
    dob DATE,
    patient_address TEXT,
    emergency_contact VARCHAR(255),
    blood_type ENUM('A+', 'A-', 'B+', 'B-',' AB+', 'AB-',' O+', 'O-'),
    allergies TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP

    FOREIGN KEY (user_id) REFERENCES users(user_id)
    PRIMARY KEY (patient_id)
)

CREATE TABLE staff(
    staff_id INT NOT NULL AUTO_INCREMENT,
    user_id INT,
    first_name VARCHAR(255) NOT NULL,
    middle_name VARCHAR(255)
    last_name VARCHAR(255) NOT NULL,
    gender ENUM('M', 'F', 'Other'),
    dob DATE,
    department_id INT,
    designation VARCHAR(255),
    specializaiton VARCHAR(255),
    hire_date DATE,
    salary DECIMAL,

    PRIMARY KEY (staff_id)
    FOREIGN KEY (user_id) REFERENCES users(user_id)
    FOREIGN KEY (department_id) REFERENCES departments(department_id)
)

-- =====================================

-- 03. DEPARTMENTS & ROOMS

-- ====================================

CREATE TABLE departments(
    department_id INT NOT NULL,
    department_name VARCHAR(255),
    department_description VARCHAR(255),

    PRIMARY KEY (department_id)
)

CREATE TABLE rooms(
    room_id INT NOT NULL,
    department_id INT,
    room_type ENUM('ICU', 'General', 'Private', 'Operation'),
    capacity INT,
    room_status ENUM('available', 'occupied', 'maintenance')

    PRIMARY KEY (room_id)
    FOREIGN KEY (department_id) REFERENCES departments(department_id)
)

-- ==================================

-- 04. APPOINTMENTS & SCHEDULING

-- =================================

CREATE TABLE appointments(
    appointment_id INT NOT NULL AUTO_INCREMENT,
    patient_id INT,
    doctor_id INT,
    appointment_date DATE,
    appointment_start_time TIME,
    appointment_end_time TIME,
    appointment_status ENUM('scheduled', 'completed', 'cancelled'),
    notes TEXT,

    PRIMARY KEY (appointment_id)
    FOREIGN KEY (patient_id) REFERENCES patients(patient_id)
    FOREIGN KEY (doctor_id) REFERENCES staff(staff_id)

)

CREATE TABLE schedules(
    schedule_id INT NOT NULL,
    staff_id INT,
    shift_date DATE,
    shift_start TIME,
    shift_end TIME,

    PRIMARY KEY (schedule_id)
    FOREIGN KEY (staff_id) REFERENCES staff(staff_id)
)

-- ===============================

-- 05. CLINICAL DATA (EHR/EMR)

-- ==============================

CREATE TABLE medical_records(
    record_id INT NOT NULL,
    patient_id INT,
    doctor_id INT,
    visit_date DATE,
    visit_time TIME,
    diagnosis TEXT,
    treatment TEXT,
    notes TEXT,

    FOREIGN KEY (patient_id) REFERENCES patients(patient_id)
    FOREIGN KEY (doctor_id) REFERENCES staff (staff_id)
    PRIMARY KEY (record_id)
)

CREATE TABLE prescriptions(
    prescription_id INT NOT NULL,
    record_id INT,
    patient_id INT,
    doctor_id INT,
    drug_id INT,
    dosage VARCHAR(255),
    frequency VARCHAR(255),
    duration VARCHAR(255),

    FOREIGN KEY (record_id) REFERENCES medical_records(record_id)
    FOREIGN KEY (patient_id) REFERENCES patients(patient_id)
    FOREIGN KEY (doctor_id) REFERENCES staff (staff_id)
    FOREIGN KEY (drug_id) REFERENCES pharmacy_inventory(drug_id)
    PRIMARY KEY (prescription_id)
)

CREATE TABLE lab_tests(
    test_id INT NOT NULL,
    patient_id INT,
    doctor_id INT,
    test_type VARCHAR(255),
    result TEXT,
    result_date DATETIME,
    lab_tech_id INT,

    FOREIGN KEY (lab_tech_id) REFERENCES staff(staff_id)
    FOREIGN KEY (doctor_id) REFERENCES staff(staff_id)
    FOREIGN KEY (patient_id) REFERENCES patients(patient_id)
    PRIMARY KEY (test_id)
)

-- =============================

-- 06. PHARMACY & INVENTORY

-- ============================

CREATE TABLE pharmacy_inventory(
    drug_id INT NOT NULL,
    drug_name VARCHAR(255),
    generic_name VARCHAR(255),
    category VARCHAR(255),
    stock INT,
    reorder_level INT,
    supplier_id INT,

    FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id)
    PRIMARY KEY (drug_id)
)

CREATE TABLE suppliers(
    supplier_id INT NOT NULL,
    supplier_name VARCHAR(255),
    contact_person VARCHAR(255),
    phone VARCHAR(255),
    supplier_address TEXT

    PRIMARY KEY (supplier_id)
)

-- ============================

-- 07. BILLING & INSURANCE

-- ============================

CREATE TABLE billing(
    bill_id INT NOT NULL,
    patient_id INT,
    appointment_id INT,
    amount DECIMAL,
    payment_status ENUM('paid', 'pending', 'cancelled'),
    payment_date DATE,

    PRIMARY KEY (bill_id)
    FOREIGN KEY (patient_id) REFERENCES patients(patient_id)
    FOREIGN KEY (appointment_id) REFERENCES appointments (appointment_id)
)

CREATE TABLE insurance_claims(
    claim_id INT NOT NULL,
    patient_id INT,
    insurance_provider VARCHAR(255),
    policy_number VARCHAR(255),
    claim_status ENUM('submitted', 'approved', 'denied', 'pending'),
    claim_amount DECIMAL,
    submission_date DATE,

    PRIMARY KEY(claim_id)
    FOREIGN KEY (patient_id) REFERENCES patients(patient_id)
)

-- ===========================

-- 08. ANALYTICS & LOGS

-- ===========================

CREATE TABLE audit_logs(
    log_id INT NOT NULL,
    user_id INT,
    user_action VARCHAR,
    action_timestamp TIMESTAMP,
    ip_address VARCHAR,

    PRIMARY KEY (log_id)
    FOREIGN KEY (user_id) REFERENCES users(user_id)
)

CREATE TABLE reports(
    report_id INT NOT NULL,
    report_type VARCHAR,
    generated_by INT,
    content TEXT,
    created_at TIMESTAMP,

    PRIMARY KEY (report_id)
    FOREIGN KEY (generated_by) REFERENCES staff(staff_id)
)
