package com.floodshield.backend.controller;

import com.floodshield.backend.dto.FieldTeamCreateRequest;
import com.floodshield.backend.entity.User;
import com.floodshield.backend.repository.UserRepository;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/authority")
public class AuthorityController {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    public AuthorityController(
            UserRepository userRepository,
            PasswordEncoder passwordEncoder) {

        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
    }

    @PostMapping("/field-teams")
    public ResponseEntity<?> createFieldTeam(
            @RequestBody FieldTeamCreateRequest request) {

        if (userRepository.existsByEmail(request.getEmail())) {
            return ResponseEntity.badRequest()
                    .body(Map.of("message", "Email already registered"));
        }

        User user = new User();

        user.setName(request.getName());
        user.setEmail(request.getEmail());
        user.setPassword(passwordEncoder.encode(request.getPassword()));
        user.setRole("FIELD_TEAM");

        userRepository.save(user);

        return ResponseEntity.ok(
                Map.of(
                        "message", "Field Team account created successfully",
                        "email", user.getEmail(),
                        "role", user.getRole()));
    }
}