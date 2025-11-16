// src/app/api/cron/check-trials/route.ts
import { NextRequest, NextResponse } from 'next/server'
import { prisma } from '@/lib/prisma'
import { sendTrialExpiring3Days, sendTrialExpiring1Day } from '@/lib/email'

/**
 * Cron job que verifica trials expirando e envia notificações
 * Deve ser executado diariamente
 *
 * Funcionalidades:
 * 1. Notifica usuários 3 dias antes do fim do trial
 * 2. Notifica usuários 1 dia antes do fim do trial
 * 3. Lista organizações que precisam de notificação
 */
export async function GET(request: NextRequest) {
  try {
    // Verificar autorização (apenas cron jobs autorizados podem chamar)
    const authHeader = request.headers.get('authorization')
    const cronSecret = process.env.CRON_SECRET || 'change-me-in-production'

    if (authHeader !== `Bearer ${cronSecret}`) {
      return NextResponse.json({
        success: false,
        error: 'Unauthorized'
      }, { status: 401 })
    }

    const now = new Date()
    const threeDaysFromNow = new Date(now)
    threeDaysFromNow.setDate(threeDaysFromNow.getDate() + 3)

    const oneDayFromNow = new Date(now)
    oneDayFromNow.setDate(oneDayFromNow.getDate() + 1)

    // Buscar organizações FREE com trial expirando
    const organizations = await prisma.organization.findMany({
      where: {
        planType: 'free',
        subscriptionStatus: 'free_trial',
        freeTrialEndsAt: {
          not: null
        }
      },
      include: {
        users: {
          where: {
            role: 'admin'
          },
          select: {
            id: true,
            name: true,
            email: true
          }
        }
      }
    })

    // Separar por categoria
    const expiring3Days: any[] = []
    const expiring1Day: any[] = []
    const expired: any[] = []

    for (const org of organizations) {
      if (!org.freeTrialEndsAt) continue

      const daysUntilExpiration = Math.ceil(
        (org.freeTrialEndsAt.getTime() - now.getTime()) / (1000 * 60 * 60 * 24)
      )

      const orgInfo = {
        id: org.id,
        name: org.name,
        freeTrialEndsAt: org.freeTrialEndsAt,
        daysUntilExpiration,
        admin: org.users[0],
        hasCardToken: !!org.paymentCardToken,
        cardLastFourDigits: org.cardLastFourDigits
      }

      if (daysUntilExpiration === 3) {
        expiring3Days.push(orgInfo)
      } else if (daysUntilExpiration === 1) {
        expiring1Day.push(orgInfo)
      } else if (daysUntilExpiration <= 0) {
        expired.push(orgInfo)
      }
    }

    // Enviar emails para organizações expirando em 3 dias
    const emailResults = {
      sent3Days: 0,
      sent1Day: 0,
      failed: [] as any[]
    }

    for (const org of expiring3Days) {
      if (org.admin && org.admin.email) {
        try {
          await sendTrialExpiring3Days(
            org.admin.email,
            org.admin.name,
            org.freeTrialEndsAt,
            org.cardLastFourDigits
          )
          emailResults.sent3Days++
        } catch (error) {
          console.error(`Failed to send 3-day email to ${org.admin.email}:`, error)
          emailResults.failed.push({
            organizationId: org.id,
            email: org.admin.email,
            type: '3-day',
            error: error instanceof Error ? error.message : 'Unknown error'
          })
        }
      }
    }

    // Enviar emails para organizações expirando em 1 dia
    for (const org of expiring1Day) {
      if (org.admin && org.admin.email) {
        try {
          await sendTrialExpiring1Day(
            org.admin.email,
            org.admin.name,
            org.freeTrialEndsAt,
            org.cardLastFourDigits
          )
          emailResults.sent1Day++
        } catch (error) {
          console.error(`Failed to send 1-day email to ${org.admin.email}:`, error)
          emailResults.failed.push({
            organizationId: org.id,
            email: org.admin.email,
            type: '1-day',
            error: error instanceof Error ? error.message : 'Unknown error'
          })
        }
      }
    }

    return NextResponse.json({
      success: true,
      timestamp: now.toISOString(),
      summary: {
        total: organizations.length,
        expiring3Days: expiring3Days.length,
        expiring1Day: expiring1Day.length,
        expired: expired.length
      },
      emailResults,
      organizations: {
        expiring3Days,
        expiring1Day,
        expired
      },
      message: 'Trial check completed successfully'
    })

  } catch (error) {
    console.error('Error checking trials:', error)
    return NextResponse.json({
      success: false,
      error: 'Internal server error',
      details: error instanceof Error ? error.message : 'Unknown error'
    }, { status: 500 })
  }
}
