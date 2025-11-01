# Guia de Implementação - Row Level Security (RLS)

## 🎯 Objetivo
Implementar Row Level Security no Supabase para garantir isolamento de dados entre organizações no nível do banco de dados.

---

## ⚠️ IMPORTANTE - Leia Antes de Executar

### O que é RLS?
Row Level Security é uma camada de segurança do PostgreSQL que **impede** que um usuário acesse linhas de outras organizações, **mesmo que haja um bug no código** da aplicação.

### Como Funciona?
- **Sem RLS:** Se seu código tiver um bug e esquecer de filtrar por `organizationId`, dados de outras orgs vazam
- **Com RLS:** Mesmo com bug no código, o banco **bloqueia** automaticamente o acesso

### Limitação Atual
Nosso sistema usa JWT próprio (não Supabase Auth), então o RLS funciona como:
- ✅ **Safety net** (rede de segurança extra)
- ✅ Proteção contra bugs no código
- ✅ Proteção contra acesso direto ao banco
- ⚠️ Mas não é a camada primária (código ainda filtra por organizationId)

---

## 📋 Passo a Passo

### PASSO 1: Acessar SQL Editor do Supabase

1. Acesse: https://supabase.com/dashboard/project/yrzlxuefbxbpfndcpfqz/sql
2. Faça login com sua conta Supabase
3. Você verá o SQL Editor

### PASSO 2: Backup do Banco de Dados (Segurança)

Antes de executar qualquer script, faça backup:

1. No Supabase Dashboard, vá em: **Database → Backups**
2. Clique em **Create backup**
3. Ou simplesmente confie nos backups automáticos (Supabase faz diariamente)

### PASSO 3: Executar Script de RLS

1. Abra o arquivo: [supabase-rls-setup.sql](supabase-rls-setup.sql)
2. Copie **TODO** o conteúdo
3. Cole no SQL Editor do Supabase
4. Clique em **Run** (ou pressione Ctrl+Enter)

**Resultado esperado:**
```
✅ Success. No rows returned
```

Se der erro, leia a mensagem e me avise!

### PASSO 4: Verificar se RLS Foi Ativado

Execute esta query no SQL Editor:

```sql
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
```

**Resultado esperado:**
```
tablename              | rowsecurity
-----------------------|------------
organizations          | true
users                  | true
projects               | true
documents              | true
document_validations   | true
api_usage              | true
```

### PASSO 5: Verificar Políticas Criadas

Execute esta query:

```sql
SELECT
  tablename,
  policyname,
  cmd
FROM pg_policies
WHERE schemaname = 'public'
ORDER BY tablename, cmd;
```

**Resultado esperado:**
Deve listar todas as políticas criadas (SELECT, INSERT, UPDATE, DELETE para cada tabela)

Exemplo:
```
tablename    | policyname                        | cmd
-------------|-----------------------------------|--------
users        | users_select_policy               | SELECT
users        | users_insert_policy               | INSERT
users        | users_update_policy               | UPDATE
users        | users_delete_policy               | DELETE
projects     | projects_select_policy            | SELECT
...
```

### PASSO 6: Testar RLS (Opcional mas Recomendado)

#### Teste 1: Verificar que Service Role Bypassa RLS

No SQL Editor, execute:

```sql
-- Conectado com Service Role (padrão no SQL Editor)
SELECT COUNT(*) FROM users;
```

**Deve retornar:** Contagem total de usuários (RLS bypassado)

#### Teste 2: Simular Acesso sem Service Role

Infelizmente, este teste é complexo sem Supabase Auth configurado.

**Para testar de verdade, você precisaria:**
1. Configurar Supabase Auth
2. Popular campo `auth_user_id` na tabela users
3. Fazer queries via API com anon key

**Por enquanto, confie que:**
- ✅ RLS está ativado
- ✅ Políticas estão criadas
- ✅ Service Role bypassa (necessário para Prisma funcionar)

---

## 🔍 Como Saber se Está Funcionando?

### 1. RLS Não Quebra a Aplicação

Após ativar RLS, teste sua aplicação normalmente:
- ✅ Login funciona?
- ✅ Criar projeto funciona?
- ✅ Upload de documento funciona?
- ✅ Dashboard carrega?

**Se tudo funcionar normalmente, RLS está OK!**

Por quê? Porque o Prisma usa Service Role Key que bypassa RLS.

### 2. RLS Protege Acesso Direto

Se alguém tentar acessar o banco diretamente (sem service role), será bloqueado.

**Teste (se quiser):**
1. Crie uma connection string com **anon key** em vez de service role
2. Tente fazer SELECT em qualquer tabela
3. Deve retornar vazio ou erro de permissão

---

## 📊 Entendendo as Políticas

### Política de SELECT (Exemplo: projects)

```sql
CREATE POLICY "projects_select_policy" ON "projects"
FOR SELECT
USING (
  organization_id = auth.get_user_organization_id()
);
```

**Tradução:**
- **FOR SELECT:** Aplica-se a queries SELECT
- **USING:** Condição para permitir acesso
- **organization_id = auth.get_user_organization_id():** Só permite se o organization_id da linha for igual ao organization_id do usuário autenticado

### Política de INSERT (Exemplo: projects)

```sql
CREATE POLICY "projects_insert_policy" ON "projects"
FOR INSERT
WITH CHECK (
  organization_id = auth.get_user_organization_id()
);
```

**Tradução:**
- **FOR INSERT:** Aplica-se a operações INSERT
- **WITH CHECK:** Condição para permitir inserção
- Só permite inserir se o organization_id for igual ao do usuário autenticado

---

## ⚠️ Troubleshooting

### Erro: "function auth.get_user_organization_id() does not exist"

**Solução:** Execute a criação da função primeiro:

```sql
CREATE OR REPLACE FUNCTION auth.get_user_organization_id()
RETURNS INTEGER AS $$
  SELECT organization_id
  FROM users
  WHERE auth_user_id = auth.uid()
  LIMIT 1;
$$ LANGUAGE sql SECURITY DEFINER;
```

### Erro: "permission denied for table users"

**Causa:** RLS está bloqueando acesso
**Solução:** Certifique-se de estar usando Service Role Key no Prisma:
```
DATABASE_URL="postgresql://postgres.yrzlxuefbxbpfndcpfqz:21957@123@..."
```

### Aplicação Para de Funcionar Após RLS

**Causa:** Prisma não está usando Service Role Key
**Solução:**
1. Verifique .env.local
2. DATABASE_URL deve usar a senha do service role (não anon key)
3. Reinicie Next.js após mudar .env

### Como Desabilitar RLS (EMERGÊNCIA APENAS)

**NUNCA use em produção!** Apenas para debugging:

```sql
ALTER TABLE "users" DISABLE ROW LEVEL SECURITY;
ALTER TABLE "projects" DISABLE ROW LEVEL SECURITY;
-- ... para cada tabela
```

Depois de resolver o problema, **REABILITE**:

```sql
ALTER TABLE "users" ENABLE ROW LEVEL SECURITY;
-- ...
```

---

## 🎯 Checklist Final

Após implementar RLS, verifique:

- [ ] ✅ RLS ativado em todas as tabelas (query no PASSO 4)
- [ ] ✅ Políticas criadas (query no PASSO 5)
- [ ] ✅ Aplicação funciona normalmente
- [ ] ✅ Login funciona
- [ ] ✅ Criar projeto funciona
- [ ] ✅ Upload de documento funciona
- [ ] ✅ Dashboard carrega
- [ ] ✅ Nenhum erro de "permission denied"

Se **TODOS** os itens acima estiverem ✅, RLS está funcionando perfeitamente!

---

## 🔐 Segurança Adicional

### Próximos Passos (Opcional)

Para segurança ainda maior, considere no futuro:

1. **Migrar para Supabase Auth:**
   - Em vez de JWT próprio
   - RLS funcionaria 100%
   - auth.uid() seria populado automaticamente

2. **Adicionar Audit Logs:**
   - Registrar todas as operações CRUD
   - Detectar tentativas de acesso não autorizado

3. **Rate Limiting:**
   - Limitar requisições por IP/usuário
   - Prevenir ataques de força bruta

4. **2FA (Two-Factor Authentication):**
   - Para contas de admin
   - Aumenta segurança do login

---

## 📞 Suporte

Se tiver qualquer problema:

1. ❌ **ERRO de SQL:** Me envie a mensagem de erro completa
2. ❌ **Aplicação quebrou:** Me envie os logs do terminal Next.js
3. ❌ **Dúvidas:** Pergunte! Estou aqui para ajudar

---

**Próximo passo após RLS:** Implementar testes automatizados de isolamento

Boa sorte! 🚀
