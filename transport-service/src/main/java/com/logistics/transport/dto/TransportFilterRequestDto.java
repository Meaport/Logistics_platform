package com.logistics.transport.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * DTO for filtering transport operations.
 * Allows filtering by various criteria like transport type, route, vehicle, and date range.
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class TransportFilterRequestDto {
    
    private String transportType;
    private String origin;
    private String destination;
    private String vehiclePlate;
    private LocalDateTime startDate;
    private LocalDateTime endDate;
    private String status;
    private String priority;
    private Long driverId;
    private String trackingNumber;
}