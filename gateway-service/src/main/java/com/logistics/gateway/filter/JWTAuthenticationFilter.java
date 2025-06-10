package com.logistics.gateway.filter;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.logistics.gateway.service.JwtService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.cloud.gateway.filter.GatewayFilterChain;
import org.springframework.cloud.gateway.filter.GlobalFilter;
import org.springframework.core.Ordered;
import org.springframework.core.io.buffer.DataBuffer;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.server.reactive.ServerHttpRequest;
import org.springframework.http.server.reactive.ServerHttpResponse;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;
import org.springframework.web.server.ServerWebExchange;
import reactor.core.publisher.Mono;

import java.nio.charset.StandardCharsets;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * JWT Authentication Filter that validates incoming JWT tokens from Authorization headers.
 * This filter implements GlobalFilter to intercept all requests and validate JWT tokens
 * before routing to downstream services.
 * 
 * @author Logistics Platform Team
 * @version 1.0.0
 */
@Component
public class JWTAuthenticationFilter implements GlobalFilter, Ordered {

    /**
     * Utility class for validating and parsing JWT tokens
     */
    @Autowired
    private JwtService jwtUtil;

    private final ObjectMapper objectMapper = new ObjectMapper();

    /**
     * Validates JWT token and adds claims to request headers for downstream services.
     * 
     * This method:
     * 1. Checks if the endpoint requires authentication
     * 2. Extracts JWT token from Authorization header
     * 3. Validates the token using JwtService
     * 4. Extracts user information (username, roles) from token
     * 5. Adds user information to request headers for downstream services
     * 6. Handles authentication errors with proper HTTP responses
     * 
     * @param exchange the current server exchange
     * @param chain provides a way to delegate to the next filter
     * @return Mono<Void> to indicate when request processing is complete
     */
    @Override
    public Mono<Void> filter(ServerWebExchange exchange, GatewayFilterChain chain) {
        ServerHttpRequest request = exchange.getRequest();
        String path = request.getURI().getPath();
        String method = request.getMethod().name();

        // Log incoming request
        logRequest(request, path, method);

        // Skip authentication for public endpoints
        if (isPublicEndpoint(path)) {
            return chain.filter(exchange);
        }

        // Extract Authorization header
        String authHeader = request.getHeaders().getFirst(HttpHeaders.AUTHORIZATION);
        
        if (!StringUtils.hasText(authHeader)) {
            return handleAuthenticationError(exchange, "Authorization header is missing", HttpStatus.UNAUTHORIZED);
        }

        if (!authHeader.startsWith("Bearer ")) {
            return handleAuthenticationError(exchange, "Authorization header must start with 'Bearer '", HttpStatus.UNAUTHORIZED);
        }

        // Extract JWT token
        String token = authHeader.substring(7);
        
        if (!StringUtils.hasText(token)) {
            return handleAuthenticationError(exchange, "JWT token is empty", HttpStatus.UNAUTHORIZED);
        }

        // Validate JWT token
        if (!jwtUtil.validateJwtToken(token)) {
            return handleAuthenticationError(exchange, "Invalid or expired JWT token", HttpStatus.UNAUTHORIZED);
        }

        try {
            // Extract user information from token
            String username = jwtUtil.getUsernameFromJwtToken(token);
            List<String> roles = jwtUtil.getRolesFromJwtToken(token);
            
            if (!StringUtils.hasText(username)) {
                return handleAuthenticationError(exchange, "Username not found in token", HttpStatus.UNAUTHORIZED);
            }

            // Create modified request with user information in headers
            ServerHttpRequest modifiedRequest = request.mutate()
                    .header("X-User-Name", username)
                    .header("X-User-Roles", roles != null ? String.join(",", roles) : "")
                    .header("X-Auth-Token", token)
                    .header("X-Request-Source", "gateway")
                    .build();

            // Create modified exchange
            ServerWebExchange modifiedExchange = exchange.mutate()
                    .request(modifiedRequest)
                    .build();

            // Log successful authentication
            logSuccessfulAuthentication(username, roles, path);
            
            return chain.filter(modifiedExchange);
            
        } catch (Exception e) {
            return handleAuthenticationError(exchange, 
                "Token processing error: " + e.getMessage(), 
                HttpStatus.UNAUTHORIZED);
        }
    }

    /**
     * Sets the filter execution order.
     * Lower values have higher priority.
     * 
     * @return the order value (1 = high priority, executed early)
     */
    @Override
    public int getOrder() {
        return 1; // High priority - execute before other filters
    }

    /**
     * Determines if the given path is a public endpoint that doesn't require authentication.
     * 
     * @param path the request path
     * @return true if the endpoint is public, false otherwise
     */
    private boolean isPublicEndpoint(String path) {
        return path.startsWith("/api/auth/") ||
               path.startsWith("/eureka/") ||
               path.startsWith("/actuator/") ||
               path.equals("/health") ||
               path.startsWith("/services/") ||
               path.startsWith("/gateway/") ||
               path.equals("/favicon.ico");
    }

    /**
     * Handles authentication errors by creating a proper HTTP error response.
     * 
     * @param exchange the current server exchange
     * @param message the error message
     * @param status the HTTP status code
     * @return Mono<Void> with error response
     */
    private Mono<Void> handleAuthenticationError(ServerWebExchange exchange, String message, HttpStatus status) {
        ServerHttpResponse response = exchange.getResponse();
        response.setStatusCode(status);
        response.getHeaders().add(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE);
        response.getHeaders().add(HttpHeaders.ACCESS_CONTROL_ALLOW_ORIGIN, "*");
        response.getHeaders().add(HttpHeaders.ACCESS_CONTROL_ALLOW_METHODS, "GET, POST, PUT, DELETE, OPTIONS");
        response.getHeaders().add(HttpHeaders.ACCESS_CONTROL_ALLOW_HEADERS, "*");

        Map<String, Object> errorResponse = new HashMap<>();
        errorResponse.put("success", false);
        errorResponse.put("error", status.getReasonPhrase());
        errorResponse.put("message", message);
        errorResponse.put("timestamp", System.currentTimeMillis());
        errorResponse.put("path", exchange.getRequest().getURI().getPath());
        errorResponse.put("method", exchange.getRequest().getMethod().name());

        try {
            String jsonResponse = objectMapper.writeValueAsString(errorResponse);
            DataBuffer buffer = response.bufferFactory().wrap(jsonResponse.getBytes(StandardCharsets.UTF_8));
            
            // Log authentication failure
            logAuthenticationFailure(exchange.getRequest(), message);
            
            return response.writeWith(Mono.just(buffer));
        } catch (JsonProcessingException e) {
            DataBuffer buffer = response.bufferFactory().wrap(
                "{\"success\":false,\"error\":\"Authentication Failed\",\"message\":\"" + message + "\"}"
                .getBytes(StandardCharsets.UTF_8));
            return response.writeWith(Mono.just(buffer));
        }
    }

    /**
     * Logs incoming request information for debugging and monitoring.
     * 
     * @param request the HTTP request
     * @param path the request path
     * @param method the HTTP method
     */
    private void logRequest(ServerHttpRequest request, String path, String method) {
        String remoteAddress = request.getRemoteAddress() != null ? 
            request.getRemoteAddress().getAddress().getHostAddress() : "unknown";
        String userAgent = request.getHeaders().getFirst("User-Agent");
        
        System.out.println(String.format(
            "[JWT-FILTER] Incoming request: %s %s from %s | User-Agent: %s", 
            method, path, remoteAddress, userAgent != null ? userAgent : "unknown"
        ));
    }

    /**
     * Logs successful authentication for monitoring and audit purposes.
     * 
     * @param username the authenticated username
     * @param roles the user roles
     * @param path the request path
     */
    private void logSuccessfulAuthentication(String username, List<String> roles, String path) {
        System.out.println(String.format(
            "[JWT-FILTER] Authentication successful: User=%s, Roles=%s, Path=%s", 
            username, roles != null ? String.join(",", roles) : "none", path
        ));
    }

    /**
     * Logs authentication failures for security monitoring.
     * 
     * @param request the HTTP request
     * @param reason the failure reason
     */
    private void logAuthenticationFailure(ServerHttpRequest request, String reason) {
        String remoteAddress = request.getRemoteAddress() != null ? 
            request.getRemoteAddress().getAddress().getHostAddress() : "unknown";
        
        System.err.println(String.format(
            "[JWT-FILTER] Authentication failed: %s | Path: %s | IP: %s", 
            reason, request.getURI().getPath(), remoteAddress
        ));
    }
}