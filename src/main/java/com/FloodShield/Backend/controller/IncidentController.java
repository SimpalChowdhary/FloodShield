package com.floodshield.backend.controller;

import com.floodshield.backend.dto.IncidentRequest;
import com.floodshield.backend.dto.IncidentStatusRequest;
import com.floodshield.backend.entity.Incident;
import com.floodshield.backend.service.IncidentService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/incidents")
public class IncidentController {

    private final IncidentService incidentService;

    public IncidentController(IncidentService incidentService) {
        this.incidentService = incidentService;
    }

    @PostMapping
    public ResponseEntity<Incident> createIncident(
            @RequestBody IncidentRequest request) {
        return ResponseEntity.ok(incidentService.createIncident(request));
    }

    @GetMapping
    public ResponseEntity<List<Incident>> getAllIncidents() {
        return ResponseEntity.ok(incidentService.getAllIncidents());
    }

    @GetMapping("/{id}")
    public ResponseEntity<Incident> getIncidentById(@PathVariable Long id) {
        return ResponseEntity.ok(incidentService.getIncidentById(id));
    }

    @PutMapping("/{id}/status")
    public ResponseEntity<Incident> updateIncidentStatus(
            @PathVariable Long id,
            @RequestBody IncidentStatusRequest request) {
        return ResponseEntity.ok(
                incidentService.updateIncidentStatus(id, request.getStatus()));
    }
}