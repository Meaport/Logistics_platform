package com.logistics.auth.security;

import io.jsonwebtoken.*;
import io.jsonwebtoken.io.Decoders;
import io.jsonwebtoken.security.Keys;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Component;

import javax.crypto.SecretKey;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * JWT Provider component for generating and validating JWT tokens from UserDetails.
 * This component provides a high-level interface for JWT operations specifically
 * designed to work with Spring Security's UserDetails interface.
 * 
 * @author Logistics Platform Team
 * @version 1.0.0
 */
@Component
public class JwtProvider {

    private static final Logger log = LoggerFactory.getLogger(JwtProvider.class);

    @Value("${jwt.secret}")
    private String jwtSecret;

    @Value("${jwt.expiration}")
    private int jwtExpirationMs;

    @Value("${jwt.refresh-expiration}")
    private int refreshTokenExpirationMs;

    /**
     * Generate JWT token from user details.
     * 
     * This method creates a comprehensive JWT token containing:
     * - Username as subject
     * - User roles and authorities
     * - Standard JWT claims (iat, exp)
     * - Custom claims for enhanced functionality
     * 
     * @param userDetails Spring Security UserDetails object containing user information
     * @return JWT token as string
     * @throws RuntimeException if token generation fails
     */
    public String generateToken(UserDetails userDetails) {
        try {
            log.debug("Generating JWT token for user: {}", userDetails.getUsername());
            
            // Extract roles and authorities from UserDetails
            List<String> authorities = userDetails.getAuthorities().stream()
                    .map(GrantedAuthority::getAuthority)
                    .collect(Collectors.toList());
            
            // Create custom claims
            Map<String, Object> claims = new HashMap<>();
            claims.put("roles", authorities);
            claims.put("enabled", userDetails.isEnabled());
            claims.put("accountNonExpired", userDetails.isAccountNonExpired());
            claims.put("accountNonLocked", userDetails.isAccountNonLocked());
            claims.put("credentialsNonExpired", userDetails.isCredentialsNonExpired());
            claims.put("tokenType", "access");
            
            // Generate token
            String token = createToken(claims, userDetails.getUsername(), jwtExpirationMs);
            
            log.info("JWT token generated successfully for user: {}", userDetails.getUsername());
            return token;
            
        } catch (Exception e) {
            log.error("Failed to generate JWT token for user: {} - {}", 
                     userDetails.getUsername(), e.getMessage());
            throw new RuntimeException("JWT token generation failed", e);
        }
    }

    /**
     * Generate refresh token from user details.
     * 
     * @param userDetails Spring Security UserDetails object
     * @return refresh token as string
     */
    public String generateRefreshToken(UserDetails userDetails) {
        try {
            log.debug("Generating refresh token for user: {}", userDetails.getUsername());
            
            Map<String, Object> claims = new HashMap<>();
            claims.put("tokenType", "refresh");
            claims.put("username", userDetails.getUsername());
            
            String refreshToken = createToken(claims, userDetails.getUsername(), refreshTokenExpirationMs);
            
            log.info("Refresh token generated successfully for user: {}", userDetails.getUsername());
            return refreshToken;
            
        } catch (Exception e) {
            log.error("Failed to generate refresh token for user: {} - {}", 
                     userDetails.getUsername(), e.getMessage());
            throw new RuntimeException("Refresh token generation failed", e);
        }
    }

    /**
     * Validate JWT token.
     * 
     * This method performs comprehensive validation including:
     * - Signature verification using the secret key
     * - Expiration date validation
     * - Token structure and format validation
     * - Claims validation
     * 
     * @param token the JWT token to validate
     * @return true if token is valid and not expired, false otherwise
     */
    public boolean validateToken(String token) {
        try {
            log.debug("Validating JWT token");
            
            Jwts.parser()
                .verifyWith(getSignInKey())
                .build()
                .parseSignedClaims(token);
            
            log.debug("JWT token validation successful");
            return true;
            
        } catch (MalformedJwtException e) {
            log.error("Invalid JWT token format: {}", e.getMessage());
        } catch (ExpiredJwtException e) {
            log.warn("JWT token is expired: {}", e.getMessage());
        } catch (UnsupportedJwtException e) {
            log.error("JWT token is unsupported: {}", e.getMessage());
        } catch (IllegalArgumentException e) {
            log.error("JWT claims string is empty: {}", e.getMessage());
        } catch (SecurityException e) {
            log.error("JWT signature validation failed: {}", e.getMessage());
        } catch (Exception e) {
            log.error("JWT token validation error: {}", e.getMessage());
        }
        
        return false;
    }

    /**
     * Extract username from JWT token.
     * 
     * @param token the JWT token
     * @return username (subject) from the token
     * @throws JwtException if token is invalid or username cannot be extracted
     */
    public String getUsernameFromToken(String token) {
        try {
            log.debug("Extracting username from JWT token");
            
            Claims claims = Jwts.parser()
                    .verifyWith(getSignInKey())
                    .build()
                    .parseSignedClaims(token)
                    .getPayload();
            
            String username = claims.getSubject();
            log.debug("Username extracted successfully: {}", username);
            
            return username;
            
        } catch (Exception e) {
            log.error("Failed to extract username from JWT token: {}", e.getMessage());
            throw new JwtException("Username extraction failed: " + e.getMessage());
        }
    }

    /**
     * Extract user roles from JWT token.
     * 
     * @param token the JWT token
     * @return list of user roles/authorities
     */
    @SuppressWarnings("unchecked")
    public List<String> getRolesFromToken(String token) {
        try {
            log.debug("Extracting roles from JWT token");
            
            Claims claims = Jwts.parser()
                    .verifyWith(getSignInKey())
                    .build()
                    .parseSignedClaims(token)
                    .getPayload();
            
            Object rolesObj = claims.get("roles");
            if (rolesObj instanceof List) {
                List<String> roles = (List<String>) rolesObj;
                log.debug("Roles extracted successfully: {}", roles);
                return roles;
            }
            
            log.debug("No roles found in token");
            return List.of();
            
        } catch (Exception e) {
            log.error("Failed to extract roles from JWT token: {}", e.getMessage());
            return List.of();
        }
    }

    /**
     * Check if JWT token is expired.
     * 
     * @param token the JWT token
     * @return true if token is expired, false otherwise
     */
    public boolean isTokenExpired(String token) {
        try {
            Claims claims = Jwts.parser()
                    .verifyWith(getSignInKey())
                    .build()
                    .parseSignedClaims(token)
                    .getPayload();
            
            Date expiration = claims.getExpiration();
            boolean expired = expiration.before(new Date());
            
            log.debug("Token expiration check: expired={}, expiration={}", expired, expiration);
            return expired;
            
        } catch (ExpiredJwtException e) {
            log.debug("Token is expired: {}", e.getMessage());
            return true;
        } catch (Exception e) {
            log.error("Error checking token expiration: {}", e.getMessage());
            return true; // Consider invalid tokens as expired
        }
    }

    /**
     * Extract all claims from JWT token.
     * 
     * @param token the JWT token
     * @return Claims object containing all token claims
     */
    public Claims getAllClaimsFromToken(String token) {
        try {
            return Jwts.parser()
                    .verifyWith(getSignInKey())
                    .build()
                    .parseSignedClaims(token)
                    .getPayload();
        } catch (Exception e) {
            log.error("Failed to extract claims from token: {}", e.getMessage());
            throw new JwtException("Claims extraction failed: " + e.getMessage());
        }
    }

    /**
     * Get token expiration date.
     * 
     * @param token the JWT token
     * @return expiration date
     */
    public Date getExpirationDateFromToken(String token) {
        try {
            Claims claims = getAllClaimsFromToken(token);
            return claims.getExpiration();
        } catch (Exception e) {
            log.error("Failed to get expiration date from token: {}", e.getMessage());
            throw new JwtException("Expiration date extraction failed: " + e.getMessage());
        }
    }

    /**
     * Get token issued date.
     * 
     * @param token the JWT token
     * @return issued date
     */
    public Date getIssuedDateFromToken(String token) {
        try {
            Claims claims = getAllClaimsFromToken(token);
            return claims.getIssuedAt();
        } catch (Exception e) {
            log.error("Failed to get issued date from token: {}", e.getMessage());
            throw new JwtException("Issued date extraction failed: " + e.getMessage());
        }
    }

    /**
     * Check if token can be refreshed.
     * 
     * @param token the JWT token
     * @return true if token can be refreshed, false otherwise
     */
    public boolean canTokenBeRefreshed(String token) {
        try {
            Claims claims = getAllClaimsFromToken(token);
            String tokenType = (String) claims.get("tokenType");
            
            // Only refresh tokens can be used for refreshing
            if (!"refresh".equals(tokenType)) {
                return false;
            }
            
            // Check if token is not expired beyond refresh threshold
            Date expiration = claims.getExpiration();
            Date now = new Date();
            
            // Allow refresh if token expired within last 7 days
            long refreshThreshold = 7 * 24 * 60 * 60 * 1000L; // 7 days in milliseconds
            return (now.getTime() - expiration.getTime()) < refreshThreshold;
            
        } catch (Exception e) {
            log.error("Error checking if token can be refreshed: {}", e.getMessage());
            return false;
        }
    }

    /**
     * Validate refresh token specifically.
     * 
     * @param token the refresh token
     * @return true if refresh token is valid, false otherwise
     */
    public boolean validateRefreshToken(String token) {
        try {
            if (!validateToken(token)) {
                return false;
            }
            
            Claims claims = getAllClaimsFromToken(token);
            String tokenType = (String) claims.get("tokenType");
            
            return "refresh".equals(tokenType);
            
        } catch (Exception e) {
            log.error("Refresh token validation failed: {}", e.getMessage());
            return false;
        }
    }

    /**
     * Get comprehensive token information for debugging.
     * 
     * @param token the JWT token
     * @return map containing detailed token information
     */
    public Map<String, Object> getTokenInfo(String token) {
        Map<String, Object> info = new HashMap<>();
        
        try {
            Claims claims = getAllClaimsFromToken(token);
            
            info.put("subject", claims.getSubject());
            info.put("issuedAt", claims.getIssuedAt());
            info.put("expiration", claims.getExpiration());
            info.put("isExpired", isTokenExpired(token));
            info.put("roles", getRolesFromToken(token));
            info.put("tokenType", claims.get("tokenType"));
            info.put("canRefresh", canTokenBeRefreshed(token));
            info.put("valid", validateToken(token));
            
            // Calculate remaining time
            Date expiration = claims.getExpiration();
            long remainingTime = expiration.getTime() - System.currentTimeMillis();
            info.put("remainingTimeMs", Math.max(0, remainingTime));
            info.put("remainingTimeMinutes", Math.max(0, remainingTime / (1000 * 60)));
            
        } catch (Exception e) {
            info.put("error", "Failed to parse token: " + e.getMessage());
            info.put("valid", false);
        }
        
        return info;
    }

    /**
     * Create JWT token with specified claims, subject, and expiration.
     * 
     * @param claims additional claims to include
     * @param subject token subject (username)
     * @param expiration expiration time in milliseconds
     * @return JWT token string
     */
    private String createToken(Map<String, Object> claims, String subject, long expiration) {
        Date now = new Date();
        Date expiryDate = new Date(now.getTime() + expiration);
        
        return Jwts.builder()
                .claims(claims)
                .subject(subject)
                .issuedAt(now)
                .expiration(expiryDate)
                .signWith(getSignInKey(), Jwts.SIG.HS512)
                .compact();
    }

    /**
     * Get the signing key for JWT operations.
     * 
     * @return SecretKey for token signing and validation
     */
    private SecretKey getSignInKey() {
        try {
            byte[] keyBytes = Decoders.BASE64.decode(jwtSecret);
            return Keys.hmacShaKeyFor(keyBytes);
        } catch (Exception e) {
            log.error("Failed to create signing key: {}", e.getMessage());
            throw new RuntimeException("JWT signing key creation failed", e);
        }
    }

    /**
     * Validate the JWT secret key configuration.
     * 
     * @return true if secret key is properly configured
     */
    public boolean isSecretKeyValid() {
        try {
            return jwtSecret != null && 
                   jwtSecret.length() >= 32 && // Minimum length for HS512
                   !jwtSecret.trim().isEmpty();
        } catch (Exception e) {
            log.error("Secret key validation failed: {}", e.getMessage());
            return false;
        }
    }

    /**
     * Get JWT configuration information.
     * 
     * @return map containing JWT configuration details
     */
    public Map<String, Object> getJwtConfig() {
        Map<String, Object> config = new HashMap<>();
        config.put("jwtExpirationMs", jwtExpirationMs);
        config.put("refreshTokenExpirationMs", refreshTokenExpirationMs);
        config.put("jwtExpirationHours", jwtExpirationMs / (1000 * 60 * 60));
        config.put("refreshTokenExpirationDays", refreshTokenExpirationMs / (1000 * 60 * 60 * 24));
        config.put("secretKeyValid", isSecretKeyValid());
        config.put("algorithm", "HS512");
        return config;
    }
}