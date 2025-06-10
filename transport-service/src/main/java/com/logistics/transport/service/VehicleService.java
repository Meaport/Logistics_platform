package com.logistics.transport.service;

import com.logistics.common.exception.BusinessException;
import com.logistics.common.exception.ResourceNotFoundException;
import com.logistics.transport.dto.CreateVehicleRequest;
import com.logistics.transport.dto.VehicleDto;
import com.logistics.transport.entity.Vehicle;
import com.logistics.transport.repository.VehicleRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
@Transactional
public class VehicleService {

    private final VehicleRepository vehicleRepository;

    @PreAuthorize("hasRole('ADMIN') or hasRole('MANAGER')")
    public Page<VehicleDto> getAllVehicles(Pageable pageable) {
        return vehicleRepository.findAll(pageable)
                .map(this::convertToDto);
    }

    public VehicleDto getVehicleById(Long id) {
        Vehicle vehicle = vehicleRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Vehicle not found with id: " + id));
        return convertToDto(vehicle);
    }

    public VehicleDto getVehicleByLicensePlate(String licensePlate) {
        Vehicle vehicle = vehicleRepository.findByLicensePlate(licensePlate)
                .orElseThrow(() -> new ResourceNotFoundException("Vehicle not found with license plate: " + licensePlate));
        return convertToDto(vehicle);
    }

    @PreAuthorize("hasRole('ADMIN') or hasRole('MANAGER')")
    public VehicleDto createVehicle(CreateVehicleRequest request) {
        if (vehicleRepository.existsByLicensePlate(request.getLicensePlate())) {
            throw new BusinessException("Vehicle with license plate already exists: " + request.getLicensePlate());
        }

        Vehicle vehicle = new Vehicle();
        vehicle.setLicensePlate(request.getLicensePlate());
        vehicle.setVehicleType(request.getVehicleType());
        vehicle.setBrand(request.getBrand());
        vehicle.setModel(request.getModel());
        vehicle.setYear(request.getYear());
        vehicle.setCapacityKg(request.getCapacityKg());
        vehicle.setCapacityM3(request.getCapacityM3());
        vehicle.setStatus(request.getStatus() != null ? request.getStatus() : Vehicle.VehicleStatus.AVAILABLE);
        vehicle.setDriverId(request.getDriverId());
        vehicle.setCurrentLocation(request.getCurrentLocation());
        vehicle.setFuelType(request.getFuelType());
        vehicle.setFuelConsumption(request.getFuelConsumption());
        vehicle.setMaintenanceDate(request.getMaintenanceDate());
        vehicle.setInsuranceExpiry(request.getInsuranceExpiry());

        Vehicle savedVehicle = vehicleRepository.save(vehicle);
        log.info("Vehicle created: {}", savedVehicle.getLicensePlate());
        
        return convertToDto(savedVehicle);
    }

    @PreAuthorize("hasRole('ADMIN') or hasRole('MANAGER')")
    public VehicleDto updateVehicle(Long id, CreateVehicleRequest request) {
        Vehicle vehicle = vehicleRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Vehicle not found with id: " + id));

        // Check license plate uniqueness if changed
        if (!vehicle.getLicensePlate().equals(request.getLicensePlate()) && 
            vehicleRepository.existsByLicensePlate(request.getLicensePlate())) {
            throw new BusinessException("Vehicle with license plate already exists: " + request.getLicensePlate());
        }

        vehicle.setLicensePlate(request.getLicensePlate());
        vehicle.setVehicleType(request.getVehicleType());
        vehicle.setBrand(request.getBrand());
        vehicle.setModel(request.getModel());
        vehicle.setYear(request.getYear());
        vehicle.setCapacityKg(request.getCapacityKg());
        vehicle.setCapacityM3(request.getCapacityM3());
        if (request.getStatus() != null) vehicle.setStatus(request.getStatus());
        vehicle.setDriverId(request.getDriverId());
        vehicle.setCurrentLocation(request.getCurrentLocation());
        vehicle.setFuelType(request.getFuelType());
        vehicle.setFuelConsumption(request.getFuelConsumption());
        vehicle.setMaintenanceDate(request.getMaintenanceDate());
        vehicle.setInsuranceExpiry(request.getInsuranceExpiry());

        Vehicle updatedVehicle = vehicleRepository.save(vehicle);
        log.info("Vehicle updated: {}", updatedVehicle.getLicensePlate());
        
        return convertToDto(updatedVehicle);
    }

    @PreAuthorize("hasRole('ADMIN')")
    public void deleteVehicle(Long id) {
        Vehicle vehicle = vehicleRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Vehicle not found with id: " + id));
        
        if (vehicle.getStatus() == Vehicle.VehicleStatus.IN_TRANSIT) {
            throw new BusinessException("Cannot delete vehicle that is in transit");
        }
        
        vehicleRepository.delete(vehicle);
        log.info("Vehicle deleted: {}", vehicle.getLicensePlate());
    }

    @PreAuthorize("hasRole('ADMIN') or hasRole('MANAGER')")
    public Page<VehicleDto> getVehiclesByStatus(Vehicle.VehicleStatus status, Pageable pageable) {
        return vehicleRepository.findByStatus(status, pageable)
                .map(this::convertToDto);
    }

    @PreAuthorize("hasRole('ADMIN') or hasRole('MANAGER')")
    public Page<VehicleDto> searchVehicles(String searchTerm, Pageable pageable) {
        return vehicleRepository.findBySearchTerm(searchTerm, pageable)
                .map(this::convertToDto);
    }

    @PreAuthorize("hasRole('ADMIN') or hasRole('MANAGER')")
    public VehicleDto updateVehicleStatus(Long id, Vehicle.VehicleStatus status) {
        Vehicle vehicle = vehicleRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Vehicle not found with id: " + id));
        
        vehicle.setStatus(status);
        Vehicle updatedVehicle = vehicleRepository.save(vehicle);
        
        log.info("Vehicle status updated: {} -> {}", updatedVehicle.getLicensePlate(), status);
        
        return convertToDto(updatedVehicle);
    }

    @PreAuthorize("hasRole('ADMIN') or hasRole('MANAGER')")
    public List<VehicleDto> getAvailableVehicles() {
        List<Vehicle> availableVehicles = vehicleRepository.findAvailableVehiclesWithDrivers();
        return availableVehicles.stream()
                .map(this::convertToDto)
                .collect(Collectors.toList());
    }

    @PreAuthorize("hasRole('ADMIN') or hasRole('MANAGER')")
    public VehicleDto assignDriver(Long vehicleId, Long driverId) {
        Vehicle vehicle = vehicleRepository.findById(vehicleId)
                .orElseThrow(() -> new ResourceNotFoundException("Vehicle not found with id: " + vehicleId));
        
        vehicle.setDriverId(driverId);
        Vehicle updatedVehicle = vehicleRepository.save(vehicle);
        
        log.info("Driver assigned to vehicle: {} -> Driver ID: {}", 
                updatedVehicle.getLicensePlate(), driverId);
        
        return convertToDto(updatedVehicle);
    }

    private VehicleDto convertToDto(Vehicle vehicle) {
        VehicleDto dto = new VehicleDto();
        dto.setId(vehicle.getId());
        dto.setLicensePlate(vehicle.getLicensePlate());
        dto.setVehicleType(vehicle.getVehicleType());
        dto.setBrand(vehicle.getBrand());
        dto.setModel(vehicle.getModel());
        dto.setYear(vehicle.getYear());
        dto.setCapacityKg(vehicle.getCapacityKg());
        dto.setCapacityM3(vehicle.getCapacityM3());
        dto.setStatus(vehicle.getStatus());
        dto.setDriverId(vehicle.getDriverId());
        dto.setCurrentLocation(vehicle.getCurrentLocation());
        dto.setFuelType(vehicle.getFuelType());
        dto.setFuelConsumption(vehicle.getFuelConsumption());
        dto.setMaintenanceDate(vehicle.getMaintenanceDate());
        dto.setInsuranceExpiry(vehicle.getInsuranceExpiry());
        dto.setCreatedAt(vehicle.getCreatedAt());
        dto.setUpdatedAt(vehicle.getUpdatedAt());
        return dto;
    }
}