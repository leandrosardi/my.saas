alter table "account" add column if not exists draining_success bool null;
alter table "account" add column if not exists draining_error_description text null;
--alter table "account" add column if not exists notificatied_about_account_deletion bool not null default false;