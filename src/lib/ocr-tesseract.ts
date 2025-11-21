/**
 * OCR com estratégia inteligente
 * 1. Google Cloud Vision API (se disponível) - Melhor qualidade para documentos jurídicos
 * 2. Tesseract OCR local (fallback gratuito) - Mais estável que tesseract.js
 * Prioriza Google Vision para máxima precisão em documentos escaneados
 */

import tesseract from 'node-tesseract-ocr'
import pdfParse from 'pdf-parse'
import sharp from 'sharp'
import fs from 'fs'
import os from 'os'
import path from 'path'
import { exec } from 'child_process'
import { promisify } from 'util'
import { GoogleVisionOCR } from './google-vision-ocr'

const execAsync = promisify(exec)

export interface OCRWord {
  text: string
  x: number
  y: number
  width: number
  height: number
  confidence: number
}

export interface OCRResult {
  text: string
  confidence: number
  processingTime: number
  words?: OCRWord[]
}

export class TesseractOCR {
  /**
   * Extrair texto de uma imagem usando estratégia inteligente:
   * 1. Google Vision (se disponível) - Melhor para docs jurídicos
   * 2. Tesseract (fallback) - Gratuito mas menos preciso
   */
  static async extractFromImage(buffer: Buffer): Promise<OCRResult> {
    const startTime = Date.now()

    // 🎯 ESTRATÉGIA: Google Vision primeiro (se disponível)
    if (GoogleVisionOCR.isAvailable()) {
      console.log('🌟 [Estratégia] Google Vision disponível - usando como primário')

      try {
        const googleResult = await GoogleVisionOCR.extractFromImage(buffer)

        // Se Google Vision teve sucesso razoável, usar o resultado
        if (googleResult.text.length > 10 && googleResult.confidence >= 50) {
          console.log('✅ [Estratégia] Google Vision bem-sucedido - usando resultado')
          return googleResult
        }

        // Se Google Vision falhou, tentar Tesseract como fallback
        console.log('⚠️ [Estratégia] Google Vision com resultado fraco - tentando Tesseract como fallback')
        return await this.extractWithTesseract(buffer, startTime)

      } catch (error) {
        console.error('❌ [Estratégia] Google Vision falhou - usando Tesseract', error)
        return await this.extractWithTesseract(buffer, startTime)
      }
    }

    // Se Google Vision não está disponível, usar Tesseract
    console.log('ℹ️ [Estratégia] Google Vision não configurado - usando Tesseract')
    return await this.extractWithTesseract(buffer, startTime)
  }

  /**
   * Extrair texto usando Tesseract (método original)
   */
  private static async extractWithTesseract(buffer: Buffer, startTime: number): Promise<OCRResult> {
    try {
      console.log('🔍 ===== TESSERACT NODE OCR =====')
      console.log('   Tamanho do buffer:', buffer.length, 'bytes')

      // Pré-processar imagem
      const processedBuffer = await this.preprocessImage(buffer)
      console.log('   Imagem processada:', processedBuffer.length, 'bytes')

      // Salvar temporariamente (node-tesseract-ocr precisa de arquivo)
      const tmpDir = await fs.promises.mkdtemp(path.join(os.tmpdir(), 'ocr-'))
      const tmpFile = path.join(tmpDir, 'image.png')
      await fs.promises.writeFile(tmpFile, processedBuffer)
      console.log('   Arquivo temporário:', tmpFile)

      // Executar OCR
      // Configurar PATH manualmente para esta execução
      process.env.PATH = `C:\\Program Files\\Tesseract-OCR;${process.env.PATH}`

      // ✅ Configuração OTIMIZADA para documentos escaneados/formulários
      const config = {
        lang: 'por+eng',
        oem: 1,  // LSTM only (melhor para texto)
        psm: 6,  // Uniform block of text (melhor para documentos estruturados)
      }

      console.log('   Config OCR:', config)
      console.log('   Executando Tesseract...')

      // Extrair texto
      const text = await tesseract.recognize(tmpFile, config)

      // Extrair coordenadas das palavras usando TSV
      const tsvFile = path.join(tmpDir, 'output.tsv')
      const tesseractCmd = `tesseract "${tmpFile}" "${tsvFile.replace('.tsv', '')}" -l por+eng --oem 1 --psm 6 tsv`

      try {
        await execAsync(tesseractCmd, { env: { ...process.env, PATH: `C:\\Program Files\\Tesseract-OCR;${process.env.PATH}` } })

        const tsvContent = await fs.promises.readFile(tsvFile, 'utf-8')
        const words = this.parseTSV(tsvContent)

        console.log(`📍 [Tesseract] Coordenadas extraídas: ${words.length} palavras`)

        await fs.promises.rm(tmpDir, { recursive: true, force: true })

        const processingTime = Date.now() - startTime
        return {
          text: text ? text.trim() : '',
          confidence: text && text.length > 0 ? 85 : 0,
          processingTime,
          words
        }

      } catch (tsvError) {
        console.warn('⚠️ Erro ao extrair coordenadas, retornando só texto:', tsvError)

        await fs.promises.rm(tmpDir, { recursive: true, force: true })

        const processingTime = Date.now() - startTime
        return {
          text: text ? text.trim() : '',
          confidence: text && text.length > 0 ? 85 : 0,
          processingTime
        }
      }

    } catch (error) {
      console.error('❌ ===== ERRO NO TESSERACT =====')
      console.error('   Erro:', error)
      console.error('   Stack:', error instanceof Error ? error.stack : 'N/A')

      return {
        text: '',
        confidence: 0,
        processingTime: Date.now() - startTime
      }
    }
  }

  /**
   * Parsear TSV do Tesseract para extrair coordenadas das palavras
   */
  private static parseTSV(tsvContent: string): OCRWord[] {
    const lines = tsvContent.split('\n').slice(1) // Pular header
    const words: OCRWord[] = []

    for (const line of lines) {
      const cols = line.split('\t')

      if (cols.length < 12) continue

      const level = parseInt(cols[0])
      const text = cols[11]?.trim()
      const conf = parseFloat(cols[10])

      // Level 5 = palavra
      if (level === 5 && text && conf > 0) {
        words.push({
          text,
          x: parseInt(cols[6]),
          y: parseInt(cols[7]),
          width: parseInt(cols[8]),
          height: parseInt(cols[9]),
          confidence: conf
        })
      }
    }

    return words
  }

  /**
   * Pré-processar imagem para melhorar OCR
   */
  private static async preprocessImage(buffer: Buffer): Promise<Buffer> {
    try {
      console.log('🖼️  [Tesseract] Pré-processando imagem...')

      const metadata = await sharp(buffer).metadata()

      if (!metadata.format || !['jpeg', 'png', 'webp', 'tiff', 'gif'].includes(metadata.format)) {
        console.warn(`⚠️ [Tesseract] Formato não suportado: ${metadata.format}`)
        return buffer
      }

      // ✅ Pré-processamento AGRESSIVO para documentos escaneados/fotografados
      console.log(`   📐 Resolução original: ${metadata.width}x${metadata.height}`)

      let pipeline = sharp(buffer)

      // Redimensionar para resolução ideal (se necessário)
      if (metadata.width && metadata.width < 2000) {
        console.log(`   📏 Aumentando resolução para melhor OCR...`)
        pipeline = pipeline.resize({
          width: 2400,
          fit: 'inside',
          withoutEnlargement: true
        })
      }

      const processed = await pipeline
        // 1. Converter para escala de cinza
        .grayscale()

        // 2. Aumentar contraste DRASTICAMENTE
        .linear(1.5, -(128 * 0.5)) // gamma correction para aumentar contraste

        // 3. Normalizar para usar todo range de tons
        .normalize()

        // 4. Sharpen agressivo para definir bordas de texto
        .sharpen({ sigma: 2.0 })

        // 5. Binarização com threshold adaptativo (conversão preto/branco)
        .threshold(128, { grayscale: false })

        // 6. Converter para PNG de máxima qualidade
        .png({ quality: 100, compressionLevel: 0 })
        .toBuffer()

      console.log('✅ [Tesseract] Imagem processada com pipeline agressivo')
      return processed

    } catch (error) {
      console.warn('⚠️ [Tesseract] Erro no pré-processamento:', error)
      return buffer
    }
  }

  /**
   * Extrair texto usando Ghostscript + OCR (para PDFs corrompidos/escaneados)
   */
  private static async extractWithGhostscriptOCR(buffer: Buffer): Promise<OCRResult> {
    const startTime = Date.now()

    try {
      console.log('📄 [GS-OCR] Convertendo PDF para imagens com Ghostscript...')

      const tmpDir = await fs.promises.mkdtemp(path.join(os.tmpdir(), 'pdf-gs-ocr-'))
      const pdfPath = path.join(tmpDir, 'input.pdf')
      const outputPattern = path.join(tmpDir, 'page-%d.png')

      await fs.promises.writeFile(pdfPath, buffer)

      // Converter TODAS as páginas de uma vez com Ghostscript (alta resolução)
      const gsPath = '"C:\\Program Files\\gs\\gs10.06.0\\bin\\gswin64c.exe"'
      const gsCmd = `${gsPath} -dSAFER -dBATCH -dNOPAUSE -sDEVICE=png16m -r300 -sOutputFile="${outputPattern}" "${pdfPath}"`

      console.log('🔄 Executando Ghostscript...')
      await execAsync(gsCmd, { timeout: 120000 })

      // Ler todas as imagens geradas
      const files = await fs.promises.readdir(tmpDir)
      const imageFiles = files.filter(f => f.startsWith('page-') && f.endsWith('.png')).sort()

      console.log(`📸 ${imageFiles.length} páginas convertidas`)

      let allText = ''
      let totalConfidence = 0
      let pagesProcessed = 0

      // Processar cada página com OCR
      for (let i = 0; i < imageFiles.length; i++) {
        const imgPath = path.join(tmpDir, imageFiles[i])
        const imgBuffer = await fs.promises.readFile(imgPath)

        console.log(`📄 [Página ${i + 1}/${imageFiles.length}] Executando OCR...`)

        try {
          const pageResult = await this.extractFromImage(imgBuffer)

          if (pageResult.text.length > 10) {
            allText += pageResult.text + '\n'
            totalConfidence += pageResult.confidence
            pagesProcessed++
            console.log(`   ✅ ${pageResult.text.length} caracteres (${pageResult.confidence}% confiança)`)
          } else {
            console.log(`   ⚠️ Pouco texto extraído (${pageResult.text.length} chars)`)
          }
        } catch (ocrError) {
          console.error(`   ❌ Erro no OCR da página ${i + 1}:`, ocrError)
        }
      }

      await fs.promises.rm(tmpDir, { recursive: true, force: true })

      const avgConfidence = pagesProcessed > 0 ? totalConfidence / pagesProcessed : 0
      const processingTime = Date.now() - startTime

      console.log(`✅ [GS-OCR] ${allText.length} caracteres de ${pagesProcessed}/${imageFiles.length} páginas`)

      return {
        text: allText.trim(),
        confidence: avgConfidence,
        processingTime
      }
    } catch (error) {
      console.error('❌ [GS-OCR] Erro:', error)
      return {
        text: '',
        confidence: 0,
        processingTime: Date.now() - startTime
      }
    }
  }

  /**
   * Extrair texto nativo de PDF usando pdf-parse
   */
  static async extractFromPDF(buffer: Buffer): Promise<OCRResult> {
    const startTime = Date.now()

    try {
      console.log('📄 [PDF-Parse] Processando PDF...')

      const data = await pdfParse(buffer, {
        max: 100,
        pagerender: (pageData: any) => {
          return pageData.getTextContent({
            normalizeWhitespace: true,
            disableCombineTextItems: false
          }).then((textContent: any) => {
            const items = textContent.items

            // Detectar colunas analisando distribuição horizontal
            const xPositions = items.map((item: any) => item.transform[4])
            const minX = Math.min(...xPositions)
            const maxX = Math.max(...xPositions)
            const pageWidth = maxX - minX

            // Agrupar items por linha (mesma posição Y)
            const lines: Map<number, any[]> = new Map()

            for (const item of items) {
              const y = Math.round(item.transform[5])
              if (!lines.has(y)) {
                lines.set(y, [])
              }
              lines.get(y)!.push(item)
            }

            // Detectar se há múltiplas colunas
            let hasMultipleColumns = false
            const columnGapThreshold = pageWidth * 0.15 // 15% da largura da página

            for (const lineItems of lines.values()) {
              if (lineItems.length > 1) {
                lineItems.sort((a: any, b: any) => a.transform[4] - b.transform[4])
                for (let i = 1; i < lineItems.length; i++) {
                  const gap = lineItems[i].transform[4] - (lineItems[i-1].transform[4] + (lineItems[i-1].width || 0))
                  if (gap > columnGapThreshold) {
                    hasMultipleColumns = true
                    break
                  }
                }
              }
              if (hasMultipleColumns) break
            }

            let text = ''

            if (hasMultipleColumns) {
              // Detectar limites das colunas
              const leftColumnMax = minX + pageWidth * 0.45
              const rightColumnMin = minX + pageWidth * 0.55

              const leftColumn: any[] = []
              const rightColumn: any[] = []
              const fullWidth: any[] = []

              for (const item of items) {
                const x = item.transform[4]
                const itemWidth = item.width || 0

                if (x + itemWidth < rightColumnMin && x < leftColumnMax) {
                  leftColumn.push(item)
                } else if (x > rightColumnMin) {
                  rightColumn.push(item)
                } else {
                  fullWidth.push(item)
                }
              }

              // Ordenar cada coluna por Y (topo para baixo) e depois X
              const sortByYX = (a: any, b: any) => {
                const yDiff = Math.abs(a.transform[5] - b.transform[5])
                if (yDiff < 5) return a.transform[4] - b.transform[4]
                return b.transform[5] - a.transform[5]
              }

              fullWidth.sort(sortByYX)
              leftColumn.sort(sortByYX)
              rightColumn.sort(sortByYX)

              // Concatenar: largura total, coluna esquerda, coluna direita
              for (const item of fullWidth) {
                if (item.str) text += item.str + ' '
              }
              for (const item of leftColumn) {
                if (item.str) text += item.str + ' '
              }
              for (const item of rightColumn) {
                if (item.str) text += item.str + ' '
              }

            } else {
              // Documento de coluna única - ordenação simples
              const sortedItems = items.sort((a: any, b: any) => {
                const yDiff = Math.abs(a.transform[5] - b.transform[5])
                if (yDiff < 5) return a.transform[4] - b.transform[4]
                return b.transform[5] - a.transform[5]
              })

              for (const item of sortedItems) {
                if (item.str) text += item.str + ' '
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
        console.log(`✅ [PDF-Parse] Texto extraído: ${cleanedText.length} caracteres`)

        // Verificar qualidade do texto extraído
        const alphanumericCount = (cleanedText.match(/[a-zA-Z0-9À-ÿ]/g) || []).length
        const alphanumericRatio = alphanumericCount / cleanedText.length

        // Se menos de 60% do texto são caracteres alfanuméricos, provavelmente está corrompido
        if (alphanumericRatio < 0.6) {
          console.warn(`⚠️ [PDF-Parse] Texto parece corrompido (${(alphanumericRatio * 100).toFixed(1)}% alfanumérico)`)
          console.warn(`   Preview: ${cleanedText.substring(0, 100)}`)
          console.log(`   💡 Fazendo fallback para OCR com Ghostscript...`)

          // Fazer OCR nas páginas renderizadas
          return await this.extractWithGhostscriptOCR(buffer)
        }

        const wordCount = cleanedText.split(/\s+/).length
        const avgWordLength = cleanedText.length / wordCount

        if (avgWordLength < 3 && wordCount < 50) {
          console.warn(`⚠️ [PDF-Parse] Texto suspeito (apenas rodapé?)`)
          return {
            text: cleanedText,
            confidence: 40,
            processingTime
          }
        }

        return {
          text: cleanedText,
          confidence: 95,
          processingTime
        }
      } else {
        console.warn(`⚠️ [PDF-Parse] PDF sem texto extraível`)
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
}
