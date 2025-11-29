// src/app/api/billing/asaas/create-customer/route.ts
import { NextRequest, NextResponse } from 'next/server'
import { requireAuth } from '@/lib/auth'
import { prisma } from '@/lib/prisma'
import axios from 'axios'

/**
 * POST /api/billing/asaas/create-customer
 * Cria um cliente no Asaas (necessário antes de criar assinatura)
 */
export async function POST(request: NextRequest) {
  try {
    const auth = await requireAuth(request)
    if (!auth.success || !auth.user) {
      return NextResponse.json({ error: auth.error }, { status: 401 })
    }

    // Buscar organização e usuário
    const organization = await prisma.organization.findUnique({
      where: { id: auth.user.organizationId },
      include: {
        users: {
          where: { role: 'admin' },
          take: 1
        }
      }
    })

    if (!organization) {
      return NextResponse.json({
        success: false,
        error: 'Organização não encontrada'
      }, { status: 404 })
    }

    const adminUser = organization.users[0] || auth.user

    console.log('📝 [ASAAS] Criando cliente:', {
      organizationId: organization.id,
      name: organization.name,
      email: adminUser.email
    })

    // Verificar se já tem customer no Asaas
    if (organization.asaasCustomerId) {
      console.log('✅ [ASAAS] Cliente já existe:', organization.asaasCustomerId)
      return NextResponse.json({
        success: true,
        customerId: organization.asaasCustomerId,
        message: 'Cliente já existe'
      })
    }

    // Criar cliente no Asaas
    const apiKey = process.env.ASAAS_API_KEY
    if (!apiKey) {
      throw new Error('ASAAS_API_KEY não configurada')
    }

    const asaasResponse = await axios.post('https://www.asaas.com/api/v3/customers', {
      name: organization.name,
      email: adminUser.email,
      phone: organization.contactPhone?.replace(/\D/g, '') || undefined,
      cpfCnpj: organization.cnpj?.replace(/\D/g, '') || undefined,
      postalCode: organization.zipCode?.replace(/\D/g, '') || undefined,
      address: organization.address || undefined,
      addressNumber: undefined, // Extrair do address se necessário
      province: organization.city || undefined,
      externalReference: organization.id.toString(),
      notificationDisabled: false
    }, {
      headers: {
        'access_token': apiKey,
        'Content-Type': 'application/json'
      }
    })

    const customerData = asaasResponse.data
    console.log('✅ [ASAAS] Cliente criado:', customerData.id)

    // Salvar ID do cliente no banco
    await prisma.organization.update({
      where: { id: organization.id },
      data: {
        asaasCustomerId: customerData.id
      }
    })

    return NextResponse.json({
      success: true,
      customerId: customerData.id,
      message: 'Cliente criado com sucesso'
    })

  } catch (error) {
    console.error('❌ [ASAAS] Erro ao criar cliente:', error)
    return NextResponse.json({
      success: false,
      error: error instanceof Error ? error.message : 'Erro interno do servidor'
    }, { status: 500 })
  }
}
