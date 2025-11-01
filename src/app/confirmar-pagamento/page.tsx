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

// import { useEffect, useState } from 'react'
// import { useRouter } from 'next/navigation'
// import { CheckCircle, ArrowRight, Info, AlertCircle } from 'lucide-react'

// export default function ConfirmarPagamentoPage() {
//   const router = useRouter()
//   const [pendingPayment, setPendingPayment] = useState<any>(null)
//   const [isProcessing, setIsProcessing] = useState(false)

//   useEffect(() => {
//     const payment = localStorage.getItem('pending_payment')
//     if (payment) {
//       setPendingPayment(JSON.parse(payment))
//     }
//   }, [])

//   const handleConfirm = async () => {
//     if (!pendingPayment) {
//       alert('Nenhum pagamento pendente encontrado. Por favor, inicie o processo de assinatura novamente.')
//       router.push('/pricing')
//       return
//     }

//     setIsProcessing(true)

//     try {
//       // Simular um pequeno delay para UX
//       await new Promise(resolve => setTimeout(resolve, 1000))

//       // Redirecionar para a página de sucesso que processará o pagamento
//       router.push('/payment-success')
//     } catch (error) {
//       console.error('Erro ao processar:', error)
//       setIsProcessing(false)
//       alert('Ocorreu um erro. Por favor, tente novamente.')
//     }
//   }

//   return (
//     <div className="min-h-screen bg-gradient-to-br from-green-50 to-blue-50 flex items-center justify-center p-4">
//       <div className="bg-white rounded-lg shadow-xl p-8 max-w-md w-full">
//         <div className="text-center mb-6">
//           <div className="inline-flex items-center justify-center w-16 h-16 bg-green-100 rounded-full mb-4">
//             <CheckCircle className="w-8 h-8 text-green-600" />
//           </div>
//           <h1 className="text-2xl font-bold text-gray-900 mb-2">
//             Pagamento Aprovado!
//           </h1>
//           <p className="text-gray-600 mb-4">
//             Seu pagamento foi processado com sucesso no MercadoPago.
//           </p>
//           {pendingPayment && (
//             <div className="bg-blue-50 border border-blue-200 rounded-lg p-3 mb-4">
//               <p className="text-sm text-blue-800">
//                 <strong>Plano:</strong> {pendingPayment.plan?.toUpperCase()}
//               </p>
//               <p className="text-xs text-blue-600 mt-1">
//                 ID: {pendingPayment.subscriptionId}
//               </p>
//             </div>
//           )}
//         </div>

//         {!pendingPayment && (
//           <div className="bg-orange-50 border border-orange-200 rounded-lg p-4 mb-6">
//             <div className="flex items-start">
//               <AlertCircle className="w-5 h-5 text-orange-600 mr-3 flex-shrink-0 mt-0.5" />
//               <div>
//                 <p className="text-sm text-orange-800">
//                   Não foi possível identificar o pagamento. Você pode ter acessado esta página diretamente.
//                 </p>
//                 <p className="text-xs text-orange-700 mt-2">
//                   Se você acabou de fazer um pagamento, clique no botão abaixo mesmo assim para verificar.
//                 </p>
//               </div>
//             </div>
//           </div>
//         )}

//         <div className="bg-blue-50 border border-blue-200 rounded-lg p-4 mb-6">
//           <div className="flex items-start">
//             <Info className="w-5 h-5 text-blue-600 mr-3 flex-shrink-0 mt-0.5" />
//             <div>
//               <p className="text-sm text-blue-800 font-medium mb-2">
//                 Como usar esta página:
//               </p>
//               <ol className="text-sm text-blue-700 space-y-1 list-decimal list-inside">
//                 <li>Após concluir o pagamento no MercadoPago</li>
//                 <li>Acesse manualmente esta página</li>
//                 <li>Clique no botão abaixo para ativar sua assinatura</li>
//               </ol>
//             </div>
//           </div>
//         </div>

//         <div className="bg-yellow-50 border border-yellow-200 rounded-lg p-4 mb-6">
//           <p className="text-sm text-yellow-800">
//             <strong>Importante:</strong> Clique no botão abaixo para confirmar e ativar sua assinatura no sistema.
//           </p>
//         </div>

//         <button
//           onClick={handleConfirm}
//           disabled={isProcessing}
//           className="w-full bg-blue-600 hover:bg-blue-700 disabled:bg-blue-400 disabled:cursor-not-allowed text-white font-semibold py-3 px-6 rounded-lg transition-colors flex items-center justify-center"
//         >
//           {isProcessing ? (
//             <>
//               <svg className="animate-spin -ml-1 mr-3 h-5 w-5 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
//                 <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
//                 <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
//               </svg>
//               <span>Processando...</span>
//             </>
//           ) : (
//             <>
//               <span>Ativar Minha Assinatura</span>
//               <ArrowRight className="w-5 h-5 ml-2" />
//             </>
//           )}
//         </button>

//         <p className="text-xs text-gray-500 text-center mt-4">
//           Ao clicar, vamos verificar seu pagamento no MercadoPago e ativar seu plano automaticamente.
//         </p>

//         <div className="mt-6 pt-6 border-t border-gray-200">
//           <p className="text-xs text-gray-500 text-center">
//             URL desta página: <br />
//             <code className="bg-gray-100 px-2 py-1 rounded text-xs">
//               /confirmar-pagamento
//             </code>
//           </p>
//         </div>
//       </div>
//     </div>
//   )
// }
