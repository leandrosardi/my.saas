CREATE TABLE IF NOT EXISTS eml_action (
	id uuid NOT NULL,
	id_user uuid NOT NULL,
	"name" varchar(500) NOT NULL,
	create_time timestamp NOT NULL,
	delete_time timestamp NULL,
	"status" bool NOT NULL,
	trigger_type int8 NOT NULL,
	action_type int8 NOT NULL,
	apply_to_previous_events bool NOT NULL,
	delay_minutes int8 NOT NULL,
	id_export uuid NULL,
	id_campaign uuid NULL,
	id_followup uuid NULL,
	id_link uuid NULL,
	CONSTRAINT eml_action_pkey PRIMARY KEY (id ASC)
);

CREATE TABLE IF NOT EXISTS eml_action_log (
	id uuid NOT NULL,
	create_time timestamp NOT NULL,
	id_action uuid NOT NULL,
	id_lead uuid NOT NULL,
	CONSTRAINT eml_action_log_pkey PRIMARY KEY (id ASC)
);

CREATE TABLE IF NOT EXISTS eml_address (
	id uuid NOT NULL,
	id_user uuid NOT NULL,
	id_mta uuid NOT NULL,
	create_time timestamp NOT NULL,
	"type" int8 NOT NULL,
	first_name varchar(500) NOT NULL,
	last_name varchar(500) NOT NULL,
	address varchar(500) NOT NULL,
	"password" varchar(500) NOT NULL,
	"shared" bool NOT NULL,
	enabled bool NOT NULL,
	imap_inbox_last_id varchar(500) NULL,
	imap_spam_last_id varchar(500) NULL,
	max_deliveries_per_day int8 NOT NULL,
	delivery_interval_min_minutes int8 NOT NULL,
	delivery_interval_max_minutes int8 NOT NULL,
	stat_tags varchar(8000) NULL,
	delete_time timestamp NULL,
	timeline_reservation_id varchar(500) NULL,
	timeline_reservation_time timestamp NULL,
	timeline_reservation_times int8 NULL,
	timeline_start_time timestamp NULL,
	timeline_end_time timestamp NULL,
	timeline_success bool NULL,
	timeline_error_description text NULL,
	timeline_last_date_processed date NULL,
	accept_all bool NOT NULL DEFAULT false,
	tracking_domain varchar(500) NULL,
	check_success bool NULL,
	check_error_description varchar(8000) NULL,
	born_time timestamp NULL,
	CONSTRAINT eml_address_address_key UNIQUE (address ASC),
	CONSTRAINT eml_address_pkey PRIMARY KEY (id ASC)
);

CREATE TABLE IF NOT EXISTS eml_address_tag (
	id uuid NOT NULL,
	id_user uuid NOT NULL,
	create_time timestamp NOT NULL,
	id_address uuid NOT NULL,
	id_tag uuid NOT NULL,
	CONSTRAINT eml_address_tag_id_address_id_tag_key UNIQUE (id_address ASC, id_tag ASC),
	CONSTRAINT eml_address_tag_pkey PRIMARY KEY (id ASC)
);

CREATE TABLE IF NOT EXISTS eml_campaign (
	id uuid NOT NULL,
	id_user uuid NOT NULL,
	create_time timestamp NOT NULL,
	"name" varchar(255) NOT NULL,
	id_export uuid NOT NULL,
	stat_sents int8 NOT NULL DEFAULT 0,
	stat_opens int8 NOT NULL DEFAULT 0,
	stat_clicks int8 NOT NULL DEFAULT 0,
	stat_replies int8 NOT NULL DEFAULT 0,
	stat_bounces int8 NOT NULL DEFAULT 0,
	stat_unsubscribes int8 NOT NULL DEFAULT 0,
	stat_complaints int8 NOT NULL DEFAULT 0,
	stat_positive_replies int8 NOT NULL DEFAULT 0,
	delete_time timestamp NULL,
	exclude_leads_reached_by_another_campaign bool NOT NULL DEFAULT false,
	use_public_addresses bool NOT NULL DEFAULT false,
	stop_followups_if_lead_replied bool NOT NULL DEFAULT true,
	stat_left int8 NOT NULL DEFAULT 0,
	use_private_addresses bool NOT NULL DEFAULT false,
	archive_end_time timestamp NULL,
	archive_start_time timestamp NULL,
	archive_success bool NULL,
	archive_error_description varchar(8000) NULL,
	timeline_reservation_id varchar(500) NULL,
	timeline_reservation_time timestamp NULL,
	timeline_reservation_times int8 NULL,
	timeline_start_time timestamp NULL,
	timeline_end_time timestamp NULL,
	timeline_success bool NULL,
	timeline_error_description text NULL,
	CONSTRAINT eml_campaign_pkey PRIMARY KEY (id ASC)
);

CREATE TABLE IF NOT EXISTS eml_click (
	id uuid NOT NULL,
	id_delivery uuid NOT NULL,
	id_link uuid NOT NULL,
	create_time timestamp NOT NULL,
	micro_emails_timeline_push_reservation_time timestamp NULL,
	micro_emails_timeline_push_reservation_times int8 NULL,
	micro_emails_timeline_push_start_time timestamp NULL,
	micro_emails_timeline_push_end_time timestamp NULL,
	micro_emails_timeline_push_success bool NULL,
	micro_emails_timeline_push_error_description varchar(8000) NULL,
	micro_emails_timeline_push_reservation_id varchar(500) NULL,
	CONSTRAINT eml_click_pkey PRIMARY KEY (id ASC)
);

CREATE TABLE IF NOT EXISTS eml_delivery (
	id uuid NOT NULL,
	id_followup uuid NULL,
	id_address uuid NOT NULL,
	id_lead uuid NOT NULL,
	create_time timestamp NOT NULL,
	delivery_reservation_time timestamp NULL,
	delivery_reservation_times int8 NULL,
	delivery_start_time timestamp NULL,
	delivery_end_time timestamp NULL,
	delivery_success bool NULL,
	delivery_error_description varchar(8000) NULL,
	email varchar(500) NOT NULL,
	subject varchar(8000) NOT NULL,
	body text NOT NULL,
	message_id varchar(500) NULL,
	id_conversation uuid NULL,
	is_response bool NOT NULL DEFAULT false,
	"name" varchar(500) NULL,
	is_single bool NOT NULL DEFAULT false,
	id_user uuid NULL,
	delivery_reservation_id varchar(500) NULL,
	is_bounce bool NOT NULL DEFAULT false,
	bounce_reason varchar(500) NULL,
	bounce_diagnosticcode varchar(8000) NULL,
	is_positive bool NOT NULL DEFAULT false,
	positive_type int8 NULL,
	positive_value float8 NOT NULL DEFAULT 0.0,
	id_template uuid NULL,
	notification_response_success bool NULL,
	notification_response_error_description varchar(8000) NULL,
	stat_account_name varchar(500) NULL,
	stat_user_name varchar(500) NULL,
	stat_user_email varchar(500) NULL,
	stat_campaign_name varchar(500) NULL,
	stat_followup_name varchar(500) NULL,
	stat_lead_name varchar(500) NULL,
	stat_lead_position varchar(500) NULL,
	stat_company_name varchar(500) NULL,
	positive_time timestamp NULL,
	delete_time timestamp NULL,
	micro_emails_timeline_push_reservation_time timestamp NULL,
	micro_emails_timeline_push_reservation_times int8 NULL,
	micro_emails_timeline_push_start_time timestamp NULL,
	micro_emails_timeline_push_end_time timestamp NULL,
	micro_emails_timeline_push_success bool NULL,
	micro_emails_timeline_push_error_description varchar(8000) NULL,
	micro_emails_timeline_push_reservation_id varchar(500) NULL,
	CONSTRAINT eml_delivery_pkey PRIMARY KEY (id ASC)
);

CREATE TABLE IF NOT EXISTS eml_followup (
	id uuid NOT NULL,
	id_user uuid NOT NULL,
	create_time timestamp NOT NULL,
	"name" varchar(255) NOT NULL,
	id_campaign uuid NOT NULL,
	subject varchar(255) NOT NULL,
	body text NOT NULL,
	"type" int8 NOT NULL,
	"status" int8 NOT NULL,
	sequence_number int8 NOT NULL,
	delay_days int8 NOT NULL,
	stat_subject_spintax_variations int8 NOT NULL,
	stat_body_spintax_variations int8 NOT NULL,
	stat_sents int8 NOT NULL DEFAULT 0,
	stat_opens int8 NOT NULL DEFAULT 0,
	stat_clicks int8 NOT NULL DEFAULT 0,
	stat_replies int8 NOT NULL DEFAULT 0,
	stat_bounces int8 NOT NULL DEFAULT 0,
	stat_unsubscribes int8 NOT NULL DEFAULT 0,
	stat_complaints int8 NOT NULL DEFAULT 0,
	planning_reservation_time timestamp NULL,
	planning_reservation_times int8 NULL,
	planning_start_time timestamp NULL,
	planning_end_time timestamp NULL,
	planning_success bool NULL,
	planning_error_description varchar(8000) NULL,
	stat_positive_replies int8 NOT NULL DEFAULT 0,
	delete_time timestamp NULL,
	planning_reservation_id varchar(500) NULL,
	track_opens_enabled bool NULL DEFAULT false,
	track_clicks_enabled bool NULL DEFAULT false,
	stat_left int8 NOT NULL DEFAULT 0,
	timeline_reservation_id varchar(500) NULL,
	timeline_reservation_time timestamp NULL,
	timeline_reservation_times int8 NULL,
	timeline_start_time timestamp NULL,
	timeline_end_time timestamp NULL,
	timeline_success bool NULL,
	timeline_error_description text NULL,
	CONSTRAINT eml_followup_pkey PRIMARY KEY (id ASC)
);

CREATE TABLE IF NOT EXISTS eml_link (
	id uuid NOT NULL,
	id_followup uuid NOT NULL,
	create_time timestamp NOT NULL,
	link_number int8 NOT NULL,
	url varchar(8000) NOT NULL,
	delete_time timestamp NULL,
	CONSTRAINT eml_link_pkey PRIMARY KEY (id ASC),
	CONSTRAINT uk_link UNIQUE (id_followup ASC, link_number ASC, delete_time ASC)
);

CREATE TABLE IF NOT EXISTS eml_log (
	id uuid NOT NULL,
	create_time timestamp NOT NULL,
	"type" varchar(50) NOT NULL,
	color varchar(50) NOT NULL,
	id_lead uuid NOT NULL,
	id_delivery uuid NOT NULL,
	id_followup uuid NOT NULL,
	id_campaign uuid NOT NULL,
	lead_name varchar(8000) NOT NULL,
	campaign_name varchar(8000) NOT NULL,
	planning_time timestamp NOT NULL,
	url varchar(8000) NULL,
	planning_id_address varchar(500) NULL,
	address varchar(500) NOT NULL,
	subject varchar(8000) NOT NULL,
	body text NOT NULL,
	error_description text NULL,
	id_account uuid NOT NULL,
	lead_email varchar(500) NOT NULL,
	CONSTRAINT eml_log_pkey PRIMARY KEY (id ASC)
);

CREATE TABLE IF NOT EXISTS eml_mta (
	id uuid NOT NULL,
	id_user uuid NOT NULL,
	create_time timestamp NOT NULL,
	smtp_address varchar(500) NOT NULL,
	smtp_port int8 NOT NULL,
	imap_port int8 NOT NULL,
	imap_address varchar(500) NOT NULL,
	authentication varchar(500) NOT NULL,
	enable_starttls_auto bool NOT NULL,
	openssl_verify_mode varchar(500) NOT NULL,
	inbox_label varchar(500) NOT NULL DEFAULT 'Inbox'::STRING,
	spam_label varchar(500) NOT NULL DEFAULT 'Spam'::STRING,
	search_all_wildcard varchar(500) NOT NULL DEFAULT ''::STRING,
	smtp_username varchar(500) NULL,
	smtp_password varchar(500) NULL,
	imap_username varchar(500) NULL,
	imap_password varchar(500) NULL,
	imap_allowed bool NOT NULL DEFAULT true,
	CONSTRAINT eml_mta_pkey PRIMARY KEY (id ASC)
);

CREATE TABLE IF NOT EXISTS eml_open (
	id uuid NOT NULL,
	id_delivery uuid NOT NULL,
	create_time timestamp NOT NULL,
	micro_emails_timeline_push_reservation_time timestamp NULL,
	micro_emails_timeline_push_reservation_times int8 NULL,
	micro_emails_timeline_push_start_time timestamp NULL,
	micro_emails_timeline_push_end_time timestamp NULL,
	micro_emails_timeline_push_success bool NULL,
	micro_emails_timeline_push_error_description varchar(8000) NULL,
	micro_emails_timeline_push_reservation_id varchar(500) NULL,
	CONSTRAINT eml_open_pkey PRIMARY KEY (id ASC)
);

CREATE TABLE IF NOT EXISTS eml_outreach (
	id uuid NOT NULL,
	id_user uuid NOT NULL,
	create_time timestamp NOT NULL,
	id_campaign uuid NOT NULL,
	id_tag uuid NOT NULL,
	CONSTRAINT eml_outreach_id_campaign_id_tag_key UNIQUE (id_campaign ASC, id_tag ASC),
	CONSTRAINT eml_outreach_pkey PRIMARY KEY (id ASC)
);

CREATE TABLE IF NOT EXISTS eml_schedule (
	id uuid NOT NULL,
	id_user uuid NOT NULL,
	create_time timestamp NOT NULL,
	"name" varchar(255) NOT NULL,
	id_campaign uuid NOT NULL,
	schedule_start_time timestamp NOT NULL,
	schedule_hour_0 bool NOT NULL,
	schedule_hour_1 bool NOT NULL,
	schedule_hour_2 bool NOT NULL,
	schedule_hour_3 bool NOT NULL,
	schedule_hour_4 bool NOT NULL,
	schedule_hour_5 bool NOT NULL,
	schedule_hour_6 bool NOT NULL,
	schedule_hour_7 bool NOT NULL,
	schedule_hour_8 bool NOT NULL,
	schedule_hour_9 bool NOT NULL,
	schedule_hour_10 bool NOT NULL,
	schedule_hour_11 bool NOT NULL,
	schedule_hour_12 bool NOT NULL,
	schedule_hour_13 bool NOT NULL,
	schedule_hour_14 bool NOT NULL,
	schedule_hour_15 bool NOT NULL,
	schedule_hour_16 bool NOT NULL,
	schedule_hour_17 bool NOT NULL,
	schedule_hour_18 bool NOT NULL,
	schedule_hour_19 bool NOT NULL,
	schedule_hour_20 bool NOT NULL,
	schedule_hour_21 bool NOT NULL,
	schedule_hour_22 bool NOT NULL,
	schedule_hour_23 bool NOT NULL,
	schedule_day_0 bool NOT NULL,
	schedule_day_1 bool NOT NULL,
	schedule_day_2 bool NOT NULL,
	schedule_day_3 bool NOT NULL,
	schedule_day_4 bool NOT NULL,
	schedule_day_5 bool NOT NULL,
	schedule_day_6 bool NOT NULL,
	delete_time timestamp NULL,
	CONSTRAINT eml_schedule_pkey PRIMARY KEY (id ASC)
);

CREATE TABLE IF NOT EXISTS eml_tag (
	id uuid NOT NULL,
	id_user uuid NOT NULL,
	create_time timestamp NOT NULL,
	"name" varchar(500) NOT NULL,
	CONSTRAINT eml_tag_pkey PRIMARY KEY (id ASC)
);

CREATE TABLE IF NOT EXISTS eml_test (
	id uuid NOT NULL,
	create_time timestamp NOT NULL,
	id_address uuid NOT NULL,
	id_followup uuid NOT NULL,
	test varchar(500) NOT NULL,
	"from" varchar(500) NULL,
	"result" varchar(500) NULL,
	CONSTRAINT eml_test_pkey PRIMARY KEY (id ASC)
);

CREATE TABLE IF NOT EXISTS eml_timeline (
	id uuid NOT NULL,
	id_campaign uuid NOT NULL,
	id_followup uuid NOT NULL,
	id_address uuid NOT NULL,
	create_time timestamp NOT NULL,
	"year" int8 NOT NULL,
	"month" int8 NOT NULL,
	"day" int8 NOT NULL,
	"hour" int8 NOT NULL,
	stat_sents int8 NOT NULL DEFAULT 0,
	stat_opens int8 NOT NULL DEFAULT 0,
	stat_clicks int8 NOT NULL DEFAULT 0,
	stat_replies int8 NOT NULL DEFAULT 0,
	stat_bounces int8 NOT NULL DEFAULT 0,
	stat_unsubscribes int8 NOT NULL DEFAULT 0,
	stat_complaints int8 NOT NULL DEFAULT 0,
	stat_positive_replies int8 NOT NULL DEFAULT 0,
	stat_value float8 NOT NULL DEFAULT 0.0,
	id_account uuid NULL,
	stat_unique_opens int8 NOT NULL DEFAULT 0,
	stat_unique_clicks int8 NOT NULL DEFAULT 0,
	CONSTRAINT eml_timeline_pkey PRIMARY KEY (id ASC),
	CONSTRAINT ix_eml_timeline UNIQUE (id_account ASC, id_campaign ASC, id_followup ASC, id_address ASC, year ASC, month ASC, day ASC, hour ASC)
);

CREATE TABLE IF NOT EXISTS eml_unsubscribe (
	id uuid NOT NULL,
	id_delivery uuid NOT NULL,
	create_time timestamp NOT NULL,
	micro_emails_timeline_push_reservation_time timestamp NULL,
	micro_emails_timeline_push_reservation_times int8 NULL,
	micro_emails_timeline_push_start_time timestamp NULL,
	micro_emails_timeline_push_end_time timestamp NULL,
	micro_emails_timeline_push_success bool NULL,
	micro_emails_timeline_push_error_description varchar(8000) NULL,
	micro_emails_timeline_push_reservation_id varchar(500) NULL,
	CONSTRAINT eml_unsubscribe_pkey PRIMARY KEY (id ASC)
);

CREATE TABLE IF NOT EXISTS eml_upload_leads_job (
	id uuid NOT NULL,
	id_user uuid NOT NULL,
	create_time timestamp NOT NULL,
	id_export uuid NOT NULL,
	skip_existing_emails bool NOT NULL DEFAULT true,
	separator_char varchar(1) NOT NULL DEFAULT ','::STRING,
	enclosure_char varchar(1) NOT NULL DEFAULT '"'::STRING,
	ingest_reservation_times int8 NULL,
	ingest_reservation_time timestamp NULL,
	ingest_start_time timestamp NULL,
	ingest_end_time timestamp NULL,
	ingest_success bool NULL,
	ingest_error_description text NULL,
	stat_total_rows int8 NULL,
	stat_imported_rows int8 NULL,
	stat_error_rows int8 NULL,
	ingest_reservation_id varchar(500) NULL,
	CONSTRAINT eml_upload_leads_job_pkey PRIMARY KEY (id ASC)
);

alter table eml_upload_leads_job add column if not exists csv_content text null;

CREATE TABLE IF NOT EXISTS eml_upload_leads_mapping (
	id uuid NOT NULL,
	id_upload_leads_job uuid NOT NULL,
	create_time timestamp NOT NULL,
	"column" int8 NOT NULL,
	data_type int8 NOT NULL,
	custom_field_name varchar(500) NOT NULL,
	CONSTRAINT eml_upload_leads_mapping_id_upload_leads_job_column_key UNIQUE (id_upload_leads_job ASC, "column" ASC),
	CONSTRAINT eml_upload_leads_mapping_pkey PRIMARY KEY (id ASC)
);

CREATE TABLE IF NOT EXISTS eml_upload_leads_row (
	id uuid NOT NULL,
	id_upload_leads_job uuid NOT NULL,
	line_number int8 NULL,
	line varchar(8000) NOT NULL,
	import_reservation_times int8 NULL,
	import_reservation_time timestamp NULL,
	import_start_time timestamp NULL,
	import_end_time timestamp NULL,
	import_success bool NULL,
	import_error_description text NULL,
	import_reservation_id varchar(500) NULL,
	verification_success bool NULL,
	verification_error_description varchar(8000) NULL,
	id_lead uuid NULL,
	CONSTRAINT eml_upload_leads_row_pkey PRIMARY KEY (id ASC)
);

CREATE TABLE IF NOT EXISTS eml_upload_leads_row_aux (
	id uuid NULL,
	id_upload_leads_job uuid NULL,
	line_number int8 NULL,
	line varchar(8000) NOT NULL,
	import_reservation_times int8 NULL,
	import_reservation_time timestamp NULL,
	import_start_time timestamp NULL,
	import_end_time timestamp NULL,
	import_success bool NULL,
	import_error_description text NULL,
	import_reservation_id varchar(500) NULL,
	verification_success bool NULL,
	verification_error_description varchar(8000) NULL,
	id_lead uuid NULL --,
	--CONSTRAINT eml_upload_leads_row_pkey PRIMARY KEY (id ASC)
);

ALTER TABLE eml_action DROP CONSTRAINT IF EXISTS eml_action_id_campaign_fkey;
ALTER TABLE eml_action ADD CONSTRAINT eml_action_id_campaign_fkey FOREIGN KEY (id_campaign) REFERENCES eml_campaign(id);

ALTER TABLE eml_action DROP CONSTRAINT IF EXISTS eml_action_id_export_fkey;
ALTER TABLE eml_action ADD CONSTRAINT eml_action_id_export_fkey FOREIGN KEY (id_export) REFERENCES fl_export(id);

ALTER TABLE eml_action DROP CONSTRAINT IF EXISTS eml_action_id_followup_fkey;
ALTER TABLE eml_action ADD CONSTRAINT eml_action_id_followup_fkey FOREIGN KEY (id_followup) REFERENCES eml_followup(id);

ALTER TABLE eml_action DROP CONSTRAINT IF EXISTS eml_action_id_link_fkey;
ALTER TABLE eml_action ADD CONSTRAINT eml_action_id_link_fkey FOREIGN KEY (id_link) REFERENCES eml_link(id);

ALTER TABLE eml_action DROP CONSTRAINT IF EXISTS eml_action_id_user_fkey;
ALTER TABLE eml_action ADD CONSTRAINT eml_action_id_user_fkey FOREIGN KEY (id_user) REFERENCES "user"(id);

ALTER TABLE eml_action_log DROP CONSTRAINT IF EXISTS eml_action_log_id_action_fkey;
ALTER TABLE eml_action_log ADD CONSTRAINT eml_action_log_id_action_fkey FOREIGN KEY (id_action) REFERENCES eml_action(id);

ALTER TABLE eml_action_log DROP CONSTRAINT IF EXISTS eml_action_log_id_lead_fkey;
ALTER TABLE eml_action_log ADD CONSTRAINT eml_action_log_id_lead_fkey FOREIGN KEY (id_lead) REFERENCES fl_lead(id);

ALTER TABLE eml_address DROP CONSTRAINT IF EXISTS eml_address_id_mta_fkey;
ALTER TABLE eml_address ADD CONSTRAINT eml_address_id_mta_fkey FOREIGN KEY (id_mta) REFERENCES eml_mta(id);

ALTER TABLE eml_address DROP CONSTRAINT IF EXISTS eml_address_id_user_fkey;
ALTER TABLE eml_address ADD CONSTRAINT eml_address_id_user_fkey FOREIGN KEY (id_user) REFERENCES "user"(id);

ALTER TABLE eml_address_tag DROP CONSTRAINT IF EXISTS eml_address_tag_id_address_fkey;
ALTER TABLE eml_address_tag ADD CONSTRAINT eml_address_tag_id_address_fkey FOREIGN KEY (id_address) REFERENCES eml_address(id);

ALTER TABLE eml_address_tag DROP CONSTRAINT IF EXISTS eml_address_tag_id_tag_fkey;
ALTER TABLE eml_address_tag ADD CONSTRAINT eml_address_tag_id_tag_fkey FOREIGN KEY (id_tag) REFERENCES eml_tag(id);

ALTER TABLE eml_address_tag DROP CONSTRAINT IF EXISTS eml_address_tag_id_user_fkey;
ALTER TABLE eml_address_tag ADD CONSTRAINT eml_address_tag_id_user_fkey FOREIGN KEY (id_user) REFERENCES "user"(id);

ALTER TABLE eml_campaign DROP CONSTRAINT IF EXISTS eml_campaign_id_export_fkey;
ALTER TABLE eml_campaign ADD CONSTRAINT eml_campaign_id_export_fkey FOREIGN KEY (id_export) REFERENCES fl_export(id);

ALTER TABLE eml_campaign DROP CONSTRAINT IF EXISTS eml_campaign_id_user_fkey;
ALTER TABLE eml_campaign ADD CONSTRAINT eml_campaign_id_user_fkey FOREIGN KEY (id_user) REFERENCES "user"(id);

ALTER TABLE eml_click DROP CONSTRAINT IF EXISTS eml_click_id_delivery_fkey;
ALTER TABLE eml_click ADD CONSTRAINT eml_click_id_delivery_fkey FOREIGN KEY (id_delivery) REFERENCES eml_delivery(id);

ALTER TABLE eml_click DROP CONSTRAINT IF EXISTS eml_click_id_link_fkey;
ALTER TABLE eml_click ADD CONSTRAINT eml_click_id_link_fkey FOREIGN KEY (id_link) REFERENCES eml_link(id);

ALTER TABLE eml_delivery DROP CONSTRAINT IF EXISTS eml_delivery_id_address_fkey;
ALTER TABLE eml_delivery ADD CONSTRAINT eml_delivery_id_address_fkey FOREIGN KEY (id_address) REFERENCES eml_address(id);

ALTER TABLE eml_delivery DROP CONSTRAINT IF EXISTS eml_delivery_id_followup_fkey;
ALTER TABLE eml_delivery ADD CONSTRAINT eml_delivery_id_followup_fkey FOREIGN KEY (id_followup) REFERENCES eml_followup(id);

ALTER TABLE eml_delivery DROP CONSTRAINT IF EXISTS eml_delivery_id_lead_fkey;
ALTER TABLE eml_delivery ADD CONSTRAINT eml_delivery_id_lead_fkey FOREIGN KEY (id_lead) REFERENCES fl_lead(id);

ALTER TABLE eml_delivery DROP CONSTRAINT IF EXISTS eml_delivery_id_user_fkey;
ALTER TABLE eml_delivery ADD CONSTRAINT eml_delivery_id_user_fkey FOREIGN KEY (id_user) REFERENCES "user"(id);

ALTER TABLE eml_followup DROP CONSTRAINT IF EXISTS eml_followup_id_campaign_fkey;
ALTER TABLE eml_followup ADD CONSTRAINT eml_followup_id_campaign_fkey FOREIGN KEY (id_campaign) REFERENCES eml_campaign(id);

ALTER TABLE eml_followup DROP CONSTRAINT IF EXISTS eml_followup_id_user_fkey;
ALTER TABLE eml_followup ADD CONSTRAINT eml_followup_id_user_fkey FOREIGN KEY (id_user) REFERENCES "user"(id);

ALTER TABLE eml_link DROP CONSTRAINT IF EXISTS eml_link_id_followup_fkey;
ALTER TABLE eml_link ADD CONSTRAINT eml_link_id_followup_fkey FOREIGN KEY (id_followup) REFERENCES eml_followup(id);

ALTER TABLE eml_log DROP CONSTRAINT IF EXISTS eml_log_id_account_fkey;
ALTER TABLE eml_log ADD CONSTRAINT eml_log_id_account_fkey FOREIGN KEY (id_account) REFERENCES account(id);

ALTER TABLE eml_log DROP CONSTRAINT IF EXISTS eml_log_id_campaign_fkey;
ALTER TABLE eml_log ADD CONSTRAINT eml_log_id_campaign_fkey FOREIGN KEY (id_campaign) REFERENCES eml_campaign(id);

ALTER TABLE eml_log DROP CONSTRAINT IF EXISTS eml_log_id_delivery_fkey;
ALTER TABLE eml_log ADD CONSTRAINT eml_log_id_delivery_fkey FOREIGN KEY (id_delivery) REFERENCES eml_delivery(id);

ALTER TABLE eml_log DROP CONSTRAINT IF EXISTS eml_log_id_followup_fkey;
ALTER TABLE eml_log ADD CONSTRAINT eml_log_id_followup_fkey FOREIGN KEY (id_followup) REFERENCES eml_followup(id);

ALTER TABLE eml_log DROP CONSTRAINT IF EXISTS eml_log_id_lead_fkey;
ALTER TABLE eml_log ADD CONSTRAINT eml_log_id_lead_fkey FOREIGN KEY (id_lead) REFERENCES fl_lead(id);

ALTER TABLE eml_mta DROP CONSTRAINT IF EXISTS eml_mta_id_user_fkey;
ALTER TABLE eml_mta ADD CONSTRAINT eml_mta_id_user_fkey FOREIGN KEY (id_user) REFERENCES "user"(id);

ALTER TABLE eml_open DROP CONSTRAINT IF EXISTS eml_open_id_delivery_fkey;
ALTER TABLE eml_open ADD CONSTRAINT eml_open_id_delivery_fkey FOREIGN KEY (id_delivery) REFERENCES eml_delivery(id);

ALTER TABLE eml_outreach DROP CONSTRAINT IF EXISTS eml_outreach_id_campaign_fkey;
ALTER TABLE eml_outreach ADD CONSTRAINT eml_outreach_id_campaign_fkey FOREIGN KEY (id_campaign) REFERENCES eml_campaign(id);

ALTER TABLE eml_outreach DROP CONSTRAINT IF EXISTS eml_outreach_id_tag_fkey;
ALTER TABLE eml_outreach ADD CONSTRAINT eml_outreach_id_tag_fkey FOREIGN KEY (id_tag) REFERENCES eml_tag(id);

ALTER TABLE eml_outreach DROP CONSTRAINT IF EXISTS eml_outreach_id_user_fkey;
ALTER TABLE eml_outreach ADD CONSTRAINT eml_outreach_id_user_fkey FOREIGN KEY (id_user) REFERENCES "user"(id);

ALTER TABLE eml_schedule DROP CONSTRAINT IF EXISTS eml_schedule_id_campaign_fkey;
ALTER TABLE eml_schedule ADD CONSTRAINT eml_schedule_id_campaign_fkey FOREIGN KEY (id_campaign) REFERENCES eml_campaign(id);

ALTER TABLE eml_schedule DROP CONSTRAINT IF EXISTS eml_schedule_id_user_fkey;
ALTER TABLE eml_schedule ADD CONSTRAINT eml_schedule_id_user_fkey FOREIGN KEY (id_user) REFERENCES "user"(id);

ALTER TABLE eml_tag DROP CONSTRAINT IF EXISTS eml_tag_id_user_fkey;
ALTER TABLE eml_tag ADD CONSTRAINT eml_tag_id_user_fkey FOREIGN KEY (id_user) REFERENCES "user"(id);

ALTER TABLE eml_test DROP CONSTRAINT IF EXISTS eml_test_id_address_fkey;
ALTER TABLE eml_test ADD CONSTRAINT eml_test_id_address_fkey FOREIGN KEY (id_address) REFERENCES eml_address(id);

ALTER TABLE eml_test DROP CONSTRAINT IF EXISTS eml_test_id_followup_fkey;
ALTER TABLE eml_test ADD CONSTRAINT eml_test_id_followup_fkey FOREIGN KEY (id_followup) REFERENCES eml_followup(id);

ALTER TABLE eml_timeline DROP CONSTRAINT IF EXISTS eml_timeline_id_account_fkey;
ALTER TABLE eml_timeline ADD CONSTRAINT eml_timeline_id_account_fkey FOREIGN KEY (id_account) REFERENCES account(id);

ALTER TABLE eml_timeline DROP CONSTRAINT IF EXISTS eml_timeline_id_account_fkey_1;
ALTER TABLE eml_timeline ADD CONSTRAINT eml_timeline_id_account_fkey_1 FOREIGN KEY (id_account) REFERENCES account(id);

ALTER TABLE eml_timeline DROP CONSTRAINT IF EXISTS eml_timeline_id_address_fkey;
ALTER TABLE eml_timeline ADD CONSTRAINT eml_timeline_id_address_fkey FOREIGN KEY (id_address) REFERENCES eml_address(id);

ALTER TABLE eml_timeline DROP CONSTRAINT IF EXISTS eml_timeline_id_campaign_fkey;
ALTER TABLE eml_timeline ADD CONSTRAINT eml_timeline_id_campaign_fkey FOREIGN KEY (id_campaign) REFERENCES eml_campaign(id);

ALTER TABLE eml_timeline DROP CONSTRAINT IF EXISTS eml_timeline_id_followup_fkey;
ALTER TABLE eml_timeline ADD CONSTRAINT eml_timeline_id_followup_fkey FOREIGN KEY (id_followup) REFERENCES eml_followup(id);

ALTER TABLE eml_unsubscribe DROP CONSTRAINT IF EXISTS eml_unsubscribe_id_delivery_fkey;
ALTER TABLE eml_unsubscribe ADD CONSTRAINT eml_unsubscribe_id_delivery_fkey FOREIGN KEY (id_delivery) REFERENCES eml_delivery(id);

ALTER TABLE eml_upload_leads_job DROP CONSTRAINT IF EXISTS eml_upload_leads_job_id_export_fkey;
ALTER TABLE eml_upload_leads_job ADD CONSTRAINT eml_upload_leads_job_id_export_fkey FOREIGN KEY (id_export) REFERENCES fl_export(id);

ALTER TABLE eml_upload_leads_job DROP CONSTRAINT IF EXISTS eml_upload_leads_job_id_user_fkey;
ALTER TABLE eml_upload_leads_job ADD CONSTRAINT eml_upload_leads_job_id_user_fkey FOREIGN KEY (id_user) REFERENCES "user"(id);

ALTER TABLE eml_upload_leads_mapping DROP CONSTRAINT IF EXISTS eml_upload_leads_mapping_id_upload_leads_job_fkey;
ALTER TABLE eml_upload_leads_mapping ADD CONSTRAINT eml_upload_leads_mapping_id_upload_leads_job_fkey FOREIGN KEY (id_upload_leads_job) REFERENCES eml_upload_leads_job(id);

ALTER TABLE eml_upload_leads_row DROP CONSTRAINT IF EXISTS eml_upload_leads_row_id_lead_fkey;
ALTER TABLE eml_upload_leads_row ADD CONSTRAINT eml_upload_leads_row_id_lead_fkey FOREIGN KEY (id_lead) REFERENCES fl_lead(id);

ALTER TABLE eml_upload_leads_row DROP CONSTRAINT IF EXISTS eml_upload_leads_row_id_lead_fkey_1;
ALTER TABLE eml_upload_leads_row ADD CONSTRAINT eml_upload_leads_row_id_lead_fkey_1 FOREIGN KEY (id_lead) REFERENCES fl_lead(id);

ALTER TABLE eml_upload_leads_row DROP CONSTRAINT IF EXISTS eml_upload_leads_row_id_upload_leads_job_fkey;
ALTER TABLE eml_upload_leads_row ADD CONSTRAINT eml_upload_leads_row_id_upload_leads_job_fkey FOREIGN KEY (id_upload_leads_job) REFERENCES eml_upload_leads_job(id);
