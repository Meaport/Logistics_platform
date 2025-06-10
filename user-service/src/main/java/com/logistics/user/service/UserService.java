package com.logistics.user.service;

import com.logistics.common.exception.BusinessException;
import com.logistics.common.exception.ResourceNotFoundException;
import com.logistics.user.dto.UserDto;
import com.logistics.user.entity.UserProfile;
import com.logistics.user.repository.UserProfileRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

/**
 * Service class for basic user operations.
 * Provides standard CRUD operations for users.
 * 
 * @author Logistics Platform Team
 * @version 1.0.0
 */
@Service
@RequiredArgsConstructor
@Slf4j
@Transactional
public class UserService {

    private final UserProfileRepository userProfileRepository;
    private final UserActivityService userActivityService;

    /**
     * Get all users.
     * 
     * @return list of all users
     */
    public List<UserDto> getAllUsers() {
        log.debug("Fetching all users");
        return userProfileRepository.findAll().stream()
                .map(this::convertToDto)
                .collect(Collectors.toList());
    }

    /**
     * Get user by ID.
     * 
     * @param id the user ID
     * @return user data
     * @throws ResourceNotFoundException if user not found
     */
    public UserDto getUserById(Long id) {
        log.debug("Fetching user by ID: {}", id);
        UserProfile userProfile = userProfileRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("User not found with id: " + id));
        return convertToDto(userProfile);
    }

    /**
     * Create a new user.
     * 
     * @param userDto the user data
     * @return created user
     * @throws BusinessException if user already exists
     */
    public UserDto createUser(UserDto userDto) {
        log.debug("Creating new user: {}", userDto.getUsername());
        
        // Validate uniqueness
        if (userProfileRepository.existsByUsername(userDto.getUsername())) {
            throw new BusinessException("Username already exists: " + userDto.getUsername());
        }
        
        if (userProfileRepository.existsByEmail(userDto.getEmail())) {
            throw new BusinessException("Email already exists: " + userDto.getEmail());
        }
        
        if (userDto.getAuthUserId() != null && userProfileRepository.existsByAuthUserId(userDto.getAuthUserId())) {
            throw new BusinessException("User profile already exists for auth user ID: " + userDto.getAuthUserId());
        }

        UserProfile userProfile = new UserProfile();
        userProfile.setAuthUserId(userDto.getAuthUserId());
        userProfile.setUsername(userDto.getUsername());
        userProfile.setEmail(userDto.getEmail());
        userProfile.setFirstName(userDto.getFirstName());
        userProfile.setLastName(userDto.getLastName());
        userProfile.setPhoneNumber(userDto.getPhoneNumber());
        userProfile.setCompany(userDto.getCompany());
        userProfile.setPosition(userDto.getPosition());
        userProfile.setStatus(userDto.getStatus() != null ? userDto.getStatus() : UserProfile.UserStatus.ACTIVE);

        UserProfile savedProfile = userProfileRepository.save(userProfile);
        
        // Log activity
        userActivityService.logActivity(savedProfile.getId(), 
                com.logistics.user.entity.UserActivity.ActivityType.PROFILE_UPDATE, 
                "User profile created via UserController");

        log.info("User created successfully: {}", savedProfile.getUsername());
        return convertToDto(savedProfile);
    }

    /**
     * Update existing user.
     * 
     * @param id the user ID
     * @param userDto the updated user data
     * @return updated user
     * @throws ResourceNotFoundException if user not found
     * @throws BusinessException if validation fails
     */
    public UserDto updateUser(Long id, UserDto userDto) {
        log.debug("Updating user with ID: {}", id);
        
        UserProfile userProfile = userProfileRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("User not found with id: " + id));

        // Check email uniqueness if changed
        if (userDto.getEmail() != null && !userDto.getEmail().equals(userProfile.getEmail())) {
            if (userProfileRepository.existsByEmail(userDto.getEmail())) {
                throw new BusinessException("Email already exists: " + userDto.getEmail());
            }
            userProfile.setEmail(userDto.getEmail());
        }

        // Check username uniqueness if changed
        if (userDto.getUsername() != null && !userDto.getUsername().equals(userProfile.getUsername())) {
            if (userProfileRepository.existsByUsername(userDto.getUsername())) {
                throw new BusinessException("Username already exists: " + userDto.getUsername());
            }
            userProfile.setUsername(userDto.getUsername());
        }

        // Update other fields if provided
        if (userDto.getFirstName() != null) userProfile.setFirstName(userDto.getFirstName());
        if (userDto.getLastName() != null) userProfile.setLastName(userDto.getLastName());
        if (userDto.getPhoneNumber() != null) userProfile.setPhoneNumber(userDto.getPhoneNumber());
        if (userDto.getCompany() != null) userProfile.setCompany(userDto.getCompany());
        if (userDto.getPosition() != null) userProfile.setPosition(userDto.getPosition());
        if (userDto.getStatus() != null) userProfile.setStatus(userDto.getStatus());

        UserProfile updatedProfile = userProfileRepository.save(userProfile);
        
        // Log activity
        userActivityService.logActivity(updatedProfile.getId(), 
                com.logistics.user.entity.UserActivity.ActivityType.PROFILE_UPDATE, 
                "User profile updated via UserController");

        log.info("User updated successfully: {}", updatedProfile.getUsername());
        return convertToDto(updatedProfile);
    }

    /**
     * Delete user by ID.
     * 
     * @param id the user ID
     * @throws ResourceNotFoundException if user not found
     */
    public void deleteUser(Long id) {
        log.debug("Deleting user with ID: {}", id);
        
        UserProfile userProfile = userProfileRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("User not found with id: " + id));
        
        userProfileRepository.delete(userProfile);
        log.info("User deleted successfully: {}", userProfile.getUsername());
    }

    /**
     * Check if the given user ID belongs to the current authenticated user.
     * Used for security authorization.
     * 
     * @param userId the user ID to check
     * @return true if current user, false otherwise
     */
    public boolean isCurrentUser(Long userId) {
        try {
            String currentUsername = SecurityContextHolder.getContext().getAuthentication().getName();
            UserProfile userProfile = userProfileRepository.findById(userId).orElse(null);
            return userProfile != null && userProfile.getUsername().equals(currentUsername);
        } catch (Exception e) {
            log.warn("Error checking current user: {}", e.getMessage());
            return false;
        }
    }

    /**
     * Convert UserProfile entity to UserDto.
     * 
     * @param userProfile the entity to convert
     * @return converted DTO
     */
    private UserDto convertToDto(UserProfile userProfile) {
        UserDto dto = new UserDto();
        dto.setId(userProfile.getId());
        dto.setAuthUserId(userProfile.getAuthUserId());
        dto.setUsername(userProfile.getUsername());
        dto.setEmail(userProfile.getEmail());
        dto.setFirstName(userProfile.getFirstName());
        dto.setLastName(userProfile.getLastName());
        dto.setPhoneNumber(userProfile.getPhoneNumber());
        dto.setCompany(userProfile.getCompany());
        dto.setPosition(userProfile.getPosition());
        dto.setStatus(userProfile.getStatus());
        dto.setEmailVerified(userProfile.isEmailVerified());
        dto.setLastLogin(userProfile.getLastLogin());
        dto.setCreatedAt(userProfile.getCreatedAt());
        dto.setUpdatedAt(userProfile.getUpdatedAt());
        return dto;
    }
}