-- Migration: Add user roles for multi-tenant admin
-- Date: 2025-10-27

-- 1. Criar enum UserRole
CREATE TYPE "UserRole" AS ENUM ('admin', 'member');

-- 2. Adicionar coluna role na tabela users
ALTER TABLE "users"
ADD COLUMN "role" "UserRole" NOT NULL DEFAULT 'member';

-- 3. Definir o primeiro usuário de cada organização como admin
UPDATE "users" u1
SET "role" = 'admin'
WHERE u1.id IN (
  SELECT MIN(u2.id)
  FROM "users" u2
  GROUP BY u2."organizationId"
);

-- Comentário:
-- Esta migration adiciona suporte a roles de usuário (admin/member)
-- O primeiro usuário de cada organização é automaticamente promovido a admin
