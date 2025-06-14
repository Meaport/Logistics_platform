package com.logistics.user.mapper;

import com.logistics.user.dto.UserDto;
import com.logistics.user.dto.UserProfileDto;
import com.logistics.user.entity.UserProfile;
import org.mapstruct.Mapper;
import org.mapstruct.factory.Mappers;

@Mapper(componentModel = "spring")
public interface UserMapper {
    
    UserMapper INSTANCE = Mappers.getMapper(UserMapper.class);
    
    UserDto userProfileToUserDto(UserProfile userProfile);
    UserProfileDto userProfileToUserProfileDto(UserProfile userProfile);
}
