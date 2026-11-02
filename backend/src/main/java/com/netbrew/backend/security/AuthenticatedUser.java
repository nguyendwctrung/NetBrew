package com.netbrew.backend.security;

import com.netbrew.backend.model.enums.Role;
import com.netbrew.backend.model.enums.UserStatus;

public record AuthenticatedUser(String firebaseUid, String phone, String email, String name, Long userId, Role role, UserStatus status) {
    public boolean isRegistered() {
        return userId != null;
    }
}
