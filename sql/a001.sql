CREATE TABLE IF NOT EXISTS public.survey (
	id uuid NOT NULL PRIMARY KEY,
  id_user uuid NOT NULL REFERENCES "user"("id"),
  id_timezone uuid NOT NULL REFERENCES "timezone"("id"),
  job_position VARCHAR(600) NOT NULL,
  company_headcount INT NOT NULL
);