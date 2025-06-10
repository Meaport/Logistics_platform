package com.logistics.transport.repository;

import com.logistics.transport.entity.RouteLog;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface RouteLogRepository extends JpaRepository<RouteLog, Long> {
    
    List<RouteLog> findByShipmentIdOrderByTimestampDesc(Long shipmentId);
    
    Page<RouteLog> findByShipmentId(Long shipmentId, Pageable pageable);
    
    Page<RouteLog> findByVehicleId(Long vehicleId, Pageable pageable);
    
    Page<RouteLog> findByDriverId(Long driverId, Pageable pageable);
    
    Page<RouteLog> findByLogType(RouteLog.LogType logType, Pageable pageable);
    
    @Query("SELECT rl FROM RouteLog rl WHERE rl.timestamp BETWEEN :startDate AND :endDate ORDER BY rl.timestamp DESC")
    List<RouteLog> findByDateRange(@Param("startDate") LocalDateTime startDate, 
                                  @Param("endDate") LocalDateTime endDate);
    
    @Query("SELECT rl FROM RouteLog rl WHERE rl.shipmentId = :shipmentId AND rl.logType = :logType ORDER BY rl.timestamp DESC")
    List<RouteLog> findByShipmentIdAndLogType(@Param("shipmentId") Long shipmentId, 
                                             @Param("logType") RouteLog.LogType logType);
    
    @Query("SELECT rl FROM RouteLog rl WHERE " +
           "LOWER(rl.location) LIKE LOWER(CONCAT('%', :search, '%')) OR " +
           "LOWER(rl.description) LIKE LOWER(CONCAT('%', :search, '%'))")
    Page<RouteLog> findBySearchTerm(@Param("search") String search, Pageable pageable);
}