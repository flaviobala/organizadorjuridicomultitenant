// src/app/api/usage/route.ts
import { NextRequest, NextResponse } from 'next/server'
import { requireAuth } from '@/lib/auth'
import { getMonthlyUsage } from '@/lib/token-tracker'

export async function GET(request: NextRequest) {
  try {
    const auth = await requireAuth(request)
    if (!auth.success || !auth.user) {
      return NextResponse.json({ error: auth.error }, { status: 401 })
    }

    // Buscar uso do mês atual
    const usage = await getMonthlyUsage(auth.user.id)

    return NextResponse.json({
      success: true,
      usage: {
        tokensInput: usage.tokensInput,
        tokensOutput: usage.tokensOutput,
        tokensTotal: usage.tokensTotal,
        tokensLimit: usage.limit,
        tokensRemaining: usage.limit - usage.tokensTotal,
        percentage: Math.round(usage.percentage * 10) / 10, // 1 casa decimal
        costBRL: Math.round(usage.costBRL * 100) / 100, // 2 casas decimais
        documentsProcessed: usage.documentsProcessed,
        avgTokensPerDoc: usage.avgTokensPerDoc,
        aiCount: usage.aiCount,
        keywordsCount: usage.keywordsCount,
        monthStart: usage.monthStart,
        monthEnd: usage.monthEnd,

        // Status visual
        status: usage.percentage >= 100 ? 'exceeded' :
                usage.percentage >= 90 ? 'critical' :
                usage.percentage >= 80 ? 'warning' : 'ok',

        // Método mais usado
        primaryMethod: usage.aiCount >= usage.keywordsCount ? 'ai' : 'keywords',
      }
    })

  } catch (error) {
    console.error('❌ Erro ao buscar uso de API:', error)
    return NextResponse.json({
      success: false,
      error: error instanceof Error ? error.message : 'Erro interno do servidor'
    }, { status: 500 })
  }
}
