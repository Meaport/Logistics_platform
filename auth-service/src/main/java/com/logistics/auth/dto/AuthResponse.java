package com.logistics.auth.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Response DTO for authentication operations.
 * Contains JWT token information and user details.
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AuthResponse {
    
    private String token;
    
    @Builder.Default
    private String tokenType = "Bearer";
    
    private String refreshToken;
    private long expiresIn; // Token expiration time in seconds
    private UserInfo user;
}