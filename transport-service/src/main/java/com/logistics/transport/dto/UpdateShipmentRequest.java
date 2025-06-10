package com.logistics.transport.dto;

import com.logistics.transport.entity.Shipment;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class UpdateShipmentRequest {
    
    private String originAddress;
    private String destinationAddress;
    private BigDecimal weightKg;
    private BigDecimal volumeM3;
    private BigDecimal declaredValue;
    private Shipment.ShipmentStatus status;
    private Shipment.Priority priority;
    private Long vehicleId;
    private Long driverId;
    private LocalDateTime pickupDate;
    private LocalDateTime deliveryDate;
    private LocalDateTime estimatedDelivery;
    private BigDecimal shippingCost;
    private String notes;
}