package com.floodshield.backend.controller;

import java.util.List;
import java.util.Map;

import com.floodshield.backend.dto.ShelterRequest;
import com.floodshield.backend.entity.Shelter;
import com.floodshield.backend.service.ShelterService;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/shelters")
public class ShelterController {

    private final ShelterService shelterService;

    public ShelterController(ShelterService shelterService) {
        this.shelterService = shelterService;
    }

    @PostMapping
    public ResponseEntity<?> createShelter(
            @RequestBody ShelterRequest request) {
        try {
            return ResponseEntity.ok(
                    shelterService.createShelter(request));
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest()
                    .body(Map.of("message", e.getMessage()));
        }
    }

    @GetMapping
    public ResponseEntity<List<Shelter>> getAllShelters() {
        return ResponseEntity.ok(
                shelterService.getAllShelters());
    }

    @GetMapping("/{id}")
    public ResponseEntity<?> getShelterById(
            @PathVariable Long id) {
        try {
            return ResponseEntity.ok(
                    shelterService.getShelterById(id));
        } catch (RuntimeException e) {
            return ResponseEntity.status(404)
                    .body(Map.of("message", e.getMessage()));
        }
    }

    @PutMapping("/{id}/occupancy")
    public ResponseEntity<?> updateOccupancy(
            @PathVariable Long id,
            @RequestBody Map<String, Integer> request) {
        try {
            Integer occupancy = request.get("occupancy");

            if (occupancy == null) {
                return ResponseEntity.badRequest()
                        .body(Map.of("message",
                                "Occupancy is required"));
            }

            return ResponseEntity.ok(
                    shelterService.updateOccupancy(
                            id, occupancy));
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest()
                    .body(Map.of("message", e.getMessage()));
        }
    }
}