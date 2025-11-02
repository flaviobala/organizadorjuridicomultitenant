// src/app/api/admin/organizations/route.ts
import { NextRequest, NextResponse } from 'next/server'
import { requireSuperAdmin } from '@/lib/auth'
import { prisma } from '@/lib/prisma'
import bcrypt from 'bcryptjs'

/**
 * POST /api/admin/organizations
 * Cria uma nova organização (apenas admin)
 */
export async function POST(request: NextRequest) {
  try {
    const auth = await requireSuperAdmin(request)
    if (!auth.success || !auth.user) {
      return NextResponse.json({ error: auth.error }, { status: 403 })
    }

    const body = await request.json()
    const { name, planType = 'trialing', email, password, userName } = body

    // Validar campos obrigatórios
    if (!name || !email || !password || !userName) {
      return NextResponse.json({
        success: false,
        error: 'Campos obrigatórios: name, email, password, userName'
      }, { status: 400 })
    }

    // Verificar se email já existe
    const existingUser = await prisma.user.findUnique({
      where: { email }
    })

    if (existingUser) {
      return NextResponse.json({
        success: false,
        error: 'Email já cadastrado'
      }, { status: 400 })
    }

    // Criar organização
    const organization = await prisma.organization.create({
      data: {
        name,
        planType: planType as any,
        subscriptionStatus: 'trialing',
        documentProcessedCount: 0,
        aiTokenCount: 0
      }
    })

    // Criar usuário admin para a organização
    const hashedPassword = await bcrypt.hash(password, 12)
    const user = await prisma.user.create({
      data: {
        email,
        password: hashedPassword,
        name: userName,
        role: 'admin',
        organizationId: organization.id
      }
    })

    return NextResponse.json({
      success: true,
      organization: {
        id: organization.id,
        name: organization.name,
        planType: organization.planType,
        subscriptionStatus: organization.subscriptionStatus
      },
      user: {
        id: user.id,
        email: user.email,
        name: user.name,
        role: user.role
      },
      message: 'Organização criada com sucesso!'
    })

  } catch (error) {
    console.error('❌ Erro ao criar organização:', error)
    return NextResponse.json({
      success: false,
      error: error instanceof Error ? error.message : 'Erro interno do servidor'
    }, { status: 500 })
  }
}

/**
 * GET /api/admin/organizations
 * Lista todas as organizações (apenas admin)
 */
export async function GET(request: NextRequest) {
  try {
    const auth = await requireSuperAdmin(request)
    if (!auth.success || !auth.user) {
      return NextResponse.json({ error: auth.error }, { status: 403 })
    }

    // Buscar todas as organizações com estatísticas E usuários
    const organizations = await prisma.organization.findMany({
      include: {
        _count: {
          select: {
            users: true,
            projects: true,
            documents: true,
          }
        },
        users: {
          select: {
            id: true,
            name: true,
            email: true,
            role: true,
            createdAt: true
          },
          orderBy: {
            role: 'asc' // admin primeiro, depois member
          }
        }
      },
      orderBy: { createdAt: 'desc' }
    })

    // Formatar resposta
    const orgsWithStats = organizations.map(org => ({
      id: org.id,
      name: org.name,
      planType: org.planType,
      subscriptionStatus: org.subscriptionStatus,
      documentProcessedCount: org.documentProcessedCount,
      aiTokenCount: org.aiTokenCount,
      stripeCustomerId: org.stripeCustomerId,
      createdAt: org.createdAt,
      updatedAt: org.updatedAt,
      stats: {
        usersCount: org._count.users,
        projectsCount: org._count.projects,
        documentsCount: org._count.documents,
      },
      users: org.users // ✅ Adicionar lista de usuários
    }))

    return NextResponse.json({
      success: true,
      organizations: orgsWithStats
    })

  } catch (error) {
    console.error('❌ Erro ao listar organizações:', error)
    return NextResponse.json({
      success: false,
      error: error instanceof Error ? error.message : 'Erro interno do servidor'
    }, { status: 500 })
  }
}
