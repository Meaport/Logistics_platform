package com.logistics.user.service;

import com.logistics.user.dto.UserActivityDto;
import com.logistics.user.entity.UserActivity;
import com.logistics.user.repository.UserActivityRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
@Slf4j
@Transactional
public class UserActivityService {

    private final UserActivityRepository userActivityRepository;

    @PreAuthorize("hasRole('ADMIN') or hasRole('MANAGER')")
    public Page<UserActivityDto> getUserActivities(Long userId, Pageable pageable) {
        return userActivityRepository.findByUserIdOrderByCreatedAtDesc(userId, pageable)
                .map(this::convertToDto);
    }

    public void logActivity(Long userId, UserActivity.ActivityType activityType, String description) {
        logActivity(userId, activityType, description, null, null);
    }

    public void logActivity(Long userId, UserActivity.ActivityType activityType, String description, 
                          String ipAddress, String userAgent) {
        UserActivity activity = new UserActivity();
        activity.setUserId(userId);
        activity.setActivityType(activityType);
        activity.setDescription(description);
        activity.setIpAddress(ipAddress);
        activity.setUserAgent(userAgent);
        
        userActivityRepository.save(activity);
        log.debug("Activity logged for user {}: {} - {}", userId, activityType, description);
    }

    @PreAuthorize("hasRole('ADMIN')")
    public Long getActivityCount(Long userId, UserActivity.ActivityType activityType) {
        return userActivityRepository.countByUserIdAndActivityType(userId, activityType);
    }

    private UserActivityDto convertToDto(UserActivity activity) {
        UserActivityDto dto = new UserActivityDto();
        dto.setId(activity.getId());
        dto.setUserId(activity.getUserId());
        dto.setActivityType(activity.getActivityType());
        dto.setDescription(activity.getDescription());
        dto.setIpAddress(activity.getIpAddress());
        dto.setUserAgent(activity.getUserAgent());
        dto.setCreatedAt(activity.getCreatedAt());
        return dto;
    }
}