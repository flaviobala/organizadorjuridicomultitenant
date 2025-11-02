-- Migração: Adicionar super_admin ao enum UserRole
-- Data: 2025-11-02
-- Descrição: Adiciona role 'super_admin' para diferenciar o dono do sistema dos admins das organizações

-- IMPORTANTE: Execute no Supabase SQL Editor ou via Prisma

-- Adicionar novo valor ao enum
ALTER TYPE "UserRole" ADD VALUE IF NOT EXISTS 'super_admin';

-- Listar todas as roles disponíveis
SELECT enum_range(NULL::public."UserRole");

-- Exemplo de como criar o primeiro super admin (após executar esta migração):
-- UPDATE users SET role = 'super_admin' WHERE email = 'seu@email.com';
