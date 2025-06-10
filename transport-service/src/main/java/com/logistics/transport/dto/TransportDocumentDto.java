package com.logistics.transport.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * DTO for transport document generation and export.
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class TransportDocumentDto {
    
    private Long transportId;
    private String transportCode;
    private String trackingNumber;
    private String origin;
    private String destination;
    private String driverName;
    private String vehiclePlate;
    private String cargoDescription;
    private LocalDateTime departureDate;
    private LocalDateTime arrivalDate;
    private LocalDateTime estimatedDelivery;
    
    // Sender Information
    private String senderName;
    private String senderAddress;
    private String senderPhone;
    private String senderEmail;
    
    // Receiver Information
    private String receiverName;
    private String receiverAddress;
    private String receiverPhone;
    private String receiverEmail;
    
    // Cargo Details
    private BigDecimal weightKg;
    private BigDecimal volumeM3;
    private BigDecimal declaredValue;
    private String priority;
    private String status;
    private BigDecimal shippingCost;
    
    // Vehicle Information
    private String vehicleType;
    private String vehicleBrand;
    private String vehicleModel;
    private BigDecimal vehicleCapacityKg;
    
    // Additional Information
    private String notes;
    private String specialInstructions;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}