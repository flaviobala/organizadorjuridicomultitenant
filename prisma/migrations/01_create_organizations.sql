-- Criação da tabela organizations
CREATE TABLE IF NOT EXISTS organizations (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    plan_type VARCHAR(50) NOT NULL DEFAULT 'trialing',
    subscription_status VARCHAR(50) NOT NULL DEFAULT 'trialing',
    document_processed_count INTEGER NOT NULL DEFAULT 0,
    ai_token_count INTEGER NOT NULL DEFAULT 0,
    stripe_customer_id VARCHAR(255) UNIQUE,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Inserir organização padrão para dados existentes
INSERT INTO organizations (name, plan_type, subscription_status, document_processed_count, ai_token_count, created_at, updated_at)
VALUES ('Default Organization', 'trialing', 'trialing', 0, 0, NOW(), NOW())
ON CONFLICT DO NOTHING;

SELECT 'Organizations table created' as status;
