package com.netbrew.backend.repository;

import com.netbrew.backend.model.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface UserRepository extends JpaRepository<User, Long> {
    public abstract Optional<User> findByFirebaseUid(String firebaseUid);
    public abstract boolean existsByFirebaseUid(String firebaseUid);
    public abstract boolean existsByPhone(String phone);
    public abstract boolean existsByEmailIgnoreCase(String email);
}
