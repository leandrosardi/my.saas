create table if not exists affiliate_payoff (
	id uuid not null primary key,
	create_time timestamp not null,
	amount float not null,
	description text null
);

create table if not exists visit (
	id uuid not null primary key,
	create_time timestamp not null,
	id_account_affiliate uuid null references "account"("id"),
	id_visitor uuid not null, -- ID to track a yet unknown visitor using cookies
	ip varchar(500) not null --,
	--id_user uuid not null references "user"("id")
);

ALTER TABLE visit
  ADD COLUMN IF NOT EXISTS user_agent TEXT,
  ADD COLUMN IF NOT EXISTS referer TEXT,
  ADD COLUMN IF NOT EXISTS page_url TEXT,
  ADD COLUMN IF NOT EXISTS path_info TEXT,
  ADD COLUMN IF NOT EXISTS query_string TEXT,
  ADD COLUMN IF NOT EXISTS accept_language VARCHAR(200),
  ADD COLUMN IF NOT EXISTS utm_params JSONB,        -- store {"utm_source":"x", "utm_medium":"y", ...}
  ADD COLUMN IF NOT EXISTS country_code VARCHAR(2), -- e.g., "US", "AR"
  ADD COLUMN IF NOT EXISTS city_name TEXT,
  ADD COLUMN IF NOT EXISTS device_type VARCHAR(50); -- e.g., "mobile" or "desktop"

alter table "user" add column if not exists id_visitor uuid null;

alter table "account" add column if not exists affiliate_commission float not null default 0.15;
--alter table "account" add column if not exists affiliate_active boolean not null default false;

alter table "account" add column if not exists stat_affiliate_visits bigint not null default 0;
alter table "account" add column if not exists stat_affiliate_unique_visits bigint not null default 0;
alter table "account" add column if not exists stat_affiliate_signups bigint not null default 0;
alter table "account" add column if not exists stat_affiliate_total_revenue bigint not null default 0;
alter table "account" add column if not exists stat_affiliate_total_commissions bigint not null default 0;
alter table "account" add column if not exists stat_affiliate_total_paid_off bigint not null default 0;