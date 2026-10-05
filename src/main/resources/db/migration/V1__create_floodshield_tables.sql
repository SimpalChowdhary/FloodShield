CREATE TABLE users (
    user_id BIGSERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    role VARCHAR(50) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE zones (
    zone_id BIGSERIAL PRIMARY KEY,
    zone_name VARCHAR(150) NOT NULL,
    geometry TEXT,
    vulnerability_score DECIMAL(5,2),
    risk_level VARCHAR(30)
);

CREATE TABLE field_teams (
    team_id BIGSERIAL PRIMARY KEY,
    team_type VARCHAR(100) NOT NULL,
    location VARCHAR(255),
    availability VARCHAR(30) NOT NULL DEFAULT 'AVAILABLE'
);

CREATE TABLE resources (
    resource_id BIGSERIAL PRIMARY KEY,
    resource_type VARCHAR(100) NOT NULL,
    quantity INTEGER NOT NULL DEFAULT 0,
    status VARCHAR(30) NOT NULL DEFAULT 'AVAILABLE'
);

CREATE TABLE shelters (
    shelter_id BIGSERIAL PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    location VARCHAR(255) NOT NULL,
    capacity INTEGER NOT NULL,
    occupancy INTEGER NOT NULL DEFAULT 0,
    zone_id BIGINT NOT NULL,
    CONSTRAINT fk_shelter_zone
        FOREIGN KEY (zone_id)
        REFERENCES zones(zone_id)
);

CREATE TABLE incidents (
    incident_id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    zone_id BIGINT NOT NULL,
    gps_location VARCHAR(255) NOT NULL,
    severity VARCHAR(30) NOT NULL,
    description TEXT,
    photo VARCHAR(500),
    timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(30) NOT NULL DEFAULT 'REPORTED',
    priority_score DECIMAL(5,2),

    CONSTRAINT fk_incident_user
        FOREIGN KEY (user_id)
        REFERENCES users(user_id),

    CONSTRAINT fk_incident_zone
        FOREIGN KEY (zone_id)
        REFERENCES zones(zone_id)
);

CREATE TABLE assignments (
    assignment_id BIGSERIAL PRIMARY KEY,
    incident_id BIGINT NOT NULL,
    team_id BIGINT NOT NULL,
    shelter_id BIGINT,
    resource_id BIGINT,
    travel_time DECIMAL(10,2),
    status VARCHAR(30) NOT NULL DEFAULT 'ASSIGNED',
    assigned_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_assignment_incident
        FOREIGN KEY (incident_id)
        REFERENCES incidents(incident_id),

    CONSTRAINT fk_assignment_team
        FOREIGN KEY (team_id)
        REFERENCES field_teams(team_id),

    CONSTRAINT fk_assignment_shelter
        FOREIGN KEY (shelter_id)
        REFERENCES shelters(shelter_id),

    CONSTRAINT fk_assignment_resource
        FOREIGN KEY (resource_id)
        REFERENCES resources(resource_id)
);

CREATE TABLE simulations (
    simulation_id BIGSERIAL PRIMARY KEY,
    zone_id BIGINT NOT NULL,
    created_by BIGINT,
    rainfall DECIMAL(10,2) NOT NULL,
    affected_area DECIMAL(10,2),
    people_affected INTEGER,
    resources_required INTEGER,
    risk_level VARCHAR(30),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_simulation_zone
        FOREIGN KEY (zone_id)
        REFERENCES zones(zone_id),

    CONSTRAINT fk_simulation_user
        FOREIGN KEY (created_by)
        REFERENCES users(user_id)
);