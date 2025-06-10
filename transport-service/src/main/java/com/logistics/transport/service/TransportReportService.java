package com.logistics.transport.service;

import com.logistics.transport.dto.TransportReportDto;
import com.logistics.transport.entity.Shipment;
import com.logistics.transport.entity.Vehicle;
import com.logistics.transport.repository.ShipmentRepository;
import com.logistics.transport.repository.VehicleRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * Service for generating transport reports and analytics.
 */
@Service
@RequiredArgsConstructor
@Slf4j
@Transactional(readOnly = true)
public class TransportReportService {

    private final ShipmentRepository shipmentRepository;
    private final VehicleRepository vehicleRepository;

    /**
     * Generate comprehensive transport report for a date range.
     */
    @PreAuthorize("hasRole('ADMIN') or hasRole('MANAGER')")
    public TransportReportDto generateReport(LocalDateTime startDate, LocalDateTime endDate) {
        log.info("Generating transport report from {} to {}", startDate, endDate);
        
        TransportReportDto report = new TransportReportDto();
        report.setReportDate(LocalDateTime.now());
        report.setReportType("COMPREHENSIVE");
        report.setStartDate(startDate);
        report.setEndDate(endDate);
        
        // Get shipments in date range
        List<Shipment> shipments = shipmentRepository.findByDateRange(startDate, endDate);
        
        // Calculate shipment statistics
        calculateShipmentStatistics(report, shipments);
        
        // Calculate vehicle statistics
        calculateVehicleStatistics(report);
        
        // Calculate financial statistics
        calculateFinancialStatistics(report, shipments);
        
        // Calculate performance metrics
        calculatePerformanceMetrics(report, shipments);
        
        // Generate route statistics
        generateRouteStatistics(report, shipments);
        
        log.info("Report generated successfully with {} shipments", shipments.size());
        return report;
    }

    /**
     * Generate daily summary report.
     */
    @PreAuthorize("hasRole('ADMIN') or hasRole('MANAGER')")
    public TransportReportDto generateDailySummary(LocalDateTime date) {
        LocalDateTime startOfDay = date.truncatedTo(ChronoUnit.DAYS);
        LocalDateTime endOfDay = startOfDay.plusDays(1).minusNanos(1);
        
        TransportReportDto report = generateReport(startOfDay, endOfDay);
        report.setReportType("DAILY_SUMMARY");
        
        return report;
    }

    /**
     * Generate monthly summary report.
     */
    @PreAuthorize("hasRole('ADMIN') or hasRole('MANAGER')")
    public TransportReportDto generateMonthlySummary(int year, int month) {
        LocalDateTime startOfMonth = LocalDateTime.of(year, month, 1, 0, 0);
        LocalDateTime endOfMonth = startOfMonth.plusMonths(1).minusNanos(1);
        
        TransportReportDto report = generateReport(startOfMonth, endOfMonth);
        report.setReportType("MONTHLY_SUMMARY");
        
        return report;
    }

    private void calculateShipmentStatistics(TransportReportDto report, List<Shipment> shipments) {
        report.setTotalShipments((long) shipments.size());
        
        Map<Shipment.ShipmentStatus, Long> statusCounts = shipments.stream()
                .collect(Collectors.groupingBy(Shipment::getStatus, Collectors.counting()));
        
        report.setPendingShipments(statusCounts.getOrDefault(Shipment.ShipmentStatus.PENDING, 0L));
        report.setInTransitShipments(statusCounts.getOrDefault(Shipment.ShipmentStatus.IN_TRANSIT, 0L));
        report.setDeliveredShipments(statusCounts.getOrDefault(Shipment.ShipmentStatus.DELIVERED, 0L));
        report.setCancelledShipments(statusCounts.getOrDefault(Shipment.ShipmentStatus.CANCELLED, 0L));
        
        // Convert to string map for JSON serialization
        Map<String, Long> shipmentsByStatus = statusCounts.entrySet().stream()
                .collect(Collectors.toMap(
                    entry -> entry.getKey().toString(),
                    Map.Entry::getValue
                ));
        report.setShipmentsByStatus(shipmentsByStatus);
    }

    private void calculateVehicleStatistics(TransportReportDto report) {
        List<Vehicle> allVehicles = vehicleRepository.findAll();
        report.setTotalVehicles((long) allVehicles.size());
        
        Map<Vehicle.VehicleStatus, Long> vehicleStatusCounts = allVehicles.stream()
                .collect(Collectors.groupingBy(Vehicle::getStatus, Collectors.counting()));
        
        report.setAvailableVehicles(vehicleStatusCounts.getOrDefault(Vehicle.VehicleStatus.AVAILABLE, 0L));
        report.setInTransitVehicles(vehicleStatusCounts.getOrDefault(Vehicle.VehicleStatus.IN_TRANSIT, 0L));
        report.setMaintenanceVehicles(vehicleStatusCounts.getOrDefault(Vehicle.VehicleStatus.MAINTENANCE, 0L));
        
        // Convert to string map
        Map<String, Long> vehiclesByStatus = vehicleStatusCounts.entrySet().stream()
                .collect(Collectors.toMap(
                    entry -> entry.getKey().toString(),
                    Map.Entry::getValue
                ));
        report.setVehiclesByStatus(vehiclesByStatus);
    }

    private void calculateFinancialStatistics(TransportReportDto report, List<Shipment> shipments) {
        BigDecimal totalRevenue = shipments.stream()
                .filter(s -> s.getShippingCost() != null)
                .map(Shipment::getShippingCost)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
        report.setTotalRevenue(totalRevenue);
        
        BigDecimal totalDeclaredValue = shipments.stream()
                .filter(s -> s.getDeclaredValue() != null)
                .map(Shipment::getDeclaredValue)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
        report.setTotalDeclaredValue(totalDeclaredValue);
        
        if (!shipments.isEmpty()) {
            BigDecimal averageCost = totalRevenue.divide(
                BigDecimal.valueOf(shipments.size()), 2, RoundingMode.HALF_UP);
            report.setAverageShippingCost(averageCost);
        } else {
            report.setAverageShippingCost(BigDecimal.ZERO);
        }
    }

    private void calculatePerformanceMetrics(TransportReportDto report, List<Shipment> shipments) {
        List<Shipment> deliveredShipments = shipments.stream()
                .filter(s -> s.getStatus() == Shipment.ShipmentStatus.DELIVERED)
                .filter(s -> s.getDeliveryDate() != null && s.getEstimatedDelivery() != null)
                .collect(Collectors.toList());
        
        if (!deliveredShipments.isEmpty()) {
            long onTimeDeliveries = deliveredShipments.stream()
                    .mapToLong(s -> s.getDeliveryDate().isBefore(s.getEstimatedDelivery()) || 
                                   s.getDeliveryDate().isEqual(s.getEstimatedDelivery()) ? 1 : 0)
                    .sum();
            
            double onTimeRate = (double) onTimeDeliveries / deliveredShipments.size() * 100;
            report.setOnTimeDeliveryRate(Math.round(onTimeRate * 100.0) / 100.0);
            
            // Calculate average delivery time
            double avgDeliveryHours = deliveredShipments.stream()
                    .filter(s -> s.getPickupDate() != null)
                    .mapToLong(s -> ChronoUnit.HOURS.between(s.getPickupDate(), s.getDeliveryDate()))
                    .average()
                    .orElse(0.0);
            report.setAverageDeliveryTime(Math.round(avgDeliveryHours * 100.0) / 100.0);
        } else {
            report.setOnTimeDeliveryRate(0.0);
            report.setAverageDeliveryTime(0.0);
        }
        
        // Count overdue shipments
        long overdueCount = shipmentRepository.findOverdueShipments(LocalDateTime.now()).size();
        report.setOverdueShipments(overdueCount);
    }

    private void generateRouteStatistics(TransportReportDto report, List<Shipment> shipments) {
        // Popular routes (origin -> destination)
        Map<String, Long> routeCounts = shipments.stream()
                .collect(Collectors.groupingBy(
                    s -> s.getOriginAddress() + " → " + s.getDestinationAddress(),
                    Collectors.counting()
                ));
        
        // Get top 10 routes
        Map<String, Long> topRoutes = routeCounts.entrySet().stream()
                .sorted(Map.Entry.<String, Long>comparingByValue().reversed())
                .limit(10)
                .collect(Collectors.toMap(
                    Map.Entry::getKey,
                    Map.Entry::getValue,
                    (e1, e2) -> e1,
                    HashMap::new
                ));
        
        report.setPopularRoutes(topRoutes);
    }
}