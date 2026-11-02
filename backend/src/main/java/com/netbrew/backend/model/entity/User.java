package com.netbrew.backend.model.entity;

import com.netbrew.backend.model.enums.Role;
import com.netbrew.backend.model.enums.UserStatus;
import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "users")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class User extends AuditableEntity{

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "firebase_uid", nullable = false, updatable = false, length = 128)
    private String firebaseUid;

    @Column(nullable = false,length = 20)
    private String phone;

    @Column(length = 255)
    private String email;

    @Column(name = "full_name", nullable = false, length = 100)
    private String fullName;

    @Column(name = "avatar_key")
    private String avatarKey;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private Role role;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private UserStatus status;
}
