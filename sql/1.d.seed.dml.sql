-- TRUNCATE TABLE "role"; -- no se puede truncar una tabla referida en una llave foranea
INSERT INTO "role" (id, name) VALUES ('6fb960c2-50c1-4edd-b82e-65157e984341', 'su') ON CONFLICT DO NOTHING; -- super user
INSERT INTO "role" (id, name) VALUES ('d96a68b1-e8a9-41fe-8e2d-9af2f0e26016', 'csm') ON CONFLICT DO NOTHING; -- customer success manager

-- TRUNCATE TABLE "account"; -- no se puede truncar una tabla referida en una llave foranea
INSERT INTO account (id, name, id_account_owner, create_time, id_timezone, storage_total_kb, api_key) VALUES ('897b4c5e-692e-400f-bc97-8ee0e3e1f1cf', 'su', '897b4c5e-692e-400f-bc97-8ee0e3e1f1cf', current_timestamp, 'f85765c7-0fc0-4626-9ab2-c1ec81032683', 15*1024, '4db9d88c-dee9-4b5a-8d36-134d38e9f763') ON CONFLICT DO NOTHING; -- super user

-- TRUNCATE TABLE "user"; -- no se puede truncar una tabla referida en una llave foranea
INSERT INTO "user" (id, id_account, create_time, email, password, name) VALUES ('d5d6d614-2780-43c0-8e52-3ad412d2f0a7', '897b4c5e-692e-400f-bc97-8ee0e3e1f1cf', current_timestamp, 'su', '$2a$12$xuhZYQWAexjLwJHTdTHeSui9/luloc1D7WEO8u7m2J9v.vL2tmOLC', 'su') ON CONFLICT DO NOTHING; -- super user

-- TRUNCATE TABLE user_role; -- no se puede truncar una tabla referida en una llave foranea

-- add su role to the su user
INSERT INTO user_role (id, create_time, id_creator, id_user, id_role) VALUES ('98c60163-3412-4952-85da-a7fa823f459f', current_timestamp, 'd5d6d614-2780-43c0-8e52-3ad412d2f0a7', 'd5d6d614-2780-43c0-8e52-3ad412d2f0a7', '6fb960c2-50c1-4edd-b82e-65157e984341') ON CONFLICT DO NOTHING; -- super user

-- add csm role to the su user
INSERT INTO user_role (id, create_time, id_creator, id_user, id_role) VALUES ('41e33e8b-2124-403b-865d-1f3b79fb107b', current_timestamp, 'd5d6d614-2780-43c0-8e52-3ad412d2f0a7', 'd5d6d614-2780-43c0-8e52-3ad412d2f0a7', 'd96a68b1-e8a9-41fe-8e2d-9af2f0e26016') ON CONFLICT DO NOTHING; -- super user



