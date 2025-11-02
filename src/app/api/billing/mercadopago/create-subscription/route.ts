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
  pro: 20.00,           
  enterprise: 199.90   // R$ 199,90/mês
}

/**
 * POST /api/billing/mercadopago/create-subscription
 * Cria uma assinatura no Mercado Pago
 */
export async function POST(request: NextRequest) {
  try {
    const auth = await requireAuth(request)
    if (!auth.success || !auth.user) {
      return NextResponse.json({ error: auth.error }, { status: 401 })
    }

    const body = await request.json()
    const { planType } = body

    // Validar plano
    if (!['basic', 'pro', 'enterprise'].includes(planType)) {
      return NextResponse.json({
        success: false,
        error: 'Plano inválido'
      }, { status: 400 })
    }

    // Buscar organização
    const organization = await prisma.organization.findUnique({
      where: { id: auth.user.organizationId }
    })

    if (!organization) {
      return NextResponse.json({
        success: false,
        error: 'Organização não encontrada'
      }, { status: 404 })
    }

    // Definir frequência e preço
    const price = PLAN_PRICES[planType as keyof typeof PLAN_PRICES]

    // ✅ PEGAR URL DO AMBIENTE
    const baseUrl = process.env.NEXT_PUBLIC_APP_URL || 'http://localhost:3000'

    // ✅ PRODUÇÃO: Usar email real do usuário logado
    const payerEmail = auth.user.email

    console.log('📝 [MP] Criando assinatura:', {
      planType,
      price,
      organizationId: organization.id,
      organizationName: organization.name,
      payerEmail,
      baseUrl
    })

    // Criar assinatura
    const subscription = await preApprovalClient.create({
      body: {
        reason: `Plano ${planType.toUpperCase()} - ${organization.name}`,
        auto_recurring: {
          frequency: 1,
          frequency_type: 'months',
          transaction_amount: price,
          currency_id: 'BRL'
        },
        back_url: `${baseUrl}/payment-success`,
        payer_email: payerEmail,
        external_reference: organization.id.toString()
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