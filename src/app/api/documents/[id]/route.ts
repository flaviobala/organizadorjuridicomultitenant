// src/app/api/documents/[id]/route.ts
import { NextRequest, NextResponse } from 'next/server'
import { requireAuth } from '@/lib/auth'
import { prisma } from '@/lib/prisma'
import { createClient } from '@supabase/supabase-js'

// ✅ SUPABASE CLIENT CONSISTENTE
const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_ROLE_KEY!
)

export async function DELETE(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    console.log('🗑️ EXCLUSÃO DE DOCUMENTO INICIADA')
    
    const auth = await requireAuth(request)
    if (!auth.success || !auth.user) {
      return NextResponse.json({ error: auth.error }, { status: 401 })
    }
    // auth.user agora contém { id, email, name, organizationId }

    const resolvedParams = await params
    const documentId = parseInt(resolvedParams.id)

    if (isNaN(documentId)) {
      return NextResponse.json({
        success: false,
        error: 'ID do documento inválido'
      }, { status: 400 })
    }

    console.log('Buscando documento para excluir:', documentId)

    // ✅ ALTERAÇÃO MULTI-TENANT (Defesa em Profundidade)
    // Verificamos se o documento pertence à ORGANIZAÇÃO do usuário,
    // não apenas se o usuário (userId) fez o upload.
    const document = await prisma.document.findFirst({
      where: {
        id: documentId,
        organizationId: auth.user.organizationId // ✅ Filtro de Tenant
      },
      include: {
        project: true
      }
    })

    if (!document) {
      return NextResponse.json({
        success: false,
        error: 'Documento não encontrado ou não pertence à sua organização'
      }, { status: 404 })
    }

    console.log('📄 Documento encontrado para exclusão:', {
      id: document.id,
      storedFilename: document.storedFilename,
      pdfPath: document.pdfPath
    })

    // ✅ LÓGICA DE EXCLUSÃO DO SUPABASE STORAGE (Está correta)
    // A 'SERVICE_ROLE_KEY' bypassa o RLS, o que é necessário para
    // que a aplicação (admin) possa apagar os arquivos físicos.
    const filesToDelete = []
    
    if (document.storedFilename && document.storedFilename.includes('supabase')) {
      const originalPath = extractSupabasePath(document.storedFilename, 'original/')
      if (originalPath) filesToDelete.push(originalPath)
    }

    if (document.pdfPath && document.pdfPath.includes('supabase')) {
      const processedPath = extractSupabasePath(document.pdfPath, 'processed/')
      if (processedPath) filesToDelete.push(processedPath)
    }

    let deletedFilesCount = 0
    for (const path of filesToDelete) {
      try {
        console.log('🗑️ Tentando excluir arquivo do Supabase:', path)
        const { error } = await supabase.storage
          .from('documents')
          .remove([path])

        if (error) {
          console.warn('⚠️ Erro ao excluir arquivo do Supabase:', path, error)
        } else {
          console.log('✅ Arquivo excluído do Supabase:', path)
          deletedFilesCount++
        }
      } catch (error) {
        console.warn('⚠️ Erro ao excluir arquivo:', path, error)
      }
    }

    // ✅ EXCLUIR REGISTRO DO BANCO DE DADOS
    // Esta operação é segura. A política RLS (DELETE) que criamos
    // garante que o banco só executará esta 'delete' se o 'documentId'
    // pertencer à organização do usuário (auth.uid()).
    await prisma.document.delete({
      where: {
        id: documentId
      }
    })

    console.log('✅ Documento excluído do banco de dados:', documentId)

    return NextResponse.json({
      success: true,
      message: `Documento excluído com sucesso (${deletedFilesCount} arquivo(s) removido(s) do storage)`
    })

  } catch (error) {
    console.error('❌ Erro na exclusão de documento:', error)
    return NextResponse.json({
      success: false,
      error: error instanceof Error ? error.message : 'Erro interno do servidor'
    }, { status: 500 })
  }
}

// ✅ FUNÇÃO AUXILIAR (Sem mudanças)
function extractSupabasePath(url: string, prefix: string): string | null {
  try {
    const urlObj = new URL(url)
    const pathParts = urlObj.pathname.split('/')
    const documentsIndex = pathParts.indexOf('documents')
    
    if (documentsIndex !== -1 && documentsIndex < pathParts.length - 1) {
      return pathParts.slice(documentsIndex + 1).join('/')
    }
    
    return null
  } catch (error) {
    console.warn('Erro ao extrair path do Supabase:', error)
    return null
  }
}

// ✅ MÉTODO GET PARA BUSCAR DETALHES DO DOCUMENTO
export async function GET(
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
    const documentId = parseInt(resolvedParams.id)

    if (isNaN(documentId)) {
      return NextResponse.json({
        success: false,
        error: 'ID do documento inválido'
      }, { status: 400 })
    }

    // ✅ ALTERAÇÃO MULTI-TENANT (Defesa em Profundidade)
    // Verificamos se o documento pertence à ORGANIZAÇÃO do usuário.
    const document = await prisma.document.findFirst({
      where: {
        id: documentId,
        organizationId: auth.user.organizationId // ✅ Filtro de Tenant
      },
      include: {
        project: {
          select: {
            id: true,
            name: true
          }
        }
      }
    })

    if (!document) {
      return NextResponse.json({
        success: false,
        error: 'Documento não encontrado ou não pertence à sua organização'
      }, { status: 404 })
    }

    // ... (retorno dos dados do documento está OK) ...
    return NextResponse.json({
      success: true,
      document: {
        id: document.id,
        originalFilename: document.originalFilename,
        smartFilename: document.smartFilename,
        documentType: document.documentType,
        detectedDocumentType: document.detectedDocumentType,
        documentNumber: document.documentNumber,
        mimeType: document.mimeType,
        status: document.status,
        originalSizeBytes: document.originalSizeBytes,
        pdfSizeBytes: document.pdfSizeBytes,
        pageCount: document.pageCount,
        aiAnalysis: document.aiAnalysis ? JSON.parse(document.aiAnalysis) : null,
        analysisConfidence: document.analysisConfidence,
        createdAt: document.createdAt,
        project: document.project
      }
    })

  } catch (error) {
    console.error('❌ Erro ao buscar documento:', error)
    return NextResponse.json({
      success: false,
      error: error instanceof Error ? error.message : 'Erro interno do servidor'
    }, { status: 500 })
  }
}