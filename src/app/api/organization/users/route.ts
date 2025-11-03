// src/app/api/organization/users/route.ts
import { NextRequest, NextResponse } from 'next/server'
import { requireAuth } from '@/lib/auth'
import { prisma } from '@/lib/prisma'
import { checkUserLimit } from '@/lib/plan-limits'
import bcrypt from 'bcryptjs'
import { z } from 'zod'

const createUserSchema = z.object({
  name: z.string().min(2, 'Nome deve ter pelo menos 2 caracteres'),
  email: z.string().email('Email inválido'),
  password: z.string().min(6, 'Senha deve ter pelo menos 6 caracteres'),
  role: z.enum(['admin', 'member'], { errorMap: () => ({ message: 'Função inválida' }) })
})

/**
 * GET /api/organization/users
 * Lista todos os usuários da organização
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
        error: 'Acesso negado: apenas administradores podem visualizar usuários'
      }, { status: 403 })
    }

    // Buscar todos os usuários da organização
    const users = await prisma.user.findMany({
      where: {
        organizationId: auth.user.organizationId
      },
      select: {
        id: true,
        name: true,
        email: true,
        role: true,
        createdAt: true
      },
      orderBy: [
        { role: 'asc' }, // admin primeiro
        { name: 'asc' }
      ]
    })

    return NextResponse.json({
      success: true,
      users
    })

  } catch (error) {
    console.error('❌ Erro ao buscar usuários:', error)
    return NextResponse.json({
      error: 'Erro interno do servidor'
    }, { status: 500 })
  }
}

/**
 * POST /api/organization/users
 * Cria um novo usuário na organização
 */
export async function POST(request: NextRequest) {
  try {
    const auth = await requireAuth(request)
    if (!auth.success || !auth.user) {
      return NextResponse.json({ error: auth.error }, { status: 401 })
    }

    // Verificar se é admin ou super_admin
    if (auth.user.role !== 'admin' && auth.user.role !== 'super_admin') {
      return NextResponse.json({
        error: 'Acesso negado: apenas administradores podem criar usuários'
      }, { status: 403 })
    }

    const body = await request.json()

    // Validar dados
    const validation = createUserSchema.safeParse(body)
    if (!validation.success) {
      return NextResponse.json({
        success: false,
        error: 'Dados inválidos',
        details: validation.error.errors
      }, { status: 400 })
    }

    const { name, email, password, role } = validation.data

    // Verificar se o email já está em uso
    const existingUser = await prisma.user.findUnique({
      where: { email }
    })

    if (existingUser) {
      return NextResponse.json({
        success: false,
        error: 'Este email já está cadastrado'
      }, { status: 400 })
    }

    // Verificar limite de usuários do plano
    const canAddUser = await checkUserLimit(auth.user.organizationId)
    if (!canAddUser) {
      return NextResponse.json({
        success: false,
        error: 'Limite de usuários do plano atingido. Faça upgrade para adicionar mais usuários.'
      }, { status: 403 })
    }

    // Hash da senha
    const hashedPassword = await bcrypt.hash(password, 12)

    // Criar usuário
    const newUser = await prisma.user.create({
      data: {
        name,
        email,
        password: hashedPassword,
        role,
        organizationId: auth.user.organizationId
      },
      select: {
        id: true,
        name: true,
        email: true,
        role: true,
        createdAt: true
      }
    })

    console.log(`✅ Novo usuário criado: ${newUser.email} (${newUser.role}) na organização ${auth.user.organizationId}`)

    return NextResponse.json({
      success: true,
      message: 'Usuário criado com sucesso',
      user: newUser
    }, { status: 201 })

  } catch (error) {
    console.error('❌ Erro ao criar usuário:', error)
    return NextResponse.json({
      success: false,
      error: 'Erro interno do servidor'
    }, { status: 500 })
  }
}
