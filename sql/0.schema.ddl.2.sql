CREATE TABLE IF NOT EXISTS fl_headcount (
	id uuid NOT NULL,
	code varchar(500) NOT NULL,
	name varchar(8000) NOT NULL,
	CONSTRAINT fl_headcount_code_key UNIQUE (code ASC),
	CONSTRAINT fl_headcount_pkey PRIMARY KEY (id ASC)
);

CREATE TABLE IF NOT EXISTS fl_industry (
	id uuid NOT NULL,
	code varchar(500) NOT NULL,
	name varchar(8000) NULL,
	CONSTRAINT "primary" PRIMARY KEY (id ASC)
);


CREATE TABLE IF NOT EXISTS fl_location (
	id uuid NOT NULL,
	name varchar(8000) NULL,
	code varchar(500) NOT NULL,
	id_country uuid NULL,
	is_state bool NOT NULL DEFAULT false,
	CONSTRAINT "primary" PRIMARY KEY (id ASC)
);

CREATE TABLE IF NOT EXISTS fl_naics (
	id uuid NOT NULL,
	code varchar(500) NOT NULL,
	name varchar(8000) NOT NULL,
	CONSTRAINT fl_naics_code_key UNIQUE (code ASC),
	CONSTRAINT fl_naics_pkey PRIMARY KEY (id ASC)
);

CREATE TABLE IF NOT EXISTS fl_revenue (
	id uuid NOT NULL,
	code varchar(500) NOT NULL,
	name varchar(8000) NOT NULL,
	CONSTRAINT fl_revenue_code_key UNIQUE (code ASC),
	CONSTRAINT fl_revenue_pkey PRIMARY KEY (id ASC)
);

CREATE TABLE IF NOT EXISTS fl_sic (
	id uuid NOT NULL,
	code varchar(500) NOT NULL,
	name varchar(8000) NOT NULL,
	CONSTRAINT fl_sic_code_key UNIQUE (code ASC),
	CONSTRAINT fl_sic_pkey PRIMARY KEY (id ASC)
);

CREATE TABLE IF NOT EXISTS fl_company (
	id uuid NOT NULL,
	name varchar(8000) NULL,
	url varchar(8000) NULL,
	naics_codes varchar(8000) NULL,
	sic_codes varchar(8000) NULL,
	address varchar(8000) NULL,
	zipcode varchar(8000) NULL,
	id_revenue uuid NULL,
	id_headcount uuid NULL,
	linkedin_url varchar(8000) NULL,
	insight1 varchar(500) NULL,
	insight1_end_time timestamp NULL,
	insight2 text NULL,
	insight2_end_time timestamp NULL,
	id_user uuid NULL,
	meta_description varchar(8000) NULL,
	title varchar(8000) NULL,
	meta_keywords varchar(8000) NULL,
	CONSTRAINT "primary" PRIMARY KEY (id ASC)
);

CREATE TABLE IF NOT EXISTS fl_data (
	id uuid NOT NULL,
	id_lead uuid NULL,
	"type" int8 NOT NULL,
	value varchar(8000) NOT NULL,
	verify_reservation_times int8 NULL,
	verify_reservation_time timestamp NULL,
	verify_start_time timestamp NULL,
	verify_end_time timestamp NULL,
	verify_success bool NULL,
	verify_error_description text NULL,
	custom_field_name varchar(500) NULL,
	trust_rate int8 NULL,
	delete_time timestamp NULL,
	verified bool NULL,
	verify_reservation_id varchar(500) NULL,
	double_check_verification_success bool NULL,
	double_check_verification_error_description varchar(8000) NULL,
	create_time timestamp NULL,
	id_user uuid NULL,
	zb_address varchar(500) NULL,
	zb_status varchar(500) NULL,
	zb_sub_status varchar(500) NULL,
	zb_free_email varchar(500) NULL,
	zb_did_you_mean varchar(500) NULL,
	zb_account varchar(500) NULL,
	zb_domain varchar(500) NULL,
	zb_domain_age_days varchar(500) NULL,
	zb_smtp_provider varchar(500) NULL,
	zb_mx_found varchar(500) NULL,
	zb_mx_record varchar(500) NULL,
	zb_firstname varchar(500) NULL,
	zb_lastname varchar(500) NULL,
	zb_gender varchar(500) NULL,
	zb_country varchar(500) NULL,
	zb_region varchar(500) NULL,
	zb_city varchar(500) NULL,
	zb_zipcode varchar(500) NULL,
	zb_processed_at varchar(500) NULL,
	ev_status varchar(500) NULL,
	db_status int8 NULL,
	double_check_verification_requested bool NOT NULL DEFAULT false,
	mail_handler varchar(8000) NULL,
	mail_handler_reservation_id varchar(500) NULL,
	mail_handler_reservation_time timestamp NULL,
	mail_handler_reservation_times int8 NULL,
	mail_handler_start_time timestamp NULL,
	mail_handler_end_time timestamp NULL,
	mail_handler_success bool NULL,
	mail_handler_error_description varchar(8000) NULL,
	"source" varchar(500) NULL,
	CONSTRAINT "primary" PRIMARY KEY (id ASC)
);

CREATE TABLE IF NOT EXISTS fl_lead (
	id uuid NOT NULL,
	name varchar(8000) NOT NULL,
	"position" varchar(8000) NULL,
	id_company uuid NULL,
	id_industry uuid NULL,
	id_location uuid NULL,
	stat_has_email bool NULL,
	stat_has_phone bool NULL,
	stat_company_name varchar(8000) NULL,
	stat_industry_name varchar(8000) NULL,
	stat_location_name varchar(8000) NULL,
	stat_naics_codes varchar(8000) NULL,
	stat_sic_codes varchar(8000) NULL,
	response_rate int8 NULL,
	stat_revenue varchar(8000) NULL,
	stat_headcount varchar(8000) NULL,
	id_user uuid NULL,
	public bool NOT NULL DEFAULT true,
	enrich_reservation_id varchar(500) NULL,
	enrich_reservation_time timestamp NULL,
	enrich_reservation_times int8 NULL,
	enrich_start_time timestamp NULL,
	enrich_end_time timestamp NULL,
	enrich_success bool NULL,
	enrich_error_description text NULL,
	stat_verified bool NULL,
	stat_trust_rate int8 NULL,
	create_time timestamp NULL,
	linkedin_picture_url varchar(8000) NULL,
	picture_url varchar(8000) NULL,
	stat_city_name varchar(8000) NULL,
	stat_state_name varchar(8000) NULL,
	stat_country_name varchar(8000) NULL,
	stat_area_name varchar(8000) NULL,
	picture_download_error_description varchar(8000) NULL,
	picture_download_success bool NULL,
	id_user_creator uuid NULL,
	id_user_uploader uuid NULL,
	delete_time timestamp NULL,
	stat_personal_verified_email bool NOT NULL DEFAULT false,
	stat_corporate_verified_email bool NOT NULL DEFAULT false,
	CONSTRAINT "primary" PRIMARY KEY (id ASC)
);

CREATE TABLE IF NOT EXISTS fl_reminder (
	id uuid NOT NULL,
	create_time timestamp NOT NULL,
	id_user uuid NOT NULL,
	id_lead uuid NOT NULL,
	description varchar(8000) NULL,
	expiration_time timestamp NOT NULL,
	done bool NOT NULL,
	delete_time timestamp NULL,
	CONSTRAINT fl_reminder_pkey PRIMARY KEY (id ASC)
);




CREATE TABLE IF NOT EXISTS fl_search (
	id uuid NOT NULL,
	id_user uuid NULL,
	name varchar(8000) NULL,
	create_time timestamp NOT NULL,
	no_of_results int8 NULL,
	no_of_companies int8 NULL,
	description varchar(8000) NULL,
	saved bool NOT NULL,
	"temp" bool NULL,
	delete_time timestamp NULL,
	stat_start_time timestamp NULL,
	stat_end_time timestamp NULL,
	stat_success bool NULL,
	stat_error_description varchar(8000) NULL,
	company_only bool NOT NULL DEFAULT false,
	phone_only bool NOT NULL DEFAULT false,
	pull_request_status int8 NULL,
	pull_request_results int8 NULL,
	pull_request_pulled int8 NULL,
	pull_request_verified_emails_only bool NULL,
	pull_request_avoid_catchall_emails bool NULL,
	posted_in_last_30_days bool NULL,
	verified_only bool NULL,
	min_trust_rate int8 NULL,
	private_only bool NULL,
	id_order uuid NULL,
	lead_name varchar(500) NULL,
	email_only bool NOT NULL DEFAULT false,
	id_export uuid NULL,
	CONSTRAINT "primary" PRIMARY KEY (id ASC)
);

CREATE TABLE IF NOT EXISTS fl_search_company (
	id uuid NOT NULL,
	value varchar(500) NOT NULL,
	id_search uuid NOT NULL,
	positive bool NOT NULL,
	CONSTRAINT fl_search_company_pkey PRIMARY KEY (id ASC)
);


CREATE TABLE IF NOT EXISTS fl_search_headcount (
	id uuid NOT NULL,
	id_headcount uuid NOT NULL,
	id_search uuid NOT NULL,
	positive bool NOT NULL,
	CONSTRAINT fl_search_headcount_pkey PRIMARY KEY (id ASC)
);


CREATE TABLE IF NOT EXISTS fl_search_industry (
	id uuid NOT NULL,
	id_industry uuid NULL,
	id_search uuid NULL,
	positive bool NULL,
	CONSTRAINT "primary" PRIMARY KEY (id ASC)
);

CREATE TABLE IF NOT EXISTS fl_search_location (
	id uuid NOT NULL,
	value varchar(8000) NOT NULL,
	id_search uuid NULL,
	positive bool NULL,
	CONSTRAINT "primary" PRIMARY KEY (id ASC)
);

CREATE TABLE IF NOT EXISTS fl_search_naics (
	id uuid NOT NULL,
	id_naics uuid NOT NULL,
	id_search uuid NOT NULL,
	positive bool NOT NULL,
	CONSTRAINT fl_search_naics_pkey PRIMARY KEY (id ASC)
);

CREATE TABLE IF NOT EXISTS fl_search_position (
	id uuid NOT NULL,
	id_search uuid NULL,
	positive bool NULL,
	value varchar(8000) NOT NULL,
	CONSTRAINT "primary" PRIMARY KEY (id ASC)
);

CREATE TABLE IF NOT EXISTS fl_search_revenue (
	id uuid NOT NULL,
	id_revenue uuid NOT NULL,
	id_search uuid NOT NULL,
	positive bool NOT NULL,
	CONSTRAINT fl_search_revenue_pkey PRIMARY KEY (id ASC)
);

CREATE TABLE IF NOT EXISTS fl_search_sic (
	id uuid NOT NULL,
	id_sic uuid NOT NULL,
	id_search uuid NOT NULL,
	positive bool NOT NULL,
	CONSTRAINT fl_search_sic_pkey PRIMARY KEY (id ASC)
);


CREATE TABLE IF NOT EXISTS fl_export (
	id uuid NOT NULL,
	id_user uuid NULL,
	id_search uuid NULL,
	create_time timestamp NOT NULL,
	allow_multiple_contacts_per_company bool NULL,
	number_of_records int8 NULL,
	filename varchar(8000) NULL,
	create_file_start_time timestamp NULL,
	create_file_end_time timestamp NULL,
	create_file_success bool NULL,
	create_file_error_description varchar(8000) NULL,
	no_of_results int8 NULL,
	no_of_companies int8 NULL,
	create_file_reservation_time timestamp NULL,
	create_file_reservation_times int8 NULL,
	create_file_reservation_id varchar(500) NULL,
	continious_restarting bool NOT NULL DEFAULT false,
	delete_time timestamp NULL,
	download_url varchar(8000) NULL,
	archive_end_time timestamp NULL,
	archive_start_time timestamp NULL,
	archive_success bool NULL,
	archive_error_description varchar(8000) NULL,
	CONSTRAINT "primary" PRIMARY KEY (id ASC)
);

CREATE TABLE IF NOT EXISTS fl_export_lead (
	id uuid NOT NULL,
	id_export uuid NULL,
	id_lead uuid NULL,
	delete_time timestamp NULL,
	added_manually bool NULL,
	create_time timestamp NOT NULL,
	id_user uuid NULL,
	hide_data bool NOT NULL DEFAULT false,
	CONSTRAINT "primary" PRIMARY KEY (id ASC)
);

ALTER TABLE fl_company DROP constraint if EXISTS fl_company_id_headcount_fkey;
ALTER TABLE fl_company ADD CONSTRAINT fl_company_id_headcount_fkey FOREIGN KEY (id_headcount) REFERENCES fl_headcount(id);

ALTER TABLE fl_company DROP constraint if EXISTS fl_company_id_headcount_fkey_1;
ALTER TABLE fl_company ADD CONSTRAINT fl_company_id_headcount_fkey_1 FOREIGN KEY (id_headcount) REFERENCES fl_headcount(id);

ALTER TABLE fl_company DROP constraint if EXISTS fl_company_id_headcount_fkey_2;
ALTER TABLE fl_company ADD CONSTRAINT fl_company_id_headcount_fkey_2 FOREIGN KEY (id_headcount) REFERENCES fl_headcount(id);

ALTER TABLE fl_company DROP constraint if EXISTS fl_company_id_headcount_fkey_3;
ALTER TABLE fl_company ADD CONSTRAINT fl_company_id_headcount_fkey_3 FOREIGN KEY (id_headcount) REFERENCES fl_headcount(id);

ALTER TABLE fl_company DROP constraint if EXISTS fl_company_id_revenue_fkey;
ALTER TABLE fl_company ADD CONSTRAINT fl_company_id_revenue_fkey FOREIGN KEY (id_revenue) REFERENCES fl_revenue(id);

ALTER TABLE fl_company DROP constraint if EXISTS fl_company_id_revenue_fkey_1;
ALTER TABLE fl_company ADD CONSTRAINT fl_company_id_revenue_fkey_1 FOREIGN KEY (id_revenue) REFERENCES fl_revenue(id);

ALTER TABLE fl_company DROP constraint if EXISTS fl_company_id_revenue_fkey_2;
ALTER TABLE fl_company ADD CONSTRAINT fl_company_id_revenue_fkey_2 FOREIGN KEY (id_revenue) REFERENCES fl_revenue(id);

ALTER TABLE fl_company DROP constraint if EXISTS fl_company_id_user_fkey;
ALTER TABLE fl_company ADD CONSTRAINT fl_company_id_user_fkey FOREIGN KEY (id_user) REFERENCES "user"(id);

ALTER TABLE fl_data DROP constraint if EXISTS fk_id_lead_ref_fl_lead;
ALTER TABLE fl_data ADD CONSTRAINT fk_id_lead_ref_fl_lead FOREIGN KEY (id_lead) REFERENCES fl_lead(id);

ALTER TABLE fl_data DROP constraint if EXISTS fl_data_id_user_fkey;
ALTER TABLE fl_data ADD CONSTRAINT fl_data_id_user_fkey FOREIGN KEY (id_user) REFERENCES "user"(id);

ALTER TABLE fl_lead DROP constraint if EXISTS fk_id_company_ref_fl_company;
ALTER TABLE fl_lead ADD CONSTRAINT fk_id_company_ref_fl_company FOREIGN KEY (id_company) REFERENCES fl_company(id);

ALTER TABLE fl_lead DROP constraint if EXISTS fk_id_industry_ref_fl_industry;
ALTER TABLE fl_lead ADD CONSTRAINT fk_id_industry_ref_fl_industry FOREIGN KEY (id_industry) REFERENCES fl_industry(id);

ALTER TABLE fl_lead DROP constraint if EXISTS fk_id_location_ref_fl_location;
ALTER TABLE fl_lead ADD CONSTRAINT fk_id_location_ref_fl_location FOREIGN KEY (id_location) REFERENCES fl_location(id);

ALTER TABLE fl_lead DROP constraint if EXISTS fl_lead_id_user_creator_fkey;
ALTER TABLE fl_lead ADD CONSTRAINT fl_lead_id_user_creator_fkey FOREIGN KEY (id_user_creator) REFERENCES "user"(id);

ALTER TABLE fl_lead DROP constraint if EXISTS fl_lead_id_user_creator_fkey_1;
ALTER TABLE fl_lead ADD CONSTRAINT fl_lead_id_user_creator_fkey_1 FOREIGN KEY (id_user_creator) REFERENCES "user"(id);

ALTER TABLE fl_lead DROP constraint if EXISTS fl_lead_id_user_fkey;
ALTER TABLE fl_lead ADD CONSTRAINT fl_lead_id_user_fkey FOREIGN KEY (id_user) REFERENCES "user"(id);

ALTER TABLE fl_lead DROP constraint if EXISTS fl_lead_id_user_fkey_1;
ALTER TABLE fl_lead ADD CONSTRAINT fl_lead_id_user_fkey_1 FOREIGN KEY (id_user) REFERENCES "user"(id);

ALTER TABLE fl_lead DROP constraint if EXISTS fl_lead_id_user_fkey_2;
ALTER TABLE fl_lead ADD CONSTRAINT fl_lead_id_user_fkey_2 FOREIGN KEY (id_user) REFERENCES "user"(id);

ALTER TABLE fl_lead DROP constraint if EXISTS fl_lead_id_user_fkey_3;
ALTER TABLE fl_lead ADD CONSTRAINT fl_lead_id_user_fkey_3 FOREIGN KEY (id_user) REFERENCES "user"(id);

ALTER TABLE fl_lead DROP constraint if EXISTS fl_lead_id_user_fkey_4;
ALTER TABLE fl_lead ADD CONSTRAINT fl_lead_id_user_fkey_4 FOREIGN KEY (id_user) REFERENCES "user"(id);

ALTER TABLE fl_lead DROP constraint if EXISTS fl_lead_id_user_fkey_5;
ALTER TABLE fl_lead ADD CONSTRAINT fl_lead_id_user_fkey_5 FOREIGN KEY (id_user) REFERENCES "user"(id);

ALTER TABLE fl_lead DROP constraint if EXISTS fl_lead_id_user_fkey_6;
ALTER TABLE fl_lead ADD CONSTRAINT fl_lead_id_user_fkey_6 FOREIGN KEY (id_user) REFERENCES "user"(id);

ALTER TABLE fl_lead DROP constraint if EXISTS fl_lead_id_user_uploader_fkey;
ALTER TABLE fl_lead ADD CONSTRAINT fl_lead_id_user_uploader_fkey FOREIGN KEY (id_user_uploader) REFERENCES "user"(id);

ALTER TABLE fl_lead DROP constraint if EXISTS fl_lead_id_user_uploader_fkey_1;
ALTER TABLE fl_lead ADD CONSTRAINT fl_lead_id_user_uploader_fkey_1 FOREIGN KEY (id_user_uploader) REFERENCES "user"(id);

ALTER TABLE fl_reminder DROP constraint if EXISTS fl_reminder_id_lead_fkey;
ALTER TABLE fl_reminder ADD CONSTRAINT fl_reminder_id_lead_fkey FOREIGN KEY (id_lead) REFERENCES fl_lead(id);

ALTER TABLE fl_reminder DROP constraint if EXISTS fl_reminder_id_user_fkey;
ALTER TABLE fl_reminder ADD CONSTRAINT fl_reminder_id_user_fkey FOREIGN KEY (id_user) REFERENCES "user"(id);

ALTER TABLE fl_search DROP constraint if EXISTS fk_id_user_ref_user;
ALTER TABLE fl_search ADD CONSTRAINT fk_id_user_ref_user FOREIGN KEY (id_user) REFERENCES "user"(id);

ALTER TABLE fl_search_company DROP constraint if EXISTS fl_search_company_id_search_fkey;
ALTER TABLE fl_search_company ADD CONSTRAINT fl_search_company_id_search_fkey FOREIGN KEY (id_search) REFERENCES fl_search(id);

ALTER TABLE fl_search_headcount DROP constraint if EXISTS fl_search_headcount_id_headcount_fkey;
ALTER TABLE fl_search_headcount ADD CONSTRAINT fl_search_headcount_id_headcount_fkey FOREIGN KEY (id_headcount) REFERENCES fl_headcount(id);

ALTER TABLE fl_search_headcount DROP constraint if EXISTS fl_search_headcount_id_search_fkey;
ALTER TABLE fl_search_headcount ADD CONSTRAINT fl_search_headcount_id_search_fkey FOREIGN KEY (id_search) REFERENCES fl_search(id);

ALTER TABLE fl_search_industry DROP constraint if EXISTS fk_id_industry_ref_fl_industry;
ALTER TABLE fl_search_industry ADD CONSTRAINT fk_id_industry_ref_fl_industry FOREIGN KEY (id_industry) REFERENCES fl_industry(id);

ALTER TABLE fl_search_industry DROP constraint if EXISTS fk_id_search_ref_fl_search;
ALTER TABLE fl_search_industry ADD CONSTRAINT fk_id_search_ref_fl_search FOREIGN KEY (id_search) REFERENCES fl_search(id);

ALTER TABLE fl_search_location DROP constraint if EXISTS fk_id_search_ref_fl_search;
ALTER TABLE fl_search_location ADD CONSTRAINT fk_id_search_ref_fl_search FOREIGN KEY (id_search) REFERENCES fl_search(id);

ALTER TABLE fl_search_naics DROP constraint if EXISTS fl_search_naics_id_naics_fkey;
ALTER TABLE fl_search_naics ADD CONSTRAINT fl_search_naics_id_naics_fkey FOREIGN KEY (id_naics) REFERENCES fl_naics(id);

ALTER TABLE fl_search_naics DROP constraint if EXISTS fl_search_naics_id_search_fkey;
ALTER TABLE fl_search_naics ADD CONSTRAINT fl_search_naics_id_search_fkey FOREIGN KEY (id_search) REFERENCES fl_search(id);

ALTER TABLE fl_search_revenue DROP constraint if EXISTS fl_search_revenue_id_revenue_fkey;
ALTER TABLE fl_search_revenue ADD CONSTRAINT fl_search_revenue_id_revenue_fkey FOREIGN KEY (id_revenue) REFERENCES fl_revenue(id);

ALTER TABLE fl_search_revenue DROP constraint if EXISTS fl_search_revenue_id_search_fkey;
ALTER TABLE fl_search_revenue ADD CONSTRAINT fl_search_revenue_id_search_fkey FOREIGN KEY (id_search) REFERENCES fl_search(id);

ALTER TABLE fl_search_sic DROP constraint if EXISTS fl_search_sic_id_search_fkey;
ALTER TABLE fl_search_sic ADD CONSTRAINT fl_search_sic_id_search_fkey FOREIGN KEY (id_search) REFERENCES fl_search(id);

ALTER TABLE fl_search_sic DROP constraint if EXISTS fl_search_sic_id_sic_fkey;
ALTER TABLE fl_search_sic ADD CONSTRAINT fl_search_sic_id_sic_fkey FOREIGN KEY (id_sic) REFERENCES fl_sic(id);

ALTER TABLE fl_export DROP constraint if EXISTS fk_id_search_ref_fl_search;
ALTER TABLE fl_export ADD CONSTRAINT fk_id_search_ref_fl_search FOREIGN KEY (id_search) REFERENCES public.fl_search(id);

ALTER TABLE fl_export DROP constraint if EXISTS fk_id_user_ref_user;
ALTER TABLE fl_export ADD CONSTRAINT fk_id_user_ref_user FOREIGN KEY (id_user) REFERENCES public."user"(id);

ALTER TABLE fl_export_lead DROP constraint if EXISTS fk_fl_export_lead__id_user;
ALTER TABLE fl_export_lead ADD CONSTRAINT fk_fl_export_lead__id_user FOREIGN KEY (id_user) REFERENCES public."user"(id);

ALTER TABLE fl_export_lead DROP constraint if EXISTS fk_id_export_ref_fl_export;
ALTER TABLE fl_export_lead ADD CONSTRAINT fk_id_export_ref_fl_export FOREIGN KEY (id_export) REFERENCES public.fl_export(id);

ALTER TABLE fl_export_lead DROP constraint if EXISTS fk_id_lead_ref_fl_lead;
ALTER TABLE fl_export_lead ADD CONSTRAINT fk_id_lead_ref_fl_lead FOREIGN KEY (id_lead) REFERENCES public.fl_lead(id);
