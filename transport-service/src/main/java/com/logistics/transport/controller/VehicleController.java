package com.logistics.transport.controller;

import com.logistics.common.dto.BaseResponse;
import com.logistics.transport.dto.CreateVehicleRequest;
import com.logistics.transport.dto.VehicleDto;
import com.logistics.transport.entity.Vehicle;
import com.logistics.transport.service.VehicleService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/vehicles")
@RequiredArgsConstructor
@CrossOrigin(origins = "*", maxAge = 3600)
public class VehicleController {

    private final VehicleService vehicleService;

    @GetMapping
    public ResponseEntity<BaseResponse<Page<VehicleDto>>> getAllVehicles(
            @PageableDefault(size = 20) Pageable pageable) {
        Page<VehicleDto> vehicles = vehicleService.getAllVehicles(pageable);
        return ResponseEntity.ok(BaseResponse.success(vehicles, "Vehicles retrieved successfully"));
    }

    @GetMapping("/{id}")
    public ResponseEntity<BaseResponse<VehicleDto>> getVehicleById(@PathVariable Long id) {
        VehicleDto vehicle = vehicleService.getVehicleById(id);
        return ResponseEntity.ok(BaseResponse.success(vehicle, "Vehicle retrieved successfully"));
    }

    @GetMapping("/license/{licensePlate}")
    public ResponseEntity<BaseResponse<VehicleDto>> getVehicleByLicensePlate(
            @PathVariable String licensePlate) {
        VehicleDto vehicle = vehicleService.getVehicleByLicensePlate(licensePlate);
        return ResponseEntity.ok(BaseResponse.success(vehicle, "Vehicle retrieved successfully"));
    }

    @PostMapping
    public ResponseEntity<BaseResponse<VehicleDto>> createVehicle(
            @Valid @RequestBody CreateVehicleRequest request) {
        VehicleDto vehicle = vehicleService.createVehicle(request);
        return ResponseEntity.ok(BaseResponse.success(vehicle, "Vehicle created successfully"));
    }

    @PutMapping("/{id}")
    public ResponseEntity<BaseResponse<VehicleDto>> updateVehicle(
            @PathVariable Long id,
            @Valid @RequestBody CreateVehicleRequest request) {
        VehicleDto vehicle = vehicleService.updateVehicle(id, request);
        return ResponseEntity.ok(BaseResponse.success(vehicle, "Vehicle updated successfully"));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<BaseResponse<Void>> deleteVehicle(@PathVariable Long id) {
        vehicleService.deleteVehicle(id);
        return ResponseEntity.ok(BaseResponse.success(null, "Vehicle deleted successfully"));
    }

    @GetMapping("/status/{status}")
    public ResponseEntity<BaseResponse<Page<VehicleDto>>> getVehiclesByStatus(
            @PathVariable Vehicle.VehicleStatus status,
            @PageableDefault(size = 20) Pageable pageable) {
        Page<VehicleDto> vehicles = vehicleService.getVehiclesByStatus(status, pageable);
        return ResponseEntity.ok(BaseResponse.success(vehicles, "Vehicles retrieved successfully"));
    }

    @GetMapping("/search")
    public ResponseEntity<BaseResponse<Page<VehicleDto>>> searchVehicles(
            @RequestParam String q,
            @PageableDefault(size = 20) Pageable pageable) {
        Page<VehicleDto> vehicles = vehicleService.searchVehicles(q, pageable);
        return ResponseEntity.ok(BaseResponse.success(vehicles, "Search completed successfully"));
    }

    @PatchMapping("/{id}/status")
    public ResponseEntity<BaseResponse<VehicleDto>> updateVehicleStatus(
            @PathVariable Long id,
            @RequestParam Vehicle.VehicleStatus status) {
        VehicleDto vehicle = vehicleService.updateVehicleStatus(id, status);
        return ResponseEntity.ok(BaseResponse.success(vehicle, "Vehicle status updated successfully"));
    }

    @GetMapping("/available")
    public ResponseEntity<BaseResponse<List<VehicleDto>>> getAvailableVehicles() {
        List<VehicleDto> vehicles = vehicleService.getAvailableVehicles();
        return ResponseEntity.ok(BaseResponse.success(vehicles, "Available vehicles retrieved successfully"));
    }

    @PatchMapping("/{id}/assign-driver")
    public ResponseEntity<BaseResponse<VehicleDto>> assignDriver(
            @PathVariable Long id,
            @RequestParam Long driverId) {
        VehicleDto vehicle = vehicleService.assignDriver(id, driverId);
        return ResponseEntity.ok(BaseResponse.success(vehicle, "Driver assigned successfully"));
    }
}