CREATE TABLE IF NOT EXISTS api_call (
  id                BIGSERIAL      PRIMARY KEY,
  id_account        UUID         NULL
    REFERENCES account(id)        -- your existing accounts table

  , endpoint_url    TEXT           NOT NULL
  , http_method     VARCHAR(10)    NOT NULL    -- e.g. 'GET', 'POST', etc.
  , api_key         TEXT           NOT NULL    -- or store a lookup‐key instead

  , request_headers JSONB          NULL        -- all request headers
  , request_body    JSONB          NULL        -- POST/PUT payload

  , response_status SMALLINT       NULL        -- HTTP status code
  , response_body   JSONB          NULL        -- full JSON response (or TEXT if not JSON)

  , called_at       TIMESTAMPTZ    NOT NULL
      DEFAULT now()                            -- when the call was made
  , duration_ms     INTEGER        NULL        -- how long the request took in milliseconds

  , error_message   TEXT           NULL        -- if you caught an exception
  --, correlation_id  UUID           NULL        -- for tracing distributed calls

  -- optional: track *which* user or profile triggered it
  --, id_profile      BIGINT         NULL
      --REFERENCES profiles(id)                  -- if you have a profiles table
);
