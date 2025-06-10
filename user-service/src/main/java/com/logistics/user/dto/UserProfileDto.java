package com.logistics.user.dto;

import com.logistics.user.entity.UserProfile;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class UserProfileDto {
    private Long id;
    private Long authUserId;
    private String username;
    private String email;
    private String firstName;
    private String lastName;
    private String phoneNumber;
    private String profilePictureUrl;
    private String bio;
    private String company;
    private String department;
    private String position;
    private String address;
    private String city;
    private String country;
    private String postalCode;
    private LocalDateTime dateOfBirth;
    private UserProfile.UserStatus status;
    private UserProfile.Language language;
    private String timezone;
    private boolean emailVerified;
    private boolean phoneVerified;
    private LocalDateTime lastLogin;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}