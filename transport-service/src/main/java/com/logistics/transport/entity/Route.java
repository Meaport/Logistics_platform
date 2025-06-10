package com.logistics.transport.entity;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

@Entity
@Table(name = "routes")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Route {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotBlank
    @Column(name = "route_name")
    private String routeName;

    @NotBlank
    @Column(name = "start_location")
    private String startLocation;

    @NotBlank
    @Column(name = "end_location")
    private String endLocation;

    @Column(name = "distance_km")
    private BigDecimal distanceKm;

    @Column(name = "estimated_duration_hours")
    private BigDecimal estimatedDurationHours;

    @Enumerated(EnumType.STRING)
    @Column(name = "status")
    private RouteStatus status = RouteStatus.ACTIVE;

    @Column(name = "vehicle_id")
    private Long vehicleId;

    @Column(name = "driver_id")
    private Long driverId;

    @Column(name = "start_time")
    private LocalDateTime startTime;

    @Column(name = "end_time")
    private LocalDateTime endTime;

    @Column(name = "waypoints", length = 2000)
    private String waypoints; // JSON string of coordinates

    @OneToMany(mappedBy = "routeId", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private List<RouteStop> stops;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }

    public enum RouteStatus {
        PLANNED, ACTIVE, COMPLETED, CANCELLED
    }
}