/* HISTORY TABLES
 *
 * History tables have the same columns that the regarding transactional table, plus a column 'update_time'.
 * The primary keys on history tables are composed by (id, update_time).
 * The transactional table must have a trigger for insert, update or delete on the regarding history table.
 * History tables don't have foreing keys, in order to insert values fast.
 *
**/

CREATE TABLE IF NOT EXISTS preference_history (
	id uuid NOT NULL, -- primary key on history tables are composed by (id, update_time)
	update_time timestamp NULL, -- this is a specific field of the history tables, where I place the update time of the last update of the row
	delete_time timestamp NULL,
	id_user uuid NOT NULL, -- REFERENCES "user" (id), -- hIstory tables should not have foreing keys, because they are huge tables and inserts must be done fast
	create_time timestamp NOT NULL,
	name varchar(500)  NOT NULL,
	type int NOT NULL, -- which type of value is stored here: string (0), int (1), float(2), bool (3)
	value_string varchar(500) NULL,
	value_int int NULL,
	value_float float NULL,
	value_bool bool NULL,
	PRIMARY KEY (id, update_time)
);
