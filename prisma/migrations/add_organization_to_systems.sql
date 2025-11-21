-- Migration: Adicionar organizationId em system_configurations
-- Data: 2025-01-19
-- Descrição: Transforma SystemConfiguration em multi-tenant

BEGIN;

-- Passo 1: Adicionar coluna organization_id (nullable temporariamente)
ALTER TABLE system_configurations
ADD COLUMN IF NOT EXISTS organization_id INTEGER;

-- Passo 2: Para cada sistema existente, criar uma cópia para cada organização
-- Primeiro, vamos criar os sistemas padrão para todas as organizações
INSERT INTO system_configurations (system_name, max_file_size, max_page_size, allowed_formats, pdf_requirements, organization_id, created_at, updated_at)
SELECT
  sc.system_name,
  sc.max_file_size,
  sc.max_page_size,
  sc.allowed_formats,
  sc.pdf_requirements,
  o.id AS organization_id,
  NOW() AS created_at,
  NOW() AS updated_at
FROM system_configurations sc
CROSS JOIN organizations o
WHERE sc.organization_id IS NULL
ON CONFLICT DO NOTHING;

-- Passo 3: Deletar registros sem organization_id (os globais que foram duplicados)
DELETE FROM system_configurations WHERE organization_id IS NULL;

-- Passo 4: Tornar organization_id NOT NULL
ALTER TABLE system_configurations
ALTER COLUMN organization_id SET NOT NULL;

-- Passo 5: Adicionar foreign key constraint
ALTER TABLE system_configurations
ADD CONSTRAINT fk_system_configurations_organization
FOREIGN KEY (organization_id)
REFERENCES organizations(id)
ON DELETE CASCADE;

-- Passo 6: Remover o constraint unique global de system_name (se existir)
DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'system_configurations_system_name_key'
    ) THEN
        ALTER TABLE system_configurations
        DROP CONSTRAINT system_configurations_system_name_key;
    END IF;
END $$;

-- Passo 7: Adicionar constraint unique composto (organization_id + system_name)
CREATE UNIQUE INDEX IF NOT EXISTS idx_system_configurations_org_name
ON system_configurations(organization_id, system_name);

-- Passo 8: Criar índice para melhorar performance de queries
CREATE INDEX IF NOT EXISTS idx_system_configurations_organization_id
ON system_configurations(organization_id);

COMMIT;

-- Verificação: Mostrar quantos sistemas foram criados por organização
SELECT
  o.name AS organization_name,
  COUNT(sc.id) AS total_systems
FROM organizations o
LEFT JOIN system_configurations sc ON sc.organization_id = o.id
GROUP BY o.id, o.name
ORDER BY o.name;
