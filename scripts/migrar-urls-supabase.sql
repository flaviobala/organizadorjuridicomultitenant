-- ========================================
-- Script de Migração: URLs do Supabase → Local
-- ========================================
--
-- Este script ajuda a migrar URLs antigas do Supabase
-- para o novo sistema de storage local
--
-- Execute conectado ao banco: organizador_juridico
--

-- 1. BACKUP (SEMPRE FAÇA BACKUP ANTES!)
-- ========================================

-- Criar backup da tabela Organization
CREATE TABLE IF NOT EXISTS "Organization_backup_$(date +%Y%m%d)" AS
SELECT * FROM "Organization";

-- Criar backup da tabela Document
CREATE TABLE IF NOT EXISTS "Document_backup_$(date +%Y%m%d)" AS
SELECT * FROM "Document";


-- 2. ANÁLISE: Ver quantos registros serão afetados
-- ========================================

-- Logos com URLs do Supabase
SELECT
    'LOGOS' as tipo,
    COUNT(*) as total,
    COUNT(CASE WHEN logo_url LIKE '%supabase%' THEN 1 END) as com_supabase,
    COUNT(CASE WHEN logo_url IS NULL THEN 1 END) as sem_logo
FROM "Organization";

-- Documentos com URLs do Supabase
SELECT
    'DOCUMENTOS' as tipo,
    COUNT(*) as total,
    COUNT(CASE WHEN "storedFilename" LIKE '%supabase%' THEN 1 END) as stored_supabase,
    COUNT(CASE WHEN "pdfPath" LIKE '%supabase%' THEN 1 END) as pdf_supabase
FROM "Document";


-- 3. LISTAR URLs antigas (para revisão)
-- ========================================

-- Ver logos do Supabase
SELECT
    id,
    name,
    logo_url,
    LENGTH(logo_url) as url_length
FROM "Organization"
WHERE logo_url LIKE '%supabase%'
ORDER BY id;

-- Ver documentos do Supabase
SELECT
    id,
    "originalFilename",
    "storedFilename",
    "pdfPath"
FROM "Document"
WHERE "storedFilename" LIKE '%supabase%'
   OR "pdfPath" LIKE '%supabase%'
ORDER BY id
LIMIT 20;


-- 4. OPÇÃO A: Limpar URLs antigas (forçar re-upload)
-- ========================================
-- CUIDADO: Isso remove as URLs do banco!
-- Os arquivos no Supabase NÃO serão deletados.
-- Os usuários precisarão fazer novo upload.

-- Limpar logos
-- DESCOMENTE PARA EXECUTAR:
-- UPDATE "Organization"
-- SET logo_url = NULL
-- WHERE logo_url LIKE '%supabase%';

-- Limpar storedFilename de documentos
-- DESCOMENTE PARA EXECUTAR:
-- UPDATE "Document"
-- SET "storedFilename" = NULL
-- WHERE "storedFilename" LIKE '%supabase%';

-- Limpar pdfPath de documentos
-- DESCOMENTE PARA EXECUTAR:
-- UPDATE "Document"
-- SET "pdfPath" = NULL
-- WHERE "pdfPath" LIKE '%supabase%';


-- 5. OPÇÃO B: Converter URLs (se você baixou os arquivos)
-- ========================================
-- Use esta opção se você baixou os arquivos do Supabase
-- e colocou na pasta local com a mesma estrutura

-- Exemplo de conversão de logo:
-- DE:  https://yrzlxuefbxbpfndcpfqz.supabase.co/storage/v1/object/public/documents/logos/1/abc-123.png
-- PARA: http://localhost:3000/uploads/logos/1/abc-123.png

-- DESCOMENTE E AJUSTE PARA EXECUTAR:
-- UPDATE "Organization"
-- SET logo_url = REPLACE(
--     logo_url,
--     'https://yrzlxuefbxbpfndcpfqz.supabase.co/storage/v1/object/public/documents/',
--     'http://localhost:3000/uploads/'
-- )
-- WHERE logo_url LIKE '%supabase%';


-- 6. OPÇÃO C: Marcar documentos antigos como "migrated"
-- ========================================
-- Esta opção mantém os registros mas marca que precisam migração

-- Adicionar coluna de migração (se não existir)
-- ALTER TABLE "Document"
-- ADD COLUMN IF NOT EXISTS "needsMigration" BOOLEAN DEFAULT FALSE;

-- Marcar documentos que precisam migração
-- UPDATE "Document"
-- SET "needsMigration" = TRUE
-- WHERE "storedFilename" LIKE '%supabase%'
--    OR "pdfPath" LIKE '%supabase%';


-- 7. VERIFICAÇÃO PÓS-MIGRAÇÃO
-- ========================================

-- Contar logos locais vs Supabase
SELECT
    COUNT(*) as total_orgs,
    COUNT(CASE WHEN logo_url LIKE 'http://localhost%' THEN 1 END) as logos_locais,
    COUNT(CASE WHEN logo_url LIKE '%supabase%' THEN 1 END) as logos_supabase,
    COUNT(CASE WHEN logo_url IS NULL THEN 1 END) as sem_logo
FROM "Organization";

-- Contar documentos locais vs Supabase
SELECT
    COUNT(*) as total_docs,
    COUNT(CASE WHEN "pdfPath" LIKE 'http://localhost%' THEN 1 END) as pdfs_locais,
    COUNT(CASE WHEN "pdfPath" LIKE '%supabase%' THEN 1 END) as pdfs_supabase,
    COUNT(CASE WHEN "pdfPath" IS NULL THEN 1 END) as sem_pdf
FROM "Document";


-- 8. ROLLBACK (se algo der errado)
-- ========================================
-- Se você criou backup no passo 1, pode restaurar:

-- Restaurar Organization (AJUSTE A DATA):
-- DROP TABLE "Organization";
-- ALTER TABLE "Organization_backup_20250110" RENAME TO "Organization";

-- Restaurar Document (AJUSTE A DATA):
-- DROP TABLE "Document";
-- ALTER TABLE "Document_backup_20250110" RENAME TO "Document";


-- 9. LIMPEZA: Deletar backups antigos
-- ========================================
-- Depois de verificar que tudo está OK, você pode deletar os backups

-- Listar backups existentes:
SELECT table_name
FROM information_schema.tables
WHERE table_name LIKE '%_backup_%'
  AND table_schema = 'public';

-- Deletar backup específico (AJUSTE A DATA):
-- DROP TABLE "Organization_backup_20250110";
-- DROP TABLE "Document_backup_20250110";


-- ========================================
-- FIM DO SCRIPT
-- ========================================

-- NOTAS IMPORTANTES:
--
-- 1. SEMPRE faça backup antes de executar UPDATE/DELETE
-- 2. Teste em ambiente de desenvolvimento primeiro
-- 3. Execute os comandos linha por linha (não tudo de uma vez)
-- 4. Verifique os resultados após cada comando
-- 5. Mantenha os backups por pelo menos 1 semana
--
-- Se você deletou arquivos do Supabase:
-- - As URLs antigas não funcionarão mais
-- - Usuários precisarão fazer re-upload
--
-- Se você manteve os arquivos do Supabase:
-- - URLs antigas ainda funcionarão temporariamente
-- - Você pode fazer migração gradual
--
-- ========================================

-- Comandos úteis:

-- Ver tamanho das tabelas:
SELECT
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;

-- Ver todas as colunas de Organization:
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'Organization'
ORDER BY ordinal_position;
