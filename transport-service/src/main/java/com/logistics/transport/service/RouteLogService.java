package com.logistics.transport.service;

import com.logistics.common.exception.ResourceNotFoundException;
import com.logistics.transport.dto.RouteLogDto;
import com.logistics.transport.entity.RouteLog;
import com.logistics.transport.entity.Shipment;
import com.logistics.transport.repository.RouteLogRepository;
import com.logistics.transport.repository.ShipmentRepository;
import com.logistics.transport.repository.VehicleRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

/**
 * Service for managing route logs and tracking information.
 */
@Service
@RequiredArgsConstructor
@Slf4j
@Transactional
public class RouteLogService {

    private final RouteLogRepository routeLogRepository;
    private final ShipmentRepository shipmentRepository;
    private final VehicleRepository vehicleRepository;

    /**
     * Create a new route log entry.
     */
    @PreAuthorize("hasRole('ADMIN') or hasRole('MANAGER')")
    public RouteLogDto createRouteLog(Long shipmentId, String location, RouteLog.LogType logType, 
                                     String description, BigDecimal latitude, BigDecimal longitude) {
        
        // Verify shipment exists
        Shipment shipment = shipmentRepository.findById(shipmentId)
                .orElseThrow(() -> new ResourceNotFoundException("Shipment not found with id: " + shipmentId));
        
        RouteLog routeLog = new RouteLog();
        routeLog.setShipmentId(shipmentId);
        routeLog.setVehicleId(shipment.getVehicleId());
        routeLog.setDriverId(shipment.getDriverId());
        routeLog.setLocation(location);
        routeLog.setLatitude(latitude);
        routeLog.setLongitude(longitude);
        routeLog.setLogType(logType);
        routeLog.setDescription(description);
        routeLog.setTimestamp(LocalDateTime.now());
        
        RouteLog savedLog = routeLogRepository.save(routeLog);
        log.info("Route log created for shipment {}: {} at {}", shipmentId, logType, location);
        
        return convertToDto(savedLog);
    }

    /**
     * Get route logs for a specific shipment.
     */
    public List<RouteLogDto> getShipmentRouteLogs(Long shipmentId) {
        List<RouteLog> logs = routeLogRepository.findByShipmentIdOrderByTimestampDesc(shipmentId);
        return logs.stream()
                .map(this::convertToDto)
                .collect(Collectors.toList());
    }

    /**
     * Get route logs for a specific shipment with pagination.
     */
    public Page<RouteLogDto> getShipmentRouteLogsPaged(Long shipmentId, Pageable pageable) {
        return routeLogRepository.findByShipmentId(shipmentId, pageable)
                .map(this::convertToDto);
    }

    /**
     * Get route logs for a specific vehicle.
     */
    @PreAuthorize("hasRole('ADMIN') or hasRole('MANAGER')")
    public Page<RouteLogDto> getVehicleRouteLogs(Long vehicleId, Pageable pageable) {
        return routeLogRepository.findByVehicleId(vehicleId, pageable)
                .map(this::convertToDto);
    }

    /**
     * Get route logs for a specific driver.
     */
    @PreAuthorize("hasRole('ADMIN') or hasRole('MANAGER')")
    public Page<RouteLogDto> getDriverRouteLogs(Long driverId, Pageable pageable) {
        return routeLogRepository.findByDriverId(driverId, pageable)
                .map(this::convertToDto);
    }

    /**
     * Get route logs by type.
     */
    @PreAuthorize("hasRole('ADMIN') or hasRole('MANAGER')")
    public Page<RouteLogDto> getRouteLogsByType(RouteLog.LogType logType, Pageable pageable) {
        return routeLogRepository.findByLogType(logType, pageable)
                .map(this::convertToDto);
    }

    /**
     * Search route logs.
     */
    @PreAuthorize("hasRole('ADMIN') or hasRole('MANAGER')")
    public Page<RouteLogDto> searchRouteLogs(String searchTerm, Pageable pageable) {
        return routeLogRepository.findBySearchTerm(searchTerm, pageable)
                .map(this::convertToDto);
    }

    /**
     * Get route logs for a date range.
     */
    @PreAuthorize("hasRole('ADMIN') or hasRole('MANAGER')")
    public List<RouteLogDto> getRouteLogsByDateRange(LocalDateTime startDate, LocalDateTime endDate) {
        List<RouteLog> logs = routeLogRepository.findByDateRange(startDate, endDate);
        return logs.stream()
                .map(this::convertToDto)
                .collect(Collectors.toList());
    }

    /**
     * Add pickup log for shipment.
     */
    @PreAuthorize("hasRole('ADMIN') or hasRole('MANAGER')")
    public RouteLogDto logPickup(Long shipmentId, String location, BigDecimal latitude, BigDecimal longitude) {
        return createRouteLog(shipmentId, location, RouteLog.LogType.PICKUP, 
                "Shipment picked up", latitude, longitude);
    }

    /**
     * Add delivery log for shipment.
     */
    @PreAuthorize("hasRole('ADMIN') or hasRole('MANAGER')")
    public RouteLogDto logDelivery(Long shipmentId, String location, BigDecimal latitude, BigDecimal longitude) {
        return createRouteLog(shipmentId, location, RouteLog.LogType.DELIVERY, 
                "Shipment delivered", latitude, longitude);
    }

    /**
     * Add checkpoint log for shipment.
     */
    @PreAuthorize("hasRole('ADMIN') or hasRole('MANAGER')")
    public RouteLogDto logCheckpoint(Long shipmentId, String location, String description, 
                                    BigDecimal latitude, BigDecimal longitude) {
        return createRouteLog(shipmentId, location, RouteLog.LogType.CHECKPOINT, 
                description, latitude, longitude);
    }

    /**
     * Add incident log for shipment.
     */
    @PreAuthorize("hasRole('ADMIN') or hasRole('MANAGER')")
    public RouteLogDto logIncident(Long shipmentId, String location, String description, 
                                  BigDecimal latitude, BigDecimal longitude) {
        return createRouteLog(shipmentId, location, RouteLog.LogType.INCIDENT, 
                description, latitude, longitude);
    }

    /**
     * Update route log with additional notes.
     */
    @PreAuthorize("hasRole('ADMIN') or hasRole('MANAGER')")
    public RouteLogDto updateRouteLogNotes(Long logId, String notes) {
        RouteLog routeLog = routeLogRepository.findById(logId)
                .orElseThrow(() -> new ResourceNotFoundException("Route log not found with id: " + logId));
        
        routeLog.setNotes(notes);
        RouteLog updatedLog = routeLogRepository.save(routeLog);
        
        return convertToDto(updatedLog);
    }

    private RouteLogDto convertToDto(RouteLog routeLog) {
        RouteLogDto dto = new RouteLogDto();
        dto.setId(routeLog.getId());
        dto.setShipmentId(routeLog.getShipmentId());
        dto.setVehicleId(routeLog.getVehicleId());
        dto.setDriverId(routeLog.getDriverId());
        dto.setLocation(routeLog.getLocation());
        dto.setLatitude(routeLog.getLatitude());
        dto.setLongitude(routeLog.getLongitude());
        dto.setLogType(routeLog.getLogType());
        dto.setDescription(routeLog.getDescription());
        dto.setTimestamp(routeLog.getTimestamp());
        dto.setNotes(routeLog.getNotes());
        
        // Get tracking number from shipment
        shipmentRepository.findById(routeLog.getShipmentId())
                .ifPresent(shipment -> dto.setTrackingNumber(shipment.getTrackingNumber()));
        
        // Get vehicle plate from vehicle
        if (routeLog.getVehicleId() != null) {
            vehicleRepository.findById(routeLog.getVehicleId())
                    .ifPresent(vehicle -> dto.setVehiclePlate(vehicle.getLicensePlate()));
        }
        
        return dto;
    }
}