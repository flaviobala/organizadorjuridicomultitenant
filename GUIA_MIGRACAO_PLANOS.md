# 🔄 GUIA DE MIGRAÇÃO - Novos Planos (Basic/Advanced/Complete)

## 📋 Resumo das Mudanças

### **Antes:**
- Planos: `free`, `basic`, `pro`
- Limites: Documentos + Tokens de IA
- Homepage: Mostrava planos diferentes do banco

### **Depois:**
- Planos: `free`, `basic`, `advanced`, `complete`
- Limites: **SOMENTE Documentos** (tokens não contam mais)
- Teste grátis: **3 dias OU 50 documentos** (o que vier primeiro)
- Homepage: Alinhada com o banco de dados

---

## ⚠️ IMPORTANTE: Clientes Existentes

✅ **Clientes com plano `pro` serão automaticamente migrados para `complete`**
✅ **Nenhum dado será perdido**
✅ **Todos os documentos e projetos continuam intactos**

---

## 🚀 PASSO A PASSO

### **PASSO 1: Backup do Banco (OBRIGATÓRIO)**

No DBeaver, execute:

```sql
-- Fazer backup da tabela organizations
CREATE TABLE organizations_backup_20250127 AS
SELECT * FROM organizations;

-- Verificar backup
SELECT COUNT(*) FROM organizations_backup_20250127;
```

---

### **PASSO 2: Executar Migração SQL**

No DBeaver, abra o arquivo: **`migrations/add_new_plan_types.sql`**

Ou copie e execute este SQL:

```sql
BEGIN;

-- 1. Criar novo tipo com todos os valores
CREATE TYPE "PlanType_new" AS ENUM ('free', 'basic', 'advanced', 'complete', 'pro');

-- 2. Alterar coluna para usar o novo tipo
ALTER TABLE "organizations"
  ALTER COLUMN "plan_type" TYPE "PlanType_new"
  USING ("plan_type"::text::"PlanType_new");

-- 3. Remover tipo antigo
DROP TYPE "PlanType";

-- 4. Renomear novo tipo
ALTER TYPE "PlanType_new" RENAME TO "PlanType";

-- 5. Converter clientes 'pro' para 'complete'
UPDATE "organizations"
SET "plan_type" = 'complete'
WHERE "plan_type" = 'pro';

COMMIT;
```

---

### **PASSO 3: Verificar Migração**

Execute no DBeaver:

```sql
-- Ver distribuição de planos
SELECT plan_type, COUNT(*) as total
FROM organizations
GROUP BY plan_type
ORDER BY plan_type;

-- Ver clientes afetados (deve retornar 0 'pro')
SELECT id, name, plan_type
FROM organizations
WHERE plan_type = 'pro';
```

**Resultado esperado:**
- ❌ Nenhum cliente com plano `pro`
- ✅ Clientes com `free`, `basic`, `advanced`, `complete`

---

### **PASSO 4: Atualizar Código no Servidor**

No servidor Linux:

```bash
cd /var/www/organizadorjuridicomultitenant

# 1. Fazer pull das mudanças
git pull origin main

# 2. Gerar novo Prisma Client
npx prisma generate

# 3. Rebuild
npm run build

# 4. Restart
pm2 restart organizador-dev

# 5. Verificar logs
pm2 logs organizador-dev --lines 50
```

---

## 📊 Novos Limites por Plano

| Plano      | Documentos/mês | Usuários | Validação IA | Preço       |
|------------|----------------|----------|--------------|-------------|
| **Free**   | 50 (teste)     | 1        | ❌ Não       | Grátis      |
| **Basic**  | 300            | 1        | ❌ Não       | R$ 34,90/mês|
| **Advanced** | 600          | 3        | ✅ Sim (300) | R$ 69,90/mês|
| **Complete** | 1.200        | 5        | ✅ Ilimitada | R$ 99,90/mês|

### **Teste Grátis:**
- ⏰ **3 dias** corridos, OU
- 📄 **50 documentos processados**
- **O que acontecer primeiro!**

---

## 🔍 Testes Recomendados

Após migração, teste:

### **1. Criar novo usuário FREE:**
```
- Registrar nova conta
- Verificar se freeTrialEndsAt está 3 dias à frente
- Processar 1 documento
- Verificar se documentProcessedCount = 1
```

### **2. Testar limite FREE:**
```
- Processar 50 documentos
- Tentar processar o 51º
- Deve mostrar: "Você atingiu o limite de 50 documentos do teste grátis"
```

### **3. Testar upgrade:**
```
- Fazer upgrade de FREE para BASIC
- Verificar se pode processar mais de 50 documentos
- Verificar se o contador zerou (se for início de mês)
```

---

## 🛠️ Rollback (Se Necessário)

Se algo der errado, execute no DBeaver:

```sql
BEGIN;

-- Restaurar da tabela de backup
TRUNCATE organizations;
INSERT INTO organizations SELECT * FROM organizations_backup_20250127;

-- Restaurar enum antigo
CREATE TYPE "PlanType_old" AS ENUM ('free', 'basic', 'pro');
ALTER TABLE organizations ALTER COLUMN plan_type TYPE "PlanType_old" USING (plan_type::text::"PlanType_old");
DROP TYPE "PlanType";
ALTER TYPE "PlanType_old" RENAME TO "PlanType";

COMMIT;
```

---

## ✅ Checklist Final

- [ ] Backup do banco criado
- [ ] SQL de migração executado sem erros
- [ ] Verificação dos planos OK (nenhum 'pro' restante)
- [ ] Git pull no servidor
- [ ] npx prisma generate executado
- [ ] npm run build sem erros
- [ ] pm2 restart realizado
- [ ] Logs sem erros
- [ ] Teste de novo cadastro FREE funcionando
- [ ] Teste de limite de 50 docs funcionando
- [ ] Clientes existentes acessando normalmente

---

## 📞 Problemas?

Se algo der errado:

1. **NÃO entre em pânico** - o backup está salvo
2. Execute o Rollback acima
3. Verifique os logs: `pm2 logs organizador-dev`
4. Restaure o código antigo se necessário: `git reset --hard HEAD~1`

---

**Data de Criação:** 2025-01-27
**Autor:** Claude + Anderson Barros
