// src/app/api/webhooks/asaas/route.ts
import { NextRequest, NextResponse } from 'next/server'
import { prisma } from '@/lib/prisma'

/**
 * POST /api/webhooks/asaas
 * Processa webhooks do Asaas
 *
 * Eventos principais:
 * - PAYMENT_CREATED: Cobrança criada
 * - PAYMENT_UPDATED: Cobrança atualizada (aprovada, rejeitada, etc)
 * - PAYMENT_CONFIRMED: Pagamento confirmado
 * - PAYMENT_RECEIVED: Pagamento recebido
 * - PAYMENT_OVERDUE: Pagamento vencido
 * - PAYMENT_DELETED: Cobrança deletada
 */
export async function POST(request: NextRequest) {
  try {
    const body = await request.json()

    console.log('🔔 [WEBHOOK ASAAS] Recebendo notificação...')
    console.log('📦 [WEBHOOK ASAAS] Dados:', JSON.stringify(body, null, 2))

    const { event, payment } = body

    // Validar token do webhook (recomendado em produção)
    const webhookToken = request.headers.get('asaas-access-token')
    if (process.env.NODE_ENV === 'production' && webhookToken !== process.env.ASAAS_API_KEY) {
      console.error('❌ [WEBHOOK ASAAS] Token inválido')
      return NextResponse.json({ error: 'Invalid token' }, { status: 401 })
    }

    console.log(`📬 [WEBHOOK ASAAS] Evento: ${event}`)

    // Processar apenas eventos de pagamento confirmado/recebido
    if (!['PAYMENT_CONFIRMED', 'PAYMENT_RECEIVED', 'PAYMENT_UPDATED'].includes(event)) {
      console.log(`ℹ️ [WEBHOOK ASAAS] Evento ${event} ignorado`)
      return NextResponse.json({ received: true })
    }

    if (!payment || !payment.id) {
      console.error('❌ [WEBHOOK ASAAS] Dados de pagamento inválidos')
      return NextResponse.json({ error: 'Invalid payment data' }, { status: 400 })
    }

    // Buscar detalhes completos do pagamento via API
    const paymentDetails = await fetchPaymentDetails(payment.id)

    if (!paymentDetails) {
      console.error('❌ [WEBHOOK ASAAS] Não foi possível buscar detalhes do pagamento')
      return NextResponse.json({ error: 'Could not fetch payment details' }, { status: 500 })
    }

    console.log('📊 [WEBHOOK ASAAS] Status do pagamento:', paymentDetails.status)
    console.log('📊 [WEBHOOK ASAAS] Valor:', paymentDetails.value)

    // Processar apenas se confirmado ou recebido
    if (!['CONFIRMED', 'RECEIVED'].includes(paymentDetails.status)) {
      console.log(`⚠️ [WEBHOOK ASAAS] Pagamento não confirmado ainda: ${paymentDetails.status}`)
      return NextResponse.json({ received: true })
    }

    // Buscar assinatura pelo ID do cliente ou externalReference
    const subscription = paymentDetails.subscription
      ? await fetchSubscriptionDetails(paymentDetails.subscription)
      : null

    if (!subscription) {
      console.warn('⚠️ [WEBHOOK ASAAS] Assinatura não encontrada, pode ser pagamento avulso')
      return NextResponse.json({ received: true })
    }

    // Extrair organizationId do externalReference
    const externalRef = subscription.externalReference
    const organizationId = externalRef ? parseInt(externalRef.split('-')[0]) : null

    if (!organizationId) {
      console.error('❌ [WEBHOOK ASAAS] organizationId não encontrado no externalReference')
      return NextResponse.json({ error: 'Organization ID not found' }, { status: 400 })
    }

    // Mapear valor para plano
    const amount = paymentDetails.value
    let planType = 'basic'

    if (amount >= 90) {
      planType = 'complete'
    } else if (amount >= 60) {
      planType = 'advanced'
    } else if (amount >= 30) {
      planType = 'basic'
    }

    console.log(`💰 [WEBHOOK ASAAS] Valor: R$ ${amount} → Plano: ${planType}`)

    // Atualizar organização
    await prisma.organization.update({
      where: { id: organizationId },
      data: {
        planType: planType as any,
        subscriptionStatus: 'active',
        asaasSubscriptionId: subscription.id,
        documentProcessedCount: 0, // Resetar contadores mensais
        aiTokenCount: 0,
        updatedAt: new Date()
      }
    })

    console.log(`✅ [WEBHOOK ASAAS] Organização ${organizationId} atualizada: ${planType} - active`)

    return NextResponse.json({ received: true, processed: true })

  } catch (error) {
    console.error('❌ [WEBHOOK ASAAS] Erro ao processar:', error)
    return NextResponse.json({
      error: 'Internal server error',
      received: true // Retornar true para Asaas não reenviar
    }, { status: 500 })
  }
}

/**
 * Busca detalhes do pagamento via API do Asaas
 */
async function fetchPaymentDetails(paymentId: string): Promise<any> {
  try {
    const apiKey = process.env.ASAAS_API_KEY

    const response = await fetch(`https://www.asaas.com/api/v3/payments/${paymentId}`, {
      headers: {
        'access_token': apiKey!
      }
    })

    if (!response.ok) {
      console.error(`❌ [ASAAS API] Erro ao buscar pagamento ${paymentId}: ${response.status}`)
      return null
    }

    return await response.json()

  } catch (error) {
    console.error('❌ [ASAAS API] Erro na requisição:', error)
    return null
  }
}

/**
 * Busca detalhes da assinatura via API do Asaas
 */
async function fetchSubscriptionDetails(subscriptionId: string): Promise<any> {
  try {
    const apiKey = process.env.ASAAS_API_KEY

    const response = await fetch(`https://www.asaas.com/api/v3/subscriptions/${subscriptionId}`, {
      headers: {
        'access_token': apiKey!
      }
    })

    if (!response.ok) {
      console.error(`❌ [ASAAS API] Erro ao buscar assinatura ${subscriptionId}: ${response.status}`)
      return null
    }

    return await response.json()

  } catch (error) {
    console.error('❌ [ASAAS API] Erro na requisição:', error)
    return null
  }
}
