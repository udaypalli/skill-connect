CREATE DATABASE SkillConnect;
USE SkillConnect;

-- Users Table
CREATE TABLE Users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    phone VARCHAR(15) UNIQUE NOT NULL,
    location VARCHAR(255),
    profile_image LONGBLOB,  -- Stores user profile images
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Service Providers Table
CREATE TABLE ServiceProviders (
    provider_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    phone VARCHAR(15) UNIQUE NOT NULL,
    expertise TEXT,
    location VARCHAR(255),
    pricing DECIMAL(10,2),
    working_hours VARCHAR(255),
    availability BOOLEAN DEFAULT TRUE,
    verification_status ENUM('Pending', 'Verified', 'Rejected') DEFAULT 'Pending',
    earnings DECIMAL(10,2) DEFAULT 0,
    profile_image LONGBLOB,  -- Stores service provider profile images
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Admin Table
CREATE TABLE Admins (
    admin_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    profile_image LONGBLOB,  -- Stores admin profile images
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Categories Table
CREATE TABLE Categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(255) UNIQUE NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Services Table
CREATE TABLE Services (
    service_id INT AUTO_INCREMENT PRIMARY KEY,
    category_id INT NOT NULL,
    service_name VARCHAR(255) NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Booking Table
CREATE TABLE Bookings (
    booking_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    provider_id INT,
    service_id INT,
    booking_time DATETIME NOT NULL,
    status ENUM('Pending', 'Accepted', 'Completed', 'Cancelled') DEFAULT 'Pending',
    total_cost DECIMAL(10,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Reviews Table
CREATE TABLE Reviews (
    review_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    provider_id INT,
    rating INT CHECK (rating BETWEEN 1 AND 5),
    review_text TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Notifications Table
CREATE TABLE Notifications (
    notification_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    provider_id INT,
    message TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Locations Table
CREATE TABLE Locations (
    location_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    provider_id INT,
    latitude DECIMAL(10,8) NOT NULL,
    longitude DECIMAL(11,8) NOT NULL,
    address VARCHAR(255) NOT NULL
);

-- Platform Fees Table
CREATE TABLE PlatformFees (
    fee_id INT AUTO_INCREMENT PRIMARY KEY,
    provider_id INT,
    amount DECIMAL(10,2) NOT NULL,
    payment_status ENUM('Pending', 'Paid') DEFAULT 'Pending',
    due_date DATE NOT NULL
);

-- Disputes Table
CREATE TABLE Disputes (
    dispute_id INT AUTO_INCREMENT PRIMARY KEY,
    booking_id INT,
    user_id INT,
    provider_id INT,
    issue_description TEXT NOT NULL,
    status ENUM('Open', 'Resolved', 'Rejected') DEFAULT 'Open',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Promotions Table
CREATE TABLE Promotions (
    promotion_id INT AUTO_INCREMENT PRIMARY KEY,
    provider_id INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    discount_percentage DECIMAL(5,2) CHECK (discount_percentage BETWEEN 0 AND 100),
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    status ENUM('Pending', 'Approved', 'Rejected', 'Published') DEFAULT 'Pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    approved_by INT NULL,
    approved_at TIMESTAMP NULL
);

-- ================== ADD FOREIGN KEYS AT THE END ==================

ALTER TABLE Services ADD CONSTRAINT fk_service_category FOREIGN KEY (category_id) REFERENCES Categories(category_id);

ALTER TABLE Bookings ADD CONSTRAINT fk_booking_user FOREIGN KEY (user_id) REFERENCES Users(user_id);
ALTER TABLE Bookings ADD CONSTRAINT fk_booking_provider FOREIGN KEY (provider_id) REFERENCES ServiceProviders(provider_id);
ALTER TABLE Bookings ADD CONSTRAINT fk_booking_service FOREIGN KEY (service_id) REFERENCES Services(service_id);

ALTER TABLE Reviews ADD CONSTRAINT fk_review_user FOREIGN KEY (user_id) REFERENCES Users(user_id);
ALTER TABLE Reviews ADD CONSTRAINT fk_review_provider FOREIGN KEY (provider_id) REFERENCES ServiceProviders(provider_id);

ALTER TABLE Notifications ADD CONSTRAINT fk_notification_user FOREIGN KEY (user_id) REFERENCES Users(user_id);
ALTER TABLE Notifications ADD CONSTRAINT fk_notification_provider FOREIGN KEY (provider_id) REFERENCES ServiceProviders(provider_id);

ALTER TABLE Locations ADD CONSTRAINT fk_location_user FOREIGN KEY (user_id) REFERENCES Users(user_id);
ALTER TABLE Locations ADD CONSTRAINT fk_location_provider FOREIGN KEY (provider_id) REFERENCES ServiceProviders(provider_id);

ALTER TABLE PlatformFees ADD CONSTRAINT fk_fee_provider FOREIGN KEY (provider_id) REFERENCES ServiceProviders(provider_id);

ALTER TABLE Disputes ADD CONSTRAINT fk_dispute_booking FOREIGN KEY (booking_id) REFERENCES Bookings(booking_id);
ALTER TABLE Disputes ADD CONSTRAINT fk_dispute_user FOREIGN KEY (user_id) REFERENCES Users(user_id);
ALTER TABLE Disputes ADD CONSTRAINT fk_dispute_provider FOREIGN KEY (provider_id) REFERENCES ServiceProviders(provider_id);

ALTER TABLE Promotions ADD CONSTRAINT fk_promotion_provider FOREIGN KEY (provider_id) REFERENCES ServiceProviders(provider_id);
ALTER TABLE Promotions ADD CONSTRAINT fk_promotion_admin FOREIGN KEY (approved_by) REFERENCES Admins(admin_id);
