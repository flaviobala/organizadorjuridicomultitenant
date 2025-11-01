# Middleware Global de Limites - Documentação

## 📋 O que foi implementado

Um middleware global que **bloqueia automaticamente** operações quando os limites do plano forem atingidos.

---

## 🎯 Como Funciona

### 1. Rotas Monitoradas

O middleware verifica limites **ANTES** de executar estas operações:

- ✅ **Upload de documentos** (`/api/documents/upload`)
- ✅ **Processamento de IA** (`/api/ai/*`)
- ✅ **Criação de projetos** (`POST /api/projects`)

### 2. Verificações Realizadas

Para cada operação, o middleware verifica:

1. **Status da Assinatura:**
   - ❌ Bloqueado se `canceled`
   - ❌ Bloqueado se `past_due`
   - ✅ Permitido se `active` ou `trialing`

2. **Limite de Documentos:**
   - Compara `documentProcessedCount` com o limite do plano
   - Bloqueado se atingir o limite

3. **Limite de Tokens IA:**
   - Compara `aiTokenCount` com o limite do plano
   - Bloqueado se atingir o limite

### 3. Resposta Quando Bloqueado

```json
{
  "error": "Limite de documentos atingido (500). Faça upgrade do seu plano.",
  "upgradeRequired": true,
  "usage": {
    "documents": 500,
    "tokens": 250000
  },
  "limits": {
    "documents": 500,
    "tokens": 1000000
  }
}
```

**Status HTTP:** `403 Forbidden`

---

## 📊 Limites por Plano

```typescript
trialing: {
  maxDocuments: 50,
  maxTokens: 100000
}

basic: {
  maxDocuments: 500,
  maxTokens: 1000000
}

pro: {
  maxDocuments: 5000,
  maxTokens: 10000000
}

enterprise: {
  maxDocuments: -1,  // ilimitado
  maxTokens: -1      // ilimitado
}
```

---

## 🔧 Como Usar no Frontend

### Exemplo: Upload de Documento

```typescript
// Antes (sem tratamento de limite)
const uploadDocument = async (file: File) => {
  const formData = new FormData()
  formData.append('file', file)

  const response = await fetch('/api/documents/upload', {
    method: 'POST',
    headers: { 'Authorization': `Bearer ${token}` },
    body: formData
  })

  const data = await response.json()

  if (!response.ok) {
    alert(data.error) // Genérico
  }
}
```

```typescript
// Depois (com tratamento de limite)
import { useState } from 'react'
import UpgradeRequiredModal from '@/components/UpgradeRequiredModal'

const uploadDocument = async (file: File) => {
  const [upgradeModal, setUpgradeModal] = useState({ isOpen: false, error: null })

  const formData = new FormData()
  formData.append('file', file)

  const response = await fetch('/api/documents/upload', {
    method: 'POST',
    headers: { 'Authorization': `Bearer ${token}` },
    body: formData
  })

  const data = await response.json()

  if (!response.ok) {
    // Verificar se é erro de limite
    if (response.status === 403 && data.upgradeRequired) {
      setUpgradeModal({ isOpen: true, error: data })
    } else {
      alert(data.error) // Outro erro
    }
  }

  // Renderizar modal
  return (
    <UpgradeRequiredModal
      isOpen={upgradeModal.isOpen}
      onClose={() => setUpgradeModal({ isOpen: false, error: null })}
      error={upgradeModal.error}
    />
  )
}
```

---

## 🧪 Como Testar

### Teste 1: Atingir Limite de Documentos

1. **Criar organização de teste** com plano `trialing` (limite: 50 docs)

2. **Simular 50 documentos já processados:**

```sql
-- No Supabase SQL Editor
UPDATE organizations
SET document_processed_count = 50
WHERE id = 1; -- Sua org de teste
```

3. **Tentar fazer upload:**
   - Deve retornar erro 403
   - Mensagem: "Limite de documentos atingido"

### Teste 2: Assinatura Cancelada

1. **Cancelar assinatura:**

```sql
UPDATE organizations
SET subscription_status = 'canceled'
WHERE id = 1;
```

2. **Tentar qualquer operação bloqueada:**
   - Deve retornar erro 403
   - Mensagem: "Assinatura cancelada. Por favor, reative sua assinatura."

### Teste 3: Pagamento Atrasado

1. **Marcar como inadimplente:**

```sql
UPDATE organizations
SET subscription_status = 'past_due'
WHERE id = 1;
```

2. **Tentar operação:**
   - Deve retornar erro 403
   - Mensagem: "Pagamento em atraso. Por favor, atualize sua forma de pagamento."

### Teste 4: Plano Enterprise (Ilimitado)

1. **Atualizar para enterprise:**

```sql
UPDATE organizations
SET plan_type = 'enterprise',
    subscription_status = 'active'
WHERE id = 1;
```

2. **Fazer 10.000 uploads:**
   - Deve funcionar normalmente
   - Sem bloqueios

---

## ⚠️ Importante: Incrementar Contadores

O middleware **NÃO incrementa automaticamente** os contadores. Você deve fazer isso manualmente após a operação ser bem-sucedida.

### Exemplo Correto:

```typescript
// src/app/api/documents/upload/route.ts

export async function POST(request: NextRequest) {
  const auth = await requireAuth(request)

  // ... processar upload ...

  // ✅ IMPORTANTE: Incrementar contador após sucesso
  await prisma.organization.update({
    where: { id: auth.user.organizationId },
    data: {
      documentProcessedCount: {
        increment: 1
      }
    }
  })

  // Ou usar a função helper:
  // await incrementDocumentCount(auth.user.organizationId)

  return NextResponse.json({ success: true, document })
}
```

---

## 🚀 Próximos Passos

### 1. Integrar Modal em Todas as Páginas

Adicione o `UpgradeRequiredModal` em:
- Página de upload de documentos
- Página de criação de projetos
- Página de processamento de IA

### 2. Adicionar Warnings Preventivos

Antes de atingir 100% do limite, mostre avisos:

```typescript
if (usage.documents / limits.documents > 0.8) {
  showWarning('Você está próximo do limite de documentos (80%)')
}
```

### 3. Dashboard de Uso

Criar uma seção no dashboard mostrando:
- Uso atual vs. limite
- Barras de progresso
- Botão de upgrade

### 4. Emails de Notificação

Quando atingir 80%, 90%, 100% dos limites:
- Enviar email automático
- Sugerir upgrade

---

## 🔧 Customizações

### Adicionar Mais Rotas Bloqueadas

Edite o arquivo `src/middleware.ts`:

```typescript
const isResourceIntensiveOperation =
  pathname.startsWith('/api/documents/upload') ||
  pathname.startsWith('/api/ai/') ||
  pathname.startsWith('/api/projects') && request.method === 'POST' ||
  pathname.startsWith('/api/sua-nova-rota') // ✅ Adicionar aqui
```

### Ajustar Limites

Edite os limites em `src/middleware.ts`:

```typescript
const PLAN_LIMITS = {
  trialing: { maxDocuments: 100, maxTokens: 200000 }, // Alterado
  basic: { maxDocuments: 1000, maxTokens: 2000000 },  // Alterado
  // ...
}
```

**IMPORTANTE:** Sincronize com `src/lib/plan-limits.ts`!

### Fail Closed vs Fail Open

Atualmente, se houver erro ao buscar organização, o middleware **permite** (fail open):

```typescript
} catch (error) {
  console.error('❌ Erro ao verificar limites:', error)
  return { allowed: true } // ✅ Permite em caso de erro
}
```

Para **bloquear** em caso de erro (fail closed):

```typescript
} catch (error) {
  console.error('❌ Erro ao verificar limites:', error)
  return { allowed: false, reason: 'Erro ao verificar limites' } // ❌ Bloqueia
}
```

---

## 📊 Monitoramento

### Logs Importantes

O middleware loga:
- ✅ Quando bloqueia uma operação
- ✅ Motivo do bloqueio
- ✅ Uso atual vs. limite
- ❌ Erros ao buscar organização

### Exemplo de Log:

```
❌ Limite atingido para Org 1
   Motivo: Limite de documentos atingido (500)
   Uso: 500 / 500 documentos
   Tokens: 250000 / 1000000
```

---

## 🎯 Checklist de Implementação

- [x] ✅ Middleware global criado
- [x] ✅ Verificação de subscription_status
- [x] ✅ Verificação de limite de documentos
- [x] ✅ Verificação de limite de tokens
- [x] ✅ Modal de upgrade criado
- [ ] ⏳ Integrar modal em páginas
- [ ] ⏳ Adicionar warnings preventivos (80%, 90%)
- [ ] ⏳ Dashboard de uso
- [ ] ⏳ Emails de notificação

---

## 🆘 Troubleshooting

### Problema: Middleware não está bloqueando

**Causa:** Rota não está na lista de operações monitoradas

**Solução:** Adicione a rota em `isResourceIntensiveOperation`

### Problema: Bloqueando operações permitidas

**Causa:** Limites configurados incorretamente

**Solução:** Verifique `PLAN_LIMITS` no middleware

### Problema: Contador não incrementa

**Causa:** Esqueceu de incrementar após sucesso

**Solução:** Use `incrementDocumentCount()` após operação bem-sucedida

### Problema: Erro "Prisma is not defined"

**Causa:** Prisma não inicializado no middleware

**Solução:** Já está implementado, reinicie Next.js

---

**Implementado em:** 2025-10-31
**Última atualização:** 2025-10-31
