package com.logistics.auth.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.Set;

/**
 * Response DTO for token validation operations.
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class TokenValidationResponse {
    
    private boolean valid;
    private String username;
    private Set<String> roles;
    private boolean expired;
    private long expiresAt; // Expiration timestamp
    private String message;
}