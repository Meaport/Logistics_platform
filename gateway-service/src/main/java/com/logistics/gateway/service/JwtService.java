package com.logistics.gateway.service;

import com.logistics.gateway.util.JwtUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;

/**
 * Service layer for JWT operations.
 * This service acts as a facade for JwtUtil and provides
 * business logic for JWT token management.
 * 
 * @author Logistics Platform Team
 * @version 1.0.0
 */
@Service
public class JwtService {

    @Autowired
    private JwtUtil jwtUtil;

    /**
     * Validates JWT token.
     * 
     * @param token the JWT token to validate
     * @return true if token is valid, false otherwise
     */
    public boolean validateJwtToken(String token) {
        return jwtUtil.validateToken(token);
    }

    /**
     * Extracts username from JWT token.
     * 
     * @param token the JWT token
     * @return the username from the token
     */
    public String getUsernameFromJwtToken(String token) {
        return jwtUtil.getUsernameFromToken(token);
    }

    /**
     * Extracts roles from JWT token.
     * 
     * @param token the JWT token
     * @return list of user roles
     */
    public List<String> getRolesFromJwtToken(String token) {
        return jwtUtil.getRolesFromToken(token);
    }

    /**
     * Checks if token is expired.
     * 
     * @param token the JWT token
     * @return true if expired, false otherwise
     */
    public boolean isTokenExpired(String token) {
        return jwtUtil.isTokenExpired(token);
    }

    /**
     * Gets comprehensive token information.
     * 
     * @param token the JWT token
     * @return map containing token details
     */
    public Map<String, Object> getTokenInfo(String token) {
        return jwtUtil.getTokenInfo(token);
    }

    /**
     * Refreshes an existing token.
     * 
     * @param token the existing token
     * @return new refreshed token
     */
    public String refreshToken(String token) {
        return jwtUtil.refreshToken(token);
    }
}