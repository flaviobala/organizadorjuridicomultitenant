'use client'
import { useEffect, useState } from 'react'
import { useRouter } from 'next/navigation'
import { CheckCircle, Loader2 } from 'lucide-react'

export default function PaymentSuccessPage() {
  const router = useRouter()
  const [processing, setProcessing] = useState(true)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    processPayment()
  }, [])

  const processPayment = async () => {
    try {
      const pendingPayment = localStorage.getItem('pending_payment')

      if (!pendingPayment) {
        setError('Nenhum pagamento pendente encontrado')
        setProcessing(false)
        return
      }

      const { plan, subscriptionId } = JSON.parse(pendingPayment)
      const token = localStorage.getItem('token')
      const userData = localStorage.getItem('user')

      if (!token || !userData) {
        router.push('/login')
        return
      }

      const user = JSON.parse(userData)

      // Processar pagamento - buscar status real no MP antes de atualizar
      const response = await fetch(`/api/billing/mercadopago/process-return?organizationId=${user.organizationId}&plan=${plan}&subscriptionId=${subscriptionId}`, {
        headers: {
          'Authorization': `Bearer ${token}`
        }
      })

      if (response.ok) {
        // Limpar localStorage
        localStorage.removeItem('pending_payment')

        // Aguardar 2 segundos e redirecionar
        setTimeout(() => {
          router.push('/dashboard')
        }, 2000)
      } else {
        setError('Erro ao processar pagamento')
        setProcessing(false)
      }

    } catch (err) {
      console.error('Erro ao processar:', err)
      setError('Erro ao processar pagamento')
      setProcessing(false)
    }
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-green-50 to-blue-50 flex items-center justify-center p-4">
      <div className="bg-white rounded-lg shadow-xl p-8 max-w-md w-full text-center">
        {processing ? (
          <>
            <div className="mb-6">
              <div className="inline-flex items-center justify-center w-16 h-16 bg-green-100 rounded-full mb-4">
                <Loader2 className="w-8 h-8 text-green-600 animate-spin" />
              </div>
              <h1 className="text-2xl font-bold text-gray-900 mb-2">
                Processando seu pagamento...
              </h1>
              <p className="text-gray-600">
                Aguarde enquanto confirmamos sua assinatura
              </p>
            </div>
          </>
        ) : error ? (
          <>
            <h1 className="text-2xl font-bold text-red-600 mb-4">
              Erro ao processar
            </h1>
            <p className="text-gray-600 mb-6">{error}</p>
            <button
              onClick={() => router.push('/dashboard')}
              className="bg-blue-600 hover:bg-blue-700 text-white font-medium py-2 px-6 rounded-lg transition-colors"
            >
              Voltar ao Dashboard
            </button>
          </>
        ) : (
          <>
            <div className="mb-6">
              <div className="inline-flex items-center justify-center w-16 h-16 bg-green-100 rounded-full mb-4">
                <CheckCircle className="w-8 h-8 text-green-600" />
              </div>
              <h1 className="text-2xl font-bold text-gray-900 mb-2">
                Pagamento confirmado!
              </h1>
              <p className="text-gray-600">
                Sua assinatura foi ativada com sucesso
              </p>
            </div>
          </>
        )}
      </div>
    </div>
  )
}
