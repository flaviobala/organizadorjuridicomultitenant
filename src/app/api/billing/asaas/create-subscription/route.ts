// src/app/api/billing/asaas/create-subscription/route.ts
import { NextRequest, NextResponse } from 'next/server'
import { requireAuth } from '@/lib/auth'
import { prisma } from '@/lib/prisma'

// Definir preços dos planos (em reais)
const PLAN_PRICES = {
  basic: 34.90,
  advanced: 69.90,
  complete: 99.90
}

/**
 * POST /api/billing/asaas/create-subscription
 * Cria uma assinatura no Asaas
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
    if (!['basic', 'advanced', 'complete'].includes(planType)) {
      return NextResponse.json({
        success: false,
        error: 'Plano inválido'
      }, { status: 400 })
    }

    const planPrice = PLAN_PRICES[planType as keyof typeof PLAN_PRICES]

    console.log('📝 [ASAAS] Criando assinatura:', {
      organizationId: auth.user.organizationId,
      planType,
      planPrice
    })

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

    // Verificar se tem customerId do Asaas
    if (!organization.asaasCustomerId) {
      // Criar customer primeiro
      const customerResponse = await fetch(`${request.nextUrl.origin}/api/billing/asaas/create-customer`, {
        method: 'POST',
        headers: {
          'Authorization': request.headers.get('Authorization') || '',
          'Content-Type': 'application/json'
        }
      })

      const customerData = await customerResponse.json()

      if (!customerData.success) {
        throw new Error('Erro ao criar cliente: ' + customerData.error)
      }

      // Atualizar organização local
      organization.asaasCustomerId = customerData.customerId
    }

    const apiKey = process.env.ASAAS_API_KEY
    if (!apiKey) {
      throw new Error('ASAAS_API_KEY não configurada')
    }

    const baseUrl = process.env.NEXT_PUBLIC_APP_URL || request.nextUrl.origin

    // Criar assinatura no Asaas
    const asaasResponse = await fetch('https://www.asaas.com/api/v3/subscriptions', {
      method: 'POST',
      headers: {
        'access_token': apiKey,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        customer: organization.asaasCustomerId,
        billingType: 'UNDEFINED', // Usuário escolhe no checkout
        value: planPrice,
        cycle: 'MONTHLY',
        description: `Plano ${planType.charAt(0).toUpperCase() + planType.slice(1)} - AdvConecta`,
        externalReference: `${organization.id}-${planType}`,
        // URLs de retorno
        callback: {
          successUrl: `${baseUrl}/payment-success?plan=${planType}`,
          autoRedirect: true
        }
      })
    })

    if (!asaasResponse.ok) {
      const errorData = await asaasResponse.json()
      console.error('❌ [ASAAS] Erro ao criar assinatura:', errorData)
      throw new Error(errorData.errors?.[0]?.description || 'Erro ao criar assinatura')
    }

    const subscriptionData = await asaasResponse.json()
    console.log('✅ [ASAAS] Assinatura criada:', subscriptionData.id)

    // Salvar ID da assinatura no localStorage (frontend vai usar)
    // Também salvar no banco para rastreamento
    await prisma.organization.update({
      where: { id: organization.id },
      data: {
        asaasSubscriptionId: subscriptionData.id,
        planType: planType as any // Vai ser confirmado via webhook
      }
    })

    // URL do checkout
    const checkoutUrl = subscriptionData.invoiceUrl || subscriptionData.bankSlipUrl

    return NextResponse.json({
      success: true,
      subscriptionId: subscriptionData.id,
      checkoutUrl,
      message: 'Assinatura criada com sucesso'
    })

  } catch (error) {
    console.error('❌ [ASAAS] Erro ao criar assinatura:', error)
    return NextResponse.json({
      success: false,
      error: error instanceof Error ? error.message : 'Erro interno do servidor'
    }, { status: 500 })
  }
}
