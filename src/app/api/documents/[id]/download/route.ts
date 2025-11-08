// Caminho: src/app/api/documents/[id]/download/route.ts
// (Arquivo MODIFICADO)

import { NextRequest, NextResponse } from 'next/server'
import { requireAuth } from '@/lib/auth'
import { prisma } from '@/lib/prisma'
// [REMOVIDO] A linha que quebrava o build
// import { createClient } from '@supabase/supabase-js'

// [ADICIONADO] Importamos nosso novo serviço "inteligente" e o BUCKET_NAME
import { downloadFile, BUCKET_NAME } from '@/lib/storage-service'

// [REMOVIDO] A inicialização do client
// const supabase = createClient(...)

export async function GET(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    console.log('🔽 DOWNLOAD DE DOCUMENTO INICIADO (Modo Serviço)')
    
    const auth = await requireAuth(request)
    if (!auth.success || !auth.user) {
      return NextResponse.json({ error: auth.error }, { status: 401 })
    }

    const resolvedParams = await params
    const documentId = parseInt(resolvedParams.id)

    if (isNaN(documentId)) {
      return NextResponse.json({
        success: false,
        error: 'ID do documento inválido'
      }, { status: 400 })
    }

    console.log('Buscando documento:', documentId, 'para organização:', auth.user.organizationId)

    // ✅ Lógica Multi-Tenant (PERMANECE IGUAL)
    const document = await prisma.document.findFirst({
      where: {
        id: documentId,
        organizationId: auth.user.organizationId // ✅ Filtro de Tenant
      },
      // (Flavio, baseado no seu código, os campos de path estão no model 'document')
    })

    if (!document) {
      return NextResponse.json({
        success: false,
        error: 'Documento não encontrado ou não pertence à sua organização'
      }, { status: 404 })
    }

    console.log('Documento encontrado:', {
      id: document.id,
      filename: document.originalFilename,
      pdfPath: document.pdfPath,
      storedFilename: document.storedFilename
    })

    // --- Lógica de seleção de arquivo (PERMANECE IGUAL) ---
    // (Baseado no seu schema: pdfPath ou storedFilename)
    let storagePath: string | null = null
    let fileName: string
    let mimeType: string

    if (document.pdfPath) {
      storagePath = document.pdfPath
      fileName = document.originalFilename.replace(/\.[^/.]+$/, '.pdf')
      mimeType = 'application/pdf'
    } else if (document.storedFilename) {
      storagePath = document.storedFilename
      fileName = document.originalFilename
      mimeType = document.mimeType
    } else {
      return NextResponse.json({
        success: false,
        error: 'Nenhum arquivo disponível para download'
      }, { status: 404 })
    }

    // --- [MUDANÇA CRÍTICA] ---
    // A lógica antiga de (IF http / IF supabase.co) foi removida
    // e substituída por uma chamada única ao nosso serviço.
    
    // O 'storagePath' salvo no banco pode ser uma URL completa (antigo)
    // ou um caminho relativo (novo). Nosso serviço precisa
    // do *caminho relativo* (ex: org-123/arquivo.pdf).
    
    // Tentamos extrair o caminho relativo da URL
    let relativePath = storagePath;
    if (storagePath.startsWith('http')) {
        try {
            // Tenta extrair 'org-123/arquivo.pdf' de 
            // 'https://[...].supabase.co/storage/v1/object/public/documents/org-123/arquivo.pdf'
            const url = new URL(storagePath);
            const pathParts = url.pathname.split(`/storage/v1/object/public/${BUCKET_NAME}/`);
            if (pathParts.length > 1) {
                relativePath = pathParts[1];
            }
        } catch (e) {
            console.error("Não foi possível parsear a URL de storage antiga:", storagePath);
            // Se falhar, talvez seja um link externo, redirecionamos
            return NextResponse.redirect(storagePath);
        }
    }

    console.log('Caminho relativo para download:', relativePath)

    try {
      // 1. Chamamos nosso serviço "cérebro"
      const fileBuffer = await downloadFile(relativePath)

      console.log('Arquivo baixado pelo serviço:', {
        size: fileBuffer.length,
        fileName
      })

      // 2. Retornamos o buffer
      // [CORREÇÃO] Envolvemos o fileBuffer com Buffer.from() para garantir
      // a compatibilidade de tipo com o NextResponse.
      return new NextResponse(Buffer.from(fileBuffer), {
        status: 200,
        headers: {
          'Content-Type': mimeType,
          'Content-Disposition': `attachment; filename="${fileName}"`,
          'Content-Length': fileBuffer.length.toString(),
        },
      })
      
    } catch (error: any) {
      console.error('Erro ao baixar pelo Storage Service:', error)
      
      // Fallback: Se o serviço falhar (ex: arquivo não encontrado)
      // e o 'storagePath' original era uma URL, tentamos redirecionar.
      if (storagePath.startsWith('http')) {
        console.log('Fallback: Redirecionando para URL original', storagePath);
        return NextResponse.redirect(storagePath);
      }
      
      return NextResponse.json({
        success: false,
        error: 'Arquivo não encontrado no storage'
      }, { status: 404 })
    }

  } catch (error) {
    console.error('Erro no download de documento:', error)
    return NextResponse.json({
      success: false,
      error: error instanceof Error ? error.message : 'Erro interno do servidor'
    }, { status: 500 })
  }
}
