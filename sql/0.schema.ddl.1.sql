-- Timezone must be GTM -3
-- Reference: https://github.com/leandrosardi/mysaas/issues/29
SET TIMEZONE = 'America/Argentina/Buenos_Aires';

-- Static Data (Parameters)
-- - Tables that contains static data that is not expected to change
--

CREATE TABLE IF NOT EXISTS public.country (
	id uuid NOT NULL,
	code varchar(500) NOT NULL,
	"name" varchar(500) NOT NULL,
	CONSTRAINT "primary_country" PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS public.state (
	id uuid NOT NULL,
	code varchar(500) NOT NULL,
	"name" varchar(500) NOT NULL,
	id_country uuid NOT NULL REFERENCES public.country(id),
	CONSTRAINT state_code_id_country_key UNIQUE (code, id_country),
	CONSTRAINT state_pkey PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS public.timeoffset (
	id uuid NOT NULL,
	"region" varchar(500) NOT NULL,
	utc numeric(2) NOT NULL,
	dst numeric(2) NULL,
	CONSTRAINT "primary_timeoffset" PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS public.zipcode (
	value varchar(500) NOT NULL,
	CONSTRAINT "primary_zipcode" PRIMARY KEY (value)
);

CREATE TABLE IF NOT EXISTS public.daily (
	"date" date NOT NULL,
	CONSTRAINT "primary_daily" PRIMARY KEY (date)
);

CREATE TABLE IF NOT EXISTS public.hourly (
	"hour" numeric(18) NOT NULL,
	CONSTRAINT "primary_hourly" PRIMARY KEY (hour)
);

CREATE TABLE IF NOT EXISTS public.minutely (
	"minute" numeric(18) NOT NULL,
	CONSTRAINT "primary_minutely" PRIMARY KEY (minute)
);

CREATE TABLE IF NOT EXISTS public.timezone (
	id uuid NOT NULL,
	"offset" float8 NOT NULL,
	large_description varchar(500) NULL,
	short_description varchar(500) NULL,
	CONSTRAINT "primary_timezone" PRIMARY KEY (id)
);

-- User security tables
-- - users, roles, permissions, etc
-- 

CREATE TABLE IF NOT EXISTS public.account (
	id uuid NOT NULL,
	id_account_owner uuid NOT NULL,
	"name" varchar(500) NOT NULL,
	create_time timestamp NOT NULL,
	delete_time timestamp NULL,
	id_timezone uuid NOT NULL,
	id_user_to_contact uuid NULL,

	api_key varchar(500) NULL,

	disabled_trial bool NULL,
	premium bool NOT NULL DEFAULT false,

	billing_address varchar(500) NULL,
	billing_city varchar(500) NULL,
	billing_state varchar(500) NULL,
	billing_zipcode varchar(500) NULL,
	billing_country varchar(500) NULL,

	update_balance_start_time timestamp NULL,
	update_balance_success bool NULL,
	update_balance_end_time timestamp NULL,
	update_balance_error_description varchar(8000) NULL,

	CONSTRAINT "primary_account" PRIMARY KEY (id),

	--CONSTRAINT fk__account__id_user_to_contact FOREIGN KEY (id_user_to_contact) REFERENCES public."user"(id),
	CONSTRAINT fk_id_account_owner_ref_account FOREIGN KEY (id_account_owner) REFERENCES public.account(id)
);

CREATE TABLE IF NOT EXISTS public."role" (
	id uuid NOT NULL,
	"name" varchar(500) NOT NULL,
	CONSTRAINT "primary_role" PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS public."user" (
	id uuid NOT NULL,
	id_account uuid NOT NULL,
	create_time timestamp NOT NULL,
	delete_time timestamp NULL,
	email varchar(500) NOT NULL,
	"password" varchar(5000) NOT NULL,
	"name" varchar(500) NOT NULL,
	phone varchar(500) NULL,
	verified bool NULL,
	"restricted" bool NOT NULL DEFAULT false,
	CONSTRAINT "primary_user" PRIMARY KEY (id),
	CONSTRAINT user_email_key UNIQUE (email),
	CONSTRAINT fk_id_account_ref_account FOREIGN KEY (id_account) REFERENCES public.account(id)
);

CREATE TABLE IF NOT EXISTS public.user_role (
	id uuid NOT NULL,
	create_time timestamp NOT NULL,
	id_creator uuid NOT NULL,
	id_user uuid NOT NULL,
	id_role uuid NOT NULL,
	CONSTRAINT "primary_user_role" PRIMARY KEY (id),
	CONSTRAINT fk_id_creator_ref_user FOREIGN KEY (id_creator) REFERENCES public."user"(id),
	CONSTRAINT fk_id_role_ref_role FOREIGN KEY (id_role) REFERENCES public."role"(id),
	CONSTRAINT fk_id_user_ref_user FOREIGN KEY (id_user) REFERENCES public."user"(id)
);

CREATE TABLE IF NOT EXISTS public."login" (
	id uuid NOT NULL,
	id_user uuid NOT NULL,
	create_time timestamp NOT NULL,
	id_real_user uuid NULL,
	CONSTRAINT "primary_login" PRIMARY KEY (id),
	CONSTRAINT fk_id_user_ref_user FOREIGN KEY (id_user) REFERENCES public."user"(id),
	CONSTRAINT login_id_real_user_fkey FOREIGN KEY (id_real_user) REFERENCES public."user"(id),
	CONSTRAINT login_id_real_user_fkey_1 FOREIGN KEY (id_real_user) REFERENCES public."user"(id),
	CONSTRAINT login_id_real_user_fkey_2 FOREIGN KEY (id_real_user) REFERENCES public."user"(id)
);

-- Invoicing and Payments Processing Tables
-- 
-- 

CREATE TABLE IF NOT EXISTS public.buffer_paypal_notification (
	id uuid NOT NULL,
	create_time timestamp NOT NULL,
	txn_type varchar(500) NULL,
	subscr_id varchar(500) NULL,
	last_name varchar(500) NULL,
	residence_country varchar(500) NULL,
	mc_currency varchar(500) NULL,
	item_name varchar(500) NULL,
	amount1 varchar(500) NULL,
	business varchar(500) NULL,
	amount3 varchar(500) NULL,
	"recurring" varchar(500) NULL,
	verify_sign varchar(500) NULL,
	payer_status varchar(500) NULL,
	test_ipn varchar(500) NULL,
	payer_email varchar(500) NULL,
	first_name varchar(500) NULL,
	receiver_email varchar(500) NULL,
	payer_id varchar(500) NULL,
	invoice varchar(500) NULL,
	reattempt varchar(500) NULL,
	item_number varchar(500) NULL,
	subscr_date varchar(500) NULL,
	charset varchar(500) NULL,
	notify_version varchar(500) NULL,
	period1 varchar(500) NULL,
	mc_amount1 varchar(500) NULL,
	period3 varchar(500) NULL,
	mc_amount3 varchar(500) NULL,
	ipn_track_id varchar(500) NULL,
	transaction_subject varchar(500) NULL,
	payment_date varchar(500) NULL,
	payment_gross varchar(500) NULL,
	payment_type varchar(500) NULL,
	txn_id varchar(500) NULL,
	receiver_id varchar(500) NULL,
	payment_status varchar(500) NULL,
	payment_fee varchar(500) NULL,
	sync_reservation_time timestamp NULL,
	sync_reservation_times int8 NULL,
	sync_start_time timestamp NULL,
	sync_end_time timestamp NULL,
	sync_result varchar(8000) NULL,
	sync_reservation_id varchar(500) NULL,
	CONSTRAINT "primary_buffer_paypal_notification" PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS public."subscription" (
	id uuid NOT NULL,
	id_buffer_paypal_notification uuid NULL,
	create_time timestamp NOT NULL,
	id_account uuid NULL,
	active bool NOT NULL,
	subscr_id varchar(500) NULL,
	last_name varchar(500) NULL,
	residence_country varchar(500) NULL,
	mc_currency varchar(500) NULL,
	amount1 varchar(500) NULL,
	business varchar(500) NULL,
	amount3 varchar(500) NULL,
	"recurring" varchar(500) NULL,
	verify_sign varchar(500) NULL,
	payer_status varchar(500) NULL,
	test_ipn varchar(500) NULL,
	payer_email varchar(500) NULL,
	first_name varchar(500) NULL,
	receiver_email varchar(500) NULL,
	payer_id varchar(500) NULL,
	invoice varchar(500) NULL,
	reattempt varchar(500) NULL,
	subscr_date varchar(500) NULL,
	charset varchar(500) NULL,
	notify_version varchar(500) NULL,
	period1 varchar(500) NULL,
	mc_amount1 varchar(500) NULL,
	period3 varchar(500) NULL,
	mc_amount3 varchar(500) NULL,
	ipn_track_id varchar(500) NULL,
	CONSTRAINT "primary_subscription" PRIMARY KEY (id),
	CONSTRAINT fk_id_account_ref_account FOREIGN KEY (id_account) REFERENCES public.account(id),
	CONSTRAINT fk_id_buffer_paypal_notification_ref_buffer_paypal_notification FOREIGN KEY (id_buffer_paypal_notification) REFERENCES public.buffer_paypal_notification(id)
);

-- reference: https://github.com/connection-sphere/docs/issues/259
-- 0: PayPal
-- 1: manual payment
alter table "subscription" add column if not exists "type" int not null default 0;  

-- reference: https://github.com/connection-sphere/docs/issues/260
-- cancelation requests
alter table "subscription" add column if not exists "cancellation_requested" boolean not null default false;  
alter table "subscription" add column if not exists "cancellation_request_time" timestamp null;  
alter table "subscription" add column if not exists "cancellation_request_id_user" uuid null references "user"(id);  

CREATE TABLE IF NOT EXISTS public.balance (
	id uuid NOT NULL,
	id_account uuid NOT NULL,
	service_code varchar(500) NOT NULL,
	last_update_time timestamp NOT NULL,
	credits int8 NOT NULL,
	amount numeric(22, 8) NOT NULL,
	CONSTRAINT "primary_balance" PRIMARY KEY (id),
	CONSTRAINT uk_balance UNIQUE (id_account, service_code),
	CONSTRAINT balance_id_account_fkey FOREIGN KEY (id_account) REFERENCES public.account(id)
);

CREATE TABLE IF NOT EXISTS public.invoice (
	id uuid NOT NULL,
	create_time timestamp NOT NULL,
	id_account uuid NOT NULL,
	billing_period_from date NULL,
	billing_period_to date NULL,
	id_buffer_paypal_notification uuid NULL,
	"status" int8 NULL,
	paypal_url varchar(8000) NULL,
	automatic_billing bool NULL,
	subscr_id varchar(500) NULL,
	disabled_trial bool NULL,
	disabled_modification bool NULL,
	id_previous_invoice uuid NULL,
	delete_time timestamp NULL,
	CONSTRAINT "primary_invoice" PRIMARY KEY (id),
	CONSTRAINT fk_id_account_ref_account FOREIGN KEY (id_account) REFERENCES public.account(id),
	CONSTRAINT fk_id_buffer_paypal_notification_ref_buffer_paypal_notification FOREIGN KEY (id_buffer_paypal_notification) REFERENCES public.buffer_paypal_notification(id),
	CONSTRAINT fk_id_previous_invoice_ref_invoice FOREIGN KEY (id_previous_invoice) REFERENCES public.invoice(id)
);

CREATE TABLE IF NOT EXISTS public.invoice_item (
	id uuid NOT NULL,
	id_invoice uuid NOT NULL,
	service_code varchar(500) NOT NULL,
	unit_price numeric(18, 4) NOT NULL,
	units numeric(18, 4) NOT NULL,
	amount numeric(18, 4) NOT NULL,
	detail varchar(500) NOT NULL,
	item_number varchar(500) NULL,
	description varchar(500) NULL,
	create_time timestamp NULL,
	CONSTRAINT "primary_invoice_item" PRIMARY KEY (id),
	CONSTRAINT fk_id_invoice_ref_invoice FOREIGN KEY (id_invoice) REFERENCES public.invoice(id)
);

CREATE TABLE IF NOT EXISTS public.movement (
	id uuid NOT NULL,
	id_account uuid NOT NULL,
	create_time timestamp NOT NULL,
	"type" int8 NOT NULL,
	id_user_creator uuid NULL,
	description text NULL,
	paypal1_amount numeric(22, 8) NOT NULL,
	bonus_amount numeric(22, 8) NOT NULL,
	amount numeric(22, 8) NOT NULL,
	credits int8 NOT NULL,
	profits_amount numeric(22, 8) NOT NULL,
	id_invoice_item uuid NULL,
	service_code varchar(500) NOT NULL,
	expiration_time timestamp NULL,
	expiration_start_time timestamp NULL,
	expiration_end_time timestamp NULL,
	expiration_tries int8 NULL,
	expiration_description varchar(500) NULL,
	expiration_on_next_payment bool NULL,
	expiration_lead_period varchar(500) NULL,
	expiration_lead_units int8 NULL,
	give_away_negative_credits bool NULL,
	CONSTRAINT "primary_movement" PRIMARY KEY (id),
	CONSTRAINT fk_id_account_ref_account FOREIGN KEY (id_account) REFERENCES public.account(id),
	CONSTRAINT fk_id_invoice_item_ref_invoice_item FOREIGN KEY (id_invoice_item) REFERENCES public.invoice_item(id),
	CONSTRAINT fk_id_user_creator_ref_user FOREIGN KEY (id_user_creator) REFERENCES public."user"(id)
);


-- Transactional Emails
-- 
-- 

CREATE TABLE IF NOT EXISTS public.notification (
	id uuid NOT NULL,
	create_time timestamp NOT NULL,
	delivery_time timestamp NULL,
	"type" int8 NOT NULL,
	id_user uuid NOT NULL,
	name_to varchar(500) NOT NULL,
	email_to varchar(500) NOT NULL,
	name_from varchar(500) NOT NULL,
	email_from varchar(500) NOT NULL,
	subject varchar(500) NOT NULL,
	body text NOT NULL,
	CONSTRAINT "primary_notification" PRIMARY KEY (id),
	CONSTRAINT fk_id_user_ref_user FOREIGN KEY (id_user) REFERENCES public."user"(id)
);

ALTER TABLE public.notification ADD COLUMN IF NOT EXISTS id_object uuid NULL;

ALTER TABLE public."user" ADD COLUMN IF NOT EXISTS notification_confirm_email_requested bool NOT NULL DEFAULT false;
ALTER TABLE public."user" ADD COLUMN IF NOT EXISTS notification_reset_password_requested bool NOT NULL DEFAULT false;
ALTER TABLE public."user" ADD COLUMN IF NOT EXISTS notification_you_have_been_added bool NOT NULL DEFAULT false;

CREATE TABLE IF NOT EXISTS public.notification_link (
	id uuid NOT NULL,
	id_notification uuid NOT NULL,
	create_time timestamp NOT NULL,
	link_number int8 NOT NULL,
	url varchar(8000) NOT NULL,
	CONSTRAINT "primary_notification_link" PRIMARY KEY (id),
	CONSTRAINT fk_id_notification_ref_notification FOREIGN KEY (id_notification) REFERENCES public.notification(id)
);

CREATE TABLE IF NOT EXISTS public.notification_click (
	id uuid NOT NULL,
	id_link uuid NOT NULL,
	create_time timestamp NOT NULL,
	id_user uuid NOT NULL,
	CONSTRAINT "primary_notification_click" PRIMARY KEY (id),
	CONSTRAINT fk_id_link_ref_notification_link FOREIGN KEY (id_link) REFERENCES public.notification_link(id),
	CONSTRAINT fk_id_user_ref_user FOREIGN KEY (id_user) REFERENCES public."user"(id)
);

CREATE TABLE IF NOT EXISTS public.notification_open (
	id uuid NOT NULL,
	id_notification uuid NOT NULL,
	create_time timestamp NOT NULL,
	id_user uuid NOT NULL,
	CONSTRAINT "primary_notification_open" PRIMARY KEY (id),
	CONSTRAINT fk_id_notification_ref_notification FOREIGN KEY (id_notification) REFERENCES public.notification(id),
	CONSTRAINT fk_id_user_ref_user FOREIGN KEY (id_user) REFERENCES public."user"(id)
);


-- User Preferences
-- 
-- 

CREATE TABLE IF NOT EXISTS public.preference_history (
	id uuid NOT NULL,
	update_time timestamp NOT NULL,
	delete_time timestamp NULL,
	id_user uuid NOT NULL,
	create_time timestamp NOT NULL,
	"name" varchar(500) NOT NULL,
	"type" int8 NOT NULL,
	value_string varchar(8000) NULL,
	value_int int8 NULL,
	value_float float8 NULL,
	value_bool bool NULL,
	CONSTRAINT "primary_preference_history" PRIMARY KEY (id, update_time)
);

CREATE TABLE IF NOT EXISTS public.preference (
	id uuid NOT NULL,
	id_user uuid NOT NULL,
	create_time timestamp NOT NULL,
	"name" varchar(500) NOT NULL,
	"type" int8 NOT NULL,
	value_string varchar(8000) NULL,
	value_int int8 NULL,
	value_float float8 NULL,
	value_bool bool NULL,
	CONSTRAINT "primary_preference" PRIMARY KEY (id),
	CONSTRAINT fk_id_user_ref_user FOREIGN KEY (id_user) REFERENCES public."user"(id)
);

-- This line works in PostgeSQL only.
-- It is commented to keep portability with CockroachDB.
-- Run this line manually in your database.
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";