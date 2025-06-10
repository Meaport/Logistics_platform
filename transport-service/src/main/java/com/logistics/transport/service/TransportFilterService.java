package com.logistics.transport.service;

import com.logistics.transport.dto.ShipmentDto;
import com.logistics.transport.dto.TransportFilterRequestDto;
import com.logistics.transport.entity.Shipment;
import com.logistics.transport.repository.ShipmentRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import jakarta.persistence.EntityManager;
import jakarta.persistence.TypedQuery;
import jakarta.persistence.criteria.*;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

/**
 * Service for filtering and searching transport operations.
 */
@Service
@RequiredArgsConstructor
@Slf4j
@Transactional(readOnly = true)
public class TransportFilterService {

    private final ShipmentRepository shipmentRepository;
    private final EntityManager entityManager;

    /**
     * Filter shipments based on multiple criteria.
     */
    @PreAuthorize("hasRole('ADMIN') or hasRole('MANAGER')")
    public List<ShipmentDto> filterTransports(TransportFilterRequestDto filter) {
        log.debug("Filtering transports with criteria: {}", filter);
        
        CriteriaBuilder cb = entityManager.getCriteriaBuilder();
        CriteriaQuery<Shipment> query = cb.createQuery(Shipment.class);
        Root<Shipment> root = query.from(Shipment.class);
        
        List<Predicate> predicates = new ArrayList<>();
        
        // Filter by origin
        if (filter.getOrigin() != null && !filter.getOrigin().trim().isEmpty()) {
            predicates.add(cb.like(cb.lower(root.get("originAddress")), 
                    "%" + filter.getOrigin().toLowerCase() + "%"));
        }
        
        // Filter by destination
        if (filter.getDestination() != null && !filter.getDestination().trim().isEmpty()) {
            predicates.add(cb.like(cb.lower(root.get("destinationAddress")), 
                    "%" + filter.getDestination().toLowerCase() + "%"));
        }
        
        // Filter by date range
        if (filter.getStartDate() != null) {
            predicates.add(cb.greaterThanOrEqualTo(root.get("createdAt"), filter.getStartDate()));
        }
        
        if (filter.getEndDate() != null) {
            predicates.add(cb.lessThanOrEqualTo(root.get("createdAt"), filter.getEndDate()));
        }
        
        // Filter by status
        if (filter.getStatus() != null && !filter.getStatus().trim().isEmpty()) {
            try {
                Shipment.ShipmentStatus status = Shipment.ShipmentStatus.valueOf(filter.getStatus().toUpperCase());
                predicates.add(cb.equal(root.get("status"), status));
            } catch (IllegalArgumentException e) {
                log.warn("Invalid status filter: {}", filter.getStatus());
            }
        }
        
        // Filter by priority
        if (filter.getPriority() != null && !filter.getPriority().trim().isEmpty()) {
            try {
                Shipment.Priority priority = Shipment.Priority.valueOf(filter.getPriority().toUpperCase());
                predicates.add(cb.equal(root.get("priority"), priority));
            } catch (IllegalArgumentException e) {
                log.warn("Invalid priority filter: {}", filter.getPriority());
            }
        }
        
        // Filter by driver ID
        if (filter.getDriverId() != null) {
            predicates.add(cb.equal(root.get("driverId"), filter.getDriverId()));
        }
        
        // Filter by tracking number
        if (filter.getTrackingNumber() != null && !filter.getTrackingNumber().trim().isEmpty()) {
            predicates.add(cb.like(cb.lower(root.get("trackingNumber")), 
                    "%" + filter.getTrackingNumber().toLowerCase() + "%"));
        }
        
        // Apply all predicates
        if (!predicates.isEmpty()) {
            query.where(cb.and(predicates.toArray(new Predicate[0])));
        }
        
        // Order by creation date descending
        query.orderBy(cb.desc(root.get("createdAt")));
        
        TypedQuery<Shipment> typedQuery = entityManager.createQuery(query);
        List<Shipment> shipments = typedQuery.getResultList();
        
        log.info("Filter returned {} shipments", shipments.size());
        
        return shipments.stream()
                .map(this::convertToDto)
                .collect(Collectors.toList());
    }

    /**
     * Advanced search with pagination.
     */
    @PreAuthorize("hasRole('ADMIN') or hasRole('MANAGER')")
    public Page<ShipmentDto> searchTransports(TransportFilterRequestDto filter, Pageable pageable) {
        // For now, use the existing search method from ShipmentService
        // This can be enhanced with more complex criteria
        String searchTerm = buildSearchTerm(filter);
        return shipmentRepository.findBySearchTerm(searchTerm, pageable)
                .map(this::convertToDto);
    }

    private String buildSearchTerm(TransportFilterRequestDto filter) {
        StringBuilder searchTerm = new StringBuilder();
        
        if (filter.getOrigin() != null) searchTerm.append(filter.getOrigin()).append(" ");
        if (filter.getDestination() != null) searchTerm.append(filter.getDestination()).append(" ");
        if (filter.getTrackingNumber() != null) searchTerm.append(filter.getTrackingNumber()).append(" ");
        
        return searchTerm.toString().trim();
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