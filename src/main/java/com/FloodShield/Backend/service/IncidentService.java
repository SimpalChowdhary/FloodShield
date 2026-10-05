package com.floodshield.backend.service;

import com.floodshield.backend.dto.IncidentRequest;
import com.floodshield.backend.entity.Incident;
import com.floodshield.backend.repository.IncidentRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class IncidentService {

    private final IncidentRepository incidentRepository;

    public IncidentService(IncidentRepository incidentRepository) {
        this.incidentRepository = incidentRepository;
    }

    public Incident createIncident(IncidentRequest request) {
        Incident incident = new Incident();

        incident.setClientId(request.getClientId());
        incident.setUserId(request.getUserId());
        incident.setZoneId(request.getZoneId());
        incident.setGpsLocation(request.getGpsLocation());
        incident.setSeverity(request.getSeverity());
        incident.setDescription(request.getDescription());
        incident.setPhoto(request.getPhoto());
        incident.setPriorityScore(request.getPriorityScore());
        incident.setStatus("REPORTED");

        return incidentRepository.save(incident);
    }

    public List<Incident> getAllIncidents() {
        return incidentRepository.findAll();
    }

    public Incident getIncidentById(Long id) {
        return incidentRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Incident not found"));
    }

    public Incident updateIncidentStatus(Long id, String status) {
        Incident incident = getIncidentById(id);
        incident.setStatus(status);
        return incidentRepository.save(incident);
    }
}