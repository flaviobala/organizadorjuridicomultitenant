import { PDFDocument, PageSizes, rgb } from 'pdf-lib'
import sharp, { type Metadata } from 'sharp'
import { uploadFile, downloadFile } from './storage-service'
import { prisma } from './prisma'
import OpenAI from 'openai'
import type { DocumentAnalysis } from '@/types'
import { trackTokens, estimateTokens } from './token-tracker'
import { TesseractOCR } from './ocr-tesseract'
import { DOCXProcessor } from './docx-processor'

const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY!,
})

export interface ElysiumOCR {
  text: string
  fileBase64: string
  words?: Array<{ text: string; x: number; y: number; width: number; height: number; confidence: number }>
  confidence?: number // ✅ Confiança do OCR (0-100)
  processingTime?: number // ✅ Tempo de processamento em ms
  pagesProcessed?: number // ✅ Número de páginas processadas
}
export interface ConversionResult {
  success: boolean
  pdfPath?: string
  pdfBuffer?: Buffer
  ocrText?: string
  ocrConfidence?: number // ✅ Confiança do OCR (0-100)
  ocrCharactersExtracted?: number // ✅ Número de caracteres extraídos
  ocrPagesProcessed?: number // ✅ Páginas processadas com OCR
  ocrQualityLevel?: 'excellent' | 'good' | 'poor' | 'failed' // ✅ Nível de qualidade
  pageCount?: number
  finalSizeBytes?: number
  smartFilename?: string
  documentAnalysis?: DocumentAnalysis
  categoryInfo?: CategoryInfo
  groupedDocuments?: number
  dividedParts?: number
  isPersonalDocument?: boolean
  shouldWaitForGrouping?: boolean
  savedDocumentId?: number
  error?: string
}

export interface CategoryInfo {
  id: number
  name: string
  code: string
  description: string
  shouldGroup?: boolean
  canDivide?: boolean
  isPersonalDocument?: boolean
}

export interface DocumentToProcess {
  buffer: Buffer
  mimeType: string
  filename: string
  ocrText?: string
  ocrWords?: Array<{ text: string; x: number; y: number; width: number; height: number; confidence: number }>
  ocrQualityMetrics?: { // ✅ Métricas de qualidade do OCR
    confidence: number
    charactersExtracted: number
    pagesProcessed: number
    processingTime: number
  }
  analysis?: DocumentAnalysis
}

export interface PendingPersonalDocument {
  id: number
  filename: string
  pdfPath: string
  pdfBuffer: Buffer
  documentType: string
  projectId: number
  createdAt: Date
}

export interface ExtractedInfo {
  ocrExtractedText: string
  cpf?: string
  rg?: string
  cnh?: string
  [key: string]: unknown
}

export class PDFConverter {
  private systemRequirements = {
    maxSizeMB: 30,
    maxPageSizeKB: 500,
    resolution: 150,
    colorMode: 'RGB' as const,
    compression: true
  }

  constructor(private systemName: string) {}

  /**
   * Limpar texto para compatibilidade com WinAnsi encoding
   * Remove caracteres que StandardFonts não suportam
   */
  private static cleanTextForWinAnsi(text: string): string {
    if (!text) return ''

    return text
      .replace(/\t/g, '    ') // Substituir tabs por 4 espaços
      .replace(/[\u0000-\u001F\u007F-\u009F]/g, '') // Remover caracteres de controle
      .replace(/[^\x20-\x7E\u00A0-\u00FF\n]/g, '') // Manter apenas caracteres WinAnsi + quebras de linha
  }

  async init(organizationId?: number): Promise<void> {
    console.log('🔧 Inicializando PDFConverter para:', this.systemName)

    // Carregar configurações do sistema se disponível e organizationId fornecido
    if (organizationId) {
      try {
        const config = await prisma.systemConfiguration.findFirst({
          where: {
            organizationId: organizationId,
            systemName: this.systemName
          }
        })

        if (config?.pdfRequirements) {
          this.systemRequirements = JSON.parse(config.pdfRequirements)
          console.log('✅ Configurações carregadas:', this.systemRequirements)
        }
      } catch (error) {
        console.warn('⚠️ Usando configurações padrão:', error)
      }
    } else {
      console.log('ℹ️ Usando configurações padrão (organizationId não fornecido)')
    }
  }

  /**
   * Método principal: converte qualquer arquivo para PDF com análise IA
   */
  async convertToPDF(
    inputBuffer: Buffer,
    mimeType: string,
    originalFilename: string,
    documentNumber: number = 1,
    projectId?: number,
    userId?: number,
    documentId?: number,
    organizationId?: number
  ): Promise<ConversionResult> {
    try {
      console.log('📄 Iniciando conversão inteligente:', {
        filename: originalFilename,
        type: mimeType,
        size: this.formatFileSize(inputBuffer.length),
        projectId
      })

      // 1. Extrair texto via OCR
      console.log('🔍 ===== INICIANDO EXTRAÇÃO DE TEXTO =====')
      console.log('   Arquivo:', originalFilename)
      console.log('   Tipo MIME:', mimeType)
      console.log('   Tamanho:', this.formatFileSize(inputBuffer.length))

      let ocrText = '';
      const resultOCR = await this.extractText(inputBuffer, mimeType)
      ocrText = resultOCR.text ?? ''

      // ✅ Capturar métricas de qualidade do OCR
      const ocrQualityMetrics = {
        confidence: resultOCR.confidence || 0,
        charactersExtracted: ocrText.length,
        pagesProcessed: resultOCR.pagesProcessed || 1,
        processingTime: resultOCR.processingTime || 0
      }

      console.log('🔍 ===== RESULTADO DA EXTRAÇÃO =====')
      console.log('   Texto extraído?', ocrText.length > 0 ? 'SIM' : 'NÃO')
      console.log('   Comprimento:', ocrText.length, 'caracteres')
      console.log('   Confiança OCR:', ocrQualityMetrics.confidence + '%')
      console.log('   Preview:', ocrText.substring(0, 150))

      // ✅ CORREÇÃO: Processar PDF retornado pelo OCR apenas se válido
      if (resultOCR.fileBase64 && resultOCR.fileBase64.length > 100) {
        try {
          console.log('📄 OCR retornou PDF processado, validando...')
          const ocrPdfBuffer = Buffer.from(resultOCR.fileBase64, 'base64')

          // Validar se é um PDF válido verificando o header
          const pdfHeader = ocrPdfBuffer.subarray(0, 5).toString()
          if (pdfHeader === '%PDF-') {
            // Tentar carregar o PDF para garantir que está válido
            await PDFDocument.load(ocrPdfBuffer, { ignoreEncryption: true })

            inputBuffer = ocrPdfBuffer
            mimeType = 'application/pdf'
            console.log('✅ PDF do OCR validado e será utilizado')
          } else {
            console.warn('⚠️ OCR retornou base64 inválido (header: ' + pdfHeader + '), usando arquivo original')
          }
        } catch (ocrError) {
          console.error('❌ Erro ao processar PDF do OCR:', ocrError)
          console.log('📄 Usando arquivo original')
        }
      }

      console.log('🔍 OCR extraído:', {
        comprimento: ocrText ? ocrText.length : 0,
        preview: ocrText ? ocrText.substring(0, 200) + '...' : 'VAZIO',
        tipo: mimeType
      })

      // 2. Análise IA do documento
      const chatGPTAnalysis = await this.analyzeWithChatGPT(ocrText, originalFilename, mimeType, userId, documentId, projectId, organizationId)
      const categoryInfo = this.parseChatGPTResponse(chatGPTAnalysis)
      
      console.log('🧠 IA categorizou como:', categoryInfo.name, categoryInfo.isPersonalDocument ? '(Pessoal)' : '')

      // 3. Preparar documento para processamento
      const docToProcess: DocumentToProcess = {
        buffer: inputBuffer,
        mimeType,
        filename: originalFilename,
        ocrText,
        ocrWords: resultOCR.words,
        ocrQualityMetrics, // ✅ Adicionar métricas de qualidade
        analysis: {
          documentType: categoryInfo.code,
          confidence: 0.9,
          detectedInfo: this.extractInfoFromOCR(ocrText),
          suggestedFilename: categoryInfo.name,
          ocrUsed: !!ocrText,
          chatGPTAnalysis
        }
      }

      // 4. Processamento com lógica inteligente
      let result: ConversionResult

      if (categoryInfo.isPersonalDocument && projectId) {
        // Documentos pessoais - agrupar automaticamente (RG, CPF, CNH)
        console.log('📄 Processando documento pessoal:', categoryInfo.name)
        result = await this.handlePersonalDocument(docToProcess, categoryInfo, documentNumber, projectId)
      } else if (projectId) {
        // ✅ NOVO: Verificar se deve agrupar com documentos similares do projeto
        // Buscar documentos do mesmo tipo (normalizado) no projeto
        const shouldGroup = await this.shouldGroupDocument(categoryInfo, projectId, organizationId)

        if (shouldGroup) {
          console.log('🔗 Detectado documento agrupável:', categoryInfo.name)
          result = await this.handleGroupableDocument(docToProcess, categoryInfo, documentNumber, projectId, organizationId!)
        } else if (categoryInfo.canDivide && this.needsDivision(inputBuffer)) {
          // Documentos grandes - dividir se necessário
          console.log('✂️ Documento grande detectado, dividindo:', categoryInfo.name)
          result = await this.handleDivisibleDocument(docToProcess, categoryInfo, documentNumber)
        } else {
          console.log('📄 Processando documento único:', categoryInfo.name)
          result = await this.processSingleDocument(docToProcess, categoryInfo, documentNumber)
        }
      } else if (categoryInfo.canDivide && this.needsDivision(inputBuffer)) {
        // Documentos grandes - dividir se necessário
        console.log('✂️ Documento grande detectado, dividindo:', categoryInfo.name)
        result = await this.handleDivisibleDocument(docToProcess, categoryInfo, documentNumber)
      } else {
        console.log('📄 Processando documento único:', categoryInfo.name)
        // Documentos normais - processar individualmente
        result = await this.processSingleDocument(docToProcess, categoryInfo, documentNumber)
      }

      console.log('✅ Conversão concluída:', result.success ? 'Sucesso' : 'Erro')
      return result

    } catch (error) {
      console.error('❌ Erro na conversão:', error)
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Erro desconhecido'
      }
    }
  }

  // ==================== EXTRAÇÃO DE TEXTO ====================

  private async extractText(buffer: Buffer, mimeType?: string): Promise<ElysiumOCR> {

    try {
      // ✅ DESABILITADO: Rotação automática removida - usuário fará manualmente via UI
      const processedBuffer = buffer
      // if (mimeType && mimeType.startsWith('image/')) {
      //   console.log('🖼️ Imagem detectada - aplicando correção de orientação...')
      //   processedBuffer = await this.correctImageOrientation(buffer)
      // }

      // ✅ NOVO: Detectar PDFs grandes e processar em lotes
      if (mimeType === 'application/pdf') {
        const shouldUseBatchProcessing = await this.shouldProcessInBatches(processedBuffer)

        // ✅ Pular OCR para PDFs muito grandes (> 50 páginas)
        if (shouldUseBatchProcessing.skipOCR) {
          console.warn('⚠️ OCR pulado - PDF muito grande')
          return { text: '', fileBase64: '' }
        }

        if (shouldUseBatchProcessing.useBatch) {
          console.log('📦 PDF grande detectado, usando processamento em lotes...')
          return await this.extractTextInBatches(processedBuffer, shouldUseBatchProcessing.pageCount)
        }
      }

      // ✅ PRIORIDADE 1: Arquivos de texto (.txt, .csv, etc.)
      if (mimeType && mimeType.startsWith('text/')) {
        try {
          console.log('📝 [TEXT] Detectado arquivo de texto, lendo diretamente...')
          const textContent = processedBuffer.toString('utf-8')

          if (textContent.length > 0) {
            console.log(`✅ [TEXT] Texto lido: ${textContent.length} caracteres`)
            return { text: textContent, fileBase64: '' }
          }
        } catch (textError) {
          console.warn('⚠️ [TEXT] Erro ao ler arquivo de texto:', textError)
        }
      }

      // ✅ PRIORIDADE 2: Processar arquivos DOCX/DOC
      if (mimeType && (mimeType.includes('word') || mimeType.includes('document'))) {
        try {
          console.log('📄 [DOCX] Detectado arquivo Word, processando...')

          // Extrair texto
          const docxResult = await DOCXProcessor.extractText(processedBuffer)

          if (docxResult.text.length > 0) {
            console.log(`✅ [DOCX] Texto extraído: ${docxResult.text.length} caracteres, ${docxResult.wordCount} palavras`)

            // Converter DOCX para PDF
            console.log('📄 [DOCX] Convertendo para PDF...')
            const pdfBuffer = await DOCXProcessor.convertToPDF(processedBuffer)
            const pdfBase64 = pdfBuffer.toString('base64')

            console.log(`✅ [DOCX] PDF gerado: ${this.formatFileSize(pdfBuffer.length)}`)

            return {
              text: docxResult.text,
              fileBase64: pdfBase64
            }
          }
        } catch (docxError) {
          console.warn('⚠️ [DOCX] Erro ao processar Word, tentando OCR:', docxError)
        }
      }

      // ✅ PRIORIDADE 3: OCR Local com Tesseract
      try {
        console.log('🔍 ===== TESSERACT OCR =====')
        console.log('   Tipo detectado:', mimeType === 'application/pdf' ? 'PDF' : 'IMAGEM')
        console.log('   Tamanho do buffer:', processedBuffer.length, 'bytes')

        const tesseractResult = mimeType === 'application/pdf'
          ? await TesseractOCR.extractFromPDF(processedBuffer)
          : await TesseractOCR.extractFromImage(processedBuffer)

        console.log('🔍 ===== RESULTADO TESSERACT =====')
        console.log('   Texto extraído:', tesseractResult.text.length, 'caracteres')
        console.log('   Confiança:', tesseractResult.confidence.toFixed(1) + '%')
        console.log('   Tempo:', tesseractResult.processingTime + 'ms')
        console.log('   Preview:', tesseractResult.text.substring(0, 200))

        // Aceitar resultado se tiver texto razoável e confiança > 30%
        if (tesseractResult.text.length > 10 && tesseractResult.confidence > 30) {
          console.log(`✅ [Tesseract] OCR ACEITO - Retornando texto extraído`)

          // ✅ Contar páginas apenas se for PDF
          let pagesProcessed = 1
          if (mimeType === 'application/pdf') {
            pagesProcessed = await this.shouldProcessInBatches(processedBuffer).then(r => r.pageCount).catch(() => 1)
          }

          return {
            text: tesseractResult.text,
            fileBase64: '',
            words: tesseractResult.words,
            confidence: tesseractResult.confidence,
            processingTime: tesseractResult.processingTime,
            pagesProcessed
          }
        } else {
          console.warn(`⚠️ [Tesseract] OCR REJEITADO - Insuficiente (${tesseractResult.text.length} chars, ${tesseractResult.confidence.toFixed(1)}% confiança)`)
          console.warn(`   💡 Sistema usará análise por nome de arquivo + ChatGPT`)
          return { text: '', fileBase64: '', confidence: 0 }
        }
      } catch (tesseractError) {
        console.error('❌ ===== ERRO CRÍTICO NO TESSERACT =====')
        console.error('   Erro:', tesseractError)
        console.error('   Stack:', tesseractError instanceof Error ? tesseractError.stack : 'N/A')
        console.warn('   💡 Sistema usará análise por nome de arquivo + ChatGPT')
        return { text: '', fileBase64: '' }
      }

    } catch (error) {
      console.error('❌ Erro crítico na API OCR:', error)
      if (error instanceof Error) {
        console.error('❌ Detalhes do erro:', error.message, error.stack)
      }
      return {text: '', fileBase64: ''}
    }
  }

  /**
   * ✅ MELHORADO: Verifica se PDF deve ser processado em lotes
   * Critérios:
   * 1. Tamanho em MB: > 5MB sempre usa lotes (mesmo com poucas páginas)
   * 2. Número de páginas: > 5 páginas usa lotes
   * 3. PDFs muito grandes: limita processamento
   */
  private async shouldProcessInBatches(buffer: Buffer): Promise<{ useBatch: boolean, pageCount: number, skipOCR?: boolean }> {
    try {
      const fileSizeMB = buffer.length / (1024 * 1024)
      console.log(`📊 Analisando PDF: ${fileSizeMB.toFixed(2)}MB`)

      // ✅ PRIORIDADE: Sempre verificar número real de páginas primeiro
      try {
        const pdfDoc = await PDFDocument.load(buffer, { ignoreEncryption: true })
        const pageCount = pdfDoc.getPageCount()

        console.log(`📄 Número de páginas: ${pageCount}`)

        // ✅ SEMPRE processar TODAS as páginas (documentos jurídicos são importantes!)
        // Processar em lotes se: > 5 páginas OU > 5MB
        if (pageCount > 5 || fileSizeMB > 5) {
          console.log(`📦 PDF grande: ${pageCount} páginas, ${fileSizeMB.toFixed(2)}MB - processando TODAS as páginas em lotes`)
          return { useBatch: true, pageCount }
        }

        console.log(`✅ PDF pequeno: ${pageCount} páginas, ${fileSizeMB.toFixed(2)}MB - processamento direto`)
        return { useBatch: false, pageCount }

      } catch (pdfError) {
        console.warn('⚠️ Erro ao verificar páginas do PDF:', pdfError)
        // Fallback: usar tamanho do arquivo
        if (fileSizeMB > 2) {
          console.log('📦 Arquivo > 2MB sem páginas detectadas - usando lotes por segurança')
          return { useBatch: true, pageCount: 10 }
        }
      }

      return { useBatch: false, pageCount: 0 }
    } catch (error) {
      console.error('❌ Erro ao verificar PDF:', error)
      return { useBatch: false, pageCount: 0 }
    }
  }

  /**
   * ✅ OTIMIZADO: Processa PDFs grandes em lotes menores
   * Divide em lotes de 3 páginas e processa com Elysium
   * Timeout: 25s por lote + delay de 2s entre lotes
   */
  private async extractTextInBatches(buffer: Buffer, totalPages: number): Promise<ElysiumOCR> {
    const extractedTexts: string[] = []

    try {
      console.log(`📦 ===== PROCESSAMENTO COM OCR (Ghostscript + Tesseract) =====`)
      console.log(`📦 Total de páginas: ${totalPages}`)
      console.log(`📦 Tempo estimado: ~${(totalPages * 7 / 60).toFixed(1)} minutos`)
      console.log(`📦 ================================================================`)

      // Converter PDF para imagens com Ghostscript
      const pageImages = await this.convertAllPDFPagesToImages(buffer, totalPages)

      if (!pageImages || pageImages.length === 0) {
        console.error('❌ Não foi possível converter PDF para imagens')
        return { text: '', fileBase64: '' }
      }

      console.log(`📸 ${pageImages.length} páginas convertidas para imagem`)

      // Processar cada página com OCR
      for (let i = 0; i < pageImages.length; i++) {
        console.log(`📄 [Página ${i + 1}/${pageImages.length}] Executando OCR...`)

        try {
          const ocrResult = await TesseractOCR.extractFromImage(pageImages[i])

          if (ocrResult.text.length > 10) {
            extractedTexts.push(ocrResult.text.replace(/\s+/g, ' ').trim())
            console.log(`   ✅ Página ${i + 1}: ${ocrResult.text.length} caracteres (${ocrResult.confidence}% confiança)`)
          } else {
            console.log(`   ⚠️ Página ${i + 1}: Pouco texto extraído (${ocrResult.text.length} chars)`)
          }

        } catch (ocrError) {
          console.error(`   ❌ Erro no OCR da página ${i + 1}:`, ocrError)
        }
      }

      const fullText = extractedTexts.join(' ')
      console.log(`✅ Extração concluída: ${fullText.length} caracteres de ${extractedTexts.length}/${totalPages} páginas`)

      return { text: fullText, fileBase64: '' }

    } catch (error) {
      console.error('❌ Erro no processamento:', error)
      return { text: '', fileBase64: '' }
    }
  }

  private async convertAllPDFPagesToImages(buffer: Buffer, totalPages: number): Promise<Buffer[]> {
    try {
      const { exec } = require('child_process')
      const { promisify } = require('util')
      const execAsync = promisify(exec)
      const fs = require('fs')
      const path = require('path')
      const os = require('os')

      const tmpDir = await fs.promises.mkdtemp(path.join(os.tmpdir(), 'pdf-all-pages-'))
      const pdfPath = path.join(tmpDir, 'input.pdf')
      const outputPattern = path.join(tmpDir, 'page-%d.png')

      await fs.promises.writeFile(pdfPath, buffer)

      // Converter TODAS as páginas de uma vez com Ghostscript
      const gsPath = process.platform === 'win32'
        ? '"C:\\Program Files\\gs\\gs10.06.0\\bin\\gswin64c.exe"'
        : 'gs'
      const gsCmd = `${gsPath} -dSAFER -dBATCH -dNOPAUSE -sDEVICE=png16m -r300 -sOutputFile="${outputPattern}" "${pdfPath}"`

      console.log('🔄 Convertendo PDF completo para imagens (300 DPI)...')
      await execAsync(gsCmd, { timeout: 120000 }) // 2 minutos timeout

      // Ler todas as imagens geradas
      const pageBuffers: Buffer[] = []
      for (let i = 1; i <= totalPages; i++) {
        const imgPath = path.join(tmpDir, `page-${i}.png`)
        if (await fs.promises.access(imgPath).then(() => true).catch(() => false)) {
          const imgBuffer = await fs.promises.readFile(imgPath)
          pageBuffers.push(imgBuffer)
        } else {
          console.warn(`   ⚠️ Imagem da página ${i} não encontrada`)
        }
      }

      await fs.promises.rm(tmpDir, { recursive: true, force: true })

      return pageBuffers

    } catch (error) {
      console.error('❌ Erro ao converter PDF para imagens:', error)
      return []
    }
  }

  private async repairPDFWithGhostscript(buffer: Buffer): Promise<Buffer | null> {
    try {
      const { exec } = require('child_process')
      const { promisify } = require('util')
      const execAsync = promisify(exec)
      const fs = require('fs')
      const path = require('path')
      const os = require('os')

      const tmpDir = await fs.promises.mkdtemp(path.join(os.tmpdir(), 'pdf-repair-'))
      const inputPath = path.join(tmpDir, 'input.pdf')
      const outputPath = path.join(tmpDir, 'output.pdf')

      await fs.promises.writeFile(inputPath, buffer)

      // Tentar reparar com Ghostscript
      const gsPath = process.platform === 'win32'
        ? '"C:\\Program Files\\gs\\gs10.06.0\\bin\\gswin64c.exe"'
        : 'gs'
      await execAsync(`${gsPath} -dSAFER -dBATCH -dNOPAUSE -dNOCACHE -sDEVICE=pdfwrite -sOutputFile="${outputPath}" "${inputPath}"`, {
        timeout: 30000
      })

      if (await fs.promises.access(outputPath).then(() => true).catch(() => false)) {
        const repairedBuffer = await fs.promises.readFile(outputPath)
        await fs.promises.rm(tmpDir, { recursive: true, force: true })
        return repairedBuffer
      }

      await fs.promises.rm(tmpDir, { recursive: true, force: true })
      return null

    } catch (error) {
      return null
    }
  }

  private async extractTextFromSinglePage(pdfBuffer: Buffer, pageIndex: number): Promise<string> {
    try {
      // Converter página para imagem usando Ghostscript
      const pageImage = await this.convertPDFPageToImageGS(pdfBuffer, pageIndex)

      if (!pageImage) {
        console.warn(`   ⚠️ Não conseguiu converter página ${pageIndex + 1} para imagem`)
        return ''
      }

      // Fazer OCR na imagem
      console.log(`   🔍 Executando OCR na página ${pageIndex + 1}...`)
      const ocrResult = await TesseractOCR.extractFromImage(pageImage)

      if (ocrResult.text.length > 5) {
        return ocrResult.text
      }

      return ''

    } catch (error) {
      console.warn(`   ⚠️ Erro ao processar página ${pageIndex + 1}:`, error)
      return ''
    }
  }

  private async convertPDFPageToImageGS(pdfBuffer: Buffer, pageIndex: number): Promise<Buffer | null> {
    try {
      const { exec } = require('child_process')
      const { promisify } = require('util')
      const execAsync = promisify(exec)
      const fs = require('fs')
      const path = require('path')
      const os = require('os')

      const tmpDir = await fs.promises.mkdtemp(path.join(os.tmpdir(), 'pdf-to-img-'))
      const pdfPath = path.join(tmpDir, 'input.pdf')
      const imgPath = path.join(tmpDir, 'page.png')

      await fs.promises.writeFile(pdfPath, pdfBuffer)

      // Converter página específica com Ghostscript (1-indexed)
      const pageNum = pageIndex + 1
      const gsPath = process.platform === 'win32'
        ? '"C:\\Program Files\\gs\\gs10.06.0\\bin\\gswin64c.exe"'
        : 'gs'
      const gsCmd = `${gsPath} -dSAFER -dBATCH -dNOPAUSE -dFirstPage=${pageNum} -dLastPage=${pageNum} -sDEVICE=png16m -r300 -sOutputFile="${imgPath}" "${pdfPath}"`

      await execAsync(gsCmd, { timeout: 15000 })

      if (await fs.promises.access(imgPath).then(() => true).catch(() => false)) {
        const imageBuffer = await fs.promises.readFile(imgPath)
        await fs.promises.rm(tmpDir, { recursive: true, force: true })
        return imageBuffer
      }

      await fs.promises.rm(tmpDir, { recursive: true, force: true })
      return null

    } catch (error) {
      console.warn(`   ⚠️ Ghostscript falhou: ${error}`)
      return null
    }
  }


  // ==================== ANÁLISE IA ====================

  private async analyzeWithChatGPT(
    ocrText: string,
    filename: string,
    mimeType: string,
    userId?: number,
    documentId?: number,
    projectId?: number,
    organizationId?: number
  ): Promise<string> {
    try {
      console.log('🧠 Iniciando análise ChatGPT:', {
        filename,
        mimeType,
        ocrTextLength: ocrText ? ocrText.length : 0,
        ocrPreview: ocrText ? ocrText.substring(0, 100) + '...' : 'VAZIO'
      })

      if (!ocrText || ocrText.trim().length < 10) {
        console.warn('⚠️ OCR texto muito curto ou vazio, analisando nome do arquivo:', {
          filename,
          ocrLength: ocrText?.length || 0,
          mimeType
        })

        // Tentar categorizar pelo nome do arquivo com mais precisão
        const filenameLower = filename.toLowerCase().normalize('NFD').replace(/[\u0300-\u036f]/g, '')

        // Palavras-chave específicas para cada categoria
        if (filenameLower.includes('declaracao') && (filenameLower.includes('hipossuficiencia') || filenameLower.includes('baixa'))) {
          return '7. Declaração de Hipossuficiência'
        }
        if (filenameLower.includes('comprovante') && (filenameLower.includes('residencia') || filenameLower.includes('endereco'))) {
          return '5. Comprovante de Residência'
        }
        if (filenameLower.includes('procuracao') || filenameLower.includes('outorga') || filenameLower.includes('mandato')) {
          return '6. Procuração'
        }
        // ✅ MELHORADO: Detectar contratos e documentos relacionados a serviços
        if (filenameLower.includes('contrato') ||
            (filenameLower.includes('servico') || filenameLower.includes('ervico')) || // Inclui "ERVIÇOS" cortado
            filenameLower.includes('honorario') ||
            filenameLower.includes('prestacao')) {
          return '8. Contratos'
        }
        if (filenameLower.includes('narrativa') || filenameLower.includes('fato') || filenameLower.includes('relato')) {
          return '1. Narrativa Fática'
        }
        if (filenameLower.includes('rg') || filenameLower.includes('identidade')) {
          return '2. RG'
        }
        if (filenameLower.includes('cnh') || filenameLower.includes('habilitacao')) {
          return '3. CNH'
        }
        if (filenameLower.includes('cpf')) {
          return '4. CPF'
        }
        // ✅ NOVO: Detectar comprovantes em geral
        if (filenameLower.includes('comprovante')) {
          return '5. Comprovante de Residência'
        }

        console.warn('⚠️ Não foi possível categorizar pelo filename, usando fallback')
        return '9. Outros Documentos'
      }

      const prompt = `Analise este documento e categorize-o conforme as opções abaixo.

TEXTO EXTRAÍDO DO DOCUMENTO:
"""
${ocrText || 'Não foi possível extrair texto'}
"""

NOME DO ARQUIVO: ${filename}
TIPO: ${mimeType}

CATEGORIAS DISPONÍVEIS (responda APENAS o número + nome EXATO):
1. Narrativa Fática - Relatos, narrativas, descrição de fatos
2. RG - Registro Geral, Carteira de Identidade, documento de identidade
3. CNH - Carteira Nacional de Habilitação, carteira de motorista
4. CPF - Cadastro de Pessoa Física, documento CPF
5. Comprovante de Residencia - Contas de luz, água, telefone, comprovante de endereço
6. Procuracao - Procurações, outorgas, mandatos
7. Declaracao de Hipossuficiencia - Declarações de baixa renda, hipossuficiência
8. Contratos - Contratos de trabalho, prestação de serviços, honorários, qualquer tipo de contrato
9. Outros Documentos - Documentos que não se encaixam nas categorias acima

INSTRUÇÕES CRÍTICAS:
- Para RG: Procure por "REGISTRO GERAL", "CARTEIRA DE IDENTIDADE", "FILIAÇÃO", nome dos pais
- Para CNH: Procure por "CNH", "HABILITAÇÃO", "CATEGORIA", "VALIDADE", códigos como "A", "B"
- Para CPF: Procure por "CPF", "CADASTRO DE PESSOA FÍSICA", formato XXX.XXX.XXX-XX
- Para CONTRATOS: Procure por "CONTRATO", "PRESTAÇÃO DE SERVIÇOS", "HONORÁRIOS", "CLÁUSULAS"
- Para DECLARAÇÃO DE HIPOSSUFICIÊNCIA: Procure por "HIPOSSUFICIÊNCIA", "BAIXA RENDA", "RECURSOS FINANCEIROS", "DECLARAÇÃO", "INSUFICIÊNCIA", "CARENTE"
- Para COMPROVANTE DE RESIDÊNCIA: Procure por "CONTA", "FATURA", "ENDEREÇO", "RESIDÊNCIA", "LUZ", "ÁGUA", "TELEFONE"
- Para PROCURAÇÃO: Procure por "PROCURAÇÃO", "OUTORGA", "PODERES", "MANDATO", "REPRESENTAÇÃO"
- ANALISE O CONTEÚDO DO TEXTO, não apenas o nome do arquivo
- Base sua decisão NO CONTEÚDO DO TEXTO EXTRAÍDO

IMPORTANTE PARA CATEGORIA 9 (OUTROS DOCUMENTOS):
Se o documento for categoria 9, identifique o tipo específico. Exemplos:
- ASO (Atestado de Saúde Ocupacional)
- Laudo Médico
- Atestado Médico
- Certidão de Nascimento
- Certidão de Casamento
- Certidão de Óbito
- Petição
- Ofício
- Notificação
- Recibo
- Declaração (outros tipos)
- Etc.

FORMATO DA RESPOSTA:
Se for categoria 1-8: responda apenas "número. nome" (ex: "3. CNH")
Se for categoria 9: responda "9. [Tipo Específico]" (ex: "9. ASO", "9. Laudo Médico", "9. Certidão de Nascimento")

RESPOSTA:`

      console.log('🤖 Enviando para OpenAI GPT-4o-mini...')

      // Estimar tokens de entrada
      const inputTokens = estimateTokens(prompt)

      const response = await openai.chat.completions.create({
        model: "gpt-4o-mini", // ✅ TROCADO: 85% mais barato que gpt-4-turbo
        messages: [
          {
            role: "system",
            content: "Você é um especialista em identificação de documentos brasileiros. Analise cuidadosamente o conteúdo do texto extraído. Responda APENAS com número e nome exato da categoria."
          },
          {
            role: "user",
            content: prompt
          }
        ],
        max_tokens: 150,
        temperature: 0.1
      })

      const chatGPTResponse = response.choices[0]?.message?.content || ''
      console.log('🧠 Resposta ChatGPT:', chatGPTResponse)

      // ✅ Registrar uso de tokens
      const outputTokens = estimateTokens(chatGPTResponse)
      if (userId && organizationId) {
        await trackTokens({
          service: 'openai',
          operation: 'categorization',
          model: 'gpt-4o-mini',
          tokensInput: inputTokens,
          tokensOutput: outputTokens,
          method: 'ai',
          success: true,
          userId,
          organizationId,
          documentId,
          projectId,
        })
      }

      return chatGPTResponse

    } catch (error) {
      console.error('❌ ===== ERRO DETALHADO NO CHATGPT =====')
      console.error('Tipo do erro:', typeof error)
      console.error('Erro completo:', error)

      if (error instanceof Error) {
        console.error('Mensagem:', error.message)
        console.error('Stack:', error.stack)
      }

      // Se for erro da OpenAI, mostrar mais detalhes
      if (error && typeof error === 'object' && 'status' in error) {
        const openAIError = error as { status?: number; code?: string; type?: string }
        console.error('Status HTTP:', openAIError.status)
        console.error('Código:', openAIError.code)
        console.error('Tipo:', openAIError.type)
      }

      // Verificar se a chave API está configurada
      const apiKey = process.env.OPENAI_API_KEY
      console.error('API Key configurada?', apiKey ? `Sim (${apiKey.substring(0, 20)}...)` : 'NÃO!')
      console.error('==========================================')

      // ✅ Registrar erro
      if (userId && organizationId) {
        await trackTokens({
          service: 'openai',
          operation: 'categorization',
          model: 'gpt-4o-mini',
          method: 'ai',
          success: false,
          errorMessage: error instanceof Error ? error.message : 'Erro desconhecido',
          userId,
          organizationId,
          documentId,
          projectId,
        })
      }

      // ✅ FALLBACK: Tentar categorização por keywords
      console.log('⚠️ OpenAI falhou, tentando fallback com keywords...')
      return this.categorizeByKeywords(ocrText, filename, userId, documentId, projectId, organizationId)
    }
  }

  /**
   * ✅ NOVO: Categorização por palavras-chave (fallback gratuito)
   * Custo: R$ 0,00
   */
  private async categorizeByKeywords(
    ocrText: string,
    filename: string,
    userId?: number,
    documentId?: number,
    projectId?: number,
    organizationId?: number
  ): Promise<string> {
    console.log('🔑 [KEYWORDS] Iniciando categorização por palavras-chave...')

    const text = (ocrText + ' ' + filename).toLowerCase().normalize('NFD').replace(/[\u0300-\u036f]/g, '')
    let result = '9. Outros Documentos'
    let detected = false

    // 1. RG - Registro Geral
    if (!detected && (text.includes('registro geral') || text.includes('carteira de identidade') || text.includes('rg')) &&
        (text.includes('filiacao') || text.includes('naturalidade') || text.includes('orgao expedidor'))) {
      console.log('✅ [KEYWORDS] Detectado: RG')
      result = '2. RG'
      detected = true
    }

    // 2. CNH - Carteira Nacional de Habilitação
    if (!detected && (text.includes('cnh') || text.includes('habilitacao') || text.includes('carteira nacional')) &&
        (text.includes('categoria') || text.includes('validade') || text.includes('permissao'))) {
      console.log('✅ [KEYWORDS] Detectado: CNH')
      result = '3. CNH'
      detected = true
    }

    // 3. CPF - Cadastro de Pessoa Física
    if (!detected && (text.includes('cpf') || text.includes('cadastro de pessoa fisica') || /\d{3}\.?\d{3}\.?\d{3}-?\d{2}/.test(text))) {
      console.log('✅ [KEYWORDS] Detectado: CPF')
      result = '4. CPF'
      detected = true
    }

    // 4. Comprovante de Residência
    if (!detected && ((text.includes('comprovante') && (text.includes('residencia') || text.includes('endereco'))) ||
        text.includes('conta de luz') || text.includes('conta de agua') || text.includes('fatura') ||
        (text.includes('energia') && text.includes('eletrica')))) {
      console.log('✅ [KEYWORDS] Detectado: Comprovante de Residência')
      result = '5. Comprovante de Residencia'
      detected = true
    }

    // 5. Procuração
    if (!detected && (text.includes('procuracao') || text.includes('outorga') ||
        (text.includes('poderes') && text.includes('representacao')))) {
      console.log('✅ [KEYWORDS] Detectado: Procuração')
      result = '6. Procuracao'
      detected = true
    }

    // 6. Declaração de Hipossuficiência
    if (!detected && (text.includes('hipossuficiencia') || (text.includes('declaracao') && text.includes('baixa renda')) ||
        text.includes('carente') || text.includes('insuficiencia'))) {
      console.log('✅ [KEYWORDS] Detectado: Declaração de Hipossuficiência')
      result = '7. Declaracao de Hipossuficiencia'
      detected = true
    }

    // 7. Contratos
    if (!detected && (text.includes('contrato') || (text.includes('clausula') && text.includes('contratante')) ||
        text.includes('prestacao de servico') || text.includes('honorario'))) {
      console.log('✅ [KEYWORDS] Detectado: Contratos')
      result = '8. Contratos'
      detected = true
    }

    // 8. Boleto
    if (!detected && (text.includes('boleto') || text.includes('codigo de barra') ||
        (text.includes('vencimento') && text.includes('valor')))) {
      console.log('✅ [KEYWORDS] Detectado: Boleto')
      result = '9. Boleto'
      detected = true
    }

    // 9. Narrativa Fática
    if (!detected && (text.includes('narrativa') || text.includes('relato') || text.includes('fatos'))) {
      console.log('✅ [KEYWORDS] Detectado: Narrativa Fática')
      result = '1. Narrativa Fática'
      detected = true
    }

    // 10. Seguro / Apólice
    if (!detected && (text.includes('seguro') || text.includes('apolice') || text.includes('proteção financeira') ||
        text.includes('protecao financeira') || text.includes('sinistro'))) {
      console.log('✅ [KEYWORDS] Detectado: Seguro/Apólice')
      result = '9. Seguro'
      detected = true
    }

    // 11. ASO - Atestado de Saúde Ocupacional
    if (!detected && (text.includes('atestado de saude ocupacional') || text.includes('atestado ocupacional') ||
        /\baso\b/.test(text))) {  // ✅ CORRIGIDO: Só detecta "aso" como palavra isolada
      console.log('✅ [KEYWORDS] Detectado: ASO')
      result = '9. ASO'
      detected = true
    }

    // 12. Certidões
    if (!detected && text.includes('certidao')) {
      if (text.includes('nascimento')) {
        result = '9. Certidão de Nascimento'
        detected = true
      } else if (text.includes('casamento')) {
        result = '9. Certidão de Casamento'
        detected = true
      } else if (text.includes('obito')) {
        result = '9. Certidão de Óbito'
        detected = true
      } else {
        console.log('✅ [KEYWORDS] Detectado: Certidão (genérica)')
        result = '9. Certidão'
        detected = true
      }
    }

    // 13. Laudo/Atestado Médico
    if (!detected && (text.includes('laudo medico') || text.includes('atestado medico') ||
        (text.includes('medico') && (text.includes('crm') || text.includes('atestado'))))) {
      console.log('✅ [KEYWORDS] Detectado: Laudo/Atestado Médico')
      result = '9. Laudo Médico'
      detected = true
    }

    // Log se não detectou nada específico
    if (!detected) {
      console.log('⚠️ [KEYWORDS] Nenhuma categoria específica detectada, usando "Outros Documentos"')
    }

    // ✅ Registrar uso do fallback (custo R$ 0,00)
    if (userId && organizationId) {
      await trackTokens({
        service: 'keywords',
        operation: 'categorization',
        method: 'keywords',
        tokensInput: 0,
        tokensOutput: 0,
        success: true,
        userId,
        organizationId,
        documentId,
        projectId,
      })
    }

    return result
  }

  private parseChatGPTResponse(chatGPTResponse: string): CategoryInfo {
    const response = chatGPTResponse.toLowerCase().trim()

    console.log('🔍 Parsing resposta ChatGPT:', response)

    // 1. Narrativa Fática
    if ((response.includes('1') && response.includes('narrativa')) ||
        response.includes('narrativa fática')) {
      return {
        id: 1, name: 'Narrativa Fática', code: '01 Narrativa Fática',
        description: 'Narrativas e relatos', shouldGroup: false, canDivide: true, isPersonalDocument: false
      }
    }

    // 2. RG
    if ((response.includes('2') && response.includes('rg')) ||
        response.includes('registro geral') ||
        response.includes('carteira de identidade')) {
      return {
        id: 2, name: 'RG', code: '02 Documentos Pessoais',
        description: 'Registro Geral', shouldGroup: true, canDivide: false, isPersonalDocument: true
      }
    }

    // 3. CNH
    if ((response.includes('3') && response.includes('cnh')) ||
        response.includes('carteira nacional de habilitação') ||
        response.includes('habilitação')) {
      return {
        id: 3, name: 'CNH', code: '02 Documentos Pessoais',
        description: 'Carteira Nacional de Habilitação', shouldGroup: true, canDivide: false, isPersonalDocument: true
      }
    }

    // 4. CPF
    if ((response.includes('4') && response.includes('cpf')) ||
        response.includes('cadastro de pessoa física')) {
      return {
        id: 4, name: 'CPF', code: '02 Documentos Pessoais',
        description: 'Cadastro de Pessoa Física', shouldGroup: true, canDivide: false, isPersonalDocument: true
      }
    }

    // 5. Comprovante de Residência
    if ((response.includes('5') && response.includes('comprovante')) ||
        response.includes('comprovante de residencia') ||
        response.includes('comprovante de endereço')) {
      return {
        id: 5, name: 'Comprovante de Residência', code: '03 Comprovante de Residência',
        description: 'Comprovantes de endereço', shouldGroup: false, canDivide: false, isPersonalDocument: false
      }
    }

    // 6. Procuração
    if ((response.includes('6') && response.includes('procuracao')) ||
        response.includes('procuração') ||
        response.includes('outorga') ||
        response.includes('mandato')) {
      return {
        id: 6, name: 'Procuração', code: '04 Procuração',
        description: 'Procurações e outorgas', shouldGroup: false, canDivide: true, isPersonalDocument: false
      }
    }

    // 7. Declaração de Hipossuficiência ✅ MELHORADO
    if ((response.includes('7') && (response.includes('hipossuficiencia') || response.includes('declaracao'))) ||
        response.includes('declaração de hipossuficiência') ||
        response.includes('declaracao de hipossuficiencia') ||
        response.includes('baixa renda') ||
        response.includes('hipossuficiência')) {
      return {
        id: 7, name: 'Declaração de Hipossuficiência', code: '05 Declaração de Hipossuficiência',
        description: 'Declarações de baixa renda', shouldGroup: false, canDivide: false, isPersonalDocument: false
      }
    }

    // 8. Contratos
    if ((response.includes('8') && response.includes('contrato')) ||
        response.includes('contratos') ||
        response.includes('prestação de serviços') ||
        response.includes('honorários')) {
      return {
        id: 8, name: 'Contratos', code: '06 Contratos',
        description: 'Contratos diversos', shouldGroup: false, canDivide: true, isPersonalDocument: false
      }
    }
    
    // 9. Outros Documentos (fallback) ✅ CORRIGIDO + TIPO ESPECÍFICO
    // Extrair tipo específico se a resposta for "9. [Tipo]"
    if (response.includes('9.') || response.includes('9')) {
      // Tentar extrair tipo específico após "9."
      const specificTypeMatch = response.match(/9\.\s*(.+)/i)
      if (specificTypeMatch && specificTypeMatch[1]) {
        const specificType = specificTypeMatch[1]
          .trim()
          .replace(/outros documentos/i, '') // Remover "Outros Documentos" genérico
          .trim()

        if (specificType.length > 0) {
          console.log('🎯 Tipo específico identificado pela IA:', specificType)
          return {
            id: 9,
            name: specificType,
            code: `07 ${specificType}`,
            description: specificType,
            shouldGroup: false,
            canDivide: true,
            isPersonalDocument: false
          }
        }
      }
    }

    // Fallback genérico se não conseguir extrair tipo específico
    return {
      id: 9, name: 'Outros Documentos', code: '07 Outros Documentos',
      description: 'Documentos não categorizados', shouldGroup: false, canDivide: true, isPersonalDocument: false
    }
  }

  private extractInfoFromOCR(ocrText: string): ExtractedInfo {
    const info: ExtractedInfo = { ocrExtractedText: ocrText }

    // Extrair CPF
    const cpfMatch = ocrText.match(/CPF[:\s]*(\d{3}\.\d{3}\.\d{3}-\d{2}|\d{11})/)
    if (cpfMatch) info.cpf = cpfMatch[1]

    // Extrair RG
    const rgMatch = ocrText.match(/RG[:\s]*(\d+)/)
    if (rgMatch) info.rg = rgMatch[1]

    // Extrair CNH
    const cnhMatch = ocrText.match(/CNH[:\s]*(\d+)/)
    if (cnhMatch) info.cnh = cnhMatch[1]

    return info
  }

  /**
   * Normaliza o tipo de documento para comparação e agrupamento
   * Remove números, acentos, artigos e variações para identificar tipos similares
   *
   * Exemplos:
   * "07 ficha financeira" → "ficha financeira"
   * "07 ficha financeira individual" → "ficha financeira"
   * "07 ficha financeira de servidor público" → "ficha financeira servidor publico"
   */
  private normalizeDocumentType(documentType: string): string {
    if (!documentType) return ''

    return documentType
      .toLowerCase()
      .normalize('NFD').replace(/[\u0300-\u036f]/g, '') // Remove acentos
      .replace(/^\d+\s*/, '') // Remove números iniciais (ex: "07 ")
      .replace(/\b(de|da|do|dos|das)\b/g, '') // Remove artigos
      .replace(/\b(individual|pessoal|completo|geral)\b/g, '') // Remove palavras genéricas
      .replace(/[^\w\s]/g, '') // Remove pontuação
      .replace(/\s+/g, ' ') // Normaliza espaços
      .trim()
  }

  /**
   * Verifica se dois tipos de documento são similares o suficiente para agrupamento
   * Usa distância de palavras-chave para determinar similaridade
   */
  private areDocumentTypesSimilar(type1: string, type2: string): boolean {
    const normalized1 = this.normalizeDocumentType(type1)
    const normalized2 = this.normalizeDocumentType(type2)

    // Se exatamente iguais após normalização
    if (normalized1 === normalized2) return true

    // Extrair palavras principais (> 3 caracteres)
    const words1 = normalized1.split(' ').filter(w => w.length > 3)
    const words2 = normalized2.split(' ').filter(w => w.length > 3)

    // Se uma das palavras principais está na outra
    const commonWords = words1.filter(w => words2.includes(w))

    // Considera similar se tiver pelo menos 1 palavra em comum e a palavra principal for igual
    return commonWords.length > 0 && words1[0] === words2[0]
  }

  // ==================== PROCESSAMENTO DE DOCUMENTOS ====================

  private async handlePersonalDocument(
    document: DocumentToProcess,
    category: CategoryInfo,
    documentNumber: number,
    projectId: number
  ): Promise<ConversionResult> {
    try {
      console.log('🆔 Processando documento pessoal:', category.name)

      // ✅ Buscar projeto para garantir isolamento multi-tenant
      const project = await prisma.project.findUnique({
        where: { id: projectId },
        select: { organizationId: true }
      })

      if (!project) {
        throw new Error('Projeto não encontrado')
      }

      // Processar documento individual primeiro
      const individualResult = await this.processSingleDocument(document, category, documentNumber)

      if (!individualResult.success) {
        return individualResult
      }

      // Armazenar para possível agrupamento
      const savedDocumentId = await this.storePersonalDocumentForGrouping(individualResult, category, projectId, document)

      // ✅ Verificar se existem outros documentos pessoais do mesmo projeto (com filtro de organização)
      const personalDocsInProject = await this.getPersonalDocumentsFromProject(projectId, project.organizationId)

      console.log(`📊 Documentos pessoais no projeto ${projectId}:`, personalDocsInProject.length)

      // Se houver 2+ documentos pessoais, criar PDF agrupado
      if (personalDocsInProject.length >= 2) {
        console.log('🔗 Agrupando documentos pessoais em PDF único...')

        const groupedResult = await this.combinePersonalDocuments(personalDocsInProject, projectId)

        if (groupedResult.success) {
          await this.cleanupIndividualPersonalDocuments(personalDocsInProject)

          return {
            ...groupedResult,
            groupedDocuments: personalDocsInProject.length,
            isPersonalDocument: true,
            savedDocumentId
          }
        }
      }

      return {
        ...individualResult,
        isPersonalDocument: true,
        shouldWaitForGrouping: true,
        savedDocumentId
      }

    } catch (error) {
      console.error('❌ Erro ao processar documento pessoal:', error)
      throw error
    }
  }

  /**
   * Verifica se um documento deve ser agrupado com outros documentos similares do projeto
   * Retorna true se encontrar documentos do mesmo tipo (normalizado)
   */
  private async shouldGroupDocument(
    category: CategoryInfo,
    projectId: number,
    organizationId?: number
  ): Promise<boolean> {
    try {
      if (!organizationId) return false

      // Buscar projeto para isolamento multi-tenant
      const project = await prisma.project.findUnique({
        where: { id: projectId },
        select: { organizationId: true }
      })

      if (!project || project.organizationId !== organizationId) return false

      // Buscar documentos não agrupados do projeto
      const existingDocs = await prisma.document.findMany({
        where: {
          projectId: projectId,
          organizationId: organizationId,
          isGrouped: false,
          status: { in: ['validated', 'ocr_completed'] }
        },
        select: {
          id: true,
          documentType: true,
          detectedDocumentType: true
        }
      })

      // Verificar se existe algum documento similar
      return existingDocs.some(doc => {
        const existingType = doc.detectedDocumentType || doc.documentType || ''
        const newType = category.name
        return this.areDocumentTypesSimilar(existingType, newType)
      })
    } catch (error) {
      console.error('❌ Erro ao verificar agrupamento:', error)
      return false
    }
  }

  /**
   * Processa documento com agrupamento genérico (qualquer tipo de documento)
   * Similar a handlePersonalDocument mas funciona para qualquer categoria
   */
  private async handleGroupableDocument(
    document: DocumentToProcess,
    category: CategoryInfo,
    documentNumber: number,
    projectId: number,
    organizationId: number
  ): Promise<ConversionResult> {
    try {
      console.log('🔗 Processando documento para agrupamento:', category.name)

      // Buscar projeto para garantir isolamento multi-tenant
      const project = await prisma.project.findUnique({
        where: { id: projectId },
        select: { organizationId: true, userId: true }
      })

      if (!project || project.organizationId !== organizationId) {
        throw new Error('Projeto não encontrado ou não pertence à organização')
      }

      // Processar documento individual primeiro
      const individualResult = await this.processSingleDocument(document, category, documentNumber)

      if (!individualResult.success) {
        return individualResult
      }

      // Armazenar documento para agrupamento
      const savedDoc = await prisma.document.create({
        data: {
          projectId: projectId,
          userId: project.userId,
          organizationId: project.organizationId,
          originalFilename: document.filename,
          storedFilename: individualResult.smartFilename || 'documento.pdf',
          smartFilename: individualResult.smartFilename,
          documentType: category.code,
          detectedDocumentType: category.name,
          documentNumber: 1,
          mimeType: document.mimeType,
          originalSizeBytes: document.buffer.length,
          isPersonalDocument: false,
          isGrouped: false,
          status: 'validated',
          pdfPath: individualResult.pdfPath,
          ocrText: document.ocrText,
          pdfSizeBytes: individualResult.finalSizeBytes,
          pageCount: individualResult.pageCount
        }
      })

      console.log('✅ Documento salvo para agrupamento, ID:', savedDoc.id)

      // ✅ CORREÇÃO: Buscar documentos similares não agrupados + documento agrupado anterior (se existir)
      const similarDocs = await this.getSimilarDocumentsFromProject(
        projectId,
        organizationId,
        category.name
      )

      // Buscar se já existe um documento agrupado do mesmo tipo
      const existingGroupedDoc = await prisma.document.findFirst({
        where: {
          projectId: projectId,
          organizationId: organizationId,
          isGrouped: false, // Documento agrupado não tem isGrouped=true
          status: { in: ['validated', 'ocr_completed'] }
        },
        orderBy: { createdAt: 'desc' }
      })

      // Verificar se o documento agrupado existe e é do mesmo tipo
      const hasExistingGroup = existingGroupedDoc &&
        existingGroupedDoc.storedFilename.includes('agrupado') &&
        this.areDocumentTypesSimilar(
          existingGroupedDoc.detectedDocumentType || existingGroupedDoc.documentType,
          category.name
        )

      console.log(`📊 Documentos similares no projeto ${projectId}:`, similarDocs.length)
      if (hasExistingGroup) {
        console.log(`📦 Encontrado documento agrupado anterior: ${existingGroupedDoc!.storedFilename}`)
      }

      // Se houver 2+ documentos similares, criar PDF agrupado
      if (similarDocs.length >= 2) {
        console.log('🔗 Agrupando documentos similares em PDF único...')

        const groupedResult = await this.combinePersonalDocuments(similarDocs, projectId)

        if (groupedResult.success) {
          // ✅ DELETAR documento agrupado anterior (se existir)
          if (hasExistingGroup && existingGroupedDoc) {
            console.log(`🗑️ Deletando documento agrupado anterior (ID: ${existingGroupedDoc.id})`)

            // Deletar arquivo físico
            if (existingGroupedDoc.pdfPath) {
              try {
                const pathParts = existingGroupedDoc.pdfPath.split('/').filter(p => p.length > 0)
                if (pathParts.length >= 2) {
                  const filePath = pathParts.slice(-2).join('/')
                  const { deleteFile } = await import('@/lib/storage-service')
                  await deleteFile(filePath)
                  console.log(`   ✅ Arquivo físico deletado: ${filePath}`)
                }
              } catch (error) {
                console.warn(`   ⚠️ Erro ao deletar arquivo físico:`, error)
              }
            }

            // Deletar registro do banco
            await prisma.document.delete({
              where: { id: existingGroupedDoc.id }
            })
            console.log(`   ✅ Registro deletado do banco`)
          }

          // Marcar todos os documentos individuais como agrupados
          await prisma.document.updateMany({
            where: {
              id: { in: similarDocs.map(d => d.id) },
              organizationId: organizationId
            },
            data: { isGrouped: true }
          })

          return {
            ...groupedResult,
            groupedDocuments: similarDocs.length,
            savedDocumentId: savedDoc.id
          }
        }
      }

      // Retornar documento individual enquanto aguarda mais uploads
      return {
        ...individualResult,
        shouldWaitForGrouping: true,
        savedDocumentId: savedDoc.id
      }

    } catch (error) {
      console.error('❌ Erro ao processar documento agrupável:', error)
      throw error
    }
  }

  /**
   * Busca documentos similares (mesmo tipo normalizado) no projeto
   */
  private async getSimilarDocumentsFromProject(
    projectId: number,
    organizationId: number,
    documentType: string
  ): Promise<PendingPersonalDocument[]> {
    try {
      // Buscar todos os documentos não agrupados do projeto
      const documents = await prisma.document.findMany({
        where: {
          projectId: projectId,
          organizationId: organizationId,
          isGrouped: false,
          status: { in: ['validated', 'ocr_completed'] }
        },
        orderBy: { createdAt: 'asc' }
      })

      // Filtrar apenas documentos similares
      const similarDocs = documents.filter(doc => {
        const docType = doc.detectedDocumentType || doc.documentType || ''
        return this.areDocumentTypesSimilar(docType, documentType)
      })

      // Mapear para o formato esperado
      return similarDocs.map((doc) => ({
        id: doc.id,
        filename: doc.smartFilename || doc.storedFilename,
        pdfPath: doc.pdfPath || `/documents/${doc.storedFilename}`,
        pdfBuffer: Buffer.alloc(0),
        documentType: doc.detectedDocumentType || doc.documentType,
        projectId: doc.projectId,
        createdAt: doc.createdAt
      }))

    } catch (error) {
      console.error('❌ Erro ao buscar documentos similares:', error)
      return []
    }
  }

  private async storePersonalDocumentForGrouping(
    result: ConversionResult,
    category: CategoryInfo,
    projectId: number,
    originalDocument: DocumentToProcess
  ): Promise<number> {
    try {
      const project = await prisma.project.findUnique({
        where: { id: projectId },
        select: { userId: true, organizationId: true }
      })

      if (!project) {
        throw new Error('Projeto não encontrado')
      }

      // Marcar documentos anteriores como agrupados
      await prisma.document.updateMany({
        where: {
          projectId: projectId,
          organizationId: project.organizationId, // ✅ Isolamento multi-tenant
          isPersonalDocument: true,
          isGrouped: false,
          documentType: category.code
        },
        data: { isGrouped: true }
      })

      // Salvar novo documento pessoal
      const document = await prisma.document.create({
        data: {
          projectId: projectId,
          userId: project.userId,
          organizationId: project.organizationId,
          originalFilename: originalDocument.filename,
          storedFilename: result.smartFilename || 'documento.pdf',
          smartFilename: result.smartFilename,
          documentType: category.code,
          detectedDocumentType: category.name,
          documentNumber: 1,
          mimeType: originalDocument.mimeType,
          originalSizeBytes: result.finalSizeBytes || 0,
          isPersonalDocument: true,
          isGrouped: false,
          status: 'validated',
          pdfPath: result.pdfPath,
          ocrText: originalDocument.ocrText,
          pdfSizeBytes: result.finalSizeBytes,
          pageCount: result.pageCount || 1,
          aiAnalysis: originalDocument.analysis ? JSON.stringify(originalDocument.analysis) : null,
          analysisConfidence: originalDocument.analysis?.confidence
        }
      })

      console.log('✅ Documento pessoal registrado no banco para agrupamento:', document.id)
      return document.id

    } catch (error) {
      console.error('❌ Erro ao armazenar documento pessoal:', error)
      throw error
    }
  }

  private async getPersonalDocumentsFromProject(projectId: number, organizationId: number): Promise<PendingPersonalDocument[]> {
    try {
      const documents = await prisma.document.findMany({
        where: {
          projectId: projectId,
          organizationId: organizationId, // ✅ Isolamento multi-tenant
          isPersonalDocument: true,
          isGrouped: false, // ✅ Simplificado (removido OR redundante)
          status: 'validated'
        },
        orderBy: { createdAt: 'asc' }
      })

      return documents.map((doc) => ({
        id: doc.id,
        filename: doc.smartFilename || doc.storedFilename,
        pdfPath: doc.pdfPath || `/documents/${doc.storedFilename}`,
        pdfBuffer: Buffer.alloc(0),
        documentType: doc.detectedDocumentType || doc.documentType,
        projectId: doc.projectId,
        createdAt: doc.createdAt
      }))
      
    } catch (error) {
      console.error('❌ Erro ao buscar documentos pessoais:', error)
      return []
    }
  }

  private async combinePersonalDocuments(
    personalDocs: PendingPersonalDocument[], 
    projectId: number
  ): Promise<ConversionResult> {
    try {
      console.log(`🔗 Combinando ${personalDocs.length} documentos pessoais...`)
      
      const combinedPdf = await PDFDocument.create()
      let totalPages = 0
      
      // Adicionar página de título
      const titlePage = combinedPdf.addPage(PageSizes.A4)
      const { width, height } = titlePage.getSize()
      
      titlePage.drawText('DOCUMENTOS PESSOAIS', {
        x: width / 2 - 100, y: height - 100, size: 20, color: rgb(0, 0, 0)
      })
      
      titlePage.drawText(`Projeto: ${projectId}`, {
        x: 50, y: height - 150, size: 12, color: rgb(0.5, 0.5, 0.5)
      })
      
      titlePage.drawText(`Data: ${new Date().toLocaleDateString('pt-BR')}`, {
        x: 50, y: height - 170, size: 12, color: rgb(0.5, 0.5, 0.5)
      })
      
      totalPages++
      
      // Processar cada documento pessoal
      for (const doc of personalDocs) {
        if (!doc.pdfPath) continue

        try {
          // Extrair caminho do storage (compatível com Supabase e Local)
          let storagePath = doc.pdfPath

          // URL Supabase
          if (doc.pdfPath.includes('/documents/')) {
            storagePath = doc.pdfPath.split('/documents/')[1]
          }
          // URL Local
          else if (doc.pdfPath.includes('/uploads/')) {
            storagePath = doc.pdfPath.split('/uploads/')[1]
          }
          // Caminho relativo
          else {
            storagePath = storagePath.replace(/^processed\//, '')
            storagePath = `processed/${storagePath}`
          }

          // Baixar usando storage-service
          const pdfData = await downloadFile(storagePath)
          const existingPdf = await PDFDocument.load(pdfData, { ignoreEncryption: true })
          
          // Adicionar página separadora
          const separatorPage = combinedPdf.addPage(PageSizes.A4)
          separatorPage.drawText(doc.documentType.toUpperCase(), {
            x: 50, y: height - 100, size: 16, color: rgb(0.2, 0.2, 0.8)
          })
          totalPages++
          
          // Copiar páginas do documento
          const pageIndices = existingPdf.getPageIndices()
          const copiedPages = await combinedPdf.copyPages(existingPdf, pageIndices)
          
          copiedPages.forEach((page) => combinedPdf.addPage(page))
          totalPages += pageIndices.length
          
        } catch (docError) {
          console.error(`❌ Erro ao processar ${doc.filename}:`, docError)
          continue
        }
      }
      
      if (combinedPdf.getPageCount() <= 1) {
        return {
          success: false,
          error: 'Nenhum documento válido encontrado para combinar'
        }
      }
      
      // Gerar PDF final
      const pdfBytes = await combinedPdf.save()
      const pdfBuffer = Buffer.from(pdfBytes)
      
      // Salvar PDF combinado
      const combinedFilename = '02 Documentos Pessoais.pdf'
      const storagePath = `processed/${combinedFilename}`

      // Upload usando storage-service
      const file = new File([pdfBuffer], combinedFilename, { type: 'application/pdf' })
      await uploadFile(file, storagePath)

      // Gerar URL pública
      let publicURL: string
      if (process.env.UPLOAD_DIR && process.env.NEXT_PUBLIC_UPLOAD_URL) {
        publicURL = `${process.env.NEXT_PUBLIC_UPLOAD_URL}/${storagePath}`
      } else if (process.env.NEXT_PUBLIC_SUPABASE_URL && process.env.SUPABASE_BUCKET_NAME) {
        publicURL = `${process.env.NEXT_PUBLIC_SUPABASE_URL}/storage/v1/object/public/${process.env.SUPABASE_BUCKET_NAME}/${storagePath}`
      } else {
        throw new Error('Configuração de storage não encontrada')
      }

      console.log(`✅ PDF combinado salvo: ${combinedFilename} (${totalPages} páginas)`)

      return {
        success: true,
        pdfPath: publicURL,
        pdfBuffer,
        ocrText: '',
        pageCount: totalPages,
        finalSizeBytes: pdfBuffer.length,
        smartFilename: combinedFilename,
        categoryInfo: {
          id: 2, name: 'Documentos Pessoais', code: '02 Documentos Pessoais',
          description: 'RG, CNH, CPF combinados', shouldGroup: true, canDivide: false, isPersonalDocument: true
        }
      }
      
    } catch (error) {
      console.error('❌ Erro ao combinar documentos pessoais:', error)
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Erro ao combinar documentos pessoais'
      }
    }
  }

  private async cleanupIndividualPersonalDocuments(personalDocs: PendingPersonalDocument[]): Promise<void> {
    try {
      console.log(`🧹 Limpando ${personalDocs.length} documentos individuais...`)
      
      for (const doc of personalDocs) {
        try {
          await prisma.document.update({
            where: { id: doc.id },
            data: {
              isGrouped: true,
              groupedAt: new Date(),
              status: 'grouped'
            }
          })
        } catch (docError) {
          console.warn(`⚠️ Erro ao marcar documento ${doc.filename}:`, docError)
        }
      }
      
      console.log('✅ Limpeza concluída - documentos marcados como agrupados')
      
    } catch (error) {
      console.error('❌ Erro na limpeza:', error)
      throw error
    }
  }

  private async handleDivisibleDocument(
    document: DocumentToProcess,
    category: CategoryInfo,
    documentNumber: number
  ): Promise<ConversionResult> {
    console.log('✂️ Documento grande detectado, dividindo:', category.name)
    
    try {
      const mainPdf = await this.createOptimizedPDF(document.buffer, document.mimeType, document.ocrText, document.ocrWords)
      const pdfBytes = await mainPdf.save()
      
      const fileSizeMB = pdfBytes.length / (1024 * 1024)
      const maxSizeMB = this.systemRequirements.maxSizeMB
      
      if (fileSizeMB <= maxSizeMB) {
        return await this.saveSinglePDF(Buffer.from(pdfBytes), category, documentNumber, document)
      }
      
      console.log(`📊 Documento ${fileSizeMB.toFixed(2)}MB > ${maxSizeMB}MB, dividindo...`)
      
      const parts = await this.dividePDFIntoChunks(mainPdf)
      const results: ConversionResult[] = []
      
      for (let i = 0; i < parts.length; i++) {
        const partNumber = i + 1
        const result = await this.saveSinglePDF(parts[i], category, documentNumber, document, partNumber)
        results.push(result)
      }
      
      const firstResult = results[0]
      return {
        ...firstResult,
        dividedParts: parts.length
      }
      
    } catch (error) {
      console.error('❌ Erro ao dividir documento:', error)
      throw error
    }
  }

  private async processSingleDocument(
    document: DocumentToProcess,
    category: CategoryInfo,
    documentNumber: number
  ): Promise<ConversionResult> {
    console.log('📄 Processando documento único:', category.name)

    try {
      let pdfBuffer: Buffer

      if (document.mimeType === 'application/pdf') {
        // ✅ VALIDAÇÃO: Verificar se o PDF está válido antes de usar
        try {
          const pdfHeader = document.buffer.subarray(0, 5).toString()
          if (pdfHeader !== '%PDF-') {
            throw new Error('PDF inválido: header incorreto - ' + pdfHeader)
          }

          // Tentar carregar o PDF para validar estrutura
          await PDFDocument.load(document.buffer, { ignoreEncryption: true })

          pdfBuffer = document.buffer
          console.log('✅ PDF original validado e será usado diretamente')
        } catch (validationError) {
          console.error('❌ PDF original corrompido:', validationError)
          console.log('🔄 Tentando reprocessar o documento...')

          // Reprocessar se o PDF estiver corrompido
          const pdfDoc = await this.createOptimizedPDF(document.buffer, document.mimeType, document.ocrText, document.ocrWords)
          const pdfBytes = await pdfDoc.save()
          pdfBuffer = Buffer.from(pdfBytes)
        }
      } else {
        // Para outros tipos, criar PDF otimizado
        const pdfDoc = await this.createOptimizedPDF(document.buffer, document.mimeType, document.ocrText, document.ocrWords)
        const pdfBytes = await pdfDoc.save()
        pdfBuffer = Buffer.from(pdfBytes)
      }

      return await this.saveSinglePDF(pdfBuffer, category, documentNumber, document)

    } catch (error) {
      console.error('❌ Erro ao processar documento único:', error)
      throw error
    }
  }

  // ==================== CRIAÇÃO DE PDF ====================

  private async createOptimizedPDF(
    buffer: Buffer,
    mimeType: string,
    ocrText?: string,
    ocrWords?: Array<{ text: string; x: number; y: number; width: number; height: number; confidence: number }>
  ): Promise<PDFDocument> {
    const pdfDoc = await PDFDocument.create()

    if (mimeType === 'application/pdf') {
      // PDF existente - copiar páginas e adicionar OCR se disponível
      console.log('📄 Copiando páginas do PDF existente...')
      const existingPdf = await PDFDocument.load(buffer, { ignoreEncryption: true })
      const pageIndices = existingPdf.getPageIndices()
      const copiedPages = await pdfDoc.copyPages(existingPdf, pageIndices)
      copiedPages.forEach(page => pdfDoc.addPage(page))

      // ✅ NOVO: Adicionar camada de texto OCR se disponível (para PDFs escaneados)
      if (ocrText && ocrText.length > 10) {
        console.log(`📝 [PDF Pesquisável] Adicionando camada OCR em PDF escaneado...`)
        console.log(`   Páginas: ${copiedPages.length}, Texto OCR: ${ocrText.length} caracteres`)

        // Se tiver coordenadas de palavras, usar
        if (ocrWords && ocrWords.length > 0) {
          console.log(`   Palavras com coordenadas: ${ocrWords.length}`)
          // Adicionar palavras na primeira página (assumindo PDF de 1 página do upload)
          const firstPage = pdfDoc.getPages()[0]
          const { width, height } = firstPage.getSize()

          let wordsAdded = 0
          for (const word of ocrWords) {
            try {
              const cleanText = PDFConverter.cleanTextForWinAnsi(word.text)
              if (cleanText) {
                // Coordenadas do OCR já estão em pixels da imagem original
                // Precisamos mapear para o espaço do PDF
                const scaledX = (word.x / 1654) * width // 1654 = largura A4 em 200 DPI
                const scaledY = height - ((word.y / 2339) * height) // 2339 = altura A4 em 200 DPI
                const fontSize = Math.max(1, (word.height / 2339) * height)

                firstPage.drawText(cleanText, {
                  x: scaledX,
                  y: scaledY,
                  size: fontSize,
                  color: rgb(0, 0, 0),
                  opacity: 0 // Totalmente transparente
                })
                wordsAdded++
              }
            } catch (drawError) {
              // Ignorar palavras com problemas de encoding
            }
          }
          console.log(`✅ [PDF Pesquisável] ${wordsAdded} palavras adicionadas ao PDF escaneado`)
        } else {
          // Fallback: adicionar texto completo de forma invisível
          console.log(`   Adicionando texto completo (sem coordenadas)`)
          try {
            const firstPage = pdfDoc.getPages()[0]
            const { width, height } = firstPage.getSize()
            const cleanText = PDFConverter.cleanTextForWinAnsi(ocrText)

            if (cleanText) {
              firstPage.drawText(cleanText, {
                x: 0,
                y: height - 10,
                size: 1,
                color: rgb(0, 0, 0),
                opacity: 0,
                maxWidth: width
              })
              console.log(`✅ [PDF Pesquisável] Texto OCR adicionado ao PDF escaneado`)
            }
          } catch (drawError) {
            console.warn('⚠️ Não foi possível adicionar texto OCR ao PDF')
          }
        }
      }

    } else if (mimeType.startsWith('image/')) {
      // Imagem - converter para PDF
      await this.addImageToPDF(pdfDoc, buffer, ocrText, ocrWords)
      
    } else if (mimeType.includes('text/')) {
      console.log('📄 Criando PDF com texto...')
      // Texto - criar PDF com texto
      await this.addTextToPDF(pdfDoc, ocrText || buffer.toString('utf-8'))
    }else if (ocrText != '') {
      await this.addTextToPDF(pdfDoc, ocrText || buffer.toString('utf-8'))
    } else {
      // Tipo não suportado - criar página vazia com aviso
      const page = pdfDoc.addPage(PageSizes.A4)
      const { height } = page.getSize()
      
      page.drawText('Documento não pôde ser convertido', {
        x: 50, y: height - 100, size: 16, color: rgb(0.8, 0, 0)
      })
      
      page.drawText(`Tipo: ${mimeType}`, {
        x: 50, y: height - 130, size: 12, color: rgb(0.5, 0.5, 0.5)
      })
    }

    return pdfDoc
  }

  private async addImageToPDF(
    pdfDoc: PDFDocument,
    buffer: Buffer,
    ocrText?: string,
    ocrWords?: Array<{ text: string; x: number; y: number; width: number; height: number; confidence: number }>
  ): Promise<void> {
    try {
      // ✅ DESABILITADO: Rotação automática removida - usuário fará manualmente via UI
      console.log('📄 [PDF] Adicionando imagem ao PDF...')
      console.log('📏 [PDF] Tamanho buffer original:', this.formatFileSize(buffer.length))
      // const correctedBuffer = await this.correctImageOrientation(buffer)
      // console.log('📏 [PDF] Orientação corrigida com sucesso')

      // Otimizar imagem para PDF
      const optimizedBuffer = await sharp(buffer)
        .resize(1654, 2339, { // A4 em 200 DPI
          fit: 'inside',
          withoutEnlargement: true
        })
        .jpeg({
          quality: this.systemRequirements.compression ? 85 : 95,
          mozjpeg: true
        })
        .toBuffer()

      // Incorporar imagem
      const image = await pdfDoc.embedJpg(optimizedBuffer)
      const page = pdfDoc.addPage(PageSizes.A4)
      const { width, height } = page.getSize()

      // Calcular dimensões mantendo proporção
      const imageAspectRatio = image.width / image.height
      const pageAspectRatio = width / height

      let drawWidth, drawHeight
      if (imageAspectRatio > pageAspectRatio) {
        drawWidth = width * 0.9
        drawHeight = drawWidth / imageAspectRatio
      } else {
        drawHeight = height * 0.9
        drawWidth = drawHeight * imageAspectRatio
      }

      const x = (width - drawWidth) / 2
      const y = (height - drawHeight) / 2

      // Desenhar imagem
      page.drawImage(image, { x, y, width: drawWidth, height: drawHeight })

      // ✅ MELHORADO: Adicionar texto invisível para busca (se OCR disponível)
      console.log(`📝 [PDF Pesquisável] Adicionando camada de texto invisível...`)
      console.log(`   Palavras detectadas: ${ocrWords?.length || 0}`)

      if (ocrWords && ocrWords.length > 0) {
        // Desenhar cada palavra nas coordenadas exatas
        const scaleX = drawWidth / image.width
        const scaleY = drawHeight / image.height

        let wordsAdded = 0
        for (const word of ocrWords) {
          const scaledX = x + (word.x * scaleX)
          const scaledY = y + drawHeight - (word.y * scaleY) - (word.height * scaleY)

          // Calcular tamanho de fonte baseado na altura da palavra
          const fontSize = Math.max(1, (word.height * scaleY))

          try {
            const cleanText = PDFConverter.cleanTextForWinAnsi(word.text)
            if (cleanText) {
              // ✅ Usar texto TOTALMENTE TRANSPARENTE (renderingMode 3 = invisible)
              page.drawText(cleanText, {
                x: scaledX,
                y: scaledY,
                size: fontSize,
                color: rgb(0, 0, 0), // Cor não importa pois será invisível
                opacity: 0 // Totalmente transparente
              })
              wordsAdded++
            }
          } catch (drawError) {
            // Ignorar palavras que não podem ser desenhadas
            console.warn('⚠️ Palavra ignorada (encoding):', word.text.substring(0, 20))
          }
        }
        console.log(`✅ [PDF Pesquisável] ${wordsAdded} palavras adicionadas como texto invisível`)
      } else if (ocrText) {
        // Fallback: texto simples sem coordenadas
        console.log(`   Usando texto completo (sem coordenadas): ${ocrText.length} caracteres`)
        try {
          const cleanText = PDFConverter.cleanTextForWinAnsi(ocrText)
          if (cleanText) {
            page.drawText(cleanText, {
              x: 0, y: height - 10, size: 1, color: rgb(0, 0, 0),
              opacity: 0, maxWidth: width
            })
          }
        } catch (drawError) {
          console.warn('⚠️ Não foi possível adicionar texto OCR (encoding incompatível)')
        }
      }

    } catch (error) {
      console.error('❌ Erro ao adicionar imagem ao PDF:', error)
      throw error
    }
  }

  private async addTextToPDF(pdfDoc: PDFDocument, text: string): Promise<void> {
    const page = pdfDoc.addPage(PageSizes.A4)
    const { width, height } = page.getSize()

    const lines = text.split('\n')
    let y = height - 50
    const lineHeight = 14

    for (const line of lines) {
      // Limpar linha para compatibilidade WinAnsi
      const cleanLine = PDFConverter.cleanTextForWinAnsi(line)
      if (!cleanLine) {
        y -= lineHeight
        continue
      }

      try {
        if (y < 50) {
          // Nova página
          const newPage = pdfDoc.addPage(PageSizes.A4)
          y = newPage.getSize().height - 50

          newPage.drawText(cleanLine, {
            x: 50, y, size: 10, maxWidth: width - 100
          })
        } else {
          page.drawText(cleanLine, {
            x: 50, y, size: 10, maxWidth: width - 100
          })
        }
      } catch (drawError) {
        console.warn('⚠️ Linha ignorada (encoding):', cleanLine.substring(0, 50))
      }

      y -= lineHeight
    }
  }

  /**
   * ✅ NOVO: Corrige automaticamente a orientação de imagens
   * Usa metadados EXIF para rotacionar corretamente
   * Custo: R$ 0,00 (processamento local com Sharp)
   */
  private async correctImageOrientation(buffer: Buffer): Promise<Buffer> {
    try {
      console.log('🔄 [ORIENTAÇÃO] Iniciando correção de orientação da imagem...')

      // Obter metadados da imagem
      const image = sharp(buffer)
      const metadata = await image.metadata()

      console.log('📊 [ORIENTAÇÃO] Metadados da imagem:', {
        formato: metadata.format,
        largura: metadata.width,
        altura: metadata.height,
        orientation: metadata.orientation,
        hasAlpha: metadata.hasAlpha,
        space: metadata.space
      })

      // Verificar se tem orientação EXIF
      if (metadata.orientation && metadata.orientation !== 1) {
        console.log(`🔄 [ORIENTAÇÃO] Detectada orientação EXIF: ${metadata.orientation} - Aplicando rotação...`)

        // Aplicar rotação baseada em EXIF
        const correctedBuffer = await sharp(buffer)
          .rotate() // Auto-rotação baseada em EXIF
          .toBuffer()

        console.log('✅ [ORIENTAÇÃO] Imagem corrigida via EXIF!')
        return correctedBuffer
      }

      // ✅ MELHORADO: Detectar orientação para QUALQUER imagem sem EXIF
      console.log('📐 [ORIENTAÇÃO] SEM metadados EXIF - usando OCR para detectar orientação correta...')

      // Testar diferentes rotações com OCR (inclui landscape e portrait)
      const bestRotation = await this.detectOrientationWithOCR(buffer, metadata)

      if (bestRotation === 0) {
        console.log('✅ [ORIENTAÇÃO] Imagem já está na orientação correta!')
        return buffer
      }

      console.log(`🔄 [ORIENTAÇÃO] Rotacionando ${bestRotation}°...`)
      const rotatedBuffer = await sharp(buffer)
        .rotate(bestRotation)
        .toBuffer()

      console.log('✅ [ORIENTAÇÃO] Documento rotacionado com sucesso!')
      return rotatedBuffer

    } catch (error) {
      console.error('❌ [ORIENTAÇÃO] Erro ao corrigir orientação:', error)
      console.warn('⚠️ [ORIENTAÇÃO] Usando imagem original')
      return buffer // Fallback: retorna imagem original
    }
  }

  /**
   * ✅ MELHORADO: Detecta a melhor orientação usando OCR
   * Testa 4 rotações (0°, 90°, 180°, 270°) e escolhe a que extrai mais texto legível
   * Custo: 4x chamadas OCR (só para imagens sem EXIF)
   */
  private async detectOrientationWithOCR(buffer: Buffer, metadata?: Metadata): Promise<number> {
    try {
      console.log('🧪 [OCR-ORIENTAÇÃO] Testando rotações com OCR...')

      // Criar versão pequena para teste rápido (economiza tempo de OCR)
      const testBuffer = await sharp(buffer)
        .resize(1000, null, { fit: 'inside', withoutEnlargement: true })
        .jpeg({ quality: 80 })
        .toBuffer()

      // ✅ MELHORADO: Testar rotações inteligentes baseadas na orientação da imagem
      let rotations: number[]

      if (metadata?.width && metadata?.height) {
        const isLandscape = metadata.width > metadata.height

        if (isLandscape) {
          // Imagem horizontal (deitada) - priorizar 90° e 270°
          console.log('📐 Imagem LANDSCAPE - testando rotações: 90°, 270°, 0°, 180°')
          rotations = [90, 270, 0, 180]
        } else {
          // Imagem vertical (em pé) - priorizar 0° e 180°
          console.log('📐 Imagem PORTRAIT - testando rotações: 0°, 180°, 90°, 270°')
          rotations = [0, 180, 90, 270]
        }
      } else {
        // Fallback: testar todas as rotações
        console.log('📐 Orientação desconhecida - testando todas as rotações')
        rotations = [0, 90, 180, 270]
      }

      const results: { rotation: number; textLength: number; text: string; wordCount: number }[] = []

      for (const rotation of rotations) {
        try {
          console.log(`   Testando ${rotation}°...`)

          // Rotacionar se necessário
          const rotatedBuffer = rotation === 0
            ? testBuffer
            : await sharp(testBuffer).rotate(rotation).toBuffer()

          // Fazer OCR
          const base64File = rotatedBuffer.toString('base64')
          const response = await fetch('https://ocr.elysiumsistemas.com.br/api/upload', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
              password: 'elysiumocr2025',
              file: base64File
            }),
            signal: AbortSignal.timeout(15000) // 15s timeout
          })

          if (!response.ok) {
            console.warn(`   ${rotation}°: Erro OCR - ${response.status}`)
            results.push({ rotation, textLength: 0, text: '', wordCount: 0 })
            continue
          }

          const data = await response.json()
          const text = data.text || ''
          const textLength = text.trim().length

          // ✅ MELHORADO: Contar palavras válidas para melhor detecção
          const words = text.trim().split(/\s+/).filter((word: string) => word.length > 2)
          const wordCount = words.length

          console.log(`   ${rotation}°: ${textLength} caracteres | ${wordCount} palavras`)

          results.push({ rotation, textLength, text, wordCount })

        } catch (error) {
          console.warn(`   ${rotation}°: Erro no teste - ${error}`)
          results.push({ rotation, textLength: 0, text: '', wordCount: 0 })
        }

        // ✅ OTIMIZAÇÃO: Se encontrou resultado excelente, parar os testes
        if (results[results.length - 1].wordCount > 20) {
          console.log(`   ⚡ Resultado excelente encontrado em ${rotation}° - parando testes`)
          break
        }
      }

      // ✅ MELHORADO: Escolher baseado em palavras (mais confiável que caracteres)
      const best = results.reduce((a, b) => {
        // Priorizar contagem de palavras, depois caracteres
        if (a.wordCount !== b.wordCount) {
          return a.wordCount > b.wordCount ? a : b
        }
        return a.textLength > b.textLength ? a : b
      })

      console.log(`🎯 [OCR-ORIENTAÇÃO] Melhor rotação: ${best.rotation}° (${best.textLength} chars | ${best.wordCount} palavras)`)

      // Mostrar preview do texto extraído
      if (best.text.length > 0) {
        const preview = best.text.substring(0, 100).replace(/\n/g, ' ')
        console.log(`📝 [OCR-ORIENTAÇÃO] Preview: "${preview}..."`)
      }

      return best.rotation

    } catch (error) {
      console.error('❌ [OCR-ORIENTAÇÃO] Erro ao detectar com OCR:', error)
      console.warn('⚠️ [OCR-ORIENTAÇÃO] Usando rotação padrão: 0° (sem rotação)')
      return 0 // Fallback: manter orientação original
    }
  }

  private async saveSinglePDF(
    pdfBuffer: Buffer,
    category: CategoryInfo,
    documentNumber: number,
    originalDocument: DocumentToProcess,
    partNumber?: number
  ): Promise<ConversionResult> {
    try {
      // ✅ CORREÇÃO: Gerar ID único para TODOS os documentos
      const { v4: uuidv4 } = await import('uuid')
      const uniqueId = uuidv4().substring(0, 8)
      
      let filename: string
      
      if (partNumber) {
        // Documentos divididos em partes
        filename = `${category.code} Parte ${partNumber} ${uniqueId}.pdf`
      } else {
        // ✅ TODOS os documentos agora têm ID único
        filename = `${category.code} ${uniqueId}.pdf`
      }

      // Sanitizar filename para evitar problemas no storage
      const sanitizedFilename = this.sanitizeFilename(filename)

      console.log('📤 Salvando PDF:', filename, '→', sanitizedFilename)

      // Upload usando storage-service
      const storagePath = `processed/${sanitizedFilename}`

      // Criar um objeto File a partir do Buffer para upload
      const file = new File([pdfBuffer], sanitizedFilename, { type: 'application/pdf' })
      await uploadFile(file, storagePath)

      // Gerar URL pública (Local ou Supabase)
      let publicURL: string
      if (process.env.UPLOAD_DIR && process.env.NEXT_PUBLIC_UPLOAD_URL) {
        // Storage Local
        publicURL = `${process.env.NEXT_PUBLIC_UPLOAD_URL}/${storagePath}`
      } else if (process.env.NEXT_PUBLIC_SUPABASE_URL && process.env.SUPABASE_BUCKET_NAME) {
        // Storage Supabase (fallback)
        publicURL = `${process.env.NEXT_PUBLIC_SUPABASE_URL}/storage/v1/object/public/${process.env.SUPABASE_BUCKET_NAME}/${storagePath}`
      } else {
        throw new Error('Configuração de storage não encontrada')
      }

      // ✅ CORREÇÃO: Gerar nome inteligente baseado na análise IA
      const smartFilename = this.generateSmartFilename(
        category,
        originalDocument.filename,
        originalDocument.analysis,
        originalDocument.ocrText
      )

      console.log('📦 ===== RETORNANDO RESULTADO =====')
      console.log('   OCR Text:', originalDocument.ocrText ? originalDocument.ocrText.length + ' chars' : 'VAZIO')
      console.log('   Smart Filename:', smartFilename || filename)
      console.log('   Categoria:', category.name)

      // ✅ Calcular nível de qualidade do OCR
      const ocrQuality = originalDocument.ocrQualityMetrics
      const qualityLevel: 'excellent' | 'good' | 'poor' | 'failed' =
        !ocrQuality || ocrQuality.confidence === 0 ? 'failed' :
        ocrQuality.confidence >= 90 ? 'excellent' :
        ocrQuality.confidence >= 70 ? 'good' : 'poor'

      return {
        success: true,
        pdfPath: publicURL,
        pdfBuffer,
        ocrText: originalDocument.ocrText || '',
        ocrConfidence: ocrQuality?.confidence || 0,
        ocrCharactersExtracted: ocrQuality?.charactersExtracted || 0,
        ocrPagesProcessed: ocrQuality?.pagesProcessed || 1,
        ocrQualityLevel: qualityLevel,
        pageCount: 1,
        finalSizeBytes: pdfBuffer.length,
        smartFilename: smartFilename || filename, // Fallback para o filename técnico
        documentAnalysis: originalDocument.analysis,
        categoryInfo: category
      }
    } catch (error) {
      console.error('❌ Erro ao salvar PDF:', error)
      throw error
    }
  }

  // ==================== UTILITÁRIOS ====================

  private generateSmartFilename(
    category: CategoryInfo,
    originalFilename: string,
    analysis?: DocumentAnalysis,
    ocrText?: string
  ): string {
    try {
      const baseName = originalFilename.replace(/\.[^/.]+$/, '') // Remove extensão

      // Para documentos pessoais, extrair informações específicas
      if (category.code.includes('RG') && ocrText) {
        const nome = this.extractNomeFromRG(ocrText)
        if (nome) return `RG_${nome.replace(/\s+/g, '_')}.pdf`
      }

      if (category.code.includes('CNH') && ocrText) {
        const nome = this.extractNomeFromCNH(ocrText)
        if (nome) return `CNH_${nome.replace(/\s+/g, '_')}.pdf`
      }

      if (category.code.includes('CPF') && ocrText) {
        const nome = this.extractNomeFromCPF(ocrText)
        if (nome) return `CPF_${nome.replace(/\s+/g, '_')}.pdf`
      }

      // Para contratos, extrair partes envolvidas
      if (category.code.includes('Contratos') && ocrText) {
        const partes = this.extractContractParties(ocrText)
        if (partes) return `Contrato_${partes.replace(/\s+/g, '_')}.pdf`
      }

      // ✅ NOVO: Para "Outros Documentos" (categoria 07+), usar o tipo identificado pela IA
      if (category.code.startsWith('07')) {
        // Se a IA identificou um tipo específico, usar ele
        if (category.name && category.name !== 'Outros Documentos') {
          console.log('✅ Usando nome identificado pela IA:', category.name)
          return `${category.code}.pdf` // Ex: "07 ASO.pdf"
        }
      }

      // Fallback: usar categoria + nome original limpo
      const categoryShort = category.name.replace(/\s+/g, '_')
      return `${categoryShort}_${baseName.replace(/[^a-zA-Z0-9]/g, '_')}.pdf`

    } catch (error) {
      console.warn('⚠️ Erro ao gerar nome inteligente:', error)
      return `${category.name.replace(/\s+/g, '_')}_documento.pdf`
    }
  }

  private extractNomeFromRG(text: string): string | null {
    // Procurar por padrões comuns em RGs
    const patterns = [
      /NOME[:\s]+([A-ZÁÇÕÃÍÚÂÊÔÀÈÌÒÙ\s]{2,50})/i,
      /^([A-ZÁÇÕÃÍÚÂÊÔÀÈÌÒÙ\s]{10,50})$/m,
      /FILIAÇÃO.*?\n([A-ZÁÇÕÃÍÚÂÊÔÀÈÌÒÙ\s]{5,50})/i
    ]

    for (const pattern of patterns) {
      const match = text.match(pattern)
      if (match?.[1]) {
        return match[1].trim().split(/\s+/).slice(0, 3).join('_') // Primeiros 3 nomes
      }
    }
    return null
  }

  private extractNomeFromCNH(text: string): string | null {
    // Procurar por padrões comuns em CNHs
    const patterns = [
      /NOME[:\s]+([A-ZÁÇÕÃÍÚÂÊÔÀÈÌÒÙ\s]{2,50})/i,
      /^([A-ZÁÇÕÃÍÚÂÊÔÀÈÌÒÙ\s]{10,50})$/m
    ]

    for (const pattern of patterns) {
      const match = text.match(pattern)
      if (match?.[1]) {
        return match[1].trim().split(/\s+/).slice(0, 3).join('_')
      }
    }
    return null
  }

  private extractNomeFromCPF(text: string): string | null {
    // Procurar por nome antes ou depois do número do CPF
    const patterns = [
      /NOME[:\s]+([A-ZÁÇÕÃÍÚÂÊÔÀÈÌÒÙ\s]{2,50})/i,
      /([A-ZÁÇÕÃÍÚÂÊÔÀÈÌÒÙ\s]{5,50})\s+CPF/i,
      /^([A-ZÁÇÕÃÍÚÂÊÔÀÈÌÒÙ\s]{10,50})$/m
    ]

    for (const pattern of patterns) {
      const match = text.match(pattern)
      if (match?.[1]) {
        return match[1].trim().split(/\s+/).slice(0, 3).join('_')
      }
    }
    return null
  }

  private extractContractParties(text: string): string | null {
    // Procurar por partes em contratos
    const patterns = [
      /CONTRATO.*?entre\s+([A-ZÁÇÕÃÍÚÂÊÔÀÈÌÒÙ\s]{3,30})\s+e\s+([A-ZÁÇÕÃÍÚÂÊÔÀÈÌÒÙ\s]{3,30})/i,
      /CONTRATANTE[:\s]+([A-ZÁÇÕÃÍÚÂÊÔÀÈÌÒÙ\s]{3,30})/i,
      /CONTRATADO[:\s]+([A-ZÁÇÕÃÍÚÂÊÔÀÈÌÒÙ\s]{3,30})/i
    ]

    for (const pattern of patterns) {
      const match = text.match(pattern)
      if (match?.[1]) {
        if (match[2]) {
          return `${match[1].trim()}_e_${match[2].trim()}`
        }
        return match[1].trim().split(/\s+/).slice(0, 2).join('_')
      }
    }
    return null
  }

  private needsDivision(buffer: Buffer): boolean {
    const fileSizeMB = buffer.length / (1024 * 1024)
    return fileSizeMB > this.systemRequirements.maxSizeMB
  }

  private async dividePDFIntoChunks(pdfDoc: PDFDocument): Promise<Buffer[]> {
    const chunks: Buffer[] = []
    const pageCount = pdfDoc.getPageCount()
    const pagesPerChunk = Math.max(1, Math.floor(pageCount / 2)) 
    
    for (let i = 0; i < pageCount; i += pagesPerChunk) {
      const chunkDoc = await PDFDocument.create()
      const endPage = Math.min(i + pagesPerChunk, pageCount)
      
      // Copiar páginas para o chunk
      for (let pageIndex = i; pageIndex < endPage; pageIndex++) {
        const [copiedPage] = await chunkDoc.copyPages(pdfDoc, [pageIndex])
        chunkDoc.addPage(copiedPage)
      }
      
      const chunkBytes = await chunkDoc.save()
      chunks.push(Buffer.from(chunkBytes))
    }
    
    console.log(`✅ PDF dividido em ${chunks.length} partes`)
    return chunks
  }

  // ==================== VALIDAÇÃO ====================

  private async validatePDF(pdfBuffer: Buffer): Promise<{ valid: boolean; errors: string[] }> {
    const errors: string[] = []
    
    try {
      const fileSizeMB = pdfBuffer.length / (1024 * 1024)
      
      if (fileSizeMB > this.systemRequirements.maxSizeMB) {
        errors.push(`PDF muito grande: ${fileSizeMB.toFixed(2)}MB (máx: ${this.systemRequirements.maxSizeMB}MB)`)
      }
      
      // Validar se é PDF válido
      try {
        await PDFDocument.load(pdfBuffer, { ignoreEncryption: true })
      } catch {
        errors.push('PDF gerado está corrompido')
      }
      
    } catch (error) {
      errors.push(`Erro na validação: ${error instanceof Error ? error.message : 'Erro desconhecido'}`)
    }

    return {
      valid: errors.length === 0,
      errors
    }
  }

  private sanitizeFilename(filename: string): string {
    return filename
      .normalize('NFD')
      .replace(/[\u0300-\u036f]/g, '') // Remove acentos
      .replace(/[^a-zA-Z0-9.\s-]/g, '_') // Permite espaços, hífen e ponto
      .replace(/\s+/g, '_') // Substitui espaços por underscore
      .replace(/_+/g, '_') // Remove underscores consecutivos
      .replace(/^_+|_+$/g, '') // Remove underscores das pontas
      .slice(0, 150) // Aumenta limite para nomes mais longos
  }

  private formatFileSize(bytes: number): string {
    if (bytes === 0) return '0 B'
    const k = 1024
    const sizes = ['B', 'KB', 'MB', 'GB']
    const i = Math.floor(Math.log(bytes) / Math.log(k))
    return `${parseFloat((bytes / Math.pow(k, i)).toFixed(2))} ${sizes[i]}`
  }

  // ==================== MÉTODOS PÚBLICOS AUXILIARES ====================

  /**
   * Validar requisitos de PDF para o sistema
   */
  async validatePDFRequirements(pdfBuffer: Buffer): Promise<{ valid: boolean, errors: string[] }> {
    return this.validatePDF(pdfBuffer)
  }

  /**
   * Obter configurações do sistema
   */
  getSystemRequirements() {
    return { ...this.systemRequirements }
  }

  /**
   * Método estático para criar instância inicializada
   */
  static async create(systemName: string, organizationId?: number): Promise<PDFConverter> {
    const converter = new PDFConverter(systemName)
    await converter.init(organizationId)
    return converter
  }
}