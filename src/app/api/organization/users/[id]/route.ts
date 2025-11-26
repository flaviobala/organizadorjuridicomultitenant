// src/app/api/organization/users/[id]/route.ts
import { NextRequest, NextResponse } from 'next/server'
import { requireAuth } from '@/lib/auth'
import { prisma } from '@/lib/prisma'

/**
 * DELETE /api/organization/users/[id]
 * Exclui um usuário da organização
 * Apenas super_admin e admin podem excluir usuários
 */
export async function DELETE(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    const auth = await requireAuth(request)
    if (!auth.success || !auth.user) {
      return NextResponse.json({ error: auth.error }, { status: 401 })
    }

    // Verificar se é admin ou super_admin
    if (auth.user.role !== 'admin' && auth.user.role !== 'super_admin') {
      return NextResponse.json({
        error: 'Acesso negado: apenas administradores podem excluir usuários'
      }, { status: 403 })
    }

    const userId = parseInt(params.id)

    if (isNaN(userId)) {
      return NextResponse.json({
        error: 'ID de usuário inválido'
      }, { status: 400 })
    }

    // Buscar o usuário para validações
    const userToDelete = await prisma.user.findUnique({
      where: { id: userId },
      include: {
        organization: true
      }
    })

    if (!userToDelete) {
      return NextResponse.json({
        error: 'Usuário não encontrado'
      }, { status: 404 })
    }

    // Validação 1: Admin só pode excluir usuários da própria organização
    if (auth.user.role === 'admin' && userToDelete.organizationId !== auth.user.organizationId) {
      return NextResponse.json({
        error: 'Você só pode excluir usuários da sua organização'
      }, { status: 403 })
    }

    // Validação 2: Não pode excluir super_admin
    if (userToDelete.role === 'super_admin') {
      return NextResponse.json({
        error: 'Não é possível excluir super administradores'
      }, { status: 403 })
    }

    // Validação 3: Não pode excluir a si mesmo
    if (userToDelete.id === auth.user.id) {
      return NextResponse.json({
        error: 'Você não pode excluir sua própria conta'
      }, { status: 400 })
    }

    // Validação 4: Verificar se é o único admin da organização
    if (userToDelete.role === 'admin') {
      const adminCount = await prisma.user.count({
        where: {
          organizationId: userToDelete.organizationId,
          role: 'admin'
        }
      })

      if (adminCount === 1) {
        return NextResponse.json({
          error: 'Não é possível excluir o único administrador da organização. Promova outro usuário a admin primeiro.'
        }, { status: 400 })
      }
    }

    // Excluir o usuário
    await prisma.user.delete({
      where: { id: userId }
    })

    console.log(`✅ Usuário excluído: ${userToDelete.email} (ID: ${userId}) da organização ${userToDelete.organization.name}`)

    return NextResponse.json({
      success: true,
      message: 'Usuário excluído com sucesso'
    })

  } catch (error) {
    console.error('❌ Erro ao excluir usuário:', error)
    return NextResponse.json({
      error: 'Erro interno do servidor'
    }, { status: 500 })
  }
}