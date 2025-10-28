// src/app/api/auth/make-admin/route.ts
// ⚠️ ROTA TEMPORÁRIA PARA DESENVOLVIMENTO
// DELETE ESTA ROTA EM PRODUÇÃO!

import { NextRequest, NextResponse } from 'next/server'
import { requireAuth } from '@/lib/auth'
import { prisma } from '@/lib/prisma'

/**
 * POST /api/auth/make-admin
 * Torna o usuário logado admin (apenas para desenvolvimento)
 */
export async function POST(request: NextRequest) {
  try {
    const auth = await requireAuth(request)
    if (!auth.success || !auth.user) {
      return NextResponse.json({ error: auth.error }, { status: 401 })
    }

    // Atualizar usuário para admin
    await prisma.user.update({
      where: { id: auth.user.id },
      data: { role: 'admin' }
    })

    return NextResponse.json({
      success: true,
      message: 'Você agora é admin! Faça logout e login novamente para o token ser atualizado.',
      user: {
        id: auth.user.id,
        email: auth.user.email,
        name: auth.user.name,
        role: 'admin'
      }
    })

  } catch (error) {
    console.error('❌ Erro ao tornar admin:', error)
    return NextResponse.json({
      success: false,
      error: error instanceof Error ? error.message : 'Erro interno do servidor'
    }, { status: 500 })
  }
}
