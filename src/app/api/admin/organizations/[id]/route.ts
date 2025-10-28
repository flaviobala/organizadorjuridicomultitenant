// src/app/api/admin/organizations/[id]/route.ts
import { NextRequest, NextResponse } from 'next/server'
import { requireAdmin } from '@/lib/auth'
import { prisma } from '@/lib/prisma'

/**
 * GET /api/admin/organizations/[id]
 * Busca detalhes de uma organização (apenas admin)
 */
export async function GET(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    const auth = await requireAdmin(request)
    if (!auth.success || !auth.user) {
      return NextResponse.json({ error: auth.error }, { status: 403 })
    }

    const orgId = parseInt(params.id)

    const organization = await prisma.organization.findUnique({
      where: { id: orgId },
      include: {
        users: {
          select: {
            id: true,
            email: true,
            name: true,
            role: true,
            createdAt: true,
          }
        },
        _count: {
          select: {
            projects: true,
            documents: true,
            apiUsages: true,
          }
        }
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
      organization
    })

  } catch (error) {
    console.error('❌ Erro ao buscar organização:', error)
    return NextResponse.json({
      success: false,
      error: error instanceof Error ? error.message : 'Erro interno do servidor'
    }, { status: 500 })
  }
}

/**
 * PATCH /api/admin/organizations/[id]
 * Atualiza uma organização (apenas admin)
 */
export async function PATCH(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    const auth = await requireAdmin(request)
    if (!auth.success || !auth.user) {
      return NextResponse.json({ error: auth.error }, { status: 403 })
    }

    const orgId = parseInt(params.id)
    const body = await request.json()

    // Campos permitidos para atualização
    const allowedFields = [
      'name',
      'planType',
      'subscriptionStatus',
      'documentProcessedCount',
      'aiTokenCount',
    ]

    const updateData: any = {}
    for (const field of allowedFields) {
      if (body[field] !== undefined) {
        updateData[field] = body[field]
      }
    }

    const organization = await prisma.organization.update({
      where: { id: orgId },
      data: updateData
    })

    return NextResponse.json({
      success: true,
      organization,
      message: 'Organização atualizada com sucesso'
    })

  } catch (error) {
    console.error('❌ Erro ao atualizar organização:', error)
    return NextResponse.json({
      success: false,
      error: error instanceof Error ? error.message : 'Erro interno do servidor'
    }, { status: 500 })
  }
}
