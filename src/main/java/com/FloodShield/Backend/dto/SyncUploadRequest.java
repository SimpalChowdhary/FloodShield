package com.floodshield.backend.dto;

import java.util.List;

public class SyncUploadRequest {

    private List<IncidentRequest> incidents;

    public List<IncidentRequest> getIncidents() {
        return incidents;
    }

    public void setIncidents(List<IncidentRequest> incidents) {
        this.incidents = incidents;
    }
}