import { NextRequest, NextResponse } from 'next/server'
import { PrismaClient } from '@prisma/client'
import { requireSuperAdmin } from '@/lib/auth'

const prisma = new PrismaClient()

// PATCH - Atualizar organização (nome e plano)
export async function PATCH(
  request: NextRequest,
  context: { params: Promise<{ id: string }> }
) {
  console.log('🔵 PATCH recebido para atualizar organização')

  const auth = await requireSuperAdmin(request)
  if (!auth.success) {
    console.log('❌ Auth falhou:', auth.error)
    return NextResponse.json({ error: auth.error }, { status: 403 })
  }

  try {
    const {
      name,
      planType,
      contactName,
      contactPhone,
      cnpj,
      address,
      city,
      state,
      zipCode
    } = await request.json()

    const params = await context.params
    const orgId = parseInt(params.id)

    console.log('📝 Dados recebidos:', { orgId, name, planType, contactName, contactPhone, cnpj })

    // Validar plano
    const validPlans = ['free', 'basic', 'advanced', 'complete']
    if (planType && !validPlans.includes(planType)) {
      return NextResponse.json({ error: 'Plano inválido' }, { status: 400 })
    }

    // Atualizar organização
    console.log('💾 Atualizando no banco...')
    const updatedOrg = await prisma.organization.update({
      where: { id: orgId },
      data: {
        ...(name && { name }),
        ...(planType && { planType }),
        ...(contactName !== undefined && { contactName: contactName || null }),
        ...(contactPhone !== undefined && { contactPhone: contactPhone || null }),
        ...(cnpj !== undefined && { cnpj: cnpj || null }),
        ...(address !== undefined && { address: address || null }),
        ...(city !== undefined && { city: city || null }),
        ...(state !== undefined && { state: state || null }),
        ...(zipCode !== undefined && { zipCode: zipCode || null })
      }
    })

    console.log('✅ Organização atualizada:', updatedOrg)

    return NextResponse.json({
      success: true,
      organization: updatedOrg
    })

  } catch (error) {
    console.error('Erro ao atualizar organização:', error)
    return NextResponse.json({
      error: 'Erro ao atualizar organização'
    }, { status: 500 })
  } finally {
    await prisma.$disconnect()
  }
}
