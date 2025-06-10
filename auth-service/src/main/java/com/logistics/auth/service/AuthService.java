package com.logistics.auth.service;

import com.logistics.auth.dto.*;
import com.logistics.auth.entity.Role;
import com.logistics.auth.entity.User;
import com.logistics.auth.repository.RoleRepository;
import com.logistics.auth.repository.UserRepository;
import com.logistics.common.exception.BusinessException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

@Service
@Transactional
@RequiredArgsConstructor
@Slf4j
public class AuthService {

    private final AuthenticationManager authenticationManager;
    private final UserRepository userRepository;
    private final RoleRepository roleRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;

    /**
     * Authenticates user and returns JWT tokens.
     */
    public JwtResponse authenticateUser(LoginRequest loginRequest, String clientIp, String userAgent) {
        Authentication authentication = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(
                        loginRequest.getUsername(),
                        loginRequest.getPassword())
        );

        SecurityContextHolder.getContext().setAuthentication(authentication);
        String jwt = jwtService.generateJwtToken(authentication);
        String refreshToken = jwtService.generateRefreshToken(authentication.getName());

        User user = userRepository.findByUsernameOrEmail(loginRequest.getUsername())
                .orElseThrow(() -> new BusinessException("User not found"));

        // Update last login
        user.setLastLogin(LocalDateTime.now());
        userRepository.save(user);

        // Log login activity
        log.info("User {} logged in from IP: {}", user.getUsername(), clientIp);

        Set<String> roles = user.getRoles().stream()
                .map(Role::getName)
                .collect(Collectors.toSet());

        return new JwtResponse(jwt, refreshToken, user.getId(), user.getUsername(), user.getEmail(), roles);
    }

    /**
     * Registers a new user.
     */
    public void registerUser(RegisterRequest registerRequest, String clientIp) {
        if (userRepository.existsByUsername(registerRequest.getUsername())) {
            throw new BusinessException("Username is already taken!");
        }

        if (userRepository.existsByEmail(registerRequest.getEmail())) {
            throw new BusinessException("Email is already in use!");
        }

        // Create new user
        User user = new User(registerRequest.getUsername(),
                           registerRequest.getEmail(),
                           passwordEncoder.encode(registerRequest.getPassword()));

        user.setFirstName(registerRequest.getFirstName());
        user.setLastName(registerRequest.getLastName());
        user.setPhoneNumber(registerRequest.getPhoneNumber());

        // Assign default role
        Set<Role> roles = new HashSet<>();
        Role userRole = roleRepository.findByName("USER")
                .orElseThrow(() -> new BusinessException("Default role not found"));
        roles.add(userRole);
        user.setRoles(roles);

        userRepository.save(user);
        log.info("New user registered: {} from IP: {}", user.getUsername(), clientIp);
    }

    /**
     * Refreshes JWT token.
     */
    public JwtResponse refreshToken(TokenRefreshRequest request) {
        String refreshToken = request.getRefreshToken();

        if (!jwtService.validateRefreshToken(refreshToken)) {
            throw new BusinessException("Refresh token is not valid!");
        }

        String username = jwtService.getUsernameFromJwtToken(refreshToken);
        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new BusinessException("User not found"));

        // Create new authentication for token generation
        Authentication authentication = new UsernamePasswordAuthenticationToken(
                user, null, user.getAuthorities());

        String newToken = jwtService.generateJwtToken(authentication);
        String newRefreshToken = jwtService.generateRefreshToken(username);

        Set<String> roles = user.getRoles().stream()
                .map(Role::getName)
                .collect(Collectors.toSet());

        return new JwtResponse(newToken, newRefreshToken, user.getId(), user.getUsername(), user.getEmail(), roles);
    }

    /**
     * Logs out user (in a real implementation, you might blacklist the token).
     */
    public void logoutUser(String token) {
        try {
            String username = jwtService.getUsernameFromJwtToken(token);
            log.info("User {} logged out", username);
            // In a real implementation, you might want to blacklist the token
        } catch (Exception e) {
            log.warn("Logout attempt with invalid token");
        }
    }

    /**
     * Validates JWT token and returns validation response.
     */
    public TokenValidationResponse validateToken(String token) {
        try {
            if (jwtService.validateJwtToken(token)) {
                String username = jwtService.getUsernameFromJwtToken(token);
                User user = userRepository.findByUsername(username)
                        .orElseThrow(() -> new BusinessException("User not found"));

                Set<String> roles = user.getRoles().stream()
                        .map(Role::getName)
                        .collect(Collectors.toSet());

                return TokenValidationResponse.builder()
                        .valid(true)
                        .username(username)
                        .roles(roles)
                        .expired(false)
                        .message("Token is valid")
                        .build();
            } else {
                return TokenValidationResponse.builder()
                        .valid(false)
                        .expired(true)
                        .message("Token is invalid or expired")
                        .build();
            }
        } catch (Exception e) {
            return TokenValidationResponse.builder()
                    .valid(false)
                    .message("Token validation failed: " + e.getMessage())
                    .build();
        }
    }

    /**
     * Gets current user information from token.
     */
    public UserInfo getCurrentUserInfo(String token) {
        String username = jwtService.getUsernameFromJwtToken(token);
        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new BusinessException("User not found"));

        Set<String> roles = user.getRoles().stream()
                .map(Role::getName)
                .collect(Collectors.toSet());

        return UserInfo.builder()
                .id(user.getId())
                .username(user.getUsername())
                .email(user.getEmail())
                .roles(roles)
                .build();
    }

    /**
     * Changes user password.
     */
    public void changePassword(String token, ChangePasswordRequest request) {
        if (!request.getNewPassword().equals(request.getConfirmPassword())) {
            throw new BusinessException("New password and confirmation do not match");
        }

        String username = jwtService.getUsernameFromJwtToken(token);
        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new BusinessException("User not found"));

        if (!passwordEncoder.matches(request.getCurrentPassword(), user.getPassword())) {
            throw new BusinessException("Current password is incorrect");
        }

        user.setPassword(passwordEncoder.encode(request.getNewPassword()));
        userRepository.save(user);
        
        log.info("Password changed for user: {}", username);
    }

    /**
     * Initiates forgot password process.
     */
    public void initiateForgotPassword(String email) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new BusinessException("User not found with email: " + email));

        // In a real implementation, you would:
        // 1. Generate a password reset token
        // 2. Save it to database with expiration
        // 3. Send email with reset link
        
        log.info("Password reset initiated for user: {}", user.getUsername());
        // For now, just log the action
    }

    /**
     * Resets password using reset token.
     */
    public void resetPassword(ResetPasswordRequest request) {
        if (!request.getNewPassword().equals(request.getConfirmPassword())) {
            throw new BusinessException("New password and confirmation do not match");
        }

        // In a real implementation, you would:
        // 1. Validate the reset token
        // 2. Find user by token
        // 3. Update password
        // 4. Invalidate the reset token
        
        log.info("Password reset completed");
    }

    /**
     * Gets authentication statistics.
     */
    public Map<String, Object> getAuthenticationStats() {
        Map<String, Object> stats = new HashMap<>();
        stats.put("totalUsers", userRepository.count());
        stats.put("activeUsers", userRepository.findAll().stream()
                .filter(User::isEnabled)
                .count());
        stats.put("timestamp", System.currentTimeMillis());
        return stats;
    }
}