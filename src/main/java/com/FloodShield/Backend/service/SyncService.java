package com.floodshield.backend.service;

import com.floodshield.backend.dto.IncidentRequest;
import com.floodshield.backend.dto.SyncUploadRequest;
import com.floodshield.backend.entity.Incident;
import com.floodshield.backend.repository.IncidentRepository;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;

@Service
public class SyncService {

    private final IncidentRepository incidentRepository;

    public SyncService(IncidentRepository incidentRepository) {
        this.incidentRepository = incidentRepository;
    }

    public List<Incident> uploadIncidents(SyncUploadRequest request) {
        List<Incident> uploadedIncidents = new ArrayList<>();

        for (IncidentRequest incidentRequest : request.getIncidents()) {

            if (incidentRepository.existsByClientId(incidentRequest.getClientId())) {
                Incident existingIncident = incidentRepository
                        .findByClientId(incidentRequest.getClientId())
                        .orElseThrow();

                uploadedIncidents.add(existingIncident);
                continue;
            }

            Incident incident = new Incident();

            incident.setClientId(incidentRequest.getClientId());
            incident.setUserId(incidentRequest.getUserId());
            incident.setZoneId(incidentRequest.getZoneId());
            incident.setGpsLocation(incidentRequest.getGpsLocation());
            incident.setSeverity(incidentRequest.getSeverity());
            incident.setDescription(incidentRequest.getDescription());
            incident.setPhoto(incidentRequest.getPhoto());
            incident.setPriorityScore(incidentRequest.getPriorityScore());
            incident.setTimestamp(incidentRequest.getTimestamp());
            incident.setStatus("REPORTED");

            uploadedIncidents.add(incidentRepository.save(incident));
        }

        return uploadedIncidents;
    }
}