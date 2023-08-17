-- this is to track an open of a notification.
create table IF NOT EXISTS notification_open (
	id uuid NOT NULL PRIMARY KEY,
    id_notification uuid NOT NULL REFERENCES notification (id),
    create_time TIMESTAMP NOT NULL,
    id_user uuid NOT NULL REFERENCES "user" (id) -- who opened the notification email
);

-- this is to replace any link into a notification by a tracking link.
create table IF NOT EXISTS notification_link (
	id uuid NOT NULL PRIMARY KEY,
    id_notification uuid NOT NULL REFERENCES notification (id),
    create_time TIMESTAMP NOT NULL,
    link_number int NOT NULL, -- the number of the link in the body notification email
    "url" VARCHAR(8000) NOT NULL -- the url to redirect.
);

-- record the clicks on a notification_link
create table IF NOT EXISTS notification_click (
	id uuid NOT NULL PRIMARY KEY,
    id_link uuid NOT NULL REFERENCES notification_link (id),
    create_time TIMESTAMP NOT NULL,
    id_user uuid NOT NULL REFERENCES "user" (id) -- who clicked the link
);