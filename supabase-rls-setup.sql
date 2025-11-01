-- ============================================================================
-- ROW LEVEL SECURITY (RLS) - MULTI-TENANT SECURITY
-- Sistema Jurídico Multi-Tenant
-- ============================================================================
-- IMPORTANTE: Execute este script no SQL Editor do Supabase
-- URL: https://supabase.com/dashboard/project/yrzlxuefbxbpfndcpfqz/sql
-- ============================================================================

-- ============================================================================
-- PASSO 1: HABILITAR RLS EM TODAS AS TABELAS
-- ============================================================================

ALTER TABLE "organizations" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "users" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "projects" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "documents" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "document_validations" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "api_usage" ENABLE ROW LEVEL SECURITY;

-- Tabelas globais NÃO precisam de RLS (compartilhadas entre todos)
-- system_configurations, document_types, action_types

-- ============================================================================
-- PASSO 2: CRIAR FUNÇÃO HELPER PARA PEGAR ORGANIZATION_ID DO USUÁRIO
-- ============================================================================

-- Esta função pega o organization_id do usuário autenticado
-- Usa auth.uid() do Supabase para identificar o usuário
CREATE OR REPLACE FUNCTION auth.get_user_organization_id()
RETURNS INTEGER AS $$
  SELECT organization_id
  FROM users
  WHERE auth_user_id = auth.uid()
  LIMIT 1;
$$ LANGUAGE sql SECURITY DEFINER;

-- ============================================================================
-- PASSO 3: POLÍTICAS PARA TABELA "organizations"
-- ============================================================================

-- SELECT: Usuário só pode ver sua própria organização
CREATE POLICY "organizations_select_policy" ON "organizations"
FOR SELECT
USING (
  id = auth.get_user_organization_id()
);

-- INSERT: Apenas para registro (não via RLS, mas via application)
-- Permitir apenas se for um super admin (você pode ajustar depois)
CREATE POLICY "organizations_insert_policy" ON "organizations"
FOR INSERT
WITH CHECK (false); -- Ninguém pode criar via SQL direto

-- UPDATE: Apenas sua própria organização
CREATE POLICY "organizations_update_policy" ON "organizations"
FOR UPDATE
USING (
  id = auth.get_user_organization_id()
);

-- DELETE: Ninguém pode deletar via SQL (apenas via application)
CREATE POLICY "organizations_delete_policy" ON "organizations"
FOR DELETE
USING (false);

-- ============================================================================
-- PASSO 4: POLÍTICAS PARA TABELA "users"
-- ============================================================================

-- SELECT: Usuário só pode ver usuários da mesma organização
CREATE POLICY "users_select_policy" ON "users"
FOR SELECT
USING (
  organization_id = auth.get_user_organization_id()
);

-- INSERT: Apenas usuários da mesma organização (para adicionar membros)
CREATE POLICY "users_insert_policy" ON "users"
FOR INSERT
WITH CHECK (
  organization_id = auth.get_user_organization_id()
);

-- UPDATE: Apenas usuários da mesma organização
CREATE POLICY "users_update_policy" ON "users"
FOR UPDATE
USING (
  organization_id = auth.get_user_organization_id()
);

-- DELETE: Apenas usuários da mesma organização
CREATE POLICY "users_delete_policy" ON "users"
FOR DELETE
USING (
  organization_id = auth.get_user_organization_id()
);

-- ============================================================================
-- PASSO 5: POLÍTICAS PARA TABELA "projects"
-- ============================================================================

-- SELECT: Apenas projetos da mesma organização
CREATE POLICY "projects_select_policy" ON "projects"
FOR SELECT
USING (
  organization_id = auth.get_user_organization_id()
);

-- INSERT: Apenas para a própria organização
CREATE POLICY "projects_insert_policy" ON "projects"
FOR INSERT
WITH CHECK (
  organization_id = auth.get_user_organization_id()
);

-- UPDATE: Apenas projetos da mesma organização
CREATE POLICY "projects_update_policy" ON "projects"
FOR UPDATE
USING (
  organization_id = auth.get_user_organization_id()
);

-- DELETE: Apenas projetos da mesma organização
CREATE POLICY "projects_delete_policy" ON "projects"
FOR DELETE
USING (
  organization_id = auth.get_user_organization_id()
);

-- ============================================================================
-- PASSO 6: POLÍTICAS PARA TABELA "documents"
-- ============================================================================

-- SELECT: Apenas documentos da mesma organização
CREATE POLICY "documents_select_policy" ON "documents"
FOR SELECT
USING (
  organization_id = auth.get_user_organization_id()
);

-- INSERT: Apenas para a própria organização
CREATE POLICY "documents_insert_policy" ON "documents"
FOR INSERT
WITH CHECK (
  organization_id = auth.get_user_organization_id()
);

-- UPDATE: Apenas documentos da mesma organização
CREATE POLICY "documents_update_policy" ON "documents"
FOR UPDATE
USING (
  organization_id = auth.get_user_organization_id()
);

-- DELETE: Apenas documentos da mesma organização
CREATE POLICY "documents_delete_policy" ON "documents"
FOR DELETE
USING (
  organization_id = auth.get_user_organization_id()
);

-- ============================================================================
-- PASSO 7: POLÍTICAS PARA TABELA "document_validations"
-- ============================================================================

-- SELECT: Apenas validações da mesma organização
CREATE POLICY "document_validations_select_policy" ON "document_validations"
FOR SELECT
USING (
  organization_id = auth.get_user_organization_id()
);

-- INSERT: Apenas para a própria organização
CREATE POLICY "document_validations_insert_policy" ON "document_validations"
FOR INSERT
WITH CHECK (
  organization_id = auth.get_user_organization_id()
);

-- UPDATE: Apenas validações da mesma organização
CREATE POLICY "document_validations_update_policy" ON "document_validations"
FOR UPDATE
USING (
  organization_id = auth.get_user_organization_id()
);

-- DELETE: Apenas validações da mesma organização
CREATE POLICY "document_validations_delete_policy" ON "document_validations"
FOR DELETE
USING (
  organization_id = auth.get_user_organization_id()
);

-- ============================================================================
-- PASSO 8: POLÍTICAS PARA TABELA "api_usage"
-- ============================================================================

-- SELECT: Apenas uso de API da mesma organização
CREATE POLICY "api_usage_select_policy" ON "api_usage"
FOR SELECT
USING (
  organization_id = auth.get_user_organization_id()
);

-- INSERT: Apenas para a própria organização
CREATE POLICY "api_usage_insert_policy" ON "api_usage"
FOR INSERT
WITH CHECK (
  organization_id = auth.get_user_organization_id()
);

-- UPDATE: Apenas uso de API da mesma organização (geralmente não se atualiza)
CREATE POLICY "api_usage_update_policy" ON "api_usage"
FOR UPDATE
USING (
  organization_id = auth.get_user_organization_id()
);

-- DELETE: Apenas uso de API da mesma organização
CREATE POLICY "api_usage_delete_policy" ON "api_usage"
FOR DELETE
USING (
  organization_id = auth.get_user_organization_id()
);

-- ============================================================================
-- PASSO 9: POLÍTICA ESPECIAL PARA SERVICE ROLE (BYPASS RLS)
-- ============================================================================

-- O Prisma Client usa o Service Role Key que tem permissão para bypassar RLS
-- Isso é NECESSÁRIO para operações administrativas e webhooks
-- Certifique-se de que SUPABASE_SERVICE_ROLE_KEY está configurado no .env

-- ============================================================================
-- PASSO 10: VERIFICAR SE RLS ESTÁ ATIVADO
-- ============================================================================

SELECT
  tablename,
  rowsecurity
FROM pg_tables
WHERE schemaname = 'public'
  AND tablename IN (
    'organizations',
    'users',
    'projects',
    'documents',
    'document_validations',
    'api_usage'
  );

-- Deve retornar todas as tabelas com rowsecurity = true

-- ============================================================================
-- PASSO 11: VERIFICAR POLÍTICAS CRIADAS
-- ============================================================================

SELECT
  schemaname,
  tablename,
  policyname,
  cmd,
  qual
FROM pg_policies
WHERE schemaname = 'public'
ORDER BY tablename, cmd;

-- Deve retornar todas as políticas criadas acima

-- ============================================================================
-- NOTAS IMPORTANTES
-- ============================================================================

/*
1. **Service Role Key:**
   - O Prisma usa SUPABASE_SERVICE_ROLE_KEY que BYPASSA o RLS
   - Isso é necessário para operações administrativas
   - RLS protege apenas acessos diretos ao banco ou via anon key

2. **auth.uid():**
   - Requer que o campo 'auth_user_id' esteja populado na tabela users
   - Este campo deve ser UUID do Supabase Auth
   - Atualmente o sistema usa JWT próprio, então RLS serve como camada extra

3. **Testando RLS:**
   - Para testar, você precisaria:
     a) Criar um usuário no Supabase Auth
     b) Popular o campo auth_user_id
     c) Fazer queries usando anon key (não service role)

4. **Limitações Atuais:**
   - O sistema usa JWT próprio, não Supabase Auth
   - RLS funciona como CAMADA ADICIONAL de segurança
   - Proteção principal ainda é via código (organizationId nas queries)

5. **Para Produção:**
   - Considere migrar para Supabase Auth no futuro
   - Ou ajustar políticas para usar session variables
   - Mantenha RLS como "safety net" mesmo com proteção no código
*/

-- ============================================================================
-- SCRIPT PARA DESABILITAR RLS (EMERGÊNCIA APENAS!)
-- ============================================================================
-- NUNCA USE EM PRODUÇÃO
-- Apenas para desenvolvimento/debugging

-- ALTER TABLE "organizations" DISABLE ROW LEVEL SECURITY;
-- ALTER TABLE "users" DISABLE ROW LEVEL SECURITY;
-- ALTER TABLE "projects" DISABLE ROW LEVEL SECURITY;
-- ALTER TABLE "documents" DISABLE ROW LEVEL SECURITY;
-- ALTER TABLE "document_validations" DISABLE ROW LEVEL SECURITY;
-- ALTER TABLE "api_usage" DISABLE ROW LEVEL SECURITY;

-- ============================================================================
-- FIM DO SCRIPT
-- ============================================================================
