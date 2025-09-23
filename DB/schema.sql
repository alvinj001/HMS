-- Create Clients table
CREATE TABLE clients (
    client_id INT AUTO_INCREMENT PRIMARY KEY,
    client_name VARCHAR(255) NOT NULL,
    contact_person VARCHAR(255),
    phone VARCHAR(50),
    email VARCHAR(255),
    address TEXT,
    city VARCHAR(100),
    country VARCHAR(100),
    tax_id VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Create Carriers table
CREATE TABLE carriers (
    carrier_id INT AUTO_INCREMENT PRIMARY KEY,
    carrier_name VARCHAR(255) NOT NULL,
    carrier_type ENUM('Air','Sea','Land') NOT NULL,
    contact_person VARCHAR(255),
    phone VARCHAR(50),
    email VARCHAR(255),
    address TEXT,
    city VARCHAR(100),
    country VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Create Warehouses table
CREATE TABLE warehouses (
    warehouse_id INT AUTO_INCREMENT PRIMARY KEY,
    warehouse_name VARCHAR(255) NOT NULL,
    address TEXT,
    city VARCHAR(100),
    country VARCHAR(100),
    capacity DECIMAL(10,2),
    contact_person VARCHAR(255),
    phone VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Create Shipments table
CREATE TABLE shipments (
    shipment_id INT AUTO_INCREMENT PRIMARY KEY,
    client_id INT,
    carrier_id INT,
    origin_warehouse_id INT,
    destination_warehouse_id INT,
    tracking_number VARCHAR(100) UNIQUE,
    shipment_type ENUM('Air','Sea','Land','Multimodal') NOT NULL,
    status ENUM('Pending','In Transit','Delivered','Cancelled') DEFAULT 'Pending',
    departure_date DATE,
    arrival_date DATE,
    weight DECIMAL(10,2),
    volume DECIMAL(10,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (client_id) REFERENCES clients(client_id),
    FOREIGN KEY (carrier_id) REFERENCES carriers(carrier_id),
    FOREIGN KEY (origin_warehouse_id) REFERENCES warehouses(warehouse_id),
    FOREIGN KEY (destination_warehouse_id) REFERENCES warehouses(warehouse_id)
);

CREATE TABLE shipment_items (
    item_id INT AUTO_INCREMENT PRIMARY KEY,
    shipment_id INT,
    description VARCHAR(255),
    quantity INT,
    weight DECIMAL(10,2),
    volume DECIMAL(10,2),
    value DECIMAL(12,2),
    hs_code VARCHAR(20),
    FOREIGN KEY (shipment_id) REFERENCES shipments(shipment_id)
);

CREATE TABLE tracking_events (
    event_id INT AUTO_INCREMENT PRIMARY KEY,
    shipment_id INT,
    event_type ENUM('Picked Up','At Warehouse','Customs Cleared','In Transit','Delivered','Other'),
    location VARCHAR(255),
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    remarks TEXT,
    FOREIGN KEY (shipment_id) REFERENCES shipments(shipment_id)
);

CREATE TABLE invoices (
    invoice_id INT AUTO_INCREMENT PRIMARY KEY,
    shipment_id INT,
    client_id INT,
    amount DECIMAL(10,2),
    currency VARCHAR(10) DEFAULT 'USD',
    status ENUM('Paid','Unpaid','Overdue') DEFAULT 'Unpaid',
    issue_date DATE,
    due_date DATE,
    paid_date DATE,
    FOREIGN KEY (shipment_id) REFERENCES shipments(shipment_id),
    FOREIGN KEY (client_id) REFERENCES clients(client_id)
);

CREATE TABLE payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    invoice_id INT,
    client_id INT,
    payment_method ENUM('Bank Transfer','Credit Card','Cash','Other'),
    amount_paid DECIMAL(10,2),
    currency VARCHAR(10) DEFAULT 'USD',
    payment_date DATE,
    reference_number VARCHAR(100),
    FOREIGN KEY (invoice_id) REFERENCES invoices(invoice_id),
    FOREIGN KEY (client_id) REFERENCES clients(client_id)
);

CREATE TABLE documents (
    document_id INT AUTO_INCREMENT PRIMARY KEY,
    shipment_id INT,
    document_type ENUM('Bill of Lading','Air Waybill','Invoice','Customs Form','Other'),
    file_path VARCHAR(500),
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (shipment_id) REFERENCES shipments(shipment_id)
);

CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    role ENUM('Admin','Operations','Finance','Warehouse','Client'),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP NULL
);

CREATE TABLE routes (
    route_id INT AUTO_INCREMENT PRIMARY KEY,
    origin_city VARCHAR(100),
    destination_city VARCHAR(100),
    distance DECIMAL(10,2),
    estimated_duration VARCHAR(50)
);

CREATE TABLE customs_declarations (
    declaration_id INT AUTO_INCREMENT PRIMARY KEY,
    shipment_id INT,
    document_number VARCHAR(100),
    status ENUM('Submitted','Cleared','On Hold') DEFAULT 'Submitted',
    clearance_date DATE,
    FOREIGN KEY (shipment_id) REFERENCES shipments(shipment_id)
);
