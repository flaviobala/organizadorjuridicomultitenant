import { NextRequest, NextResponse } from 'next/server'
import fs from 'fs'
import path from 'path'

/**
 * Rota para servir arquivos estáticos do diretório de uploads local
 *
 * Exemplos:
 * - GET /uploads/processed/documento.pdf
 * - GET /uploads/logos/1/logo.png
 * - GET /uploads/original/imagem.jpg
 */
export async function GET(
  request: NextRequest,
  { params }: { params: Promise<{ path: string[] }> }
) {
  try {
    const resolvedParams = await params
    const filePath = resolvedParams.path.join('/')

    // Diretório base de uploads
    const uploadDir = process.env.UPLOAD_DIR
    if (!uploadDir) {
      return NextResponse.json(
        { error: 'UPLOAD_DIR não configurado' },
        { status: 500 }
      )
    }

    // Caminho completo do arquivo
    const fullPath = path.join(uploadDir, filePath)

    // Verificar se o arquivo existe
    if (!fs.existsSync(fullPath)) {
      return NextResponse.json(
        { error: 'Arquivo não encontrado' },
        { status: 404 }
      )
    }

    // Verificar se é um arquivo (não um diretório)
    const stats = fs.statSync(fullPath)
    if (!stats.isFile()) {
      return NextResponse.json(
        { error: 'Caminho inválido' },
        { status: 400 }
      )
    }

    // Ler o arquivo
    const fileBuffer = fs.readFileSync(fullPath)

    // Determinar o tipo MIME baseado na extensão
    const ext = path.extname(fullPath).toLowerCase()
    const mimeTypes: Record<string, string> = {
      '.pdf': 'application/pdf',
      '.png': 'image/png',
      '.jpg': 'image/jpeg',
      '.jpeg': 'image/jpeg',
      '.gif': 'image/gif',
      '.svg': 'image/svg+xml',
      '.webp': 'image/webp',
      '.txt': 'text/plain',
      '.doc': 'application/msword',
      '.docx': 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    }

    const contentType = mimeTypes[ext] || 'application/octet-stream'

    // Retornar o arquivo com o tipo MIME correto
    return new NextResponse(fileBuffer, {
      status: 200,
      headers: {
        'Content-Type': contentType,
        'Content-Length': fileBuffer.length.toString(),
        'Cache-Control': 'public, max-age=31536000, immutable',
      },
    })
  } catch (error) {
    console.error('Erro ao servir arquivo:', error)
    return NextResponse.json(
      { error: 'Erro ao carregar arquivo' },
      { status: 500 }
    )
  }
}
