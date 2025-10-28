import { NextRequest, NextResponse } from 'next/server'
import { prisma } from '@/lib/prisma'
import { createClient } from '@supabase/supabase-js'
import sharp from 'sharp'
import { PDFDocument } from 'pdf-lib'
import jwt from 'jsonwebtoken'

const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_ROLE_KEY!
)

const JWT_SECRET = process.env.JWT_SECRET || 'your-secret-key'

interface JWTPayload {
  userId: number
  organizationId: number
}

/**
 * POST /api/documents/[id]/rotate
 * Rotaciona um documento (PDF com imagem) em 90° horário
 */
export async function POST(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    // Autenticação
    const authHeader = request.headers.get('authorization')
    if (!authHeader?.startsWith('Bearer ')) {
      return NextResponse.json({ success: false, error: 'Token não fornecido' }, { status: 401 })
    }

    const token = authHeader.substring(7)
    let decoded: JWTPayload

    try {
      decoded = jwt.verify(token, JWT_SECRET) as JWTPayload
    } catch {
      return NextResponse.json({ success: false, error: 'Token inválido' }, { status: 401 })
    }

    const resolvedParams = await params
    const documentId = parseInt(resolvedParams.id)

    if (isNaN(documentId)) {
      return NextResponse.json({ success: false, error: 'ID de documento inválido' }, { status: 400 })
    }

    // Buscar documento com isolamento de tenant
    const document = await prisma.document.findFirst({
      where: {
        id: documentId,
        organizationId: decoded.organizationId
      },
      include: { project: true }
    })

    if (!document) {
      return NextResponse.json({ success: false, error: 'Documento não encontrado ou sem permissão' }, { status: 404 })
    }

    // Verificação adicional: usuário é dono do projeto
    if (document.project.userId !== decoded.userId) {
      return NextResponse.json({ success: false, error: 'Acesso negado' }, { status: 403 })
    }

    // Obter graus de rotação (padrão: 90°)
    const body = await request.json()
    const degrees = body.degrees || 90

    if (![90, 180, 270, -90].includes(degrees)) {
      return NextResponse.json({ success: false, error: 'Rotação inválida. Use 90, 180, 270 ou -90' }, { status: 400 })
    }

    console.log(`🔄 Rotacionando documento ${documentId} em ${degrees}°...`)
    console.log(`📋 Dados do documento:`, {
      storedFilename: document.storedFilename,
      pdfPath: document.pdfPath,
      originalFilename: document.originalFilename
    })

    // Baixar PDF do Supabase
    if (!document.pdfPath) {
      return NextResponse.json({ success: false, error: 'Documento não possui PDF' }, { status: 400 })
    }

    // Extrair o caminho correto do arquivo a partir do pdfPath
    // pdfPath exemplo: "https://xxx.supabase.co/storage/v1/object/public/documents/processed/arquivo.pdf"
    let storagePath = ''

    // Tentar extrair do pdfPath (mais confiável)
    const pdfPathParts = document.pdfPath.split('/documents/')
    if (pdfPathParts.length > 1) {
      storagePath = pdfPathParts[1]
      console.log(`📁 Caminho extraído do pdfPath: ${storagePath}`)
    } else if (document.storedFilename) {
      // Fallback: usar storedFilename
      storagePath = document.storedFilename.startsWith('processed/')
        ? document.storedFilename
        : `processed/${document.storedFilename}`
      console.log(`📁 Usando storedFilename: ${storagePath}`)
    } else {
      console.error('❌ Não foi possível extrair caminho do arquivo')
      return NextResponse.json({ success: false, error: 'Não foi possível determinar o caminho do arquivo' }, { status: 400 })
    }

    const { data: pdfData, error: downloadError } = await supabase.storage
      .from('documents')
      .download(storagePath)

    if (downloadError || !pdfData) {
      console.error('❌ Erro ao baixar PDF:', downloadError)
      return NextResponse.json({ success: false, error: 'Erro ao baixar documento' }, { status: 500 })
    }

    // Converter Blob para Buffer
    const arrayBuffer = await pdfData.arrayBuffer()
    const pdfBuffer = Buffer.from(arrayBuffer)

    // Carregar PDF
    const pdfDoc = await PDFDocument.load(pdfBuffer, { ignoreEncryption: true })
    const pageCount = pdfDoc.getPageCount()

    console.log(`📄 PDF carregado: ${pageCount} página(s)`)

    // Rotacionar cada página
    for (let i = 0; i < pageCount; i++) {
      const page = pdfDoc.getPage(i)
      const currentRotation = page.getRotation().angle

      // Calcular nova rotação
      let newRotation = (currentRotation + degrees) % 360
      if (newRotation < 0) newRotation += 360

      page.setRotation({ type: 'degrees', angle: newRotation })
      console.log(`   Página ${i + 1}: ${currentRotation}° → ${newRotation}°`)
    }

    // Salvar PDF rotacionado
    const rotatedPdfBytes = await pdfDoc.save()
    const rotatedPdfBuffer = Buffer.from(rotatedPdfBytes)

    console.log(`💾 PDF rotacionado: ${(rotatedPdfBuffer.length / 1024).toFixed(2)} KB`)

    // Fazer upload do PDF rotacionado (sobrescrever)
    const { error: uploadError } = await supabase.storage
      .from('documents')
      .upload(storagePath, rotatedPdfBuffer, {
        contentType: 'application/pdf',
        upsert: true // Sobrescrever arquivo existente
      })

    if (uploadError) {
      console.error('❌ Erro ao fazer upload:', uploadError)
      return NextResponse.json({ success: false, error: 'Erro ao salvar documento rotacionado' }, { status: 500 })
    }

    // Atualizar tamanho no banco de dados
    await prisma.document.update({
      where: { id: documentId },
      data: {
        pdfSizeBytes: rotatedPdfBuffer.length,
        updatedAt: new Date()
      }
    })

    console.log(`✅ Documento ${documentId} rotacionado com sucesso!`)

    return NextResponse.json({
      success: true,
      message: `Documento rotacionado ${degrees}° com sucesso`,
      newSize: rotatedPdfBuffer.length
    })

  } catch (error) {
    console.error('❌ Erro ao rotacionar documento:', error)
    return NextResponse.json({
      success: false,
      error: error instanceof Error ? error.message : 'Erro desconhecido'
    }, { status: 500 })
  }
}
