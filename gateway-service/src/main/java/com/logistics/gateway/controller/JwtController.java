package com.logistics.gateway.controller;

import com.logistics.gateway.service.JwtService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

/**
 * REST Controller for JWT token operations.
 * Provides endpoints for token validation and information retrieval.
 */
@RestController
@RequestMapping("/gateway/jwt")
public class JwtController {

    @Autowired
    private JwtService jwtService;

    /**
     * Validates a JWT token.
     * 
     * @param token the JWT token to validate
     * @return validation result
     */
    @PostMapping("/validate")
    public ResponseEntity<Map<String, Object>> validateToken(@RequestBody Map<String, String> request) {
        String token = request.get("token");
        Map<String, Object> response = new HashMap<>();
        
        try {
            boolean isValid = jwtService.validateJwtToken(token);
            response.put("valid", isValid);
            
            if (isValid) {
                response.put("username", jwtService.getUsernameFromJwtToken(token));
                response.put("roles", jwtService.getRolesFromJwtToken(token));
                response.put("expired", jwtService.isTokenExpired(token));
            }
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            response.put("valid", false);
            response.put("error", e.getMessage());
            return ResponseEntity.badRequest().body(response);
        }
    }

    /**
     * Gets detailed information about a JWT token.
     * 
     * @param token the JWT token
     * @return token information
     */
    @PostMapping("/info")
    public ResponseEntity<Map<String, Object>> getTokenInfo(@RequestBody Map<String, String> request) {
        String token = request.get("token");
        
        try {
            Map<String, Object> tokenInfo = jwtService.getTokenInfo(token);
            return ResponseEntity.ok(tokenInfo);
        } catch (Exception e) {
            Map<String, Object> error = new HashMap<>();
            error.put("error", e.getMessage());
            return ResponseEntity.badRequest().body(error);
        }
    }

    /**
     * Refreshes a JWT token.
     * 
     * @param request containing the token to refresh
     * @return new refreshed token
     */
    @PostMapping("/refresh")
    public ResponseEntity<Map<String, Object>> refreshToken(@RequestBody Map<String, String> request) {
        String token = request.get("token");
        Map<String, Object> response = new HashMap<>();
        
        try {
            String newToken = jwtService.refreshToken(token);
            response.put("success", true);
            response.put("token", newToken);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            response.put("success", false);
            response.put("error", e.getMessage());
            return ResponseEntity.badRequest().body(response);
        }
    }
}