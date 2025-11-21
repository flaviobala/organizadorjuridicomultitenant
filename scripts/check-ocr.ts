import { PrismaClient } from '@prisma/client'

const prisma = new PrismaClient()

async function main() {
  const docs = await prisma.document.findMany({
    where: { projectId: 11 },
    orderBy: { createdAt: 'desc' },
    take: 3,
    select: {
      id: true,
      originalFilename: true,
      storedFilename: true,
      documentType: true,
      ocrText: true,
      createdAt: true,
      pdfPath: true
    }
  })

  console.log('\n===== ÚLTIMOS 3 DOCUMENTOS =====\n')

  for (const doc of docs) {
    console.log(`ID: ${doc.id}`)
    console.log(`Arquivo: ${doc.originalFilename}`)
    console.log(`PDF salvo: ${doc.storedFilename}`)
    console.log(`Tipo: ${doc.documentType}`)
    console.log(`Data: ${doc.createdAt}`)
    console.log(`OCR Text Length: ${doc.ocrText?.length || 0} caracteres`)

    if (doc.ocrText && doc.ocrText.length > 0) {
      console.log(`\n--- TEXTO OCR EXTRAÍDO ---`)
      console.log(doc.ocrText.substring(0, 500))
      console.log(`\n... (total: ${doc.ocrText.length} caracteres)`)
    } else {
      console.log(`OCR Text: VAZIO ❌`)
    }

    console.log(`\nPDF Path: ${doc.pdfPath}`)
    console.log('\n' + '='.repeat(80) + '\n')
  }

  await prisma.$disconnect()
}

main()
