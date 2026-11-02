package com.netbrew.backend.dto.response;

import com.netbrew.backend.model.entity.User;
import com.netbrew.backend.model.enums.Role;

import java.time.Instant;

public record UserResponse(Long id, String fullName, String phone, String email, Role role, Instant createdAt) {
    public static UserResponse from(User user) {
        return new UserResponse(
                user.getId(),
                user.getFullName(),
                user.getPhone(),
                user.getEmail(),
                user.getRole(),
                user.getCreatedAt()
        );
    }
}
