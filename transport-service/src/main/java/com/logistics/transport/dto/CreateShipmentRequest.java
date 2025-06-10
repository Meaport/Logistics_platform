package com.logistics.transport.dto;

import com.logistics.transport.entity.Shipment;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class CreateShipmentRequest {
    
    @NotNull(message = "Sender ID is required")
    private Long senderId;
    
    @NotNull(message = "Receiver ID is required")
    private Long receiverId;
    
    @NotBlank(message = "Origin address is required")
    private String originAddress;
    
    @NotBlank(message = "Destination address is required")
    private String destinationAddress;
    
    private BigDecimal weightKg;
    private BigDecimal volumeM3;
    private BigDecimal declaredValue;
    private Shipment.Priority priority;
    private LocalDateTime pickupDate;
    private LocalDateTime estimatedDelivery;
    private String notes;
}