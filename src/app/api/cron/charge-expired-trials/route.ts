// src/app/api/cron/charge-expired-trials/route.ts
import { NextRequest, NextResponse } from 'next/server'
import { prisma } from '@/lib/prisma'
import { sendPaymentConfirmed, sendPaymentFailed } from '@/lib/email'
import { MercadoPagoConfig, Payment } from 'mercadopago'

// Configurar MercadoPago
const client = new MercadoPagoConfig({
  accessToken: process.env.MERCADOPAGO_ACCESS_TOKEN || ''
})

const paymentApi = new Payment(client)

/**
 * Cron job que cobra automaticamente organizações com trial expirado
 * Deve ser executado diariamente
 *
 * Funcionalidades:
 * 1. Identifica organizações FREE com trial expirado
 * 2. Cobra automaticamente usando o cartão tokenizado
 * 3. Atualiza o status da organização (ativa ou bloqueada)
 * 4. Envia notificação de cobrança
 */
export async function POST(request: NextRequest) {
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

    // Buscar organizações FREE com trial expirado que têm cartão cadastrado
    const expiredOrganizations = await prisma.organization.findMany({
      where: {
        planType: 'free',
        subscriptionStatus: 'free_trial',
        freeTrialEndsAt: {
          lte: now // Menor ou igual a agora (expirado)
        },
        paymentCardToken: {
          not: null // Só organizações com cartão cadastrado
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

    const results = {
      success: [] as any[],
      failed: [] as any[],
      noCard: [] as any[]
    }

    // Processar cada organização
    for (const org of expiredOrganizations) {
      try {
        // Verificar se tem cartão
        if (!org.paymentCardToken) {
          results.noCard.push({
            organizationId: org.id,
            name: org.name,
            reason: 'No payment card token'
          })

          // Bloquear organização sem cartão
          await prisma.organization.update({
            where: { id: org.id },
            data: {
              subscriptionStatus: 'canceled'
            }
          })
          continue
        }

        // Determinar qual plano cobrar (vamos assumir BASIC por padrão)
        // Você pode adicionar lógica para permitir que o usuário escolha
        const planType = 'basic'
        const amount = planType === 'basic' ? 15.00 : 25.00 // BASIC: R$15, PRO: R$25

        // Integrar com Mercado Pago para cobrar
        try {
          const payment = await paymentApi.create({
            body: {
              transaction_amount: amount,
              token: org.paymentCardToken,
              description: `Assinatura ${planType.toUpperCase()} - ${org.name}`,
              installments: 1,
              payment_method_id: 'credit_card',
              payer: {
                email: org.users[0]?.email || 'no-email@example.com',
                identification: {
                  type: 'CPF',
                  number: org.cardHolderCpf || '00000000000'
                }
              }
            }
          })

          if (payment.status === 'approved') {
            // Cobrança aprovada
            const nextBillingDate = new Date(now.getFullYear(), now.getMonth() + 1, now.getDate())

            await prisma.organization.update({
              where: { id: org.id },
              data: {
                planType: planType,
                subscriptionStatus: 'active',
                subscriptionDueDate: nextBillingDate
              }
            })

            results.success.push({
              organizationId: org.id,
              name: org.name,
              planType,
              amount,
              paymentId: payment.id
            })

            // Enviar email de confirmação
            if (org.users[0]?.email) {
              try {
                await sendPaymentConfirmed(
                  org.users[0].email,
                  org.users[0].name,
                  amount,
                  planType,
                  nextBillingDate,
                  org.cardLastFourDigits || undefined
                )
              } catch (emailError) {
                console.error('Error sending confirmation email:', emailError)
              }
            }
          } else {
            // Cobrança falhou
            await prisma.organization.update({
              where: { id: org.id },
              data: {
                subscriptionStatus: 'past_due'
              }
            })

            results.failed.push({
              organizationId: org.id,
              name: org.name,
              reason: payment.status_detail || 'Payment not approved'
            })

            // Enviar email de falha na cobrança
            if (org.users[0]?.email) {
              try {
                await sendPaymentFailed(
                  org.users[0].email,
                  org.users[0].name,
                  amount,
                  payment.status_detail || 'Pagamento não aprovado',
                  org.cardLastFourDigits || undefined
                )
              } catch (emailError) {
                console.error('Error sending failure email:', emailError)
              }
            }
          }
        } catch (mpError: any) {
          // Erro ao processar com Mercado Pago
          console.error(`Mercado Pago error for org ${org.id}:`, mpError)

          await prisma.organization.update({
            where: { id: org.id },
            data: {
              subscriptionStatus: 'past_due'
            }
          })

          results.failed.push({
            organizationId: org.id,
            name: org.name,
            error: mpError.message || 'Mercado Pago processing error'
          })

          // Enviar email de falha
          if (org.users[0]?.email) {
            try {
              await sendPaymentFailed(
                org.users[0].email,
                org.users[0].name,
                amount,
                mpError.message || 'Erro ao processar pagamento',
                org.cardLastFourDigits || undefined
              )
            } catch (emailError) {
              console.error('Error sending failure email:', emailError)
            }
          }
        }

      } catch (error) {
        console.error(`Error charging organization ${org.id}:`, error)
        results.failed.push({
          organizationId: org.id,
          name: org.name,
          error: error instanceof Error ? error.message : 'Unknown error'
        })
      }
    }

    return NextResponse.json({
      success: true,
      timestamp: now.toISOString(),
      summary: {
        total: expiredOrganizations.length,
        charged: results.success.length,
        failed: results.failed.length,
        noCard: results.noCard.length
      },
      results,
      message: 'Charging process completed'
    })

  } catch (error) {
    console.error('Error in charge-expired-trials:', error)
    return NextResponse.json({
      success: false,
      error: 'Internal server error',
      details: error instanceof Error ? error.message : 'Unknown error'
    }, { status: 500 })
  }
}
