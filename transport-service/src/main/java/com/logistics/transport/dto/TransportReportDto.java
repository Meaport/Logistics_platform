package com.logistics.transport.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.Map;

/**
 * DTO for transport reports and analytics.
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class TransportReportDto {
    
    private LocalDateTime reportDate;
    private String reportType;
    
    // Shipment Statistics
    private Long totalShipments;
    private Long pendingShipments;
    private Long inTransitShipments;
    private Long deliveredShipments;
    private Long cancelledShipments;
    
    // Vehicle Statistics
    private Long totalVehicles;
    private Long availableVehicles;
    private Long inTransitVehicles;
    private Long maintenanceVehicles;
    
    // Financial Statistics
    private BigDecimal totalRevenue;
    private BigDecimal averageShippingCost;
    private BigDecimal totalDeclaredValue;
    
    // Performance Metrics
    private Double onTimeDeliveryRate;
    private Double averageDeliveryTime;
    private Long overdueShipments;
    
    // Route Statistics
    private Map<String, Long> popularRoutes;
    private Map<String, Long> shipmentsByStatus;
    private Map<String, Long> vehiclesByStatus;
    
    // Date Range
    private LocalDateTime startDate;
    private LocalDateTime endDate;
}