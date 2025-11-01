// src/middleware.ts
import { NextResponse } from 'next/server'
import type { NextRequest } from 'next/server'
import { jwtVerify } from 'jose'
import { PrismaClient } from '@prisma/client'

const JWT_SECRET = process.env.JWT_SECRET || 'fallback-secret-key'

// Inicializar Prisma para middleware
const prisma = new PrismaClient()

// Definir limites por plano (sincronizado com plan-limits.ts)
const PLAN_LIMITS = {
  trialing: { maxDocuments: 50, maxTokens: 100000 },
  basic: { maxDocuments: 500, maxTokens: 1000000 },
  pro: { maxDocuments: 5000, maxTokens: 10000000 },
  enterprise: { maxDocuments: -1, maxTokens: -1 } // ilimitado
} as const

export async function middleware(request: NextRequest) {
  const { pathname } = request.nextUrl

  // Rotas públicas que não precisam de autenticação
  const publicPaths = ['/login', '/register', '/api/auth/login', '/api/auth/register']
  if (publicPaths.some(path => pathname.startsWith(path))) {
    return NextResponse.next()
  }

  // Rotas de API webhook (não precisam de token JWT)
  if (pathname.startsWith('/api/webhooks/')) {
    return NextResponse.next()
  }

  // ✅ Para páginas do cliente (/dashboard, /admin, /pricing, etc.),
  // deixar passar e validar no lado do cliente (useEffect)
  // O middleware só valida APIs
  if (!pathname.startsWith('/api/')) {
    return NextResponse.next()
  }

  // Para APIs, verificar token no header Authorization
  const authHeader = request.headers.get('authorization')
  const token = authHeader?.replace('Bearer ', '')

  if (!token) {
    return NextResponse.json(
      { error: 'Token de autorização não fornecido' },
      { status: 401 }
    )
  }

  try {
    // Verificar token JWT
    const secret = new TextEncoder().encode(JWT_SECRET)
    const { payload } = await jwtVerify(token, secret)

    // Verificar se é rota admin API
    if (pathname.startsWith('/api/admin')) {
      if (payload.role !== 'admin') {
        return NextResponse.json(
          { error: 'Acesso negado: apenas administradores' },
          { status: 403 }
        )
      }
    }

    // ✅ NOVO: Verificar limites de plano para operações críticas
    const isResourceIntensiveOperation =
      pathname.startsWith('/api/documents/upload') ||
      pathname.startsWith('/api/ai/') ||
      pathname.startsWith('/api/projects') && request.method === 'POST'

    if (isResourceIntensiveOperation && payload.organizationId) {
      const limitCheck = await checkPlanLimitsMiddleware(payload.organizationId as number)

      if (!limitCheck.allowed) {
        return NextResponse.json({
          error: limitCheck.reason,
          upgradeRequired: true,
          usage: limitCheck.usage,
          limits: limitCheck.limits
        }, { status: 403 })
      }
    }

    return NextResponse.next()
  } catch (error) {
    console.error('Erro ao verificar token:', error)
    return NextResponse.json(
      { error: 'Token inválido ou expirado' },
      { status: 401 }
    )
  }
}

/**
 * Verifica limites do plano da organização
 * (Versão otimizada para middleware)
 */
async function checkPlanLimitsMiddleware(organizationId: number): Promise<{
  allowed: boolean
  reason?: string
  usage?: { documents: number; tokens: number }
  limits?: { documents: number; tokens: number }
}> {
  try {
    const organization = await prisma.organization.findUnique({
      where: { id: organizationId },
      select: {
        planType: true,
        subscriptionStatus: true,
        documentProcessedCount: true,
        aiTokenCount: true
      }
    })

    if (!organization) {
      return { allowed: false, reason: 'Organização não encontrada' }
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
      return { allowed: false, reason: 'Plano inválido' }
    }

    // Verificar limite de documentos (-1 = ilimitado)
    if (limits.maxDocuments !== -1 && organization.documentProcessedCount >= limits.maxDocuments) {
      return {
        allowed: false,
        reason: `Limite de documentos atingido (${limits.maxDocuments}). Faça upgrade do seu plano.`,
        usage: {
          documents: organization.documentProcessedCount,
          tokens: organization.aiTokenCount
        },
        limits: {
          documents: limits.maxDocuments,
          tokens: limits.maxTokens
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
          tokens: organization.aiTokenCount
        },
        limits: {
          documents: limits.maxDocuments,
          tokens: limits.maxTokens
        }
      }
    }

    // Tudo OK
    return { allowed: true }

  } catch (error) {
    console.error('❌ Erro ao verificar limites no middleware:', error)
    // Em caso de erro, permitir (fail open) mas logar
    return { allowed: true }
  }
}

export const config = {
  matcher: [
    /*
     * Match all request paths except for the ones starting with:
     * - _next/static (static files)
     * - _next/image (image optimization files)
     * - favicon.ico (favicon file)
     * - public folder
     */
    '/((?!_next/static|_next/image|favicon.ico|public).*)',
  ],
}
