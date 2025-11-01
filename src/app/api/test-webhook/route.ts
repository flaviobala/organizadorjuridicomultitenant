// src/app/api/test-webhook/route.ts
import { NextRequest, NextResponse } from 'next/server'

/**
 * Endpoint de teste para verificar se webhooks estão funcionando
 * Acesse: GET /api/test-webhook
 */
export async function GET(request: NextRequest) {
  return NextResponse.json({
    success: true,
    message: 'Webhook endpoint está funcionando!',
    timestamp: new Date().toISOString(),
    headers: Object.fromEntries(request.headers),
    url: request.url
  })
}

/**
 * Teste de POST (simular webhook do MercadoPago)
 */
export async function POST(request: NextRequest) {
  try {
    const body = await request.json()

    return NextResponse.json({
      success: true,
      message: 'POST recebido com sucesso!',
      receivedData: body,
      headers: Object.fromEntries(request.headers),
      timestamp: new Date().toISOString()
    })
  } catch (error) {
    return NextResponse.json({
      success: false,
      error: 'Erro ao processar POST',
      details: error instanceof Error ? error.message : 'Erro desconhecido'
    }, { status: 400 })
  }
}
