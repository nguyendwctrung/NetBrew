package com.netbrew.backend.security;

import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseAuthException;
import com.google.firebase.auth.FirebaseToken;
import com.netbrew.backend.model.entity.User;
import com.netbrew.backend.model.enums.UserStatus;
import com.netbrew.backend.repository.UserRepository;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpHeaders;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.List;
import java.util.Optional;

@Slf4j
public class FirebaseAuthenticationFilter extends OncePerRequestFilter {
    private static final String BEARER = "Bearer";
    private final FirebaseAuth firebaseAuth;
    private final UserRepository userRepository;

    public FirebaseAuthenticationFilter(FirebaseAuth firebaseAuth, UserRepository userRepository) {
        this.firebaseAuth = firebaseAuth;
        this.userRepository = userRepository;
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain chain) throws ServletException, IOException {
        String header = request.getHeader(HttpHeaders.AUTHORIZATION);
        if (header != null && header.startsWith(BEARER)) {
            authenticate(header.substring(BEARER.length()).trim());
        }
        chain.doFilter(request, response);
    }

    private void authenticate(String idToken) {
        try {
            FirebaseToken token = firebaseAuth.verifyIdToken(idToken);
            String phone = (String) token.getClaims().get("phone_number");
            Optional<User> user = userRepository.findByFirebaseUid(token.getUid());

            AuthenticatedUser principal = new AuthenticatedUser(
                    token.getUid(),
                    phone,
                    token.getEmail(),
                    token.getName(),
                    user.map(User::getId).orElse(null),
                    user.map(User::getRole).orElse(null),
                    user.map(User::getStatus).orElse(null)
            );

            List<GrantedAuthority> authorities = user
                    .filter(u -> u.getStatus() == UserStatus.ACTIVE)
                    .<GrantedAuthority>map(u -> new SimpleGrantedAuthority("ROLE_" + u.getRole().name()))
                    .stream()
                    .toList();

            SecurityContextHolder.getContext().setAuthentication(
                    new UsernamePasswordAuthenticationToken(principal, null, authorities)
            );

        } catch (FirebaseAuthException | IllegalArgumentException e) {
            SecurityContextHolder.clearContext();
            log.debug("Rejected Firebase ID token: {}", e.getMessage());
        }
    }
}
