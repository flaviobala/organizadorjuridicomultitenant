/**
 * Google Cloud Vision OCR
 * Motor de OCR primário de alta qualidade para documentos jurídicos
 * Melhor precisão em: manuscritos, layouts complexos, colunas, documentos escaneados
 */

import vision, { ImageAnnotatorClient } from '@google-cloud/vision'
import type { OCRResult } from './ocr-tesseract'

export class GoogleVisionOCR {
  private static client: ImageAnnotatorClient | null = null

  /**
   * Inicializar cliente do Google Vision
   */
  private static getClient(): ImageAnnotatorClient {
    if (this.client) return this.client

    // Verificar se as credenciais estão configuradas
    const hasCredentials =
      process.env.GOOGLE_APPLICATION_CREDENTIALS ||
      (process.env.GOOGLE_CLOUD_PROJECT_ID &&
       process.env.GOOGLE_CLOUD_PRIVATE_KEY &&
       process.env.GOOGLE_CLOUD_CLIENT_EMAIL)

    if (!hasCredentials) {
      throw new Error('Google Vision credentials not configured')
    }

    // Criar cliente com credenciais do ambiente
    if (process.env.GOOGLE_CLOUD_PRIVATE_KEY) {
      this.client = new vision.ImageAnnotatorClient({
        credentials: {
          client_email: process.env.GOOGLE_CLOUD_CLIENT_EMAIL!,
          private_key: process.env.GOOGLE_CLOUD_PRIVATE_KEY.replace(/\\n/g, '\n'),
        },
        projectId: process.env.GOOGLE_CLOUD_PROJECT_ID!,
      })
    } else {
      // Usar GOOGLE_APPLICATION_CREDENTIALS (arquivo JSON)
      this.client = new vision.ImageAnnotatorClient()
    }

    return this.client
  }

  /**
   * Verificar se Google Vision está disponível
   */
  static isAvailable(): boolean {
    try {
      return !!(
        process.env.GOOGLE_APPLICATION_CREDENTIALS ||
        (process.env.GOOGLE_CLOUD_PROJECT_ID &&
         process.env.GOOGLE_CLOUD_PRIVATE_KEY &&
         process.env.GOOGLE_CLOUD_CLIENT_EMAIL)
      )
    } catch {
      return false
    }
  }

  /**
   * Extrair texto de imagem usando Google Vision
   */
  static async extractFromImage(buffer: Buffer): Promise<OCRResult> {
    const startTime = Date.now()

    try {
      console.log('☁️ [Google Vision] Iniciando OCR...')

      const client = this.getClient()

      // Fazer OCR com detecção de texto completo (melhor que textDetection)
      const [result] = await client.documentTextDetection({
        image: { content: buffer },
      })

      const detections = result.fullTextAnnotation

      if (!detections || !detections.text) {
        console.warn('⚠️ [Google Vision] Nenhum texto detectado')
        return {
          text: '',
          confidence: 0,
          processingTime: Date.now() - startTime
        }
      }

      // Calcular confiança média das páginas
      const pages = detections.pages || []
      let totalConfidence = 0
      let wordCount = 0

      for (const page of pages) {
        for (const block of page.blocks || []) {
          for (const paragraph of block.paragraphs || []) {
            for (const word of paragraph.words || []) {
              if (word.confidence !== undefined && word.confidence !== null) {
                totalConfidence += word.confidence
                wordCount++
              }
            }
          }
        }
      }

      const avgConfidence = wordCount > 0
        ? Math.round(totalConfidence / wordCount * 100)
        : 95 // Se não tiver dados de confiança, assumir 95%

      const text = detections.text.trim()
      const processingTime = Date.now() - startTime

      console.log('✅ [Google Vision] OCR concluído')
      console.log(`   Texto extraído: ${text.length} caracteres`)
      console.log(`   Confiança média: ${avgConfidence}%`)
      console.log(`   Tempo: ${processingTime}ms`)

      return {
        text,
        confidence: avgConfidence,
        processingTime
      }

    } catch (error) {
      console.error('❌ [Google Vision] Erro:', error)

      // Se for erro de credenciais, logar mais detalhes
      if (error instanceof Error && error.message.includes('credentials')) {
        console.error('   💡 Verifique as credenciais do Google Cloud em .env.local')
      }

      return {
        text: '',
        confidence: 0,
        processingTime: Date.now() - startTime
      }
    }
  }

  /**
   * Extrair texto de PDF usando Google Vision
   * Converte PDF para imagens com Ghostscript e processa cada página
   */
  static async extractFromPDF(buffer: Buffer): Promise<OCRResult> {
    const startTime = Date.now()

    try {
      console.log('📄 [Google Vision] Processando PDF...')

      const fs = await import('fs')
      const os = await import('os')
      const path = await import('path')
      const { exec } = await import('child_process')
      const { promisify } = await import('util')
      const execAsync = promisify(exec)

      // Criar diretório temporário
      const tmpDir = await fs.promises.mkdtemp(path.join(os.tmpdir(), 'gv-pdf-'))
      const pdfPath = path.join(tmpDir, 'input.pdf')
      const outputPattern = path.join(tmpDir, 'page-%d.png')

      await fs.promises.writeFile(pdfPath, buffer)

      // Converter PDF para imagens em alta resolução (300 DPI)
      const gsPath = '"C:\\Program Files\\gs\\gs10.06.0\\bin\\gswin64c.exe"'
      const gsCmd = `${gsPath} -dSAFER -dBATCH -dNOPAUSE -sDEVICE=png16m -r300 -sOutputFile="${outputPattern}" "${pdfPath}"`

      console.log('🔄 [Google Vision] Convertendo PDF para imagens (300 DPI)...')
      await execAsync(gsCmd, { timeout: 120000 })

      // Ler todas as imagens geradas
      const files = await fs.promises.readdir(tmpDir)
      const imageFiles = files.filter(f => f.startsWith('page-') && f.endsWith('.png')).sort()

      console.log(`📸 [Google Vision] ${imageFiles.length} páginas convertidas`)

      let allText = ''
      let totalConfidence = 0
      let pagesProcessed = 0

      // Processar cada página com Google Vision
      for (let i = 0; i < imageFiles.length; i++) {
        const imgPath = path.join(tmpDir, imageFiles[i])
        const imgBuffer = await fs.promises.readFile(imgPath)

        console.log(`📄 [Google Vision] Página ${i + 1}/${imageFiles.length}...`)

        try {
          const pageResult = await this.extractFromImage(imgBuffer)

          if (pageResult.text.length > 10) {
            allText += pageResult.text + '\n\n'
            totalConfidence += pageResult.confidence
            pagesProcessed++
            console.log(`   ✅ ${pageResult.text.length} caracteres (${pageResult.confidence}% confiança)`)
          } else {
            console.log(`   ⚠️ Pouco texto na página ${i + 1}`)
          }
        } catch (pageError) {
          console.error(`   ❌ Erro na página ${i + 1}:`, pageError)
        }
      }

      // Limpar arquivos temporários
      await fs.promises.rm(tmpDir, { recursive: true, force: true })

      const avgConfidence = pagesProcessed > 0 ? Math.round(totalConfidence / pagesProcessed) : 0
      const processingTime = Date.now() - startTime

      console.log(`✅ [Google Vision] PDF processado: ${allText.length} caracteres de ${pagesProcessed}/${imageFiles.length} páginas`)
      console.log(`   Confiança média: ${avgConfidence}%`)
      console.log(`   Tempo total: ${processingTime}ms`)

      return {
        text: allText.trim(),
        confidence: avgConfidence,
        processingTime
      }

    } catch (error) {
      console.error('❌ [Google Vision] Erro ao processar PDF:', error)
      return {
        text: '',
        confidence: 0,
        processingTime: Date.now() - startTime
      }
    }
  }
}
