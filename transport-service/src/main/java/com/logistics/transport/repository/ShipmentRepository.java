package com.logistics.transport.repository;

import com.logistics.transport.entity.Shipment;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Repository
public interface ShipmentRepository extends JpaRepository<Shipment, Long> {
    
    Optional<Shipment> findByTrackingNumber(String trackingNumber);
    
    Page<Shipment> findBySenderId(Long senderId, Pageable pageable);
    
    Page<Shipment> findByReceiverId(Long receiverId, Pageable pageable);
    
    Page<Shipment> findByStatus(Shipment.ShipmentStatus status, Pageable pageable);
    
    Page<Shipment> findByVehicleId(Long vehicleId, Pageable pageable);
    
    Page<Shipment> findByDriverId(Long driverId, Pageable pageable);
    
    @Query("SELECT s FROM Shipment s WHERE s.senderId = :userId OR s.receiverId = :userId")
    Page<Shipment> findByUserId(@Param("userId") Long userId, Pageable pageable);
    
    @Query("SELECT s FROM Shipment s WHERE s.createdAt BETWEEN :startDate AND :endDate")
    List<Shipment> findByDateRange(@Param("startDate") LocalDateTime startDate, 
                                  @Param("endDate") LocalDateTime endDate);
    
    @Query("SELECT s FROM Shipment s WHERE " +
           "LOWER(s.trackingNumber) LIKE LOWER(CONCAT('%', :search, '%')) OR " +
           "LOWER(s.originAddress) LIKE LOWER(CONCAT('%', :search, '%')) OR " +
           "LOWER(s.destinationAddress) LIKE LOWER(CONCAT('%', :search, '%'))")
    Page<Shipment> findBySearchTerm(@Param("search") String search, Pageable pageable);
    
    @Query("SELECT COUNT(s) FROM Shipment s WHERE s.status = :status")
    Long countByStatus(@Param("status") Shipment.ShipmentStatus status);
    
    @Query("SELECT s FROM Shipment s WHERE s.estimatedDelivery < :date AND s.status NOT IN ('DELIVERED', 'CANCELLED')")
    List<Shipment> findOverdueShipments(@Param("date") LocalDateTime date);
}