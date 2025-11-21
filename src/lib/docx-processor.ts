/**
 * Processador de Documentos DOCX/DOC
 * Extrai texto e converte para PDF usando Mammoth
 */

import mammoth from 'mammoth'
import { PDFDocument, StandardFonts, rgb } from 'pdf-lib'

export interface DOCXResult {
  text: string
  html: string
  wordCount: number
  processingTime: number
}

export class DOCXProcessor {
  /**
   * Extrair texto de arquivo DOCX
   */
  static async extractText(buffer: Buffer): Promise<DOCXResult> {
    const startTime = Date.now()

    try {
      console.log('📄 [DOCX] Processando documento Word...')

      // Extrair texto puro
      const textResult = await mammoth.extractRawText({ buffer })
      const text = textResult.value

      // Extrair HTML (para preservar formatação)
      const htmlResult = await mammoth.convertToHtml({ buffer })
      const html = htmlResult.value

      // Contar palavras
      const wordCount = text.split(/\s+/).filter(word => word.length > 0).length

      const processingTime = Date.now() - startTime

      console.log(`✅ [DOCX] Documento processado em ${processingTime}ms`)
      console.log(`📊 [DOCX] ${text.length} caracteres, ${wordCount} palavras`)

      // Mostrar warnings se houver
      if (textResult.messages.length > 0) {
        console.warn('⚠️ [DOCX] Warnings:', textResult.messages)
      }

      return {
        text,
        html,
        wordCount,
        processingTime
      }

    } catch (error) {
      console.error('❌ [DOCX] Erro ao processar documento:', error)
      return {
        text: '',
        html: '',
        wordCount: 0,
        processingTime: Date.now() - startTime
      }
    }
  }

  /**
   * Converter DOCX para PDF mantendo texto pesquisável
   */
  static async convertToPDF(buffer: Buffer): Promise<Buffer> {
    try {
      console.log('📄 [DOCX] Convertendo para PDF...')

      // Extrair texto
      const result = await this.extractText(buffer)

      if (result.text.length === 0) {
        throw new Error('Nenhum texto extraído do documento')
      }

      // Criar PDF
      const pdfDoc = await PDFDocument.create()
      const font = await pdfDoc.embedFont(StandardFonts.Helvetica)

      // Configurações de página A4
      const pageWidth = 595.28 // A4 width in points
      const pageHeight = 841.89 // A4 height in points
      const margin = 50
      const maxWidth = pageWidth - (margin * 2)
      const fontSize = 12
      const lineHeight = fontSize * 1.5

      let currentPage = pdfDoc.addPage([pageWidth, pageHeight])
      let yPosition = pageHeight - margin

      // Limpar caracteres especiais que WinAnsi não suporta
      const cleanText = result.text
        .replace(/\t/g, '    ') // Substituir tabs por 4 espaços
        .replace(/[\u0000-\u001F\u007F-\u009F]/g, '') // Remover caracteres de controle
        .replace(/[^\x20-\x7E\u00A0-\u00FF\n]/g, '') // Manter apenas caracteres WinAnsi + quebras de linha

      // Quebrar texto em linhas
      const lines = cleanText.split('\n')

      for (const line of lines) {
        // Pular linhas vazias
        if (!line.trim()) {
          yPosition -= lineHeight
          if (yPosition < margin) {
            currentPage = pdfDoc.addPage([pageWidth, pageHeight])
            yPosition = pageHeight - margin
          }
          continue
        }

        // Quebrar linha se muito longa
        const words = line.split(' ')
        let currentLine = ''

        for (const word of words) {
          if (!word) continue // Pular palavras vazias

          const testLine = currentLine + (currentLine ? ' ' : '') + word

          let textWidth
          try {
            textWidth = font.widthOfTextAtSize(testLine, fontSize)
          } catch (encodeError) {
            // Se falhar ao calcular largura, usar palavra sem caracteres especiais
            const cleanWord = word.replace(/[^\x20-\x7E\u00A0-\u00FF]/g, '')
            const cleanTestLine = currentLine + (currentLine ? ' ' : '') + cleanWord
            textWidth = font.widthOfTextAtSize(cleanTestLine, fontSize)
          }

          if (textWidth > maxWidth && currentLine) {
            // Desenhar linha atual
            try {
              currentPage.drawText(currentLine, {
                x: margin,
                y: yPosition,
                size: fontSize,
                font,
                color: rgb(0, 0, 0)
              })
            } catch (drawError) {
              // Tentar com texto limpo se falhar
              const cleanLine = currentLine.replace(/[^\x20-\x7E\u00A0-\u00FF]/g, '')
              if (cleanLine) {
                currentPage.drawText(cleanLine, {
                  x: margin,
                  y: yPosition,
                  size: fontSize,
                  font,
                  color: rgb(0, 0, 0)
                })
              }
            }

            yPosition -= lineHeight

            // Nova página se necessário
            if (yPosition < margin) {
              currentPage = pdfDoc.addPage([pageWidth, pageHeight])
              yPosition = pageHeight - margin
            }

            currentLine = word
          } else {
            currentLine = testLine
          }
        }

        // Desenhar linha restante
        if (currentLine) {
          try {
            currentPage.drawText(currentLine, {
              x: margin,
              y: yPosition,
              size: fontSize,
              font,
              color: rgb(0, 0, 0)
            })
          } catch (drawError) {
            // Tentar com texto limpo se falhar
            const cleanLine = currentLine.replace(/[^\x20-\x7E\u00A0-\u00FF]/g, '')
            if (cleanLine) {
              currentPage.drawText(cleanLine, {
                x: margin,
                y: yPosition,
                size: fontSize,
                font,
                color: rgb(0, 0, 0)
              })
            }
          }

          yPosition -= lineHeight

          // Nova página se necessário
          if (yPosition < margin) {
            currentPage = pdfDoc.addPage([pageWidth, pageHeight])
            yPosition = pageHeight - margin
          }
        }
      }

      // Salvar PDF
      const pdfBytes = await pdfDoc.save()
      const pdfBuffer = Buffer.from(pdfBytes)

      console.log(`✅ [DOCX] PDF gerado: ${pdfDoc.getPageCount()} páginas, ${pdfBuffer.length} bytes`)

      return pdfBuffer

    } catch (error) {
      console.error('❌ [DOCX] Erro ao converter para PDF:', error)
      throw error
    }
  }

  /**
   * Verificar se buffer é um arquivo DOCX válido
   */
  static isValidDOCX(buffer: Buffer): boolean {
    try {
      // DOCX são arquivos ZIP que começam com PK
      const header = buffer.subarray(0, 4).toString()
      return header.startsWith('PK')
    } catch {
      return false
    }
  }
}
