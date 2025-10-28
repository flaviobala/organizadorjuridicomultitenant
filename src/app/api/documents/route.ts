// src/app/api/documents/route.ts
import { NextRequest, NextResponse } from 'next/server'
import { requireAuth } from '@/lib/auth'
import { prisma } from '@/lib/prisma'

export async function GET(request: NextRequest) {
  try {
    const auth = await requireAuth(request)
    if (!auth.success || !auth.user) {
      return NextResponse.json({ error: auth.error }, { status: 401 })
    }
    // auth.user agora contém { id, email, name, organizationId }

    const { searchParams } = new URL(request.url)
    const projectId = searchParams.get('projectId')

    if (!projectId) {
      return NextResponse.json({
        success: false,
        error: 'ProjectId é obrigatório'
      }, { status: 400 })
    }

    const projectIdNum = parseInt(projectId)
    if (isNaN(projectIdNum)) {
      return NextResponse.json({
        success: false,
        error: 'ProjectId inválido'
      }, { status: 400 })
    }

    // ✅ ALTERAÇÃO MULTI-TENANT (Defesa em Profundidade)
    // Garantir que o projeto pertence à organização do usuário.
    // O RLS já nos protege, mas o briefing (3.3) exige que a aplicação
    // também seja "tenant-aware".
    const project = await prisma.project.findFirst({
      where: {
        id: projectIdNum,
        // userId: auth.user.id, // Mantemos a verificação do "dono"
        organizationId: auth.user.organizationId // ✅ Filtro de Tenant
      }
    })

    if (!project) {
      return NextResponse.json({
        success: false,
        error: 'Projeto não encontrado ou não pertence à sua organização'
      }, { status: 404 })
    }

    // ✅ ALTERAÇÃO MULTI-TENANT
    // Buscar documentos filtrando pelo 'organizationId'.
    // Removemos o 'userId' daqui, pois o 'userId' no documento
    // refere-se a *quem fez o upload*, não ao dono.
    // A segurança é garantida pelo 'organizationId'.
    const documents = await prisma.document.findMany({
      where: {
        projectId: projectIdNum,
        organizationId: auth.user.organizationId // ✅ Filtro de Tenant
      },
      orderBy: {
        documentNumber: 'asc'
      },
      include: {
        validations: {
          orderBy: { createdAt: 'desc' },
          take: 1
        }
      }
    })

    // O restante do mapeamento está correto
    return NextResponse.json({
      success: true,
      documents: documents.map(doc => ({
        id: doc.id,
        originalFilename: doc.originalFilename,
        storedFilename: doc.storedFilename,
        documentType: doc.documentType,
        documentNumber: doc.documentNumber,
        mimeType: doc.mimeType,
        status: doc.status,
        pdfPath: doc.pdfPath,
        pageCount: doc.pageCount,
        originalSizeBytes: doc.originalSizeBytes,
        pdfSizeBytes: doc.pdfSizeBytes,
        createdAt: doc.createdAt,
        validation: doc.validations[0] || null
      }))
    })

  } catch (error) {
    console.error('Erro ao buscar documentos:', error)
    return NextResponse.json({
      success: false,
      error: 'Erro interno do servidor'
    }, { status: 500 })
  }
}