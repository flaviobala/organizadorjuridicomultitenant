// Endpoint de teste para validar OpenAI API Key
import { NextResponse } from 'next/server'
import OpenAI from 'openai'

export async function GET() {
  try {
    console.log('🧪 [TEST] Testando conexão com OpenAI...')

    // Verificar se a chave está configurada
    const apiKey = process.env.OPENAI_API_KEY
    if (!apiKey) {
      console.error('❌ [TEST] OPENAI_API_KEY não configurada!')
      return NextResponse.json({
        success: false,
        error: 'OPENAI_API_KEY não configurada no ambiente',
        configured: false
      }, { status: 500 })
    }

    console.log(`✅ [TEST] API Key encontrada: ${apiKey.substring(0, 20)}...`)

    // Inicializar cliente
    const openai = new OpenAI({
      apiKey: apiKey
    })

    // Fazer uma chamada simples de teste
    console.log('🚀 [TEST] Fazendo chamada de teste ao GPT-4o-mini...')

    const response = await openai.chat.completions.create({
      model: "gpt-4o-mini",
      messages: [
        {
          role: "user",
          content: "Diga apenas 'OK' se você está funcionando."
        }
      ],
      max_tokens: 10,
      temperature: 0
    })

    const result = response.choices[0]?.message?.content || ''

    console.log('✅ [TEST] Resposta recebida:', result)
    console.log('✅ [TEST] Tokens usados:', response.usage)

    return NextResponse.json({
      success: true,
      message: 'OpenAI está funcionando corretamente!',
      configured: true,
      response: result,
      model: response.model,
      usage: response.usage
    })

  } catch (error) {
    console.error('❌ [TEST] ===== ERRO NO TESTE DO OPENAI =====')
    console.error('Tipo:', typeof error)
    console.error('Erro completo:', error)

    if (error instanceof Error) {
      console.error('Mensagem:', error.message)
      console.error('Stack:', error.stack)
    }

    // Se for erro da API OpenAI
    if (error && typeof error === 'object' && 'status' in error) {
      const apiError = error as any
      console.error('Status HTTP:', apiError.status)
      console.error('Código:', apiError.code)
      console.error('Tipo:', apiError.type)
      console.error('Mensagem API:', apiError.message)

      return NextResponse.json({
        success: false,
        error: apiError.message || 'Erro na API OpenAI',
        status: apiError.status,
        code: apiError.code,
        type: apiError.type,
        configured: true
      }, { status: 500 })
    }

    return NextResponse.json({
      success: false,
      error: error instanceof Error ? error.message : 'Erro desconhecido',
      configured: true
    }, { status: 500 })
  }
}
