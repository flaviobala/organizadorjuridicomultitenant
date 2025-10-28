// src/app/api/projects/[id]/route.ts

import { NextRequest, NextResponse } from 'next/server'
import { requireAuth } from '@/lib/auth'
import { prisma } from '@/lib/prisma'

export async function GET(
  request: NextRequest, 
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    console.log('🚀 BUSCA DE PROJETO INICIADA')
    
    const auth = await requireAuth(request)
    if (!auth.success || !auth.user) {
      return NextResponse.json({ error: auth.error }, { status: 401 })
    }
    // auth.user agora contém { id, email, name, organizationId }

    const resolvedParams = await params
    const projectId = parseInt(resolvedParams.id)

    if (isNaN(projectId)) {
      return NextResponse.json({
        success: false,
        error: 'ID do projeto inválido'
      }, { status: 400 })
    }

    console.log('Buscando projeto:', projectId, 'para organização:', auth.user.organizationId)

    // ✅ ALTERAÇÃO MULTI-TENANT (Defesa em Profundidade)
    // Verificamos se o projeto pertence à ORGANIZAÇÃO do usuário.
    // A lógica de 'userId' (dono) foi removida, pois a organização é a fronteira.
    const project = await prisma.project.findFirst({
      where: {
        id: projectId,
        organizationId: auth.user.organizationId // ✅ Filtro de Tenant
      },
      include: {
        documents: {
          // ✅ ALTERAÇÃO MULTI-TENANT: Garantir que os documentos
          //    incluídos também são da mesma organização.
          where: {
            organizationId: auth.user.organizationId
          },
          select: {
            id: true,
            originalFilename: true,
            storedFilename: true,
            smartFilename: true,
            documentType: true,
            detectedDocumentType: true,
            documentNumber: true,
            mimeType: true,
            originalSizeBytes: true,
            status: true,
            pdfPath: true,
            ocrText: true,
            pdfSizeBytes: true,
            pageCount: true,
            pageSize: true,
            aiAnalysis: true,
            analysisConfidence: true,
            isPersonalDocument: true,
            createdAt: true,
            updatedAt: true,
            validations: {
              select: {
                id: true,
                isRelevant: true,
                relevanceScore: true,
                aiAnalysis: true,
                suggestions: true,
                status: true,
                reviewedAt: true
              }
            }
          },
          orderBy: {
            documentNumber: "asc"
          }
        }
      }
    })

    if (!project) {
      return NextResponse.json({
        success: false,
        error: 'Projeto não encontrado ou não pertence à sua organização'
      }, { status: 404 })
    }

    console.log('✅ Projeto encontrado:', {
      id: project.id,
      name: project.name,
      documentCount: project.documents.length
    })

    // ... (Lógica de retorno e parse OK) ...
    return NextResponse.json({
      success: true,
      project: {
        ...project,
        documents: project.documents.map(doc => ({
          ...doc,
          aiAnalysis: doc.aiAnalysis ? JSON.parse(doc.aiAnalysis) : null,
          hasOcrText: !!doc.ocrText,
          isPersonalDocument: !!doc.isPersonalDocument,
          validation: doc.validations && doc.validations.length > 0 ? {
            isRelevant: doc.validations[0].isRelevant,
            relevanceScore: doc.validations[0].relevanceScore,
            analysis: doc.validations[0].aiAnalysis,
            suggestions: doc.validations[0].suggestions,
            status: doc.validations[0].status
          } : null
        }))
      }
    })

  } catch (error) {
    console.error('❌ Erro ao buscar projeto:', error)
    return NextResponse.json({
      success: false,
      error: error instanceof Error ? error.message : 'Erro interno do servidor'
    }, { status: 500 })
  }
}

export async function PUT(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const auth = await requireAuth(request)
    if (!auth.success || !auth.user) {
      return NextResponse.json({ error: auth.error }, { status: 401 })
    }
    // auth.user agora contém { id, email, name, organizationId }

    const resolvedParams = await params
    const projectId = parseInt(resolvedParams.id)

    if (isNaN(projectId)) {
      return NextResponse.json({
        success: false,
        error: 'ID do projeto inválido'
      }, { status: 400 })
    }

    const body = await request.json()
    const { name, client, system, actionType, narrative, status, processedNarrative } = body

    // ✅ ALTERAÇÃO MULTI-TENANT (Defesa em Profundidade)
    // Verificamos se o projeto pertence à ORGANIZAÇÃO do usuário
    // antes de permitir a atualização.
    const existingProject = await prisma.project.findFirst({
      where: {
        id: projectId,
        organizationId: auth.user.organizationId // ✅ Filtro de Tenant
      }
    })

    if (!existingProject) {
      return NextResponse.json({
        success: false,
        error: 'Projeto não encontrado ou não pertence à sua organização'
      }, { status: 404 })
    }

    // A atualização é segura, pois 'where: { id: projectId }' é único
    // e já validamos a propriedade (acima). O RLS também protege.
    const updatedProject = await prisma.project.update({
      where: { id: projectId },
      data: {
        name: name || existingProject.name,
        client: client || existingProject.client,
        system: system || existingProject.system,
        actionType: actionType || existingProject.actionType,
        narrative: narrative !== undefined ? narrative : existingProject.narrative,
        processedNarrative: processedNarrative !== undefined ? processedNarrative : existingProject.processedNarrative,
        status: status || existingProject.status,
        updatedAt: new Date()
      }
    })

    return NextResponse.json({
      success: true,
      project: updatedProject
    })

  } catch (error) {
    console.error('❌ Erro ao atualizar projeto:', error)
    return NextResponse.json({
      success: false,
      error: error instanceof Error ? error.message : 'Erro interno do servidor'
    }, { status: 500 })
  }
}

export async function DELETE(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    console.log('🗑️ EXCLUSÃO DE PROJETO INICIADA')
    
    const auth = await requireAuth(request)
    if (!auth.success || !auth.user) {
      return NextResponse.json({ error: auth.error }, { status: 401 })
    }
    // auth.user agora contém { id, email, name, organizationId }

    const resolvedParams = await params
    const projectId = parseInt(resolvedParams.id)

    if (isNaN(projectId)) {
      return NextResponse.json({
        success: false,
        error: 'ID do projeto inválido'
      }, { status: 400 })
    }

    console.log('Deletando projeto:', projectId, 'para organização:', auth.user.organizationId)

    // ✅ ALTERAÇÃO MULTI-TENANT (Defesa em Profundidade)
    // Verificamos se o projeto pertence à ORGANIZAÇÃO do usuário.
    const existingProject = await prisma.project.findFirst({
      where: {
        id: projectId,
        organizationId: auth.user.organizationId // ✅ Filtro de Tenant
      },
      include: {
        documents: { 
          // ✅ Filtro de Tenant na inclusão
          where: { organizationId: auth.user.organizationId },
          select: { id: true }
        }
      }
    })

    if (!existingProject) {
      return NextResponse.json({
        success: false,
        error: 'Projeto não encontrado ou não pertence à sua organização'
      }, { status: 404 })
    }

    console.log(`Projeto "${existingProject.name}" tem ${existingProject.documents.length} documento(s)`)

    // Deletar documentos associados
    // (Embora o schema tenha cascade, RLS pode bloquear. Ser explícito é mais seguro)
    if (existingProject.documents.length > 0) {
      console.log('Deletando documentos associados...')
      
      // ✅ ALTERAÇÃO MULTI-TENANT: Adicionar filtro de tenant ao deleteMany
      await prisma.document.deleteMany({
        where: { 
          projectId: projectId,
          organizationId: auth.user.organizationId // ✅ Filtro de Tenant
        }
      })
      console.log('✅ Documentos deletados')
    }

    // Deletar o projeto
    // RLS garante a segurança aqui.
    await prisma.project.delete({
      where: { id: projectId }
    })

    console.log('✅ Projeto deletado com sucesso!')

    return NextResponse.json({
      success: true,
      message: `Projeto "${existingProject.name}" excluído com sucesso`
    })

  } catch (error) {
    console.error('❌ Erro ao excluir projeto:', error)
    return NextResponse.json({
      success: false,
      error: error instanceof Error ? error.message : 'Erro interno do servidor'
    }, { status: 500 })
  }
}