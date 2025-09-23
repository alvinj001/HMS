-- ===============================
-- Lookup / Reference Tables
-- ===============================

-- Shipment Statuses
CREATE TABLE shipment_statuses (
    status_id INT AUTO_INCREMENT PRIMARY KEY,
    status_name VARCHAR(50) UNIQUE NOT NULL
);

INSERT INTO shipment_statuses (status_name) VALUES 
('Pending'), ('In Transit'), ('Delivered'), ('Cancelled'), ('Waiting for Carrier'), ('At Warehouse');

-- Shipment Types (optional if needed)
CREATE TABLE shipment_types (
    shipment_type_id INT AUTO_INCREMENT PRIMARY KEY,
    type_name VARCHAR(50) UNIQUE NOT NULL
);

INSERT INTO shipment_types (type_name) VALUES ('Air'), ('Sea'), ('Land'), ('Multimodal');

-- Payment Methods
CREATE TABLE payment_methods (
    payment_method_id INT AUTO_INCREMENT PRIMARY KEY,
    method_name VARCHAR(50) UNIQUE NOT NULL
);

INSERT INTO payment_methods (method_name) VALUES ('Bank Transfer'), ('Credit Card'), ('Cash'), ('Other');

-- Document Types
CREATE TABLE document_types (
    document_type_id INT AUTO_INCREMENT PRIMARY KEY,
    type_name VARCHAR(50) UNIQUE NOT NULL
);

INSERT INTO document_types (type_name) VALUES ('Bill of Lading'), ('Air Waybill'), ('Invoice'), ('Customs Form'), ('Other');

-- User Roles
CREATE TABLE user_roles (
    role_id INT AUTO_INCREMENT PRIMARY KEY,
    role_name VARCHAR(50) UNIQUE NOT NULL
);

INSERT INTO user_roles (role_name) VALUES ('Admin'), ('Operations'), ('Finance'), ('Warehouse'), ('Client');

-- Customs Statuses
CREATE TABLE customs_statuses (
    status_id INT AUTO_INCREMENT PRIMARY KEY,
    status_name VARCHAR(50) UNIQUE NOT NULL
);

INSERT INTO customs_statuses (status_name) VALUES ('Submitted'), ('Cleared'), ('On Hold');

-- ===============================
-- Core Entities
-- ===============================

-- Clients
CREATE TABLE clients (
    client_id INT AUTO_INCREMENT PRIMARY KEY,
    client_name VARCHAR(255) NOT NULL,
    contact_person VARCHAR(255),
    phone VARCHAR(50),
    email VARCHAR(255),
    address VARCHAR(500),
    city VARCHAR(100),
    country VARCHAR(100),
    tax_id VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Carriers
CREATE TABLE carriers (
    carrier_id INT AUTO_INCREMENT PRIMARY KEY,
    carrier_name VARCHAR(255) NOT NULL,
    carrier_type VARCHAR(50) NOT NULL, -- Air, Sea, Land
    contact_person VARCHAR(255),
    phone VARCHAR(50),
    email VARCHAR(255),
    address VARCHAR(500),
    city VARCHAR(100),
    country VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Warehouses
CREATE TABLE warehouses (
    warehouse_id INT AUTO_INCREMENT PRIMARY KEY,
    warehouse_name VARCHAR(255) NOT NULL,
    address VARCHAR(500),
    city VARCHAR(100),
    country VARCHAR(100),
    capacity DECIMAL(12,2),
    contact_person VARCHAR(255),
    phone VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Users
CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    role_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP NULL,
    FOREIGN KEY (role_id) REFERENCES user_roles(role_id)
);

-- Routes (optional, can be used for planning)
CREATE TABLE routes (
    route_id INT AUTO_INCREMENT PRIMARY KEY,
    origin_city VARCHAR(100),
    destination_city VARCHAR(100),
    distance DECIMAL(10,2),
    estimated_duration VARCHAR(50)
);

-- ===============================
-- Shipments & Legs
-- ===============================

-- Shipments
CREATE TABLE shipments (
    shipment_id INT AUTO_INCREMENT PRIMARY KEY,
    client_id INT NOT NULL,
    tracking_number VARCHAR(100) UNIQUE NOT NULL,
    shipment_description VARCHAR(255),
    total_weight DECIMAL(12,2),
    total_volume DECIMAL(12,2),
    status_id INT NOT NULL DEFAULT 1, -- FK to shipment_statuses
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (client_id) REFERENCES clients(client_id) ON DELETE CASCADE,
    FOREIGN KEY (status_id) REFERENCES shipment_statuses(status_id)
);

-- Shipment Legs (handles carriers, transport mode, warehouses)
CREATE TABLE shipment_legs (
    leg_id INT AUTO_INCREMENT PRIMARY KEY,
    shipment_id INT NOT NULL,
    carrier_id INT NOT NULL,
    mode_of_transport VARCHAR(50) NOT NULL, -- Air, Sea, Land
    origin_address VARCHAR(500),
    origin_warehouse_id INT NULL,
    destination_address VARCHAR(500),
    destination_warehouse_id INT NULL,
    departure_date DATETIME,
    arrival_date DATETIME,
    status_id INT NOT NULL DEFAULT 1, -- FK to shipment_statuses
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (shipment_id) REFERENCES shipments(shipment_id) ON DELETE CASCADE,
    FOREIGN KEY (carrier_id) REFERENCES carriers(carrier_id),
    FOREIGN KEY (origin_warehouse_id) REFERENCES warehouses(warehouse_id),
    FOREIGN KEY (destination_warehouse_id) REFERENCES warehouses(warehouse_id),
    FOREIGN KEY (status_id) REFERENCES shipment_statuses(status_id)
);

CREATE INDEX idx_shipment_legs_status ON shipment_legs(status_id);

-- ===============================
-- Shipment Items
-- ===============================

CREATE TABLE shipment_items (
    item_id INT AUTO_INCREMENT PRIMARY KEY,
    leg_id INT NOT NULL,
    description VARCHAR(255),
    quantity INT,
    weight DECIMAL(12,2),
    volume DECIMAL(12,2),
    value DECIMAL(14,2),
    hs_code VARCHAR(20),
    FOREIGN KEY (leg_id) REFERENCES shipment_legs(leg_id) ON DELETE CASCADE
);

-- ===============================
-- Tracking Events
-- ===============================

CREATE TABLE tracking_events (
    event_id INT AUTO_INCREMENT PRIMARY KEY,
    leg_id INT NOT NULL,
    event_type VARCHAR(50),
    location VARCHAR(255),
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    remarks TEXT,
    FOREIGN KEY (leg_id) REFERENCES shipment_legs(leg_id) ON DELETE CASCADE
);

CREATE INDEX idx_tracking_leg ON tracking_events(leg_id);

-- ===============================
-- Documents
-- ===============================

CREATE TABLE documents (
    document_id INT AUTO_INCREMENT PRIMARY KEY,
    leg_id INT NOT NULL,
    document_type_id INT NOT NULL,
    file_path VARCHAR(500) UNIQUE,
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (leg_id) REFERENCES shipment_legs(leg_id) ON DELETE CASCADE,
    FOREIGN KEY (document_type_id) REFERENCES document_types(document_type_id)
);

-- ===============================
-- Invoices & Payments
-- ===============================

CREATE TABLE invoices (
    invoice_id INT AUTO_INCREMENT PRIMARY KEY,
    shipment_id INT NOT NULL,
    amount DECIMAL(12,2),
    currency VARCHAR(10) DEFAULT 'USD',
    status VARCHAR(50) DEFAULT 'Unpaid',
    issue_date DATE,
    due_date DATE,
    paid_date DATE,
    FOREIGN KEY (shipment_id) REFERENCES shipments(shipment_id) ON DELETE CASCADE
);

CREATE TABLE payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    invoice_id INT NOT NULL,
    payment_method_id INT NOT NULL,
    amount_paid DECIMAL(12,2),
    currency VARCHAR(10) DEFAULT 'USD',
    payment_date DATE,
    reference_number VARCHAR(100),
    FOREIGN KEY (invoice_id) REFERENCES invoices(invoice_id) ON DELETE CASCADE,
    FOREIGN KEY (payment_method_id) REFERENCES payment_methods(payment_method_id)
);

-- ===============================
-- Customs Declarations
-- ===============================

CREATE TABLE customs_declarations (
    declaration_id INT AUTO_INCREMENT PRIMARY KEY,
    leg_id INT NOT NULL,
    document_number VARCHAR(100),
    status_id INT DEFAULT 1, -- FK to customs_statuses
    clearance_date DATE,
    FOREIGN KEY (leg_id) REFERENCES shipment_legs(leg_id) ON DELETE CASCADE,
    FOREIGN KEY (status_id) REFERENCES customs_statuses(status_id)
);
