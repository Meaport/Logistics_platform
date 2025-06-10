package com.logistics.transport.controller;

import com.logistics.common.dto.BaseResponse;
import com.logistics.transport.dto.RouteLogDto;
import com.logistics.transport.entity.RouteLog;
import com.logistics.transport.service.RouteLogService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

/**
 * Controller for route logs and tracking operations.
 */
@RestController
@RequestMapping("/transport/route-logs")
@RequiredArgsConstructor
@CrossOrigin(origins = "*", maxAge = 3600)
public class RouteLogController {

    private final RouteLogService routeLogService;

    /**
     * Get route logs for a specific shipment.
     */
    @GetMapping("/shipment/{shipmentId}")
    public ResponseEntity<BaseResponse<List<RouteLogDto>>> getShipmentRouteLogs(
            @PathVariable Long shipmentId) {
        List<RouteLogDto> logs = routeLogService.getShipmentRouteLogs(shipmentId);
        return ResponseEntity.ok(BaseResponse.success(logs, "Shipment route logs retrieved successfully"));
    }

    /**
     * Get route logs for a specific shipment with pagination.
     */
    @GetMapping("/shipment/{shipmentId}/paged")
    public ResponseEntity<BaseResponse<Page<RouteLogDto>>> getShipmentRouteLogsPaged(
            @PathVariable Long shipmentId,
            @PageableDefault(size = 20) Pageable pageable) {
        Page<RouteLogDto> logs = routeLogService.getShipmentRouteLogsPaged(shipmentId, pageable);
        return ResponseEntity.ok(BaseResponse.success(logs, "Shipment route logs retrieved successfully"));
    }

    /**
     * Get route logs for a specific vehicle.
     */
    @GetMapping("/vehicle/{vehicleId}")
    public ResponseEntity<BaseResponse<Page<RouteLogDto>>> getVehicleRouteLogs(
            @PathVariable Long vehicleId,
            @PageableDefault(size = 20) Pageable pageable) {
        Page<RouteLogDto> logs = routeLogService.getVehicleRouteLogs(vehicleId, pageable);
        return ResponseEntity.ok(BaseResponse.success(logs, "Vehicle route logs retrieved successfully"));
    }

    /**
     * Get route logs for a specific driver.
     */
    @GetMapping("/driver/{driverId}")
    public ResponseEntity<BaseResponse<Page<RouteLogDto>>> getDriverRouteLogs(
            @PathVariable Long driverId,
            @PageableDefault(size = 20) Pageable pageable) {
        Page<RouteLogDto> logs = routeLogService.getDriverRouteLogs(driverId, pageable);
        return ResponseEntity.ok(BaseResponse.success(logs, "Driver route logs retrieved successfully"));
    }

    /**
     * Get route logs by type.
     */
    @GetMapping("/type/{logType}")
    public ResponseEntity<BaseResponse<Page<RouteLogDto>>> getRouteLogsByType(
            @PathVariable RouteLog.LogType logType,
            @PageableDefault(size = 20) Pageable pageable) {
        Page<RouteLogDto> logs = routeLogService.getRouteLogsByType(logType, pageable);
        return ResponseEntity.ok(BaseResponse.success(logs, "Route logs by type retrieved successfully"));
    }

    /**
     * Search route logs.
     */
    @GetMapping("/search")
    public ResponseEntity<BaseResponse<Page<RouteLogDto>>> searchRouteLogs(
            @RequestParam String q,
            @PageableDefault(size = 20) Pageable pageable) {
        Page<RouteLogDto> logs = routeLogService.searchRouteLogs(q, pageable);
        return ResponseEntity.ok(BaseResponse.success(logs, "Route logs search completed successfully"));
    }

    /**
     * Get route logs for a date range.
     */
    @GetMapping("/date-range")
    public ResponseEntity<BaseResponse<List<RouteLogDto>>> getRouteLogsByDateRange(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime startDate,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime endDate) {
        List<RouteLogDto> logs = routeLogService.getRouteLogsByDateRange(startDate, endDate);
        return ResponseEntity.ok(BaseResponse.success(logs, "Route logs for date range retrieved successfully"));
    }

    /**
     * Log pickup for shipment.
     */
    @PostMapping("/pickup")
    public ResponseEntity<BaseResponse<RouteLogDto>> logPickup(
            @RequestParam Long shipmentId,
            @RequestParam String location,
            @RequestParam(required = false) BigDecimal latitude,
            @RequestParam(required = false) BigDecimal longitude) {
        RouteLogDto log = routeLogService.logPickup(shipmentId, location, latitude, longitude);
        return ResponseEntity.ok(BaseResponse.success(log, "Pickup logged successfully"));
    }

    /**
     * Log delivery for shipment.
     */
    @PostMapping("/delivery")
    public ResponseEntity<BaseResponse<RouteLogDto>> logDelivery(
            @RequestParam Long shipmentId,
            @RequestParam String location,
            @RequestParam(required = false) BigDecimal latitude,
            @RequestParam(required = false) BigDecimal longitude) {
        RouteLogDto log = routeLogService.logDelivery(shipmentId, location, latitude, longitude);
        return ResponseEntity.ok(BaseResponse.success(log, "Delivery logged successfully"));
    }

    /**
     * Log checkpoint for shipment.
     */
    @PostMapping("/checkpoint")
    public ResponseEntity<BaseResponse<RouteLogDto>> logCheckpoint(
            @RequestParam Long shipmentId,
            @RequestParam String location,
            @RequestParam String description,
            @RequestParam(required = false) BigDecimal latitude,
            @RequestParam(required = false) BigDecimal longitude) {
        RouteLogDto log = routeLogService.logCheckpoint(shipmentId, location, description, latitude, longitude);
        return ResponseEntity.ok(BaseResponse.success(log, "Checkpoint logged successfully"));
    }

    /**
     * Log incident for shipment.
     */
    @PostMapping("/incident")
    public ResponseEntity<BaseResponse<RouteLogDto>> logIncident(
            @RequestParam Long shipmentId,
            @RequestParam String location,
            @RequestParam String description,
            @RequestParam(required = false) BigDecimal latitude,
            @RequestParam(required = false) BigDecimal longitude) {
        RouteLogDto log = routeLogService.logIncident(shipmentId, location, description, latitude, longitude);
        return ResponseEntity.ok(BaseResponse.success(log, "Incident logged successfully"));
    }

    /**
     * Update route log notes.
     */
    @PatchMapping("/{logId}/notes")
    public ResponseEntity<BaseResponse<RouteLogDto>> updateRouteLogNotes(
            @PathVariable Long logId,
            @RequestParam String notes) {
        RouteLogDto log = routeLogService.updateRouteLogNotes(logId, notes);
        return ResponseEntity.ok(BaseResponse.success(log, "Route log notes updated successfully"));
    }
}