package com.logistics.transport.controller;

import com.logistics.transport.service.DocumentExportService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.io.IOException;

/**
 * Controller for document export operations.
 */
@RestController
@RequestMapping("/transport/documents")
@RequiredArgsConstructor
@CrossOrigin(origins = "*", maxAge = 3600)
@Slf4j
public class DocumentExportController {

    private final DocumentExportService documentExportService;

    /**
     * Export shipment document as PDF.
     */
    @GetMapping("/export/pdf/{id}")
    public ResponseEntity<byte[]> exportDocumentPdf(@PathVariable Long id) {
        try {
            log.info("Exporting PDF document for shipment: {}", id);
            
            byte[] pdfBytes = documentExportService.exportDocumentPdf(id);
            
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_PDF);
            headers.setContentDispositionFormData("attachment", "transport-document-" + id + ".pdf");
            headers.setContentLength(pdfBytes.length);
            
            return ResponseEntity.ok()
                    .headers(headers)
                    .body(pdfBytes);
                    
        } catch (IOException e) {
            log.error("Error exporting PDF document for shipment {}: {}", id, e.getMessage());
            return ResponseEntity.internalServerError().build();
        } catch (Exception e) {
            log.error("Unexpected error exporting PDF document for shipment {}: {}", id, e.getMessage());
            return ResponseEntity.badRequest().build();
        }
    }

    /**
     * Export shipment document as Excel.
     */
    @GetMapping("/export/excel/{id}")
    public ResponseEntity<byte[]> exportDocumentExcel(@PathVariable Long id) {
        try {
            log.info("Exporting Excel document for shipment: {}", id);
            
            byte[] excelBytes = documentExportService.exportDocumentExcel(id);
            
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.parseMediaType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"));
            headers.setContentDispositionFormData("attachment", "transport-document-" + id + ".xlsx");
            headers.setContentLength(excelBytes.length);
            
            return ResponseEntity.ok()
                    .headers(headers)
                    .body(excelBytes);
                    
        } catch (IOException e) {
            log.error("Error exporting Excel document for shipment {}: {}", id, e.getMessage());
            return ResponseEntity.internalServerError().build();
        } catch (Exception e) {
            log.error("Unexpected error exporting Excel document for shipment {}: {}", id, e.getMessage());
            return ResponseEntity.badRequest().build();
        }
    }

    /**
     * Get document preview information.
     */
    @GetMapping("/preview/{id}")
    public ResponseEntity<String> getDocumentPreview(@PathVariable Long id) {
        try {
            // Return basic document information for preview
            return ResponseEntity.ok("Document preview for shipment " + id + " is available for export as PDF or Excel.");
        } catch (Exception e) {
            log.error("Error getting document preview for shipment {}: {}", id, e.getMessage());
            return ResponseEntity.badRequest().body("Error getting document preview: " + e.getMessage());
        }
    }
}