/*
  # Transport Service Database Schema

  1. New Tables
    - `vehicles` - Vehicle management with capacity and status tracking
    - `shipments` - Shipment tracking with full logistics workflow
    - `route_logs` - GPS tracking and route logging

  2. Security
    - Enable RLS on all tables
    - Create policies for authenticated users
    - Allow public access for shipment tracking

  3. Performance
    - Add comprehensive indexes for all search operations
    - Create triggers for automatic timestamp updates
*/

-- Switch to transport service schema
SET search_path TO transport_service;

-- Drop existing tables if they exist (for clean migration)
DROP TABLE IF EXISTS route_logs CASCADE;
DROP TABLE IF EXISTS shipments CASCADE;
DROP TABLE IF EXISTS vehicles CASCADE;

-- Drop existing functions if they exist
DROP FUNCTION IF EXISTS update_updated_at_column() CASCADE;

-- Vehicles table
CREATE TABLE vehicles (
    id BIGSERIAL PRIMARY KEY,
    license_plate VARCHAR(20) UNIQUE NOT NULL,
    vehicle_type VARCHAR(50) NOT NULL,
    brand VARCHAR(50) NOT NULL,
    model VARCHAR(50) NOT NULL,
    year INTEGER,
    capacity_kg DECIMAL(10,2),
    capacity_m3 DECIMAL(10,2),
    status VARCHAR(20) DEFAULT 'AVAILABLE',
    driver_id BIGINT,
    current_location TEXT,
    fuel_type VARCHAR(20),
    fuel_consumption DECIMAL(5,2),
    maintenance_date TIMESTAMP,
    insurance_expiry TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Shipments table
CREATE TABLE shipments (
    id BIGSERIAL PRIMARY KEY,
    tracking_number VARCHAR(50) UNIQUE NOT NULL,
    sender_id BIGINT NOT NULL,
    receiver_id BIGINT NOT NULL,
    origin_address TEXT NOT NULL,
    destination_address TEXT NOT NULL,
    weight_kg DECIMAL(10,2),
    volume_m3 DECIMAL(10,2),
    declared_value DECIMAL(12,2),
    status VARCHAR(20) DEFAULT 'PENDING',
    priority VARCHAR(10) DEFAULT 'NORMAL',
    vehicle_id BIGINT,
    driver_id BIGINT,
    pickup_date TIMESTAMP,
    delivery_date TIMESTAMP,
    estimated_delivery TIMESTAMP,
    shipping_cost DECIMAL(12,2),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Route logs table
CREATE TABLE route_logs (
    id BIGSERIAL PRIMARY KEY,
    shipment_id BIGINT NOT NULL,
    vehicle_id BIGINT,
    driver_id BIGINT,
    location TEXT NOT NULL,
    latitude DECIMAL(10,8),
    longitude DECIMAL(11,8),
    log_type VARCHAR(20) NOT NULL,
    description TEXT,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for better performance
CREATE INDEX idx_vehicles_license_plate ON vehicles(license_plate);
CREATE INDEX idx_vehicles_status ON vehicles(status);
CREATE INDEX idx_vehicles_driver_id ON vehicles(driver_id);
CREATE INDEX idx_vehicles_created_at ON vehicles(created_at);

CREATE INDEX idx_shipments_tracking_number ON shipments(tracking_number);
CREATE INDEX idx_shipments_status ON shipments(status);
CREATE INDEX idx_shipments_sender_id ON shipments(sender_id);
CREATE INDEX idx_shipments_receiver_id ON shipments(receiver_id);
CREATE INDEX idx_shipments_vehicle_id ON shipments(vehicle_id);
CREATE INDEX idx_shipments_driver_id ON shipments(driver_id);
CREATE INDEX idx_shipments_created_at ON shipments(created_at);

CREATE INDEX idx_route_logs_shipment_id ON route_logs(shipment_id);
CREATE INDEX idx_route_logs_vehicle_id ON route_logs(vehicle_id);
CREATE INDEX idx_route_logs_driver_id ON route_logs(driver_id);
CREATE INDEX idx_route_logs_log_type ON route_logs(log_type);
CREATE INDEX idx_route_logs_timestamp ON route_logs(timestamp);

-- Create function for updating updated_at column
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create triggers for updated_at
CREATE TRIGGER update_vehicles_updated_at 
    BEFORE UPDATE ON vehicles 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_shipments_updated_at 
    BEFORE UPDATE ON shipments 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Enable Row Level Security
ALTER TABLE vehicles ENABLE ROW LEVEL SECURITY;
ALTER TABLE shipments ENABLE ROW LEVEL SECURITY;
ALTER TABLE route_logs ENABLE ROW LEVEL SECURITY;

-- Create policies for vehicles
CREATE POLICY "vehicles_read_authenticated"
    ON vehicles FOR SELECT
    TO authenticated
    USING (true);

CREATE POLICY "vehicles_insert_authenticated"
    ON vehicles FOR INSERT
    TO authenticated
    WITH CHECK (true);

CREATE POLICY "vehicles_update_authenticated"
    ON vehicles FOR UPDATE
    TO authenticated
    USING (true);

-- Create policies for shipments
CREATE POLICY "shipments_read_authenticated"
    ON shipments FOR SELECT
    TO authenticated
    USING (true);

CREATE POLICY "shipments_read_public_tracking"
    ON shipments FOR SELECT
    TO anon
    USING (true);

CREATE POLICY "shipments_insert_authenticated"
    ON shipments FOR INSERT
    TO authenticated
    WITH CHECK (true);

CREATE POLICY "shipments_update_authenticated"
    ON shipments FOR UPDATE
    TO authenticated
    USING (true);

-- Create policies for route_logs
CREATE POLICY "route_logs_read_authenticated"
    ON route_logs FOR SELECT
    TO authenticated
    USING (true);

CREATE POLICY "route_logs_insert_authenticated"
    ON route_logs FOR INSERT
    TO authenticated
    WITH CHECK (true);

-- Insert sample data for testing
INSERT INTO vehicles (license_plate, vehicle_type, brand, model, year, capacity_kg, capacity_m3, current_location, fuel_type) VALUES
('34 ABC 123', 'Kamyon', 'Mercedes', 'Actros', 2022, 15000.00, 45.00, 'İstanbul Depo', 'Dizel'),
('06 XYZ 456', 'Kamyonet', 'Ford', 'Transit', 2021, 3500.00, 12.00, 'Ankara Merkez', 'Dizel'),
('35 DEF 789', 'Tır', 'Volvo', 'FH16', 2023, 25000.00, 80.00, 'İzmir Liman', 'Dizel');

INSERT INTO shipments (tracking_number, sender_id, receiver_id, origin_address, destination_address, weight_kg, volume_m3, declared_value, priority, estimated_delivery, notes) VALUES
('TRK17056789123456', 1, 2, 'İstanbul Merkez Depo', 'Ankara Çankaya Mahallesi', 150.50, 2.30, 2500.00, 'HIGH', '2024-01-25 15:00:00', 'Kırılabilir eşya - Dikkatli taşınmalı'),
('TRK17056789123457', 2, 3, 'Ankara Ostim', 'İzmir Konak', 75.25, 1.80, 1200.00, 'NORMAL', '2024-01-26 12:00:00', 'Elektronik malzeme'),
('TRK17056789123458', 3, 1, 'İzmir Bornova', 'İstanbul Kadıköy', 220.75, 3.50, 3800.00, 'URGENT', '2024-01-24 18:00:00', 'Acil teslimat gerekli');

-- Verify tables created
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'transport_service' 
ORDER BY table_name;