/*
# Transport Service Database Schema

1. New Tables
   - `vehicles` - Vehicle management with capacity and status tracking
   - `shipments` - Shipment tracking with GPS coordinates and status
   - `route_logs` - Route logging for real-time tracking

2. Security
   - Enable RLS on all tables
   - Add policies for authenticated and anonymous users
   - Public access for shipment tracking

3. Performance
   - Comprehensive indexing strategy
   - Triggers for automatic timestamp updates
   - Optimized for logistics operations
*/

-- Vehicles table
CREATE TABLE IF NOT EXISTS vehicles (
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
CREATE TABLE IF NOT EXISTS shipments (
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
CREATE TABLE IF NOT EXISTS route_logs (
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
CREATE INDEX IF NOT EXISTS idx_vehicles_license_plate ON vehicles(license_plate);
CREATE INDEX IF NOT EXISTS idx_vehicles_status ON vehicles(status);
CREATE INDEX IF NOT EXISTS idx_vehicles_driver_id ON vehicles(driver_id);
CREATE INDEX IF NOT EXISTS idx_vehicles_created_at ON vehicles(created_at);

CREATE INDEX IF NOT EXISTS idx_shipments_tracking_number ON shipments(tracking_number);
CREATE INDEX IF NOT EXISTS idx_shipments_status ON shipments(status);
CREATE INDEX IF NOT EXISTS idx_shipments_sender_id ON shipments(sender_id);
CREATE INDEX IF NOT EXISTS idx_shipments_receiver_id ON shipments(receiver_id);
CREATE INDEX IF NOT EXISTS idx_shipments_vehicle_id ON shipments(vehicle_id);
CREATE INDEX IF NOT EXISTS idx_shipments_driver_id ON shipments(driver_id);
CREATE INDEX IF NOT EXISTS idx_shipments_created_at ON shipments(created_at);

CREATE INDEX IF NOT EXISTS idx_route_logs_shipment_id ON route_logs(shipment_id);
CREATE INDEX IF NOT EXISTS idx_route_logs_vehicle_id ON route_logs(vehicle_id);
CREATE INDEX IF NOT EXISTS idx_route_logs_driver_id ON route_logs(driver_id);
CREATE INDEX IF NOT EXISTS idx_route_logs_log_type ON route_logs(log_type);
CREATE INDEX IF NOT EXISTS idx_route_logs_timestamp ON route_logs(timestamp);

-- Create function for updating updated_at column
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Drop existing triggers if they exist
DROP TRIGGER IF EXISTS update_vehicles_updated_at ON vehicles;
DROP TRIGGER IF EXISTS update_shipments_updated_at ON shipments;

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

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Authenticated users can read vehicles" ON vehicles;
DROP POLICY IF EXISTS "Authenticated users can insert vehicles" ON vehicles;
DROP POLICY IF EXISTS "Authenticated users can update vehicles" ON vehicles;

DROP POLICY IF EXISTS "Authenticated users can read shipments" ON shipments;
DROP POLICY IF EXISTS "Public can read shipments for tracking" ON shipments;
DROP POLICY IF EXISTS "Authenticated users can insert shipments" ON shipments;
DROP POLICY IF EXISTS "Authenticated users can update shipments" ON shipments;

DROP POLICY IF EXISTS "Authenticated users can read route logs" ON route_logs;
DROP POLICY IF EXISTS "Authenticated users can insert route logs" ON route_logs;

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

-- Verify tables created
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'public' AND table_name IN ('vehicles', 'shipments', 'route_logs')
ORDER BY table_name;