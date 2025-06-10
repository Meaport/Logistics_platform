package com.logistics.user.dto;

import com.logistics.user.entity.UserProfile;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class CreateUserProfileRequest {
    
    @NotNull(message = "Auth user ID is required")
    private Long authUserId;
    
    @NotBlank(message = "Username is required")
    private String username;
    
    @NotBlank(message = "Email is required")
    @Email(message = "Email should be valid")
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
    private UserProfile.Language language;
    private String timezone;
}