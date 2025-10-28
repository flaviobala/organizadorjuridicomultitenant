-- RESET COMPLETO DO BANCO DE DADOS
-- Este script destrói TODOS os dados e recria as tabelas

-- Desabilitar foreign keys temporariamente
SET session_replication_role = 'replica';

-- Dropar todas as tabelas
DROP TABLE IF EXISTS api_usage CASCADE;
DROP TABLE IF EXISTS document_validations CASCADE;
DROP TABLE IF EXISTS documents CASCADE;
DROP TABLE IF EXISTS projects CASCADE;
DROP TABLE IF EXISTS users CASCADE;
DROP TABLE IF EXISTS organizations CASCADE;
DROP TABLE IF EXISTS action_types CASCADE;
DROP TABLE IF EXISTS document_types CASCADE;
DROP TABLE IF EXISTS system_configurations CASCADE;

-- Dropar tipos ENUM
DROP TYPE IF EXISTS "PlanType" CASCADE;
DROP TYPE IF EXISTS "SubscriptionStatus" CASCADE;

-- Reabilitar foreign keys
SET session_replication_role = 'origin';

-- Criar ENUM types
CREATE TYPE "PlanType" AS ENUM ('basic', 'pro', 'enterprise', 'trialing');
CREATE TYPE "SubscriptionStatus" AS ENUM ('active', 'past_due', 'canceled', 'trialing');

-- Criar tabela organizations
CREATE TABLE organizations (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    plan_type "PlanType" NOT NULL DEFAULT 'trialing',
    subscription_status "SubscriptionStatus" NOT NULL DEFAULT 'trialing',
    document_processed_count INTEGER NOT NULL DEFAULT 0,
    ai_token_count INTEGER NOT NULL DEFAULT 0,
    stripe_customer_id VARCHAR(255) UNIQUE,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Criar tabela users
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    name VARCHAR(255) NOT NULL,
    auth_user_id UUID UNIQUE,
    "organizationId" INTEGER NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    FOREIGN KEY ("organizationId") REFERENCES organizations(id) ON DELETE CASCADE
);

CREATE INDEX users_organization_id_idx ON users("organizationId");

-- Criar tabela projects
CREATE TABLE projects (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    name VARCHAR(255) NOT NULL,
    client VARCHAR(255) NOT NULL,
    system VARCHAR(255) NOT NULL,
    action_type VARCHAR(255) NOT NULL,
    narrative TEXT,
    processed_narrative TEXT,
    status VARCHAR(50) NOT NULL DEFAULT 'draft',
    "organizationId" INTEGER NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE NO ACTION,
    FOREIGN KEY ("organizationId") REFERENCES organizations(id) ON DELETE CASCADE
);

CREATE INDEX projects_user_id_idx ON projects(user_id);
CREATE INDEX projects_organization_id_idx ON projects("organizationId");

-- Criar tabela documents
CREATE TABLE documents (
    id SERIAL PRIMARY KEY,
    project_id INTEGER NOT NULL,
    user_id INTEGER NOT NULL,
    original_filename VARCHAR(255) NOT NULL,
    stored_filename VARCHAR(255) NOT NULL,
    smart_filename VARCHAR(255),
    document_type VARCHAR(255) NOT NULL,
    detected_document_type VARCHAR(255),
    document_number INTEGER NOT NULL,
    mime_type VARCHAR(255) NOT NULL,
    original_size_bytes INTEGER NOT NULL,
    is_personal_document BOOLEAN NOT NULL DEFAULT false,
    is_grouped BOOLEAN NOT NULL DEFAULT false,
    grouped_at TIMESTAMP,
    status VARCHAR(50) NOT NULL DEFAULT 'uploaded',
    pdf_path VARCHAR(500),
    ocr_text TEXT,
    pdf_size_bytes INTEGER,
    page_count INTEGER,
    page_size VARCHAR(50),
    ai_analysis TEXT,
    analysis_confidence DOUBLE PRECISION,
    "organizationId" INTEGER NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE NO ACTION,
    FOREIGN KEY ("organizationId") REFERENCES organizations(id) ON DELETE CASCADE
);

CREATE INDEX documents_project_id_idx ON documents(project_id);
CREATE INDEX documents_user_id_idx ON documents(user_id);
CREATE INDEX documents_organization_id_idx ON documents("organizationId");

-- Criar tabela document_validations
CREATE TABLE document_validations (
    id SERIAL PRIMARY KEY,
    project_id INTEGER NOT NULL,
    document_id INTEGER NOT NULL UNIQUE,
    is_relevant BOOLEAN NOT NULL,
    relevance_score DOUBLE PRECISION NOT NULL,
    ai_analysis TEXT NOT NULL,
    suggestions TEXT,
    status VARCHAR(50) NOT NULL DEFAULT 'pending',
    reviewed_at TIMESTAMP,
    "organizationId" INTEGER NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE,
    FOREIGN KEY (document_id) REFERENCES documents(id) ON DELETE CASCADE,
    FOREIGN KEY ("organizationId") REFERENCES organizations(id) ON DELETE CASCADE
);

CREATE INDEX document_validations_project_id_idx ON document_validations(project_id);
CREATE INDEX document_validations_organization_id_idx ON document_validations("organizationId");

-- Criar tabela api_usage
CREATE TABLE api_usage (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    organization_id INTEGER NOT NULL,
    project_id INTEGER,
    document_id INTEGER,
    service VARCHAR(255) NOT NULL,
    operation VARCHAR(255) NOT NULL,
    model VARCHAR(255),
    tokens_input INTEGER NOT NULL,
    tokens_output INTEGER NOT NULL,
    tokens_total INTEGER NOT NULL,
    cost_brl DOUBLE PRECISION NOT NULL,
    method VARCHAR(255) NOT NULL,
    success BOOLEAN NOT NULL DEFAULT true,
    error_message TEXT,
    date TIMESTAMP NOT NULL DEFAULT NOW(),
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (organization_id) REFERENCES organizations(id) ON DELETE CASCADE
);

CREATE INDEX api_usage_user_id_idx ON api_usage(user_id);
CREATE INDEX api_usage_organization_id_idx ON api_usage(organization_id);
CREATE INDEX api_usage_date_idx ON api_usage(date);
CREATE INDEX api_usage_service_idx ON api_usage(service);

-- Criar tabelas globais
CREATE TABLE system_configurations (
    id SERIAL PRIMARY KEY,
    system_name VARCHAR(255) UNIQUE NOT NULL,
    max_file_size INTEGER NOT NULL,
    max_page_size INTEGER NOT NULL,
    allowed_formats VARCHAR(255) NOT NULL,
    pdf_requirements TEXT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE document_types (
    id SERIAL PRIMARY KEY,
    code VARCHAR(255) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    is_required BOOLEAN NOT NULL DEFAULT false,
    "order" INTEGER NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE action_types (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) UNIQUE NOT NULL,
    description TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

SELECT 'Database reset completed successfully!' as status;
