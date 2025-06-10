package com.logistics.transport.dto;

import com.logistics.transport.entity.Vehicle;
import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class CreateVehicleRequest {
    
    @NotBlank(message = "License plate is required")
    private String licensePlate;
    
    @NotBlank(message = "Vehicle type is required")
    private String vehicleType;
    
    @NotBlank(message = "Brand is required")
    private String brand;
    
    @NotBlank(message = "Model is required")
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
}