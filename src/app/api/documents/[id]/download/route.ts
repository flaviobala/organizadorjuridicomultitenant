// src/app/api/documents/[id]/download/route.ts
import { NextRequest, NextResponse } from 'next/server'
import { requireAuth } from '@/lib/auth'
import { prisma } from '@/lib/prisma'
import { createClient } from '@supabase/supabase-js'

// Configurar Supabase
const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_ROLE_KEY!
)

export async function GET(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    console.log('🔽 DOWNLOAD DE DOCUMENTO INICIADO')
    
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

    console.log('Buscando documento:', documentId, 'para organização:', auth.user.organizationId)

    // ✅ ALTERAÇÃO MULTI-TENANT (Defesa em Profundidade)
    // Verificamos se o documento pertence à ORGANIZAÇÃO do usuário.
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

    console.log('Documento encontrado:', {
      id: document.id,
      filename: document.originalFilename,
      pdfPath: document.pdfPath
    })

    // ... (A lógica de seleção de URL/Nome de arquivo permanece a mesma) ...
    let downloadUrl: string
    let fileName: string
    let mimeType: string

    if (document.pdfPath) {
      downloadUrl = document.pdfPath
      fileName = document.originalFilename.replace(/\.[^/.]+$/, '.pdf')
      mimeType = 'application/pdf'
    } else if (document.storedFilename) {
      downloadUrl = document.storedFilename
      fileName = document.originalFilename
      mimeType = document.mimeType
    } else {
      return NextResponse.json({
        success: false,
        error: 'Nenhum arquivo disponível para download'
      }, { status: 404 })
    }

    console.log('URL de download:', downloadUrl)

    // A lógica de download (Opção 1 e 2) está correta e agora
    // é segura, pois o 'document' foi validado pela organização.

    if (downloadUrl.startsWith('http')) {
      console.log('Redirecionando para Supabase Storage')
      return NextResponse.redirect(downloadUrl)
    }

    if (downloadUrl.includes('supabase.co')) {
      try {
        const urlParts = downloadUrl.split('/storage/v1/object/public/documents/')
        if (urlParts.length > 1) {
          const filePath = urlParts[1]
          
          console.log('Baixando do Supabase Storage:', filePath)
          
          // Usamos a SERVICE_ROLE_KEY para bypassar o RLS do Storage (se houver)
          const { data, error } = await supabase.storage
            .from('documents')
            .download(filePath)

          if (error) {
            console.error('Erro ao baixar do Supabase:', error)
            return NextResponse.json({
              success: false,
              error: 'Arquivo não encontrado no storage'
            }, { status: 404 })
          }

          const arrayBuffer = await data.arrayBuffer()
          const fileBuffer = Buffer.from(arrayBuffer)

          console.log('Arquivo baixado com sucesso:', {
            size: fileBuffer.length,
            fileName
          })

          return new NextResponse(fileBuffer, {
            status: 200,
            headers: {
              'Content-Type': mimeType,
              'Content-Disposition': `attachment; filename="${fileName}"`,
              'Content-Length': fileBuffer.length.toString(),
            },
          })
        }
      } catch (error) {
        console.error('Erro ao processar download do Supabase:', error)
      }
    }

    console.log('Usando fallback: redirecionamento direto')
    return NextResponse.redirect(downloadUrl)

  } catch (error) {
    console.error('Erro no download de documento:', error)
    return NextResponse.json({
      success: false,
      error: error instanceof Error ? error.message : 'Erro interno do servidor'
    }, { status: 500 })
  }
}