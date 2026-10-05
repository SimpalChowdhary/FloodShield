ALTER TABLE incidents
ADD COLUMN client_id VARCHAR(100);

ALTER TABLE incidents
ADD CONSTRAINT uk_incidents_client_id UNIQUE (client_id);
