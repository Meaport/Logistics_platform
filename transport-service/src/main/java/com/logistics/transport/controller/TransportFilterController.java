package com.logistics.transport.controller;

import com.logistics.common.dto.BaseResponse;
import com.logistics.transport.dto.ShipmentDto;
import com.logistics.transport.dto.TransportFilterRequestDto;
import com.logistics.transport.service.TransportFilterService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * Controller for transport filtering and search operations.
 */
@RestController
@RequestMapping("/transport/filter")
@RequiredArgsConstructor
@CrossOrigin(origins = "*", maxAge = 3600)
public class TransportFilterController {

    private final TransportFilterService transportFilterService;

    /**
     * Filter transports based on multiple criteria.
     */
    @PostMapping
    public ResponseEntity<BaseResponse<List<ShipmentDto>>> filterTransports(
            @Valid @RequestBody TransportFilterRequestDto filter) {
        List<ShipmentDto> shipments = transportFilterService.filterTransports(filter);
        return ResponseEntity.ok(BaseResponse.success(shipments, "Transport filter completed successfully"));
    }

    /**
     * Advanced search with pagination.
     */
    @PostMapping("/search")
    public ResponseEntity<BaseResponse<Page<ShipmentDto>>> searchTransports(
            @Valid @RequestBody TransportFilterRequestDto filter,
            @PageableDefault(size = 20) Pageable pageable) {
        Page<ShipmentDto> shipments = transportFilterService.searchTransports(filter, pageable);
        return ResponseEntity.ok(BaseResponse.success(shipments, "Transport search completed successfully"));
    }
}