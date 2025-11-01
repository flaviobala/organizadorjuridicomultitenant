// src/app/api/billing/mercadopago/create-test-user/route.ts
import { NextResponse } from 'next/server'

/**
 * POST /api/billing/mercadopago/create-test-user
 * Cria um usuário de teste no MercadoPago
 */
export async function POST() {
  try {
    const accessToken = process.env.MERCADOPAGO_ACCESS_TOKEN

    if (!accessToken) {
      return NextResponse.json({
        success: false,
        error: 'MERCADOPAGO_ACCESS_TOKEN não configurado'
      }, { status: 500 })
    }

    // Criar usuário de teste
    const response = await fetch('https://api.mercadopago.com/users/test', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${accessToken}`
      },
      body: JSON.stringify({
        site_id: 'MLB', // Brasil
        description: 'Test user for subscriptions'
      })
    })

    if (!response.ok) {
      const error = await response.json()
      throw new Error(JSON.stringify(error))
    }

    const testUser = await response.json()

    console.log('✅ [MP] Usuário de teste criado:', testUser)

    return NextResponse.json({
      success: true,
      testUser: {
        id: testUser.id,
        nickname: testUser.nickname,
        email: testUser.email,
        password: testUser.password
      }
    })

  } catch (error: any) {
    console.error('❌ [MP] Erro ao criar usuário de teste:', error)

    return NextResponse.json({
      success: false,
      error: error instanceof Error ? error.message : 'Erro interno do servidor'
    }, { status: 500 })
  }
}
