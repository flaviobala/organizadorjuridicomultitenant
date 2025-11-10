// src/app/api/documents/[id]/route.ts
import { NextRequest, NextResponse } from 'next/server'
import { requireAuth } from '@/lib/auth'
import { prisma } from '@/lib/prisma'
import { deleteFile } from '@/lib/storage-service'

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

    // ✅ LÓGICA DE EXCLUSÃO DO STORAGE (Local ou Supabase)
    const filesToDelete = []

    // Extrair caminho do arquivo original
    if (document.storedFilename) {
      const originalPath = extractStoragePath(document.storedFilename, 'original/')
      if (originalPath) filesToDelete.push(originalPath)
    }

    // Extrair caminho do PDF processado
    if (document.pdfPath) {
      const processedPath = extractStoragePath(document.pdfPath, 'processed/')
      if (processedPath) filesToDelete.push(processedPath)
    }

    let deletedFilesCount = 0
    for (const path of filesToDelete) {
      try {
        console.log('🗑️ Tentando excluir arquivo do storage:', path)
        await deleteFile(path)
        console.log('✅ Arquivo excluído do storage:', path)
        deletedFilesCount++
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

/**
 * Extrai o caminho do storage de uma URL (Supabase ou Local)
 * Exemplos:
 * - Supabase: https://xxx.supabase.co/storage/v1/object/public/documents/processed/file.pdf → processed/file.pdf
 * - Local: http://localhost:3000/uploads/processed/file.pdf → processed/file.pdf
 * - Caminho relativo: processed/file.pdf → processed/file.pdf
 */
function extractStoragePath(url: string, prefix?: string): string | null {
  try {
    // Se não é uma URL, retornar como está
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      return url
    }

    const urlObj = new URL(url)
    const pathParts = urlObj.pathname.split('/')

    // Tentar extrair de URL Supabase
    const documentsIndex = pathParts.indexOf('documents')
    if (documentsIndex !== -1 && documentsIndex < pathParts.length - 1) {
      return pathParts.slice(documentsIndex + 1).join('/')
    }

    // Tentar extrair de URL Local
    const uploadsIndex = pathParts.indexOf('uploads')
    if (uploadsIndex !== -1 && uploadsIndex < pathParts.length - 1) {
      return pathParts.slice(uploadsIndex + 1).join('/')
    }

    return null
  } catch (error) {
    console.warn('Erro ao extrair path do storage:', error)
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