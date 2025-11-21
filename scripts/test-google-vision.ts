import fs from 'fs'
import path from 'path'
import sharp from 'sharp'
import { config } from 'dotenv'
import { TesseractOCR } from '../src/lib/ocr-tesseract'

// Carregar variáveis de ambiente do .env.local
config({ path: path.join(process.cwd(), '.env.local') })

/**
 * Script para testar Google Vision degradando artificialmente uma imagem
 * Força o Tesseract a ter baixa confiança para acionar o fallback
 */
async function main() {
  const argv = process.argv.slice(2)
  if (argv.length === 0) {
    console.error('Usage: tsx scripts/test-google-vision.ts <path-to-pdf>')
    process.exit(1)
  }

  const pdfPath = path.resolve(argv[0])
  if (!fs.existsSync(pdfPath)) {
    console.error('File not found:', pdfPath)
    process.exit(1)
  }

  console.log('🧪 === TESTE GOOGLE VISION FALLBACK ===')
  console.log('📄 PDF:', pdfPath)
  console.log('')

  // 1. Converter primeira página do PDF para imagem com Ghostscript
  console.log('📸 Convertendo primeira página do PDF...')
  const { exec } = require('child_process')
  const util = require('util')
  const execPromise = util.promisify(exec)

  const tempImagePath = path.join(process.cwd(), 'temp-page-1.png')

  try {
    await execPromise(
      `"C:\\Program Files\\gs\\gs10.06.0\\bin\\gswin64c.exe" ` +
      `-dSAFER -dBATCH -dNOPAUSE -dFirstPage=1 -dLastPage=1 ` +
      `-sDEVICE=png16m -r300 -sOutputFile="${tempImagePath}" "${pdfPath}"`
    )
    console.log('✅ Página convertida')
  } catch (err) {
    console.error('❌ Erro ao converter PDF:', err)
    process.exit(1)
  }

  // 2. Carregar imagem
  const originalBuffer = await fs.promises.readFile(tempImagePath)
  console.log('📊 Tamanho original:', originalBuffer.length, 'bytes')

  // 3. Degradar imagem para forçar baixa confiança
  console.log('')
  console.log('🔧 Degradando imagem artificialmente...')
  console.log('   - Reduzindo resolução para 100 DPI')
  console.log('   - Adicionando ruído gaussiano')
  console.log('   - Reduzindo contraste')
  console.log('   - Aplicando blur')

  const metadata = await sharp(originalBuffer).metadata()

  const degradedBuffer = await sharp(originalBuffer)
    // Reduzir drasticamente a resolução (75% menor)
    .resize(Math.floor(metadata.width! / 4), Math.floor(metadata.height! / 4), {
      fit: 'fill',
      kernel: 'nearest'  // Pior qualidade de redimensionamento
    })
    // Converter para escala de cinza
    .grayscale()
    // Reduzir contraste drasticamente
    .linear(0.4, 80)
    // Adicionar blur pesado
    .blur(3)
    // Adicionar ruído via threshold
    .threshold(100, { grayscale: false })
    // Comprimir com péssima qualidade
    .jpeg({ quality: 10 })
    .toBuffer()

  console.log('✅ Imagem degradada:', degradedBuffer.length, 'bytes')

  // 4. Testar OCR com imagem degradada
  console.log('')
  console.log('🔍 === TESTANDO OCR COM IMAGEM DEGRADADA ===')
  console.log('')

  const startTime = Date.now()
  const result = await TesseractOCR.extractFromImage(degradedBuffer)
  const totalTime = Date.now() - startTime

  // 5. Mostrar resultados
  console.log('')
  console.log('📊 === RESULTADO ===')
  console.log('Confiança:', result.confidence + '%')
  console.log('Caracteres extraídos:', result.text.length)
  console.log('Tempo total:', totalTime + 'ms')
  console.log('')

  if (result.confidence < 70) {
    console.log('✅ Google Vision deveria ter sido acionado!')
  } else {
    console.log('⚠️  Tesseract ainda teve boa confiança - Google Vision não foi necessário')
  }

  console.log('')
  console.log('---- Preview do texto (500 chars) ----')
  console.log(result.text.substring(0, 500))

  // 6. Limpar arquivo temporário
  try {
    await fs.promises.unlink(tempImagePath)
    console.log('')
    console.log('🧹 Arquivo temporário removido')
  } catch (err) {
    // Ignorar erro
  }
}

main()
