// src/app/api/subscription/route.ts
import { NextRequest, NextResponse } from 'next/server'
import { requireAuth } from '@/lib/auth'
import { prisma } from '@/lib/prisma'

/**
 * GET /api/subscription
 * Retorna informações da assinatura da organização do usuário
 */
export async function GET(request: NextRequest) {
  try {
    const auth = await requireAuth(request)
    if (!auth.success || !auth.user) {
      return NextResponse.json({ error: auth.error }, { status: 401 })
    }

    // Buscar organização
    const organization = await prisma.organization.findUnique({
      where: { id: auth.user.organizationId },
      select: {
        id: true,
        name: true,
        planType: true,
        subscriptionStatus: true,
        documentProcessedCount: true,
        aiTokenCount: true
      }
    })

    if (!organization) {
      return NextResponse.json({
        success: false,
        error: 'Organização não encontrada'
      }, { status: 404 })
    }

    return NextResponse.json({
      success: true,
      subscription: {
        planType: organization.planType,
        subscriptionStatus: organization.subscriptionStatus,
        documentProcessedCount: organization.documentProcessedCount,
        aiTokenCount: organization.aiTokenCount
      }
    })

  } catch (error) {
    console.error('❌ Erro ao buscar assinatura:', error)
    return NextResponse.json({
      success: false,
      error: 'Erro interno do servidor'
    }, { status: 500 })
  }
}
