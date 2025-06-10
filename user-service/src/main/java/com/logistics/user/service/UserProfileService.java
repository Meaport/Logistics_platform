package com.logistics.user.service;

import com.logistics.common.exception.BusinessException;
import com.logistics.common.exception.ResourceNotFoundException;
import com.logistics.user.dto.CreateUserProfileRequest;
import com.logistics.user.dto.UpdateUserProfileRequest;
import com.logistics.user.dto.UserProfileDto;
import com.logistics.user.entity.UserProfile;
import com.logistics.user.repository.UserProfileRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
@Slf4j
@Transactional
public class UserProfileService {

    private final UserProfileRepository userProfileRepository;
    private final UserActivityService userActivityService;

    @PreAuthorize("hasRole('ADMIN') or hasRole('MANAGER')")
    public Page<UserProfileDto> getAllUsers(Pageable pageable) {
        return userProfileRepository.findAll(pageable)
                .map(this::convertToDto);
    }

    @PreAuthorize("hasRole('ADMIN') or hasRole('MANAGER') or authentication.name == #username")
    public UserProfileDto getUserByUsername(String username) {
        UserProfile userProfile = userProfileRepository.findByUsername(username)
                .orElseThrow(() -> new ResourceNotFoundException("User not found with username: " + username));
        return convertToDto(userProfile);
    }

    public UserProfileDto getUserByAuthUserId(Long authUserId) {
        UserProfile userProfile = userProfileRepository.findByAuthUserId(authUserId)
                .orElseThrow(() -> new ResourceNotFoundException("User profile not found for auth user ID: " + authUserId));
        return convertToDto(userProfile);
    }

    public UserProfileDto getCurrentUserProfile() {
        String currentUsername = SecurityContextHolder.getContext().getAuthentication().getName();
        return getUserByUsername(currentUsername);
    }

    public UserProfileDto createUserProfile(CreateUserProfileRequest request) {
        // Check if profile already exists
        if (userProfileRepository.existsByAuthUserId(request.getAuthUserId())) {
            throw new BusinessException("User profile already exists for auth user ID: " + request.getAuthUserId());
        }

        if (userProfileRepository.existsByUsername(request.getUsername())) {
            throw new BusinessException("Username is already taken: " + request.getUsername());
        }

        if (userProfileRepository.existsByEmail(request.getEmail())) {
            throw new BusinessException("Email is already in use: " + request.getEmail());
        }

        UserProfile userProfile = new UserProfile();
        userProfile.setAuthUserId(request.getAuthUserId());
        userProfile.setUsername(request.getUsername());
        userProfile.setEmail(request.getEmail());
        userProfile.setFirstName(request.getFirstName());
        userProfile.setLastName(request.getLastName());
        userProfile.setPhoneNumber(request.getPhoneNumber());
        userProfile.setProfilePictureUrl(request.getProfilePictureUrl());
        userProfile.setBio(request.getBio());
        userProfile.setCompany(request.getCompany());
        userProfile.setDepartment(request.getDepartment());
        userProfile.setPosition(request.getPosition());
        userProfile.setAddress(request.getAddress());
        userProfile.setCity(request.getCity());
        userProfile.setCountry(request.getCountry());
        userProfile.setPostalCode(request.getPostalCode());
        userProfile.setDateOfBirth(request.getDateOfBirth());
        userProfile.setLanguage(request.getLanguage() != null ? request.getLanguage() : UserProfile.Language.EN);
        userProfile.setTimezone(request.getTimezone() != null ? request.getTimezone() : "UTC");

        UserProfile savedProfile = userProfileRepository.save(userProfile);
        
        // Log activity
        userActivityService.logActivity(savedProfile.getId(), 
                com.logistics.user.entity.UserActivity.ActivityType.PROFILE_UPDATE, 
                "User profile created");

        return convertToDto(savedProfile);
    }

    @PreAuthorize("hasRole('ADMIN') or authentication.name == #username")
    public UserProfileDto updateUserProfile(String username, UpdateUserProfileRequest request) {
        UserProfile userProfile = userProfileRepository.findByUsername(username)
                .orElseThrow(() -> new ResourceNotFoundException("User not found with username: " + username));

        // Check email uniqueness if changed
        if (request.getEmail() != null && !request.getEmail().equals(userProfile.getEmail())) {
            if (userProfileRepository.existsByEmail(request.getEmail())) {
                throw new BusinessException("Email is already in use: " + request.getEmail());
            }
            userProfile.setEmail(request.getEmail());
        }

        // Update fields if provided
        if (request.getFirstName() != null) userProfile.setFirstName(request.getFirstName());
        if (request.getLastName() != null) userProfile.setLastName(request.getLastName());
        if (request.getPhoneNumber() != null) userProfile.setPhoneNumber(request.getPhoneNumber());
        if (request.getProfilePictureUrl() != null) userProfile.setProfilePictureUrl(request.getProfilePictureUrl());
        if (request.getBio() != null) userProfile.setBio(request.getBio());
        if (request.getCompany() != null) userProfile.setCompany(request.getCompany());
        if (request.getDepartment() != null) userProfile.setDepartment(request.getDepartment());
        if (request.getPosition() != null) userProfile.setPosition(request.getPosition());
        if (request.getAddress() != null) userProfile.setAddress(request.getAddress());
        if (request.getCity() != null) userProfile.setCity(request.getCity());
        if (request.getCountry() != null) userProfile.setCountry(request.getCountry());
        if (request.getPostalCode() != null) userProfile.setPostalCode(request.getPostalCode());
        if (request.getDateOfBirth() != null) userProfile.setDateOfBirth(request.getDateOfBirth());
        if (request.getLanguage() != null) userProfile.setLanguage(request.getLanguage());
        if (request.getTimezone() != null) userProfile.setTimezone(request.getTimezone());

        UserProfile updatedProfile = userProfileRepository.save(userProfile);
        
        // Log activity
        userActivityService.logActivity(updatedProfile.getId(), 
                com.logistics.user.entity.UserActivity.ActivityType.PROFILE_UPDATE, 
                "User profile updated");

        return convertToDto(updatedProfile);
    }

    @PreAuthorize("hasRole('ADMIN')")
    public void deleteUserProfile(String username) {
        UserProfile userProfile = userProfileRepository.findByUsername(username)
                .orElseThrow(() -> new ResourceNotFoundException("User not found with username: " + username));
        
        userProfileRepository.delete(userProfile);
        log.info("User profile deleted: {}", username);
    }

    @PreAuthorize("hasRole('ADMIN') or hasRole('MANAGER')")
    public Page<UserProfileDto> searchUsers(String searchTerm, Pageable pageable) {
        return userProfileRepository.findBySearchTerm(searchTerm, pageable)
                .map(this::convertToDto);
    }

    @PreAuthorize("hasRole('ADMIN') or hasRole('MANAGER')")
    public Page<UserProfileDto> getUsersByStatus(UserProfile.UserStatus status, Pageable pageable) {
        return userProfileRepository.findByStatus(status, pageable)
                .map(this::convertToDto);
    }

    @PreAuthorize("hasRole('ADMIN')")
    public UserProfileDto updateUserStatus(String username, UserProfile.UserStatus status) {
        UserProfile userProfile = userProfileRepository.findByUsername(username)
                .orElseThrow(() -> new ResourceNotFoundException("User not found with username: " + username));
        
        userProfile.setStatus(status);
        UserProfile updatedProfile = userProfileRepository.save(userProfile);
        
        // Log activity
        userActivityService.logActivity(updatedProfile.getId(), 
                com.logistics.user.entity.UserActivity.ActivityType.ROLE_CHANGE, 
                "User status changed to: " + status);

        return convertToDto(updatedProfile);
    }

    public void updateLastLogin(String username) {
        UserProfile userProfile = userProfileRepository.findByUsername(username)
                .orElseThrow(() -> new ResourceNotFoundException("User not found with username: " + username));
        
        userProfile.setLastLogin(LocalDateTime.now());
        userProfileRepository.save(userProfile);
        
        // Log activity
        userActivityService.logActivity(userProfile.getId(), 
                com.logistics.user.entity.UserActivity.ActivityType.LOGIN, 
                "User logged in");
    }

    private UserProfileDto convertToDto(UserProfile userProfile) {
        UserProfileDto dto = new UserProfileDto();
        dto.setId(userProfile.getId());
        dto.setAuthUserId(userProfile.getAuthUserId());
        dto.setUsername(userProfile.getUsername());
        dto.setEmail(userProfile.getEmail());
        dto.setFirstName(userProfile.getFirstName());
        dto.setLastName(userProfile.getLastName());
        dto.setPhoneNumber(userProfile.getPhoneNumber());
        dto.setProfilePictureUrl(userProfile.getProfilePictureUrl());
        dto.setBio(userProfile.getBio());
        dto.setCompany(userProfile.getCompany());
        dto.setDepartment(userProfile.getDepartment());
        dto.setPosition(userProfile.getPosition());
        dto.setAddress(userProfile.getAddress());
        dto.setCity(userProfile.getCity());
        dto.setCountry(userProfile.getCountry());
        dto.setPostalCode(userProfile.getPostalCode());
        dto.setDateOfBirth(userProfile.getDateOfBirth());
        dto.setStatus(userProfile.getStatus());
        dto.setLanguage(userProfile.getLanguage());
        dto.setTimezone(userProfile.getTimezone());
        dto.setEmailVerified(userProfile.isEmailVerified());
        dto.setPhoneVerified(userProfile.isPhoneVerified());
        dto.setLastLogin(userProfile.getLastLogin());
        dto.setCreatedAt(userProfile.getCreatedAt());
        dto.setUpdatedAt(userProfile.getUpdatedAt());
        return dto;
    }
}