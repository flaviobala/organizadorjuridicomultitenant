// src/lib/email.ts
import { Resend } from 'resend'

const resend = new Resend(process.env.RESEND_API_KEY)

interface EmailOptions {
  to: string
  subject: string
  html: string
}

export async function sendEmail({ to, subject, html }: EmailOptions) {
  try {
    const data = await resend.emails.send({
      from: process.env.EMAIL_FROM || 'noreply@organizadorjuridico.com',
      to,
      subject,
      html
    })

    return { success: true, data }
  } catch (error) {
    console.error('Error sending email:', error)
    return { success: false, error }
  }
}

// Template: Trial expirando em 3 dias
export function trialExpiring3DaysTemplate(data: {
  name: string
  expirationDate: Date
  cardLastFourDigits?: string
}) {
  const formattedDate = data.expirationDate.toLocaleDateString('pt-BR', {
    day: '2-digit',
    month: 'long',
    year: 'numeric'
  })

  return `
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <style>
    body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
    .container { max-width: 600px; margin: 0 auto; padding: 20px; }
    .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 30px; text-align: center; border-radius: 8px 8px 0 0; }
    .content { background: #f9fafb; padding: 30px; border-radius: 0 0 8px 8px; }
    .button { display: inline-block; background: #667eea; color: white; padding: 12px 30px; text-decoration: none; border-radius: 6px; margin: 20px 0; }
    .footer { text-align: center; margin-top: 20px; color: #6b7280; font-size: 14px; }
    .highlight { background: #fef3c7; padding: 15px; border-left: 4px solid #f59e0b; margin: 20px 0; }
  </style>
</head>
<body>
  <div class="container">
    <div class="header">
      <h1>⏰ Seu teste grátis expira em breve!</h1>
    </div>
    <div class="content">
      <p>Olá <strong>${data.name}</strong>,</p>

      <p>Esperamos que esteja aproveitando o <strong>Organizador Jurídico</strong>!</p>

      <div class="highlight">
        <strong>⚠️ Aviso Importante:</strong><br>
        Seu período de teste de 3 dias termina amanhã.<br>
        Data de expiração: <strong>${formattedDate}</strong>
      </div>

      <p>Após o período de teste, cobraremos automaticamente <strong>R$ 15,00/mês</strong> (Plano BASIC) ${data.cardLastFourDigits ? `no cartão final <strong>${data.cardLastFourDigits}</strong>` : 'no cartão cadastrado'}.</p>

      <h3>O que acontece agora?</h3>
      <ul>
        <li>✅ Continue usando o sistema normalmente até ${formattedDate}</li>
        <li>💳 Após a expiração, a cobrança será feita automaticamente</li>
        <li>📧 Você receberá um email confirmando o pagamento</li>
      </ul>

      <h3>Não quer continuar?</h3>
      <p>Sem problemas! Se não desejar continuar usando o serviço, cancele antes de ${formattedDate} para evitar a cobrança.</p>

      <a href="${process.env.NEXT_PUBLIC_APP_URL || 'http://localhost:3000'}/settings" class="button">
        Gerenciar Assinatura
      </a>

      <p>Se tiver alguma dúvida, responda este email. Estamos aqui para ajudar!</p>

      <p>Atenciosamente,<br><strong>Equipe Organizador Jurídico</strong></p>
    </div>
    <div class="footer">
      <p>Este é um email automático. Por favor, não responda.</p>
    </div>
  </div>
</body>
</html>
  `
}

// Template: Trial expirando em 1 dia
export function trialExpiring1DayTemplate(data: {
  name: string
  expirationDate: Date
  cardLastFourDigits?: string
}) {
  const formattedDate = data.expirationDate.toLocaleDateString('pt-BR', {
    day: '2-digit',
    month: 'long',
    year: 'numeric'
  })

  return `
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <style>
    body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
    .container { max-width: 600px; margin: 0 auto; padding: 20px; }
    .header { background: linear-gradient(135deg, #ef4444 0%, #dc2626 100%); color: white; padding: 30px; text-align: center; border-radius: 8px 8px 0 0; }
    .content { background: #f9fafb; padding: 30px; border-radius: 0 0 8px 8px; }
    .button { display: inline-block; background: #ef4444; color: white; padding: 12px 30px; text-decoration: none; border-radius: 6px; margin: 20px 0; }
    .footer { text-align: center; margin-top: 20px; color: #6b7280; font-size: 14px; }
    .highlight { background: #fee2e2; padding: 15px; border-left: 4px solid #ef4444; margin: 20px 0; }
  </style>
</head>
<body>
  <div class="container">
    <div class="header">
      <h1>🚨 Última chance!</h1>
    </div>
    <div class="content">
      <p>Olá <strong>${data.name}</strong>,</p>

      <div class="highlight">
        <strong>⚠️ URGENTE:</strong><br>
        Seu período de teste expira <strong>AMANHÃ</strong> (${formattedDate}).<br>
        A cobrança será feita automaticamente em <strong>24 horas</strong>.
      </div>

      <p>Se deseja continuar usando o <strong>Organizador Jurídico</strong>, não precisa fazer nada! Cobraremos automaticamente <strong>R$ 15,00/mês</strong> ${data.cardLastFourDigits ? `no cartão final <strong>${data.cardLastFourDigits}</strong>` : 'no cartão cadastrado'}.</p>

      <h3>⏰ O que acontece amanhã?</h3>
      <ul>
        <li>💳 Cobrança automática de R$ 15,00 (Plano BASIC)</li>
        <li>✅ Seu acesso continua sem interrupções</li>
        <li>📧 Email de confirmação do pagamento</li>
      </ul>

      <h3>🛑 Não quer continuar?</h3>
      <p><strong>Cancele HOJE</strong> para evitar a cobrança:</p>

      <a href="${process.env.NEXT_PUBLIC_APP_URL || 'http://localhost:3000'}/settings" class="button">
        Cancelar Assinatura
      </a>

      <p>Atenciosamente,<br><strong>Equipe Organizador Jurídico</strong></p>
    </div>
    <div class="footer">
      <p>Este é um email automático. Por favor, não responda.</p>
    </div>
  </div>
</body>
</html>
  `
}

// Template: Pagamento confirmado
export function paymentConfirmedTemplate(data: {
  name: string
  amount: number
  planType: string
  nextBillingDate: Date
  cardLastFourDigits?: string
}) {
  const formattedDate = data.nextBillingDate.toLocaleDateString('pt-BR', {
    day: '2-digit',
    month: 'long',
    year: 'numeric'
  })

  return `
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <style>
    body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
    .container { max-width: 600px; margin: 0 auto; padding: 20px; }
    .header { background: linear-gradient(135deg, #10b981 0%, #059669 100%); color: white; padding: 30px; text-align: center; border-radius: 8px 8px 0 0; }
    .content { background: #f9fafb; padding: 30px; border-radius: 0 0 8px 8px; }
    .button { display: inline-block; background: #10b981; color: white; padding: 12px 30px; text-decoration: none; border-radius: 6px; margin: 20px 0; }
    .footer { text-align: center; margin-top: 20px; color: #6b7280; font-size: 14px; }
    .invoice { background: white; padding: 20px; border: 1px solid #e5e7eb; border-radius: 8px; margin: 20px 0; }
  </style>
</head>
<body>
  <div class="container">
    <div class="header">
      <h1>✅ Pagamento Confirmado!</h1>
    </div>
    <div class="content">
      <p>Olá <strong>${data.name}</strong>,</p>

      <p>Seu pagamento foi processado com sucesso! 🎉</p>

      <div class="invoice">
        <h3>Detalhes da Cobrança</h3>
        <table style="width: 100%; border-collapse: collapse;">
          <tr>
            <td style="padding: 8px 0;"><strong>Plano:</strong></td>
            <td style="text-align: right;">${data.planType.toUpperCase()}</td>
          </tr>
          <tr>
            <td style="padding: 8px 0;"><strong>Valor:</strong></td>
            <td style="text-align: right;">R$ ${data.amount.toFixed(2)}</td>
          </tr>
          ${data.cardLastFourDigits ? `
          <tr>
            <td style="padding: 8px 0;"><strong>Cartão:</strong></td>
            <td style="text-align: right;">Final ${data.cardLastFourDigits}</td>
          </tr>
          ` : ''}
          <tr>
            <td style="padding: 8px 0;"><strong>Próxima cobrança:</strong></td>
            <td style="text-align: right;">${formattedDate}</td>
          </tr>
        </table>
      </div>

      <p>Seu acesso ao <strong>Organizador Jurídico</strong> continua ativo sem interrupções!</p>

      <a href="${process.env.NEXT_PUBLIC_APP_URL || 'http://localhost:3000'}/dashboard" class="button">
        Acessar Dashboard
      </a>

      <p>Se tiver alguma dúvida sobre sua cobrança, acesse a seção de configurações ou entre em contato conosco.</p>

      <p>Obrigado por confiar em nosso serviço!</p>

      <p>Atenciosamente,<br><strong>Equipe Organizador Jurídico</strong></p>
    </div>
    <div class="footer">
      <p>Este é um email automático. Por favor, não responda.</p>
    </div>
  </div>
</body>
</html>
  `
}

// Template: Falha no pagamento
export function paymentFailedTemplate(data: {
  name: string
  amount: number
  reason?: string
  cardLastFourDigits?: string
}) {
  return `
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <style>
    body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
    .container { max-width: 600px; margin: 0 auto; padding: 20px; }
    .header { background: linear-gradient(135deg, #ef4444 0%, #dc2626 100%); color: white; padding: 30px; text-align: center; border-radius: 8px 8px 0 0; }
    .content { background: #f9fafb; padding: 30px; border-radius: 0 0 8px 8px; }
    .button { display: inline-block; background: #ef4444; color: white; padding: 12px 30px; text-decoration: none; border-radius: 6px; margin: 20px 0; }
    .footer { text-align: center; margin-top: 20px; color: #6b7280; font-size: 14px; }
    .alert { background: #fee2e2; padding: 15px; border-left: 4px solid #ef4444; margin: 20px 0; }
  </style>
</head>
<body>
  <div class="container">
    <div class="header">
      <h1>❌ Falha no Pagamento</h1>
    </div>
    <div class="content">
      <p>Olá <strong>${data.name}</strong>,</p>

      <div class="alert">
        <strong>⚠️ Atenção:</strong><br>
        Não conseguimos processar seu pagamento de <strong>R$ ${data.amount.toFixed(2)}</strong>.<br>
        ${data.reason ? `Motivo: ${data.reason}` : ''}
      </div>

      <h3>O que fazer agora?</h3>
      <ul>
        <li>Verifique se há saldo disponível no cartão ${data.cardLastFourDigits ? `final <strong>${data.cardLastFourDigits}</strong>` : 'cadastrado'}</li>
        <li>Confirme se o cartão não está vencido</li>
        <li>Atualize seus dados de pagamento se necessário</li>
      </ul>

      <p><strong>Importante:</strong> Seu acesso ao sistema será suspenso até a regularização do pagamento.</p>

      <a href="${process.env.NEXT_PUBLIC_APP_URL || 'http://localhost:3000'}/settings" class="button">
        Atualizar Forma de Pagamento
      </a>

      <p>Se continuar tendo problemas, entre em contato conosco. Estamos aqui para ajudar!</p>

      <p>Atenciosamente,<br><strong>Equipe Organizador Jurídico</strong></p>
    </div>
    <div class="footer">
      <p>Este é um email automático. Por favor, não responda.</p>
    </div>
  </div>
</body>
</html>
  `
}

// Funções auxiliares para enviar emails específicos
export async function sendTrialExpiring3Days(
  email: string,
  name: string,
  expirationDate: Date,
  cardLastFourDigits?: string
) {
  return sendEmail({
    to: email,
    subject: '⏰ Seu teste grátis expira em 3 dias',
    html: trialExpiring3DaysTemplate({ name, expirationDate, cardLastFourDigits })
  })
}

export async function sendTrialExpiring1Day(
  email: string,
  name: string,
  expirationDate: Date,
  cardLastFourDigits?: string
) {
  return sendEmail({
    to: email,
    subject: '🚨 Última chance! Seu teste expira amanhã',
    html: trialExpiring1DayTemplate({ name, expirationDate, cardLastFourDigits })
  })
}

export async function sendPaymentConfirmed(
  email: string,
  name: string,
  amount: number,
  planType: string,
  nextBillingDate: Date,
  cardLastFourDigits?: string
) {
  return sendEmail({
    to: email,
    subject: '✅ Pagamento Confirmado - Organizador Jurídico',
    html: paymentConfirmedTemplate({ name, amount, planType, nextBillingDate, cardLastFourDigits })
  })
}

export async function sendPaymentFailed(
  email: string,
  name: string,
  amount: number,
  reason?: string,
  cardLastFourDigits?: string
) {
  return sendEmail({
    to: email,
    subject: '❌ Falha no Pagamento - Ação Necessária',
    html: paymentFailedTemplate({ name, amount, reason, cardLastFourDigits })
  })
}
