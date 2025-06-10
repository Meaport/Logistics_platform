package com.logistics.transport.service;

import com.itextpdf.kernel.pdf.PdfDocument;
import com.itextpdf.kernel.pdf.PdfWriter;
import com.itextpdf.layout.Document;
import com.itextpdf.layout.element.Paragraph;
import com.itextpdf.layout.element.Table;
import com.itextpdf.layout.element.Cell;
import com.itextpdf.layout.property.TextAlignment;
import com.itextpdf.layout.property.UnitValue;
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
     */
    @PreAuthorize("hasRole('ADMIN') or hasRole('MANAGER')")
    public byte[] exportDocumentPdf(Long shipmentId) throws IOException {
        log.info("Exporting PDF document for shipment: {}", shipmentId);
        
        TransportDocumentDto document = prepareDocumentData(shipmentId);
        
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        PdfWriter writer = new PdfWriter(baos);
        PdfDocument pdf = new PdfDocument(writer);
        Document pdfDocument = new Document(pdf);

        // Add title
        pdfDocument.add(new Paragraph("TRANSPORT DOCUMENT")
                .setTextAlignment(TextAlignment.CENTER)
                .setFontSize(20)
                .setBold());

        pdfDocument.add(new Paragraph("\n"));

        // Add shipment information
        addShipmentInfoToPdf(pdfDocument, document);
        
        // Add sender/receiver information
        addPartyInfoToPdf(pdfDocument, document);
        
        // Add cargo details
        addCargoDetailsToPdf(pdfDocument, document);
        
        // Add vehicle information
        addVehicleInfoToPdf(pdfDocument, document);

        pdfDocument.close();
        
        log.info("PDF document exported successfully for shipment: {}", shipmentId);
        return baos.toByteArray();
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

    private void addShipmentInfoToPdf(Document document, TransportDocumentDto data) {
        document.add(new Paragraph("SHIPMENT INFORMATION").setBold().setFontSize(14));
        
        Table table = new Table(UnitValue.createPercentArray(new float[]{30, 70}));
        table.setWidth(UnitValue.createPercentValue(100));
        
        table.addCell(new Cell().add(new Paragraph("Transport Code:").setBold()));
        table.addCell(new Cell().add(new Paragraph(data.getTransportCode())));
        
        table.addCell(new Cell().add(new Paragraph("Tracking Number:").setBold()));
        table.addCell(new Cell().add(new Paragraph(data.getTrackingNumber())));
        
        table.addCell(new Cell().add(new Paragraph("Status:").setBold()));
        table.addCell(new Cell().add(new Paragraph(data.getStatus())));
        
        table.addCell(new Cell().add(new Paragraph("Priority:").setBold()));
        table.addCell(new Cell().add(new Paragraph(data.getPriority())));
        
        if (data.getDepartureDate() != null) {
            table.addCell(new Cell().add(new Paragraph("Departure Date:").setBold()));
            table.addCell(new Cell().add(new Paragraph(data.getDepartureDate().format(DATE_FORMATTER))));
        }
        
        if (data.getEstimatedDelivery() != null) {
            table.addCell(new Cell().add(new Paragraph("Estimated Delivery:").setBold()));
            table.addCell(new Cell().add(new Paragraph(data.getEstimatedDelivery().format(DATE_FORMATTER))));
        }
        
        document.add(table);
        document.add(new Paragraph("\n"));
    }

    private void addPartyInfoToPdf(Document document, TransportDocumentDto data) {
        document.add(new Paragraph("SENDER & RECEIVER INFORMATION").setBold().setFontSize(14));
        
        Table table = new Table(UnitValue.createPercentArray(new float[]{25, 25, 25, 25}));
        table.setWidth(UnitValue.createPercentValue(100));
        
        // Headers
        table.addCell(new Cell().add(new Paragraph("").setBold()));
        table.addCell(new Cell().add(new Paragraph("SENDER").setBold()));
        table.addCell(new Cell().add(new Paragraph("").setBold()));
        table.addCell(new Cell().add(new Paragraph("RECEIVER").setBold()));
        
        // Name
        table.addCell(new Cell().add(new Paragraph("Name:").setBold()));
        table.addCell(new Cell().add(new Paragraph(data.getSenderName())));
        table.addCell(new Cell().add(new Paragraph("Name:").setBold()));
        table.addCell(new Cell().add(new Paragraph(data.getReceiverName())));
        
        // Address
        table.addCell(new Cell().add(new Paragraph("Address:").setBold()));
        table.addCell(new Cell().add(new Paragraph(data.getSenderAddress())));
        table.addCell(new Cell().add(new Paragraph("Address:").setBold()));
        table.addCell(new Cell().add(new Paragraph(data.getReceiverAddress())));
        
        // Phone
        table.addCell(new Cell().add(new Paragraph("Phone:").setBold()));
        table.addCell(new Cell().add(new Paragraph(data.getSenderPhone())));
        table.addCell(new Cell().add(new Paragraph("Phone:").setBold()));
        table.addCell(new Cell().add(new Paragraph(data.getReceiverPhone())));
        
        document.add(table);
        document.add(new Paragraph("\n"));
    }

    private void addCargoDetailsToPdf(Document document, TransportDocumentDto data) {
        document.add(new Paragraph("CARGO DETAILS").setBold().setFontSize(14));
        
        Table table = new Table(UnitValue.createPercentArray(new float[]{30, 70}));
        table.setWidth(UnitValue.createPercentValue(100));
        
        table.addCell(new Cell().add(new Paragraph("Description:").setBold()));
        table.addCell(new Cell().add(new Paragraph(data.getCargoDescription())));
        
        if (data.getWeightKg() != null) {
            table.addCell(new Cell().add(new Paragraph("Weight (kg):").setBold()));
            table.addCell(new Cell().add(new Paragraph(data.getWeightKg().toString())));
        }
        
        if (data.getVolumeM3() != null) {
            table.addCell(new Cell().add(new Paragraph("Volume (m³):").setBold()));
            table.addCell(new Cell().add(new Paragraph(data.getVolumeM3().toString())));
        }
        
        if (data.getDeclaredValue() != null) {
            table.addCell(new Cell().add(new Paragraph("Declared Value:").setBold()));
            table.addCell(new Cell().add(new Paragraph(data.getDeclaredValue().toString() + " TL")));
        }
        
        if (data.getShippingCost() != null) {
            table.addCell(new Cell().add(new Paragraph("Shipping Cost:").setBold()));
            table.addCell(new Cell().add(new Paragraph(data.getShippingCost().toString() + " TL")));
        }
        
        document.add(table);
        document.add(new Paragraph("\n"));
    }

    private void addVehicleInfoToPdf(Document document, TransportDocumentDto data) {
        if (data.getVehiclePlate() != null) {
            document.add(new Paragraph("VEHICLE INFORMATION").setBold().setFontSize(14));
            
            Table table = new Table(UnitValue.createPercentArray(new float[]{30, 70}));
            table.setWidth(UnitValue.createPercentValue(100));
            
            table.addCell(new Cell().add(new Paragraph("License Plate:").setBold()));
            table.addCell(new Cell().add(new Paragraph(data.getVehiclePlate())));
            
            if (data.getVehicleType() != null) {
                table.addCell(new Cell().add(new Paragraph("Vehicle Type:").setBold()));
                table.addCell(new Cell().add(new Paragraph(data.getVehicleType())));
            }
            
            if (data.getVehicleBrand() != null && data.getVehicleModel() != null) {
                table.addCell(new Cell().add(new Paragraph("Brand/Model:").setBold()));
                table.addCell(new Cell().add(new Paragraph(data.getVehicleBrand() + " " + data.getVehicleModel())));
            }
            
            if (data.getDriverName() != null) {
                table.addCell(new Cell().add(new Paragraph("Driver:").setBold()));
                table.addCell(new Cell().add(new Paragraph(data.getDriverName())));
            }
            
            document.add(table);
        }
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