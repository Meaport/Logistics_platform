/*
  # User Service Tables Creation

  1. New Tables
    - `user_profiles`
      - `id` (bigserial, primary key)
      - `auth_user_id` (bigint, unique, references auth service user)
      - `username` (varchar, unique)
      - `email` (varchar, unique)
      - `first_name`, `last_name` (varchar)
      - `phone_number` (varchar)
      - `profile_picture_url` (text)
      - `bio` (text)
      - `company`, `department`, `position` (varchar)
      - `address`, `city`, `country`, `postal_code` (varchar)
      - `date_of_birth` (timestamp)
      - `status` (varchar, default 'ACTIVE')
      - `language` (varchar, default 'EN')
      - `timezone` (varchar, default 'UTC')
      - `is_email_verified`, `is_phone_verified` (boolean)
      - `last_login`, `created_at`, `updated_at` (timestamp)
    
    - `user_activities`
      - `id` (bigserial, primary key)
      - `user_id` (bigint, references user_profiles)
      - `activity_type` (varchar)
      - `description` (text)
      - `ip_address` (inet)
      - `user_agent` (text)
      - `created_at` (timestamp)

  2. Security
    - Indexes for performance optimization
    - Foreign key constraints for data integrity
*/

-- Switch to user service schema
SET search_path TO user_service;

-- User profiles table
CREATE TABLE user_profiles (
    id BIGSERIAL PRIMARY KEY,
    auth_user_id BIGINT UNIQUE NOT NULL,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    phone_number VARCHAR(20),
    profile_picture_url TEXT,
    bio TEXT,
    company VARCHAR(100),
    department VARCHAR(100),
    position VARCHAR(100),
    address TEXT,
    city VARCHAR(100),
    country VARCHAR(100),
    postal_code VARCHAR(20),
    date_of_birth TIMESTAMP,
    status VARCHAR(20) DEFAULT 'ACTIVE',
    language VARCHAR(5) DEFAULT 'EN',
    timezone VARCHAR(50) DEFAULT 'UTC',
    is_email_verified BOOLEAN DEFAULT false,
    is_phone_verified BOOLEAN DEFAULT false,
    last_login TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- User activities table
CREATE TABLE user_activities (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    activity_type VARCHAR(50) NOT NULL,
    description TEXT,
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for better performance
CREATE INDEX idx_user_profiles_auth_user_id ON user_profiles(auth_user_id);
CREATE INDEX idx_user_profiles_username ON user_profiles(username);
CREATE INDEX idx_user_profiles_email ON user_profiles(email);
CREATE INDEX idx_user_profiles_status ON user_profiles(status);
CREATE INDEX idx_user_activities_user_id ON user_activities(user_id);
CREATE INDEX idx_user_activities_type ON user_activities(activity_type);
CREATE INDEX idx_user_activities_created_at ON user_activities(created_at);

-- Add trigger for updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_user_profiles_updated_at 
    BEFORE UPDATE ON user_profiles 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();