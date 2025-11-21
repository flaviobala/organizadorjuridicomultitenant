import { NextRequest, NextResponse } from 'next/server'
import { prisma } from '@/lib/prisma'
import crypto from 'crypto'
import { Resend } from 'resend'

export async function POST(request: NextRequest) {
  try {
    console.log('🔵 [FORGOT-PASSWORD] Início da requisição')

    const { email } = await request.json()
    console.log('🔵 [FORGOT-PASSWORD] Email recebido:', email)

    if (!email) {
      console.log('❌ [FORGOT-PASSWORD] Email vazio')
      return NextResponse.json({
        success: false,
        message: 'Email é obrigatório'
      }, { status: 400 })
    }

    // Buscar usuário por email
    console.log('🔵 [FORGOT-PASSWORD] Buscando usuário...')
    const user = await prisma.user.findUnique({
      where: { email: email.toLowerCase().trim() }
    })
    console.log('🔵 [FORGOT-PASSWORD] Usuário encontrado:', user ? `ID: ${user.id}` : 'NÃO ENCONTRADO')

    // Por segurança, sempre retornar sucesso mesmo se o email não existir
    // Isso impede que atacantes descubram quais emails estão cadastrados
    if (!user) {
      console.log(`❌ Email não encontrado: ${email}`)
      return NextResponse.json({
        success: true,
        message: 'Se o email existir em nosso sistema, você receberá um link de recuperação'
      })
    }

    // Gerar token aleatório
    console.log('🔵 [FORGOT-PASSWORD] Gerando token...')
    const token = crypto.randomBytes(32).toString('hex')
    console.log('🔵 [FORGOT-PASSWORD] Token gerado:', token.substring(0, 10) + '...')

    // Expiração em 1 hora
    const expiresAt = new Date()
    expiresAt.setHours(expiresAt.getHours() + 1)
    console.log('🔵 [FORGOT-PASSWORD] Expira em:', expiresAt)

    // Invalidar tokens antigos do usuário
    console.log('🔵 [FORGOT-PASSWORD] Invalidando tokens antigos...')
    await prisma.passwordResetToken.updateMany({
      where: {
        userId: user.id,
        used: false
      },
      data: { used: true }
    })

    // Criar novo token
    console.log('🔵 [FORGOT-PASSWORD] Criando novo token no banco...')
    await prisma.passwordResetToken.create({
      data: {
        userId: user.id,
        token,
        expiresAt
      }
    })
    console.log('✅ [FORGOT-PASSWORD] Token criado com sucesso')

    // URL de reset (ajustar conforme seu domínio)
    const resetUrl = `${process.env.NEXT_PUBLIC_APP_URL || 'http://localhost:3000'}/reset-password/${token}`

    console.log('📧 Token de reset gerado:', {
      email: user.email,
      resetUrl,
      expiresAt
    })

    // TODO: Enviar email (implementar configuração SMTP)
    // Por enquanto, apenas loga o link no console para desenvolvimento
    console.log('🔵 [FORGOT-PASSWORD] Enviando email...')
    try {
      await sendPasswordResetEmail(user.email, user.name, resetUrl)
      console.log('✅ [FORGOT-PASSWORD] Email enviado com sucesso para:', user.email)
    } catch (emailError) {
      console.error('⚠️ [FORGOT-PASSWORD] Erro ao enviar email (link gerado):', emailError)
      // Não falhar a requisição se o email não for enviado
      // O link ainda foi gerado e pode ser usado
    }

    console.log('✅ [FORGOT-PASSWORD] Processo concluído com sucesso')
    return NextResponse.json({
      success: true,
      message: 'Se o email existir em nosso sistema, você receberá um link de recuperação',
      // Em desenvolvimento, retornar o link para facilitar testes
      ...(process.env.NODE_ENV === 'development' && { resetUrl })
    })

  } catch (error) {
    console.error('❌ [FORGOT-PASSWORD] ERRO FATAL:', error)
    console.error('❌ [FORGOT-PASSWORD] Stack trace:', (error as Error).stack)
    return NextResponse.json({
      success: false,
      message: 'Erro ao processar solicitação'
    }, { status: 500 })
  }
}

// Função helper para enviar email
async function sendPasswordResetEmail(email: string, name: string, resetUrl: string) {
  const resendApiKey = process.env.RESEND_API_KEY
  const emailFrom = process.env.EMAIL_FROM || 'onboarding@resend.dev'

  // Se Resend estiver configurado, enviar email real
  if (resendApiKey) {
    try {
      const resend = new Resend(resendApiKey)

      await resend.emails.send({
        from: emailFrom,
        to: email,
        subject: 'Recuperação de Senha - Sistema Jurídico',
        html: `
          <!DOCTYPE html>
          <html>
            <head>
              <meta charset="utf-8">
              <style>
                body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
                .container { max-width: 600px; margin: 0 auto; padding: 20px; }
                .header { background: linear-gradient(135deg, #1e3a8a 0%, #1e40af 100%); color: white; padding: 30px; text-align: center; border-radius: 10px 10px 0 0; }
                .content { background: #f9fafb; padding: 30px; border-radius: 0 0 10px 10px; }
                .button { display: inline-block; padding: 15px 30px; background: #1e40af; color: white; text-decoration: none; border-radius: 5px; margin: 20px 0; }
                .footer { text-align: center; margin-top: 30px; color: #6b7280; font-size: 12px; }
                .warning { background: #fef3c7; border-left: 4px solid #f59e0b; padding: 15px; margin: 20px 0; }
              </style>
            </head>
            <body>
              <div class="container">
                <div class="header">
                  <h1>Recuperação de Senha</h1>
                </div>
                <div class="content">
                  <p>Olá <strong>${name}</strong>,</p>

                  <p>Recebemos uma solicitação para redefinir a senha da sua conta no Sistema Jurídico.</p>

                  <p>Clique no botão abaixo para criar uma nova senha:</p>

                  <div style="text-align: center;">
                    <a href="${resetUrl}" class="button">Redefinir Senha</a>
                  </div>

                  <p>Ou copie e cole este link no seu navegador:</p>
                  <p style="background: white; padding: 10px; border-radius: 5px; word-break: break-all; font-size: 12px;">
                    ${resetUrl}
                  </p>

                  <div class="warning">
                    <strong>⏱️ Este link expira em 1 hora.</strong>
                  </div>

                  <p>Se você não solicitou a recuperação de senha, ignore este email. Sua senha permanecerá inalterada.</p>

                  <p>Atenciosamente,<br>Equipe Sistema Jurídico</p>
                </div>
                <div class="footer">
                  <p>Este é um email automático. Por favor, não responda.</p>
                  <p>&copy; ${new Date().getFullYear()} Sistema Jurídico. Todos os direitos reservados.</p>
                </div>
              </div>
            </body>
          </html>
        `
      })

      console.log('✅ Email enviado com sucesso via Resend para:', email)
      return
    } catch (error) {
      console.error('❌ Erro ao enviar email via Resend:', error)
      throw error
    }
  }

  // Fallback: apenas log no console (desenvolvimento sem Resend)
  console.log(`
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    📧 EMAIL DE RECUPERAÇÃO DE SENHA
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    Para: ${email}
    Nome: ${name}

    Link de recuperação:
    ${resetUrl}

    Este link expira em 1 hora.
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  `)

  console.warn('⚠️ AVISO: RESEND_API_KEY não configurado. Email não foi enviado.')
}
