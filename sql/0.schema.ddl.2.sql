--this is for postrges only. 
--cockroach does not need it.
-- CREATE EXTENSION if not exists "uuid-ossp";

CREATE TABLE IF NOT EXISTS public.zi_company_headcount (
	value varchar(8000) NOT NULL,
	CONSTRAINT zi_company_headcount_pkey PRIMARY KEY (value)
);

CREATE TABLE IF NOT EXISTS public.zi_company_revenue (
	value varchar(8000) NOT NULL,
	CONSTRAINT zi_company_revenue_pkey PRIMARY KEY (value)
);

CREATE TABLE IF NOT EXISTS public.zi_department (
	value varchar(8000) NOT NULL,
	CONSTRAINT zi_department_pkey PRIMARY KEY (value)
);

CREATE TABLE IF NOT EXISTS public.zi_industry (
	value varchar(8000) NOT NULL,
	CONSTRAINT zi_industry_pkey PRIMARY KEY (value)
);

CREATE TABLE IF NOT EXISTS public.zi_search (
	id uuid NOT NULL,
	id_account uuid NOT NULL references account(id), -- account owner of this search.
	id_user uuid NOT NULL references "user"(id), -- user creator of this search. it may be a support agent.
	stop_limit int8 NOT NULL DEFAULT 100,
	--last_csv_file int4 NOT NULL DEFAULT 0,
	"name" varchar(80000) NOT NULL,
	status bool NOT NULL DEFAULT true,
	--thread_number int4 NULL,
	create_time timestamp NULL,
	stat_tier1_scope int8 NULL,
	stat_tier2_scope int8 NULL,
	stat_processed_results int8 NULL,
	stat_verified_results int8 NULL,
	stat_tier3_scope int8 NULL,
	earning_per_verified_email float8 NULL,
	stat_profit float8 NULL,
	stat_earning float8 NULL,
	stat_cost float8 NULL,
	--credits int8 NOT NULL DEFAULT 0,
	verify_email bool NOT NULL DEFAULT true,
	insight_source int4 NULL,
	insight_prompt1 varchar(8000) NULL,
	insight_prompt2 varchar(8000) NULL,
	insight_positive_response_pattern varchar(8000) NULL,
	insight_negative_response_pattern varchar(8000) NULL,
	export_download_url varchar(8000) NULL,
	export_time timestamp NULL,
	CONSTRAINT zi_search_pkey PRIMARY KEY (id)
);

alter table zi_search add column if not exists stat_progress float not null default 0;

alter table zi_search add column if not exists stat_revenue float not null default 0;

--alter table zi_search add column if not exists insight_source int null;

alter table zi_search add column if not exists delete_time timestamp null;

alter table zi_search add column if not exists insight_template int4 null;

alter table zi_search add column if not exists insight_requirement int4 null;

alter table zi_search add column if not exists insight_enabled boolean not null default false;

alter table zi_search add column if not exists badge_color varchar(500) null;

alter table zi_search add column if not exists badge_text varchar(500) null;

alter table zi_search add column if not exists micro_data_node varchar(500) null;
alter table zi_search add column if not exists micro_data_push_time timestamp null;
alter table zi_search add column if not exists micro_data_push_success boolean null;
alter table zi_search add column if not exists micro_data_push_error_description varchar(8000) null;

CREATE TABLE IF NOT EXISTS public.zi_seniority (
	value varchar(8000) NOT NULL,
	CONSTRAINT zi_seniority_pkey PRIMARY KEY (value)
);

CREATE TABLE IF NOT EXISTS public.zi_sic (
	value varchar(8000) NOT NULL,
	CONSTRAINT zi_sic_pkey PRIMARY KEY (value)
);

CREATE TABLE IF NOT EXISTS public.zi_state (
	value varchar(8000) NOT NULL,
	CONSTRAINT zi_state_pkey PRIMARY KEY (value)
);

CREATE TABLE IF NOT EXISTS public.zi_search_company_headcount (
	id uuid NOT NULL,
	id_search uuid NOT NULL,
	value varchar(80000) NOT NULL,
	positive bool NOT NULL DEFAULT true,
	CONSTRAINT zi_search_company_headcount_pkey PRIMARY KEY (id),
	CONSTRAINT zi_search_company_headcount_id_search_fkey FOREIGN KEY (id_search) REFERENCES public.zi_search(id),
	CONSTRAINT zi_search_company_headcount_value_fkey FOREIGN KEY (value) REFERENCES public.zi_company_headcount(value)
);

CREATE TABLE IF NOT EXISTS public.zi_search_company_revenue (
	id uuid NOT NULL,
	id_search uuid NOT NULL,
	value varchar(80000) NOT NULL,
	positive bool NOT NULL DEFAULT true,
	CONSTRAINT zi_search_company_revenue_pkey PRIMARY KEY (id),
	CONSTRAINT zi_search_company_revenue_id_search_fkey FOREIGN KEY (id_search) REFERENCES public.zi_search(id),
	CONSTRAINT zi_search_company_revenue_value_fkey FOREIGN KEY (value) REFERENCES public.zi_company_revenue(value)
);

CREATE TABLE IF NOT EXISTS public.zi_search_department (
	id uuid NOT NULL,
	id_search uuid NOT NULL,
	value varchar(80000) NOT NULL,
	positive bool NOT NULL DEFAULT true,
	CONSTRAINT zi_search_department_pkey PRIMARY KEY (id),
	CONSTRAINT zi_search_department_id_search_fkey FOREIGN KEY (id_search) REFERENCES public.zi_search(id),
	CONSTRAINT zi_search_department_value_fkey FOREIGN KEY (value) REFERENCES public.zi_department(value)
);

CREATE TABLE IF NOT EXISTS public.zi_search_industry (
	id uuid NOT NULL,
	id_search uuid NOT NULL,
	value varchar(80000) NOT NULL,
	positive bool NOT NULL DEFAULT true,
	CONSTRAINT zi_search_industry_pkey PRIMARY KEY (id),
	CONSTRAINT zi_search_industry_id_search_fkey FOREIGN KEY (id_search) REFERENCES public.zi_search(id)
);

CREATE TABLE IF NOT EXISTS public.zi_search_job_title (
	id uuid NOT NULL,
	id_search uuid NOT NULL,
	value varchar(80000) NOT NULL,
	positive bool NOT NULL DEFAULT true,
	CONSTRAINT zi_search_job_title_pkey PRIMARY KEY (id),
	CONSTRAINT zi_search_job_title_id_search_fkey FOREIGN KEY (id_search) REFERENCES public.zi_search(id)
);

CREATE TABLE IF NOT EXISTS public.zi_search_keyword (
	id uuid NOT NULL,
	id_search uuid NOT NULL,
	value varchar(80000) NOT NULL,
	CONSTRAINT zi_search_keyword_pkey PRIMARY KEY (id),
	CONSTRAINT zi_search_keyword_id_search_fkey FOREIGN KEY (id_search) REFERENCES public.zi_search(id)
);

CREATE TABLE IF NOT EXISTS public.zi_search_company_name (
	id uuid NOT NULL,
	id_search uuid NOT NULL,
	value varchar(80000) NOT NULL,
	CONSTRAINT zi_search_company_name_pkey PRIMARY KEY (id),
	CONSTRAINT zi_search_company_name_id_search_fkey FOREIGN KEY (id_search) REFERENCES public.zi_search(id)
);

CREATE TABLE IF NOT EXISTS public.zi_search_company_domain (
	id uuid NOT NULL,
	id_search uuid NOT NULL,
	value varchar(80000) NOT NULL,
	CONSTRAINT zi_search_company_domain_pkey PRIMARY KEY (id),
	CONSTRAINT zi_search_company_domain_id_search_fkey FOREIGN KEY (id_search) REFERENCES public.zi_search(id)
);

alter table zi_search_company_name add column if not exists positive boolean not null default true;
alter table zi_search_company_domain add column if not exists positive boolean not null default true;

CREATE TABLE IF NOT EXISTS public.zi_search_seniority (
	id uuid NOT NULL,
	id_search uuid NOT NULL,
	value varchar(80000) NOT NULL,
	positive bool NOT NULL DEFAULT true,
	CONSTRAINT zi_search_seniority_pkey PRIMARY KEY (id),
	CONSTRAINT zi_search_seniority_id_search_fkey FOREIGN KEY (id_search) REFERENCES public.zi_search(id),
	CONSTRAINT zi_search_seniority_value_fkey FOREIGN KEY (value) REFERENCES public.zi_seniority(value)
);

CREATE TABLE IF NOT EXISTS public.zi_search_sic (
	id uuid NOT NULL,
	id_search uuid NOT NULL,
	value varchar(80000) NOT NULL,
	positive bool NOT NULL DEFAULT true,
	CONSTRAINT zi_search_sic_pkey PRIMARY KEY (id),
	CONSTRAINT zi_search_sic_id_search_fkey FOREIGN KEY (id_search) REFERENCES public.zi_search(id),
	CONSTRAINT zi_search_sic_value_fkey FOREIGN KEY (value) REFERENCES public.zi_sic(value)
);

CREATE TABLE IF NOT EXISTS public.zi_search_state (
	id uuid NOT NULL,
	id_search uuid NOT NULL,
	value varchar(80000) NOT NULL,
	positive bool NOT NULL DEFAULT true,
	CONSTRAINT zi_search_state_pkey PRIMARY KEY (id),
	CONSTRAINT zi_search_state_id_search_fkey FOREIGN KEY (id_search) REFERENCES public.zi_search(id),
	CONSTRAINT zi_search_state_value_fkey FOREIGN KEY (value) REFERENCES public.zi_state(value)
);

-----------------------------------------------------

alter table zi_search add column if not exists stat_tier3_scope int8 null;
alter table zi_search add column if not exists stat_tier4_scope int8 null;
alter table zi_search add column if not exists stat_tier5_scope int8 null;

alter table zi_search_keyword add column if not exists "type" int4 not null default 0;

-- Direct phone number filte
-- https://github.com/ConnectionSphere/micro.data/issues/14
alter table zi_search add column if not exists direct_phone_number_only boolean not null default false;

-- Drain search
-- https://github.com/ConnectionSphere/micro.data/issues/18
alter table zi_search add column if not exists auto_drain boolean not null default true;

-- credits must be a float number
-- https://github.com/FreeLeadsData/app/issues/2
--ALTER TABLE zi_search ALTER COLUMN credits TYPE FLOAT USING (credits::float);

-- snapshot the price_per_record for an account, based on average rate of all its invoices
-- https://github.com/FreeLeadsData/app/issues/2
ALTER TABLE account ADD COLUMN IF NOT EXISTS price_per_record FLOAT NOT NULL DEFAULT 0;

-- async search push
-- https://github.com/FreeLeadsData/app/issues/11
alter table zi_search add column if not exists update_time timestamp not null default '1900-01-01';

-- daily quota tracking
-- https://github.com/FreeLeadsData/app/issues/12
create table if not exists zi_timeline (
	id uuid not null primary key,
	year int not null,
	month int not null,
	day int not null,
	hour int not null,
	minute int not null,
	id_search uuid not null references zi_search(id),
	stat_processed_results bigint not null default 0,
	stat_verified_results bigint not null default 0
);

alter table account add column if not exists custom_daily_quota int null;
