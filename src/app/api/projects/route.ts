// src/app/api/projects/route.ts
import { NextRequest, NextResponse } from 'next/server'
import { requireAuth } from '@/lib/auth'
import { prisma } from '@/lib/prisma'
import { z } from 'zod'

const createProjectSchema = z.object({
  name: z.string().min(2, 'Nome do projeto deve ter pelo menos 2 caracteres'),
  client: z.string().min(2, 'Nome do cliente deve ter pelo menos 2 caracteres'),
  system: z.string().min(1, 'Sistema é obrigatório'),
  actionType: z.string().min(1, 'Tipo de ação é obrigatório'),
  narrative: z.string().optional(),
})

// GET - Listar projetos (AGORA FILTRADO POR ORGANIZAÇÃO)
export async function GET(request: NextRequest) {
  try {
    const auth = await requireAuth(request)
    if (!auth.success || !auth.user) {
      return NextResponse.json({ error: auth.error }, { status: 401 })
    }

    // ✅ ALTERAÇÃO MULTI-TENANT
    // Adicionamos 'organizationId' ao 'where'.
    // Embora o RLS (Banco) já nos proteja, o briefing (Item 3.3)
    // exige que a aplicação também seja "tenant-aware" (Defesa em Profundidade).
    const projects = await prisma.project.findMany({
      where: {
        userId: auth.user.id, // Mantém a lógica original
        organizationId: auth.user.organizationId // ✅ Filtro de Tenant
      },
      orderBy: { createdAt: 'desc' },
      include: {
        documents: {
          select: {
            id: true,
            documentType: true,
            status: true
          }
        },
        _count: {
          select: {
            documents: true
          }
        }
      }
    })

    // O restante do mapeamento de retorno está correto
    return NextResponse.json({
      success: true,
      projects: projects.map(project => ({
        id: project.id,
        name: project.name,
        client: project.client,
        system: project.system,
        actionType: project.actionType,
        narrative: project.narrative,
        processedNarrative: project.processedNarrative,
        status: project.status,
        createdAt: project.createdAt,
        updatedAt: project.updatedAt,
        documentsCount: project._count.documents,
        documents: project.documents
      }))
    })

  } catch (error) {
    console.error('Erro ao listar projetos:', error)
    return NextResponse.json({
      success: false,
      error: 'Erro interno do servidor'
    }, { status: 500 })
  }
}

// POST - Criar novo projeto (AGORA LIGADO À ORGANIZAÇÃO)
export async function POST(request: NextRequest) {
  try {
    const auth = await requireAuth(request)
    if (!auth.success || !auth.user) {
      return NextResponse.json({ error: auth.error }, { status: 401 })
    }
    
    // O auth.user agora contém: { id, email, name, organizationId }

    const body = await request.json()
    
    // Validar dados
    const validation = createProjectSchema.safeParse(body)
    if (!validation.success) {
      return NextResponse.json({
        success: false,
        error: 'Dados inválidos',
        details: validation.error.errors
      }, { status: 400 })
    }

    const { name, client, system, actionType, narrative } = validation.data

    // Verificar sistema (lógica de negócio mantida)
    const systemConfig = await prisma.systemConfiguration.findUnique({
      where: { systemName: system }
    })

    if (!systemConfig) {
      return NextResponse.json({
        success: false,
        error: 'Sistema judicial não encontrado'
      }, { status: 400 })
    }

    // ✅ ALTERAÇÃO MULTI-TENANT
    // Injetamos o 'organizationId' (vindo do requireAuth) no 'create'.
    // Isso é OBRIGATÓRIO para satisfazer o RLS (WITH CHECK) e o Schema.
    const project = await prisma.project.create({
      data: {
        userId: auth.user.id,
        organizationId: auth.user.organizationId, // ✅ Injeção do Tenant
        name,
        client,
        system,
        actionType,
        narrative,
        status: 'draft'
      }
    })

    // O restante do retorno está correto
    return NextResponse.json({
      success: true,
      message: 'Projeto criado com sucesso',
      project: {
        id: project.id,
        name: project.name,
        client: project.client,
        system: project.system,
        actionType: project.actionType,
        narrative: project.narrative,
        status: project.status,
        createdAt: project.createdAt
      }
    }, { status: 201 })

  } catch (error) {
    console.error('Erro ao criar projeto:', error)
    return NextResponse.json({
      success: false,
      error: 'Erro interno do servidor'
    }, { status: 500 })
  }
}