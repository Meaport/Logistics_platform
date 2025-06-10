package com.logistics.transport.controller;

import com.logistics.common.dto.BaseResponse;
import com.logistics.transport.dto.TransportReportDto;
import com.logistics.transport.service.TransportReportService;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;

/**
 * Controller for transport reports and analytics.
 */
@RestController
@RequestMapping("/transport/reports")
@RequiredArgsConstructor
@CrossOrigin(origins = "*", maxAge = 3600)
public class TransportReportController {

    private final TransportReportService transportReportService;

    /**
     * Generate comprehensive transport report for a date range.
     */
    @GetMapping("/comprehensive")
    public ResponseEntity<BaseResponse<TransportReportDto>> generateReport(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime startDate,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime endDate) {
        TransportReportDto report = transportReportService.generateReport(startDate, endDate);
        return ResponseEntity.ok(BaseResponse.success(report, "Comprehensive report generated successfully"));
    }

    /**
     * Generate daily summary report.
     */
    @GetMapping("/daily")
    public ResponseEntity<BaseResponse<TransportReportDto>> generateDailySummary(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime date) {
        TransportReportDto report = transportReportService.generateDailySummary(date);
        return ResponseEntity.ok(BaseResponse.success(report, "Daily summary generated successfully"));
    }

    /**
     * Generate monthly summary report.
     */
    @GetMapping("/monthly")
    public ResponseEntity<BaseResponse<TransportReportDto>> generateMonthlySummary(
            @RequestParam int year,
            @RequestParam int month) {
        TransportReportDto report = transportReportService.generateMonthlySummary(year, month);
        return ResponseEntity.ok(BaseResponse.success(report, "Monthly summary generated successfully"));
    }

    /**
     * Generate current month report.
     */
    @GetMapping("/current-month")
    public ResponseEntity<BaseResponse<TransportReportDto>> generateCurrentMonthReport() {
        LocalDateTime now = LocalDateTime.now();
        TransportReportDto report = transportReportService.generateMonthlySummary(now.getYear(), now.getMonthValue());
        return ResponseEntity.ok(BaseResponse.success(report, "Current month report generated successfully"));
    }

    /**
     * Generate today's report.
     */
    @GetMapping("/today")
    public ResponseEntity<BaseResponse<TransportReportDto>> generateTodayReport() {
        TransportReportDto report = transportReportService.generateDailySummary(LocalDateTime.now());
        return ResponseEntity.ok(BaseResponse.success(report, "Today's report generated successfully"));
    }
}