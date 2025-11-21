# Migração: Sistemas Multi-Tenant

## O que foi alterado?

Transformamos a tabela `system_configurations` para suportar **isolamento por organização** (multi-tenant).

### Antes
- Sistemas eram globais
- Todos os clientes viam os mesmos sistemas
- Um cliente podia criar um sistema que aparecia para todos

### Depois
- Cada organização tem seus próprios sistemas
- Sistemas são isolados por `organizationId`
- Sistemas padrão são criados automaticamente para cada organização

---

## Mudanças Implementadas

### 1. Schema do Prisma (`prisma/schema.prisma`)
✅ Adicionado campo `organizationId` em `SystemConfiguration`
✅ Adicionada relação com `Organization`
✅ Removido `@unique` global de `systemName`
✅ Adicionado `@@unique([organizationId, systemName])` - permite mesmo nome em orgs diferentes

### 2. API de Sistemas (`src/app/api/systems/route.ts`)
✅ **GET**: Filtra sistemas por `organizationId` do usuário logado
✅ **POST**: Cria sistemas vinculados à organização do usuário
✅ Verifica duplicatas apenas dentro da organização

### 3. Scripts
✅ **Migration SQL** (`prisma/migrations/add_organization_to_systems.sql`)
✅ **Seed de Sistemas Padrão** (`scripts/seed-default-systems.ts`)

---

## Como Aplicar as Mudanças

### Passo 1: Aplicar a Migration SQL

Execute a migration SQL manualmente no banco de dados:

```bash
# Opção 1: Via psql (recomendado)
psql -U seu_usuario -d organizador_juridico -f prisma/migrations/add_organization_to_systems.sql

# Opção 2: Via arquivo .sql no seu cliente SQL preferido
# Copie e execute o conteúdo de: prisma/migrations/add_organization_to_systems.sql
```

**O que a migration faz:**
1. Adiciona coluna `organization_id` em `system_configurations`
2. Para cada sistema existente, cria uma cópia para cada organização
3. Remove sistemas globais (sem `organization_id`)
4. Adiciona constraints e índices
5. Mostra quantos sistemas foram criados por organização

### Passo 2: Gerar Prisma Client Atualizado

```bash
npx prisma generate
```

### Passo 3: (Opcional) Popular Sistemas Padrão

Se você tem organizações **SEM sistemas**, execute o seed:

```bash
npx tsx scripts/seed-default-systems.ts
```

**Sistemas padrão criados:**
- e-SAJ (30 MB, 300 KB/página)
- PJe - 1o Grau (5 MB, 500 KB/página)
- PJe - 2o Grau (10 MB, 500 KB/página)
- PJe 2x (3 MB, 300 KB/página)
- PJe - TRT 1o Grau (3 MB, 500 KB/página)

---

## Verificação

### 1. Verificar no Banco de Dados

```sql
-- Ver quantos sistemas cada organização tem
SELECT
  o.name AS organization_name,
  COUNT(sc.id) AS total_systems,
  STRING_AGG(sc.system_name, ', ') AS systems
FROM organizations o
LEFT JOIN system_configurations sc ON sc.organization_id = o.id
GROUP BY o.id, o.name
ORDER BY o.name;
```

### 2. Verificar no Frontend

1. Faça login como usuário da **Organização A**
2. Vá em **Novo Projeto** ou **Editar Projeto**
3. Veja a lista de sistemas no dropdown
4. Adicione um novo sistema personalizado

5. Faça login como usuário da **Organização B**
6. Veja a lista de sistemas - NÃO deve aparecer o sistema criado pela Org A
7. A Organização B deve ver apenas seus próprios sistemas

---

## Funcionalidades

### ✅ Isolamento Completo
- Cada organização vê apenas seus próprios sistemas
- Não há vazamento de dados entre organizações

### ✅ Sistemas Padrão Automáticos
- Ao criar nova organização, você pode rodar o seed para popular sistemas padrão
- Ou criar manualmente via interface

### ✅ Personalização
- Cada organização pode criar sistemas personalizados
- Pode ter sistemas com mesmo nome de outra org (ex: ambas podem ter "e-SAJ" com configurações diferentes)

---

## Rollback (Em caso de problemas)

Se precisar reverter as mudanças:

```sql
BEGIN;

-- 1. Remover constraint unique composto
DROP INDEX IF EXISTS idx_system_configurations_org_name;

-- 2. Remover foreign key
ALTER TABLE system_configurations
DROP CONSTRAINT IF EXISTS fk_system_configurations_organization;

-- 3. Remover coluna organization_id
ALTER TABLE system_configurations
DROP COLUMN IF EXISTS organization_id;

-- 4. Re-adicionar unique constraint global
ALTER TABLE system_configurations
ADD CONSTRAINT system_configurations_system_name_key
UNIQUE (system_name);

COMMIT;

-- 5. Reverter schema do Prisma manualmente
-- 6. Rodar: npx prisma generate
```

---

## Suporte

Se encontrar problemas:

1. Verifique logs do console (API systems)
2. Verifique se `organizationId` está sendo enviado corretamente
3. Execute as queries SQL de verificação acima
4. Verifique se o Prisma Client foi regenerado (`npx prisma generate`)

---

## Checklist de Implementação

- [ ] Executar migration SQL no banco
- [ ] Executar `npx prisma generate`
- [ ] (Opcional) Executar seed de sistemas padrão
- [ ] Testar criação de sistema pela UI
- [ ] Testar visualização de sistemas (apenas da org)
- [ ] Testar com 2+ organizações diferentes
- [ ] Verificar isolamento (org A não vê sistemas da org B)

---

**Data**: 2025-01-19
**Autor**: Claude
**Versão**: 1.0
