package com.logistics.transport.repository;

import com.logistics.transport.entity.Route;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface RouteRepository extends JpaRepository<Route, Long> {
    
    Page<Route> findByStatus(Route.RouteStatus status, Pageable pageable);
    
    Page<Route> findByVehicleId(Long vehicleId, Pageable pageable);
    
    Page<Route> findByDriverId(Long driverId, Pageable pageable);
    
    @Query("SELECT r FROM Route r WHERE " +
           "LOWER(r.routeName) LIKE LOWER(CONCAT('%', :search, '%')) OR " +
           "LOWER(r.startLocation) LIKE LOWER(CONCAT('%', :search, '%')) OR " +
           "LOWER(r.endLocation) LIKE LOWER(CONCAT('%', :search, '%'))")
    Page<Route> findBySearchTerm(@Param("search") String search, Pageable pageable);
    
    @Query("SELECT r FROM Route r WHERE r.startTime BETWEEN :startDate AND :endDate")
    List<Route> findByDateRange(@Param("startDate") LocalDateTime startDate, 
                               @Param("endDate") LocalDateTime endDate);
    
    @Query("SELECT r FROM Route r WHERE r.status = 'ACTIVE' AND r.vehicleId = :vehicleId")
    List<Route> findActiveRoutesByVehicle(@Param("vehicleId") Long vehicleId);
}