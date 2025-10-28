// src/app/api/ai/process-narrative/route.ts
import { NextRequest, NextResponse } from 'next/server'
import { requireAuth } from '@/lib/auth'
import { prisma } from '@/lib/prisma'
import { OpenAIService } from '@/lib/openai' // Assumindo que esta classe não acessa o 'prisma'
import { z } from 'zod'

const processNarrativeSchema = z.object({
  projectId: z.number(),
  narrative: z.string().min(10, 'Narrativa deve ter pelo menos 10 caracteres'),
})

export async function POST(request: NextRequest) {
  try {
    console.log('🤖 API de processamento de narrativa chamada')
    
    const auth = await requireAuth(request)
    if (!auth.success || !auth.user) {
      return NextResponse.json({ error: auth.error }, { status: 401 })
    }
    // auth.user agora contém { id, email, name, organizationId }

    const body = await request.json()
    
    // Validar dados
    const validation = processNarrativeSchema.safeParse(body)
    if (!validation.success) {
      return NextResponse.json({
        success: false,
        error: 'Dados inválidos',
        details: validation.error.errors
      }, { status: 400 })
    }

    const { projectId, narrative } = validation.data

    // ✅ ALTERAÇÃO MULTI-TENANT (Defesa em Profundidade)
    // Verificamos se o projeto pertence à ORGANIZAÇÃO do usuário.
    const project = await prisma.project.findFirst({
      where: {
        id: projectId,
        organizationId: auth.user.organizationId // ✅ Filtro de Tenant
      }
    })

    if (!project) {
      return NextResponse.json({
        success: false,
        error: 'Projeto não encontrado ou não pertence à sua organização'
      }, { status: 404 })
    }

    console.log('Processando narrativa para projeto:', project.name)

    // Atualizar status do projeto (Seguro)
    // O RLS nos protege de updates indevidos.
    await prisma.project.update({
      where: { id: projectId },
      data: { 
        status: 'processing',
        narrative: narrative
      }
    })

    // Processar narrativa com OpenAI (OK)
    const openaiService = new OpenAIService()
    const result = await openaiService.processNarrative(narrative, project.actionType)

    if (!result.success) {
      // Reverter status em caso de erro (Seguro)
      await prisma.project.update({
        where: { id: projectId },
        data: { status: 'draft' }
      })

      return NextResponse.json({
        success: false,
        error: result.error || 'Erro no processamento da narrativa'
      }, { status: 500 })
    }

    // Salvar narrativa processada (Seguro)
    const updatedProject = await prisma.project.update({
      where: { id: projectId },
      data: {
        processedNarrative: result.processedNarrative,
        status: 'completed'
      }
    })

    console.log('✅ Narrativa processada com sucesso')

    // ... (Retorno OK) ...
    return NextResponse.json({
      success: true,
      message: 'Narrativa processada com sucesso',
      data: {
        originalNarrative: narrative,
        processedNarrative: result.processedNarrative,
        suggestions: result.suggestions,
        projectStatus: updatedProject.status
      }
    })

  } catch (error) {
    console.error('Erro na API de processamento de narrativa:', error)
    return NextResponse.json({
      success: false,
      error: 'Erro interno do servidor'
    }, { status: 500 })
  }
}