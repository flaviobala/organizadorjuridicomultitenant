import { NextRequest, NextResponse } from 'next/server'
import { prisma } from '@/lib/prisma'
import bcrypt from 'bcryptjs'

export async function POST(request: NextRequest) {
  try {
    const { token, password } = await request.json()

    if (!token || !password) {
      return NextResponse.json({
        success: false,
        message: 'Token e senha são obrigatórios'
      }, { status: 400 })
    }

    // Validar senha
    if (password.length < 6) {
      return NextResponse.json({
        success: false,
        message: 'A senha deve ter no mínimo 6 caracteres'
      }, { status: 400 })
    }

    // Buscar token no banco
    const resetToken = await prisma.passwordResetToken.findUnique({
      where: { token },
      include: { user: true }
    })

    // Validar token
    if (!resetToken) {
      return NextResponse.json({
        success: false,
        message: 'Token inválido ou expirado'
      }, { status: 400 })
    }

    if (resetToken.used) {
      return NextResponse.json({
        success: false,
        message: 'Este token já foi utilizado'
      }, { status: 400 })
    }

    if (new Date() > resetToken.expiresAt) {
      return NextResponse.json({
        success: false,
        message: 'Token expirado. Solicite um novo link de recuperação'
      }, { status: 400 })
    }

    // Hash da nova senha
    const hashedPassword = await bcrypt.hash(password, 10)

    // Atualizar senha do usuário e marcar token como usado
    await prisma.$transaction([
      prisma.user.update({
        where: { id: resetToken.userId },
        data: { password: hashedPassword }
      }),
      prisma.passwordResetToken.update({
        where: { id: resetToken.id },
        data: { used: true }
      })
    ])

    console.log('✅ Senha alterada com sucesso:', resetToken.user.email)

    return NextResponse.json({
      success: true,
      message: 'Senha alterada com sucesso! Você já pode fazer login com a nova senha'
    })

  } catch (error) {
    console.error('❌ Erro no reset-password:', error)
    return NextResponse.json({
      success: false,
      message: 'Erro ao processar solicitação'
    }, { status: 500 })
  }
}
