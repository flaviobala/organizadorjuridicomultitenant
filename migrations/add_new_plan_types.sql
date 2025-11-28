-- =============================================
-- MIGRAÇÃO: Adicionar novos tipos de plano
-- Data: 2025-01-27
-- Descrição: Adicionar 'advanced' e 'complete', manter clientes existentes
-- =============================================

-- PASSO 1: Adicionar novos valores ao enum PlanType
-- (PostgreSQL não permite ALTER TYPE diretamente, então usamos esta técnica)

BEGIN;

-- 1.1: Criar novo tipo temporário com todos os valores
CREATE TYPE "PlanType_new" AS ENUM ('free', 'basic', 'advanced', 'complete', 'pro');

-- 1.2: Alterar coluna para usar o novo tipo
ALTER TABLE "organizations"
  ALTER COLUMN "plan_type" TYPE "PlanType_new"
  USING ("plan_type"::text::"PlanType_new");

-- 1.3: Remover tipo antigo
DROP TYPE "PlanType";

-- 1.4: Renomear novo tipo
ALTER TYPE "PlanType_new" RENAME TO "PlanType";

-- PASSO 2: Converter clientes existentes com 'pro' para 'complete'
-- (Assumindo que 'pro' é o plano mais completo atualmente)
UPDATE "organizations"
SET "plan_type" = 'complete'
WHERE "plan_type" = 'pro';

-- PASSO 3: Verificar resultado
-- (Apenas para validação - você pode rodar depois)
-- SELECT plan_type, COUNT(*) as total
-- FROM organizations
-- GROUP BY plan_type;

COMMIT;

-- =============================================
-- IMPORTANTE: Rodar este script no DBeaver
-- Depois de executar, verificar se tudo está OK antes de continuar
-- =============================================
