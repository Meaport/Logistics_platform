package com.logistics.user.controller;

import com.logistics.common.dto.BaseResponse;
import com.logistics.user.dto.CreateUserProfileRequest;
import com.logistics.user.dto.UpdateUserProfileRequest;
import com.logistics.user.dto.UserProfileDto;
import com.logistics.user.entity.UserProfile;
import com.logistics.user.service.UserProfileService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/users")
@RequiredArgsConstructor
@CrossOrigin(origins = "*", maxAge = 3600)
public class UserProfileController {

    private final UserProfileService userProfileService;

    @GetMapping
    public ResponseEntity<BaseResponse<Page<UserProfileDto>>> getAllUsers(
            @PageableDefault(size = 20) Pageable pageable) {
        Page<UserProfileDto> users = userProfileService.getAllUsers(pageable);
        return ResponseEntity.ok(BaseResponse.success(users, "Users retrieved successfully"));
    }

    @GetMapping("/profile")
    public ResponseEntity<BaseResponse<UserProfileDto>> getCurrentUserProfile() {
        UserProfileDto userProfile = userProfileService.getCurrentUserProfile();
        return ResponseEntity.ok(BaseResponse.success(userProfile, "User profile retrieved successfully"));
    }

    @GetMapping("/{username}")
    public ResponseEntity<BaseResponse<UserProfileDto>> getUserByUsername(@PathVariable String username) {
        UserProfileDto userProfile = userProfileService.getUserByUsername(username);
        return ResponseEntity.ok(BaseResponse.success(userProfile, "User retrieved successfully"));
    }

    @GetMapping("/auth/{authUserId}")
    public ResponseEntity<BaseResponse<UserProfileDto>> getUserByAuthUserId(@PathVariable Long authUserId) {
        UserProfileDto userProfile = userProfileService.getUserByAuthUserId(authUserId);
        return ResponseEntity.ok(BaseResponse.success(userProfile, "User retrieved successfully"));
    }

    @PostMapping
    public ResponseEntity<BaseResponse<UserProfileDto>> createUserProfile(
            @Valid @RequestBody CreateUserProfileRequest request) {
        UserProfileDto userProfile = userProfileService.createUserProfile(request);
        return ResponseEntity.ok(BaseResponse.success(userProfile, "User profile created successfully"));
    }

    @PutMapping("/{username}")
    public ResponseEntity<BaseResponse<UserProfileDto>> updateUserProfile(
            @PathVariable String username,
            @Valid @RequestBody UpdateUserProfileRequest request) {
        UserProfileDto userProfile = userProfileService.updateUserProfile(username, request);
        return ResponseEntity.ok(BaseResponse.success(userProfile, "User profile updated successfully"));
    }

    @DeleteMapping("/{username}")
    public ResponseEntity<BaseResponse<Void>> deleteUserProfile(@PathVariable String username) {
        userProfileService.deleteUserProfile(username);
        return ResponseEntity.ok(BaseResponse.success(null, "User profile deleted successfully"));
    }

    @GetMapping("/search")
    public ResponseEntity<BaseResponse<Page<UserProfileDto>>> searchUsers(
            @RequestParam String q,
            @PageableDefault(size = 20) Pageable pageable) {
        Page<UserProfileDto> users = userProfileService.searchUsers(q, pageable);
        return ResponseEntity.ok(BaseResponse.success(users, "Search completed successfully"));
    }

    @GetMapping("/status/{status}")
    public ResponseEntity<BaseResponse<Page<UserProfileDto>>> getUsersByStatus(
            @PathVariable UserProfile.UserStatus status,
            @PageableDefault(size = 20) Pageable pageable) {
        Page<UserProfileDto> users = userProfileService.getUsersByStatus(status, pageable);
        return ResponseEntity.ok(BaseResponse.success(users, "Users retrieved successfully"));
    }

    @PatchMapping("/{username}/status")
    public ResponseEntity<BaseResponse<UserProfileDto>> updateUserStatus(
            @PathVariable String username,
            @RequestParam UserProfile.UserStatus status) {
        UserProfileDto userProfile = userProfileService.updateUserStatus(username, status);
        return ResponseEntity.ok(BaseResponse.success(userProfile, "User status updated successfully"));
    }

    @PostMapping("/{username}/last-login")
    public ResponseEntity<BaseResponse<Void>> updateLastLogin(@PathVariable String username) {
        userProfileService.updateLastLogin(username);
        return ResponseEntity.ok(BaseResponse.success(null, "Last login updated successfully"));
    }
}