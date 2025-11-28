# Instruções para Testar o Fluxo de Pagamento MercadoPago

## Problema Identificado

O MercadoPago não redireciona automaticamente de volta para o sistema após a aprovação de uma assinatura (PreApproval). O botão "Voltar para o site" redireciona para `https://www.mercadopago.com.br/subscriptions` em vez da `back_url` configurada.

## Solução Temporária Implementada

Criamos uma página de confirmação manual que você deve acessar após concluir o pagamento.

---

## Fluxo Completo de Teste

### 1. Iniciar Assinatura

1. Faça login no sistema com o usuário de teste
2. Acesse a página de planos: `/pricing`
3. Leia o banner azul com as instruções
4. Clique em "Assinar agora" no plano desejado (Basic, Advanced ou Complete)
5. Você será redirecionado para o checkout do MercadoPago

### 2. Completar Pagamento no MercadoPago

1. Na tela do MercadoPago, escolha a forma de pagamento:
   - **Pix**: Mais rápido para testes
   - **Cartão de teste**: Use os dados fornecidos pelo MP
   - **Boleto**: Demora mais para aprovar

2. Complete o pagamento

3. Aguarde a tela de aprovação:
   ```
   Pronto! Você atualizou seu meio de pagamento
   [Voltar para o site]
   ```

### 3. Ativar Assinatura Manualmente

**IMPORTANTE:** Não clique em "Voltar para o site" (ele vai para o lugar errado)

Em vez disso:

1. Copie esta URL (substitua `SEU_DOMINIO` pela URL do seu ngrok):
   ```
   https://SEU_DOMINIO.ngrok-free.app/confirmar-pagamento
   ```

2. Cole a URL em uma nova aba do navegador

3. Você verá a página de confirmação com:
   - Informações do plano contratado
   - ID da assinatura
   - Instruções de uso
   - Botão "Ativar Minha Assinatura"

4. Clique no botão "Ativar Minha Assinatura"

5. O sistema vai:
   - Verificar o pagamento no MercadoPago
   - Atualizar o banco de dados (planType, subscriptionStatus)
   - Redirecionar para o dashboard

### 4. Verificar no Dashboard

Após a ativação, você será redirecionado para `/dashboard` onde poderá ver:

- **SubscriptionCard**: Card mostrando o plano atual e status
- **Status da assinatura**:
  - Verde = Ativa
  - Azul = Trial
  - Amarelo = Pagamento Atrasado
  - Vermelho = Cancelada

### 5. Gerenciar Assinatura

No dashboard, clique em "Gerenciar Assinatura" para ver:
- Plano atual
- Status da assinatura
- Uso de documentos (com barra de progresso)
- Uso de tokens IA (com barra de progresso)
- Recursos incluídos
- Botão para fazer upgrade

---

## URLs Importantes

### URL para Confirmação Manual (copie esta!)
```
https://SEU_DOMINIO.ngrok-free.app/confirmar-pagamento
```

### Outras URLs do Fluxo
- Pricing: `/pricing`
- Dashboard: `/dashboard`
- Gerenciar Assinatura: `/subscription`
- Payment Success (automático): `/payment-success`

---

## Endpoints da API

### Criar Assinatura
```
POST /api/billing/mercadopago/create-subscription
Authorization: Bearer TOKEN
Body: { "planType": "basic" | "advanced" | "complete" }
```

### Processar Retorno
```
GET /api/billing/mercadopago/process-return
  ?organizationId=X
  &plan=basic
  &subscriptionId=XXX
Authorization: Bearer TOKEN
```

### Consultar Assinatura
```
GET /api/subscription
Authorization: Bearer TOKEN
```

### Webhook (ainda não funciona)
```
POST /api/webhooks/mercadopago
```

---

## Verificação de Status no Banco

Após a ativação, verifique no Supabase:

```sql
SELECT
  id,
  name,
  planType,
  subscriptionStatus,
  mercadoPagoSubscriptionId,
  documentProcessedCount,
  aiTokenCount
FROM "Organization"
WHERE id = YOUR_ORG_ID;
```

Deve mostrar:
- `planType`: "free", "basic", "advanced" ou "complete"
- `subscriptionStatus`: "active"
- `mercadoPagoSubscriptionId`: ID da assinatura do MP

---

## Limites por Plano

Configurados em `src/lib/plan-limits.ts`:

### Free (Teste Grátis)
- 15 documentos
- Duração: 3 dias
- 1 usuário
- Sem validação de pertinência

### Basic (R$ 34,90/mês)
- 300 documentos por mês
- Tokens IA ilimitados
- 1 usuário
- Sem validação de pertinência

### Advanced (R$ 69,90/mês)
- 600 documentos por mês
- Tokens IA ilimitados
- 3 usuários
- Validação de pertinência (300 docs/mês)

### Complete (R$ 99,90/mês)
- 1.200 documentos por mês
- Tokens IA ilimitados
- 5 usuários
- Validação de pertinência ilimitada

---

## Próximos Passos

### Para Produção

1. Os valores já estão configurados corretamente em `/components/PricingSection.tsx`:
   - Basic: R$ 34,90/mês
   - Advanced: R$ 69,90/mês
   - Complete: R$ 99,90/mês

2. Usar credenciais de produção no `.env.local`:
   ```env
   MERCADOPAGO_ACCESS_TOKEN=APP_USR-prod-token
   NEXT_PUBLIC_MERCADOPAGO_PUBLIC_KEY=APP_USR-prod-public-key
   MERCADOPAGO_TEST_USER_EMAIL=email@real.com
   ```

3. Testar webhook em produção (pode funcionar diferente)

4. Implementar cancelamento de assinatura

5. Implementar mudança de plano

### Melhorias Futuras

- [ ] Investigar por que `back_url` não funciona para assinaturas
- [ ] Tentar usar `notification_url` em vez de webhook
- [ ] Adicionar email de confirmação após ativação
- [ ] Implementar sistema de retry para webhooks
- [ ] Adicionar logs mais detalhados de pagamento
- [ ] Criar página de histórico de pagamentos
- [ ] Implementar downgrade de plano

---

## Troubleshooting

### Pagamento não está atualizando o banco

**Possíveis causas:**
1. Você não acessou `/confirmar-pagamento` manualmente
2. Token expirou (faça login novamente)
3. Subscription ID incorreto no localStorage
4. MP não aprovou o pagamento ainda

**Como resolver:**
1. Acesse `/confirmar-pagamento` manualmente
2. Verifique o console do navegador para erros
3. Verifique os logs do Next.js no terminal
4. Consulte o status no painel do MercadoPago

### Webhook não está chegando

**Isso é esperado!** O webhook do MercadoPago pode não funcionar imediatamente em ambiente de teste. Por isso criamos o fluxo manual.

**Para testar webhook:**
1. Verifique se está configurado no painel do MP
2. URL deve ser: `https://SEU_DOMINIO.ngrok-free.app/api/webhooks/mercadopago`
3. Verifique se o ngrok está rodando
4. Teste manualmente com curl ou Postman

### "Nenhum pagamento pendente encontrado"

**Causa:** localStorage foi limpo ou você acessou de outro navegador

**Solução:**
1. Volte para `/pricing`
2. Faça uma nova assinatura
3. Ou adicione manualmente no console do navegador:
   ```javascript
   localStorage.setItem('pending_payment', JSON.stringify({
     plan: 'basic',
     subscriptionId: 'SEU_SUBSCRIPTION_ID',
     timestamp: Date.now()
   }))
   ```

---

## Contatos e Suporte

Se encontrar problemas:

1. Verifique os logs no terminal do Next.js
2. Verifique o console do navegador (F12)
3. Consulte a documentação do MercadoPago: https://www.mercadopago.com.br/developers
4. Verifique o status no painel do MP: https://www.mercadopago.com.br/subscriptions

---

**Última atualização:** 2025-10-30
