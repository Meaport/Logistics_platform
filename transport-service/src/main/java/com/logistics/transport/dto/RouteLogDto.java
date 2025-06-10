package com.logistics.transport.dto;

import com.logistics.transport.entity.RouteLog;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * DTO for route logs and tracking information.
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class RouteLogDto {
    
    private Long id;
    private Long shipmentId;
    private String trackingNumber;
    private Long vehicleId;
    private String vehiclePlate;
    private Long driverId;
    private String location;
    private BigDecimal latitude;
    private BigDecimal longitude;
    private RouteLog.LogType logType;
    private String description;
    private LocalDateTime timestamp;
    private String notes;
}