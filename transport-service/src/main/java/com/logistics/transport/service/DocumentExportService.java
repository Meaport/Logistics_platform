package com.logistics.transport.service;

import com.logistics.common.exception.ResourceNotFoundException;
import com.logistics.transport.dto.TransportDocumentDto;
import com.logistics.transport.entity.Shipment;
import com.logistics.transport.entity.Vehicle;
import com.logistics.transport.repository.ShipmentRepository;
import com.logistics.transport.repository.VehicleRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Service;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.time.format.DateTimeFormatter;

/**
 * Service for exporting transport documents in various formats.
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class DocumentExportService {

    private final ShipmentRepository shipmentRepository;
    private final VehicleRepository vehicleRepository;

    private static final DateTimeFormatter DATE_FORMATTER = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");

    /**
     * Export shipment document as PDF.
     * Note: PDF functionality temporarily disabled due to dependency issues.
     */
    @PreAuthorize("hasRole('ADMIN') or hasRole('MANAGER')")
    public byte[] exportDocumentPdf(Long shipmentId) throws IOException {
        log.info("PDF export requested for shipment: {}", shipmentId);
        
        // For now, return a simple text-based PDF alternative
        String content = generateDocumentText(shipmentId);
        return content.getBytes("UTF-8");
    }

    /**
     * Export shipment document as Excel.
     */
    @PreAuthorize("hasRole('ADMIN') or hasRole('MANAGER')")
    public byte[] exportDocumentExcel(Long shipmentId) throws IOException {
        log.info("Exporting Excel document for shipment: {}", shipmentId);
        
        TransportDocumentDto document = prepareDocumentData(shipmentId);
        
        Workbook workbook = new XSSFWorkbook();
        Sheet sheet = workbook.createSheet("Transport Document");
        
        // Create header style
        CellStyle headerStyle = workbook.createCellStyle();
        Font headerFont = workbook.createFont();
        headerFont.setBold(true);
        headerFont.setFontHeightInPoints((short) 12);
        headerStyle.setFont(headerFont);
        
        int rowNum = 0;
        
        // Add title
        Row titleRow = sheet.createRow(rowNum++);
        Cell titleCell = titleRow.createCell(0);
        titleCell.setCellValue("TRANSPORT DOCUMENT");
        titleCell.setCellStyle(headerStyle);
        
        rowNum++; // Empty row
        
        // Add shipment information
        rowNum = addShipmentInfoToExcel(sheet, document, rowNum, headerStyle);
        
        // Add sender/receiver information
        rowNum = addPartyInfoToExcel(sheet, document, rowNum, headerStyle);
        
        // Add cargo details
        rowNum = addCargoDetailsToExcel(sheet, document, rowNum, headerStyle);
        
        // Add vehicle information
        addVehicleInfoToExcel(sheet, document, rowNum, headerStyle);
        
        // Auto-size columns
        for (int i = 0; i < 4; i++) {
            sheet.autoSizeColumn(i);
        }
        
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        workbook.write(baos);
        workbook.close();
        
        log.info("Excel document exported successfully for shipment: {}", shipmentId);
        return baos.toByteArray();
    }

    private String generateDocumentText(Long shipmentId) {
        TransportDocumentDto document = prepareDocumentData(shipmentId);
        
        StringBuilder sb = new StringBuilder();
        sb.append("TRANSPORT DOCUMENT\n");
        sb.append("==================\n\n");
        
        sb.append("SHIPMENT INFORMATION\n");
        sb.append("Transport Code: ").append(document.getTransportCode()).append("\n");
        sb.append("Tracking Number: ").append(document.getTrackingNumber()).append("\n");
        sb.append("Status: ").append(document.getStatus()).append("\n");
        sb.append("Priority: ").append(document.getPriority()).append("\n");
        
        if (document.getDepartureDate() != null) {
            sb.append("Departure Date: ").append(document.getDepartureDate().format(DATE_FORMATTER)).append("\n");
        }
        
        if (document.getEstimatedDelivery() != null) {
            sb.append("Estimated Delivery: ").append(document.getEstimatedDelivery().format(DATE_FORMATTER)).append("\n");
        }
        
        sb.append("\nSENDER & RECEIVER INFORMATION\n");
        sb.append("Sender Name: ").append(document.getSenderName()).append("\n");
        sb.append("Sender Address: ").append(document.getSenderAddress()).append("\n");
        sb.append("Receiver Name: ").append(document.getReceiverName()).append("\n");
        sb.append("Receiver Address: ").append(document.getReceiverAddress()).append("\n");
        
        sb.append("\nCARGO DETAILS\n");
        sb.append("Description: ").append(document.getCargoDescription()).append("\n");
        
        if (document.getWeightKg() != null) {
            sb.append("Weight (kg): ").append(document.getWeightKg()).append("\n");
        }
        
        if (document.getVolumeM3() != null) {
            sb.append("Volume (m³): ").append(document.getVolumeM3()).append("\n");
        }
        
        if (document.getDeclaredValue() != null) {
            sb.append("Declared Value: ").append(document.getDeclaredValue()).append(" TL\n");
        }
        
        if (document.getShippingCost() != null) {
            sb.append("Shipping Cost: ").append(document.getShippingCost()).append(" TL\n");
        }
        
        if (document.getVehiclePlate() != null) {
            sb.append("\nVEHICLE INFORMATION\n");
            sb.append("License Plate: ").append(document.getVehiclePlate()).append("\n");
            
            if (document.getVehicleType() != null) {
                sb.append("Vehicle Type: ").append(document.getVehicleType()).append("\n");
            }
            
            if (document.getVehicleBrand() != null && document.getVehicleModel() != null) {
                sb.append("Brand/Model: ").append(document.getVehicleBrand()).append(" ").append(document.getVehicleModel()).append("\n");
            }
            
            if (document.getDriverName() != null) {
                sb.append("Driver: ").append(document.getDriverName()).append("\n");
            }
        }
        
        return sb.toString();
    }

    private TransportDocumentDto prepareDocumentData(Long shipmentId) {
        Shipment shipment = shipmentRepository.findById(shipmentId)
                .orElseThrow(() -> new ResourceNotFoundException("Shipment not found with id: " + shipmentId));
        
        TransportDocumentDto document = new TransportDocumentDto();
        
        // Basic shipment information
        document.setTransportId(shipment.getId());
        document.setTransportCode("TRP-" + String.format("%06d", shipment.getId()));
        document.setTrackingNumber(shipment.getTrackingNumber());
        document.setOrigin(shipment.getOriginAddress());
        document.setDestination(shipment.getDestinationAddress());
        document.setDepartureDate(shipment.getPickupDate());
        document.setArrivalDate(shipment.getDeliveryDate());
        document.setEstimatedDelivery(shipment.getEstimatedDelivery());
        
        // Cargo details
        document.setWeightKg(shipment.getWeightKg());
        document.setVolumeM3(shipment.getVolumeM3());
        document.setDeclaredValue(shipment.getDeclaredValue());
        document.setPriority(shipment.getPriority() != null ? shipment.getPriority().toString() : "NORMAL");
        document.setStatus(shipment.getStatus().toString());
        document.setShippingCost(shipment.getShippingCost());
        document.setNotes(shipment.getNotes());
        document.setCreatedAt(shipment.getCreatedAt());
        document.setUpdatedAt(shipment.getUpdatedAt());
        
        // Vehicle information
        if (shipment.getVehicleId() != null) {
            vehicleRepository.findById(shipment.getVehicleId()).ifPresent(vehicle -> {
                document.setVehiclePlate(vehicle.getLicensePlate());
                document.setVehicleType(vehicle.getVehicleType());
                document.setVehicleBrand(vehicle.getBrand());
                document.setVehicleModel(vehicle.getModel());
                document.setVehicleCapacityKg(vehicle.getCapacityKg());
            });
        }
        
        // Mock sender/receiver information (in real implementation, get from user service)
        document.setSenderName("Sender Company Ltd.");
        document.setSenderAddress(shipment.getOriginAddress());
        document.setSenderPhone("+90 212 555 0001");
        document.setSenderEmail("sender@company.com");
        
        document.setReceiverName("Receiver Company Ltd.");
        document.setReceiverAddress(shipment.getDestinationAddress());
        document.setReceiverPhone("+90 312 555 0002");
        document.setReceiverEmail("receiver@company.com");
        
        document.setCargoDescription("General cargo");
        document.setDriverName("Driver Name"); // In real implementation, get from user service
        
        return document;
    }

    // Excel helper methods
    private int addShipmentInfoToExcel(Sheet sheet, TransportDocumentDto data, int rowNum, CellStyle headerStyle) {
        Row headerRow = sheet.createRow(rowNum++);
        Cell headerCell = headerRow.createCell(0);
        headerCell.setCellValue("SHIPMENT INFORMATION");
        headerCell.setCellStyle(headerStyle);
        
        rowNum = addExcelRow(sheet, rowNum, "Transport Code:", data.getTransportCode());
        rowNum = addExcelRow(sheet, rowNum, "Tracking Number:", data.getTrackingNumber());
        rowNum = addExcelRow(sheet, rowNum, "Status:", data.getStatus());
        rowNum = addExcelRow(sheet, rowNum, "Priority:", data.getPriority());
        
        if (data.getDepartureDate() != null) {
            rowNum = addExcelRow(sheet, rowNum, "Departure Date:", data.getDepartureDate().format(DATE_FORMATTER));
        }
        
        if (data.getEstimatedDelivery() != null) {
            rowNum = addExcelRow(sheet, rowNum, "Estimated Delivery:", data.getEstimatedDelivery().format(DATE_FORMATTER));
        }
        
        return rowNum + 1; // Add empty row
    }

    private int addPartyInfoToExcel(Sheet sheet, TransportDocumentDto data, int rowNum, CellStyle headerStyle) {
        Row headerRow = sheet.createRow(rowNum++);
        Cell headerCell = headerRow.createCell(0);
        headerCell.setCellValue("SENDER & RECEIVER INFORMATION");
        headerCell.setCellStyle(headerStyle);
        
        rowNum = addExcelRow(sheet, rowNum, "Sender Name:", data.getSenderName());
        rowNum = addExcelRow(sheet, rowNum, "Sender Address:", data.getSenderAddress());
        rowNum = addExcelRow(sheet, rowNum, "Sender Phone:", data.getSenderPhone());
        rowNum = addExcelRow(sheet, rowNum, "Receiver Name:", data.getReceiverName());
        rowNum = addExcelRow(sheet, rowNum, "Receiver Address:", data.getReceiverAddress());
        rowNum = addExcelRow(sheet, rowNum, "Receiver Phone:", data.getReceiverPhone());
        
        return rowNum + 1; // Add empty row
    }

    private int addCargoDetailsToExcel(Sheet sheet, TransportDocumentDto data, int rowNum, CellStyle headerStyle) {
        Row headerRow = sheet.createRow(rowNum++);
        Cell headerCell = headerRow.createCell(0);
        headerCell.setCellValue("CARGO DETAILS");
        headerCell.setCellStyle(headerStyle);
        
        rowNum = addExcelRow(sheet, rowNum, "Description:", data.getCargoDescription());
        
        if (data.getWeightKg() != null) {
            rowNum = addExcelRow(sheet, rowNum, "Weight (kg):", data.getWeightKg().toString());
        }
        
        if (data.getVolumeM3() != null) {
            rowNum = addExcelRow(sheet, rowNum, "Volume (m³):", data.getVolumeM3().toString());
        }
        
        if (data.getDeclaredValue() != null) {
            rowNum = addExcelRow(sheet, rowNum, "Declared Value:", data.getDeclaredValue().toString() + " TL");
        }
        
        if (data.getShippingCost() != null) {
            rowNum = addExcelRow(sheet, rowNum, "Shipping Cost:", data.getShippingCost().toString() + " TL");
        }
        
        return rowNum + 1; // Add empty row
    }

    private int addVehicleInfoToExcel(Sheet sheet, TransportDocumentDto data, int rowNum, CellStyle headerStyle) {
        if (data.getVehiclePlate() != null) {
            Row headerRow = sheet.createRow(rowNum++);
            Cell headerCell = headerRow.createCell(0);
            headerCell.setCellValue("VEHICLE INFORMATION");
            headerCell.setCellStyle(headerStyle);
            
            rowNum = addExcelRow(sheet, rowNum, "License Plate:", data.getVehiclePlate());
            
            if (data.getVehicleType() != null) {
                rowNum = addExcelRow(sheet, rowNum, "Vehicle Type:", data.getVehicleType());
            }
            
            if (data.getVehicleBrand() != null && data.getVehicleModel() != null) {
                rowNum = addExcelRow(sheet, rowNum, "Brand/Model:", data.getVehicleBrand() + " " + data.getVehicleModel());
            }
            
            if (data.getDriverName() != null) {
                rowNum = addExcelRow(sheet, rowNum, "Driver:", data.getDriverName());
            }
        }
        
        return rowNum;
    }

    private int addExcelRow(Sheet sheet, int rowNum, String label, String value) {
        Row row = sheet.createRow(rowNum);
        row.createCell(0).setCellValue(label);
        row.createCell(1).setCellValue(value != null ? value : "");
        return rowNum + 1;
    }
}