# Como Se Tornar SUPER ADMIN (Dono do Sistema)

## O Que é Super Admin?

O **Super Admin** é o dono do sistema (VOCÊ), que tem acesso total para gerenciar todas as organizações (escritórios de advocacia).

### Diferença entre roles:

| Role | Descrição | Acesso |
|------|-----------|--------|
| **super_admin** | **Dono do sistema (VOCÊ)** | Vê TODAS as organizações em `/admin` |
| **admin** | Admin da organização (cliente) | Gerencia apenas sua organização no `/dashboard` |
| **member** | Usuário comum | Acessa apenas `/dashboard` da sua organização |

---

## 📌 PASSO A PASSO: Tornar-se Super Admin

### Opção 1: Via Supabase SQL Editor (RECOMENDADO)

1. **Acesse o Supabase:**
   - Vá em: https://supabase.com/dashboard
   - Selecione seu projeto
   - Clique em "SQL Editor"

2. **Execute a migração:**
   ```sql
   -- Adicionar super_admin ao enum
   ALTER TYPE "UserRole" ADD VALUE IF NOT EXISTS 'super_admin';
   ```

3. **Crie sua conta no sistema:**
   - Acesse o sistema: http://localhost:3000/login
   - Clique em "Cadastrar"
   - Preencha: Nome, Email, Senha
   - Faça login

4. **Torne-se Super Admin:**
   - Volte ao Supabase SQL Editor
   - Execute (substitua pelo SEU email):
   ```sql
   UPDATE users
   SET role = 'super_admin'
   WHERE email = 'seu@email.com';
   ```

5. **Faça logout e login novamente:**
   - IMPORTANTE: O token JWT precisa ser regenerado!
   - Faça logout no sistema
   - Faça login novamente

6. **Acesse o Admin Dashboard:**
   - Vá em: http://localhost:3000/admin
   - Você verá TODAS as organizações cadastradas ✅

---

### Opção 2: Via Prisma Studio

1. **Execute a migração SQL primeiro** (Opção 1, passo 2)

2. **Abra o Prisma Studio:**
   ```bash
   npx prisma studio
   ```

3. **Encontre seu usuário:**
   - Clique em "User"
   - Encontre seu email

4. **Altere a role:**
   - Clique no campo "role"
   - Selecione "super_admin"
   - Clique em "Save 1 change"

5. **Faça logout e login novamente** no sistema

---

## 🔐 Verificando se Você é Super Admin

### Via DevTools (Navegador):

1. Abra o DevTools (F12)
2. Vá em "Console"
3. Cole e execute:
   ```javascript
   JSON.parse(atob(localStorage.getItem('token').split('.')[1]))
   ```
4. Verifique o campo `role` - deve ser **"super_admin"**

### Via Supabase:

```sql
SELECT id, name, email, role
FROM users
WHERE role = 'super_admin';
```

---

## 🚨 Segurança

### IMPORTANTE - Proteções Implementadas:

1. ✅ **Middleware:** Apenas `super_admin` acessa `/api/admin/*`
2. ✅ **Backend:** APIs verificam role via `requireSuperAdmin()`
3. ✅ **Frontend:** Página `/admin` verifica role no token JWT
4. ✅ **Removido:** Rota `/make-admin` foi deletada (era insegura)

### O Que SUPER ADMIN Pode Fazer:

- ✅ Ver TODAS as organizações em `/admin`
- ✅ Criar novas organizações
- ✅ Ver estatísticas globais (usuários, projetos, documentos)
- ✅ Monitorar uso de tokens IA e documentos
- ✅ Ver status de assinaturas e planos
- ❌ **NÃO pode acessar dados específicos dos clientes** (projetos, documentos)

---

## 📊 Estrutura do Sistema

```
┌─────────────────────────────────────────────┐
│           SUPER ADMIN (VOCÊ)                │
│         Acessa: /admin                      │
│   Vê: Todas as 4 organizações              │
└─────────────────────────────────────────────┘
                    │
        ┌───────────┼───────────┬──────────┐
        │           │           │          │
    ┌───▼───┐   ┌──▼────┐  ┌──▼────┐ ┌──▼────┐
    │ Org 1 │   │ Org 2 │  │ Org 3 │ │ Org 4 │
    │ Admin │   │ Admin │  │ Admin │ │ Admin │
    └───────┘   └───────┘  └───────┘ └───────┘
        │           │          │          │
    ┌───▼────┐  ┌──▼─────┐ ┌─▼──────┐ ┌─▼─────┐
    │Members │  │Members │ │Members │ │Members│
    └────────┘  └────────┘ └────────┘ └───────┘
```

---

## ❓ Troubleshooting

### "Acesso negado: apenas super administradores do sistema"

**Causa:** Você não tem role `super_admin` no banco

**Solução:**
1. Verifique se executou a migração SQL
2. Verifique se atualizou seu usuário no banco
3. Faça logout e login novamente
4. Verifique o token JWT (veja seção "Verificando")

### "Token inválido ou expirado"

**Causa:** Token não foi atualizado após virar super_admin

**Solução:**
- Faça logout
- Faça login novamente
- Isso vai gerar um novo token com `role: 'super_admin'`

### Erro 500 ao acessar /admin

**Causa:** Possível erro de migração ou banco

**Solução:**
1. Execute a migração SQL novamente
2. Rode `npx prisma generate` no terminal
3. Reinicie o servidor (`npm run dev`)

---

## 📝 Próximos Passos Após Se Tornar Super Admin

1. **Teste o Admin Dashboard:**
   - Acesse `/admin`
   - Verifique se vê sua organização
   - Confira os contadores (usuários, projetos, docs)

2. **Crie organizações de teste:**
   - Use o botão "Nova Organização"
   - Teste diferentes planos (Basic, Pro, Enterprise)

3. **Teste isolamento:**
   - Crie um segundo usuário em outra organização
   - Faça login como esse usuário
   - Tente acessar `/admin` → Deve dar erro 403 ✅

4. **Monitore uso:**
   - Veja documentos processados
   - Veja tokens IA consumidos
   - Teste limites de plano

---

## 🔧 Em Produção

### IMPORTANTE: Nunca exponha rota de criar super_admin!

Em produção, para criar novos super admins:

1. **Via CLI/SQL direto no banco:**
   ```sql
   UPDATE users
   SET role = 'super_admin'
   WHERE email = 'novo_admin@email.com';
   ```

2. **Ou crie um script administrativo seguro:**
   - Com autenticação de 2 fatores
   - Logs de auditoria
   - Apenas acessível via VPN/IP restrito

---

**LEMBRE-SE:**
- Apenas VOCÊ (dono do sistema) deve ter `super_admin`
- Seus clientes (escritórios) são `admin` das suas organizações
- Funcionários dos escritórios são `member`
