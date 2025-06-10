package com.logistics.transport.entity;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "vehicles")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Vehicle {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotBlank
    @Column(name = "license_plate", unique = true)
    private String licensePlate;

    @NotBlank
    @Column(name = "vehicle_type")
    private String vehicleType;

    @NotBlank
    @Column(name = "brand")
    private String brand;

    @NotBlank
    @Column(name = "model")
    private String model;

    @Column(name = "year")
    private Integer year;

    @Column(name = "capacity_kg")
    private BigDecimal capacityKg;

    @Column(name = "capacity_m3")
    private BigDecimal capacityM3;

    @Enumerated(EnumType.STRING)
    @Column(name = "status")
    private VehicleStatus status = VehicleStatus.AVAILABLE;

    @Column(name = "driver_id")
    private Long driverId;

    @Column(name = "current_location")
    private String currentLocation;

    @Column(name = "fuel_type")
    private String fuelType;

    @Column(name = "fuel_consumption")
    private BigDecimal fuelConsumption;

    @Column(name = "maintenance_date")
    private LocalDateTime maintenanceDate;

    @Column(name = "insurance_expiry")
    private LocalDateTime insuranceExpiry;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }

    public enum VehicleStatus {
        AVAILABLE, IN_TRANSIT, MAINTENANCE, OUT_OF_SERVICE
    }
}