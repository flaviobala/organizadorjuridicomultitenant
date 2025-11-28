// src/app/api/billing/mercadopago/check-subscription/route.ts
import { NextRequest, NextResponse } from 'next/server'
import { requireAuth } from '@/lib/auth'
import { prisma } from '@/lib/prisma'

/**
 * POST /api/billing/mercadopago/check-subscription
 * Verifica status da assinatura no MercadoPago e atualiza banco
 */
export async function POST(request: NextRequest) {
  try {
    console.log('🔍 [CHECK SUBSCRIPTION] Iniciando verificação...')

    // 1. Autenticar usuário
    const auth = await requireAuth(request)
    if (!auth.success || !auth.user) {
      console.error('❌ [CHECK SUBSCRIPTION] Erro de autenticação:', auth.error)
      return NextResponse.json({
        success: false,
        error: auth.error || 'Não autenticado'
      }, { status: 401 })
    }

    console.log('✅ [CHECK SUBSCRIPTION] Usuário autenticado:', auth.user.email)

    // 2. Obter subscriptionId do body
    const body = await request.json()
    const { subscriptionId } = body

    if (!subscriptionId) {
      console.error('❌ [CHECK SUBSCRIPTION] subscriptionId não fornecido')
      return NextResponse.json({
        success: false,
        error: 'ID da assinatura não fornecido'
      }, { status: 400 })
    }

    console.log('📋 [CHECK SUBSCRIPTION] SubscriptionId:', subscriptionId)

    // 3. Buscar status real da assinatura no MercadoPago
    const accessToken = process.env.MERCADOPAGO_ACCESS_TOKEN
    if (!accessToken) {
      console.error('❌ [CHECK SUBSCRIPTION] MERCADOPAGO_ACCESS_TOKEN não configurado')
      return NextResponse.json({
        success: false,
        error: 'Erro de configuração do servidor'
      }, { status: 500 })
    }

    console.log('🔗 [CHECK SUBSCRIPTION] Buscando status no MercadoPago...')

    const mpResponse = await fetch(`https://api.mercadopago.com/preapproval/${subscriptionId}`, {
      headers: {
        'Authorization': `Bearer ${accessToken}`
      }
    })

    if (!mpResponse.ok) {
      console.error(`❌ [CHECK SUBSCRIPTION] Erro ao buscar assinatura no MP: ${mpResponse.status}`)
      const errorText = await mpResponse.text()
      console.error('Erro do MP:', errorText)
      return NextResponse.json({
        success: false,
        error: 'Erro ao verificar status do pagamento no MercadoPago'
      }, { status: 500 })
    }

    const subscription = await mpResponse.json()

    console.log(`📊 [CHECK SUBSCRIPTION] Status da assinatura no MP: ${subscription.status}`)
    console.log(`📊 [CHECK SUBSCRIPTION] Dados completos:`, JSON.stringify(subscription, null, 2))

    // 4. Verificar se foi autorizada/aprovada
    if (subscription.status !== 'authorized') {
      console.warn(`⚠️ [CHECK SUBSCRIPTION] Assinatura não autorizada ainda: ${subscription.status}`)
      return NextResponse.json({
        success: false,
        error: `Pagamento ainda não foi aprovado. Status atual: ${subscription.status}. Por favor, aguarde alguns minutos e tente novamente.`,
        status: subscription.status
      }, { status: 400 })
    }

    // 5. Mapear plano baseado no valor (auto_recurring.transaction_amount)
    const amount = subscription.auto_recurring?.transaction_amount || 0

    let planType = 'basic' // padrão
    let planName = 'Basic'

    // Mapear baseado nos preços: Basic=R$34.90, Advanced=R$69.90, Complete=R$99.90
    if (amount >= 90) {
      // R$ 99.90 = Complete
      planType = 'complete'
      planName = 'Complete'
    } else if (amount >= 60) {
      // R$ 69.90 = Advanced
      planType = 'advanced'
      planName = 'Advanced'
    } else if (amount >= 30) {
      // R$ 34.90 = Basic
      planType = 'basic'
      planName = 'Basic'
    } else {
      planType = 'basic'
      planName = 'Basic'
    }

    console.log(`📦 [CHECK SUBSCRIPTION] Plano identificado: ${planName} (R$ ${amount})`)

    // 6. Verificar se já foi processado antes (evitar duplicação)
    const organizationId = auth.user.organizationId

    const currentOrg = await prisma.organization.findUnique({
      where: { id: organizationId },
      select: {
        mercadoPagoSubscriptionId: true,
        subscriptionStatus: true,
        planType: true
      }
    })

    if (currentOrg?.mercadoPagoSubscriptionId === subscriptionId &&
        currentOrg?.subscriptionStatus === 'active') {
      console.log(`✅ [CHECK SUBSCRIPTION] Assinatura já processada anteriormente`)
      return NextResponse.json({
        success: true,
        message: 'Assinatura já estava ativada',
        planName: currentOrg.planType.charAt(0).toUpperCase() + currentOrg.planType.slice(1),
        planType: currentOrg.planType,
        subscriptionStatus: 'active',
        alreadyProcessed: true
      })
    }

    console.log(`💾 [CHECK SUBSCRIPTION] Atualizando organização ${organizationId}...`)

    await prisma.organization.update({
      where: { id: organizationId },
      data: {
        planType: planType as any,
        subscriptionStatus: 'active',
        mercadoPagoSubscriptionId: subscriptionId,
        documentProcessedCount: 0, // Resetar contadores APENAS na primeira ativação
        aiTokenCount: 0,
        updatedAt: new Date()
      }
    })

    console.log(`✅ [CHECK SUBSCRIPTION] Organização ${organizationId} atualizada com sucesso!`)
    console.log(`   - Plano: ${planType}`)
    console.log(`   - Status: active`)
    console.log(`   - SubscriptionId: ${subscriptionId}`)

    return NextResponse.json({
      success: true,
      message: 'Assinatura ativada com sucesso',
      planName: planName,
      planType: planType,
      subscriptionStatus: 'active'
    })

  } catch (error) {
    console.error('❌ [CHECK SUBSCRIPTION] Erro ao processar:', error)
    console.error('Stack:', error instanceof Error ? error.stack : 'N/A')

    return NextResponse.json({
      success: false,
      error: error instanceof Error ? error.message : 'Erro interno do servidor'
    }, { status: 500 })
  }
}
