package com.logistics.user.dto;

import com.logistics.user.entity.UserActivity;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class UserActivityDto {
    private Long id;
    private Long userId;
    private UserActivity.ActivityType activityType;
    private String description;
    private String ipAddress;
    private String userAgent;
    private LocalDateTime createdAt;
}