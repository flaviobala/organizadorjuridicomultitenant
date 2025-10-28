-- Migration: Tornar usuário específico admin
-- Execute este script para tornar um usuário admin

-- Opção 1: Tornar TODOS os usuários admin (útil para desenvolvimento)
UPDATE users SET role = 'admin';

-- Opção 2: Tornar apenas o primeiro usuário de cada organização admin
-- (descomente se preferir esta opção)
-- UPDATE users u1
-- SET role = 'admin'
-- WHERE u1.id IN (
--   SELECT MIN(u2.id)
--   FROM users u2
--   GROUP BY u2."organizationId"
-- );

-- Opção 3: Tornar um usuário específico admin
-- (descomente e substitua pelo seu email)
-- UPDATE users SET role = 'admin' WHERE email = 'seu@email.com';
