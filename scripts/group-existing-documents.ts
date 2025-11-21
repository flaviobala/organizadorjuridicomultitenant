/**
 * Script para agrupar retroativamente documentos similares existentes
 *
 * Uso: npx tsx scripts/group-existing-documents.ts [projectId]
 */

import { PrismaClient } from '@prisma/client'
import { PDFDocument } from 'pdf-lib'
import fs from 'fs'
import path from 'path'

const prisma = new PrismaClient()

interface DocumentToGroup {
  id: number
  storedFilename: string
  pdfPath: string | null
  detectedDocumentType: string | null
  documentType: string
}

/**
 * Normaliza tipo de documento para comparação
 */
function normalizeDocumentType(documentType: string): string {
  if (!documentType) return ''

  return documentType
    .toLowerCase()
    .normalize('NFD').replace(/[\u0300-\u036f]/g, '') // Remove acentos
    .replace(/^\d+\s*/, '') // Remove números iniciais
    .replace(/\b(de|da|do|dos|das)\b/g, '') // Remove artigos
    .replace(/\b(individual|pessoal|completo|geral)\b/g, '') // Remove palavras genéricas
    .replace(/[^\w\s]/g, '') // Remove pontuação
    .replace(/\s+/g, ' ') // Normaliza espaços
    .trim()
}

/**
 * Verifica se dois tipos são similares
 */
function areDocumentTypesSimilar(type1: string, type2: string): boolean {
  const normalized1 = normalizeDocumentType(type1)
  const normalized2 = normalizeDocumentType(type2)

  if (normalized1 === normalized2) return true

  const words1 = normalized1.split(' ').filter(w => w.length > 3)
  const words2 = normalized2.split(' ').filter(w => w.length > 3)
  const commonWords = words1.filter(w => words2.includes(w))

  return commonWords.length > 0 && words1[0] === words2[0]
}

/**
 * Agrupa documentos por tipo similar
 */
function groupDocumentsByType(documents: DocumentToGroup[]): Map<string, DocumentToGroup[]> {
  const groups = new Map<string, DocumentToGroup[]>()

  for (const doc of documents) {
    const docType = doc.detectedDocumentType || doc.documentType
    let foundGroup = false

    // Procurar grupo similar existente
    for (const [groupKey, groupDocs] of groups.entries()) {
      if (areDocumentTypesSimilar(groupKey, docType)) {
        groupDocs.push(doc)
        foundGroup = true
        break
      }
    }

    // Criar novo grupo se não encontrou similar
    if (!foundGroup) {
      groups.set(docType, [doc])
    }
  }

  return groups
}

/**
 * Combina múltiplos PDFs em um único
 */
async function combinePDFs(documents: DocumentToGroup[], uploadDir: string): Promise<Buffer> {
  const mergedPdf = await PDFDocument.create()

  for (const doc of documents) {
    try {
      // Extrair caminho do arquivo
      let filePath = ''

      if (doc.pdfPath) {
        // Extrair de URL
        const pathParts = doc.pdfPath.split('/').filter(p => p.length > 0)
        if (pathParts.length >= 2) {
          filePath = path.join(uploadDir, pathParts.slice(-2).join('/'))
        }
      }

      if (!filePath || !fs.existsSync(filePath)) {
        // Fallback: usar storedFilename
        filePath = path.join(uploadDir, 'processed', doc.storedFilename)
      }

      if (!fs.existsSync(filePath)) {
        console.warn(`⚠️ Arquivo não encontrado: ${doc.storedFilename}`)
        continue
      }

      const pdfBytes = fs.readFileSync(filePath)
      const pdf = await PDFDocument.load(pdfBytes)
      const pages = await mergedPdf.copyPages(pdf, pdf.getPageIndices())

      pages.forEach(page => mergedPdf.addPage(page))

      console.log(`   ✅ ${doc.storedFilename} (${pages.length} páginas)`)
    } catch (error) {
      console.error(`   ❌ Erro ao processar ${doc.storedFilename}:`, error)
    }
  }

  return Buffer.from(await mergedPdf.save())
}

/**
 * Salva PDF agrupado e cria registro no banco
 */
async function saveGroupedDocument(
  pdfBuffer: Buffer,
  groupType: string,
  projectId: number,
  organizationId: number,
  userId: number,
  documentIds: number[]
): Promise<void> {
  const uploadDir = process.env.UPLOAD_DIR
  if (!uploadDir) throw new Error('UPLOAD_DIR não configurado')

  // Gerar nome do arquivo
  const timestamp = Date.now()
  const normalizedType = normalizeDocumentType(groupType).replace(/\s+/g, '_')
  const filename = `${normalizedType}_agrupado_${timestamp}.pdf`
  const storagePath = `processed/${filename}`
  const fullPath = path.join(uploadDir, storagePath)

  // Salvar arquivo
  fs.mkdirSync(path.dirname(fullPath), { recursive: true })
  fs.writeFileSync(fullPath, pdfBuffer)

  // Contar páginas
  const pdf = await PDFDocument.load(pdfBuffer)
  const pageCount = pdf.getPageCount()

  // Criar registro no banco
  const publicUrl = `${process.env.NEXT_PUBLIC_UPLOAD_URL}/${storagePath}`

  const groupedDoc = await prisma.document.create({
    data: {
      projectId,
      userId,
      organizationId,
      originalFilename: filename,
      storedFilename: filename,
      smartFilename: filename,
      documentType: groupType,
      detectedDocumentType: groupType,
      documentNumber: 1,
      mimeType: 'application/pdf',
      originalSizeBytes: pdfBuffer.length,
      isPersonalDocument: false,
      isGrouped: false,
      status: 'ocr_completed',
      pdfPath: publicUrl,
      pdfSizeBytes: pdfBuffer.length,
      pageCount
    }
  })

  // Marcar documentos individuais como agrupados
  await prisma.document.updateMany({
    where: {
      id: { in: documentIds },
      organizationId
    },
    data: { isGrouped: true }
  })

  console.log(`   📄 Documento agrupado criado: ${filename}`)
  console.log(`   📊 ${documentIds.length} documentos marcados como agrupados`)
  console.log(`   📑 Total de ${pageCount} páginas`)
}

/**
 * Função principal
 */
async function main() {
  try {
    const projectId = process.argv[2] ? parseInt(process.argv[2]) : null

    if (!projectId) {
      console.error('❌ Uso: npx tsx scripts/group-existing-documents.ts <projectId>')
      process.exit(1)
    }

    console.log(`🔍 Buscando documentos não agrupados no projeto ${projectId}...\n`)

    // Buscar projeto
    const project = await prisma.project.findUnique({
      where: { id: projectId },
      select: { id: true, name: true, userId: true, organizationId: true }
    })

    if (!project) {
      console.error(`❌ Projeto ${projectId} não encontrado`)
      process.exit(1)
    }

    console.log(`📁 Projeto: ${project.name}`)
    console.log(`🏢 Organização: ${project.organizationId}\n`)

    // Buscar documentos não agrupados
    const documents = await prisma.document.findMany({
      where: {
        projectId,
        organizationId: project.organizationId,
        isGrouped: false,
        status: { in: ['validated', 'ocr_completed'] }
      },
      select: {
        id: true,
        storedFilename: true,
        pdfPath: true,
        detectedDocumentType: true,
        documentType: true
      },
      orderBy: { createdAt: 'asc' }
    })

    if (documents.length === 0) {
      console.log('✅ Nenhum documento para agrupar')
      return
    }

    console.log(`📋 ${documents.length} documentos encontrados\n`)

    // Agrupar por tipo similar
    const groups = groupDocumentsByType(documents)

    console.log(`🔗 ${groups.size} grupos identificados:\n`)

    for (const [groupType, groupDocs] of groups.entries()) {
      if (groupDocs.length < 2) {
        console.log(`⏭️ "${groupType}": apenas 1 documento, pulando...`)
        continue
      }

      console.log(`📦 Agrupando "${groupType}" (${groupDocs.length} documentos):`)

      try {
        // Combinar PDFs
        const uploadDir = process.env.UPLOAD_DIR
        if (!uploadDir) throw new Error('UPLOAD_DIR não configurado')

        const mergedPdf = await combinePDFs(groupDocs, uploadDir)

        // Salvar documento agrupado
        await saveGroupedDocument(
          mergedPdf,
          groupType,
          projectId,
          project.organizationId,
          project.userId,
          groupDocs.map(d => d.id)
        )

        console.log(`   ✅ Grupo concluído!\n`)
      } catch (error) {
        console.error(`   ❌ Erro ao agrupar "${groupType}":`, error)
      }
    }

    console.log('✅ Agrupamento concluído!')

  } catch (error) {
    console.error('❌ Erro:', error)
    process.exit(1)
  } finally {
    await prisma.$disconnect()
  }
}

main()
