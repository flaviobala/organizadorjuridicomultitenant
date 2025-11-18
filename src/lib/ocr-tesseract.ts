/**
 * OCR Local com Tesseract.js
 * Processa imagens extraindo texto sem depender de APIs externas
 * Para PDFs, usa pdf-parse para extrair texto nativo
 */

import Tesseract, { createWorker, Worker } from 'tesseract.js'
import pdfParse from 'pdf-parse'
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

    try {
      for (let i = 0; i < this.MAX_WORKERS; i++) {
        const worker = await createWorker({
          logger: (m) => {
            if (m.status === 'recognizing text') {
              console.log(`📖 [Tesseract Worker ${i}] Progresso: ${(m.progress * 100).toFixed(0)}%`)
            }
          }
        })

        await worker.loadLanguage('por+eng')
        await worker.initialize('por+eng')

        this.workers.push(worker)
        console.log(`✅ [Tesseract] Worker ${i} inicializado`)
      }

      this.initialized = true
    } catch (error) {
      console.error('❌ [Tesseract] Erro ao inicializar workers:', error)
      throw error
    }
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

      // Verificar se é uma imagem válida
      const metadata = await sharp(buffer).metadata()

      if (!metadata.format || !['jpeg', 'png', 'webp', 'tiff', 'gif'].includes(metadata.format)) {
        console.warn(`⚠️ [Tesseract] Formato não suportado: ${metadata.format}, usando original`)
        return buffer
      }

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
   * Extrair texto nativo de PDF usando pdf-parse
   * Configurado para lidar melhor com colunas, rodapés e cabeçalhos
   */
  static async extractFromPDF(buffer: Buffer): Promise<OCRResult> {
    const startTime = Date.now()

    try {
      console.log('📄 [PDF-Parse] Processando PDF...')

      // ✅ Configurações otimizadas para PDFs com layout complexo
      const data = await pdfParse(buffer, {
        // Limitar máximo de páginas a processar (evita timeout)
        max: 100,

        // Renderizar opções customizadas
        pagerender: (pageData: any) => {
          return pageData.getTextContent({
            // ✅ Normalizar whitespace (evita espaços estranhos em colunas)
            normalizeWhitespace: true,
            // ✅ Desabilitar combinação de items (melhor para colunas)
            disableCombineTextItems: false
          }).then((textContent: any) => {
            let text = ''
            const items = textContent.items

            // ✅ Ordenar items por posição Y (vertical) e depois X (horizontal)
            // Isso ajuda a manter a ordem correta em layouts com colunas
            const sortedItems = items.sort((a: any, b: any) => {
              // Agrupar items na mesma linha (margem de 5 pixels)
              const yDiff = Math.abs(a.transform[5] - b.transform[5])
              if (yDiff < 5) {
                // Mesma linha: ordenar por X (esquerda para direita)
                return a.transform[4] - b.transform[4]
              }
              // Linhas diferentes: ordenar por Y (topo para baixo - PDF usa Y invertido)
              return b.transform[5] - a.transform[5]
            })

            // Extrair texto dos items ordenados
            for (let item of sortedItems) {
              if (item.str) {
                text += item.str + ' '
              }
            }

            return text
          })
        }
      })

      const processingTime = Date.now() - startTime
      const cleanedText = data.text.trim()
      const hasText = cleanedText.length > 0

      if (hasText) {
        console.log(`✅ [PDF-Parse] Texto extraído: ${cleanedText.length} caracteres de ${data.numpages} páginas`)

        // Validar qualidade do texto extraído
        const wordCount = cleanedText.split(/\s+/).length
        const avgWordLength = cleanedText.length / wordCount

        // Se texto parece ser apenas rodapés/números de página (palavras muito curtas)
        if (avgWordLength < 3 && wordCount < 50) {
          console.warn(`⚠️ [PDF-Parse] Texto suspeito (apenas ${wordCount} palavras curtas) - pode ser apenas rodapé`)
          return {
            text: cleanedText, // Retorna mesmo assim, mas com confiança baixa
            confidence: 40,
            processingTime
          }
        }

        // PDF com texto nativo = alta confiança
        return {
          text: cleanedText,
          confidence: 95,
          processingTime
        }
      } else {
        console.warn(`⚠️ [PDF-Parse] PDF sem texto (provavelmente escaneado) - ${data.numpages} páginas`)
        return {
          text: '',
          confidence: 0,
          processingTime
        }
      }

    } catch (error) {
      console.error('❌ [PDF-Parse] Erro ao processar PDF:', error)
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
