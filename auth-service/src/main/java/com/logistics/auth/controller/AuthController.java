package com.logistics.auth.controller;

import com.logistics.auth.dto.*;
import com.logistics.auth.service.AuthService;
import com.logistics.common.dto.BaseResponse;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

/**
 * REST Controller for authentication operations.
 * Handles user login, registration, token refresh, and validation.
 * 
 * @author Logistics Platform Team
 * @version 1.0.0
 */
@RestController
@RequestMapping("/api/auth")
@CrossOrigin(origins = "*", maxAge = 3600)
@RequiredArgsConstructor
@Slf4j
public class AuthController {

    private final AuthService authService;

    /**
     * Handles user login and returns JWT token.
     * 
     * This endpoint authenticates users with username/email and password,
     * then returns a JWT token along with user information and refresh token.
     * 
     * @param loginRequest the login credentials
     * @param request HTTP servlet request for IP tracking
     * @return ResponseEntity containing JWT token and user information
     */
    @PostMapping("/login")
    public ResponseEntity<BaseResponse<AuthResponse>> login(
            @Valid @RequestBody LoginRequest loginRequest,
            HttpServletRequest request) {
        
        log.info("Login attempt for user: {}", loginRequest.getUsername());
        
        try {
            // Get client IP for security logging
            String clientIp = getClientIpAddress(request);
            String userAgent = request.getHeader("User-Agent");
            
            // Authenticate user and generate tokens
            JwtResponse jwtResponse = authService.authenticateUser(loginRequest, clientIp, userAgent);
            
            // Create auth response with updated structure
            AuthResponse authResponse = AuthResponse.builder()
                    .token(jwtResponse.getToken())
                    .tokenType("Bearer")
                    .refreshToken(jwtResponse.getRefreshToken())
                    .expiresIn(86400) // 24 hours in seconds
                    .user(UserInfo.builder()
                            .id(jwtResponse.getId())
                            .username(jwtResponse.getUsername())
                            .email(jwtResponse.getEmail())
                            .roles(jwtResponse.getRoles())
                            .build())
                    .build();
            
            log.info("Login successful for user: {}", loginRequest.getUsername());
            return ResponseEntity.ok(BaseResponse.success(authResponse, "Login successful"));
            
        } catch (Exception e) {
            log.error("Login failed for user: {} - {}", loginRequest.getUsername(), e.getMessage());
            return ResponseEntity.badRequest()
                    .body(BaseResponse.error("Login failed: " + e.getMessage()));
        }
    }

    /**
     * Handles user registration.
     * 
     * @param registerRequest the registration details
     * @param request HTTP servlet request for IP tracking
     * @return ResponseEntity with registration result
     */
    @PostMapping("/register")
    public ResponseEntity<BaseResponse<Map<String, Object>>> register(
            @Valid @RequestBody RegisterRequest registerRequest,
            HttpServletRequest request) {
        
        log.info("Registration attempt for user: {}", registerRequest.getUsername());
        
        try {
            String clientIp = getClientIpAddress(request);
            authService.registerUser(registerRequest, clientIp);
            
            Map<String, Object> response = new HashMap<>();
            response.put("username", registerRequest.getUsername());
            response.put("email", registerRequest.getEmail());
            response.put("message", "User registered successfully. Please verify your email.");
            
            log.info("Registration successful for user: {}", registerRequest.getUsername());
            return ResponseEntity.ok(BaseResponse.success(response, "User registered successfully"));
            
        } catch (Exception e) {
            log.error("Registration failed for user: {} - {}", registerRequest.getUsername(), e.getMessage());
            return ResponseEntity.badRequest()
                    .body(BaseResponse.error("Registration failed: " + e.getMessage()));
        }
    }

    /**
     * Refreshes JWT access token using refresh token.
     * 
     * @param request the token refresh request
     * @return ResponseEntity with new access token
     */
    @PostMapping("/refresh")
    public ResponseEntity<BaseResponse<AuthResponse>> refreshToken(
            @Valid @RequestBody TokenRefreshRequest request) {
        
        log.info("Token refresh attempt");
        
        try {
            JwtResponse jwtResponse = authService.refreshToken(request);
            
            AuthResponse authResponse = AuthResponse.builder()
                    .token(jwtResponse.getToken())
                    .tokenType("Bearer")
                    .refreshToken(jwtResponse.getRefreshToken())
                    .expiresIn(86400) // 24 hours in seconds
                    .user(UserInfo.builder()
                            .id(jwtResponse.getId())
                            .username(jwtResponse.getUsername())
                            .email(jwtResponse.getEmail())
                            .roles(jwtResponse.getRoles())
                            .build())
                    .build();
            
            log.info("Token refresh successful");
            return ResponseEntity.ok(BaseResponse.success(authResponse, "Token refreshed successfully"));
            
        } catch (Exception e) {
            log.error("Token refresh failed: {}", e.getMessage());
            return ResponseEntity.badRequest()
                    .body(BaseResponse.error("Token refresh failed: " + e.getMessage()));
        }
    }

    /**
     * Logs out user by invalidating tokens.
     * 
     * @param request HTTP servlet request
     * @return ResponseEntity with logout result
     */
    @PostMapping("/logout")
    public ResponseEntity<BaseResponse<Map<String, Object>>> logout(HttpServletRequest request) {
        
        try {
            String authHeader = request.getHeader("Authorization");
            if (authHeader != null && authHeader.startsWith("Bearer ")) {
                String token = authHeader.substring(7);
                authService.logoutUser(token);
            }
            
            Map<String, Object> response = new HashMap<>();
            response.put("message", "Logged out successfully");
            response.put("timestamp", System.currentTimeMillis());
            
            log.info("User logout successful");
            return ResponseEntity.ok(BaseResponse.success(response, "User logged out successfully"));
            
        } catch (Exception e) {
            log.error("Logout failed: {}", e.getMessage());
            return ResponseEntity.badRequest()
                    .body(BaseResponse.error("Logout failed: " + e.getMessage()));
        }
    }

    /**
     * Validates JWT token.
     * This endpoint is used by other services to validate tokens.
     * 
     * @param authHeader the Authorization header containing Bearer token
     * @return ResponseEntity with validation result
     */
    @GetMapping("/validate")
    public ResponseEntity<BaseResponse<TokenValidationResponse>> validateToken(
            @RequestHeader("Authorization") String authHeader) {
        
        try {
            if (authHeader == null || !authHeader.startsWith("Bearer ")) {
                return ResponseEntity.badRequest()
                        .body(BaseResponse.error("Invalid authorization header"));
            }
            
            String token = authHeader.substring(7);
            TokenValidationResponse validation = authService.validateToken(token);
            
            return ResponseEntity.ok(BaseResponse.success(validation, "Token validation successful"));
            
        } catch (Exception e) {
            log.error("Token validation failed: {}", e.getMessage());
            return ResponseEntity.badRequest()
                    .body(BaseResponse.error("Token validation failed: " + e.getMessage()));
        }
    }

    /**
     * Gets current user information from JWT token.
     * 
     * @param authHeader the Authorization header
     * @return ResponseEntity with user information
     */
    @GetMapping("/me")
    @PreAuthorize("hasRole('USER')")
    public ResponseEntity<BaseResponse<UserInfo>> getCurrentUser(
            @RequestHeader("Authorization") String authHeader) {
        
        try {
            String token = authHeader.substring(7);
            UserInfo userInfo = authService.getCurrentUserInfo(token);
            
            return ResponseEntity.ok(BaseResponse.success(userInfo, "User information retrieved successfully"));
            
        } catch (Exception e) {
            log.error("Failed to get current user: {}", e.getMessage());
            return ResponseEntity.badRequest()
                    .body(BaseResponse.error("Failed to get user information: " + e.getMessage()));
        }
    }

    /**
     * Changes user password.
     * 
     * @param request the password change request
     * @param authHeader the Authorization header
     * @return ResponseEntity with result
     */
    @PostMapping("/change-password")
    @PreAuthorize("hasRole('USER')")
    public ResponseEntity<BaseResponse<Map<String, Object>>> changePassword(
            @Valid @RequestBody ChangePasswordRequest request,
            @RequestHeader("Authorization") String authHeader) {
        
        try {
            String token = authHeader.substring(7);
            authService.changePassword(token, request);
            
            Map<String, Object> response = new HashMap<>();
            response.put("message", "Password changed successfully");
            response.put("timestamp", System.currentTimeMillis());
            
            log.info("Password change successful");
            return ResponseEntity.ok(BaseResponse.success(response, "Password changed successfully"));
            
        } catch (Exception e) {
            log.error("Password change failed: {}", e.getMessage());
            return ResponseEntity.badRequest()
                    .body(BaseResponse.error("Password change failed: " + e.getMessage()));
        }
    }

    /**
     * Initiates password reset process.
     * 
     * @param request the password reset request
     * @return ResponseEntity with result
     */
    @PostMapping("/forgot-password")
    public ResponseEntity<BaseResponse<Map<String, Object>>> forgotPassword(
            @Valid @RequestBody ForgotPasswordRequest request) {
        
        try {
            authService.initiateForgotPassword(request.getEmail());
            
            Map<String, Object> response = new HashMap<>();
            response.put("message", "Password reset instructions sent to email");
            response.put("email", request.getEmail());
            
            log.info("Password reset initiated for email: {}", request.getEmail());
            return ResponseEntity.ok(BaseResponse.success(response, "Password reset initiated"));
            
        } catch (Exception e) {
            log.error("Password reset failed for email: {} - {}", request.getEmail(), e.getMessage());
            return ResponseEntity.badRequest()
                    .body(BaseResponse.error("Password reset failed: " + e.getMessage()));
        }
    }

    /**
     * Resets password using reset token.
     * 
     * @param request the reset password request
     * @return ResponseEntity with result
     */
    @PostMapping("/reset-password")
    public ResponseEntity<BaseResponse<Map<String, Object>>> resetPassword(
            @Valid @RequestBody ResetPasswordRequest request) {
        
        try {
            authService.resetPassword(request);
            
            Map<String, Object> response = new HashMap<>();
            response.put("message", "Password reset successfully");
            response.put("timestamp", System.currentTimeMillis());
            
            log.info("Password reset successful");
            return ResponseEntity.ok(BaseResponse.success(response, "Password reset successfully"));
            
        } catch (Exception e) {
            log.error("Password reset failed: {}", e.getMessage());
            return ResponseEntity.badRequest()
                    .body(BaseResponse.error("Password reset failed: " + e.getMessage()));
        }
    }

    /**
     * Gets authentication statistics (admin only).
     * 
     * @return ResponseEntity with auth statistics
     */
    @GetMapping("/stats")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<BaseResponse<Map<String, Object>>> getAuthStats() {
        
        try {
            Map<String, Object> stats = authService.getAuthenticationStats();
            return ResponseEntity.ok(BaseResponse.success(stats, "Authentication statistics retrieved"));
            
        } catch (Exception e) {
            log.error("Failed to get auth stats: {}", e.getMessage());
            return ResponseEntity.badRequest()
                    .body(BaseResponse.error("Failed to get statistics: " + e.getMessage()));
        }
    }

    /**
     * Health check endpoint for the auth service.
     * 
     * @return ResponseEntity with health status
     */
    @GetMapping("/health")
    public ResponseEntity<Map<String, Object>> health() {
        Map<String, Object> health = new HashMap<>();
        health.put("status", "UP");
        health.put("service", "auth-service");
        health.put("timestamp", System.currentTimeMillis());
        health.put("version", "1.0.0");
        return ResponseEntity.ok(health);
    }

    /**
     * Extracts client IP address from HTTP request.
     * 
     * @param request the HTTP servlet request
     * @return client IP address
     */
    private String getClientIpAddress(HttpServletRequest request) {
        String xForwardedFor = request.getHeader("X-Forwarded-For");
        if (xForwardedFor != null && !xForwardedFor.isEmpty()) {
            return xForwardedFor.split(",")[0].trim();
        }
        
        String xRealIp = request.getHeader("X-Real-IP");
        if (xRealIp != null && !xRealIp.isEmpty()) {
            return xRealIp;
        }
        
        return request.getRemoteAddr();
    }
}