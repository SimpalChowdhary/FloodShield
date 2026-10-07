package com.floodshield.backend.service;

import java.util.List;

import com.floodshield.backend.dto.ShelterRequest;
import com.floodshield.backend.entity.Shelter;
import com.floodshield.backend.repository.ShelterRepository;

import org.springframework.stereotype.Service;

@Service
public class ShelterService {

    private final ShelterRepository shelterRepository;

    public ShelterService(ShelterRepository shelterRepository) {
        this.shelterRepository = shelterRepository;
    }

    public Shelter createShelter(ShelterRequest request) {

        Shelter shelter = new Shelter();

        shelter.setName(request.getName());
        shelter.setLocation(request.getLocation());
        shelter.setCapacity(request.getCapacity());
        shelter.setOccupancy(
                request.getOccupancy() == null ? 0 : request.getOccupancy());
        shelter.setZoneId(request.getZoneId());
        shelter.setLatitude(request.getLatitude());
        shelter.setLongitude(request.getLongitude());

        return shelterRepository.save(shelter);
    }

    public List<Shelter> getAllShelters() {
        return shelterRepository.findAll();
    }

    public Shelter getShelterById(Long id) {
        return shelterRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Shelter not found"));
    }

    public Shelter updateOccupancy(Long id, Integer occupancy) {

        Shelter shelter = getShelterById(id);

        if (occupancy < 0) {
            throw new RuntimeException("Occupancy cannot be negative");
        }

        if (occupancy > shelter.getCapacity()) {
            throw new RuntimeException(
                    "Occupancy cannot exceed shelter capacity");
        }

        shelter.setOccupancy(occupancy);

        return shelterRepository.save(shelter);
    }
}