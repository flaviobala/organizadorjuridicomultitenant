# 🚀 Setup Asaas - Guia Completo

## O QUE É ASAAS?

Asaas é a melhor plataforma brasileira para pagamentos recorrentes (assinaturas). Oferece:
- ✅ Redirecionamento automático após pagamento
- ✅ Webhook super confiável
- ✅ UX otimizada para conversão
- ✅ Taxas competitivas (1,99% PIX, 2,99% cartão)
- ✅ Suporte em português

---

## 📋 PASSO 1: CRIAR CONTA NO ASAAS

### 1.1 Criar conta
1. Acesse: https://www.asaas.com
2. Clique em "Criar Conta"
3. Preencha os dados do CNPJ
4. Valide o email

### 1.2 Validação de conta
- Envie documentos (CNPJ, comprovante de endereço)
- Aguarde aprovação (1-2 dias úteis)
- Você receberá email quando aprovar

---

## 🔑 PASSO 2: OBTER API KEYS

### 2.1 Modo Sandbox (Testes)
1. Acesse: https://www.asaas.com/config/api
2. Clique em "Gerar nova chave de API"
3. **Marque "Ambiente de Testes (Sandbox)"**
4. Copie a chave (começa com `$aact_...`)

### 2.2 Modo Produção
1. Após conta validada, acesse: https://www.asaas.com/config/api
2. Clique em "Gerar nova chave de API"
3. **Deixe DESMARCADO "Ambiente de Testes"**
4. Copie a chave (começa com `$aact_...`)

---

## ⚙️ PASSO 3: CONFIGURAR .ENV

Adicione no `.env` (produção) ou `.env.local` (desenvolvimento):

```env
# ==================== ASAAS ====================
# API Key do Asaas (SANDBOX para testes, PRODUÇÃO para real)
ASAAS_API_KEY="$aact_YTU5YTE0M2M2N2I4MTliNzk0YTI5N2U5MzdjNWZmNDQ6OjAwMDAwMDAwMDAwMDAwODQ2ODY6OiRhYWNoXzBlNjVhMDRhLWNiZTEtNDk1ZC04YWEyLTA1YjJmZmIzNTAwZA=="

# URL pública do webhook (obrigatório para receber notificações)
NEXT_PUBLIC_APP_URL="https://app.advconecta.com.br"
```

**IMPORTANTE:**
- 🔴 **NUNCA** commite o arquivo `.env` com a chave de PRODUÇÃO
- ✅ Use `.env.local` para desenvolvimento (não vai para git)
- ✅ Configure a chave no servidor via painel de hospedagem

---

## 🔔 PASSO 4: CONFIGURAR WEBHOOKS

Os webhooks permitem que o Asaas notifique seu sistema quando um pagamento é confirmado.

### 4.1 Configurar URL do Webhook
1. Acesse: https://www.asaas.com/config/webhooks
2. Clique em "Adicionar webhook"
3. Configure:
   - **URL**: `https://app.advconecta.com.br/api/webhooks/asaas`
   - **Eventos**:
     - [x] PAYMENT_CREATED
     - [x] PAYMENT_UPDATED
     - [x] PAYMENT_CONFIRMED
     - [x] PAYMENT_RECEIVED
   - **Status**: Ativo
4. Salve

### 4.2 Testar Webhook (Sandbox)
```bash
curl -X POST https://app.advconecta.com.br/api/webhooks/asaas \
  -H "Content-Type: application/json" \
  -H "asaas-access-token: $aact_..." \
  -d '{
    "event": "PAYMENT_CONFIRMED",
    "payment": {
      "id": "pay_test123",
      "status": "CONFIRMED",
      "value": 34.90
    }
  }'
```

---

## 🗄️ PASSO 5: MIGRAÇÃO DO BANCO DE DADOS

Execute a migração do Prisma para adicionar os campos do Asaas:

```bash
# Gerar migração
npx prisma migrate dev --name add_asaas_fields

# Ou aplicar diretamente no banco
npx prisma db push
```

Isso adiciona os campos:
- `asaas_customer_id` - ID do cliente no Asaas
- `asaas_subscription_id` - ID da assinatura no Asaas

---

## 🎯 PASSO 6: TESTAR INTEGRAÇÃO

### 6.1 Fluxo de Teste em Sandbox

1. **Acesse a página de planos**
   ```
   https://app.advconecta.com.br/pricing
   ```

2. **Clique em "Assinar agora"**
   - Selecione qualquer plano (Basic, Advanced ou Complete)
   - Você será redirecionado para o checkout do Asaas

3. **Complete o pagamento**
   - **PIX**: Use PIX de teste (QR Code falso)
   - **Cartão**: Use cartões de teste do Asaas:
     - Número: `5162306219378829`
     - Validade: Qualquer data futura
     - CVV: `318`
     - Nome: Qualquer nome

4. **Aguarde redirecionamento**
   - Após aprovar, você será **automaticamente redirecionado** para `/payment-success`
   - Não precisa copiar URL nem nada manual!

5. **Verifique no dashboard**
   - Acesse `/dashboard`
   - Verifique se o plano foi ativado
   - Verifique se os limites estão corretos

### 6.2 Cartões de Teste (Sandbox)

| Bandeira | Número | CVV | Resultado |
|----------|--------|-----|-----------|
| Visa | 4539 0033 5251 8056 | 123 | ✅ Aprovado |
| Master | 5162 3062 1937 8829 | 318 | ✅ Aprovado |
| Elo | 6362 9704 1486 9107 | 701 | ✅ Aprovado |
| Qualquer | 4242 4242 4242 4242 | Qualquer | ❌ Recusado |

---

## 📊 PASSO 7: MONITORAR PAGAMENTOS

### 7.1 Painel do Asaas
Acesse: https://www.asaas.com/receivable

Você pode ver:
- Cobranças criadas
- Pagamentos confirmados
- Assinaturas ativas
- Webhooks enviados (e status)

### 7.2 Logs do Sistema
No terminal do Next.js, você verá:
```
📝 [ASAAS] Criando cliente: { organizationId: 3, name: "Escritório Silva" }
✅ [ASAAS] Cliente criado: cus_123456789
📝 [ASAAS] Criando assinatura: { planType: "basic", planPrice: 34.90 }
✅ [ASAAS] Assinatura criada: sub_987654321
🔔 [WEBHOOK ASAAS] Recebendo notificação...
📬 [WEBHOOK ASAAS] Evento: PAYMENT_CONFIRMED
✅ [WEBHOOK ASAAS] Organização 3 atualizada: basic - active
```

---

## 💰 PASSO 8: IR PARA PRODUÇÃO

### 8.1 Validar Conta
1. Envie documentação completa
2. Aguarde aprovação (1-2 dias)
3. Valide conta bancária para recebimento

### 8.2 Trocar API Key
No `.env` do servidor, troque a chave de sandbox para produção:

```env
# ANTES (Sandbox)
ASAAS_API_KEY="$aact_..._sandbox..."

# DEPOIS (Produção)
ASAAS_API_KEY="$aact_..._prod..."
```

### 8.3 Reconfigurar Webhook
1. Acesse webhooks em modo produção
2. Configure mesma URL: `https://app.advconecta.com.br/api/webhooks/asaas`
3. Ative os mesmos eventos

### 8.4 Fazer Teste Real
1. Crie uma assinatura de teste
2. Pague com cartão real (será cobrado!)
3. Verifique se ativou corretamente
4. Cancele a assinatura de teste

---

## 📁 ARQUIVOS DA INTEGRAÇÃO

### APIs criadas:
- `/api/billing/asaas/create-customer` - Cria cliente no Asaas
- `/api/billing/asaas/create-subscription` - Cria assinatura
- `/api/webhooks/asaas` - Recebe notificações de pagamento

### Componentes atualizados:
- `/components/PricingSection.tsx` - Página de planos
- `/app/payment-success/page.tsx` - Página de sucesso

---

## 🔍 TROUBLESHOOTING

### Erro: "ASAAS_API_KEY não configurada"
**Causa:** Variável de ambiente não foi configurada

**Solução:**
```bash
# Verifique se está no .env
cat .env | grep ASAAS_API_KEY

# Se não estiver, adicione:
echo 'ASAAS_API_KEY="sua_chave_aqui"' >> .env

# Reinicie o servidor
pm2 restart organizador-dev
```

### Erro: "Cliente não encontrado"
**Causa:** Organization não tem `asaasCustomerId`

**Solução:**
A API cria automaticamente, mas se der erro:
```bash
# Limpar e recriar
psql -d organizador_juridico -c "UPDATE organizations SET asaas_customer_id = NULL WHERE id = 3;"
```

### Webhook não está chegando
**Causa:** URL não configurada ou firewall bloqueando

**Verificar:**
1. Teste manualmente com curl (comando acima)
2. Verifique logs do Asaas: https://www.asaas.com/webhook/logs
3. Verifique se URL está acessível publicamente

---

## 💡 DICAS

1. **Use Sandbox primeiro**
   - Teste tudo em sandbox antes de produção
   - Cartões de teste não cobram de verdade

2. **Monitore os webhooks**
   - Asaas retentar em caso de falha
   - Logs ficam disponíveis no painel

3. **Customize os emails**
   - Asaas permite customizar emails de cobrança
   - Configure em: https://www.asaas.com/config/emails

4. **Split de pagamento**
   - Se quiser dividir pagamento entre organizações
   - Configure "split" nas assinaturas

---

## 📞 SUPORTE

- **Documentação**: https://docs.asaas.com
- **Suporte Asaas**: suporte@asaas.com ou chat no painel
- **Comunidade**: https://forum.asaas.com

---

**Última atualização:** 2025-01-28
