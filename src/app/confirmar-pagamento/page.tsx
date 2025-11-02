 'use client'

 // src/app/confirmar-pagamento/page.tsx
'use client'

import { useState, useEffect, useCallback } from 'react'
import { useRouter } from 'next/navigation'

// Interfaces de estado para a UI
type PaymentStatus = 'loading' | 'success' | 'error'

export default function ConfirmarPagamentoPage() {
  const router = useRouter()
  
  // Estado para controlar a UI (Carregando, Sucesso, Falha)
  const [status, setStatus] = useState<PaymentStatus>('loading')
  
  // Estado para armazenar mensagens de erro ou nomes de plano
  const [planName, setPlanName] = useState<string>('')
  const [errorDetails, setErrorDetails] = useState<string>('')

  // Função de verificação (usada no 'useEffect' e no 'Tentar Novamente')
  const verifyPayment = useCallback(async () => {
    setStatus('loading')
    setErrorDetails('')
    
    try {
      // 1. Obter token de autenticação
      const token = localStorage.getItem('token')
      if (!token) {
        throw new Error('Usuário não autenticado. Faça login novamente.')
      }

      // 2. Obter dados do pagamento pendente
      const paymentInfoRaw = localStorage.getItem('pending_payment')
      if (!paymentInfoRaw) {
        throw new Error('Nenhuma informação de pagamento pendente encontrada.')
      }

      const paymentInfo = JSON.parse(paymentInfoRaw)
      const { plan, subscriptionId } = paymentInfo

      // Define um nome de plano provisório caso a API falhe
      setPlanName(plan || 'desconhecido') 

      // 3. Chamar a API de backend para verificar o status da assinatura
      //    Flavio: Esta API (check-subscription) precisa ser criada.
      const response = await fetch('/api/billing/mercadopago/check-subscription', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${token}`
        },
        body: JSON.stringify({ 
          subscriptionId: subscriptionId // ID da assinatura/preapproval do MercadoPago
        })
      })

      const data = await response.json()

      if (!response.ok) {
        // A API falhou (4xx, 5xx)
        throw new Error(data.error || 'Erro ao verificar assinatura.')
      }

      // 4. A API retornou sucesso (200 OK)
      if (data.success) {
        // Estado de Sucesso
        setStatus('success')
        setPlanName(data.planName || plan)
        // Limpa o localStorage pois o pagamento foi confirmado
        localStorage.removeItem('pending_payment')
      } else {
        // Estado de Falha (Ex: Pagamento pendente, recusado)
        // A API retornou 200, mas o status do pagamento não é 'active'
        throw new Error(data.error || 'Pagamento ainda não confirmado.')
      }

    } catch (e) {
      // Estado de Falha (Erro de rede, API, etc.)
      setStatus('error')
      setErrorDetails(e instanceof Error ? e.message : 'Erro desconhecido')
    }
  }, []) // 'useCallback' sem dependências, pois 'router' é estável

  // Efeito para rodar a verificação assim que a página carrega
  useEffect(() => {
    verifyPayment()
  }, [verifyPayment]) // Roda a função de verificação no mount

  // === RENDERIZAÇÃO DOS 3 ESTADOS (Conforme Wireframe) ===

  const renderLoadingState = () => (
    <>
      <SpinnerIcon className="mx-auto h-12 w-12 text-blue-600 animate-spin" />
      <h2 className="mt-4 text-center text-2xl font-bold text-gray-900">
        Verificando seu pagamento...
      </h2>
      <p className="mt-2 text-center text-md text-gray-600">
        Estamos confirmando sua assinatura com o MercadoPago. Isso pode levar alguns segundos, por favor, não feche esta janela.
      </p>
    </>
  )

  const renderSuccessState = () => (
    <>
      <CheckIcon className="mx-auto h-12 w-12 text-green-500" />
      <h2 className="mt-4 text-center text-2xl font-bold text-gray-900">
        Assinatura Ativada!
      </h2>
      <p className="mt-2 text-center text-md text-gray-600">
        Seu plano <span className="font-semibold">{planName}</span> foi ativado com sucesso. Você já pode acessar todos os recursos.
      </p>
      <button
        onClick={() => router.push('/dashboard')}
        className="w-full mt-6 bg-blue-600 text-white py-3 rounded-lg font-semibold hover:bg-blue-700 transition-colors"
      >
        Ir para o Dashboard
      </button>
    </>
  )

  const renderErrorState = () => (
    <>
      <ErrorIcon className="mx-auto h-12 w-12 text-red-500" />
      <h2 className="mt-4 text-center text-2xl font-bold text-gray-900">
        Pagamento não confirmado
      </h2>
      <p className="mt-2 text-center text-md text-gray-600">
        {errorDetails || "Ainda não recebemos a confirmação do seu pagamento. Se você pagou via boleto, pode levar até 1 dia útil. Se foi via Pix ou Cartão, tente novamente em alguns minutos."}
      </p>
      <div className="mt-6 space-y-3">
        <button
          onClick={verifyPayment}
          disabled={status === 'loading'}
          className="w-full bg-white border border-gray-300 py-3 rounded-lg font-semibold text-gray-700 hover:bg-gray-50 transition-colors disabled:opacity-50"
        >
          Tentar verificar novamente
        </button>
        <button
          onClick={() => router.push('/dashboard')}
          className="block w-full text-center text-sm text-blue-600 hover:text-blue-700"
        >
          Voltar para o Dashboard
        </button>
      </div>
    </>
  )

  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-50 py-12 px-4">
      <div className="max-w-md w-full bg-white shadow-xl rounded-lg p-8 md:p-10">
        {status === 'loading' && renderLoadingState()}
        {status === 'success' && renderSuccessState()}
        {status === 'error' && renderErrorState()}
      </div>
    </div>
  )
}

// === ÍCONES SVG (Conforme Wireframe) ===

function SpinnerIcon(props: React.ComponentProps<'svg'>) {
  return (
    <svg fill="none" viewBox="0 0 24 24" {...props}>
      <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
      <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
    </svg>
  )
}

function CheckIcon(props: React.ComponentProps<'svg'>) {
  return (
    <svg fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2} {...props}>
      <path strokeLinecap="round" strokeLinejoin="round" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
    </svg>
  )
}

function ErrorIcon(props: React.ComponentProps<'svg'>) {
  return (
    <svg fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2} {...props}>
      <path strokeLinecap="round" strokeLinejoin="round" d="M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2m7-2a9 9 0 11-18 0 9 9 0 0118 0z" />
    </svg>
  )
}