package com.floodshield.backend.config;

import com.floodshield.backend.entity.User;
import com.floodshield.backend.repository.UserRepository;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.crypto.password.PasswordEncoder;

@Configuration
public class DataInitializer {

    @Bean
    CommandLineRunner createAuthority(
            UserRepository userRepository,
            PasswordEncoder passwordEncoder) {

        return args -> {

            if (!userRepository.existsByEmail("authority@floodshield.com")) {

                User user = new User();

                user.setName("FloodShield Authority");
                user.setEmail("authority@floodshield.com");
                user.setPassword(
                        passwordEncoder.encode("Authority@123"));
                user.setRole("AUTHORITY");

                userRepository.save(user);

                System.out.println(
                        "Default Authority account created");
            }
        };
    }
}