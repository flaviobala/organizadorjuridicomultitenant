//src/app/api/systems/route.ts
import { NextRequest, NextResponse } from 'next/server'
import { requireAuth } from '@/lib/auth'
import { prisma } from '@/lib/prisma'
import { DEFAULT_SYSTEMS } from '@/lib/default-systems'

export async function POST(request: NextRequest) {
  try {
    console.log('📝 API POST Systems chamada')

    const auth = await requireAuth(request)
    if (!auth.success || !auth.user) {
      console.log('❌ Falha na autenticação:', auth.error)
      return NextResponse.json({ error: auth.error }, { status: 401 })
    }

    console.log('✅ Usuário autenticado:', auth.user.email)

    const body = await request.json()
    const { systemName, maxFileSize, maxPageSize } = body

    // Validações
    if (!systemName || !systemName.trim()) {
      return NextResponse.json({
        success: false,
        error: 'Nome do sistema é obrigatório'
      }, { status: 400 })
    }

    if (!maxFileSize || maxFileSize < 1) {
      return NextResponse.json({
        success: false,
        error: 'Tamanho máximo do arquivo deve ser pelo menos 1MB'
      }, { status: 400 })
    }

    if (!maxPageSize || maxPageSize < 100) {
      return NextResponse.json({
        success: false,
        error: 'Tamanho máximo por página deve ser pelo menos 100KB'
      }, { status: 400 })
    }

    // Verificar se é um nome de sistema padrão
    const isDefaultSystem = DEFAULT_SYSTEMS.some(
      sys => sys.systemName.toLowerCase() === systemName.trim().toLowerCase()
    )

    if (isDefaultSystem) {
      return NextResponse.json({
        success: false,
        error: 'Este nome de sistema já existe como padrão do sistema. Use outro nome.'
      }, { status: 409 })
    }

    // Verificar se já existe para esta organização
    const existingSystem = await prisma.systemConfiguration.findFirst({
      where: {
        organizationId: auth.user.organizationId,
        systemName: systemName.trim()
      }
    })

    if (existingSystem) {
      return NextResponse.json({
        success: false,
        error: 'Sistema já existe para sua organização'
      }, { status: 409 })
    }

    // Criar novo sistema para esta organização
    const newSystem = await prisma.systemConfiguration.create({
      data: {
        organizationId: auth.user.organizationId,
        systemName: systemName.trim(),
        maxFileSize: maxFileSize,
        maxPageSize: maxPageSize,
        allowedFormats: JSON.stringify(['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png']),
        pdfRequirements: JSON.stringify({
          maxSizeMB: Math.floor(maxFileSize / (1024 * 1024)),
          maxPageSizeKB: maxPageSize,
          resolution: 150,
          colorMode: 'RGB',
          compression: true
        })
      }
    })

    console.log('✅ Sistema criado com sucesso:', newSystem.systemName)

    return NextResponse.json({
      success: true,
      system: {
        systemName: newSystem.systemName,
        maxFileSize: newSystem.maxFileSize,
        maxPageSize: newSystem.maxPageSize
      }
    })

  } catch (error) {
    console.error('❌ Erro ao criar sistema:', error)
    return NextResponse.json({
      success: false,
      error: 'Erro interno do servidor',
      debug: error instanceof Error ? error.message : 'Erro desconhecido'
    }, { status: 500 })
  }
}

export async function GET(request: NextRequest) {
  try {
    console.log('🔍 API Systems chamada')

    const auth = await requireAuth(request)
    if (!auth.success || !auth.user) {
      console.log('❌ Falha na autenticação:', auth.error)
      return NextResponse.json({ error: auth.error }, { status: 401 })
    }

    console.log('✅ Usuário autenticado:', auth.user.email)
    console.log('🏢 Organização ID:', auth.user.organizationId)

    // Buscar sistemas da organização do usuário
    const orgSystems = await prisma.systemConfiguration.findMany({
      where: {
        organizationId: auth.user.organizationId
      },
      orderBy: { systemName: 'asc' }
    })

    console.log('📊 Sistemas da organização:', orgSystems.length)
    console.log('📋 Sistemas padrão disponíveis:', DEFAULT_SYSTEMS.length)

    // Formatar sistemas da organização
    const formattedOrgSystems = orgSystems.map(system => {
      let allowedFormats, pdfRequirements

      try {
        allowedFormats = JSON.parse(system.allowedFormats)
      } catch (e) {
        console.warn('Erro ao parsear allowedFormats:', e)
        allowedFormats = ['pdf', 'doc', 'docx', 'txt', 'jpg', 'jpeg', 'png']
      }

      try {
        pdfRequirements = JSON.parse(system.pdfRequirements)
      } catch (e) {
        console.warn('Erro ao parsear pdfRequirements:', e)
        pdfRequirements = { maxSizeMB: 5, maxPageSizeKB: 500 }
      }

      return {
        id: system.id,
        systemName: system.systemName,
        maxFileSize: system.maxFileSize,
        maxPageSize: system.maxPageSize,
        allowedFormats,
        pdfRequirements,
        isDefault: false // Sistema criado pela organização
      }
    })

    // Formatar sistemas padrão
    const formattedDefaultSystems = DEFAULT_SYSTEMS.map(system => ({
      id: system.id,
      systemName: system.systemName,
      maxFileSize: system.maxFileSize,
      maxPageSize: system.maxPageSize,
      allowedFormats: system.allowedFormats.split(','),
      pdfRequirements: { description: system.pdfRequirements },
      isDefault: true // Sistema padrão global
    }))

    // Combinar: sistemas padrão primeiro, depois os da organização
    const allSystems = [...formattedDefaultSystems, ...formattedOrgSystems]

    console.log('✅ Total de sistemas retornados:', allSystems.length)
    console.log('  - Padrão:', formattedDefaultSystems.length)
    console.log('  - Organização:', formattedOrgSystems.length)

    return NextResponse.json({
      success: true,
      systems: allSystems
    })

  } catch (error) {
    console.error('❌ Erro ao buscar sistemas:', error)
    return NextResponse.json({
      success: false,
      error: 'Erro interno do servidor',
      debug: error instanceof Error ? error.message : 'Erro desconhecido'
    }, { status: 500 })
  }
}