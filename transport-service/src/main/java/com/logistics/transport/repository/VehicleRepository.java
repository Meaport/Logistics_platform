package com.logistics.transport.repository;

import com.logistics.transport.entity.Vehicle;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface VehicleRepository extends JpaRepository<Vehicle, Long> {
    
    Optional<Vehicle> findByLicensePlate(String licensePlate);
    
    Page<Vehicle> findByStatus(Vehicle.VehicleStatus status, Pageable pageable);
    
    Page<Vehicle> findByVehicleType(String vehicleType, Pageable pageable);
    
    Page<Vehicle> findByDriverId(Long driverId, Pageable pageable);
    
    @Query("SELECT v FROM Vehicle v WHERE " +
           "LOWER(v.licensePlate) LIKE LOWER(CONCAT('%', :search, '%')) OR " +
           "LOWER(v.brand) LIKE LOWER(CONCAT('%', :search, '%')) OR " +
           "LOWER(v.model) LIKE LOWER(CONCAT('%', :search, '%'))")
    Page<Vehicle> findBySearchTerm(@Param("search") String search, Pageable pageable);
    
    @Query("SELECT v FROM Vehicle v WHERE v.status = 'AVAILABLE' AND v.driverId IS NOT NULL")
    List<Vehicle> findAvailableVehiclesWithDrivers();
    
    @Query("SELECT COUNT(v) FROM Vehicle v WHERE v.status = :status")
    Long countByStatus(@Param("status") Vehicle.VehicleStatus status);
    
    boolean existsByLicensePlate(String licensePlate);
}