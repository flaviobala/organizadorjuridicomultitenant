// src/lib/plan-limits.ts
import { prisma } from './prisma'

/**
 * Limites por tipo de plano
 * NOTA: Limites por DOCUMENTOS (não mais por tokens de IA)
 */
export const PLAN_LIMITS = {
  free: {
    maxDocuments: 15, // Teste grátis: 3 dias OU 50 documentos
    maxUsers: 1,
    trialDays: 3, // 3 dias de teste
    hasValidation: false, // Sem validação de pertinência
    features: ['basic_processing', 'ai_categorization', 'ocr']
  },
  basic: {
    maxDocuments: 300, // 300 documentos por mês
    maxUsers: 1,
    hasValidation: false, // Sem validação de pertinência
    features: ['basic_processing', 'ai_categorization', 'batch_upload', 'ocr']
  },
  advanced: {
    maxDocuments: 600, // 600 documentos por mês
    maxUsers: 3,
    hasValidation: true, // Validação de pertinência (300 docs/mês)
    maxValidations: 300,
    features: ['basic_processing', 'ai_categorization', 'batch_upload', 'ocr', 'ai_validation', 'usage_panel', 'priority_support']
  },
  complete: {
    maxDocuments: 1200, // 1.200 documentos por mês
    maxUsers: 5,
    hasValidation: true, // Validação de pertinência ilimitada
    maxValidations: -1, // Ilimitado
    features: ['basic_processing', 'ai_categorization', 'batch_upload', 'ocr', 'ai_validation', 'usage_panel', 'complete_support']
  }
} as const

export interface PlanCheckResult {
  allowed: boolean
  reason?: string
  usage?: {
    documents: number
    users: number
  }
  limits?: {
    documents: number
    users: number
  }
}

/**
 * Verifica se a organização pode processar mais documentos
 */
export async function checkPlanLimits(organizationId: number): Promise<PlanCheckResult> {
  try {
    // Buscar organização
    const organization = await prisma.organization.findUnique({
      where: { id: organizationId },
      include: {
        _count: {
          select: {
            documents: true,
            users: true
          }
        }
      }
    })

    if (!organization) {
      return {
        allowed: false,
        reason: 'Organização não encontrada'
      }
    }

    // Verificar se o período FREE expirou (3 dias OU 50 documentos - o que vier primeiro)
    if (organization.planType === 'free') {
      const now = new Date()

      // Verificar se os 3 dias expiraram
      if (organization.freeTrialEndsAt && now > organization.freeTrialEndsAt) {
        return {
          allowed: false,
          reason: 'Seu período de teste de 3 dias expirou. Faça upgrade para continuar usando o sistema.'
        }
      }

      // Verificar se atingiu 50 documentos
      if (organization.documentProcessedCount >= 50) {
        return {
          allowed: false,
          reason: 'Você atingiu o limite de 50 documentos do teste grátis. Faça upgrade para continuar usando o sistema.'
        }
      }
    }

    // Verificar status da assinatura
    if (organization.subscriptionStatus === 'canceled') {
      return {
        allowed: false,
        reason: 'Assinatura cancelada. Por favor, reative sua assinatura para continuar.'
      }
    }

    if (organization.subscriptionStatus === 'past_due') {
      return {
        allowed: false,
        reason: 'Pagamento em atraso. Por favor, atualize sua forma de pagamento.'
      }
    }

    // Buscar limites do plano
    const limits = PLAN_LIMITS[organization.planType as keyof typeof PLAN_LIMITS]
    if (!limits) {
      return {
        allowed: false,
        reason: 'Plano inválido'
      }
    }

    // Verificar limite de documentos (-1 = ilimitado)
    if (limits.maxDocuments !== -1 && organization.documentProcessedCount >= limits.maxDocuments) {
      return {
        allowed: false,
        reason: `Limite de ${limits.maxDocuments} documentos atingido neste mês. Faça upgrade do seu plano ou aguarde a renovação.`,
        usage: {
          documents: organization.documentProcessedCount,
          users: organization._count.users
        },
        limits: {
          documents: limits.maxDocuments,
          users: limits.maxUsers
        }
      }
    }

    // Tudo OK
    return {
      allowed: true,
      usage: {
        documents: organization.documentProcessedCount,
        users: organization._count.users
      },
      limits: {
        documents: limits.maxDocuments,
        users: limits.maxUsers
      }
    }

  } catch (error) {
    console.error('❌ Erro ao verificar limites do plano:', error)
    return {
      allowed: false,
      reason: 'Erro ao verificar limites do plano'
    }
  }
}

/**
 * Verifica se a organização pode adicionar mais usuários
 */
export async function checkUserLimit(organizationId: number): Promise<boolean> {
  try {
    const organization = await prisma.organization.findUnique({
      where: { id: organizationId },
      include: {
        _count: {
          select: { users: true }
        }
      }
    })

    if (!organization) return false

    const limits = PLAN_LIMITS[organization.planType as keyof typeof PLAN_LIMITS]
    if (!limits) return false

    // -1 = ilimitado
    if (limits.maxUsers === -1) return true

    return organization._count.users < limits.maxUsers
  } catch (error) {
    console.error('❌ Erro ao verificar limite de usuários:', error)
    return false
  }
}

/**
 * Incrementa contador de documentos processados
 */
export async function incrementDocumentCount(organizationId: number): Promise<void> {
  try {
    await prisma.organization.update({
      where: { id: organizationId },
      data: {
        documentProcessedCount: {
          increment: 1
        }
      }
    })
  } catch (error) {
    console.error('❌ Erro ao incrementar contador de documentos:', error)
  }
}

/**
 * Incrementa contador de tokens IA
 * NOTA: Mantido para compatibilidade, mas não mais usado para limites
 */
export async function incrementTokenCount(organizationId: number, tokens: number): Promise<void> {
  try {
    await prisma.organization.update({
      where: { id: organizationId },
      data: {
        aiTokenCount: {
          increment: tokens
        }
      }
    })
  } catch (error) {
    console.error('❌ Erro ao incrementar contador de tokens:', error)
  }
}
