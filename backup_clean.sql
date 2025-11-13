--
-- PostgreSQL database dump
--


-- Dumped from database version 17.4
-- Dumped by pg_dump version 17.6

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

DROP POLICY IF EXISTS users_service_role_policy ON public.users;
DROP POLICY IF EXISTS projects_service_role_policy ON public.projects;
DROP POLICY IF EXISTS organizations_service_role_policy ON public.organizations;
DROP POLICY IF EXISTS documents_service_role_policy ON public.documents;
DROP POLICY IF EXISTS document_validations_service_role_policy ON public.document_validations;
DROP POLICY IF EXISTS api_usage_service_role_policy ON public.api_usage;
ALTER TABLE IF EXISTS ONLY storage.s3_multipart_uploads_parts DROP CONSTRAINT IF EXISTS s3_multipart_uploads_parts_upload_id_fkey;
ALTER TABLE IF EXISTS ONLY storage.s3_multipart_uploads_parts DROP CONSTRAINT IF EXISTS s3_multipart_uploads_parts_bucket_id_fkey;
ALTER TABLE IF EXISTS ONLY storage.s3_multipart_uploads DROP CONSTRAINT IF EXISTS s3_multipart_uploads_bucket_id_fkey;
ALTER TABLE IF EXISTS ONLY storage.prefixes DROP CONSTRAINT IF EXISTS "prefixes_bucketId_fkey";
ALTER TABLE IF EXISTS ONLY storage.objects DROP CONSTRAINT IF EXISTS "objects_bucketId_fkey";
ALTER TABLE IF EXISTS ONLY public.users DROP CONSTRAINT IF EXISTS "users_organizationId_fkey";
ALTER TABLE IF EXISTS ONLY public.projects DROP CONSTRAINT IF EXISTS projects_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.projects DROP CONSTRAINT IF EXISTS "projects_organizationId_fkey";
ALTER TABLE IF EXISTS ONLY public.documents DROP CONSTRAINT IF EXISTS documents_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.documents DROP CONSTRAINT IF EXISTS documents_project_id_fkey;
ALTER TABLE IF EXISTS ONLY public.documents DROP CONSTRAINT IF EXISTS "documents_organizationId_fkey";
ALTER TABLE IF EXISTS ONLY public.document_validations DROP CONSTRAINT IF EXISTS document_validations_project_id_fkey;
ALTER TABLE IF EXISTS ONLY public.document_validations DROP CONSTRAINT IF EXISTS "document_validations_organizationId_fkey";
ALTER TABLE IF EXISTS ONLY public.document_validations DROP CONSTRAINT IF EXISTS document_validations_document_id_fkey;
ALTER TABLE IF EXISTS ONLY public.api_usage DROP CONSTRAINT IF EXISTS api_usage_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.api_usage DROP CONSTRAINT IF EXISTS api_usage_organization_id_fkey;
ALTER TABLE IF EXISTS ONLY auth.sso_domains DROP CONSTRAINT IF EXISTS sso_domains_sso_provider_id_fkey;
ALTER TABLE IF EXISTS ONLY auth.sessions DROP CONSTRAINT IF EXISTS sessions_user_id_fkey;
ALTER TABLE IF EXISTS ONLY auth.sessions DROP CONSTRAINT IF EXISTS sessions_oauth_client_id_fkey;
ALTER TABLE IF EXISTS ONLY auth.saml_relay_states DROP CONSTRAINT IF EXISTS saml_relay_states_sso_provider_id_fkey;
ALTER TABLE IF EXISTS ONLY auth.saml_relay_states DROP CONSTRAINT IF EXISTS saml_relay_states_flow_state_id_fkey;
ALTER TABLE IF EXISTS ONLY auth.saml_providers DROP CONSTRAINT IF EXISTS saml_providers_sso_provider_id_fkey;
ALTER TABLE IF EXISTS ONLY auth.refresh_tokens DROP CONSTRAINT IF EXISTS refresh_tokens_session_id_fkey;
ALTER TABLE IF EXISTS ONLY auth.one_time_tokens DROP CONSTRAINT IF EXISTS one_time_tokens_user_id_fkey;
ALTER TABLE IF EXISTS ONLY auth.oauth_consents DROP CONSTRAINT IF EXISTS oauth_consents_user_id_fkey;
ALTER TABLE IF EXISTS ONLY auth.oauth_consents DROP CONSTRAINT IF EXISTS oauth_consents_client_id_fkey;
ALTER TABLE IF EXISTS ONLY auth.oauth_authorizations DROP CONSTRAINT IF EXISTS oauth_authorizations_user_id_fkey;
ALTER TABLE IF EXISTS ONLY auth.oauth_authorizations DROP CONSTRAINT IF EXISTS oauth_authorizations_client_id_fkey;
ALTER TABLE IF EXISTS ONLY auth.mfa_factors DROP CONSTRAINT IF EXISTS mfa_factors_user_id_fkey;
ALTER TABLE IF EXISTS ONLY auth.mfa_challenges DROP CONSTRAINT IF EXISTS mfa_challenges_auth_factor_id_fkey;
ALTER TABLE IF EXISTS ONLY auth.mfa_amr_claims DROP CONSTRAINT IF EXISTS mfa_amr_claims_session_id_fkey;
ALTER TABLE IF EXISTS ONLY auth.identities DROP CONSTRAINT IF EXISTS identities_user_id_fkey;
DROP TRIGGER IF EXISTS update_objects_updated_at ON storage.objects;
DROP TRIGGER IF EXISTS prefixes_delete_hierarchy ON storage.prefixes;
DROP TRIGGER IF EXISTS prefixes_create_hierarchy ON storage.prefixes;
DROP TRIGGER IF EXISTS objects_update_create_prefix ON storage.objects;
DROP TRIGGER IF EXISTS objects_insert_create_prefix ON storage.objects;
DROP TRIGGER IF EXISTS objects_delete_delete_prefix ON storage.objects;
DROP TRIGGER IF EXISTS enforce_bucket_name_length_trigger ON storage.buckets;
DROP TRIGGER IF EXISTS tr_check_filters ON realtime.subscription;
DROP INDEX IF EXISTS storage.objects_bucket_id_level_idx;
DROP INDEX IF EXISTS storage.name_prefix_search;
DROP INDEX IF EXISTS storage.idx_prefixes_lower_name;
DROP INDEX IF EXISTS storage.idx_objects_lower_name;
DROP INDEX IF EXISTS storage.idx_objects_bucket_id_name;
DROP INDEX IF EXISTS storage.idx_name_bucket_level_unique;
DROP INDEX IF EXISTS storage.idx_multipart_uploads_list;
DROP INDEX IF EXISTS storage.bucketid_objname;
DROP INDEX IF EXISTS storage.bname;
DROP INDEX IF EXISTS realtime.subscription_subscription_id_entity_filters_key;
DROP INDEX IF EXISTS realtime.messages_inserted_at_topic_index;
DROP INDEX IF EXISTS realtime.ix_realtime_subscription_entity;
DROP INDEX IF EXISTS public."users_organizationId_idx";
DROP INDEX IF EXISTS public.users_email_key;
DROP INDEX IF EXISTS public.users_auth_user_id_key;
DROP INDEX IF EXISTS public.system_configurations_system_name_key;
DROP INDEX IF EXISTS public.projects_user_id_idx;
DROP INDEX IF EXISTS public."projects_organizationId_idx";
DROP INDEX IF EXISTS public.organizations_stripe_customer_id_key;
DROP INDEX IF EXISTS public.organizations_mercadopago_subscription_id_key;
DROP INDEX IF EXISTS public.organizations_cnpj_key;
DROP INDEX IF EXISTS public.documents_user_id_idx;
DROP INDEX IF EXISTS public.documents_project_id_idx;
DROP INDEX IF EXISTS public."documents_organizationId_idx";
DROP INDEX IF EXISTS public.document_validations_project_id_idx;
DROP INDEX IF EXISTS public."document_validations_organizationId_idx";
DROP INDEX IF EXISTS public.document_validations_document_id_key;
DROP INDEX IF EXISTS public.document_types_code_key;
DROP INDEX IF EXISTS public.api_usage_user_id_idx;
DROP INDEX IF EXISTS public.api_usage_service_idx;
DROP INDEX IF EXISTS public.api_usage_organization_id_idx;
DROP INDEX IF EXISTS public.api_usage_date_idx;
DROP INDEX IF EXISTS public.action_types_name_key;
DROP INDEX IF EXISTS auth.users_is_anonymous_idx;
DROP INDEX IF EXISTS auth.users_instance_id_idx;
DROP INDEX IF EXISTS auth.users_instance_id_email_idx;
DROP INDEX IF EXISTS auth.users_email_partial_key;
DROP INDEX IF EXISTS auth.user_id_created_at_idx;
DROP INDEX IF EXISTS auth.unique_phone_factor_per_user;
DROP INDEX IF EXISTS auth.sso_providers_resource_id_pattern_idx;
DROP INDEX IF EXISTS auth.sso_providers_resource_id_idx;
DROP INDEX IF EXISTS auth.sso_domains_sso_provider_id_idx;
DROP INDEX IF EXISTS auth.sso_domains_domain_idx;
DROP INDEX IF EXISTS auth.sessions_user_id_idx;
DROP INDEX IF EXISTS auth.sessions_oauth_client_id_idx;
DROP INDEX IF EXISTS auth.sessions_not_after_idx;
DROP INDEX IF EXISTS auth.saml_relay_states_sso_provider_id_idx;
DROP INDEX IF EXISTS auth.saml_relay_states_for_email_idx;
DROP INDEX IF EXISTS auth.saml_relay_states_created_at_idx;
DROP INDEX IF EXISTS auth.saml_providers_sso_provider_id_idx;
DROP INDEX IF EXISTS auth.refresh_tokens_updated_at_idx;
DROP INDEX IF EXISTS auth.refresh_tokens_session_id_revoked_idx;
DROP INDEX IF EXISTS auth.refresh_tokens_parent_idx;
DROP INDEX IF EXISTS auth.refresh_tokens_instance_id_user_id_idx;
DROP INDEX IF EXISTS auth.refresh_tokens_instance_id_idx;
DROP INDEX IF EXISTS auth.recovery_token_idx;
DROP INDEX IF EXISTS auth.reauthentication_token_idx;
DROP INDEX IF EXISTS auth.one_time_tokens_user_id_token_type_key;
DROP INDEX IF EXISTS auth.one_time_tokens_token_hash_hash_idx;
DROP INDEX IF EXISTS auth.one_time_tokens_relates_to_hash_idx;
DROP INDEX IF EXISTS auth.oauth_consents_user_order_idx;
DROP INDEX IF EXISTS auth.oauth_consents_active_user_client_idx;
DROP INDEX IF EXISTS auth.oauth_consents_active_client_idx;
DROP INDEX IF EXISTS auth.oauth_clients_deleted_at_idx;
DROP INDEX IF EXISTS auth.oauth_auth_pending_exp_idx;
DROP INDEX IF EXISTS auth.mfa_factors_user_id_idx;
DROP INDEX IF EXISTS auth.mfa_factors_user_friendly_name_unique;
DROP INDEX IF EXISTS auth.mfa_challenge_created_at_idx;
DROP INDEX IF EXISTS auth.idx_user_id_auth_method;
DROP INDEX IF EXISTS auth.idx_auth_code;
DROP INDEX IF EXISTS auth.identities_user_id_idx;
DROP INDEX IF EXISTS auth.identities_email_idx;
DROP INDEX IF EXISTS auth.flow_state_created_at_idx;
DROP INDEX IF EXISTS auth.factor_id_created_at_idx;
DROP INDEX IF EXISTS auth.email_change_token_new_idx;
DROP INDEX IF EXISTS auth.email_change_token_current_idx;
DROP INDEX IF EXISTS auth.confirmation_token_idx;
DROP INDEX IF EXISTS auth.audit_logs_instance_id_idx;
ALTER TABLE IF EXISTS ONLY supabase_migrations.seed_files DROP CONSTRAINT IF EXISTS seed_files_pkey;
ALTER TABLE IF EXISTS ONLY supabase_migrations.schema_migrations DROP CONSTRAINT IF EXISTS schema_migrations_pkey;
ALTER TABLE IF EXISTS ONLY storage.s3_multipart_uploads DROP CONSTRAINT IF EXISTS s3_multipart_uploads_pkey;
ALTER TABLE IF EXISTS ONLY storage.s3_multipart_uploads_parts DROP CONSTRAINT IF EXISTS s3_multipart_uploads_parts_pkey;
ALTER TABLE IF EXISTS ONLY storage.prefixes DROP CONSTRAINT IF EXISTS prefixes_pkey;
ALTER TABLE IF EXISTS ONLY storage.objects DROP CONSTRAINT IF EXISTS objects_pkey;
ALTER TABLE IF EXISTS ONLY storage.migrations DROP CONSTRAINT IF EXISTS migrations_pkey;
ALTER TABLE IF EXISTS ONLY storage.migrations DROP CONSTRAINT IF EXISTS migrations_name_key;
ALTER TABLE IF EXISTS ONLY storage.buckets DROP CONSTRAINT IF EXISTS buckets_pkey;
ALTER TABLE IF EXISTS ONLY storage.buckets_analytics DROP CONSTRAINT IF EXISTS buckets_analytics_pkey;
ALTER TABLE IF EXISTS ONLY realtime.schema_migrations DROP CONSTRAINT IF EXISTS schema_migrations_pkey;
ALTER TABLE IF EXISTS ONLY realtime.subscription DROP CONSTRAINT IF EXISTS pk_subscription;
ALTER TABLE IF EXISTS ONLY realtime.messages DROP CONSTRAINT IF EXISTS messages_pkey;
ALTER TABLE IF EXISTS ONLY public.users DROP CONSTRAINT IF EXISTS users_pkey;
ALTER TABLE IF EXISTS ONLY public.system_configurations DROP CONSTRAINT IF EXISTS system_configurations_pkey;
ALTER TABLE IF EXISTS ONLY public.projects DROP CONSTRAINT IF EXISTS projects_pkey;
ALTER TABLE IF EXISTS ONLY public.organizations DROP CONSTRAINT IF EXISTS organizations_pkey;
ALTER TABLE IF EXISTS ONLY public.documents DROP CONSTRAINT IF EXISTS documents_pkey;
ALTER TABLE IF EXISTS ONLY public.document_validations DROP CONSTRAINT IF EXISTS document_validations_pkey;
ALTER TABLE IF EXISTS ONLY public.document_types DROP CONSTRAINT IF EXISTS document_types_pkey;
ALTER TABLE IF EXISTS ONLY public.api_usage DROP CONSTRAINT IF EXISTS api_usage_pkey;
ALTER TABLE IF EXISTS ONLY public.action_types DROP CONSTRAINT IF EXISTS action_types_pkey;
ALTER TABLE IF EXISTS ONLY public._prisma_migrations DROP CONSTRAINT IF EXISTS _prisma_migrations_pkey;
ALTER TABLE IF EXISTS ONLY auth.users DROP CONSTRAINT IF EXISTS users_pkey;
ALTER TABLE IF EXISTS ONLY auth.users DROP CONSTRAINT IF EXISTS users_phone_key;
ALTER TABLE IF EXISTS ONLY auth.sso_providers DROP CONSTRAINT IF EXISTS sso_providers_pkey;
ALTER TABLE IF EXISTS ONLY auth.sso_domains DROP CONSTRAINT IF EXISTS sso_domains_pkey;
ALTER TABLE IF EXISTS ONLY auth.sessions DROP CONSTRAINT IF EXISTS sessions_pkey;
ALTER TABLE IF EXISTS ONLY auth.schema_migrations DROP CONSTRAINT IF EXISTS schema_migrations_pkey;
ALTER TABLE IF EXISTS ONLY auth.saml_relay_states DROP CONSTRAINT IF EXISTS saml_relay_states_pkey;
ALTER TABLE IF EXISTS ONLY auth.saml_providers DROP CONSTRAINT IF EXISTS saml_providers_pkey;
ALTER TABLE IF EXISTS ONLY auth.saml_providers DROP CONSTRAINT IF EXISTS saml_providers_entity_id_key;
ALTER TABLE IF EXISTS ONLY auth.refresh_tokens DROP CONSTRAINT IF EXISTS refresh_tokens_token_unique;
ALTER TABLE IF EXISTS ONLY auth.refresh_tokens DROP CONSTRAINT IF EXISTS refresh_tokens_pkey;
ALTER TABLE IF EXISTS ONLY auth.one_time_tokens DROP CONSTRAINT IF EXISTS one_time_tokens_pkey;
ALTER TABLE IF EXISTS ONLY auth.oauth_consents DROP CONSTRAINT IF EXISTS oauth_consents_user_client_unique;
ALTER TABLE IF EXISTS ONLY auth.oauth_consents DROP CONSTRAINT IF EXISTS oauth_consents_pkey;
ALTER TABLE IF EXISTS ONLY auth.oauth_clients DROP CONSTRAINT IF EXISTS oauth_clients_pkey;
ALTER TABLE IF EXISTS ONLY auth.oauth_authorizations DROP CONSTRAINT IF EXISTS oauth_authorizations_pkey;
ALTER TABLE IF EXISTS ONLY auth.oauth_authorizations DROP CONSTRAINT IF EXISTS oauth_authorizations_authorization_id_key;
ALTER TABLE IF EXISTS ONLY auth.oauth_authorizations DROP CONSTRAINT IF EXISTS oauth_authorizations_authorization_code_key;
ALTER TABLE IF EXISTS ONLY auth.mfa_factors DROP CONSTRAINT IF EXISTS mfa_factors_pkey;
ALTER TABLE IF EXISTS ONLY auth.mfa_factors DROP CONSTRAINT IF EXISTS mfa_factors_last_challenged_at_key;
ALTER TABLE IF EXISTS ONLY auth.mfa_challenges DROP CONSTRAINT IF EXISTS mfa_challenges_pkey;
ALTER TABLE IF EXISTS ONLY auth.mfa_amr_claims DROP CONSTRAINT IF EXISTS mfa_amr_claims_session_id_authentication_method_pkey;
ALTER TABLE IF EXISTS ONLY auth.instances DROP CONSTRAINT IF EXISTS instances_pkey;
ALTER TABLE IF EXISTS ONLY auth.identities DROP CONSTRAINT IF EXISTS identities_provider_id_provider_unique;
ALTER TABLE IF EXISTS ONLY auth.identities DROP CONSTRAINT IF EXISTS identities_pkey;
ALTER TABLE IF EXISTS ONLY auth.flow_state DROP CONSTRAINT IF EXISTS flow_state_pkey;
ALTER TABLE IF EXISTS ONLY auth.audit_log_entries DROP CONSTRAINT IF EXISTS audit_log_entries_pkey;
ALTER TABLE IF EXISTS ONLY auth.mfa_amr_claims DROP CONSTRAINT IF EXISTS amr_id_pk;
ALTER TABLE IF EXISTS public.users ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.system_configurations ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.projects ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.organizations ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.documents ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.document_validations ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.document_types ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.api_usage ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.action_types ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS auth.refresh_tokens ALTER COLUMN id DROP DEFAULT;
DROP TABLE IF EXISTS supabase_migrations.seed_files;
DROP TABLE IF EXISTS supabase_migrations.schema_migrations;
DROP TABLE IF EXISTS storage.s3_multipart_uploads_parts;
DROP TABLE IF EXISTS storage.s3_multipart_uploads;
DROP TABLE IF EXISTS storage.prefixes;
DROP TABLE IF EXISTS storage.objects;
DROP TABLE IF EXISTS storage.migrations;
DROP TABLE IF EXISTS storage.buckets_analytics;
DROP TABLE IF EXISTS storage.buckets;
DROP TABLE IF EXISTS realtime.subscription;
DROP TABLE IF EXISTS realtime.schema_migrations;
DROP TABLE IF EXISTS realtime.messages;
DROP SEQUENCE IF EXISTS public.users_id_seq;
DROP TABLE IF EXISTS public.users;
DROP SEQUENCE IF EXISTS public.system_configurations_id_seq;
DROP TABLE IF EXISTS public.system_configurations;
DROP SEQUENCE IF EXISTS public.projects_id_seq;
DROP TABLE IF EXISTS public.projects;
DROP SEQUENCE IF EXISTS public.organizations_id_seq;
DROP TABLE IF EXISTS public.organizations;
DROP SEQUENCE IF EXISTS public.documents_id_seq;
DROP TABLE IF EXISTS public.documents;
DROP SEQUENCE IF EXISTS public.document_validations_id_seq;
DROP TABLE IF EXISTS public.document_validations;
DROP SEQUENCE IF EXISTS public.document_types_id_seq;
DROP TABLE IF EXISTS public.document_types;
DROP SEQUENCE IF EXISTS public.api_usage_id_seq;
DROP TABLE IF EXISTS public.api_usage;
DROP SEQUENCE IF EXISTS public.action_types_id_seq;
DROP TABLE IF EXISTS public.action_types;
DROP TABLE IF EXISTS public._prisma_migrations;
DROP TABLE IF EXISTS auth.users;
DROP TABLE IF EXISTS auth.sso_providers;
DROP TABLE IF EXISTS auth.sso_domains;
DROP TABLE IF EXISTS auth.sessions;
DROP TABLE IF EXISTS auth.schema_migrations;
DROP TABLE IF EXISTS auth.saml_relay_states;
DROP TABLE IF EXISTS auth.saml_providers;
DROP SEQUENCE IF EXISTS auth.refresh_tokens_id_seq;
DROP TABLE IF EXISTS auth.refresh_tokens;
DROP TABLE IF EXISTS auth.one_time_tokens;
DROP TABLE IF EXISTS auth.oauth_consents;
DROP TABLE IF EXISTS auth.oauth_clients;
DROP TABLE IF EXISTS auth.oauth_authorizations;
DROP TABLE IF EXISTS auth.mfa_factors;
DROP TABLE IF EXISTS auth.mfa_challenges;
DROP TABLE IF EXISTS auth.mfa_amr_claims;
DROP TABLE IF EXISTS auth.instances;
DROP TABLE IF EXISTS auth.identities;
DROP TABLE IF EXISTS auth.flow_state;
DROP TABLE IF EXISTS auth.audit_log_entries;
DROP FUNCTION IF EXISTS storage.update_updated_at_column();
DROP FUNCTION IF EXISTS storage.search_v2(prefix text, bucket_name text, limits integer, levels integer, start_after text, sort_order text, sort_column text, sort_column_after text);
DROP FUNCTION IF EXISTS storage.search_v1_optimised(prefix text, bucketname text, limits integer, levels integer, offsets integer, search text, sortcolumn text, sortorder text);
DROP FUNCTION IF EXISTS storage.search_legacy_v1(prefix text, bucketname text, limits integer, levels integer, offsets integer, search text, sortcolumn text, sortorder text);
DROP FUNCTION IF EXISTS storage.search(prefix text, bucketname text, limits integer, levels integer, offsets integer, search text, sortcolumn text, sortorder text);
DROP FUNCTION IF EXISTS storage.prefixes_insert_trigger();
DROP FUNCTION IF EXISTS storage.prefixes_delete_cleanup();
DROP FUNCTION IF EXISTS storage.operation();
DROP FUNCTION IF EXISTS storage.objects_update_prefix_trigger();
DROP FUNCTION IF EXISTS storage.objects_update_level_trigger();
DROP FUNCTION IF EXISTS storage.objects_update_cleanup();
DROP FUNCTION IF EXISTS storage.objects_insert_prefix_trigger();
DROP FUNCTION IF EXISTS storage.objects_delete_cleanup();
DROP FUNCTION IF EXISTS storage.lock_top_prefixes(bucket_ids text[], names text[]);
DROP FUNCTION IF EXISTS storage.list_objects_with_delimiter(bucket_id text, prefix_param text, delimiter_param text, max_keys integer, start_after text, next_token text);
DROP FUNCTION IF EXISTS storage.list_multipart_uploads_with_delimiter(bucket_id text, prefix_param text, delimiter_param text, max_keys integer, next_key_token text, next_upload_token text);
DROP FUNCTION IF EXISTS storage.get_size_by_bucket();
DROP FUNCTION IF EXISTS storage.get_prefixes(name text);
DROP FUNCTION IF EXISTS storage.get_prefix(name text);
DROP FUNCTION IF EXISTS storage.get_level(name text);
DROP FUNCTION IF EXISTS storage.foldername(name text);
DROP FUNCTION IF EXISTS storage.filename(name text);
DROP FUNCTION IF EXISTS storage.extension(name text);
DROP FUNCTION IF EXISTS storage.enforce_bucket_name_length();
DROP FUNCTION IF EXISTS storage.delete_prefix_hierarchy_trigger();
DROP FUNCTION IF EXISTS storage.delete_prefix(_bucket_id text, _name text);
DROP FUNCTION IF EXISTS storage.delete_leaf_prefixes(bucket_ids text[], names text[]);
DROP FUNCTION IF EXISTS storage.can_insert_object(bucketid text, name text, owner uuid, metadata jsonb);
DROP FUNCTION IF EXISTS storage.add_prefixes(_bucket_id text, _name text);
DROP FUNCTION IF EXISTS realtime.topic();
DROP FUNCTION IF EXISTS realtime.to_regrole(role_name text);
DROP FUNCTION IF EXISTS realtime.subscription_check_filters();
DROP FUNCTION IF EXISTS realtime.send(payload jsonb, event text, topic text, private boolean);
DROP FUNCTION IF EXISTS realtime.quote_wal2json(entity regclass);
DROP FUNCTION IF EXISTS realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer);
DROP FUNCTION IF EXISTS realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]);
DROP FUNCTION IF EXISTS realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text);
DROP FUNCTION IF EXISTS realtime."cast"(val text, type_ regtype);
DROP FUNCTION IF EXISTS realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]);
DROP FUNCTION IF EXISTS realtime.broadcast_changes(topic_name text, event_name text, operation text, table_name text, table_schema text, new record, old record, level text);
DROP FUNCTION IF EXISTS realtime.apply_rls(wal jsonb, max_record_bytes integer);
DROP FUNCTION IF EXISTS pgbouncer.get_auth(p_usename text);
DROP FUNCTION IF EXISTS extensions.set_graphql_placeholder();
DROP FUNCTION IF EXISTS extensions.pgrst_drop_watch();
DROP FUNCTION IF EXISTS extensions.pgrst_ddl_watch();
DROP FUNCTION IF EXISTS extensions.grant_pg_net_access();
DROP FUNCTION IF EXISTS extensions.grant_pg_graphql_access();
DROP FUNCTION IF EXISTS extensions.grant_pg_cron_access();
DROP FUNCTION IF EXISTS auth.uid();
DROP FUNCTION IF EXISTS auth.role();
DROP FUNCTION IF EXISTS auth.jwt();
DROP FUNCTION IF EXISTS auth.email();
DROP TYPE IF EXISTS storage.buckettype;
DROP TYPE IF EXISTS realtime.wal_rls;
DROP TYPE IF EXISTS realtime.wal_column;
DROP TYPE IF EXISTS realtime.user_defined_filter;
DROP TYPE IF EXISTS realtime.equality_op;
DROP TYPE IF EXISTS realtime.action;
DROP TYPE IF EXISTS public."UserRole";
DROP TYPE IF EXISTS public."SubscriptionStatus";
DROP TYPE IF EXISTS public."PlanType";
DROP TYPE IF EXISTS auth.one_time_token_type;
DROP TYPE IF EXISTS auth.oauth_response_type;
DROP TYPE IF EXISTS auth.oauth_registration_type;
DROP TYPE IF EXISTS auth.oauth_client_type;
DROP TYPE IF EXISTS auth.oauth_authorization_status;
DROP TYPE IF EXISTS auth.factor_type;
DROP TYPE IF EXISTS auth.factor_status;
DROP TYPE IF EXISTS auth.code_challenge_method;
DROP TYPE IF EXISTS auth.aal_level;
DROP EXTENSION IF EXISTS "uuid-ossp";
DROP SCHEMA IF EXISTS supabase_migrations;
-- *not* dropping schema, since initdb creates it
DROP SCHEMA IF EXISTS pgbouncer;
DROP SCHEMA IF EXISTS graphql;
--
-- Name: auth; Type: SCHEMA; Schema: -; Owner: supabase_admin
--

CREATE SCHEMA auth;


ALTER SCHEMA auth OWNER TO supabase_admin;

--
-- Name: extensions; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA extensions;


ALTER SCHEMA extensions OWNER TO postgres;

--
-- Name: graphql; Type: SCHEMA; Schema: -; Owner: supabase_admin
--

CREATE SCHEMA graphql;


ALTER SCHEMA graphql OWNER TO supabase_admin;

--
-- Name: graphql_public; Type: SCHEMA; Schema: -; Owner: supabase_admin
--

CREATE SCHEMA graphql_public;


ALTER SCHEMA graphql_public OWNER TO supabase_admin;

--
-- Name: pgbouncer; Type: SCHEMA; Schema: -; Owner: pgbouncer
--

CREATE SCHEMA pgbouncer;


ALTER SCHEMA pgbouncer OWNER TO pgbouncer;

--
-- Name: public; Type: SCHEMA; Schema: -; Owner: postgres
--

-- *not* creating schema, since initdb creates it


ALTER SCHEMA public OWNER TO postgres;

--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA public IS '';


--
-- Name: realtime; Type: SCHEMA; Schema: -; Owner: supabase_admin
--

CREATE SCHEMA realtime;


ALTER SCHEMA realtime OWNER TO supabase_admin;

--
-- Name: storage; Type: SCHEMA; Schema: -; Owner: supabase_admin
--

CREATE SCHEMA storage;


ALTER SCHEMA storage OWNER TO supabase_admin;

--
-- Name: supabase_migrations; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA supabase_migrations;


ALTER SCHEMA supabase_migrations OWNER TO postgres;

--
-- Name: vault; Type: SCHEMA; Schema: -; Owner: supabase_admin
--

CREATE SCHEMA vault;


ALTER SCHEMA vault OWNER TO supabase_admin;

--
-- Name: pg_graphql; Type: EXTENSION; Schema: -; Owner: -
--



--
-- Name: EXTENSION pg_graphql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pg_graphql IS 'pg_graphql: GraphQL support';


--
-- Name: pg_stat_statements; Type: EXTENSION; Schema: -; Owner: -
--



--
-- Name: EXTENSION pg_stat_statements; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pg_stat_statements IS 'track planning and execution statistics of all SQL statements executed';


--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--



--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: supabase_vault; Type: EXTENSION; Schema: -; Owner: -
--



--
-- Name: EXTENSION supabase_vault; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION supabase_vault IS 'Supabase Vault Extension';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA extensions;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: aal_level; Type: TYPE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TYPE auth.aal_level AS ENUM (
    'aal1',
    'aal2',
    'aal3'
);


ALTER TYPE auth.aal_level OWNER TO supabase_auth_admin;

--
-- Name: code_challenge_method; Type: TYPE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TYPE auth.code_challenge_method AS ENUM (
    's256',
    'plain'
);


ALTER TYPE auth.code_challenge_method OWNER TO supabase_auth_admin;

--
-- Name: factor_status; Type: TYPE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TYPE auth.factor_status AS ENUM (
    'unverified',
    'verified'
);


ALTER TYPE auth.factor_status OWNER TO supabase_auth_admin;

--
-- Name: factor_type; Type: TYPE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TYPE auth.factor_type AS ENUM (
    'totp',
    'webauthn',
    'phone'
);


ALTER TYPE auth.factor_type OWNER TO supabase_auth_admin;

--
-- Name: oauth_authorization_status; Type: TYPE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TYPE auth.oauth_authorization_status AS ENUM (
    'pending',
    'approved',
    'denied',
    'expired'
);


ALTER TYPE auth.oauth_authorization_status OWNER TO supabase_auth_admin;

--
-- Name: oauth_client_type; Type: TYPE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TYPE auth.oauth_client_type AS ENUM (
    'public',
    'confidential'
);


ALTER TYPE auth.oauth_client_type OWNER TO supabase_auth_admin;

--
-- Name: oauth_registration_type; Type: TYPE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TYPE auth.oauth_registration_type AS ENUM (
    'dynamic',
    'manual'
);


ALTER TYPE auth.oauth_registration_type OWNER TO supabase_auth_admin;

--
-- Name: oauth_response_type; Type: TYPE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TYPE auth.oauth_response_type AS ENUM (
    'code'
);


ALTER TYPE auth.oauth_response_type OWNER TO supabase_auth_admin;

--
-- Name: one_time_token_type; Type: TYPE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TYPE auth.one_time_token_type AS ENUM (
    'confirmation_token',
    'reauthentication_token',
    'recovery_token',
    'email_change_token_new',
    'email_change_token_current',
    'phone_change_token'
);


ALTER TYPE auth.one_time_token_type OWNER TO supabase_auth_admin;

--
-- Name: PlanType; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public."PlanType" AS ENUM (
    'basic',
    'pro',
    'enterprise',
    'trialing'
);


ALTER TYPE public."PlanType" OWNER TO postgres;

--
-- Name: SubscriptionStatus; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public."SubscriptionStatus" AS ENUM (
    'active',
    'past_due',
    'canceled',
    'trialing'
);


ALTER TYPE public."SubscriptionStatus" OWNER TO postgres;

--
-- Name: UserRole; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public."UserRole" AS ENUM (
    'admin',
    'member',
    'super_admin'
);


ALTER TYPE public."UserRole" OWNER TO postgres;

--
-- Name: action; Type: TYPE; Schema: realtime; Owner: supabase_admin
--

CREATE TYPE realtime.action AS ENUM (
    'INSERT',
    'UPDATE',
    'DELETE',
    'TRUNCATE',
    'ERROR'
);


ALTER TYPE realtime.action OWNER TO supabase_admin;

--
-- Name: equality_op; Type: TYPE; Schema: realtime; Owner: supabase_admin
--

CREATE TYPE realtime.equality_op AS ENUM (
    'eq',
    'neq',
    'lt',
    'lte',
    'gt',
    'gte',
    'in'
);


ALTER TYPE realtime.equality_op OWNER TO supabase_admin;

--
-- Name: user_defined_filter; Type: TYPE; Schema: realtime; Owner: supabase_admin
--

CREATE TYPE realtime.user_defined_filter AS (
	column_name text,
	op realtime.equality_op,
	value text
);


ALTER TYPE realtime.user_defined_filter OWNER TO supabase_admin;

--
-- Name: wal_column; Type: TYPE; Schema: realtime; Owner: supabase_admin
--

CREATE TYPE realtime.wal_column AS (
	name text,
	type_name text,
	type_oid oid,
	value jsonb,
	is_pkey boolean,
	is_selectable boolean
);


ALTER TYPE realtime.wal_column OWNER TO supabase_admin;

--
-- Name: wal_rls; Type: TYPE; Schema: realtime; Owner: supabase_admin
--

CREATE TYPE realtime.wal_rls AS (
	wal jsonb,
	is_rls_enabled boolean,
	subscription_ids uuid[],
	errors text[]
);


ALTER TYPE realtime.wal_rls OWNER TO supabase_admin;

--
-- Name: buckettype; Type: TYPE; Schema: storage; Owner: supabase_storage_admin
--

CREATE TYPE storage.buckettype AS ENUM (
    'STANDARD',
    'ANALYTICS'
);


ALTER TYPE storage.buckettype OWNER TO supabase_storage_admin;

--
-- Name: email(); Type: FUNCTION; Schema: auth; Owner: supabase_auth_admin
--

CREATE FUNCTION auth.email() RETURNS text
    LANGUAGE sql STABLE
    AS $$
  select 
  coalesce(
    nullif(current_setting('request.jwt.claim.email', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'email')
  )::text
$$;


ALTER FUNCTION auth.email() OWNER TO supabase_auth_admin;

--
-- Name: FUNCTION email(); Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON FUNCTION auth.email() IS 'Deprecated. Use auth.jwt() -> ''email'' instead.';


--
-- Name: jwt(); Type: FUNCTION; Schema: auth; Owner: supabase_auth_admin
--

CREATE FUNCTION auth.jwt() RETURNS jsonb
    LANGUAGE sql STABLE
    AS $$
  select 
    coalesce(
        nullif(current_setting('request.jwt.claim', true), ''),
        nullif(current_setting('request.jwt.claims', true), '')
    )::jsonb
$$;


ALTER FUNCTION auth.jwt() OWNER TO supabase_auth_admin;

--
-- Name: role(); Type: FUNCTION; Schema: auth; Owner: supabase_auth_admin
--

CREATE FUNCTION auth.role() RETURNS text
    LANGUAGE sql STABLE
    AS $$
  select 
  coalesce(
    nullif(current_setting('request.jwt.claim.role', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'role')
  )::text
$$;


ALTER FUNCTION auth.role() OWNER TO supabase_auth_admin;

--
-- Name: FUNCTION role(); Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON FUNCTION auth.role() IS 'Deprecated. Use auth.jwt() -> ''role'' instead.';


--
-- Name: uid(); Type: FUNCTION; Schema: auth; Owner: supabase_auth_admin
--

CREATE FUNCTION auth.uid() RETURNS uuid
    LANGUAGE sql STABLE
    AS $$
  select 
  coalesce(
    nullif(current_setting('request.jwt.claim.sub', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'sub')
  )::uuid
$$;


ALTER FUNCTION auth.uid() OWNER TO supabase_auth_admin;

--
-- Name: FUNCTION uid(); Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON FUNCTION auth.uid() IS 'Deprecated. Use auth.jwt() -> ''sub'' instead.';


--
-- Name: grant_pg_cron_access(); Type: FUNCTION; Schema: extensions; Owner: supabase_admin
--

CREATE FUNCTION extensions.grant_pg_cron_access() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF EXISTS (
    SELECT
    FROM pg_event_trigger_ddl_commands() AS ev
    JOIN pg_extension AS ext
    ON ev.objid = ext.oid
    WHERE ext.extname = 'pg_cron'
  )
  THEN
    grant usage on schema cron to postgres with grant option;

    alter default privileges in schema cron grant all on tables to postgres with grant option;
    alter default privileges in schema cron grant all on functions to postgres with grant option;
    alter default privileges in schema cron grant all on sequences to postgres with grant option;

    alter default privileges for user supabase_admin in schema cron grant all
        on sequences to postgres with grant option;
    alter default privileges for user supabase_admin in schema cron grant all
        on tables to postgres with grant option;
    alter default privileges for user supabase_admin in schema cron grant all
        on functions to postgres with grant option;

    grant all privileges on all tables in schema cron to postgres with grant option;
    revoke all on table cron.job from postgres;
    grant select on table cron.job to postgres with grant option;
  END IF;
END;
$$;


ALTER FUNCTION extensions.grant_pg_cron_access() OWNER TO supabase_admin;

--
-- Name: FUNCTION grant_pg_cron_access(); Type: COMMENT; Schema: extensions; Owner: supabase_admin
--

COMMENT ON FUNCTION extensions.grant_pg_cron_access() IS 'Grants access to pg_cron';


--
-- Name: grant_pg_graphql_access(); Type: FUNCTION; Schema: extensions; Owner: supabase_admin
--

CREATE FUNCTION extensions.grant_pg_graphql_access() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $_$
DECLARE
    func_is_graphql_resolve bool;
BEGIN
    func_is_graphql_resolve = (
        SELECT n.proname = 'resolve'
        FROM pg_event_trigger_ddl_commands() AS ev
        LEFT JOIN pg_catalog.pg_proc AS n
        ON ev.objid = n.oid
    );

    IF func_is_graphql_resolve
    THEN
        -- Update public wrapper to pass all arguments through to the pg_graphql resolve func
        DROP FUNCTION IF EXISTS graphql_public.graphql;
        create or replace function graphql_public.graphql(
            "operationName" text default null,
            query text default null,
            variables jsonb default null,
            extensions jsonb default null
        )
            returns jsonb
            language sql
        as $$
            select graphql.resolve(
                query := query,
                variables := coalesce(variables, '{}'),
                "operationName" := "operationName",
                extensions := extensions
            );
        $$;

        -- This hook executes when `graphql.resolve` is created. That is not necessarily the last
        -- function in the extension so we need to grant permissions on existing entities AND
        -- update default permissions to any others that are created after `graphql.resolve`
        grant usage on schema graphql to postgres, anon, authenticated, service_role;
        grant select on all tables in schema graphql to postgres, anon, authenticated, service_role;
        grant execute on all functions in schema graphql to postgres, anon, authenticated, service_role;
        grant all on all sequences in schema graphql to postgres, anon, authenticated, service_role;
        alter default privileges in schema graphql grant all on tables to postgres, anon, authenticated, service_role;
        alter default privileges in schema graphql grant all on functions to postgres, anon, authenticated, service_role;
        alter default privileges in schema graphql grant all on sequences to postgres, anon, authenticated, service_role;

        -- Allow postgres role to allow granting usage on graphql and graphql_public schemas to custom roles
        grant usage on schema graphql_public to postgres with grant option;
        grant usage on schema graphql to postgres with grant option;
    END IF;

END;
$_$;


ALTER FUNCTION extensions.grant_pg_graphql_access() OWNER TO supabase_admin;

--
-- Name: FUNCTION grant_pg_graphql_access(); Type: COMMENT; Schema: extensions; Owner: supabase_admin
--

COMMENT ON FUNCTION extensions.grant_pg_graphql_access() IS 'Grants access to pg_graphql';


--
-- Name: grant_pg_net_access(); Type: FUNCTION; Schema: extensions; Owner: supabase_admin
--

CREATE FUNCTION extensions.grant_pg_net_access() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM pg_event_trigger_ddl_commands() AS ev
    JOIN pg_extension AS ext
    ON ev.objid = ext.oid
    WHERE ext.extname = 'pg_net'
  )
  THEN
    IF NOT EXISTS (
      SELECT 1
      FROM pg_roles
      WHERE rolname = 'supabase_functions_admin'
    )
    THEN
      CREATE USER supabase_functions_admin NOINHERIT CREATEROLE LOGIN NOREPLICATION;
    END IF;

    GRANT USAGE ON SCHEMA net TO supabase_functions_admin, postgres, anon, authenticated, service_role;

    IF EXISTS (
      SELECT FROM pg_extension
      WHERE extname = 'pg_net'
      -- all versions in use on existing projects as of 2025-02-20
      -- version 0.12.0 onwards don't need these applied
      AND extversion IN ('0.2', '0.6', '0.7', '0.7.1', '0.8', '0.10.0', '0.11.0')
    ) THEN
      ALTER function net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) SECURITY DEFINER;
      ALTER function net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) SECURITY DEFINER;

      ALTER function net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) SET search_path = net;
      ALTER function net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) SET search_path = net;

      REVOKE ALL ON FUNCTION net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) FROM PUBLIC;
      REVOKE ALL ON FUNCTION net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) FROM PUBLIC;

      GRANT EXECUTE ON FUNCTION net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) TO supabase_functions_admin, postgres, anon, authenticated, service_role;
      GRANT EXECUTE ON FUNCTION net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) TO supabase_functions_admin, postgres, anon, authenticated, service_role;
    END IF;
  END IF;
END;
$$;


ALTER FUNCTION extensions.grant_pg_net_access() OWNER TO supabase_admin;

--
-- Name: FUNCTION grant_pg_net_access(); Type: COMMENT; Schema: extensions; Owner: supabase_admin
--

COMMENT ON FUNCTION extensions.grant_pg_net_access() IS 'Grants access to pg_net';


--
-- Name: pgrst_ddl_watch(); Type: FUNCTION; Schema: extensions; Owner: supabase_admin
--

CREATE FUNCTION extensions.pgrst_ddl_watch() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  cmd record;
BEGIN
  FOR cmd IN SELECT * FROM pg_event_trigger_ddl_commands()
  LOOP
    IF cmd.command_tag IN (
      'CREATE SCHEMA', 'ALTER SCHEMA'
    , 'CREATE TABLE', 'CREATE TABLE AS', 'SELECT INTO', 'ALTER TABLE'
    , 'CREATE FOREIGN TABLE', 'ALTER FOREIGN TABLE'
    , 'CREATE VIEW', 'ALTER VIEW'
    , 'CREATE MATERIALIZED VIEW', 'ALTER MATERIALIZED VIEW'
    , 'CREATE FUNCTION', 'ALTER FUNCTION'
    , 'CREATE TRIGGER'
    , 'CREATE TYPE', 'ALTER TYPE'
    , 'CREATE RULE'
    , 'COMMENT'
    )
    -- don't notify in case of CREATE TEMP table or other objects created on pg_temp
    AND cmd.schema_name is distinct from 'pg_temp'
    THEN
      NOTIFY pgrst, 'reload schema';
    END IF;
  END LOOP;
END; $$;


ALTER FUNCTION extensions.pgrst_ddl_watch() OWNER TO supabase_admin;

--
-- Name: pgrst_drop_watch(); Type: FUNCTION; Schema: extensions; Owner: supabase_admin
--

CREATE FUNCTION extensions.pgrst_drop_watch() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  obj record;
BEGIN
  FOR obj IN SELECT * FROM pg_event_trigger_dropped_objects()
  LOOP
    IF obj.object_type IN (
      'schema'
    , 'table'
    , 'foreign table'
    , 'view'
    , 'materialized view'
    , 'function'
    , 'trigger'
    , 'type'
    , 'rule'
    )
    AND obj.is_temporary IS false -- no pg_temp objects
    THEN
      NOTIFY pgrst, 'reload schema';
    END IF;
  END LOOP;
END; $$;


ALTER FUNCTION extensions.pgrst_drop_watch() OWNER TO supabase_admin;

--
-- Name: set_graphql_placeholder(); Type: FUNCTION; Schema: extensions; Owner: supabase_admin
--

CREATE FUNCTION extensions.set_graphql_placeholder() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $_$
    DECLARE
    graphql_is_dropped bool;
    BEGIN
    graphql_is_dropped = (
        SELECT ev.schema_name = 'graphql_public'
        FROM pg_event_trigger_dropped_objects() AS ev
        WHERE ev.schema_name = 'graphql_public'
    );

    IF graphql_is_dropped
    THEN
        create or replace function graphql_public.graphql(
            "operationName" text default null,
            query text default null,
            variables jsonb default null,
            extensions jsonb default null
        )
            returns jsonb
            language plpgsql
        as $$
            DECLARE
                server_version float;
            BEGIN
                server_version = (SELECT (SPLIT_PART((select version()), ' ', 2))::float);

                IF server_version >= 14 THEN
                    RETURN jsonb_build_object(
                        'errors', jsonb_build_array(
                            jsonb_build_object(
                                'message', 'pg_graphql extension is not enabled.'
                            )
                        )
                    );
                ELSE
                    RETURN jsonb_build_object(
                        'errors', jsonb_build_array(
                            jsonb_build_object(
                                'message', 'pg_graphql is only available on projects running Postgres 14 onwards.'
                            )
                        )
                    );
                END IF;
            END;
        $$;
    END IF;

    END;
$_$;


ALTER FUNCTION extensions.set_graphql_placeholder() OWNER TO supabase_admin;

--
-- Name: FUNCTION set_graphql_placeholder(); Type: COMMENT; Schema: extensions; Owner: supabase_admin
--

COMMENT ON FUNCTION extensions.set_graphql_placeholder() IS 'Reintroduces placeholder function for graphql_public.graphql';


--
-- Name: get_auth(text); Type: FUNCTION; Schema: pgbouncer; Owner: supabase_admin
--

CREATE FUNCTION pgbouncer.get_auth(p_usename text) RETURNS TABLE(username text, password text)
    LANGUAGE plpgsql SECURITY DEFINER
    AS $_$
begin
    raise debug 'PgBouncer auth request: %', p_usename;

    return query
    select 
        rolname::text, 
        case when rolvaliduntil < now() 
            then null 
            else rolpassword::text 
        end 
    from pg_authid 
    where rolname=$1 and rolcanlogin;
end;
$_$;


ALTER FUNCTION pgbouncer.get_auth(p_usename text) OWNER TO supabase_admin;

--
-- Name: apply_rls(jsonb, integer); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer DEFAULT (1024 * 1024)) RETURNS SETOF realtime.wal_rls
    LANGUAGE plpgsql
    AS $$
declare
-- Regclass of the table e.g. public.notes
entity_ regclass = (quote_ident(wal ->> 'schema') || '.' || quote_ident(wal ->> 'table'))::regclass;

-- I, U, D, T: insert, update ...
action realtime.action = (
    case wal ->> 'action'
        when 'I' then 'INSERT'
        when 'U' then 'UPDATE'
        when 'D' then 'DELETE'
        else 'ERROR'
    end
);

-- Is row level security enabled for the table
is_rls_enabled bool = relrowsecurity from pg_class where oid = entity_;

subscriptions realtime.subscription[] = array_agg(subs)
    from
        realtime.subscription subs
    where
        subs.entity = entity_;

-- Subscription vars
roles regrole[] = array_agg(distinct us.claims_role::text)
    from
        unnest(subscriptions) us;

working_role regrole;
claimed_role regrole;
claims jsonb;

subscription_id uuid;
subscription_has_access bool;
visible_to_subscription_ids uuid[] = '{}';

-- structured info for wal's columns
columns realtime.wal_column[];
-- previous identity values for update/delete
old_columns realtime.wal_column[];

error_record_exceeds_max_size boolean = octet_length(wal::text) > max_record_bytes;

-- Primary jsonb output for record
output jsonb;

begin
perform set_config('role', null, true);

columns =
    array_agg(
        (
            x->>'name',
            x->>'type',
            x->>'typeoid',
            realtime.cast(
                (x->'value') #>> '{}',
                coalesce(
                    (x->>'typeoid')::regtype, -- null when wal2json version <= 2.4
                    (x->>'type')::regtype
                )
            ),
            (pks ->> 'name') is not null,
            true
        )::realtime.wal_column
    )
    from
        jsonb_array_elements(wal -> 'columns') x
        left join jsonb_array_elements(wal -> 'pk') pks
            on (x ->> 'name') = (pks ->> 'name');

old_columns =
    array_agg(
        (
            x->>'name',
            x->>'type',
            x->>'typeoid',
            realtime.cast(
                (x->'value') #>> '{}',
                coalesce(
                    (x->>'typeoid')::regtype, -- null when wal2json version <= 2.4
                    (x->>'type')::regtype
                )
            ),
            (pks ->> 'name') is not null,
            true
        )::realtime.wal_column
    )
    from
        jsonb_array_elements(wal -> 'identity') x
        left join jsonb_array_elements(wal -> 'pk') pks
            on (x ->> 'name') = (pks ->> 'name');

for working_role in select * from unnest(roles) loop

    -- Update `is_selectable` for columns and old_columns
    columns =
        array_agg(
            (
                c.name,
                c.type_name,
                c.type_oid,
                c.value,
                c.is_pkey,
                pg_catalog.has_column_privilege(working_role, entity_, c.name, 'SELECT')
            )::realtime.wal_column
        )
        from
            unnest(columns) c;

    old_columns =
            array_agg(
                (
                    c.name,
                    c.type_name,
                    c.type_oid,
                    c.value,
                    c.is_pkey,
                    pg_catalog.has_column_privilege(working_role, entity_, c.name, 'SELECT')
                )::realtime.wal_column
            )
            from
                unnest(old_columns) c;

    if action <> 'DELETE' and count(1) = 0 from unnest(columns) c where c.is_pkey then
        return next (
            jsonb_build_object(
                'schema', wal ->> 'schema',
                'table', wal ->> 'table',
                'type', action
            ),
            is_rls_enabled,
            -- subscriptions is already filtered by entity
            (select array_agg(s.subscription_id) from unnest(subscriptions) as s where claims_role = working_role),
            array['Error 400: Bad Request, no primary key']
        )::realtime.wal_rls;

    -- The claims role does not have SELECT permission to the primary key of entity
    elsif action <> 'DELETE' and sum(c.is_selectable::int) <> count(1) from unnest(columns) c where c.is_pkey then
        return next (
            jsonb_build_object(
                'schema', wal ->> 'schema',
                'table', wal ->> 'table',
                'type', action
            ),
            is_rls_enabled,
            (select array_agg(s.subscription_id) from unnest(subscriptions) as s where claims_role = working_role),
            array['Error 401: Unauthorized']
        )::realtime.wal_rls;

    else
        output = jsonb_build_object(
            'schema', wal ->> 'schema',
            'table', wal ->> 'table',
            'type', action,
            'commit_timestamp', to_char(
                ((wal ->> 'timestamp')::timestamptz at time zone 'utc'),
                'YYYY-MM-DD"T"HH24:MI:SS.MS"Z"'
            ),
            'columns', (
                select
                    jsonb_agg(
                        jsonb_build_object(
                            'name', pa.attname,
                            'type', pt.typname
                        )
                        order by pa.attnum asc
                    )
                from
                    pg_attribute pa
                    join pg_type pt
                        on pa.atttypid = pt.oid
                where
                    attrelid = entity_
                    and attnum > 0
                    and pg_catalog.has_column_privilege(working_role, entity_, pa.attname, 'SELECT')
            )
        )
        -- Add "record" key for insert and update
        || case
            when action in ('INSERT', 'UPDATE') then
                jsonb_build_object(
                    'record',
                    (
                        select
                            jsonb_object_agg(
                                -- if unchanged toast, get column name and value from old record
                                coalesce((c).name, (oc).name),
                                case
                                    when (c).name is null then (oc).value
                                    else (c).value
                                end
                            )
                        from
                            unnest(columns) c
                            full outer join unnest(old_columns) oc
                                on (c).name = (oc).name
                        where
                            coalesce((c).is_selectable, (oc).is_selectable)
                            and ( not error_record_exceeds_max_size or (octet_length((c).value::text) <= 64))
                    )
                )
            else '{}'::jsonb
        end
        -- Add "old_record" key for update and delete
        || case
            when action = 'UPDATE' then
                jsonb_build_object(
                        'old_record',
                        (
                            select jsonb_object_agg((c).name, (c).value)
                            from unnest(old_columns) c
                            where
                                (c).is_selectable
                                and ( not error_record_exceeds_max_size or (octet_length((c).value::text) <= 64))
                        )
                    )
            when action = 'DELETE' then
                jsonb_build_object(
                    'old_record',
                    (
                        select jsonb_object_agg((c).name, (c).value)
                        from unnest(old_columns) c
                        where
                            (c).is_selectable
                            and ( not error_record_exceeds_max_size or (octet_length((c).value::text) <= 64))
                            and ( not is_rls_enabled or (c).is_pkey ) -- if RLS enabled, we can't secure deletes so filter to pkey
                    )
                )
            else '{}'::jsonb
        end;

        -- Create the prepared statement
        if is_rls_enabled and action <> 'DELETE' then
            if (select 1 from pg_prepared_statements where name = 'walrus_rls_stmt' limit 1) > 0 then
                deallocate walrus_rls_stmt;
            end if;
            execute realtime.build_prepared_statement_sql('walrus_rls_stmt', entity_, columns);
        end if;

        visible_to_subscription_ids = '{}';

        for subscription_id, claims in (
                select
                    subs.subscription_id,
                    subs.claims
                from
                    unnest(subscriptions) subs
                where
                    subs.entity = entity_
                    and subs.claims_role = working_role
                    and (
                        realtime.is_visible_through_filters(columns, subs.filters)
                        or (
                          action = 'DELETE'
                          and realtime.is_visible_through_filters(old_columns, subs.filters)
                        )
                    )
        ) loop

            if not is_rls_enabled or action = 'DELETE' then
                visible_to_subscription_ids = visible_to_subscription_ids || subscription_id;
            else
                -- Check if RLS allows the role to see the record
                perform
                    -- Trim leading and trailing quotes from working_role because set_config
                    -- doesn't recognize the role as valid if they are included
                    set_config('role', trim(both '"' from working_role::text), true),
                    set_config('request.jwt.claims', claims::text, true);

                execute 'execute walrus_rls_stmt' into subscription_has_access;

                if subscription_has_access then
                    visible_to_subscription_ids = visible_to_subscription_ids || subscription_id;
                end if;
            end if;
        end loop;

        perform set_config('role', null, true);

        return next (
            output,
            is_rls_enabled,
            visible_to_subscription_ids,
            case
                when error_record_exceeds_max_size then array['Error 413: Payload Too Large']
                else '{}'
            end
        )::realtime.wal_rls;

    end if;
end loop;

perform set_config('role', null, true);
end;
$$;


ALTER FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer) OWNER TO supabase_admin;

--
-- Name: broadcast_changes(text, text, text, text, text, record, record, text); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.broadcast_changes(topic_name text, event_name text, operation text, table_name text, table_schema text, new record, old record, level text DEFAULT 'ROW'::text) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    -- Declare a variable to hold the JSONB representation of the row
    row_data jsonb := '{}'::jsonb;
BEGIN
    IF level = 'STATEMENT' THEN
        RAISE EXCEPTION 'function can only be triggered for each row, not for each statement';
    END IF;
    -- Check the operation type and handle accordingly
    IF operation = 'INSERT' OR operation = 'UPDATE' OR operation = 'DELETE' THEN
        row_data := jsonb_build_object('old_record', OLD, 'record', NEW, 'operation', operation, 'table', table_name, 'schema', table_schema);
        PERFORM realtime.send (row_data, event_name, topic_name);
    ELSE
        RAISE EXCEPTION 'Unexpected operation type: %', operation;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Failed to process the row: %', SQLERRM;
END;

$$;


ALTER FUNCTION realtime.broadcast_changes(topic_name text, event_name text, operation text, table_name text, table_schema text, new record, old record, level text) OWNER TO supabase_admin;

--
-- Name: build_prepared_statement_sql(text, regclass, realtime.wal_column[]); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) RETURNS text
    LANGUAGE sql
    AS $$
      /*
      Builds a sql string that, if executed, creates a prepared statement to
      tests retrive a row from *entity* by its primary key columns.
      Example
          select realtime.build_prepared_statement_sql('public.notes', '{"id"}'::text[], '{"bigint"}'::text[])
      */
          select
      'prepare ' || prepared_statement_name || ' as
          select
              exists(
                  select
                      1
                  from
                      ' || entity || '
                  where
                      ' || string_agg(quote_ident(pkc.name) || '=' || quote_nullable(pkc.value #>> '{}') , ' and ') || '
              )'
          from
              unnest(columns) pkc
          where
              pkc.is_pkey
          group by
              entity
      $$;


ALTER FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) OWNER TO supabase_admin;

--
-- Name: cast(text, regtype); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime."cast"(val text, type_ regtype) RETURNS jsonb
    LANGUAGE plpgsql IMMUTABLE
    AS $$
    declare
      res jsonb;
    begin
      execute format('select to_jsonb(%L::'|| type_::text || ')', val)  into res;
      return res;
    end
    $$;


ALTER FUNCTION realtime."cast"(val text, type_ regtype) OWNER TO supabase_admin;

--
-- Name: check_equality_op(realtime.equality_op, regtype, text, text); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) RETURNS boolean
    LANGUAGE plpgsql IMMUTABLE
    AS $$
      /*
      Casts *val_1* and *val_2* as type *type_* and check the *op* condition for truthiness
      */
      declare
          op_symbol text = (
              case
                  when op = 'eq' then '='
                  when op = 'neq' then '!='
                  when op = 'lt' then '<'
                  when op = 'lte' then '<='
                  when op = 'gt' then '>'
                  when op = 'gte' then '>='
                  when op = 'in' then '= any'
                  else 'UNKNOWN OP'
              end
          );
          res boolean;
      begin
          execute format(
              'select %L::'|| type_::text || ' ' || op_symbol
              || ' ( %L::'
              || (
                  case
                      when op = 'in' then type_::text || '[]'
                      else type_::text end
              )
              || ')', val_1, val_2) into res;
          return res;
      end;
      $$;


ALTER FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) OWNER TO supabase_admin;

--
-- Name: is_visible_through_filters(realtime.wal_column[], realtime.user_defined_filter[]); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) RETURNS boolean
    LANGUAGE sql IMMUTABLE
    AS $_$
    /*
    Should the record be visible (true) or filtered out (false) after *filters* are applied
    */
        select
            -- Default to allowed when no filters present
            $2 is null -- no filters. this should not happen because subscriptions has a default
            or array_length($2, 1) is null -- array length of an empty array is null
            or bool_and(
                coalesce(
                    realtime.check_equality_op(
                        op:=f.op,
                        type_:=coalesce(
                            col.type_oid::regtype, -- null when wal2json version <= 2.4
                            col.type_name::regtype
                        ),
                        -- cast jsonb to text
                        val_1:=col.value #>> '{}',
                        val_2:=f.value
                    ),
                    false -- if null, filter does not match
                )
            )
        from
            unnest(filters) f
            join unnest(columns) col
                on f.column_name = col.name;
    $_$;


ALTER FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) OWNER TO supabase_admin;

--
-- Name: list_changes(name, name, integer, integer); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) RETURNS SETOF realtime.wal_rls
    LANGUAGE sql
    SET log_min_messages TO 'fatal'
    AS $$
      with pub as (
        select
          concat_ws(
            ',',
            case when bool_or(pubinsert) then 'insert' else null end,
            case when bool_or(pubupdate) then 'update' else null end,
            case when bool_or(pubdelete) then 'delete' else null end
          ) as w2j_actions,
          coalesce(
            string_agg(
              realtime.quote_wal2json(format('%I.%I', schemaname, tablename)::regclass),
              ','
            ) filter (where ppt.tablename is not null and ppt.tablename not like '% %'),
            ''
          ) w2j_add_tables
        from
          pg_publication pp
          left join pg_publication_tables ppt
            on pp.pubname = ppt.pubname
        where
          pp.pubname = publication
        group by
          pp.pubname
        limit 1
      ),
      w2j as (
        select
          x.*, pub.w2j_add_tables
        from
          pub,
          pg_logical_slot_get_changes(
            slot_name, null, max_changes,
            'include-pk', 'true',
            'include-transaction', 'false',
            'include-timestamp', 'true',
            'include-type-oids', 'true',
            'format-version', '2',
            'actions', pub.w2j_actions,
            'add-tables', pub.w2j_add_tables
          ) x
      )
      select
        xyz.wal,
        xyz.is_rls_enabled,
        xyz.subscription_ids,
        xyz.errors
      from
        w2j,
        realtime.apply_rls(
          wal := w2j.data::jsonb,
          max_record_bytes := max_record_bytes
        ) xyz(wal, is_rls_enabled, subscription_ids, errors)
      where
        w2j.w2j_add_tables <> ''
        and xyz.subscription_ids[1] is not null
    $$;


ALTER FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) OWNER TO supabase_admin;

--
-- Name: quote_wal2json(regclass); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.quote_wal2json(entity regclass) RETURNS text
    LANGUAGE sql IMMUTABLE STRICT
    AS $$
      select
        (
          select string_agg('' || ch,'')
          from unnest(string_to_array(nsp.nspname::text, null)) with ordinality x(ch, idx)
          where
            not (x.idx = 1 and x.ch = '"')
            and not (
              x.idx = array_length(string_to_array(nsp.nspname::text, null), 1)
              and x.ch = '"'
            )
        )
        || '.'
        || (
          select string_agg('' || ch,'')
          from unnest(string_to_array(pc.relname::text, null)) with ordinality x(ch, idx)
          where
            not (x.idx = 1 and x.ch = '"')
            and not (
              x.idx = array_length(string_to_array(nsp.nspname::text, null), 1)
              and x.ch = '"'
            )
          )
      from
        pg_class pc
        join pg_namespace nsp
          on pc.relnamespace = nsp.oid
      where
        pc.oid = entity
    $$;


ALTER FUNCTION realtime.quote_wal2json(entity regclass) OWNER TO supabase_admin;

--
-- Name: send(jsonb, text, text, boolean); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.send(payload jsonb, event text, topic text, private boolean DEFAULT true) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  BEGIN
    -- Set the topic configuration
    EXECUTE format('SET LOCAL realtime.topic TO %L', topic);

    -- Attempt to insert the message
    INSERT INTO realtime.messages (payload, event, topic, private, extension)
    VALUES (payload, event, topic, private, 'broadcast');
  EXCEPTION
    WHEN OTHERS THEN
      -- Capture and notify the error
      RAISE WARNING 'ErrorSendingBroadcastMessage: %', SQLERRM;
  END;
END;
$$;


ALTER FUNCTION realtime.send(payload jsonb, event text, topic text, private boolean) OWNER TO supabase_admin;

--
-- Name: subscription_check_filters(); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.subscription_check_filters() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    /*
    Validates that the user defined filters for a subscription:
    - refer to valid columns that the claimed role may access
    - values are coercable to the correct column type
    */
    declare
        col_names text[] = coalesce(
                array_agg(c.column_name order by c.ordinal_position),
                '{}'::text[]
            )
            from
                information_schema.columns c
            where
                format('%I.%I', c.table_schema, c.table_name)::regclass = new.entity
                and pg_catalog.has_column_privilege(
                    (new.claims ->> 'role'),
                    format('%I.%I', c.table_schema, c.table_name)::regclass,
                    c.column_name,
                    'SELECT'
                );
        filter realtime.user_defined_filter;
        col_type regtype;

        in_val jsonb;
    begin
        for filter in select * from unnest(new.filters) loop
            -- Filtered column is valid
            if not filter.column_name = any(col_names) then
                raise exception 'invalid column for filter %', filter.column_name;
            end if;

            -- Type is sanitized and safe for string interpolation
            col_type = (
                select atttypid::regtype
                from pg_catalog.pg_attribute
                where attrelid = new.entity
                      and attname = filter.column_name
            );
            if col_type is null then
                raise exception 'failed to lookup type for column %', filter.column_name;
            end if;

            -- Set maximum number of entries for in filter
            if filter.op = 'in'::realtime.equality_op then
                in_val = realtime.cast(filter.value, (col_type::text || '[]')::regtype);
                if coalesce(jsonb_array_length(in_val), 0) > 100 then
                    raise exception 'too many values for `in` filter. Maximum 100';
                end if;
            else
                -- raises an exception if value is not coercable to type
                perform realtime.cast(filter.value, col_type);
            end if;

        end loop;

        -- Apply consistent order to filters so the unique constraint on
        -- (subscription_id, entity, filters) can't be tricked by a different filter order
        new.filters = coalesce(
            array_agg(f order by f.column_name, f.op, f.value),
            '{}'
        ) from unnest(new.filters) f;

        return new;
    end;
    $$;


ALTER FUNCTION realtime.subscription_check_filters() OWNER TO supabase_admin;

--
-- Name: to_regrole(text); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.to_regrole(role_name text) RETURNS regrole
    LANGUAGE sql IMMUTABLE
    AS $$ select role_name::regrole $$;


ALTER FUNCTION realtime.to_regrole(role_name text) OWNER TO supabase_admin;

--
-- Name: topic(); Type: FUNCTION; Schema: realtime; Owner: supabase_realtime_admin
--

CREATE FUNCTION realtime.topic() RETURNS text
    LANGUAGE sql STABLE
    AS $$
select nullif(current_setting('realtime.topic', true), '')::text;
$$;


ALTER FUNCTION realtime.topic() OWNER TO supabase_realtime_admin;

--
-- Name: add_prefixes(text, text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.add_prefixes(_bucket_id text, _name text) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
    prefixes text[];
BEGIN
    prefixes := "storage"."get_prefixes"("_name");

    IF array_length(prefixes, 1) > 0 THEN
        INSERT INTO storage.prefixes (name, bucket_id)
        SELECT UNNEST(prefixes) as name, "_bucket_id" ON CONFLICT DO NOTHING;
    END IF;
END;
$$;


ALTER FUNCTION storage.add_prefixes(_bucket_id text, _name text) OWNER TO supabase_storage_admin;

--
-- Name: can_insert_object(text, text, uuid, jsonb); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.can_insert_object(bucketid text, name text, owner uuid, metadata jsonb) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  INSERT INTO "storage"."objects" ("bucket_id", "name", "owner", "metadata") VALUES (bucketid, name, owner, metadata);
  -- hack to rollback the successful insert
  RAISE sqlstate 'PT200' using
  message = 'ROLLBACK',
  detail = 'rollback successful insert';
END
$$;


ALTER FUNCTION storage.can_insert_object(bucketid text, name text, owner uuid, metadata jsonb) OWNER TO supabase_storage_admin;

--
-- Name: delete_leaf_prefixes(text[], text[]); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.delete_leaf_prefixes(bucket_ids text[], names text[]) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
    v_rows_deleted integer;
BEGIN
    LOOP
        WITH candidates AS (
            SELECT DISTINCT
                t.bucket_id,
                unnest(storage.get_prefixes(t.name)) AS name
            FROM unnest(bucket_ids, names) AS t(bucket_id, name)
        ),
        uniq AS (
             SELECT
                 bucket_id,
                 name,
                 storage.get_level(name) AS level
             FROM candidates
             WHERE name <> ''
             GROUP BY bucket_id, name
        ),
        leaf AS (
             SELECT
                 p.bucket_id,
                 p.name,
                 p.level
             FROM storage.prefixes AS p
                  JOIN uniq AS u
                       ON u.bucket_id = p.bucket_id
                           AND u.name = p.name
                           AND u.level = p.level
             WHERE NOT EXISTS (
                 SELECT 1
                 FROM storage.objects AS o
                 WHERE o.bucket_id = p.bucket_id
                   AND o.level = p.level + 1
                   AND o.name COLLATE "C" LIKE p.name || '/%'
             )
             AND NOT EXISTS (
                 SELECT 1
                 FROM storage.prefixes AS c
                 WHERE c.bucket_id = p.bucket_id
                   AND c.level = p.level + 1
                   AND c.name COLLATE "C" LIKE p.name || '/%'
             )
        )
        DELETE
        FROM storage.prefixes AS p
            USING leaf AS l
        WHERE p.bucket_id = l.bucket_id
          AND p.name = l.name
          AND p.level = l.level;

        GET DIAGNOSTICS v_rows_deleted = ROW_COUNT;
        EXIT WHEN v_rows_deleted = 0;
    END LOOP;
END;
$$;


ALTER FUNCTION storage.delete_leaf_prefixes(bucket_ids text[], names text[]) OWNER TO supabase_storage_admin;

--
-- Name: delete_prefix(text, text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.delete_prefix(_bucket_id text, _name text) RETURNS boolean
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
BEGIN
    -- Check if we can delete the prefix
    IF EXISTS(
        SELECT FROM "storage"."prefixes"
        WHERE "prefixes"."bucket_id" = "_bucket_id"
          AND level = "storage"."get_level"("_name") + 1
          AND "prefixes"."name" COLLATE "C" LIKE "_name" || '/%'
        LIMIT 1
    )
    OR EXISTS(
        SELECT FROM "storage"."objects"
        WHERE "objects"."bucket_id" = "_bucket_id"
          AND "storage"."get_level"("objects"."name") = "storage"."get_level"("_name") + 1
          AND "objects"."name" COLLATE "C" LIKE "_name" || '/%'
        LIMIT 1
    ) THEN
    -- There are sub-objects, skip deletion
    RETURN false;
    ELSE
        DELETE FROM "storage"."prefixes"
        WHERE "prefixes"."bucket_id" = "_bucket_id"
          AND level = "storage"."get_level"("_name")
          AND "prefixes"."name" = "_name";
        RETURN true;
    END IF;
END;
$$;


ALTER FUNCTION storage.delete_prefix(_bucket_id text, _name text) OWNER TO supabase_storage_admin;

--
-- Name: delete_prefix_hierarchy_trigger(); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.delete_prefix_hierarchy_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    prefix text;
BEGIN
    prefix := "storage"."get_prefix"(OLD."name");

    IF coalesce(prefix, '') != '' THEN
        PERFORM "storage"."delete_prefix"(OLD."bucket_id", prefix);
    END IF;

    RETURN OLD;
END;
$$;


ALTER FUNCTION storage.delete_prefix_hierarchy_trigger() OWNER TO supabase_storage_admin;

--
-- Name: enforce_bucket_name_length(); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.enforce_bucket_name_length() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
    if length(new.name) > 100 then
        raise exception 'bucket name "%" is too long (% characters). Max is 100.', new.name, length(new.name);
    end if;
    return new;
end;
$$;


ALTER FUNCTION storage.enforce_bucket_name_length() OWNER TO supabase_storage_admin;

--
-- Name: extension(text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.extension(name text) RETURNS text
    LANGUAGE plpgsql IMMUTABLE
    AS $$
DECLARE
    _parts text[];
    _filename text;
BEGIN
    SELECT string_to_array(name, '/') INTO _parts;
    SELECT _parts[array_length(_parts,1)] INTO _filename;
    RETURN reverse(split_part(reverse(_filename), '.', 1));
END
$$;


ALTER FUNCTION storage.extension(name text) OWNER TO supabase_storage_admin;

--
-- Name: filename(text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.filename(name text) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
_parts text[];
BEGIN
	select string_to_array(name, '/') into _parts;
	return _parts[array_length(_parts,1)];
END
$$;


ALTER FUNCTION storage.filename(name text) OWNER TO supabase_storage_admin;

--
-- Name: foldername(text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.foldername(name text) RETURNS text[]
    LANGUAGE plpgsql IMMUTABLE
    AS $$
DECLARE
    _parts text[];
BEGIN
    -- Split on "/" to get path segments
    SELECT string_to_array(name, '/') INTO _parts;
    -- Return everything except the last segment
    RETURN _parts[1 : array_length(_parts,1) - 1];
END
$$;


ALTER FUNCTION storage.foldername(name text) OWNER TO supabase_storage_admin;

--
-- Name: get_level(text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.get_level(name text) RETURNS integer
    LANGUAGE sql IMMUTABLE STRICT
    AS $$
SELECT array_length(string_to_array("name", '/'), 1);
$$;


ALTER FUNCTION storage.get_level(name text) OWNER TO supabase_storage_admin;

--
-- Name: get_prefix(text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.get_prefix(name text) RETURNS text
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
SELECT
    CASE WHEN strpos("name", '/') > 0 THEN
             regexp_replace("name", '[\/]{1}[^\/]+\/?$', '')
         ELSE
             ''
        END;
$_$;


ALTER FUNCTION storage.get_prefix(name text) OWNER TO supabase_storage_admin;

--
-- Name: get_prefixes(text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.get_prefixes(name text) RETURNS text[]
    LANGUAGE plpgsql IMMUTABLE STRICT
    AS $$
DECLARE
    parts text[];
    prefixes text[];
    prefix text;
BEGIN
    -- Split the name into parts by '/'
    parts := string_to_array("name", '/');
    prefixes := '{}';

    -- Construct the prefixes, stopping one level below the last part
    FOR i IN 1..array_length(parts, 1) - 1 LOOP
            prefix := array_to_string(parts[1:i], '/');
            prefixes := array_append(prefixes, prefix);
    END LOOP;

    RETURN prefixes;
END;
$$;


ALTER FUNCTION storage.get_prefixes(name text) OWNER TO supabase_storage_admin;

--
-- Name: get_size_by_bucket(); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.get_size_by_bucket() RETURNS TABLE(size bigint, bucket_id text)
    LANGUAGE plpgsql STABLE
    AS $$
BEGIN
    return query
        select sum((metadata->>'size')::bigint) as size, obj.bucket_id
        from "storage".objects as obj
        group by obj.bucket_id;
END
$$;


ALTER FUNCTION storage.get_size_by_bucket() OWNER TO supabase_storage_admin;

--
-- Name: list_multipart_uploads_with_delimiter(text, text, text, integer, text, text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.list_multipart_uploads_with_delimiter(bucket_id text, prefix_param text, delimiter_param text, max_keys integer DEFAULT 100, next_key_token text DEFAULT ''::text, next_upload_token text DEFAULT ''::text) RETURNS TABLE(key text, id text, created_at timestamp with time zone)
    LANGUAGE plpgsql
    AS $_$
BEGIN
    RETURN QUERY EXECUTE
        'SELECT DISTINCT ON(key COLLATE "C") * from (
            SELECT
                CASE
                    WHEN position($2 IN substring(key from length($1) + 1)) > 0 THEN
                        substring(key from 1 for length($1) + position($2 IN substring(key from length($1) + 1)))
                    ELSE
                        key
                END AS key, id, created_at
            FROM
                storage.s3_multipart_uploads
            WHERE
                bucket_id = $5 AND
                key ILIKE $1 || ''%'' AND
                CASE
                    WHEN $4 != '''' AND $6 = '''' THEN
                        CASE
                            WHEN position($2 IN substring(key from length($1) + 1)) > 0 THEN
                                substring(key from 1 for length($1) + position($2 IN substring(key from length($1) + 1))) COLLATE "C" > $4
                            ELSE
                                key COLLATE "C" > $4
                            END
                    ELSE
                        true
                END AND
                CASE
                    WHEN $6 != '''' THEN
                        id COLLATE "C" > $6
                    ELSE
                        true
                    END
            ORDER BY
                key COLLATE "C" ASC, created_at ASC) as e order by key COLLATE "C" LIMIT $3'
        USING prefix_param, delimiter_param, max_keys, next_key_token, bucket_id, next_upload_token;
END;
$_$;


ALTER FUNCTION storage.list_multipart_uploads_with_delimiter(bucket_id text, prefix_param text, delimiter_param text, max_keys integer, next_key_token text, next_upload_token text) OWNER TO supabase_storage_admin;

--
-- Name: list_objects_with_delimiter(text, text, text, integer, text, text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.list_objects_with_delimiter(bucket_id text, prefix_param text, delimiter_param text, max_keys integer DEFAULT 100, start_after text DEFAULT ''::text, next_token text DEFAULT ''::text) RETURNS TABLE(name text, id uuid, metadata jsonb, updated_at timestamp with time zone)
    LANGUAGE plpgsql
    AS $_$
BEGIN
    RETURN QUERY EXECUTE
        'SELECT DISTINCT ON(name COLLATE "C") * from (
            SELECT
                CASE
                    WHEN position($2 IN substring(name from length($1) + 1)) > 0 THEN
                        substring(name from 1 for length($1) + position($2 IN substring(name from length($1) + 1)))
                    ELSE
                        name
                END AS name, id, metadata, updated_at
            FROM
                storage.objects
            WHERE
                bucket_id = $5 AND
                name ILIKE $1 || ''%'' AND
                CASE
                    WHEN $6 != '''' THEN
                    name COLLATE "C" > $6
                ELSE true END
                AND CASE
                    WHEN $4 != '''' THEN
                        CASE
                            WHEN position($2 IN substring(name from length($1) + 1)) > 0 THEN
                                substring(name from 1 for length($1) + position($2 IN substring(name from length($1) + 1))) COLLATE "C" > $4
                            ELSE
                                name COLLATE "C" > $4
                            END
                    ELSE
                        true
                END
            ORDER BY
                name COLLATE "C" ASC) as e order by name COLLATE "C" LIMIT $3'
        USING prefix_param, delimiter_param, max_keys, next_token, bucket_id, start_after;
END;
$_$;


ALTER FUNCTION storage.list_objects_with_delimiter(bucket_id text, prefix_param text, delimiter_param text, max_keys integer, start_after text, next_token text) OWNER TO supabase_storage_admin;

--
-- Name: lock_top_prefixes(text[], text[]); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.lock_top_prefixes(bucket_ids text[], names text[]) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
    v_bucket text;
    v_top text;
BEGIN
    FOR v_bucket, v_top IN
        SELECT DISTINCT t.bucket_id,
            split_part(t.name, '/', 1) AS top
        FROM unnest(bucket_ids, names) AS t(bucket_id, name)
        WHERE t.name <> ''
        ORDER BY 1, 2
        LOOP
            PERFORM pg_advisory_xact_lock(hashtextextended(v_bucket || '/' || v_top, 0));
        END LOOP;
END;
$$;


ALTER FUNCTION storage.lock_top_prefixes(bucket_ids text[], names text[]) OWNER TO supabase_storage_admin;

--
-- Name: objects_delete_cleanup(); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.objects_delete_cleanup() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
    v_bucket_ids text[];
    v_names      text[];
BEGIN
    IF current_setting('storage.gc.prefixes', true) = '1' THEN
        RETURN NULL;
    END IF;

    PERFORM set_config('storage.gc.prefixes', '1', true);

    SELECT COALESCE(array_agg(d.bucket_id), '{}'),
           COALESCE(array_agg(d.name), '{}')
    INTO v_bucket_ids, v_names
    FROM deleted AS d
    WHERE d.name <> '';

    PERFORM storage.lock_top_prefixes(v_bucket_ids, v_names);
    PERFORM storage.delete_leaf_prefixes(v_bucket_ids, v_names);

    RETURN NULL;
END;
$$;


ALTER FUNCTION storage.objects_delete_cleanup() OWNER TO supabase_storage_admin;

--
-- Name: objects_insert_prefix_trigger(); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.objects_insert_prefix_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    PERFORM "storage"."add_prefixes"(NEW."bucket_id", NEW."name");
    NEW.level := "storage"."get_level"(NEW."name");

    RETURN NEW;
END;
$$;


ALTER FUNCTION storage.objects_insert_prefix_trigger() OWNER TO supabase_storage_admin;

--
-- Name: objects_update_cleanup(); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.objects_update_cleanup() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
    -- NEW - OLD (destinations to create prefixes for)
    v_add_bucket_ids text[];
    v_add_names      text[];

    -- OLD - NEW (sources to prune)
    v_src_bucket_ids text[];
    v_src_names      text[];
BEGIN
    IF TG_OP <> 'UPDATE' THEN
        RETURN NULL;
    END IF;

    -- 1) Compute NEWÃ”ÃªÃ†OLD (added paths) and OLDÃ”ÃªÃ†NEW (moved-away paths)
    WITH added AS (
        SELECT n.bucket_id, n.name
        FROM new_rows n
        WHERE n.name <> '' AND position('/' in n.name) > 0
        EXCEPT
        SELECT o.bucket_id, o.name FROM old_rows o WHERE o.name <> ''
    ),
    moved AS (
         SELECT o.bucket_id, o.name
         FROM old_rows o
         WHERE o.name <> ''
         EXCEPT
         SELECT n.bucket_id, n.name FROM new_rows n WHERE n.name <> ''
    )
    SELECT
        -- arrays for ADDED (dest) in stable order
        COALESCE( (SELECT array_agg(a.bucket_id ORDER BY a.bucket_id, a.name) FROM added a), '{}' ),
        COALESCE( (SELECT array_agg(a.name      ORDER BY a.bucket_id, a.name) FROM added a), '{}' ),
        -- arrays for MOVED (src) in stable order
        COALESCE( (SELECT array_agg(m.bucket_id ORDER BY m.bucket_id, m.name) FROM moved m), '{}' ),
        COALESCE( (SELECT array_agg(m.name      ORDER BY m.bucket_id, m.name) FROM moved m), '{}' )
    INTO v_add_bucket_ids, v_add_names, v_src_bucket_ids, v_src_names;

    -- Nothing to do?
    IF (array_length(v_add_bucket_ids, 1) IS NULL) AND (array_length(v_src_bucket_ids, 1) IS NULL) THEN
        RETURN NULL;
    END IF;

    -- 2) Take per-(bucket, top) locks: ALL prefixes in consistent global order to prevent deadlocks
    DECLARE
        v_all_bucket_ids text[];
        v_all_names text[];
    BEGIN
        -- Combine source and destination arrays for consistent lock ordering
        v_all_bucket_ids := COALESCE(v_src_bucket_ids, '{}') || COALESCE(v_add_bucket_ids, '{}');
        v_all_names := COALESCE(v_src_names, '{}') || COALESCE(v_add_names, '{}');

        -- Single lock call ensures consistent global ordering across all transactions
        IF array_length(v_all_bucket_ids, 1) IS NOT NULL THEN
            PERFORM storage.lock_top_prefixes(v_all_bucket_ids, v_all_names);
        END IF;
    END;

    -- 3) Create destination prefixes (NEWÃ”ÃªÃ†OLD) BEFORE pruning sources
    IF array_length(v_add_bucket_ids, 1) IS NOT NULL THEN
        WITH candidates AS (
            SELECT DISTINCT t.bucket_id, unnest(storage.get_prefixes(t.name)) AS name
            FROM unnest(v_add_bucket_ids, v_add_names) AS t(bucket_id, name)
            WHERE name <> ''
        )
        INSERT INTO storage.prefixes (bucket_id, name)
        SELECT c.bucket_id, c.name
        FROM candidates c
        ON CONFLICT DO NOTHING;
    END IF;

    -- 4) Prune source prefixes bottom-up for OLDÃ”ÃªÃ†NEW
    IF array_length(v_src_bucket_ids, 1) IS NOT NULL THEN
        -- re-entrancy guard so DELETE on prefixes won't recurse
        IF current_setting('storage.gc.prefixes', true) <> '1' THEN
            PERFORM set_config('storage.gc.prefixes', '1', true);
        END IF;

        PERFORM storage.delete_leaf_prefixes(v_src_bucket_ids, v_src_names);
    END IF;

    RETURN NULL;
END;
$$;


ALTER FUNCTION storage.objects_update_cleanup() OWNER TO supabase_storage_admin;

--
-- Name: objects_update_level_trigger(); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.objects_update_level_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Ensure this is an update operation and the name has changed
    IF TG_OP = 'UPDATE' AND (NEW."name" <> OLD."name" OR NEW."bucket_id" <> OLD."bucket_id") THEN
        -- Set the new level
        NEW."level" := "storage"."get_level"(NEW."name");
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION storage.objects_update_level_trigger() OWNER TO supabase_storage_admin;

--
-- Name: objects_update_prefix_trigger(); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.objects_update_prefix_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    old_prefixes TEXT[];
BEGIN
    -- Ensure this is an update operation and the name has changed
    IF TG_OP = 'UPDATE' AND (NEW."name" <> OLD."name" OR NEW."bucket_id" <> OLD."bucket_id") THEN
        -- Retrieve old prefixes
        old_prefixes := "storage"."get_prefixes"(OLD."name");

        -- Remove old prefixes that are only used by this object
        WITH all_prefixes as (
            SELECT unnest(old_prefixes) as prefix
        ),
        can_delete_prefixes as (
             SELECT prefix
             FROM all_prefixes
             WHERE NOT EXISTS (
                 SELECT 1 FROM "storage"."objects"
                 WHERE "bucket_id" = OLD."bucket_id"
                   AND "name" <> OLD."name"
                   AND "name" LIKE (prefix || '%')
             )
         )
        DELETE FROM "storage"."prefixes" WHERE name IN (SELECT prefix FROM can_delete_prefixes);

        -- Add new prefixes
        PERFORM "storage"."add_prefixes"(NEW."bucket_id", NEW."name");
    END IF;
    -- Set the new level
    NEW."level" := "storage"."get_level"(NEW."name");

    RETURN NEW;
END;
$$;


ALTER FUNCTION storage.objects_update_prefix_trigger() OWNER TO supabase_storage_admin;

--
-- Name: operation(); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.operation() RETURNS text
    LANGUAGE plpgsql STABLE
    AS $$
BEGIN
    RETURN current_setting('storage.operation', true);
END;
$$;


ALTER FUNCTION storage.operation() OWNER TO supabase_storage_admin;

--
-- Name: prefixes_delete_cleanup(); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.prefixes_delete_cleanup() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
    v_bucket_ids text[];
    v_names      text[];
BEGIN
    IF current_setting('storage.gc.prefixes', true) = '1' THEN
        RETURN NULL;
    END IF;

    PERFORM set_config('storage.gc.prefixes', '1', true);

    SELECT COALESCE(array_agg(d.bucket_id), '{}'),
           COALESCE(array_agg(d.name), '{}')
    INTO v_bucket_ids, v_names
    FROM deleted AS d
    WHERE d.name <> '';

    PERFORM storage.lock_top_prefixes(v_bucket_ids, v_names);
    PERFORM storage.delete_leaf_prefixes(v_bucket_ids, v_names);

    RETURN NULL;
END;
$$;


ALTER FUNCTION storage.prefixes_delete_cleanup() OWNER TO supabase_storage_admin;

--
-- Name: prefixes_insert_trigger(); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.prefixes_insert_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    PERFORM "storage"."add_prefixes"(NEW."bucket_id", NEW."name");
    RETURN NEW;
END;
$$;


ALTER FUNCTION storage.prefixes_insert_trigger() OWNER TO supabase_storage_admin;

--
-- Name: search(text, text, integer, integer, integer, text, text, text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.search(prefix text, bucketname text, limits integer DEFAULT 100, levels integer DEFAULT 1, offsets integer DEFAULT 0, search text DEFAULT ''::text, sortcolumn text DEFAULT 'name'::text, sortorder text DEFAULT 'asc'::text) RETURNS TABLE(name text, id uuid, updated_at timestamp with time zone, created_at timestamp with time zone, last_accessed_at timestamp with time zone, metadata jsonb)
    LANGUAGE plpgsql
    AS $$
declare
    can_bypass_rls BOOLEAN;
begin
    SELECT rolbypassrls
    INTO can_bypass_rls
    FROM pg_roles
    WHERE rolname = coalesce(nullif(current_setting('role', true), 'none'), current_user);

    IF can_bypass_rls THEN
        RETURN QUERY SELECT * FROM storage.search_v1_optimised(prefix, bucketname, limits, levels, offsets, search, sortcolumn, sortorder);
    ELSE
        RETURN QUERY SELECT * FROM storage.search_legacy_v1(prefix, bucketname, limits, levels, offsets, search, sortcolumn, sortorder);
    END IF;
end;
$$;


ALTER FUNCTION storage.search(prefix text, bucketname text, limits integer, levels integer, offsets integer, search text, sortcolumn text, sortorder text) OWNER TO supabase_storage_admin;

--
-- Name: search_legacy_v1(text, text, integer, integer, integer, text, text, text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.search_legacy_v1(prefix text, bucketname text, limits integer DEFAULT 100, levels integer DEFAULT 1, offsets integer DEFAULT 0, search text DEFAULT ''::text, sortcolumn text DEFAULT 'name'::text, sortorder text DEFAULT 'asc'::text) RETURNS TABLE(name text, id uuid, updated_at timestamp with time zone, created_at timestamp with time zone, last_accessed_at timestamp with time zone, metadata jsonb)
    LANGUAGE plpgsql STABLE
    AS $_$
declare
    v_order_by text;
    v_sort_order text;
begin
    case
        when sortcolumn = 'name' then
            v_order_by = 'name';
        when sortcolumn = 'updated_at' then
            v_order_by = 'updated_at';
        when sortcolumn = 'created_at' then
            v_order_by = 'created_at';
        when sortcolumn = 'last_accessed_at' then
            v_order_by = 'last_accessed_at';
        else
            v_order_by = 'name';
        end case;

    case
        when sortorder = 'asc' then
            v_sort_order = 'asc';
        when sortorder = 'desc' then
            v_sort_order = 'desc';
        else
            v_sort_order = 'asc';
        end case;

    v_order_by = v_order_by || ' ' || v_sort_order;

    return query execute
        'with folders as (
           select path_tokens[$1] as folder
           from storage.objects
             where objects.name ilike $2 || $3 || ''%''
               and bucket_id = $4
               and array_length(objects.path_tokens, 1) <> $1
           group by folder
           order by folder ' || v_sort_order || '
     )
     (select folder as "name",
            null as id,
            null as updated_at,
            null as created_at,
            null as last_accessed_at,
            null as metadata from folders)
     union all
     (select path_tokens[$1] as "name",
            id,
            updated_at,
            created_at,
            last_accessed_at,
            metadata
     from storage.objects
     where objects.name ilike $2 || $3 || ''%''
       and bucket_id = $4
       and array_length(objects.path_tokens, 1) = $1
     order by ' || v_order_by || ')
     limit $5
     offset $6' using levels, prefix, search, bucketname, limits, offsets;
end;
$_$;


ALTER FUNCTION storage.search_legacy_v1(prefix text, bucketname text, limits integer, levels integer, offsets integer, search text, sortcolumn text, sortorder text) OWNER TO supabase_storage_admin;

--
-- Name: search_v1_optimised(text, text, integer, integer, integer, text, text, text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.search_v1_optimised(prefix text, bucketname text, limits integer DEFAULT 100, levels integer DEFAULT 1, offsets integer DEFAULT 0, search text DEFAULT ''::text, sortcolumn text DEFAULT 'name'::text, sortorder text DEFAULT 'asc'::text) RETURNS TABLE(name text, id uuid, updated_at timestamp with time zone, created_at timestamp with time zone, last_accessed_at timestamp with time zone, metadata jsonb)
    LANGUAGE plpgsql STABLE
    AS $_$
declare
    v_order_by text;
    v_sort_order text;
begin
    case
        when sortcolumn = 'name' then
            v_order_by = 'name';
        when sortcolumn = 'updated_at' then
            v_order_by = 'updated_at';
        when sortcolumn = 'created_at' then
            v_order_by = 'created_at';
        when sortcolumn = 'last_accessed_at' then
            v_order_by = 'last_accessed_at';
        else
            v_order_by = 'name';
        end case;

    case
        when sortorder = 'asc' then
            v_sort_order = 'asc';
        when sortorder = 'desc' then
            v_sort_order = 'desc';
        else
            v_sort_order = 'asc';
        end case;

    v_order_by = v_order_by || ' ' || v_sort_order;

    return query execute
        'with folders as (
           select (string_to_array(name, ''/''))[level] as name
           from storage.prefixes
             where lower(prefixes.name) like lower($2 || $3) || ''%''
               and bucket_id = $4
               and level = $1
           order by name ' || v_sort_order || '
     )
     (select name,
            null as id,
            null as updated_at,
            null as created_at,
            null as last_accessed_at,
            null as metadata from folders)
     union all
     (select path_tokens[level] as "name",
            id,
            updated_at,
            created_at,
            last_accessed_at,
            metadata
     from storage.objects
     where lower(objects.name) like lower($2 || $3) || ''%''
       and bucket_id = $4
       and level = $1
     order by ' || v_order_by || ')
     limit $5
     offset $6' using levels, prefix, search, bucketname, limits, offsets;
end;
$_$;


ALTER FUNCTION storage.search_v1_optimised(prefix text, bucketname text, limits integer, levels integer, offsets integer, search text, sortcolumn text, sortorder text) OWNER TO supabase_storage_admin;

--
-- Name: search_v2(text, text, integer, integer, text, text, text, text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.search_v2(prefix text, bucket_name text, limits integer DEFAULT 100, levels integer DEFAULT 1, start_after text DEFAULT ''::text, sort_order text DEFAULT 'asc'::text, sort_column text DEFAULT 'name'::text, sort_column_after text DEFAULT ''::text) RETURNS TABLE(key text, name text, id uuid, updated_at timestamp with time zone, created_at timestamp with time zone, last_accessed_at timestamp with time zone, metadata jsonb)
    LANGUAGE plpgsql STABLE
    AS $_$
DECLARE
    sort_col text;
    sort_ord text;
    cursor_op text;
    cursor_expr text;
    sort_expr text;
BEGIN
    -- Validate sort_order
    sort_ord := lower(sort_order);
    IF sort_ord NOT IN ('asc', 'desc') THEN
        sort_ord := 'asc';
    END IF;

    -- Determine cursor comparison operator
    IF sort_ord = 'asc' THEN
        cursor_op := '>';
    ELSE
        cursor_op := '<';
    END IF;
    
    sort_col := lower(sort_column);
    -- Validate sort column  
    IF sort_col IN ('updated_at', 'created_at') THEN
        cursor_expr := format(
            '($5 = '''' OR ROW(date_trunc(''milliseconds'', %I), name COLLATE "C") %s ROW(COALESCE(NULLIF($6, '''')::timestamptz, ''epoch''::timestamptz), $5))',
            sort_col, cursor_op
        );
        sort_expr := format(
            'COALESCE(date_trunc(''milliseconds'', %I), ''epoch''::timestamptz) %s, name COLLATE "C" %s',
            sort_col, sort_ord, sort_ord
        );
    ELSE
        cursor_expr := format('($5 = '''' OR name COLLATE "C" %s $5)', cursor_op);
        sort_expr := format('name COLLATE "C" %s', sort_ord);
    END IF;

    RETURN QUERY EXECUTE format(
        $sql$
        SELECT * FROM (
            (
                SELECT
                    split_part(name, '/', $4) AS key,
                    name,
                    NULL::uuid AS id,
                    updated_at,
                    created_at,
                    NULL::timestamptz AS last_accessed_at,
                    NULL::jsonb AS metadata
                FROM storage.prefixes
                WHERE name COLLATE "C" LIKE $1 || '%%'
                    AND bucket_id = $2
                    AND level = $4
                    AND %s
                ORDER BY %s
                LIMIT $3
            )
            UNION ALL
            (
                SELECT
                    split_part(name, '/', $4) AS key,
                    name,
                    id,
                    updated_at,
                    created_at,
                    last_accessed_at,
                    metadata
                FROM storage.objects
                WHERE name COLLATE "C" LIKE $1 || '%%'
                    AND bucket_id = $2
                    AND level = $4
                    AND %s
                ORDER BY %s
                LIMIT $3
            )
        ) obj
        ORDER BY %s
        LIMIT $3
        $sql$,
        cursor_expr,    -- prefixes WHERE
        sort_expr,      -- prefixes ORDER BY
        cursor_expr,    -- objects WHERE
        sort_expr,      -- objects ORDER BY
        sort_expr       -- final ORDER BY
    )
    USING prefix, bucket_name, limits, levels, start_after, sort_column_after;
END;
$_$;


ALTER FUNCTION storage.search_v2(prefix text, bucket_name text, limits integer, levels integer, start_after text, sort_order text, sort_column text, sort_column_after text) OWNER TO supabase_storage_admin;

--
-- Name: update_updated_at_column(); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.update_updated_at_column() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW; 
END;
$$;


ALTER FUNCTION storage.update_updated_at_column() OWNER TO supabase_storage_admin;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: audit_log_entries; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.audit_log_entries (
    instance_id uuid,
    id uuid NOT NULL,
    payload json,
    created_at timestamp with time zone,
    ip_address character varying(64) DEFAULT ''::character varying NOT NULL
);


ALTER TABLE auth.audit_log_entries OWNER TO supabase_auth_admin;

--
-- Name: TABLE audit_log_entries; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.audit_log_entries IS 'Auth: Audit trail for user actions.';


--
-- Name: flow_state; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.flow_state (
    id uuid NOT NULL,
    user_id uuid,
    auth_code text NOT NULL,
    code_challenge_method auth.code_challenge_method NOT NULL,
    code_challenge text NOT NULL,
    provider_type text NOT NULL,
    provider_access_token text,
    provider_refresh_token text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    authentication_method text NOT NULL,
    auth_code_issued_at timestamp with time zone
);


ALTER TABLE auth.flow_state OWNER TO supabase_auth_admin;

--
-- Name: TABLE flow_state; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.flow_state IS 'stores metadata for pkce logins';


--
-- Name: identities; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.identities (
    provider_id text NOT NULL,
    user_id uuid NOT NULL,
    identity_data jsonb NOT NULL,
    provider text NOT NULL,
    last_sign_in_at timestamp with time zone,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    email text GENERATED ALWAYS AS (lower((identity_data ->> 'email'::text))) STORED,
    id uuid DEFAULT gen_random_uuid() NOT NULL
);


ALTER TABLE auth.identities OWNER TO supabase_auth_admin;

--
-- Name: TABLE identities; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.identities IS 'Auth: Stores identities associated to a user.';


--
-- Name: COLUMN identities.email; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON COLUMN auth.identities.email IS 'Auth: Email is a generated column that references the optional email property in the identity_data';


--
-- Name: instances; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.instances (
    id uuid NOT NULL,
    uuid uuid,
    raw_base_config text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


ALTER TABLE auth.instances OWNER TO supabase_auth_admin;

--
-- Name: TABLE instances; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.instances IS 'Auth: Manages users across multiple sites.';


--
-- Name: mfa_amr_claims; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.mfa_amr_claims (
    session_id uuid NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    authentication_method text NOT NULL,
    id uuid NOT NULL
);


ALTER TABLE auth.mfa_amr_claims OWNER TO supabase_auth_admin;

--
-- Name: TABLE mfa_amr_claims; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.mfa_amr_claims IS 'auth: stores authenticator method reference claims for multi factor authentication';


--
-- Name: mfa_challenges; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.mfa_challenges (
    id uuid NOT NULL,
    factor_id uuid NOT NULL,
    created_at timestamp with time zone NOT NULL,
    verified_at timestamp with time zone,
    ip_address inet NOT NULL,
    otp_code text,
    web_authn_session_data jsonb
);


ALTER TABLE auth.mfa_challenges OWNER TO supabase_auth_admin;

--
-- Name: TABLE mfa_challenges; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.mfa_challenges IS 'auth: stores metadata about challenge requests made';


--
-- Name: mfa_factors; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.mfa_factors (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    friendly_name text,
    factor_type auth.factor_type NOT NULL,
    status auth.factor_status NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    secret text,
    phone text,
    last_challenged_at timestamp with time zone,
    web_authn_credential jsonb,
    web_authn_aaguid uuid,
    last_webauthn_challenge_data jsonb
);


ALTER TABLE auth.mfa_factors OWNER TO supabase_auth_admin;

--
-- Name: TABLE mfa_factors; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.mfa_factors IS 'auth: stores metadata about factors';


--
-- Name: COLUMN mfa_factors.last_webauthn_challenge_data; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON COLUMN auth.mfa_factors.last_webauthn_challenge_data IS 'Stores the latest WebAuthn challenge data including attestation/assertion for customer verification';


--
-- Name: oauth_authorizations; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.oauth_authorizations (
    id uuid NOT NULL,
    authorization_id text NOT NULL,
    client_id uuid NOT NULL,
    user_id uuid,
    redirect_uri text NOT NULL,
    scope text NOT NULL,
    state text,
    resource text,
    code_challenge text,
    code_challenge_method auth.code_challenge_method,
    response_type auth.oauth_response_type DEFAULT 'code'::auth.oauth_response_type NOT NULL,
    status auth.oauth_authorization_status DEFAULT 'pending'::auth.oauth_authorization_status NOT NULL,
    authorization_code text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    expires_at timestamp with time zone DEFAULT (now() + '00:03:00'::interval) NOT NULL,
    approved_at timestamp with time zone,
    CONSTRAINT oauth_authorizations_authorization_code_length CHECK ((char_length(authorization_code) <= 255)),
    CONSTRAINT oauth_authorizations_code_challenge_length CHECK ((char_length(code_challenge) <= 128)),
    CONSTRAINT oauth_authorizations_expires_at_future CHECK ((expires_at > created_at)),
    CONSTRAINT oauth_authorizations_redirect_uri_length CHECK ((char_length(redirect_uri) <= 2048)),
    CONSTRAINT oauth_authorizations_resource_length CHECK ((char_length(resource) <= 2048)),
    CONSTRAINT oauth_authorizations_scope_length CHECK ((char_length(scope) <= 4096)),
    CONSTRAINT oauth_authorizations_state_length CHECK ((char_length(state) <= 4096))
);


ALTER TABLE auth.oauth_authorizations OWNER TO supabase_auth_admin;

--
-- Name: oauth_clients; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.oauth_clients (
    id uuid NOT NULL,
    client_secret_hash text,
    registration_type auth.oauth_registration_type NOT NULL,
    redirect_uris text NOT NULL,
    grant_types text NOT NULL,
    client_name text,
    client_uri text,
    logo_uri text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    client_type auth.oauth_client_type DEFAULT 'confidential'::auth.oauth_client_type NOT NULL,
    CONSTRAINT oauth_clients_client_name_length CHECK ((char_length(client_name) <= 1024)),
    CONSTRAINT oauth_clients_client_uri_length CHECK ((char_length(client_uri) <= 2048)),
    CONSTRAINT oauth_clients_logo_uri_length CHECK ((char_length(logo_uri) <= 2048))
);


ALTER TABLE auth.oauth_clients OWNER TO supabase_auth_admin;

--
-- Name: oauth_consents; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.oauth_consents (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    client_id uuid NOT NULL,
    scopes text NOT NULL,
    granted_at timestamp with time zone DEFAULT now() NOT NULL,
    revoked_at timestamp with time zone,
    CONSTRAINT oauth_consents_revoked_after_granted CHECK (((revoked_at IS NULL) OR (revoked_at >= granted_at))),
    CONSTRAINT oauth_consents_scopes_length CHECK ((char_length(scopes) <= 2048)),
    CONSTRAINT oauth_consents_scopes_not_empty CHECK ((char_length(TRIM(BOTH FROM scopes)) > 0))
);


ALTER TABLE auth.oauth_consents OWNER TO supabase_auth_admin;

--
-- Name: one_time_tokens; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.one_time_tokens (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    token_type auth.one_time_token_type NOT NULL,
    token_hash text NOT NULL,
    relates_to text NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT one_time_tokens_token_hash_check CHECK ((char_length(token_hash) > 0))
);


ALTER TABLE auth.one_time_tokens OWNER TO supabase_auth_admin;

--
-- Name: refresh_tokens; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.refresh_tokens (
    instance_id uuid,
    id bigint NOT NULL,
    token character varying(255),
    user_id character varying(255),
    revoked boolean,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    parent character varying(255),
    session_id uuid
);


ALTER TABLE auth.refresh_tokens OWNER TO supabase_auth_admin;

--
-- Name: TABLE refresh_tokens; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.refresh_tokens IS 'Auth: Store of tokens used to refresh JWT tokens once they expire.';


--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE; Schema: auth; Owner: supabase_auth_admin
--

CREATE SEQUENCE auth.refresh_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE auth.refresh_tokens_id_seq OWNER TO supabase_auth_admin;

--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: auth; Owner: supabase_auth_admin
--

ALTER SEQUENCE auth.refresh_tokens_id_seq OWNED BY auth.refresh_tokens.id;


--
-- Name: saml_providers; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.saml_providers (
    id uuid NOT NULL,
    sso_provider_id uuid NOT NULL,
    entity_id text NOT NULL,
    metadata_xml text NOT NULL,
    metadata_url text,
    attribute_mapping jsonb,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    name_id_format text,
    CONSTRAINT "entity_id not empty" CHECK ((char_length(entity_id) > 0)),
    CONSTRAINT "metadata_url not empty" CHECK (((metadata_url = NULL::text) OR (char_length(metadata_url) > 0))),
    CONSTRAINT "metadata_xml not empty" CHECK ((char_length(metadata_xml) > 0))
);


ALTER TABLE auth.saml_providers OWNER TO supabase_auth_admin;

--
-- Name: TABLE saml_providers; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.saml_providers IS 'Auth: Manages SAML Identity Provider connections.';


--
-- Name: saml_relay_states; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.saml_relay_states (
    id uuid NOT NULL,
    sso_provider_id uuid NOT NULL,
    request_id text NOT NULL,
    for_email text,
    redirect_to text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    flow_state_id uuid,
    CONSTRAINT "request_id not empty" CHECK ((char_length(request_id) > 0))
);


ALTER TABLE auth.saml_relay_states OWNER TO supabase_auth_admin;

--
-- Name: TABLE saml_relay_states; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.saml_relay_states IS 'Auth: Contains SAML Relay State information for each Service Provider initiated login.';


--
-- Name: schema_migrations; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.schema_migrations (
    version character varying(255) NOT NULL
);


ALTER TABLE auth.schema_migrations OWNER TO supabase_auth_admin;

--
-- Name: TABLE schema_migrations; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.schema_migrations IS 'Auth: Manages updates to the auth system.';


--
-- Name: sessions; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.sessions (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    factor_id uuid,
    aal auth.aal_level,
    not_after timestamp with time zone,
    refreshed_at timestamp without time zone,
    user_agent text,
    ip inet,
    tag text,
    oauth_client_id uuid,
    refresh_token_hmac_key text,
    refresh_token_counter bigint
);


ALTER TABLE auth.sessions OWNER TO supabase_auth_admin;

--
-- Name: TABLE sessions; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.sessions IS 'Auth: Stores session data associated to a user.';


--
-- Name: COLUMN sessions.not_after; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON COLUMN auth.sessions.not_after IS 'Auth: Not after is a nullable column that contains a timestamp after which the session should be regarded as expired.';


--
-- Name: COLUMN sessions.refresh_token_hmac_key; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON COLUMN auth.sessions.refresh_token_hmac_key IS 'Holds a HMAC-SHA256 key used to sign refresh tokens for this session.';


--
-- Name: COLUMN sessions.refresh_token_counter; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON COLUMN auth.sessions.refresh_token_counter IS 'Holds the ID (counter) of the last issued refresh token.';


--
-- Name: sso_domains; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.sso_domains (
    id uuid NOT NULL,
    sso_provider_id uuid NOT NULL,
    domain text NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    CONSTRAINT "domain not empty" CHECK ((char_length(domain) > 0))
);


ALTER TABLE auth.sso_domains OWNER TO supabase_auth_admin;

--
-- Name: TABLE sso_domains; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.sso_domains IS 'Auth: Manages SSO email address domain mapping to an SSO Identity Provider.';


--
-- Name: sso_providers; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.sso_providers (
    id uuid NOT NULL,
    resource_id text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    disabled boolean,
    CONSTRAINT "resource_id not empty" CHECK (((resource_id = NULL::text) OR (char_length(resource_id) > 0)))
);


ALTER TABLE auth.sso_providers OWNER TO supabase_auth_admin;

--
-- Name: TABLE sso_providers; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.sso_providers IS 'Auth: Manages SSO identity provider information; see saml_providers for SAML.';


--
-- Name: COLUMN sso_providers.resource_id; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON COLUMN auth.sso_providers.resource_id IS 'Auth: Uniquely identifies a SSO provider according to a user-chosen resource ID (case insensitive), useful in infrastructure as code.';


--
-- Name: users; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.users (
    instance_id uuid,
    id uuid NOT NULL,
    aud character varying(255),
    role character varying(255),
    email character varying(255),
    encrypted_password character varying(255),
    email_confirmed_at timestamp with time zone,
    invited_at timestamp with time zone,
    confirmation_token character varying(255),
    confirmation_sent_at timestamp with time zone,
    recovery_token character varying(255),
    recovery_sent_at timestamp with time zone,
    email_change_token_new character varying(255),
    email_change character varying(255),
    email_change_sent_at timestamp with time zone,
    last_sign_in_at timestamp with time zone,
    raw_app_meta_data jsonb,
    raw_user_meta_data jsonb,
    is_super_admin boolean,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    phone text DEFAULT NULL::character varying,
    phone_confirmed_at timestamp with time zone,
    phone_change text DEFAULT ''::character varying,
    phone_change_token character varying(255) DEFAULT ''::character varying,
    phone_change_sent_at timestamp with time zone,
    confirmed_at timestamp with time zone GENERATED ALWAYS AS (LEAST(email_confirmed_at, phone_confirmed_at)) STORED,
    email_change_token_current character varying(255) DEFAULT ''::character varying,
    email_change_confirm_status smallint DEFAULT 0,
    banned_until timestamp with time zone,
    reauthentication_token character varying(255) DEFAULT ''::character varying,
    reauthentication_sent_at timestamp with time zone,
    is_sso_user boolean DEFAULT false NOT NULL,
    deleted_at timestamp with time zone,
    is_anonymous boolean DEFAULT false NOT NULL,
    CONSTRAINT users_email_change_confirm_status_check CHECK (((email_change_confirm_status >= 0) AND (email_change_confirm_status <= 2)))
);


ALTER TABLE auth.users OWNER TO supabase_auth_admin;

--
-- Name: TABLE users; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.users IS 'Auth: Stores user login data within a secure schema.';


--
-- Name: COLUMN users.is_sso_user; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON COLUMN auth.users.is_sso_user IS 'Auth: Set this column to true when the account comes from SSO. These accounts can have duplicate emails.';


--
-- Name: _prisma_migrations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public._prisma_migrations (
    id character varying(36) NOT NULL,
    checksum character varying(64) NOT NULL,
    finished_at timestamp with time zone,
    migration_name character varying(255) NOT NULL,
    logs text,
    rolled_back_at timestamp with time zone,
    started_at timestamp with time zone DEFAULT now() NOT NULL,
    applied_steps_count integer DEFAULT 0 NOT NULL
);


ALTER TABLE public._prisma_migrations OWNER TO postgres;

--
-- Name: action_types; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.action_types (
    id integer NOT NULL,
    name text NOT NULL,
    description text,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.action_types OWNER TO postgres;

--
-- Name: action_types_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.action_types_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.action_types_id_seq OWNER TO postgres;

--
-- Name: action_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.action_types_id_seq OWNED BY public.action_types.id;


--
-- Name: api_usage; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.api_usage (
    id integer NOT NULL,
    user_id integer NOT NULL,
    service text NOT NULL,
    operation text NOT NULL,
    model text,
    tokens_input integer NOT NULL,
    tokens_output integer NOT NULL,
    tokens_total integer NOT NULL,
    cost_brl double precision NOT NULL,
    method text NOT NULL,
    success boolean DEFAULT true NOT NULL,
    error_message text,
    document_id integer,
    project_id integer,
    date timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    organization_id integer NOT NULL
);


ALTER TABLE public.api_usage OWNER TO postgres;

--
-- Name: api_usage_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.api_usage_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.api_usage_id_seq OWNER TO postgres;

--
-- Name: api_usage_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.api_usage_id_seq OWNED BY public.api_usage.id;


--
-- Name: document_types; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.document_types (
    id integer NOT NULL,
    code text NOT NULL,
    name text NOT NULL,
    description text,
    is_required boolean DEFAULT false NOT NULL,
    "order" integer NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.document_types OWNER TO postgres;

--
-- Name: document_types_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.document_types_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.document_types_id_seq OWNER TO postgres;

--
-- Name: document_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.document_types_id_seq OWNED BY public.document_types.id;


--
-- Name: document_validations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.document_validations (
    id integer NOT NULL,
    project_id integer NOT NULL,
    document_id integer NOT NULL,
    is_relevant boolean NOT NULL,
    relevance_score double precision NOT NULL,
    ai_analysis text NOT NULL,
    suggestions text,
    status text DEFAULT 'pending'::text NOT NULL,
    reviewed_at timestamp(3) without time zone,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL,
    "organizationId" integer NOT NULL
);


ALTER TABLE public.document_validations OWNER TO postgres;

--
-- Name: document_validations_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.document_validations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.document_validations_id_seq OWNER TO postgres;

--
-- Name: document_validations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.document_validations_id_seq OWNED BY public.document_validations.id;


--
-- Name: documents; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.documents (
    id integer NOT NULL,
    project_id integer NOT NULL,
    user_id integer NOT NULL,
    original_filename text NOT NULL,
    stored_filename text NOT NULL,
    document_type text NOT NULL,
    document_number integer NOT NULL,
    mime_type text NOT NULL,
    original_size_bytes integer NOT NULL,
    status text DEFAULT 'uploaded'::text NOT NULL,
    pdf_path text,
    ocr_text text,
    pdf_size_bytes integer,
    page_count integer,
    page_size text,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL,
    ai_analysis text,
    analysis_confidence double precision,
    detected_document_type text,
    grouped_at timestamp(3) without time zone,
    is_grouped boolean DEFAULT false NOT NULL,
    is_personal_document boolean DEFAULT false NOT NULL,
    smart_filename text,
    "organizationId" integer NOT NULL
);


ALTER TABLE public.documents OWNER TO postgres;

--
-- Name: documents_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.documents_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.documents_id_seq OWNER TO postgres;

--
-- Name: documents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.documents_id_seq OWNED BY public.documents.id;


--
-- Name: organizations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.organizations (
    id integer NOT NULL,
    name text NOT NULL,
    plan_type public."PlanType" DEFAULT 'trialing'::public."PlanType" NOT NULL,
    subscription_status public."SubscriptionStatus" DEFAULT 'trialing'::public."SubscriptionStatus" NOT NULL,
    document_processed_count integer DEFAULT 0 NOT NULL,
    ai_token_count integer DEFAULT 0 NOT NULL,
    stripe_customer_id text,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL,
    mercadopago_subscription_id text,
    address text,
    city text,
    cnpj text,
    contact_name text,
    contact_phone text,
    state text,
    zip_code text,
    subscription_due_date timestamp(3) without time zone,
    logo_url text
);


ALTER TABLE public.organizations OWNER TO postgres;

--
-- Name: organizations_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.organizations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.organizations_id_seq OWNER TO postgres;

--
-- Name: organizations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.organizations_id_seq OWNED BY public.organizations.id;


--
-- Name: projects; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.projects (
    id integer NOT NULL,
    user_id integer NOT NULL,
    name text NOT NULL,
    client text NOT NULL,
    system text NOT NULL,
    action_type text NOT NULL,
    narrative text,
    processed_narrative text,
    status text DEFAULT 'draft'::text NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL,
    "organizationId" integer NOT NULL
);


ALTER TABLE public.projects OWNER TO postgres;

--
-- Name: projects_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.projects_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.projects_id_seq OWNER TO postgres;

--
-- Name: projects_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.projects_id_seq OWNED BY public.projects.id;


--
-- Name: system_configurations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.system_configurations (
    id integer NOT NULL,
    system_name text NOT NULL,
    max_file_size integer NOT NULL,
    max_page_size integer NOT NULL,
    allowed_formats text NOT NULL,
    pdf_requirements text NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.system_configurations OWNER TO postgres;

--
-- Name: system_configurations_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.system_configurations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.system_configurations_id_seq OWNER TO postgres;

--
-- Name: system_configurations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.system_configurations_id_seq OWNED BY public.system_configurations.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id integer NOT NULL,
    email text NOT NULL,
    password text NOT NULL,
    name text NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL,
    auth_user_id uuid,
    "organizationId" integer NOT NULL,
    role public."UserRole" DEFAULT 'member'::public."UserRole" NOT NULL
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_id_seq OWNER TO postgres;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: messages; Type: TABLE; Schema: realtime; Owner: supabase_realtime_admin
--

CREATE TABLE realtime.messages (
    topic text NOT NULL,
    extension text NOT NULL,
    payload jsonb,
    event text,
    private boolean DEFAULT false,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    inserted_at timestamp without time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL
)
PARTITION BY RANGE (inserted_at);


ALTER TABLE realtime.messages OWNER TO supabase_realtime_admin;

--
-- Name: schema_migrations; Type: TABLE; Schema: realtime; Owner: supabase_admin
--

CREATE TABLE realtime.schema_migrations (
    version bigint NOT NULL,
    inserted_at timestamp(0) without time zone
);


ALTER TABLE realtime.schema_migrations OWNER TO supabase_admin;

--
-- Name: subscription; Type: TABLE; Schema: realtime; Owner: supabase_admin
--

CREATE TABLE realtime.subscription (
    id bigint NOT NULL,
    subscription_id uuid NOT NULL,
    entity regclass NOT NULL,
    filters realtime.user_defined_filter[] DEFAULT '{}'::realtime.user_defined_filter[] NOT NULL,
    claims jsonb NOT NULL,
    claims_role regrole GENERATED ALWAYS AS (realtime.to_regrole((claims ->> 'role'::text))) STORED NOT NULL,
    created_at timestamp without time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);


ALTER TABLE realtime.subscription OWNER TO supabase_admin;

--
-- Name: subscription_id_seq; Type: SEQUENCE; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE realtime.subscription ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME realtime.subscription_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: buckets; Type: TABLE; Schema: storage; Owner: supabase_storage_admin
--

CREATE TABLE storage.buckets (
    id text NOT NULL,
    name text NOT NULL,
    owner uuid,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    public boolean DEFAULT false,
    avif_autodetection boolean DEFAULT false,
    file_size_limit bigint,
    allowed_mime_types text[],
    owner_id text,
    type storage.buckettype DEFAULT 'STANDARD'::storage.buckettype NOT NULL
);


ALTER TABLE storage.buckets OWNER TO supabase_storage_admin;

--
-- Name: COLUMN buckets.owner; Type: COMMENT; Schema: storage; Owner: supabase_storage_admin
--

COMMENT ON COLUMN storage.buckets.owner IS 'Field is deprecated, use owner_id instead';


--
-- Name: buckets_analytics; Type: TABLE; Schema: storage; Owner: supabase_storage_admin
--

CREATE TABLE storage.buckets_analytics (
    id text NOT NULL,
    type storage.buckettype DEFAULT 'ANALYTICS'::storage.buckettype NOT NULL,
    format text DEFAULT 'ICEBERG'::text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE storage.buckets_analytics OWNER TO supabase_storage_admin;

--
-- Name: migrations; Type: TABLE; Schema: storage; Owner: supabase_storage_admin
--

CREATE TABLE storage.migrations (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    hash character varying(40) NOT NULL,
    executed_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE storage.migrations OWNER TO supabase_storage_admin;

--
-- Name: objects; Type: TABLE; Schema: storage; Owner: supabase_storage_admin
--

CREATE TABLE storage.objects (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    bucket_id text,
    name text,
    owner uuid,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    last_accessed_at timestamp with time zone DEFAULT now(),
    metadata jsonb,
    path_tokens text[] GENERATED ALWAYS AS (string_to_array(name, '/'::text)) STORED,
    version text,
    owner_id text,
    user_metadata jsonb,
    level integer
);


ALTER TABLE storage.objects OWNER TO supabase_storage_admin;

--
-- Name: COLUMN objects.owner; Type: COMMENT; Schema: storage; Owner: supabase_storage_admin
--

COMMENT ON COLUMN storage.objects.owner IS 'Field is deprecated, use owner_id instead';


--
-- Name: prefixes; Type: TABLE; Schema: storage; Owner: supabase_storage_admin
--

CREATE TABLE storage.prefixes (
    bucket_id text NOT NULL,
    name text NOT NULL COLLATE pg_catalog."C",
    level integer GENERATED ALWAYS AS (storage.get_level(name)) STORED NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


ALTER TABLE storage.prefixes OWNER TO supabase_storage_admin;

--
-- Name: s3_multipart_uploads; Type: TABLE; Schema: storage; Owner: supabase_storage_admin
--

CREATE TABLE storage.s3_multipart_uploads (
    id text NOT NULL,
    in_progress_size bigint DEFAULT 0 NOT NULL,
    upload_signature text NOT NULL,
    bucket_id text NOT NULL,
    key text NOT NULL COLLATE pg_catalog."C",
    version text NOT NULL,
    owner_id text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    user_metadata jsonb
);


ALTER TABLE storage.s3_multipart_uploads OWNER TO supabase_storage_admin;

--
-- Name: s3_multipart_uploads_parts; Type: TABLE; Schema: storage; Owner: supabase_storage_admin
--

CREATE TABLE storage.s3_multipart_uploads_parts (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    upload_id text NOT NULL,
    size bigint DEFAULT 0 NOT NULL,
    part_number integer NOT NULL,
    bucket_id text NOT NULL,
    key text NOT NULL COLLATE pg_catalog."C",
    etag text NOT NULL,
    owner_id text,
    version text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE storage.s3_multipart_uploads_parts OWNER TO supabase_storage_admin;

--
-- Name: schema_migrations; Type: TABLE; Schema: supabase_migrations; Owner: postgres
--

CREATE TABLE supabase_migrations.schema_migrations (
    version text NOT NULL,
    statements text[],
    name text
);


ALTER TABLE supabase_migrations.schema_migrations OWNER TO postgres;

--
-- Name: seed_files; Type: TABLE; Schema: supabase_migrations; Owner: postgres
--

CREATE TABLE supabase_migrations.seed_files (
    path text NOT NULL,
    hash text NOT NULL
);


ALTER TABLE supabase_migrations.seed_files OWNER TO postgres;

--
-- Name: refresh_tokens id; Type: DEFAULT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.refresh_tokens ALTER COLUMN id SET DEFAULT nextval('auth.refresh_tokens_id_seq'::regclass);


--
-- Name: action_types id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.action_types ALTER COLUMN id SET DEFAULT nextval('public.action_types_id_seq'::regclass);


--
-- Name: api_usage id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.api_usage ALTER COLUMN id SET DEFAULT nextval('public.api_usage_id_seq'::regclass);


--
-- Name: document_types id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.document_types ALTER COLUMN id SET DEFAULT nextval('public.document_types_id_seq'::regclass);


--
-- Name: document_validations id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.document_validations ALTER COLUMN id SET DEFAULT nextval('public.document_validations_id_seq'::regclass);


--
-- Name: documents id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.documents ALTER COLUMN id SET DEFAULT nextval('public.documents_id_seq'::regclass);


--
-- Name: organizations id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.organizations ALTER COLUMN id SET DEFAULT nextval('public.organizations_id_seq'::regclass);


--
-- Name: projects id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.projects ALTER COLUMN id SET DEFAULT nextval('public.projects_id_seq'::regclass);


--
-- Name: system_configurations id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.system_configurations ALTER COLUMN id SET DEFAULT nextval('public.system_configurations_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Data for Name: audit_log_entries; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.audit_log_entries (instance_id, id, payload, created_at, ip_address) FROM stdin;
\.


--
-- Data for Name: flow_state; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.flow_state (id, user_id, auth_code, code_challenge_method, code_challenge, provider_type, provider_access_token, provider_refresh_token, created_at, updated_at, authentication_method, auth_code_issued_at) FROM stdin;
\.


--
-- Data for Name: identities; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.identities (provider_id, user_id, identity_data, provider, last_sign_in_at, created_at, updated_at, id) FROM stdin;
\.


--
-- Data for Name: instances; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.instances (id, uuid, raw_base_config, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: mfa_amr_claims; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.mfa_amr_claims (session_id, created_at, updated_at, authentication_method, id) FROM stdin;
\.


--
-- Data for Name: mfa_challenges; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.mfa_challenges (id, factor_id, created_at, verified_at, ip_address, otp_code, web_authn_session_data) FROM stdin;
\.


--
-- Data for Name: mfa_factors; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.mfa_factors (id, user_id, friendly_name, factor_type, status, created_at, updated_at, secret, phone, last_challenged_at, web_authn_credential, web_authn_aaguid, last_webauthn_challenge_data) FROM stdin;
\.


--
-- Data for Name: oauth_authorizations; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.oauth_authorizations (id, authorization_id, client_id, user_id, redirect_uri, scope, state, resource, code_challenge, code_challenge_method, response_type, status, authorization_code, created_at, expires_at, approved_at) FROM stdin;
\.


--
-- Data for Name: oauth_clients; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.oauth_clients (id, client_secret_hash, registration_type, redirect_uris, grant_types, client_name, client_uri, logo_uri, created_at, updated_at, deleted_at, client_type) FROM stdin;
\.


--
-- Data for Name: oauth_consents; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.oauth_consents (id, user_id, client_id, scopes, granted_at, revoked_at) FROM stdin;
\.


--
-- Data for Name: one_time_tokens; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.one_time_tokens (id, user_id, token_type, token_hash, relates_to, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: refresh_tokens; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.refresh_tokens (instance_id, id, token, user_id, revoked, created_at, updated_at, parent, session_id) FROM stdin;
\.


--
-- Data for Name: saml_providers; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.saml_providers (id, sso_provider_id, entity_id, metadata_xml, metadata_url, attribute_mapping, created_at, updated_at, name_id_format) FROM stdin;
\.


--
-- Data for Name: saml_relay_states; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.saml_relay_states (id, sso_provider_id, request_id, for_email, redirect_to, created_at, updated_at, flow_state_id) FROM stdin;
\.


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.schema_migrations (version) FROM stdin;
20171026211738
20171026211808
20171026211834
20180103212743
20180108183307
20180119214651
20180125194653
00
20210710035447
20210722035447
20210730183235
20210909172000
20210927181326
20211122151130
20211124214934
20211202183645
20220114185221
20220114185340
20220224000811
20220323170000
20220429102000
20220531120530
20220614074223
20220811173540
20221003041349
20221003041400
20221011041400
20221020193600
20221021073300
20221021082433
20221027105023
20221114143122
20221114143410
20221125140132
20221208132122
20221215195500
20221215195800
20221215195900
20230116124310
20230116124412
20230131181311
20230322519590
20230402418590
20230411005111
20230508135423
20230523124323
20230818113222
20230914180801
20231027141322
20231114161723
20231117164230
20240115144230
20240214120130
20240306115329
20240314092811
20240427152123
20240612123726
20240729123726
20240802193726
20240806073726
20241009103726
20250717082212
20250731150234
20250804100000
20250901200500
20250903112500
20250904133000
20250925093508
20251007112900
\.


--
-- Data for Name: sessions; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.sessions (id, user_id, created_at, updated_at, factor_id, aal, not_after, refreshed_at, user_agent, ip, tag, oauth_client_id, refresh_token_hmac_key, refresh_token_counter) FROM stdin;
\.


--
-- Data for Name: sso_domains; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.sso_domains (id, sso_provider_id, domain, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: sso_providers; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.sso_providers (id, resource_id, created_at, updated_at, disabled) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, invited_at, confirmation_token, confirmation_sent_at, recovery_token, recovery_sent_at, email_change_token_new, email_change, email_change_sent_at, last_sign_in_at, raw_app_meta_data, raw_user_meta_data, is_super_admin, created_at, updated_at, phone, phone_confirmed_at, phone_change, phone_change_token, phone_change_sent_at, email_change_token_current, email_change_confirm_status, banned_until, reauthentication_token, reauthentication_sent_at, is_sso_user, deleted_at, is_anonymous) FROM stdin;
\.


--
-- Data for Name: _prisma_migrations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public._prisma_migrations (id, checksum, finished_at, migration_name, logs, rolled_back_at, started_at, applied_steps_count) FROM stdin;
494d183f-a5f9-4252-98b4-cbb75cd9f88f	b00fb9309b1c57cd7708d93243b2d8b2929d1f66d51a515af413543672c145d3	2025-10-28 13:48:45.29933+00	20250728235343_initial_setup	\N	\N	2025-10-28 13:48:44.858072+00	1
eaeb0831-362f-4cb5-8012-6ea4b0f8ed1b	dbf8c7acd4e4574969e0b2484295e991ae9d8fef8d8a3818f3264dd5117a51c8	2025-10-28 13:48:45.811507+00	20250817004520_add_personal_document_grouping_columns	\N	\N	2025-10-28 13:48:45.445132+00	1
1073db65-da92-43a5-8439-9ba6771fac5e	baa69fb4102d0f8e2db9729dcc96873c8c05a30df71d132937af3652c692988d	2025-10-28 13:48:46.308049+00	20251022024437_create_action_types	\N	\N	2025-10-28 13:48:45.947484+00	1
99f48c54-6a4f-485f-b32f-a744f646b95c	45de7c82e82242ffc8a38a5f06c24a5c0c433161ba0111a34c4a37c5f7016229	2025-10-28 13:48:46.804898+00	20251022190017_add_api_usage_tracking	\N	\N	2025-10-28 13:48:46.45015+00	1
\.


--
-- Data for Name: action_types; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.action_types (id, name, description, created_at, updated_at) FROM stdin;
1	Aâ”œÂºâ”œÃºo Administrativa	\N	2025-11-08 00:25:11.096	2025-11-08 00:25:11.096
\.


--
-- Data for Name: api_usage; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.api_usage (id, user_id, service, operation, model, tokens_input, tokens_output, tokens_total, cost_brl, method, success, error_message, document_id, project_id, date, created_at, organization_id) FROM stdin;
11	3	openai	categorization	gpt-4o-mini	772	9	781	0.000606	ai	t	\N	\N	2	2025-11-03 02:28:56.152	2025-11-03 02:28:56.152	3
12	3	openai	categorization	gpt-4o-mini	868	5	873	0.0006659999999999999	ai	t	\N	\N	2	2025-11-03 02:29:01.149	2025-11-03 02:29:01.149	3
13	3	openai	categorization	gpt-4o-mini	1072	5	1077	0.000819	ai	t	\N	\N	2	2025-11-03 02:29:06.753	2025-11-03 02:29:06.753	3
14	3	openai	categorization	gpt-4o-mini	765	8	773	0.00059775	ai	t	\N	\N	2	2025-11-03 02:29:10.621	2025-11-03 02:29:10.621	3
15	11	openai	categorization	gpt-4o-mini	765	8	773	0.00059775	ai	t	\N	\N	4	2025-11-03 15:57:12.127	2025-11-03 15:57:12.127	9
16	3	openai	categorization	gpt-4o-mini	827	4	831	0.00063225	ai	t	\N	\N	2	2025-11-03 20:11:49.727	2025-11-03 20:11:49.727	3
17	3	openai	categorization	gpt-4o-mini	13881	3	13884	0.01041975	ai	t	\N	\N	2	2025-11-03 20:41:02.699	2025-11-03 20:41:02.699	3
18	12	openai	categorization	gpt-4o-mini	883	4	887	0.0006742499999999999	ai	t	\N	\N	5	2025-11-03 22:18:03.784	2025-11-03 22:18:03.784	10
19	12	openai	categorization	gpt-4o-mini	1426	4	1430	0.0010815	ai	t	\N	\N	5	2025-11-03 22:18:17.087	2025-11-03 22:18:17.087	10
20	12	openai	categorization	gpt-4o-mini	1528	7	1535	0.001167	ai	t	\N	\N	5	2025-11-03 22:18:26.622	2025-11-03 22:18:26.622	10
21	12	openai	categorization	gpt-4o-mini	762	9	771	0.0005985	ai	t	\N	\N	5	2025-11-03 22:18:36.958	2025-11-03 22:18:36.958	10
22	12	openai	categorization	gpt-4o-mini	1257	9	1266	0.00096975	ai	t	\N	\N	5	2025-11-03 22:18:48.534	2025-11-03 22:18:48.534	10
23	12	openai	categorization	gpt-4o-mini	1477	3	1480	0.00111675	ai	t	\N	\N	5	2025-11-03 22:19:03	2025-11-03 22:19:03	10
24	12	openai	categorization	gpt-4o-mini	1134	3	1137	0.0008594999999999999	ai	t	\N	\N	5	2025-11-03 22:19:11.098	2025-11-03 22:19:11.098	10
25	12	openai	categorization	gpt-4o-mini	1087	9	1096	0.00084225	ai	t	\N	\N	5	2025-11-03 22:19:18.488	2025-11-03 22:19:18.488	10
26	12	openai	categorization	gpt-4o-mini	1058	3	1061	0.0008024999999999998	ai	t	\N	\N	5	2025-11-03 22:19:26.668	2025-11-03 22:19:26.668	10
27	12	openai	categorization	gpt-4o-mini	1286	3	1289	0.0009735	ai	t	\N	\N	5	2025-11-03 22:19:35.918	2025-11-03 22:19:35.918	10
28	12	openai	categorization	gpt-4o-mini	1135	3	1138	0.0008602499999999999	ai	t	\N	\N	5	2025-11-03 22:19:44.7	2025-11-03 22:19:44.7	10
29	12	openai	categorization	gpt-4o-mini	1051	3	1054	0.0007972499999999999	ai	t	\N	\N	5	2025-11-03 22:19:51.643	2025-11-03 22:19:51.643	10
30	12	openai	categorization	gpt-4o-mini	1086	3	1089	0.0008235	ai	t	\N	\N	5	2025-11-03 22:20:01.446	2025-11-03 22:20:01.446	10
31	12	openai	categorization	gpt-4o-mini	1083	3	1086	0.0008212499999999999	ai	t	\N	\N	5	2025-11-03 22:20:09.391	2025-11-03 22:20:09.391	10
32	12	openai	categorization	gpt-4o-mini	1273	3	1276	0.0009637499999999999	ai	t	\N	\N	5	2025-11-03 22:20:20.214	2025-11-03 22:20:20.214	10
33	12	openai	categorization	gpt-4o-mini	659	5	664	0.0005092499999999999	ai	t	\N	\N	5	2025-11-03 22:20:27.304	2025-11-03 22:20:27.304	10
34	12	openai	categorization	gpt-4o-mini	1011	3	1014	0.0007672499999999999	ai	t	\N	\N	5	2025-11-03 22:20:34.597	2025-11-03 22:20:34.597	10
35	12	openai	categorization	gpt-4o-mini	1002	6	1008	0.0007695	ai	t	\N	\N	5	2025-11-03 22:20:39.906	2025-11-03 22:20:39.906	10
36	12	openai	categorization	gpt-4o-mini	648	3	651	0.000495	ai	t	\N	\N	5	2025-11-03 22:20:44.056	2025-11-03 22:20:44.056	10
37	12	openai	categorization	gpt-4o-mini	926	3	929	0.0007034999999999999	ai	t	\N	\N	5	2025-11-03 22:20:50.872	2025-11-03 22:20:50.872	10
38	12	openai	categorization	gpt-4o-mini	639	5	644	0.00049425	ai	t	\N	\N	5	2025-11-03 22:20:58.352	2025-11-03 22:20:58.352	10
39	12	openai	categorization	gpt-4o-mini	856	7	863	0.000663	ai	t	\N	\N	5	2025-11-03 22:21:04.187	2025-11-03 22:21:04.187	10
40	12	openai	categorization	gpt-4o-mini	703	3	706	0.00053625	ai	t	\N	\N	5	2025-11-03 22:21:08.696	2025-11-03 22:21:08.696	10
41	12	openai	categorization	gpt-4o-mini	916	3	919	0.000696	ai	t	\N	\N	5	2025-11-03 22:21:14.049	2025-11-03 22:21:14.049	10
42	12	openai	categorization	gpt-4o-mini	1230	3	1233	0.0009314999999999998	ai	t	\N	\N	5	2025-11-03 22:21:20.682	2025-11-03 22:21:20.682	10
43	12	openai	categorization	gpt-4o-mini	1140	3	1143	0.0008639999999999999	ai	t	\N	\N	5	2025-11-03 22:21:28.534	2025-11-03 22:21:28.534	10
44	12	openai	categorization	gpt-4o-mini	849	3	852	0.00064575	ai	t	\N	\N	5	2025-11-03 22:21:34.912	2025-11-03 22:21:34.912	10
45	12	openai	categorization	gpt-4o-mini	1341	3	1344	0.00101475	ai	t	\N	\N	5	2025-11-03 22:21:42.659	2025-11-03 22:21:42.659	10
46	12	openai	categorization	gpt-4o-mini	747	3	750	0.00056925	ai	t	\N	\N	5	2025-11-03 22:21:48.638	2025-11-03 22:21:48.638	10
47	12	openai	categorization	gpt-4o-mini	1196	3	1199	0.0009059999999999999	ai	t	\N	\N	5	2025-11-03 22:21:54.612	2025-11-03 22:21:54.612	10
48	12	openai	categorization	gpt-4o-mini	1338	3	1341	0.0010125	ai	t	\N	\N	5	2025-11-03 22:22:02.032	2025-11-03 22:22:02.032	10
49	12	openai	categorization	gpt-4o-mini	1934	8	1942	0.0014745	ai	t	\N	\N	5	2025-11-03 22:22:10.694	2025-11-03 22:22:10.694	10
50	12	openai	categorization	gpt-4o-mini	1370	3	1373	0.0010365	ai	t	\N	\N	5	2025-11-03 22:22:18.146	2025-11-03 22:22:18.146	10
51	12	openai	categorization	gpt-4o-mini	1310	3	1313	0.0009914999999999998	ai	t	\N	\N	5	2025-11-03 22:22:24.276	2025-11-03 22:22:24.276	10
52	12	openai	categorization	gpt-4o-mini	1720	3	1723	0.001299	ai	t	\N	\N	5	2025-11-03 22:22:31.547	2025-11-03 22:22:31.547	10
53	12	openai	categorization	gpt-4o-mini	718	3	721	0.0005474999999999999	ai	t	\N	\N	5	2025-11-03 22:22:37.293	2025-11-03 22:22:37.293	10
54	12	openai	categorization	gpt-4o-mini	724	8	732	0.000567	ai	t	\N	\N	5	2025-11-03 22:22:43.521	2025-11-03 22:22:43.521	10
55	12	openai	categorization	gpt-4o-mini	2154	3	2157	0.0016245	ai	t	\N	\N	5	2025-11-03 22:22:51.399	2025-11-03 22:22:51.399	10
56	12	openai	categorization	gpt-4o-mini	980	6	986	0.000753	ai	t	\N	\N	5	2025-11-03 22:22:58.962	2025-11-03 22:22:58.962	10
57	12	openai	categorization	gpt-4o-mini	1078	3	1081	0.0008175	ai	t	\N	\N	5	2025-11-03 22:23:04.51	2025-11-03 22:23:04.51	10
58	3	openai	categorization	gpt-4o-mini	1093	8	1101	0.0008437500000000001	ai	t	\N	\N	2	2025-11-08 00:29:03.116	2025-11-08 00:29:03.116	3
59	3	openai	categorization	gpt-4o-mini	997	8	1005	0.0007717500000000001	ai	t	\N	\N	2	2025-11-08 00:29:09.716	2025-11-08 00:29:09.716	3
60	3	openai	categorization	gpt-4o-mini	1072	5	1077	0.000819	ai	t	\N	\N	2	2025-11-08 00:29:44.325	2025-11-08 00:29:44.325	3
61	3	openai	categorization	gpt-4o-mini	765	8	773	0.00059775	ai	t	\N	\N	2	2025-11-08 00:29:48.46	2025-11-08 00:29:48.46	3
62	3	openai	categorization	gpt-4o-mini	731	4	735	0.00056025	ai	t	\N	\N	2	2025-11-08 00:29:51.426	2025-11-08 00:29:51.426	3
63	3	openai	categorization	gpt-4o-mini	826	6	832	0.0006375	ai	t	\N	\N	2	2025-11-08 00:29:54.777	2025-11-08 00:29:54.777	3
\.


--
-- Data for Name: document_types; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.document_types (id, code, name, description, is_required, "order", created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: document_validations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.document_validations (id, project_id, document_id, is_relevant, relevance_score, ai_analysis, suggestions, status, reviewed_at, created_at, updated_at, "organizationId") FROM stdin;
13	4	21	f	0.9	O documento apresentado â”œÂ® uma ficha financeira individual de um funcionâ”œÃ­rio da Prefeitura Municipal de Atalaia, que nâ”œÃºo possui relaâ”œÂºâ”œÃºo direta com a situaâ”œÂºâ”œÃºo de despejo do Autor ou com a Aâ”œÂºâ”œÃºo de Cobranâ”œÂºa em questâ”œÃºo. Nâ”œÃºo hâ”œÃ­ evidâ”œÂ¬ncias de que este documento comprove ou relate os fatos do caso, como a inadimplâ”œÂ¬ncia do Autor ou a relaâ”œÂºâ”œÃºo contratual com o Râ”œÂ®u.	\N	needs_revision	\N	2025-11-03 15:57:47.672	2025-11-03 15:57:47.672	9
14	5	27	t	0.9	O documento de procuraâ”œÂºâ”œÃºo â”œÂ® assinado por JOSE ANTONIO DE LIMA, que â”œÂ® o nome do Autor mencionado na narrativa. O CPF 347.333.704-82 tambâ”œÂ®m deve ser verificado, mas a correspondâ”œÂ¬ncia do nome jâ”œÃ­ estabelece uma forte conexâ”œÃºo. Portanto, o documento â”œÂ® relevante para o processo.	\N	approved	2025-11-03 22:24:54.533	2025-11-03 22:24:07.103	2025-11-03 22:24:54.534	10
15	5	28	t	0.9	O documento de procuraâ”œÂºâ”œÃºo pertence a Maria Jose De Lima, que â”œÂ® o outorgante. Embora o nome do autor nâ”œÃºo tenha sido explicitamente mencionado na narrativa, a procuraâ”œÂºâ”œÃºo indica que Maria Jose De Lima â”œÂ® uma pessoa fâ”œÂ¡sica, aposentada, e nâ”œÃºo hâ”œÃ­ informaâ”œÂºâ”œÃes que contradigam sua possâ”œÂ¡vel relaâ”œÂºâ”œÃºo com o autor do processo. O CPF 331.518.494-15 pode ser verificado para confirmar a identidade, mas a conexâ”œÃºo com o caso â”œÂ® forte, pois ela estâ”œÃ­ diretamente envolvida como outorgante na procuraâ”œÂºâ”œÃºo.	\N	approved	2025-11-03 22:24:59.22	2025-11-03 22:24:11.188	2025-11-03 22:24:59.221	10
16	5	29	t	0.9	O nome no comprovante de residâ”œÂ¬ncia â”œÂ® 'JOSE ANTONIO DE LIMA', que nâ”œÃºo â”œÂ® mencionado diretamente na narrativa como Autor ou Râ”œÂ®u. No entanto, o Autor â”œÂ® a parte que busca reparaâ”œÂºâ”œÃºo e pode ser identificado como 'Josâ”œÂ®' se considerarmos que o nome pode ser uma variaâ”œÂºâ”œÃºo ou um nome completo. A anâ”œÃ­lise do CPF nâ”œÃºo pode ser feita completamente, mas a presenâ”œÂºa do nome sugere uma relaâ”œÂºâ”œÃºo com o Autor. Portanto, hâ”œÃ­ uma alta probabilidade de que este documento pertenâ”œÂºa ao Autor, justificando sua relevâ”œÃ³ncia.	\N	approved	2025-11-03 22:25:04.549	2025-11-03 22:24:16.099	2025-11-03 22:25:04.55	10
9	2	17	t	0.9	O nome no documento, 'Rosimeire Acioly Albuquerque', â”œÂ® o mesmo que o da autora mencionada na narrativa, que busca o reconhecimento da licenâ”œÂºa-prâ”œÂ¬mio. Alâ”œÂ®m disso, o CPF apresentado no documento (333.164.654-72) pode ser verificado para confirmar a identidade, e a declaraâ”œÂºâ”œÃºo de hipossuficiâ”œÂ¬ncia â”œÂ® relevante para o processo, pois a autora estâ”œÃ­ solicitando gratuidade de justiâ”œÂºa. Portanto, a declaraâ”œÂºâ”œÃºo pertence a uma das partes do processo.	\N	approved	2025-11-08 00:31:24.738	2025-11-03 02:29:54.068	2025-11-08 00:31:24.741	3
10	2	18	t	0.8	A ficha financeira individual da servidora pode fornecer informaâ”œÂºâ”œÃes sobre seu tempo de serviâ”œÂºo, remuneraâ”œÂºâ”œÃºo e eventuais descontos, que sâ”œÃºo relevantes para comprovar a ausâ”œÂ¬ncia de gozo da licenâ”œÂºa-prâ”œÂ¬mio e os impactos financeiros decorrentes dessa omissâ”œÃºo. Embora o documento nâ”œÃºo mencione diretamente a licenâ”œÂºa-prâ”œÂ¬mio, ele pode ser utilizado para demonstrar a situaâ”œÂºâ”œÃºo financeira da autora e a relaâ”œÂºâ”œÃºo com seu vâ”œÂ¡nculo empregatâ”œÂ¡cio, o que â”œÂ® pertinente ao caso.	\N	approved	2025-11-08 00:31:28.714	2025-11-03 02:29:57.506	2025-11-08 00:31:28.715	3
20	5	33	t	0.8	O documento parece ser um contrato relacionado ao financiamento do veâ”œÂ¡culo adquirido pelo Autor. Embora o conteâ”œâ•‘do esteja parcialmente ilegâ”œÂ¡vel e confuso, a menâ”œÂºâ”œÃºo a valores, multas e encargos sugere que ele pode ser relevante para comprovar a relaâ”œÂºâ”œÃºo financeira entre o Autor e o Râ”œÂ®u, alâ”œÂ®m de evidenciar a situaâ”œÂºâ”œÃºo do financiamento que foi cancelado. Isso pode ajudar a demonstrar os danos materiais que o Autor alega ter sofrido.	\N	approved	\N	2025-11-03 22:24:31.118	2025-11-03 22:24:31.118	10
17	5	30	t	0.9	O nome no documento, 'Jose Antonio de Lima', â”œÂ® semelhante ao 'Autor' mencionado na narrativa, que â”œÂ® a parte que busca reparaâ”œÂºâ”œÃºo pelos danos sofridos. Embora o nome nâ”œÃºo seja exatamente o mesmo, a similaridade e a funâ”œÂºâ”œÃºo de 'Autor' na narrativa indicam que ele pode ser a mesma pessoa. Alâ”œÂ®m disso, o CPF apresentado no documento (347.333.704-82) deve ser verificado para confirmar a identidade, mas a relaâ”œÂºâ”œÃºo com a narrativa â”œÂ® forte o suficiente para considerar o documento relevante.	\N	approved	2025-11-03 22:25:08.662	2025-11-03 22:24:20.04	2025-11-03 22:25:08.663	10
18	5	31	f	0.9	O documento pertence a Maria Jose De Lima, que nâ”œÃºo â”œÂ® mencionada na narrativa do caso. O Autor â”œÂ® uma parte do processo, mas seu nome nâ”œÃºo corresponde ao do declarante. Alâ”œÂ®m disso, o CPF apresentado no documento (331.518.494-15) nâ”œÃºo foi mencionado na narrativa, que se concentra em um Autor nâ”œÃºo identificado por esse nome. Portanto, o documento nâ”œÃºo â”œÂ® relevante para o processo.	\N	needs_revision	2025-11-03 22:25:12.87	2025-11-03 22:24:23.018	2025-11-03 22:25:12.871	10
19	5	32	f	0.7	O documento apresentado parece ser um modelo de contrato ou informaâ”œÂºâ”œÃes sobre procedimentos jurâ”œÂ¡dicos, mas nâ”œÃºo contâ”œÂ®m informaâ”œÂºâ”œÃes especâ”œÂ¡ficas ou comprobatâ”œâ”‚rias relacionadas â”œÃ¡ compra do veâ”œÂ¡culo HB20, â”œÃ¡ transferâ”œÂ¬ncia de documentaâ”œÂºâ”œÃºo ou â”œÃ¡ relaâ”œÂºâ”œÃºo entre o Autor e o Râ”œÂ®u. Portanto, nâ”œÃºo â”œÂ® diretamente relevante para os fatos narrados no caso.	\N	needs_revision	2025-11-03 22:25:16.319	2025-11-03 22:24:26.813	2025-11-03 22:25:16.32	10
29	2	67	f	0.2	O documento trata da concessâ”œÃºo de aposentadoria de uma servidora especâ”œÂ¡fica, enquanto a narrativa do caso se concentra no direito â”œÃ¡ licenâ”œÂºa-prâ”œÂ¬mio nâ”œÃºo utilizada pela autora. Nâ”œÃºo hâ”œÃ­ relaâ”œÂºâ”œÃºo direta entre a concessâ”œÃºo de aposentadoria e o pleito da licenâ”œÂºa-prâ”œÂ¬mio, o que diminui a relevâ”œÃ³ncia do documento para o caso em questâ”œÃºo.	\N	needs_revision	\N	2025-11-08 00:31:35.281	2025-11-08 00:31:35.281	3
30	2	68	t	0.8	O documento, uma ficha financeira individual da servidora, â”œÂ® relevante pois pode comprovar o vâ”œÂ¡nculo empregatâ”œÂ¡cio da autora com a Administraâ”œÂºâ”œÃºo Pâ”œâ•‘blica, alâ”œÂ®m de fornecer informaâ”œÂºâ”œÃes sobre sua remuneraâ”œÂºâ”œÃºo e tempo de serviâ”œÂºo, que sâ”œÃºo fundamentais para a anâ”œÃ­lise do direito â”œÃ¡ licenâ”œÂºa-prâ”œÂ¬mio. Embora nâ”œÃºo trate diretamente da concessâ”œÃºo da licenâ”œÂºa-prâ”œÂ¬mio, a documentaâ”œÂºâ”œÃºo financeira pode ajudar a demonstrar a continuidade do serviâ”œÂºo e a ausâ”œÂ¬ncia de usufruto do benefâ”œÂ¡cio.	\N	approved	\N	2025-11-08 00:31:39.477	2025-11-08 00:31:39.477	3
31	2	69	t	0.8	O documento â”œÂ® uma ficha financeira que pode conter informaâ”œÂºâ”œÃes sobre os proventos e a situaâ”œÂºâ”œÃºo funcional da autora, servidora pâ”œâ•‘blica, durante o perâ”œÂ¡odo em que ela nâ”œÃºo usufruiu da licenâ”œÂºa-prâ”œÂ¬mio. Embora o conteâ”œâ•‘do esteja parcialmente ilegâ”œÂ¡vel, ele pode ajudar a comprovar a relaâ”œÂºâ”œÃºo de trabalho da autora com a Administraâ”œÂºâ”œÃºo Pâ”œâ•‘blica e a ausâ”œÂ¬ncia de benefâ”œÂ¡cios, como a licenâ”œÂºa-prâ”œÂ¬mio, que â”œÂ® o foco da aâ”œÂºâ”œÃºo. Portanto, â”œÂ® relevante para demonstrar a situaâ”œÂºâ”œÃºo financeira e funcional da autora.	\N	approved	\N	2025-11-08 00:31:43.517	2025-11-08 00:31:43.517	3
32	2	70	t	0.8	O documento, uma ficha financeira individual da servidora, pode conter informaâ”œÂºâ”œÃes relevantes sobre o tempo de serviâ”œÂºo, remuneraâ”œÂºâ”œÃºo e vâ”œÂ¡nculos empregatâ”œÂ¡cios, que sâ”œÃºo essenciais para comprovar a elegibilidade da autora para a licenâ”œÂºa-prâ”œÂ¬mio. Embora o conteâ”œâ•‘do esteja parcialmente ilegâ”œÂ¡vel e confuso, a relaâ”œÂºâ”œÃºo com a situaâ”œÂºâ”œÃºo da autora e a necessidade de comprovaâ”œÂºâ”œÃºo de seu direito â”œÃ¡ licenâ”œÂºa-prâ”œÂ¬mio justifica sua relevâ”œÃ³ncia.	\N	approved	\N	2025-11-08 00:31:49.978	2025-11-08 00:31:49.978	3
33	2	71	t	0.8	O contracheque da servidora pode fornecer informaâ”œÂºâ”œÃes sobre o vâ”œÂ¡nculo empregatâ”œÂ¡cio, tempo de serviâ”œÂºo e remuneraâ”œÂºâ”œÃºo, que sâ”œÃºo relevantes para comprovar a elegibilidade da autora para a licenâ”œÂºa-prâ”œÂ¬mio. Embora o documento nâ”œÃºo trate diretamente da licenâ”œÂºa-prâ”œÂ¬mio, ele pode servir como evidâ”œÂ¬ncia do tempo de serviâ”œÂºo e da condiâ”œÂºâ”œÃºo de servidora pâ”œâ•‘blica, aspectos fundamentais para o pleito da autora.	\N	approved	\N	2025-11-08 00:31:53.236	2025-11-08 00:31:53.236	3
34	2	72	f	0.8	O documento se refere a declaraâ”œÂºâ”œÃes de fâ”œÂ®rias regulamentares do servidor, enquanto a narrativa do caso trata especificamente do direito â”œÃ¡ licenâ”œÂºa-prâ”œÂ¬mio nâ”œÃºo utilizada. Embora ambos os temas estejam relacionados ao tempo de serviâ”œÂºo do servidor pâ”œâ•‘blico, o documento nâ”œÃºo aborda diretamente a questâ”œÃºo da licenâ”œÂºa-prâ”œÂ¬mio, que â”œÂ® o foco da aâ”œÂºâ”œÃºo. Portanto, sua relevâ”œÃ³ncia para o caso â”œÂ® limitada.	\N	needs_revision	\N	2025-11-08 00:31:57.851	2025-11-08 00:31:57.851	3
\.


--
-- Data for Name: documents; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.documents (id, project_id, user_id, original_filename, stored_filename, document_type, document_number, mime_type, original_size_bytes, status, pdf_path, ocr_text, pdf_size_bytes, page_count, page_size, created_at, updated_at, ai_analysis, analysis_confidence, detected_document_type, grouped_at, is_grouped, is_personal_document, smart_filename, "organizationId") FROM stdin;
44	5	12	WhatsApp Image 2025-10-21 at 15.55.56 (1).jpeg	07 boletim de ocorrâ”œÂ¬ncia.pdf	07 boletim de ocorrâ”œÂ¬ncia	18	image/jpeg	133938	ocr_completed	https://yrzlxuefbxbpfndcpfqz.supabase.co/storage/v1/object/public/documents/processed/07_boletim_de_ocorrencia_b7aa5292.pdf	GOVERNO DO ESTADO DE ALAGOAS POLICIA CIVIL CENTRAL DE FLAGRANTES - MACEIO - AL BOLETIM DE OCORRENCIA Nâ”¬â–‘: 00417124/2025 DADOS DO REGISTRO Data/Hora Inicio do Registro: 15/08/2025 10:39:02 Data/Hora Fim: 15/08/2025 10:59:38 Delegado(a): Eliel Tavares Paranhos DADOS DA OCORRENCIA Unidade de Apuragao: 4â”¬â–‘ Distrito Policlal - Gruta Data/Hora do Fato Inicio: 23/05/2025 10:00 (Hora Aproximada) Data/Hora do Fato Fim Local do Fato Municipio: Maceiâ”œÂ® (AL) Baio: Gruta de Lourdes Tipo do Local: Estabelecimento comercial Descrigao do Local: Super Car Natureza Meio(s) Empregado(s) 4103: OUTROS FATOS ATIPICOS Nao Houve ENVOLVIDO(S) [Nome Civil: MARIA JOSE DE LIMA (VITIMA,, COMUNICANTE ) Nacionalidade: Brasileira Sexo Feminino Nasc:08/08/1960 dade 65 Profisso: Aposentado Estado Civil: Unido Estavel Naturalidade: Flexeiras ~ AL Filiagdo 1: Olivia Maria de Lima Pocumento(s) CPF: 931.518.494-15 Endereco Municipio: Macelâ”œÂ® - AL Logradouro: LOTEAMENTO TERRA DE ANTARES | Ne 53 Complemento: QUADRA 35 CEP: 7.048-160 OBJETO(S) ENVOLVIDO(S) Nenhum Objeto Informado RELATO/HISTORICO Compareceu a esta Central de Flagrantes a comunicante acima qualificada a fim de informar que no dla, hora e local supracitados comprou um carro, Hyundai HB20, de placa SJC2193, na lola Super Car, situada na AV. Rotary, no baiiro da Gruta de Lourdes, dando na ocasiao RS 30,000,00, de entrada â”¬Â® 60 parcelas de RS1,305,00, contudo atâ”œÂ® o presente Ã”Ã‡Ã¿momento ndo recebeu â”¬Â® documento do referido veiculo. Nada mais disse, raz8o pela qual encerrel o presente boletim de ocorrâ”œÂ®ncia 2 Impresso por: Denisson Batista Cardoso de Almeida - IP de Registro: 186,249.60.34 Pagina t de 2 BSinwsp Pradeimprescte 19080025 105057 Po Precedtnan Polo Batic ~~	138195	1	\N	2025-11-03 22:20:40.962	2025-11-03 22:20:40.962	{"documentType":"07 boletim de ocorrâ”œÂ¬ncia","confidence":0.9,"detectedInfo":{"ocrExtractedText":"GOVERNO DO ESTADO DE ALAGOAS POLICIA CIVIL CENTRAL DE FLAGRANTES - MACEIO - AL BOLETIM DE OCORRENCIA Nâ”¬â–‘: 00417124/2025 DADOS DO REGISTRO Data/Hora Inicio do Registro: 15/08/2025 10:39:02 Data/Hora Fim: 15/08/2025 10:59:38 Delegado(a): Eliel Tavares Paranhos DADOS DA OCORRENCIA Unidade de Apuragao: 4â”¬â–‘ Distrito Policlal - Gruta Data/Hora do Fato Inicio: 23/05/2025 10:00 (Hora Aproximada) Data/Hora do Fato Fim Local do Fato Municipio: Maceiâ”œÂ® (AL) Baio: Gruta de Lourdes Tipo do Local: Estabelecimento comercial Descrigao do Local: Super Car Natureza Meio(s) Empregado(s) 4103: OUTROS FATOS ATIPICOS Nao Houve ENVOLVIDO(S) [Nome Civil: MARIA JOSE DE LIMA (VITIMA,, COMUNICANTE ) Nacionalidade: Brasileira Sexo Feminino Nasc:08/08/1960 dade 65 Profisso: Aposentado Estado Civil: Unido Estavel Naturalidade: Flexeiras ~ AL Filiagdo 1: Olivia Maria de Lima Pocumento(s) CPF: 931.518.494-15 Endereco Municipio: Macelâ”œÂ® - AL Logradouro: LOTEAMENTO TERRA DE ANTARES | Ne 53 Complemento: QUADRA 35 CEP: 7.048-160 OBJETO(S) ENVOLVIDO(S) Nenhum Objeto Informado RELATO/HISTORICO Compareceu a esta Central de Flagrantes a comunicante acima qualificada a fim de informar que no dla, hora e local supracitados comprou um carro, Hyundai HB20, de placa SJC2193, na lola Super Car, situada na AV. Rotary, no baiiro da Gruta de Lourdes, dando na ocasiao RS 30,000,00, de entrada â”¬Â® 60 parcelas de RS1,305,00, contudo atâ”œÂ® o presente Ã”Ã‡Ã¿momento ndo recebeu â”¬Â® documento do referido veiculo. Nada mais disse, raz8o pela qual encerrel o presente boletim de ocorrâ”œÂ®ncia 2 Impresso por: Denisson Batista Cardoso de Almeida - IP de Registro: 186,249.60.34 Pagina t de 2 BSinwsp Pradeimprescte 19080025 105057 Po Precedtnan Polo Batic ~~","cpf":"931.518.494-15"},"suggestedFilename":"boletim de ocorrâ”œÂ¬ncia","ocrUsed":true,"chatGPTAnalysis":"9. Boletim de Ocorrâ”œÂ¬ncia"}	0.9	07 boletim de ocorrâ”œÂ¬ncia	\N	f	f	07 boletim de ocorrâ”œÂ¬ncia.pdf	10
45	5	12	WhatsApp Image 2025-10-21 at 15.55.56 (2).jpeg	Contratos_WhatsApp_Image_2025_10_21_at_15_55_56__2_.pdf	06 Contratos	19	image/jpeg	72594	ocr_completed	https://yrzlxuefbxbpfndcpfqz.supabase.co/storage/v1/object/public/documents/processed/06_Contratos_bcae3a04.pdf	(__) O cliente prefere efetuar por conta prâ”œÂ®pria e fica ciente das previsâ”œÂ®es legais dos Arts. 123, |, â”¬Âº 42 Ã”Ã©Â¼ 233 da Lei nâ”¬Â«. 9.503/97 ~ Câ”œÂ®digo de Transito Brasileiro ~ CTB. Maceid/AL, 24 de MAIO de 2025 MARCIO GERLANDIO GOMES XAVIER. CPF: 063.105.434-07 MARIA JOSE DE LIMA CPF: 331.518.494-15	72234	1	\N	2025-11-03 22:20:45.187	2025-11-03 22:20:45.187	{"documentType":"06 Contratos","confidence":0.9,"detectedInfo":{"ocrExtractedText":"(__) O cliente prefere efetuar por conta prâ”œÂ®pria e fica ciente das previsâ”œÂ®es legais dos Arts. 123, |, â”¬Âº 42 Ã”Ã©Â¼ 233 da Lei nâ”¬Â«. 9.503/97 ~ Câ”œÂ®digo de Transito Brasileiro ~ CTB. Maceid/AL, 24 de MAIO de 2025 MARCIO GERLANDIO GOMES XAVIER. CPF: 063.105.434-07 MARIA JOSE DE LIMA CPF: 331.518.494-15","cpf":"063.105.434-07"},"suggestedFilename":"Contratos","ocrUsed":true,"chatGPTAnalysis":"8. Contratos"}	0.9	06 Contratos	\N	f	f	Contratos_WhatsApp_Image_2025_10_21_at_15_55_56__2_.pdf	10
51	5	12	WhatsApp Image 2025-10-21 at 15.55.58 (1).jpeg	Contratos_WhatsApp_Image_2025_10_21_at_15_55_58__1_.pdf	06 Contratos	25	image/jpeg	231175	ocr_completed	https://yrzlxuefbxbpfndcpfqz.supabase.co/storage/v1/object/public/documents/processed/06_Contratos_347344c9.pdf	| ISAO UE, estas sao as principais condigâ”œÂ®es do seu financiamento. Leia com fa e guarde esta via com vocâ”œÂ®. By [gredor ow BV: Banco Votorantim S/A CNPJ: 69.586.111/0001-03 | CEDULA DE CREDITO BANCARIO- 1 | lav. das Naghes Unidas, 14.171 - Torre A 18â”¬â–‘ andar - S40 PaulolSP |Ã”Ã‡Ã¶-FINANCIAMENTO DE VEICULO | | |N? da Proposta: 200438908 |VERSAO: 1 "ATENGAO: A efetiva contratacao da operacao de crâ”œÂ®dito, nestas condigdes, depende da autorizacao da instituigao fi inanceira, C__TARIFAS (conforme normas do Banco Central do Brasil) en Sage Financiadal_|Sim [x] Nao| 0,00%, Isengao[x]Sim L] Nao| _ 0,00 0,00% [Tatta de Avaliagao, Reavaliagao e Substituigâ”œÂ®o do(s) bem(ns) | Financiada [xlSim LJ Nao â”œÂ® 0,95% |recebido(s) em garantia: |__ tsengâ”œÂ®d]Sim De Nao! 00 0,00% IMPOSTOS INCIDENTES SOBRE A OPERAGAO 7 5 al Total de imposto a serem financiados: f â”œÂ® | 1,509,335 3,22% |1OF i ai 1.336,84 2.85% HOF - aliquota adici = 0,38% (â”œÂ®nica)| ) Sim [1 Nao} 172,49 0,37% io ~__ |VALOR COM SEGURO (RS): i | Valor da Parcela: 1.305,00 Somatâ”œÂ®rio das Parcelas:_ 78.300,00 Valor Total Financiado (com: tarifas e postos}: 46.900,85 Valor Total Financiado + Valor Total de Pagamentos Attorizadod) _ E5.1 Tarifa de Cadastro: R$ 0,00 E5.2 Tarifa de Avaliagao de Bem: R$ 444,00 E5.3 Impostos: R$ 1.509,33 E5.4. Seguros: R$ 2.479,13 Quantidade de Parcelas: 60 parcelas Pas Vencimento da Primeira Parcela: 23/06/2025 | E8 [Vencimento da ultima parcela: 23/05/2030 ENCARGOS MORATORIO: | ro |gâ”¬â•— | Juros de atraso: 6,00% a.m pro-rata pelo periado de Multa por atraso: 2,00% sobre o valor da parcela | ee pro-rata pelo periodo d (CUSTO EFETIVO TOTAL DA OPERAGAO _ 5 2 Taxa de Juros Mensal (% a.m): 1,84% G2 Taxa de Juros Anual (% a.a): 24,42% Custo Efetivo Total Mensal (% a.m): 2,29% __| G4 | Custo efetivo Total Anual (% a.a): 31,74% (GERAL | TAnexos: [] |- Relagao de Bens Financiados (se mais de um) __ [Jl Relacdo de Garantias Adicionais (se aplicavel) |Assinatura do Emitente: MARTA JOSE DE LIMA |Em caso de portabilidade, Operacao de Crâ”œÂ®dito nâ”¬â–‘ (05 percents aqui presents fram caulados com base no Valor Total Financiado (83) \\â”¬Ã³4 | Confeogao de cadastro para inicio de relacionamento: le ? Caso na data do desembolso a aliquota do OF tenha sido alterada, 0 BV fard os ajustes necessdrios para adequagao do calcul em | conformidade com a legisiago em vigor. Se a aliquota for inferior & aplicada nessa CCB, o BV sera responsavel por me geembolsar a |Giferenga e, se a aliquota for superior, deverel reembolsar a diferenga ao BV, na forma disponibilzada pelo BV. Hach sha256 da CCR: fad297479h671 die 2dad Tice TAPh6TT 1 24f57a226A70Fa1 {OchthS51559n7bR	239658	1	\N	2025-11-03 22:21:21.972	2025-11-03 22:21:21.972	{"documentType":"06 Contratos","confidence":0.9,"detectedInfo":{"ocrExtractedText":"| ISAO UE, estas sao as principais condigâ”œÂ®es do seu financiamento. Leia com fa e guarde esta via com vocâ”œÂ®. By [gredor ow BV: Banco Votorantim S/A CNPJ: 69.586.111/0001-03 | CEDULA DE CREDITO BANCARIO- 1 | lav. das Naghes Unidas, 14.171 - Torre A 18â”¬â–‘ andar - S40 PaulolSP |Ã”Ã‡Ã¶-FINANCIAMENTO DE VEICULO | | |N? da Proposta: 200438908 |VERSAO: 1 \\"ATENGAO: A efetiva contratacao da operacao de crâ”œÂ®dito, nestas condigdes, depende da autorizacao da instituigao fi inanceira, C__TARIFAS (conforme normas do Banco Central do Brasil) en Sage Financiadal_|Sim [x] Nao| 0,00%, Isengao[x]Sim L] Nao| _ 0,00 0,00% [Tatta de Avaliagao, Reavaliagao e Substituigâ”œÂ®o do(s) bem(ns) | Financiada [xlSim LJ Nao â”œÂ® 0,95% |recebido(s) em garantia: |__ tsengâ”œÂ®d]Sim De Nao! 00 0,00% IMPOSTOS INCIDENTES SOBRE A OPERAGAO 7 5 al Total de imposto a serem financiados: f â”œÂ® | 1,509,335 3,22% |1OF i ai 1.336,84 2.85% HOF - aliquota adici = 0,38% (â”œÂ®nica)| ) Sim [1 Nao} 172,49 0,37% io ~__ |VALOR COM SEGURO (RS): i | Valor da Parcela: 1.305,00 Somatâ”œÂ®rio das Parcelas:_ 78.300,00 Valor Total Financiado (com: tarifas e postos}: 46.900,85 Valor Total Financiado + Valor Total de Pagamentos Attorizadod) _ E5.1 Tarifa de Cadastro: R$ 0,00 E5.2 Tarifa de Avaliagao de Bem: R$ 444,00 E5.3 Impostos: R$ 1.509,33 E5.4. Seguros: R$ 2.479,13 Quantidade de Parcelas: 60 parcelas Pas Vencimento da Primeira Parcela: 23/06/2025 | E8 [Vencimento da ultima parcela: 23/05/2030 ENCARGOS MORATORIO: | ro |gâ”¬â•— | Juros de atraso: 6,00% a.m pro-rata pelo periado de Multa por atraso: 2,00% sobre o valor da parcela | ee pro-rata pelo periodo d (CUSTO EFETIVO TOTAL DA OPERAGAO _ 5 2 Taxa de Juros Mensal (% a.m): 1,84% G2 Taxa de Juros Anual (% a.a): 24,42% Custo Efetivo Total Mensal (% a.m): 2,29% __| G4 | Custo efetivo Total Anual (% a.a): 31,74% (GERAL | TAnexos: [] |- Relagao de Bens Financiados (se mais de um) __ [Jl Relacdo de Garantias Adicionais (se aplicavel) |Assinatura do Emitente: MARTA JOSE DE LIMA |Em caso de portabilidade, Operacao de Crâ”œÂ®dito nâ”¬â–‘ (05 percents aqui presents fram caulados com base no Valor Total Financiado (83) \\\\â”¬Ã³4 | Confeogao de cadastro para inicio de relacionamento: le ? Caso na data do desembolso a aliquota do OF tenha sido alterada, 0 BV fard os ajustes necessdrios para adequagao do calcul em | conformidade com a legisiago em vigor. Se a aliquota for inferior & aplicada nessa CCB, o BV sera responsavel por me geembolsar a |Giferenga e, se a aliquota for superior, deverel reembolsar a diferenga ao BV, na forma disponibilzada pelo BV. Hach sha256 da CCR: fad297479h671 die 2dad Tice TAPh6TT 1 24f57a226A70Fa1 {OchthS51559n7bR"},"suggestedFilename":"Contratos","ocrUsed":true,"chatGPTAnalysis":"8. Contratos"}	0.9	06 Contratos	\N	f	f	Contratos_WhatsApp_Image_2025_10_21_at_15_55_58__1_.pdf	10
52	5	12	WhatsApp Image 2025-10-21 at 15.55.58 (2).jpeg	Contratos_WhatsApp_Image_2025_10_21_at_15_55_58__2_.pdf	06 Contratos	26	image/jpeg	380361	ocr_completed	https://yrzlxuefbxbpfndcpfqz.supabase.co/storage/v1/object/public/documents/processed/06_Contratos_9133915c.pdf	|IMPORTANTE: estas so as principais condigâ”œÂ®es do seu financiamento. Leia com atengao e guarde esta via com voce. _ : ii yu! EI im | By redor ou BV: Banco Votorantim S/A CNP: 59.588.114/0001-03 | â”¬Â® Pe epee | Ni as Unidas, 14.171 - Tc A18â”¬â–‘ . ve BB A | v. das Nagdes Unidas, orre A 18â”¬â–‘ andar - Sdo Paulo/SP. [Nâ”¬Â« da Proposta: 200438008 |VERSAO: { ATENGAO: Aefetiva contratacao da operagao de crâ”œÂ®dito, nestas condigoes, depende da autorizagao da instituico financeira. A__DADOS DO CONSUMIDOR / EMITENTE DO VEICULO. a 2 z |Nome/Razao Social: MARIA JOSE DE LIMA i zi = ae |CPFICNPY: 331.518.494-15 [RG: 99001030433 a |Enderego: PV TIMBOZINHO, 7. CEP: 57690000 Bairro: CENTRO Cidade: ATALAIA ____|UF: ALÃ”Ã‡Ã– [Telefones: (82) 98713-7630 E-mail: ANDRESSASILVAS001@GMAIL.COM as: e Renda: R$ 15.000,00 |Patrimâ”œÂ®nio: RS 780.000,00 Dados da conta bancaria (Bco. / Age. / Cta.): Veiculo: HYUNDAI HB20 COMFORT PLUS 1.0 MT5 4P (AG) COMPLETO 2023 / 2024 SJC2I93 GASOLINA/ALCOOL JEL RD PRATA 01368028621_ ~ = = Concessionâ”œÂ®ria / /Lojista: SUPER CAR [CNPUJ: 28.409.939/0001-23 a VALOR AINGADO (PRINCIPAL + ACESSORIOS + OUTRAS DESPESAS INCLUIDAS A RS PEDIDO DO CONSUMIDOR) Tipo de Operagao: CDC - Financiamento de] Tipo de Contrato: [xINovo [JRefinanciamento [Portabilidade ito em conta de minha titularidade Valor da entrada: - ~___36.000,00 Valor total financiado: 46.900,85 100,00% Valor financiado do veiculo: 42,000.00 89,55% SUBTOTAL: VEICULO + ACESSORIOS + OUTROS SERVIGOSIPRODUTOS 2.47913 - CONTRATAI 4. Seguro Protegao Financeira Total / Seguro Prestamista; Cardif | 2 Ã”Ã‡Â£4 do Brasil Vida e Previdencia SA, 03.546,261/0001-08 Ginaneadey(lS\\n e)Necl 2. Seg AP Premiado ICATU / Seguro de Vida; Icatu Seguros S/A, eee | 42.283.77010001-39 i anciada; x) tin On Na 680,35 1.45% | Ã”Ã‡Ã¿Somat6rio Total dos Seguros 2.479,13 _5,29% Acessorios - financiados: DSimX)Nao| BB IPVA- financiado: | Osim kxINao Multas de transito - financiadas: | Sim|x| Nao B10 Ã”Ã‡Ã¿Licenciamento-financiado: | ||Sim Ã”Ã‡Ã¶_[xINao Registro Contrato - Cartâ”œÂ®rio financiado: ae Dsin Nao Despesas com Despachante - financiadas: z | Dsim___ INao 2 Ã”Ã‡Ã¿Empresa e C B13 Registro Contrato - Orgao de Transito - fi 5 ae fxlsim LINao: 468,39 1,00% Hash sha256 ca CCR: Rerl397429h6712Ade3dad7fecTAIH6TT 1 RAF57a2 ATMA TOCHIDSS ISSA IHR	235435	1	\N	2025-11-03 22:21:29.933	2025-11-03 22:21:29.933	{"documentType":"06 Contratos","confidence":0.9,"detectedInfo":{"ocrExtractedText":"|IMPORTANTE: estas so as principais condigâ”œÂ®es do seu financiamento. Leia com atengao e guarde esta via com voce. _ : ii yu! EI im | By redor ou BV: Banco Votorantim S/A CNP: 59.588.114/0001-03 | â”¬Â® Pe epee | Ni as Unidas, 14.171 - Tc A18â”¬â–‘ . ve BB A | v. das Nagdes Unidas, orre A 18â”¬â–‘ andar - Sdo Paulo/SP. [Nâ”¬Â« da Proposta: 200438008 |VERSAO: { ATENGAO: Aefetiva contratacao da operagao de crâ”œÂ®dito, nestas condigoes, depende da autorizagao da instituico financeira. A__DADOS DO CONSUMIDOR / EMITENTE DO VEICULO. a 2 z |Nome/Razao Social: MARIA JOSE DE LIMA i zi = ae |CPFICNPY: 331.518.494-15 [RG: 99001030433 a |Enderego: PV TIMBOZINHO, 7. CEP: 57690000 Bairro: CENTRO Cidade: ATALAIA ____|UF: ALÃ”Ã‡Ã– [Telefones: (82) 98713-7630 E-mail: ANDRESSASILVAS001@GMAIL.COM as: e Renda: R$ 15.000,00 |Patrimâ”œÂ®nio: RS 780.000,00 Dados da conta bancaria (Bco. / Age. / Cta.): Veiculo: HYUNDAI HB20 COMFORT PLUS 1.0 MT5 4P (AG) COMPLETO 2023 / 2024 SJC2I93 GASOLINA/ALCOOL JEL RD PRATA 01368028621_ ~ = = Concessionâ”œÂ®ria / /Lojista: SUPER CAR [CNPUJ: 28.409.939/0001-23 a VALOR AINGADO (PRINCIPAL + ACESSORIOS + OUTRAS DESPESAS INCLUIDAS A RS PEDIDO DO CONSUMIDOR) Tipo de Operagao: CDC - Financiamento de] Tipo de Contrato: [xINovo [JRefinanciamento [Portabilidade ito em conta de minha titularidade Valor da entrada: - ~___36.000,00 Valor total financiado: 46.900,85 100,00% Valor financiado do veiculo: 42,000.00 89,55% SUBTOTAL: VEICULO + ACESSORIOS + OUTROS SERVIGOSIPRODUTOS 2.47913 - CONTRATAI 4. Seguro Protegao Financeira Total / Seguro Prestamista; Cardif | 2 Ã”Ã‡Â£4 do Brasil Vida e Previdencia SA, 03.546,261/0001-08 Ginaneadey(lS\\\\n e)Necl 2. Seg AP Premiado ICATU / Seguro de Vida; Icatu Seguros S/A, eee | 42.283.77010001-39 i anciada; x) tin On Na 680,35 1.45% | Ã”Ã‡Ã¿Somat6rio Total dos Seguros 2.479,13 _5,29% Acessorios - financiados: DSimX)Nao| BB IPVA- financiado: | Osim kxINao Multas de transito - financiadas: | Sim|x| Nao B10 Ã”Ã‡Ã¿Licenciamento-financiado: | ||Sim Ã”Ã‡Ã¶_[xINao Registro Contrato - Cartâ”œÂ®rio financiado: ae Dsin Nao Despesas com Despachante - financiadas: z | Dsim___ INao 2 Ã”Ã‡Ã¿Empresa e C B13 Registro Contrato - Orgao de Transito - fi 5 ae fxlsim LINao: 468,39 1,00% Hash sha256 ca CCR: Rerl397429h6712Ade3dad7fecTAIH6TT 1 RAF57a2 ATMA TOCHIDSS ISSA IHR","rg":"99001030433"},"suggestedFilename":"Contratos","ocrUsed":true,"chatGPTAnalysis":"8. Contratos"}	0.9	06 Contratos	\N	f	f	Contratos_WhatsApp_Image_2025_10_21_at_15_55_58__2_.pdf	10
53	5	12	WhatsApp Image 2025-10-21 at 15.55.58 (3).jpeg	Contratos_WhatsApp_Image_2025_10_21_at_15_55_58__3_.pdf	06 Contratos	27	image/jpeg	176372	ocr_completed	https://yrzlxuefbxbpfndcpfqz.supabase.co/storage/v1/object/public/documents/processed/06_Contratos_c232783e.pdf	By ORGAMENTO DE OPERACAO DE CREDITO DIRETO AO EEE CONSUMIDOR (CDC) - VEICULOS |Credor ou BV: Banco Votorantim S/A CNP4J: 59.588.111/0001-03 [ ____ORCAMENTO Nâ”¬â–‘: 200438908 ATENCAO: A efetiva contratacao da operacao de crâ”œÂ®dito, nestas condigdes, depende da autorizagao da instituigao financeira responsavel pelo presente orgamento |_H_|CET% a.m.: 2,29% |_| | Prazo de validade do orgamento (Ã”Ã‡Ã˜): 03 DIAS LJ [Assinatura | do Consumidor. |) 0s parcentuais anresentados foram calcutados com base no VALOR TOTAL FINANCIADO (F6). â”¬Ãº2) 0 prazo de validade aqui apontado refere-se as condigSes financeiras do orcamento, apenas, â”¬Ã³ no & disponibilitade do veiculo, bem como de outros produtos pelo mesmo periodo, â”¬Â½ Central de Relacionamento BV: 3003 1616 (capitais e regibes metropoftanas) ou 0800 701 8600 (demais localidades) de 2a a 6a das 7h as 22h, "SAC - Sugestfies, cancelamentos, elogios, reclamagies ou informagdes: 0800 770 3335 ou 0600 701 8661 (deficiente auctvo e de fala) - 24hs por dia, 7 des por semana Hash sha256 da COR: Red 2974 7AbE71 Pde dad icc TAIDGTT 1 ASST a7 ie 70a 1 Och tb S51 SSO IR	101124	1	\N	2025-11-03 22:21:36.154	2025-11-03 22:21:36.154	{"documentType":"06 Contratos","confidence":0.9,"detectedInfo":{"ocrExtractedText":"By ORGAMENTO DE OPERACAO DE CREDITO DIRETO AO EEE CONSUMIDOR (CDC) - VEICULOS |Credor ou BV: Banco Votorantim S/A CNP4J: 59.588.111/0001-03 [ ____ORCAMENTO Nâ”¬â–‘: 200438908 ATENCAO: A efetiva contratacao da operacao de crâ”œÂ®dito, nestas condigdes, depende da autorizagao da instituigao financeira responsavel pelo presente orgamento |_H_|CET% a.m.: 2,29% |_| | Prazo de validade do orgamento (Ã”Ã‡Ã˜): 03 DIAS LJ [Assinatura | do Consumidor. |) 0s parcentuais anresentados foram calcutados com base no VALOR TOTAL FINANCIADO (F6). â”¬Ãº2) 0 prazo de validade aqui apontado refere-se as condigSes financeiras do orcamento, apenas, â”¬Ã³ no & disponibilitade do veiculo, bem como de outros produtos pelo mesmo periodo, â”¬Â½ Central de Relacionamento BV: 3003 1616 (capitais e regibes metropoftanas) ou 0800 701 8600 (demais localidades) de 2a a 6a das 7h as 22h, \\"SAC - Sugestfies, cancelamentos, elogios, reclamagies ou informagdes: 0800 770 3335 ou 0600 701 8661 (deficiente auctvo e de fala) - 24hs por dia, 7 des por semana Hash sha256 da COR: Red 2974 7AbE71 Pde dad icc TAIDGTT 1 ASST a7 ie 70a 1 Och tb S51 SSO IR"},"suggestedFilename":"Contratos","ocrUsed":true,"chatGPTAnalysis":"8. Contratos"}	0.9	06 Contratos	\N	f	f	Contratos_WhatsApp_Image_2025_10_21_at_15_55_58__3_.pdf	10
54	5	12	WhatsApp Image 2025-10-21 at 15.55.58 (4).jpeg	Contratos_WhatsApp_Image_2025_10_21_at_15_55_58__4_.pdf	06 Contratos	28	image/jpeg	480088	ocr_completed	https://yrzlxuefbxbpfndcpfqz.supabase.co/storage/v1/object/public/documents/processed/06_Contratos_7cb1243e.pdf	By ORGAMENTO DE OPERACAO DE CREDITO DIRETO AO = CONSUMIDOR (CDC) - VEICULOS \\Credor ou BV: Banco Votorantim S/A CNPJ: 59.588.111/0001-03 | ORGAMENTO Nâ”¬Â«: 200438908, ATENCAO: A efetiva contratagao da operagao de crâ”œÂ®dito, nestas condigdes, depende da autorizagao da instituigâ”œÂ®o financeira |responsdvel pelo presente orgamento. ies Ã”Ã‡Ã¶. [ DADOS DE RESPONSABILIDADE DO CORF DENTE (CONCESSIONARIA / REVENDA / LOJISTA) Ã”Ã‡Â£Ta A- INFORMAGOES GE! JADOS CONSUMIDOR E VEICULO $ aa Nome Consumidor: MARIAJOSEDELIMA a CPF: 331.518.494-15 Pl 2 /Combustivel: GASOLINA/ALCOOL __Ã”Ã‡Ã¶Ã”Ã‡Ã¶_Ã”Ã‡Ã¶_[ Ano / Modelo: 2023 / 20: |_A3 | Concessionaria / Revenda/ Lojista: SUPERCAR FSS |B - VALOR FINANCIADO (PRINCIPAL + ACESSORIOS + OUTRAS DESPESAS INCLUIDAS NA| = OPERAGAO A PEDIDO DO CONSUMIDOR) Valor do Veiculo a Vista: = _Ã”Ã‡Ã¶ 0.000. Acessorios - Financiados: ; - [1 Sim [x] Nao 9,00% IPVA - Financiado: [1 Sim [x] Nao 0,00% | B4 |Multas de Transito-Financiado: LSim xl Nao ,00 0,00%4 Licenciamento - Financiado: Sim [x] Nao 0,00% 4. Seguro Protecao Financeira Total / Seguro Prestamista; Cardif do Brasil cng, 404 Vide e Previdencia SA, 03.546.261/0001-08 - Financiado: HsmeNs : Sy B6 |2. Seg AP Premiado ICATU / Seguro de Vida; Icatu Seguros S/A, i 42.283.770/0001-39 - Financiado: BEuIah es sg Somatorio Total dos Seguros 2.47913 _5,29% 87 Despesas com Despachante - Financiado: Es 2 [Sim bX Nao 0,00 0,00% _* |Despachante: |CNPY: = B8 | Registro contrato - Cartâ”œÂ®rio - Financiado: Lsim bd Nao| 0,00 3% B9 | Registro contrato - Orgao de Transito - Financiadas: [x] Sim [] Nao 468,39 1,00% B10 SUBTOTAL: VEICULO + ACESSORIOS + OUTRAS DESPESAS INCLUIDAS NA 82,947.52 OPERACAO A PEDIDO DO CONSUMIDOR Ss =o C- PAGAMENTO INICIAL / ENTRADA ne RS %) C1 |Valorde entrada: _ = 38.000,00, | C2 [Valor Liquido Liberado (B1 + B2 + B3 + B4 + BS + B7 - C1) wiles 42.000,00, 89,55% DADOS DE RESPONSABILIDADE DA INSTITUIGAO FINANCEIRA | s D-TARIFAS 5 RS %l)_| Financiadal_] Sim [x] Nao 0,00, 0,00% Ã”Ã‡Ã¿Ene aig 7 | Isengadx] Sim L] Nao ~ if 0,00%, Tarifa de avaliacao do veiculo usado financiado (garantia da _Financiadalx] Sim [] Nao! } 0,95% operacao) - financiada: i IsengaoL] Sim [x] Nao 00, _0,00' Total de tarifas a serem financiadas: ws = 0,95% E - IOF - IMPOSTOS INCIDENTES SOBRE A OPERAGAO %') Valor total a ser financiado sem impostos (B10 - C1 + D3): 45.391,52, Aliquota: 9 \\OF - financiado: 0,0082% ad Xi sim 1) Nao} 1.336,84 2,85% IOF - aliquota adicional (Decreto 6.339/08) - financiado: Beene IX] Sim [] Nao 172,49 0,37% Total de impostos a serem financiados: 1.509,33 _ 3,22% F - DADOS DO FINANCIAMENTO Data do 1â”¬â–‘ Vencimento: 23/06/2025 _| Data Ultimo Vencimento: 23/05/2030 Nâ”¬â–‘ de parcelas mensais: 60 4 es 27 Taxa de Juros mensal e anual: Mensal% a.m.: 1,849 Anual% a.a.: 24,42% VALOR COM SEGURO (R$): Valor de cada parcela mensal: 1.305,00, Somatâ”œÂ®rio das parcelas(F2 x F4): 78.300,00 Valor total financiado (com impostos) (E1 + E4): a 46.900,85 VALOR TOTAL PAGO AO FINAL (F5 + C1) 116,300,00) Hash sha25f da CCR: fled392429b871 2AdeRdad Tee TAPh677 1 Adf57a?2BeTOfal 1chthS51559bIbR Tarifa de Cadastro	303219	1	\N	2025-11-03 22:21:44.125	2025-11-03 22:21:44.125	{"documentType":"06 Contratos","confidence":0.9,"detectedInfo":{"ocrExtractedText":"By ORGAMENTO DE OPERACAO DE CREDITO DIRETO AO = CONSUMIDOR (CDC) - VEICULOS \\\\Credor ou BV: Banco Votorantim S/A CNPJ: 59.588.111/0001-03 | ORGAMENTO Nâ”¬Â«: 200438908, ATENCAO: A efetiva contratagao da operagao de crâ”œÂ®dito, nestas condigdes, depende da autorizagao da instituigâ”œÂ®o financeira |responsdvel pelo presente orgamento. ies Ã”Ã‡Ã¶. [ DADOS DE RESPONSABILIDADE DO CORF DENTE (CONCESSIONARIA / REVENDA / LOJISTA) Ã”Ã‡Â£Ta A- INFORMAGOES GE! JADOS CONSUMIDOR E VEICULO $ aa Nome Consumidor: MARIAJOSEDELIMA a CPF: 331.518.494-15 Pl 2 /Combustivel: GASOLINA/ALCOOL __Ã”Ã‡Ã¶Ã”Ã‡Ã¶_Ã”Ã‡Ã¶_[ Ano / Modelo: 2023 / 20: |_A3 | Concessionaria / Revenda/ Lojista: SUPERCAR FSS |B - VALOR FINANCIADO (PRINCIPAL + ACESSORIOS + OUTRAS DESPESAS INCLUIDAS NA| = OPERAGAO A PEDIDO DO CONSUMIDOR) Valor do Veiculo a Vista: = _Ã”Ã‡Ã¶ 0.000. Acessorios - Financiados: ; - [1 Sim [x] Nao 9,00% IPVA - Financiado: [1 Sim [x] Nao 0,00% | B4 |Multas de Transito-Financiado: LSim xl Nao ,00 0,00%4 Licenciamento - Financiado: Sim [x] Nao 0,00% 4. Seguro Protecao Financeira Total / Seguro Prestamista; Cardif do Brasil cng, 404 Vide e Previdencia SA, 03.546.261/0001-08 - Financiado: HsmeNs : Sy B6 |2. Seg AP Premiado ICATU / Seguro de Vida; Icatu Seguros S/A, i 42.283.770/0001-39 - Financiado: BEuIah es sg Somatorio Total dos Seguros 2.47913 _5,29% 87 Despesas com Despachante - Financiado: Es 2 [Sim bX Nao 0,00 0,00% _* |Despachante: |CNPY: = B8 | Registro contrato - Cartâ”œÂ®rio - Financiado: Lsim bd Nao| 0,00 3% B9 | Registro contrato - Orgao de Transito - Financiadas: [x] Sim [] Nao 468,39 1,00% B10 SUBTOTAL: VEICULO + ACESSORIOS + OUTRAS DESPESAS INCLUIDAS NA 82,947.52 OPERACAO A PEDIDO DO CONSUMIDOR Ss =o C- PAGAMENTO INICIAL / ENTRADA ne RS %) C1 |Valorde entrada: _ = 38.000,00, | C2 [Valor Liquido Liberado (B1 + B2 + B3 + B4 + BS + B7 - C1) wiles 42.000,00, 89,55% DADOS DE RESPONSABILIDADE DA INSTITUIGAO FINANCEIRA | s D-TARIFAS 5 RS %l)_| Financiadal_] Sim [x] Nao 0,00, 0,00% Ã”Ã‡Ã¿Ene aig 7 | Isengadx] Sim L] Nao ~ if 0,00%, Tarifa de avaliacao do veiculo usado financiado (garantia da _Financiadalx] Sim [] Nao! } 0,95% operacao) - financiada: i IsengaoL] Sim [x] Nao 00, _0,00' Total de tarifas a serem financiadas: ws = 0,95% E - IOF - IMPOSTOS INCIDENTES SOBRE A OPERAGAO %') Valor total a ser financiado sem impostos (B10 - C1 + D3): 45.391,52, Aliquota: 9 \\\\OF - financiado: 0,0082% ad Xi sim 1) Nao} 1.336,84 2,85% IOF - aliquota adicional (Decreto 6.339/08) - financiado: Beene IX] Sim [] Nao 172,49 0,37% Total de impostos a serem financiados: 1.509,33 _ 3,22% F - DADOS DO FINANCIAMENTO Data do 1â”¬â–‘ Vencimento: 23/06/2025 _| Data Ultimo Vencimento: 23/05/2030 Nâ”¬â–‘ de parcelas mensais: 60 4 es 27 Taxa de Juros mensal e anual: Mensal% a.m.: 1,849 Anual% a.a.: 24,42% VALOR COM SEGURO (R$): Valor de cada parcela mensal: 1.305,00, Somatâ”œÂ®rio das parcelas(F2 x F4): 78.300,00 Valor total financiado (com impostos) (E1 + E4): a 46.900,85 VALOR TOTAL PAGO AO FINAL (F5 + C1) 116,300,00) Hash sha25f da CCR: fled392429b871 2AdeRdad Tee TAPh677 1 Adf57a?2BeTOfal 1chthS51559bIbR Tarifa de Cadastro","cpf":"331.518.494-15"},"suggestedFilename":"Contratos","ocrUsed":true,"chatGPTAnalysis":"8. Contratos"}	0.9	06 Contratos	\N	f	f	Contratos_WhatsApp_Image_2025_10_21_at_15_55_58__4_.pdf	10
55	5	12	WhatsApp Image 2025-10-21 at 15.55.58.jpeg	07 recibo.pdf	07 recibo	29	image/jpeg	125199	ocr_completed	https://yrzlxuefbxbpfndcpfqz.supabase.co/storage/v1/object/public/documents/processed/07_recibo_e02240c8.pdf	MUNIZ AUTO CENTER - MACEIO nid Meretonicn a muniz DADOS DAO.S Câ”œÂ®digo: 24 FINALIZADC Status Tipo Atondimento: PASSE ve Inicio: 09/06 ao Responsavel JNAFRENTE Ã”Ã‡Ã¶ Tâ”œÂ®rmineÃ”Ã‡Ã– 08/2025 19.064 DADOS DO CLIENTE Cliente: JOSE ANTONI POVOAD DE LIMA Bc CPFICNPS. 34 we? Cidade: A Endereco INHO Bairro: URICURT DADOS DO VEICULO Modelo: HB20 1.0 Placa: $3210 Ken: 4 PRODUTOS SUBTOTAL SERVICOS SUBTOTAL: DETALHES LEER ELAR vensimenta sans xons2nz ones Valor 4790.00, 00,00 Percale TOTAL DE SERVICOS: TOTAL DE PRODUTOS: TOTAL ABATIDO EM TROCA: TOTAL ABATIDO DE CREDITOS: VALOR RECEBIDO: TOTAL A PAGAR: RS 1.200,00 RS 1.700,00 Rs 0.00 Rs 0,00 RS0,90 R$ 2.900,00 Assinatura do Cliente Scanned with @camScanner \\	129102	1	\N	2025-11-03 22:21:49.82	2025-11-03 22:21:49.82	{"documentType":"07 recibo","confidence":0.9,"detectedInfo":{"ocrExtractedText":"MUNIZ AUTO CENTER - MACEIO nid Meretonicn a muniz DADOS DAO.S Câ”œÂ®digo: 24 FINALIZADC Status Tipo Atondimento: PASSE ve Inicio: 09/06 ao Responsavel JNAFRENTE Ã”Ã‡Ã¶ Tâ”œÂ®rmineÃ”Ã‡Ã– 08/2025 19.064 DADOS DO CLIENTE Cliente: JOSE ANTONI POVOAD DE LIMA Bc CPFICNPS. 34 we? Cidade: A Endereco INHO Bairro: URICURT DADOS DO VEICULO Modelo: HB20 1.0 Placa: $3210 Ken: 4 PRODUTOS SUBTOTAL SERVICOS SUBTOTAL: DETALHES LEER ELAR vensimenta sans xons2nz ones Valor 4790.00, 00,00 Percale TOTAL DE SERVICOS: TOTAL DE PRODUTOS: TOTAL ABATIDO EM TROCA: TOTAL ABATIDO DE CREDITOS: VALOR RECEBIDO: TOTAL A PAGAR: RS 1.200,00 RS 1.700,00 Rs 0.00 Rs 0,00 RS0,90 R$ 2.900,00 Assinatura do Cliente Scanned with @camScanner \\\\"},"suggestedFilename":"recibo","ocrUsed":true,"chatGPTAnalysis":"9. Recibo"}	0.9	07 recibo	\N	f	f	07 recibo.pdf	10
56	5	12	WhatsApp Image 2025-10-21 at 15.55.59 (1).jpeg	Contratos_WhatsApp_Image_2025_10_21_at_15_55_59__1_.pdf	06 Contratos	30	image/jpeg	209836	ocr_completed	https://yrzlxuefbxbpfndcpfqz.supabase.co/storage/v1/object/public/documents/processed/06_Contratos_99ebf52a.pdf	DULA DE CREDITO BANCARIO- | FINANCIAMENTO DE VEICULO NTE estas sao as principais condigdes do seu financiamento. Leia com stengie e guarde esta via com vocâ”œÂ®. Ã”Ã‡Ã˜ Credor ou BV: Banco Votorantim S/A CNPJ: 59.588.111/0001-03 ie | \\V. das Nagdes Unidas, 14.171 - Torre A 18â”¬â–‘ andar - Sao Paulo/SP INP essa CCB, independentemente de qualquer aviso ou comunicagâ”œÂ®o, podendo para tanto entregar ao cessionario toda a documentacao relativa ao crâ”œÂ®dito, sendo que apds a cessao os dâ”œÂ®bitos da operagao de crâ”œÂ®dito representada por essa CCB passarao a ser devidos e cobrados pelo cessionario. Na hipâ”œÂ®tese de emissao eletrâ”œÂ®nica da CCB, esta sera emitida em uma unica via (eletrâ”œÂ®nica), sendo negociavel apenas quando apresentada pelo BV. Na hipdtese de emissâ”œÂ®o de CCB assinada caligraficamente (fisica), serao emitidas tantas vias quantos forem seus subscritores, sendo negociavel apenas a via apresentada pelo BV. O documento "Condigâ”œÂ®es Gerais da Câ”œÂ®dula de Crâ”œÂ®dito Bancario" foi registrado sob nâ”¬â–‘1.625.129 em 19/10/2022 e averbado em 08/05/2024 sob nâ”¬â–‘ 1.655.506, no 5â”¬â–‘ Oficial de Registro oe ee e Documentos da Comarca de Sao Paulo. ee para todos os fins e efeitos, que recebi na data acima indi CCB Teller rai letas, a: tomei viamente ura. MACEIO, 24 de Maio de 2025. Assinatura do Emitente: MARIA JOSE DE LIMA Seo Emitente for analfabeto ou possuir deficiâ”œÂ®ncia, de forma que limite ou impossibilite a leitura e/ou compreensao dessa CCB, (i) as testemunhas abaixo identificadas declaram que leram o preambulo e as clausulas em voz alta e, sendo o Emitente questionado sobre sua compreensdo, declarou seu entendimento e concordancia a respeito das condicg6es aqui previstas, e, (ii) a pessoa abaixo identificada foi indicada pelo Emitente para assinar a presente CCB m. nome (assinatura a râ”¬Ã³ Na forma da lei). Assinatura a pedido do Emitente: Nome: CPF: Testemunhas: Nome: _ Ã”Ã‡Ã¶ Nome: RG: DEVEDOR(ES) SOLIDARIO(S) Assinatura: Endereco: Assinatura: Central de Relacionamento BV: 3003 1616 (capitais e regioes metropolitanas) ou 0800 701 8600 (demais localidades) de 2a | 6a feira das 7h as 22h. SAC - Sugestâ”œÂ®es, cancelamentos, elogios, reclamagâ”œÂ®es ou informagdes: 0800 770 3335 ou 0800 701 8661 (defi icientes auditivos e de fala). | Ouvidoria: 0800 707 0083 ou 0800 701 8661 (deficientes auditivos e de fala) ou pelo chat no site bv.com.br/ouvidoria, de 2a ico] fa feira, das 9h as 18h, exceto feriados nacionais_ Hash cha256 da CCR: Rad392429h81 Adie 2dad7 fee 7d 2hA77 1241570 23Ke7Mfa WichfhS51 55h IA	217444	1	\N	2025-11-03 22:21:55.641	2025-11-03 22:21:55.641	{"documentType":"06 Contratos","confidence":0.9,"detectedInfo":{"ocrExtractedText":"DULA DE CREDITO BANCARIO- | FINANCIAMENTO DE VEICULO NTE estas sao as principais condigdes do seu financiamento. Leia com stengie e guarde esta via com vocâ”œÂ®. Ã”Ã‡Ã˜ Credor ou BV: Banco Votorantim S/A CNPJ: 59.588.111/0001-03 ie | \\\\V. das Nagdes Unidas, 14.171 - Torre A 18â”¬â–‘ andar - Sao Paulo/SP INP essa CCB, independentemente de qualquer aviso ou comunicagâ”œÂ®o, podendo para tanto entregar ao cessionario toda a documentacao relativa ao crâ”œÂ®dito, sendo que apds a cessao os dâ”œÂ®bitos da operagao de crâ”œÂ®dito representada por essa CCB passarao a ser devidos e cobrados pelo cessionario. Na hipâ”œÂ®tese de emissao eletrâ”œÂ®nica da CCB, esta sera emitida em uma unica via (eletrâ”œÂ®nica), sendo negociavel apenas quando apresentada pelo BV. Na hipdtese de emissâ”œÂ®o de CCB assinada caligraficamente (fisica), serao emitidas tantas vias quantos forem seus subscritores, sendo negociavel apenas a via apresentada pelo BV. O documento \\"Condigâ”œÂ®es Gerais da Câ”œÂ®dula de Crâ”œÂ®dito Bancario\\" foi registrado sob nâ”¬â–‘1.625.129 em 19/10/2022 e averbado em 08/05/2024 sob nâ”¬â–‘ 1.655.506, no 5â”¬â–‘ Oficial de Registro oe ee e Documentos da Comarca de Sao Paulo. ee para todos os fins e efeitos, que recebi na data acima indi CCB Teller rai letas, a: tomei viamente ura. MACEIO, 24 de Maio de 2025. Assinatura do Emitente: MARIA JOSE DE LIMA Seo Emitente for analfabeto ou possuir deficiâ”œÂ®ncia, de forma que limite ou impossibilite a leitura e/ou compreensao dessa CCB, (i) as testemunhas abaixo identificadas declaram que leram o preambulo e as clausulas em voz alta e, sendo o Emitente questionado sobre sua compreensdo, declarou seu entendimento e concordancia a respeito das condicg6es aqui previstas, e, (ii) a pessoa abaixo identificada foi indicada pelo Emitente para assinar a presente CCB m. nome (assinatura a râ”¬Ã³ Na forma da lei). Assinatura a pedido do Emitente: Nome: CPF: Testemunhas: Nome: _ Ã”Ã‡Ã¶ Nome: RG: DEVEDOR(ES) SOLIDARIO(S) Assinatura: Endereco: Assinatura: Central de Relacionamento BV: 3003 1616 (capitais e regioes metropolitanas) ou 0800 701 8600 (demais localidades) de 2a | 6a feira das 7h as 22h. SAC - Sugestâ”œÂ®es, cancelamentos, elogios, reclamagâ”œÂ®es ou informagdes: 0800 770 3335 ou 0800 701 8661 (defi icientes auditivos e de fala). | Ouvidoria: 0800 707 0083 ou 0800 701 8661 (deficientes auditivos e de fala) ou pelo chat no site bv.com.br/ouvidoria, de 2a ico] fa feira, das 9h as 18h, exceto feriados nacionais_ Hash cha256 da CCR: Rad392429h81 Adie 2dad7 fee 7d 2hA77 1241570 23Ke7Mfa WichfhS51 55h IA"},"suggestedFilename":"Contratos","ocrUsed":true,"chatGPTAnalysis":"8. Contratos"}	0.9	06 Contratos	\N	f	f	Contratos_WhatsApp_Image_2025_10_21_at_15_55_59__1_.pdf	10
57	5	12	WhatsApp Image 2025-10-21 at 15.55.59 (2).jpeg	Contratos_WhatsApp_Image_2025_10_21_at_15_55_59__2_.pdf	06 Contratos	31	image/jpeg	217173	ocr_completed	https://yrzlxuefbxbpfndcpfqz.supabase.co/storage/v1/object/public/documents/processed/06_Contratos_92cc387b.pdf	FICHA DE GADASTRO - FINANGIADO / ARRENDATARIO TIPO DO CONTRATO: Operador / câ”œÂ®digo: Data do cadastro 24/05/2025 Câ”œÂ®digo Loja 1476120 Loja / Goncessionaria Filial |SUPER CAR [MACEIO Telefone DADOS DO CLIENTE GPFICNPS 931.518.494-15 __| MARIA JOSE DE LIMA. Ã”Ã‡Ã¿Orgio emissor _|ssP. Identidade Data Nascimento los/o8/1960 OF Nome Completo |FEMININO Estado civil | SOLTEIRO Data emis TT | lacionatidade N [BRASILEIRO 99001030433, Fillagao (Pai) ~ [Filiagio (Mite) OLIVIA MARIA DE LIMA_ ca ~amplomento Ã”Ã‡Â£Enderego Residencial ceP ; \\57690-000__I7. PV TIMBOZINHO. Bairro UF, Tipo Residâ”œÂ®ncia _ Tempo Residencia Cidade J ATALAIA {AL___| PROPRIO | "Feletone Residencial email {(82)3371-8122 | ANDRESSASILVASO01 @GMAIL.COM Ã”Ã‡Ã¿Ano Veteuto | | I Telefone Celular |(@2)98713-7630 Financeira Patrimonio RS 780.000,00_ Veicuto Financeira Propriedade "Valor Total Ã”Ã‡Â£Tempo Servigo (ano / mâ”œÂ®s) Telefone comercial | 10 ANOS E â”¬Âº MESES Contador Tipo profissional Prefisebo ADMINISTRADOR. _!ASSALARIADO Empresa atval | | Telefone Empresa anterior Telefone Ã”Ã‡Â£Enderago Comercial we Ã”Ã‡Ã¿Complemento Ã”Ã‡Â£Bairro Cidade UF Endereso para correspondâ”œÂ®ncia DADOS DO CONJUGE _ Nascimento PF Nome Compieto Naclonalidade Ã”Ã‡Ã¿Orga emissor Tdentidade Data emisso Naturalidade iL DADOS PROFISSIONAIS DO CONJUGE Profissao | Empresa atval NPS = Servigo ; | CEP â”¬â–‘ Ã”Ã‡Ã¿Complemento | Telefone comercial | Ramat Enderego Comercial do Conjuge Bairro Telefone [ Total [R$ 15.000,00 Entrada ou VRG antecipado REFERENCIAS PESSOAIS DO CLIENTE Renda Mensal / Faturamento Rendimentos do câ”œÂ®njuge Outros rendimentos R$ 15.000,00 | | Contrato Gondigao Comercial Valor da Compra PRE-FIXADO | 105 {R$ 80.000,00 [42.93% : RS 38.000,00 Valor Financiado Coeficiente jor da Prestagao * Vencimento Val 6 4 3 R$ 46.900,85 {0.02875 [60 X DE R$ 1.305,00 (23/06/2025 VEICULO(S) Ã”Ã‡Ã¿Ano Fabricagio Ano Modelo Cor AUTOMOVEL - HYUNDAI - HB20 COMFORT PLUS 1.0 MTS 4P ( (2023 ze IPRATA | Seguros Valor de \\OUTROS: RS 2.947,52 Carâ”œÂ®ncia {30 DIAS) Place Issc2is3 Ã”Ã‡Ã¿Observacao LAUDO DE VISTORIA Tapecaria / Estofamento Bom [] Regular Ruim Estado geral do veiculo Bom [_] Regular Ruim Pneus Regular Pintura Regular Bom. ASSINATURA DO VISTORIADOR ladas a vista do original do documento de identificagao, CPF e outros comprobatâ”œÂ®rios dos demais licagao disposto do Art.19 da Lei nâ”¬â–‘ 7.492, de 16/06/1986. Ademais, autorizo expressamente 2 te operacdo e informagoes, inclusive cadastrais, para efeito de cobranca extrajudicial Ã”Ã©Â¼ financeiras, â”œÂ®rgaos de protegao ao crâ”œÂ®dito (SPC Ã”Ã©Â¼ ~ (AL 200438908, Responsabilizo-me pela exatidao das informagGes prest elementos de informagao apresentados, sob pena de ap! divulgagao e encaminhamento dos documentos relativos a presen judicial, bem como para a consultalenvio de meus dados e/ou operagdes junto a outras instituiges SERASA) e Central de Riscos do Banco Central do Brasil ATENGAO - NAO ASSINE SEM 0 COMPLETO PREENCHIMENTO E CONCORDANCIA DO PLANO AC MACEIO 24/05/2025, LOCAL E DATA ASSINATURA DO FINANCIADO / ARRENDATARIO. Hash cha?5h da COR* Red397479h6742AdeAdad7fcc7d9hAT77 1 2dt57a2A6e 70% VOchthaS 1559 7bR a	224972	1	\N	2025-11-03 22:22:03.497	2025-11-03 22:22:03.497	{"documentType":"06 Contratos","confidence":0.9,"detectedInfo":{"ocrExtractedText":"FICHA DE GADASTRO - FINANGIADO / ARRENDATARIO TIPO DO CONTRATO: Operador / câ”œÂ®digo: Data do cadastro 24/05/2025 Câ”œÂ®digo Loja 1476120 Loja / Goncessionaria Filial |SUPER CAR [MACEIO Telefone DADOS DO CLIENTE GPFICNPS 931.518.494-15 __| MARIA JOSE DE LIMA. Ã”Ã‡Ã¿Orgio emissor _|ssP. Identidade Data Nascimento los/o8/1960 OF Nome Completo |FEMININO Estado civil | SOLTEIRO Data emis TT | lacionatidade N [BRASILEIRO 99001030433, Fillagao (Pai) ~ [Filiagio (Mite) OLIVIA MARIA DE LIMA_ ca ~amplomento Ã”Ã‡Â£Enderego Residencial ceP ; \\\\57690-000__I7. PV TIMBOZINHO. Bairro UF, Tipo Residâ”œÂ®ncia _ Tempo Residencia Cidade J ATALAIA {AL___| PROPRIO | \\"Feletone Residencial email {(82)3371-8122 | ANDRESSASILVASO01 @GMAIL.COM Ã”Ã‡Ã¿Ano Veteuto | | I Telefone Celular |(@2)98713-7630 Financeira Patrimonio RS 780.000,00_ Veicuto Financeira Propriedade \\"Valor Total Ã”Ã‡Â£Tempo Servigo (ano / mâ”œÂ®s) Telefone comercial | 10 ANOS E â”¬Âº MESES Contador Tipo profissional Prefisebo ADMINISTRADOR. _!ASSALARIADO Empresa atval | | Telefone Empresa anterior Telefone Ã”Ã‡Â£Enderago Comercial we Ã”Ã‡Ã¿Complemento Ã”Ã‡Â£Bairro Cidade UF Endereso para correspondâ”œÂ®ncia DADOS DO CONJUGE _ Nascimento PF Nome Compieto Naclonalidade Ã”Ã‡Ã¿Orga emissor Tdentidade Data emisso Naturalidade iL DADOS PROFISSIONAIS DO CONJUGE Profissao | Empresa atval NPS = Servigo ; | CEP â”¬â–‘ Ã”Ã‡Ã¿Complemento | Telefone comercial | Ramat Enderego Comercial do Conjuge Bairro Telefone [ Total [R$ 15.000,00 Entrada ou VRG antecipado REFERENCIAS PESSOAIS DO CLIENTE Renda Mensal / Faturamento Rendimentos do câ”œÂ®njuge Outros rendimentos R$ 15.000,00 | | Contrato Gondigao Comercial Valor da Compra PRE-FIXADO | 105 {R$ 80.000,00 [42.93% : RS 38.000,00 Valor Financiado Coeficiente jor da Prestagao * Vencimento Val 6 4 3 R$ 46.900,85 {0.02875 [60 X DE R$ 1.305,00 (23/06/2025 VEICULO(S) Ã”Ã‡Ã¿Ano Fabricagio Ano Modelo Cor AUTOMOVEL - HYUNDAI - HB20 COMFORT PLUS 1.0 MTS 4P ( (2023 ze IPRATA | Seguros Valor de \\\\OUTROS: RS 2.947,52 Carâ”œÂ®ncia {30 DIAS) Place Issc2is3 Ã”Ã‡Ã¿Observacao LAUDO DE VISTORIA Tapecaria / Estofamento Bom [] Regular Ruim Estado geral do veiculo Bom [_] Regular Ruim Pneus Regular Pintura Regular Bom. ASSINATURA DO VISTORIADOR ladas a vista do original do documento de identificagao, CPF e outros comprobatâ”œÂ®rios dos demais licagao disposto do Art.19 da Lei nâ”¬â–‘ 7.492, de 16/06/1986. Ademais, autorizo expressamente 2 te operacdo e informagoes, inclusive cadastrais, para efeito de cobranca extrajudicial Ã”Ã©Â¼ financeiras, â”œÂ®rgaos de protegao ao crâ”œÂ®dito (SPC Ã”Ã©Â¼ ~ (AL 200438908, Responsabilizo-me pela exatidao das informagGes prest elementos de informagao apresentados, sob pena de ap! divulgagao e encaminhamento dos documentos relativos a presen judicial, bem como para a consultalenvio de meus dados e/ou operagdes junto a outras instituiges SERASA) e Central de Riscos do Banco Central do Brasil ATENGAO - NAO ASSINE SEM 0 COMPLETO PREENCHIMENTO E CONCORDANCIA DO PLANO AC MACEIO 24/05/2025, LOCAL E DATA ASSINATURA DO FINANCIADO / ARRENDATARIO. Hash cha?5h da COR* Red397479h6742AdeAdad7fcc7d9hAT77 1 2dt57a2A6e 70% VOchthaS 1559 7bR a"},"suggestedFilename":"Contratos","ocrUsed":true,"chatGPTAnalysis":"8. Contratos"}	0.9	06 Contratos	\N	f	f	Contratos_WhatsApp_Image_2025_10_21_at_15_55_59__2_.pdf	10
58	5	12	WhatsApp Image 2025-10-21 at 15.55.59 (3).jpeg	07 proposta de adesâ”œÃºo de seguro.pdf	07 proposta de adesâ”œÃºo de seguro	32	image/jpeg	265356	ocr_completed	https://yrzlxuefbxbpfndcpfqz.supabase.co/storage/v1/object/public/documents/processed/07_proposta_de_adesao_de_seguro_7ed6bdaf.pdf	4. A lcatu â”¬Âº i a 4 aida 7 icon ia. aera P eguros S.A. nos termos da regulamentagao em vigor, estâ”œÂ® autorizada a buscar novos subsidios para a analise e verificagao das informagdes aqui prestadas no Ã”Ã‡Ã¿momento da contratagâ”œÂ®o do seguro ou na ocorrencia de cmt, 15. As informagoes contidas nesta rope 840 certas, completas e verdadeiras. Estou ee de que {\\aisquer omissdes ou inexatiddes contdas nas informagdes prestadas nesta proposta ocasionarao a perda do drlto ou a resolug4o do contrato pela Sequradora, de acordo COm 0s termos do art, 768 do Codigo Civil. Se o segurado, seu representante ou seu corretor de seguros fizer declaragies inexatas ou omit fatos que alterem aceitagao da Droposta ou 0 valor do prâ”œÂ®mio, 0 segurado estara obrigado ao. pagamento do prâ”œÂ®mio vencido @ 0 direito & ie ficara prejucicado | 8. A aveitagdo do Seguro estara Sujeita a andlise do risco. | 7. Estou ciente de que (i) 0 tratamento dos dados pessoais informados no presente documento sera realizado em conformidade com toda a legislagdo incluindo, mas nao se limtando a Lei Geral de Proterdo de Dados, (i) a Icatu Seguros podera, sempre respeitando a legislacdo aplicavel, compartlhar os cdados pessoais aqui informados, bem como dados referentes ao Produto contratado comn os Intermediarios e com outras entidades privadas ou drgaos pli i mais informagbes sobre a protegao dos dados pessoais, basta avessar a Politica Privacidade da lcatu disponivel na Area do Chente. J contempla 0 Imposto sobre Operagbes Financeiras ((OF), Em atendimento A Lei 12.741/12, estâ”œÂ®o disponivels no site http alteragGes relativas aos tibutos incidentes, com o detalhamento das aliquotas e dedugoes estabelecidas em legislagao espectfica, Declaro que tiv prvioe expresso conhecimento dos temas das Condigdes Contras do plano escchido, bem como das Condes Gerais do Seguro csponives para consulta no site hitp:/www.icatuse ;s,com,.br. Deca ainda que o produto e plano escolhido esto de acordo com meu perfil de investimento @ adequados aos meus inferesses, bem como 0 valor do prâ”œÂ®mio â”œÂ® compativel com minha stuagSo france, Estou cents de que toda a comuricarao da sequradora ser realizata preerenciamentepore-mal. utvizooEstnulant a efetuar a cobranca relia ao pagamento do()prâ”œÂ®mo() do seguro constant) nesta proposta de adeso, MARIA JOSE DE LIMA MACEIO 24/05/2025 Local e data Assinatura do proponente Ã”Ã‡Ã¿A leat Seguros SIA tem o prazo de atâ”œÂ® 15 dias, contados da data que vier a ser recebida a proposta, para manifestar-se em relagdo @ sua aceitagao ou recusa. Este prazo sera suspenso quando necessaria a requisigao de outros documentos ou dados para andlise do risco. Essa eventual suspensdo terminara quando forem protocolados todos (0s documentos ou dados solictados, A emissdo e o envio da apdlice ou certficado individual dentro do prazo de andlise substitui a manifestacdo expressa de aceitacao da proposta pela seguradora, Caso nao haja manifestagao expressa sobre o resultado da andlise desta proposta por parte da Icatu Seguros SIA denito do prazo antes referido, ficara caracterizada a sua aceitagao tacita. No caso de nâ”œÂ®o aceitagao da proposta, a Icalu Seguros S/A devolverd 0 valor do prâ”œÂ®mio j4 quitado, atualizado atâ”œÂ® a data da efetiva restitvigdo, de acordo com a legislagdo vigente. Seguro de Acidentes Pessoais, administrado por Icatu Seguros SIA, CNPJIMF 42283,770/0001-39 Câ”œÂ®digo Susep: 0544-2. â”¬â•— N? Processos SUSEP: Acidentes Pessoais Coletivo: 15444.00272112006-63, â”¬â•— Titulo de pagamento tnico da modalidade incentivo emitido pela Icatu Capitalzacao SIA, CNPJMF nâ”¬â–‘ 74.267.170/0001-73, Processos SUSEP n? 15414.900369/2019-48. Ands a comunicagdo do sorteio, o prâ”œÂ®mio estarâ”œÂ® cisponivel para pagamento pelo prazo prescricional em vigor, 0 qual, alualmente â”œÂ® de 5 anos, conforme previsto no Câ”œÂ®digo Civil de 2002. SAC Icatu Captalizagao 08000 286 0116. Ouvidoria Icatu Seguros 0800 286 0047. Este seguro Ã”Ã©Â¼ por prazo determinado tendo a Sequradora a faculdade de ndo renovar a apdlice na data de vencimento, sem devoluco dos prâ”œÂ®mios pagos nos termos da apdlice. 0 registro do produto Ã”Ã©Â¼ automatic e nao representa aprovagao ou recomendagao a sua comercializago, O segurado podera consultar a sitvagao cadastral de seu corretor de seguros (BV Coretora de Seguros S.A. - Codigo SUSEP 20 206.807-4), no site www.susep.gov.br, por meio do nimero de seu registto na SUSEP, nome completo, CNP) ou CPF. Seguro Estipulado por Banco Votorantim S.A, CNPJ 59.588.111/0001-03. â”¬Â® montante corespondenie a cinquenta Ã”Ã©Â¼ cinoo por cento do prâ”œÂ®mio liquido pago pelo cliente a Icalu Seguros SIA, decorente da venda do presente produto â”œÂ® referente a cistibuicao realizada pela BV Corretora de Seguros S.A. CNPJ 09.023.931/0001-80. ORC; 4002 0045 capitais e regides metropolitanas / 0800 286 0045 demais localidades. SAC 0800 286 0110, de segunda a sexta-feira, das 8h as 20h â”¬Ã³ sâ”œÂ®bados, dominos â”¬Ã³ feriados nacionais, das 8h 8s 16h. Nos demais horarios, vooe pode acessar 0 Ã”Ã‡Ã¿SAC em www.icafuiseguros.combrlatendimento, Para alendimento em Libras, avesse nosso site de segunda a sexta-feira, das 8h as 20h e sdbados, domingos feriados nacionais, das 8h as Ã”Ã‡Ã¿6h... Ouvidora (ao ligar tenha em midos o ndmero do protocolo de atendimento) 0800 286 0047, de segunda a sexta-eira, das 8h as 18h, exceto feriados, Proposta de Adesdo Seguro de Vida -3 VIAS - 1" SEGURADORA / 2* CORRETOR | 3* PROPONENTE Hash eha?56 da CCR: Red 392429h6712Rdle Aad tee T 2667712415 7a7 26a 7 Mat Ac bh S51559h76R	279988	1	\N	2025-11-03 22:22:12.161	2025-11-03 22:22:12.161	{"documentType":"07 proposta de adesâ”œÃºo de seguro","confidence":0.9,"detectedInfo":{"ocrExtractedText":"4. A lcatu â”¬Âº i a 4 aida 7 icon ia. aera P eguros S.A. nos termos da regulamentagao em vigor, estâ”œÂ® autorizada a buscar novos subsidios para a analise e verificagao das informagdes aqui prestadas no Ã”Ã‡Ã¿momento da contratagâ”œÂ®o do seguro ou na ocorrencia de cmt, 15. As informagoes contidas nesta rope 840 certas, completas e verdadeiras. Estou ee de que {\\\\aisquer omissdes ou inexatiddes contdas nas informagdes prestadas nesta proposta ocasionarao a perda do drlto ou a resolug4o do contrato pela Sequradora, de acordo COm 0s termos do art, 768 do Codigo Civil. Se o segurado, seu representante ou seu corretor de seguros fizer declaragies inexatas ou omit fatos que alterem aceitagao da Droposta ou 0 valor do prâ”œÂ®mio, 0 segurado estara obrigado ao. pagamento do prâ”œÂ®mio vencido @ 0 direito & ie ficara prejucicado | 8. A aveitagdo do Seguro estara Sujeita a andlise do risco. | 7. Estou ciente de que (i) 0 tratamento dos dados pessoais informados no presente documento sera realizado em conformidade com toda a legislagdo incluindo, mas nao se limtando a Lei Geral de Proterdo de Dados, (i) a Icatu Seguros podera, sempre respeitando a legislacdo aplicavel, compartlhar os cdados pessoais aqui informados, bem como dados referentes ao Produto contratado comn os Intermediarios e com outras entidades privadas ou drgaos pli i mais informagbes sobre a protegao dos dados pessoais, basta avessar a Politica Privacidade da lcatu disponivel na Area do Chente. J contempla 0 Imposto sobre Operagbes Financeiras ((OF), Em atendimento A Lei 12.741/12, estâ”œÂ®o disponivels no site http alteragGes relativas aos tibutos incidentes, com o detalhamento das aliquotas e dedugoes estabelecidas em legislagao espectfica, Declaro que tiv prvioe expresso conhecimento dos temas das Condigdes Contras do plano escchido, bem como das Condes Gerais do Seguro csponives para consulta no site hitp:/www.icatuse ;s,com,.br. Deca ainda que o produto e plano escolhido esto de acordo com meu perfil de investimento @ adequados aos meus inferesses, bem como 0 valor do prâ”œÂ®mio â”œÂ® compativel com minha stuagSo france, Estou cents de que toda a comuricarao da sequradora ser realizata preerenciamentepore-mal. utvizooEstnulant a efetuar a cobranca relia ao pagamento do()prâ”œÂ®mo() do seguro constant) nesta proposta de adeso, MARIA JOSE DE LIMA MACEIO 24/05/2025 Local e data Assinatura do proponente Ã”Ã‡Ã¿A leat Seguros SIA tem o prazo de atâ”œÂ® 15 dias, contados da data que vier a ser recebida a proposta, para manifestar-se em relagdo @ sua aceitagao ou recusa. Este prazo sera suspenso quando necessaria a requisigao de outros documentos ou dados para andlise do risco. Essa eventual suspensdo terminara quando forem protocolados todos (0s documentos ou dados solictados, A emissdo e o envio da apdlice ou certficado individual dentro do prazo de andlise substitui a manifestacdo expressa de aceitacao da proposta pela seguradora, Caso nao haja manifestagao expressa sobre o resultado da andlise desta proposta por parte da Icatu Seguros SIA denito do prazo antes referido, ficara caracterizada a sua aceitagao tacita. No caso de nâ”œÂ®o aceitagao da proposta, a Icalu Seguros S/A devolverd 0 valor do prâ”œÂ®mio j4 quitado, atualizado atâ”œÂ® a data da efetiva restitvigdo, de acordo com a legislagdo vigente. Seguro de Acidentes Pessoais, administrado por Icatu Seguros SIA, CNPJIMF 42283,770/0001-39 Câ”œÂ®digo Susep: 0544-2. â”¬â•— N? Processos SUSEP: Acidentes Pessoais Coletivo: 15444.00272112006-63, â”¬â•— Titulo de pagamento tnico da modalidade incentivo emitido pela Icatu Capitalzacao SIA, CNPJMF nâ”¬â–‘ 74.267.170/0001-73, Processos SUSEP n? 15414.900369/2019-48. Ands a comunicagdo do sorteio, o prâ”œÂ®mio estarâ”œÂ® cisponivel para pagamento pelo prazo prescricional em vigor, 0 qual, alualmente â”œÂ® de 5 anos, conforme previsto no Câ”œÂ®digo Civil de 2002. SAC Icatu Captalizagao 08000 286 0116. Ouvidoria Icatu Seguros 0800 286 0047. Este seguro Ã”Ã©Â¼ por prazo determinado tendo a Sequradora a faculdade de ndo renovar a apdlice na data de vencimento, sem devoluco dos prâ”œÂ®mios pagos nos termos da apdlice. 0 registro do produto Ã”Ã©Â¼ automatic e nao representa aprovagao ou recomendagao a sua comercializago, O segurado podera consultar a sitvagao cadastral de seu corretor de seguros (BV Coretora de Seguros S.A. - Codigo SUSEP 20 206.807-4), no site www.susep.gov.br, por meio do nimero de seu registto na SUSEP, nome completo, CNP) ou CPF. Seguro Estipulado por Banco Votorantim S.A, CNPJ 59.588.111/0001-03. â”¬Â® montante corespondenie a cinquenta Ã”Ã©Â¼ cinoo por cento do prâ”œÂ®mio liquido pago pelo cliente a Icalu Seguros SIA, decorente da venda do presente produto â”œÂ® referente a cistibuicao realizada pela BV Corretora de Seguros S.A. CNPJ 09.023.931/0001-80. ORC; 4002 0045 capitais e regides metropolitanas / 0800 286 0045 demais localidades. SAC 0800 286 0110, de segunda a sexta-feira, das 8h as 20h â”¬Ã³ sâ”œÂ®bados, dominos â”¬Ã³ feriados nacionais, das 8h 8s 16h. Nos demais horarios, vooe pode acessar 0 Ã”Ã‡Ã¿SAC em www.icafuiseguros.combrlatendimento, Para alendimento em Libras, avesse nosso site de segunda a sexta-feira, das 8h as 20h e sdbados, domingos feriados nacionais, das 8h as Ã”Ã‡Ã¿6h... Ouvidora (ao ligar tenha em midos o ndmero do protocolo de atendimento) 0800 286 0047, de segunda a sexta-eira, das 8h as 18h, exceto feriados, Proposta de Adesdo Seguro de Vida -3 VIAS - 1\\" SEGURADORA / 2* CORRETOR | 3* PROPONENTE Hash eha?56 da CCR: Red 392429h6712Rdle Aad tee T 2667712415 7a7 26a 7 Mat Ac bh S51559h76R"},"suggestedFilename":"proposta de adesâ”œÃºo de seguro","ocrUsed":true,"chatGPTAnalysis":"9. Proposta de Adesâ”œÃºo de Seguro"}	0.9	07 proposta de adesâ”œÃºo de seguro	\N	f	f	07 proposta de adesâ”œÃºo de seguro.pdf	10
59	5	12	WhatsApp Image 2025-10-21 at 15.55.59.jpeg	Contratos_WhatsApp_Image_2025_10_21_at_15_55_59.pdf	06 Contratos	33	image/jpeg	406398	ocr_completed	https://yrzlxuefbxbpfndcpfqz.supabase.co/storage/v1/object/public/documents/processed/06_Contratos_4e98eeea.pdf	SEGURO PROTECAO FINANCEIRA TOTAL As Condicoes Gerals deste seguro foram apresentadas ao sequrado no momento da contratagao, e tambâ”œÂ®m estao disponiveis no site condicoesgerals.bnpparibascardif.com.bt/pf. a 4 VOCE E 0 Ã”Ã‡Â£PROPONENTEÃ”Ã‡Ã˜ NESTA PROPOSTA DE ADESAO. AQUI ESTAO OS SEUS DADOS PESSOAIS: Home. MARIA HOSE DE LIMA Ã”Ã‡Â£Nome sit cer 931,518. 49415 Data de Nascimento 09/08/1960. Nacionaliade BRASILEIRO fndereoo PV TIMBOZINHO, 7- CENTRO oe $7690-000 Cita ATALATA uf AL 4 CONFIRA OS DADOS DO SEGURO QUE VOCE VAI CONTRATAR: N*daroposta 200438908 Valor Financiads RS 48.90,85 Prtinio tice Total RS 1.798,78 Forma de Papamenta nuida no Financlamento (oe RS 6,81 Modaldage de Cantal Seourado Contatada. Coberturas de Protepaa Financeira: Capital Segurado Vinculada /Coberturas de Protecao ao Segurado: Capital Sequrada ValarFixa Vigâ”œÂ®neia do CO perfodo de vigâ”œÂ®ncla do seguro seguird a vigâ”œÂ®ncia do Contrato de Financiamento, que serd de 60 meses. As datas de inicio e fim de vigâ”œÂ®nela serao Segura: discriminadas no Certificado de Seguro. As coberturas de Protecao Financeira vigerdo desde a data de Inicio de vigâ”œÂ®ncla do Certificada de segura atâ”œÂ® a data da liquidagao do Contrato de Financiamento. As coberturas de Proteco ao Segurado vigerdo desde a data da liquidapao Antecipada do Contrato de Financlamento, se ocomer, atâ”œÂ® a.data originalmente prevista para tâ”œÂ®rmino de vigâ”œÂ®ncia do Seguro. 4 VEIA AQUI ALGUMAS DEFINIGOES IMPORTANTES PARA 0 SEU SEGURO: Coberturas de Prot Financeira - Capital Sequrade Vinculado: Modalidade em que o Capital Segurado â”œÂ® necessariamente igual a0 valor da Obrigacao, sendo alterado avtomaticamente a cada amortizacâ”œÂ®o ov reajuste Coberturas de Protepao ao Segurado (ativadas se ocorer a ee Antec da Obrigacdo) - Capital Sequrado valor fixe: Ã”Ã©Â¼ 0 valor maxima a ser page pela Seguratiora para als) cobe 4 pONHECe O SEGURO QUE VOCE VAI CONTRATAR EM DETALHES, PROTEGAO POR PROTEGAO: PROTECAO FINANCEIRA - VIGENCIA ATE LIQUIDAGAO ANTECIPADA DA OBRIGACAO |Coberturas: fra. |Eegiblidade: veja as protecies Prâ”œÂ®mio: 0 or Ue [eae Sapa it do [Fans rd {Cantal Sequa: eventos previstos|previstas de acordo c â”¬â•— seu tng segura | trabalha j protec: i responsavel pela divid Pagamento do saldo devedar Fj | | lata do evento, sem ennsiderar | Morte (1) Todos as tipos RS 956,95 Nao ha Parcelas em atraso @ encargos, Ho limite de BS $3.000,00, pages | a vista, Pagamento do saldo devedor na Invalidez data do evento, sem considerar Permanente Total | Todos os tipos 19 parcelas em atraso e encargas, for Acidente no limite de AS 55.000,00, pages a vista Ã”Ã‡Ã˜|Profissionals com vinculo empregaticio minima de 365 dias| Pagamento de atâ”œÂ® 3 parcelas, Desemprega ininterruptos com regime CLT ns 73390 sem considerar parcelas em Involuntâ”œÂ®rio (2) para o mesmo empregador, com ? atraso Ã”Ã©Â¼ encargos, no limite de Ã”Ã‡Ã¿uma jomada de trabalho minima RS1.500,00, por parcela. de 30 horas semanais. Pagamento de atâ”œÂ® J parcelas, Incapacidade Fisica |Profissionais liberals/avtonomos Ã”Ã‡Ã¿sem considerar parcelas em Total Temporaria (3) |requiamentados e comprovados. atraso e encargos, no limite de AS1300,00, por parcela, Hash sha256 da CCR: Red397429h621 2Ade34a47fcc7d2h6771 2405 7a23he7 fat 1Ochfh551559b2bR	249115	1	\N	2025-11-03 22:22:19.639	2025-11-03 22:22:19.639	{"documentType":"06 Contratos","confidence":0.9,"detectedInfo":{"ocrExtractedText":"SEGURO PROTECAO FINANCEIRA TOTAL As Condicoes Gerals deste seguro foram apresentadas ao sequrado no momento da contratagao, e tambâ”œÂ®m estao disponiveis no site condicoesgerals.bnpparibascardif.com.bt/pf. a 4 VOCE E 0 Ã”Ã‡Â£PROPONENTEÃ”Ã‡Ã˜ NESTA PROPOSTA DE ADESAO. AQUI ESTAO OS SEUS DADOS PESSOAIS: Home. MARIA HOSE DE LIMA Ã”Ã‡Â£Nome sit cer 931,518. 49415 Data de Nascimento 09/08/1960. Nacionaliade BRASILEIRO fndereoo PV TIMBOZINHO, 7- CENTRO oe $7690-000 Cita ATALATA uf AL 4 CONFIRA OS DADOS DO SEGURO QUE VOCE VAI CONTRATAR: N*daroposta 200438908 Valor Financiads RS 48.90,85 Prtinio tice Total RS 1.798,78 Forma de Papamenta nuida no Financlamento (oe RS 6,81 Modaldage de Cantal Seourado Contatada. Coberturas de Protepaa Financeira: Capital Segurado Vinculada /Coberturas de Protecao ao Segurado: Capital Sequrada ValarFixa Vigâ”œÂ®neia do CO perfodo de vigâ”œÂ®ncla do seguro seguird a vigâ”œÂ®ncia do Contrato de Financiamento, que serd de 60 meses. As datas de inicio e fim de vigâ”œÂ®nela serao Segura: discriminadas no Certificado de Seguro. As coberturas de Protecao Financeira vigerdo desde a data de Inicio de vigâ”œÂ®ncla do Certificada de segura atâ”œÂ® a data da liquidagao do Contrato de Financiamento. As coberturas de Proteco ao Segurado vigerdo desde a data da liquidapao Antecipada do Contrato de Financlamento, se ocomer, atâ”œÂ® a.data originalmente prevista para tâ”œÂ®rmino de vigâ”œÂ®ncia do Seguro. 4 VEIA AQUI ALGUMAS DEFINIGOES IMPORTANTES PARA 0 SEU SEGURO: Coberturas de Prot Financeira - Capital Sequrade Vinculado: Modalidade em que o Capital Segurado â”œÂ® necessariamente igual a0 valor da Obrigacao, sendo alterado avtomaticamente a cada amortizacâ”œÂ®o ov reajuste Coberturas de Protepao ao Segurado (ativadas se ocorer a ee Antec da Obrigacdo) - Capital Sequrado valor fixe: Ã”Ã©Â¼ 0 valor maxima a ser page pela Seguratiora para als) cobe 4 pONHECe O SEGURO QUE VOCE VAI CONTRATAR EM DETALHES, PROTEGAO POR PROTEGAO: PROTECAO FINANCEIRA - VIGENCIA ATE LIQUIDAGAO ANTECIPADA DA OBRIGACAO |Coberturas: fra. |Eegiblidade: veja as protecies Prâ”œÂ®mio: 0 or Ue [eae Sapa it do [Fans rd {Cantal Sequa: eventos previstos|previstas de acordo c â”¬â•— seu tng segura | trabalha j protec: i responsavel pela divid Pagamento do saldo devedar Fj | | lata do evento, sem ennsiderar | Morte (1) Todos as tipos RS 956,95 Nao ha Parcelas em atraso @ encargos, Ho limite de BS $3.000,00, pages | a vista, Pagamento do saldo devedor na Invalidez data do evento, sem considerar Permanente Total | Todos os tipos 19 parcelas em atraso e encargas, for Acidente no limite de AS 55.000,00, pages a vista Ã”Ã‡Ã˜|Profissionals com vinculo empregaticio minima de 365 dias| Pagamento de atâ”œÂ® 3 parcelas, Desemprega ininterruptos com regime CLT ns 73390 sem considerar parcelas em Involuntâ”œÂ®rio (2) para o mesmo empregador, com ? atraso Ã”Ã©Â¼ encargos, no limite de Ã”Ã‡Ã¿uma jomada de trabalho minima RS1.500,00, por parcela. de 30 horas semanais. Pagamento de atâ”œÂ® J parcelas, Incapacidade Fisica |Profissionais liberals/avtonomos Ã”Ã‡Ã¿sem considerar parcelas em Total Temporaria (3) |requiamentados e comprovados. atraso e encargos, no limite de AS1300,00, por parcela, Hash sha256 da CCR: Red397429h621 2Ade34a47fcc7d2h6771 2405 7a23he7 fat 1Ochfh551559b2bR"},"suggestedFilename":"Contratos","ocrUsed":true,"chatGPTAnalysis":"8. Contratos"}	0.9	06 Contratos	\N	f	f	Contratos_WhatsApp_Image_2025_10_21_at_15_55_59.pdf	10
60	5	12	WhatsApp Image 2025-10-21 at 15.56.00 (1).jpeg	Contratos_WhatsApp_Image_2025_10_21_at_15_56_00__1_.pdf	06 Contratos	34	image/jpeg	166292	ocr_completed	https://yrzlxuefbxbpfndcpfqz.supabase.co/storage/v1/object/public/documents/processed/06_Contratos_38169a3a.pdf	SEGURO PROTECAO FINANCEIRA TOTAL Ã”Ã‡Ã¿As CondigGes Gerais deste sequro foram apresentadas ao sequrada no momento da contratacdo, â”¬Ã³ tambâ”œÂ®m estao disponivels no site condicoesgerals.bnpparibascardifcom.br/pf. Sinistros: 8009-4244 Capitals e Seguradora: Cardy do Brasil Vida e Previderola SA CNPT 0a 546 2617000708 Codigo SUSEP: Obo4-e Particpagan: 30% (rinta Regides Metropolitanas ov for cento) Ã”Ã‡Ã¿0800 200 0844 Demais localdades Cosseguradora: Brasiseg Companhia De Seguros CNP: 28.196 B89/0001-43 Câ”œÂ®iga SUSEP: 0678-5 Partciparao: 70 % (setenta Segunda a Sdbado das 08 as 22 horâ”œÂ®s. por centa), . Processo SUSEP: 15414.616080/2022-60 Fee am tan sons NOTRE ESEO? 800 da ce bc oti 2 Disponivels todos 6 aia, 24 Fstioulante: Banco Votorantin 8/8. CNP â”¬Âº9.588,1/000F-03, Remuneracdo: 00% - AS 89.60 CCorretora: BV Corretora de Seguros â”¬Âº.A. CNP!: 09.028.991/0001-80 Registra SUSEP: 202068074, Remunerapdo BVCS; equivalente a atâ”œÂ® 3.06% sobre o capital nerado que correspond ao valor iquido fnanciad * taxas. Disposipdes Gerals: Caso nd esteja satisfeito com a resposta fomnecida pelo SAC, entre em contato com a Ouvidoria: 0800 727 2482 - Dias itels, das 9h as 18 horas (horâ”œÂ®ri de Brasfia) exceto feriados ov acesse ouvidoria bnoparibascardif.com:br Ã”Ã©Â¼ tambâ”œÂ®m www.consumidor.gov.br. A contratagao do Segura â”œÂ® opcional. 0 registra do produto & avtomatico e ndo representa aprovacdo ou recomendacao por parte da Susep, 0 sequrado poderd consular asituagdo cadastral do conto de seguros & fla sociedade seguradora no sftio eletrinico wwwsusepgov.br. A aceltagdo da proposta de seguro esti sujeita a andlise do risco. As condigies contratuais/tegulamento deste produto protocolizadas pela sociedade/entidade junto a SUSEP poderao ser consultadas no enderego eletrdnico www.susep.gov.br de acordo com o nimero de processo constante da apdlice/proposta, Este seguro Ã”Ã©Â¼ por prazo determinada tendo a seguradora a faculdade de nao renavar a apdlice na data de vencimenta sem devolueao das prâ”œÂ®mins pagos nos termos da apdlice. Fm atendimenta @ lel 12,741)? informamos que incidem as aliquotas de 0.85% de PiS/Pasep e de 4% de COFINS sobre os premios de seguros/as contribuicâ”œÂ®es a planos de cardter previdenciâ”œÂ®rio/os pagamentos destinados a planos de capitalizardo, deduzidos do estabelecido em lenislacdo espectfica A falta de pagamenta de parcelas ou do prâ”œÂ®mio a vista, na data indicada no respective documento de cobranca, implicarâ”œÂ®automaticamente na suspensdo da cobertura que somente serâ”œÂ®reablitada a partir das 24 (vite E quatro) horas da data em que 0 sSegurado ov o estipulante retomar o pagamento do prâ”œÂ®mio. Decorrida o prazo estabelecida para pagamento, 0 seguro ficard automaticamente cancelado, independentemente de qualquer interpelagan judicial ov extrajudicial A FRAUDE CONTRA SEBUROS ECAIME, DENUNGIE (71)2259-17_OU 18 - WW. FENASES.ORE. BR BNP PARIBAS GG carpiF Hash sha256 da CCR: naci202420h8212Adie24ad7fecTA2hh77124157a2AhA7OfA 1 Ochth55155Ah2HA	174061	1	\N	2025-11-03 22:22:25.41	2025-11-03 22:22:25.41	{"documentType":"06 Contratos","confidence":0.9,"detectedInfo":{"ocrExtractedText":"SEGURO PROTECAO FINANCEIRA TOTAL Ã”Ã‡Ã¿As CondigGes Gerais deste sequro foram apresentadas ao sequrada no momento da contratacdo, â”¬Ã³ tambâ”œÂ®m estao disponivels no site condicoesgerals.bnpparibascardifcom.br/pf. Sinistros: 8009-4244 Capitals e Seguradora: Cardy do Brasil Vida e Previderola SA CNPT 0a 546 2617000708 Codigo SUSEP: Obo4-e Particpagan: 30% (rinta Regides Metropolitanas ov for cento) Ã”Ã‡Ã¿0800 200 0844 Demais localdades Cosseguradora: Brasiseg Companhia De Seguros CNP: 28.196 B89/0001-43 Câ”œÂ®iga SUSEP: 0678-5 Partciparao: 70 % (setenta Segunda a Sdbado das 08 as 22 horâ”œÂ®s. por centa), . Processo SUSEP: 15414.616080/2022-60 Fee am tan sons NOTRE ESEO? 800 da ce bc oti 2 Disponivels todos 6 aia, 24 Fstioulante: Banco Votorantin 8/8. CNP â”¬Âº9.588,1/000F-03, Remuneracdo: 00% - AS 89.60 CCorretora: BV Corretora de Seguros â”¬Âº.A. CNP!: 09.028.991/0001-80 Registra SUSEP: 202068074, Remunerapdo BVCS; equivalente a atâ”œÂ® 3.06% sobre o capital nerado que correspond ao valor iquido fnanciad * taxas. Disposipdes Gerals: Caso nd esteja satisfeito com a resposta fomnecida pelo SAC, entre em contato com a Ouvidoria: 0800 727 2482 - Dias itels, das 9h as 18 horas (horâ”œÂ®ri de Brasfia) exceto feriados ov acesse ouvidoria bnoparibascardif.com:br Ã”Ã©Â¼ tambâ”œÂ®m www.consumidor.gov.br. A contratagao do Segura â”œÂ® opcional. 0 registra do produto & avtomatico e ndo representa aprovacdo ou recomendacao por parte da Susep, 0 sequrado poderd consular asituagdo cadastral do conto de seguros & fla sociedade seguradora no sftio eletrinico wwwsusepgov.br. A aceltagdo da proposta de seguro esti sujeita a andlise do risco. As condigies contratuais/tegulamento deste produto protocolizadas pela sociedade/entidade junto a SUSEP poderao ser consultadas no enderego eletrdnico www.susep.gov.br de acordo com o nimero de processo constante da apdlice/proposta, Este seguro Ã”Ã©Â¼ por prazo determinada tendo a seguradora a faculdade de nao renavar a apdlice na data de vencimenta sem devolueao das prâ”œÂ®mins pagos nos termos da apdlice. Fm atendimenta @ lel 12,741)? informamos que incidem as aliquotas de 0.85% de PiS/Pasep e de 4% de COFINS sobre os premios de seguros/as contribuicâ”œÂ®es a planos de cardter previdenciâ”œÂ®rio/os pagamentos destinados a planos de capitalizardo, deduzidos do estabelecido em lenislacdo espectfica A falta de pagamenta de parcelas ou do prâ”œÂ®mio a vista, na data indicada no respective documento de cobranca, implicarâ”œÂ®automaticamente na suspensdo da cobertura que somente serâ”œÂ®reablitada a partir das 24 (vite E quatro) horas da data em que 0 sSegurado ov o estipulante retomar o pagamento do prâ”œÂ®mio. Decorrida o prazo estabelecida para pagamento, 0 seguro ficard automaticamente cancelado, independentemente de qualquer interpelagan judicial ov extrajudicial A FRAUDE CONTRA SEBUROS ECAIME, DENUNGIE (71)2259-17_OU 18 - WW. FENASES.ORE. BR BNP PARIBAS GG carpiF Hash sha256 da CCR: naci202420h8212Adie24ad7fecTA2hh77124157a2AhA7OfA 1 Ochth55155Ah2HA"},"suggestedFilename":"Contratos","ocrUsed":true,"chatGPTAnalysis":"8. Contratos"}	0.9	06 Contratos	\N	f	f	Contratos_WhatsApp_Image_2025_10_21_at_15_56_00__1_.pdf	10
61	5	12	WhatsApp Image 2025-10-21 at 15.56.00.jpeg	Contratos_WhatsApp_Image_2025_10_21_at_15_56_00.pdf	06 Contratos	35	image/jpeg	259860	ocr_completed	https://yrzlxuefbxbpfndcpfqz.supabase.co/storage/v1/object/public/documents/processed/06_Contratos_e53846af.pdf	ICATU Seguro de Acderes Pessais Premio PROPOSTADE CONTRATAGAO. 24/05/2025 14:15:43 Para uso da Seguradora [ Seguro: 53 Novo J LINÃ”Ã‡Ã– da proposta 202413670194 Dados da Apdlice Ny da apolice Estipulante | 82014503, | [BANCO VOTORANTIN S.A Qualificagâ”œÂ®o do proponente Nome completo Nome Social | MARIA JOSE DE LIMA {lh Sexo Data de nascimento CPF Nâ”¬â–‘ eNatureza doc. dentfcagaot Orgdo expeidor Cimasc. 1X] fem. | 09/08/1960 | |. 931.518.494-15 | |_9900%030433 SSP Profissdo Enderego residencial (Av. / Rua) Nimero Complemento ADMINISTRADOR {PV TIMBOZINHO \\ {7 7 mm Baio Cidade CEP UF DDD Ã”Ã‡Ã¶_Telefone | CENTRO | [ATALAIA _| {57690000 | [AL 82__| 987137630 Exmait Renda Nensal/Patrimdnio Esirado | ANDRESSASLVASOO1@GMALL COM ; | | 18000 00 4 - Se proponente estrangeiro, ulllzar o passaporte como documento de identificagdo. | 2 - A comunicagao entre seguradora e segurado se dara por e-mail, tendo 0 Ã”Ã‡Ã¿segurado a opg&o de retirar essa autorizagao a qualquer momento. Forma de cobranca Boleto bancario ] 100% custeado pelo Segurado [Prâ”œÂ®mio Unico Total R$ 680,35 {_ Garantia Basica Titular % [Capital Segurado (RS) (Ã”Ã‡Ã¶ Beneficio Tipo de Plano Ã”Ã‡Ã¿Valor do Sorteio (RS) [12 Morte Acidental 100 47,008,75 Ã”Ã‡Ã¿| [1 Sorteiot 1 Sorteio Mensal 153.078,75 A vigâ”œÂ®ncia do risco individual, bem como todos os direitos @ obrigagGes dela decorrentes, se inicia & 00:00 (zero) hora do dia 25/05/2025, desde que o prâ”œÂ®mio fenha sido pago. O periodo de vigâ”œÂ®ncia do seguro sera de 60 meses. Ã”Ã‡Ã¿As datas de inicio e fim de vigâ”œÂ®ncia serdo discriminadas no Certficado do Seguro. [3-0 valor do sorteio 6 bruto de impostos (25%) e esta sujeito @ tributacao com base na legislagao vigente. A vigâ”œÂ®ncia do sorteio seri a partir do mâ”œÂ®s subsequente da compra do titulo de capitalizacdo pela Icatu Seguros S.A. Dados dos Beneficiâ”œÂ®rios Para designagao de beneficiarios, preencha 0 formulario disponivel no site: hitpsÃ”Ã‡Ã–//portal.icatuseguros.com.briformularios, Os beneficiarios poderdo ser alterados a qualquet momento mediante envio de formulario de alteragao de beneficierios para 0 e-mail formularios@icatuseguros.com.br. Na ausâ”œÂ®ncia de indicagao de beneficidrios, ou se, pot qualquer motivo, nao prevalecer a indicagao feita, a indenizagdo sera paga nos termos da legislacdo vigente. Caso no sejam nado benefice, o capital sequadodeverd ser pagochservando a segue orem de indica de benefice: 4â”¬â–‘ - {00% 20 Conjugelcompanheiro(a) vivo - aquele que, ao tempo do sinistro,tiver relagdo de uniao estavel de fato com o proponentelsegurado 2-Na ausâ”œÂ®ncia do 1â”¬â–‘ indicado, pagar aos filhos vivos do proponentelsegurado, em partes iguals para cada um 3? - Na ausâ”œÂ®ncia dos 1â”¬â–‘ e 2â”¬â–‘ indicados, pagar aos pais vivos do proponente/segurado, em partes iguais para cada um por er amas emgesso da mina vriadesbscevo a ncato de benfdros ana on. sobre a ql ass nese ae excsa responsi spend ae ees quo 8 giao do cal sequdona oma por mim cada, Am ds, rele nape clei uno & possi ce sulsltuigdo a qualquer tempo dos beneficâ”œÂ®ros ora indicados acima. _Declaragoes do proponente Umma vez aprovada esta proposta pela Icatu Seguros S.A, delaro estar cents e de acordo que: 4. As coberturas do seguro vigorardo conforme definido no item Inicio de Vigâ”œÂ®ncia do Risoo Individual, constante no contrato em poder do Estipulante. [2 Este seguro â”œÂ® pot prazo determinado tendo a seguradora a faouldade de nâ”œÂ®o renovar a apdlice na data de vencimento, sem devolugdo dos prâ”œÂ®mios pagos nos termos da apdlice. Caso seguradora nao lenha mais interesse em renovar a apolice, esta comunicara sua decisâ”œÂ®o ao Estipulante, mediante aviso prâ”œÂ®vio, de no minimo, 60 (sessenta) dias quÃ”Ã‡Ã– antecedam o final de vigencia da apdlice.[3. Para os fins previstos nos atts, 774 Ã”Ã©Â¼ 801 do Codigo Civil, e com base no disposto no Art 2â”¬â–‘ da Resolugao CNSP Nâ”¬â–‘ 434/202 conoedo ao Estipulante da apdlice em questo o direto de agir em meu nome rio cumprimento de todas as clâ”œÂ®usulas e Condigoes Gerais e Particulares da referida apoliot devendo todas as comunicagdes e avisos referentes 20 contrato serem encaminhados diretamente aquele, que, para ta fim fica investido dos poderes de representagao. N entanto fica ressalvado que os poderes de representagao, ora coutorgados, no the dao direito a cancelar 0 seguro durante a vigâ”œÂ®ncia da apdtice, nem a realizar qualque alteragdo na apdlice que implique em Onus, dever ou redugdo dos meus direitos, salvo se obtiver a anuâ”œÂ®ncia expressa de % (trâ”œÂ®s quartos) do grupo segurado, proposta de Adesdo Seguro de Vida -3 VIAS- 1* SEGURADORA /2* CORRETOR /$* PROPONENTE Pagina 1/2 Hash eha?56 da CCR: Red392429691 Adedad7fec7A2bA771 Adfi7a22ReTOfat 1OchthS51559h2bR	272713	1	\N	2025-11-03 22:22:32.562	2025-11-03 22:22:32.562	{"documentType":"06 Contratos","confidence":0.9,"detectedInfo":{"ocrExtractedText":"ICATU Seguro de Acderes Pessais Premio PROPOSTADE CONTRATAGAO. 24/05/2025 14:15:43 Para uso da Seguradora [ Seguro: 53 Novo J LINÃ”Ã‡Ã– da proposta 202413670194 Dados da Apdlice Ny da apolice Estipulante | 82014503, | [BANCO VOTORANTIN S.A Qualificagâ”œÂ®o do proponente Nome completo Nome Social | MARIA JOSE DE LIMA {lh Sexo Data de nascimento CPF Nâ”¬â–‘ eNatureza doc. dentfcagaot Orgdo expeidor Cimasc. 1X] fem. | 09/08/1960 | |. 931.518.494-15 | |_9900%030433 SSP Profissdo Enderego residencial (Av. / Rua) Nimero Complemento ADMINISTRADOR {PV TIMBOZINHO \\\\ {7 7 mm Baio Cidade CEP UF DDD Ã”Ã‡Ã¶_Telefone | CENTRO | [ATALAIA _| {57690000 | [AL 82__| 987137630 Exmait Renda Nensal/Patrimdnio Esirado | ANDRESSASLVASOO1@GMALL COM ; | | 18000 00 4 - Se proponente estrangeiro, ulllzar o passaporte como documento de identificagdo. | 2 - A comunicagao entre seguradora e segurado se dara por e-mail, tendo 0 Ã”Ã‡Ã¿segurado a opg&o de retirar essa autorizagao a qualquer momento. Forma de cobranca Boleto bancario ] 100% custeado pelo Segurado [Prâ”œÂ®mio Unico Total R$ 680,35 {_ Garantia Basica Titular % [Capital Segurado (RS) (Ã”Ã‡Ã¶ Beneficio Tipo de Plano Ã”Ã‡Ã¿Valor do Sorteio (RS) [12 Morte Acidental 100 47,008,75 Ã”Ã‡Ã¿| [1 Sorteiot 1 Sorteio Mensal 153.078,75 A vigâ”œÂ®ncia do risco individual, bem como todos os direitos @ obrigagGes dela decorrentes, se inicia & 00:00 (zero) hora do dia 25/05/2025, desde que o prâ”œÂ®mio fenha sido pago. O periodo de vigâ”œÂ®ncia do seguro sera de 60 meses. Ã”Ã‡Ã¿As datas de inicio e fim de vigâ”œÂ®ncia serdo discriminadas no Certficado do Seguro. [3-0 valor do sorteio 6 bruto de impostos (25%) e esta sujeito @ tributacao com base na legislagao vigente. A vigâ”œÂ®ncia do sorteio seri a partir do mâ”œÂ®s subsequente da compra do titulo de capitalizacdo pela Icatu Seguros S.A. Dados dos Beneficiâ”œÂ®rios Para designagao de beneficiarios, preencha 0 formulario disponivel no site: hitpsÃ”Ã‡Ã–//portal.icatuseguros.com.briformularios, Os beneficiarios poderdo ser alterados a qualquet momento mediante envio de formulario de alteragao de beneficierios para 0 e-mail formularios@icatuseguros.com.br. Na ausâ”œÂ®ncia de indicagao de beneficidrios, ou se, pot qualquer motivo, nao prevalecer a indicagao feita, a indenizagdo sera paga nos termos da legislacdo vigente. Caso no sejam nado benefice, o capital sequadodeverd ser pagochservando a segue orem de indica de benefice: 4â”¬â–‘ - {00% 20 Conjugelcompanheiro(a) vivo - aquele que, ao tempo do sinistro,tiver relagdo de uniao estavel de fato com o proponentelsegurado 2-Na ausâ”œÂ®ncia do 1â”¬â–‘ indicado, pagar aos filhos vivos do proponentelsegurado, em partes iguals para cada um 3? - Na ausâ”œÂ®ncia dos 1â”¬â–‘ e 2â”¬â–‘ indicados, pagar aos pais vivos do proponente/segurado, em partes iguais para cada um por er amas emgesso da mina vriadesbscevo a ncato de benfdros ana on. sobre a ql ass nese ae excsa responsi spend ae ees quo 8 giao do cal sequdona oma por mim cada, Am ds, rele nape clei uno & possi ce sulsltuigdo a qualquer tempo dos beneficâ”œÂ®ros ora indicados acima. _Declaragoes do proponente Umma vez aprovada esta proposta pela Icatu Seguros S.A, delaro estar cents e de acordo que: 4. As coberturas do seguro vigorardo conforme definido no item Inicio de Vigâ”œÂ®ncia do Risoo Individual, constante no contrato em poder do Estipulante. [2 Este seguro â”œÂ® pot prazo determinado tendo a seguradora a faouldade de nâ”œÂ®o renovar a apdlice na data de vencimento, sem devolugdo dos prâ”œÂ®mios pagos nos termos da apdlice. Caso seguradora nao lenha mais interesse em renovar a apolice, esta comunicara sua decisâ”œÂ®o ao Estipulante, mediante aviso prâ”œÂ®vio, de no minimo, 60 (sessenta) dias quÃ”Ã‡Ã– antecedam o final de vigencia da apdlice.[3. Para os fins previstos nos atts, 774 Ã”Ã©Â¼ 801 do Codigo Civil, e com base no disposto no Art 2â”¬â–‘ da Resolugao CNSP Nâ”¬â–‘ 434/202 conoedo ao Estipulante da apdlice em questo o direto de agir em meu nome rio cumprimento de todas as clâ”œÂ®usulas e Condigoes Gerais e Particulares da referida apoliot devendo todas as comunicagdes e avisos referentes 20 contrato serem encaminhados diretamente aquele, que, para ta fim fica investido dos poderes de representagao. N entanto fica ressalvado que os poderes de representagao, ora coutorgados, no the dao direito a cancelar 0 seguro durante a vigâ”œÂ®ncia da apdtice, nem a realizar qualque alteragdo na apdlice que implique em Onus, dever ou redugdo dos meus direitos, salvo se obtiver a anuâ”œÂ®ncia expressa de % (trâ”œÂ®s quartos) do grupo segurado, proposta de Adesdo Seguro de Vida -3 VIAS- 1* SEGURADORA /2* CORRETOR /$* PROPONENTE Pagina 1/2 Hash eha?56 da CCR: Red392429691 Adedad7fec7A2bA771 Adfi7a22ReTOfat 1OchthS51559h2bR"},"suggestedFilename":"Contratos","ocrUsed":true,"chatGPTAnalysis":"8. Contratos"}	0.9	06 Contratos	\N	f	f	Contratos_WhatsApp_Image_2025_10_21_at_15_56_00.pdf	10
17	2	3	Declaraâ”œÂºâ”œÃºo de Hipossuficiâ”œÂ¬ncia.pdf	Declaraâ”œÂºâ”œÃºo_de_Hipossuficiâ”œÂ¬ncia_Declara__o_de_Hipossufici_ncia.pdf	05 Declaraâ”œÂºâ”œÃºo de Hipossuficiâ”œÂ¬ncia	1	application/pdf	91332	ocr_completed	https://yrzlxuefbxbpfndcpfqz.supabase.co/storage/v1/object/public/documents/processed/05_Declaracao_de_Hipossuficiencia_1fcfdb61.pdf	DECLARAGAO DE HIPOSSUFICIENCIA DECLARANTE: ROSIMEIRE ACIOLY ALBUQUERQUE, brasileira, inscrito (a) no CPF sob on. 333.164.654-72, residente e domiciliado na Rua da Palmeira, s/n, ao lado da igreja catdlica, Distrito St. Antâ”œÂ®nio, Zona Rural, Atalaia - AL. CEP:57690-000. Declaro que n&o posso suportar as despesas processuais decorrentes desta demanda sem prejuizo do meu proprio sustento e de minha familia, sendo, pois para fins de concessdo do beneficio da gratuidade de justiâ”¬Ã³a, nos termos da Lei n. 1.060/50, pobre no sentido legal da acepâ”¬Ã³ao da justica. Declaro ainda ter conhecimento das sang6es penais que estarei sujeito caso inveridica a declaragao prestada, sobretudo a disciplinada no art. 299 do Coâ”œÂ®digo Penal. Atalaia, 30 de Outubro de 2025. ROSIMEIRE ACIOLY ALBUQUERQUE DECLARANTE	91332	1	\N	2025-11-03 02:28:57.202	2025-11-03 02:28:57.202	{"documentType":"05 Declaraâ”œÂºâ”œÃºo de Hipossuficiâ”œÂ¬ncia","confidence":0.9,"detectedInfo":{"ocrExtractedText":"DECLARAGAO DE HIPOSSUFICIENCIA DECLARANTE: ROSIMEIRE ACIOLY ALBUQUERQUE, brasileira, inscrito (a) no CPF sob on. 333.164.654-72, residente e domiciliado na Rua da Palmeira, s/n, ao lado da igreja catdlica, Distrito St. Antâ”œÂ®nio, Zona Rural, Atalaia - AL. CEP:57690-000. Declaro que n&o posso suportar as despesas processuais decorrentes desta demanda sem prejuizo do meu proprio sustento e de minha familia, sendo, pois para fins de concessdo do beneficio da gratuidade de justiâ”¬Ã³a, nos termos da Lei n. 1.060/50, pobre no sentido legal da acepâ”¬Ã³ao da justica. Declaro ainda ter conhecimento das sang6es penais que estarei sujeito caso inveridica a declaragao prestada, sobretudo a disciplinada no art. 299 do Coâ”œÂ®digo Penal. Atalaia, 30 de Outubro de 2025. ROSIMEIRE ACIOLY ALBUQUERQUE DECLARANTE"},"suggestedFilename":"Declaraâ”œÂºâ”œÃºo de Hipossuficiâ”œÂ¬ncia","ocrUsed":true,"chatGPTAnalysis":"7. Declaraâ”œÂºâ”œÃºo de Hipossuficiâ”œÂ¬ncia"}	0.9	05 Declaraâ”œÂºâ”œÃºo de Hipossuficiâ”œÂ¬ncia	\N	f	f	Declaraâ”œÂºâ”œÃºo_de_Hipossuficiâ”œÂ¬ncia_Declara__o_de_Hipossufici_ncia.pdf	3
18	2	3	IMG-20251030-WA0010.jpg	07 ficha financeira.pdf	07 ficha financeira	2	image/jpeg	145470	ocr_completed	https://yrzlxuefbxbpfndcpfqz.supabase.co/storage/v1/object/public/documents/processed/07_ficha_financeira_0f4eb7b9.pdf	PREFEITURA MUNICIPAL DE ATALAIA 12.200.143/0001-26 1.21 - FICHA FINANCEIRA INDIVIDUAI INCIONARIO ~ 1028 ROSIMBIR OLY ALBUOUEROUE IT. FUNCIONARTO - Topo: FUNCIONARTO: SEXO. nino CARGO. .: PRO ENDEREGO... : LESOtgsend BAIRRO. SECRETARIA. ADMISSAo c.custo ONDAMENTAL, LOTAGAO. FRANCISCO DE ALBUQUERQUE PONTE: NASCIMENTO VINCULO: Es ) NATURAL... .: CPF RG : 482980 PIS/PASEP @. ADMISSAO: Ffetivo DEP. IRRF.: 0 DEP. SF: 0 REFERENCIA 3 12/2020 SITUAGKO..: ATzvi PROVENTOS OCORRENCIA oN TFICACAG INCORSORADA 70} 5.031, 78 100 - PROVENTOS 7.188, 27 - 13â”¬â–‘ SALARIO 0,00 â”œÂ® ? TOTAL OCORRENCTA: 12.220,05 DESCONTOS Ã”Ã‡Ã¿OCORRENCTA Eg FEV MAR ABR MAT ON Ea 260 Ser our nov EZ nâ”œÂ®crwo] 1.344, 344,20 1,344,201 10,80 1.710,80 1.710,80 0,00 540,11 1,540,111 1 1,540, 10 1,540, 10 0,00 301 Ã”Ã‡Ã¶ IRR 2.121,49 2,121,492 2,020,68 2.020,68 2.020, 68 0,00 # < â”¬â–‘ 0 1.006,35 ~ 13 ATALAIA PREV 0,00 0,00 4,00 9,00 0,00 0,00 0,00 0,0 9,00 0 0,00 2.244, 40 5 0,00 0,0 9,00 y o, o, 5 71,58 5.271,58 3.220,75 TOTAL OCORRENCTA: 5.005,80 5.005,80 5,005,789 1,58 5.271,58 17,491,63 17,491,63 17,492,63 17.491,63 17,491,63 17.491,63 17 4 17.492,64 15.440, 8: 6.948,47 6.948,47 6.948,47 6.948,47 6.948,47 6..949,47 6,948,456 6.948.468.9992	149731	1	\N	2025-11-03 02:29:02.16	2025-11-03 02:29:02.16	{"documentType":"07 ficha financeira","confidence":0.9,"detectedInfo":{"ocrExtractedText":"PREFEITURA MUNICIPAL DE ATALAIA 12.200.143/0001-26 1.21 - FICHA FINANCEIRA INDIVIDUAI INCIONARIO ~ 1028 ROSIMBIR OLY ALBUOUEROUE IT. FUNCIONARTO - Topo: FUNCIONARTO: SEXO. nino CARGO. .: PRO ENDEREGO... : LESOtgsend BAIRRO. SECRETARIA. ADMISSAo c.custo ONDAMENTAL, LOTAGAO. FRANCISCO DE ALBUQUERQUE PONTE: NASCIMENTO VINCULO: Es ) NATURAL... .: CPF RG : 482980 PIS/PASEP @. ADMISSAO: Ffetivo DEP. IRRF.: 0 DEP. SF: 0 REFERENCIA 3 12/2020 SITUAGKO..: ATzvi PROVENTOS OCORRENCIA oN TFICACAG INCORSORADA 70} 5.031, 78 100 - PROVENTOS 7.188, 27 - 13â”¬â–‘ SALARIO 0,00 â”œÂ® ? TOTAL OCORRENCTA: 12.220,05 DESCONTOS Ã”Ã‡Ã¿OCORRENCTA Eg FEV MAR ABR MAT ON Ea 260 Ser our nov EZ nâ”œÂ®crwo] 1.344, 344,20 1,344,201 10,80 1.710,80 1.710,80 0,00 540,11 1,540,111 1 1,540, 10 1,540, 10 0,00 301 Ã”Ã‡Ã¶ IRR 2.121,49 2,121,492 2,020,68 2.020,68 2.020, 68 0,00 # < â”¬â–‘ 0 1.006,35 ~ 13 ATALAIA PREV 0,00 0,00 4,00 9,00 0,00 0,00 0,00 0,0 9,00 0 0,00 2.244, 40 5 0,00 0,0 9,00 y o, o, 5 71,58 5.271,58 3.220,75 TOTAL OCORRENCTA: 5.005,80 5.005,80 5,005,789 1,58 5.271,58 17,491,63 17,491,63 17,492,63 17.491,63 17,491,63 17.491,63 17 4 17.492,64 15.440, 8: 6.948,47 6.948,47 6.948,47 6.948,47 6.948,47 6..949,47 6,948,456 6.948.468.9992","rg":"482980"},"suggestedFilename":"ficha financeira","ocrUsed":true,"chatGPTAnalysis":"9. Ficha Financeira"}	0.9	07 ficha financeira	\N	f	f	07 ficha financeira.pdf	3
21	4	11	IMG-20251030-WA0012.jpg	07 ficha financeira individual.pdf	07 ficha financeira individual	1	image/jpeg	285747	ocr_completed	https://yrzlxuefbxbpfndcpfqz.supabase.co/storage/v1/object/public/documents/processed/07_ficha_financeira_individual_0429bea6.pdf	PREFEITURA MUNICIPAL DE ATALAIA 12.200.147/0001-26 1,21 - FICHA FINANCEIRA INDIVIDUAL UNCIONARIO - 1028 ROSIM ACTOLY ALBUQUEROUE SIT. FUNCTONARTO = 7 FUNCIONARIO: 1028 ENDERECO. SECRETARIA.: SEC SEXO CARGO Weak BATRRO ADMISSKO C.cUSTO: FUNDER - 70% 10 FUNDAMEN LOTAGKO....: ESCOLA MU NASCIMENTO 1962 VINCULO i NATURAL....: ATALATA/AL CPF 164.654-72 BG 4 PIS/PASEP: 17023285219 1. ADMISSAO: Efetivo DEP. IRRF.: 0 DEP. SF: REFERENCIA.: 01/2017 8 12/201 SYTUACAO PROVENTOS Ã”Ã‡Ã¿OCORRENCTA Ey FEV WAR BR MAT oN Ea G0 Ser our nov, DE dâ”œÂ®crwo| wee 25670; 20 670 70,20 2 3 a o,00 pasconros oconsicaa nT ee a a i ss : 88, 88,19 9 88,19 48,19 aa,19 88,19 88,19 48,19 34g ~ 13 ATAIAIA PREV 9,00 0,00 2.0 : ce go. ~ 13 TRF 000,08 0,00 0 : Ã”Ã‡Ã¿ : ETC Teer 8769 TOTAL LiQuiDo: 6.494, 5.272, 38 Ã”Ã‡Ã¿ 1,3 5 EEE	177324	1	\N	2025-11-03 15:57:13.595	2025-11-03 15:57:13.595	{"documentType":"07 ficha financeira individual","confidence":0.9,"detectedInfo":{"ocrExtractedText":"PREFEITURA MUNICIPAL DE ATALAIA 12.200.147/0001-26 1,21 - FICHA FINANCEIRA INDIVIDUAL UNCIONARIO - 1028 ROSIM ACTOLY ALBUQUEROUE SIT. FUNCTONARTO = 7 FUNCIONARIO: 1028 ENDERECO. SECRETARIA.: SEC SEXO CARGO Weak BATRRO ADMISSKO C.cUSTO: FUNDER - 70% 10 FUNDAMEN LOTAGKO....: ESCOLA MU NASCIMENTO 1962 VINCULO i NATURAL....: ATALATA/AL CPF 164.654-72 BG 4 PIS/PASEP: 17023285219 1. ADMISSAO: Efetivo DEP. IRRF.: 0 DEP. SF: REFERENCIA.: 01/2017 8 12/201 SYTUACAO PROVENTOS Ã”Ã‡Ã¿OCORRENCTA Ey FEV WAR BR MAT oN Ea G0 Ser our nov, DE dâ”œÂ®crwo| wee 25670; 20 670 70,20 2 3 a o,00 pasconros oconsicaa nT ee a a i ss : 88, 88,19 9 88,19 48,19 aa,19 88,19 88,19 48,19 34g ~ 13 ATAIAIA PREV 9,00 0,00 2.0 : ce go. ~ 13 TRF 000,08 0,00 0 : Ã”Ã‡Ã¿ : ETC Teer 8769 TOTAL LiQuiDo: 6.494, 5.272, 38 Ã”Ã‡Ã¿ 1,3 5 EEE"},"suggestedFilename":"ficha financeira individual","ocrUsed":true,"chatGPTAnalysis":"9. Ficha Financeira Individual"}	0.9	07 ficha financeira individual	\N	f	f	07 ficha financeira individual.pdf	9
27	5	12	1. Procuraâ”œÂºâ”œÃºo - Antonio Jose.pdf	Procuraâ”œÂºâ”œÃºo_1__Procura__o___Antonio_Jose.pdf	04 Procuraâ”œÂºâ”œÃºo	1	application/pdf	128744	ocr_completed	https://yrzlxuefbxbpfndcpfqz.supabase.co/storage/v1/object/public/documents/processed/04_Procuracao_554a12f7.pdf	OUTORGANTE: JOSE ANTONIO DE LIMA, casado, aposentado(a), inscrito (a) no CPF sob o n. 347.333.704-82, residenta e domiciliado na (o) PV TIMBOZINHO, s/n, TIMBOZINHO, Atalaia-AL, CEP 57690-000. OUTORGADO (S) ANDERSON RICARDO BARROS SILVA - SOCIEDADE INDIVIDUAL DE ADVOCACIA, registrada na OAB/AL sob o n. 1262/2022, CNPJ n. 48.367.253/0001-24 e ANDERSON RICARDO BARROS SILVA, OAB/AL Nâ”¬â–‘ 12.803. Enderego constante no rodapeâ”œÂ® da pagina. a quem confere os poderes da clausula | os poderes especiais para transigir; desistir; ad judicia et extra, permitindo atuar em | firmar compromissos e/ou acordos, acolher todas fases do processo; propor contra | valores relacionados com 0 litigio, podendo, quem de direito as ag6es que se fizerem | por isso, receber e dar quitagdes, seja da necessarias, defendendo-o das | parte contraria ou de terceiros, relacionados contrarias, atinentes, conferindo, ainda, | com o objeto deste mandato; finnar aos outorgados; compromisso; assinar declaragao de hipossuficiâ”œÂ®ncia econdâ”œÂ®mica (CPC, art. 105); podendo agir em conjunto ou separadamente, inclusive substabelecer, no todo ou em parte, com ou sem reservas de poderes, _ Atalaia, 21 de outubro de 2026. _ K hy i A h \\ ant ra a Jose Antonio De Lima OUTORGANTE	128744	1	\N	2025-11-03 22:18:04.974	2025-11-03 22:18:04.974	{"documentType":"04 Procuraâ”œÂºâ”œÃºo","confidence":0.9,"detectedInfo":{"ocrExtractedText":"OUTORGANTE: JOSE ANTONIO DE LIMA, casado, aposentado(a), inscrito (a) no CPF sob o n. 347.333.704-82, residenta e domiciliado na (o) PV TIMBOZINHO, s/n, TIMBOZINHO, Atalaia-AL, CEP 57690-000. OUTORGADO (S) ANDERSON RICARDO BARROS SILVA - SOCIEDADE INDIVIDUAL DE ADVOCACIA, registrada na OAB/AL sob o n. 1262/2022, CNPJ n. 48.367.253/0001-24 e ANDERSON RICARDO BARROS SILVA, OAB/AL Nâ”¬â–‘ 12.803. Enderego constante no rodapeâ”œÂ® da pagina. a quem confere os poderes da clausula | os poderes especiais para transigir; desistir; ad judicia et extra, permitindo atuar em | firmar compromissos e/ou acordos, acolher todas fases do processo; propor contra | valores relacionados com 0 litigio, podendo, quem de direito as ag6es que se fizerem | por isso, receber e dar quitagdes, seja da necessarias, defendendo-o das | parte contraria ou de terceiros, relacionados contrarias, atinentes, conferindo, ainda, | com o objeto deste mandato; finnar aos outorgados; compromisso; assinar declaragao de hipossuficiâ”œÂ®ncia econdâ”œÂ®mica (CPC, art. 105); podendo agir em conjunto ou separadamente, inclusive substabelecer, no todo ou em parte, com ou sem reservas de poderes, _ Atalaia, 21 de outubro de 2026. _ K hy i A h \\\\ ant ra a Jose Antonio De Lima OUTORGANTE"},"suggestedFilename":"Procuraâ”œÂºâ”œÃºo","ocrUsed":true,"chatGPTAnalysis":"6. Procuraâ”œÂºâ”œÃºo"}	0.9	04 Procuraâ”œÂºâ”œÃºo	\N	f	f	Procuraâ”œÂºâ”œÃºo_1__Procura__o___Antonio_Jose.pdf	10
28	5	12	2. Procuraâ”œÂºâ”œÃºo - Maria Jose.pdf	Procuraâ”œÂºâ”œÃºo_2__Procura__o___Maria_Jose.pdf	04 Procuraâ”œÂºâ”œÃºo	2	application/pdf	196267	ocr_completed	https://yrzlxuefbxbpfndcpfqz.supabase.co/storage/v1/object/public/documents/processed/04_Procuracao_f9dc28d9.pdf	PROCURACAO M Pessoa Fisica RAKBUIS & ALVES o OUTORGANTE: iÃ”Ã‡Ã¶ Maria Jose De Lima, uniao estavel, aposentado(a), inscrito (a) no CPF sob o n. 331.518.494-15, e-mail: , residente e domiciliado na (0) LT Terra de Antares, 53, Antares, Maceid-AL, CEP 57048-714. a OUTORGADO (S) ANDERSON RICARDO BARROS SILVA Ã”Ã‡Ã¶- SOCIEDADE INDIVIDUAL DE ADVOCACIA, registrada na OAB/AL sob o n. 1262/2022, CNPJ n. 48.367.253/0001- 24 e ANDERSON RICARDO BARROS SILVA, OAB/AL Nâ”¬â–‘ 12.803. Enderego constante no rodapâ”œÂ® da pagina. PODERES GERAIS a quem confere os poderes da clausula | os poderes especiais para transigir; desistir; ad judicia et extra, permitindo atuar em | firmar compromissos e/ou acordos, acolher todas fases do processo; propor contra | valores relacionados com 0 litigio, podendo, quem de direito as agdes que se fizerem | por isso, receber e dar quitagdes, seja da necessarias, defendendo-o das | parte contraria ou de terceiros, relacionados contrarias, atinentes, conferindo, ainda, | com o objeto deste mandato; _firmar aos outorgados; compromisso; assinar declaragao de hipossuficiâ”œÂ®ncia econdmica (CPC, art. 105); podendo agir em conjunto ou separadamente, inclusive substabelecer, no todo ou em parte, com ou sem reservas de poderes; Atalaia, 28 de outubro de 2025. Maria Jose De Lima OUTORGANTE Digitally signed by SEDEP. SERVICO DE ENTREGA DE PUBLIGACO:37535259000147 Date: 2025.10.28 10:46:27 -04:00 Bia Zacariac da Azayadg 399 Centro Maceid-A Av. Fredson Amorim, s/n, Josâ”œÂ® Paulino www.barrosealvesadvogados.com.br Guid: foef59a9-b3da-49a8-9ad9-65406cd94d1a Atalaia-AL contato@barrosealvesadvogados.com.br (82) 9 9602-3839 fo= Datas e horarios em GMT -04:00 Campo Grande ota. Log gerado em 28 de outubro de 2025. Procuracao - Maria Jose.pdf Documento numero: fbef59a9-b3da-49a8-9ad9-65406cd94d1a Hash do documento original (SHA256): aDkvRS/N1p5buAJ7UIGAxpiJxuh7 YrXT5cqMyMXdxul=aDkvRS/N1p5buAJ7UIGAxpiJdxuh7YrxT5cqMyMxdxul= Assinaturas Maria Jose De Lima CPF: 331.518.494-15 Assinou em: 28 out 2025 as 10:43:18 IP: 45.161.74.175 Geolocalizagao: -9.5765717, -35.7407746 Dispositivo: Mozilla/5.0 (Linux; Android 10; K) AppleWebkKit/537.36 (KHTML, like Gecko) SamsungBrowser/28.0 Chrome/130.0.0.0 Mobile Safari/537.36 Emitido por Sistema FAZ. Log 28 out 2025, 10:32:54 Operador com email administrativo@barrosealvesadvogados.com.br criou este documento numero fbef59a9-b3da-49a8-9ad9-65406cd94d1a. Finalizagao automatica apâ”œÂ®s a ultima assinatura: habilitada. Idioma: Portuguâ”œÂ®s brasileiro. 28 out 2025, 10:43:18 Assinado por Maria Jose De Lima, CPF: 331.518.494-15, Data de nascimento: 09/08/1960. Pontos de autenticagao: evia whatsapp, Token: 404055, Telefone: 82987137630, IP: 45.161.74.175. 28 out 2025, 10:46:27 Processo de assinatura concluido para o documento numero fbef59a9-b3da-49a8-9ad9- 65406cd94d 1a. iCP Este Log â”œÂ® exclusivo e deve ser considerado parte do documento nâ”¬â–‘ foef59a9-b3da-49a8-9ad9-65406cd94d1a, com Brasil os efeitos prescritos nos Termos de Uso/Termos de Adesao do Sistema FAZ no momento da solicitagado, disponivel ak ~ em http://privacidade.sedep.com.br/politica-privacidade. Para validar este documento escaneie 0 QRCode usando https://validar.iti.gov.br ou acesse https://validador.faz.adv.br e siga as instrugdes. As assinaturas digitais e eletrâ”œÂ®nicas tâ”œÂ®m validade juridica prevista na Medida Provisâ”œÂ®ria nâ”¬â–‘. 2200-2 / 2001 QFYU0C6W ame foef59a9-b3da-49a8-9ad9-65406cd94d1a Pagina 1 de 1	196267	1	\N	2025-11-03 22:18:18.2	2025-11-03 22:18:18.2	{"documentType":"04 Procuraâ”œÂºâ”œÃºo","confidence":0.9,"detectedInfo":{"ocrExtractedText":"PROCURACAO M Pessoa Fisica RAKBUIS & ALVES o OUTORGANTE: iÃ”Ã‡Ã¶ Maria Jose De Lima, uniao estavel, aposentado(a), inscrito (a) no CPF sob o n. 331.518.494-15, e-mail: , residente e domiciliado na (0) LT Terra de Antares, 53, Antares, Maceid-AL, CEP 57048-714. a OUTORGADO (S) ANDERSON RICARDO BARROS SILVA Ã”Ã‡Ã¶- SOCIEDADE INDIVIDUAL DE ADVOCACIA, registrada na OAB/AL sob o n. 1262/2022, CNPJ n. 48.367.253/0001- 24 e ANDERSON RICARDO BARROS SILVA, OAB/AL Nâ”¬â–‘ 12.803. Enderego constante no rodapâ”œÂ® da pagina. PODERES GERAIS a quem confere os poderes da clausula | os poderes especiais para transigir; desistir; ad judicia et extra, permitindo atuar em | firmar compromissos e/ou acordos, acolher todas fases do processo; propor contra | valores relacionados com 0 litigio, podendo, quem de direito as agdes que se fizerem | por isso, receber e dar quitagdes, seja da necessarias, defendendo-o das | parte contraria ou de terceiros, relacionados contrarias, atinentes, conferindo, ainda, | com o objeto deste mandato; _firmar aos outorgados; compromisso; assinar declaragao de hipossuficiâ”œÂ®ncia econdmica (CPC, art. 105); podendo agir em conjunto ou separadamente, inclusive substabelecer, no todo ou em parte, com ou sem reservas de poderes; Atalaia, 28 de outubro de 2025. Maria Jose De Lima OUTORGANTE Digitally signed by SEDEP. SERVICO DE ENTREGA DE PUBLIGACO:37535259000147 Date: 2025.10.28 10:46:27 -04:00 Bia Zacariac da Azayadg 399 Centro Maceid-A Av. Fredson Amorim, s/n, Josâ”œÂ® Paulino www.barrosealvesadvogados.com.br Guid: foef59a9-b3da-49a8-9ad9-65406cd94d1a Atalaia-AL contato@barrosealvesadvogados.com.br (82) 9 9602-3839 fo= Datas e horarios em GMT -04:00 Campo Grande ota. Log gerado em 28 de outubro de 2025. Procuracao - Maria Jose.pdf Documento numero: fbef59a9-b3da-49a8-9ad9-65406cd94d1a Hash do documento original (SHA256): aDkvRS/N1p5buAJ7UIGAxpiJxuh7 YrXT5cqMyMXdxul=aDkvRS/N1p5buAJ7UIGAxpiJdxuh7YrxT5cqMyMxdxul= Assinaturas Maria Jose De Lima CPF: 331.518.494-15 Assinou em: 28 out 2025 as 10:43:18 IP: 45.161.74.175 Geolocalizagao: -9.5765717, -35.7407746 Dispositivo: Mozilla/5.0 (Linux; Android 10; K) AppleWebkKit/537.36 (KHTML, like Gecko) SamsungBrowser/28.0 Chrome/130.0.0.0 Mobile Safari/537.36 Emitido por Sistema FAZ. Log 28 out 2025, 10:32:54 Operador com email administrativo@barrosealvesadvogados.com.br criou este documento numero fbef59a9-b3da-49a8-9ad9-65406cd94d1a. Finalizagao automatica apâ”œÂ®s a ultima assinatura: habilitada. Idioma: Portuguâ”œÂ®s brasileiro. 28 out 2025, 10:43:18 Assinado por Maria Jose De Lima, CPF: 331.518.494-15, Data de nascimento: 09/08/1960. Pontos de autenticagao: evia whatsapp, Token: 404055, Telefone: 82987137630, IP: 45.161.74.175. 28 out 2025, 10:46:27 Processo de assinatura concluido para o documento numero fbef59a9-b3da-49a8-9ad9- 65406cd94d 1a. iCP Este Log â”œÂ® exclusivo e deve ser considerado parte do documento nâ”¬â–‘ foef59a9-b3da-49a8-9ad9-65406cd94d1a, com Brasil os efeitos prescritos nos Termos de Uso/Termos de Adesao do Sistema FAZ no momento da solicitagado, disponivel ak ~ em http://privacidade.sedep.com.br/politica-privacidade. Para validar este documento escaneie 0 QRCode usando https://validar.iti.gov.br ou acesse https://validador.faz.adv.br e siga as instrugdes. As assinaturas digitais e eletrâ”œÂ®nicas tâ”œÂ®m validade juridica prevista na Medida Provisâ”œÂ®ria nâ”¬â–‘. 2200-2 / 2001 QFYU0C6W ame foef59a9-b3da-49a8-9ad9-65406cd94d1a Pagina 1 de 1","cpf":"331.518.494-15"},"suggestedFilename":"Procuraâ”œÂºâ”œÃºo","ocrUsed":true,"chatGPTAnalysis":"6. Procuraâ”œÂºâ”œÃºo"}	0.9	04 Procuraâ”œÂºâ”œÃºo	\N	f	f	Procuraâ”œÂºâ”œÃºo_2__Procura__o___Maria_Jose.pdf	10
29	5	12	03 Comprovante de Residâ”œÂ¬ncia.pdf	Comprovante_de_Residâ”œÂ¬ncia_03_Comprovante_de_Resid_ncia.pdf	03 Comprovante de Residâ”œÂ¬ncia	3	application/pdf	68595	ocr_completed	https://yrzlxuefbxbpfndcpfqz.supabase.co/storage/v1/object/public/documents/processed/03_Comprovante_de_Residencia_ee98368e.pdf	DANFSE - DOCUMENTO AUXILIAR DA NOTA FISCAL DE ENERGIA ELETRICA ELETRONICA . . . . . 2? Via . Equatorial Alagoas Disitribuidora de Energia S.A. Pagina 1/1 nnatanial Ã”Ã‡Ã¶cypy. 12.272.084/0001-00 | Insc. Estadual: 24.007.177-8 ehebtert bat el Av. Fernandes Lima, 3349 Gruta de Lourdes - Maceiâ”œÂ® - AL CEP: 57.052-902 Classificagao: Resid. Baixa Renda Tipo de Fornecimento: MONOFASICO | Tarifa Social de Energia Elâ”œÂ®trica criada pela Lei 10.438/02 Tensao Nominal Disp: 220V = Lim Min: 202 V_Ã”Ã‡Ã¶__Lim Max: 231 V Data das | Leitura Anterior Leitura Atual Nâ”¬â–‘ de Dias |} Proxima Leitura JOSE ANTONIO DE LIMA Leituras 14/08/2025 13/09/2025 30 14/10/2025 INSTALAGAO: 6678823 CPF: ***.333.70*-** PV TIMBOZINHO , S/N , CEP: 57690-000 TIMBOZINHO - ATALAIA - AL Parceiro de Negocio 676829 Conta Contrato 6678823 NOTA FISCAL Nâ”¬â–‘ 057573574 - SERIE 000 / DATA DE EMISSAO: 13/09/2025 Consulte pela Chave de Acesso em: https://dfe-portal.svrs.rs.gov. br/NF3E/Consulta chave de acesso: 272509 12272084000100660000575735742025456698 Protocolo de autorizagao: 327250001 1968853 - 13/09/2025 as 16:07:15 Conta Mâ”œÂ®s Vencimento Total a Pagar 09/2025 22/09/2025 R$ 0,00 INFORMACOES PARA O CLIENTE @ A tarifa na sua conta de luz agora â”œÂ® zero para consumo atâ”œÂ® 80kWh, MP 1.300/25 do Governo Federal. Acesse: gov.br/luzdopovo â”¬Ã³ Periodos: Band. Tarif.: Vermelha : 15/08 - 13/09 @ Conforme REN 1095/24 ANEEL, a partir de 01/01/26 o numero da UC sera padronizado em todo pais, sendo composto por uma sequâ”œÂ®ncia atribuida pela distribuidora + câ”œÂ®d da distribuidora + digitos verificadores. Mais informag6es nos canais de atendimento. # BENEF. TAR. SOCIAL RES 1000/21 R$ 61,94 Itens de Fatura Quant. Prego Unit.(R$) Tarifa PIS/ ICMS Valor(R$) Tributo Base(R$) Aliquota(%) Ã”Ã‡Ã¶ Valor(R$) com Tributos _Unit.(R$) COFINS(R$) (R$) ioMs 0,00 0,00 0,00 Consumo (kWh) 80 0,000000 0,000000 0,00 0,00 0,00 PIS 70,75 0,4646 0,33 Consumo (kWh) 9 0,713333 0,695410 0,17 0,00 6,42 COFINS 70,75 2,1515 1,53 Beneficio Tarifario Bruto 1,67 0,00 63,61 Adicional Bandeira 0,02 0,00 0,72 ITENS FINANCEIROS SET/24 Beneficio Tarifario Liquido 61,94- OUT/24 Bonus ITAIPU art. 21 Lei 10.438/2002 3,13- Cc NOV/24 Valor transf. prox. Fatura 5,68- 4 DEZ/24 S| JAN/25 | FEW/25 O| MAR/25 ABR/25 | w| MAW25 h | JUN/25 JUL/25 AGO/25 SET/25 ] Ativo Medidor Grandeza Posto Horatio | Leitura | Leitura | Const. Consumo Reservado ao Fisco Anterior Atual Medidor 01644798 Consumo) ATIVO TOTAL 12.522 12.611 1,00 89 kWh A5F2.C04C.9519.8545.B34C.7018.DD50.DCCC Resolugao ANEEL Apresentagao Nâ”¬â–‘ do Programa Social 3450/25 13/09/2025 REAVISO DE VENCIMENTO CENTRAL DE ATENDIMENTO hintaan neh ag LIGUE GRATIS 0800 082 0196 de segunda a sexta, das Gh ds 16h, ATENDIMENTO GRATUITO 24 H ARSAL: 0800 727 0167 Ligacâ”œÂ®o gratuita de telefones fixos. conossa ste: warwaquotshlenergia come Glequatorialal @Gequatorialal OeequatorialAL | Agâ”œÂ®ncia Nacional de Energia Elâ”œÂ®trica (ANEEL) 167 LigegSo gratuita de telefone fixes â”¬Ã³ md DIREITOS Edireito do consumidor ou da central geradora de solicitar & distribuidora o detalhamento da apuragao dos indicadores DIC, FIC, DMIC â”¬Ã³ DICRI a qualquer tempo. E direito do consumidor ou da central geradora de receber uma compensacao, caso sejam violados os limites de continuidade individuais relatives 4 unidade consumidora ou central geradora. O nosso Whatsapp, e fale com a Clara, para: + Informar falta de energia El, + Pedircâ”œÂ®digos de barras para pagamento â”¬Â½ Solicitar religacao () + Pedir segunda via da fatura E acesse 0 nosso site e baixne o nosso app, para: â”¬Â½ Solicitar troca de titularldade + Cadaitra de Tarifa Social Baixa Renda (82) 2126-9200 equatorialenergia.com.br Nome do Cliente: C.C: Unidade de Leitura: Competâ”œÂ®ncia: Vencimento: Valor cobrado (R$): JOSE ANTONIO DE LIMA 6678823 ATO9B015 09/2025 0,00 DV / CONTA DE DEVOLUGAO. VALIDA SOMENTE COMO DEMOSTRATIVO. NAO RECEBER	68595	1	\N	2025-11-03 22:18:27.473	2025-11-03 22:18:27.473	{"documentType":"03 Comprovante de Residâ”œÂ¬ncia","confidence":0.9,"detectedInfo":{"ocrExtractedText":"DANFSE - DOCUMENTO AUXILIAR DA NOTA FISCAL DE ENERGIA ELETRICA ELETRONICA . . . . . 2? Via . Equatorial Alagoas Disitribuidora de Energia S.A. Pagina 1/1 nnatanial Ã”Ã‡Ã¶cypy. 12.272.084/0001-00 | Insc. Estadual: 24.007.177-8 ehebtert bat el Av. Fernandes Lima, 3349 Gruta de Lourdes - Maceiâ”œÂ® - AL CEP: 57.052-902 Classificagao: Resid. Baixa Renda Tipo de Fornecimento: MONOFASICO | Tarifa Social de Energia Elâ”œÂ®trica criada pela Lei 10.438/02 Tensao Nominal Disp: 220V = Lim Min: 202 V_Ã”Ã‡Ã¶__Lim Max: 231 V Data das | Leitura Anterior Leitura Atual Nâ”¬â–‘ de Dias |} Proxima Leitura JOSE ANTONIO DE LIMA Leituras 14/08/2025 13/09/2025 30 14/10/2025 INSTALAGAO: 6678823 CPF: ***.333.70*-** PV TIMBOZINHO , S/N , CEP: 57690-000 TIMBOZINHO - ATALAIA - AL Parceiro de Negocio 676829 Conta Contrato 6678823 NOTA FISCAL Nâ”¬â–‘ 057573574 - SERIE 000 / DATA DE EMISSAO: 13/09/2025 Consulte pela Chave de Acesso em: https://dfe-portal.svrs.rs.gov. br/NF3E/Consulta chave de acesso: 272509 12272084000100660000575735742025456698 Protocolo de autorizagao: 327250001 1968853 - 13/09/2025 as 16:07:15 Conta Mâ”œÂ®s Vencimento Total a Pagar 09/2025 22/09/2025 R$ 0,00 INFORMACOES PARA O CLIENTE @ A tarifa na sua conta de luz agora â”œÂ® zero para consumo atâ”œÂ® 80kWh, MP 1.300/25 do Governo Federal. Acesse: gov.br/luzdopovo â”¬Ã³ Periodos: Band. Tarif.: Vermelha : 15/08 - 13/09 @ Conforme REN 1095/24 ANEEL, a partir de 01/01/26 o numero da UC sera padronizado em todo pais, sendo composto por uma sequâ”œÂ®ncia atribuida pela distribuidora + câ”œÂ®d da distribuidora + digitos verificadores. Mais informag6es nos canais de atendimento. # BENEF. TAR. SOCIAL RES 1000/21 R$ 61,94 Itens de Fatura Quant. Prego Unit.(R$) Tarifa PIS/ ICMS Valor(R$) Tributo Base(R$) Aliquota(%) Ã”Ã‡Ã¶ Valor(R$) com Tributos _Unit.(R$) COFINS(R$) (R$) ioMs 0,00 0,00 0,00 Consumo (kWh) 80 0,000000 0,000000 0,00 0,00 0,00 PIS 70,75 0,4646 0,33 Consumo (kWh) 9 0,713333 0,695410 0,17 0,00 6,42 COFINS 70,75 2,1515 1,53 Beneficio Tarifario Bruto 1,67 0,00 63,61 Adicional Bandeira 0,02 0,00 0,72 ITENS FINANCEIROS SET/24 Beneficio Tarifario Liquido 61,94- OUT/24 Bonus ITAIPU art. 21 Lei 10.438/2002 3,13- Cc NOV/24 Valor transf. prox. Fatura 5,68- 4 DEZ/24 S| JAN/25 | FEW/25 O| MAR/25 ABR/25 | w| MAW25 h | JUN/25 JUL/25 AGO/25 SET/25 ] Ativo Medidor Grandeza Posto Horatio | Leitura | Leitura | Const. Consumo Reservado ao Fisco Anterior Atual Medidor 01644798 Consumo) ATIVO TOTAL 12.522 12.611 1,00 89 kWh A5F2.C04C.9519.8545.B34C.7018.DD50.DCCC Resolugao ANEEL Apresentagao Nâ”¬â–‘ do Programa Social 3450/25 13/09/2025 REAVISO DE VENCIMENTO CENTRAL DE ATENDIMENTO hintaan neh ag LIGUE GRATIS 0800 082 0196 de segunda a sexta, das Gh ds 16h, ATENDIMENTO GRATUITO 24 H ARSAL: 0800 727 0167 Ligacâ”œÂ®o gratuita de telefones fixos. conossa ste: warwaquotshlenergia come Glequatorialal @Gequatorialal OeequatorialAL | Agâ”œÂ®ncia Nacional de Energia Elâ”œÂ®trica (ANEEL) 167 LigegSo gratuita de telefone fixes â”¬Ã³ md DIREITOS Edireito do consumidor ou da central geradora de solicitar & distribuidora o detalhamento da apuragao dos indicadores DIC, FIC, DMIC â”¬Ã³ DICRI a qualquer tempo. E direito do consumidor ou da central geradora de receber uma compensacao, caso sejam violados os limites de continuidade individuais relatives 4 unidade consumidora ou central geradora. O nosso Whatsapp, e fale com a Clara, para: + Informar falta de energia El, + Pedircâ”œÂ®digos de barras para pagamento â”¬Â½ Solicitar religacao () + Pedir segunda via da fatura E acesse 0 nosso site e baixne o nosso app, para: â”¬Â½ Solicitar troca de titularldade + Cadaitra de Tarifa Social Baixa Renda (82) 2126-9200 equatorialenergia.com.br Nome do Cliente: C.C: Unidade de Leitura: Competâ”œÂ®ncia: Vencimento: Valor cobrado (R$): JOSE ANTONIO DE LIMA 6678823 ATO9B015 09/2025 0,00 DV / CONTA DE DEVOLUGAO. VALIDA SOMENTE COMO DEMOSTRATIVO. NAO RECEBER"},"suggestedFilename":"Comprovante de Residâ”œÂ¬ncia","ocrUsed":true,"chatGPTAnalysis":"5. Comprovante de Residâ”œÂ¬ncia"}	0.9	03 Comprovante de Residâ”œÂ¬ncia	\N	f	f	Comprovante_de_Residâ”œÂ¬ncia_03_Comprovante_de_Resid_ncia.pdf	10
30	5	12	3. Declaraâ”œÂºâ”œÃºo de hipossuficiâ”œÂ¬ncia - Antonio Jose.pdf	Declaraâ”œÂºâ”œÃºo_de_Hipossuficiâ”œÂ¬ncia_3__Declara__o_de_hipossufici_ncia___Antonio_Jose.pdf	05 Declaraâ”œÂºâ”œÃºo de Hipossuficiâ”œÂ¬ncia	4	application/pdf	91511	ocr_completed	https://yrzlxuefbxbpfndcpfqz.supabase.co/storage/v1/object/public/documents/processed/05_Declaracao_de_Hipossuficiencia_b6ca538b.pdf	DECLARAGAO DE HIPOSSUFICIENCIA DECLARANTE: JOSE ANTONIO DE LIMA, casado, aposentado(a), inscrito (a) no CPF sob on. 347.333,704-82, residente e domiciliado na (0) PV TIMBOZINHO, TIMBOZINHO, Atalaia-AL, CEP 57690-000. Declaro que nfo posso suportar as despesas processuais decorrentes desta demanda sem prejuizo do meu prâ”œÂ®prio sustento e de minha familia, sendo, pois para fins de concessdo do beneficio da gratuidade de justiga, nos termos da Lei n. 1.060/50, pobre no sentido legal da acepcao da justicâ”¬Ã³a. Declaro ainda ter conhecimento das sancgdes penais que estarei sujeito caso inveridica a declaracgdo prestada, sobretudo a disciplinada no art. 299 do Câ”œÂ®digo Penal. Atalaia, 21 de outubro de 2025. Jose Antonio De Lima DECLARANTE	91511	1	\N	2025-11-03 22:18:37.982	2025-11-03 22:18:37.982	{"documentType":"05 Declaraâ”œÂºâ”œÃºo de Hipossuficiâ”œÂ¬ncia","confidence":0.9,"detectedInfo":{"ocrExtractedText":"DECLARAGAO DE HIPOSSUFICIENCIA DECLARANTE: JOSE ANTONIO DE LIMA, casado, aposentado(a), inscrito (a) no CPF sob on. 347.333,704-82, residente e domiciliado na (0) PV TIMBOZINHO, TIMBOZINHO, Atalaia-AL, CEP 57690-000. Declaro que nfo posso suportar as despesas processuais decorrentes desta demanda sem prejuizo do meu prâ”œÂ®prio sustento e de minha familia, sendo, pois para fins de concessdo do beneficio da gratuidade de justiga, nos termos da Lei n. 1.060/50, pobre no sentido legal da acepcao da justicâ”¬Ã³a. Declaro ainda ter conhecimento das sancgdes penais que estarei sujeito caso inveridica a declaracgdo prestada, sobretudo a disciplinada no art. 299 do Câ”œÂ®digo Penal. Atalaia, 21 de outubro de 2025. Jose Antonio De Lima DECLARANTE"},"suggestedFilename":"Declaraâ”œÂºâ”œÃºo de Hipossuficiâ”œÂ¬ncia","ocrUsed":true,"chatGPTAnalysis":"7. Declaraâ”œÂºâ”œÃºo de Hipossuficiâ”œÂ¬ncia"}	0.9	05 Declaraâ”œÂºâ”œÃºo de Hipossuficiâ”œÂ¬ncia	\N	f	f	Declaraâ”œÂºâ”œÃºo_de_Hipossuficiâ”œÂ¬ncia_3__Declara__o_de_hipossufici_ncia___Antonio_Jose.pdf	10
31	5	12	4. Declaraâ”œÂºâ”œÃºo de hipossuficiâ”œÂ¬ncia - Maria Jose.pdf	Declaraâ”œÂºâ”œÃºo_de_Hipossuficiâ”œÂ¬ncia_4__Declara__o_de_hipossufici_ncia___Maria_Jose.pdf	05 Declaraâ”œÂºâ”œÃºo de Hipossuficiâ”œÂ¬ncia	5	application/pdf	117916	ocr_completed	https://yrzlxuefbxbpfndcpfqz.supabase.co/storage/v1/object/public/documents/processed/05_Declaracao_de_Hipossuficiencia_57d3ae8c.pdf	DECLARAGAO DE HIPOSSUFICIENCIA DECLARANTE: Maria Jose De Lima, uniao estavel, aposentado(a), inscrito (a) no CPF sob o n. 331.518.494-15, e-mail: , residente e domiciliado na (0) LT Terra de Antares, Antares, Maceiâ”œÂ®-AL, CEP 57048-714. Declaro que nao posso suportar as despesas processuais decorrentes desta demanda sem prejuizo do meu prâ”œÂ®prio sustento e de minha familia, sendo, pois para fins de concessao do beneficio da gratuidade de justiga, nos termos da Lei n. 1.060/50, pobre no sentido legal da acepcâ”¬Ã³ao da justiga. Declaro ainda ter conhecimento das sangdes penais que estarei sujeito caso inveridica a declaragao prestada, sobretudo a disciplinada no art. 299 do Câ”œÂ®digo Penal. Atalaia, 28 de outubro de 2025. Maria Jose De Lima DECLARANTE Digitally signed by SEDEP. SERVICO DE ENTREGA DE DESPACHOS E PUBLICACO:37535259000147 Date: 2025.10.28 11:00:23 -04:00 Guid: 42969925-8066-4fab-9de0-f5e6f3cfd97b fo= Datas e horarios em GMT -04:00 Campo Grande ota. Log gerado em 28 de outubro de 2025. Declaracao de hipossuficiâ”œÂ®ncia - Maria Jose.pdf Documento numero: 42969925-8066-4fab-9de0-f5e6f3cid97b Hash do documento original (SHA256): XWr5NxVdDXGjc4WEBAAslfsez7eV4pLfSxxEttMpnf4=xwr 5NxVdDxXGjc4WEBAAs1fsez7eV4pLâ”¬ÃºSxxEttMpnf4= Assinaturas Maria Jose De Lima CPF: 331.518.494-15 Assinou em: 28 out 2025 as 10:57:42 IP: 45.161.74.175 Geolocalizagao: -9.5765815, -35.7408923 Dispositivo: Mozilla/5.0 (Linux; Android 10; K) AppleWebkKit/537.36 (KHTML, like Gecko) SamsungBrowser/28.0 Chrome/130.0.0.0 Mobile Safari/537.36 Emitido por Sistema FAZ. Log 28 out 2025, 10:50:39 Operador com email administrativo@barrosealvesadvogados.com.br criou este documento numero 42969925-8066-4fab-9de0-f5e6f3cfd97b. Finalizagdo automatica apâ”œÂ®s a ultima assinatura: habilitada. Idioma: Portuguâ”œÂ®s brasileiro. 28 out 2025, 10:57:42 Assinado por Maria Jose De Lima, CPF: 331.518.494-15, Data de nascimento: 09/08/1960. Pontos de autenticagao: evia whatsapp, Token: 232140, Telefone: 82987137630, IP: 45.161.74.175. 28 out 2025, 11:00:22 Processo de assinatura concluido para o documento numero 42969925-8066-4fab-9de0- f5e6f3cfd97b. iCP Este Log â”œÂ® exclusivo e deve ser considerado parte do documento nâ”¬â–‘ 42969925-8066-4fab-9de0-f5e6f3cfd97b, com os Brasil efeitos prescritos nos Termos de Uso/Termos de Adesao do Sistema FAZ no momento da solicitagao, disponivel em ak ~ http://privacidade.sedep.com.br/politica-privacidade. Para validar este documento escaneie 0 QRCode usando https://validar.iti.gov.br ou acesse https://validador.faz.adv.br e siga as instrugdes. As assinaturas digitais e eletrâ”œÂ®nicas tâ”œÂ®m validade juridica prevista na Medida Provisâ”œÂ®ria nâ”¬â–‘. 2200-2 / 2001 SRMK16LE ame 42969925-8066-4fab-9de0-f5e6f3cfd97b Pagina 1 de 1	117916	1	\N	2025-11-03 22:18:49.692	2025-11-03 22:18:49.692	{"documentType":"05 Declaraâ”œÂºâ”œÃºo de Hipossuficiâ”œÂ¬ncia","confidence":0.9,"detectedInfo":{"ocrExtractedText":"DECLARAGAO DE HIPOSSUFICIENCIA DECLARANTE: Maria Jose De Lima, uniao estavel, aposentado(a), inscrito (a) no CPF sob o n. 331.518.494-15, e-mail: , residente e domiciliado na (0) LT Terra de Antares, Antares, Maceiâ”œÂ®-AL, CEP 57048-714. Declaro que nao posso suportar as despesas processuais decorrentes desta demanda sem prejuizo do meu prâ”œÂ®prio sustento e de minha familia, sendo, pois para fins de concessao do beneficio da gratuidade de justiga, nos termos da Lei n. 1.060/50, pobre no sentido legal da acepcâ”¬Ã³ao da justiga. Declaro ainda ter conhecimento das sangdes penais que estarei sujeito caso inveridica a declaragao prestada, sobretudo a disciplinada no art. 299 do Câ”œÂ®digo Penal. Atalaia, 28 de outubro de 2025. Maria Jose De Lima DECLARANTE Digitally signed by SEDEP. SERVICO DE ENTREGA DE DESPACHOS E PUBLICACO:37535259000147 Date: 2025.10.28 11:00:23 -04:00 Guid: 42969925-8066-4fab-9de0-f5e6f3cfd97b fo= Datas e horarios em GMT -04:00 Campo Grande ota. Log gerado em 28 de outubro de 2025. Declaracao de hipossuficiâ”œÂ®ncia - Maria Jose.pdf Documento numero: 42969925-8066-4fab-9de0-f5e6f3cid97b Hash do documento original (SHA256): XWr5NxVdDXGjc4WEBAAslfsez7eV4pLfSxxEttMpnf4=xwr 5NxVdDxXGjc4WEBAAs1fsez7eV4pLâ”¬ÃºSxxEttMpnf4= Assinaturas Maria Jose De Lima CPF: 331.518.494-15 Assinou em: 28 out 2025 as 10:57:42 IP: 45.161.74.175 Geolocalizagao: -9.5765815, -35.7408923 Dispositivo: Mozilla/5.0 (Linux; Android 10; K) AppleWebkKit/537.36 (KHTML, like Gecko) SamsungBrowser/28.0 Chrome/130.0.0.0 Mobile Safari/537.36 Emitido por Sistema FAZ. Log 28 out 2025, 10:50:39 Operador com email administrativo@barrosealvesadvogados.com.br criou este documento numero 42969925-8066-4fab-9de0-f5e6f3cfd97b. Finalizagdo automatica apâ”œÂ®s a ultima assinatura: habilitada. Idioma: Portuguâ”œÂ®s brasileiro. 28 out 2025, 10:57:42 Assinado por Maria Jose De Lima, CPF: 331.518.494-15, Data de nascimento: 09/08/1960. Pontos de autenticagao: evia whatsapp, Token: 232140, Telefone: 82987137630, IP: 45.161.74.175. 28 out 2025, 11:00:22 Processo de assinatura concluido para o documento numero 42969925-8066-4fab-9de0- f5e6f3cfd97b. iCP Este Log â”œÂ® exclusivo e deve ser considerado parte do documento nâ”¬â–‘ 42969925-8066-4fab-9de0-f5e6f3cfd97b, com os Brasil efeitos prescritos nos Termos de Uso/Termos de Adesao do Sistema FAZ no momento da solicitagao, disponivel em ak ~ http://privacidade.sedep.com.br/politica-privacidade. Para validar este documento escaneie 0 QRCode usando https://validar.iti.gov.br ou acesse https://validador.faz.adv.br e siga as instrugdes. As assinaturas digitais e eletrâ”œÂ®nicas tâ”œÂ®m validade juridica prevista na Medida Provisâ”œÂ®ria nâ”¬â–‘. 2200-2 / 2001 SRMK16LE ame 42969925-8066-4fab-9de0-f5e6f3cfd97b Pagina 1 de 1","cpf":"331.518.494-15"},"suggestedFilename":"Declaraâ”œÂºâ”œÃºo de Hipossuficiâ”œÂ¬ncia","ocrUsed":true,"chatGPTAnalysis":"7. Declaraâ”œÂºâ”œÃºo de Hipossuficiâ”œÂ¬ncia"}	0.9	05 Declaraâ”œÂºâ”œÃºo de Hipossuficiâ”œÂ¬ncia	\N	f	f	Declaraâ”œÂºâ”œÃºo_de_Hipossuficiâ”œÂ¬ncia_4__Declara__o_de_hipossufici_ncia___Maria_Jose.pdf	10
32	5	12	5. Contrato de honorarios.pdf	Contrato_rescindir_o.pdf	06 Contratos	6	application/pdf	258388	ocr_completed	https://yrzlxuefbxbpfndcpfqz.supabase.co/storage/v1/object/public/documents/processed/06_Contratos_7cde3ade.pdf	CONTRATANTE (8): CONTRATADO (S) Propositura de aco judicial/administrativa: C) Inventario judicial; OC Inventario extrajudicial; [Direito de familia: Tipo de ac&o/procedimento: Clique ou toque aqui para inserir o texto, & Contrato: Tipo de aâ”¬Ã³So/procedimento: REVISAO DE CONTRATO Clique ou toque aqui para inserir o taxto. & Reparaciio de dano Outros procedimentos: Clique ou toque aqui para inserir o texto. informagâ”œÂ®es importantes: Acompanhamento juridico: LC Atâ”œÂ® a propositura da ag4o; OC Atâ”œÂ® a audiâ”œÂ®ncia de conciliagdo; C Atâ”œÂ® a audiâ”œÂ®ncia de instrugao; C) Atâ”œÂ® as alegaces finais; & Atâ”œÂ® a prolacgdo da sentenca. Fase recursal: 0 Sim 0 Nao Cj Atâ”œÂ® o TJ/TRF: 1 Atâ”œÂ® o STU: & Atâ”œÂ® o STF. 4] DO VALOR CONTRATADO Clique ou toque aqui para Inserir o texto. &! 20% sobre o â”œÂ®xito da demanda: 1 30% sobre o â”œÂ®xito da demanda:; CO Honorarios Iniciais: Pagamento integral: & Pagamento Parcelado: QTD de Parcela: 3 parcelas. Valor da Parcela: R$ 1670,00. Vencimento: 1. 22/10/2026 2, 25/11/2026 3. 25/12/2025 JOSE ANTONIO DE LIMA, casado, aposentado(a), inscrito (a) no CPF sob o n. 347.333.704-82, e-mail: , residente 6 domiciliado na (o) PV TIMBOZINHO, s/n, TIMBOZINHO. Atalaia-AL, CEP 57690-000. ANDERSON RICARDO BARROS SILVA - SOCIEDADE INDIVIDUAL DE ADVOCACIA, ragistrada na OAB/AL sob on. 1262/2022, CNPJ n. 48,367.253/0001-24. Enderego constante no rodapâ”œÂ® da pagina. Atuacdo na defesa do râ”œÂ®u: Ndmero do processo: Clique ou toque aqui para inserir 0 texto. [] Contastacao QO) Audiâ”œÂ®ncia de conciliagfo/instrugao: 0 Alegacdes finais; Outros procedimentos de primeiro grau: ique ou toque aqui para inserir o texto. Informacies importantes: Acompanhamento juridico: Atâ”œÂ® a apresentacao da contestacdo: C Atâ”œÂ® a audiâ”œÂ®ncia de conciliacdo; OO Atâ”œÂ® a audiâ”œÂ®ncia de instrugdo: OO Atâ”œÂ® as alegacâ”œÂ®es finais: CO Atâ”œÂ® a prolagdo da sentenca. Fase recursal: 0 Sim 0 Nao Atâ”œÂ® o TJ/TRF; Atâ”œÂ® o STU: C Atâ”œÂ®o STF. nterposiâ”¬Ã³â”œÂ®o/defesa de recurso: C) Embargos de declaragao; O Apelagao; _] Agravo de instrumento: Recurso Especial: 1) Recurso Extraordinario; Outros recursos/procedimentos: Clique ou toque aqui para inserir o texto. DA DESISTENCIA DO CONTRATO Os honordrios ora pactuades sero devidos mesmo em caso de adimplemento ou reconhecimento administrativo do pedido formulado na inicial ou iniciado o procedimento de defesa, e caso queira o contratante rescindir o presente instrumento, devera arcar com 100% dos honorarios previstos no item 1. 3 DAS DESPESAS EXTRAS O (a) contratante (a) fica obrigado a pagar despesas judiciais ou extras, tais como custas processuais, honordnos de terceiros (peritos, câ”œÂ®lculos etc.) e gastos de viagem, quando necessâ”œÂ®rias; 4 DOS HONORARIOS SUCUMBENCIAIS Eventuais honerdrios cobrados da parte contrâ”œÂ®ra de Sucumbaâ”œÂ®ncia ou nao, pertencero ao representante da contratada e indapendem dos honordrios ora contratados, Ve PAGAMENTO E DESTAQUES DOS HONORARIOS Chave Pix - 48.367,253/0001-24 - ANDERSON RICARDO BARROS SILVA - SOCIEDADE INDIVIDUAL DE ADVOCACIA, 2 Transferâ”œÂ®ncia bancana: Agâ”œÂ®ncia 0001, C/C 37033287-7, Banco 0260 Nu Pagamentos S.A â”¬Â® Boleto Bancano; 1 Em espâ”œÂ®cie; independente dos honoraâ”œÂ®rios sucumbenciais. CO Destaque dos honordrios contratuais dos valores pactuados, DO FORO Fore de Atalaia-AL; OO Foro de Maceiâ”œÂ®-AL; (2 Outro: Clique ou toque aqui para inserir o texto. Ã”Ã‡Ã¿, i = \\, c \\ \\ Ã”Ã‡Ã¿ianect ay eS SASLAR | Say ae, Atalaia, 21 de outubro de 2025. Ns N a Cal. d a Sh cS. = Ã”Ã‡Â£Jose Antonio De Lima Outorgante/contratante Anderson Ricardo Barros Silva Ã”Ã‡Ã¶ Sociedade individual de Advocacia Outorgado/contratado Testemunhas: off Jar caw, - arte . Ã”Ã‡Ã¿AA. ay tf Ã”Ã‡Â£Nome/CPF | ees iat pe z WE yee |e ASS E2F-02 Nome/CPF	258388	1	\N	2025-11-03 22:19:03.886	2025-11-03 22:19:03.886	{"documentType":"06 Contratos","confidence":0.9,"detectedInfo":{"ocrExtractedText":"CONTRATANTE (8): CONTRATADO (S) Propositura de aco judicial/administrativa: C) Inventario judicial; OC Inventario extrajudicial; [Direito de familia: Tipo de ac&o/procedimento: Clique ou toque aqui para inserir o texto, & Contrato: Tipo de aâ”¬Ã³So/procedimento: REVISAO DE CONTRATO Clique ou toque aqui para inserir o taxto. & Reparaciio de dano Outros procedimentos: Clique ou toque aqui para inserir o texto. informagâ”œÂ®es importantes: Acompanhamento juridico: LC Atâ”œÂ® a propositura da ag4o; OC Atâ”œÂ® a audiâ”œÂ®ncia de conciliagdo; C Atâ”œÂ® a audiâ”œÂ®ncia de instrugao; C) Atâ”œÂ® as alegaces finais; & Atâ”œÂ® a prolacgdo da sentenca. Fase recursal: 0 Sim 0 Nao Cj Atâ”œÂ® o TJ/TRF: 1 Atâ”œÂ® o STU: & Atâ”œÂ® o STF. 4] DO VALOR CONTRATADO Clique ou toque aqui para Inserir o texto. &! 20% sobre o â”œÂ®xito da demanda: 1 30% sobre o â”œÂ®xito da demanda:; CO Honorarios Iniciais: Pagamento integral: & Pagamento Parcelado: QTD de Parcela: 3 parcelas. Valor da Parcela: R$ 1670,00. Vencimento: 1. 22/10/2026 2, 25/11/2026 3. 25/12/2025 JOSE ANTONIO DE LIMA, casado, aposentado(a), inscrito (a) no CPF sob o n. 347.333.704-82, e-mail: , residente 6 domiciliado na (o) PV TIMBOZINHO, s/n, TIMBOZINHO. Atalaia-AL, CEP 57690-000. ANDERSON RICARDO BARROS SILVA - SOCIEDADE INDIVIDUAL DE ADVOCACIA, ragistrada na OAB/AL sob on. 1262/2022, CNPJ n. 48,367.253/0001-24. Enderego constante no rodapâ”œÂ® da pagina. Atuacdo na defesa do râ”œÂ®u: Ndmero do processo: Clique ou toque aqui para inserir 0 texto. [] Contastacao QO) Audiâ”œÂ®ncia de conciliagfo/instrugao: 0 Alegacdes finais; Outros procedimentos de primeiro grau: ique ou toque aqui para inserir o texto. Informacies importantes: Acompanhamento juridico: Atâ”œÂ® a apresentacao da contestacdo: C Atâ”œÂ® a audiâ”œÂ®ncia de conciliacdo; OO Atâ”œÂ® a audiâ”œÂ®ncia de instrugdo: OO Atâ”œÂ® as alegacâ”œÂ®es finais: CO Atâ”œÂ® a prolagdo da sentenca. Fase recursal: 0 Sim 0 Nao Atâ”œÂ® o TJ/TRF; Atâ”œÂ® o STU: C Atâ”œÂ®o STF. nterposiâ”¬Ã³â”œÂ®o/defesa de recurso: C) Embargos de declaragao; O Apelagao; _] Agravo de instrumento: Recurso Especial: 1) Recurso Extraordinario; Outros recursos/procedimentos: Clique ou toque aqui para inserir o texto. DA DESISTENCIA DO CONTRATO Os honordrios ora pactuades sero devidos mesmo em caso de adimplemento ou reconhecimento administrativo do pedido formulado na inicial ou iniciado o procedimento de defesa, e caso queira o contratante rescindir o presente instrumento, devera arcar com 100% dos honorarios previstos no item 1. 3 DAS DESPESAS EXTRAS O (a) contratante (a) fica obrigado a pagar despesas judiciais ou extras, tais como custas processuais, honordnos de terceiros (peritos, câ”œÂ®lculos etc.) e gastos de viagem, quando necessâ”œÂ®rias; 4 DOS HONORARIOS SUCUMBENCIAIS Eventuais honerdrios cobrados da parte contrâ”œÂ®ra de Sucumbaâ”œÂ®ncia ou nao, pertencero ao representante da contratada e indapendem dos honordrios ora contratados, Ve PAGAMENTO E DESTAQUES DOS HONORARIOS Chave Pix - 48.367,253/0001-24 - ANDERSON RICARDO BARROS SILVA - SOCIEDADE INDIVIDUAL DE ADVOCACIA, 2 Transferâ”œÂ®ncia bancana: Agâ”œÂ®ncia 0001, C/C 37033287-7, Banco 0260 Nu Pagamentos S.A â”¬Â® Boleto Bancano; 1 Em espâ”œÂ®cie; independente dos honoraâ”œÂ®rios sucumbenciais. CO Destaque dos honordrios contratuais dos valores pactuados, DO FORO Fore de Atalaia-AL; OO Foro de Maceiâ”œÂ®-AL; (2 Outro: Clique ou toque aqui para inserir o texto. Ã”Ã‡Ã¿, i = \\\\, c \\\\ \\\\ Ã”Ã‡Ã¿ianect ay eS SASLAR | Say ae, Atalaia, 21 de outubro de 2025. Ns N a Cal. d a Sh cS. = Ã”Ã‡Â£Jose Antonio De Lima Outorgante/contratante Anderson Ricardo Barros Silva Ã”Ã‡Ã¶ Sociedade individual de Advocacia Outorgado/contratado Testemunhas: off Jar caw, - arte . Ã”Ã‡Ã¿AA. ay tf Ã”Ã‡Â£Nome/CPF | ees iat pe z WE yee |e ASS E2F-02 Nome/CPF"},"suggestedFilename":"Contratos","ocrUsed":true,"chatGPTAnalysis":"8. Contratos"}	0.9	06 Contratos	\N	f	f	Contrato_rescindir_o.pdf	10
33	5	12	WhatsApp Image 2025-10-21 at 15.55.42 (1).jpeg	Contratos_WhatsApp_Image_2025_10_21_at_15_55_42__1_.pdf	06 Contratos	7	image/jpeg	502904	ocr_completed	https://yrzlxuefbxbpfndcpfqz.supabase.co/storage/v1/object/public/documents/processed/06_Contratos_7dfbf91a.pdf	Veoncrwivnmim | 655-6 | Yomncovaernim | 655-6 | 65500,00002 00264 500265 96885.926000 9 Aes 260 | paaoz7 "PAGAVEL EM QUALQUER BANCO ATE 0 VENCIMENTO zavos/a027 heise | "Bunce Vlranin iA CNP 6968611 (0001.09 or aose7ai2 wekere. Ã”Ã‡Â£zorniz02s | 02608081 Pe [on peoscoes | "soozoonaasez8 veer [omen poaR [amet Ta rarencar once TST ENTS aves (eal formes dal lg 1 sof dcn fap hal) Ã”Ã‡Ã¶ CONTRATO NO: 4 /12104000078087 STAS RESIS VAL ORIGINAL: 1.305,00 MULTA: 26,19 ENCARGOS ATRASO: 3,41 AO OIA TARTERA TOSCO WRENS RERIOR MARIA JOSE DE LIMA abt ea! 500/269688592-8 PV TIMBOZINHO,7 ieee SAZADOR/AVALISTA, 7690-000 __ CENTRO ATALAIA os = MUM Yrmcoiowoniin | 655-6 | 65590,00002 00264.500265 96885.936003 5 1973000130500 22160 | PAGAVEL EM QUALQUER BANCO ATE 0 VENCIMENTO we zatorozr oor srioss7ot-2 Ã”Ã‡Â£Banco Voloranim S/A CNP: 59 508.111/0001-03 ee 000 SH1055751-2 | Ã”Ã‡Â£zonsre005_| 2605254 bea per pros2025 "sooreseeases-s 500 RS CONTRATO NO: 1/12104000078287 Corry VAL ORIGINAL: 1.308,00 MULTA. 28,10 ENGARGOS ATRASO: 3,41 AO OIA a a aro eee a San rescence lay TARTERATROSSO NERS PxaRDOR MARIA JOSE DE LIMA GPF ssisiasenis 500/269688593-6 PV TIMBOZINHO,7 AvAUsTA 57690.000__ CENTRO ATALAIA 0260525-1 ae ATION ATTA vector | 655-6 | Yrwcciocenian | 655-6 | 65590.00002 00264.500265 96885.944007 1 2040000130500 30/60 23i1112027 PAGAVEL EM QUALQUER BANCO ATE 0 VENCIMENTO. E 23/11/2027 TERIA aanea ENERO TenerCAR EAT ROO BERETS 0001-811055751-2 Banco Volorantim S/A CNPJ: â”¬Âº9.588,111/0001-03 001-9/1055751-2 TSEDR [SARTRE BRR BODGE | POSTINENTO ESP GG | RCETE [BATA FREGESSANENTO Ã”Ã‡Â£FERRER HOESOWOMERD RS 26/05/2028 | 0260825-1 at N 26/05/2025 500/2696885344 500 RS L 5 1905.00 Tyan (Tia ages dela ona Hi i igor apnea aneOr@) TBESCONTOTASATINENTS TOTRAS DEES ET; Ã”Ã‡Ã¶Ã”Ã‡Ã¶_Ã”Ã‡Ã¶ CONTRATO NO: 4/ 1204000078287 [PIRORATILTA SaaS] Ã”Ã‡Ã¿VAL ORIGINAL: 1:305,00 MULTA: 28,10 ENCARGOS ATRASO: 3.41 A0 DIA GuTRGS ARESCOS aa ane otra S.A, Sass ol ot eer da BY Places A. ~ Ci, ams tina) Byer CoRADS Ã”Ã‡Ã¿Ania Nae nas 11 Ter 8 nV rer Sho PyÃ”Ã‡Â£ OFAN heir Sern de om atv a at inn one tt el de eno AERATOR RENT Fasabor MARIA JOSE DE LIMA GH ssi staderis 00/269688594-4 PY TIMBOZINHO,7 aeRO Ca DSS OMENS fe Soon SAGADOR/AVALSTA 7090-000 __ CENTRO. ATALAIA mn TTT LET ATE ATS ee NA AL GARR S=2P ="	305666	1	\N	2025-11-03 22:19:12.705	2025-11-03 22:19:12.705	{"documentType":"06 Contratos","confidence":0.9,"detectedInfo":{"ocrExtractedText":"Veoncrwivnmim | 655-6 | Yomncovaernim | 655-6 | 65500,00002 00264 500265 96885.926000 9 Aes 260 | paaoz7 \\"PAGAVEL EM QUALQUER BANCO ATE 0 VENCIMENTO zavos/a027 heise | \\"Bunce Vlranin iA CNP 6968611 (0001.09 or aose7ai2 wekere. Ã”Ã‡Â£zorniz02s | 02608081 Pe [on peoscoes | \\"soozoonaasez8 veer [omen poaR [amet Ta rarencar once TST ENTS aves (eal formes dal lg 1 sof dcn fap hal) Ã”Ã‡Ã¶ CONTRATO NO: 4 /12104000078087 STAS RESIS VAL ORIGINAL: 1.305,00 MULTA: 26,19 ENCARGOS ATRASO: 3,41 AO OIA TARTERA TOSCO WRENS RERIOR MARIA JOSE DE LIMA abt ea! 500/269688592-8 PV TIMBOZINHO,7 ieee SAZADOR/AVALISTA, 7690-000 __ CENTRO ATALAIA os = MUM Yrmcoiowoniin | 655-6 | 65590,00002 00264.500265 96885.936003 5 1973000130500 22160 | PAGAVEL EM QUALQUER BANCO ATE 0 VENCIMENTO we zatorozr oor srioss7ot-2 Ã”Ã‡Â£Banco Voloranim S/A CNP: 59 508.111/0001-03 ee 000 SH1055751-2 | Ã”Ã‡Â£zonsre005_| 2605254 bea per pros2025 \\"sooreseeases-s 500 RS CONTRATO NO: 1/12104000078287 Corry VAL ORIGINAL: 1.308,00 MULTA. 28,10 ENGARGOS ATRASO: 3,41 AO OIA a a aro eee a San rescence lay TARTERATROSSO NERS PxaRDOR MARIA JOSE DE LIMA GPF ssisiasenis 500/269688593-6 PV TIMBOZINHO,7 AvAUsTA 57690.000__ CENTRO ATALAIA 0260525-1 ae ATION ATTA vector | 655-6 | Yrwcciocenian | 655-6 | 65590.00002 00264.500265 96885.944007 1 2040000130500 30/60 23i1112027 PAGAVEL EM QUALQUER BANCO ATE 0 VENCIMENTO. E 23/11/2027 TERIA aanea ENERO TenerCAR EAT ROO BERETS 0001-811055751-2 Banco Volorantim S/A CNPJ: â”¬Âº9.588,111/0001-03 001-9/1055751-2 TSEDR [SARTRE BRR BODGE | POSTINENTO ESP GG | RCETE [BATA FREGESSANENTO Ã”Ã‡Â£FERRER HOESOWOMERD RS 26/05/2028 | 0260825-1 at N 26/05/2025 500/2696885344 500 RS L 5 1905.00 Tyan (Tia ages dela ona Hi i igor apnea aneOr@) TBESCONTOTASATINENTS TOTRAS DEES ET; Ã”Ã‡Ã¶Ã”Ã‡Ã¶_Ã”Ã‡Ã¶ CONTRATO NO: 4/ 1204000078287 [PIRORATILTA SaaS] Ã”Ã‡Ã¿VAL ORIGINAL: 1:305,00 MULTA: 28,10 ENCARGOS ATRASO: 3.41 A0 DIA GuTRGS ARESCOS aa ane otra S.A, Sass ol ot eer da BY Places A. ~ Ci, ams tina) Byer CoRADS Ã”Ã‡Ã¿Ania Nae nas 11 Ter 8 nV rer Sho PyÃ”Ã‡Â£ OFAN heir Sern de om atv a at inn one tt el de eno AERATOR RENT Fasabor MARIA JOSE DE LIMA GH ssi staderis 00/269688594-4 PY TIMBOZINHO,7 aeRO Ca DSS OMENS fe Soon SAGADOR/AVALSTA 7090-000 __ CENTRO. ATALAIA mn TTT LET ATE ATS ee NA AL GARR S=2P =\\""},"suggestedFilename":"Contratos","ocrUsed":true,"chatGPTAnalysis":"8. Contratos"}	0.9	06 Contratos	\N	f	f	Contratos_WhatsApp_Image_2025_10_21_at_15_55_42__1_.pdf	10
34	5	12	WhatsApp Image 2025-10-21 at 15.55.42.jpeg	07 nota fiscal de serviâ”œÂºo eletrâ”œâ”¤nica.pdf	07 nota fiscal de serviâ”œÂºo eletrâ”œâ”¤nica	8	image/jpeg	337726	ocr_completed	https://yrzlxuefbxbpfndcpfqz.supabase.co/storage/v1/object/public/documents/processed/07_nota_fiscal_de_servico_eletronica_995a17ac.pdf	PREFEITURA MUNICIPAL DE MACEIO SECRETARIA MUNICIPAL DE FAZENDA NOTA FISCAL DE SERVIGO ELETRONICA - NFS-â”¬Ã³ Câ”œÂ®digo de Verificagao NFS-e 10650 PZSA3RFBQ Emissao da NFS-e 10/06/2025 08:53 NFS-e Substituida CPFICNPY: Nome/Razao Social: Enderego 42.571.957/0001-38 E J BARBOSA DE OMENA & CIA LTDA MENDONCA JUNIOR Complemento: CEP. E-mail 57052-480 escritorioitauna@hotmail.com Municipio: MACEIO Inserigao Nomero: Bairro: Pais: Telefone: 901602435 762 GRUTA DE LOURDES Brasil (22)9916-9434 CPFICNPS: Nome/Razao Social: | Enderego: Complemento: CEP. 5790-000 347.333.704-82 JOSE ANTONIO DE LIMA Rua POVOADO TIMBOZINHO Municipio: Tomador de Serviâ”¬Ã³o Inscrigâ”œÂ®o Municipal: ATALAIA NIF- Namero: Bairro: Pais: Telefone: a Atalaia Brasil (s2)98845-9876 Atividade Econâ”œÂ®mica 14.01 /4520004 - servicos de alinhamento e balanceamento de veiculos automotores Discriminacao do Serviâ”¬Ã³go } BALANCEAMENTO 1 ALINHAMENTO, } DESEMPENO } LIMPEZA DE CAMPANA }t LIMPEZA DE SISTEMA DE FREIOS CASTER 1 LIMPEZA ARREFECIMENTO Tributos Federais (RS) Valor Aproximado dos Tributos (%) pis | COFINS INSS IR Federal Estadual Municipal 0,00 000 | 000 | 0,00 0,00% 0,00% 0,00% Identificagao Prestacao de Servicos Detalhamento de Valores (RS) (Câ”œÂ®digo da Obra Valor do Servigo 1.200,00 Codigo A.RT. Desconto incondicionado 0,00 Exigiblidade ISSON 1-Exigivel ynto Condicionado 0,00 Regime Especial de Tibutagao Ã”Ã‡Ã¿O-Nenhum jetengdes Federais 0,00 Ã”Ã‡Ã¿Simples Nacional (X) Sim () Nao Outras Retengoes 0,00 incentivador Fiscal Dedugdes Previstas em Lei 0,00 Competâ”œÂ®ncia Municipio Prestagao Ã”Ã‡Â£MACEIO- AL Base de Calculo 1.200,00 Ã”Ã‡Ã¿Aliquota 5,00 Ã”Ã‡Ã¿Municipio Incidâ”œÂ®ncia MACEIO - AL ISSQN 0,00 ISSN a Reter ~ (Sim (X) Nao Valor Liquido 1.200,00 Outras Informagâ”œÂ®es 1- Uma via desta Nota Fiscal sera enviada atravâ”œÂ®s do e-mail fornecido pelo Tomador do Servigo. 2- A autenticidade desta Nota Fiscal podera ser verificada no site, http://maceio.giss.com. br com a utllizagao do Câ”œÂ®digo de Verificagao. 3 - Documento emitido por ME ou EPP optante pelo Simples Nacional. Nao gera direito a crâ”œÂ®dito fiscal de ISS e IPI.	204681	1	\N	2025-11-03 22:19:19.396	2025-11-03 22:19:19.396	{"documentType":"07 nota fiscal de serviâ”œÂºo eletrâ”œâ”¤nica","confidence":0.9,"detectedInfo":{"ocrExtractedText":"PREFEITURA MUNICIPAL DE MACEIO SECRETARIA MUNICIPAL DE FAZENDA NOTA FISCAL DE SERVIGO ELETRONICA - NFS-â”¬Ã³ Câ”œÂ®digo de Verificagao NFS-e 10650 PZSA3RFBQ Emissao da NFS-e 10/06/2025 08:53 NFS-e Substituida CPFICNPY: Nome/Razao Social: Enderego 42.571.957/0001-38 E J BARBOSA DE OMENA & CIA LTDA MENDONCA JUNIOR Complemento: CEP. E-mail 57052-480 escritorioitauna@hotmail.com Municipio: MACEIO Inserigao Nomero: Bairro: Pais: Telefone: 901602435 762 GRUTA DE LOURDES Brasil (22)9916-9434 CPFICNPS: Nome/Razao Social: | Enderego: Complemento: CEP. 5790-000 347.333.704-82 JOSE ANTONIO DE LIMA Rua POVOADO TIMBOZINHO Municipio: Tomador de Serviâ”¬Ã³o Inscrigâ”œÂ®o Municipal: ATALAIA NIF- Namero: Bairro: Pais: Telefone: a Atalaia Brasil (s2)98845-9876 Atividade Econâ”œÂ®mica 14.01 /4520004 - servicos de alinhamento e balanceamento de veiculos automotores Discriminacao do Serviâ”¬Ã³go } BALANCEAMENTO 1 ALINHAMENTO, } DESEMPENO } LIMPEZA DE CAMPANA }t LIMPEZA DE SISTEMA DE FREIOS CASTER 1 LIMPEZA ARREFECIMENTO Tributos Federais (RS) Valor Aproximado dos Tributos (%) pis | COFINS INSS IR Federal Estadual Municipal 0,00 000 | 000 | 0,00 0,00% 0,00% 0,00% Identificagao Prestacao de Servicos Detalhamento de Valores (RS) (Câ”œÂ®digo da Obra Valor do Servigo 1.200,00 Codigo A.RT. Desconto incondicionado 0,00 Exigiblidade ISSON 1-Exigivel ynto Condicionado 0,00 Regime Especial de Tibutagao Ã”Ã‡Ã¿O-Nenhum jetengdes Federais 0,00 Ã”Ã‡Ã¿Simples Nacional (X) Sim () Nao Outras Retengoes 0,00 incentivador Fiscal Dedugdes Previstas em Lei 0,00 Competâ”œÂ®ncia Municipio Prestagao Ã”Ã‡Â£MACEIO- AL Base de Calculo 1.200,00 Ã”Ã‡Ã¿Aliquota 5,00 Ã”Ã‡Ã¿Municipio Incidâ”œÂ®ncia MACEIO - AL ISSQN 0,00 ISSN a Reter ~ (Sim (X) Nao Valor Liquido 1.200,00 Outras Informagâ”œÂ®es 1- Uma via desta Nota Fiscal sera enviada atravâ”œÂ®s do e-mail fornecido pelo Tomador do Servigo. 2- A autenticidade desta Nota Fiscal podera ser verificada no site, http://maceio.giss.com. br com a utllizagao do Câ”œÂ®digo de Verificagao. 3 - Documento emitido por ME ou EPP optante pelo Simples Nacional. Nao gera direito a crâ”œÂ®dito fiscal de ISS e IPI."},"suggestedFilename":"nota fiscal de serviâ”œÂºo eletrâ”œâ”¤nica","ocrUsed":true,"chatGPTAnalysis":"9. Nota Fiscal de Serviâ”œÂºo Eletrâ”œâ”¤nica"}	0.9	07 nota fiscal de serviâ”œÂºo eletrâ”œâ”¤nica	\N	f	f	07 nota fiscal de serviâ”œÂºo eletrâ”œâ”¤nica.pdf	10
35	5	12	WhatsApp Image 2025-10-21 at 15.55.43.jpeg	Contratos_WhatsApp_Image_2025_10_21_at_15_55_43.pdf	06 Contratos	9	image/jpeg	484521	ocr_completed	https://yrzlxuefbxbpfndcpfqz.supabase.co/storage/v1/object/public/documents/processed/06_Contratos_252d7377.pdf	Yonmasiis | 685-6 | 165590,00002 00264,500265 96885,898005 2 1510000130500 Wimorain | 6555 | 2560 | asoezo2r TPAGAVEL EM QUALGUER BANCO ATE â”¬Â® VENGIMENTO poneÃ”Ã‡Ã– zoe oor-avioserst *aenco Voloraniim S/A GNP} 69.5884 11/0001-05, ee 01. A/1085751-2 ees. "vosa0as | 0260626-4 Pe [ow zens |Ã”Ã‡Ã˜ Ã”Ã‡Â£soranasen-s SERIOUS Ã”Ã‡Ã¶Ã”Ã‡Ã¶ are tear ree faery oe RCT RRS ATT ome | CONTRATO NO: 1 12104000078287 VAL ORIGINAL: {908,00 MULTA: 26,10 ENCARGOS ATRASO: 3.41 AO) 1A MARIA JOSE DE LIMA GF TASTES supra PY TIMBOZINHO 7 egEomaee AGAOORIAYAISTA 57600000 _ CENTRO AANA aa Yooncvrorntin | 655-6 | Ã”Ã‡Â£Yeonomonnin | 655-6 | __ 65590,00002 00264.500265 96885.001007 7 1881000130500 pmo | 23072027 "PAGAVEL EM QUALQUER BANCO ATE â”¬Â® VENCIMENTO ae Zorro "arco Votorantim S/A CNPL: 89 58.11170001-08 pe Goat 105575%-2 Ã”Ã‡Â£porosaoas | 0360525 Pre, [ow Lo zaoszoss | sovasonasco- cam Tareas foam Dean IS TA GONTRATO No: 4/ 1210400078287 \\VAL ORIGINAL: 1.305,00 MULTA: 26,10 ENCARGOS ATRASO: 3.47 AO DIA pours Deb aSoS 1 ST SRAOeS 0260525-1 500/269688590-1 ENT MARIA JOSE DE LIMA PV TIMBOZINHO7 cabo /AVALISTAâ”¬Âº7690-000_ CENTRO ATALAIA AL OFF (ONIN ON IN Ml Yeommnnn | 655-6 | Yosecvaoenin | 655-6 | 65590.00002 00264.500265 96885.911006 1 19120000130500 27160 23/08/2027 * PAGAVEL EM QUALQUER BANCO ATE â”¬Â® VENGIMENTO zaioaize27 TSEEATSISSS RENEFURS TEENCIA GoOGS BENEFIOAR Banco Votorantim S/A CNPJ: 59,588.111/0001-03 001-9/1055751-2 oor ahs7ar2 [ erosrons | 0208054 a 2082025 SorzaeHee-t 1306.09] 500 RS t 1305.00 oe TERT TyauTROs AERESONOS TaeR oa CONTRATO No: 1 /12104000078287 Ã”Ã‡Ã¿VAL ORIGINAL: 4 308 00 MULTA: 26,10 ENCARGOS ATRASO: 3.41 AO DIA es Yarn Sait ane eens [romascmoses i (UTRGS AERESCRIOS [pemerccsans un caecr cen a ons ee oa eae Cdn om cena rete TARTERAT NOSSO NOMERO PAGADOR WARIA JOSE DE LIMA reese) 5o0/269688501-1 Py TIMBOZINHO.7 WieRa pa DOS NENTO r a he 5 AL SAGADOR /AVALISTA, 6 7690-000 _CENTRO. ATALAIA (0260525-1 = RITA TERA ROPES omatonet WIL IMI IWrscanner	294009	1	\N	2025-11-03 22:19:27.76	2025-11-03 22:19:27.76	{"documentType":"06 Contratos","confidence":0.9,"detectedInfo":{"ocrExtractedText":"Yonmasiis | 685-6 | 165590,00002 00264,500265 96885,898005 2 1510000130500 Wimorain | 6555 | 2560 | asoezo2r TPAGAVEL EM QUALGUER BANCO ATE â”¬Â® VENGIMENTO poneÃ”Ã‡Ã– zoe oor-avioserst *aenco Voloraniim S/A GNP} 69.5884 11/0001-05, ee 01. A/1085751-2 ees. \\"vosa0as | 0260626-4 Pe [ow zens |Ã”Ã‡Ã˜ Ã”Ã‡Â£soranasen-s SERIOUS Ã”Ã‡Ã¶Ã”Ã‡Ã¶ are tear ree faery oe RCT RRS ATT ome | CONTRATO NO: 1 12104000078287 VAL ORIGINAL: {908,00 MULTA: 26,10 ENCARGOS ATRASO: 3.41 AO) 1A MARIA JOSE DE LIMA GF TASTES supra PY TIMBOZINHO 7 egEomaee AGAOORIAYAISTA 57600000 _ CENTRO AANA aa Yooncvrorntin | 655-6 | Ã”Ã‡Â£Yeonomonnin | 655-6 | __ 65590,00002 00264.500265 96885.001007 7 1881000130500 pmo | 23072027 \\"PAGAVEL EM QUALQUER BANCO ATE â”¬Â® VENCIMENTO ae Zorro \\"arco Votorantim S/A CNPL: 89 58.11170001-08 pe Goat 105575%-2 Ã”Ã‡Â£porosaoas | 0360525 Pre, [ow Lo zaoszoss | sovasonasco- cam Tareas foam Dean IS TA GONTRATO No: 4/ 1210400078287 \\\\VAL ORIGINAL: 1.305,00 MULTA: 26,10 ENCARGOS ATRASO: 3.47 AO DIA pours Deb aSoS 1 ST SRAOeS 0260525-1 500/269688590-1 ENT MARIA JOSE DE LIMA PV TIMBOZINHO7 cabo /AVALISTAâ”¬Âº7690-000_ CENTRO ATALAIA AL OFF (ONIN ON IN Ml Yeommnnn | 655-6 | Yosecvaoenin | 655-6 | 65590.00002 00264.500265 96885.911006 1 19120000130500 27160 23/08/2027 * PAGAVEL EM QUALQUER BANCO ATE â”¬Â® VENGIMENTO zaioaize27 TSEEATSISSS RENEFURS TEENCIA GoOGS BENEFIOAR Banco Votorantim S/A CNPJ: 59,588.111/0001-03 001-9/1055751-2 oor ahs7ar2 [ erosrons | 0208054 a 2082025 SorzaeHee-t 1306.09] 500 RS t 1305.00 oe TERT TyauTROs AERESONOS TaeR oa CONTRATO No: 1 /12104000078287 Ã”Ã‡Ã¿VAL ORIGINAL: 4 308 00 MULTA: 26,10 ENCARGOS ATRASO: 3.41 AO DIA es Yarn Sait ane eens [romascmoses i (UTRGS AERESCRIOS [pemerccsans un caecr cen a ons ee oa eae Cdn om cena rete TARTERAT NOSSO NOMERO PAGADOR WARIA JOSE DE LIMA reese) 5o0/269688501-1 Py TIMBOZINHO.7 WieRa pa DOS NENTO r a he 5 AL SAGADOR /AVALISTA, 6 7690-000 _CENTRO. ATALAIA (0260525-1 = RITA TERA ROPES omatonet WIL IMI IWrscanner"},"suggestedFilename":"Contratos","ocrUsed":true,"chatGPTAnalysis":"8. Contratos"}	0.9	06 Contratos	\N	f	f	Contratos_WhatsApp_Image_2025_10_21_at_15_55_43.pdf	10
36	5	12	WhatsApp Image 2025-10-21 at 15.55.44.jpeg	Contratos_WhatsApp_Image_2025_10_21_at_15_55_44.pdf	06 Contratos	10	image/jpeg	507397	ocr_completed	https://yrzlxuefbxbpfndcpfqz.supabase.co/storage/v1/object/public/documents/processed/06_Contratos_a93aed51.pdf	W rancevotoratin | 856 | Yorcomecnin | 686-6 | 65590.00002 00264.500265 96885.863009 4 1759000130500 nn hace ie 22/60 23/03/2027 PAGAVEL EM QUALQUER BANCO ATE O VENCIMENTO- 2Y03/2027 ee ew emcee 0001-9/1055751-2 Banco Votorantim S/A CNPJ: 59,588.11 1/0001-03 0001-9/1055751-2 RS 26/05/2025 | 0260525-1 a. 4 N 26/05/2025 500/269688586-3 sae | : Sa RS Hl EEOTO EATEN Troumasnenvcses eT OUTROS ACRESOOIOS TIvNaR CoS CONTRATO NO: +/42104000078287 Ã”Ã‡Ã¿VAL ORIGINAL; 1.905,00 MULTA: 26,10 ENCARGOS ATRASO: 3,44 AO DIA DESCENT ABATITERTO frroUTRAS DEuSDES orcas ARESSNOS ARTE NOSSO HOMERS MARIA JOSE DE LIMA CPF: 331 518 408-15 Ã”Ã‡Ã¿shale PV TIMBOZINHO,7 TRESS TONES aAGADOR /AVALISTA cers so00-000__CENTRO ATMA Fenesreonin | 655-6 | Ã”Ã‡Â£Yroncowsrmin | 655-6 | ___65690.00002 00264.500265 96885.87 1002 6 1790000130500 oe TOCALDEPREMRENTO TSRCRENTS ae 23/04/2027 PAGAVEL EM QUALQUER BANCO ATE VENCIMENTO. SERA COSGO SENET Ã”Ã‡Ã¿Banco Votorantim S/A CNP4: 59.588.111/0001-03 (0001-9/1055751-2 TaADODSS [oOSNENTO ESP OSE GTA PROCESEATENTS | ENTE TROSSO NUMERO 26/05/2025 | 02605251 01 26/05/2025 500/269688587-1 Teocoemce EARTERA Ã”Ã‡Ã¶uoeen [rae TRO PER BTC ENTO 808.00) 500 RS l 4308.00 CONTRATO No: 4/12104000078267, VAL ORIGINAL: 1.305,00 MULTA: 28,10 ENCARGOS ATRASO: 3,41 AO DIA ra conbecer occas da noses unis act ou ete a con co mn cn derail + SUTRAS DEDUREES [> 1OUTRGS AGRESGNIOS VALOR COBRADO TERTERAT NOSSO NOMERD 500/289688587-1 =AGOR MARIA JOSE DE LIMA, PVTINBOZINHO,7 CPF: Sot STEASHI5 TERS DODOOIENTO SACADOR/AVALISTA â”¬Âº7600.000__ CENTRO ATALAIA 0260525-1 TOTENTIONGRO WECRMEA PCN Yrmowsorenin | 655-6 | Yrmncvsoratn | 655-6 | 65590.00002 00264.500265 96885.881001 3 1820000130500 ara [OCR DE POAT TERSRENTS 24160 23/05/2027 PAGAVEL EM QUALQUER BANCO ATE O VENCIMENTO 23/05/2027 RGENGAT COCO REEFS 0001-9/1055751-2 Banco Votorantim S/A CNPJ: 59,588.111/0001-03 0001-9/1055751-2 TEER | SORTOREE GARBODGE | WOGHENTO aE DOE | SESTE BTA FROGEESRENTO | EXRTERAT ROSHONINERS RS 26/05/2025 | 02605251 ot N 26/05/2025 500/269688588-1 ToT DOSES Teeoeemee[omrnn [noe Ã”Ã‡Ã¶Ã”Ã‡Ã¶JaunTeane Tae TRIGA BODSSMENTO 4305.00 500 RS t â”œÂ® 1305.00 TDESCONTOTABATINENTO Donwssects Ã”Ã‡Ã¶Ã”Ã‡Ã¶Ã”Ã‡Ã¶] ea Ty OuTROS AERESERIOS TaVALOR GoeRAGS Trnlglos (Tod us foray ins deste aquolo wo de axa (esposabaKade do beni) CONTRATO No: 1/ 1210400078287 VAL ORIGINAL: 1 305,00 MULTA: 26,10 ENCARGOS ATRASO: 3,41 AO DIA bane Yann 5. (Suc oa yor xpunso de BY Pinas S.A. Cio, aie lavina) Ã”Ã‡Ã¿Avene ds Nagbe Dida a7 A, dar- la Goes Sip Palo - 0434-000 Pus nee neers de owas wide act ie eet ta eat an cma de aban ETDESCONTOT ADATINENTO FoMerer yey SUTRAS DEDUSSES TINORATIINTA Tr 1 OUTROS AERESERIOS TrIVATORCOSRAGS GARTEIRA NOSSO NOMERO 500/269688588-1 WineRO 09 DOC UMENTO (0260525-1 won so ia PREDOR MARIA JOSE DE LIMA PV TIMBOZINHO,7 SACADOR /AVALISTAÃ”Ã‡Ã–67690-000 __ CENTRO. ATALAIA CPF 991.518.4815 AL OANA Ue oa) ir Scanner	310404	1	\N	2025-11-03 22:19:37.321	2025-11-03 22:19:37.321	{"documentType":"06 Contratos","confidence":0.9,"detectedInfo":{"ocrExtractedText":"W rancevotoratin | 856 | Yorcomecnin | 686-6 | 65590.00002 00264.500265 96885.863009 4 1759000130500 nn hace ie 22/60 23/03/2027 PAGAVEL EM QUALQUER BANCO ATE O VENCIMENTO- 2Y03/2027 ee ew emcee 0001-9/1055751-2 Banco Votorantim S/A CNPJ: 59,588.11 1/0001-03 0001-9/1055751-2 RS 26/05/2025 | 0260525-1 a. 4 N 26/05/2025 500/269688586-3 sae | : Sa RS Hl EEOTO EATEN Troumasnenvcses eT OUTROS ACRESOOIOS TIvNaR CoS CONTRATO NO: +/42104000078287 Ã”Ã‡Ã¿VAL ORIGINAL; 1.905,00 MULTA: 26,10 ENCARGOS ATRASO: 3,44 AO DIA DESCENT ABATITERTO frroUTRAS DEuSDES orcas ARESSNOS ARTE NOSSO HOMERS MARIA JOSE DE LIMA CPF: 331 518 408-15 Ã”Ã‡Ã¿shale PV TIMBOZINHO,7 TRESS TONES aAGADOR /AVALISTA cers so00-000__CENTRO ATMA Fenesreonin | 655-6 | Ã”Ã‡Â£Yroncowsrmin | 655-6 | ___65690.00002 00264.500265 96885.87 1002 6 1790000130500 oe TOCALDEPREMRENTO TSRCRENTS ae 23/04/2027 PAGAVEL EM QUALQUER BANCO ATE VENCIMENTO. SERA COSGO SENET Ã”Ã‡Ã¿Banco Votorantim S/A CNP4: 59.588.111/0001-03 (0001-9/1055751-2 TaADODSS [oOSNENTO ESP OSE GTA PROCESEATENTS | ENTE TROSSO NUMERO 26/05/2025 | 02605251 01 26/05/2025 500/269688587-1 Teocoemce EARTERA Ã”Ã‡Ã¶uoeen [rae TRO PER BTC ENTO 808.00) 500 RS l 4308.00 CONTRATO No: 4/12104000078267, VAL ORIGINAL: 1.305,00 MULTA: 28,10 ENCARGOS ATRASO: 3,41 AO DIA ra conbecer occas da noses unis act ou ete a con co mn cn derail + SUTRAS DEDUREES [> 1OUTRGS AGRESGNIOS VALOR COBRADO TERTERAT NOSSO NOMERD 500/289688587-1 =AGOR MARIA JOSE DE LIMA, PVTINBOZINHO,7 CPF: Sot STEASHI5 TERS DODOOIENTO SACADOR/AVALISTA â”¬Âº7600.000__ CENTRO ATALAIA 0260525-1 TOTENTIONGRO WECRMEA PCN Yrmowsorenin | 655-6 | Yrmncvsoratn | 655-6 | 65590.00002 00264.500265 96885.881001 3 1820000130500 ara [OCR DE POAT TERSRENTS 24160 23/05/2027 PAGAVEL EM QUALQUER BANCO ATE O VENCIMENTO 23/05/2027 RGENGAT COCO REEFS 0001-9/1055751-2 Banco Votorantim S/A CNPJ: 59,588.111/0001-03 0001-9/1055751-2 TEER | SORTOREE GARBODGE | WOGHENTO aE DOE | SESTE BTA FROGEESRENTO | EXRTERAT ROSHONINERS RS 26/05/2025 | 02605251 ot N 26/05/2025 500/269688588-1 ToT DOSES Teeoeemee[omrnn [noe Ã”Ã‡Ã¶Ã”Ã‡Ã¶JaunTeane Tae TRIGA BODSSMENTO 4305.00 500 RS t â”œÂ® 1305.00 TDESCONTOTABATINENTO Donwssects Ã”Ã‡Ã¶Ã”Ã‡Ã¶Ã”Ã‡Ã¶] ea Ty OuTROS AERESERIOS TaVALOR GoeRAGS Trnlglos (Tod us foray ins deste aquolo wo de axa (esposabaKade do beni) CONTRATO No: 1/ 1210400078287 VAL ORIGINAL: 1 305,00 MULTA: 26,10 ENCARGOS ATRASO: 3,41 AO DIA bane Yann 5. (Suc oa yor xpunso de BY Pinas S.A. Cio, aie lavina) Ã”Ã‡Ã¿Avene ds Nagbe Dida a7 A, dar- la Goes Sip Palo - 0434-000 Pus nee neers de owas wide act ie eet ta eat an cma de aban ETDESCONTOT ADATINENTO FoMerer yey SUTRAS DEDUSSES TINORATIINTA Tr 1 OUTROS AERESERIOS TrIVATORCOSRAGS GARTEIRA NOSSO NOMERO 500/269688588-1 WineRO 09 DOC UMENTO (0260525-1 won so ia PREDOR MARIA JOSE DE LIMA PV TIMBOZINHO,7 SACADOR /AVALISTAÃ”Ã‡Ã–67690-000 __ CENTRO. ATALAIA CPF 991.518.4815 AL OANA Ue oa) ir Scanner"},"suggestedFilename":"Contratos","ocrUsed":true,"chatGPTAnalysis":"8. Contratos"}	0.9	06 Contratos	\N	f	f	Contratos_WhatsApp_Image_2025_10_21_at_15_55_44.pdf	10
37	5	12	WhatsApp Image 2025-10-21 at 15.55.45.jpeg	Contratos_WhatsApp_Image_2025_10_21_at_15_55_45.pdf	06 Contratos	11	image/jpeg	493163	ocr_completed	https://yrzlxuefbxbpfndcpfqz.supabase.co/storage/v1/object/public/documents/processed/06_Contratos_4b1714fb.pdf	Vorvciesiim | 656-6 | Ã”Ã‡Ã¿Yencnmwctn | 656-6 | __ 65590,00002 00264.500268 96885 839009 7 1669000130500 PARSING [oENeTaeTO 19/60 23/12/2026 ToTEPRTENTO rae PAGAVEL EM QUALQUER BANCO ATE O VENCIMENTO 2312/2028 TeiticaTconpopeNEAOARE 0001-8/1055751-2 Boercane SERA TEENS BEERS Blanco Vatorantim S/A CNPJ: 69.688.111/0001-03 0001-9/1055751-2 BOER [SURE RS Bara DS bea | OSETIENT Er Oe [SETA PROCESSES | CHT ERAT HOSED HOMERS 2evos/2025 | 02605251 a 26/05/2025 500/769688560-9 VaoRao oo 500 4 4305.00 rauTROe RECO CONTRATO NO:1/42104000076287 RENT VAL ORIGINAL: 1308.00 MULTA: 26,10 ENCARGOS ATRASO: 3,47 AO BIA spe 8 '500/260688583-9 0260525-1 Yenceonnin | 655-6 | PRGADOR MARIA JOSE DE LIMA Gr SSI AGES Py TiMaaziNHo,7 SAGAOON/AVALISTA_â”¬Âº7600-000_ CENTRO. ATALAA a POMOC A A Foncoiowrriin | 655-6 | 65590.00002 00264.500265 96885.647002 7 1700000013050 20/60 23/01/2027 PAGAVEL EM QUALQUER BANCO ATE O VENCIMENTO. â”œÂ® Ã”Ã‡Ã¿23/01/2027 SEROA | SOOIGO RENE (0004-911055751-2 Banco Votorantim SIA CNPJ: 59,588.111/0001-03 0001-9/1055751-2 2608/2025 | 0260525-1 26/05/2025 500/269688584-7 500 RS 4306.00 preaTRAS DeDRES Ã”Ã‡Ã¿CONTRATO No: 1/ 4210400078287 RATT VAL ORIGINAL: 1.305,00 MULTA: 26,10 ENCARGOS ATRASO: 3,41 AO DIA 1S 500/269668584-7 Y sancoveroraction | 655-6 | PAERDOR (MARIA JOSE DE LIMA CPF SSTSteAOHIS PY TIMBOZINHO7 ACADOR J AVALISTA â”¬Âº7690-000_ CENTRO ATALAIA a IU AA Yorncovsocnim | 655-6 | 65590,00002 00264.500265 96885.855005 9 1731000013050 21/60 23/02/2027 PAGAVEL EM QUALQUER BANCO ATE 0 VENCIMENTO, 23/02/2027 TEERGIR BOO BERERIOARS (0001-9/1055751-2 Genera RENE CODGO SENEFIORRO Banco Votorantim S/A CNPJ: 59.588.111/0001-03 001-9/1055751-2 RS 26/05/2025 | 0260525-1 ot N 26/05/2025 '800/269688585-5 THER, Te WAGR OO DOCUMENT i 4905.00 500 RS renneexnecams | TS inane as enabes Se ine sd icata aparece 6 ane) DEREONTOTABRTORENTO frrsmmascmoctes CONTRATO No: 1/12104000078287 MRT VAL ORIGINAL: 1 305,00 MULTA: 26,10 ENCARGOS ATRASO: 3.41 AO DIA Sone aes Yarn (St olor mcr de BV igen Ã”Ã‡Ã¶ iin Fiance ii): Ã”Ã‡Ã¿oud dae Napber Onis i4171 sone A dt Vi etry Pal 00 TIVESRCOHPADO ARTE T ROSSO OWES 500/269688585-5 ro a (9260525-1 FBiER MARIA JOSE DE LIMA Grr ss1stednis PV TIMBOZINHO,7 SACADOR /AVALISTA,â”¬Âº7690-000_ CENTRO ATALAIA AL TRIO SoA ILM IN LALA	299890	1	\N	2025-11-03 22:19:45.907	2025-11-03 22:19:45.907	{"documentType":"06 Contratos","confidence":0.9,"detectedInfo":{"ocrExtractedText":"Vorvciesiim | 656-6 | Ã”Ã‡Ã¿Yencnmwctn | 656-6 | __ 65590,00002 00264.500268 96885 839009 7 1669000130500 PARSING [oENeTaeTO 19/60 23/12/2026 ToTEPRTENTO rae PAGAVEL EM QUALQUER BANCO ATE O VENCIMENTO 2312/2028 TeiticaTconpopeNEAOARE 0001-8/1055751-2 Boercane SERA TEENS BEERS Blanco Vatorantim S/A CNPJ: 69.688.111/0001-03 0001-9/1055751-2 BOER [SURE RS Bara DS bea | OSETIENT Er Oe [SETA PROCESSES | CHT ERAT HOSED HOMERS 2evos/2025 | 02605251 a 26/05/2025 500/769688560-9 VaoRao oo 500 4 4305.00 rauTROe RECO CONTRATO NO:1/42104000076287 RENT VAL ORIGINAL: 1308.00 MULTA: 26,10 ENCARGOS ATRASO: 3,47 AO BIA spe 8 '500/260688583-9 0260525-1 Yenceonnin | 655-6 | PRGADOR MARIA JOSE DE LIMA Gr SSI AGES Py TiMaaziNHo,7 SAGAOON/AVALISTA_â”¬Âº7600-000_ CENTRO. ATALAA a POMOC A A Foncoiowrriin | 655-6 | 65590.00002 00264.500265 96885.647002 7 1700000013050 20/60 23/01/2027 PAGAVEL EM QUALQUER BANCO ATE O VENCIMENTO. â”œÂ® Ã”Ã‡Ã¿23/01/2027 SEROA | SOOIGO RENE (0004-911055751-2 Banco Votorantim SIA CNPJ: 59,588.111/0001-03 0001-9/1055751-2 2608/2025 | 0260525-1 26/05/2025 500/269688584-7 500 RS 4306.00 preaTRAS DeDRES Ã”Ã‡Ã¿CONTRATO No: 1/ 4210400078287 RATT VAL ORIGINAL: 1.305,00 MULTA: 26,10 ENCARGOS ATRASO: 3,41 AO DIA 1S 500/269668584-7 Y sancoveroraction | 655-6 | PAERDOR (MARIA JOSE DE LIMA CPF SSTSteAOHIS PY TIMBOZINHO7 ACADOR J AVALISTA â”¬Âº7690-000_ CENTRO ATALAIA a IU AA Yorncovsocnim | 655-6 | 65590,00002 00264.500265 96885.855005 9 1731000013050 21/60 23/02/2027 PAGAVEL EM QUALQUER BANCO ATE 0 VENCIMENTO, 23/02/2027 TEERGIR BOO BERERIOARS (0001-9/1055751-2 Genera RENE CODGO SENEFIORRO Banco Votorantim S/A CNPJ: 59.588.111/0001-03 001-9/1055751-2 RS 26/05/2025 | 0260525-1 ot N 26/05/2025 '800/269688585-5 THER, Te WAGR OO DOCUMENT i 4905.00 500 RS renneexnecams | TS inane as enabes Se ine sd icata aparece 6 ane) DEREONTOTABRTORENTO frrsmmascmoctes CONTRATO No: 1/12104000078287 MRT VAL ORIGINAL: 1 305,00 MULTA: 26,10 ENCARGOS ATRASO: 3.41 AO DIA Sone aes Yarn (St olor mcr de BV igen Ã”Ã‡Ã¶ iin Fiance ii): Ã”Ã‡Ã¿oud dae Napber Onis i4171 sone A dt Vi etry Pal 00 TIVESRCOHPADO ARTE T ROSSO OWES 500/269688585-5 ro a (9260525-1 FBiER MARIA JOSE DE LIMA Grr ss1stednis PV TIMBOZINHO,7 SACADOR /AVALISTA,â”¬Âº7690-000_ CENTRO ATALAIA AL TRIO SoA ILM IN LALA"},"suggestedFilename":"Contratos","ocrUsed":true,"chatGPTAnalysis":"8. Contratos"}	0.9	06 Contratos	\N	f	f	Contratos_WhatsApp_Image_2025_10_21_at_15_55_45.pdf	10
38	5	12	WhatsApp Image 2025-10-21 at 15.55.54 (1).jpeg	Contratos_WhatsApp_Image_2025_10_21_at_15_55_54__1_.pdf	06 Contratos	12	image/jpeg	251365	ocr_completed	https://yrzlxuefbxbpfndcpfqz.supabase.co/storage/v1/object/public/documents/processed/06_Contratos_766c6793.pdf	Timer | 6558 | Ã”Ã‡Ã¿Yenamenin | 655: | 65600.00002 o0264.500266 06886, 774008 6 1486000010500 dao Ã”Ã‡Ã¿29peiz026 PAGAVEL EM QUALQUER BANCO ATE 0 VENCIMENTO ee azn Rosia "Bove Vlad Si GPU 686864 0-03 Pee ot aces eevee. Ã”Ã‡Â£zaroiaoes | 02608264 peal pe gnsianes soor2ssee867-4 - Se Se sao Tooresnenetes Ã”Ã‡Ã¶Ã”Ã‡Ã¶Ã”Ã‡Ã¶Ã”Ã‡Ã¶Ã”Ã‡Ã¶] Bono coy CONTRATO No:1/12t04000078287 Rana ORS ARLENE VAL ORIGINAL: 1 308.00 MUTA: 2610 ENCARGOS ATRASO: 3.44 40 DIA [scannos Rea STORES co MARIA JOSE DELIMA Poetoee 500/21 z 1688677. Pv TimaaziNnHo7 ia oo SAEADOR/AVALSTA 57000.000 CENTRO. ATALAIA ANA smcowionntin | 655-6 | Ysmcoraccniin | 655-6 | 65590.00002 00264.500265 96885,782001 2 1516000130500 23/07/2026 _PAGAVEL EM QUALQUER BANCO ATE 0 VENCIMENTO (0001-9/1055751-2 Ã”Ã‡Ã¿Banco Volorantim S/A CNPJ: 9.588.111/0001-03 0001-9/1055751-2 26/05/2025 | 0260525-1 oF 261052025 soarzeasaes78-2 4305.00 Ba DuTRASREDUSES CCONTRATO No: +/12104000078287 RRATETS \\YAL ORIGINAL: 1 305,00 MULTA: 26,10 ENCARGOS ATRASO: 3,41 AO DIA STERN HOSS TOMER MARIA JOSE DE LIMA CPF SH STRAGEIS 500/269688578-2 Py TIMBOZINHO,7 DS DOSINENTS SACADOR/AVALISTA_â”¬Âº7600-000___ CENTRO ATALAIA nm 0260525-1 THREES ERI [IIIA Yewonsormn | 655-6 | Yoxcovsoranin | 655-6 | 65590.00002 00264.500265 96885.790004 4 1547000130500 16/60 23/08/2026 PAGAVEL EM QUALQUER BANCO ATE O VENCIMENTO. 29/08/2026 (0001-S/1055751-2 Ã”Ã‡Ã¿Banco Votorantim S/A CNPJ: 59.588.111/0001-03 Ã”Ã‡Ã¿0001-9/1055751-2 RS 2605/2025 | 0260525-1 26/05/2025 500/269688579-0 TATOOS TeecoEANGS | AATERA [SEER rSTTRCOR DSDSCERTO 1305.00] 500 RS 1305.00 ST RESCORTOTABATIENTS [rouesceactes Tommspnts | TRATION Ã”Ã‡Ã¿CONTRATO NO: 1/ 12104900078287 IRORATIRRTA Ã”Ã‡Ã¿VAL ORIGINAL: 1 305,00 MULTA: 26,10 ENCARGOS ATRASO: 3.41 A0 DIA cone Ã”Ã‡Ã¿bas Yr (Suns op pore BY Finca SA Ã”Ã‡Ã¶ Cb Fania ears) RAT NOSSO HOMERS FRB MARIA JOSE DE LIMA 500/269688579-0 PV TIMBOZINHO,7 a a SACAOOR/AVAISTA, 57690-000 CENTRO ATALAIA === LIAN NUL LUA ENP Searneâ”¬Â« Bi steaset5 AL	260930	1	\N	2025-11-03 22:19:52.712	2025-11-03 22:19:52.712	{"documentType":"06 Contratos","confidence":0.9,"detectedInfo":{"ocrExtractedText":"Timer | 6558 | Ã”Ã‡Ã¿Yenamenin | 655: | 65600.00002 o0264.500266 06886, 774008 6 1486000010500 dao Ã”Ã‡Ã¿29peiz026 PAGAVEL EM QUALQUER BANCO ATE 0 VENCIMENTO ee azn Rosia \\"Bove Vlad Si GPU 686864 0-03 Pee ot aces eevee. Ã”Ã‡Â£zaroiaoes | 02608264 peal pe gnsianes soor2ssee867-4 - Se Se sao Tooresnenetes Ã”Ã‡Ã¶Ã”Ã‡Ã¶Ã”Ã‡Ã¶Ã”Ã‡Ã¶Ã”Ã‡Ã¶] Bono coy CONTRATO No:1/12t04000078287 Rana ORS ARLENE VAL ORIGINAL: 1 308.00 MUTA: 2610 ENCARGOS ATRASO: 3.44 40 DIA [scannos Rea STORES co MARIA JOSE DELIMA Poetoee 500/21 z 1688677. Pv TimaaziNnHo7 ia oo SAEADOR/AVALSTA 57000.000 CENTRO. ATALAIA ANA smcowionntin | 655-6 | Ysmcoraccniin | 655-6 | 65590.00002 00264.500265 96885,782001 2 1516000130500 23/07/2026 _PAGAVEL EM QUALQUER BANCO ATE 0 VENCIMENTO (0001-9/1055751-2 Ã”Ã‡Ã¿Banco Volorantim S/A CNPJ: 9.588.111/0001-03 0001-9/1055751-2 26/05/2025 | 0260525-1 oF 261052025 soarzeasaes78-2 4305.00 Ba DuTRASREDUSES CCONTRATO No: +/12104000078287 RRATETS \\\\YAL ORIGINAL: 1 305,00 MULTA: 26,10 ENCARGOS ATRASO: 3,41 AO DIA STERN HOSS TOMER MARIA JOSE DE LIMA CPF SH STRAGEIS 500/269688578-2 Py TIMBOZINHO,7 DS DOSINENTS SACADOR/AVALISTA_â”¬Âº7600-000___ CENTRO ATALAIA nm 0260525-1 THREES ERI [IIIA Yewonsormn | 655-6 | Yoxcovsoranin | 655-6 | 65590.00002 00264.500265 96885.790004 4 1547000130500 16/60 23/08/2026 PAGAVEL EM QUALQUER BANCO ATE O VENCIMENTO. 29/08/2026 (0001-S/1055751-2 Ã”Ã‡Ã¿Banco Votorantim S/A CNPJ: 59.588.111/0001-03 Ã”Ã‡Ã¿0001-9/1055751-2 RS 2605/2025 | 0260525-1 26/05/2025 500/269688579-0 TATOOS TeecoEANGS | AATERA [SEER rSTTRCOR DSDSCERTO 1305.00] 500 RS 1305.00 ST RESCORTOTABATIENTS [rouesceactes Tommspnts | TRATION Ã”Ã‡Ã¿CONTRATO NO: 1/ 12104900078287 IRORATIRRTA Ã”Ã‡Ã¿VAL ORIGINAL: 1 305,00 MULTA: 26,10 ENCARGOS ATRASO: 3.41 A0 DIA cone Ã”Ã‡Ã¿bas Yr (Suns op pore BY Finca SA Ã”Ã‡Ã¶ Cb Fania ears) RAT NOSSO HOMERS FRB MARIA JOSE DE LIMA 500/269688579-0 PV TIMBOZINHO,7 a a SACAOOR/AVAISTA, 57690-000 CENTRO ATALAIA === LIAN NUL LUA ENP Searneâ”¬Â« Bi steaset5 AL"},"suggestedFilename":"Contratos","ocrUsed":true,"chatGPTAnalysis":"8. Contratos"}	0.9	06 Contratos	\N	f	f	Contratos_WhatsApp_Image_2025_10_21_at_15_55_54__1_.pdf	10
39	5	12	WhatsApp Image 2025-10-21 at 15.55.54 (2).jpeg	Contratos_WhatsApp_Image_2025_10_21_at_15_55_54__2_.pdf	06 Contratos	13	image/jpeg	247388	ocr_completed	https://yrzlxuefbxbpfndcpfqz.supabase.co/storage/v1/object/public/documents/processed/06_Contratos_43707335.pdf	Yowivanin | 665-6 | Ã”Ã‡Ã¿Yrmewwoonim | 656-6 | __65590,00002 00264500265 96885.741007 2 1340000130500 rar TERSHENTO THAT BE ROMO ETS 40/60, 23/03/2026 PAGAVEL EM GUALQUER BANCO ATE 0 VENCIMENTO 23/03/2028 Ã”Ã‡Ã¿Rasa topes penerARo raarcoRT aRRCIA COB BENE (0001-8/1055751-2, Banco Votorantim S/A CNPJ; 69,588.11 1/0001-03 (0001-9/1055751-2 TE aTATORDE a ca EP DO0 [REET DATE PROCESO RS 2ero6/2025 | 0260525-1 of N 26/05/2025 s0g/269688574-1 RORDBOSSUITEÃ”Ã‡Ã¶Ã”Ã‡Ã¶Ã”Ã‡Ã¶> TeonsameafeanTEn faonmonne Tao, TRLER TO renee 500, I 1905.00 TeuRAS DeRONEES Gem Rete TRATO NO: 1) 12104000078287 RATE ee VAL ORIGINAL: 108,00 MULITA: 26,10 ENCARGOS ATRASO: 3.41 AO OIA pee MARIA JOSE DE LIMA SHB AAS ss PV TIMBQZINHO7 Ã”Ã‡Ã¶ GABOR IAVALISTA_â”¬Âº7690:000__CENTRO ATALAIA '500/260688574-1 EFM Ã”Ã‡Ã¿Veen Ã”Ã‡Ã¿Wrncsiswrni | 655-6 | _65590.00002 00264.500265 96885.758001 1 1425000010500 11/60 PAGAVEL EM QUALQUER BANCO ATE O VENCIMENTO zaj04r2028 ano Vlora SIA GNP 56.58.11 1000-08 oor ancssrer2 me zonsizoas | oases [ot ansztas sovzae006575-8 (0001-8/1055751-2 1305.00 ea RS 1305.00 rSuTRAS DeDIEES CONTRATO No: 1 +2s04000076287 \\VAL ORIGINAL: 1.306,00 MULTA: 26 10 ENCARGOS ATRASO: 3,47 AO DIA. HRA Fraabor MARIA JOSE DE LIMA arses '500/269688575-8 ev TimeozINHo.7 Wmnoporomero SY SACADORAVAISTAâ”¬Âº7690-000 CENTRO. ATALAIA aL (0280525-1 = AMINA A Yemeni | 655-6 | Yrsncvooronin | 655-6 | $5590,00002 00264.500265 96885.766004 6 1455000130500 Ã”Ã‡Ã¿200 | 2ansr20%8 'PAGAVEL EM QUALQUER BANCO ATE 0 VENCIMENTO. sia 2yusi2026 o01-SH055751.2 Ã”Ã‡Â£Banco Votorantim S/A GNPJ:58.588.111/0001-08 Hee on aross7st 2 warepees Ã”Ã‡Â£ovosioas |" 02608261 Ã”Ã‡Â£or | Nn | 2eosaoas ['~ sooesedasre-s TATE RTE oer leery Pern var es eres perms TOESOITOTROATIENTO Tes (ates nas Gov gi io ohana egeaoAae Feuer) eTRESEONTOT ATER Cpt ae Se [rremnasmecoces ra CONTRATO NO: 1/ 1210400078287 RAT rot | \\VAL ORIGINAL: 1 305,00 MULTA: 26,10 ENCARGOS ATRASO: 3.41 AO DIA Spo ena TARTERATHOSSO NNER Faano VARIA JOSE DE LIMA PF S51 St8ABe 1S '500/269688576-8 PV TIMBOZINHO.7 enorme AVALSTA, 7890-000 __ CENTRO ATALAIA AL UAV MOTO OA AP Ss2ener	256833	1	\N	2025-11-03 22:20:02.366	2025-11-03 22:20:02.366	{"documentType":"06 Contratos","confidence":0.9,"detectedInfo":{"ocrExtractedText":"Yowivanin | 665-6 | Ã”Ã‡Ã¿Yrmewwoonim | 656-6 | __65590,00002 00264500265 96885.741007 2 1340000130500 rar TERSHENTO THAT BE ROMO ETS 40/60, 23/03/2026 PAGAVEL EM GUALQUER BANCO ATE 0 VENCIMENTO 23/03/2028 Ã”Ã‡Ã¿Rasa topes penerARo raarcoRT aRRCIA COB BENE (0001-8/1055751-2, Banco Votorantim S/A CNPJ; 69,588.11 1/0001-03 (0001-9/1055751-2 TE aTATORDE a ca EP DO0 [REET DATE PROCESO RS 2ero6/2025 | 0260525-1 of N 26/05/2025 s0g/269688574-1 RORDBOSSUITEÃ”Ã‡Ã¶Ã”Ã‡Ã¶Ã”Ã‡Ã¶> TeonsameafeanTEn faonmonne Tao, TRLER TO renee 500, I 1905.00 TeuRAS DeRONEES Gem Rete TRATO NO: 1) 12104000078287 RATE ee VAL ORIGINAL: 108,00 MULITA: 26,10 ENCARGOS ATRASO: 3.41 AO OIA pee MARIA JOSE DE LIMA SHB AAS ss PV TIMBQZINHO7 Ã”Ã‡Ã¶ GABOR IAVALISTA_â”¬Âº7690:000__CENTRO ATALAIA '500/260688574-1 EFM Ã”Ã‡Ã¿Veen Ã”Ã‡Ã¿Wrncsiswrni | 655-6 | _65590.00002 00264.500265 96885.758001 1 1425000010500 11/60 PAGAVEL EM QUALQUER BANCO ATE O VENCIMENTO zaj04r2028 ano Vlora SIA GNP 56.58.11 1000-08 oor ancssrer2 me zonsizoas | oases [ot ansztas sovzae006575-8 (0001-8/1055751-2 1305.00 ea RS 1305.00 rSuTRAS DeDIEES CONTRATO No: 1 +2s04000076287 \\\\VAL ORIGINAL: 1.306,00 MULTA: 26 10 ENCARGOS ATRASO: 3,47 AO DIA. HRA Fraabor MARIA JOSE DE LIMA arses '500/269688575-8 ev TimeozINHo.7 Wmnoporomero SY SACADORAVAISTAâ”¬Âº7690-000 CENTRO. ATALAIA aL (0280525-1 = AMINA A Yemeni | 655-6 | Yrsncvooronin | 655-6 | $5590,00002 00264.500265 96885.766004 6 1455000130500 Ã”Ã‡Ã¿200 | 2ansr20%8 'PAGAVEL EM QUALQUER BANCO ATE 0 VENCIMENTO. sia 2yusi2026 o01-SH055751.2 Ã”Ã‡Â£Banco Votorantim S/A GNPJ:58.588.111/0001-08 Hee on aross7st 2 warepees Ã”Ã‡Â£ovosioas |\\" 02608261 Ã”Ã‡Â£or | Nn | 2eosaoas ['~ sooesedasre-s TATE RTE oer leery Pern var es eres perms TOESOITOTROATIENTO Tes (ates nas Gov gi io ohana egeaoAae Feuer) eTRESEONTOT ATER Cpt ae Se [rremnasmecoces ra CONTRATO NO: 1/ 1210400078287 RAT rot | \\\\VAL ORIGINAL: 1 305,00 MULTA: 26,10 ENCARGOS ATRASO: 3.41 AO DIA Spo ena TARTERATHOSSO NNER Faano VARIA JOSE DE LIMA PF S51 St8ABe 1S '500/269688576-8 PV TIMBOZINHO.7 enorme AVALSTA, 7890-000 __ CENTRO ATALAIA AL UAV MOTO OA AP Ss2ener"},"suggestedFilename":"Contratos","ocrUsed":true,"chatGPTAnalysis":"8. Contratos"}	0.9	06 Contratos	\N	f	f	Contratos_WhatsApp_Image_2025_10_21_at_15_55_54__2_.pdf	10
40	5	12	WhatsApp Image 2025-10-21 at 15.55.54.jpeg	Contratos_WhatsApp_Image_2025_10_21_at_15_55_54.pdf	06 Contratos	14	image/jpeg	465254	ocr_completed	https://yrzlxuefbxbpfndcpfqz.supabase.co/storage/v1/object/public/documents/processed/06_Contratos_75bd48b4.pdf	Yemen | 6868 | Yrnearaconin | 655-6 | 85590,00002 00264,500266 96885.804003 4 1578000013050 46/60 23/09/2026 PAGAVEL EM QUALQUER BANCO ATE 0 VENCIMENTO 2109/2026 RSmNCA copa ReRERICARS (0001-3/1055754 2 Tero ERAT Ca aera Banco Votorantim S/A CNPJ: 59.588.414/0001-03 (0001-6/1055781-2 RS 26/05/2025 | 0360826-1 ot N 21952025 500/269688500-4 4808.00] 500 Rs n 1305.00 TOTS DEORE SRE ARES [rvsrees venueces Ã”Ã‡Ã¶Ã”Ã‡Ã¶ CONTRATO No: $/ 4204000078287 or \\VAL ORIGINAL; 1.305.00 MULTA: 26,10 ENCARGOS ATRASO: 341 AG OIA ey 500/260688500-4 9260525-1 WY vancorotrentin | 5556 | oo MARA GOSE BELA Cr BinSiaAaETS PV TIMBOZINHO,7 EAGAOOR /AVALSTAÃ”Ã‡Ã– 67000000 CENTRO. ATALAIK a UAL UT WA Ã”Ã‡Â£Yeowennt | 655.6 | 9559000008 00264 son265 96885.012008 9 1608000020500 17/60 23/10/2026 PAGAVEL EM QUALQUER BANCO ATE 0 VENCIMENTO 2anorzaz6 TaeGn] SooGSEE (0004-9/1055751-2 Banco Votorantim S/A CNPJ: 59.588,111/0001-03, (0001-9/1055751-2 26/05/2028 | 0260525-1 ot 26/05/2025 Ã”Ã‡Ã¿s00/z60688581-2 1305.00 Fas eee GONTRATO No: 1/12404000076267 RRO VAL ORIGINAL: {.205,00 MULTA: 26,10 ENCARGOS ATRASO: 3,41 AO DIA Ã”Ã‡Ã¶_Ã”Ã‡Ã¶Ã”Ã‡Ã¶Ã”Ã‡Ã¶Ã”Ã‡Ã¶ 500/269688581-2 0260525-1 Y sxvcotoren | 9856 | MARIA JOSE DE LINA CPF SaTSIaAOrIS PV TIMBOZINHO,7 VAUSTA â”¬Âº7690-000 CENTRO ATALAIA DOOM TAT Yroorsoranim | 655-6 | _65590.00002 00264.500265 96885,820009 1 16390000130500 18/60 2 3/1 1/2026 PAGAVEL EM QUALQUER BANCO ATE O VENCIMENTO 29/11/2026 (0001-9/1055751-2 SeEFCANO [aera Tots seneRCTRS Banco Volorantim S/A CNPJ: 59.588.111/0001-03, (0001-9/1085751-2 RS 26/05/2025 | 0260525-1 N 26/05/2025 '500/269688582-0 Teonoe RIERA a TaiacoRDoDOSIENTO 500. n 1905.00 [peter (oder ms rzpbes dele agus sae cuss eapoabiean bowel) IBESCONTOTABATIIENTOC [reuresceactes CONTRATO NO: 4 /12104000078287 IRORATIONTA VAL ORIGINAL: 1 305,00 MULTA: 25,10 ENCARGOS ATRASO: 3.41 AO DIA TevouTROs ACRESCIOS ans Vaan (Sree pr cre a Frc 3. Ã”Ã‡Ã¶ Ci lacie) fi $500/269688582-0 TREAD DO DOCIMENTO 0260525-1 FRGEDOR WARIA JOSE DE LIMA CPF sststeseet5 PV TIMBOZINHO,7 SACADOR AVALISTA 67690-000__ CENTRO ATALAIA A (OLOT00 0 1M AL Ss2"e	282599	1	\N	2025-11-03 22:20:10.968	2025-11-03 22:20:10.968	{"documentType":"06 Contratos","confidence":0.9,"detectedInfo":{"ocrExtractedText":"Yemen | 6868 | Yrnearaconin | 655-6 | 85590,00002 00264,500266 96885.804003 4 1578000013050 46/60 23/09/2026 PAGAVEL EM QUALQUER BANCO ATE 0 VENCIMENTO 2109/2026 RSmNCA copa ReRERICARS (0001-3/1055754 2 Tero ERAT Ca aera Banco Votorantim S/A CNPJ: 59.588.414/0001-03 (0001-6/1055781-2 RS 26/05/2025 | 0360826-1 ot N 21952025 500/269688500-4 4808.00] 500 Rs n 1305.00 TOTS DEORE SRE ARES [rvsrees venueces Ã”Ã‡Ã¶Ã”Ã‡Ã¶ CONTRATO No: $/ 4204000078287 or \\\\VAL ORIGINAL; 1.305.00 MULTA: 26,10 ENCARGOS ATRASO: 341 AG OIA ey 500/260688500-4 9260525-1 WY vancorotrentin | 5556 | oo MARA GOSE BELA Cr BinSiaAaETS PV TIMBOZINHO,7 EAGAOOR /AVALSTAÃ”Ã‡Ã– 67000000 CENTRO. ATALAIK a UAL UT WA Ã”Ã‡Â£Yeowennt | 655.6 | 9559000008 00264 son265 96885.012008 9 1608000020500 17/60 23/10/2026 PAGAVEL EM QUALQUER BANCO ATE 0 VENCIMENTO 2anorzaz6 TaeGn] SooGSEE (0004-9/1055751-2 Banco Votorantim S/A CNPJ: 59.588,111/0001-03, (0001-9/1055751-2 26/05/2028 | 0260525-1 ot 26/05/2025 Ã”Ã‡Ã¿s00/z60688581-2 1305.00 Fas eee GONTRATO No: 1/12404000076267 RRO VAL ORIGINAL: {.205,00 MULTA: 26,10 ENCARGOS ATRASO: 3,41 AO DIA Ã”Ã‡Ã¶_Ã”Ã‡Ã¶Ã”Ã‡Ã¶Ã”Ã‡Ã¶Ã”Ã‡Ã¶ 500/269688581-2 0260525-1 Y sxvcotoren | 9856 | MARIA JOSE DE LINA CPF SaTSIaAOrIS PV TIMBOZINHO,7 VAUSTA â”¬Âº7690-000 CENTRO ATALAIA DOOM TAT Yroorsoranim | 655-6 | _65590.00002 00264.500265 96885,820009 1 16390000130500 18/60 2 3/1 1/2026 PAGAVEL EM QUALQUER BANCO ATE O VENCIMENTO 29/11/2026 (0001-9/1055751-2 SeEFCANO [aera Tots seneRCTRS Banco Volorantim S/A CNPJ: 59.588.111/0001-03, (0001-9/1085751-2 RS 26/05/2025 | 0260525-1 N 26/05/2025 '500/269688582-0 Teonoe RIERA a TaiacoRDoDOSIENTO 500. n 1905.00 [peter (oder ms rzpbes dele agus sae cuss eapoabiean bowel) IBESCONTOTABATIIENTOC [reuresceactes CONTRATO NO: 4 /12104000078287 IRORATIONTA VAL ORIGINAL: 1 305,00 MULTA: 25,10 ENCARGOS ATRASO: 3.41 AO DIA TevouTROs ACRESCIOS ans Vaan (Sree pr cre a Frc 3. Ã”Ã‡Ã¶ Ci lacie) fi $500/269688582-0 TREAD DO DOCIMENTO 0260525-1 FRGEDOR WARIA JOSE DE LIMA CPF sststeseet5 PV TIMBOZINHO,7 SACADOR AVALISTA 67690-000__ CENTRO ATALAIA A (OLOT00 0 1M AL Ss2\\"e"},"suggestedFilename":"Contratos","ocrUsed":true,"chatGPTAnalysis":"8. Contratos"}	0.9	06 Contratos	\N	f	f	Contratos_WhatsApp_Image_2025_10_21_at_15_55_54.pdf	10
41	5	12	WhatsApp Image 2025-10-21 at 15.55.55 (1).jpeg	Contratos_WhatsApp_Image_2025_10_21_at_15_55_55__1_.pdf	06 Contratos	15	image/jpeg	257726	ocr_completed	https://yrzlxuefbxbpfndcpfqz.supabase.co/storage/v1/object/public/documents/processed/06_Contratos_162045c8.pdf	Wenawonam | 655-6 | Yenevawcnn | 655-6 | _ 65590,00002 00264,500266 96886,685006 1 1213000130500 FREON ive TORT BE RROETO rca 460 29/09/2026 PAGAVEL EM QUALQUER BANCO ATE O VENCIMENTO 23/09/2025 TSENGA SOC DE FEARS TEeFCURG [abre Teto BenerenS (0001-9/1055751-2 Banco Votorantim S/A CNPJ: 69.588.111/0001-09, (0001-9/1055751-2 ra or BTkDO BOS OCEMENTS we [ee Ike a RS 2065/2025 | 0260525-1 a N 26/05/2025 Soorzaasee560-5 TRSRDS SCONES tesppeanca[omTERA Ã”Ã‡Ã¶ [woes Ã”Ã‡Ã¶Ã”Ã‡Â£faumamonce Tatar [eran nanan 500 RS L 1905.00 FIDESCONTO ABATINENTO inane rere dot ea sd ocnen apenaahtae do baicsaray ae r Lees ae pPACO Gases. re VAL ORIGINAL: 1.908,00 MULTA: 26,10 ENCARGOS ATRASO: 341 A0 DIA LOTS EES ae Your Sic lop ricer dV Firs. Chit, innit. Avenida Nie Uiag4T1 Ã”Ã‡Â£Tore A Tamir Via erro Plo OFT TER CRETE CARTER HOSED WOMENS PREADOR WARIA JOBE DE LIMA gece: 500/269688568-5 PV TIMBOZINHO,7 TEST SACAOORAVALISTA,â”¬Âº7690.000 __GENTIIO ATLA 0260525-4 & TI OI eras a Le Yreneveornin | 655-6 | Yrnoveornin | 655-6 | 5590.00002 00264.500265 96885.693000 6 1240000130500 560 23110/2025 PAGAVEL EM QUALQUER BANCO ATE O VENCIMENTO zanor202s REERGR) SORT SAEFOATO DENEFOARO SGERERTEGOGO SENSORS (0001-8/1055751-2 Banco Votorantim S/A CNPJ: 59,588.11 1/0001-03 (0001-9/1055751-2 RS 26/06/2028 | 0260525-1 of N 26/05/2025 500/269688569-3 - 1305.00 inaoples (oai iowa die bin i ta ap TRESCONTSAEATRENTS 4305.00) RS CONTRATO No: 1 12104000078267 Ã”Ã‡Ã¿Z ROT VAL ORIGINAL: 1.305,00 MULTA: 26,10 ENCARGOS ATRASO: 3,41 AO DIA [PIOUTROS ACRESSOS anc Veo S.A. (Sacer oppor npr a BV Fanci S.A. ances elvan Ã”Ã‡Ã¿Av ut Noes Ulin 4171 Tone A er Vie Gere Sie Pasa O80 [eiWAoSoERAES PARDON MARIA JOSE DE LIMA Sistas 500/269688569-3 PVTIMBOZINHO? Ã”Ã‡Ã¿Wuerooovocmeto SY SACADOR/ AVAUSTA57690-000__ CENTRO. ATALAIA 9260525-1 i, ICAO A Y tancciverorntion | 655-6 | Bancovotorantn | 655-6 | 65590.00002 00264.500265 96885.707008 6 1274000130500 PRES [CITE TEAL BEPREATENTO TERRES 23/11/2025 PAGAVEL EM QUALQUER BANCO ATE O VENCIMENTO 29/11/2025 16 CORO ENEFIORRS TENEFCARO IRGENAT CONGO SEREFCRO 0004-9/1055751-2 Banco Votorantim S/A CNPJ: $8,588, 1 11/0001-03 (0001-9/1055751-2 | covszras | o2508054 a1 278/025 SoU ze508STOT RE SSR Peceepaoeaete spt eee 500 RS x 1305.00 TESCO ATEN Intends onagbes dese Duel sade ekauna exnaabideay baat) FTBESCONTOTABTHENTO TOOTS DES rrouTRas oeDORES orm CONTRATO No: 1/12104900078287 RAT TomreaRRESEaS VAL ORIGINAL: 1 306,00 MULTA: 26,10 ENCARGOS ATRASO: 3.41 AO DIA anes sae ano etrain 5.A. Susee lop por xp a UV Pans SAC, Fein lavtini) IVAN CORIO Ã”Ã‡Ã¿rei ges aan aT ne Ah ane ran pas OU . IVD EOSRO uch pest oe aes sn he cree conten ea omen ena Ã”Ã‡Ã¿CaRTERAT NOSED WOMERS FASADOR Tateaoe 18 i WARIA JOSE DE LIMA CF BTS Timens ba DoS UMENTO PY TIMBOZINHO,7 ees SAGADONIAVALETA57690-000 CENTRO ATALAIA oe eee e ALE AHP Se 2m	268628	1	\N	2025-11-03 22:20:21.613	2025-11-03 22:20:21.613	{"documentType":"06 Contratos","confidence":0.9,"detectedInfo":{"ocrExtractedText":"Wenawonam | 655-6 | Yenevawcnn | 655-6 | _ 65590,00002 00264,500266 96886,685006 1 1213000130500 FREON ive TORT BE RROETO rca 460 29/09/2026 PAGAVEL EM QUALQUER BANCO ATE O VENCIMENTO 23/09/2025 TSENGA SOC DE FEARS TEeFCURG [abre Teto BenerenS (0001-9/1055751-2 Banco Votorantim S/A CNPJ: 69.588.111/0001-09, (0001-9/1055751-2 ra or BTkDO BOS OCEMENTS we [ee Ike a RS 2065/2025 | 0260525-1 a N 26/05/2025 Soorzaasee560-5 TRSRDS SCONES tesppeanca[omTERA Ã”Ã‡Ã¶ [woes Ã”Ã‡Ã¶Ã”Ã‡Â£faumamonce Tatar [eran nanan 500 RS L 1905.00 FIDESCONTO ABATINENTO inane rere dot ea sd ocnen apenaahtae do baicsaray ae r Lees ae pPACO Gases. re VAL ORIGINAL: 1.908,00 MULTA: 26,10 ENCARGOS ATRASO: 341 A0 DIA LOTS EES ae Your Sic lop ricer dV Firs. Chit, innit. Avenida Nie Uiag4T1 Ã”Ã‡Â£Tore A Tamir Via erro Plo OFT TER CRETE CARTER HOSED WOMENS PREADOR WARIA JOBE DE LIMA gece: 500/269688568-5 PV TIMBOZINHO,7 TEST SACAOORAVALISTA,â”¬Âº7690.000 __GENTIIO ATLA 0260525-4 & TI OI eras a Le Yreneveornin | 655-6 | Yrnoveornin | 655-6 | 5590.00002 00264.500265 96885.693000 6 1240000130500 560 23110/2025 PAGAVEL EM QUALQUER BANCO ATE O VENCIMENTO zanor202s REERGR) SORT SAEFOATO DENEFOARO SGERERTEGOGO SENSORS (0001-8/1055751-2 Banco Votorantim S/A CNPJ: 59,588.11 1/0001-03 (0001-9/1055751-2 RS 26/06/2028 | 0260525-1 of N 26/05/2025 500/269688569-3 - 1305.00 inaoples (oai iowa die bin i ta ap TRESCONTSAEATRENTS 4305.00) RS CONTRATO No: 1 12104000078267 Ã”Ã‡Ã¿Z ROT VAL ORIGINAL: 1.305,00 MULTA: 26,10 ENCARGOS ATRASO: 3,41 AO DIA [PIOUTROS ACRESSOS anc Veo S.A. (Sacer oppor npr a BV Fanci S.A. ances elvan Ã”Ã‡Ã¿Av ut Noes Ulin 4171 Tone A er Vie Gere Sie Pasa O80 [eiWAoSoERAES PARDON MARIA JOSE DE LIMA Sistas 500/269688569-3 PVTIMBOZINHO? Ã”Ã‡Ã¿Wuerooovocmeto SY SACADOR/ AVAUSTA57690-000__ CENTRO. ATALAIA 9260525-1 i, ICAO A Y tancciverorntion | 655-6 | Bancovotorantn | 655-6 | 65590.00002 00264.500265 96885.707008 6 1274000130500 PRES [CITE TEAL BEPREATENTO TERRES 23/11/2025 PAGAVEL EM QUALQUER BANCO ATE O VENCIMENTO 29/11/2025 16 CORO ENEFIORRS TENEFCARO IRGENAT CONGO SEREFCRO 0004-9/1055751-2 Banco Votorantim S/A CNPJ: $8,588, 1 11/0001-03 (0001-9/1055751-2 | covszras | o2508054 a1 278/025 SoU ze508STOT RE SSR Peceepaoeaete spt eee 500 RS x 1305.00 TESCO ATEN Intends onagbes dese Duel sade ekauna exnaabideay baat) FTBESCONTOTABTHENTO TOOTS DES rrouTRas oeDORES orm CONTRATO No: 1/12104900078287 RAT TomreaRRESEaS VAL ORIGINAL: 1 306,00 MULTA: 26,10 ENCARGOS ATRASO: 3.41 AO DIA anes sae ano etrain 5.A. Susee lop por xp a UV Pans SAC, Fein lavtini) IVAN CORIO Ã”Ã‡Ã¿rei ges aan aT ne Ah ane ran pas OU . IVD EOSRO uch pest oe aes sn he cree conten ea omen ena Ã”Ã‡Ã¿CaRTERAT NOSED WOMERS FASADOR Tateaoe 18 i WARIA JOSE DE LIMA CF BTS Timens ba DoS UMENTO PY TIMBOZINHO,7 ees SAGADONIAVALETA57690-000 CENTRO ATALAIA oe eee e ALE AHP Se 2m"},"suggestedFilename":"Contratos","ocrUsed":true,"chatGPTAnalysis":"8. Contratos"}	0.9	06 Contratos	\N	f	f	Contratos_WhatsApp_Image_2025_10_21_at_15_55_55__1_.pdf	10
42	5	12	WhatsApp Image 2025-10-21 at 15.55.55 (2).jpeg	Outros_Documentos_WhatsApp_Image_2025_10_21_at_15_55_55__2_.pdf	07 Outros Documentos	16	image/jpeg	171500	ocr_completed	https://yrzlxuefbxbpfndcpfqz.supabase.co/storage/v1/object/public/documents/processed/07_Outros_Documentos_376a2a04.pdf	Anexos Ã”Ã‡Ã¿Mulio obrigado por acreditar na Darwin Seguros Faaremos sempre de tudo para vocs ter a melhor experiâ”œÂ®ncia com seu seguro. Carlos Souza Barros Firmino Freitas Founder & CO-CEO Founder & CO-CEO Geniral de Atendimenios Guvdoria: 0800 701.0512 Tolofone ou Whatsapp: (11) 9512-7210 SAC: 0800 2371 360 mal: chamaqui@darwinsoguros.com	99449	1	\N	2025-11-03 22:20:28.168	2025-11-03 22:20:28.168	{"documentType":"07 Outros Documentos","confidence":0.9,"detectedInfo":{"ocrExtractedText":"Anexos Ã”Ã‡Ã¿Mulio obrigado por acreditar na Darwin Seguros Faaremos sempre de tudo para vocs ter a melhor experiâ”œÂ®ncia com seu seguro. Carlos Souza Barros Firmino Freitas Founder & CO-CEO Founder & CO-CEO Geniral de Atendimenios Guvdoria: 0800 701.0512 Tolofone ou Whatsapp: (11) 9512-7210 SAC: 0800 2371 360 mal: chamaqui@darwinsoguros.com"},"suggestedFilename":"Outros Documentos","ocrUsed":true,"chatGPTAnalysis":"9. Outros Documentos"}	0.9	07 Outros Documentos	\N	f	f	Outros_Documentos_WhatsApp_Image_2025_10_21_at_15_55_55__2_.pdf	10
43	5	12	WhatsApp Image 2025-10-21 at 15.55.55.jpeg	Contratos_WhatsApp_Image_2025_10_21_at_15_55_55.pdf	06 Contratos	17	image/jpeg	432209	ocr_completed	https://yrzlxuefbxbpfndcpfqz.supabase.co/storage/v1/object/public/documents/processed/06_Contratos_f666bb06.pdf	Yerawvann | 655-6 | Wenewwvantn | 655-6 | _ 65500,00002 00264 5002 4.19040000130500 feo | 272025 "BAGAVEL EM QUALGUER BANCO ATE â”¬Â® VENCIMENTO pene savaaoas booraiossrsta Ã”Ã‡Â£elanco Volorantim SiA CNP: 69,5881 11/000%-03, pee poo anogers2 cl aos Ã”Ã‡Â£s/n0as | 0200825-1 eon Przeosc0es | soraoouesri-s TOT aoe a a a al : reaver Ã”Ã‡Â£paris CONTRATO NO: 1/12404000078287 RATE \\VAL ORIGINAL: 1,308.00 MULTA: 26,10 ENCARGOS ATRASO: 341 AO DIA ROSSER or MARIA JOSE DE LIMA Bistesaets '500/269688571-5 Pv TIMBOZINHO7 <AZADORJAVAUISTA, 7690-000 __ CENTRO. ATALAIA 10 ON 0 coronas | 6556 | Yenowsecnie | 655-6 | $5590,00002 00264.500265 96885.723005 2 1350000130500 Beo | 2a0ire026 PAGAVEL EM QUALQUER BANCO ATE 0 VENGIMENTO zyo12028 door siioss7st2 Ã”Ã‡Â£Banco Votorantim S/A CNPS: 59,588 111000103 eee oct a OS57S1-2 eae Ã”Ã‡Â£zovos202s | o2e0828 1 ae przansio2s | soaeessesr2s =a Tesorenes_ | TEn pen : are CONTRATO No: 1/12108000078267 RoE TE \\VAL ORIGINAL: 1.305,00 MULTA: 26,10 ENCARGOS ATRASO: 3.41 AODIA Ã”Ã‡Ã¶Ã”Ã‡Ã¶Ã”Ã‡Ã¶= STRATICS FacaDor MARIA JOSE DE UMA ECSTECaT 500/289688572-3 PV TIMBOZINHO,7 STA â”¬Âº7690-000 CENTRO. ATALAIA a (9260525-1 (00 000810 000 Wsanconsocenn Yrmcvacranim | 655-6 | 190,00002 00264.500265 96885.731008 4 1360000130500 9/60 Ã”Ã‡Â£23/02/2026 PAGAVEL EM QUALQUER BANCO ATE O VENCIMENTO. r 23/02/2026 SER SECO RNAI eran RGENEATESEGO BERGA 000-811058751-2 Ã”Ã‡Ã¿Banco Votorantim S/A CNP: 59.588,111/0001-09, 0001-9/1058751-2 RS lj 26105/2025 | 0260525-1 ot N 26/05/2025 500/269688573-1 soo | RS l 1305.00 Tomas cas eas BeIRES ETE] CONTRATO NO: 1/12104000078287 ea = OUTROS RoRESEAS \\VAL ORIGINAL: 1 305,00 MULTA: 26,10 ENCARGOS ATRASO: 3.4} AO DIA ee an Frabor MARIA JOSE DELIMA =i 500/269688673-4 BieABaTS J PY TIMBOZINHO:7 Genres s AVALSTA, 7600-000 __ CENTRO A = NH RSe2>	268970	1	\N	2025-11-03 22:20:35.714	2025-11-03 22:20:35.714	{"documentType":"06 Contratos","confidence":0.9,"detectedInfo":{"ocrExtractedText":"Yerawvann | 655-6 | Wenewwvantn | 655-6 | _ 65500,00002 00264 5002 4.19040000130500 feo | 272025 \\"BAGAVEL EM QUALGUER BANCO ATE â”¬Â® VENCIMENTO pene savaaoas booraiossrsta Ã”Ã‡Â£elanco Volorantim SiA CNP: 69,5881 11/000%-03, pee poo anogers2 cl aos Ã”Ã‡Â£s/n0as | 0200825-1 eon Przeosc0es | soraoouesri-s TOT aoe a a a al : reaver Ã”Ã‡Â£paris CONTRATO NO: 1/12404000078287 RATE \\\\VAL ORIGINAL: 1,308.00 MULTA: 26,10 ENCARGOS ATRASO: 341 AO DIA ROSSER or MARIA JOSE DE LIMA Bistesaets '500/269688571-5 Pv TIMBOZINHO7 <AZADORJAVAUISTA, 7690-000 __ CENTRO. ATALAIA 10 ON 0 coronas | 6556 | Yenowsecnie | 655-6 | $5590,00002 00264.500265 96885.723005 2 1350000130500 Beo | 2a0ire026 PAGAVEL EM QUALQUER BANCO ATE 0 VENGIMENTO zyo12028 door siioss7st2 Ã”Ã‡Â£Banco Votorantim S/A CNPS: 59,588 111000103 eee oct a OS57S1-2 eae Ã”Ã‡Â£zovos202s | o2e0828 1 ae przansio2s | soaeessesr2s =a Tesorenes_ | TEn pen : are CONTRATO No: 1/12108000078267 RoE TE \\\\VAL ORIGINAL: 1.305,00 MULTA: 26,10 ENCARGOS ATRASO: 3.41 AODIA Ã”Ã‡Ã¶Ã”Ã‡Ã¶Ã”Ã‡Ã¶= STRATICS FacaDor MARIA JOSE DE UMA ECSTECaT 500/289688572-3 PV TIMBOZINHO,7 STA â”¬Âº7690-000 CENTRO. ATALAIA a (9260525-1 (00 000810 000 Wsanconsocenn Yrmcvacranim | 655-6 | 190,00002 00264.500265 96885.731008 4 1360000130500 9/60 Ã”Ã‡Â£23/02/2026 PAGAVEL EM QUALQUER BANCO ATE O VENCIMENTO. r 23/02/2026 SER SECO RNAI eran RGENEATESEGO BERGA 000-811058751-2 Ã”Ã‡Ã¿Banco Votorantim S/A CNP: 59.588,111/0001-09, 0001-9/1058751-2 RS lj 26105/2025 | 0260525-1 ot N 26/05/2025 500/269688573-1 soo | RS l 1305.00 Tomas cas eas BeIRES ETE] CONTRATO NO: 1/12104000078287 ea = OUTROS RoRESEAS \\\\VAL ORIGINAL: 1 305,00 MULTA: 26,10 ENCARGOS ATRASO: 3.4} AO DIA ee an Frabor MARIA JOSE DELIMA =i 500/269688673-4 BieABaTS J PY TIMBOZINHO:7 Genres s AVALSTA, 7600-000 __ CENTRO A = NH RSe2>"},"suggestedFilename":"Contratos","ocrUsed":true,"chatGPTAnalysis":"8. Contratos"}	0.9	06 Contratos	\N	f	f	Contratos_WhatsApp_Image_2025_10_21_at_15_55_55.pdf	10
46	5	12	WhatsApp Image 2025-10-21 at 15.55.56.jpeg	Contrato_Oficina_para.pdf	06 Contratos	20	image/jpeg	198665	ocr_completed	https://yrzlxuefbxbpfndcpfqz.supabase.co/storage/v1/object/public/documents/processed/06_Contratos_1156b838.pdf	hn, 10: Olâ”œÂ® JOSE, agora voce â”œÂ® Darwin =) Ã”Ã‡Â£0 @ Seus dados Seu corretor Ã”Ã‡Ã¿Segurado Corretora JOSE ANTONIO DE LIMA. BV CORRETORA DE SEGUROS S.A. CPF /CNPY CPF / CNPJ Câ”œÂ®digo SUSEP 347.999,704-82 09.023.931/0001-80 Ã”Ã‡Ã¿4RAEBQABODES Email CEP de pemoite + Cbdigo de transmissâ”œÂ®o JOSELIMA590622@GMAIL.COM 57690000 2505273965662274 Seu carro Placa / Chass! Marca Modelo SJC2193 HYUNDA\\ HB20 COMFORT 1.0 FLEX 12â”¬Ã‘ Tipo de uso Codigo FIPE byes! Particular 0152153 Ã”Ã‡Ã¿Ano de Fabricago 2028 Seu contrato Bithete Namero Ã”Ã‡Ã¿Sua Seguradora Ã”Ã‡Ã¿NPS Câ”œÂ®digo FIP 01010002025060005779 Darwin Seguros S.A 44.187,990/0001-94 0459-7 Inicio Vigâ”œÂ®nois Fim Vigâ”œÂ®ncia Emissao Canal de Venda 10/08/2025 00:00:00 (09/07/2025 23:59:59 (09/06/2025 21:11:34 Corretor Classe de bonus Classe de bonus 0 Câ”œÂ®digo de identificagâ”œÂ®io (CI) 45325050509621 Seu Plano Plano Contratado Oficina para Reparo Impostos (OF) Prego do Seguro SMARTXR Rede referenciada. AS 3.46 R$ 50.32 Cobertura, Tipo de Pega para Reparo Forma de Pagamento Faixa de Prego da Renovacao MENSAL Novas originals Cartao de crâ”œÂ®dito De RS 46.92 atâ”œÂ® AS 55.36 Suas Coberturas Coberturas Basicas Limite Maximo de Indenizagao Franquia Premio alo Mensal Roubo Perda Total 100% FIPE RS 0,00 Furto Perda Total 100% FIPE RS 0,00 RS 4,90 Incâ”œÂ®ndio Perda Total 100% FIPE AS 0,00 RS 13,59 Assistâ”œÂ®ncias Limite Maximo de Indenizago Franquia Prâ”œÂ®mio Liquido Mensal 200 km 200 km Ã”Ã‡Ã¶ RS 29,63 Prego do Seguro AS 50.92	118909	1	\N	2025-11-03 22:20:51.907	2025-11-03 22:20:51.907	{"documentType":"06 Contratos","confidence":0.9,"detectedInfo":{"ocrExtractedText":"hn, 10: Olâ”œÂ® JOSE, agora voce â”œÂ® Darwin =) Ã”Ã‡Â£0 @ Seus dados Seu corretor Ã”Ã‡Ã¿Segurado Corretora JOSE ANTONIO DE LIMA. BV CORRETORA DE SEGUROS S.A. CPF /CNPY CPF / CNPJ Câ”œÂ®digo SUSEP 347.999,704-82 09.023.931/0001-80 Ã”Ã‡Ã¿4RAEBQABODES Email CEP de pemoite + Cbdigo de transmissâ”œÂ®o JOSELIMA590622@GMAIL.COM 57690000 2505273965662274 Seu carro Placa / Chass! Marca Modelo SJC2193 HYUNDA\\\\ HB20 COMFORT 1.0 FLEX 12â”¬Ã‘ Tipo de uso Codigo FIPE byes! Particular 0152153 Ã”Ã‡Ã¿Ano de Fabricago 2028 Seu contrato Bithete Namero Ã”Ã‡Ã¿Sua Seguradora Ã”Ã‡Ã¿NPS Câ”œÂ®digo FIP 01010002025060005779 Darwin Seguros S.A 44.187,990/0001-94 0459-7 Inicio Vigâ”œÂ®nois Fim Vigâ”œÂ®ncia Emissao Canal de Venda 10/08/2025 00:00:00 (09/07/2025 23:59:59 (09/06/2025 21:11:34 Corretor Classe de bonus Classe de bonus 0 Câ”œÂ®digo de identificagâ”œÂ®io (CI) 45325050509621 Seu Plano Plano Contratado Oficina para Reparo Impostos (OF) Prego do Seguro SMARTXR Rede referenciada. AS 3.46 R$ 50.32 Cobertura, Tipo de Pega para Reparo Forma de Pagamento Faixa de Prego da Renovacao MENSAL Novas originals Cartao de crâ”œÂ®dito De RS 46.92 atâ”œÂ® AS 55.36 Suas Coberturas Coberturas Basicas Limite Maximo de Indenizagao Franquia Premio alo Mensal Roubo Perda Total 100% FIPE RS 0,00 Furto Perda Total 100% FIPE RS 0,00 RS 4,90 Incâ”œÂ®ndio Perda Total 100% FIPE AS 0,00 RS 13,59 Assistâ”œÂ®ncias Limite Maximo de Indenizago Franquia Prâ”œÂ®mio Liquido Mensal 200 km 200 km Ã”Ã‡Ã¶ RS 29,63 Prego do Seguro AS 50.92"},"suggestedFilename":"Contratos","ocrUsed":true,"chatGPTAnalysis":"8. Contratos"}	0.9	06 Contratos	\N	f	f	Contrato_Oficina_para.pdf	10
47	5	12	WhatsApp Image 2025-10-21 at 15.55.57 (1).jpeg	Outros_Documentos_WhatsApp_Image_2025_10_21_at_15_55_57__1_.pdf	07 Outros Documentos	21	image/jpeg	285685	ocr_completed	https://yrzlxuefbxbpfndcpfqz.supabase.co/storage/v1/object/public/documents/processed/07_Outros_Documentos_c78c2df2.pdf	ne 11145 MOOD VAL Reo Rs 0.00 RS 0,00 RS 0,00 Rg 830,45 ANSPORTADOR / VOLUMES TRANSPORTADOS 9-SEM FRETE 2 Seo T1031 1009) 060] 5005 | on Ts0311000) 060] 540s | un eae 0 405 | DADOS ADICIOWAIS (conc Secon NS Ã”Ã‡Â£Total de tens da nota; Ã”Ã‡Ã¿Scanned with @camscanner	160475	1	\N	2025-11-03 22:20:59.567	2025-11-03 22:20:59.567	{"documentType":"07 Outros Documentos","confidence":0.9,"detectedInfo":{"ocrExtractedText":"ne 11145 MOOD VAL Reo Rs 0.00 RS 0,00 RS 0,00 Rg 830,45 ANSPORTADOR / VOLUMES TRANSPORTADOS 9-SEM FRETE 2 Seo T1031 1009) 060] 5005 | on Ts0311000) 060] 540s | un eae 0 405 | DADOS ADICIOWAIS (conc Secon NS Ã”Ã‡Â£Total de tens da nota; Ã”Ã‡Ã¿Scanned with @camscanner"},"suggestedFilename":"Outros Documentos","ocrUsed":true,"chatGPTAnalysis":"9. Outros Documentos"}	0.9	07 Outros Documentos	\N	f	f	Outros_Documentos_WhatsApp_Image_2025_10_21_at_15_55_57__1_.pdf	10
48	5	12	WhatsApp Image 2025-10-21 at 15.55.57 (2).jpeg	07 certificado de garantia.pdf	07 certificado de garantia	22	image/jpeg	261740	ocr_completed	https://yrzlxuefbxbpfndcpfqz.supabase.co/storage/v1/object/public/documents/processed/07_certificado_de_garantia_ec8219b1.pdf	@> muniz V7 Roto Center ESTE CERTIFICADO DE GARANTIA NAO TERA VALIDADE SE HOUVER MAU USO DOS PNEUS, TAIS COMO 4)USO INORRETO DA PRESSAO DE AR No PNEU 2)DANOS ACIDENTAIS COMO ROLHAS E FUROS NO NEU: 3)DESALINHAMENTO DA DIREGAO DO VEICULO OU DESBALANCEAMENTO DO CONJUNTO PNEURODA, 4)IRREGULARIDADES MECANICAS NO SISTEMA DE SUSPENSAO, AMORTECEDORES, DIREGAO E FREIOS DO VEICULO. S)INSTALAGAO DE MEDIDA DE PNEU NAO EQUIVALENTE A ORIGINAL DO VEICULO, 6)MONTAGEM E DESMONTAGEM INCORRETAS DOS PNEUS OU CONSERTOS INADEQUADOS E/OU EM LOCAL DIVERSO DA REDE MUNIZ AUTO CENTER TINSTALAGAO DE PNEU COM INDICE DE CARGA INFERIOR AO EXIGIDO PELO FABRICANTE DO VEICULO, 8)USO DE PNEU EM TERRENO INAPROPRIADO OU MA CONDUGAD: 9)CONTAMINACAO DO PNEU POR PRODUTOS QuiMicos J0)UTILIZAGAO DE PNEUS RUN FLAT EM CARROS NAO HOMOLOGADOS. 44)PRAZO DE GARANTIA PARA PEGAS E SERVICOS: 90 DIAS 12)PRAZO DE GARANTIA PARA PNEUS OFERECIDA PELO FABRICANTE CONTRA DEFEITOS DE FABRICACAO: 5 ANOS. O CERTIFICADO DE GARANTI SERVICOS INDICADOS PELA MUNIZ AUTO CENTER NA REALIZADOS POR OPQAQ 100 CLIENTE. SENDO E SOBRE SUA NECESSIDADE, CONFORME CIENCIA ABALX ae ae	151725	1	\N	2025-11-03 22:21:05.137	2025-11-03 22:21:05.137	{"documentType":"07 certificado de garantia","confidence":0.9,"detectedInfo":{"ocrExtractedText":"@> muniz V7 Roto Center ESTE CERTIFICADO DE GARANTIA NAO TERA VALIDADE SE HOUVER MAU USO DOS PNEUS, TAIS COMO 4)USO INORRETO DA PRESSAO DE AR No PNEU 2)DANOS ACIDENTAIS COMO ROLHAS E FUROS NO NEU: 3)DESALINHAMENTO DA DIREGAO DO VEICULO OU DESBALANCEAMENTO DO CONJUNTO PNEURODA, 4)IRREGULARIDADES MECANICAS NO SISTEMA DE SUSPENSAO, AMORTECEDORES, DIREGAO E FREIOS DO VEICULO. S)INSTALAGAO DE MEDIDA DE PNEU NAO EQUIVALENTE A ORIGINAL DO VEICULO, 6)MONTAGEM E DESMONTAGEM INCORRETAS DOS PNEUS OU CONSERTOS INADEQUADOS E/OU EM LOCAL DIVERSO DA REDE MUNIZ AUTO CENTER TINSTALAGAO DE PNEU COM INDICE DE CARGA INFERIOR AO EXIGIDO PELO FABRICANTE DO VEICULO, 8)USO DE PNEU EM TERRENO INAPROPRIADO OU MA CONDUGAD: 9)CONTAMINACAO DO PNEU POR PRODUTOS QuiMicos J0)UTILIZAGAO DE PNEUS RUN FLAT EM CARROS NAO HOMOLOGADOS. 44)PRAZO DE GARANTIA PARA PEGAS E SERVICOS: 90 DIAS 12)PRAZO DE GARANTIA PARA PNEUS OFERECIDA PELO FABRICANTE CONTRA DEFEITOS DE FABRICACAO: 5 ANOS. O CERTIFICADO DE GARANTI SERVICOS INDICADOS PELA MUNIZ AUTO CENTER NA REALIZADOS POR OPQAQ 100 CLIENTE. SENDO E SOBRE SUA NECESSIDADE, CONFORME CIENCIA ABALX ae ae"},"suggestedFilename":"certificado de garantia","ocrUsed":true,"chatGPTAnalysis":"9. Certificado de Garantia"}	0.9	07 certificado de garantia	\N	f	f	07 certificado de garantia.pdf	10
49	5	12	WhatsApp Image 2025-10-21 at 15.55.57 (3).jpeg	07 recibo.pdf	07 recibo	23	image/jpeg	243047	ocr_completed	https://yrzlxuefbxbpfndcpfqz.supabase.co/storage/v1/object/public/documents/processed/07_recibo_df7de707.pdf	@> muniz Auto Center NUMERO DA OS: eS oe L PRODUTOS Produto BICO VALVULA PNEU. PNEU (DUNLOP) 185/65 R15 SP SPORT Quantidade 4.00 4,00 A GARANTIA LEGAL PREVISTA NO CODIGO DO CONSUMIDOR ESTA INTRINSECA A ORDEM DE SERVICO DISPONIBILIZADA AO CONSUMIDOR NO ATO DA COMPRA. ESTOU CIENTEEDE ACORDO COM TODOS OS TERMOS E DIGOES DESTA GARANTIA DE PNEUS QUE PERDURARA PELO PRAZO DE 5 Anos PELO FABRIGANTE CONTRA DEFEITOS DE FABRICACAO. RUN ATO CENTER -MACEIO OMENA AUTO CENTER L7DA veut Mt au Hel Scanned with @ CamScanner	140276	1	\N	2025-11-03 22:21:09.807	2025-11-03 22:21:09.807	{"documentType":"07 recibo","confidence":0.9,"detectedInfo":{"ocrExtractedText":"@> muniz Auto Center NUMERO DA OS: eS oe L PRODUTOS Produto BICO VALVULA PNEU. PNEU (DUNLOP) 185/65 R15 SP SPORT Quantidade 4.00 4,00 A GARANTIA LEGAL PREVISTA NO CODIGO DO CONSUMIDOR ESTA INTRINSECA A ORDEM DE SERVICO DISPONIBILIZADA AO CONSUMIDOR NO ATO DA COMPRA. ESTOU CIENTEEDE ACORDO COM TODOS OS TERMOS E DIGOES DESTA GARANTIA DE PNEUS QUE PERDURARA PELO PRAZO DE 5 Anos PELO FABRIGANTE CONTRA DEFEITOS DE FABRICACAO. RUN ATO CENTER -MACEIO OMENA AUTO CENTER L7DA veut Mt au Hel Scanned with @ CamScanner"},"suggestedFilename":"recibo","ocrUsed":true,"chatGPTAnalysis":"9. Recibo"}	0.9	07 recibo	\N	f	f	07 recibo.pdf	10
50	5	12	WhatsApp Image 2025-10-21 at 15.55.57.jpeg	Contratos_WhatsApp_Image_2025_10_21_at_15_55_57.pdf	06 Contratos	24	image/jpeg	220510	ocr_completed	https://yrzlxuefbxbpfndcpfqz.supabase.co/storage/v1/object/public/documents/processed/06_Contratos_4c1de08d.pdf	peice SUPER CAR CONTRATO DE COMPRA E VENDA DE VEICULO USADO DAS PARTES: COMPRADOR: MARIA JOSE DE LIMA, brasileiro, inscrito no CPF:331.518.494-15 TEL (82) 98713-7630 VENDEDOR: SUPERCAR, inscrito no CNJP: 28.409.939\\001-23, AV ROTARY 623 , 623 CEP: 57052-4380 Ã”Ã‡Ã¶ Macei6/Al Ã”Ã‡Ã¶ telefone: (82)98718-2486. Marca: HYUNDAI Modelo: HB20 10M COMFORT Placa: SIC2I93. | Cor: PRATA Ã”Ã‡Ã¿Ano/Modelo: 2024 KM: | oe | Renavam: 01368028621 Combustivel: ALCOOL/GASOLINA Chassi: Valor: R$ 72.000 Forma de pagamento: DANDO ENTRADA: 15.000 MIL CARRO FORD\\FIESTA PLACA: NMD0495, 15.000 MIL DINHERO,42.000 FINANCIADO PELO BANCO BV, BV (_X_), Safra(__),ltat(__), Bradesco(__), Santander(__) Porto Seguro(_) PAN ( ) C6 (X) BRASIL () DA GARANTIA DO VEICULO: O vendedor responsabiliza-se por 90 (noventa) dias por qualquer vicio ou defeito no motor e/ou Ã”Ã‡Ã¿cambio do veiculo existente em â”œÂ®poca posterior a assinatura do contrato, desde que devidamente comprovado pela parte prejudicada. 0 vendedor â”œÂ® responsavel pelo pagamento de multa(s) de transito, imposto(s), financiamento(s) ou taxa(s) vencida(s), inclusive IPVA VENCIDO referente ao veiculo acima cujos fatos gerados tenham anteriormente a data de assinatura do presente contrato. O veiculo sera entregue emplacado 2025. DA TRANSFERENCIA DA PROPRIEDADE DO VEICULO: (_) O cliente pagarâ”œÂ® pela transferâ”œÂ®ncia e sera efetuada pelo despachante da loja.	134052	1	\N	2025-11-03 22:21:14.856	2025-11-03 22:21:14.856	{"documentType":"06 Contratos","confidence":0.9,"detectedInfo":{"ocrExtractedText":"peice SUPER CAR CONTRATO DE COMPRA E VENDA DE VEICULO USADO DAS PARTES: COMPRADOR: MARIA JOSE DE LIMA, brasileiro, inscrito no CPF:331.518.494-15 TEL (82) 98713-7630 VENDEDOR: SUPERCAR, inscrito no CNJP: 28.409.939\\\\001-23, AV ROTARY 623 , 623 CEP: 57052-4380 Ã”Ã‡Ã¶ Macei6/Al Ã”Ã‡Ã¶ telefone: (82)98718-2486. Marca: HYUNDAI Modelo: HB20 10M COMFORT Placa: SIC2I93. | Cor: PRATA Ã”Ã‡Ã¿Ano/Modelo: 2024 KM: | oe | Renavam: 01368028621 Combustivel: ALCOOL/GASOLINA Chassi: Valor: R$ 72.000 Forma de pagamento: DANDO ENTRADA: 15.000 MIL CARRO FORD\\\\FIESTA PLACA: NMD0495, 15.000 MIL DINHERO,42.000 FINANCIADO PELO BANCO BV, BV (_X_), Safra(__),ltat(__), Bradesco(__), Santander(__) Porto Seguro(_) PAN ( ) C6 (X) BRASIL () DA GARANTIA DO VEICULO: O vendedor responsabiliza-se por 90 (noventa) dias por qualquer vicio ou defeito no motor e/ou Ã”Ã‡Ã¿cambio do veiculo existente em â”œÂ®poca posterior a assinatura do contrato, desde que devidamente comprovado pela parte prejudicada. 0 vendedor â”œÂ® responsavel pelo pagamento de multa(s) de transito, imposto(s), financiamento(s) ou taxa(s) vencida(s), inclusive IPVA VENCIDO referente ao veiculo acima cujos fatos gerados tenham anteriormente a data de assinatura do presente contrato. O veiculo sera entregue emplacado 2025. DA TRANSFERENCIA DA PROPRIEDADE DO VEICULO: (_) O cliente pagarâ”œÂ® pela transferâ”œÂ®ncia e sera efetuada pelo despachante da loja.","cpf":"331.518.494-15"},"suggestedFilename":"Contratos","ocrUsed":true,"chatGPTAnalysis":"8. Contratos"}	0.9	06 Contratos	\N	f	f	Contratos_WhatsApp_Image_2025_10_21_at_15_55_57.pdf	10
62	5	12	WhatsApp Image 2025-10-21 at 15.56.01 (1).jpeg	07 recibo.pdf	07 recibo	36	image/jpeg	162760	ocr_completed	https://yrzlxuefbxbpfndcpfqz.supabase.co/storage/v1/object/public/documents/processed/07_recibo_740e2455.pdf	Shes fep EFORBLICA EEDERATI IK DO BRASIL ALIZA RENT A CAR SK 16. 670..085/0001-55| ARDOCALOCALTZA Syc2193 2023 2024 Vile dita na vender RS 64,00, 00 MARA / MOON NLD YONDAT/HB20 10M ComrorT on QBUCUSIAARPS24218 {C0060 DE HLGURAMCA CY NOMIRO CRY 233868577670 88158018400 NOMERO ATP 251012333028621 [DADA D330 00 CY 09/11/2023 yoobueT 47660 ecciie, Foe IDENTIFICACAO DO COMPRADOR Cooad be see ODE CONSULTA Liz RANG: sauricino DE DOMICLIO OU RESOENOA MIGUEL DOS MILAGRES â”¬â•— fae? Qa ercasen Ã”Ã‡Ã¿noenEcO DF DONNCRID OU RESOENOA Bens oSt emai ns 017 Tey R FELISBERTO RIAIDE 1 7540-000	168658	1	\N	2025-11-03 22:22:38.587	2025-11-03 22:22:38.587	{"documentType":"07 recibo","confidence":0.9,"detectedInfo":{"ocrExtractedText":"Shes fep EFORBLICA EEDERATI IK DO BRASIL ALIZA RENT A CAR SK 16. 670..085/0001-55| ARDOCALOCALTZA Syc2193 2023 2024 Vile dita na vender RS 64,00, 00 MARA / MOON NLD YONDAT/HB20 10M ComrorT on QBUCUSIAARPS24218 {C0060 DE HLGURAMCA CY NOMIRO CRY 233868577670 88158018400 NOMERO ATP 251012333028621 [DADA D330 00 CY 09/11/2023 yoobueT 47660 ecciie, Foe IDENTIFICACAO DO COMPRADOR Cooad be see ODE CONSULTA Liz RANG: sauricino DE DOMICLIO OU RESOENOA MIGUEL DOS MILAGRES â”¬â•— fae? Qa ercasen Ã”Ã‡Ã¿noenEcO DF DONNCRID OU RESOENOA Bens oSt emai ns 017 Tey R FELISBERTO RIAIDE 1 7540-000"},"suggestedFilename":"recibo","ocrUsed":true,"chatGPTAnalysis":"9. Recibo"}	0.9	07 recibo	\N	f	f	07 recibo.pdf	10
63	5	12	WhatsApp Image 2025-10-21 at 15.56.01.jpeg	07 contrato de compra e venda.pdf	07 contrato de compra e venda	37	image/jpeg	164508	ocr_completed	https://yrzlxuefbxbpfndcpfqz.supabase.co/storage/v1/object/public/documents/processed/07_contrato_de_compra_e_venda_1ae77595.pdf	i Reeve ca cepenativa DO BRASIL O136802R621 16.670,085/0! SIC2193 YS DELO NORTZONTE 2023 2028 : Ã”Ã‡Ã¿5 ular detlareta nn vender 64 $00,00 HYUNDAT/HB20 10". on Ã”Ã‡Ã¿QBUCUSLAARP524218 wOMRO Om {GO0IGO BE SLOUAMA CY 233868577670 98158018400 oMeeno ArT [DATA xasho 00 C8 251012333028622 09/31/2023 HeDDMETRO: 47660 spENTIFICAGA DO COMPRADOR nome BG POUSADA LTDA HORE , COM. i TOGKAVIER 37.647. 733/0001-22| aGuarL.. MARC: $2190â”¬Ã³ consuita Covad Be seURANCA Kress 729 sa une Q Rarowcaes IssORs0 30 earner SOS 034 EnolRee.17 + iz Ã”Ã‡Ã¿rent gb DE DOMICLIO OU RESIOLNCA Ee 1 Judiclivig â”¬Â½Estado de Ain cofrasm Wise inset	170587	1	\N	2025-11-03 22:22:44.311	2025-11-03 22:22:44.311	{"documentType":"07 contrato de compra e venda","confidence":0.9,"detectedInfo":{"ocrExtractedText":"i Reeve ca cepenativa DO BRASIL O136802R621 16.670,085/0! SIC2193 YS DELO NORTZONTE 2023 2028 : Ã”Ã‡Ã¿5 ular detlareta nn vender 64 $00,00 HYUNDAT/HB20 10\\". on Ã”Ã‡Ã¿QBUCUSLAARP524218 wOMRO Om {GO0IGO BE SLOUAMA CY 233868577670 98158018400 oMeeno ArT [DATA xasho 00 C8 251012333028622 09/31/2023 HeDDMETRO: 47660 spENTIFICAGA DO COMPRADOR nome BG POUSADA LTDA HORE , COM. i TOGKAVIER 37.647. 733/0001-22| aGuarL.. MARC: $2190â”¬Ã³ consuita Covad Be seURANCA Kress 729 sa une Q Rarowcaes IssORs0 30 earner SOS 034 EnolRee.17 + iz Ã”Ã‡Ã¿rent gb DE DOMICLIO OU RESIOLNCA Ee 1 Judiclivig â”¬Â½Estado de Ain cofrasm Wise inset"},"suggestedFilename":"contrato de compra e venda","ocrUsed":true,"chatGPTAnalysis":"9. Contrato de Compra e Venda"}	0.9	07 contrato de compra e venda	\N	f	f	07 contrato de compra e venda.pdf	10
64	5	12	WhatsApp Image 2025-10-21 at 16.37.31.jpeg	Contratos_WhatsApp_Image_2025_10_21_at_16_37_31.pdf	06 Contratos	38	image/jpeg	271768	ocr_completed	https://yrzlxuefbxbpfndcpfqz.supabase.co/storage/v1/object/public/documents/processed/06_Contratos_e04042f1.pdf	l@ pagame: SL " Lt Behower) 47 em | as5g Ã”Ã‡Ã¶ ee eos \\pp/e-mails com 24092005 al , nsporte e hosp Ã”Ã‡Ã¶Ã”Ã‡Ã¶ v w IMPORTANTE: estas so as principais condigdes do seu financlamento, Lela com alencdo e quarde esta via com Voo8. | Credor ou BV: Banco Votorantim S/ I: 4/0001. CEDULA DE CREDITO BANC: a: By JAv, das Nagdes Unidas, 14.171 Tome A 18 andar. Seo Pauls (.,FINANCIAMENTO DEV velcule = . Ã”Ã‡Ã¶__ =i Boman vS*_|Nâ”¬Â« da Proposta: 200438908 |VERSAO: 1 | Reconhego como valida, eficaz e vinculante essa Câ”œÂ®dula de Crâ”œÂ®dito Bancario ("CCB"), que representa o crâ”œÂ®dito bancario concedido pelo BV e reconhego, ainda, que essa CCB constitui titulo executivo extrajudicial, nos termos do artigo 28 da Lei 10.931/04. Prometo pagar ao BV, na praga da sua sede, ou a sua ordem, nas respectivas datas de vencimento, a divida em dinheiro, certa, liquida e exigivel correspondente ao Valor Total Financiado (Item B3) acrescidos dos juros remuneratorios (item G) capitalizados diariamente e ja incorporados no Valor da Parcela (item E1) Sei que (a) devo obter 0 boleto de pagamento somente nos canais de atendimento oficiais do banco BV (app BV, Minha BV, canais de atendimento) e, antes de paga-lo, devo conferir os dadas em bv.com.br/boleto; (b) posso desistir da operagao de crâ”œÂ®dito, no prazo de atâ”œÂ® 7 (sete) dias, sempre que for contratada de forma remota, fora do estabelecimento comercial, inclusive no caso de contratacao eletrâ”œÂ®nica; (c) no prazo maximo e improrrogavel de 30 (trinta) dias devo transferir o(s) bem(ns) financiado(s) para o meu nome perante o Detran, o que viabilizar o registro da garantia (alienago fiduciania); e (d) 0 descumprimento dessa obrigagdo impedira 0 BV de processar a liberacao do gravame no Detran, ainda que eu tenha quitado essa CCB. Para garantir 0 cumprimento e pagamento integral de todas as minhas obrigagdes decorrentes da operacao contratada e dessa CCB, constituo em favor do BV a propriedade fiduciaria do(s) bem(ns) financiado e descrito(s) no item A.2 e/ou anexos | e ll, conforme 361, â”¬Âº 1â”¬â–‘ e seguintes do Codigo Civil, art. 66-B da Lei 4.728/65, alterada pela Lei 10.931/04. Tenho srimento das minhas obrigagdes 0 BV podera consolidar a propriedade plena do(s) b seguintes do Codi |; e (b) essa garantia permanecera em pleno vigor atâ”œÂ® a satisfagao javel g umidas no Ambito da operacao contratada e dessa CCB. Estou ciente e de acordo que (i) no caso de atraso ou falta de pagamento das parcelas, o BV podera consolidar a propriedade do veiculo perante o Oficial do Registro de Titulos e Documentos ou orgaos executivos de transito dos Estados, sendo que eu deverei efetuar o pagamento, entregar ou disponibilizar voluntariamente o veiculo ao BV, sob pena de multa de 5% (cinco por cento) do valor da divida e (ii) no caso da nao regularizacao do saldo devedor, da nao entrega ou disponibilizagao do veiculo, o BV poder providenciar a busca e apreensdo extrajudicial deste junto ao Oficial do Registro de Titulos e Documentos ou â”œÂ®rgaos executivos de transito dos Estados. Alâ”œÂ®m disso, sel que 0 BV podera, por si ou por terceiros com mandato para agirem em seu nome, diligenciar para localizagao do veiculo e, apâ”œÂ®s a apreensdo, 0 BV podera vender o veiculo devendo (i) informar-me sobre a venda, (i) cancelar os langamentos, comunicagdes e restricâ”œÂ®es sistâ”œÂ®micas do veiculo e (iil) registrar a venda do veiculo no registro pertinente ou informar a seu respeito aos orgaos registrais competentes Declaro C is as infor s, completas e verdadeiras, faturamento (se for 0 caso) e patrimonio itratagio da operagao de crâ”œÂ®dito e emissao dessa sujeito ao disposto no art. 2â”¬â–‘ da Lel 7.115/83; (b) minha renda, foram obtidos de forma licita, estou ciente das disposigoes do art. 11, II da Lei 9. 8 e suas alterag q ide das informagdes ensejara a aplicagao das penalidades legals, especialmente as criminais, conforme ar. 19 da Lei 7.492/86 e artigos 297, 298 e 299 do Câ”œÂ®digo Penal Estou ciente que o BV colelard e tratara os meus dados pessoals de acordo com o disposto na Politica de Privacidade (Gisponivel em wwwbv.com.bripotica-de-privacidade) @, quando aplicâ”œÂ®vel, nos Termos de Uso (dlsponivel "em www,bv.com.britermo-de-uso), e sempre em conformidade com todas as leis e regulamentos aplicaveis ao tratamento de dados pessoais realizado no Brasil, Inclindo, mas nao se limtando a Lei 13.709, de 14 de agosto de 2018 e suas alleragoes posteriores. Adicionalmente, estou ciente que os meus direitos como titular de dados pessoals poderao ser exercides por meio tio Portal da Transparâ”œÂ®ncia (portaldetransparencia by.com.br/) ou outro ambiente publicamente divulgado pelo BV que venha a substitui-lo. Autorizo o BV a entrar em contato comigo por qualquer meio de comunicagao disponivel, inclusive, mas nao limitado, a ligagao telefâ”œÂ®nica ou envio de mensagens, aos telefones e enderecos informados no ambito dessa contratacao, sendo certo que, ainda que meus ntimeros e dados constem em bases de dados como "Nao Perturbe" e outras que impecam ou restrinjam o contato com clientes, 0 BV podera contatar-me para tratar de assuntos relacionados a essa contratagao. Ã”Ã‡Ã¿Autorizo o BV a consultar, utilizar e compartilhar com outras instituigdes autorizadas pelo Banco Central do Brasil dados e informagâ”œÂ®es sobre indicios de fraudes, inclusive aqueles que digam respeito a vocâ”œÂ®, a identificagao de quem teria executado ou tentado executar a fraude; a descrigao dos fatos que indicam a ocorrâ”œÂ®ncia ou tentativa de fraude; a identificagao da instituigao responsavel pelo registro dos dados e informagâ”œÂ®es. Estou ciente e de acordo que o BV podera solicitar a instalagao de rastreador veicular, sem @ cobranga de custos adicionais, Caso solicite, comprometo-me a comparecer no prazo â”œÂ® local de instalagao indicados pelo BV. Para fins da LGPD, autorizo o BV, empresas do seu conglomerado financeiro, seus parceiros, eventual cessionario ou outra instituiâ”¬Ã³ao que manifeste interesse em adquirir ou receber em garantia o crâ”œÂ®dito dessa CCB, a compartilhar meus dados pessoals e do veiculo com as empresas responsaveis pela instalagao e prestagao de servigos de rastreamento, podendo, inclusive, utilizar as informagdes rastreadas para assegurar seu direito de crâ”œÂ®dito. Adicionalmente, autorizo desde ja o BV a ceder ou transferir meu crâ”œÂ®dito e Hash aha25@ cia CCR: Rad297429b674 7A Lâ”œÂ®nd7 fer 7A7H67719A07A7ABATONT Web ADSStS VNR	289758	1	\N	2025-11-03 22:22:53.137	2025-11-03 22:22:53.137	{"documentType":"06 Contratos","confidence":0.9,"detectedInfo":{"ocrExtractedText":"l@ pagame: SL \\" Lt Behower) 47 em | as5g Ã”Ã‡Ã¶ ee eos \\\\pp/e-mails com 24092005 al , nsporte e hosp Ã”Ã‡Ã¶Ã”Ã‡Ã¶ v w IMPORTANTE: estas so as principais condigdes do seu financlamento, Lela com alencdo e quarde esta via com Voo8. | Credor ou BV: Banco Votorantim S/ I: 4/0001. CEDULA DE CREDITO BANC: a: By JAv, das Nagdes Unidas, 14.171 Tome A 18 andar. Seo Pauls (.,FINANCIAMENTO DEV velcule = . Ã”Ã‡Ã¶__ =i Boman vS*_|Nâ”¬Â« da Proposta: 200438908 |VERSAO: 1 | Reconhego como valida, eficaz e vinculante essa Câ”œÂ®dula de Crâ”œÂ®dito Bancario (\\"CCB\\"), que representa o crâ”œÂ®dito bancario concedido pelo BV e reconhego, ainda, que essa CCB constitui titulo executivo extrajudicial, nos termos do artigo 28 da Lei 10.931/04. Prometo pagar ao BV, na praga da sua sede, ou a sua ordem, nas respectivas datas de vencimento, a divida em dinheiro, certa, liquida e exigivel correspondente ao Valor Total Financiado (Item B3) acrescidos dos juros remuneratorios (item G) capitalizados diariamente e ja incorporados no Valor da Parcela (item E1) Sei que (a) devo obter 0 boleto de pagamento somente nos canais de atendimento oficiais do banco BV (app BV, Minha BV, canais de atendimento) e, antes de paga-lo, devo conferir os dadas em bv.com.br/boleto; (b) posso desistir da operagao de crâ”œÂ®dito, no prazo de atâ”œÂ® 7 (sete) dias, sempre que for contratada de forma remota, fora do estabelecimento comercial, inclusive no caso de contratacao eletrâ”œÂ®nica; (c) no prazo maximo e improrrogavel de 30 (trinta) dias devo transferir o(s) bem(ns) financiado(s) para o meu nome perante o Detran, o que viabilizar o registro da garantia (alienago fiduciania); e (d) 0 descumprimento dessa obrigagdo impedira 0 BV de processar a liberacao do gravame no Detran, ainda que eu tenha quitado essa CCB. Para garantir 0 cumprimento e pagamento integral de todas as minhas obrigagdes decorrentes da operacao contratada e dessa CCB, constituo em favor do BV a propriedade fiduciaria do(s) bem(ns) financiado e descrito(s) no item A.2 e/ou anexos | e ll, conforme 361, â”¬Âº 1â”¬â–‘ e seguintes do Codigo Civil, art. 66-B da Lei 4.728/65, alterada pela Lei 10.931/04. Tenho srimento das minhas obrigagdes 0 BV podera consolidar a propriedade plena do(s) b seguintes do Codi |; e (b) essa garantia permanecera em pleno vigor atâ”œÂ® a satisfagao javel g umidas no Ambito da operacao contratada e dessa CCB. Estou ciente e de acordo que (i) no caso de atraso ou falta de pagamento das parcelas, o BV podera consolidar a propriedade do veiculo perante o Oficial do Registro de Titulos e Documentos ou orgaos executivos de transito dos Estados, sendo que eu deverei efetuar o pagamento, entregar ou disponibilizar voluntariamente o veiculo ao BV, sob pena de multa de 5% (cinco por cento) do valor da divida e (ii) no caso da nao regularizacao do saldo devedor, da nao entrega ou disponibilizagao do veiculo, o BV poder providenciar a busca e apreensdo extrajudicial deste junto ao Oficial do Registro de Titulos e Documentos ou â”œÂ®rgaos executivos de transito dos Estados. Alâ”œÂ®m disso, sel que 0 BV podera, por si ou por terceiros com mandato para agirem em seu nome, diligenciar para localizagao do veiculo e, apâ”œÂ®s a apreensdo, 0 BV podera vender o veiculo devendo (i) informar-me sobre a venda, (i) cancelar os langamentos, comunicagdes e restricâ”œÂ®es sistâ”œÂ®micas do veiculo e (iil) registrar a venda do veiculo no registro pertinente ou informar a seu respeito aos orgaos registrais competentes Declaro C is as infor s, completas e verdadeiras, faturamento (se for 0 caso) e patrimonio itratagio da operagao de crâ”œÂ®dito e emissao dessa sujeito ao disposto no art. 2â”¬â–‘ da Lel 7.115/83; (b) minha renda, foram obtidos de forma licita, estou ciente das disposigoes do art. 11, II da Lei 9. 8 e suas alterag q ide das informagdes ensejara a aplicagao das penalidades legals, especialmente as criminais, conforme ar. 19 da Lei 7.492/86 e artigos 297, 298 e 299 do Câ”œÂ®digo Penal Estou ciente que o BV colelard e tratara os meus dados pessoals de acordo com o disposto na Politica de Privacidade (Gisponivel em wwwbv.com.bripotica-de-privacidade) @, quando aplicâ”œÂ®vel, nos Termos de Uso (dlsponivel \\"em www,bv.com.britermo-de-uso), e sempre em conformidade com todas as leis e regulamentos aplicaveis ao tratamento de dados pessoais realizado no Brasil, Inclindo, mas nao se limtando a Lei 13.709, de 14 de agosto de 2018 e suas alleragoes posteriores. Adicionalmente, estou ciente que os meus direitos como titular de dados pessoals poderao ser exercides por meio tio Portal da Transparâ”œÂ®ncia (portaldetransparencia by.com.br/) ou outro ambiente publicamente divulgado pelo BV que venha a substitui-lo. Autorizo o BV a entrar em contato comigo por qualquer meio de comunicagao disponivel, inclusive, mas nao limitado, a ligagao telefâ”œÂ®nica ou envio de mensagens, aos telefones e enderecos informados no ambito dessa contratacao, sendo certo que, ainda que meus ntimeros e dados constem em bases de dados como \\"Nao Perturbe\\" e outras que impecam ou restrinjam o contato com clientes, 0 BV podera contatar-me para tratar de assuntos relacionados a essa contratagao. Ã”Ã‡Ã¿Autorizo o BV a consultar, utilizar e compartilhar com outras instituigdes autorizadas pelo Banco Central do Brasil dados e informagâ”œÂ®es sobre indicios de fraudes, inclusive aqueles que digam respeito a vocâ”œÂ®, a identificagao de quem teria executado ou tentado executar a fraude; a descrigao dos fatos que indicam a ocorrâ”œÂ®ncia ou tentativa de fraude; a identificagao da instituigao responsavel pelo registro dos dados e informagâ”œÂ®es. Estou ciente e de acordo que o BV podera solicitar a instalagao de rastreador veicular, sem @ cobranga de custos adicionais, Caso solicite, comprometo-me a comparecer no prazo â”œÂ® local de instalagao indicados pelo BV. Para fins da LGPD, autorizo o BV, empresas do seu conglomerado financeiro, seus parceiros, eventual cessionario ou outra instituiâ”¬Ã³ao que manifeste interesse em adquirir ou receber em garantia o crâ”œÂ®dito dessa CCB, a compartilhar meus dados pessoals e do veiculo com as empresas responsaveis pela instalagao e prestagao de servigos de rastreamento, podendo, inclusive, utilizar as informagdes rastreadas para assegurar seu direito de crâ”œÂ®dito. Adicionalmente, autorizo desde ja o BV a ceder ou transferir meu crâ”œÂ®dito e Hash aha25@ cia CCR: Rad297429b674 7A Lâ”œÂ®nd7 fer 7A7H67719A07A7ABATONT Web ADSStS VNR"},"suggestedFilename":"Contratos","ocrUsed":true,"chatGPTAnalysis":"8. Contratos"}	0.9	06 Contratos	\N	f	f	Contratos_WhatsApp_Image_2025_10_21_at_16_37_31.pdf	10
65	5	12	WhatsApp Image 2025-10-21 at 16.37.56.jpeg	07 contrato de seguro.pdf	07 contrato de seguro	39	image/jpeg	174799	ocr_completed	https://yrzlxuefbxbpfndcpfqz.supabase.co/storage/v1/object/public/documents/processed/07_contrato_de_seguro_9663b672.pdf	PAGAVEL EM QUALQUER BANCO A SEGURO PROTECAO FINANCEIRA TOTAL 58590,00002 00264 500265 96886, 085006 1 2130000130500 Ã”Ã‡Ã¿As CondigOes Gerais deste seguro foram apresentadas ao segurado no momento da conlralagao, & tambâ”œÂ®m estio disponiveis no'site ot coesgerais bnpparibaseardif com bi/pf. O ANTECIPADA DA OBRIGACAO | PROTECAO AO SEGURADO - VIGENCIA A PARTIR DA LIQUIDACA\\ joberturas i art as apt lis fas, a i | aap a as 15 dias als com vinculo. 1 cio mii ite hon _ | | Aundlio Funk Mos 0s tipo Nao ha | Nâ”œÂ®o hd elacionan an coin d te pondente em ta materializa o exerci omit circunstâ”œÂ®ncias que nento do do sinist f que a assinatura di ha one: sam influir na acelt Declaro estar clente tamhâ”œÂ®m poder e emieo do proc 0 Seguro pre ropasta ov Capital Sagurado: (que voce tem deri, so vane precise do Se QUTO af nce a uote vi Pagammento de alâ”œÂ® 09 parcelas no mesmo. valor das parcelas do seu contrato de ftanclamento imkada & S250000 | Pagamento de atâ”œÂ® 03 parcelas no mesmo | valor das is do seu contrato de jclamento limitado & RS2.500,00. | | camo Tea o limite de AS 5.00000 ti a eta 018 m deverd Ser paga @ cobeta, imitado ao ( 0 Funeral, Qu a do segurado em atâ”œÂ® das Condipte ver se pra i vl recusa. 0 i ofr Oui sub nento da da propasta. 0 prâ”œÂ®mlo powventua atamente, com a restiu aslo has CondigGes Contratuals do seguro, Declara Sei que se eu, meU representant 9 valor do prâ”œÂ®mlo, card prejudicado o meu direitaÃ”Ã‡Ã–â”¬Â« siisto serd necessario entrar em cantato com dria pata Solicitar a ahertura Astra 0 Prononerte toca edn MACEI, 24 de Maio de 2025 Hash sha280 da COR: Rat2Q7420h021 Pde Aad Pec 7A2HK771 240870 92GA7OAT {Och IHAMA RRO IDR	183186	1	\N	2025-11-03 22:22:59.793	2025-11-03 22:22:59.793	{"documentType":"07 contrato de seguro","confidence":0.9,"detectedInfo":{"ocrExtractedText":"PAGAVEL EM QUALQUER BANCO A SEGURO PROTECAO FINANCEIRA TOTAL 58590,00002 00264 500265 96886, 085006 1 2130000130500 Ã”Ã‡Ã¿As CondigOes Gerais deste seguro foram apresentadas ao segurado no momento da conlralagao, & tambâ”œÂ®m estio disponiveis no'site ot coesgerais bnpparibaseardif com bi/pf. O ANTECIPADA DA OBRIGACAO | PROTECAO AO SEGURADO - VIGENCIA A PARTIR DA LIQUIDACA\\\\ joberturas i art as apt lis fas, a i | aap a as 15 dias als com vinculo. 1 cio mii ite hon _ | | Aundlio Funk Mos 0s tipo Nao ha | Nâ”œÂ®o hd elacionan an coin d te pondente em ta materializa o exerci omit circunstâ”œÂ®ncias que nento do do sinist f que a assinatura di ha one: sam influir na acelt Declaro estar clente tamhâ”œÂ®m poder e emieo do proc 0 Seguro pre ropasta ov Capital Sagurado: (que voce tem deri, so vane precise do Se QUTO af nce a uote vi Pagammento de alâ”œÂ® 09 parcelas no mesmo. valor das parcelas do seu contrato de ftanclamento imkada & S250000 | Pagamento de atâ”œÂ® 03 parcelas no mesmo | valor das is do seu contrato de jclamento limitado & RS2.500,00. | | camo Tea o limite de AS 5.00000 ti a eta 018 m deverd Ser paga @ cobeta, imitado ao ( 0 Funeral, Qu a do segurado em atâ”œÂ® das Condipte ver se pra i vl recusa. 0 i ofr Oui sub nento da da propasta. 0 prâ”œÂ®mlo powventua atamente, com a restiu aslo has CondigGes Contratuals do seguro, Declara Sei que se eu, meU representant 9 valor do prâ”œÂ®mlo, card prejudicado o meu direitaÃ”Ã‡Ã–â”¬Â« siisto serd necessario entrar em cantato com dria pata Solicitar a ahertura Astra 0 Prononerte toca edn MACEI, 24 de Maio de 2025 Hash sha280 da COR: Rat2Q7420h021 Pde Aad Pec 7A2HK771 240870 92GA7OAT {Och IHAMA RRO IDR"},"suggestedFilename":"contrato de seguro","ocrUsed":true,"chatGPTAnalysis":"9. Contrato de Seguro"}	0.9	07 contrato de seguro	\N	f	f	07 contrato de seguro.pdf	10
66	5	12	WhatsApp Image 2025-10-21 at 16.38.16.jpeg	Contratos_WhatsApp_Image_2025_10_21_at_16_38_16.pdf	06 Contratos	40	image/jpeg	120736	ocr_completed	https://yrzlxuefbxbpfndcpfqz.supabase.co/storage/v1/object/public/documents/processed/06_Contratos_69c32a30.pdf	SEGURO PROTEGAO FINANCEIRA TOTAL Js Condicdes Gerais deste sequto foram apresentadas ao sequrado no momento da ccontratapao, tambâ”œÂ®m estao disponiveis no sie condicaesgerals bnpparlbascardif. com bi/pf cage mmeMcnane Sedo asf SIS eB CNP TATU OS Paco TE Regides Metropolitana cu por cent), : (00 200 0944 DemalsLocaliades Ã”Ã‡Ã¿Cssegurador:Brasisen Compania De Sequmns CNP: 28196 889/000143 Cian SUSEP 0678'S Participagdo: 70 % (setenta Segunda a Sabato das OB as 22horas, por cento), Ã”Ã‡Ã¿$aC: 000 5 5440 Processo SUSEP:1o4l4B16860/2022-60 = Andlice: 9589-2 9589-9. Inia de Vigâ”œÂ®nla de Apdlice: anerenee Auctive: 0800 725 0645 aa tndosos me shee Fstjoulante: Banco Votorantim S/A CNP: $9.588,1/000! 03, Remuneragaa: 00% - AS 89,80 CCometora: BV Corretora de Seguros SA. CNP: 09,028 93/0001-80 Reatstra SUSEP: 202068074 femunerapdo VCS: equivalent a atâ”œÂ® 80% sobre o capital Hberado que coresponide ao valor iquido fnanclad * taxa. Disposiobes Gerais: Caso nao estela satisfeto com 2 resposta jomec ida pela SAC, ent em contato com a Ouvidaria (0800 727 2482 - Dias Utes, das Sh as 18 horas (hordrio de Bras eto feriadas ov acesse ouvidoria npparibascardifcom.br & Ã”Ã‡Ã¿tambâ”œÂ®m www consumidor.govbr. A contratayan do Seguro â”¬Ã³ opolonal. Oregistio do produto â”œÂ® automâ”œÂ®tico nao representa aprovapdo au recomendarad por parte da Susep. 0 sequrado poderd Ã”Ã‡Ã¿consultar a situagdo cadastral do cometor de seguros Ã”Ã©Â¼ fa no sitio eletrdnico wwwsusepgovibr. A aceitapao da proposta de seguro esta sujeita 4 andise do risco. AS condighes ntidade junto & SUSEP poderao ser consultadas no endereco eletrGnico www susep.gov.br de m o numero de p tant sl do tendo a seguradora a faculdade de no renavar 2 apdlice na ven em, 177410? informamos que ineidem as aliquotas de (5% de cl fragamentos destinados a planos de captalizaras, ctivo documento de cobranga, we 0 segurado ou o estipulante fe qualquer acordo data 2 indicada no re etm interpe BNP PARIBAS fall caroir Hach ahaha da COR: Roci202420H674 28d 2daa7ioe7A2HH774 AAFS7a2AR0 OLA 1OchihSS455OHIHR	126438	1	\N	2025-11-03 22:23:05.297	2025-11-03 22:23:05.297	{"documentType":"06 Contratos","confidence":0.9,"detectedInfo":{"ocrExtractedText":"SEGURO PROTEGAO FINANCEIRA TOTAL Js Condicdes Gerais deste sequto foram apresentadas ao sequrado no momento da ccontratapao, tambâ”œÂ®m estao disponiveis no sie condicaesgerals bnpparlbascardif. com bi/pf cage mmeMcnane Sedo asf SIS eB CNP TATU OS Paco TE Regides Metropolitana cu por cent), : (00 200 0944 DemalsLocaliades Ã”Ã‡Ã¿Cssegurador:Brasisen Compania De Sequmns CNP: 28196 889/000143 Cian SUSEP 0678'S Participagdo: 70 % (setenta Segunda a Sabato das OB as 22horas, por cento), Ã”Ã‡Ã¿$aC: 000 5 5440 Processo SUSEP:1o4l4B16860/2022-60 = Andlice: 9589-2 9589-9. Inia de Vigâ”œÂ®nla de Apdlice: anerenee Auctive: 0800 725 0645 aa tndosos me shee Fstjoulante: Banco Votorantim S/A CNP: $9.588,1/000! 03, Remuneragaa: 00% - AS 89,80 CCometora: BV Corretora de Seguros SA. CNP: 09,028 93/0001-80 Reatstra SUSEP: 202068074 femunerapdo VCS: equivalent a atâ”œÂ® 80% sobre o capital Hberado que coresponide ao valor iquido fnanclad * taxa. Disposiobes Gerais: Caso nao estela satisfeto com 2 resposta jomec ida pela SAC, ent em contato com a Ouvidaria (0800 727 2482 - Dias Utes, das Sh as 18 horas (hordrio de Bras eto feriadas ov acesse ouvidoria npparibascardifcom.br & Ã”Ã‡Ã¿tambâ”œÂ®m www consumidor.govbr. A contratayan do Seguro â”¬Ã³ opolonal. Oregistio do produto â”œÂ® automâ”œÂ®tico nao representa aprovapdo au recomendarad por parte da Susep. 0 sequrado poderd Ã”Ã‡Ã¿consultar a situagdo cadastral do cometor de seguros Ã”Ã©Â¼ fa no sitio eletrdnico wwwsusepgovibr. A aceitapao da proposta de seguro esta sujeita 4 andise do risco. AS condighes ntidade junto & SUSEP poderao ser consultadas no endereco eletrGnico www susep.gov.br de m o numero de p tant sl do tendo a seguradora a faculdade de no renavar 2 apdlice na ven em, 177410? informamos que ineidem as aliquotas de (5% de cl fragamentos destinados a planos de captalizaras, ctivo documento de cobranga, we 0 segurado ou o estipulante fe qualquer acordo data 2 indicada no re etm interpe BNP PARIBAS fall caroir Hach ahaha da COR: Roci202420H674 28d 2daa7ioe7A2HH774 AAFS7a2AR0 OLA 1OchihSS455OHIHR"},"suggestedFilename":"Contratos","ocrUsed":true,"chatGPTAnalysis":"8. Contratos"}	0.9	06 Contratos	\N	f	f	Contratos_WhatsApp_Image_2025_10_21_at_16_38_16.pdf	10
67	2	3	Concessâ”œÃºo da aposentadoria.pdf	07 concessâ”œÃºo de aposentadoria.pdf	07 concessâ”œÃºo de aposentadoria	3	application/pdf	147048	ocr_completed	https://yrzlxuefbxbpfndcpfqz.supabase.co/storage/v1/object/public/documents/processed/07_concessao_de_aposentadoria_a3f027ed.pdf	ATALAIA Cilede Aird CPcerte @ Tees REGIME PROPRIO OOS SERVIDGHES TITULARES DE CARGO FUBLICO DE PROVMENTO EFRTIYG E IMATIVOS TALAIA PREY Portaria ATALAIA PREV nâ”¬â–‘ 06/2023 Atalaia/AL, em 03 de Abril de 2023. Dispoe sobre a concessado do beneficio de Aposentadoria Voluntaria por Idade e Tempo de Contribuiâ”¬Ã³do - Art. 6â”¬â–‘ EC 41/2003 (Professor), em favor da servidora ROSIMEIRE ACIOLY ALBUQUERQUE. A Prefeita do Municipio de Atalaia, conjuntamente com a Diretora Presidente do REGIME PROPRIO DOS SERVIDORES TITULARES DE CARGO PUBLICO DE PROVIMENTO EFETIVO E INATIVOS - ATALAIA PREV, Estado de Alagoas no uso pleno de suas atribuicoes legais determinadas em conformidade com os dispositivos contidos na Lei Municipal n.â”¬â–‘ 904, de 05 de outubro de 2005, e na Lei Municipal n.â”¬â–‘ 1.131, de 30 de junho de 2020; RESOLVEM: Art. 1â”¬â–‘ - Conceder o beneficio de Aposentadoria Voluntaria por Idade e Tempo de Contribuicao com provertos integrais e paridade, a servidora ROSIMEIRE ACIOLY ALBUQUERQUE, portadora do RG 482980, SEDS/AL, CPF 333.164.654-72, Efetivo no cargo de PROFESSORA, Classe E, Nivel 2, Tabela 8, registrada sob a Matricula Funcional 1028, lotada na Secretaria Municipal de Educacao, nos termos do Artigo 6â”¬â–‘, incisos |, Il, Ill e IV, e Art.7â”¬â–‘da Emenda Constitucional n.â”¬â–‘ 41, de 19 de Dezembro de 2003, c/c â”¬Âº 5.â”¬â–‘ do Artigo 40 da Constituicao Federal, e Artigo 2.â”¬â–‘ da Emenda Constitucional n.â”¬â–‘ 47, de 05 de julho de 2005, Artiga 51, Incisos |, H, le lâ”¬Ã‘, e â”¬Âº Unico, c/c 0 â”¬Âº1â”¬â–‘ do Art, 30, ambos da Lei Municipal n.â”¬â–‘ 904, de 05 de outubro de 2005, conforme os documentos do ProcessoAdministrativo ATALAIA PREV - REGIME PROPRIO DOS SERVIDORES TITULARES DE CARGO PUBLICO DE PROVIMENTO EFETIVO E INATIVOS, registrado sob o numero 122/2023, a partir desta data atâ”œÂ® posterior deliberacao. Art. 2â”¬â–‘ - Esta Portaria entra em vigor na data de sua publicacao, revogadas as disposiâ”¬Ã³oes em contrario. Art. 3â”¬â–‘ Registre-se, publique-se e Cumpra-se. NA Diretora Presidente ATALAIA PREV Homologo: Prefeita Municipal Documento em conformidade cam o item 20 da anexo | da IN TCE/AL 0027/2018 Pagina 1 de 1 1	147048	1	\N	2025-11-08 00:29:04.481	2025-11-08 00:29:04.481	{"documentType":"07 concessâ”œÃºo de aposentadoria","confidence":0.9,"detectedInfo":{"ocrExtractedText":"ATALAIA Cilede Aird CPcerte @ Tees REGIME PROPRIO OOS SERVIDGHES TITULARES DE CARGO FUBLICO DE PROVMENTO EFRTIYG E IMATIVOS TALAIA PREY Portaria ATALAIA PREV nâ”¬â–‘ 06/2023 Atalaia/AL, em 03 de Abril de 2023. Dispoe sobre a concessado do beneficio de Aposentadoria Voluntaria por Idade e Tempo de Contribuiâ”¬Ã³do - Art. 6â”¬â–‘ EC 41/2003 (Professor), em favor da servidora ROSIMEIRE ACIOLY ALBUQUERQUE. A Prefeita do Municipio de Atalaia, conjuntamente com a Diretora Presidente do REGIME PROPRIO DOS SERVIDORES TITULARES DE CARGO PUBLICO DE PROVIMENTO EFETIVO E INATIVOS - ATALAIA PREV, Estado de Alagoas no uso pleno de suas atribuicoes legais determinadas em conformidade com os dispositivos contidos na Lei Municipal n.â”¬â–‘ 904, de 05 de outubro de 2005, e na Lei Municipal n.â”¬â–‘ 1.131, de 30 de junho de 2020; RESOLVEM: Art. 1â”¬â–‘ - Conceder o beneficio de Aposentadoria Voluntaria por Idade e Tempo de Contribuicao com provertos integrais e paridade, a servidora ROSIMEIRE ACIOLY ALBUQUERQUE, portadora do RG 482980, SEDS/AL, CPF 333.164.654-72, Efetivo no cargo de PROFESSORA, Classe E, Nivel 2, Tabela 8, registrada sob a Matricula Funcional 1028, lotada na Secretaria Municipal de Educacao, nos termos do Artigo 6â”¬â–‘, incisos |, Il, Ill e IV, e Art.7â”¬â–‘da Emenda Constitucional n.â”¬â–‘ 41, de 19 de Dezembro de 2003, c/c â”¬Âº 5.â”¬â–‘ do Artigo 40 da Constituicao Federal, e Artigo 2.â”¬â–‘ da Emenda Constitucional n.â”¬â–‘ 47, de 05 de julho de 2005, Artiga 51, Incisos |, H, le lâ”¬Ã‘, e â”¬Âº Unico, c/c 0 â”¬Âº1â”¬â–‘ do Art, 30, ambos da Lei Municipal n.â”¬â–‘ 904, de 05 de outubro de 2005, conforme os documentos do ProcessoAdministrativo ATALAIA PREV - REGIME PROPRIO DOS SERVIDORES TITULARES DE CARGO PUBLICO DE PROVIMENTO EFETIVO E INATIVOS, registrado sob o numero 122/2023, a partir desta data atâ”œÂ® posterior deliberacao. Art. 2â”¬â–‘ - Esta Portaria entra em vigor na data de sua publicacao, revogadas as disposiâ”¬Ã³oes em contrario. Art. 3â”¬â–‘ Registre-se, publique-se e Cumpra-se. NA Diretora Presidente ATALAIA PREV Homologo: Prefeita Municipal Documento em conformidade cam o item 20 da anexo | da IN TCE/AL 0027/2018 Pagina 1 de 1 1","cpf":"333.164.654-72","rg":"482980"},"suggestedFilename":"concessâ”œÃºo de aposentadoria","ocrUsed":true,"chatGPTAnalysis":"9. Concessâ”œÃºo de Aposentadoria"}	0.9	07 concessâ”œÃºo de aposentadoria	\N	f	f	07 concessâ”œÃºo de aposentadoria.pdf	3
68	2	3	IMG-20251030-WA0009.jpg	07 ficha financeira individual.pdf	07 ficha financeira individual	4	image/jpeg	160363	ocr_completed	https://yrzlxuefbxbpfndcpfqz.supabase.co/storage/v1/object/public/documents/processed/07_ficha_financeira_individual_dd2f2ade.pdf	PREFEITURA MUNICIPAL DE ATALAIA 12.200.143/0001-26 Pag. 1.21 - FICHA FINANCEIRA INDIVIDUAI INCIONARIO - 1028 ROSIMEIRE ACTOLY ALB| SIT, FUNCIONARTO - TODOS SS FUNCIONARIO: 1028 - ROSIMEIRE ACIOLY ALBUQUERQUE SEXO......: Feminino CARGO. . ENDEREGO... Ne, BAIRRO SECRETARIA.: SZC, EDUCACAO ADMISSAO..: 36/03/1993 c.cusTo: NDAMENTAL EOTACAO....: ESCOLA MUNICIPAL FRANCISCO DE ALBUQUERQUE PONTES NASCIMENTO: 31/07/1962 VINCULO: Estatutario MATURAL....: ATALATA/AL CPF... 164.654-72 RG.....: 482980 PIS/PASEP: 17023285219 7. ADMISSAO: Efetivo DEP. IRRF,: 0 DEP. SF: 0 REFERENCIA.: 01/2022 & 12/2022 STTUAGKO..: ATIVO PROVENTOS OCORRENCTA TAN FEV DEcTa] 0,00 0,0 2,00 0,00 0,00 0,00 0,00 0,00 0,00 0,00 TOTAL OCORRENCIA: 7.185,50 9.580,66 7 10.634,54 8.335,18 9 8 3.047 Aes: oe DESCONTOS Ã”Ã‡Ã¿OCORRENCTA TAN FEV MAR ABR MAT JON Ã”Ã‡Ã¿ouL Ã”Ã‡Ã¿aco Ser our Nov EZ DecIMo| 344 - ATALATA 1.005)97 1,005,97 1.005,97 2.005,9 468,83 1.126,68 1.1 1,126,682 0,00 05 - CONSIGNACAO CEF 540,10 1.540,10 1.540,10 1.540,10 540,10 1,540,120 1,840,10 1.540,10 2 0,00 1.033,93 0,00 o1- 830,01 830,01 365,84 830,01 645,71 1,112,871 i Ã”Ã‡Â£3 20 >, 00 2.00 0,00 2.033,93 01 Ã”Ã‡Ã¶ 23 TRRE 0,00 0,00 0,00 0,00 0,00 9,00 0,00 : " a= 0,00 6,00 0,00 0,00 9,00 0,00 4,00 0,00 0,00 0,00 1,126, 68 7 n 3 00,71 3.700,71 438,42 2.260,62 TOTAL OCORRENCIA: 3.376, 08 3.376,08 4.674, 64 4.069,57 3,700.72 3.700 700, 4.438,42 2.160; TOTAL GERAL 561,58 10.561,58 15,309,18 12 13.450, 62 11,748,47 12,748,47 12,748,47 12,748,47 15.268,77 10.208, : = 8 0s 887, 2 orah foro; 3.809,42 3.909;42 6.167,75 2.80942 .959,90 4.558,49 â”¬Âº,218;48 4947405 4a0me08 AA84 4,347,083 6.291,93 5.88 Aaa vivway SOMA 5 OA1942 CINSYHADYE 30 ODIIENE Obuy> sO SauVINLIA ZAVOOIANRS SOO ClUsOUs BHIOAY	165559	1	\N	2025-11-08 00:29:10.585	2025-11-08 00:29:10.585	{"documentType":"07 ficha financeira individual","confidence":0.9,"detectedInfo":{"ocrExtractedText":"PREFEITURA MUNICIPAL DE ATALAIA 12.200.143/0001-26 Pag. 1.21 - FICHA FINANCEIRA INDIVIDUAI INCIONARIO - 1028 ROSIMEIRE ACTOLY ALB| SIT, FUNCIONARTO - TODOS SS FUNCIONARIO: 1028 - ROSIMEIRE ACIOLY ALBUQUERQUE SEXO......: Feminino CARGO. . ENDEREGO... Ne, BAIRRO SECRETARIA.: SZC, EDUCACAO ADMISSAO..: 36/03/1993 c.cusTo: NDAMENTAL EOTACAO....: ESCOLA MUNICIPAL FRANCISCO DE ALBUQUERQUE PONTES NASCIMENTO: 31/07/1962 VINCULO: Estatutario MATURAL....: ATALATA/AL CPF... 164.654-72 RG.....: 482980 PIS/PASEP: 17023285219 7. ADMISSAO: Efetivo DEP. IRRF,: 0 DEP. SF: 0 REFERENCIA.: 01/2022 & 12/2022 STTUAGKO..: ATIVO PROVENTOS OCORRENCTA TAN FEV DEcTa] 0,00 0,0 2,00 0,00 0,00 0,00 0,00 0,00 0,00 0,00 TOTAL OCORRENCIA: 7.185,50 9.580,66 7 10.634,54 8.335,18 9 8 3.047 Aes: oe DESCONTOS Ã”Ã‡Ã¿OCORRENCTA TAN FEV MAR ABR MAT JON Ã”Ã‡Ã¿ouL Ã”Ã‡Ã¿aco Ser our Nov EZ DecIMo| 344 - ATALATA 1.005)97 1,005,97 1.005,97 2.005,9 468,83 1.126,68 1.1 1,126,682 0,00 05 - CONSIGNACAO CEF 540,10 1.540,10 1.540,10 1.540,10 540,10 1,540,120 1,840,10 1.540,10 2 0,00 1.033,93 0,00 o1- 830,01 830,01 365,84 830,01 645,71 1,112,871 i Ã”Ã‡Â£3 20 >, 00 2.00 0,00 2.033,93 01 Ã”Ã‡Ã¶ 23 TRRE 0,00 0,00 0,00 0,00 0,00 9,00 0,00 : \\" a= 0,00 6,00 0,00 0,00 9,00 0,00 4,00 0,00 0,00 0,00 1,126, 68 7 n 3 00,71 3.700,71 438,42 2.260,62 TOTAL OCORRENCIA: 3.376, 08 3.376,08 4.674, 64 4.069,57 3,700.72 3.700 700, 4.438,42 2.160; TOTAL GERAL 561,58 10.561,58 15,309,18 12 13.450, 62 11,748,47 12,748,47 12,748,47 12,748,47 15.268,77 10.208, : = 8 0s 887, 2 orah foro; 3.809,42 3.909;42 6.167,75 2.80942 .959,90 4.558,49 â”¬Âº,218;48 4947405 4a0me08 AA84 4,347,083 6.291,93 5.88 Aaa vivway SOMA 5 OA1942 CINSYHADYE 30 ODIIENE Obuy> sO SauVINLIA ZAVOOIANRS SOO ClUsOUs BHIOAY"},"suggestedFilename":"ficha financeira individual","ocrUsed":true,"chatGPTAnalysis":"9. Ficha Financeira Individual"}	0.9	07 ficha financeira individual	\N	f	f	07 ficha financeira individual.pdf	3
69	2	3	IMG-20251030-WA0011.jpg	07 ficha financeira.pdf	07 ficha financeira	5	image/jpeg	323891	ocr_completed	https://yrzlxuefbxbpfndcpfqz.supabase.co/storage/v1/object/public/documents/processed/07_ficha_financeira_a71de900.pdf	PREFEITURA MUNICIPAL DE ATALATA 12.200.143/0001-26 Pag. : if 42 - FICHA FINANCEIRA INDIVIDUAy Data: 19/02/2020 13:26:19 FUNULUNARLO = 102% RUSIMELKE ACLULY ALBUUUSKUL SIT, FUNCIONARIO - TODOS FUNCIONARIO: 1028 - ROSTMEIRE ACTOLY Al SEXO... Uescnlane eee. END) ce EREGO. Ne. a BARRO. : HCI EDUCACAO ch 30/03/ mae - SECRETARIA. EDUCACA ADMESSAO..: 30/03/1963 C.cusTO: FUNDES - 60% ENSTNO FUNDAMENTA LOTAGAO....: ESCOLA MUNICIPAL FRANCTSC BUQUERQUE PONTES NASCIMENTO: VINCULO: Estatutario NATURAL. ne 3 CPF. Ã”Ã‡Ã¿RG. PIS/PASEP: 1 T. ADMISsio: Efetivo DEP. IRRF.: 0 DEP. SF: 0 REFERENCIA.: 01/2019 a 12/2019 SETUAGAO..: ATIVO PROVENTOS OCORRENCIA JAN FEV MAR ABR MAT uN a) our Ã”Ã‡Ã¿Nov Ã”Ã‡Ã¿DER Peete a jaa = at 0c aaa ? sastee $76 ~ DEVOLUCAO IR DO 1/6 0,00 ( ,00 0,00 403 - GRAT. INCORPORADA 408 2. 0,00 06 9,0 9,00 â”¬â•—, 00 9,00 393 - GRATIFICACAO INCORPORADA 708 031,78 5.041, 5,031,718 5.031,78 $.032,78 a 78 100 ~ PROvENTOS 7.188, 1a 1.198,27 188, 28, 28, 188,27 171 ~ 13â”¬â–‘ SALARIO 0,00 0,00 00 at i 0, 0 TOTAL OCORKENCIA 10.524,82 12,220,051 ary v 5 12.220, 2 z i DESCONTOS (OCORRENCIA a a Ã”Ã‡Â£gat Ã”Ã‡Ã˜*COFEV MAR ABR MAL uN oon, aco. our pez kero | 344 Ã”Ã‡Ã¶ ATALATA PREV 7.106,89 1.344,20 1.344, 20 1,344,20 1.344 Tat, Fi 1.344,20 0,00 205 - CONSIGNACAO CEF 1.540,11 1.540,11 1.540/12 1,540,121 1,540,11 1,540,122 1.840,22-1.540,2 1.540, 12 0,00 301 - IRRF 4.593,69 2.121,49 2,321,49 â”¬Â® 2-121,49 2.121, 49 21,49 2.121,49 â”¬Â® 2.221,492.221,49 2 2.128449 0,00 344 - 13 ATALAIA PREV 0,00 0,00 0,00 0,00 0,00 0,00 0,00 0,00 0,00 0,00 790,70 301 - 13 IRRF 0,00 0,00 0,00 0,00 0,00 0,00 0,00 0,00 0,00 0,00 0,00 2.273, 71 mount ObonBRNCIA 40240,75" 57005/60 9-005/@0 8.005,80. 5.005,80 9,008;80 x00 5.005,80 5.005,80 3.005,80 5.005,80 3,064,432 Pas Ty ee ee 3,85 17.225,85 17.225,85 18.054,51 25.284, 46 mOTAL L{QUIDO = 6. 284,03 7.214,25 7.214,25 7.214, 25 14,25 7.214,2 7.214, 25 7.224,25 7,214,25 7.214, 25 HBL, 25 8.042, 91 9.155, 64 Ã”Ã‡Ã¶ agua virwiy SONLViI â”¬Â« CALB9a OLNSMNAOWSs 30 CDIIENE OoUY> BO SauVINAIs SAVOOIANAS SOO C1UdONd ANIORY	180728	1	\N	2025-11-08 00:29:45.374	2025-11-08 00:29:45.374	{"documentType":"07 ficha financeira","confidence":0.9,"detectedInfo":{"ocrExtractedText":"PREFEITURA MUNICIPAL DE ATALATA 12.200.143/0001-26 Pag. : if 42 - FICHA FINANCEIRA INDIVIDUAy Data: 19/02/2020 13:26:19 FUNULUNARLO = 102% RUSIMELKE ACLULY ALBUUUSKUL SIT, FUNCIONARIO - TODOS FUNCIONARIO: 1028 - ROSTMEIRE ACTOLY Al SEXO... Uescnlane eee. END) ce EREGO. Ne. a BARRO. : HCI EDUCACAO ch 30/03/ mae - SECRETARIA. EDUCACA ADMESSAO..: 30/03/1963 C.cusTO: FUNDES - 60% ENSTNO FUNDAMENTA LOTAGAO....: ESCOLA MUNICIPAL FRANCTSC BUQUERQUE PONTES NASCIMENTO: VINCULO: Estatutario NATURAL. ne 3 CPF. Ã”Ã‡Ã¿RG. PIS/PASEP: 1 T. ADMISsio: Efetivo DEP. IRRF.: 0 DEP. SF: 0 REFERENCIA.: 01/2019 a 12/2019 SETUAGAO..: ATIVO PROVENTOS OCORRENCIA JAN FEV MAR ABR MAT uN a) our Ã”Ã‡Ã¿Nov Ã”Ã‡Ã¿DER Peete a jaa = at 0c aaa ? sastee $76 ~ DEVOLUCAO IR DO 1/6 0,00 ( ,00 0,00 403 - GRAT. INCORPORADA 408 2. 0,00 06 9,0 9,00 â”¬â•—, 00 9,00 393 - GRATIFICACAO INCORPORADA 708 031,78 5.041, 5,031,718 5.031,78 $.032,78 a 78 100 ~ PROvENTOS 7.188, 1a 1.198,27 188, 28, 28, 188,27 171 ~ 13â”¬â–‘ SALARIO 0,00 0,00 00 at i 0, 0 TOTAL OCORKENCIA 10.524,82 12,220,051 ary v 5 12.220, 2 z i DESCONTOS (OCORRENCIA a a Ã”Ã‡Â£gat Ã”Ã‡Ã˜*COFEV MAR ABR MAL uN oon, aco. our pez kero | 344 Ã”Ã‡Ã¶ ATALATA PREV 7.106,89 1.344,20 1.344, 20 1,344,20 1.344 Tat, Fi 1.344,20 0,00 205 - CONSIGNACAO CEF 1.540,11 1.540,11 1.540/12 1,540,121 1,540,11 1,540,122 1.840,22-1.540,2 1.540, 12 0,00 301 - IRRF 4.593,69 2.121,49 2,321,49 â”¬Â® 2-121,49 2.121, 49 21,49 2.121,49 â”¬Â® 2.221,492.221,49 2 2.128449 0,00 344 - 13 ATALAIA PREV 0,00 0,00 0,00 0,00 0,00 0,00 0,00 0,00 0,00 0,00 790,70 301 - 13 IRRF 0,00 0,00 0,00 0,00 0,00 0,00 0,00 0,00 0,00 0,00 0,00 2.273, 71 mount ObonBRNCIA 40240,75\\" 57005/60 9-005/@0 8.005,80. 5.005,80 9,008;80 x00 5.005,80 5.005,80 3.005,80 5.005,80 3,064,432 Pas Ty ee ee 3,85 17.225,85 17.225,85 18.054,51 25.284, 46 mOTAL L{QUIDO = 6. 284,03 7.214,25 7.214,25 7.214, 25 14,25 7.214,2 7.214, 25 7.224,25 7,214,25 7.214, 25 HBL, 25 8.042, 91 9.155, 64 Ã”Ã‡Ã¶ agua virwiy SONLViI â”¬Â« CALB9a OLNSMNAOWSs 30 CDIIENE OoUY> BO SauVINAIs SAVOOIANAS SOO C1UdONd ANIORY"},"suggestedFilename":"ficha financeira","ocrUsed":true,"chatGPTAnalysis":"9. Ficha Financeira"}	0.9	07 ficha financeira	\N	f	f	07 ficha financeira.pdf	3
70	2	3	IMG-20251030-WA0012.jpg	07 ficha financeira individual.pdf	07 ficha financeira individual	6	image/jpeg	285747	ocr_completed	https://yrzlxuefbxbpfndcpfqz.supabase.co/storage/v1/object/public/documents/processed/07_ficha_financeira_individual_d674ba7c.pdf	PREFEITURA MUNICIPAL DE ATALAIA 12.200.147/0001-26 1,21 - FICHA FINANCEIRA INDIVIDUAL UNCIONARIO - 1028 ROSIM ACTOLY ALBUQUEROUE SIT. FUNCTONARTO = 7 FUNCIONARIO: 1028 ENDERECO. SECRETARIA.: SEC SEXO CARGO Weak BATRRO ADMISSKO C.cUSTO: FUNDER - 70% 10 FUNDAMEN LOTAGKO....: ESCOLA MU NASCIMENTO 1962 VINCULO i NATURAL....: ATALATA/AL CPF 164.654-72 BG 4 PIS/PASEP: 17023285219 1. ADMISSAO: Efetivo DEP. IRRF.: 0 DEP. SF: REFERENCIA.: 01/2017 8 12/201 SYTUACAO PROVENTOS Ã”Ã‡Ã¿OCORRENCTA Ey FEV WAR BR MAT oN Ea G0 Ser our nov, DE dâ”œÂ®crwo| wee 25670; 20 670 70,20 2 3 a o,00 pasconros oconsicaa nT ee a a i ss : 88, 88,19 9 88,19 48,19 aa,19 88,19 88,19 48,19 34g ~ 13 ATAIAIA PREV 9,00 0,00 2.0 : ce go. ~ 13 TRF 000,08 0,00 0 : Ã”Ã‡Ã¿ : ETC Teer 8769 TOTAL LiQuiDo: 6.494, 5.272, 38 Ã”Ã‡Ã¿ 1,3 5 EEE	177324	1	\N	2025-11-08 00:29:49.022	2025-11-08 00:29:49.022	{"documentType":"07 ficha financeira individual","confidence":0.9,"detectedInfo":{"ocrExtractedText":"PREFEITURA MUNICIPAL DE ATALAIA 12.200.147/0001-26 1,21 - FICHA FINANCEIRA INDIVIDUAL UNCIONARIO - 1028 ROSIM ACTOLY ALBUQUEROUE SIT. FUNCTONARTO = 7 FUNCIONARIO: 1028 ENDERECO. SECRETARIA.: SEC SEXO CARGO Weak BATRRO ADMISSKO C.cUSTO: FUNDER - 70% 10 FUNDAMEN LOTAGKO....: ESCOLA MU NASCIMENTO 1962 VINCULO i NATURAL....: ATALATA/AL CPF 164.654-72 BG 4 PIS/PASEP: 17023285219 1. ADMISSAO: Efetivo DEP. IRRF.: 0 DEP. SF: REFERENCIA.: 01/2017 8 12/201 SYTUACAO PROVENTOS Ã”Ã‡Ã¿OCORRENCTA Ey FEV WAR BR MAT oN Ea G0 Ser our nov, DE dâ”œÂ®crwo| wee 25670; 20 670 70,20 2 3 a o,00 pasconros oconsicaa nT ee a a i ss : 88, 88,19 9 88,19 48,19 aa,19 88,19 88,19 48,19 34g ~ 13 ATAIAIA PREV 9,00 0,00 2.0 : ce go. ~ 13 TRF 000,08 0,00 0 : Ã”Ã‡Ã¿ : ETC Teer 8769 TOTAL LiQuiDo: 6.494, 5.272, 38 Ã”Ã‡Ã¿ 1,3 5 EEE"},"suggestedFilename":"ficha financeira individual","ocrUsed":true,"chatGPTAnalysis":"9. Ficha Financeira Individual"}	0.9	07 ficha financeira individual	\N	f	f	07 ficha financeira individual.pdf	3
71	2	3	IMG-20251030-WA0013.jpg	07 contracheque.pdf	07 contracheque	7	image/jpeg	106136	ocr_completed	https://yrzlxuefbxbpfndcpfqz.supabase.co/storage/v1/object/public/documents/processed/07_contracheque_468235cf.pdf	PREFEITURA MUNICIPAL DE ATALAIA 12,200.143/0001-26 Pag 1 Ã”Ã‡Â£ICHA FINANCEIRA INDIVIDUAL FUNCIONARIO: 1028 - ROSIN I QUERGL SEXO, ENDERECO BAIRRO SECRETARIA.: ED ADMISSAO 0 8 c.cusTo - 7 SI LOTACAO A sco L i E NASCIMENTO. 1196: VINCULO: Bstatutar WATURAL, AT a CRF. 333.164.654-72 RG 45298 219 T. ADMISSAO: Efe DEP, IRRF. DEP. SF: REFERENCIA. 23 A 12/2023 SITUAGKO..: ATIYC PROVENTOS OCORRENCTA ony FEV MAR ABR MAT oN UL SET our Nov DEZ acm, ENT â”¬â–‘ . Ã”Ã‡Ã¿TOTAL OCORRENCIA SCONTOS OCORRENCIA sas FEV MAR ABR MAT JON JuL ser Nov EZ necro | TOTAL OCORRENCTA am 0 . 0 0 0 0 6 Ã”Ã‡Ã¿TOTAL GERAL 48,4 a 4 , 09 i : TOTAL LiguiDo 4.34 47, 00 a,c 4,0 mM 0 9 " eC. eee	107701	1	\N	2025-11-08 00:29:51.887	2025-11-08 00:29:51.887	{"documentType":"07 contracheque","confidence":0.9,"detectedInfo":{"ocrExtractedText":"PREFEITURA MUNICIPAL DE ATALAIA 12,200.143/0001-26 Pag 1 Ã”Ã‡Â£ICHA FINANCEIRA INDIVIDUAL FUNCIONARIO: 1028 - ROSIN I QUERGL SEXO, ENDERECO BAIRRO SECRETARIA.: ED ADMISSAO 0 8 c.cusTo - 7 SI LOTACAO A sco L i E NASCIMENTO. 1196: VINCULO: Bstatutar WATURAL, AT a CRF. 333.164.654-72 RG 45298 219 T. ADMISSAO: Efe DEP, IRRF. DEP. SF: REFERENCIA. 23 A 12/2023 SITUAGKO..: ATIYC PROVENTOS OCORRENCTA ony FEV MAR ABR MAT oN UL SET our Nov DEZ acm, ENT â”¬â–‘ . Ã”Ã‡Ã¿TOTAL OCORRENCIA SCONTOS OCORRENCIA sas FEV MAR ABR MAT JON JuL ser Nov EZ necro | TOTAL OCORRENCTA am 0 . 0 0 0 0 6 Ã”Ã‡Ã¿TOTAL GERAL 48,4 a 4 , 09 i : TOTAL LiguiDo 4.34 47, 00 a,c 4,0 mM 0 9 \\" eC. eee","rg":"45298"},"suggestedFilename":"contracheque","ocrUsed":true,"chatGPTAnalysis":"9. Contracheque"}	0.9	07 contracheque	\N	f	f	07 contracheque.pdf	3
72	2	3	IMG-20251030-WA0014.jpg	07 declaraâ”œÂºâ”œÃºo de fâ”œÂ®rias.pdf	07 declaraâ”œÂºâ”œÃºo de fâ”œÂ®rias	8	image/jpeg	156680	ocr_completed	https://yrzlxuefbxbpfndcpfqz.supabase.co/storage/v1/object/public/documents/processed/07_declaracao_de_ferias_26a1c1a0.pdf	Estado de Alagoas 5 Prefeitura Municipal de Atalaia SERVIGO DE ADMINISTRAGAO SETOR PESSOAL ROSINETRE ACTOLI A Ã”Ã‡Ã¿ Wen do Servidor Ã”Ã‡Â£eee BOAO: AUBUG! I Matricula; Data da Admiss&o;__ 30.93.83... Data do ee Histosios nn idico unico de acordo com lei N& 774/93 de 16.12.0936 Fob concedida suas fâ”œÂ®rias regulamentares a que tem direito referente ao pâ”œÂ®riodo 91/92, ver proc. Nâ”¬Â« 136/940 fâ”œÂ®rias regulamentares @ ae /93: ver proc 92/9 pro o pâ”œÂ®ric 05.01.95 Foi concedida suas fâ”œÂ®rias reguaamentares a que tem @ireito, referente a0 pâ”œÂ®riodo de 93/94: ver: proCe Ee i 30/95 a ~ 06.07.95 Foi comcedide suas fâ”œÂ®rias regulameatares a que tem @ireito referente 20 ano de 94/95. Ver. Proe. de Nâ”¬Â« 473/85. de H2 1.374/99 amento de sa ao 31.06.99 | Foi concedido suas, fâ”œÂ®xas regulamentares referente | ao perfodo 97/98. Vere (Brot. We 2.346/99. 28509099 Poi concedido suas eee regulamentares referente ao perfodo 97/98. Ver. Prot. de N@ 1. 484/99. g28-09-99] Foi concedido suas fâ”œÂ®rias regulamentares referente perfodo de 98/99. Vero Prot. de Nâ”¬Â« 1485/99.	161761	1	\N	2025-11-08 00:29:55.399	2025-11-08 00:29:55.399	{"documentType":"07 declaraâ”œÂºâ”œÃºo de fâ”œÂ®rias","confidence":0.9,"detectedInfo":{"ocrExtractedText":"Estado de Alagoas 5 Prefeitura Municipal de Atalaia SERVIGO DE ADMINISTRAGAO SETOR PESSOAL ROSINETRE ACTOLI A Ã”Ã‡Ã¿ Wen do Servidor Ã”Ã‡Â£eee BOAO: AUBUG! I Matricula; Data da Admiss&o;__ 30.93.83... Data do ee Histosios nn idico unico de acordo com lei N& 774/93 de 16.12.0936 Fob concedida suas fâ”œÂ®rias regulamentares a que tem direito referente ao pâ”œÂ®riodo 91/92, ver proc. Nâ”¬Â« 136/940 fâ”œÂ®rias regulamentares @ ae /93: ver proc 92/9 pro o pâ”œÂ®ric 05.01.95 Foi concedida suas fâ”œÂ®rias reguaamentares a que tem @ireito, referente a0 pâ”œÂ®riodo de 93/94: ver: proCe Ee i 30/95 a ~ 06.07.95 Foi comcedide suas fâ”œÂ®rias regulameatares a que tem @ireito referente 20 ano de 94/95. Ver. Proe. de Nâ”¬Â« 473/85. de H2 1.374/99 amento de sa ao 31.06.99 | Foi concedido suas, fâ”œÂ®xas regulamentares referente | ao perfodo 97/98. Vere (Brot. We 2.346/99. 28509099 Poi concedido suas eee regulamentares referente ao perfodo 97/98. Ver. Prot. de N@ 1. 484/99. g28-09-99] Foi concedido suas fâ”œÂ®rias regulamentares referente perfodo de 98/99. Vero Prot. de Nâ”¬Â« 1485/99."},"suggestedFilename":"declaraâ”œÂºâ”œÃºo de fâ”œÂ®rias","ocrUsed":true,"chatGPTAnalysis":"9. Declaraâ”œÂºâ”œÃºo de Fâ”œÂ®rias"}	0.9	07 declaraâ”œÂºâ”œÃºo de fâ”œÂ®rias	\N	f	f	07 declaraâ”œÂºâ”œÃºo de fâ”œÂ®rias.pdf	3
\.


--
-- Data for Name: organizations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.organizations (id, name, plan_type, subscription_status, document_processed_count, ai_token_count, stripe_customer_id, created_at, updated_at, mercadopago_subscription_id, address, city, cnpj, contact_name, contact_phone, state, zip_code, subscription_due_date, logo_url) FROM stdin;
6	Escritorio do Adm	enterprise	trialing	0	0	\N	2025-11-02 22:50:40.269	2025-11-03 01:14:35.024	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
5	Escola de Musica	basic	active	0	0	\N	2025-11-01 21:18:16.442	2025-11-03 01:16:37.282	ce4e636bf3dd4f5080aa35fec58bcf6f	\N	\N	\N	\N	\N	\N	\N	\N	\N
2	Oraganizaâ”œÂºâ”œÃºo de Teste	pro	active	0	0	\N	2025-10-29 13:25:47.56	2025-11-03 01:26:28.657	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
8	Escritorio Juridico	trialing	trialing	0	0	\N	2025-11-02 23:49:58.346	2025-11-03 01:15:42.302	\N	RIO LARGO	\N	\N	\N	\N	\N	\N	\N	\N
7	Barros e Alves Advocacia	pro	trialing	0	0	cus_TEST_67890	2025-11-02 23:38:01.994	2025-11-03 02:07:04.431	teste_mp_456	rua  abc de cima	ATALAIA	123456456000148	ANDERSON RICARDO 	8299997777	AL	57690000	\N	\N
9	ADVOCACIA ALTAS HORAS	trialing	trialing	1	3247	\N	2025-11-03 01:59:46.44	2025-11-03 15:57:54.336	\N	ATALAIA	ATALAIA	123456456000147	JOAO CARLOS	8299998888	AL	57690000	\N	\N
11	maria do socorro 's Organization	trialing	trialing	0	0	\N	2025-11-03 21:02:01.556	2025-11-03 21:02:01.556	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
10	Anderson Barros's Organization	trialing	trialing	40	4267	\N	2025-11-03 20:57:25.989	2025-11-03 22:23:05.419	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
1	ATALAIA DIREITO DA MULHER	basic	canceled	0	0	\N	2025-10-28 20:56:19.046	2025-11-04 06:41:17.607	\N	PARQUE DO FUTURO 1, Nâ”¬â•‘ 101, EM FRENTE A CASA DO CICERO DO PT	ATALAIA	32.165.445/0001-85	VERONICA BASILIO ALVES	(82) 99312-1577	AL	57690-000	2025-11-03 14:21:42.938	\N
12	Pedro Henrique Duarte Miranda's Organization	trialing	trialing	0	0	\N	2025-11-05 01:45:00.866	2025-11-05 01:45:00.866	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
3	Escritâ”œâ”‚rio de Advocacia do Direito Internacional	trialing	trialing	15	16037	\N	2025-10-30 18:21:35.606	2025-11-08 00:32:15.219	teste_mp_123	\N	\N	\N	\N	\N	\N	\N	2025-12-03 14:21:42.938	\N
\.


--
-- Data for Name: projects; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.projects (id, user_id, name, client, system, action_type, narrative, processed_narrative, status, created_at, updated_at, "organizationId") FROM stdin;
2	3	Rosimere - atalaia	Rosimere Albuquerque	Pje	Aâ”œÂºâ”œÃºo Administrativa	A autora, servidora pâ”œâ•‘blica, pleiteia judicialmente o reconhecimento e a concessâ”œÃºo da licenâ”œÂºa-prâ”œÂ¬mio nâ”œÃºo utilizada, a qual lhe â”œÂ® devida em razâ”œÃºo de seu tempo de serviâ”œÂºo. A demanda se fundamenta na legislaâ”œÂºâ”œÃºo pertinente que assegura tal direito aos servidores, visando a compensaâ”œÂºâ”œÃºo por perâ”œÂ¡odos de trabalho contâ”œÂ¡nuo.\n\nOs fatos ocorreram no â”œÃ³mbito da Administraâ”œÂºâ”œÃºo Pâ”œâ•‘blica, onde a autora exerceu suas funâ”œÂºâ”œÃes ao longo de vâ”œÃ­rios anos, especificamente entre os anos de 2010 e 2023. Durante esse perâ”œÂ¡odo, a autora nâ”œÃºo usufruiu da licenâ”œÂºa-prâ”œÂ¬mio, apesar de ter cumprido todos os requisitos legais para sua concessâ”œÃºo.\n\nA autora, ao longo de sua trajetâ”œâ”‚ria funcional, nâ”œÃºo teve a oportunidade de gozar da licenâ”œÂºa-prâ”œÂ¬mio, uma vez que a Administraâ”œÂºâ”œÃºo Pâ”œâ•‘blica nâ”œÃºo a convocou para tal. A falta de informaâ”œÂºâ”œÃºo e a ausâ”œÂ¬ncia de regulamentaâ”œÂºâ”œÃºo clara sobre a utilizaâ”œÂºâ”œÃºo desse benefâ”œÂ¡cio contribuâ”œÂ¡ram para que a autora nâ”œÃºo realizasse o seu direito.\n\nO pleito da autora se justifica pela necessidade de reconhecimento do direito â”œÃ¡ licenâ”œÂºa-prâ”œÂ¬mio, que visa nâ”œÃºo apenas a compensaâ”œÂºâ”œÃºo pelo tempo de serviâ”œÂºo, mas tambâ”œÂ®m a valorizaâ”œÂºâ”œÃºo do servidor pâ”œâ•‘blico. A negativa da Administraâ”œÂºâ”œÃºo em conceder a licenâ”œÂºa-prâ”œÂ¬mio resulta em prejuâ”œÂ¡zos ao patrimâ”œâ”¤nio jurâ”œÂ¡dico da autora, que se vâ”œÂ¬ privada de um direito garantido.\n\nComo consequâ”œÂ¬ncia da omissâ”œÃºo da Administraâ”œÂºâ”œÃºo Pâ”œâ•‘blica, a autora enfrenta danos de natureza moral e material, uma vez que a licenâ”œÂºa-prâ”œÂ¬mio representa um direito que, se nâ”œÃºo exercido, implica em perdas financeiras e na desvalorizaâ”œÂºâ”œÃºo de sua trajetâ”œâ”‚ria profissional. Portanto, a presente aâ”œÂºâ”œÃºo busca a reparaâ”œÂºâ”œÃºo e o reconhecimento do direito â”œÃ¡ licenâ”œÂºa-prâ”œÂ¬mio nâ”œÃºo utilizada.	A presente Aâ”œÂºâ”œÃºo Civil Pâ”œâ•‘blica tem como objetivo o reconhecimento e a concessâ”œÃºo da licenâ”œÂºa-prâ”œÂ¬mio nâ”œÃºo utilizada pela autora, servidora pâ”œâ•‘blica, em decorrâ”œÂ¬ncia do tempo de serviâ”œÂºo prestado. Tal pleito fundamenta-se na legislaâ”œÂºâ”œÃºo pertinente que assegura o direito â”œÃ¡ licenâ”œÂºa-prâ”œÂ¬mio, visando a compensaâ”œÂºâ”œÃºo pelo trabalho contâ”œÂ¡nuo do servidor.\n\nOs fatos ocorreram no â”œÃ³mbito da Administraâ”œÂºâ”œÃºo Pâ”œâ•‘blica, onde a autora exerceu suas funâ”œÂºâ”œÃes de 2010 a 2023. Durante esse extenso perâ”œÂ¡odo, a autora nâ”œÃºo usufruiu da licenâ”œÂºa-prâ”œÂ¬mio, apesar de ter cumprido todos os requisitos legais para a sua concessâ”œÃºo, o que demonstra a relevâ”œÃ³ncia do reconhecimento de seu direito.\n\nA ausâ”œÂ¬ncia de convocaâ”œÂºâ”œÃºo por parte da Administraâ”œÂºâ”œÃºo Pâ”œâ•‘blica para que a autora gozasse da licenâ”œÂºa-prâ”œÂ¬mio, aliada â”œÃ¡ falta de informaâ”œÂºâ”œÃºo e â”œÃ¡ ausâ”œÂ¬ncia de regulamentaâ”œÂºâ”œÃºo clara sobre a utilizaâ”œÂºâ”œÃºo desse benefâ”œÂ¡cio, resultou na nâ”œÃºo realizaâ”œÂºâ”œÃºo do direito da autora. Essa omissâ”œÃºo configura uma falha na gestâ”œÃºo pâ”œâ•‘blica, que deve zelar pelo cumprimento dos direitos dos servidores.\n\nO pleito da autora justifica-se pela necessidade de reconhecimento do direito â”œÃ¡ licenâ”œÂºa-prâ”œÂ¬mio, que nâ”œÃºo apenas visa a compensaâ”œÂºâ”œÃºo pelo tempo de serviâ”œÂºo, mas tambâ”œÂ®m a valorizaâ”œÂºâ”œÃºo do servidor pâ”œâ•‘blico. A negativa da Administraâ”œÂºâ”œÃºo em conceder a licenâ”œÂºa-prâ”œÂ¬mio resulta em prejuâ”œÂ¡zos ao patrimâ”œâ”¤nio jurâ”œÂ¡dico da autora, que se vâ”œÂ¬ privada de um direito garantido por lei.\n\nComo consequâ”œÂ¬ncia da omissâ”œÃºo da Administraâ”œÂºâ”œÃºo Pâ”œâ•‘blica, a autora enfrenta danos de natureza moral e material, uma vez que a licenâ”œÂºa-prâ”œÂ¬mio representa um direito que, se nâ”œÃºo exercido, implica em perdas financeiras e na desvalorizaâ”œÂºâ”œÃºo de sua trajetâ”œâ”‚ria profissional. Assim, a presente aâ”œÂºâ”œÃºo busca a reparaâ”œÂºâ”œÃºo e o reconhecimento do direito â”œÃ¡ licenâ”œÂºa-prâ”œÂ¬mio nâ”œÃºo utilizada.	completed	2025-11-03 02:27:14.27	2025-11-08 00:32:15.035	3
3	10	teste elza	teste elza	Pje	Aâ”œÂºâ”œÃºo Trabalhista	meu nome â”œÂ® francisca alves e estou com dificuldade de pagar as contas fui demitida sem me pagarem nada	A presente aâ”œÂºâ”œÃºo trabalhista â”œÂ® proposta por Francisca Alves, doravante denominada Autor, em face de seu ex-empregador, que serâ”œÃ­ identificado como Râ”œÂ®u. A Autor alega que foi demitida sem justa causa, sem que lhe fossem pagos os valores devidos a tâ”œÂ¡tulo de verbas rescisâ”œâ”‚rias, o que lhe causa sâ”œÂ®rias dificuldades financeiras.\n\nA demissâ”œÃºo da Autor ocorreu em sua residâ”œÂ¬ncia, no municâ”œÂ¡pio de [inserir cidade], no mâ”œÂ¬s de [inserir mâ”œÂ¬s e ano], apâ”œâ”‚s o tâ”œÂ®rmino de seu contrato de trabalho. A Autor laborou para o Râ”œÂ®u por um perâ”œÂ¡odo de [inserir duraâ”œÂºâ”œÃºo do contrato], exercendo a funâ”œÂºâ”œÃºo de [inserir funâ”œÂºâ”œÃºo], e sempre cumpriu com suas obrigaâ”œÂºâ”œÃes laborais.\n\nA demissâ”œÃºo se deu de forma abrupta, sem qualquer aviso prâ”œÂ®vio ou justificativa plausâ”œÂ¡vel por parte do Râ”œÂ®u. A Autor nâ”œÃºo recebeu as verbas rescisâ”œâ”‚rias, que incluem, mas nâ”œÃºo se limitam a, saldo de salâ”œÃ­rio, fâ”œÂ®rias proporcionais e 13â”¬â•‘ salâ”œÃ­rio, o que configura a violaâ”œÂºâ”œÃºo de seus direitos trabalhistas.\n\nA motivaâ”œÂºâ”œÃºo para a demissâ”œÃºo da Autor nâ”œÃºo foi esclarecida pelo Râ”œÂ®u, o que gera a presunâ”œÂºâ”œÃºo de que a rescisâ”œÃºo ocorreu sem a observâ”œÃ³ncia das normas legais pertinentes. Tal conduta do Râ”œÂ®u, alâ”œÂ®m de ser considerada abusiva, infringe os direitos garantidos pela Consolidaâ”œÂºâ”œÃºo das Leis do Trabalho (CLT).\n\nComo consequâ”œÂ¬ncia da demissâ”œÃºo sem o pagamento das verbas rescisâ”œâ”‚rias, a Autor enfrenta dificuldades financeiras significativas, comprometendo sua capacidade de arcar com suas obrigaâ”œÂºâ”œÃes mensais, como contas de â”œÃ­gua, luz e alimentaâ”œÂºâ”œÃºo. Diante do exposto, a Autor busca a reparaâ”œÂºâ”œÃºo dos danos sofridos e a regularizaâ”œÂºâ”œÃºo de suas verbas rescisâ”œâ”‚rias.	completed	2025-11-03 15:35:10.036	2025-11-03 15:39:41.604	3
4	11	acao trabalhista joao silva	joao silva da silva	Pje	Aâ”œÂºâ”œÃºo de Cobranâ”œÂºa	despejaram da minha casa por motivo de falta de pagamento 	O Autor, na qualidade de locatâ”œÃ­rio, enfrenta a situaâ”œÂºâ”œÃºo de ter sido despejado de sua residâ”œÂ¬ncia em decorrâ”œÂ¬ncia de falta de pagamento dos aluguâ”œÂ®is devidos ao Râ”œÂ®u, que atua como locador do imâ”œâ”‚vel. Tal fato configura a base da presente Aâ”œÂºâ”œÃºo de Cobranâ”œÂºa, uma vez que o Autor busca a reparaâ”œÂºâ”œÃºo pelos danos decorrentes dessa medida extrema.\n\nO despejo ocorreu no imâ”œâ”‚vel situado na Rua das Flores, nâ”¬â•‘ 123, Bairro Jardim, na cidade de Sâ”œÃºo Paulo, no dia 15 de agosto de 2023. O Autor reside neste local desde janeiro de 2022, tendo firmado contrato de locaâ”œÂºâ”œÃºo com o Râ”œÂ®u, que estipulava o pagamento mensal do aluguel atâ”œÂ® o quinto dia â”œâ•‘til de cada mâ”œÂ¬s.\n\nO Autor, por sua vez, enfrentou dificuldades financeiras que culminaram na inadimplâ”œÂ¬ncia dos meses de junho e julho de 2023. Apesar de ter tentado negociar a dâ”œÂ¡vida com o Râ”œÂ®u, nâ”œÃºo obteve sucesso, o que resultou na decisâ”œÃºo unilateral do locador de promover a desocupaâ”œÂºâ”œÃºo do imâ”œâ”‚vel, utilizando-se da forâ”œÂºa policial para efetivar o despejo.\n\nA motivaâ”œÂºâ”œÃºo para o despejo reside na alegaâ”œÂºâ”œÃºo do Râ”œÂ®u de que a falta de pagamento configura descumprimento contratual, o que, segundo a legislaâ”œÂºâ”œÃºo vigente, autoriza a rescisâ”œÃºo do contrato de locaâ”œÂºâ”œÃºo e a consequente desocupaâ”œÂºâ”œÃºo do imâ”œâ”‚vel. No entanto, o Autor sustenta que a medida foi desproporcional, considerando que a situaâ”œÂºâ”œÃºo de inadimplâ”œÂ¬ncia era temporâ”œÃ­ria e passâ”œÂ¡vel de resoluâ”œÂºâ”œÃºo.\n\nComo consequâ”œÂ¬ncia do despejo, o Autor sofreu danos materiais e morais, uma vez que se viu privado de seu lar e teve que arcar com despesas adicionais para encontrar um novo local para residir. Assim, o Autor pleiteia a reparaâ”œÂºâ”œÃºo dos valores devidos, bem como a indenizaâ”œÂºâ”œÃºo pelos prejuâ”œÂ¡zos sofridos em decorrâ”œÂ¬ncia da aâ”œÂºâ”œÃºo do Râ”œÂ®u.	completed	2025-11-03 15:56:00.595	2025-11-03 15:57:54.181	9
5	12	Josâ”œÂ® Antonio Carro	Josâ”œÂ® Antonio	Pje	Aâ”œÂºâ”œÃºo de Indenizaâ”œÂºâ”œÃºo	\n00:00:01 \nQuero que o senhor conte, tâ”œÃ­ gravando, tâ”œÃ­? Isso. Tranquilo. Quero que o senhor conte tudo.\n00:00:06 \nNo dia vinte e trâ”œÂ¬s do mâ”œÂ¬s cinco. O que foi que aconteceu. \n00:00:09 \nO senhor vai conversar comigo, normal.\n00:00:10 \nTranquilo.\n00:00:11 \nEsqueâ”œÂºa o que tâ”œÃ­ gravando. Conte tudo, nâ”œÃºo esqueâ”œÂºa nada.\n00:00:13 \nQuando lâ”œÃ­ na loja, nâ”œâ”‚s chegamos lâ”œÃ­, cheguei com o meu carrinho, um Fiesta 2009, um valor de quinze mil, foi pedido pra ele, nâ”œÂ®? Aâ”œÂ¡ eu dei quinze mil, o carro valor quinze mil, mas quinze mil irmâ”œÃºo, trinta mil de entrada, eu dei de entrada. Aâ”œÂ¡ ele pegou, mandou, quando passou no CPF, aâ”œÂ¡ passou no da minha irmâ”œÃº, nâ”œÃºo sei o nome. que tâ”œÃ­ aqui, do meu carro. Cadâ”œÂ¬ o quâ”œÂ¬? O recibo do meu carro, nâ”œÂ®? O recibo do seu carro. Sim. Assina aqui, faz uma compra, assinar, assinei, assinei atâ”œÂ® no capuz do carro e no escritâ”œâ”‚rio.\n00:00:43 \nnâ”œÃºo entrou. Eu assinei como vendedor do carro, nâ”œÃºo â”œÂ® isso? Eu dei, cadâ”œÂ¬ o do HB20? Ele disse, olha sâ”œâ”‚, Toninho, hoje â”œÂ® sâ”œÃ­bado, amanhâ”œÃº jâ”œÃ­ â”œÂ® domingo, segunda-feira, vou pegar toda papelada, vou entregar a mâ”œÃºo do despachante, vou pagar setecentos e cinquenta reais pro meu despachante, jâ”œÃ­ entrega ao senhor. Eu soube tudo lâ”œÃ­, tudo certo, eu soube que era sâ”œâ”‚ a sua irmâ”œÃº para ir na locatâ”œâ”‚ria, eu encostei firma e fazer a transferâ”œÂ¬ncia, certo? Quando foi segunda, terâ”œÂºa, quarta-feira estâ”œÃ­ pronto. Que loja foi? â”œÃ«, a Supercar, lâ”œÃ­ na Rotary.\n00:01:16 \nSupercar. Aâ”œÂ¡ eu fui lâ”œÃ­ na quarta-feira. Eita, acho que o cara comeâ”œÂºou a ressacar, despachando, nâ”œÃºo sei o quâ”œÂ¬, nada ainda, nâ”œÃºo sei o quâ”œÂ¬, mas daqui para a tarde... Aâ”œÂ¡ eu fiquei o dia todinho lâ”œÃ­ no centro do meu cunhado, que â”œÂ® por trâ”œÃ­s da loja dele, porque lâ”œÃ­ nada. Eu estava na rotatâ”œâ”‚ria no inverno, dormindo na casa da minha irmâ”œÃº, sem trocar de roupa, sem nada, aguardando para o outro dia. Tipo, amanhâ”œÃº estâ”œÃ­ pronto, com certeza. Comeâ”œÂºou a ressacar. Aâ”œÂ¡ no dia todinho, nada. Nâ”œÃºo, â”œÂ® que deve estar parado. Aâ”œÂ¡ mandou eu ir para casa, que eu fosse com trâ”œÂ¬s dias.\n00:01:48 \nFui lâ”œÃ­ de novo. Aâ”œÂ¡ fui lâ”œÃ­ de noite, nada. Aâ”œÂ¡ a pessoa vai enrolando, dizia que era o dead trunk, estava fechado. Era o sistema que nâ”œÃºo estava, nâ”œÃºo sei o quâ”œÂ¬, estava... Aâ”œÂ¡ comeâ”œÂºou, pâ”œÃ­, pâ”œÃ­. Isso aâ”œÂ¡ rolou um mâ”œÂ¬s. Acaba de um mâ”œÂ¬s. Em vez de pouco, eu digo, rapaz, que negâ”œâ”‚cio â”œÂ® esse? Cinco dias, amigo. Deve atâ”œÂ® estar funcionando. Para perceber, deve estar funcionando. Nâ”œÃºo porque nâ”œÃºo sei o quâ”œÂ¬, â”œÂ® porque atâ”œÂ® o sistema sei o quâ”œÂ¬ e tal e ficou. Mais outro mâ”œÂ¬s, nada de transferâ”œÂ¬ncia do documento. Aâ”œÂ¡ quando eu cheguei lâ”œÃ­, minha irmâ”œÃº dormiu em Bojano,\n00:02:20 \npelo ataque no Bojano, que foi de Bojano, quando consegui dirigir, mas o pessoal, negou isso na minha cabeâ”œÂºa. Eu falei, eu digo, rapaz, o que estâ”œÃ­ acontecendo? Fala a verdade, qual â”œÂ® o banco que tem no recibo desse carro? Nâ”œÃºo, vocâ”œÂ¬ pagou a transferâ”œÂ¬ncia? O dinheiro do despachante? Eu falei, mas vocâ”œÂ¬ nâ”œÃºo disse que ia pagar as sete cento e cinquenta para ele entregar o papel de ladrâ”œÃºo certinho? Nâ”œÃºo, ninguâ”œÂ®m trabalha de caâ”œÂºa, nâ”œÃºo. Eu sei que tem que pagar. Eu falei, quanto â”œÂ®? Oitocentos e vinte. Eu disse, eu estou com oitocentos. Me dâ”œÂ¬. Oitocentos. Porque os oitocentos eu dei a ele.\n00:02:49 \nAâ”œÂ¡ vocâ”œÂ¬ deu mais oitocentos reais para ele pagar.\n00:02:51 \no despachante. Entendeu? Pâ”œâ”¤, amanhâ”œÃº estâ”œÃ­ pronto. Aâ”œÂ¡ depois de um ano eu venho. Aâ”œÂ¡ fui lâ”œÃ­ do nada. Nada. Rolou. Aâ”œÂ¡, com mais 15 dias, fui lâ”œÃ­ de novo. Depois, vocâ”œÂ¬ pediu o dinheiro, que era no dia que ela estava com o documento pronto. Pai, diga, vocâ”œÂ¬ estâ”œÃ­ falando a verdade comigo? Vocâ”œÂ¬ nâ”œÃºo estâ”œÃ­ falando a verdade comigo, nâ”œÃºo. Nâ”œÃºo adianta isso. Eles estâ”œÃºo mentindo. Aâ”œÂ¡, eles corriam, porque eu falei que eles queriam tambâ”œÂ®m processar-me. Eles estâ”œÃºo processando, porque eu estou dizendo que vocâ”œÂ¬s estâ”œÃºo mentindo? Por que vocâ”œÂ¬ estâ”œÃ­ falando a verdade, nâ”œÃºo? Nem falei para a minha irmâ”œÃº, nâ”œÃºo.\n00:03:21 \nMinha irmâ”œÃº viaja aqui jâ”œÃ­. Aâ”œÂ¡, outro veio lâ”œÃ­ para câ”œÃ­. Eu vou com o dinheiro dele, mandei ele se virar. Mesmo assim. Aâ”œÂ¡, eu fiquei lâ”œÃ­ nervoso. Ele nâ”œÃºo passou o dinheiro para a minha conta MAP, meu PIX. Jâ”œÃ­ pediu o PIX do meu germo. Ele estava comigo, foi dirigindo o carro. E passou para ele. Passou o quâ”œÂ¬? O dinheiro da devoluâ”œÂºâ”œÃºo dos 800.\n00:03:42 \nAh, ele devolveu os 800? Os 800.\n00:03:44 \nMais os 30 mil? E mandou-me se virar.\n00:03:47 \nMais os 30 mil, nâ”œÃºo? Nâ”œÃºo, nâ”œÃºo.\n00:03:49 \nE mandou-me se virar. Se virem. Aâ”œÂ¡, o anjo disse. Como â”œÂ® que ele vai se virar sem o documento do carro? Ele vai fazer o quâ”œÂ¬? Nâ”œÃºo, nâ”œÃºo quero nem saber. E nâ”œÃºo venho aqui mais, nâ”œÃºo. Nâ”œÃºo quero sair daqui mais, nâ”œÃºo. Por quâ”œÂ¬? Eu vou mandar vocâ”œÂ¬ agora. â”œÃ« com vocâ”œÂ¬, Maurâ”œÂ¡cio, agora. Pronto. â”œÃ« com vocâ”œÂ¬. Ele nunca me entendeu mais, nâ”œÃºo me ouviu mais, aâ”œÂ¡ ele falou lâ”œÃ­ com o Maurâ”œÂ¡cio.\n00:04:06 \nMas esse carro estâ”œÃ­ financiado mesmo, tâ”œÃ­. \n00:04:08 \nTâ”œÃ­. Entâ”œÃºo eu paguei a quinta parcela jâ”œÃ­. Hâ”œÃº? Eu paguei a quinta parcela.\n00:04:12 \nO senhor estâ”œÃ­ pagando...\n00:04:13 \nEstou pagando. Paguei esse mâ”œÂ¬s, esse dia 23, eu paguei dia 17. Estâ”œÃ­ aqui todinho, eu recebo tudo. Certo. E o carro estâ”œÃ­ no nome do senhor? Nâ”œÃºo, ninguâ”œÂ®m sabe qual o nome que esse carro estâ”œÃ­. Porque atâ”œÂ® agora ele nâ”œÃºo mostrou o nome. Ele falou assim, â”œÂ® o nome da minha irmâ”œÃº. Mas atâ”œÂ® agora ele nâ”œÃºo sabe onde â”œÂ® que esse carro estâ”œÃ­.\n00:04:30 \nEsse carro que estâ”œÃ­ financiado, que o senhor estâ”œÃ­ pagando, o senhor nâ”œÃºo sabe...\n00:04:33 \nNâ”œÃºo. ...no nome de quem estâ”œÃ­. Aâ”œÂ¡ depois foi descoberto que o carro era de Minas, da locadora de Minas. Aâ”œÂ¡ ele disse que tinha que... Esse â”œÂ® o pai que estâ”œÃ­ aqui, que esteve aqui. Foi quem entrou em contato com Minas, me encheu o carro e saiu daqui. E deu a documentaâ”œÂºâ”œÃºo do carro, recebi o carro com ele, quem comprou o carro. Minas sem nada a ver mais. Beleza. Ah, mas espera aâ”œÂ¡. Aâ”œÂ¡ ele disse que tinha que transferir o carro de Minas, estâ”œÃ­ aqui, â”œâ”‚. De Minas, da locadora de Minas, para a BG Posada, que â”œÂ® a sede dele. Pra daâ”œÂ¡, tâ”œÃ­ feito pra minha irmâ”œÃº.\n00:05:04 \nE eu pagando, tambâ”œÂ®m pagando. Aâ”œÂ¡ como eu nâ”œÃºo pude ter um terâ”œÂºo mais...\n00:05:07 \nâ”œÃ« minha irmâ”œÃº. Entâ”œÃºo esse carro, teoricamente, era pra estar no nome dela.\n00:05:12 \nExatamente. Sâ”œâ”‚ que nâ”œÃºo tâ”œÃ­. Nâ”œÃºo, nâ”œÃºo. Ela mora lâ”œÃ­ no Antalho. Ela vai lâ”œÃ­, jâ”œÃ­ foi lâ”œÃ­, o marido dela, o filho dela, vai estar com ele, fica sâ”œâ”‚ enrolando. Entendeu? Aâ”œÂ¡ agora transferiu de Minas pra BG, que â”œÂ® a pousada dele. Pra daâ”œÂ¡, tâ”œÃ­ feito pra Maria. Aâ”œÂ¡ nâ”œÃºo transferiu ainda. Jâ”œÃ­ tâ”œÃ­ com mais de mâ”œÂ¬s que esse carro veio de... Foi transferido de Minas pra pousada dele, que â”œÂ® aqui, tâ”œÃ­ aqui, a BG pousada. Mas pra nâ”œÃºo dar a minha irmâ”œÃº, nâ”œÃºo. Aâ”œÂ¡ o banco agora cancelou. O banco multou ele em R$460,00. Pâ”œâ”¤s ele no enviador a documentaâ”œÂºâ”œÃºo do carro correto. Sâ”œâ”‚ mostrando que o carro tava incorreto.\n00:05:42 \nA documentaâ”œÂºâ”œÃºo incorreta. Nâ”œÃºo mandou. Atâ”œÂ® que o banco multou ele em R$460,00 e agora cancelou.\n00:05:49 \nE tem essa informaâ”œÂºâ”œÃºo do banco, cancelando? Tâ”œÃ­ aqui. O banco cancelou. Tem vâ”œÃ­rios documentos aqui.\n00:06:01 \nAâ”œÂ¡ eu pagando o carro, sem saber para quem eu estou pagando, que o banco mandou ontem a mensagem que tinha cancelado o financiamento.\n00:06:12 \nFoi cancelado, porque nâ”œÃºo recebeu a documentaâ”œÂºâ”œÃºo necessâ”œÃ­ria.\n00:06:15 \nEle disse, â”œÂ® a senhora, que â”œÂ® vocâ”œÂ¬s. Mas como â”œÂ®, moâ”œÂºo, ele disse que o que vai pagar a documentaâ”œÂºâ”œÃºo â”œÂ® ele.\n00:06:24 \nMas o senhor pagou os 30 mil.\n00:06:26 \nEu dei 30 mil em mâ”œÃºo, o carro â”œÂ® mais 15 mil em mâ”œÃºo, e eu vou pagando jâ”œÃ­ 6.525 do carro. Cinco parcelas. E atâ”œÂ® agora eu nâ”œÃºo sei para quem eu estou pagando esse dinheiro. Porque nem para a minha irmâ”œÃº nâ”œÃºo â”œÂ®, eu nâ”œÃºo sei para quem â”œÂ®, porque atâ”œÂ® agora nâ”œÃºo tem nada sâ”œÂ®rio. Eles sâ”œâ”‚ mentiram, sâ”œâ”‚ enrolando a gente. Aâ”œÂ¡ minha irmâ”œÃº passa mal, eu passo mal tambâ”œÂ®m aqui, porque eu nunca me vi com esse tipo de coisa.\n00:06:53 \nNâ”œÃºo, mas agora a gente tem que ter tranquilidade, nâ”œÂ®? Para a gente poder resolver.\n00:06:57 \nFiquei 13 anos com o carro em meio, 13 anos.\n00:07:01 \nCadâ”œÂ¬ a comprovaâ”œÂºâ”œÃºo que o senhor pagou, o senhor fez o boletim de ocorrâ”œÂ¬ncia que eu vi aqui.\n00:07:06 \nFoi, mandaram ele para entrar na justiâ”œÂºa, nâ”œÂ®? O delegado explicou a gente como era e tal.\n00:07:59 \nEstâ”œÃ­ aqui. Estâ”œÃ­ no contrato, nâ”œÂ®? â”œÃ« meu irmâ”œÃºo de papel, tem um papel que eu fico doido, eu nâ”œÃºo me... Nâ”œÃºo, quero sâ”œâ”‚ saber aqui. Pronto, tem mais alguma coisa? Algum detalhe que o senhor esqueceu sobre isso. \n00:08:17 \nVai depender do... como â”œÂ® que a gente vai resolver, porque... Nâ”œÃºo, eu quero sâ”œâ”‚ entender o que aconteceu. O que eu queria era o... Foi isso aâ”œÂ¡, nâ”œÂ®? Nâ”œÃºo, isso aqui. Isso aqui estâ”œÃ­ dizendo aâ”œÂ¡ o valor do carro que ele pegou, 15 mil. Ele atâ”œÂ® modificou aâ”œÂ¡, que era problema dele, mas... Tâ”œÃ­, que valor de entrada, 38 mil. Ele botou 8 mil, nâ”œÃºo sei porquâ”œÂ¬, ele disse que era problema dele, tinha nada a ver. Ele mandou vocâ”œÂ¬ 30 mil.\n00:08:46 \nCerto, mas eu quero saber, ver o seguinte. Como foi, o senhor nâ”œÃºo... Nâ”œÃºo, ele nâ”œÃºo assinou o recibo que recebeu e nem o PIX. O senhor pagou em mâ”œÃºo. Em mâ”œÃºo. Com o carro e 15 mil.\n00:09:01 \nEu passei no cartâ”œÃºo para ele e o preâ”œÂºo foi 10 mil, 12 mil e 3 mil foi em mâ”œÃºo.\n00:09:06 \nCerto. Entâ”œÃºo, cadâ”œÂ¬ esse copo ao rato do cartâ”œÃºo? Ele nâ”œÃºo deu. Nâ”œÃºo, mas nâ”œÃºo foi no seu cartâ”œÃºo? Foi. Entâ”œÃºo, tem na sua fatura. O senhor passou no cartâ”œÃºo de quem? Do meu mesmo. Entâ”œÃºo, nâ”œÃºo fica na fatura? O senhor passou 12 mil? Sâ”œâ”‚ que eu nâ”œÃºo sei procurar.\n00:09:23 \nHâ”œÃº? Eu sei procurar.\n00:09:25 \nâ”œÃ«, mas o senhor tem.\n00:09:27 \nTem. Aâ”œÂ¡... Aâ”œÂ¡ o tremor vocâ”œÂ¬ que eu dei em mâ”œÃºo. Aâ”œÂ¡ ele conseguiu 12 mil, eu dei um rato.\n00:09:31 \nCerto. Entâ”œÃºo, aâ”œÂ¡ veja aâ”œÂ¡. Aâ”œÂ¡, essa fatura do cartâ”œÃºo.\n00:09:35 \nDo caâ”œÂºar. Certo.\n00:09:37 \nE eu quero tambâ”œÂ®m, essa mensagem. Cancelando. O senhor mandou para o menino? Nâ”œÃºo.\n00:09:44 \nEu disse aqui que tinha essa mensagem, mas ele nâ”œÃºo tirou nâ”œÃºo.\n00:09:46 \nIsso aqui. Pronto. Nâ”œÃºo tirou nâ”œÃºo, nâ”œÂ®? Nâ”œÃºo. Tâ”œÃ­ certo. Eu sâ”œâ”‚ mostrei ele. Eu vou chamar ele aqui.\n00:09:51 \nNâ”œÃºo sei se...	O Autor, no dia 23 de maio de 2022, adquiriu um veâ”œÂ¡culo da marca HB20, no valor total de R$ 15.000,00, junto ao Râ”œÂ®u, representante da loja Supercar, localizada na Rotary. O Autor efetuou um pagamento inicial de R$ 30.000,00, sendo que o restante do valor seria quitado por meio de financiamento. O Râ”œÂ®u comprometeu-se a realizar a transferâ”œÂ¬ncia da documentaâ”œÂºâ”œÃºo do veâ”œÂ¡culo, garantindo que toda a papelada seria entregue ao Autor em breve.\n\nApâ”œâ”‚s a compra, o Autor aguardou a entrega da documentaâ”œÂºâ”œÃºo por um perâ”œÂ¡odo que se estendeu por mais de um mâ”œÂ¬s, durante o qual o Râ”œÂ®u apresentou diversas justificativas para a demora, alegando problemas com o sistema de transferâ”œÂ¬ncia e a necessidade de regularizaâ”œÂºâ”œÃºo da documentaâ”œÂºâ”œÃºo junto a uma locadora de Minas Gerais. O Autor, em vâ”œÃ­rias ocasiâ”œÃes, compareceu â”œÃ¡ loja na expectativa de receber os documentos, mas sempre foi informado de que a situaâ”œÂºâ”œÃºo ainda nâ”œÃºo estava resolvida.\n\nO Autor, em decorrâ”œÂ¬ncia da falta de documentaâ”œÂºâ”œÃºo e da ausâ”œÂ¬ncia de informaâ”œÂºâ”œÃes claras por parte do Râ”œÂ®u, comeâ”œÂºou a questionar a legalidade da compra e a situaâ”œÂºâ”œÃºo do financiamento do veâ”œÂ¡culo. Durante esse perâ”œÂ¡odo, o Autor continuou a efetuar os pagamentos das parcelas do financiamento, totalizando cinco parcelas pagas, sem saber a quem realmente pertencia o veâ”œÂ¡culo, uma vez que o Râ”œÂ®u nâ”œÃºo forneceu informaâ”œÂºâ”œÃes precisas sobre a titularidade do bem.\n\nA situaâ”œÂºâ”œÃºo agravou-se quando o banco responsâ”œÃ­vel pelo financiamento cancelou o contrato, alegando que a documentaâ”œÂºâ”œÃºo necessâ”œÃ­ria nâ”œÃºo foi apresentada pelo Râ”œÂ®u. O Autor, que jâ”œÃ­ havia desembolsado um total de R$ 30.000,00, alâ”œÂ®m das parcelas pagas, viu-se em uma situaâ”œÂºâ”œÃºo de incerteza e prejuâ”œÂ¡zo financeiro, sem a posse regular do veâ”œÂ¡culo e sem a possibilidade de utilizâ”œÃ­-lo legalmente.\n\nDiante dos fatos narrados, o Autor busca a reparaâ”œÂºâ”œÃºo pelos danos materiais e morais sofridos em decorrâ”œÂ¬ncia da conduta negligente do Râ”œÂ®u, que nâ”œÃºo cumpriu com suas obrigaâ”œÂºâ”œÃes contratuais, causando transtornos e prejuâ”œÂ¡zos significativos â”œÃ¡ sua vida pessoal e financeira.	completed	2025-11-03 22:15:22.59	2025-11-03 22:15:45.954	10
6	1	Flavio Henrique	FLAVIO ALVES	Pje	Execuâ”œÂºâ”œÃºo		\N	draft	2025-11-07 20:58:21.808	2025-11-07 20:58:21.808	1
\.


--
-- Data for Name: system_configurations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.system_configurations (id, system_name, max_file_size, max_page_size, allowed_formats, pdf_requirements, created_at, updated_at) FROM stdin;
1	Pje	31457280	500	["pdf","doc","docx","jpg","jpeg","png"]	{"maxSizeMB":30,"maxPageSizeKB":500,"resolution":150,"colorMode":"RGB","compression":true}	2025-11-01 03:18:58.202	2025-11-01 03:18:58.202
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, email, password, name, created_at, updated_at, auth_user_id, "organizationId", role) FROM stdin;
2	test_user_4747390768769537901@testuser.com	$2a$12$7k28kXaMlt64wy6ZIGk2m.uSYeg2eQocn/P4OqrltMiBJhP28J7QG	usuario teste	2025-10-29 13:25:48.003	2025-10-29 13:25:48.003	\N	2	member
1	flavioha@msn.com	$2a$12$3jEO8KgwkwufWG5aNSeHr.v/GLjBw1r.J1VeB0RnDRTGLsXVx4LgW	Flavio Henrique	2025-10-28 20:56:19.488	2025-10-28 20:56:19.488	\N	1	member
6	flavioha@gmail.com	$2a$12$1eQy3u8PXN859UHjyR9P5ecVijPSWGYfRPVBxSZlr7jRFDSlmVG5q	Flavio Henrique Alves	2025-11-02 22:50:40.817	2025-11-02 22:50:40.817	\N	6	super_admin
7	flaviohenriquealves@icloud.com	$2a$12$3xqWL2OwpwPc9U3ET4rszuH0aDuKPZKnPjtQCzOzJeo4/xuy7S/GK	Flavio dev	2025-11-02 23:38:02.715	2025-11-02 23:38:02.715	\N	7	admin
8	flavio@icloud.com	$2a$12$48i8Zqu0aGC07QVZXdmSd.X1hkw6.aJGh3YtcdQGCZY58lYPgS.bC	Flavio dev	2025-11-02 23:49:59.096	2025-11-02 23:49:59.096	\N	8	admin
9	joaosilvajunior@teste.com.br	$2a$12$yrvVpLt3yieWR1QY/VK5f.fl2z0nOrSxgAu.i5iq9tu0v2fti94ua	JOAO SILVA JUNIOR	2025-11-03 01:59:46.87	2025-11-03 01:59:46.87	\N	9	admin
3	elza@gmail.com	$2a$12$5/JJ.7XeHlp2EumzywcLm.pnNhnxmwjBVPoIeB.GCSgZOHVWC9OCm	elza	2025-10-30 18:21:36.075	2025-10-30 18:21:36.075	\N	3	admin
10	userelza@arb.com.br	$2a$12$mBbzmT9BIEi1eE3Wd8uoc.0UScqHR0/mZ9JbYRKo//3lxTCthPTua	usuario-elza	2025-11-03 15:30:35.954	2025-11-03 15:30:35.954	\N	3	member
11	usuario-de-joao@teste.com	$2a$12$wcITdANZFKrILZXnsgprz.E9IbCCk/g0JA0Yd7hnnam5/e8U64W8y	user-joao	2025-11-03 15:54:21.96	2025-11-03 15:54:21.96	\N	9	member
12	andersonricardoadv@hotmail.com	$2a$12$P42LwTVP5.nDxubiy7RIXOEZw3eV/RB4cwKjdm/YP/7WzKkJ6EURm	Anderson Barros	2025-11-03 20:57:26.709	2025-11-03 20:57:26.709	\N	10	admin
13	mariadosocorro@arb.com.br	$2a$12$jORFPXnzaANs0VfTQLeSVeaRbupnTuUSyapUz7bTRDdG/UBKxs0H.	maria do socorro 	2025-11-03 21:02:02.244	2025-11-03 21:02:02.244	\N	11	admin
14	jmario@gmail.com	$2a$12$0gIlPWdG7R8ncxWlMBQS9eCiB3aNYI/gg9IvlavwOSK7SGrbp2NtK	Josâ”œÂ® Marinho	2025-11-03 22:13:50.973	2025-11-03 22:13:50.973	\N	10	member
15	phdtemiranda@gmail.com	$2a$12$TMPfdcVmuGIDWQtWx6gH7u6dVMD8jBZicDauYOW9vAsihKzj498pC	Pedro Henrique Duarte Miranda	2025-11-05 01:45:01.687	2025-11-05 01:45:01.687	\N	12	admin
\.


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: realtime; Owner: supabase_admin
--

COPY realtime.schema_migrations (version, inserted_at) FROM stdin;
20211116024918	2025-07-21 00:47:20
20211116045059	2025-07-21 00:47:24
20211116050929	2025-07-21 00:47:28
20211116051442	2025-07-21 00:47:31
20211116212300	2025-07-21 00:47:35
20211116213355	2025-07-21 00:47:38
20211116213934	2025-07-21 00:47:42
20211116214523	2025-07-21 00:47:46
20211122062447	2025-07-21 00:47:50
20211124070109	2025-07-21 00:47:53
20211202204204	2025-07-21 00:47:56
20211202204605	2025-07-21 00:47:59
20211210212804	2025-07-21 00:48:10
20211228014915	2025-07-21 00:48:13
20220107221237	2025-07-21 00:48:17
20220228202821	2025-07-21 00:48:20
20220312004840	2025-07-21 00:48:23
20220603231003	2025-07-21 00:48:29
20220603232444	2025-07-21 00:48:32
20220615214548	2025-07-21 00:48:36
20220712093339	2025-07-21 00:48:39
20220908172859	2025-07-21 00:48:43
20220916233421	2025-07-21 00:48:46
20230119133233	2025-07-21 00:48:49
20230128025114	2025-07-21 00:48:54
20230128025212	2025-07-21 00:48:57
20230227211149	2025-07-21 00:49:01
20230228184745	2025-07-21 00:49:04
20230308225145	2025-07-21 00:49:08
20230328144023	2025-07-21 00:49:11
20231018144023	2025-07-21 00:49:15
20231204144023	2025-07-21 00:49:20
20231204144024	2025-07-21 00:49:23
20231204144025	2025-07-21 00:49:27
20240108234812	2025-07-21 00:49:30
20240109165339	2025-07-21 00:49:33
20240227174441	2025-07-21 00:49:39
20240311171622	2025-07-21 00:49:44
20240321100241	2025-07-21 00:49:51
20240401105812	2025-07-21 00:50:00
20240418121054	2025-07-21 00:50:05
20240523004032	2025-07-21 00:50:17
20240618124746	2025-07-21 00:50:21
20240801235015	2025-07-21 00:50:24
20240805133720	2025-07-21 00:50:27
20240827160934	2025-07-21 00:50:31
20240919163303	2025-07-21 00:50:35
20240919163305	2025-07-21 00:50:39
20241019105805	2025-07-21 00:50:42
20241030150047	2025-07-21 00:50:54
20241108114728	2025-07-21 00:50:59
20241121104152	2025-07-21 00:51:02
20241130184212	2025-07-21 00:51:06
20241220035512	2025-07-21 00:51:10
20241220123912	2025-07-21 00:51:13
20241224161212	2025-07-21 00:51:16
20250107150512	2025-07-21 00:51:20
20250110162412	2025-07-21 00:51:23
20250123174212	2025-07-21 00:51:27
20250128220012	2025-07-21 00:51:31
20250506224012	2025-07-21 00:51:33
20250523164012	2025-07-21 00:51:37
20250714121412	2025-07-21 00:51:40
20250905041441	2025-10-01 18:13:16
\.


--
-- Data for Name: subscription; Type: TABLE DATA; Schema: realtime; Owner: supabase_admin
--

COPY realtime.subscription (id, subscription_id, entity, filters, claims, created_at) FROM stdin;
\.


--
-- Data for Name: buckets; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--

COPY storage.buckets (id, name, owner, created_at, updated_at, public, avif_autodetection, file_size_limit, allowed_mime_types, owner_id, type) FROM stdin;
documents	documents	\N	2025-07-22 01:23:47.946652+00	2025-07-22 01:23:47.946652+00	t	f	\N	\N	\N	STANDARD
\.


--
-- Data for Name: buckets_analytics; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--

COPY storage.buckets_analytics (id, type, format, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: migrations; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--

COPY storage.migrations (id, name, hash, executed_at) FROM stdin;
0	create-migrations-table	e18db593bcde2aca2a408c4d1100f6abba2195df	2025-07-21 00:47:14.528371
1	initialmigration	6ab16121fbaa08bbd11b712d05f358f9b555d777	2025-07-21 00:47:14.537968
2	storage-schema	5c7968fd083fcea04050c1b7f6253c9771b99011	2025-07-21 00:47:14.545499
3	pathtoken-column	2cb1b0004b817b29d5b0a971af16bafeede4b70d	2025-07-21 00:47:14.568827
4	add-migrations-rls	427c5b63fe1c5937495d9c635c263ee7a5905058	2025-07-21 00:47:14.584882
5	add-size-functions	79e081a1455b63666c1294a440f8ad4b1e6a7f84	2025-07-21 00:47:14.592976
6	change-column-name-in-get-size	f93f62afdf6613ee5e7e815b30d02dc990201044	2025-07-21 00:47:14.601553
7	add-rls-to-buckets	e7e7f86adbc51049f341dfe8d30256c1abca17aa	2025-07-21 00:47:14.609588
8	add-public-to-buckets	fd670db39ed65f9d08b01db09d6202503ca2bab3	2025-07-21 00:47:14.618136
9	fix-search-function	3a0af29f42e35a4d101c259ed955b67e1bee6825	2025-07-21 00:47:14.625961
10	search-files-search-function	68dc14822daad0ffac3746a502234f486182ef6e	2025-07-21 00:47:14.634445
11	add-trigger-to-auto-update-updated_at-column	7425bdb14366d1739fa8a18c83100636d74dcaa2	2025-07-21 00:47:14.644951
12	add-automatic-avif-detection-flag	8e92e1266eb29518b6a4c5313ab8f29dd0d08df9	2025-07-21 00:47:14.655502
13	add-bucket-custom-limits	cce962054138135cd9a8c4bcd531598684b25e7d	2025-07-21 00:47:14.667184
14	use-bytes-for-max-size	941c41b346f9802b411f06f30e972ad4744dad27	2025-07-21 00:47:14.675407
15	add-can-insert-object-function	934146bc38ead475f4ef4b555c524ee5d66799e5	2025-07-21 00:47:14.703039
16	add-version	76debf38d3fd07dcfc747ca49096457d95b1221b	2025-07-21 00:47:14.712732
17	drop-owner-foreign-key	f1cbb288f1b7a4c1eb8c38504b80ae2a0153d101	2025-07-21 00:47:14.720351
18	add_owner_id_column_deprecate_owner	e7a511b379110b08e2f214be852c35414749fe66	2025-07-21 00:47:14.728307
19	alter-default-value-objects-id	02e5e22a78626187e00d173dc45f58fa66a4f043	2025-07-21 00:47:14.739641
20	list-objects-with-delimiter	cd694ae708e51ba82bf012bba00caf4f3b6393b7	2025-07-21 00:47:14.749862
21	s3-multipart-uploads	8c804d4a566c40cd1e4cc5b3725a664a9303657f	2025-07-21 00:47:14.759789
22	s3-multipart-uploads-big-ints	9737dc258d2397953c9953d9b86920b8be0cdb73	2025-07-21 00:47:14.775516
23	optimize-search-function	9d7e604cddc4b56a5422dc68c9313f4a1b6f132c	2025-07-21 00:47:14.790139
24	operation-function	8312e37c2bf9e76bbe841aa5fda889206d2bf8aa	2025-07-21 00:47:14.797944
25	custom-metadata	d974c6057c3db1c1f847afa0e291e6165693b990	2025-07-21 00:47:14.806553
26	objects-prefixes	ef3f7871121cdc47a65308e6702519e853422ae2	2025-08-26 19:14:41.425956
27	search-v2	33b8f2a7ae53105f028e13e9fcda9dc4f356b4a2	2025-08-26 19:14:41.627054
28	object-bucket-name-sorting	ba85ec41b62c6a30a3f136788227ee47f311c436	2025-08-26 19:14:41.808995
29	create-prefixes	a7b1a22c0dc3ab630e3055bfec7ce7d2045c5b7b	2025-08-26 19:14:41.906923
30	update-object-levels	6c6f6cc9430d570f26284a24cf7b210599032db7	2025-08-26 19:14:42.04718
31	objects-level-index	33f1fef7ec7fea08bb892222f4f0f5d79bab5eb8	2025-08-26 19:14:42.448685
32	backward-compatible-index-on-objects	2d51eeb437a96868b36fcdfb1ddefdf13bef1647	2025-08-26 19:14:42.508877
33	backward-compatible-index-on-prefixes	fe473390e1b8c407434c0e470655945b110507bf	2025-08-26 19:14:42.530219
34	optimize-search-function-v1	82b0e469a00e8ebce495e29bfa70a0797f7ebd2c	2025-08-26 19:14:42.532931
35	add-insert-trigger-prefixes	63bb9fd05deb3dc5e9fa66c83e82b152f0caf589	2025-08-26 19:14:42.547279
36	optimise-existing-functions	81cf92eb0c36612865a18016a38496c530443899	2025-08-26 19:14:42.558608
37	add-bucket-name-length-trigger	3944135b4e3e8b22d6d4cbb568fe3b0b51df15c1	2025-08-26 19:14:42.575012
38	iceberg-catalog-flag-on-buckets	19a8bd89d5dfa69af7f222a46c726b7c41e462c5	2025-08-26 19:14:42.583119
39	add-search-v2-sort-support	39cf7d1e6bf515f4b02e41237aba845a7b492853	2025-09-25 01:22:24.402825
40	fix-prefix-race-conditions-optimized	fd02297e1c67df25a9fc110bf8c8a9af7fb06d1f	2025-09-25 01:22:24.446547
41	add-object-level-update-trigger	44c22478bf01744b2129efc480cd2edc9a7d60e9	2025-09-25 12:47:07.111578
42	rollback-prefix-triggers	f2ab4f526ab7f979541082992593938c05ee4b47	2025-09-25 12:47:07.127263
43	fix-object-level	ab837ad8f1c7d00cc0b7310e989a23388ff29fc6	2025-09-25 12:47:07.134275
\.


--
-- Data for Name: objects; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--

COPY storage.objects (id, bucket_id, name, owner, created_at, updated_at, last_accessed_at, metadata, version, owner_id, user_metadata, level) FROM stdin;
dc63a2cd-03f3-4bbd-9fff-06ff967ce63d	documents	original/.emptyFolderPlaceholder	\N	2025-10-24 18:17:37.043141+00	2025-10-24 18:17:37.043141+00	2025-10-24 18:17:37.043141+00	{"eTag": "\\"d41d8cd98f00b204e9800998ecf8427e\\"", "size": 0, "mimetype": "application/octet-stream", "cacheControl": "max-age=3600", "lastModified": "2025-10-24T18:17:37.044Z", "contentLength": 0, "httpStatusCode": 200}	34f7b009-9b21-4256-9307-b26757e40869	\N	{}	2
6876be31-71c4-4e31-8a49-2a65928970b4	documents	temp/.emptyFolderPlaceholder	\N	2025-10-24 18:19:55.11813+00	2025-10-24 18:19:55.11813+00	2025-10-24 18:19:55.11813+00	{"eTag": "\\"d41d8cd98f00b204e9800998ecf8427e\\"", "size": 0, "mimetype": "application/octet-stream", "cacheControl": "max-age=3600", "lastModified": "2025-10-24T18:19:55.120Z", "contentLength": 0, "httpStatusCode": 200}	940d68a5-58bd-455d-af9a-1d7fb3e2b35b	\N	{}	2
c1c1eac4-71a8-480b-aea8-c675668aabee	documents	processed/06_Contratos_e04042f1.pdf	\N	2025-11-03 22:22:53.023331+00	2025-11-03 22:22:53.023331+00	2025-11-03 22:22:53.023331+00	{"eTag": "\\"d298c8fb99a380de78c495da588c8a15\\"", "size": 289758, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-11-03T22:22:53.000Z", "contentLength": 289758, "httpStatusCode": 200}	c4f971cc-a9ac-4d0a-b4a5-9497bf9f0880	\N	{}	2
ff7d7ccb-0804-4fdc-8bee-0992bbbc1e58	documents	processed/07_Outros_Documentos_95354540.pdf	\N	2025-10-14 19:24:57.763324+00	2025-10-14 19:24:57.763324+00	2025-10-14 19:24:57.763324+00	{"eTag": "\\"9ee3c6fc631c1b31ca185ea842c19b4c-3\\"", "size": 10985415, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-10-14T19:24:58.000Z", "contentLength": 10985415, "httpStatusCode": 200}	59ba3420-e815-4818-8f56-fe7b1eda46a6	\N	{}	2
c6c848ba-28c9-4cad-9d20-a93252b3b371	documents	processado/.emptyFolderPlaceholder	\N	2025-10-24 18:18:17.148973+00	2025-10-24 18:18:17.148973+00	2025-10-24 18:18:17.148973+00	{"eTag": "\\"d41d8cd98f00b204e9800998ecf8427e\\"", "size": 0, "mimetype": "application/octet-stream", "cacheControl": "max-age=3600", "lastModified": "2025-10-24T18:18:17.150Z", "contentLength": 0, "httpStatusCode": 200}	7243f19e-9883-4e44-945d-56b3f497e02c	\N	{}	2
2f46feb0-af5e-4956-b13e-4a182efb7172	documents	processed/07_contrato_de_seguro_9663b672.pdf	\N	2025-11-03 22:22:59.681929+00	2025-11-03 22:22:59.681929+00	2025-11-03 22:22:59.681929+00	{"eTag": "\\"fa7933b6898bb759362d9fa4238902ec\\"", "size": 183186, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-11-03T22:23:00.000Z", "contentLength": 183186, "httpStatusCode": 200}	06e4854c-8a25-453e-b870-f3fef3f00033	\N	{}	2
a544b252-a27f-41c5-b0a8-43c5009e55f0	documents	processed/06_Contratos_69c32a30.pdf	\N	2025-11-03 22:23:05.177328+00	2025-11-03 22:23:05.177328+00	2025-11-03 22:23:05.177328+00	{"eTag": "\\"6385501b9c00897b1f073e5be5918fe3\\"", "size": 126438, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-11-03T22:23:06.000Z", "contentLength": 126438, "httpStatusCode": 200}	5938a270-c8ef-4af4-9029-2b647de7aa88	\N	{}	2
c415caf7-cd9c-4db5-a4a3-444c15f6183b	documents	processed/07_Outros_Documentos_859facd3.pdf	\N	2025-10-22 03:35:42.598018+00	2025-10-22 03:35:42.598018+00	2025-10-22 03:35:42.598018+00	{"eTag": "\\"0cbd9fa6e5c00ebbb4a63e4f2fbeff88\\"", "size": 361111, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-10-22T03:35:43.000Z", "contentLength": 361111, "httpStatusCode": 200}	0b834681-5f11-4955-8e09-d344b5b1adad	\N	{}	2
39e2ef47-d346-46ab-a078-4c4fb56d1ebe	documents	processed/08 Documentos Medicos 2.pdf	\N	2025-09-17 21:31:16.835209+00	2025-09-17 21:31:16.835209+00	2025-09-17 21:31:16.835209+00	{"eTag": "\\"89e456d17cf53c6d17942119b7393c7c\\"", "size": 76306, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-09-17T21:31:17.000Z", "contentLength": 76306, "httpStatusCode": 200}	a99e6198-2f54-43b3-94f4-089493cf517f	\N	{}	2
42ef8dcc-e7fd-4c9e-b8f9-38b0d4e755cc	documents	processed/07_concessao_de_aposentadoria_a3f027ed.pdf	\N	2025-11-08 00:29:04.412141+00	2025-11-08 00:29:04.412141+00	2025-11-08 00:29:04.412141+00	{"eTag": "\\"15f75ece821874edd049d1811d0afe31\\"", "size": 147048, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-11-08T00:29:05.000Z", "contentLength": 147048, "httpStatusCode": 200}	3be61145-2aba-4163-aa9f-b6c363833445	\N	{}	2
75897272-fed8-4542-bfe0-472a5942e578	documents	processed/07_Outros_Documentos_dbf1281f.pdf	\N	2025-10-27 14:24:17.997141+00	2025-10-27 14:36:48.223305+00	2025-10-27 14:24:17.997141+00	{"eTag": "\\"ff5b95e25a325d9dc327cd5927bb61c5\\"", "size": 22783, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-10-27T14:36:49.000Z", "contentLength": 22783, "httpStatusCode": 200}	5959329f-5d8b-461b-a491-7b1dba74c803	\N	{}	2
8711c87f-0def-427a-841b-21679644c8a6	documents	processed/07_ficha_financeira_individual_dd2f2ade.pdf	\N	2025-11-08 00:29:10.524583+00	2025-11-08 00:29:10.524583+00	2025-11-08 00:29:10.524583+00	{"eTag": "\\"c9d45fe05a8901be5e60903499c06461\\"", "size": 165559, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-11-08T00:29:11.000Z", "contentLength": 165559, "httpStatusCode": 200}	6be538c3-8a45-4c78-b2e0-753e11948cc2	\N	{}	2
7c4a09e3-51d9-433e-ab43-471a7b454685	documents	processed/07_ficha_financeira_a71de900.pdf	\N	2025-11-08 00:29:45.322095+00	2025-11-08 00:29:45.322095+00	2025-11-08 00:29:45.322095+00	{"eTag": "\\"b11a3b59a218a067a0050e7eba6a3586\\"", "size": 180728, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-11-08T00:29:46.000Z", "contentLength": 180728, "httpStatusCode": 200}	4de3f16a-a223-4423-9acc-83c908918431	\N	{}	2
6c255f6d-8809-45c0-a00a-24bc4b679df0	documents	processed/07_ficha_financeira_individual_d674ba7c.pdf	\N	2025-11-08 00:29:48.96917+00	2025-11-08 00:29:48.96917+00	2025-11-08 00:29:48.96917+00	{"eTag": "\\"2672f16f950db85d954b5f1a33886220\\"", "size": 177324, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-11-08T00:29:49.000Z", "contentLength": 177324, "httpStatusCode": 200}	de3f87b5-5b43-4163-9969-dfd15849be7f	\N	{}	2
b99a4227-982f-40df-8f40-083d137bd579	documents	processed/07_contracheque_468235cf.pdf	\N	2025-11-08 00:29:51.848767+00	2025-11-08 00:29:51.848767+00	2025-11-08 00:29:51.848767+00	{"eTag": "\\"dd276e0ec9b4e19c1f27523e9f0ef974\\"", "size": 107701, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-11-08T00:29:52.000Z", "contentLength": 107701, "httpStatusCode": 200}	dbd9ef75-ce43-4beb-9665-07f714d58ffe	\N	{}	2
d42b1795-9a73-4cf2-9de7-bbf4eb7fb2f5	documents	processed/07_declaracao_de_ferias_26a1c1a0.pdf	\N	2025-11-08 00:29:55.326435+00	2025-11-08 00:29:55.326435+00	2025-11-08 00:29:55.326435+00	{"eTag": "\\"9c25b986b420a0be9a2ed6aa13f6c752\\"", "size": 161761, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-11-08T00:29:56.000Z", "contentLength": 161761, "httpStatusCode": 200}	ac954ed8-7866-4532-ba42-e58f7c013f99	\N	{}	2
dd30a978-5a24-4d15-8097-d2560428a8ad	documents	processed/07_Outros_Documentos_2ef7634e.pdf	\N	2025-10-02 20:49:20.306031+00	2025-10-02 20:49:20.306031+00	2025-10-02 20:49:20.306031+00	{"eTag": "\\"99010967597d96c549d635d0a08c574b-2\\"", "size": 7401688, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-10-02T20:49:20.000Z", "contentLength": 7401688, "httpStatusCode": 200}	f3e642f1-7382-4be4-beeb-e767f0a7d9ca	\N	{}	2
068c9208-33ff-44dd-8f4b-657709e6577a	documents	processed/07_Outros_Documentos_b36328eb.pdf	\N	2025-10-02 20:49:23.569064+00	2025-10-02 20:49:23.569064+00	2025-10-02 20:49:23.569064+00	{"eTag": "\\"eaad84195ef60487792f79eca79c8bb8\\"", "size": 163750, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-10-02T20:49:24.000Z", "contentLength": 163750, "httpStatusCode": 200}	908a9709-6ddc-4d4c-9f62-f1dc32437af9	\N	{}	2
9ae60499-4ff6-4d8d-a99b-1a6d29d9b046	documents	processed/07_Outros_Documentos_721c3d3a.pdf	\N	2025-10-02 20:49:26.842459+00	2025-10-02 20:49:26.842459+00	2025-10-02 20:49:26.842459+00	{"eTag": "\\"e42ec9b78b7ce3633339ba3c31809aa5\\"", "size": 172283, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-10-02T20:49:27.000Z", "contentLength": 172283, "httpStatusCode": 200}	afe352de-a8d3-42c0-9dc5-2b1456d32dae	\N	{}	2
83831805-a622-4d1a-bcae-f3b3e3af16b8	documents	processed/07_Outros_Documentos_ae69ed88.pdf	\N	2025-10-22 03:35:54.094974+00	2025-10-22 03:35:54.094974+00	2025-10-22 03:35:54.094974+00	{"eTag": "\\"4ffcdc6e88e9861f8dc414ee8181a33a\\"", "size": 68595, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-10-22T03:35:54.000Z", "contentLength": 68595, "httpStatusCode": 200}	62e05737-5a1a-4134-bf3e-37d5096f85e1	\N	{}	2
8a6d77a4-4792-41ae-aa24-5954730ac094	documents	processed/03_Comprovante_de_Residencia_ab4bede9.pdf	\N	2025-10-27 15:38:29.642308+00	2025-10-27 15:38:29.642308+00	2025-10-27 15:38:29.642308+00	{"eTag": "\\"93277c9bc5bd4af30acf2b420d6e091c\\"", "size": 340271, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-10-27T15:38:30.000Z", "contentLength": 340271, "httpStatusCode": 200}	d17b2859-4a73-4587-990f-4ee20945364d	\N	{}	2
b8e24b7b-9ad5-4936-beb0-08e3209f4922	documents	processed/07_aso_atestado_de_saude_ocupacional_9ad63eec.pdf	\N	2025-10-27 15:38:36.083473+00	2025-10-27 15:38:36.083473+00	2025-10-27 15:38:36.083473+00	{"eTag": "\\"3d45957942ed052549ce4d37be7e6d5b\\"", "size": 253736, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-10-27T15:38:37.000Z", "contentLength": 253736, "httpStatusCode": 200}	895167e2-c582-4326-ad1e-b5a6795741dc	\N	{}	2
1b01f84d-d795-4c58-8506-778b9e4247ab	documents	processed/07_laudo_medico_c4f2066c.pdf	\N	2025-10-27 15:38:40.592535+00	2025-10-27 15:38:40.592535+00	2025-10-27 15:38:40.592535+00	{"eTag": "\\"643e5c85a4210d2685545d2041a1da8d\\"", "size": 191809, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-10-27T15:38:41.000Z", "contentLength": 191809, "httpStatusCode": 200}	22ed8ca2-5a86-4719-8e21-d1ad231fc688	\N	{}	2
ab8a7c8d-ab3f-44b6-9fc3-9b203b20737e	documents	processed/07_laudo_medico_1ba1ecf5.pdf	\N	2025-10-27 15:39:06.736723+00	2025-10-27 15:39:06.736723+00	2025-10-27 15:39:06.736723+00	{"eTag": "\\"3e23e7b666bc538b035180f6265187e2\\"", "size": 336061, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-10-27T15:39:07.000Z", "contentLength": 336061, "httpStatusCode": 200}	d9f98715-67f2-4086-8e97-0fbaccbc2c70	\N	{}	2
376a8568-6d67-44dc-b4f3-0a633c5ea0a0	documents	processed/07_certidao_de_nascimento_49f0f224.pdf	\N	2025-10-16 19:09:40.331842+00	2025-10-16 19:09:40.331842+00	2025-10-16 19:09:40.331842+00	{"eTag": "\\"f09c0814cba524458f354cfdf534f60f\\"", "size": 378505, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-10-16T19:09:41.000Z", "contentLength": 378505, "httpStatusCode": 200}	4bef9b0a-1753-463a-9993-5ced3fca9933	\N	{}	2
c29d2ec4-247b-46d0-98de-65ea8048fc26	documents	processed/07_Outros_Documentos_5a7dc650.pdf	\N	2025-10-22 03:42:44.048042+00	2025-10-22 03:42:44.048042+00	2025-10-22 03:42:44.048042+00	{"eTag": "\\"0cbd9fa6e5c00ebbb4a63e4f2fbeff88\\"", "size": 361111, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-10-22T03:42:44.000Z", "contentLength": 361111, "httpStatusCode": 200}	479a4bdc-34d6-4f29-a7b8-2f408d115de8	\N	{}	2
a7146bf5-7fac-49bb-b059-1fd45e6d8507	documents	processed/07_Outros_Documentos_136f971e.pdf	\N	2025-10-22 03:42:56.201091+00	2025-10-22 03:42:56.201091+00	2025-10-22 03:42:56.201091+00	{"eTag": "\\"4ffcdc6e88e9861f8dc414ee8181a33a\\"", "size": 68595, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-10-22T03:42:57.000Z", "contentLength": 68595, "httpStatusCode": 200}	0f22f473-15ce-4811-b18d-f21400ea044c	\N	{}	2
22f995f7-c211-429b-b8b8-d7fd0989765f	documents	processed/07_Outros_Documentos_1bc58fbd.pdf	\N	2025-10-02 20:49:29.132461+00	2025-10-02 20:49:29.132461+00	2025-10-02 20:49:29.132461+00	{"eTag": "\\"1c8086b87ce2132fcbba8b12a0608db3\\"", "size": 178073, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-10-02T20:49:30.000Z", "contentLength": 178073, "httpStatusCode": 200}	0029d975-df04-4bfb-a187-fa5ae35b8419	\N	{}	2
87802a45-362e-458f-a781-001679aee46c	documents	processed/07_Outros_Documentos_b5ba2199.pdf	\N	2025-10-22 03:43:12.701383+00	2025-10-22 03:43:12.701383+00	2025-10-22 03:43:12.701383+00	{"eTag": "\\"14c32394a9d377ba8e640199969f67ea\\"", "size": 264530, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-10-22T03:43:13.000Z", "contentLength": 264530, "httpStatusCode": 200}	67883732-c10b-4336-8a63-5ebc1f1c546b	\N	{}	2
cf17a87f-36cc-46a1-8b44-6aa233181706	documents	processed/07_ficha_financeira_13d5c181.pdf	\N	2025-11-02 01:42:59.38643+00	2025-11-02 01:42:59.38643+00	2025-11-02 01:42:59.38643+00	{"eTag": "\\"4d2507ccf418434560001eae70d9c2c3\\"", "size": 180729, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-11-02T01:43:00.000Z", "contentLength": 180729, "httpStatusCode": 200}	23ca538e-dd54-45bc-b86c-f714b7d39799	\N	{}	2
c0eefc37-ff90-4d9c-86c6-fed8719fce09	documents	processed/07 Outros Documentos.pdf	\N	2025-09-25 03:10:30.50733+00	2025-10-22 03:54:49.079141+00	2025-09-25 03:10:30.50733+00	{"eTag": "\\"96e02ac4dd3e82309789e312e5e4d667\\"", "size": 1433051, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-10-22T03:54:49.000Z", "contentLength": 1433051, "httpStatusCode": 200}	36835c33-f8cc-48a2-8c06-95f887bd10e5	\N	{}	2
135b4888-2732-439c-8a85-0071a4c801d2	documents	processed/07_ficha_financeira_individual_ee3cbe40.pdf	\N	2025-11-02 01:43:03.894505+00	2025-11-02 01:43:03.894505+00	2025-11-02 01:43:03.894505+00	{"eTag": "\\"79a24dcaf1434fc7928be44f9f6785bc\\"", "size": 177325, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-11-02T01:43:04.000Z", "contentLength": 177325, "httpStatusCode": 200}	1f6e19b9-45c4-465b-9e9f-d11bf34aabdc	\N	{}	2
48c7fe8e-ad3b-49aa-8e06-b2827af6700a	documents	processed/04_Procuracao_14f01221.pdf	\N	2025-11-02 01:43:14.025621+00	2025-11-02 01:43:14.025621+00	2025-11-02 01:43:14.025621+00	{"eTag": "\\"3621ef9659fad4f701597606b8484d62\\"", "size": 127844, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-11-02T01:43:14.000Z", "contentLength": 127844, "httpStatusCode": 200}	eba9c7de-f451-44cd-b902-6a320421c23c	\N	{}	2
979fa8f3-8b9d-4eb8-9908-c7537b0a779a	documents	processed/07_recibo_de_pagamento_de_salario_49125543.pdf	\N	2025-11-02 01:43:30.527961+00	2025-11-02 01:43:30.527961+00	2025-11-02 01:43:30.527961+00	{"eTag": "\\"c1a14f6219afd42b873c914357c9ddd3\\"", "size": 101983, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-11-02T01:43:31.000Z", "contentLength": 101983, "httpStatusCode": 200}	5638bf77-65e1-4350-9796-5e85e9637481	\N	{}	2
d942e67a-1848-4033-bbbd-9ac9a50d2f4a	documents	processed/07_Outros_Documentos_4f19e8c7.pdf	\N	2025-10-16 19:30:17.010395+00	2025-10-16 19:30:17.010395+00	2025-10-16 19:30:17.010395+00	{"eTag": "\\"9cca75a3965a8553b46a62c3a277b18e\\"", "size": 336732, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-10-16T19:30:17.000Z", "contentLength": 336732, "httpStatusCode": 200}	0afb6477-796b-4162-87bc-83227da32378	\N	{}	2
24679dcd-2807-4c0f-bc42-d3d7aa787592	documents	processed/07_Outros_Documentos_dba299f0.pdf	\N	2025-10-16 19:30:39.29834+00	2025-10-16 19:30:39.29834+00	2025-10-16 19:30:39.29834+00	{"eTag": "\\"349d46c3a084c7ab4761dc21bb8d511b\\"", "size": 439162, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-10-16T19:30:40.000Z", "contentLength": 439162, "httpStatusCode": 200}	033b2308-4a50-4e54-b520-d8ecc4f97ab7	\N	{}	2
cf6a3e8e-9ee1-4ff4-9ebd-58fafdca1015	documents	processed/07_Outros_Documentos_2c78f15c.pdf	\N	2025-10-22 03:43:24.235437+00	2025-10-22 03:43:24.235437+00	2025-10-22 03:43:24.235437+00	{"eTag": "\\"af38231f61574735a9697d45f563433f\\"", "size": 239660, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-10-22T03:43:25.000Z", "contentLength": 239660, "httpStatusCode": 200}	1f5e6ccf-75fa-4d66-966d-9449874e3719	\N	{}	2
51df613b-b524-4ab7-8267-718834019d1c	documents	processed/07_Outros_Documentos_a079ad38.pdf	\N	2025-11-02 02:30:15.670254+00	2025-11-02 02:30:15.670254+00	2025-11-02 02:30:15.670254+00	{"eTag": "\\"bcdc27335393fa0a3a3e47dd70a81f57-3\\"", "size": 12054512, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-11-02T02:30:15.000Z", "contentLength": 12054512, "httpStatusCode": 200}	6a9d868d-4eaa-4456-b4a7-0553375596bc	\N	{}	2
c6e30068-bebb-45e3-8cc8-a698950b7a4b	documents	processed/07_Outros_Documentos_745e967c.pdf	\N	2025-10-02 22:44:09.6316+00	2025-10-02 22:44:09.6316+00	2025-10-02 22:44:09.6316+00	{"eTag": "\\"13a9107be1a2ae19df9db60ef7e8cd82\\"", "size": 11903, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-10-02T22:44:10.000Z", "contentLength": 11903, "httpStatusCode": 200}	6725fe71-9125-4e1f-a05a-c77ceb3c4d70	\N	{}	2
66cbdb5d-0280-4215-8e8f-c35c6e300e53	documents	processed/07_Outros_Documentos_dc0c9a7e.pdf	\N	2025-10-08 23:05:33.447931+00	2025-10-08 23:05:33.447931+00	2025-10-08 23:05:33.447931+00	{"eTag": "\\"bbc1dd367bb93ed672aa811c1f46f2d7\\"", "size": 439161, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-10-08T23:05:34.000Z", "contentLength": 439161, "httpStatusCode": 200}	616b2765-01bb-4d2f-80a7-700a28fb8838	\N	{}	2
1ef1dd03-bca9-4291-b94f-408dbd4ba4b8	documents	processed/07_Outros_Documentos_1af21421.pdf	\N	2025-11-02 02:58:44.427221+00	2025-11-02 02:58:44.427221+00	2025-11-02 02:58:44.427221+00	{"eTag": "\\"bcdc27335393fa0a3a3e47dd70a81f57-3\\"", "size": 12054512, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-11-02T02:58:44.000Z", "contentLength": 12054512, "httpStatusCode": 200}	9ab7791d-d3c7-4183-8b0e-dc38f6cb3610	\N	{}	2
4f0b412b-8c2a-40c1-bdb9-3802e94edecf	documents	processed/07_Outros_Documentos_9e6ef1b4.pdf	\N	2025-10-02 22:57:23.998945+00	2025-10-02 22:57:23.998945+00	2025-10-02 22:57:23.998945+00	{"eTag": "\\"eaad84195ef60487792f79eca79c8bb8\\"", "size": 163750, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-10-02T22:57:24.000Z", "contentLength": 163750, "httpStatusCode": 200}	789e9a91-9ea0-4018-bf88-fdf02e786e56	\N	{}	2
ed6ee832-b82f-496f-a4db-5d35d28772a0	documents	processed/07_Outros_Documentos_1e1876e7.pdf	\N	2025-09-29 17:18:41.728182+00	2025-09-29 17:18:41.728182+00	2025-09-29 17:18:41.728182+00	{"eTag": "\\"2ce827e8d38036311e5f22db11de69cb\\"", "size": 292928, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-09-29T17:18:42.000Z", "contentLength": 292928, "httpStatusCode": 200}	9602a550-3d76-4503-8b38-b615198b89ea	\N	{}	2
b0be1bb0-7601-4a45-958d-32914ae5b4e1	documents	processed/07_Outros_Documentos_357d5a91.pdf	\N	2025-10-22 03:43:35.614003+00	2025-10-22 03:43:35.614003+00	2025-10-22 03:43:35.614003+00	{"eTag": "\\"8c72fadf13e9b23edfa3e48b74b30d0e\\"", "size": 220577, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-10-22T03:43:36.000Z", "contentLength": 220577, "httpStatusCode": 200}	6a42e1d2-1798-4afa-82c7-e3ea3c03af21	\N	{}	2
86e8c867-d2b1-4acf-bf7c-5fc8165414f5	documents	processed/05_Declaracao_de_Hipossuficiencia_1fcfdb61.pdf	\N	2025-11-03 02:28:57.456809+00	2025-11-03 02:28:57.456809+00	2025-11-03 02:28:57.456809+00	{"eTag": "\\"87bfd03a84af9ca1ed17a764b00f9490\\"", "size": 91332, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-11-03T02:28:58.000Z", "contentLength": 91332, "httpStatusCode": 200}	8aacea90-77dc-4d23-b50a-7ca490de21f5	\N	{}	2
f6ca0abc-641f-4c3c-ad69-06352a156566	documents	processed/07_ficha_financeira_0f4eb7b9.pdf	\N	2025-11-03 02:29:02.426798+00	2025-11-03 02:29:02.426798+00	2025-11-03 02:29:02.426798+00	{"eTag": "\\"3d2f7726a6e25a60e37e9e71108d5bf6\\"", "size": 149731, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-11-03T02:29:03.000Z", "contentLength": 149731, "httpStatusCode": 200}	56d40f7f-2ace-4c12-bd85-154ac8833970	\N	{}	2
990a3a06-a5c8-4e27-b913-6e122d745a4b	documents	processed/07_documento_judicial_5d1b725a.pdf	\N	2025-10-12 21:41:53.625589+00	2025-10-12 21:41:53.625589+00	2025-10-12 21:41:53.625589+00	{"eTag": "\\"a18a71d3dce474b553cf32569ae432fa\\"", "size": 336234, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-10-12T21:41:54.000Z", "contentLength": 336234, "httpStatusCode": 200}	52a76f0e-9013-42cb-9946-3d8fdc9c9ae6	\N	{}	2
7f16bbe6-b77a-4681-a353-6d066dfb3e03	documents	processed/07_Outros_Documentos_d5d5bf89.pdf	\N	2025-09-29 17:30:52.816667+00	2025-09-29 17:30:52.816667+00	2025-09-29 17:30:52.816667+00	{"eTag": "\\"2ce827e8d38036311e5f22db11de69cb\\"", "size": 292928, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-09-29T17:30:53.000Z", "contentLength": 292928, "httpStatusCode": 200}	6e8fc990-e2d9-4f9f-b421-987eb6dede25	\N	{}	2
f9007366-28bd-4840-a169-d9c601cc59e0	documents	processed/07_Outros_Documentos_1e6a39e2.pdf	\N	2025-10-03 01:46:43.900639+00	2025-10-03 01:46:43.900639+00	2025-10-03 01:46:43.900639+00	{"eTag": "\\"1854f159d1bda4a9c3bf618eb57b95de\\"", "size": 584, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-10-03T01:46:44.000Z", "contentLength": 584, "httpStatusCode": 200}	9ba02e4f-6c97-4878-8801-29a5c9d333eb	\N	{}	2
ff7c356c-4b7c-4b7f-9d6b-fb3a0bb9131a	documents	processed/07_Outros_Documentos_931dc3ca.pdf	\N	2025-10-03 01:46:53.464473+00	2025-10-03 01:46:53.464473+00	2025-10-03 01:46:53.464473+00	{"eTag": "\\"eaad84195ef60487792f79eca79c8bb8\\"", "size": 163750, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-10-03T01:46:54.000Z", "contentLength": 163750, "httpStatusCode": 200}	d9f7451f-b583-417d-93c1-e5b27725e69b	\N	{}	2
f61c5fb6-4dc1-4570-a356-97af9605b26d	documents	processed/07_Outros_Documentos_dbcd633f.pdf	\N	2025-10-03 01:46:56.270627+00	2025-10-03 01:46:56.270627+00	2025-10-03 01:46:56.270627+00	{"eTag": "\\"e42ec9b78b7ce3633339ba3c31809aa5\\"", "size": 172283, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-10-03T01:46:57.000Z", "contentLength": 172283, "httpStatusCode": 200}	73e618b3-545a-44e6-9469-a0956a049a8f	\N	{}	2
457096b9-d91e-4e1e-8e80-03b67e6b66c9	documents	processed/07_Outros_Documentos_8fd64f4f.pdf	\N	2025-10-03 01:46:59.661327+00	2025-10-03 01:46:59.661327+00	2025-10-03 01:46:59.661327+00	{"eTag": "\\"1c8086b87ce2132fcbba8b12a0608db3\\"", "size": 178073, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-10-03T01:47:00.000Z", "contentLength": 178073, "httpStatusCode": 200}	87ae3a8a-bef0-4d40-a9b6-2b6ba055c847	\N	{}	2
a31c3068-e817-47c8-b441-3117d47b9de6	documents	processed/07_Outros_Documentos_aec3fe0d.pdf	\N	2025-10-22 03:43:47.010817+00	2025-10-22 03:43:47.010817+00	2025-10-22 03:43:47.010817+00	{"eTag": "\\"5a636de4afcd84928e3c888f12d5ae67\\"", "size": 286109, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-10-22T03:43:47.000Z", "contentLength": 286109, "httpStatusCode": 200}	236ca436-ae5c-4d4c-9b47-c798c9a5db33	\N	{}	2
51dbb374-3523-41ea-b537-9f2231b4d898	documents	processed/07_ficha_financeira_individual_0429bea6.pdf	\N	2025-11-03 15:57:12.802688+00	2025-11-03 15:57:12.802688+00	2025-11-03 15:57:12.802688+00	{"eTag": "\\"16962dba4e4531a03e7270cdf7d3b781\\"", "size": 177324, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-11-03T15:57:13.000Z", "contentLength": 177324, "httpStatusCode": 200}	80b35303-c95b-4275-b3e8-54d33e0237f7	\N	{}	2
db070eff-ff7b-44f2-8997-e4f99923a506	documents	processed/07_Outros_Documentos_0320db52.pdf	\N	2025-10-22 03:43:59.444059+00	2025-10-22 03:43:59.444059+00	2025-10-22 03:43:59.444059+00	{"eTag": "\\"5e772631448303e180adf5b41fe71c57\\"", "size": 224974, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-10-22T03:44:00.000Z", "contentLength": 224974, "httpStatusCode": 200}	a0dd98b3-9bce-4fcc-8bea-4ad2b585edc5	\N	{}	2
ec2c4d58-9f86-4792-9ae3-ac6823d24a49	documents	processed/07_Outros_Documentos_dd7268c9.pdf	\N	2025-10-09 00:24:42.870131+00	2025-10-09 00:24:42.870131+00	2025-10-09 00:24:42.870131+00	{"eTag": "\\"1089d41b447df9ff2c84e49f8ce560d5\\"", "size": 537771, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-10-09T00:24:43.000Z", "contentLength": 537771, "httpStatusCode": 200}	32c3ca9d-ff28-4f59-a9d3-4070f63a050e	\N	{}	2
11f9458b-f352-4dc4-8eaa-d686d037728e	documents	processed/07_certidao_73477f7e.pdf	\N	2025-10-12 21:41:58.478279+00	2025-10-12 21:41:58.478279+00	2025-10-12 21:41:58.478279+00	{"eTag": "\\"2d5b5352239832057d4959d68aa2ce0f\\"", "size": 77447, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-10-12T21:41:59.000Z", "contentLength": 77447, "httpStatusCode": 200}	941777de-55ff-4b27-808e-7fa7f2da5cb9	\N	{}	2
c09a5c71-b78c-4c1c-87be-a0448576a4ca	documents	processed/07_documento_judicial_004ee1ee.pdf	\N	2025-10-12 21:42:02.902223+00	2025-10-12 21:42:02.902223+00	2025-10-12 21:42:02.902223+00	{"eTag": "\\"8d1f99d35b3ca57bc6c0fa956b93fb13\\"", "size": 98087, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-10-12T21:42:03.000Z", "contentLength": 98087, "httpStatusCode": 200}	9fd75911-7a44-4bef-92f1-0d1cf4c3584b	\N	{}	2
4bede4c6-71d2-47cb-81d6-e0f24cdbeb49	documents	processed/07_peticao_9aeb000d.pdf	\N	2025-10-12 21:42:11.113329+00	2025-10-12 21:42:11.113329+00	2025-10-12 21:42:11.113329+00	{"eTag": "\\"fe0d34f21e3830a5a590f11c4544854f\\"", "size": 1563491, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-10-12T21:42:11.000Z", "contentLength": 1563491, "httpStatusCode": 200}	736c3a96-af45-4779-a8d6-7651a318a0ca	\N	{}	2
2332551b-9d80-425f-bfaf-efd02786632d	documents	processed/07_Outros_Documentos_63bea0ee.pdf	\N	2025-10-22 03:44:09.102026+00	2025-10-22 03:44:09.102026+00	2025-10-22 03:44:09.102026+00	{"eTag": "\\"5fd4046d6a865702419bf49fc7238bfc\\"", "size": 183186, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-10-22T03:44:10.000Z", "contentLength": 183186, "httpStatusCode": 200}	fc22c1c1-50ab-4cc8-8091-498502da1b67	\N	{}	2
63efd5cd-87e8-4d9f-918e-c54199a020b6	documents	processed/07_Outros_Documentos_3a92808d.pdf	\N	2025-10-22 03:44:16.210297+00	2025-10-22 03:44:16.210297+00	2025-10-22 03:44:16.210297+00	{"eTag": "\\"bc1c2c71acc4146667372c17d8a613e6\\"", "size": 126438, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-10-22T03:44:17.000Z", "contentLength": 126438, "httpStatusCode": 200}	de2785d7-328a-46f1-b4d0-2a31ad81b3c8	\N	{}	2
954bb4f8-d20a-4dbe-849a-85f523b9a5de	documents	processed/07_Outros_Documentos_c23382b1.pdf	\N	2025-10-10 18:14:29.741665+00	2025-10-10 18:14:29.741665+00	2025-10-10 18:14:29.741665+00	{"eTag": "\\"728884e4879152181e268e89a5a27349\\"", "size": 439161, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-10-10T18:14:30.000Z", "contentLength": 439161, "httpStatusCode": 200}	b7c186ee-2946-478b-a524-8c10119ec817	\N	{}	2
c726f6a4-af3b-45dc-b8a5-0c3c6c37a42b	documents	processed/07_Outros_Documentos_0419df7a.pdf	\N	2025-10-10 18:14:40.114361+00	2025-10-10 18:14:40.114361+00	2025-10-10 18:14:40.114361+00	{"eTag": "\\"4a5b74d3daaeee437a14eeaceeecd747\\"", "size": 547853, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-10-10T18:14:41.000Z", "contentLength": 547853, "httpStatusCode": 200}	5c9374a2-89b6-48fc-92f9-6183a9c77ffd	\N	{}	2
c084268b-d455-4c7f-8e5a-98b318206b87	documents	processed/07_Outros_Documentos_3ae4d168.pdf	\N	2025-10-01 13:28:48.57144+00	2025-10-01 13:28:48.57144+00	2025-10-01 13:28:48.57144+00	{"eTag": "\\"93574835c9751ba028eb3214d174f5a6\\"", "size": 336732, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-10-01T13:28:49.000Z", "contentLength": 336732, "httpStatusCode": 200}	bce036fa-95fa-43dc-94f4-a860a22d2934	\N	{}	2
d4fd99c3-e19a-4551-a249-8dcffb946295	documents	processed/07_Outros_Documentos_5a3dd217.pdf	\N	2025-10-10 18:14:43.525753+00	2025-10-10 18:14:43.525753+00	2025-10-10 18:14:43.525753+00	{"eTag": "\\"d328d3befa6e42f523d191ee32693ce1\\"", "size": 524856, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-10-10T18:14:44.000Z", "contentLength": 524856, "httpStatusCode": 200}	55c2fea8-b4cd-4809-a44c-051afc9553c0	\N	{}	2
2f10953f-af99-4a04-949e-65ee9d979c7c	documents	processed/07_Outros_Documentos_Parte_2_3c199736.pdf	\N	2025-11-03 20:25:56.565239+00	2025-11-03 20:25:56.565239+00	2025-11-03 20:25:56.565239+00	{"eTag": "\\"4b92e728bbc715d17e464bb87793ce39-7\\"", "size": 36548504, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-11-03T20:25:56.000Z", "contentLength": 36548504, "httpStatusCode": 200}	8e3ea2af-0456-42ec-a838-c04a309dcdcc	\N	{}	2
cb74a9ac-deae-4d54-8398-9dee97a24ae8	documents	processed/07_Outros_Documentos_Parte_3_2e3a6961.pdf	\N	2025-11-03 20:25:56.85596+00	2025-11-03 20:25:56.85596+00	2025-11-03 20:25:56.85596+00	{"eTag": "\\"ab23b471be3ded9e7643449693b1d1e3\\"", "size": 416796, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-11-03T20:25:57.000Z", "contentLength": 416796, "httpStatusCode": 200}	c893ab07-c856-49d2-81f7-d6efc2461d47	\N	{}	2
3b71fb56-8d31-41b8-b709-c5aca9d0ccf8	documents	processed/07_Outros_Documentos_fae59a97.pdf	\N	2025-10-01 13:28:56.721223+00	2025-10-01 13:28:56.721223+00	2025-10-01 13:28:56.721223+00	{"eTag": "\\"55c8fecb65b5ec52c6f1847b2243d955\\"", "size": 30862, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-10-01T13:28:57.000Z", "contentLength": 30862, "httpStatusCode": 200}	a5b7a726-2c76-4950-815e-ea4a57fa4558	\N	{}	2
4b7c2dc8-4d51-4ddd-b4b9-3bd97b0b64f8	documents	processed/07_Outros_Documentos_f87df7be.pdf	\N	2025-10-01 13:36:34.005673+00	2025-10-01 13:36:34.005673+00	2025-10-01 13:36:34.005673+00	{"eTag": "\\"456fe9169b26339ed402eef34f0b356b\\"", "size": 336732, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-10-01T13:36:34.000Z", "contentLength": 336732, "httpStatusCode": 200}	66ab52c9-414f-43fa-a01b-c702596e86c5	\N	{}	2
1f64f613-bb7e-40d6-af72-fe29a97b66ae	documents	processed/07_Outros_Documentos_482509d5.pdf	\N	2025-10-01 13:39:19.932031+00	2025-10-01 13:39:19.932031+00	2025-10-01 13:39:19.932031+00	{"eTag": "\\"3c96354a596adc0abcccd9099a424eb0\\"", "size": 336732, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-10-01T13:39:20.000Z", "contentLength": 336732, "httpStatusCode": 200}	a1c1daa3-5a4d-4ec9-8822-42013569542e	\N	{}	2
e078ad3f-5bf3-4dea-8f2f-91c9eafe628e	documents	processed/07_Outros_Documentos_41eef387.pdf	\N	2025-10-22 03:46:08.512705+00	2025-10-22 03:46:08.512705+00	2025-10-22 03:46:08.512705+00	{"eTag": "\\"0cbd9fa6e5c00ebbb4a63e4f2fbeff88\\"", "size": 361111, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-10-22T03:46:09.000Z", "contentLength": 361111, "httpStatusCode": 200}	5d44a251-18c3-44b5-9320-af89e4d3f0e1	\N	{}	2
d0350ab8-44eb-4285-b92b-ef4fde785126	documents	processed/07_Outros_Documentos_10f2e48b.pdf	\N	2025-10-01 13:41:09.260131+00	2025-10-01 13:41:09.260131+00	2025-10-01 13:41:09.260131+00	{"eTag": "\\"d24dee5ecc3bcaaecc613421febd14d3\\"", "size": 336732, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-10-01T13:41:10.000Z", "contentLength": 336732, "httpStatusCode": 200}	da634b9f-86e7-4dac-819c-fe2ae74d2580	\N	{}	2
b5ac1f78-4284-4eeb-8812-06398206a567	documents	processed/07_peticao_Parte_2_df530006.pdf	\N	2025-11-03 20:41:17.755817+00	2025-11-03 20:41:17.755817+00	2025-11-03 20:41:17.755817+00	{"eTag": "\\"0dcbb8c4618a25c2d0770764d25fb703-7\\"", "size": 36548504, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-11-03T20:41:17.000Z", "contentLength": 36548504, "httpStatusCode": 200}	2df4bf5d-df1f-45c5-af80-fcce014aa57d	\N	{}	2
6478a906-b4f0-4b7b-a828-0a826765a3aa	documents	processed/07_peticao_Parte_3_657bd81f.pdf	\N	2025-11-03 20:41:18.02777+00	2025-11-03 20:41:18.02777+00	2025-11-03 20:41:18.02777+00	{"eTag": "\\"1ba3e58f9cbc84de1f65ab568ce49b1c\\"", "size": 416797, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-11-03T20:41:18.000Z", "contentLength": 416797, "httpStatusCode": 200}	683e8137-7671-4fff-a04a-5cbd63447f00	\N	{}	2
ce56de0c-0590-44a2-8140-e30a0b200c1e	documents	processed/07_Outros_Documentos_9b8d136a.pdf	\N	2025-10-01 13:49:52.302186+00	2025-10-01 13:49:52.302186+00	2025-10-01 13:49:52.302186+00	{"eTag": "\\"3e198670283bf952e5371f7cd16d0c0a\\"", "size": 336732, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-10-01T13:49:53.000Z", "contentLength": 336732, "httpStatusCode": 200}	42259ed1-e8c5-4723-8109-76a3c6010400	\N	{}	2
7291c48f-0e94-4826-9039-35b83ffbfc30	documents	processed/04_Procuracao_554a12f7.pdf	\N	2025-11-03 22:18:04.843366+00	2025-11-03 22:18:04.843366+00	2025-11-03 22:18:04.843366+00	{"eTag": "\\"f372a4e4b4353244eddbc3621e342fff\\"", "size": 128744, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-11-03T22:18:05.000Z", "contentLength": 128744, "httpStatusCode": 200}	74711907-3475-434f-8a06-f1c3a8eb5904	\N	{}	2
a2ca3938-c068-4656-99b8-78f6bb9d42af	documents	processed/04_Procuracao_f9dc28d9.pdf	\N	2025-11-03 22:18:18.085317+00	2025-11-03 22:18:18.085317+00	2025-11-03 22:18:18.085317+00	{"eTag": "\\"bc911746f7a7fa477ecfe58e96378ac1\\"", "size": 196267, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-11-03T22:18:19.000Z", "contentLength": 196267, "httpStatusCode": 200}	b4fd528d-56b0-43d1-bc2d-3948a4d1a44e	\N	{}	2
3a68eb88-d2b0-4fdb-bc4b-f1fe8329289d	documents	processed/03_Comprovante_de_Residencia_ee98368e.pdf	\N	2025-11-03 22:18:27.376433+00	2025-11-03 22:18:27.376433+00	2025-11-03 22:18:27.376433+00	{"eTag": "\\"4ffcdc6e88e9861f8dc414ee8181a33a\\"", "size": 68595, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-11-03T22:18:28.000Z", "contentLength": 68595, "httpStatusCode": 200}	d159281f-2912-46df-a5ab-e68ee0e268f4	\N	{}	2
7517365e-0c24-4d0e-aa35-17e12a817457	documents	processed/05_Declaracao_de_Hipossuficiencia_b6ca538b.pdf	\N	2025-11-03 22:18:37.873434+00	2025-11-03 22:18:37.873434+00	2025-11-03 22:18:37.873434+00	{"eTag": "\\"f620fd36db5ed3c4a31c7fbaa96f836f\\"", "size": 91511, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-11-03T22:18:38.000Z", "contentLength": 91511, "httpStatusCode": 200}	3839d107-007f-4c76-8926-42c3822ffcf4	\N	{}	2
f6866daf-19a7-46bd-a4e8-5880a0cdcfb4	documents	processed/07_Outros_Documentos_067180b4.pdf	\N	2025-09-30 03:07:27.862127+00	2025-09-30 03:07:27.862127+00	2025-09-30 03:07:27.862127+00	{"eTag": "\\"2ce827e8d38036311e5f22db11de69cb\\"", "size": 292928, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-09-30T03:07:28.000Z", "contentLength": 292928, "httpStatusCode": 200}	6e629ff7-da93-4034-a50e-1110880109c3	\N	{}	2
0af9c5b5-5ccb-4548-a55d-3843f1e64e62	documents	processed/05_Declaracao_de_Hipossuficiencia_57d3ae8c.pdf	\N	2025-11-03 22:18:49.581452+00	2025-11-03 22:18:49.581452+00	2025-11-03 22:18:49.581452+00	{"eTag": "\\"be3d8d821ede93f3b99dc27eda07baf8\\"", "size": 117916, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-11-03T22:18:50.000Z", "contentLength": 117916, "httpStatusCode": 200}	26626218-ddd9-4298-8706-a41c61359caa	\N	{}	2
5bbbc795-6d28-4661-8500-45054056f10f	documents	processed/07_Outros_Documentos_74ef4193.pdf	\N	2025-10-04 03:29:15.107079+00	2025-10-04 03:29:15.107079+00	2025-10-04 03:29:15.107079+00	{"eTag": "\\"eaad84195ef60487792f79eca79c8bb8\\"", "size": 163750, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-10-04T03:29:16.000Z", "contentLength": 163750, "httpStatusCode": 200}	d5c0b42c-84b7-41ef-96da-c18c5a5389a0	\N	{}	2
ead809e4-4a33-4b69-abab-0d034f72f564	documents	processed/06_Contratos_7cde3ade.pdf	\N	2025-11-03 22:19:03.758142+00	2025-11-03 22:19:03.758142+00	2025-11-03 22:19:03.758142+00	{"eTag": "\\"2fb857c33bf80f0d744180869b619771\\"", "size": 258388, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-11-03T22:19:04.000Z", "contentLength": 258388, "httpStatusCode": 200}	10ab44f2-7e73-41f0-8370-36bfa57330a9	\N	{}	2
f03af8a7-2ca2-4164-a48e-4526161465e6	documents	processed/06_Contratos_7dfbf91a.pdf	\N	2025-11-03 22:19:12.589837+00	2025-11-03 22:19:12.589837+00	2025-11-03 22:19:12.589837+00	{"eTag": "\\"f86b8c55074cea41a4b4c8d7379a98ce\\"", "size": 305666, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-11-03T22:19:13.000Z", "contentLength": 305666, "httpStatusCode": 200}	c5887c1f-3be9-43f0-bed4-56beeddfcd4a	\N	{}	2
276b2f45-c8cf-40a6-9412-027e0ef497bd	documents	processed/07_nota_fiscal_de_servico_eletronica_995a17ac.pdf	\N	2025-11-03 22:19:19.29048+00	2025-11-03 22:19:19.29048+00	2025-11-03 22:19:19.29048+00	{"eTag": "\\"7100e3729be41c0a19e60c7683be9ea6\\"", "size": 204681, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-11-03T22:19:20.000Z", "contentLength": 204681, "httpStatusCode": 200}	855f94b1-793f-4bf3-aca5-bf8c650bea47	\N	{}	2
d6bb6e32-7005-4640-b48e-2deb55d88c2c	documents	processed/06_Contratos_252d7377.pdf	\N	2025-11-03 22:19:27.660584+00	2025-11-03 22:19:27.660584+00	2025-11-03 22:19:27.660584+00	{"eTag": "\\"b60d67742219402ed88e0bbda97bf516\\"", "size": 294009, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-11-03T22:19:28.000Z", "contentLength": 294009, "httpStatusCode": 200}	bba1fe71-7d0e-4a56-ac54-d39f58eeeebf	\N	{}	2
21447129-8166-4848-819c-2f79c5ae9607	documents	processed/06_Contratos_a93aed51.pdf	\N	2025-11-03 22:19:37.196112+00	2025-11-03 22:19:37.196112+00	2025-11-03 22:19:37.196112+00	{"eTag": "\\"738bf542f1d37de4615e92dceb828e67\\"", "size": 310404, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-11-03T22:19:38.000Z", "contentLength": 310404, "httpStatusCode": 200}	f20b3d6b-1f0b-4fe1-8f26-2e72546f7828	\N	{}	2
48b37d91-6590-4b1b-9689-0af8045762c1	documents	processed/07_Outros_Documentos_e971ea16.pdf	\N	2025-10-22 03:46:20.6403+00	2025-10-22 03:46:20.6403+00	2025-10-22 03:46:20.6403+00	{"eTag": "\\"4ffcdc6e88e9861f8dc414ee8181a33a\\"", "size": 68595, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-10-22T03:46:21.000Z", "contentLength": 68595, "httpStatusCode": 200}	efa1767a-5a1a-49ff-b1fd-fd2dcf3d2e5a	\N	{}	2
95c59953-fadb-42ba-8945-f4a4ad910d76	documents	processed/06_Contratos_4b1714fb.pdf	\N	2025-11-03 22:19:45.793377+00	2025-11-03 22:19:45.793377+00	2025-11-03 22:19:45.793377+00	{"eTag": "\\"a7ca383897b5cd3638b7532c4ad216e5\\"", "size": 299890, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-11-03T22:19:46.000Z", "contentLength": 299890, "httpStatusCode": 200}	f7ef8a3b-86fd-4a26-8fe8-d110d220d82d	\N	{}	2
340d1982-ea15-4094-98c9-924cbeeb5516	documents	processed/06_Contratos_766c6793.pdf	\N	2025-11-03 22:19:52.594926+00	2025-11-03 22:19:52.594926+00	2025-11-03 22:19:52.594926+00	{"eTag": "\\"38cf4776ae17b50c32744b0fbb1c64d4\\"", "size": 260930, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-11-03T22:19:53.000Z", "contentLength": 260930, "httpStatusCode": 200}	a056793a-4642-4ea2-b256-27ea8c8f4e82	\N	{}	2
8ae3cac8-76ac-41b9-a65e-e34a1ecaacf8	documents	processed/06_Contratos_43707335.pdf	\N	2025-11-03 22:20:02.264266+00	2025-11-03 22:20:02.264266+00	2025-11-03 22:20:02.264266+00	{"eTag": "\\"95ac3cc2a0f8ad4ba37f0768cec1192c\\"", "size": 256833, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-11-03T22:20:03.000Z", "contentLength": 256833, "httpStatusCode": 200}	ada9f212-8f98-4e76-9296-03dcfae1027b	\N	{}	2
9509d807-b10c-4c01-bc1c-c133bcd27252	documents	processed/06_Contratos_75bd48b4.pdf	\N	2025-11-03 22:20:10.868257+00	2025-11-03 22:20:10.868257+00	2025-11-03 22:20:10.868257+00	{"eTag": "\\"5deac44e5e87b09ab1cedf773067bc4b\\"", "size": 282599, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-11-03T22:20:11.000Z", "contentLength": 282599, "httpStatusCode": 200}	025a23a5-3f48-4abf-9436-645b22e5cdc7	\N	{}	2
3c1e6abd-3d1e-4441-a3be-95ab9d208a9d	documents	processed/06_Contratos_162045c8.pdf	\N	2025-11-03 22:20:21.509249+00	2025-11-03 22:20:21.509249+00	2025-11-03 22:20:21.509249+00	{"eTag": "\\"2fbc82544b3e497574915bd80a79c79b\\"", "size": 268628, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-11-03T22:20:22.000Z", "contentLength": 268628, "httpStatusCode": 200}	f6ac7e5a-5b85-4b08-8f34-2f261ce6c588	\N	{}	2
71ff6bf5-ccca-4c83-ad62-ad102fdf29aa	documents	processed/07_Outros_Documentos_376a2a04.pdf	\N	2025-11-03 22:20:28.066429+00	2025-11-03 22:20:28.066429+00	2025-11-03 22:20:28.066429+00	{"eTag": "\\"ceccfbc6b34fd3ae645e8beded4df019\\"", "size": 99449, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-11-03T22:20:29.000Z", "contentLength": 99449, "httpStatusCode": 200}	2734cd1c-2973-42b1-8478-5926685c177d	\N	{}	2
34a54a8b-911c-4b40-a2af-b7e9e5418963	documents	processed/06_Contratos_f666bb06.pdf	\N	2025-11-03 22:20:35.61056+00	2025-11-03 22:20:35.61056+00	2025-11-03 22:20:35.61056+00	{"eTag": "\\"1570a4c02fcdb53ec09f16c9988b30ff\\"", "size": 268970, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-11-03T22:20:36.000Z", "contentLength": 268970, "httpStatusCode": 200}	8084fcd1-dcf3-43f9-b014-d55c19b0df8e	\N	{}	2
5c0597b9-d53b-407f-a0f0-f0a2822a053c	documents	processed/07_boletim_de_ocorrencia_b7aa5292.pdf	\N	2025-11-03 22:20:40.861071+00	2025-11-03 22:20:40.861071+00	2025-11-03 22:20:40.861071+00	{"eTag": "\\"b4c82d93b62732539f5a647d79e345bc\\"", "size": 138195, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-11-03T22:20:41.000Z", "contentLength": 138195, "httpStatusCode": 200}	723b4e08-e79b-408c-9042-b5f83b10974b	\N	{}	2
dbff4f94-4464-4f63-a487-50088257bbbf	documents	processed/06_Contratos_bcae3a04.pdf	\N	2025-11-03 22:20:45.07122+00	2025-11-03 22:20:45.07122+00	2025-11-03 22:20:45.07122+00	{"eTag": "\\"dbebe490eefc3af82a4dc407ce5703e3\\"", "size": 72234, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-11-03T22:20:46.000Z", "contentLength": 72234, "httpStatusCode": 200}	e4077ec1-04f2-46ca-9a2c-14f7b979bc90	\N	{}	2
567ab3b8-3daf-409d-9bed-703e143c5291	documents	processed/06_Contratos_1156b838.pdf	\N	2025-11-03 22:20:51.804525+00	2025-11-03 22:20:51.804525+00	2025-11-03 22:20:51.804525+00	{"eTag": "\\"e2765d9ee5f0bf5b61e0920e96d6f26d\\"", "size": 118909, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-11-03T22:20:52.000Z", "contentLength": 118909, "httpStatusCode": 200}	6effef7c-39fa-42f6-8199-2a28a0a77e40	\N	{}	2
73e2c761-3b47-4a43-9d8a-f44ef22dc015	documents	processed/07_laudo_medico_5c23d22c.pdf	\N	2025-10-16 19:30:52.678284+00	2025-10-16 19:30:52.678284+00	2025-10-16 19:30:52.678284+00	{"eTag": "\\"d328d3befa6e42f523d191ee32693ce1\\"", "size": 524856, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-10-16T19:30:53.000Z", "contentLength": 524856, "httpStatusCode": 200}	81d6a42f-31ba-4d6b-997f-ad9fcfcd9316	\N	{}	2
1081d8ce-17df-4c8d-b376-ff1701e25e51	documents	processed/07_laudo_medico_0258c1cf.pdf	\N	2025-10-16 19:30:59.535337+00	2025-10-16 19:30:59.535337+00	2025-10-16 19:30:59.535337+00	{"eTag": "\\"4a5b74d3daaeee437a14eeaceeecd747\\"", "size": 547853, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-10-16T19:31:00.000Z", "contentLength": 547853, "httpStatusCode": 200}	d5b6e36e-3d29-4822-9d70-c2e57b454352	\N	{}	2
b92681d1-2753-4b69-8e86-e36dc3c1a64d	documents	processed/07_Outros_Documentos_c78c2df2.pdf	\N	2025-11-03 22:20:59.453867+00	2025-11-03 22:20:59.453867+00	2025-11-03 22:20:59.453867+00	{"eTag": "\\"76341951354d1e713194fa520a7c3c17\\"", "size": 160475, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-11-03T22:21:00.000Z", "contentLength": 160475, "httpStatusCode": 200}	fdc6b33b-43e0-4693-827f-baf9230d3a25	\N	{}	2
736e8619-15f9-413e-8775-e987557440fe	documents	processed/07_certificado_de_garantia_ec8219b1.pdf	\N	2025-11-03 22:21:05.035202+00	2025-11-03 22:21:05.035202+00	2025-11-03 22:21:05.035202+00	{"eTag": "\\"790ccb4e5341ea9d6690620cdd9835b0\\"", "size": 151725, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-11-03T22:21:05.000Z", "contentLength": 151725, "httpStatusCode": 200}	4ad81d47-5d3f-407e-bf04-5ed26a083276	\N	{}	2
91b33423-e0ab-48a0-93be-d55dd5a00eab	documents	processed/07_recibo_df7de707.pdf	\N	2025-11-03 22:21:09.670248+00	2025-11-03 22:21:09.670248+00	2025-11-03 22:21:09.670248+00	{"eTag": "\\"8dcb8123105877f00cb95bc13cd6489f\\"", "size": 140276, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-11-03T22:21:10.000Z", "contentLength": 140276, "httpStatusCode": 200}	93295422-0440-4efb-b6ad-ca80f60132b2	\N	{}	2
87f3dd6f-3e2b-4736-8aa0-b0ca18af01b1	documents	processed/07_Outros_Documentos_ba6538a0.pdf	\N	2025-10-22 03:46:39.409175+00	2025-10-22 03:46:39.409175+00	2025-10-22 03:46:39.409175+00	{"eTag": "\\"14c32394a9d377ba8e640199969f67ea\\"", "size": 264530, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-10-22T03:46:40.000Z", "contentLength": 264530, "httpStatusCode": 200}	715dd1d1-af71-4ea2-8c72-3b1105409916	\N	{}	2
97ff6c35-ae53-49ec-8429-4517f0188477	documents	processed/06_Contratos_4c1de08d.pdf	\N	2025-11-03 22:21:14.760416+00	2025-11-03 22:21:14.760416+00	2025-11-03 22:21:14.760416+00	{"eTag": "\\"75c54f00d299702c6c26b61daad010e3\\"", "size": 134052, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-11-03T22:21:15.000Z", "contentLength": 134052, "httpStatusCode": 200}	fce53d8b-1c6c-4f4c-a04a-8660d79b0e9c	\N	{}	2
35912b98-c5d8-4e17-8bcf-2c8a4d5c5185	documents	processed/06_Contratos_347344c9.pdf	\N	2025-11-03 22:21:21.876482+00	2025-11-03 22:21:21.876482+00	2025-11-03 22:21:21.876482+00	{"eTag": "\\"000305de1f9ee5e8da1fd8600f00cfa6\\"", "size": 239658, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-11-03T22:21:22.000Z", "contentLength": 239658, "httpStatusCode": 200}	ba676e20-dc7c-43a6-92f9-399dd600a7a3	\N	{}	2
52a9eaa6-a0bc-4da3-8e00-c864e022cb0a	documents	processed/06_Contratos_9133915c.pdf	\N	2025-11-03 22:21:29.833836+00	2025-11-03 22:21:29.833836+00	2025-11-03 22:21:29.833836+00	{"eTag": "\\"ade70ed0c4660ffd5acffa4cd1878d9c\\"", "size": 235435, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-11-03T22:21:30.000Z", "contentLength": 235435, "httpStatusCode": 200}	1edcafd7-ae39-42cb-8597-a7be3b2ffdc9	\N	{}	2
ab77e010-22e9-49d4-9d5d-89930690849e	documents	processed/07_carteira_de_trabalho_digital_dea1cf7c.pdf	\N	2025-10-15 20:12:06.620499+00	2025-10-15 20:12:06.620499+00	2025-10-15 20:12:06.620499+00	{"eTag": "\\"d79e7bd8c405fa600a4598b4406330e7\\"", "size": 95259, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-10-15T20:12:07.000Z", "contentLength": 95259, "httpStatusCode": 200}	ff4a32c1-4480-4518-a3b0-bd4e2442140b	\N	{}	2
07d3e706-6e04-4b13-8b64-d3db278c33b8	documents	processed/07 Outros Documentos 6cb0b0bc.pdf	\N	2025-09-25 14:06:02.731623+00	2025-09-25 14:06:02.731623+00	2025-09-25 14:06:02.731623+00	{"eTag": "\\"63f75001b29c3925a47734759c586c8f\\"", "size": 179713, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-09-25T14:06:03.000Z", "contentLength": 179713, "httpStatusCode": 200}	97a3b6cc-72be-41d3-b4e7-4f1d59dc6594	\N	{}	2
955bdb17-8e53-45a0-8e2d-33df8c6f1459	documents	processed/06_Contratos_c232783e.pdf	\N	2025-11-03 22:21:36.027038+00	2025-11-03 22:21:36.027038+00	2025-11-03 22:21:36.027038+00	{"eTag": "\\"6486f9d8fd8f95fabb18ac1cc2e1a9bc\\"", "size": 101124, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-11-03T22:21:36.000Z", "contentLength": 101124, "httpStatusCode": 200}	bd5c1064-ad9a-43a0-aa20-6c56ca36f040	\N	{}	2
1c739b5c-76bc-44c4-9137-ce2be14692e7	documents	processed/06_Contratos_7cb1243e.pdf	\N	2025-11-03 22:21:44.009507+00	2025-11-03 22:21:44.009507+00	2025-11-03 22:21:44.009507+00	{"eTag": "\\"808168557ef5c4ae7d79ca8c2a6f5ddc\\"", "size": 303219, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-11-03T22:21:44.000Z", "contentLength": 303219, "httpStatusCode": 200}	029ac31c-c6b5-4eed-9c3f-c9c700338d6f	\N	{}	2
66211a56-8470-4cd9-aa04-109caf049fa1	documents	processed/07_recibo_e02240c8.pdf	\N	2025-11-03 22:21:49.714663+00	2025-11-03 22:21:49.714663+00	2025-11-03 22:21:49.714663+00	{"eTag": "\\"c2729587555703c46e91211a5362ed1e\\"", "size": 129102, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-11-03T22:21:50.000Z", "contentLength": 129102, "httpStatusCode": 200}	e8702608-5c67-4d9e-a52f-f82a0571a59a	\N	{}	2
45ea74a3-1d09-4cb5-9a78-60bfb3589025	documents	processed/07_resultados_de_exames_laboratoriais_89490cbd.pdf	\N	2025-10-19 23:27:28.599797+00	2025-10-19 23:27:28.599797+00	2025-10-19 23:27:28.599797+00	{"eTag": "\\"f6fb5ae01d102c1919a3ef2211b5ebbb\\"", "size": 356035, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-10-19T23:27:29.000Z", "contentLength": 356035, "httpStatusCode": 200}	715331d2-2ee7-47a7-9bb7-62528a397eb9	\N	{}	2
e0ef1442-19fd-4a98-a0a9-bca67b8e0844	documents	processed/09 Outros Documentos Parte 1.pdf	\N	2025-09-17 21:26:43.751757+00	2025-09-19 13:02:43.681435+00	2025-09-17 21:26:43.751757+00	{"eTag": "\\"62c4c941e6ef6174da10bc7b4a05d8bd\\"", "size": 1710367, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-09-19T13:02:44.000Z", "contentLength": 1710367, "httpStatusCode": 200}	0bdde6fb-d189-4635-bd5b-2b3139720145	\N	{}	2
078c6d0b-e34c-48f7-b7db-e487fa67632f	documents	processed/06_Contratos_99ebf52a.pdf	\N	2025-11-03 22:21:55.539525+00	2025-11-03 22:21:55.539525+00	2025-11-03 22:21:55.539525+00	{"eTag": "\\"04c2dcd4c30f8a74da63919f6cd1dcf3\\"", "size": 217444, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-11-03T22:21:56.000Z", "contentLength": 217444, "httpStatusCode": 200}	3acd5f65-be13-4c35-a916-5696d2f63b4e	\N	{}	2
3f27bee2-c683-40be-8222-56000961233d	documents	processed/07 Outros Documentos d5743466.pdf	\N	2025-09-25 14:06:16.902281+00	2025-09-25 14:06:16.902281+00	2025-09-25 14:06:16.902281+00	{"eTag": "\\"5cc8541aba8aeb5d31e8616aca8fa10d\\"", "size": 286196, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-09-25T14:06:17.000Z", "contentLength": 286196, "httpStatusCode": 200}	b330da24-feb9-4d70-badc-f9c1a4186973	\N	{}	2
8243ae32-f7be-463a-8d6b-9c74c750e929	documents	processed/06_Contratos_92cc387b.pdf	\N	2025-11-03 22:22:03.389133+00	2025-11-03 22:22:03.389133+00	2025-11-03 22:22:03.389133+00	{"eTag": "\\"056133a1b002be0a06cc399b3393ef75\\"", "size": 224972, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-11-03T22:22:04.000Z", "contentLength": 224972, "httpStatusCode": 200}	4b96dbbc-a7d5-4878-993c-c0b5d7fa866d	\N	{}	2
d17400f4-f7a4-48f8-a611-a97180c18a69	documents	processed/07_proposta_de_adesao_de_seguro_7ed6bdaf.pdf	\N	2025-11-03 22:22:12.060546+00	2025-11-03 22:22:12.060546+00	2025-11-03 22:22:12.060546+00	{"eTag": "\\"615c6feedf865c2c42396e4c5db897fd\\"", "size": 279988, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-11-03T22:22:13.000Z", "contentLength": 279988, "httpStatusCode": 200}	f71593df-bd8a-45f4-a010-d642e9a150f8	\N	{}	2
29f8d531-c963-483a-88ef-6fdcdb5ea6a0	documents	processed/06_Contratos_4e98eeea.pdf	\N	2025-11-03 22:22:19.53183+00	2025-11-03 22:22:19.53183+00	2025-11-03 22:22:19.53183+00	{"eTag": "\\"297d9ac299846761d010c79731689eef\\"", "size": 249115, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-11-03T22:22:20.000Z", "contentLength": 249115, "httpStatusCode": 200}	9af09159-e50a-40cf-93a3-d27ff5e7895a	\N	{}	2
0fde5735-9fad-4b91-9adc-6eaa69871196	documents	processed/06_Contratos_38169a3a.pdf	\N	2025-11-03 22:22:25.292215+00	2025-11-03 22:22:25.292215+00	2025-11-03 22:22:25.292215+00	{"eTag": "\\"39c948afacda6e99e794c2f4464461cb\\"", "size": 174061, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-11-03T22:22:26.000Z", "contentLength": 174061, "httpStatusCode": 200}	be1e18eb-a23b-48d1-8b6b-284960618d1f	\N	{}	2
4b67e72f-cbe5-4b01-8c11-86190f64a3c4	documents	processed/06_Contratos_e53846af.pdf	\N	2025-11-03 22:22:32.458981+00	2025-11-03 22:22:32.458981+00	2025-11-03 22:22:32.458981+00	{"eTag": "\\"396a13c8655beeeb09221ac253e9514b\\"", "size": 272713, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-11-03T22:22:33.000Z", "contentLength": 272713, "httpStatusCode": 200}	901f77c2-070b-48a9-9668-88943f675226	\N	{}	2
ef752f25-bef3-474f-bddd-0baf555becaa	documents	processed/07_recibo_740e2455.pdf	\N	2025-11-03 22:22:38.408179+00	2025-11-03 22:22:38.408179+00	2025-11-03 22:22:38.408179+00	{"eTag": "\\"12fea7f7ed0b911dd2fc170fd894fc98\\"", "size": 168658, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-11-03T22:22:39.000Z", "contentLength": 168658, "httpStatusCode": 200}	7ce14156-90e6-46c3-8178-4c92bc496002	\N	{}	2
f803aabc-643f-4d51-97c6-a06cc01e2733	documents	processed/07_contrato_de_compra_e_venda_1ae77595.pdf	\N	2025-11-03 22:22:44.202379+00	2025-11-03 22:22:44.202379+00	2025-11-03 22:22:44.202379+00	{"eTag": "\\"a8a4b0762c4229f1dfead777b1aef9ef\\"", "size": 170587, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-11-03T22:22:45.000Z", "contentLength": 170587, "httpStatusCode": 200}	f87d6272-9f78-4250-afd4-02f00ec19ad8	\N	{}	2
70c85f27-3796-4db2-a1d5-07f4f42df3be	documents	processed/09 Outros Documentos Parte 3.pdf	\N	2025-09-17 21:26:45.760985+00	2025-09-19 13:02:45.468015+00	2025-09-17 21:26:45.760985+00	{"eTag": "\\"fa9e3292b172887e3a9008515e2f4d56\\"", "size": 1432794, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-09-19T13:02:46.000Z", "contentLength": 1432794, "httpStatusCode": 200}	a3aa7b0f-00c8-485d-9f08-c4a5f249d770	\N	{}	2
c1e1c5cd-3a92-4573-9ac6-b9a6f0e8451d	documents	processed/07_Outros_Documentos_6003e66c.pdf	\N	2025-10-22 03:46:50.655308+00	2025-10-22 03:46:50.655308+00	2025-10-22 03:46:50.655308+00	{"eTag": "\\"af38231f61574735a9697d45f563433f\\"", "size": 239660, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-10-22T03:46:51.000Z", "contentLength": 239660, "httpStatusCode": 200}	60fa4ea1-1f15-43b2-94cc-cea3a1f2d053	\N	{}	2
0bea53f8-1ffe-48ac-b5ac-334541a5e0be	documents	processed/07_Outros_Documentos_45faf9b2.pdf	\N	2025-10-22 03:47:01.879902+00	2025-10-22 03:47:01.879902+00	2025-10-22 03:47:01.879902+00	{"eTag": "\\"8c72fadf13e9b23edfa3e48b74b30d0e\\"", "size": 220577, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-10-22T03:47:02.000Z", "contentLength": 220577, "httpStatusCode": 200}	aa67066c-7b2e-4557-a0d6-f1b86fc8cf6a	\N	{}	2
4d6984e2-4bd6-45cd-841d-0214653a8b92	documents	processed/09 Outros Documentos Parte 2.pdf	\N	2025-09-17 21:26:44.893894+00	2025-09-19 13:02:44.400786+00	2025-09-17 21:26:44.893894+00	{"eTag": "\\"190deb531f4d7b3e349f9980c3327216\\"", "size": 2022758, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-09-19T13:02:45.000Z", "contentLength": 2022758, "httpStatusCode": 200}	256ed020-95dc-4878-8ce8-eb1335c29cb5	\N	{}	2
565a2e41-a06a-4e01-a903-9c729c723709	documents	processed/07_Outros_Documentos_61d4ec40.pdf	\N	2025-10-22 03:47:14.098967+00	2025-10-22 03:47:14.098967+00	2025-10-22 03:47:14.098967+00	{"eTag": "\\"5a636de4afcd84928e3c888f12d5ae67\\"", "size": 286109, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-10-22T03:47:15.000Z", "contentLength": 286109, "httpStatusCode": 200}	abdbfc2e-6883-4c1d-b85b-87e9da42659b	\N	{}	2
ed8196df-a2c4-40b0-bbad-e6ab6818e361	documents	processed/07_Outros_Documentos_8a3c88b8.pdf	\N	2025-10-22 03:47:26.390066+00	2025-10-22 03:47:26.390066+00	2025-10-22 03:47:26.390066+00	{"eTag": "\\"5e772631448303e180adf5b41fe71c57\\"", "size": 224974, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-10-22T03:47:27.000Z", "contentLength": 224974, "httpStatusCode": 200}	79d88c90-85fd-48a4-a793-bbda2455c34c	\N	{}	2
ed0627af-2342-4241-bd13-2581ff2983d0	documents	processed/07_Outros_Documentos_43f9ea7a.pdf	\N	2025-10-22 03:47:35.040205+00	2025-10-22 03:47:35.040205+00	2025-10-22 03:47:35.040205+00	{"eTag": "\\"5fd4046d6a865702419bf49fc7238bfc\\"", "size": 183186, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-10-22T03:47:35.000Z", "contentLength": 183186, "httpStatusCode": 200}	29577f97-de9c-4ff5-b924-1f223947082b	\N	{}	2
71c265e2-eead-4d43-9c13-6a6e3f6d5abc	documents	processed/07_Outros_Documentos_c5a1d845.pdf	\N	2025-10-22 03:47:42.866842+00	2025-10-22 03:47:42.866842+00	2025-10-22 03:47:42.866842+00	{"eTag": "\\"bc1c2c71acc4146667372c17d8a613e6\\"", "size": 126438, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-10-22T03:47:43.000Z", "contentLength": 126438, "httpStatusCode": 200}	cd3d11f3-44f9-4641-b864-cc97897164ad	\N	{}	2
73aba467-f9b9-41ec-9979-3f90426b35f5	documents	processed/07_Outros_Documentos_043ea03a.pdf	\N	2025-10-13 23:10:22.771848+00	2025-10-13 23:10:22.771848+00	2025-10-13 23:10:22.771848+00	{"eTag": "\\"66ec77016636359e3f801021e6696470-4\\"", "size": 19833754, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-10-13T23:10:23.000Z", "contentLength": 19833754, "httpStatusCode": 200}	9ae8a153-c0e5-44c8-b9f7-b441eee5a2d2	\N	{}	2
9eb9b7d2-51b9-44b6-accc-4bc06ee99d3e	documents	processed/07_documento_judicial_066209a6.pdf	\N	2025-10-13 23:16:23.747399+00	2025-10-13 23:16:23.747399+00	2025-10-13 23:16:23.747399+00	{"eTag": "\\"a18a71d3dce474b553cf32569ae432fa\\"", "size": 336234, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-10-13T23:16:24.000Z", "contentLength": 336234, "httpStatusCode": 200}	7d8468b7-049c-47af-9a29-b427add8e54b	\N	{}	2
77511034-9ee1-4466-8bc8-f0df7e6c3b5b	documents	processed/07_peticao_8b6ed0e8.pdf	\N	2025-10-13 23:16:27.711034+00	2025-10-13 23:16:27.711034+00	2025-10-13 23:16:27.711034+00	{"eTag": "\\"fe0d34f21e3830a5a590f11c4544854f\\"", "size": 1563491, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-10-13T23:16:28.000Z", "contentLength": 1563491, "httpStatusCode": 200}	9c1bcc75-4921-45ac-b914-a602467778f8	\N	{}	2
9be778b8-9767-457f-bd6f-f94939ff7ad5	documents	processed/07_boleto_5dd663b8.pdf	\N	2025-10-13 23:16:30.320658+00	2025-10-13 23:16:30.320658+00	2025-10-13 23:16:30.320658+00	{"eTag": "\\"1574bffdf9fcd84d56adca696bc6b60c\\"", "size": 153411, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-10-13T23:16:31.000Z", "contentLength": 153411, "httpStatusCode": 200}	383a20af-cfeb-4566-9ed0-093b20b6bb8f	\N	{}	2
54aa8a15-f6df-49ba-ae07-ea3c348a95bc	documents	processed/07_certidao_de_citacao_b602b48a.pdf	\N	2025-10-13 23:16:37.164541+00	2025-10-13 23:16:37.164541+00	2025-10-13 23:16:37.164541+00	{"eTag": "\\"2d5b5352239832057d4959d68aa2ce0f\\"", "size": 77447, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-10-13T23:16:38.000Z", "contentLength": 77447, "httpStatusCode": 200}	27449c07-8338-4c3e-825a-a18cb033059a	\N	{}	2
47309e06-bd0f-42bc-b7db-c4118b57beb1	documents	processed/07_Outros_Documentos_998793b6.pdf	\N	2025-10-22 03:48:59.953994+00	2025-10-22 03:48:59.953994+00	2025-10-22 03:48:59.953994+00	{"eTag": "\\"0cbd9fa6e5c00ebbb4a63e4f2fbeff88\\"", "size": 361111, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-10-22T03:49:00.000Z", "contentLength": 361111, "httpStatusCode": 200}	a8effbb2-1224-456e-b372-358321c7f4f5	\N	{}	2
9170134c-84db-45c3-ae60-c2b9819be707	documents	processed/07_aso_a1257eae.pdf	\N	2025-10-10 19:49:05.236508+00	2025-10-10 19:49:05.236508+00	2025-10-10 19:49:05.236508+00	{"eTag": "\\"9734d1f0bf2d8c8fcbc41c10bca67b30\\"", "size": 253736, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-10-10T19:49:06.000Z", "contentLength": 253736, "httpStatusCode": 200}	f214a2e9-c5bc-4b43-8215-c0ac34a5df10	\N	{}	2
c2773a84-b078-49db-b017-2b10290df2e4	documents	processed/07_laudo_medico_669f6b44.pdf	\N	2025-10-10 19:49:11.497895+00	2025-10-10 19:49:11.497895+00	2025-10-10 19:49:11.497895+00	{"eTag": "\\"513e0fa7b5b1fa7ceec269733c9b95f9\\"", "size": 191807, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-10-10T19:49:12.000Z", "contentLength": 191807, "httpStatusCode": 200}	9adcfd9b-bf07-46a0-8a93-c8e2eda94f8a	\N	{}	2
a43cb556-2fa0-4238-be67-c1e56e5f855f	documents	processed/07_Outros_Documentos_62bb3572.pdf	\N	2025-10-15 22:04:17.655025+00	2025-10-15 22:04:17.655025+00	2025-10-15 22:04:17.655025+00	{"eTag": "\\"66ec77016636359e3f801021e6696470-4\\"", "size": 19833754, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-10-15T22:04:17.000Z", "contentLength": 19833754, "httpStatusCode": 200}	24aa6d49-3618-463a-9a02-afa2e9213f5d	\N	{}	2
79deef09-f9b2-43c5-bac3-16020f4c7b57	documents	processed/07_laudo_medico_ec4bc07c.pdf	\N	2025-10-10 19:50:01.666903+00	2025-10-10 19:50:01.666903+00	2025-10-10 19:50:01.666903+00	{"eTag": "\\"285cd5f2a9842ffff7d0d6594eabf89b\\"", "size": 369374, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-10-10T19:50:02.000Z", "contentLength": 369374, "httpStatusCode": 200}	a2358a8b-2163-4603-9db6-0590ed1575f8	\N	{}	2
44d921eb-f6e6-4d46-bc35-e332c4c01ad4	documents	processed/07_Outros_Documentos_d293674c.pdf	\N	2025-10-22 03:49:12.45657+00	2025-10-22 03:49:12.45657+00	2025-10-22 03:49:12.45657+00	{"eTag": "\\"4ffcdc6e88e9861f8dc414ee8181a33a\\"", "size": 68595, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-10-22T03:49:13.000Z", "contentLength": 68595, "httpStatusCode": 200}	a0779954-93f4-41be-a204-f8be43deca1a	\N	{}	2
dad18653-38f5-4993-a02d-e687d1c750fe	documents	processed/07_termo_de_consentimento_livre_e_esclarecido_e0248ba4.pdf	\N	2025-10-10 19:50:10.294724+00	2025-10-10 19:50:10.294724+00	2025-10-10 19:50:10.294724+00	{"eTag": "\\"013fc979107f2c577974cbd3ab550b24\\"", "size": 304596, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-10-10T19:50:11.000Z", "contentLength": 304596, "httpStatusCode": 200}	297f1a5c-90ae-42fa-a9c8-405f574fd29d	\N	{}	2
d9238e67-cc52-4445-82c8-da2cc6176dfa	documents	processed/07_laudo_medico_b7ded723.pdf	\N	2025-10-10 19:50:18.349592+00	2025-10-10 19:50:18.349592+00	2025-10-10 19:50:18.349592+00	{"eTag": "\\"45c02f3a2276dfea3018da8c8e3a1557\\"", "size": 336061, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-10-10T19:50:19.000Z", "contentLength": 336061, "httpStatusCode": 200}	ffd921e1-959d-406a-9c95-6ecea0fd95f0	\N	{}	2
88648329-a1e7-4398-a22b-d5bc6ecd8da0	documents	processed/07_laudo_medico_7fb08afc.pdf	\N	2025-10-10 19:50:23.711673+00	2025-10-10 19:50:23.711673+00	2025-10-10 19:50:23.711673+00	{"eTag": "\\"2dc0e76abbeb9ddf0a83f96da62f9a2f\\"", "size": 186212, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-10-10T19:50:24.000Z", "contentLength": 186212, "httpStatusCode": 200}	cbec98f1-40c6-4471-879c-7400095f37d0	\N	{}	2
d6309de5-a662-4f7e-9b9a-a86fd3a0c8ca	documents	processed/07_atestado_medico_df404583.pdf	\N	2025-10-10 19:50:29.394858+00	2025-10-10 19:50:29.394858+00	2025-10-10 19:50:29.394858+00	{"eTag": "\\"b26d72e2933d77df170c2f78b75c4370\\"", "size": 352453, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-10-10T19:50:30.000Z", "contentLength": 352453, "httpStatusCode": 200}	61466a18-cbd7-4bf2-8c9a-eca46a6b3831	\N	{}	2
5247d24d-0462-4dca-84d8-a710ac7812e6	documents	processed/07_atestado_medico_a64cdfd3.pdf	\N	2025-10-10 19:50:35.845325+00	2025-10-10 19:50:35.845325+00	2025-10-10 19:50:35.845325+00	{"eTag": "\\"d9e075cf653be5ee090bcb4e70eb123b\\"", "size": 270920, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-10-10T19:50:36.000Z", "contentLength": 270920, "httpStatusCode": 200}	67487a7c-04e7-4dc4-918b-0b12f596d628	\N	{}	2
9775566e-38e0-4585-a9d2-8db8018e5b37	documents	processed/07_atestado_medico_cb067b9f.pdf	\N	2025-10-10 19:50:41.885283+00	2025-10-10 19:50:41.885283+00	2025-10-10 19:50:41.885283+00	{"eTag": "\\"1d86727a6521bf00f3e4f649d50405ad\\"", "size": 358495, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-10-10T19:50:42.000Z", "contentLength": 358495, "httpStatusCode": 200}	bda41821-8f54-4b46-9f5c-d9672a9887dc	\N	{}	2
cab9f01b-4de9-4beb-8610-d34bff5a3283	documents	processed/07_requerimento_de_beneficio_por_incapacidade_9a03bef7.pdf	\N	2025-10-10 19:50:48.13409+00	2025-10-10 19:50:48.13409+00	2025-10-10 19:50:48.13409+00	{"eTag": "\\"31653490c401eba4ba0ef51a5e804e2d\\"", "size": 276187, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-10-10T19:50:48.000Z", "contentLength": 276187, "httpStatusCode": 200}	4baf3c51-2189-4cd1-9857-0cb4efa3dc44	\N	{}	2
0589831e-8855-4966-a026-ac17f06c18dc	documents	processed/07 Outros Documentos 6ab846e3.pdf	\N	2025-09-25 14:53:16.430664+00	2025-09-25 14:53:16.430664+00	2025-09-25 14:53:16.430664+00	{"eTag": "\\"541a5a5b31678b83195128c9638c5fe0\\"", "size": 179713, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-09-25T14:53:17.000Z", "contentLength": 179713, "httpStatusCode": 200}	505cd04c-decb-4a7d-ab04-ed9be77d760b	\N	{}	2
0955a5f0-c7fc-4a89-8ba4-06252dadd59f	documents	processed/07_atestado_medico_5271fe68.pdf	\N	2025-10-10 19:50:53.756855+00	2025-10-10 19:50:53.756855+00	2025-10-10 19:50:53.756855+00	{"eTag": "\\"8d4ffd385b2f503d388c732493ce6d0c\\"", "size": 116821, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-10-10T19:50:54.000Z", "contentLength": 116821, "httpStatusCode": 200}	4a5c6602-eea3-4f31-a21e-ed913f4717f5	\N	{}	2
73a32800-a25a-41a7-b57f-45478f110f02	documents	processed/07 Outros Documentos 0251e043.pdf	\N	2025-09-25 14:53:23.327545+00	2025-09-25 14:53:23.327545+00	2025-09-25 14:53:23.327545+00	{"eTag": "\\"310789d0aa2cd7760819f51956c726b0\\"", "size": 286196, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-09-25T14:53:24.000Z", "contentLength": 286196, "httpStatusCode": 200}	1130a536-d4eb-4842-8f7a-4b518c362405	\N	{}	2
f8832ab2-2a85-4ada-a9cd-482d91105680	documents	processed/07_Outros_Documentos_ea68db22.pdf	\N	2025-10-02 02:26:59.277216+00	2025-10-02 02:26:59.277216+00	2025-10-02 02:26:59.277216+00	{"eTag": "\\"dd82320274f90a7dc4bcf4df1733736c\\"", "size": 583, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-10-02T02:27:00.000Z", "contentLength": 583, "httpStatusCode": 200}	aafc141b-e58b-4f13-9436-a3b0381189e1	\N	{}	2
4a15ac49-02e4-43b7-8b54-1319da2fc80f	documents	processed/07_Outros_Documentos_0783db66.pdf	\N	2025-10-02 02:27:04.824105+00	2025-10-02 02:27:04.824105+00	2025-10-02 02:27:04.824105+00	{"eTag": "\\"1480375dfc088564e7a15f7ac5aac6f3\\"", "size": 11829, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-10-02T02:27:05.000Z", "contentLength": 11829, "httpStatusCode": 200}	095ca445-7c0f-4aeb-a755-0ab455388ebf	\N	{}	2
ed3e8e2a-a129-4fac-96c0-25b3f80dad13	documents	processed/07_atestado_medico_d5208b61.pdf	\N	2025-10-10 19:50:58.893223+00	2025-10-10 19:50:58.893223+00	2025-10-10 19:50:58.893223+00	{"eTag": "\\"5967068450ec51bffbe2c0ca525574f8\\"", "size": 172714, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-10-10T19:50:59.000Z", "contentLength": 172714, "httpStatusCode": 200}	369f009e-1c1e-4363-a80d-6f759ea43e66	\N	{}	2
4b18ee8e-3dcd-4cb9-93e2-ceef34e06957	documents	processed/07_Outros_Documentos_31111c18.pdf	\N	2025-10-02 02:27:09.668051+00	2025-10-02 02:27:09.668051+00	2025-10-02 02:27:09.668051+00	{"eTag": "\\"eaad84195ef60487792f79eca79c8bb8\\"", "size": 163750, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-10-02T02:27:10.000Z", "contentLength": 163750, "httpStatusCode": 200}	92bdbe1f-9f5f-43cd-9321-93c4b64e7448	\N	{}	2
6f4b8156-911c-421c-a5bd-9f022fc08664	documents	processed/07_Outros_Documentos_1bf556a7.pdf	\N	2025-10-02 02:27:13.029103+00	2025-10-02 02:27:13.029103+00	2025-10-02 02:27:13.029103+00	{"eTag": "\\"e42ec9b78b7ce3633339ba3c31809aa5\\"", "size": 172283, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-10-02T02:27:13.000Z", "contentLength": 172283, "httpStatusCode": 200}	0d56976e-8edc-431d-ad1c-c4b98f169b5f	\N	{}	2
eb71a0a8-6708-4458-b1d4-dd05047a19c1	documents	processed/07_atestado_medico_90f64b10.pdf	\N	2025-10-10 19:51:04.021344+00	2025-10-10 19:51:04.021344+00	2025-10-10 19:51:04.021344+00	{"eTag": "\\"e50fc6e515f189d817c973ede506d031\\"", "size": 152122, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-10-10T19:51:04.000Z", "contentLength": 152122, "httpStatusCode": 200}	578aeb11-07b6-487c-ba52-6b36b3b9dc26	\N	{}	2
c4c2022b-b99b-4593-ac69-a610dd49e9d9	documents	processed/07_Outros_Documentos_3c73bae6.pdf	\N	2025-10-02 02:27:16.783983+00	2025-10-02 02:27:16.783983+00	2025-10-02 02:27:16.783983+00	{"eTag": "\\"1c8086b87ce2132fcbba8b12a0608db3\\"", "size": 178073, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-10-02T02:27:17.000Z", "contentLength": 178073, "httpStatusCode": 200}	bc4677a8-810c-471b-a5bd-a182b6a28739	\N	{}	2
12daef68-95ec-43c0-a894-6a5d17770c98	documents	processed/07_Outros_Documentos_7561b1bb.pdf	\N	2025-10-02 02:27:24.320329+00	2025-10-02 02:27:24.320329+00	2025-10-02 02:27:24.320329+00	{"eTag": "\\"2058ccf25993cff71b9f01ae6aa9dece\\"", "size": 11842, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-10-02T02:27:25.000Z", "contentLength": 11842, "httpStatusCode": 200}	fe6e8746-eccc-4912-9d85-74a3410b650b	\N	{}	2
eb721643-2026-44e3-9347-90fc3fcfb674	documents	processed/07_laudo_medico_48d24a36.pdf	\N	2025-10-10 19:51:09.828757+00	2025-10-10 19:51:09.828757+00	2025-10-10 19:51:09.828757+00	{"eTag": "\\"fa52c1d00d2a37532a4f350c76b8ca90\\"", "size": 108525, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-10-10T19:51:10.000Z", "contentLength": 108525, "httpStatusCode": 200}	0f5f61c6-b1e6-416d-944c-58193a196828	\N	{}	2
01233bbb-1d19-41bb-9711-df18d1eb1e93	documents	processed/07_Outros_Documentos_ba50ae8d.pdf	\N	2025-10-02 02:27:27.643356+00	2025-10-02 02:27:27.643356+00	2025-10-02 02:27:27.643356+00	{"eTag": "\\"08bfa466902123a432982d6ecbf1bedb\\"", "size": 11842, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-10-02T02:27:28.000Z", "contentLength": 11842, "httpStatusCode": 200}	57430ac4-a39c-4843-ac37-43c38276e4f2	\N	{}	2
f63eede7-a39c-4e40-999d-bbb693aae4ad	documents	processed/07_Outros_Documentos_9b98ff1e.pdf	\N	2025-10-02 02:27:31.773352+00	2025-10-02 02:27:31.773352+00	2025-10-02 02:27:31.773352+00	{"eTag": "\\"1089d41b447df9ff2c84e49f8ce560d5\\"", "size": 537771, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-10-02T02:27:32.000Z", "contentLength": 537771, "httpStatusCode": 200}	fca0ceb9-5ddb-405c-939a-e824e56e90ca	\N	{}	2
a64100e1-70b2-4736-b31c-c63c4149b77b	documents	processed/07 Outros Documentos 7f6eaeba.pdf	\N	2025-09-25 18:00:03.830615+00	2025-09-25 18:00:03.830615+00	2025-09-25 18:00:03.830615+00	{"eTag": "\\"2aadc70aa20a3a20edd7a22d61d321b5\\"", "size": 286196, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-09-25T18:00:04.000Z", "contentLength": 286196, "httpStatusCode": 200}	8c01341b-7239-4133-9dba-afcfdf5b5653	\N	{}	2
4a767dff-5d60-4d5f-b1f4-c80e33841dcc	documents	processed/07_laudo_medico_417f5f5b.pdf	\N	2025-10-10 19:51:14.021512+00	2025-10-10 19:51:14.021512+00	2025-10-10 19:51:14.021512+00	{"eTag": "\\"4ded804e28a6900722445c9c60b6d172\\"", "size": 80127, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-10-10T19:51:14.000Z", "contentLength": 80127, "httpStatusCode": 200}	293e3f56-e738-4fd9-99df-01cd24bcf1a0	\N	{}	2
80a55f60-8e5b-4a04-bafe-80f17bf56ba5	documents	processed/07_receituario_5ad1439e.pdf	\N	2025-10-10 19:51:18.28997+00	2025-10-10 19:51:18.28997+00	2025-10-10 19:51:18.28997+00	{"eTag": "\\"e30a4340970c038260f1af9d0f419d22\\"", "size": 54286, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-10-10T19:51:19.000Z", "contentLength": 54286, "httpStatusCode": 200}	6dbe217e-72c2-4636-98ad-cfc2df93676b	\N	{}	2
b0783055-5a88-4450-bd70-283e8c5ca134	documents	processed/07_documento_judicial_d8ed6483.pdf	\N	2025-10-13 23:46:51.629755+00	2025-10-13 23:46:51.629755+00	2025-10-13 23:46:51.629755+00	{"eTag": "\\"a18a71d3dce474b553cf32569ae432fa\\"", "size": 336234, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-10-13T23:46:52.000Z", "contentLength": 336234, "httpStatusCode": 200}	278c06f7-9f67-4540-8e44-fd3e02f6ca87	\N	{}	2
7d0208d5-315f-402c-93e7-abf94855c796	documents	processed/07_certidao_de_citacao_90fc7130.pdf	\N	2025-10-13 23:46:55.105844+00	2025-10-13 23:46:55.105844+00	2025-10-13 23:46:55.105844+00	{"eTag": "\\"2d5b5352239832057d4959d68aa2ce0f\\"", "size": 77447, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-10-13T23:46:56.000Z", "contentLength": 77447, "httpStatusCode": 200}	607e13a8-bc66-4c4c-ad8a-bc197c2460cc	\N	{}	2
706ba4a1-5424-45c3-b26d-32690202f116	documents	processed/07_documento_judicial_0bb2929b.pdf	\N	2025-10-13 23:46:57.695627+00	2025-10-13 23:46:57.695627+00	2025-10-13 23:46:57.695627+00	{"eTag": "\\"8d1f99d35b3ca57bc6c0fa956b93fb13\\"", "size": 98087, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-10-13T23:46:58.000Z", "contentLength": 98087, "httpStatusCode": 200}	9a55d02b-aa19-4446-9c3b-e661c98fa6d7	\N	{}	2
e454d971-4a98-4ca5-ac89-031e22191b78	documents	processed/07_peticao_16d112df.pdf	\N	2025-10-13 23:47:02.208508+00	2025-10-13 23:47:02.208508+00	2025-10-13 23:47:02.208508+00	{"eTag": "\\"fe0d34f21e3830a5a590f11c4544854f\\"", "size": 1563491, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-10-13T23:47:03.000Z", "contentLength": 1563491, "httpStatusCode": 200}	5798b5a1-9e8c-454a-b54e-d1c57420d458	\N	{}	2
ccb622b0-5a26-4a8d-a9f4-e8d05da14072	documents	processed/07_Outros_Documentos_4a19631c.pdf	\N	2025-10-22 03:49:32.551323+00	2025-10-22 03:49:32.551323+00	2025-10-22 03:49:32.551323+00	{"eTag": "\\"14c32394a9d377ba8e640199969f67ea\\"", "size": 264530, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-10-22T03:49:33.000Z", "contentLength": 264530, "httpStatusCode": 200}	65de492d-ec39-4691-a4f7-084308dd6e98	\N	{}	2
8d6b63e9-3b67-4008-902e-b188f953a452	documents	processed/07 Outros Documentos fffd54b7.pdf	\N	2025-09-25 18:16:25.861831+00	2025-09-25 18:16:25.861831+00	2025-09-25 18:16:25.861831+00	{"eTag": "\\"2ce827e8d38036311e5f22db11de69cb\\"", "size": 292928, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-09-25T18:16:26.000Z", "contentLength": 292928, "httpStatusCode": 200}	10c93649-90a0-4100-ab89-ea0f2f82b5f5	\N	{}	2
b2d3a9f6-b6f9-4924-bd66-d934a6b1383e	documents	processed/07_Outros_Documentos_a12f8f13.pdf	\N	2025-10-13 23:48:42.63419+00	2025-10-13 23:48:42.63419+00	2025-10-13 23:48:42.63419+00	{"eTag": "\\"66ec77016636359e3f801021e6696470-4\\"", "size": 19833754, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-10-13T23:48:42.000Z", "contentLength": 19833754, "httpStatusCode": 200}	96f4b8d7-8238-45a5-8948-3f1a4fb44a4b	\N	{}	2
f6f55c0b-e490-4780-9aa8-e8b5f33f1d09	documents	processed/07_boleto_32d9ffed.pdf	\N	2025-10-13 23:48:54.620759+00	2025-10-13 23:48:54.620759+00	2025-10-13 23:48:54.620759+00	{"eTag": "\\"1574bffdf9fcd84d56adca696bc6b60c\\"", "size": 153411, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-10-13T23:48:55.000Z", "contentLength": 153411, "httpStatusCode": 200}	66cf3803-be9a-4d75-9044-1b28bc6f22b9	\N	{}	2
244d6321-508c-4a94-a561-4c188ff55945	documents	processed/07_Outros_Documentos_7c9eccef.pdf	\N	2025-10-22 03:49:45.241383+00	2025-10-22 03:49:45.241383+00	2025-10-22 03:49:45.241383+00	{"eTag": "\\"af38231f61574735a9697d45f563433f\\"", "size": 239660, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-10-22T03:49:46.000Z", "contentLength": 239660, "httpStatusCode": 200}	4fe84bac-25b6-4cc5-8114-a71b07e82687	\N	{}	2
e7495c12-88dc-47b6-8efc-b7d7718f0741	documents	processed/07 Outros Documentos eb76cf27.pdf	\N	2025-09-25 18:32:11.308428+00	2025-09-25 18:32:11.308428+00	2025-09-25 18:32:11.308428+00	{"eTag": "\\"2ce827e8d38036311e5f22db11de69cb\\"", "size": 292928, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-09-25T18:32:12.000Z", "contentLength": 292928, "httpStatusCode": 200}	9c85c8f2-25d3-4eeb-acb3-82daad73f7ce	\N	{}	2
208904d0-ae0a-4387-b9e5-4460b535a54d	documents	processed/07 Outros Documentos c3854e2c.pdf	\N	2025-09-25 18:46:05.774805+00	2025-09-25 18:46:05.774805+00	2025-09-25 18:46:05.774805+00	{"eTag": "\\"2ce827e8d38036311e5f22db11de69cb\\"", "size": 292928, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-09-25T18:46:06.000Z", "contentLength": 292928, "httpStatusCode": 200}	a2219aef-0637-46ea-a640-9af7106bfafc	\N	{}	2
f3eb213a-f6d0-4fb3-b36d-8253e3f628db	documents	processed/07_laudo_medico_c09ceb69.pdf	\N	2025-10-12 04:08:02.925417+00	2025-10-12 04:08:02.925417+00	2025-10-12 04:08:02.925417+00	{"eTag": "\\"4a5b74d3daaeee437a14eeaceeecd747\\"", "size": 547853, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-10-12T04:08:03.000Z", "contentLength": 547853, "httpStatusCode": 200}	65800b53-809c-4b37-af6c-8c7355d86c8c	\N	{}	2
2f71d121-8ca2-4aac-809f-64e2103ec975	documents	processed/07_Outros_Documentos_446d06ce.pdf	\N	2025-10-22 03:49:58.191528+00	2025-10-22 03:49:58.191528+00	2025-10-22 03:49:58.191528+00	{"eTag": "\\"8c72fadf13e9b23edfa3e48b74b30d0e\\"", "size": 220577, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-10-22T03:49:59.000Z", "contentLength": 220577, "httpStatusCode": 200}	7e502583-c39b-4b4a-8ace-39d7292311aa	\N	{}	2
0a6facac-b0a3-414b-b8cd-6b2192712c18	documents	processed/07_laudo_medico_d7401f36.pdf	\N	2025-10-16 18:36:57.116186+00	2025-10-16 18:36:57.116186+00	2025-10-16 18:36:57.116186+00	{"eTag": "\\"d328d3befa6e42f523d191ee32693ce1\\"", "size": 524856, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-10-16T18:36:58.000Z", "contentLength": 524856, "httpStatusCode": 200}	f4efda56-1495-484e-8638-8cf2b1a0773d	\N	{}	2
ac16fc4a-a5ad-4e7e-98ab-07a333b85f7b	documents	processed/07_laudo_medico_c65a6504.pdf	\N	2025-10-16 18:37:01.416188+00	2025-10-16 18:37:01.416188+00	2025-10-16 18:37:01.416188+00	{"eTag": "\\"4a5b74d3daaeee437a14eeaceeecd747\\"", "size": 547853, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-10-16T18:37:02.000Z", "contentLength": 547853, "httpStatusCode": 200}	e73aa6e9-1a04-4aac-a7c7-0c6380aeae67	\N	{}	2
3d506420-06b5-4c7a-9572-594513bbe9a4	documents	processed/07_Outros_Documentos_d45000c4.pdf	\N	2025-10-22 03:50:11.553389+00	2025-10-22 03:50:11.553389+00	2025-10-22 03:50:11.553389+00	{"eTag": "\\"5a636de4afcd84928e3c888f12d5ae67\\"", "size": 286109, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-10-22T03:50:12.000Z", "contentLength": 286109, "httpStatusCode": 200}	6cf2fcba-fcac-4faa-8f47-f522cc1723f2	\N	{}	2
787f9001-1115-485b-a356-e41c196a04d4	documents	processed/07 Outros Documentos cf1972e9.pdf	\N	2025-09-25 18:56:50.933443+00	2025-09-25 18:56:50.933443+00	2025-09-25 18:56:50.933443+00	{"eTag": "\\"2ce827e8d38036311e5f22db11de69cb\\"", "size": 292928, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-09-25T18:56:51.000Z", "contentLength": 292928, "httpStatusCode": 200}	b6a97851-a55e-41cb-bff3-ad7022c5ee45	\N	{}	2
8c552bad-7fb2-4206-90a8-71a40e9a9b5e	documents	processed/07 Outros Documentos e5932c56.pdf	\N	2025-09-25 18:59:26.083419+00	2025-09-25 18:59:26.083419+00	2025-09-25 18:59:26.083419+00	{"eTag": "\\"2ce827e8d38036311e5f22db11de69cb\\"", "size": 292928, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-09-25T18:59:27.000Z", "contentLength": 292928, "httpStatusCode": 200}	3c1e234e-e707-4a05-befb-6ae1370dc929	\N	{}	2
5d692556-7148-4475-8967-1eb03f14b190	documents	processed/07 Outros Documentos 67207a22.pdf	\N	2025-09-25 19:00:25.726737+00	2025-09-25 19:00:25.726737+00	2025-09-25 19:00:25.726737+00	{"eTag": "\\"2ce827e8d38036311e5f22db11de69cb\\"", "size": 292928, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-09-25T19:00:26.000Z", "contentLength": 292928, "httpStatusCode": 200}	f7597a83-ebc7-4254-8fd4-e58bbe9345f5	\N	{}	2
71f88a93-6fcd-437a-be1b-a07b85299ce5	documents	processed/07 Outros Documentos 32860b54.pdf	\N	2025-09-25 19:06:13.04352+00	2025-09-25 19:06:13.04352+00	2025-09-25 19:06:13.04352+00	{"eTag": "\\"2ce827e8d38036311e5f22db11de69cb\\"", "size": 292928, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-09-25T19:06:13.000Z", "contentLength": 292928, "httpStatusCode": 200}	8e7d3606-fe02-4c49-a0b3-0684b9a53b7c	\N	{}	2
f0e4d5aa-3be8-4cb0-81bb-29d8fff5f9fa	documents	processed/07 Outros Documentos d958f0c0.pdf	\N	2025-09-29 15:44:45.635236+00	2025-09-29 15:44:45.635236+00	2025-09-29 15:44:45.635236+00	{"eTag": "\\"f0f9ea89bc507507e6e4d4b4548982ce\\"", "size": 183238, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-09-29T15:44:46.000Z", "contentLength": 183238, "httpStatusCode": 200}	9b0280e0-536a-4099-872d-11e203923e8d	\N	{}	2
09f6ab3b-676d-4c1f-890d-e1746f3033cb	documents	processed/07_Outros_Documentos_e964b1e9.pdf	\N	2025-10-22 03:50:25.223935+00	2025-10-22 03:50:25.223935+00	2025-10-22 03:50:25.223935+00	{"eTag": "\\"5e772631448303e180adf5b41fe71c57\\"", "size": 224974, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-10-22T03:50:26.000Z", "contentLength": 224974, "httpStatusCode": 200}	da24363b-bf8d-400c-a875-c05bbf23831c	\N	{}	2
e2a1eee5-fe07-4e34-a056-70a60a0a525b	documents	processed/09-Outros-Documentos-outros-documentos.pdf	\N	2025-08-08 23:15:43.003484+00	2025-08-26 19:14:41.911465+00	2025-08-08 23:15:43.003484+00	{"eTag": "\\"a4ca2f95f33edad198f5da2f31c0f9d9\\"", "size": 583, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-08-10T23:17:17.000Z", "contentLength": 583, "httpStatusCode": 200}	4b22f598-c710-422f-8427-d6b760518cd8	\N	{}	2
6b48539d-cdca-48da-a7d7-adb50b835d44	documents	processed/15/02-Documentos-Pessoais-Agrupados-Cicero-1754702841184.pdf	\N	2025-08-09 01:27:21.930584+00	2025-08-26 19:14:41.911465+00	2025-08-09 01:27:21.930584+00	{"eTag": "\\"7da75437c10634e0b00c3b22b8b4559c\\"", "size": 123287, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-08-09T01:27:22.000Z", "contentLength": 123287, "httpStatusCode": 200}	e42acb09-a172-4ebc-bf73-7973dffe566e	\N	{}	3
f26f5373-5fb8-4bd1-8530-efff62aab08a	documents	processed/DOC1.pdf	\N	2025-08-24 16:59:07.554202+00	2025-08-26 19:14:41.911465+00	2025-08-24 16:59:07.554202+00	{"eTag": "\\"2d786f8301af957bfbd05f4c4bae0807\\"", "size": 90962, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-08-24T16:59:08.000Z", "contentLength": 90962, "httpStatusCode": 200}	c5bf0316-2a93-411e-bfe2-f34390fa93ac	\N	{}	2
0c58a77e-4db5-4f72-83d7-7044f8f23ab3	documents	processed/07_Outros_Documentos_817f15cb.pdf	\N	2025-10-22 03:53:48.180545+00	2025-10-22 03:53:48.180545+00	2025-10-22 03:53:48.180545+00	{"eTag": "\\"0cbd9fa6e5c00ebbb4a63e4f2fbeff88\\"", "size": 361111, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-10-22T03:53:49.000Z", "contentLength": 361111, "httpStatusCode": 200}	30cd7c6b-d0c8-46e3-b9ae-210fb4efda06	\N	{}	2
0ab8d80e-9e64-4e65-ba02-af416a1f3b8c	documents	processed/09 Outros Documentos.pdf	\N	2025-08-06 21:54:24.669818+00	2025-09-25 02:29:53.37495+00	2025-08-06 21:54:24.669818+00	{"eTag": "\\"6981296d41a7015ee5a6f5cd6981552d\\"", "size": 286196, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-09-25T02:29:54.000Z", "contentLength": 286196, "httpStatusCode": 200}	02ef3e37-5287-4d4a-95f9-86e7b6970ab5	\N	{}	2
ea507b82-2e6a-4fbe-89d1-e962fa9407d9	documents	processed/07 Outros Documentos b6af5f80.pdf	\N	2025-09-29 15:44:47.555129+00	2025-09-29 15:44:47.555129+00	2025-09-29 15:44:47.555129+00	{"eTag": "\\"586eb510e1e69dc74a60ea626dc622fc\\"", "size": 30862, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-09-29T15:44:48.000Z", "contentLength": 30862, "httpStatusCode": 200}	327d3464-af6c-48d5-aca8-9807f07ca671	\N	{}	2
f9442251-38ff-40fe-b210-8d5969b79662	documents	processed/07_Outros_Documentos_d3de73b4.pdf	\N	2025-10-22 03:53:57.347358+00	2025-10-22 03:53:57.347358+00	2025-10-22 03:53:57.347358+00	{"eTag": "\\"4ffcdc6e88e9861f8dc414ee8181a33a\\"", "size": 68595, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-10-22T03:53:58.000Z", "contentLength": 68595, "httpStatusCode": 200}	f3420a34-7ff6-4d6a-bbe1-c368e75f9f7c	\N	{}	2
be0f72c7-0ee0-4595-81b1-f70fc5172046	documents	processed/07 Outros Documentos 3725b1e3.pdf	\N	2025-09-29 15:44:52.935849+00	2025-09-29 15:44:52.935849+00	2025-09-29 15:44:52.935849+00	{"eTag": "\\"2ce827e8d38036311e5f22db11de69cb\\"", "size": 292928, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-09-29T15:44:53.000Z", "contentLength": 292928, "httpStatusCode": 200}	be7e878e-e826-47b7-ada8-7f6cafa6fce3	\N	{}	2
8637f947-a2c9-4d2b-bc20-183dd6c1c953	documents	processed/07 Outros Documentos 92093fd3.pdf	\N	2025-09-29 15:44:57.09417+00	2025-09-29 15:44:57.09417+00	2025-09-29 15:44:57.09417+00	{"eTag": "\\"c7925c0ecec49e857442ea517752d7b5\\"", "size": 402051, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-09-29T15:44:58.000Z", "contentLength": 402051, "httpStatusCode": 200}	f436720b-1c12-495c-825e-53be02145adf	\N	{}	2
b238b16c-8553-4c94-ac1e-80d72bc58064	documents	processed/07_Outros_Documentos_34c3abf7.pdf	\N	2025-10-22 03:54:14.066941+00	2025-10-22 03:54:14.066941+00	2025-10-22 03:54:14.066941+00	{"eTag": "\\"14c32394a9d377ba8e640199969f67ea\\"", "size": 264530, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-10-22T03:54:15.000Z", "contentLength": 264530, "httpStatusCode": 200}	32f80b4f-fc0f-4dfd-a2fe-befd2e85aad4	\N	{}	2
96e0db7c-9414-4af0-b69f-73086ce8d9ab	documents	processed/07_Outros_Documentos_fe062948.pdf	\N	2025-10-22 03:54:24.55594+00	2025-10-22 03:54:24.55594+00	2025-10-22 03:54:24.55594+00	{"eTag": "\\"af38231f61574735a9697d45f563433f\\"", "size": 239660, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-10-22T03:54:25.000Z", "contentLength": 239660, "httpStatusCode": 200}	cbe278b0-afc2-4d3b-b469-9788b25159e7	\N	{}	2
aeefca00-a6e0-4591-b3dc-f819943f03d5	documents	processed/07_Outros_Documentos_d9d9c2af.pdf	\N	2025-10-22 03:54:35.188505+00	2025-10-22 03:54:35.188505+00	2025-10-22 03:54:35.188505+00	{"eTag": "\\"8c72fadf13e9b23edfa3e48b74b30d0e\\"", "size": 220577, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-10-22T03:54:36.000Z", "contentLength": 220577, "httpStatusCode": 200}	0f1eeed0-5506-4742-9d88-e1e176bc9e66	\N	{}	2
85645804-a3be-4c55-8ba3-78207c62e67a	documents	processed/07_Outros_Documentos_927d6e33.pdf	\N	2025-10-22 03:54:46.76292+00	2025-10-22 03:54:46.76292+00	2025-10-22 03:54:46.76292+00	{"eTag": "\\"5a636de4afcd84928e3c888f12d5ae67\\"", "size": 286109, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-10-22T03:54:47.000Z", "contentLength": 286109, "httpStatusCode": 200}	fe7815b6-4ae1-46a5-831b-e9972bc71b12	\N	{}	2
2755c51f-9ab5-46dc-99e9-6907d93ed363	documents	processed/07_declaracao_de_compra_6c065fb1.pdf	\N	2025-10-24 12:36:07.301518+00	2025-10-24 12:36:07.301518+00	2025-10-24 12:36:07.301518+00	{"eTag": "\\"cdd1d7f8bc21f3a1ad5f7b01d49ade43\\"", "size": 107766, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-10-24T12:36:08.000Z", "contentLength": 107766, "httpStatusCode": 200}	371f3c28-684c-435e-85e8-35b1757632a1	\N	{}	2
\.


--
-- Data for Name: prefixes; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--

COPY storage.prefixes (bucket_id, name, created_at, updated_at) FROM stdin;
documents	processed	2025-08-26 19:14:41.815317+00	2025-08-26 19:14:41.815317+00
documents	processed/15	2025-08-26 19:14:41.815317+00	2025-08-26 19:14:41.815317+00
documents	original	2025-10-24 18:17:37.043141+00	2025-10-24 18:17:37.043141+00
documents	processado	2025-10-24 18:18:17.148973+00	2025-10-24 18:18:17.148973+00
documents	temp	2025-10-24 18:19:55.11813+00	2025-10-24 18:19:55.11813+00
\.


--
-- Data for Name: s3_multipart_uploads; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--

COPY storage.s3_multipart_uploads (id, in_progress_size, upload_signature, bucket_id, key, version, owner_id, created_at, user_metadata) FROM stdin;
\.


--
-- Data for Name: s3_multipart_uploads_parts; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--

COPY storage.s3_multipart_uploads_parts (id, upload_id, size, part_number, bucket_id, key, etag, owner_id, version, created_at) FROM stdin;
\.


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: supabase_migrations; Owner: postgres
--

COPY supabase_migrations.schema_migrations (version, statements, name) FROM stdin;
20251024141338	{"SET statement_timeout = 0","SET lock_timeout = 0","SET idle_in_transaction_session_timeout = 0","SET client_encoding = 'UTF8'","SET standard_conforming_strings = on","SELECT pg_catalog.set_config('search_path', '', false)","SET check_function_bodies = false","SET xmloption = content","SET client_min_messages = warning","SET row_security = off","ALTER SCHEMA \\"public\\" OWNER TO \\"postgres\\"","CREATE EXTENSION IF NOT EXISTS \\"pg_graphql\\" WITH SCHEMA \\"graphql\\"","CREATE EXTENSION IF NOT EXISTS \\"pg_stat_statements\\" WITH SCHEMA \\"extensions\\"","CREATE EXTENSION IF NOT EXISTS \\"pgcrypto\\" WITH SCHEMA \\"extensions\\"","CREATE EXTENSION IF NOT EXISTS \\"supabase_vault\\" WITH SCHEMA \\"vault\\"","CREATE EXTENSION IF NOT EXISTS \\"uuid-ossp\\" WITH SCHEMA \\"extensions\\"","SET default_tablespace = ''","SET default_table_access_method = \\"heap\\"","CREATE TABLE IF NOT EXISTS \\"public\\".\\"_prisma_migrations\\" (\n    \\"id\\" character varying(36) NOT NULL,\n    \\"checksum\\" character varying(64) NOT NULL,\n    \\"finished_at\\" timestamp with time zone,\n    \\"migration_name\\" character varying(255) NOT NULL,\n    \\"logs\\" \\"text\\",\n    \\"rolled_back_at\\" timestamp with time zone,\n    \\"started_at\\" timestamp with time zone DEFAULT \\"now\\"() NOT NULL,\n    \\"applied_steps_count\\" integer DEFAULT 0 NOT NULL\n)","ALTER TABLE \\"public\\".\\"_prisma_migrations\\" OWNER TO \\"postgres\\"","CREATE TABLE IF NOT EXISTS \\"public\\".\\"action_types\\" (\n    \\"id\\" integer NOT NULL,\n    \\"name\\" \\"text\\" NOT NULL,\n    \\"description\\" \\"text\\",\n    \\"created_at\\" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,\n    \\"updated_at\\" timestamp(3) without time zone NOT NULL\n)","ALTER TABLE \\"public\\".\\"action_types\\" OWNER TO \\"postgres\\"","CREATE SEQUENCE IF NOT EXISTS \\"public\\".\\"action_types_id_seq\\"\n    AS integer\n    START WITH 1\n    INCREMENT BY 1\n    NO MINVALUE\n    NO MAXVALUE\n    CACHE 1","ALTER SEQUENCE \\"public\\".\\"action_types_id_seq\\" OWNER TO \\"postgres\\"","ALTER SEQUENCE \\"public\\".\\"action_types_id_seq\\" OWNED BY \\"public\\".\\"action_types\\".\\"id\\"","CREATE TABLE IF NOT EXISTS \\"public\\".\\"api_usage\\" (\n    \\"id\\" integer NOT NULL,\n    \\"user_id\\" integer,\n    \\"service\\" \\"text\\" NOT NULL,\n    \\"operation\\" \\"text\\" NOT NULL,\n    \\"model\\" \\"text\\",\n    \\"tokens_input\\" integer DEFAULT 0 NOT NULL,\n    \\"tokens_output\\" integer DEFAULT 0 NOT NULL,\n    \\"tokens_total\\" integer DEFAULT 0 NOT NULL,\n    \\"cost_brl\\" double precision DEFAULT 0 NOT NULL,\n    \\"method\\" \\"text\\" DEFAULT 'ai'::\\"text\\" NOT NULL,\n    \\"success\\" boolean DEFAULT true NOT NULL,\n    \\"error_message\\" \\"text\\",\n    \\"document_id\\" integer,\n    \\"project_id\\" integer,\n    \\"date\\" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,\n    \\"created_at\\" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL\n)","ALTER TABLE \\"public\\".\\"api_usage\\" OWNER TO \\"postgres\\"","CREATE SEQUENCE IF NOT EXISTS \\"public\\".\\"api_usage_id_seq\\"\n    AS integer\n    START WITH 1\n    INCREMENT BY 1\n    NO MINVALUE\n    NO MAXVALUE\n    CACHE 1","ALTER SEQUENCE \\"public\\".\\"api_usage_id_seq\\" OWNER TO \\"postgres\\"","ALTER SEQUENCE \\"public\\".\\"api_usage_id_seq\\" OWNED BY \\"public\\".\\"api_usage\\".\\"id\\"","CREATE TABLE IF NOT EXISTS \\"public\\".\\"document_types\\" (\n    \\"id\\" integer NOT NULL,\n    \\"code\\" \\"text\\" NOT NULL,\n    \\"name\\" \\"text\\" NOT NULL,\n    \\"description\\" \\"text\\",\n    \\"is_required\\" boolean DEFAULT false NOT NULL,\n    \\"order\\" integer NOT NULL,\n    \\"created_at\\" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,\n    \\"updated_at\\" timestamp(3) without time zone NOT NULL\n)","ALTER TABLE \\"public\\".\\"document_types\\" OWNER TO \\"postgres\\"","CREATE SEQUENCE IF NOT EXISTS \\"public\\".\\"document_types_id_seq\\"\n    AS integer\n    START WITH 1\n    INCREMENT BY 1\n    NO MINVALUE\n    NO MAXVALUE\n    CACHE 1","ALTER SEQUENCE \\"public\\".\\"document_types_id_seq\\" OWNER TO \\"postgres\\"","ALTER SEQUENCE \\"public\\".\\"document_types_id_seq\\" OWNED BY \\"public\\".\\"document_types\\".\\"id\\"","CREATE TABLE IF NOT EXISTS \\"public\\".\\"document_validations\\" (\n    \\"id\\" integer NOT NULL,\n    \\"project_id\\" integer NOT NULL,\n    \\"document_id\\" integer NOT NULL,\n    \\"is_relevant\\" boolean NOT NULL,\n    \\"relevance_score\\" double precision NOT NULL,\n    \\"ai_analysis\\" \\"text\\" NOT NULL,\n    \\"suggestions\\" \\"text\\",\n    \\"status\\" \\"text\\" DEFAULT 'pending'::\\"text\\" NOT NULL,\n    \\"reviewed_at\\" timestamp(3) without time zone,\n    \\"created_at\\" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,\n    \\"updated_at\\" timestamp(3) without time zone NOT NULL\n)","ALTER TABLE \\"public\\".\\"document_validations\\" OWNER TO \\"postgres\\"","CREATE SEQUENCE IF NOT EXISTS \\"public\\".\\"document_validations_id_seq\\"\n    AS integer\n    START WITH 1\n    INCREMENT BY 1\n    NO MINVALUE\n    NO MAXVALUE\n    CACHE 1","ALTER SEQUENCE \\"public\\".\\"document_validations_id_seq\\" OWNER TO \\"postgres\\"","ALTER SEQUENCE \\"public\\".\\"document_validations_id_seq\\" OWNED BY \\"public\\".\\"document_validations\\".\\"id\\"","CREATE TABLE IF NOT EXISTS \\"public\\".\\"documents\\" (\n    \\"id\\" integer NOT NULL,\n    \\"project_id\\" integer NOT NULL,\n    \\"user_id\\" integer NOT NULL,\n    \\"original_filename\\" \\"text\\" NOT NULL,\n    \\"stored_filename\\" \\"text\\" NOT NULL,\n    \\"document_type\\" \\"text\\" NOT NULL,\n    \\"document_number\\" integer NOT NULL,\n    \\"mime_type\\" \\"text\\" NOT NULL,\n    \\"original_size_bytes\\" integer NOT NULL,\n    \\"status\\" \\"text\\" DEFAULT 'uploaded'::\\"text\\" NOT NULL,\n    \\"pdf_path\\" \\"text\\",\n    \\"ocr_text\\" \\"text\\",\n    \\"pdf_size_bytes\\" integer,\n    \\"page_count\\" integer,\n    \\"page_size\\" \\"text\\",\n    \\"created_at\\" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,\n    \\"updated_at\\" timestamp(3) without time zone NOT NULL,\n    \\"ai_analysis\\" \\"text\\",\n    \\"analysis_confidence\\" double precision,\n    \\"detected_document_type\\" \\"text\\",\n    \\"grouped_at\\" timestamp(3) without time zone,\n    \\"is_grouped\\" boolean DEFAULT false NOT NULL,\n    \\"is_personal_document\\" boolean DEFAULT false NOT NULL,\n    \\"smart_filename\\" \\"text\\"\n)","ALTER TABLE \\"public\\".\\"documents\\" OWNER TO \\"postgres\\"","CREATE SEQUENCE IF NOT EXISTS \\"public\\".\\"documents_id_seq\\"\n    AS integer\n    START WITH 1\n    INCREMENT BY 1\n    NO MINVALUE\n    NO MAXVALUE\n    CACHE 1","ALTER SEQUENCE \\"public\\".\\"documents_id_seq\\" OWNER TO \\"postgres\\"","ALTER SEQUENCE \\"public\\".\\"documents_id_seq\\" OWNED BY \\"public\\".\\"documents\\".\\"id\\"","CREATE TABLE IF NOT EXISTS \\"public\\".\\"projects\\" (\n    \\"id\\" integer NOT NULL,\n    \\"user_id\\" integer NOT NULL,\n    \\"name\\" \\"text\\" NOT NULL,\n    \\"client\\" \\"text\\" NOT NULL,\n    \\"system\\" \\"text\\" NOT NULL,\n    \\"action_type\\" \\"text\\" NOT NULL,\n    \\"narrative\\" \\"text\\",\n    \\"processed_narrative\\" \\"text\\",\n    \\"status\\" \\"text\\" DEFAULT 'draft'::\\"text\\" NOT NULL,\n    \\"created_at\\" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,\n    \\"updated_at\\" timestamp(3) without time zone NOT NULL\n)","ALTER TABLE \\"public\\".\\"projects\\" OWNER TO \\"postgres\\"","CREATE SEQUENCE IF NOT EXISTS \\"public\\".\\"projects_id_seq\\"\n    AS integer\n    START WITH 1\n    INCREMENT BY 1\n    NO MINVALUE\n    NO MAXVALUE\n    CACHE 1","ALTER SEQUENCE \\"public\\".\\"projects_id_seq\\" OWNER TO \\"postgres\\"","ALTER SEQUENCE \\"public\\".\\"projects_id_seq\\" OWNED BY \\"public\\".\\"projects\\".\\"id\\"","CREATE TABLE IF NOT EXISTS \\"public\\".\\"system_configurations\\" (\n    \\"id\\" integer NOT NULL,\n    \\"system_name\\" \\"text\\" NOT NULL,\n    \\"max_file_size\\" integer NOT NULL,\n    \\"max_page_size\\" integer NOT NULL,\n    \\"allowed_formats\\" \\"text\\" NOT NULL,\n    \\"pdf_requirements\\" \\"text\\" NOT NULL,\n    \\"created_at\\" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,\n    \\"updated_at\\" timestamp(3) without time zone NOT NULL\n)","ALTER TABLE \\"public\\".\\"system_configurations\\" OWNER TO \\"postgres\\"","CREATE SEQUENCE IF NOT EXISTS \\"public\\".\\"system_configurations_id_seq\\"\n    AS integer\n    START WITH 1\n    INCREMENT BY 1\n    NO MINVALUE\n    NO MAXVALUE\n    CACHE 1","ALTER SEQUENCE \\"public\\".\\"system_configurations_id_seq\\" OWNER TO \\"postgres\\"","ALTER SEQUENCE \\"public\\".\\"system_configurations_id_seq\\" OWNED BY \\"public\\".\\"system_configurations\\".\\"id\\"","CREATE TABLE IF NOT EXISTS \\"public\\".\\"users\\" (\n    \\"id\\" integer NOT NULL,\n    \\"email\\" \\"text\\" NOT NULL,\n    \\"password\\" \\"text\\" NOT NULL,\n    \\"name\\" \\"text\\" NOT NULL,\n    \\"created_at\\" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,\n    \\"updated_at\\" timestamp(3) without time zone NOT NULL\n)","ALTER TABLE \\"public\\".\\"users\\" OWNER TO \\"postgres\\"","CREATE SEQUENCE IF NOT EXISTS \\"public\\".\\"users_id_seq\\"\n    AS integer\n    START WITH 1\n    INCREMENT BY 1\n    NO MINVALUE\n    NO MAXVALUE\n    CACHE 1","ALTER SEQUENCE \\"public\\".\\"users_id_seq\\" OWNER TO \\"postgres\\"","ALTER SEQUENCE \\"public\\".\\"users_id_seq\\" OWNED BY \\"public\\".\\"users\\".\\"id\\"","ALTER TABLE ONLY \\"public\\".\\"action_types\\" ALTER COLUMN \\"id\\" SET DEFAULT \\"nextval\\"('\\"public\\".\\"action_types_id_seq\\"'::\\"regclass\\")","ALTER TABLE ONLY \\"public\\".\\"api_usage\\" ALTER COLUMN \\"id\\" SET DEFAULT \\"nextval\\"('\\"public\\".\\"api_usage_id_seq\\"'::\\"regclass\\")","ALTER TABLE ONLY \\"public\\".\\"document_types\\" ALTER COLUMN \\"id\\" SET DEFAULT \\"nextval\\"('\\"public\\".\\"document_types_id_seq\\"'::\\"regclass\\")","ALTER TABLE ONLY \\"public\\".\\"document_validations\\" ALTER COLUMN \\"id\\" SET DEFAULT \\"nextval\\"('\\"public\\".\\"document_validations_id_seq\\"'::\\"regclass\\")","ALTER TABLE ONLY \\"public\\".\\"documents\\" ALTER COLUMN \\"id\\" SET DEFAULT \\"nextval\\"('\\"public\\".\\"documents_id_seq\\"'::\\"regclass\\")","ALTER TABLE ONLY \\"public\\".\\"projects\\" ALTER COLUMN \\"id\\" SET DEFAULT \\"nextval\\"('\\"public\\".\\"projects_id_seq\\"'::\\"regclass\\")","ALTER TABLE ONLY \\"public\\".\\"system_configurations\\" ALTER COLUMN \\"id\\" SET DEFAULT \\"nextval\\"('\\"public\\".\\"system_configurations_id_seq\\"'::\\"regclass\\")","ALTER TABLE ONLY \\"public\\".\\"users\\" ALTER COLUMN \\"id\\" SET DEFAULT \\"nextval\\"('\\"public\\".\\"users_id_seq\\"'::\\"regclass\\")","ALTER TABLE ONLY \\"public\\".\\"_prisma_migrations\\"\n    ADD CONSTRAINT \\"_prisma_migrations_pkey\\" PRIMARY KEY (\\"id\\")","ALTER TABLE ONLY \\"public\\".\\"action_types\\"\n    ADD CONSTRAINT \\"action_types_pkey\\" PRIMARY KEY (\\"id\\")","ALTER TABLE ONLY \\"public\\".\\"api_usage\\"\n    ADD CONSTRAINT \\"api_usage_pkey\\" PRIMARY KEY (\\"id\\")","ALTER TABLE ONLY \\"public\\".\\"document_types\\"\n    ADD CONSTRAINT \\"document_types_pkey\\" PRIMARY KEY (\\"id\\")","ALTER TABLE ONLY \\"public\\".\\"document_validations\\"\n    ADD CONSTRAINT \\"document_validations_pkey\\" PRIMARY KEY (\\"id\\")","ALTER TABLE ONLY \\"public\\".\\"documents\\"\n    ADD CONSTRAINT \\"documents_pkey\\" PRIMARY KEY (\\"id\\")","ALTER TABLE ONLY \\"public\\".\\"projects\\"\n    ADD CONSTRAINT \\"projects_pkey\\" PRIMARY KEY (\\"id\\")","ALTER TABLE ONLY \\"public\\".\\"system_configurations\\"\n    ADD CONSTRAINT \\"system_configurations_pkey\\" PRIMARY KEY (\\"id\\")","ALTER TABLE ONLY \\"public\\".\\"users\\"\n    ADD CONSTRAINT \\"users_pkey\\" PRIMARY KEY (\\"id\\")","CREATE UNIQUE INDEX \\"action_types_name_key\\" ON \\"public\\".\\"action_types\\" USING \\"btree\\" (\\"name\\")","CREATE INDEX \\"api_usage_date_idx\\" ON \\"public\\".\\"api_usage\\" USING \\"btree\\" (\\"date\\")","CREATE INDEX \\"api_usage_method_idx\\" ON \\"public\\".\\"api_usage\\" USING \\"btree\\" (\\"method\\")","CREATE INDEX \\"api_usage_service_idx\\" ON \\"public\\".\\"api_usage\\" USING \\"btree\\" (\\"service\\")","CREATE INDEX \\"api_usage_user_id_idx\\" ON \\"public\\".\\"api_usage\\" USING \\"btree\\" (\\"user_id\\")","CREATE UNIQUE INDEX \\"document_types_code_key\\" ON \\"public\\".\\"document_types\\" USING \\"btree\\" (\\"code\\")","CREATE UNIQUE INDEX \\"document_validations_document_id_key\\" ON \\"public\\".\\"document_validations\\" USING \\"btree\\" (\\"document_id\\")","CREATE INDEX \\"document_validations_project_id_idx\\" ON \\"public\\".\\"document_validations\\" USING \\"btree\\" (\\"project_id\\")","CREATE INDEX \\"documents_project_id_idx\\" ON \\"public\\".\\"documents\\" USING \\"btree\\" (\\"project_id\\")","CREATE INDEX \\"documents_user_id_idx\\" ON \\"public\\".\\"documents\\" USING \\"btree\\" (\\"user_id\\")","CREATE INDEX \\"projects_user_id_idx\\" ON \\"public\\".\\"projects\\" USING \\"btree\\" (\\"user_id\\")","CREATE UNIQUE INDEX \\"system_configurations_system_name_key\\" ON \\"public\\".\\"system_configurations\\" USING \\"btree\\" (\\"system_name\\")","CREATE UNIQUE INDEX \\"users_email_key\\" ON \\"public\\".\\"users\\" USING \\"btree\\" (\\"email\\")","ALTER TABLE ONLY \\"public\\".\\"document_validations\\"\n    ADD CONSTRAINT \\"document_validations_document_id_fkey\\" FOREIGN KEY (\\"document_id\\") REFERENCES \\"public\\".\\"documents\\"(\\"id\\") ON UPDATE CASCADE ON DELETE CASCADE","ALTER TABLE ONLY \\"public\\".\\"document_validations\\"\n    ADD CONSTRAINT \\"document_validations_project_id_fkey\\" FOREIGN KEY (\\"project_id\\") REFERENCES \\"public\\".\\"projects\\"(\\"id\\") ON UPDATE CASCADE ON DELETE CASCADE","ALTER TABLE ONLY \\"public\\".\\"documents\\"\n    ADD CONSTRAINT \\"documents_project_id_fkey\\" FOREIGN KEY (\\"project_id\\") REFERENCES \\"public\\".\\"projects\\"(\\"id\\") ON UPDATE CASCADE ON DELETE CASCADE","ALTER TABLE ONLY \\"public\\".\\"documents\\"\n    ADD CONSTRAINT \\"documents_user_id_fkey\\" FOREIGN KEY (\\"user_id\\") REFERENCES \\"public\\".\\"users\\"(\\"id\\") ON UPDATE CASCADE ON DELETE CASCADE","ALTER TABLE ONLY \\"public\\".\\"projects\\"\n    ADD CONSTRAINT \\"projects_user_id_fkey\\" FOREIGN KEY (\\"user_id\\") REFERENCES \\"public\\".\\"users\\"(\\"id\\") ON UPDATE CASCADE ON DELETE CASCADE","ALTER PUBLICATION \\"supabase_realtime\\" OWNER TO \\"postgres\\"","REVOKE USAGE ON SCHEMA \\"public\\" FROM PUBLIC","RESET ALL"}	remote_schema
\.


--
-- Data for Name: seed_files; Type: TABLE DATA; Schema: supabase_migrations; Owner: postgres
--

COPY supabase_migrations.seed_files (path, hash) FROM stdin;
\.


--
-- Data for Name: secrets; Type: TABLE DATA; Schema: vault; Owner: supabase_admin
--

COPY vault.secrets (id, name, description, secret, key_id, nonce, created_at, updated_at) FROM stdin;
\.


--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE SET; Schema: auth; Owner: supabase_auth_admin
--

SELECT pg_catalog.setval('auth.refresh_tokens_id_seq', 1, false);


--
-- Name: action_types_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.action_types_id_seq', 1, true);


--
-- Name: api_usage_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.api_usage_id_seq', 63, true);


--
-- Name: document_types_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.document_types_id_seq', 1, false);


--
-- Name: document_validations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.document_validations_id_seq', 34, true);


--
-- Name: documents_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.documents_id_seq', 72, true);


--
-- Name: organizations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.organizations_id_seq', 12, true);


--
-- Name: projects_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.projects_id_seq', 6, true);


--
-- Name: system_configurations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.system_configurations_id_seq', 1, true);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_id_seq', 15, true);


--
-- Name: subscription_id_seq; Type: SEQUENCE SET; Schema: realtime; Owner: supabase_admin
--

SELECT pg_catalog.setval('realtime.subscription_id_seq', 1, false);


--
-- Name: mfa_amr_claims amr_id_pk; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_amr_claims
    ADD CONSTRAINT amr_id_pk PRIMARY KEY (id);


--
-- Name: audit_log_entries audit_log_entries_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.audit_log_entries
    ADD CONSTRAINT audit_log_entries_pkey PRIMARY KEY (id);


--
-- Name: flow_state flow_state_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.flow_state
    ADD CONSTRAINT flow_state_pkey PRIMARY KEY (id);


--
-- Name: identities identities_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.identities
    ADD CONSTRAINT identities_pkey PRIMARY KEY (id);


--
-- Name: identities identities_provider_id_provider_unique; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.identities
    ADD CONSTRAINT identities_provider_id_provider_unique UNIQUE (provider_id, provider);


--
-- Name: instances instances_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.instances
    ADD CONSTRAINT instances_pkey PRIMARY KEY (id);


--
-- Name: mfa_amr_claims mfa_amr_claims_session_id_authentication_method_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_amr_claims
    ADD CONSTRAINT mfa_amr_claims_session_id_authentication_method_pkey UNIQUE (session_id, authentication_method);


--
-- Name: mfa_challenges mfa_challenges_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_challenges
    ADD CONSTRAINT mfa_challenges_pkey PRIMARY KEY (id);


--
-- Name: mfa_factors mfa_factors_last_challenged_at_key; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_factors
    ADD CONSTRAINT mfa_factors_last_challenged_at_key UNIQUE (last_challenged_at);


--
-- Name: mfa_factors mfa_factors_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_factors
    ADD CONSTRAINT mfa_factors_pkey PRIMARY KEY (id);


--
-- Name: oauth_authorizations oauth_authorizations_authorization_code_key; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.oauth_authorizations
    ADD CONSTRAINT oauth_authorizations_authorization_code_key UNIQUE (authorization_code);


--
-- Name: oauth_authorizations oauth_authorizations_authorization_id_key; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.oauth_authorizations
    ADD CONSTRAINT oauth_authorizations_authorization_id_key UNIQUE (authorization_id);


--
-- Name: oauth_authorizations oauth_authorizations_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.oauth_authorizations
    ADD CONSTRAINT oauth_authorizations_pkey PRIMARY KEY (id);


--
-- Name: oauth_clients oauth_clients_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.oauth_clients
    ADD CONSTRAINT oauth_clients_pkey PRIMARY KEY (id);


--
-- Name: oauth_consents oauth_consents_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.oauth_consents
    ADD CONSTRAINT oauth_consents_pkey PRIMARY KEY (id);


--
-- Name: oauth_consents oauth_consents_user_client_unique; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.oauth_consents
    ADD CONSTRAINT oauth_consents_user_client_unique UNIQUE (user_id, client_id);


--
-- Name: one_time_tokens one_time_tokens_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.one_time_tokens
    ADD CONSTRAINT one_time_tokens_pkey PRIMARY KEY (id);


--
-- Name: refresh_tokens refresh_tokens_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.refresh_tokens
    ADD CONSTRAINT refresh_tokens_pkey PRIMARY KEY (id);


--
-- Name: refresh_tokens refresh_tokens_token_unique; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.refresh_tokens
    ADD CONSTRAINT refresh_tokens_token_unique UNIQUE (token);


--
-- Name: saml_providers saml_providers_entity_id_key; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.saml_providers
    ADD CONSTRAINT saml_providers_entity_id_key UNIQUE (entity_id);


--
-- Name: saml_providers saml_providers_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.saml_providers
    ADD CONSTRAINT saml_providers_pkey PRIMARY KEY (id);


--
-- Name: saml_relay_states saml_relay_states_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.saml_relay_states
    ADD CONSTRAINT saml_relay_states_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- Name: sso_domains sso_domains_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.sso_domains
    ADD CONSTRAINT sso_domains_pkey PRIMARY KEY (id);


--
-- Name: sso_providers sso_providers_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.sso_providers
    ADD CONSTRAINT sso_providers_pkey PRIMARY KEY (id);


--
-- Name: users users_phone_key; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.users
    ADD CONSTRAINT users_phone_key UNIQUE (phone);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: _prisma_migrations _prisma_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public._prisma_migrations
    ADD CONSTRAINT _prisma_migrations_pkey PRIMARY KEY (id);


--
-- Name: action_types action_types_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.action_types
    ADD CONSTRAINT action_types_pkey PRIMARY KEY (id);


--
-- Name: api_usage api_usage_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.api_usage
    ADD CONSTRAINT api_usage_pkey PRIMARY KEY (id);


--
-- Name: document_types document_types_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.document_types
    ADD CONSTRAINT document_types_pkey PRIMARY KEY (id);


--
-- Name: document_validations document_validations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.document_validations
    ADD CONSTRAINT document_validations_pkey PRIMARY KEY (id);


--
-- Name: documents documents_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.documents
    ADD CONSTRAINT documents_pkey PRIMARY KEY (id);


--
-- Name: organizations organizations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.organizations
    ADD CONSTRAINT organizations_pkey PRIMARY KEY (id);


--
-- Name: projects projects_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT projects_pkey PRIMARY KEY (id);


--
-- Name: system_configurations system_configurations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.system_configurations
    ADD CONSTRAINT system_configurations_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: messages messages_pkey; Type: CONSTRAINT; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER TABLE ONLY realtime.messages
    ADD CONSTRAINT messages_pkey PRIMARY KEY (id, inserted_at);


--
-- Name: subscription pk_subscription; Type: CONSTRAINT; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY realtime.subscription
    ADD CONSTRAINT pk_subscription PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY realtime.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: buckets_analytics buckets_analytics_pkey; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.buckets_analytics
    ADD CONSTRAINT buckets_analytics_pkey PRIMARY KEY (id);


--
-- Name: buckets buckets_pkey; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.buckets
    ADD CONSTRAINT buckets_pkey PRIMARY KEY (id);


--
-- Name: migrations migrations_name_key; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.migrations
    ADD CONSTRAINT migrations_name_key UNIQUE (name);


--
-- Name: migrations migrations_pkey; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.migrations
    ADD CONSTRAINT migrations_pkey PRIMARY KEY (id);


--
-- Name: objects objects_pkey; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.objects
    ADD CONSTRAINT objects_pkey PRIMARY KEY (id);


--
-- Name: prefixes prefixes_pkey; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.prefixes
    ADD CONSTRAINT prefixes_pkey PRIMARY KEY (bucket_id, level, name);


--
-- Name: s3_multipart_uploads_parts s3_multipart_uploads_parts_pkey; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.s3_multipart_uploads_parts
    ADD CONSTRAINT s3_multipart_uploads_parts_pkey PRIMARY KEY (id);


--
-- Name: s3_multipart_uploads s3_multipart_uploads_pkey; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.s3_multipart_uploads
    ADD CONSTRAINT s3_multipart_uploads_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: supabase_migrations; Owner: postgres
--

ALTER TABLE ONLY supabase_migrations.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: seed_files seed_files_pkey; Type: CONSTRAINT; Schema: supabase_migrations; Owner: postgres
--

ALTER TABLE ONLY supabase_migrations.seed_files
    ADD CONSTRAINT seed_files_pkey PRIMARY KEY (path);


--
-- Name: audit_logs_instance_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX audit_logs_instance_id_idx ON auth.audit_log_entries USING btree (instance_id);


--
-- Name: confirmation_token_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX confirmation_token_idx ON auth.users USING btree (confirmation_token) WHERE ((confirmation_token)::text !~ '^[0-9 ]*$'::text);


--
-- Name: email_change_token_current_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX email_change_token_current_idx ON auth.users USING btree (email_change_token_current) WHERE ((email_change_token_current)::text !~ '^[0-9 ]*$'::text);


--
-- Name: email_change_token_new_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX email_change_token_new_idx ON auth.users USING btree (email_change_token_new) WHERE ((email_change_token_new)::text !~ '^[0-9 ]*$'::text);


--
-- Name: factor_id_created_at_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX factor_id_created_at_idx ON auth.mfa_factors USING btree (user_id, created_at);


--
-- Name: flow_state_created_at_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX flow_state_created_at_idx ON auth.flow_state USING btree (created_at DESC);


--
-- Name: identities_email_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX identities_email_idx ON auth.identities USING btree (email text_pattern_ops);


--
-- Name: INDEX identities_email_idx; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON INDEX auth.identities_email_idx IS 'Auth: Ensures indexed queries on the email column';


--
-- Name: identities_user_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX identities_user_id_idx ON auth.identities USING btree (user_id);


--
-- Name: idx_auth_code; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX idx_auth_code ON auth.flow_state USING btree (auth_code);


--
-- Name: idx_user_id_auth_method; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX idx_user_id_auth_method ON auth.flow_state USING btree (user_id, authentication_method);


--
-- Name: mfa_challenge_created_at_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX mfa_challenge_created_at_idx ON auth.mfa_challenges USING btree (created_at DESC);


--
-- Name: mfa_factors_user_friendly_name_unique; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX mfa_factors_user_friendly_name_unique ON auth.mfa_factors USING btree (friendly_name, user_id) WHERE (TRIM(BOTH FROM friendly_name) <> ''::text);


--
-- Name: mfa_factors_user_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX mfa_factors_user_id_idx ON auth.mfa_factors USING btree (user_id);


--
-- Name: oauth_auth_pending_exp_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX oauth_auth_pending_exp_idx ON auth.oauth_authorizations USING btree (expires_at) WHERE (status = 'pending'::auth.oauth_authorization_status);


--
-- Name: oauth_clients_deleted_at_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX oauth_clients_deleted_at_idx ON auth.oauth_clients USING btree (deleted_at);


--
-- Name: oauth_consents_active_client_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX oauth_consents_active_client_idx ON auth.oauth_consents USING btree (client_id) WHERE (revoked_at IS NULL);


--
-- Name: oauth_consents_active_user_client_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX oauth_consents_active_user_client_idx ON auth.oauth_consents USING btree (user_id, client_id) WHERE (revoked_at IS NULL);


--
-- Name: oauth_consents_user_order_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX oauth_consents_user_order_idx ON auth.oauth_consents USING btree (user_id, granted_at DESC);


--
-- Name: one_time_tokens_relates_to_hash_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX one_time_tokens_relates_to_hash_idx ON auth.one_time_tokens USING hash (relates_to);


--
-- Name: one_time_tokens_token_hash_hash_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX one_time_tokens_token_hash_hash_idx ON auth.one_time_tokens USING hash (token_hash);


--
-- Name: one_time_tokens_user_id_token_type_key; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX one_time_tokens_user_id_token_type_key ON auth.one_time_tokens USING btree (user_id, token_type);


--
-- Name: reauthentication_token_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX reauthentication_token_idx ON auth.users USING btree (reauthentication_token) WHERE ((reauthentication_token)::text !~ '^[0-9 ]*$'::text);


--
-- Name: recovery_token_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX recovery_token_idx ON auth.users USING btree (recovery_token) WHERE ((recovery_token)::text !~ '^[0-9 ]*$'::text);


--
-- Name: refresh_tokens_instance_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX refresh_tokens_instance_id_idx ON auth.refresh_tokens USING btree (instance_id);


--
-- Name: refresh_tokens_instance_id_user_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX refresh_tokens_instance_id_user_id_idx ON auth.refresh_tokens USING btree (instance_id, user_id);


--
-- Name: refresh_tokens_parent_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX refresh_tokens_parent_idx ON auth.refresh_tokens USING btree (parent);


--
-- Name: refresh_tokens_session_id_revoked_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX refresh_tokens_session_id_revoked_idx ON auth.refresh_tokens USING btree (session_id, revoked);


--
-- Name: refresh_tokens_updated_at_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX refresh_tokens_updated_at_idx ON auth.refresh_tokens USING btree (updated_at DESC);


--
-- Name: saml_providers_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX saml_providers_sso_provider_id_idx ON auth.saml_providers USING btree (sso_provider_id);


--
-- Name: saml_relay_states_created_at_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX saml_relay_states_created_at_idx ON auth.saml_relay_states USING btree (created_at DESC);


--
-- Name: saml_relay_states_for_email_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX saml_relay_states_for_email_idx ON auth.saml_relay_states USING btree (for_email);


--
-- Name: saml_relay_states_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX saml_relay_states_sso_provider_id_idx ON auth.saml_relay_states USING btree (sso_provider_id);


--
-- Name: sessions_not_after_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX sessions_not_after_idx ON auth.sessions USING btree (not_after DESC);


--
-- Name: sessions_oauth_client_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX sessions_oauth_client_id_idx ON auth.sessions USING btree (oauth_client_id);


--
-- Name: sessions_user_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX sessions_user_id_idx ON auth.sessions USING btree (user_id);


--
-- Name: sso_domains_domain_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX sso_domains_domain_idx ON auth.sso_domains USING btree (lower(domain));


--
-- Name: sso_domains_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX sso_domains_sso_provider_id_idx ON auth.sso_domains USING btree (sso_provider_id);


--
-- Name: sso_providers_resource_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX sso_providers_resource_id_idx ON auth.sso_providers USING btree (lower(resource_id));


--
-- Name: sso_providers_resource_id_pattern_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX sso_providers_resource_id_pattern_idx ON auth.sso_providers USING btree (resource_id text_pattern_ops);


--
-- Name: unique_phone_factor_per_user; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX unique_phone_factor_per_user ON auth.mfa_factors USING btree (user_id, phone);


--
-- Name: user_id_created_at_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX user_id_created_at_idx ON auth.sessions USING btree (user_id, created_at);


--
-- Name: users_email_partial_key; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX users_email_partial_key ON auth.users USING btree (email) WHERE (is_sso_user = false);


--
-- Name: INDEX users_email_partial_key; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON INDEX auth.users_email_partial_key IS 'Auth: A partial unique index that applies only when is_sso_user is false';


--
-- Name: users_instance_id_email_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX users_instance_id_email_idx ON auth.users USING btree (instance_id, lower((email)::text));


--
-- Name: users_instance_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX users_instance_id_idx ON auth.users USING btree (instance_id);


--
-- Name: users_is_anonymous_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX users_is_anonymous_idx ON auth.users USING btree (is_anonymous);


--
-- Name: action_types_name_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX action_types_name_key ON public.action_types USING btree (name);


--
-- Name: api_usage_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX api_usage_date_idx ON public.api_usage USING btree (date);


--
-- Name: api_usage_organization_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX api_usage_organization_id_idx ON public.api_usage USING btree (organization_id);


--
-- Name: api_usage_service_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX api_usage_service_idx ON public.api_usage USING btree (service);


--
-- Name: api_usage_user_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX api_usage_user_id_idx ON public.api_usage USING btree (user_id);


--
-- Name: document_types_code_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX document_types_code_key ON public.document_types USING btree (code);


--
-- Name: document_validations_document_id_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX document_validations_document_id_key ON public.document_validations USING btree (document_id);


--
-- Name: document_validations_organizationId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "document_validations_organizationId_idx" ON public.document_validations USING btree ("organizationId");


--
-- Name: document_validations_project_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX document_validations_project_id_idx ON public.document_validations USING btree (project_id);


--
-- Name: documents_organizationId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "documents_organizationId_idx" ON public.documents USING btree ("organizationId");


--
-- Name: documents_project_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX documents_project_id_idx ON public.documents USING btree (project_id);


--
-- Name: documents_user_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX documents_user_id_idx ON public.documents USING btree (user_id);


--
-- Name: organizations_cnpj_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX organizations_cnpj_key ON public.organizations USING btree (cnpj);


--
-- Name: organizations_mercadopago_subscription_id_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX organizations_mercadopago_subscription_id_key ON public.organizations USING btree (mercadopago_subscription_id);


--
-- Name: organizations_stripe_customer_id_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX organizations_stripe_customer_id_key ON public.organizations USING btree (stripe_customer_id);


--
-- Name: projects_organizationId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "projects_organizationId_idx" ON public.projects USING btree ("organizationId");


--
-- Name: projects_user_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX projects_user_id_idx ON public.projects USING btree (user_id);


--
-- Name: system_configurations_system_name_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX system_configurations_system_name_key ON public.system_configurations USING btree (system_name);


--
-- Name: users_auth_user_id_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX users_auth_user_id_key ON public.users USING btree (auth_user_id);


--
-- Name: users_email_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX users_email_key ON public.users USING btree (email);


--
-- Name: users_organizationId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "users_organizationId_idx" ON public.users USING btree ("organizationId");


--
-- Name: ix_realtime_subscription_entity; Type: INDEX; Schema: realtime; Owner: supabase_admin
--

CREATE INDEX ix_realtime_subscription_entity ON realtime.subscription USING btree (entity);


--
-- Name: messages_inserted_at_topic_index; Type: INDEX; Schema: realtime; Owner: supabase_realtime_admin
--

CREATE INDEX messages_inserted_at_topic_index ON ONLY realtime.messages USING btree (inserted_at DESC, topic) WHERE ((extension = 'broadcast'::text) AND (private IS TRUE));


--
-- Name: subscription_subscription_id_entity_filters_key; Type: INDEX; Schema: realtime; Owner: supabase_admin
--

CREATE UNIQUE INDEX subscription_subscription_id_entity_filters_key ON realtime.subscription USING btree (subscription_id, entity, filters);


--
-- Name: bname; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE UNIQUE INDEX bname ON storage.buckets USING btree (name);


--
-- Name: bucketid_objname; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE UNIQUE INDEX bucketid_objname ON storage.objects USING btree (bucket_id, name);


--
-- Name: idx_multipart_uploads_list; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE INDEX idx_multipart_uploads_list ON storage.s3_multipart_uploads USING btree (bucket_id, key, created_at);


--
-- Name: idx_name_bucket_level_unique; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE UNIQUE INDEX idx_name_bucket_level_unique ON storage.objects USING btree (name COLLATE "C", bucket_id, level);


--
-- Name: idx_objects_bucket_id_name; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE INDEX idx_objects_bucket_id_name ON storage.objects USING btree (bucket_id, name COLLATE "C");


--
-- Name: idx_objects_lower_name; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE INDEX idx_objects_lower_name ON storage.objects USING btree ((path_tokens[level]), lower(name) text_pattern_ops, bucket_id, level);


--
-- Name: idx_prefixes_lower_name; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE INDEX idx_prefixes_lower_name ON storage.prefixes USING btree (bucket_id, level, ((string_to_array(name, '/'::text))[level]), lower(name) text_pattern_ops);


--
-- Name: name_prefix_search; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE INDEX name_prefix_search ON storage.objects USING btree (name text_pattern_ops);


--
-- Name: objects_bucket_id_level_idx; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE UNIQUE INDEX objects_bucket_id_level_idx ON storage.objects USING btree (bucket_id, level, name COLLATE "C");


--
-- Name: subscription tr_check_filters; Type: TRIGGER; Schema: realtime; Owner: supabase_admin
--

CREATE TRIGGER tr_check_filters BEFORE INSERT OR UPDATE ON realtime.subscription FOR EACH ROW EXECUTE FUNCTION realtime.subscription_check_filters();


--
-- Name: buckets enforce_bucket_name_length_trigger; Type: TRIGGER; Schema: storage; Owner: supabase_storage_admin
--

CREATE TRIGGER enforce_bucket_name_length_trigger BEFORE INSERT OR UPDATE OF name ON storage.buckets FOR EACH ROW EXECUTE FUNCTION storage.enforce_bucket_name_length();


--
-- Name: objects objects_delete_delete_prefix; Type: TRIGGER; Schema: storage; Owner: supabase_storage_admin
--

CREATE TRIGGER objects_delete_delete_prefix AFTER DELETE ON storage.objects FOR EACH ROW EXECUTE FUNCTION storage.delete_prefix_hierarchy_trigger();


--
-- Name: objects objects_insert_create_prefix; Type: TRIGGER; Schema: storage; Owner: supabase_storage_admin
--

CREATE TRIGGER objects_insert_create_prefix BEFORE INSERT ON storage.objects FOR EACH ROW EXECUTE FUNCTION storage.objects_insert_prefix_trigger();


--
-- Name: objects objects_update_create_prefix; Type: TRIGGER; Schema: storage; Owner: supabase_storage_admin
--

CREATE TRIGGER objects_update_create_prefix BEFORE UPDATE ON storage.objects FOR EACH ROW WHEN (((new.name <> old.name) OR (new.bucket_id <> old.bucket_id))) EXECUTE FUNCTION storage.objects_update_prefix_trigger();


--
-- Name: prefixes prefixes_create_hierarchy; Type: TRIGGER; Schema: storage; Owner: supabase_storage_admin
--

CREATE TRIGGER prefixes_create_hierarchy BEFORE INSERT ON storage.prefixes FOR EACH ROW WHEN ((pg_trigger_depth() < 1)) EXECUTE FUNCTION storage.prefixes_insert_trigger();


--
-- Name: prefixes prefixes_delete_hierarchy; Type: TRIGGER; Schema: storage; Owner: supabase_storage_admin
--

CREATE TRIGGER prefixes_delete_hierarchy AFTER DELETE ON storage.prefixes FOR EACH ROW EXECUTE FUNCTION storage.delete_prefix_hierarchy_trigger();


--
-- Name: objects update_objects_updated_at; Type: TRIGGER; Schema: storage; Owner: supabase_storage_admin
--

CREATE TRIGGER update_objects_updated_at BEFORE UPDATE ON storage.objects FOR EACH ROW EXECUTE FUNCTION storage.update_updated_at_column();


--
-- Name: identities identities_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.identities
    ADD CONSTRAINT identities_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: mfa_amr_claims mfa_amr_claims_session_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_amr_claims
    ADD CONSTRAINT mfa_amr_claims_session_id_fkey FOREIGN KEY (session_id) REFERENCES auth.sessions(id) ON DELETE CASCADE;


--
-- Name: mfa_challenges mfa_challenges_auth_factor_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_challenges
    ADD CONSTRAINT mfa_challenges_auth_factor_id_fkey FOREIGN KEY (factor_id) REFERENCES auth.mfa_factors(id) ON DELETE CASCADE;


--
-- Name: mfa_factors mfa_factors_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_factors
    ADD CONSTRAINT mfa_factors_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: oauth_authorizations oauth_authorizations_client_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.oauth_authorizations
    ADD CONSTRAINT oauth_authorizations_client_id_fkey FOREIGN KEY (client_id) REFERENCES auth.oauth_clients(id) ON DELETE CASCADE;


--
-- Name: oauth_authorizations oauth_authorizations_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.oauth_authorizations
    ADD CONSTRAINT oauth_authorizations_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: oauth_consents oauth_consents_client_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.oauth_consents
    ADD CONSTRAINT oauth_consents_client_id_fkey FOREIGN KEY (client_id) REFERENCES auth.oauth_clients(id) ON DELETE CASCADE;


--
-- Name: oauth_consents oauth_consents_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.oauth_consents
    ADD CONSTRAINT oauth_consents_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: one_time_tokens one_time_tokens_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.one_time_tokens
    ADD CONSTRAINT one_time_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: refresh_tokens refresh_tokens_session_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.refresh_tokens
    ADD CONSTRAINT refresh_tokens_session_id_fkey FOREIGN KEY (session_id) REFERENCES auth.sessions(id) ON DELETE CASCADE;


--
-- Name: saml_providers saml_providers_sso_provider_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.saml_providers
    ADD CONSTRAINT saml_providers_sso_provider_id_fkey FOREIGN KEY (sso_provider_id) REFERENCES auth.sso_providers(id) ON DELETE CASCADE;


--
-- Name: saml_relay_states saml_relay_states_flow_state_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.saml_relay_states
    ADD CONSTRAINT saml_relay_states_flow_state_id_fkey FOREIGN KEY (flow_state_id) REFERENCES auth.flow_state(id) ON DELETE CASCADE;


--
-- Name: saml_relay_states saml_relay_states_sso_provider_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.saml_relay_states
    ADD CONSTRAINT saml_relay_states_sso_provider_id_fkey FOREIGN KEY (sso_provider_id) REFERENCES auth.sso_providers(id) ON DELETE CASCADE;


--
-- Name: sessions sessions_oauth_client_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.sessions
    ADD CONSTRAINT sessions_oauth_client_id_fkey FOREIGN KEY (oauth_client_id) REFERENCES auth.oauth_clients(id) ON DELETE CASCADE;


--
-- Name: sessions sessions_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.sessions
    ADD CONSTRAINT sessions_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: sso_domains sso_domains_sso_provider_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.sso_domains
    ADD CONSTRAINT sso_domains_sso_provider_id_fkey FOREIGN KEY (sso_provider_id) REFERENCES auth.sso_providers(id) ON DELETE CASCADE;


--
-- Name: api_usage api_usage_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.api_usage
    ADD CONSTRAINT api_usage_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: api_usage api_usage_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.api_usage
    ADD CONSTRAINT api_usage_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: document_validations document_validations_document_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.document_validations
    ADD CONSTRAINT document_validations_document_id_fkey FOREIGN KEY (document_id) REFERENCES public.documents(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: document_validations document_validations_organizationId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.document_validations
    ADD CONSTRAINT "document_validations_organizationId_fkey" FOREIGN KEY ("organizationId") REFERENCES public.organizations(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: document_validations document_validations_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.document_validations
    ADD CONSTRAINT document_validations_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.projects(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: documents documents_organizationId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.documents
    ADD CONSTRAINT "documents_organizationId_fkey" FOREIGN KEY ("organizationId") REFERENCES public.organizations(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: documents documents_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.documents
    ADD CONSTRAINT documents_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.projects(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: documents documents_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.documents
    ADD CONSTRAINT documents_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON UPDATE CASCADE;


--
-- Name: projects projects_organizationId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT "projects_organizationId_fkey" FOREIGN KEY ("organizationId") REFERENCES public.organizations(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: projects projects_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT projects_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON UPDATE CASCADE;


--
-- Name: users users_organizationId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT "users_organizationId_fkey" FOREIGN KEY ("organizationId") REFERENCES public.organizations(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: objects objects_bucketId_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.objects
    ADD CONSTRAINT "objects_bucketId_fkey" FOREIGN KEY (bucket_id) REFERENCES storage.buckets(id);


--
-- Name: prefixes prefixes_bucketId_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.prefixes
    ADD CONSTRAINT "prefixes_bucketId_fkey" FOREIGN KEY (bucket_id) REFERENCES storage.buckets(id);


--
-- Name: s3_multipart_uploads s3_multipart_uploads_bucket_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.s3_multipart_uploads
    ADD CONSTRAINT s3_multipart_uploads_bucket_id_fkey FOREIGN KEY (bucket_id) REFERENCES storage.buckets(id);


--
-- Name: s3_multipart_uploads_parts s3_multipart_uploads_parts_bucket_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.s3_multipart_uploads_parts
    ADD CONSTRAINT s3_multipart_uploads_parts_bucket_id_fkey FOREIGN KEY (bucket_id) REFERENCES storage.buckets(id);


--
-- Name: s3_multipart_uploads_parts s3_multipart_uploads_parts_upload_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.s3_multipart_uploads_parts
    ADD CONSTRAINT s3_multipart_uploads_parts_upload_id_fkey FOREIGN KEY (upload_id) REFERENCES storage.s3_multipart_uploads(id) ON DELETE CASCADE;


--
-- Name: audit_log_entries; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.audit_log_entries ENABLE ROW LEVEL SECURITY;

--
-- Name: flow_state; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.flow_state ENABLE ROW LEVEL SECURITY;

--
-- Name: identities; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.identities ENABLE ROW LEVEL SECURITY;

--
-- Name: instances; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.instances ENABLE ROW LEVEL SECURITY;

--
-- Name: mfa_amr_claims; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.mfa_amr_claims ENABLE ROW LEVEL SECURITY;

--
-- Name: mfa_challenges; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.mfa_challenges ENABLE ROW LEVEL SECURITY;

--
-- Name: mfa_factors; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.mfa_factors ENABLE ROW LEVEL SECURITY;

--
-- Name: one_time_tokens; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.one_time_tokens ENABLE ROW LEVEL SECURITY;

--
-- Name: refresh_tokens; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.refresh_tokens ENABLE ROW LEVEL SECURITY;

--
-- Name: saml_providers; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.saml_providers ENABLE ROW LEVEL SECURITY;

--
-- Name: saml_relay_states; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.saml_relay_states ENABLE ROW LEVEL SECURITY;

--
-- Name: schema_migrations; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.schema_migrations ENABLE ROW LEVEL SECURITY;

--
-- Name: sessions; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.sessions ENABLE ROW LEVEL SECURITY;

--
-- Name: sso_domains; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.sso_domains ENABLE ROW LEVEL SECURITY;

--
-- Name: sso_providers; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.sso_providers ENABLE ROW LEVEL SECURITY;

--
-- Name: users; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.users ENABLE ROW LEVEL SECURITY;

--
-- Name: api_usage; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.api_usage ENABLE ROW LEVEL SECURITY;

--
-- Name: api_usage api_usage_service_role_policy; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY api_usage_service_role_policy ON public.api_usage USING (true);


--
-- Name: document_validations; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.document_validations ENABLE ROW LEVEL SECURITY;

--
-- Name: document_validations document_validations_service_role_policy; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY document_validations_service_role_policy ON public.document_validations USING (true);


--
-- Name: documents; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.documents ENABLE ROW LEVEL SECURITY;

--
-- Name: documents documents_service_role_policy; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY documents_service_role_policy ON public.documents USING (true);


--
-- Name: organizations; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.organizations ENABLE ROW LEVEL SECURITY;

--
-- Name: organizations organizations_service_role_policy; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY organizations_service_role_policy ON public.organizations USING (true);


--
-- Name: projects; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.projects ENABLE ROW LEVEL SECURITY;

--
-- Name: projects projects_service_role_policy; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY projects_service_role_policy ON public.projects USING (true);


--
-- Name: users; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

--
-- Name: users users_service_role_policy; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY users_service_role_policy ON public.users USING (true);


--
-- Name: messages; Type: ROW SECURITY; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER TABLE realtime.messages ENABLE ROW LEVEL SECURITY;

--
-- Name: buckets; Type: ROW SECURITY; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE storage.buckets ENABLE ROW LEVEL SECURITY;

--
-- Name: buckets_analytics; Type: ROW SECURITY; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE storage.buckets_analytics ENABLE ROW LEVEL SECURITY;

--
-- Name: migrations; Type: ROW SECURITY; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE storage.migrations ENABLE ROW LEVEL SECURITY;

--
-- Name: objects; Type: ROW SECURITY; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

--
-- Name: prefixes; Type: ROW SECURITY; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE storage.prefixes ENABLE ROW LEVEL SECURITY;

--
-- Name: s3_multipart_uploads; Type: ROW SECURITY; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE storage.s3_multipart_uploads ENABLE ROW LEVEL SECURITY;

--
-- Name: s3_multipart_uploads_parts; Type: ROW SECURITY; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE storage.s3_multipart_uploads_parts ENABLE ROW LEVEL SECURITY;

--
-- Name: supabase_realtime; Type: PUBLICATION; Schema: -; Owner: postgres
--




ALTER PUBLICATION supabase_realtime OWNER TO postgres;

--
-- Name: SCHEMA auth; Type: ACL; Schema: -; Owner: supabase_admin
--

GRANT USAGE ON SCHEMA auth TO anon;
GRANT USAGE ON SCHEMA auth TO authenticated;
GRANT USAGE ON SCHEMA auth TO service_role;
GRANT ALL ON SCHEMA auth TO supabase_auth_admin;
GRANT ALL ON SCHEMA auth TO dashboard_user;
GRANT USAGE ON SCHEMA auth TO postgres;


--
-- Name: SCHEMA extensions; Type: ACL; Schema: -; Owner: postgres
--

GRANT USAGE ON SCHEMA extensions TO anon;
GRANT USAGE ON SCHEMA extensions TO authenticated;
GRANT USAGE ON SCHEMA extensions TO service_role;
GRANT ALL ON SCHEMA extensions TO dashboard_user;


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE USAGE ON SCHEMA public FROM PUBLIC;


--
-- Name: SCHEMA realtime; Type: ACL; Schema: -; Owner: supabase_admin
--

GRANT USAGE ON SCHEMA realtime TO postgres;
GRANT USAGE ON SCHEMA realtime TO anon;
GRANT USAGE ON SCHEMA realtime TO authenticated;
GRANT USAGE ON SCHEMA realtime TO service_role;
GRANT ALL ON SCHEMA realtime TO supabase_realtime_admin;


--
-- Name: SCHEMA storage; Type: ACL; Schema: -; Owner: supabase_admin
--

GRANT USAGE ON SCHEMA storage TO postgres WITH GRANT OPTION;
GRANT USAGE ON SCHEMA storage TO anon;
GRANT USAGE ON SCHEMA storage TO authenticated;
GRANT USAGE ON SCHEMA storage TO service_role;
GRANT ALL ON SCHEMA storage TO supabase_storage_admin;
GRANT ALL ON SCHEMA storage TO dashboard_user;


--
-- Name: SCHEMA vault; Type: ACL; Schema: -; Owner: supabase_admin
--

GRANT USAGE ON SCHEMA vault TO postgres WITH GRANT OPTION;
GRANT USAGE ON SCHEMA vault TO service_role;


--
-- Name: FUNCTION email(); Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON FUNCTION auth.email() TO dashboard_user;


--
-- Name: FUNCTION jwt(); Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON FUNCTION auth.jwt() TO postgres;
GRANT ALL ON FUNCTION auth.jwt() TO dashboard_user;


--
-- Name: FUNCTION role(); Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON FUNCTION auth.role() TO dashboard_user;


--
-- Name: FUNCTION uid(); Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON FUNCTION auth.uid() TO dashboard_user;


--
-- Name: FUNCTION armor(bytea); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.armor(bytea) FROM postgres;
GRANT ALL ON FUNCTION extensions.armor(bytea) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.armor(bytea) TO dashboard_user;


--
-- Name: FUNCTION armor(bytea, text[], text[]); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.armor(bytea, text[], text[]) FROM postgres;
GRANT ALL ON FUNCTION extensions.armor(bytea, text[], text[]) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.armor(bytea, text[], text[]) TO dashboard_user;


--
-- Name: FUNCTION crypt(text, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.crypt(text, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.crypt(text, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.crypt(text, text) TO dashboard_user;


--
-- Name: FUNCTION dearmor(text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.dearmor(text) FROM postgres;
GRANT ALL ON FUNCTION extensions.dearmor(text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.dearmor(text) TO dashboard_user;


--
-- Name: FUNCTION decrypt(bytea, bytea, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.decrypt(bytea, bytea, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.decrypt(bytea, bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.decrypt(bytea, bytea, text) TO dashboard_user;


--
-- Name: FUNCTION decrypt_iv(bytea, bytea, bytea, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.decrypt_iv(bytea, bytea, bytea, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.decrypt_iv(bytea, bytea, bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.decrypt_iv(bytea, bytea, bytea, text) TO dashboard_user;


--
-- Name: FUNCTION digest(bytea, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.digest(bytea, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.digest(bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.digest(bytea, text) TO dashboard_user;


--
-- Name: FUNCTION digest(text, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.digest(text, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.digest(text, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.digest(text, text) TO dashboard_user;


--
-- Name: FUNCTION encrypt(bytea, bytea, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.encrypt(bytea, bytea, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.encrypt(bytea, bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.encrypt(bytea, bytea, text) TO dashboard_user;


--
-- Name: FUNCTION encrypt_iv(bytea, bytea, bytea, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.encrypt_iv(bytea, bytea, bytea, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.encrypt_iv(bytea, bytea, bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.encrypt_iv(bytea, bytea, bytea, text) TO dashboard_user;


--
-- Name: FUNCTION gen_random_bytes(integer); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.gen_random_bytes(integer) FROM postgres;
GRANT ALL ON FUNCTION extensions.gen_random_bytes(integer) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.gen_random_bytes(integer) TO dashboard_user;


--
-- Name: FUNCTION gen_random_uuid(); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.gen_random_uuid() FROM postgres;
GRANT ALL ON FUNCTION extensions.gen_random_uuid() TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.gen_random_uuid() TO dashboard_user;


--
-- Name: FUNCTION gen_salt(text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.gen_salt(text) FROM postgres;
GRANT ALL ON FUNCTION extensions.gen_salt(text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.gen_salt(text) TO dashboard_user;


--
-- Name: FUNCTION gen_salt(text, integer); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.gen_salt(text, integer) FROM postgres;
GRANT ALL ON FUNCTION extensions.gen_salt(text, integer) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.gen_salt(text, integer) TO dashboard_user;


--
-- Name: FUNCTION grant_pg_cron_access(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

REVOKE ALL ON FUNCTION extensions.grant_pg_cron_access() FROM supabase_admin;
GRANT ALL ON FUNCTION extensions.grant_pg_cron_access() TO supabase_admin WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.grant_pg_cron_access() TO dashboard_user;


--
-- Name: FUNCTION grant_pg_graphql_access(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.grant_pg_graphql_access() TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION grant_pg_net_access(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

REVOKE ALL ON FUNCTION extensions.grant_pg_net_access() FROM supabase_admin;
GRANT ALL ON FUNCTION extensions.grant_pg_net_access() TO supabase_admin WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.grant_pg_net_access() TO dashboard_user;


--
-- Name: FUNCTION hmac(bytea, bytea, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.hmac(bytea, bytea, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.hmac(bytea, bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.hmac(bytea, bytea, text) TO dashboard_user;


--
-- Name: FUNCTION hmac(text, text, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.hmac(text, text, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.hmac(text, text, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.hmac(text, text, text) TO dashboard_user;


--
-- Name: FUNCTION pg_stat_statements(showtext boolean, OUT userid oid, OUT dbid oid, OUT toplevel boolean, OUT queryid bigint, OUT query text, OUT plans bigint, OUT total_plan_time double precision, OUT min_plan_time double precision, OUT max_plan_time double precision, OUT mean_plan_time double precision, OUT stddev_plan_time double precision, OUT calls bigint, OUT total_exec_time double precision, OUT min_exec_time double precision, OUT max_exec_time double precision, OUT mean_exec_time double precision, OUT stddev_exec_time double precision, OUT rows bigint, OUT shared_blks_hit bigint, OUT shared_blks_read bigint, OUT shared_blks_dirtied bigint, OUT shared_blks_written bigint, OUT local_blks_hit bigint, OUT local_blks_read bigint, OUT local_blks_dirtied bigint, OUT local_blks_written bigint, OUT temp_blks_read bigint, OUT temp_blks_written bigint, OUT shared_blk_read_time double precision, OUT shared_blk_write_time double precision, OUT local_blk_read_time double precision, OUT local_blk_write_time double precision, OUT temp_blk_read_time double precision, OUT temp_blk_write_time double precision, OUT wal_records bigint, OUT wal_fpi bigint, OUT wal_bytes numeric, OUT jit_functions bigint, OUT jit_generation_time double precision, OUT jit_inlining_count bigint, OUT jit_inlining_time double precision, OUT jit_optimization_count bigint, OUT jit_optimization_time double precision, OUT jit_emission_count bigint, OUT jit_emission_time double precision, OUT jit_deform_count bigint, OUT jit_deform_time double precision, OUT stats_since timestamp with time zone, OUT minmax_stats_since timestamp with time zone); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pg_stat_statements(showtext boolean, OUT userid oid, OUT dbid oid, OUT toplevel boolean, OUT queryid bigint, OUT query text, OUT plans bigint, OUT total_plan_time double precision, OUT min_plan_time double precision, OUT max_plan_time double precision, OUT mean_plan_time double precision, OUT stddev_plan_time double precision, OUT calls bigint, OUT total_exec_time double precision, OUT min_exec_time double precision, OUT max_exec_time double precision, OUT mean_exec_time double precision, OUT stddev_exec_time double precision, OUT rows bigint, OUT shared_blks_hit bigint, OUT shared_blks_read bigint, OUT shared_blks_dirtied bigint, OUT shared_blks_written bigint, OUT local_blks_hit bigint, OUT local_blks_read bigint, OUT local_blks_dirtied bigint, OUT local_blks_written bigint, OUT temp_blks_read bigint, OUT temp_blks_written bigint, OUT shared_blk_read_time double precision, OUT shared_blk_write_time double precision, OUT local_blk_read_time double precision, OUT local_blk_write_time double precision, OUT temp_blk_read_time double precision, OUT temp_blk_write_time double precision, OUT wal_records bigint, OUT wal_fpi bigint, OUT wal_bytes numeric, OUT jit_functions bigint, OUT jit_generation_time double precision, OUT jit_inlining_count bigint, OUT jit_inlining_time double precision, OUT jit_optimization_count bigint, OUT jit_optimization_time double precision, OUT jit_emission_count bigint, OUT jit_emission_time double precision, OUT jit_deform_count bigint, OUT jit_deform_time double precision, OUT stats_since timestamp with time zone, OUT minmax_stats_since timestamp with time zone) FROM postgres;
GRANT ALL ON FUNCTION extensions.pg_stat_statements(showtext boolean, OUT userid oid, OUT dbid oid, OUT toplevel boolean, OUT queryid bigint, OUT query text, OUT plans bigint, OUT total_plan_time double precision, OUT min_plan_time double precision, OUT max_plan_time double precision, OUT mean_plan_time double precision, OUT stddev_plan_time double precision, OUT calls bigint, OUT total_exec_time double precision, OUT min_exec_time double precision, OUT max_exec_time double precision, OUT mean_exec_time double precision, OUT stddev_exec_time double precision, OUT rows bigint, OUT shared_blks_hit bigint, OUT shared_blks_read bigint, OUT shared_blks_dirtied bigint, OUT shared_blks_written bigint, OUT local_blks_hit bigint, OUT local_blks_read bigint, OUT local_blks_dirtied bigint, OUT local_blks_written bigint, OUT temp_blks_read bigint, OUT temp_blks_written bigint, OUT shared_blk_read_time double precision, OUT shared_blk_write_time double precision, OUT local_blk_read_time double precision, OUT local_blk_write_time double precision, OUT temp_blk_read_time double precision, OUT temp_blk_write_time double precision, OUT wal_records bigint, OUT wal_fpi bigint, OUT wal_bytes numeric, OUT jit_functions bigint, OUT jit_generation_time double precision, OUT jit_inlining_count bigint, OUT jit_inlining_time double precision, OUT jit_optimization_count bigint, OUT jit_optimization_time double precision, OUT jit_emission_count bigint, OUT jit_emission_time double precision, OUT jit_deform_count bigint, OUT jit_deform_time double precision, OUT stats_since timestamp with time zone, OUT minmax_stats_since timestamp with time zone) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pg_stat_statements(showtext boolean, OUT userid oid, OUT dbid oid, OUT toplevel boolean, OUT queryid bigint, OUT query text, OUT plans bigint, OUT total_plan_time double precision, OUT min_plan_time double precision, OUT max_plan_time double precision, OUT mean_plan_time double precision, OUT stddev_plan_time double precision, OUT calls bigint, OUT total_exec_time double precision, OUT min_exec_time double precision, OUT max_exec_time double precision, OUT mean_exec_time double precision, OUT stddev_exec_time double precision, OUT rows bigint, OUT shared_blks_hit bigint, OUT shared_blks_read bigint, OUT shared_blks_dirtied bigint, OUT shared_blks_written bigint, OUT local_blks_hit bigint, OUT local_blks_read bigint, OUT local_blks_dirtied bigint, OUT local_blks_written bigint, OUT temp_blks_read bigint, OUT temp_blks_written bigint, OUT shared_blk_read_time double precision, OUT shared_blk_write_time double precision, OUT local_blk_read_time double precision, OUT local_blk_write_time double precision, OUT temp_blk_read_time double precision, OUT temp_blk_write_time double precision, OUT wal_records bigint, OUT wal_fpi bigint, OUT wal_bytes numeric, OUT jit_functions bigint, OUT jit_generation_time double precision, OUT jit_inlining_count bigint, OUT jit_inlining_time double precision, OUT jit_optimization_count bigint, OUT jit_optimization_time double precision, OUT jit_emission_count bigint, OUT jit_emission_time double precision, OUT jit_deform_count bigint, OUT jit_deform_time double precision, OUT stats_since timestamp with time zone, OUT minmax_stats_since timestamp with time zone) TO dashboard_user;


--
-- Name: FUNCTION pg_stat_statements_info(OUT dealloc bigint, OUT stats_reset timestamp with time zone); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pg_stat_statements_info(OUT dealloc bigint, OUT stats_reset timestamp with time zone) FROM postgres;
GRANT ALL ON FUNCTION extensions.pg_stat_statements_info(OUT dealloc bigint, OUT stats_reset timestamp with time zone) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pg_stat_statements_info(OUT dealloc bigint, OUT stats_reset timestamp with time zone) TO dashboard_user;


--
-- Name: FUNCTION pg_stat_statements_reset(userid oid, dbid oid, queryid bigint, minmax_only boolean); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pg_stat_statements_reset(userid oid, dbid oid, queryid bigint, minmax_only boolean) FROM postgres;
GRANT ALL ON FUNCTION extensions.pg_stat_statements_reset(userid oid, dbid oid, queryid bigint, minmax_only boolean) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pg_stat_statements_reset(userid oid, dbid oid, queryid bigint, minmax_only boolean) TO dashboard_user;


--
-- Name: FUNCTION pgp_armor_headers(text, OUT key text, OUT value text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_armor_headers(text, OUT key text, OUT value text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_armor_headers(text, OUT key text, OUT value text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_armor_headers(text, OUT key text, OUT value text) TO dashboard_user;


--
-- Name: FUNCTION pgp_key_id(bytea); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_key_id(bytea) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_key_id(bytea) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_key_id(bytea) TO dashboard_user;


--
-- Name: FUNCTION pgp_pub_decrypt(bytea, bytea); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea) TO dashboard_user;


--
-- Name: FUNCTION pgp_pub_decrypt(bytea, bytea, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea, text) TO dashboard_user;


--
-- Name: FUNCTION pgp_pub_decrypt(bytea, bytea, text, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea, text, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea, text, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea, text, text) TO dashboard_user;


--
-- Name: FUNCTION pgp_pub_decrypt_bytea(bytea, bytea); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea) TO dashboard_user;


--
-- Name: FUNCTION pgp_pub_decrypt_bytea(bytea, bytea, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea, text) TO dashboard_user;


--
-- Name: FUNCTION pgp_pub_decrypt_bytea(bytea, bytea, text, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea, text, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea, text, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea, text, text) TO dashboard_user;


--
-- Name: FUNCTION pgp_pub_encrypt(text, bytea); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_pub_encrypt(text, bytea) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt(text, bytea) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt(text, bytea) TO dashboard_user;


--
-- Name: FUNCTION pgp_pub_encrypt(text, bytea, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_pub_encrypt(text, bytea, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt(text, bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt(text, bytea, text) TO dashboard_user;


--
-- Name: FUNCTION pgp_pub_encrypt_bytea(bytea, bytea); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_pub_encrypt_bytea(bytea, bytea) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt_bytea(bytea, bytea) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt_bytea(bytea, bytea) TO dashboard_user;


--
-- Name: FUNCTION pgp_pub_encrypt_bytea(bytea, bytea, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_pub_encrypt_bytea(bytea, bytea, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt_bytea(bytea, bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt_bytea(bytea, bytea, text) TO dashboard_user;


--
-- Name: FUNCTION pgp_sym_decrypt(bytea, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_sym_decrypt(bytea, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt(bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt(bytea, text) TO dashboard_user;


--
-- Name: FUNCTION pgp_sym_decrypt(bytea, text, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_sym_decrypt(bytea, text, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt(bytea, text, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt(bytea, text, text) TO dashboard_user;


--
-- Name: FUNCTION pgp_sym_decrypt_bytea(bytea, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_sym_decrypt_bytea(bytea, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt_bytea(bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt_bytea(bytea, text) TO dashboard_user;


--
-- Name: FUNCTION pgp_sym_decrypt_bytea(bytea, text, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_sym_decrypt_bytea(bytea, text, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt_bytea(bytea, text, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt_bytea(bytea, text, text) TO dashboard_user;


--
-- Name: FUNCTION pgp_sym_encrypt(text, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_sym_encrypt(text, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt(text, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt(text, text) TO dashboard_user;


--
-- Name: FUNCTION pgp_sym_encrypt(text, text, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_sym_encrypt(text, text, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt(text, text, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt(text, text, text) TO dashboard_user;


--
-- Name: FUNCTION pgp_sym_encrypt_bytea(bytea, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_sym_encrypt_bytea(bytea, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt_bytea(bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt_bytea(bytea, text) TO dashboard_user;


--
-- Name: FUNCTION pgp_sym_encrypt_bytea(bytea, text, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_sym_encrypt_bytea(bytea, text, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt_bytea(bytea, text, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt_bytea(bytea, text, text) TO dashboard_user;


--
-- Name: FUNCTION pgrst_ddl_watch(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgrst_ddl_watch() TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION pgrst_drop_watch(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgrst_drop_watch() TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION set_graphql_placeholder(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.set_graphql_placeholder() TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION uuid_generate_v1(); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.uuid_generate_v1() FROM postgres;
GRANT ALL ON FUNCTION extensions.uuid_generate_v1() TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.uuid_generate_v1() TO dashboard_user;


--
-- Name: FUNCTION uuid_generate_v1mc(); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.uuid_generate_v1mc() FROM postgres;
GRANT ALL ON FUNCTION extensions.uuid_generate_v1mc() TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.uuid_generate_v1mc() TO dashboard_user;


--
-- Name: FUNCTION uuid_generate_v3(namespace uuid, name text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.uuid_generate_v3(namespace uuid, name text) FROM postgres;
GRANT ALL ON FUNCTION extensions.uuid_generate_v3(namespace uuid, name text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.uuid_generate_v3(namespace uuid, name text) TO dashboard_user;


--
-- Name: FUNCTION uuid_generate_v4(); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.uuid_generate_v4() FROM postgres;
GRANT ALL ON FUNCTION extensions.uuid_generate_v4() TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.uuid_generate_v4() TO dashboard_user;


--
-- Name: FUNCTION uuid_generate_v5(namespace uuid, name text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.uuid_generate_v5(namespace uuid, name text) FROM postgres;
GRANT ALL ON FUNCTION extensions.uuid_generate_v5(namespace uuid, name text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.uuid_generate_v5(namespace uuid, name text) TO dashboard_user;


--
-- Name: FUNCTION uuid_nil(); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.uuid_nil() FROM postgres;
GRANT ALL ON FUNCTION extensions.uuid_nil() TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.uuid_nil() TO dashboard_user;


--
-- Name: FUNCTION uuid_ns_dns(); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.uuid_ns_dns() FROM postgres;
GRANT ALL ON FUNCTION extensions.uuid_ns_dns() TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.uuid_ns_dns() TO dashboard_user;


--
-- Name: FUNCTION uuid_ns_oid(); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.uuid_ns_oid() FROM postgres;
GRANT ALL ON FUNCTION extensions.uuid_ns_oid() TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.uuid_ns_oid() TO dashboard_user;


--
-- Name: FUNCTION uuid_ns_url(); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.uuid_ns_url() FROM postgres;
GRANT ALL ON FUNCTION extensions.uuid_ns_url() TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.uuid_ns_url() TO dashboard_user;


--
-- Name: FUNCTION uuid_ns_x500(); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.uuid_ns_x500() FROM postgres;
GRANT ALL ON FUNCTION extensions.uuid_ns_x500() TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.uuid_ns_x500() TO dashboard_user;


--
-- Name: FUNCTION graphql("operationName" text, query text, variables jsonb, extensions jsonb); Type: ACL; Schema: graphql_public; Owner: supabase_admin
--

GRANT ALL ON FUNCTION graphql_public.graphql("operationName" text, query text, variables jsonb, extensions jsonb) TO postgres;
GRANT ALL ON FUNCTION graphql_public.graphql("operationName" text, query text, variables jsonb, extensions jsonb) TO anon;
GRANT ALL ON FUNCTION graphql_public.graphql("operationName" text, query text, variables jsonb, extensions jsonb) TO authenticated;
GRANT ALL ON FUNCTION graphql_public.graphql("operationName" text, query text, variables jsonb, extensions jsonb) TO service_role;


--
-- Name: FUNCTION get_auth(p_usename text); Type: ACL; Schema: pgbouncer; Owner: supabase_admin
--

REVOKE ALL ON FUNCTION pgbouncer.get_auth(p_usename text) FROM PUBLIC;
GRANT ALL ON FUNCTION pgbouncer.get_auth(p_usename text) TO pgbouncer;
GRANT ALL ON FUNCTION pgbouncer.get_auth(p_usename text) TO postgres;


--
-- Name: FUNCTION apply_rls(wal jsonb, max_record_bytes integer); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer) TO postgres;
GRANT ALL ON FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer) TO dashboard_user;
GRANT ALL ON FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer) TO anon;
GRANT ALL ON FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer) TO authenticated;
GRANT ALL ON FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer) TO service_role;
GRANT ALL ON FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer) TO supabase_realtime_admin;


--
-- Name: FUNCTION broadcast_changes(topic_name text, event_name text, operation text, table_name text, table_schema text, new record, old record, level text); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.broadcast_changes(topic_name text, event_name text, operation text, table_name text, table_schema text, new record, old record, level text) TO postgres;
GRANT ALL ON FUNCTION realtime.broadcast_changes(topic_name text, event_name text, operation text, table_name text, table_schema text, new record, old record, level text) TO dashboard_user;


--
-- Name: FUNCTION build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) TO postgres;
GRANT ALL ON FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) TO dashboard_user;
GRANT ALL ON FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) TO anon;
GRANT ALL ON FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) TO authenticated;
GRANT ALL ON FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) TO service_role;
GRANT ALL ON FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) TO supabase_realtime_admin;


--
-- Name: FUNCTION "cast"(val text, type_ regtype); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime."cast"(val text, type_ regtype) TO postgres;
GRANT ALL ON FUNCTION realtime."cast"(val text, type_ regtype) TO dashboard_user;
GRANT ALL ON FUNCTION realtime."cast"(val text, type_ regtype) TO anon;
GRANT ALL ON FUNCTION realtime."cast"(val text, type_ regtype) TO authenticated;
GRANT ALL ON FUNCTION realtime."cast"(val text, type_ regtype) TO service_role;
GRANT ALL ON FUNCTION realtime."cast"(val text, type_ regtype) TO supabase_realtime_admin;


--
-- Name: FUNCTION check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) TO postgres;
GRANT ALL ON FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) TO dashboard_user;
GRANT ALL ON FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) TO anon;
GRANT ALL ON FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) TO authenticated;
GRANT ALL ON FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) TO service_role;
GRANT ALL ON FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) TO supabase_realtime_admin;


--
-- Name: FUNCTION is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) TO postgres;
GRANT ALL ON FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) TO dashboard_user;
GRANT ALL ON FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) TO anon;
GRANT ALL ON FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) TO authenticated;
GRANT ALL ON FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) TO service_role;
GRANT ALL ON FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) TO supabase_realtime_admin;


--
-- Name: FUNCTION list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) TO postgres;
GRANT ALL ON FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) TO dashboard_user;
GRANT ALL ON FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) TO anon;
GRANT ALL ON FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) TO authenticated;
GRANT ALL ON FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) TO service_role;
GRANT ALL ON FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) TO supabase_realtime_admin;


--
-- Name: FUNCTION quote_wal2json(entity regclass); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.quote_wal2json(entity regclass) TO postgres;
GRANT ALL ON FUNCTION realtime.quote_wal2json(entity regclass) TO dashboard_user;
GRANT ALL ON FUNCTION realtime.quote_wal2json(entity regclass) TO anon;
GRANT ALL ON FUNCTION realtime.quote_wal2json(entity regclass) TO authenticated;
GRANT ALL ON FUNCTION realtime.quote_wal2json(entity regclass) TO service_role;
GRANT ALL ON FUNCTION realtime.quote_wal2json(entity regclass) TO supabase_realtime_admin;


--
-- Name: FUNCTION send(payload jsonb, event text, topic text, private boolean); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.send(payload jsonb, event text, topic text, private boolean) TO postgres;
GRANT ALL ON FUNCTION realtime.send(payload jsonb, event text, topic text, private boolean) TO dashboard_user;


--
-- Name: FUNCTION subscription_check_filters(); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.subscription_check_filters() TO postgres;
GRANT ALL ON FUNCTION realtime.subscription_check_filters() TO dashboard_user;
GRANT ALL ON FUNCTION realtime.subscription_check_filters() TO anon;
GRANT ALL ON FUNCTION realtime.subscription_check_filters() TO authenticated;
GRANT ALL ON FUNCTION realtime.subscription_check_filters() TO service_role;
GRANT ALL ON FUNCTION realtime.subscription_check_filters() TO supabase_realtime_admin;


--
-- Name: FUNCTION to_regrole(role_name text); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.to_regrole(role_name text) TO postgres;
GRANT ALL ON FUNCTION realtime.to_regrole(role_name text) TO dashboard_user;
GRANT ALL ON FUNCTION realtime.to_regrole(role_name text) TO anon;
GRANT ALL ON FUNCTION realtime.to_regrole(role_name text) TO authenticated;
GRANT ALL ON FUNCTION realtime.to_regrole(role_name text) TO service_role;
GRANT ALL ON FUNCTION realtime.to_regrole(role_name text) TO supabase_realtime_admin;


--
-- Name: FUNCTION topic(); Type: ACL; Schema: realtime; Owner: supabase_realtime_admin
--

GRANT ALL ON FUNCTION realtime.topic() TO postgres;
GRANT ALL ON FUNCTION realtime.topic() TO dashboard_user;


--
-- Name: FUNCTION _crypto_aead_det_decrypt(message bytea, additional bytea, key_id bigint, context bytea, nonce bytea); Type: ACL; Schema: vault; Owner: supabase_admin
--

GRANT ALL ON FUNCTION vault._crypto_aead_det_decrypt(message bytea, additional bytea, key_id bigint, context bytea, nonce bytea) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION vault._crypto_aead_det_decrypt(message bytea, additional bytea, key_id bigint, context bytea, nonce bytea) TO service_role;


--
-- Name: FUNCTION create_secret(new_secret text, new_name text, new_description text, new_key_id uuid); Type: ACL; Schema: vault; Owner: supabase_admin
--

GRANT ALL ON FUNCTION vault.create_secret(new_secret text, new_name text, new_description text, new_key_id uuid) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION vault.create_secret(new_secret text, new_name text, new_description text, new_key_id uuid) TO service_role;


--
-- Name: FUNCTION update_secret(secret_id uuid, new_secret text, new_name text, new_description text, new_key_id uuid); Type: ACL; Schema: vault; Owner: supabase_admin
--

GRANT ALL ON FUNCTION vault.update_secret(secret_id uuid, new_secret text, new_name text, new_description text, new_key_id uuid) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION vault.update_secret(secret_id uuid, new_secret text, new_name text, new_description text, new_key_id uuid) TO service_role;


--
-- Name: TABLE audit_log_entries; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE auth.audit_log_entries TO dashboard_user;
GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.audit_log_entries TO postgres;
GRANT SELECT ON TABLE auth.audit_log_entries TO postgres WITH GRANT OPTION;


--
-- Name: TABLE flow_state; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.flow_state TO postgres;
GRANT SELECT ON TABLE auth.flow_state TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.flow_state TO dashboard_user;


--
-- Name: TABLE identities; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.identities TO postgres;
GRANT SELECT ON TABLE auth.identities TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.identities TO dashboard_user;


--
-- Name: TABLE instances; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE auth.instances TO dashboard_user;
GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.instances TO postgres;
GRANT SELECT ON TABLE auth.instances TO postgres WITH GRANT OPTION;


--
-- Name: TABLE mfa_amr_claims; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.mfa_amr_claims TO postgres;
GRANT SELECT ON TABLE auth.mfa_amr_claims TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.mfa_amr_claims TO dashboard_user;


--
-- Name: TABLE mfa_challenges; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.mfa_challenges TO postgres;
GRANT SELECT ON TABLE auth.mfa_challenges TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.mfa_challenges TO dashboard_user;


--
-- Name: TABLE mfa_factors; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.mfa_factors TO postgres;
GRANT SELECT ON TABLE auth.mfa_factors TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.mfa_factors TO dashboard_user;


--
-- Name: TABLE oauth_authorizations; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE auth.oauth_authorizations TO postgres;
GRANT ALL ON TABLE auth.oauth_authorizations TO dashboard_user;


--
-- Name: TABLE oauth_clients; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE auth.oauth_clients TO postgres;
GRANT ALL ON TABLE auth.oauth_clients TO dashboard_user;


--
-- Name: TABLE oauth_consents; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE auth.oauth_consents TO postgres;
GRANT ALL ON TABLE auth.oauth_consents TO dashboard_user;


--
-- Name: TABLE one_time_tokens; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.one_time_tokens TO postgres;
GRANT SELECT ON TABLE auth.one_time_tokens TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.one_time_tokens TO dashboard_user;


--
-- Name: TABLE refresh_tokens; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE auth.refresh_tokens TO dashboard_user;
GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.refresh_tokens TO postgres;
GRANT SELECT ON TABLE auth.refresh_tokens TO postgres WITH GRANT OPTION;


--
-- Name: SEQUENCE refresh_tokens_id_seq; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON SEQUENCE auth.refresh_tokens_id_seq TO dashboard_user;
GRANT ALL ON SEQUENCE auth.refresh_tokens_id_seq TO postgres;


--
-- Name: TABLE saml_providers; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.saml_providers TO postgres;
GRANT SELECT ON TABLE auth.saml_providers TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.saml_providers TO dashboard_user;


--
-- Name: TABLE saml_relay_states; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.saml_relay_states TO postgres;
GRANT SELECT ON TABLE auth.saml_relay_states TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.saml_relay_states TO dashboard_user;


--
-- Name: TABLE schema_migrations; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT SELECT ON TABLE auth.schema_migrations TO postgres WITH GRANT OPTION;


--
-- Name: TABLE sessions; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.sessions TO postgres;
GRANT SELECT ON TABLE auth.sessions TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.sessions TO dashboard_user;


--
-- Name: TABLE sso_domains; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.sso_domains TO postgres;
GRANT SELECT ON TABLE auth.sso_domains TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.sso_domains TO dashboard_user;


--
-- Name: TABLE sso_providers; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.sso_providers TO postgres;
GRANT SELECT ON TABLE auth.sso_providers TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.sso_providers TO dashboard_user;


--
-- Name: TABLE users; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE auth.users TO dashboard_user;
GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.users TO postgres;
GRANT SELECT ON TABLE auth.users TO postgres WITH GRANT OPTION;


--
-- Name: TABLE pg_stat_statements; Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON TABLE extensions.pg_stat_statements FROM postgres;
GRANT ALL ON TABLE extensions.pg_stat_statements TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE extensions.pg_stat_statements TO dashboard_user;


--
-- Name: TABLE pg_stat_statements_info; Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON TABLE extensions.pg_stat_statements_info FROM postgres;
GRANT ALL ON TABLE extensions.pg_stat_statements_info TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE extensions.pg_stat_statements_info TO dashboard_user;


--
-- Name: TABLE messages; Type: ACL; Schema: realtime; Owner: supabase_realtime_admin
--

GRANT ALL ON TABLE realtime.messages TO postgres;
GRANT ALL ON TABLE realtime.messages TO dashboard_user;
GRANT SELECT,INSERT,UPDATE ON TABLE realtime.messages TO anon;
GRANT SELECT,INSERT,UPDATE ON TABLE realtime.messages TO authenticated;
GRANT SELECT,INSERT,UPDATE ON TABLE realtime.messages TO service_role;


--
-- Name: TABLE schema_migrations; Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON TABLE realtime.schema_migrations TO postgres;
GRANT ALL ON TABLE realtime.schema_migrations TO dashboard_user;
GRANT SELECT ON TABLE realtime.schema_migrations TO anon;
GRANT SELECT ON TABLE realtime.schema_migrations TO authenticated;
GRANT SELECT ON TABLE realtime.schema_migrations TO service_role;
GRANT ALL ON TABLE realtime.schema_migrations TO supabase_realtime_admin;


--
-- Name: TABLE subscription; Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON TABLE realtime.subscription TO postgres;
GRANT ALL ON TABLE realtime.subscription TO dashboard_user;
GRANT SELECT ON TABLE realtime.subscription TO anon;
GRANT SELECT ON TABLE realtime.subscription TO authenticated;
GRANT SELECT ON TABLE realtime.subscription TO service_role;
GRANT ALL ON TABLE realtime.subscription TO supabase_realtime_admin;


--
-- Name: SEQUENCE subscription_id_seq; Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON SEQUENCE realtime.subscription_id_seq TO postgres;
GRANT ALL ON SEQUENCE realtime.subscription_id_seq TO dashboard_user;
GRANT USAGE ON SEQUENCE realtime.subscription_id_seq TO anon;
GRANT USAGE ON SEQUENCE realtime.subscription_id_seq TO authenticated;
GRANT USAGE ON SEQUENCE realtime.subscription_id_seq TO service_role;
GRANT ALL ON SEQUENCE realtime.subscription_id_seq TO supabase_realtime_admin;


--
-- Name: TABLE buckets; Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT ALL ON TABLE storage.buckets TO anon;
GRANT ALL ON TABLE storage.buckets TO authenticated;
GRANT ALL ON TABLE storage.buckets TO service_role;
GRANT ALL ON TABLE storage.buckets TO postgres WITH GRANT OPTION;


--
-- Name: TABLE buckets_analytics; Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT ALL ON TABLE storage.buckets_analytics TO service_role;
GRANT ALL ON TABLE storage.buckets_analytics TO authenticated;
GRANT ALL ON TABLE storage.buckets_analytics TO anon;


--
-- Name: TABLE objects; Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT ALL ON TABLE storage.objects TO anon;
GRANT ALL ON TABLE storage.objects TO authenticated;
GRANT ALL ON TABLE storage.objects TO service_role;
GRANT ALL ON TABLE storage.objects TO postgres WITH GRANT OPTION;


--
-- Name: TABLE prefixes; Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT ALL ON TABLE storage.prefixes TO service_role;
GRANT ALL ON TABLE storage.prefixes TO authenticated;
GRANT ALL ON TABLE storage.prefixes TO anon;


--
-- Name: TABLE s3_multipart_uploads; Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT ALL ON TABLE storage.s3_multipart_uploads TO service_role;
GRANT SELECT ON TABLE storage.s3_multipart_uploads TO authenticated;
GRANT SELECT ON TABLE storage.s3_multipart_uploads TO anon;


--
-- Name: TABLE s3_multipart_uploads_parts; Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT ALL ON TABLE storage.s3_multipart_uploads_parts TO service_role;
GRANT SELECT ON TABLE storage.s3_multipart_uploads_parts TO authenticated;
GRANT SELECT ON TABLE storage.s3_multipart_uploads_parts TO anon;


--
-- Name: TABLE secrets; Type: ACL; Schema: vault; Owner: supabase_admin
--

GRANT SELECT,REFERENCES,DELETE,TRUNCATE ON TABLE vault.secrets TO postgres WITH GRANT OPTION;
GRANT SELECT,DELETE ON TABLE vault.secrets TO service_role;


--
-- Name: TABLE decrypted_secrets; Type: ACL; Schema: vault; Owner: supabase_admin
--

GRANT SELECT,REFERENCES,DELETE,TRUNCATE ON TABLE vault.decrypted_secrets TO postgres WITH GRANT OPTION;
GRANT SELECT,DELETE ON TABLE vault.decrypted_secrets TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: auth; Owner: supabase_auth_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_auth_admin IN SCHEMA auth GRANT ALL ON SEQUENCES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_auth_admin IN SCHEMA auth GRANT ALL ON SEQUENCES TO dashboard_user;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: auth; Owner: supabase_auth_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_auth_admin IN SCHEMA auth GRANT ALL ON FUNCTIONS TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_auth_admin IN SCHEMA auth GRANT ALL ON FUNCTIONS TO dashboard_user;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: auth; Owner: supabase_auth_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_auth_admin IN SCHEMA auth GRANT ALL ON TABLES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_auth_admin IN SCHEMA auth GRANT ALL ON TABLES TO dashboard_user;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: extensions; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA extensions GRANT ALL ON SEQUENCES TO postgres WITH GRANT OPTION;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: extensions; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA extensions GRANT ALL ON FUNCTIONS TO postgres WITH GRANT OPTION;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: extensions; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA extensions GRANT ALL ON TABLES TO postgres WITH GRANT OPTION;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: graphql; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON SEQUENCES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON SEQUENCES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON SEQUENCES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON SEQUENCES TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: graphql; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON FUNCTIONS TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON FUNCTIONS TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON FUNCTIONS TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON FUNCTIONS TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: graphql; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON TABLES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON TABLES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON TABLES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON TABLES TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: graphql_public; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON SEQUENCES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON SEQUENCES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON SEQUENCES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON SEQUENCES TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: graphql_public; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON FUNCTIONS TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON FUNCTIONS TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON FUNCTIONS TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON FUNCTIONS TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: graphql_public; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON TABLES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON TABLES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON TABLES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON TABLES TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: realtime; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA realtime GRANT ALL ON SEQUENCES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA realtime GRANT ALL ON SEQUENCES TO dashboard_user;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: realtime; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA realtime GRANT ALL ON FUNCTIONS TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA realtime GRANT ALL ON FUNCTIONS TO dashboard_user;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: realtime; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA realtime GRANT ALL ON TABLES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA realtime GRANT ALL ON TABLES TO dashboard_user;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: storage; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON SEQUENCES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON SEQUENCES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON SEQUENCES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON SEQUENCES TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: storage; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON FUNCTIONS TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON FUNCTIONS TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON FUNCTIONS TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON FUNCTIONS TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: storage; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON TABLES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON TABLES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON TABLES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON TABLES TO service_role;


--
-- Name: issue_graphql_placeholder; Type: EVENT TRIGGER; Schema: -; Owner: supabase_admin
--




ALTER EVENT TRIGGER issue_graphql_placeholder OWNER TO supabase_admin;

--
-- Name: issue_pg_cron_access; Type: EVENT TRIGGER; Schema: -; Owner: supabase_admin
--




ALTER EVENT TRIGGER issue_pg_cron_access OWNER TO supabase_admin;

--
-- Name: issue_pg_graphql_access; Type: EVENT TRIGGER; Schema: -; Owner: supabase_admin
--




ALTER EVENT TRIGGER issue_pg_graphql_access OWNER TO supabase_admin;

--
-- Name: issue_pg_net_access; Type: EVENT TRIGGER; Schema: -; Owner: supabase_admin
--




ALTER EVENT TRIGGER issue_pg_net_access OWNER TO supabase_admin;

--
-- Name: pgrst_ddl_watch; Type: EVENT TRIGGER; Schema: -; Owner: supabase_admin
--




ALTER EVENT TRIGGER pgrst_ddl_watch OWNER TO supabase_admin;

--
-- Name: pgrst_drop_watch; Type: EVENT TRIGGER; Schema: -; Owner: supabase_admin
--




ALTER EVENT TRIGGER pgrst_drop_watch OWNER TO supabase_admin;

--
-- PostgreSQL database dump complete
--

\unrestrict n5fjB13iII5giFs6NfjdnnxfNDWXfILE825eAnf3RNOvi6zpGV9jxCVSSFJHmeu

