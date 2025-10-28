//src/app/api/auth/register/route.ts
import { NextRequest, NextResponse } from 'next/server'
import { registerUser } from '@/lib/auth'
import { z } from 'zod'

const registerSchema = z.object({
  email: z.string().email('Email inválido'),
  password: z.string().min(6, 'Senha deve ter pelo menos 6 caracteres'),
  name: z.string().min(2, 'Nome deve ter pelo menos 2 caracteres'),
})

export async function POST(request: NextRequest) {
  try {
    const body = await request.json()
    
    // Validar dados de entrada
    const validation = registerSchema.safeParse(body)
    if (!validation.success) {
      return NextResponse.json({
        success: false,
        message: 'Dados inválidos',
        errors: validation.error.errors
      }, { status: 400 })
    }

    const { email, password, name } = validation.data

    // Registrar usuário
    const result = await registerUser(email, password, name)

    if (!result.success) {
      return NextResponse.json(result, { status: 400 })
    }

    return NextResponse.json(result, { status: 201 })

  } catch (error) {
    console.error('Erro na API de registro:', error)
    return NextResponse.json({
      success: false,
      message: 'Erro interno do servidor'
    }, { status: 500 })
  }
}