// src/app/api/billing/mercadopago/process-return/route.ts
import { NextRequest, NextResponse } from 'next/server'
import { requireAuth } from '@/lib/auth'
import { prisma } from '@/lib/prisma'

/**
 * GET /api/billing/mercadopago/process-return
 * Processa retorno do MercadoPago e atualiza banco
 */
export async function GET(request: NextRequest) {
  try {
    const auth = await requireAuth(request)
    if (!auth.success || !auth.user) {
      return NextResponse.json({ error: auth.error }, { status: 401 })
    }

    const { searchParams } = new URL(request.url)
    const organizationId = searchParams.get('organizationId')
    const plan = searchParams.get('plan')
    const subscriptionId = searchParams.get('subscriptionId')

    console.log(`🔄 [RETORNO MP] OrganizationId: ${organizationId}, Plan: ${plan}, SubscriptionId: ${subscriptionId}`)

    if (!organizationId || !plan || !subscriptionId) {
      return NextResponse.json({
        success: false,
        error: 'Parâmetros inválidos'
      }, { status: 400 })
    }

    // Buscar status real da assinatura no MercadoPago
    const accessToken = process.env.MERCADOPAGO_ACCESS_TOKEN
    const mpResponse = await fetch(`https://api.mercadopago.com/preapproval/${subscriptionId}`, {
      headers: {
        'Authorization': `Bearer ${accessToken}`
      }
    })

    if (!mpResponse.ok) {
      console.error(`❌ [RETORNO MP] Erro ao buscar assinatura no MP: ${mpResponse.status}`)
      return NextResponse.json({
        success: false,
        error: 'Erro ao verificar status do pagamento'
      }, { status: 500 })
    }

    const subscription = await mpResponse.json()

    console.log(`📋 [RETORNO MP] Status da assinatura no MP: ${subscription.status}`)

    // Verificar se foi autorizada/aprovada
    if (subscription.status !== 'authorized') {
      console.warn(`⚠️ [RETORNO MP] Assinatura não autorizada: ${subscription.status}`)
      return NextResponse.json({
        success: false,
        error: `Pagamento não foi aprovado. Status: ${subscription.status}`,
        status: subscription.status
      }, { status: 400 })
    }

    // Mapear nome do plano
    const planTypeMap: Record<string, string> = {
      'basic': 'basic',
      'pro': 'pro',
      'enterprise': 'enterprise'
    }

    const planType = planTypeMap[plan.toLowerCase()] || 'basic'

    // Atualizar organização SOMENTE se aprovado
    await prisma.organization.update({
      where: { id: parseInt(organizationId) },
      data: {
        planType: planType as any,
        subscriptionStatus: 'active',
        documentProcessedCount: 0,
        aiTokenCount: 0,
        updatedAt: new Date()
      }
    })

    console.log(`✅ [RETORNO MP] Organização ${organizationId} atualizada: ${planType} - active`)

    return NextResponse.json({
      success: true,
      message: 'Assinatura ativada com sucesso',
      plan: planType
    })

  } catch (error) {
    console.error('❌ [RETORNO MP] Erro ao processar:', error)
    return NextResponse.json({
      success: false,
      error: 'Erro interno do servidor'
    }, { status: 500 })
  }
}
