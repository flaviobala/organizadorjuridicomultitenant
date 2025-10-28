// src/lib/plan-limits.ts
import { prisma } from './prisma'

/**
 * Limites por tipo de plano
 */
export const PLAN_LIMITS = {
  trialing: {
    maxDocuments: 50,
    maxTokens: 100000,
    maxUsers: 2,
    features: ['basic_processing', 'ai_categorization']
  },
  basic: {
    maxDocuments: 500,
    maxTokens: 1000000,
    maxUsers: 5,
    features: ['basic_processing', 'ai_categorization', 'batch_upload']
  },
  pro: {
    maxDocuments: 5000,
    maxTokens: 10000000,
    maxUsers: 20,
    features: ['basic_processing', 'ai_categorization', 'batch_upload', 'advanced_ai', 'priority_support']
  },
  enterprise: {
    maxDocuments: -1, // ilimitado
    maxTokens: -1,    // ilimitado
    maxUsers: -1,     // ilimitado
    features: ['basic_processing', 'ai_categorization', 'batch_upload', 'advanced_ai', 'priority_support', 'custom_integration', 'dedicated_support']
  }
} as const

export interface PlanCheckResult {
  allowed: boolean
  reason?: string
  usage?: {
    documents: number
    tokens: number
    users: number
  }
  limits?: {
    documents: number
    tokens: number
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
        reason: `Limite de documentos atingido (${limits.maxDocuments}). Faça upgrade do seu plano.`,
        usage: {
          documents: organization.documentProcessedCount,
          tokens: organization.aiTokenCount,
          users: organization._count.users
        },
        limits: {
          documents: limits.maxDocuments,
          tokens: limits.maxTokens,
          users: limits.maxUsers
        }
      }
    }

    // Verificar limite de tokens (-1 = ilimitado)
    if (limits.maxTokens !== -1 && organization.aiTokenCount >= limits.maxTokens) {
      return {
        allowed: false,
        reason: `Limite de tokens IA atingido (${limits.maxTokens.toLocaleString()}). Faça upgrade do seu plano.`,
        usage: {
          documents: organization.documentProcessedCount,
          tokens: organization.aiTokenCount,
          users: organization._count.users
        },
        limits: {
          documents: limits.maxDocuments,
          tokens: limits.maxTokens,
          users: limits.maxUsers
        }
      }
    }

    // Tudo OK
    return {
      allowed: true,
      usage: {
        documents: organization.documentProcessedCount,
        tokens: organization.aiTokenCount,
        users: organization._count.users
      },
      limits: {
        documents: limits.maxDocuments,
        tokens: limits.maxTokens,
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
