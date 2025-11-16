// src/app/api/webhooks/mercadopago/route.ts
import { NextRequest, NextResponse } from 'next/server'
import { prisma } from '@/lib/prisma'
import crypto from 'crypto'

/**
 * POST /api/webhooks/mercadopago
 * Processa eventos de webhook do Mercado Pago
 *
 * Eventos principais de assinaturas:
 * - subscription_preapproval: Criação/atualização de assinatura
 * - subscription_authorized_payment: Pagamento recorrente processado
 * - subscription_preapproval_plan: Plano criado/vinculado
 */
export async function POST(request: NextRequest) {
  try {
    console.log('🔔 [WEBHOOK MP] Recebendo notificação...')

    // Parsear corpo primeiro
    const body = await request.json()
    console.log('📦 [WEBHOOK MP] Dados recebidos:', JSON.stringify(body, null, 2))

    // Validar assinatura do webhook
    const signature = request.headers.get('x-signature')
    const requestId = request.headers.get('x-request-id')

    // Validação de assinatura ativada
    const isProduction = process.env.NODE_ENV === 'production'
    const FORCE_ACCEPT_UNSIGNED = false

    if (signature && !FORCE_ACCEPT_UNSIGNED) {
      // Se tem signature, validar
      const isValid = await validateSignature(signature, body, request.headers.get('x-timestamp') || '')

      if (!isValid) {
        if (isProduction) {
          console.error('❌ [WEBHOOK MP] Assinatura inválida em PRODUÇÃO')
          return NextResponse.json({ error: 'Invalid signature' }, { status: 401 })
        } else {
          console.warn('⚠️ [WEBHOOK MP] Assinatura inválida, mas aceitando em DEV/TEST')
        }
      }
    } else {
      // Sem signature ou modo forçado
      if (FORCE_ACCEPT_UNSIGNED) {
        console.warn('⚠️ [WEBHOOK MP] Aceitando webhook sem validação de assinatura (modo teste)')
      } else if (isProduction) {
        console.error('❌ [WEBHOOK MP] Assinatura ausente em PRODUÇÃO')
        return NextResponse.json({ error: 'Missing signature' }, { status: 401 })
      } else {
        console.warn('⚠️ [WEBHOOK MP] Assinatura ausente - modo DEV/TEST, aceitando...')
      }
    }

    // Extrair tipo de evento e dados
    const { type, action, data } = body

    console.log(`📬 [WEBHOOK MP] Evento: ${type} - Ação: ${action}`)

    // Processar evento baseado no tipo
    switch (type) {
      case 'subscription_preapproval':
        await handleSubscriptionPreapproval(data, action)
        break

      case 'subscription_authorized_payment':
        await handleSubscriptionPayment(data, action)
        break

      case 'subscription_preapproval_plan':
        await handleSubscriptionPlan(data, action)
        break

      default:
        console.log(`ℹ️ [WEBHOOK MP] Evento ${type} não processado (não relacionado a assinaturas)`)
    }

    return NextResponse.json({ success: true, received: true })

  } catch (error) {
    console.error('❌ [WEBHOOK MP] Erro ao processar:', error)
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    )
  }
}

/**
 * Valida assinatura HMAC SHA256 do webhook
 */
async function validateSignature(signature: string, body: any, timestamp: string): Promise<boolean> {
  try {
    const secret = process.env.MERCADOPAGO_WEBHOOK_SECRET

    if (!secret) {
      console.warn('⚠️ [WEBHOOK MP] Secret não configurado - pulando validação (DEV ONLY!)')
      return true // Em dev, aceitar sem validação
    }

    // Extrair ts e v1 do header x-signature
    // Formato: "ts=1234567890,v1=hash"
    const parts = signature.split(',')
    const tsMatch = parts.find(p => p.startsWith('ts='))
    const v1Match = parts.find(p => p.startsWith('v1='))

    if (!tsMatch || !v1Match) {
      console.error('❌ [WEBHOOK MP] Formato de assinatura inválido')
      return false
    }

    const ts = tsMatch.split('=')[1]
    const receivedHash = v1Match.split('=')[1]

    // Construir string para validação: id;ts;body
    const dataId = body.data?.id || body.id || ''
    const manifest = `${dataId};${ts};${JSON.stringify(body)}`

    // Gerar hash HMAC SHA256
    const expectedHash = crypto
      .createHmac('sha256', secret)
      .update(manifest)
      .digest('hex')

    const isValid = expectedHash === receivedHash

    if (!isValid) {
      console.error('❌ [WEBHOOK MP] Hash não confere')
      console.error('Esperado:', expectedHash)
      console.error('Recebido:', receivedHash)
    }

    return isValid

  } catch (error) {
    console.error('❌ [WEBHOOK MP] Erro ao validar assinatura:', error)
    return false
  }
}

/**
 * Processa eventos de assinatura (criação, atualização, cancelamento)
 */
async function handleSubscriptionPreapproval(data: any, action: string) {
  try {
    const subscriptionId = data.id

    console.log(`🔄 [ASSINATURA] Processando preapproval: ${subscriptionId} - Ação: ${action}`)

    // Buscar detalhes da assinatura via API do MP
    const subscriptionDetails = await fetchSubscriptionDetails(subscriptionId)

    if (!subscriptionDetails) {
      console.error('❌ [ASSINATURA] Não foi possível buscar detalhes')
      return
    }

    // Extrair dados importantes
    const { status, payer_email, external_reference, reason } = subscriptionDetails

    // external_reference deve conter o organizationId
    const organizationId = external_reference ? parseInt(external_reference) : null

    if (!organizationId) {
      console.error('❌ [ASSINATURA] organizationId não encontrado no external_reference')
      return
    }

    // Mapear status do MP para nosso enum
    const subscriptionStatus = mapMercadoPagoStatus(status)

    // Atualizar organização
    await prisma.organization.update({
      where: { id: organizationId },
      data: {
        subscriptionStatus,
        updatedAt: new Date()
      }
    })

    console.log(`✅ [ASSINATURA] Org ${organizationId} atualizada: ${subscriptionStatus}`)

    // Se foi cancelada, logar
    if (status === 'cancelled') {
      console.log(`🚫 [ASSINATURA] Assinatura ${subscriptionId} cancelada - Org ${organizationId}`)
    }

  } catch (error) {
    console.error('❌ [ASSINATURA] Erro ao processar preapproval:', error)
  }
}

/**
 * Processa eventos de pagamento recorrente
 */
async function handleSubscriptionPayment(data: any, action: string) {
  try {
    const paymentId = data.id

    console.log(`💳 [PAGAMENTO] Processando pagamento: ${paymentId} - Ação: ${action}`)

    // Tentar buscar como pagamento primeiro
    let paymentDetails = await fetchPaymentDetails(paymentId)
    let organizationId: number | null = null

    // Se não encontrou como payment, pode ser que o ID seja de preapproval
    if (!paymentDetails) {
      console.log(`⚠️ [PAGAMENTO] ID ${paymentId} não é um payment, tentando buscar como preapproval...`)

      // Buscar como assinatura
      const subscription = await fetchSubscriptionDetails(paymentId)

      if (subscription && subscription.external_reference) {
        organizationId = parseInt(subscription.external_reference)

        // Para assinaturas, considerar como ativo se status for 'authorized'
        if (subscription.status === 'authorized') {
          console.log(`✅ [PAGAMENTO] Assinatura ${paymentId} está autorizada - Org ${organizationId}`)

          await prisma.organization.update({
            where: { id: organizationId },
            data: {
              subscriptionStatus: 'active',
              documentProcessedCount: 0,
              aiTokenCount: 0,
              updatedAt: new Date()
            }
          })

          console.log(`🔄 [PAGAMENTO] Contadores resetados para Org ${organizationId}`)
          return
        }
      } else {
        console.error('❌ [PAGAMENTO] Não foi possível buscar detalhes como payment ou preapproval')
        return
      }
    }

    // Se chegou aqui, encontrou como payment
    const { status, external_reference, preapproval_id } = paymentDetails

    // external_reference ou buscar via preapproval_id
    organizationId = external_reference ? parseInt(external_reference) : null

    if (!organizationId && preapproval_id) {
      // Buscar organization via assinatura
      const subscription = await fetchSubscriptionDetails(preapproval_id)
      organizationId = subscription?.external_reference ? parseInt(subscription.external_reference) : null
    }

    if (!organizationId) {
      console.error('❌ [PAGAMENTO] organizationId não encontrado')
      return
    }

    // Processar baseado no status do pagamento
    if (status === 'approved') {
      console.log(`✅ [PAGAMENTO] Pagamento aprovado - Org ${organizationId}`)

      // Atualizar status para active e resetar contadores
      await prisma.organization.update({
        where: { id: organizationId },
        data: {
          subscriptionStatus: 'active',
          documentProcessedCount: 0, // Resetar contadores mensais
          aiTokenCount: 0,
          updatedAt: new Date()
        }
      })

      console.log(`🔄 [PAGAMENTO] Contadores resetados para Org ${organizationId}`)

    } else if (status === 'rejected' || status === 'cancelled') {
      console.log(`❌ [PAGAMENTO] Pagamento ${status} - Org ${organizationId}`)

      // Atualizar para past_due (inadimplente)
      await prisma.organization.update({
        where: { id: organizationId },
        data: {
          subscriptionStatus: 'past_due',
          updatedAt: new Date()
        }
      })
    }

  } catch (error) {
    console.error('❌ [PAGAMENTO] Erro ao processar pagamento:', error)
  }
}

/**
 * Processa eventos de plano de assinatura
 */
async function handleSubscriptionPlan(data: any, action: string) {
  console.log(`📋 [PLANO] Evento de plano: ${data.id} - Ação: ${action}`)
  // Por enquanto só logamos, pode ser útil para analytics
}

/**
 * Mapeia status do Mercado Pago para nosso enum
 */
function mapMercadoPagoStatus(mpStatus: string): 'active' | 'past_due' | 'canceled' | 'trialing' {
  const statusMap: Record<string, 'active' | 'past_due' | 'canceled' | 'trialing'> = {
    'authorized': 'active',
    'paused': 'past_due',
    'cancelled': 'canceled',
    'pending': 'trialing'
  }

  return statusMap[mpStatus] || 'trialing'
}

/**
 * Busca detalhes da assinatura via API do Mercado Pago
 */
async function fetchSubscriptionDetails(subscriptionId: string): Promise<any> {
  try {
    const accessToken = process.env.MERCADOPAGO_ACCESS_TOKEN

    const response = await fetch(`https://api.mercadopago.com/preapproval/${subscriptionId}`, {
      headers: {
        'Authorization': `Bearer ${accessToken}`
      }
    })

    if (!response.ok) {
      console.error(`❌ [MP API] Erro ao buscar assinatura ${subscriptionId}: ${response.status}`)
      return null
    }

    return await response.json()

  } catch (error) {
    console.error('❌ [MP API] Erro na requisição:', error)
    return null
  }
}

/**
 * Busca detalhes do pagamento via API do Mercado Pago
 */
async function fetchPaymentDetails(paymentId: string): Promise<any> {
  try {
    const accessToken = process.env.MERCADOPAGO_ACCESS_TOKEN

    const response = await fetch(`https://api.mercadopago.com/v1/payments/${paymentId}`, {
      headers: {
        'Authorization': `Bearer ${accessToken}`
      }
    })

    if (!response.ok) {
      console.error(`❌ [MP API] Erro ao buscar pagamento ${paymentId}: ${response.status}`)
      return null
    }

    return await response.json()

  } catch (error) {
    console.error('❌ [MP API] Erro na requisição:', error)
    return null
  }
}
