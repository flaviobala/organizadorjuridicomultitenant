// src/lib/token-tracker.ts
import { prisma } from './prisma'

/**
 * ✅ Sistema de Rastreamento de Tokens OpenAI
 * Custo: R$ 0,00 (apenas registra uso)
 */

// Preços OpenAI (em USD) - Atualizado 2025
const PRICING = {
  'gpt-4o-mini': {
    input: 0.00015 / 1000,  // $0.15 per 1M tokens = $0.00015 per 1K
    output: 0.0006 / 1000,  // $0.60 per 1M tokens = $0.0006 per 1K
  },
  'gpt-4-turbo-preview': {
    input: 0.01 / 1000,     // $10 per 1M tokens
    output: 0.03 / 1000,    // $30 per 1M tokens
  },
} as const

const USD_TO_BRL = 5.0 // Taxa de câmbio (pode ser atualizada)

export interface TrackTokensInput {
  service: string          // 'openai'
  operation: string        // 'categorization'
  model?: string           // 'gpt-4o-mini'
  tokensInput?: number
  tokensOutput?: number
  method?: string          // 'ai' ou 'keywords'
  success?: boolean
  errorMessage?: string
  documentId?: number
  projectId?: number
  userId: number           // ✅ Obrigatório (multi-tenant)
  organizationId: number   // ✅ Obrigatório (multi-tenant)
}

/**
 * Registra uso de tokens no banco
 */
export async function trackTokens(input: TrackTokensInput) {
  try {
    const tokensInput = input.tokensInput || 0
    const tokensOutput = input.tokensOutput || 0
    const tokensTotal = tokensInput + tokensOutput

    // Calcular custo em BRL
    let costBRL = 0
    if (input.model && PRICING[input.model as keyof typeof PRICING]) {
      const pricing = PRICING[input.model as keyof typeof PRICING]
      const costUSD = (tokensInput * pricing.input) + (tokensOutput * pricing.output)
      costBRL = costUSD * USD_TO_BRL
    }

    // Registrar no banco
    await prisma.apiUsage.create({
      data: {
        userId: input.userId,
        organizationId: input.organizationId,
        service: input.service,
        operation: input.operation,
        model: input.model || null,
        tokensInput,
        tokensOutput,
        tokensTotal,
        costBRL,
        method: input.method || 'ai',
        success: input.success !== false,
        errorMessage: input.errorMessage || null,
        documentId: input.documentId || null,
        projectId: input.projectId || null,
      },
    })

    console.log(`✅ [TOKENS] Registrado: ${tokensTotal} tokens (R$ ${costBRL.toFixed(4)}) - Método: ${input.method || 'ai'}`)
  } catch (error) {
    console.error('❌ Erro ao registrar uso de tokens:', error)
    // Não lançar erro para não quebrar fluxo principal
  }
}

/**
 * Obter uso de tokens do mês atual
 */
export async function getMonthlyUsage(userId?: number) {
  try {
    const now = new Date()
    const firstDayOfMonth = new Date(now.getFullYear(), now.getMonth(), 1)
    const lastDayOfMonth = new Date(now.getFullYear(), now.getMonth() + 1, 0, 23, 59, 59)

    const where = userId ? { userId, date: { gte: firstDayOfMonth, lte: lastDayOfMonth } } : { date: { gte: firstDayOfMonth, lte: lastDayOfMonth } }

    const usage = await prisma.apiUsage.findMany({
      where,
      orderBy: { date: 'desc' },
    })

    // Calcular totais
    const totals = usage.reduce(
      (acc, item) => {
        acc.tokensInput += item.tokensInput
        acc.tokensOutput += item.tokensOutput
        acc.tokensTotal += item.tokensTotal
        acc.costBRL += item.costBRL
        acc.documentsProcessed += item.documentId ? 1 : 0

        if (item.method === 'ai') acc.aiCount++
        if (item.method === 'keywords') acc.keywordsCount++

        return acc
      },
      {
        tokensInput: 0,
        tokensOutput: 0,
        tokensTotal: 0,
        costBRL: 0,
        documentsProcessed: 0,
        aiCount: 0,
        keywordsCount: 0,
      }
    )

    // Média de tokens por documento
    const avgTokensPerDoc = totals.documentsProcessed > 0 ? Math.round(totals.tokensTotal / totals.documentsProcessed) : 0

    return {
      ...totals,
      avgTokensPerDoc,
      limit: 100000, // Limite mensal padrão
      percentage: (totals.tokensTotal / 100000) * 100,
      monthStart: firstDayOfMonth,
      monthEnd: lastDayOfMonth,
    }
  } catch (error) {
    console.error('❌ Erro ao buscar uso mensal:', error)
    return {
      tokensInput: 0,
      tokensOutput: 0,
      tokensTotal: 0,
      costBRL: 0,
      documentsProcessed: 0,
      aiCount: 0,
      keywordsCount: 0,
      avgTokensPerDoc: 0,
      limit: 100000,
      percentage: 0,
      monthStart: new Date(),
      monthEnd: new Date(),
    }
  }
}

/**
 * Verificar se atingiu limite mensal
 */
export async function hasReachedLimit(userId?: number): Promise<boolean> {
  const usage = await getMonthlyUsage(userId)
  return usage.tokensTotal >= usage.limit
}

/**
 * Estimar tokens de um texto
 * Aproximação: ~4 caracteres = 1 token (para português)
 */
export function estimateTokens(text: string): number {
  if (!text) return 0
  return Math.ceil(text.length / 4)
}
