package com.logistics.transport.service;

import com.logistics.common.exception.BusinessException;
import com.logistics.common.exception.ResourceNotFoundException;
import com.logistics.transport.dto.CreateShipmentRequest;
import com.logistics.transport.dto.ShipmentDto;
import com.logistics.transport.dto.UpdateShipmentRequest;
import com.logistics.transport.entity.Shipment;
import com.logistics.transport.repository.ShipmentRepository;
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

@Service
@RequiredArgsConstructor
@Slf4j
@Transactional
public class ShipmentService {

    private final ShipmentRepository shipmentRepository;

    @PreAuthorize("hasRole('ADMIN') or hasRole('MANAGER')")
    public Page<ShipmentDto> getAllShipments(Pageable pageable) {
        return shipmentRepository.findAll(pageable)
                .map(this::convertToDto);
    }

    public ShipmentDto getShipmentById(Long id) {
        Shipment shipment = shipmentRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Shipment not found with id: " + id));
        return convertToDto(shipment);
    }

    public ShipmentDto getShipmentByTrackingNumber(String trackingNumber) {
        Shipment shipment = shipmentRepository.findByTrackingNumber(trackingNumber)
                .orElseThrow(() -> new ResourceNotFoundException("Shipment not found with tracking number: " + trackingNumber));
        return convertToDto(shipment);
    }

    public ShipmentDto createShipment(CreateShipmentRequest request) {
        Shipment shipment = new Shipment();
        shipment.setSenderId(request.getSenderId());
        shipment.setReceiverId(request.getReceiverId());
        shipment.setOriginAddress(request.getOriginAddress());
        shipment.setDestinationAddress(request.getDestinationAddress());
        shipment.setWeightKg(request.getWeightKg());
        shipment.setVolumeM3(request.getVolumeM3());
        shipment.setDeclaredValue(request.getDeclaredValue());
        shipment.setPriority(request.getPriority() != null ? request.getPriority() : Shipment.Priority.NORMAL);
        shipment.setPickupDate(request.getPickupDate());
        shipment.setEstimatedDelivery(request.getEstimatedDelivery());
        shipment.setNotes(request.getNotes());
        
        // Calculate shipping cost
        shipment.setShippingCost(calculateShippingCost(shipment));

        Shipment savedShipment = shipmentRepository.save(shipment);
        log.info("Shipment created with tracking number: {}", savedShipment.getTrackingNumber());
        
        return convertToDto(savedShipment);
    }

    @PreAuthorize("hasRole('ADMIN') or hasRole('MANAGER')")
    public ShipmentDto updateShipment(Long id, UpdateShipmentRequest request) {
        Shipment shipment = shipmentRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Shipment not found with id: " + id));

        // Update fields if provided
        if (request.getOriginAddress() != null) shipment.setOriginAddress(request.getOriginAddress());
        if (request.getDestinationAddress() != null) shipment.setDestinationAddress(request.getDestinationAddress());
        if (request.getWeightKg() != null) shipment.setWeightKg(request.getWeightKg());
        if (request.getVolumeM3() != null) shipment.setVolumeM3(request.getVolumeM3());
        if (request.getDeclaredValue() != null) shipment.setDeclaredValue(request.getDeclaredValue());
        if (request.getStatus() != null) shipment.setStatus(request.getStatus());
        if (request.getPriority() != null) shipment.setPriority(request.getPriority());
        if (request.getVehicleId() != null) shipment.setVehicleId(request.getVehicleId());
        if (request.getDriverId() != null) shipment.setDriverId(request.getDriverId());
        if (request.getPickupDate() != null) shipment.setPickupDate(request.getPickupDate());
        if (request.getDeliveryDate() != null) shipment.setDeliveryDate(request.getDeliveryDate());
        if (request.getEstimatedDelivery() != null) shipment.setEstimatedDelivery(request.getEstimatedDelivery());
        if (request.getShippingCost() != null) shipment.setShippingCost(request.getShippingCost());
        if (request.getNotes() != null) shipment.setNotes(request.getNotes());

        Shipment updatedShipment = shipmentRepository.save(shipment);
        log.info("Shipment updated: {}", updatedShipment.getTrackingNumber());
        
        return convertToDto(updatedShipment);
    }

    @PreAuthorize("hasRole('ADMIN')")
    public void deleteShipment(Long id) {
        Shipment shipment = shipmentRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Shipment not found with id: " + id));
        
        if (shipment.getStatus() == Shipment.ShipmentStatus.IN_TRANSIT) {
            throw new BusinessException("Cannot delete shipment that is in transit");
        }
        
        shipmentRepository.delete(shipment);
        log.info("Shipment deleted: {}", shipment.getTrackingNumber());
    }

    public Page<ShipmentDto> getShipmentsByUser(Long userId, Pageable pageable) {
        return shipmentRepository.findByUserId(userId, pageable)
                .map(this::convertToDto);
    }

    @PreAuthorize("hasRole('ADMIN') or hasRole('MANAGER')")
    public Page<ShipmentDto> getShipmentsByStatus(Shipment.ShipmentStatus status, Pageable pageable) {
        return shipmentRepository.findByStatus(status, pageable)
                .map(this::convertToDto);
    }

    @PreAuthorize("hasRole('ADMIN') or hasRole('MANAGER')")
    public Page<ShipmentDto> searchShipments(String searchTerm, Pageable pageable) {
        return shipmentRepository.findBySearchTerm(searchTerm, pageable)
                .map(this::convertToDto);
    }

    @PreAuthorize("hasRole('ADMIN') or hasRole('MANAGER')")
    public ShipmentDto updateShipmentStatus(Long id, Shipment.ShipmentStatus status) {
        Shipment shipment = shipmentRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Shipment not found with id: " + id));
        
        shipment.setStatus(status);
        
        // Update delivery date if delivered
        if (status == Shipment.ShipmentStatus.DELIVERED) {
            shipment.setDeliveryDate(LocalDateTime.now());
        }
        
        Shipment updatedShipment = shipmentRepository.save(shipment);
        log.info("Shipment status updated: {} -> {}", updatedShipment.getTrackingNumber(), status);
        
        return convertToDto(updatedShipment);
    }

    @PreAuthorize("hasRole('ADMIN') or hasRole('MANAGER')")
    public ShipmentDto assignVehicle(Long shipmentId, Long vehicleId) {
        Shipment shipment = shipmentRepository.findById(shipmentId)
                .orElseThrow(() -> new ResourceNotFoundException("Shipment not found with id: " + shipmentId));
        
        shipment.setVehicleId(vehicleId);
        Shipment updatedShipment = shipmentRepository.save(shipment);
        
        log.info("Vehicle assigned to shipment: {} -> Vehicle ID: {}", 
                updatedShipment.getTrackingNumber(), vehicleId);
        
        return convertToDto(updatedShipment);
    }

    @PreAuthorize("hasRole('ADMIN') or hasRole('MANAGER')")
    public List<ShipmentDto> getOverdueShipments() {
        List<Shipment> overdueShipments = shipmentRepository.findOverdueShipments(LocalDateTime.now());
        return overdueShipments.stream()
                .map(this::convertToDto)
                .collect(Collectors.toList());
    }

    private BigDecimal calculateShippingCost(Shipment shipment) {
        // Simple cost calculation based on weight and volume
        BigDecimal baseCost = BigDecimal.valueOf(10.0); // Base cost
        BigDecimal weightCost = shipment.getWeightKg() != null ? 
                shipment.getWeightKg().multiply(BigDecimal.valueOf(2.0)) : BigDecimal.ZERO;
        BigDecimal volumeCost = shipment.getVolumeM3() != null ? 
                shipment.getVolumeM3().multiply(BigDecimal.valueOf(5.0)) : BigDecimal.ZERO;
        
        BigDecimal totalCost = baseCost.add(weightCost).add(volumeCost);
        
        // Priority multiplier
        if (shipment.getPriority() == Shipment.Priority.HIGH) {
            totalCost = totalCost.multiply(BigDecimal.valueOf(1.5));
        } else if (shipment.getPriority() == Shipment.Priority.URGENT) {
            totalCost = totalCost.multiply(BigDecimal.valueOf(2.0));
        }
        
        return totalCost;
    }

    private ShipmentDto convertToDto(Shipment shipment) {
        ShipmentDto dto = new ShipmentDto();
        dto.setId(shipment.getId());
        dto.setTrackingNumber(shipment.getTrackingNumber());
        dto.setSenderId(shipment.getSenderId());
        dto.setReceiverId(shipment.getReceiverId());
        dto.setOriginAddress(shipment.getOriginAddress());
        dto.setDestinationAddress(shipment.getDestinationAddress());
        dto.setWeightKg(shipment.getWeightKg());
        dto.setVolumeM3(shipment.getVolumeM3());
        dto.setDeclaredValue(shipment.getDeclaredValue());
        dto.setStatus(shipment.getStatus());
        dto.setPriority(shipment.getPriority());
        dto.setVehicleId(shipment.getVehicleId());
        dto.setDriverId(shipment.getDriverId());
        dto.setPickupDate(shipment.getPickupDate());
        dto.setDeliveryDate(shipment.getDeliveryDate());
        dto.setEstimatedDelivery(shipment.getEstimatedDelivery());
        dto.setShippingCost(shipment.getShippingCost());
        dto.setNotes(shipment.getNotes());
        dto.setCreatedAt(shipment.getCreatedAt());
        dto.setUpdatedAt(shipment.getUpdatedAt());
        return dto;
    }
}