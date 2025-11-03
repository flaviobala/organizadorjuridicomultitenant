// Função utilitária para retry/backoff em erros 429
async function withRetry<T>(fn: () => Promise<T>, retries = 3, delayMs = 2000): Promise<T> {
  let lastError;
  for (let i = 0; i < retries; i++) {
    try {
      return await fn();
    } catch (err: any) {
      // OpenAI error: err.status ou err.response?.status
      const status = err?.status || err?.response?.status;
      if (status === 429) {
        await new Promise(res => setTimeout(res, delayMs * (i + 1)));
        lastError = err;
      } else {
        throw err;
      }
    }
  }
  throw lastError;
}
// src/lib/openai.ts

import OpenAI from 'openai'
import type { NarrativeProcessResult, DocumentAnalysis } from '@/types'

export class OpenAIService {
  private openai: OpenAI

  constructor() {
    this.openai = new OpenAI({
      apiKey: process.env.OPENAI_API_KEY
    })
  }

  /**
   * Processa narrativa fática convertendo para linguagem jurídica
   */
  async processNarrative(rawNarrative: string, actionType: string): Promise<NarrativeProcessResult> {
    try {
      console.log('🤖 Processando narrativa com OpenAI...')
      
      const prompt = `
Você é um assistente jurídico especializado em redação de peças processuais.

TAREFA: Converter o texto fornecido em uma narrativa fática profissional para uma ${actionType}.

TEXTO FORNECIDO:
"${rawNarrative}"

INSTRUÇÕES:
1. Organize as informações seguindo a técnica 5W2H (o que, onde, quando, como, por que)
2. Use linguagem jurídica formal mas acessível
3. Estruture em até 5 parágrafos de 4 linhas cada
4. Identifique as partes como "Autor" e "Réu" quando apropriado
5. Mantenha apenas informações relevantes ao caso
6. Use presente do indicativo para fatos atuais
7. Use pretérito perfeito para fatos passados

EXEMPLO DE ESTRUTURA:
- 1º parágrafo: O QUE aconteceu (fato principal)
- 2º parágrafo: ONDE e QUANDO aconteceu (contexto temporal e espacial)  
- 3º parágrafo: COMO aconteceu (circunstâncias e detalhes)
- 4º parágrafo: POR QUE aconteceu (motivações e causas)
- 5º parágrafo: CONSEQUÊNCIAS (danos e prejuízos)

Responda APENAS com a narrativa processada, sem comentários adicionais.`

      const completion = await withRetry(() =>
        this.openai.chat.completions.create({
          model: "gpt-4o-mini",
          messages: [
            {
              role: "system",
              content: "Você é um advogado experiente especializado em redação de peças processuais. Seja preciso, claro e use linguagem jurídica apropriada."
            },
            {
              role: "user",
              content: prompt
            }
          ],
          max_tokens: 2000,
          temperature: 0.3
        })
      );

      const processedNarrative = completion.choices[0].message?.content?.trim()

      if (!processedNarrative) {
        throw new Error('Resposta vazia da OpenAI')
      }

      // Capturar uso de tokens
      const tokensUsed = completion.usage?.total_tokens || 0
      console.log(`🤖 Tokens utilizados: ${tokensUsed}`)

      // Gerar sugestões adicionais
      const suggestionResult = await this.generateSuggestions(processedNarrative, actionType)

      console.log('✅ Narrativa processada com sucesso')

      return {
        success: true,
        processedNarrative,
        suggestions: suggestionResult.suggestions,
        tokensUsed: tokensUsed + (suggestionResult.tokensUsed || 0)
      }

    } catch (error) {
      console.error('Erro ao processar narrativa:', error)
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Erro desconhecido'
      }
    }
  }

  /**
   * Analisa documento e categoriza automaticamente
   */
  async analyzeDocument(
    ocrText: string, 
    filename: string, 
    mimeType: string
  ): Promise<DocumentAnalysis> {
    try {
      console.log('🧠 Analisando documento com IA...')

      const prompt = `
Analise este documento brasileiro e categorize-o conforme as opções abaixo.

TEXTO EXTRAÍDO:
"""
${ocrText || 'Não foi possível extrair texto'}
"""

NOME DO ARQUIVO: ${filename}
TIPO: ${mimeType}

CATEGORIAS DISPONÍVEIS:
1. RG - Registro Geral, Carteira de Identidade (contém: filiação, órgão expedidor, CPF)
2. CNH - Carteira Nacional de Habilitação (contém: categoria, validade, RENACH)
3. CPF - Cadastro de Pessoa Física (contém: número CPF, situação cadastral)
4. Comprovante Residência - Contas, comprovantes de endereço
5. Procuração - Procurações, outorgas, mandatos
6. Contrato - Qualquer tipo de contrato ou acordo
7. Documento Médico - Atestados, laudos, receitas
8. Certidão - Nascimento, casamento, óbito
9. Narrativa - Relatos, descrição de fatos
10. Outro - Documentos que não se encaixam acima

INSTRUÇÕES CRÍTICAS:
- Para RG: Procure "REGISTRO GERAL", "IDENTIDADE", "FILIAÇÃO", nome dos pais
- Para CNH: Procure "CNH", "HABILITAÇÃO", "CATEGORIA", "VALIDADE" 
- Para CPF: Procure "CPF", formato XXX.XXX.XXX-XX
- Basei sua decisão NO CONTEÚDO DO TEXTO, não no nome do arquivo

Responda em JSON:
{
  "category": "nome_da_categoria",
  "confidence": 0.95,
  "detectedInfo": {
    "name": "nome_encontrado",
    "cpf": "cpf_encontrado",
    "rg": "rg_encontrado",
    "organizacaoExpedidora": "orgao_expedidor"
  },
  "suggestedFilename": "nome_inteligente_do_arquivo.pdf"
}`

      const response = await withRetry(() =>
        this.openai.chat.completions.create({
          model: "gpt-4o-mini",
          messages: [
            {
              role: "system",
              content: "Você é um especialista em identificação de documentos brasileiros. Analise cuidadosamente o texto extraído e responda APENAS em JSON válido."
            },
            {
              role: "user",
              content: prompt
            }
          ],
          max_tokens: 500,
          temperature: 0.1
        })
      );

      const aiResponse = response.choices[0]?.message?.content?.trim()
      
      if (!aiResponse) {
        throw new Error('Resposta vazia da IA')
      }

      // Parse da resposta JSON
      let analysisData
      try {
        // ✅ CORREÇÃO: Limpar markdown antes do parse
        const cleanResponse = aiResponse
          .replace(/```json\s*/g, '')
          .replace(/```\s*/g, '')
          .trim()

        analysisData = JSON.parse(cleanResponse)
      } catch (parseError) {
        console.warn('Erro no parse JSON, usando fallback:', parseError)
        analysisData = this.createFallbackAnalysis(ocrText, filename)
      }

      // Estruturar resultado final
      const analysis: DocumentAnalysis = {
        documentType: analysisData.category || 'Outro',
        confidence: analysisData.confidence || 0.7,
        detectedInfo: {
          name: analysisData.detectedInfo?.name || this.extractName(ocrText),
          cpf: analysisData.detectedInfo?.cpf || this.extractCPF(ocrText),
          rg: analysisData.detectedInfo?.rg || this.extractRG(ocrText),
          organizacaoExpedidora: analysisData.detectedInfo?.organizacaoExpedidora || this.extractOrgao(ocrText)
        },
        suggestedFilename: analysisData.suggestedFilename || this.generateSmartFilename(analysisData.category, filename),
        ocrUsed: !!ocrText
      }

      console.log('✅ Documento analisado:', {
        categoria: analysis.documentType,
        confiança: Math.round(analysis.confidence * 100) + '%',
        nome: analysis.suggestedFilename
      })

      return analysis

    } catch (error) {
      console.error('Erro na análise do documento:', error)
      
      // Retornar análise básica em caso de erro
      return {
        documentType: 'Outro',
        confidence: 0.5,
        detectedInfo: {
          name: this.extractName(ocrText),
          cpf: this.extractCPF(ocrText)
        },
        suggestedFilename: filename.replace(/\.[^/.]+$/, '.pdf'),
        ocrUsed: !!ocrText
      }
    }
  }

  /**
   * Gera sugestões para fortalecer o caso
   */
  private async generateSuggestions(processedNarrative: string, actionType: string): Promise<{ suggestions: string[], tokensUsed: number }> {
    try {
      const prompt = `
Baseado na narrativa processada abaixo, liste 3-5 sugestões práticas para fortalecer juridicamente esta ${actionType}:

NARRATIVA: "${processedNarrative}"

SUGESTÕES (uma por linha, sem numeração):
- Foque em documentos que comprovem os fatos
- Seja específico e prático
- Considere jurisprudência aplicável
- Pense em provas que podem faltar`

      const completion = await withRetry(() =>
        this.openai.chat.completions.create({
          model: "gpt-4o-mini",
          messages: [
            {
              role: "user",
              content: prompt
            }
          ],
          max_tokens: 400,
          temperature: 0.4
        })
      );

      const suggestionsText = completion.choices[0]?.message?.content?.trim()
      const tokensUsed = completion.usage?.total_tokens || 0

      const suggestions = suggestionsText
        ? suggestionsText.split('\n').filter(s => s.trim().length > 10).slice(0, 5)
        : []

      return { suggestions, tokensUsed }

    } catch (error) {
      console.warn('Erro ao gerar sugestões:', error)
      return { suggestions: [], tokensUsed: 0 }
    }
  }

  // ==================== HELPERS PRIVADOS ====================

  private createFallbackAnalysis(ocrText: string, filename: string) {
    const text = ocrText.toLowerCase()
    let category = 'Outro'
    
    if (text.includes('registro geral') || text.includes('identidade') || text.includes('filiação')) {
      category = 'RG'
    } else if (text.includes('cnh') || text.includes('habilitação') || text.includes('categoria')) {
      category = 'CNH'
    } else if (text.includes('cpf') || text.match(/\d{3}\.?\d{3}\.?\d{3}-?\d{2}/)) {
      category = 'CPF'
    } else if (text.includes('comprovante') || text.includes('conta') || text.includes('endereço')) {
      category = 'Comprovante Residência'
    } else if (text.includes('procuração') || text.includes('outorga')) {
      category = 'Procuração'
    }
    
    return {
      category,
      confidence: 0.6,
      detectedInfo: {},
      suggestedFilename: this.generateSmartFilename(category, filename)
    }
  }

  private generateSmartFilename(category: string, originalFilename: string): string {
    const timestamp = new Date().toISOString().slice(0, 10)
    const cleanOriginal = originalFilename.replace(/\.[^/.]+$/, '')

    // Mapeamento correto conforme especificação do cliente
    const categoryMap: Record<string, string> = {
      // 01 - Narrativa Fática
      'Narrativa': '01 Narrativa Fática',
      'Narrativa Fática': '01 Narrativa Fática',

      // 02 - Documentos Pessoais (agrupados: RG, CNH, CPF)
      'Documentos Pessoais': '02 Documentos Pessoais',
      'RG': '02 RG',
      'CNH': '02 CNH',
      'CPF': '02 CPF',
      'Documento de Identidade': '02 RG',
      'Carteira de Identidade': '02 RG',
      'Carteira Nacional de Habilitação': '02 CNH',

      // 03 - Comprovante de Residência
      'Comprovante de Residência': '03 Comprovante de Residência',
      'Comprovante Residência': '03 Comprovante de Residência',
      'Conta de Luz': '03 Comprovante de Residência',
      'Conta de Água': '03 Comprovante de Residência',

      // 04 - Procuração
      'Procuração': '04 Procuração',

      // 05 - Declaração de Hipossuficiência
      'Declaração de Hipossuficiência': '05 Declaração de Hipossuficiência',
      'Declaração Hipossuficiência': '05 Declaração de Hipossuficiência',

      // 06 - Contratos
      'Contrato': '06 Contrato',
      'Contrato de Prestação de Serviços': '06 Contrato',
      'Contrato Prestação Serviços': '06 Contrato',
      'Contrato de Trabalho': '06 Contrato',
      'Termo de Acordo': '06 Contrato',

      // 07 - Outros Documentos
      'Documento Médico': '07 Outros Documentos',
      'Certidão': '07 Outros Documentos',
      'Petição': '07 Outros Documentos',
      'Outros Documentos': '07 Outros Documentos',
      'Outro': '07 Outros Documentos'
    }

    const prefix = categoryMap[category] || '07 Outros Documentos'
    return `${prefix}.pdf`
  }

  private extractName(text: string): string | undefined {
    const nameMatch = text.match(/(?:NOME|Nome)[:\s]+([A-ZÀ-Ÿ\s]{10,50})/i)
    return nameMatch?.[1]?.trim()
  }

  private extractCPF(text: string): string | undefined {
    const cpfMatch = text.match(/(?:CPF[:\s]*)?(\d{3}\.?\d{3}\.?\d{3}-?\d{2})/i)
    if (!cpfMatch) return undefined
    
    const cpf = cpfMatch[1].replace(/\D/g, '')
    return cpf.replace(/(\d{3})(\d{3})(\d{3})(\d{2})/, '$1.$2.$3-$4')
  }

  private extractRG(text: string): string | undefined {
    const rgMatch = text.match(/(?:RG[:\s]*)?(\d{1,2}\.?\d{3}\.?\d{3}-?\d{1})/i)
    return rgMatch?.[1]
  }

  private extractOrgao(text: string): string | undefined {
    const orgaoMatch = text.match(/(?:SSP|DETRAN|PC|IFP)[\/\s-]*([A-Z]{2})/i)
    return orgaoMatch?.[0]?.toUpperCase()
  }

  async validateDocumentRelevance(
    narrative: string,
    documentText: string,
    documentType: string | null,
    actionType: string
  ): Promise<{ relevant: boolean; confidence: number; reasoning: string; tokensUsed: number }> {
    try {
      // ✅ CORREÇÃO INTELIGENTE: Identificar documentos pessoais para análise especial
      const personalDocumentTypes = [
        'RG',
        'CNH',
        'CPF',
        'Documentos Pessoais',
        'Documento de Identidade',
        'Carteira de Identidade',
        'Carteira Nacional de Habilitação',
        'Comprovante de Residência',
        'Comprovante Residência',
        'Declaração de Hipossuficiência',
        'Declaração Hipossuficiência',
        'Procuração',
        'Certidão',
        'Certidão de Nascimento',
        'Certidão de Casamento'
      ]

      // Verificar se é documento pessoal
      const isPersonalDocument = personalDocumentTypes.some(type =>
        documentType?.toLowerCase().includes(type.toLowerCase())
      )

      // ✅ PROMPT INTELIGENTE: Para documentos pessoais, validar se a pessoa está relacionada ao caso
      const prompt = isPersonalDocument ? `
Você está analisando um DOCUMENTO PESSOAL (${documentType}) em um processo jurídico.

NARRATIVA DO CASO (com nomes das partes envolvidas):
${narrative}

TIPO DE AÇÃO: ${actionType}

DOCUMENTO A VALIDAR:
Tipo: ${documentType}
Conteúdo extraído: ${documentText.substring(0, 1500)}...

INSTRUÇÕES CRÍTICAS:
1. DOCUMENTOS PESSOAIS (RG, CNH, CPF, Comprovantes, Certidões, Procurações, Declarações) são FUNDAMENTAIS para identificar e qualificar as partes no processo
2. Compare o NOME no documento com os nomes mencionados na narrativa (Autor, Réu, testemunhas, partes relacionadas)
3. Se o documento pertence a uma das partes do processo (Autor, Réu) ou pessoa mencionada na narrativa → RELEVANTE
4. Se o documento pertence a uma pessoa completamente diferente que não tem relação com o caso → NÃO RELEVANTE
5. Procure por: nomes, CPFs, datas de nascimento, endereços mencionados na narrativa

EXEMPLOS:
- Se a narrativa fala de "João Silva" e o RG é do João Silva → RELEVANTE (confiança alta)
- Se a narrativa fala de "Maria Santos" e o RG é do José Oliveira (não mencionado) → NÃO RELEVANTE
- Se há dúvida sobre a identidade mas pode ser parte relacionada → RELEVANTE (confiança média)

Responda APENAS no formato JSON:
{
  "relevant": true/false,
  "confidence": 0.0-1.0,
  "reasoning": "explicação detalhada comparando nome do documento com narrativa"
}
` : `
Analise se este documento é relevante para o caso jurídico baseado na narrativa dos fatos.

NARRATIVA DO CASO:
${narrative}

TIPO DE AÇÃO: ${actionType}

DOCUMENTO A VALIDAR:
Tipo: ${documentType || 'Não identificado'}
Conteúdo: ${documentText.substring(0, 1000)}...

INSTRUÇÕES:
1. Compare o conteúdo do documento com os fatos narrados
2. Verifique se o documento prova, comprova ou está relacionado aos fatos do caso
3. Seja criterioso mas considere que documentos comprobatórios são geralmente relevantes
4. Se houver dúvida, prefira marcar como relevante

Responda APENAS no formato JSON:
{
  "relevant": true/false,
  "confidence": 0.0-1.0,
  "reasoning": "explicação breve"
}
`

      console.log(`🔍 Validando ${isPersonalDocument ? 'DOCUMENTO PESSOAL' : 'documento'}: ${documentType}`)

      const response = await withRetry(() =>
        this.openai.chat.completions.create({
          model: "gpt-4o-mini", // ✅ TROCADO: 85% mais barato
          messages: [
            {
              role: "system",
              content: isPersonalDocument
                ? "Você é um assistente jurídico especializado. Para DOCUMENTOS PESSOAIS, sua tarefa crítica é verificar se a pessoa do documento É UMA DAS PARTES DO PROCESSO. Compare nomes, CPFs e informações pessoais com a narrativa. Seja INTELIGENTE e CRITERIOSO."
                : "Você é um assistente jurídico especializado em validar relevância de documentos para casos jurídicos. Analise cuidadosamente a relação entre o documento e os fatos narrados."
            },
            {
              role: "user",
              content: prompt
            }
          ],
          max_tokens: isPersonalDocument ? 500 : 300,
          temperature: 0.1
        })
      );

      const content = response.choices[0]?.message?.content
      if (!content) {
        throw new Error('Resposta vazia da OpenAI')
      }

      // Remove markdown code blocks se existirem
      const cleanedContent = content
        .replace(/```json\s*/g, '')
        .replace(/```\s*/g, '')
        .trim()

      const result = JSON.parse(cleanedContent)
      const tokensUsed = response.usage?.total_tokens || 0

      console.log(`📊 Resultado da validação (${documentType}):`, {
        relevante: result.relevant,
        confiança: `${(result.confidence * 100).toFixed(0)}%`,
        raciocínio: result.reasoning?.substring(0, 100) + '...',
        tokens: tokensUsed
      })

      return {
        relevant: Boolean(result.relevant),
        confidence: Number(result.confidence) || 0.5,
        reasoning: String(result.reasoning) || 'Sem explicação disponível',
        tokensUsed
      }

    } catch (error) {
      console.error('Erro na validação de relevância:', error)
      return {
        relevant: true, // Por segurança, assume que é relevante se houver erro
        confidence: 0.5,
        reasoning: 'Erro na validação - assumindo relevância por segurança',
        tokensUsed: 0
      }
    }
  }

  async detectInconsistencies(
    narrative: string,
    documents: { type: string | null; text: string }[],
    actionType: string
  ): Promise<{ inconsistencies: string[]; overallConsistency: number; recommendations: string[]; tokensUsed: number }> {
    try {
      const documentsInfo = documents.map(doc =>
        `- ${doc.type || 'Tipo não identificado'}: ${doc.text?.substring(0, 100) || 'sem texto'}...`
      ).join('\n')

      const prompt = `
Analise a consistência entre a narrativa dos fatos e os documentos anexados para esta ação jurídica.

NARRATIVA DO CASO:
${narrative}

TIPO DE AÇÃO: ${actionType}

DOCUMENTOS ANEXADOS:
${documentsInfo}

Identifique:
1. Inconsistências entre a narrativa e os documentos
2. Documentos que parecem contradizer a narrativa
3. Lacunas ou documentos em falta

Responda APENAS no formato JSON:
{
  "inconsistencies": ["lista de inconsistências encontradas"],
  "overallConsistency": 0.0-1.0,
  "recommendations": ["lista de recomendações"]
}
`

      const response = await withRetry(() =>
        this.openai.chat.completions.create({
          model: "gpt-4o-mini", // ✅ TROCADO: 85% mais barato
          messages: [
            {
              role: "system",
              content: "Você é um assistente jurídico especializado em análise de consistência documental."
            },
            {
              role: "user",
              content: prompt
            }
          ],
          max_tokens: 800,
          temperature: 0.1
        })
      );

      const content = response.choices[0]?.message?.content
      if (!content) {
        throw new Error('Resposta vazia da OpenAI')
      }

      // ✅ CORREÇÃO: Limpar markdown da resposta (```json ... ```)
      let cleanContent = content.trim()

      // Remover backticks e marcadores de código
      cleanContent = cleanContent.replace(/```json\s*/g, '')
      cleanContent = cleanContent.replace(/```\s*/g, '')
      cleanContent = cleanContent.trim()

      console.log('🧹 Conteúdo limpo para parse:', cleanContent.substring(0, 200))

      const result = JSON.parse(cleanContent)
      const tokensUsed = response.usage?.total_tokens || 0

      return {
        inconsistencies: Array.isArray(result.inconsistencies) ? result.inconsistencies : [],
        overallConsistency: Number(result.overallConsistency) || 0.5,
        recommendations: Array.isArray(result.recommendations) ? result.recommendations : [],
        tokensUsed
      }

    } catch (error) {
      console.error('Erro na detecção de inconsistências:', error)
      return {
        inconsistencies: [],
        overallConsistency: 0.5,
        recommendations: ['Erro na análise - revisão manual recomendada'],
        tokensUsed: 0
      }
    }
  }
}