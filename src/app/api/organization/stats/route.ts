// src/app/api/organization/stats/route.ts
import { NextRequest, NextResponse } from 'next/server'
import { requireAuth } from '@/lib/auth'
import { prisma } from '@/lib/prisma'
import { PLAN_LIMITS } from '@/lib/plan-limits'

/**
 * GET /api/organization/stats
 * Retorna estatísticas da organização do usuário logado
 */
export async function GET(request: NextRequest) {
  try {
    const auth = await requireAuth(request)
    if (!auth.success || !auth.user) {
      return NextResponse.json({ error: auth.error }, { status: 401 })
    }

    // Verificar se é admin ou super_admin
    if (auth.user.role !== 'admin' && auth.user.role !== 'super_admin') {
      return NextResponse.json({
        error: 'Acesso negado: apenas administradores podem visualizar estatísticas'
      }, { status: 403 })
    }

    // Buscar organização com contagens
    const organization = await prisma.organization.findUnique({
      where: { id: auth.user.organizationId },
      include: {
        _count: {
          select: {
            users: true,
            projects: true,
            documents: true
          }
        }
      }
    })

    if (!organization) {
      return NextResponse.json({ error: 'Organização não encontrada' }, { status: 404 })
    }

    // Buscar limites do plano
    const limits = PLAN_LIMITS[organization.planType as keyof typeof PLAN_LIMITS]

    return NextResponse.json({
      success: true,
      data: {
        name: organization.name,
        planType: organization.planType,
        subscriptionStatus: organization.subscriptionStatus,
        aiTokenCount: organization.aiTokenCount,
        documentProcessedCount: organization.documentProcessedCount,
        limits: {
          maxTokens: limits.maxTokens,
          maxDocuments: limits.maxDocuments,
          maxUsers: limits.maxUsers
        },
        stats: {
          totalUsers: organization._count.users,
          totalProjects: organization._count.projects,
          totalDocuments: organization._count.documents
        }
      }
    })

  } catch (error) {
    console.error('❌ Erro ao buscar estatísticas da organização:', error)
    return NextResponse.json({
      error: 'Erro interno do servidor'
    }, { status: 500 })
  }
}
