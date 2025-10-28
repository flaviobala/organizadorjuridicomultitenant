// src/app/api/document-types/route.ts
import { NextRequest, NextResponse } from 'next/server'
import { requireAuth } from '@/lib/auth'
import { prisma } from '@/lib/prisma'

export async function GET(request: NextRequest) {
  try {
    const auth = await requireAuth(request)
    if (!auth.success || !auth.user) {
      return NextResponse.json({ error: auth.error }, { status: 401 })
    }

    const documentTypes = await prisma.documentType.findMany({
      orderBy: { order: 'asc' }
    })

    return NextResponse.json({
      success: true,
      documentTypes: documentTypes.map(type => ({
        code: type.code,
        name: type.name,
        description: type.description,
        isRequired: type.isRequired,
        order: type.order
      }))
    })

  } catch (error) {
    console.error('Erro ao buscar tipos de documentos:', error)
    return NextResponse.json({
      success: false,
      error: 'Erro interno do servidor'
    }, { status: 500 })
  }
}