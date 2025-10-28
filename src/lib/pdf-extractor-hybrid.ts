export interface ExtractResult {
  text: string
  fileBase64: string
  method: 'pdf-parse' | 'elysium' | 'elysium-batched' | 'pdfjs' | 'fallback'
  confidence: 'high' | 'medium' | 'low'
  metadata?: {
    pages?: number
    fileSize?: number
    processingTime?: number
    batches?: number
    processedPages?: number
  }
}

export class HybridPDFExtractor {
  private elysiumApiUrl = 'https://ocr.elysiumsistemas.com.br/api/upload'
  private elysiumPassword = 'elysiumocr2025'

  /**
   * Método principal: extrai texto usando estratégia híbrida
   */
  async extractText(buffer: Buffer, mimeType: string): Promise<ExtractResult> {
    const startTime = Date.now()

    try {
      console.log('🔍 [HYBRID] Iniciando extração híbrida:', {
        mimeType,
        size: this.formatFileSize(buffer.length)
      })

      // ESTRATÉGIA 1: Para PDFs, tentar extrair texto localmente primeiro
      if (mimeType === 'application/pdf') {
        const pdfParseResult = await this.extractWithPdfParse(buffer)

        const totalPages = pdfParseResult.pages || 1
        const minCharsPerPage = 30 // Se tiver menos que isso por página, considera OCR
        const avgCharsPerPage = pdfParseResult.text.length / totalPages

        if (pdfParseResult.text.length > 500 && avgCharsPerPage >= minCharsPerPage) {
          const processingTime = Date.now() - startTime
          console.log('✅ [HYBRID] pdf-parse bem-sucedido:', {
            caracteres: pdfParseResult.text.length,
            tempo: `${processingTime}ms`
          })

          return {
            text: pdfParseResult.text,
            fileBase64: buffer.toString('base64'),
            method: 'pdf-parse',
            confidence: 'high',
            metadata: {
              pages: pdfParseResult.pages,
              fileSize: buffer.length,
              processingTime
            }
          }
        }

        console.log(
          `⚠️ [HYBRID] pdf-parse retornou pouco texto (${pdfParseResult.text.length} caracteres, ${avgCharsPerPage.toFixed(
            2
          )} caracteres/página). Tentando Elysium OCR...`
        )
      }

      // ESTRATÉGIA 2: Para DOCX, PDFs complexos ou fallback
      const elysiumResult = await this.extractWithElysium(buffer)
      const processingTime = Date.now() - startTime

      if (elysiumResult.text.length > 0) {
        console.log('✅ [HYBRID] Elysium bem-sucedido:', {
          caracteres: elysiumResult.text.length,
          tempo: `${processingTime}ms`
        })

        return {
          text: elysiumResult.text,
          fileBase64: elysiumResult.fileBase64,
          method: 'elysium',
          confidence: 'high',
          metadata: {
            fileSize: buffer.length,
            processingTime
          }
        }
      }

      // Fallback: retornar vazio
      console.warn('⚠️ [HYBRID] Nenhum método conseguiu extrair texto')
      return {
        text: '',
        fileBase64: buffer.toString('base64'),
        method: 'fallback',
        confidence: 'low',
        metadata: {
          fileSize: buffer.length,
          processingTime
        }
      }

    } catch (error) {
      console.error('❌ [HYBRID] Erro na extração:', error)
      return {
        text: '',
        fileBase64: buffer.toString('base64'),
        method: 'fallback',
        confidence: 'low'
      }
    }
  }

  /**
   * Extrai texto de PDF usando pdf-parse
   */
  private async extractWithPdfParse(buffer: Buffer): Promise<{ text: string, pages: number }> {
    try {
      console.log('📄 [pdf-parse] Extraindo texto do PDF...')

      const pdfParse = (await import('pdf-parse')).default
      const data = await pdfParse(buffer, { max: 0, version: 'default' })

      if (data.text && data.text.length > 0) {
        const cleanText = data.text.replace(/[ \t]+/g, ' ').replace(/\n{3,}/g, '\n\n').trim()
        console.log('✅ [pdf-parse] Texto extraído:', {
          páginas: data.numpages,
          caracteres: cleanText.length,
          linhas: cleanText.split('\n').length,
          preview: cleanText.substring(0, 150) + '...'
        })
        return { text: cleanText, pages: data.numpages || 1 }
      }
      return { text: '', pages: 0 }

    } catch (error) {
      console.warn('⚠️ [pdf-parse] Falhou:', error)
      return { text: '', pages: 0 }
    }
  }

  /**
   * Extrai texto usando API Elysium OCR
   */
  private async extractWithElysium(buffer: Buffer): Promise<{ text: string, fileBase64: string }> {
    try {
      console.log('🌐 [Elysium] Chamando API OCR...')
      const base64File = buffer.toString('base64')
      const response = await fetch(this.elysiumApiUrl, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ password: this.elysiumPassword, file: base64File }, null, 2)
      })
      const data = await response.json()

      if (data.success && data.text && typeof data.text === 'string') {
        const extractedText = data.text.replace(/[ \t]+/g, ' ').replace(/\n{3,}/g, '\n\n').trim()
        console.log('✅ [Elysium] Texto extraído:', {
          caracteres: extractedText.length,
          linhas: extractedText.split('\n').length,
          preview: extractedText.substring(0, 150) + '...'
        })
        return { text: extractedText, fileBase64: data.pdf || base64File }
      }
      console.warn('⚠️ [Elysium] API não retornou texto válido')
      return { text: '', fileBase64: base64File }

    } catch (error) {
      console.error('❌ [Elysium] Erro na API:', error)
      return { text: '', fileBase64: buffer.toString('base64') }
    }
  }

  /**
   * Compara os métodos pdf-parse e Elysium
   */
  async compareExtractionMethods(buffer: Buffer, mimeType: string): Promise<{
    pdfParse: { text: string, length: number, time: number }
    elysium: { text: string, length: number, time: number }
    recommendation: 'pdf-parse' | 'elysium' | 'both-similar'
  }> {
    console.log('🔬 [TESTE] Comparando métodos de extração...')
    const pdfParseStart = Date.now()
    const pdfParseResult = mimeType === 'application/pdf'
      ? await this.extractWithPdfParse(buffer)
      : { text: '', pages: 0 }
    const pdfParseTime = Date.now() - pdfParseStart

    const elysiumStart = Date.now()
    const elysiumResult = await this.extractWithElysium(buffer)
    const elysiumTime = Date.now() - elysiumStart

    const pdfParseLength = pdfParseResult.text.length
    const elysiumLength = elysiumResult.text.length

    let recommendation: 'pdf-parse' | 'elysium' | 'both-similar' = 'both-similar'
    if (pdfParseLength > elysiumLength * 1.2) recommendation = 'pdf-parse'
    else if (elysiumLength > pdfParseLength * 1.2) recommendation = 'elysium'

    console.log('📊 [TESTE] Resultados da comparação:', {
      pdfParse: { caracteres: pdfParseLength, tempo: `${pdfParseTime}ms` },
      elysium: { caracteres: elysiumLength, tempo: `${elysiumTime}ms` },
      recomendação: recommendation
    })

    return {
      pdfParse: { text: pdfParseResult.text, length: pdfParseLength, time: pdfParseTime },
      elysium: { text: elysiumResult.text, length: elysiumLength, time: elysiumTime },
      recommendation
    }
  }

  /**
   * Processa PDFs grandes em lotes
   */
  async extractTextInBatches(
    buffer: Buffer,
    options: { pagesPerBatch?: number; maxBatches?: number; startPage?: number } = {}
  ): Promise<ExtractResult> {
    const startTime = Date.now()
    const pagesPerBatch = options.pagesPerBatch || 10
    const maxBatches = options.maxBatches
    const startPage = options.startPage || 1

    try {
      console.log('📦 [BATCHED] Iniciando processamento em lotes...')
      const { PDFDocument } = await import('pdf-lib')
      const pdfDoc = await PDFDocument.load(buffer, { ignoreEncryption: true })
      const totalPages = pdfDoc.getPageCount()

      if (totalPages === 0)
        return { text: '', fileBase64: buffer.toString('base64'), method: 'fallback', confidence: 'low', metadata: { pages: 0, fileSize: buffer.length, processingTime: Date.now() - startTime } }

      const extractedTexts: string[] = []
      let processedPages = 0
      let batchCount = 0

      for (let i = startPage - 1; i < totalPages; i += pagesPerBatch) {
        if (maxBatches && batchCount >= maxBatches) break
        const endPage = Math.min(i + pagesPerBatch, totalPages)
        batchCount++

        const batchPdf = await PDFDocument.create()
        const pageIndices = Array.from({ length: endPage - i }, (_, idx) => i + idx)
        const copiedPages = await batchPdf.copyPages(pdfDoc, pageIndices)
        copiedPages.forEach(page => batchPdf.addPage(page))
        const batchBytes = await batchPdf.save()
        const batchBuffer = Buffer.from(batchBytes)

        const batchResult = await this.extractWithElysium(batchBuffer)
        if (batchResult.text.length > 0) {
          extractedTexts.push(batchResult.text)
          processedPages += pageIndices.length
        }
        await new Promise(resolve => setTimeout(resolve, 500)) // evita sobrecarga
      }

      const fullText = extractedTexts.join(' ')
      const processingTime = Date.now() - startTime

      return {
        text: fullText,
        fileBase64: '',
        method: 'elysium-batched',
        confidence: fullText.length > 100 ? 'high' : 'low',
        metadata: { pages: totalPages, processedPages, batches: batchCount, fileSize: buffer.length, processingTime }
      }

    } catch (error) {
      console.error('❌ [BATCHED] Erro no processamento em lotes:', error)
      return { text: '', fileBase64: '', method: 'fallback', confidence: 'low', metadata: { fileSize: buffer.length, processingTime: Date.now() - startTime } }
    }
  }

  /**
   * Formata tamanho de arquivo
   */
  private formatFileSize(bytes: number): string {
    if (bytes === 0) return '0 B'
    const k = 1024
    const sizes = ['B', 'KB', 'MB', 'GB']
    const i = Math.floor(Math.log(bytes) / Math.log(k))
    return `${parseFloat((bytes / Math.pow(k, i)).toFixed(2))} ${sizes[i]}`
  }
}
