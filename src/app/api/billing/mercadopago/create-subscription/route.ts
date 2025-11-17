// src/app/api/billing/mercadopago/create-subscription/route.ts
import { NextRequest, NextResponse } from 'next/server'
import { requireAuth } from '@/lib/auth'
import { prisma } from '@/lib/prisma'
import { MercadoPagoConfig, PreApproval } from 'mercadopago'

// Configurar cliente Mercado Pago
const client = new MercadoPagoConfig({
  accessToken: process.env.MERCADOPAGO_ACCESS_TOKEN!,
  options: {
    timeout: 5000
  }
})

const preApprovalClient = new PreApproval(client)

// Definir preços dos planos (em reais) - VALORES DE TESTE
const PLAN_PRICES = {
  basic: 15.00,
  pro: 25.00
}

/**
 * POST /api/billing/mercadopago/create-subscription
 * Cria uma assinatura no Mercado Pago
 */
export async function POST(request: NextRequest) {
  try {
    const body = await request.json()
    const { planType, email } = body

    // Validar plano
    if (!['basic', 'pro'].includes(planType)) {
      return NextResponse.json({
        success: false,
        error: 'Plano inválido'
      }, { status: 400 })
    }

    const baseUrl = process.env.NEXT_PUBLIC_APP_URL || request.nextUrl.origin || 'http://localhost:3000'
    const planPrice = PLAN_PRICES[planType as keyof typeof PLAN_PRICES]

    // Em desenvolvimento, usar URL de produção para back_url (MercadoPago não aceita localhost)
    const backUrl = baseUrl.includes('localhost')
      ? 'https://app.advconecta.com.br/payment-success'
      : `${baseUrl}/payment-success`

    console.log('📝 [MP] Criando assinatura:', {
      planType,
      planPrice,
      baseUrl,
      backUrl
    })

    // Criar assinatura
    const subscription = await preApprovalClient.create({
      body: {
        reason: `Plano ${planType.toUpperCase()}`,
        auto_recurring: {
          frequency: 1,
          frequency_type: 'months',
          transaction_amount: planPrice,
          currency_id: 'BRL'
        },
        back_url: backUrl,
        payer_email: email, // Email do pagador é obrigatório
        external_reference: planType // Armazenar plano selecionado
      }
    })

    console.log('✅ [MP] Assinatura criada:', subscription.id)
    console.log('🔗 [MP] URL de checkout:', subscription.init_point)

    // Link de checkout
    const checkoutUrl = subscription.init_point

    return NextResponse.json({
      success: true,
      subscriptionId: subscription.id,
      checkoutUrl,
      message: 'Assinatura criada com sucesso'
    })

  } catch (error: any) {
    console.error('❌ [MP] Erro ao criar assinatura:', error)
    console.error('❌ [MP] Detalhes completos:', JSON.stringify(error, null, 2))

    // Se for erro da API do MP, mostrar mais detalhes
    if (error.cause) {
      console.error('❌ [MP] Causa do erro:', JSON.stringify(error.cause, null, 2))
    }

    return NextResponse.json({
      success: false,
      error: error instanceof Error ? error.message : 'Erro interno do servidor',
      details: error.cause || error
    }, { status: 500 })
  }
}