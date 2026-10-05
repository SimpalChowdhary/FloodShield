package com.floodshield.backend.controller;

import com.floodshield.backend.dto.SyncUploadRequest;
import com.floodshield.backend.entity.Incident;
import com.floodshield.backend.service.SyncService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/sync")
public class SyncController {

    private final SyncService syncService;

    public SyncController(SyncService syncService) {
        this.syncService = syncService;
    }

    @PostMapping("/upload")
    public ResponseEntity<List<Incident>> uploadIncidents(
            @RequestBody SyncUploadRequest request) {

        return ResponseEntity.ok(syncService.uploadIncidents(request));
    }
}