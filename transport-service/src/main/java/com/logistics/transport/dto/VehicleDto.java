package com.logistics.transport.dto;

import com.logistics.transport.entity.Vehicle;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class VehicleDto {
    
    private Long id;
    private String licensePlate;
    private String vehicleType;
    private String brand;
    private String model;
    private Integer year;
    private BigDecimal capacityKg;
    private BigDecimal capacityM3;
    private Vehicle.VehicleStatus status;
    private Long driverId;
    private String currentLocation;
    private String fuelType;
    private BigDecimal fuelConsumption;
    private LocalDateTime maintenanceDate;
    private LocalDateTime insuranceExpiry;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}