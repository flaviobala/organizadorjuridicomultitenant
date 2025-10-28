//src/app/api/action-types/route.ts
import { NextRequest, NextResponse } from 'next/server'
import { requireAuth } from '@/lib/auth'
import { prisma } from '@/lib/prisma'

export async function POST(request: NextRequest) {
  try {
    console.log('📝 API POST ActionTypes chamada')

    const auth = await requireAuth(request)
    if (!auth.success || !auth.user) {
      console.log('❌ Falha na autenticação:', auth.error)
      return NextResponse.json({ error: auth.error }, { status: 401 })
    }

    console.log('✅ Usuário autenticado:', auth.user.email)

    const body = await request.json()
    const { name, description } = body

    // Validações
    if (!name || !name.trim()) {
      return NextResponse.json({
        success: false,
        error: 'Nome do tipo de ação é obrigatório'
      }, { status: 400 })
    }

    // Verificar se já existe
    const existingActionType = await prisma.actionType.findUnique({
      where: { name: name.trim() }
    })

    if (existingActionType) {
      return NextResponse.json({
        success: false,
        error: 'Tipo de ação já existe no banco de dados'
      }, { status: 409 })
    }

    // Criar novo tipo de ação
    const newActionType = await prisma.actionType.create({
      data: {
        name: name.trim(),
        description: description?.trim() || null
      }
    })

    console.log('✅ Tipo de ação criado com sucesso:', newActionType.name)

    return NextResponse.json({
      success: true,
      actionType: {
        id: newActionType.id,
        name: newActionType.name,
        description: newActionType.description
      }
    })

  } catch (error) {
    console.error('❌ Erro ao criar tipo de ação:', error)
    return NextResponse.json({
      success: false,
      error: 'Erro interno do servidor',
      debug: error instanceof Error ? error.message : 'Erro desconhecido'
    }, { status: 500 })
  }
}

export async function GET(request: NextRequest) {
  try {
    console.log('📋 API GET ActionTypes chamada')

    const auth = await requireAuth(request)
    if (!auth.success || !auth.user) {
      console.log('❌ Falha na autenticação:', auth.error)
      return NextResponse.json({ error: auth.error }, { status: 401 })
    }

    const actionTypes = await prisma.actionType.findMany({
      orderBy: {
        name: 'asc'
      }
    })

    console.log(`✅ ${actionTypes.length} tipos de ação encontrados`)

    return NextResponse.json({
      success: true,
      actionTypes: actionTypes.map(at => at.name)
    })

  } catch (error) {
    console.error('❌ Erro ao buscar tipos de ação:', error)
    return NextResponse.json({
      success: false,
      error: 'Erro interno do servidor',
      debug: error instanceof Error ? error.message : 'Erro desconhecido'
    }, { status: 500 })
  }
}