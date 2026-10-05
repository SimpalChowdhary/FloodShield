package com.floodshield.backend.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api")
public class RoleTestController {

    @GetMapping("/citizen/test")
    public String citizenTest() {
        return "Citizen API accessed successfully!";
    }

    @GetMapping("/authority/test")
    public String authorityTest() {
        return "Authority API accessed successfully!";
    }

    @GetMapping("/field-team/test")
    public String fieldTeamTest() {
        return "Field Team API accessed successfully!";
    }
}