# 🚀 Como Executar a Migration - Sistemas Multi-Tenant

## Erro Atual
```
The column `system_configurations.organization_id` does not exist in the current database.
```

## Solução: Executar Migration em 4 Passos

---

### ✅ Passo 1: Parar o servidor Next.js

No terminal onde está rodando `npm run dev`, pressione:
```
Ctrl + C
```

Aguarde até o servidor parar completamente.

---

### ✅ Passo 2: Executar a Migration SQL no Banco

Você tem 3 opções:

#### **Opção A: Via psql (Recomendado)**
```bash
psql -U postgres -d organizador_juridico -f prisma/migrations/add_organization_to_systems.sql
```

#### **Opção B: Via pgAdmin**
1. Abra o pgAdmin
2. Conecte ao banco `organizador_juridico`
3. Clique com botão direito no banco > Query Tool
4. Copie e cole o conteúdo do arquivo: `prisma/migrations/add_organization_to_systems.sql`
5. Clique em "Execute" (F5)

#### **Opção C: Via DBeaver / Outro Cliente SQL**
1. Conecte ao banco `organizador_juridico`
2. Abra um novo SQL Editor
3. Copie e cole o conteúdo do arquivo: `prisma/migrations/add_organization_to_systems.sql`
4. Execute o script

---

### ✅ Passo 3: Gerar Prisma Client Atualizado

```bash
npx prisma generate
```

**Se der erro "EPERM"**: Aguarde 5 segundos e tente novamente.

---

### ✅ Passo 4: Reiniciar o Servidor

```bash
npm run dev
```

---

## 🧪 Testar se Funcionou

1. Acesse a aplicação
2. Vá em **Criar Projeto** ou **Editar Projeto**
3. O dropdown de sistemas deve carregar sem erros
4. Você deve ver os sistemas da sua organização

---

## ❓ Ainda com Problemas?

### Verificar se a migration foi executada:

```sql
-- Execute no banco de dados:
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'system_configurations'
  AND column_name = 'organization_id';
```

**Resultado esperado**: Deve retornar uma linha mostrando a coluna `organization_id`

Se não retornar nada, a migration não foi executada corretamente.

---

### Verificar quantos sistemas foram criados:

```sql
SELECT
  o.name AS organization_name,
  COUNT(sc.id) AS total_systems
FROM organizations o
LEFT JOIN system_configurations sc ON sc.organization_id = o.id
GROUP BY o.id, o.name
ORDER BY o.name;
```

---

## 📋 Checklist Rápido

- [ ] Parar servidor Next.js
- [ ] Executar migration SQL
- [ ] Confirmar que migration executou sem erros
- [ ] Executar `npx prisma generate`
- [ ] Reiniciar servidor
- [ ] Testar criação/edição de projeto
- [ ] Verificar que sistemas carregam corretamente

---

**Data**: 2025-01-19
