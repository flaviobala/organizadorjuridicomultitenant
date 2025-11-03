// src/app/api/organization/projects/route.ts
import { NextRequest, NextResponse } from 'next/server'
import { requireAuth } from '@/lib/auth'
import { prisma } from '@/lib/prisma'

/**
 * GET /api/organization/projects
 * Lista todos os projetos de todos os usuários da organização
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
        error: 'Acesso negado: apenas administradores podem visualizar todos os projetos'
      }, { status: 403 })
    }

    // Buscar todos os projetos da organização
    const projects = await prisma.project.findMany({
      where: {
        organizationId: auth.user.organizationId
      },
      include: {
        user: {
          select: {
            id: true,
            name: true,
            email: true
          }
        },
        _count: {
          select: {
            documents: true
          }
        }
      },
      orderBy: {
        createdAt: 'desc'
      }
    })

    return NextResponse.json({
      success: true,
      projects
    })

  } catch (error) {
    console.error('❌ Erro ao buscar projetos:', error)
    return NextResponse.json({
      error: 'Erro interno do servidor'
    }, { status: 500 })
  }
}
