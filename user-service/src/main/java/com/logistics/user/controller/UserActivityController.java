package com.logistics.user.controller;

import com.logistics.common.dto.BaseResponse;
import com.logistics.user.dto.UserActivityDto;
import com.logistics.user.service.UserActivityService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/users/{userId}/activities")
@RequiredArgsConstructor
@CrossOrigin(origins = "*", maxAge = 3600)
public class UserActivityController {

    private final UserActivityService userActivityService;

    @GetMapping
    public ResponseEntity<BaseResponse<Page<UserActivityDto>>> getUserActivities(
            @PathVariable Long userId,
            @PageableDefault(size = 20) Pageable pageable) {
        Page<UserActivityDto> activities = userActivityService.getUserActivities(userId, pageable);
        return ResponseEntity.ok(BaseResponse.success(activities, "User activities retrieved successfully"));
    }
}