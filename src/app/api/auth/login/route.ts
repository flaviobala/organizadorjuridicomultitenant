// src/app/api/auth/login/route.ts
import { NextRequest, NextResponse } from 'next/server'
import { loginUser } from '@/lib/auth'
import { z } from 'zod'

const loginSchema = z.object({
  email: z.string().email('Email inválido'),
  password: z.string().min(1, 'Senha é obrigatória'),
})

export async function POST(request: NextRequest) {
  try {
    const body = await request.json()
    
    console.log('🔍 DEBUG LOGIN - Dados recebidos:', body)
    
    // Validar dados de entrada
    const validation = loginSchema.safeParse(body)
    if (!validation.success) {
      console.log('❌ Validação falhou:', validation.error.errors)
      return NextResponse.json({
        success: false,
        message: 'Dados inválidos',
        errors: validation.error.errors,
        debug: { receivedData: body }
      }, { status: 400 })
    }

    console.log('✅ Validação passou, tentando login...')
    const { email, password } = validation.data

    // Fazer login
    const result = await loginUser(email, password)
    
    console.log('📊 Resultado do login:', { 
      success: result.success, 
      message: result.message,
      hasUser: !!result.user,
      hasToken: !!result.token 
    })

    if (!result.success) {
      return NextResponse.json(result, { status: 401 })
    }

    return NextResponse.json(result, { status: 200 })

  } catch (error) {
    console.error('❌ Erro na API de login:', error)
    return NextResponse.json({
      success: false,
      message: 'Erro interno do servidor',
      debug: error instanceof Error ? error.message : 'Erro desconhecido'
    }, { status: 500 })
  }
}