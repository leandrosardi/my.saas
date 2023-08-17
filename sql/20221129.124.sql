-- viral sharing to the list of contacts of our users, using a tool like CloudSponge.
create table if not exists vir_sharing (
    id uuid not null primary key,
    create_time timestamp not null,
    id_user uuid not null references "user"(id),
    service_code varchar(100) not null, -- MySaas extension name which viral sharing is about.
    "name" varchar(500) not null, -- Name of the sharing. This value is configured in the MySaas extension.
    "subject" varchar(500) not null, -- This subject may be edited by the user? Its default value is configured in the MySaas extension.
    "body" text not null -- This body may be edited by the user? Its default value is configured in the MySaas extension.
);

-- list of contacts of a user, imported using any tool like CloudSponge.
create table if not exists vir_contact (
    id uuid not null primary key,
    create_time timestamp not null,
    id_sharing uuid not null references vir_sharing(id),
    "name" varchar(8000) not null,
    "email" varchar(8000) not null,
    -- We grab all the contacts of the user, but the user may choose some ones and not all.
    -- This flag is true if the user has allowed us to use this contact.
    allowed boolean not null,
    -- This flag is set if the user has already been invited by this sharing. 
    delivery_time timestamp null
);

