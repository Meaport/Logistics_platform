package com.logistics.auth.mapper;

import com.logistics.auth.dto.JwtResponse;
import com.logistics.auth.dto.UserInfo;
import com.logistics.auth.entity.Role;
import com.logistics.auth.entity.User;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.factory.Mappers;

import java.util.Set;
import java.util.stream.Collectors;

@Mapper(componentModel = "spring")
public interface AuthMapper {
    
    AuthMapper INSTANCE = Mappers.getMapper(AuthMapper.class);
    
    @Mapping(target = "roles", expression = "java(mapRolesToStrings(user.getRoles()))")
    UserInfo userToUserInfo(User user);
    
    default Set<String> mapRolesToStrings(Set<Role> roles) {
        return roles.stream()
                .map(Role::getName)
                .collect(Collectors.toSet());
    }
}
