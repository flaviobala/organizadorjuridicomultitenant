//src/app/api/action-types/route.ts
import { NextRequest, NextResponse } from 'next/server'
import { requireAuth } from '@/lib/auth'
import { prisma } from '@/lib/prisma'
import { DEFAULT_ACTION_TYPES } from '@/lib/default-action-types'

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

    // Verificar se é um nome de tipo de ação padrão
    const isDefaultActionType = DEFAULT_ACTION_TYPES.some(
      at => at.name.toLowerCase() === name.trim().toLowerCase()
    )

    if (isDefaultActionType) {
      return NextResponse.json({
        success: false,
        error: 'Este tipo de ação já existe como padrão do sistema. Use outro nome.'
      }, { status: 409 })
    }

    // Verificar se já existe para esta organização
    const existingActionType = await prisma.actionType.findFirst({
      where: {
        organizationId: auth.user.organizationId,
        name: name.trim()
      }
    })

    if (existingActionType) {
      return NextResponse.json({
        success: false,
        error: 'Tipo de ação já existe para sua organização'
      }, { status: 409 })
    }

    // Criar novo tipo de ação para esta organização
    const newActionType = await prisma.actionType.create({
      data: {
        name: name.trim(),
        description: description?.trim() || null,
        organizationId: auth.user.organizationId
      }
    })

    console.log(`✅ Tipo de ação criado com sucesso: ${newActionType.name} (Organização: ${auth.user.organizationId})`)

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

    console.log('✅ Usuário autenticado:', auth.user.email)
    console.log('🏢 Organização ID:', auth.user.organizationId)

    // Buscar tipos de ação da organização do usuário
    const dbActionTypes = await prisma.actionType.findMany({
      where: {
        organizationId: auth.user.organizationId
      },
      orderBy: {
        name: 'asc'
      }
    })

    console.log('📊 Tipos de ação da organização:', dbActionTypes.length)
    console.log('📋 Tipos de ação padrão disponíveis:', DEFAULT_ACTION_TYPES.length)

    // Formatar tipos de ação do banco
    const formattedDbActionTypes = dbActionTypes.map(at => ({
      id: at.id,
      name: at.name,
      description: at.description,
      isDefault: false // Tipo de ação criado no banco
    }))

    // Formatar tipos de ação padrão
    const formattedDefaultActionTypes = DEFAULT_ACTION_TYPES.map(at => ({
      id: at.id,
      name: at.name,
      description: at.description,
      isDefault: true // Tipo de ação padrão global
    }))

    // Combinar: tipos padrão primeiro, depois os do banco
    const allActionTypes = [...formattedDefaultActionTypes, ...formattedDbActionTypes]

    console.log('✅ Total de tipos de ação retornados:', allActionTypes.length)
    console.log('  - Padrão:', formattedDefaultActionTypes.length)
    console.log('  - Organização:', formattedDbActionTypes.length)

    return NextResponse.json({
      success: true,
      actionTypes: allActionTypes
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