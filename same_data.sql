﻿--
-- Script was generated by Devart dbForge Studio 2020 for PostgreSQL, Version 2.3.278.0
-- Product home page: http://www.devart.com/dbforge/postgresql/studio
-- Script date 01/02/2022 22:25:04
-- Server version: PostgreSQL 13.3
--

CREATE TABLE IF NOT EXISTS computers (
  id BIGINT GENERATED BY DEFAULT AS IDENTITY,
  name CHARACTER VARYING NOT NULL,
  description CHARACTER VARYING,
  location CHARACTER VARYING NOT NULL,
  CONSTRAINT computers_pkey PRIMARY KEY (id)
) USING HEAP;


CREATE TABLE IF NOT EXISTS events (
  id BIGINT GENERATED BY DEFAULT AS IDENTITY,
  computer_id BIGINT NOT NULL,
  description TEXT NOT NULL,
  level CHARACTER VARYING NOT NULL,
  service CHARACTER VARYING NOT NULL,
  "timestamp" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT NOW(),
  type CHARACTER VARYING NOT NULL,
  "user" CHARACTER VARYING NOT NULL,
  CONSTRAINT events_pkey PRIMARY KEY (id),
  CONSTRAINT events_computer_id_fkey FOREIGN KEY (computer_id) REFERENCES computers (id)
) USING HEAP;





INSERT INTO computers(id, name, description, location) VALUES
(1, E'PC-121-01', E'Windows 10 PC', E'room 121');
INSERT INTO computers(id, name, description, location) VALUES
(2, E'WWW', E'Web Server', E'Server Room');
INSERT INTO computers(id, name, description, location) VALUES
(3, E'PostgreSQL Server', E'Database server', E'Server Room');
INSERT INTO computers(id, name, description, location) VALUES
(4, E'File Server', E'Office file server', E'Server Room');

INSERT INTO events(id, computer_id, description, level, service, "timestamp", type, "user") VALUES
(1, 1, E'restart required', E'warning', E'windows update', '04/05/2021 13:46:41.000000 AD', E'system', E'system');
INSERT INTO events(id, computer_id, description, level, service, "timestamp", type, "user") VALUES
(2, 2, E'The service was restarted', E'information', E'httpd', '04/05/2021 13:47:48.000000 AD', E'service', E'www');
INSERT INTO events(id, computer_id, description, level, service, "timestamp", type, "user") VALUES
(3, 3, E'crash', E'error', E'postgres', '04/05/2021 13:48:45.000000 AD', E'service', E'database');
INSERT INTO events(id, computer_id, description, level, service, "timestamp", type, "user") VALUES
(4, 4, E'updates installed', E'information', E'file', '04/05/2021 13:49:36.000000 AD', E'system update', E'system');