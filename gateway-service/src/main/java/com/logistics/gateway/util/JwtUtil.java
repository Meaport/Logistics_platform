package com.logistics.gateway.util;

import io.jsonwebtoken.*;
import io.jsonwebtoken.io.Decoders;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import javax.crypto.SecretKey;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Utility class for generating and validating JWT tokens.
 * This class provides comprehensive JWT operations including token generation,
 * validation, and claims extraction for the API Gateway.
 * 
 * @author Logistics Platform Team
 * @version 1.0.0
 */
@Component
public class JwtUtil {

    /**
     * Secret key for signing JWT tokens
     */
    @Value("${jwt.secret}")
    private String secretKey;

    /**
     * JWT token expiration time in milliseconds
     */
    @Value("${jwt.expiration:86400000}") // Default: 24 hours
    private long jwtExpiration;

    /**
     * Parser for JWT tokens - initialized lazily for performance
     */
    private JwtParser jwtParser;

    /**
     * Generates a JWT token with claims and subject.
     * 
     * This method creates a new JWT token with the provided username as subject
     * and additional claims. The token is signed with the configured secret key
     * and includes standard claims like issued date and expiration.
     * 
     * @param username the username to set as token subject
     * @param claims additional claims to include in the token
     * @return generated JWT token as string
     * @throws RuntimeException if token generation fails
     */
    public String generateToken(String username, Map<String, Object> claims) {
        try {
            if (claims == null) {
                claims = new HashMap<>();
            }
            
            Date now = new Date();
            Date expiryDate = new Date(now.getTime() + jwtExpiration);
            
            return Jwts.builder()
                    .claims(claims)
                    .subject(username)
                    .issuedAt(now)
                    .expiration(expiryDate)
                    .signWith(getSignInKey(), Jwts.SIG.HS512)
                    .compact();
                    
        } catch (Exception e) {
            throw new RuntimeException("Failed to generate JWT token", e);
        }
    }

    /**
     * Generates a JWT token with username only (no additional claims).
     * 
     * @param username the username to set as token subject
     * @return generated JWT token as string
     */
    public String generateToken(String username) {
        return generateToken(username, new HashMap<>());
    }

    /**
     * Validates the JWT token.
     * 
     * This method performs comprehensive validation including:
     * - Token signature verification
     * - Expiration date check
     * - Token format validation
     * - Claims structure validation
     * 
     * @param token the JWT token to validate
     * @return true if token is valid, false otherwise
     */
    public boolean validateToken(String token) {
        try {
            getJwtParser().parseSignedClaims(token);
            return true;
        } catch (MalformedJwtException e) {
            System.err.println("Invalid JWT token format: " + e.getMessage());
        } catch (ExpiredJwtException e) {
            System.err.println("JWT token is expired: " + e.getMessage());
        } catch (UnsupportedJwtException e) {
            System.err.println("JWT token is unsupported: " + e.getMessage());
        } catch (IllegalArgumentException e) {
            System.err.println("JWT claims string is empty: " + e.getMessage());
        } catch (SecurityException e) {
            System.err.println("JWT signature validation failed: " + e.getMessage());
        } catch (Exception e) {
            System.err.println("JWT token validation error: " + e.getMessage());
        }
        return false;
    }

    /**
     * Extracts username from JWT token.
     * 
     * @param token the JWT token
     * @return the username (subject) from the token
     * @throws JwtException if token is invalid or expired
     */
    public String getUsernameFromToken(String token) {
        try {
            Claims claims = getJwtParser()
                    .parseSignedClaims(token)
                    .getPayload();
            return claims.getSubject();
        } catch (Exception e) {
            throw new JwtException("Failed to extract username from token: " + e.getMessage());
        }
    }

    /**
     * Extracts user roles from JWT token.
     * 
     * @param token the JWT token
     * @return list of user roles, empty list if no roles found
     */
    @SuppressWarnings("unchecked")
    public List<String> getRolesFromToken(String token) {
        try {
            Claims claims = getJwtParser()
                    .parseSignedClaims(token)
                    .getPayload();
            
            Object rolesObj = claims.get("roles");
            if (rolesObj instanceof List) {
                return (List<String>) rolesObj;
            }
            return List.of(); // Return empty list if no roles
        } catch (Exception e) {
            System.err.println("Failed to extract roles from token: " + e.getMessage());
            return List.of();
        }
    }

    /**
     * Extracts expiration date from JWT token.
     * 
     * @param token the JWT token
     * @return expiration date
     * @throws JwtException if token is invalid
     */
    public Date getExpirationDateFromToken(String token) {
        try {
            Claims claims = getJwtParser()
                    .parseSignedClaims(token)
                    .getPayload();
            return claims.getExpiration();
        } catch (Exception e) {
            throw new JwtException("Failed to extract expiration date from token: " + e.getMessage());
        }
    }

    /**
     * Extracts issued date from JWT token.
     * 
     * @param token the JWT token
     * @return issued date
     * @throws JwtException if token is invalid
     */
    public Date getIssuedDateFromToken(String token) {
        try {
            Claims claims = getJwtParser()
                    .parseSignedClaims(token)
                    .getPayload();
            return claims.getIssuedAt();
        } catch (Exception e) {
            throw new JwtException("Failed to extract issued date from token: " + e.getMessage());
        }
    }

    /**
     * Checks if JWT token is expired.
     * 
     * @param token the JWT token
     * @return true if token is expired, false otherwise
     */
    public boolean isTokenExpired(String token) {
        try {
            Date expiration = getExpirationDateFromToken(token);
            return expiration.before(new Date());
        } catch (Exception e) {
            return true; // Consider invalid tokens as expired
        }
    }

    /**
     * Extracts all claims from JWT token.
     * 
     * @param token the JWT token
     * @return Claims object containing all token claims
     * @throws JwtException if token is invalid
     */
    public Claims getAllClaimsFromToken(String token) {
        try {
            return getJwtParser()
                    .parseSignedClaims(token)
                    .getPayload();
        } catch (Exception e) {
            throw new JwtException("Failed to extract claims from token: " + e.getMessage());
        }
    }

    /**
     * Extracts a specific claim from JWT token.
     * 
     * @param token the JWT token
     * @param claimName the name of the claim to extract
     * @return the claim value, null if not found
     */
    public Object getClaimFromToken(String token, String claimName) {
        try {
            Claims claims = getAllClaimsFromToken(token);
            return claims.get(claimName);
        } catch (Exception e) {
            System.err.println("Failed to extract claim '" + claimName + "' from token: " + e.getMessage());
            return null;
        }
    }

    /**
     * Checks if token can be refreshed (not expired beyond refresh threshold).
     * 
     * @param token the JWT token
     * @return true if token can be refreshed, false otherwise
     */
    public boolean canTokenBeRefreshed(String token) {
        try {
            Date expiration = getExpirationDateFromToken(token);
            Date now = new Date();
            
            // Allow refresh if token expired within last hour
            long refreshThreshold = 3600000; // 1 hour in milliseconds
            return (now.getTime() - expiration.getTime()) < refreshThreshold;
        } catch (Exception e) {
            return false;
        }
    }

    /**
     * Refreshes JWT token with new expiration time.
     * 
     * @param token the existing JWT token
     * @return new JWT token with extended expiration
     * @throws JwtException if token cannot be refreshed
     */
    public String refreshToken(String token) {
        try {
            Claims claims = getAllClaimsFromToken(token);
            String username = claims.getSubject();
            
            // Create new claims map excluding standard claims
            Map<String, Object> newClaims = new HashMap<>();
            claims.forEach((key, value) -> {
                if (!key.equals("sub") && !key.equals("iat") && !key.equals("exp")) {
                    newClaims.put(key, value);
                }
            });
            
            return generateToken(username, newClaims);
        } catch (Exception e) {
            throw new JwtException("Failed to refresh token: " + e.getMessage());
        }
    }

    /**
     * Gets the JWT parser instance, creating it if necessary.
     * 
     * @return configured JWT parser
     */
    private JwtParser getJwtParser() {
        if (jwtParser == null) {
            jwtParser = Jwts.parser()
                    .verifyWith(getSignInKey())
                    .build();
        }
        return jwtParser;
    }

    /**
     * Gets the signing key for JWT token operations.
     * 
     * @return SecretKey for token signing and validation
     */
    private SecretKey getSignInKey() {
        try {
            byte[] keyBytes = Decoders.BASE64.decode(secretKey);
            return Keys.hmacShaKeyFor(keyBytes);
        } catch (Exception e) {
            throw new RuntimeException("Failed to create signing key: " + e.getMessage());
        }
    }

    /**
     * Validates the secret key configuration.
     * 
     * @return true if secret key is properly configured
     */
    public boolean isSecretKeyValid() {
        try {
            return secretKey != null && 
                   secretKey.length() >= 32 && // Minimum length for HS512
                   !secretKey.trim().isEmpty();
        } catch (Exception e) {
            return false;
        }
    }

    /**
     * Gets token information for debugging purposes.
     * 
     * @param token the JWT token
     * @return map containing token information
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
            info.put("canRefresh", canTokenBeRefreshed(token));
        } catch (Exception e) {
            info.put("error", "Failed to parse token: " + e.getMessage());
        }
        return info;
    }
}