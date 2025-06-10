package com.logistics.transport.controller;

import com.logistics.common.dto.BaseResponse;
import com.logistics.transport.dto.CreateShipmentRequest;
import com.logistics.transport.dto.RouteLogDto;
import com.logistics.transport.dto.ShipmentDto;
import com.logistics.transport.dto.UpdateShipmentRequest;
import com.logistics.transport.entity.RouteLog;
import com.logistics.transport.entity.Shipment;
import com.logistics.transport.service.RouteLogService;
import com.logistics.transport.service.ShipmentService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/shipments")
@RequiredArgsConstructor
@CrossOrigin(origins = "*", maxAge = 3600)
public class ShipmentController {

    private final ShipmentService shipmentService;
    private final RouteLogService routeLogService;

    @GetMapping
    public ResponseEntity<BaseResponse<Page<ShipmentDto>>> getAllShipments(
            @PageableDefault(size = 20) Pageable pageable) {
        Page<ShipmentDto> shipments = shipmentService.getAllShipments(pageable);
        return ResponseEntity.ok(BaseResponse.success(shipments, "Shipments retrieved successfully"));
    }

    @GetMapping("/{id}")
    public ResponseEntity<BaseResponse<ShipmentDto>> getShipmentById(@PathVariable Long id) {
        ShipmentDto shipment = shipmentService.getShipmentById(id);
        return ResponseEntity.ok(BaseResponse.success(shipment, "Shipment retrieved successfully"));
    }

    @GetMapping("/tracking/{trackingNumber}")
    public ResponseEntity<BaseResponse<ShipmentDto>> getShipmentByTrackingNumber(
            @PathVariable String trackingNumber) {
        ShipmentDto shipment = shipmentService.getShipmentByTrackingNumber(trackingNumber);
        return ResponseEntity.ok(BaseResponse.success(shipment, "Shipment retrieved successfully"));
    }

    @PostMapping
    public ResponseEntity<BaseResponse<ShipmentDto>> createShipment(
            @Valid @RequestBody CreateShipmentRequest request) {
        ShipmentDto shipment = shipmentService.createShipment(request);
        return ResponseEntity.ok(BaseResponse.success(shipment, "Shipment created successfully"));
    }

    @PutMapping("/{id}")
    public ResponseEntity<BaseResponse<ShipmentDto>> updateShipment(
            @PathVariable Long id,
            @Valid @RequestBody UpdateShipmentRequest request) {
        ShipmentDto shipment = shipmentService.updateShipment(id, request);
        return ResponseEntity.ok(BaseResponse.success(shipment, "Shipment updated successfully"));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<BaseResponse<Void>> deleteShipment(@PathVariable Long id) {
        shipmentService.deleteShipment(id);
        return ResponseEntity.ok(BaseResponse.success(null, "Shipment deleted successfully"));
    }

    @GetMapping("/user/{userId}")
    public ResponseEntity<BaseResponse<Page<ShipmentDto>>> getShipmentsByUser(
            @PathVariable Long userId,
            @PageableDefault(size = 20) Pageable pageable) {
        Page<ShipmentDto> shipments = shipmentService.getShipmentsByUser(userId, pageable);
        return ResponseEntity.ok(BaseResponse.success(shipments, "User shipments retrieved successfully"));
    }

    @GetMapping("/status/{status}")
    public ResponseEntity<BaseResponse<Page<ShipmentDto>>> getShipmentsByStatus(
            @PathVariable Shipment.ShipmentStatus status,
            @PageableDefault(size = 20) Pageable pageable) {
        Page<ShipmentDto> shipments = shipmentService.getShipmentsByStatus(status, pageable);
        return ResponseEntity.ok(BaseResponse.success(shipments, "Shipments retrieved successfully"));
    }

    @GetMapping("/search")
    public ResponseEntity<BaseResponse<Page<ShipmentDto>>> searchShipments(
            @RequestParam String q,
            @PageableDefault(size = 20) Pageable pageable) {
        Page<ShipmentDto> shipments = shipmentService.searchShipments(q, pageable);
        return ResponseEntity.ok(BaseResponse.success(shipments, "Search completed successfully"));
    }

    @PatchMapping("/{id}/status")
    public ResponseEntity<BaseResponse<ShipmentDto>> updateShipmentStatus(
            @PathVariable Long id,
            @RequestParam Shipment.ShipmentStatus status) {
        ShipmentDto shipment = shipmentService.updateShipmentStatus(id, status);
        return ResponseEntity.ok(BaseResponse.success(shipment, "Shipment status updated successfully"));
    }

    @PatchMapping("/{id}/assign-vehicle")
    public ResponseEntity<BaseResponse<ShipmentDto>> assignVehicle(
            @PathVariable Long id,
            @RequestParam Long vehicleId) {
        ShipmentDto shipment = shipmentService.assignVehicle(id, vehicleId);
        return ResponseEntity.ok(BaseResponse.success(shipment, "Vehicle assigned successfully"));
    }

    @GetMapping("/overdue")
    public ResponseEntity<BaseResponse<List<ShipmentDto>>> getOverdueShipments() {
        List<ShipmentDto> overdueShipments = shipmentService.getOverdueShipments();
        return ResponseEntity.ok(BaseResponse.success(overdueShipments, "Overdue shipments retrieved successfully"));
    }

    /**
     * Add route log to shipment.
     * This endpoint allows adding custom route logs to a specific shipment.
     */
    @PostMapping("/{id}/log")
    public ResponseEntity<BaseResponse<RouteLogDto>> addRouteLog(
            @PathVariable Long id,
            @Valid @RequestBody RouteLogRequest log) {
        
        RouteLogDto routeLog = routeLogService.createRouteLog(
                id, 
                log.getLocation(), 
                log.getLogType(), 
                log.getDescription(), 
                log.getLatitude(), 
                log.getLongitude()
        );
        
        return ResponseEntity.ok(BaseResponse.success(routeLog, "Route log added successfully"));
    }

    /**
     * Get route logs for a specific shipment.
     */
    @GetMapping("/{id}/logs")
    public ResponseEntity<BaseResponse<List<RouteLogDto>>> getShipmentLogs(@PathVariable Long id) {
        List<RouteLogDto> logs = routeLogService.getShipmentRouteLogs(id);
        return ResponseEntity.ok(BaseResponse.success(logs, "Shipment logs retrieved successfully"));
    }

    /**
     * Request DTO for adding route logs.
     */
    @lombok.Data
    @lombok.NoArgsConstructor
    @lombok.AllArgsConstructor
    public static class RouteLogRequest {
        @jakarta.validation.constraints.NotBlank(message = "Location is required")
        private String location;
        
        @jakarta.validation.constraints.NotNull(message = "Log type is required")
        private RouteLog.LogType logType;
        
        private String description;
        private java.math.BigDecimal latitude;
        private java.math.BigDecimal longitude;
    }
}