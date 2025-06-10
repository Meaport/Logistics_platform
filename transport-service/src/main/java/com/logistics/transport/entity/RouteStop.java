package com.logistics.transport.entity;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Table(name = "route_stops")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class RouteStop {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotNull
    @Column(name = "route_id")
    private Long routeId;

    @NotNull
    @Column(name = "shipment_id")
    private Long shipmentId;

    @NotBlank
    @Column(name = "address")
    private String address;

    @NotNull
    @Column(name = "stop_order")
    private Integer stopOrder;

    @Enumerated(EnumType.STRING)
    @Column(name = "stop_type")
    private StopType stopType;

    @Enumerated(EnumType.STRING)
    @Column(name = "status")
    private StopStatus status = StopStatus.PENDING;

    @Column(name = "planned_arrival")
    private LocalDateTime plannedArrival;

    @Column(name = "actual_arrival")
    private LocalDateTime actualArrival;

    @Column(name = "planned_departure")
    private LocalDateTime plannedDeparture;

    @Column(name = "actual_departure")
    private LocalDateTime actualDeparture;

    @Column(name = "notes", length = 500)
    private String notes;

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

    public enum StopType {
        PICKUP, DELIVERY, WAYPOINT
    }

    public enum StopStatus {
        PENDING, ARRIVED, COMPLETED, SKIPPED
    }
}