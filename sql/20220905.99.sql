-- this table tracks if a user accessed an extensions or signed up for an extension.
create table if not exists user_extension (
	id uuid not null primary key,
	id_user uuid not null references "user"(id),
	extension_name varchar(500) not null,
	create_time timestamp not null
);