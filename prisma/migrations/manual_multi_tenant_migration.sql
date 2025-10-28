-- Manual Migration for Multi-Tenant
-- This script handles existing data and adds organizationId to all tables

BEGIN;

-- 1. Criar uma organização padrão para dados existentes
INSERT INTO organizations (name, plan_type, subscription_status, document_processed_count, ai_token_count, created_at, updated_at)
VALUES ('Default Organization', 'trialing', 'trialing', 0, 0, NOW(), NOW())
ON CONFLICT DO NOTHING;

-- Obter o ID da organização padrão
DO $$
DECLARE
    default_org_id INT;
BEGIN
    SELECT id INTO default_org_id FROM organizations WHERE name = 'Default Organization' LIMIT 1;

    -- 2. Adicionar coluna organizationId aos users (se não existir)
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'users' AND column_name = 'organizationId') THEN
        ALTER TABLE users ADD COLUMN "organizationId" INTEGER;

        -- Atualizar usuários existentes com a organização padrão
        UPDATE users SET "organizationId" = default_org_id WHERE "organizationId" IS NULL;

        -- Tornar a coluna obrigatória
        ALTER TABLE users ALTER COLUMN "organizationId" SET NOT NULL;

        -- Adicionar foreign key
        ALTER TABLE users ADD CONSTRAINT users_organization_fk
            FOREIGN KEY ("organizationId") REFERENCES organizations(id) ON DELETE CASCADE;

        -- Adicionar índice
        CREATE INDEX IF NOT EXISTS users_organization_id_idx ON users("organizationId");
    END IF;

    -- 3. Adicionar coluna organizationId aos projects (se não existir)
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'projects' AND column_name = 'organizationId') THEN
        ALTER TABLE projects ADD COLUMN "organizationId" INTEGER;

        -- Atualizar projetos existentes com a organização padrão
        UPDATE projects SET "organizationId" = default_org_id WHERE "organizationId" IS NULL;

        -- Tornar a coluna obrigatória
        ALTER TABLE projects ALTER COLUMN "organizationId" SET NOT NULL;

        -- Adicionar foreign key
        ALTER TABLE projects ADD CONSTRAINT projects_organization_fk
            FOREIGN KEY ("organizationId") REFERENCES organizations(id) ON DELETE CASCADE;

        -- Adicionar índice
        CREATE INDEX IF NOT EXISTS projects_organization_id_idx ON projects("organizationId");
    END IF;

    -- 4. Adicionar coluna organizationId aos documents (se não existir)
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'documents' AND column_name = 'organizationId') THEN
        ALTER TABLE documents ADD COLUMN "organizationId" INTEGER;

        -- Atualizar documentos existentes com a organização padrão
        UPDATE documents SET "organizationId" = default_org_id WHERE "organizationId" IS NULL;

        -- Tornar a coluna obrigatória
        ALTER TABLE documents ALTER COLUMN "organizationId" SET NOT NULL;

        -- Adicionar foreign key
        ALTER TABLE documents ADD CONSTRAINT documents_organization_fk
            FOREIGN KEY ("organizationId") REFERENCES organizations(id) ON DELETE CASCADE;

        -- Adicionar índice
        CREATE INDEX IF NOT EXISTS documents_organization_id_idx ON documents("organizationId");
    END IF;

    -- 5. Adicionar coluna organizationId aos document_validations (se não existir)
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'document_validations' AND column_name = 'organizationId') THEN
        ALTER TABLE document_validations ADD COLUMN "organizationId" INTEGER;

        -- Atualizar validações existentes com a organização padrão
        UPDATE document_validations SET "organizationId" = default_org_id WHERE "organizationId" IS NULL;

        -- Tornar a coluna obrigatória
        ALTER TABLE document_validations ALTER COLUMN "organizationId" SET NOT NULL;

        -- Adicionar foreign key
        ALTER TABLE document_validations ADD CONSTRAINT document_validations_organization_fk
            FOREIGN KEY ("organizationId") REFERENCES organizations(id) ON DELETE CASCADE;

        -- Adicionar índice
        CREATE INDEX IF NOT EXISTS document_validations_organization_id_idx ON document_validations("organizationId");
    END IF;

    -- 6. Criar tabela api_usage (se não existir)
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'api_usage') THEN
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
            created_at TIMESTAMP NOT NULL DEFAULT NOW()
        );

        -- Adicionar foreign keys
        ALTER TABLE api_usage ADD CONSTRAINT api_usage_user_fk
            FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

        ALTER TABLE api_usage ADD CONSTRAINT api_usage_organization_fk
            FOREIGN KEY (organization_id) REFERENCES organizations(id) ON DELETE CASCADE;

        -- Adicionar índices
        CREATE INDEX IF NOT EXISTS api_usage_user_id_idx ON api_usage(user_id);
        CREATE INDEX IF NOT EXISTS api_usage_organization_id_idx ON api_usage(organization_id);
        CREATE INDEX IF NOT EXISTS api_usage_date_idx ON api_usage(date);
        CREATE INDEX IF NOT EXISTS api_usage_service_idx ON api_usage(service);
    ELSE
        -- Se a tabela já existe, adicionar colunas que faltam
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'api_usage' AND column_name = 'organization_id') THEN
            ALTER TABLE api_usage ADD COLUMN organization_id INTEGER;
            UPDATE api_usage SET organization_id = default_org_id WHERE organization_id IS NULL;
            ALTER TABLE api_usage ALTER COLUMN organization_id SET NOT NULL;

            ALTER TABLE api_usage ADD CONSTRAINT api_usage_organization_fk
                FOREIGN KEY (organization_id) REFERENCES organizations(id) ON DELETE CASCADE;

            CREATE INDEX IF NOT EXISTS api_usage_organization_id_idx ON api_usage(organization_id);
        END IF;

        -- Corrigir user_id NULL
        IF EXISTS (SELECT 1 FROM api_usage WHERE user_id IS NULL) THEN
            -- Pegar o primeiro usuário da organização padrão
            DECLARE first_user_id INT;
            BEGIN
                SELECT id INTO first_user_id FROM users WHERE "organizationId" = default_org_id LIMIT 1;
                UPDATE api_usage SET user_id = first_user_id WHERE user_id IS NULL;
            END;
        END IF;
    END IF;

    -- 7. Adicionar coluna auth_user_id aos users (para integração Supabase)
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'users' AND column_name = 'auth_user_id') THEN
        ALTER TABLE users ADD COLUMN auth_user_id UUID UNIQUE;
    END IF;

END $$;

COMMIT;

-- Exibir resumo
SELECT
    'Migration completed successfully!' as status,
    (SELECT COUNT(*) FROM organizations) as organizations_count,
    (SELECT COUNT(*) FROM users) as users_count,
    (SELECT COUNT(*) FROM projects) as projects_count,
    (SELECT COUNT(*) FROM documents) as documents_count,
    (SELECT COUNT(*) FROM api_usage) as api_usage_count;
