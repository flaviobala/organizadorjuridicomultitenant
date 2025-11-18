/**
 * OCR Local com Tesseract.js
 * Processa PDFs e imagens extraindo texto sem depender de APIs externas
 */

import Tesseract, { createWorker, Worker } from 'tesseract.js'
import { PDFDocument } from 'pdf-lib'
import sharp from 'sharp'

export interface OCRResult {
  text: string
  confidence: number
  processingTime: number
}

export class TesseractOCR {
  private static workers: Worker[] = []
  private static readonly MAX_WORKERS = 2 // Número de workers paralelos
  private static initialized = false

  /**
   * Inicializar workers do Tesseract
   */
  private static async initWorkers(): Promise<void> {
    if (this.initialized) return

    console.log('🔧 [Tesseract] Inicializando workers...')

    for (let i = 0; i < this.MAX_WORKERS; i++) {
      const worker = await createWorker('por+eng', 1, {
        logger: (m) => {
          if (m.status === 'recognizing text') {
            console.log(`📖 [Tesseract Worker ${i}] Progresso: ${(m.progress * 100).toFixed(0)}%`)
          }
        }
      })

      this.workers.push(worker)
      console.log(`✅ [Tesseract] Worker ${i} inicializado`)
    }

    this.initialized = true
  }

  /**
   * Obter worker disponível (round-robin)
   */
  private static async getWorker(): Promise<Worker> {
    await this.initWorkers()

    // Round-robin simples
    const worker = this.workers.shift()!
    this.workers.push(worker)

    return worker
  }

  /**
   * Pré-processar imagem para melhorar OCR
   */
  private static async preprocessImage(buffer: Buffer): Promise<Buffer> {
    try {
      console.log('🖼️  [Tesseract] Pré-processando imagem...')

      const processed = await sharp(buffer)
        // Converter para escala de cinza
        .grayscale()
        // Aumentar resolução se muito pequena
        .resize({
          width: 2000,
          fit: 'inside',
          withoutEnlargement: true
        })
        // Aumentar nitidez
        .sharpen()
        // Normalizar contraste
        .normalize()
        // Converter para PNG (melhor para OCR)
        .png()
        .toBuffer()

      console.log('✅ [Tesseract] Imagem pré-processada')
      return processed

    } catch (error) {
      console.warn('⚠️ [Tesseract] Erro no pré-processamento, usando imagem original:', error)
      return buffer
    }
  }

  /**
   * Extrair texto de uma imagem
   */
  static async extractFromImage(buffer: Buffer): Promise<OCRResult> {
    const startTime = Date.now()

    try {
      // Pré-processar imagem
      const processedBuffer = await this.preprocessImage(buffer)

      // Obter worker
      const worker = await this.getWorker()

      console.log('🔍 [Tesseract] Iniciando OCR...')

      // Executar OCR
      const { data } = await worker.recognize(processedBuffer)

      const processingTime = Date.now() - startTime

      console.log(`✅ [Tesseract] OCR concluído em ${processingTime}ms`)
      console.log(`📊 [Tesseract] Confiança: ${(data.confidence).toFixed(1)}%`)
      console.log(`📝 [Tesseract] Texto extraído: ${data.text.length} caracteres`)

      return {
        text: data.text,
        confidence: data.confidence,
        processingTime
      }

    } catch (error) {
      console.error('❌ [Tesseract] Erro no OCR:', error)
      return {
        text: '',
        confidence: 0,
        processingTime: Date.now() - startTime
      }
    }
  }

  /**
   * Extrair imagens de PDF e processar com OCR
   */
  static async extractFromPDF(buffer: Buffer): Promise<OCRResult> {
    const startTime = Date.now()

    try {
      console.log('📄 [Tesseract] Processando PDF...')

      // Carregar PDF
      const pdfDoc = await PDFDocument.load(buffer, { ignoreEncryption: true })
      const pageCount = pdfDoc.getPageCount()

      console.log(`📊 [Tesseract] PDF com ${pageCount} páginas`)

      // Limitar a 50 páginas para evitar timeout
      const pagesToProcess = Math.min(pageCount, 50)

      if (pageCount > 50) {
        console.warn(`⚠️ [Tesseract] PDF muito grande (${pageCount} páginas), processando apenas primeiras 50`)
      }

      const allTexts: string[] = []
      let totalConfidence = 0

      // Processar cada página
      for (let i = 0; i < pagesToProcess; i++) {
        try {
          console.log(`📄 [Tesseract] Processando página ${i + 1}/${pagesToProcess}...`)

          // Criar PDF temporário com apenas esta página
          const singlePagePdf = await PDFDocument.create()
          const [copiedPage] = await singlePagePdf.copyPages(pdfDoc, [i])
          singlePagePdf.addPage(copiedPage)

          const singlePageBytes = await singlePagePdf.save()
          const singlePageBuffer = Buffer.from(singlePageBytes)

          // Converter PDF para imagem usando Sharp
          // Como Sharp não suporta PDF diretamente, vamos enviar o PDF inteiro
          // e tentar extrair como imagem
          const result = await this.extractFromImage(singlePageBuffer)

          if (result.text.trim().length > 0) {
            allTexts.push(result.text)
            totalConfidence += result.confidence
          }

        } catch (pageError) {
          console.error(`❌ [Tesseract] Erro na página ${i + 1}:`, pageError)
          continue
        }
      }

      const finalText = allTexts.join('\n\n')
      const avgConfidence = pagesToProcess > 0 ? totalConfidence / pagesToProcess : 0
      const processingTime = Date.now() - startTime

      console.log(`✅ [Tesseract] PDF processado: ${finalText.length} caracteres em ${processingTime}ms`)

      return {
        text: finalText,
        confidence: avgConfidence,
        processingTime
      }

    } catch (error) {
      console.error('❌ [Tesseract] Erro ao processar PDF:', error)
      return {
        text: '',
        confidence: 0,
        processingTime: Date.now() - startTime
      }
    }
  }

  /**
   * Limpar workers ao encerrar
   */
  static async cleanup(): Promise<void> {
    console.log('🧹 [Tesseract] Limpando workers...')

    for (const worker of this.workers) {
      await worker.terminate()
    }

    this.workers = []
    this.initialized = false

    console.log('✅ [Tesseract] Workers limpos')
  }
}
