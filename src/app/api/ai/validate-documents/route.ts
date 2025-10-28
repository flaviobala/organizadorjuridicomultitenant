// src/app/api/documents/validate/route.ts
import { NextRequest, NextResponse } from 'next/server'
import { requireAuth } from '@/lib/auth'
import { prisma } from '@/lib/prisma'
import { OpenAIService } from '@/lib/openai' // Assumindo que esta classe não acessa o 'prisma'
import { z } from 'zod'

const validateDocumentsSchema = z.object({
  projectId: z.number(),
})

export async function POST(request: NextRequest) {
  try {
    console.log('🔍 API de validação de documentos chamada')
    
    const auth = await requireAuth(request)
    if (!auth.success || !auth.user) {
      return NextResponse.json({ error: auth.error }, { status: 401 })
    }
    // auth.user agora contém { id, email, name, organizationId }

    const body = await request.json()
    
    // Validar dados
    const validation = validateDocumentsSchema.safeParse(body)
    if (!validation.success) {
      return NextResponse.json({
        success: false,
        error: 'Dados inválidos',
        details: validation.error.errors
      }, { status: 400 })
    }

    const { projectId } = validation.data

    // ✅ ALTERAÇÃO MULTI-TENANT (Defesa em Profundidade)
    // Buscar projeto filtrando pela Organização.
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
          orderBy: { documentNumber: 'asc' }
        }
      }
    })

    if (!project) {
      return NextResponse.json({
        success: false,
        error: 'Projeto não encontrado ou não pertence à sua organização'
      }, { status: 404 })
    }

    // ... (Validações de 'processedNarrative' e 'documents.length' OK) ...
    if (!project.processedNarrative) {
      return NextResponse.json({
        success: false,
        error: 'Narrativa deve ser processada antes da validação dos documentos'
      }, { status: 400 })
    }
    if (project.documents.length === 0) {
      return NextResponse.json({
        success: false,
        error: 'Nenhum documento encontrado para validação'
      }, { status: 400 })
    }

    console.log(`Validando ${project.documents.length} documentos para projeto: ${project.name}`)

    const openaiService = new OpenAIService()
    const validationResults = []

    // O loop 'for (const document of project.documents)' é seguro,
    // pois 'project.documents' já foi filtrado pelo organizationId.
    for (const document of project.documents) {
      console.log(`Validando documento: ${document.documentType}`)

      const documentText = document.ocrText || `Documento do tipo ${document.documentType}: ${document.originalFilename}`

      const validation = await openaiService.validateDocumentRelevance(
        project.processedNarrative,
        documentText,
        document.documentType,
        project.actionType
      )

      // ✅ ALTERAÇÃO MULTI-TENANT (Injeção Obrigatória)
      // Injetamos o 'organizationId' no 'create' do 'upsert'.
      // Sem isso, a criação falharia no RLS e no Schema.
      const savedValidation = await prisma.documentValidation.upsert({
        where: { documentId: document.id },
        update: {
          isRelevant: validation.relevant,
          relevanceScore: validation.confidence,
          aiAnalysis: validation.reasoning,
          suggestions: null,
          status: validation.relevant ? 'approved' : 'needs_revision',
          reviewedAt: new Date()
        },
        create: {
          projectId: projectId,
          documentId: document.id,
          organizationId: auth.user.organizationId, // ✅ Injeção do Tenant
          isRelevant: validation.relevant,
          relevanceScore: validation.confidence,
          aiAnalysis: validation.reasoning,
          suggestions: null,
          status: validation.relevant ? 'approved' : 'needs_revision'
        }
      })

      validationResults.push({
        documentId: document.id,
        // ... (outros dados de resultado) ...
        status: savedValidation.status
      })

      // Pequena pausa entre validações para evitar rate limit
      await new Promise(resolve => setTimeout(resolve, 1000))
    }

    // ... (Lógica de 'inconsistencyAnalysis' OK, pois não acessa o DB) ...
    const documentsForAnalysis = project.documents.map(doc => ({
      type: doc.documentType,
      text: doc.ocrText || `${doc.documentType}: ${doc.originalFilename}`
    }))
    console.log('Detectando inconsistências gerais...')
    const inconsistencyAnalysis = await openaiService.detectInconsistencies(
      project.processedNarrative,
      documentsForAnalysis,
      project.actionType
    )


    // Atualizar status do projeto
    // Esta operação é segura, pois 'projectId' foi validado acima
    // e o RLS protege a tabela 'projects' contra updates indevidos.
    const allRelevant = validationResults.every(result => result.isRelevant)
    const newStatus = allRelevant ? 'validated' : 'completed'
    await prisma.project.update({
      where: { id: projectId },
      data: { status: newStatus }
    })

    console.log('✅ Validação de documentos concluída')

    // ... (Lógica de 'stats' e 'return' OK) ...
    const stats = {
      totalDocuments: validationResults.length,
      relevantDocuments: validationResults.filter(r => r.isRelevant).length,
      averageRelevanceScore: Math.round(
        validationResults.reduce((sum, r) => sum + r.relevanceScore, 0) / (validationResults.length || 1)
      ),
      needsRevision: validationResults.filter(r => !r.isRelevant).length
    }

    return NextResponse.json({
      success: true,
      message: 'Validação de documentos concluída',
      data: {
        projectStatus: newStatus,
        validationResults,
        inconsistencies: inconsistencyAnalysis.inconsistencies,
        recommendations: inconsistencyAnalysis.recommendations,
        statistics: stats
      }
    })

  } catch (error) {
    console.error('Erro na API de validação de documentos:', error)
    return NextResponse.json({
      success: false,
      error: 'Erro interno do servidor'
    }, { status: 500 })
  }
}