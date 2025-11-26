-- Migration: Add organization_id to action_types
-- Created: 2025-01-25
-- Description: Adiciona coluna organization_id para isolar tipos de ação por organização

-- 1. Adicionar coluna organization_id (nullable temporariamente)
ALTER TABLE action_types
ADD COLUMN organization_id INTEGER;

-- 2. Definir organização padrão (primeira organização) para tipos existentes
UPDATE action_types
SET organization_id = (SELECT id FROM organizations ORDER BY id LIMIT 1)
WHERE organization_id IS NULL;

-- 3. Tornar a coluna NOT NULL
ALTER TABLE action_types
ALTER COLUMN organization_id SET NOT NULL;

-- 4. Remover constraint de unique no name (agora name pode se repetir entre organizações)
ALTER TABLE action_types
DROP CONSTRAINT IF EXISTS action_types_name_key;

-- 5. Adicionar foreign key
ALTER TABLE action_types
ADD CONSTRAINT action_types_organization_id_fkey
FOREIGN KEY (organization_id)
REFERENCES organizations(id)
ON DELETE CASCADE;

-- 6. Adicionar unique constraint composto (name + organization_id)
ALTER TABLE action_types
ADD CONSTRAINT action_types_name_organization_id_key
UNIQUE (name, organization_id);

-- 7. Criar índice para melhor performance
CREATE INDEX idx_action_types_organization_id ON action_types(organization_id);
