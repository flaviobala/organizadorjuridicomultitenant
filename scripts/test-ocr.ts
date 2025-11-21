import fs from 'fs'
import path from 'path'
import { config } from 'dotenv'
import { TesseractOCR } from '../src/lib/ocr-tesseract'

// Carregar variáveis de ambiente do .env.local
config({ path: path.join(process.cwd(), '.env.local') })

async function main() {
  const argv = process.argv.slice(2)
  if (argv.length === 0) {
    console.error('Usage: tsx scripts/test-ocr.ts <path-to-file>')
    process.exit(1)
  }

  const filePath = path.resolve(argv[0])
  if (!fs.existsSync(filePath)) {
    console.error('File not found:', filePath)
    process.exit(1)
  }

  const buffer = await fs.promises.readFile(filePath)
  const isPDF = filePath.toLowerCase().endsWith('.pdf')

  console.log('== Test OCR ==')
  console.log('File:', filePath)
  console.log('Type:', isPDF ? 'PDF' : 'Image')

  try {
    if (isPDF) {
      const res = await TesseractOCR.extractFromPDF(buffer)
      console.log('== OCR Result ==')
      console.log('Text length:', res.text.length)
      console.log('Confidence:', res.confidence)
      console.log('Time ms:', res.processingTime)
      console.log('\n---- Text Preview ----\n')
      console.log(res.text.substring(0, 2000))
    } else {
      const res = await TesseractOCR.extractFromImage(buffer)
      console.log('== OCR Result ==')
      console.log('Text length:', res.text.length)
      console.log('Confidence:', res.confidence)
      console.log('Time ms:', res.processingTime)
      console.log('\n---- Text Preview ----\n')
      console.log(res.text.substring(0, 2000))
    }
  } catch (err) {
    console.error('Error during OCR test:', err)
    process.exit(2)
  }
}

main()
