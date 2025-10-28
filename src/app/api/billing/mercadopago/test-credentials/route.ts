// src/app/api/billing/mercadopago/test-credentials/route.ts
import { NextRequest, NextResponse } from 'next/server'
import { requireAuth } from '@/lib/auth'

/**
 * GET /api/billing/mercadopago/test-credentials
 * Testa se as credenciais do Mercado Pago estão corretas
 */
export async function GET(request: NextRequest) {
  try {
    const auth = await requireAuth(request)
    if (!auth.success || !auth.user) {
      return NextResponse.json({ error: auth.error }, { status: 401 })
    }

    // Verificar se é admin
    if (auth.user.role !== 'admin') {
      return NextResponse.json({ error: 'Apenas administradores' }, { status: 403 })
    }

    const accessToken = process.env.MERCADOPAGO_ACCESS_TOKEN

    if (!accessToken) {
      return NextResponse.json({
        success: false,
        error: 'MERCADOPAGO_ACCESS_TOKEN não configurado'
      }, { status: 500 })
    }

    // Testar chamada simples à API do MP para validar o token
    // Usando endpoint /v1/payment_methods que é público
    const testResponse = await fetch('https://api.mercadopago.com/v1/payment_methods', {
      headers: {
        'Authorization': `Bearer ${accessToken}`
      }
    })

    const testData = await testResponse.json()

    if (!testResponse.ok) {
      return NextResponse.json({
        success: false,
        error: 'Access Token inválido ou sem permissões',
        details: testData,
        status: testResponse.status
      })
    }

    // Testar endpoint de PreApproval Plans (específico para assinaturas)
    const plansResponse = await fetch('https://api.mercadopago.com/preapproval_plan/search', {
      headers: {
        'Authorization': `Bearer ${accessToken}`,
        'Content-Type': 'application/json'
      }
    })

    const plansData = await plansResponse.json()

    return NextResponse.json({
      success: true,
      message: 'Credenciais válidas',
      tokenPrefix: accessToken.substring(0, 15) + '...',
      tests: {
        paymentMethods: {
          status: testResponse.status,
          ok: testResponse.ok
        },
        preapprovalPlans: {
          status: plansResponse.status,
          ok: plansResponse.ok,
          hasPermission: plansResponse.ok,
          error: plansResponse.ok ? null : plansData
        }
      }
    })

  } catch (error) {
    console.error('❌ [TEST] Erro ao testar credenciais:', error)
    return NextResponse.json({
      success: false,
      error: error instanceof Error ? error.message : 'Erro ao testar'
    }, { status: 500 })
  }
}
