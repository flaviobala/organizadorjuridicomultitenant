'use client'

import { useState, useEffect } from 'react'
import { useRouter } from 'next/navigation'

// VALORES DE TESTE - Mudar para valores reais em produção
const PLANS = [
  {
    id: 'basic',
    name: 'Basic',
    price: 'R$ 1',
    period: '/mês (TESTE)',
    paymentMethods: 'Pix, Boleto ou Cartão',
    features: [
      '500 documentos/mês',
      '1M tokens IA/mês',
      'Até 5 usuários',
      'Processamento básico',
      'Categorização IA',
      'Upload em lote',
      '7 dias de teste grátis',
    ],
    highlighted: false,
  },
  {
    id: 'pro',
    name: 'Pro',
    price: 'R$ 2',
    period: '/mês (TESTE)',
    paymentMethods: 'Pix, Boleto ou Cartão',
    features: [
      '5.000 documentos/mês',
      '10M tokens IA/mês',
      'Até 20 usuários',
      'Tudo do Basic +',
      'IA Avançada',
      'Suporte prioritário',
      '7 dias de teste grátis',
    ],
    highlighted: true,
  },
  {
    id: 'enterprise',
    name: 'Enterprise',
    price: 'R$ 3',
    period: '/mês (TESTE)',
    paymentMethods: 'Pix, Boleto ou Cartão',
    features: [
      'Documentos ilimitados',
      'Tokens ilimitados',
      'Usuários ilimitados',
      'Tudo do Pro +',
      'Integração customizada',
      'Suporte dedicado',
      '7 dias de teste grátis',
    ],
    highlighted: false,
  },
]

export default function PricingPage() {
  const router = useRouter()
  const [loading, setLoading] = useState<string | null>(null)

  useEffect(() => {
    // Verificar se está logado
    const token = localStorage.getItem('token')
    if (!token) {
      router.push('/login')
    }
  }, [router])

  const handleSelectPlan = async (planId: string) => {
    if (planId === 'enterprise') {
      // Para enterprise, redirecionar para contato
      alert('Entre em contato conosco para um plano Enterprise personalizado!')
      return
    }

    setLoading(planId)

    try {
      const token = localStorage.getItem('token')
      if (!token) {
        router.push('/login')
        return
      }

      const response = await fetch('/api/billing/mercadopago/create-subscription', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${token}`
        },
        body: JSON.stringify({ planType: planId })
      })

      const data = await response.json()

      if (!response.ok) {
        alert(data.error || 'Erro ao criar assinatura')
        return
      }

      // Redirecionar para checkout do Mercado Pago
      if (data.checkoutUrl) {
        window.location.href = data.checkoutUrl
      }
    } catch (error) {
      console.error('Erro:', error)
      alert('Erro ao processar pagamento')
    } finally {
      setLoading(null)
    }
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100 py-12 px-4">
      <div className="max-w-7xl mx-auto">
        {/* Header */}
        <div className="text-center mb-12">
          <h1 className="text-4xl font-bold text-gray-900 mb-4">
            Escolha o plano ideal para seu escritório
          </h1>
          <p className="text-xl text-gray-600">
            Gerencie documentos jurídicos com inteligência artificial
          </p>
        </div>

        {/* Plans Grid */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
          {PLANS.map((plan) => (
            <div
              key={plan.id}
              className={`bg-white rounded-lg shadow-lg overflow-hidden transition-transform hover:scale-105 ${
                plan.highlighted ? 'ring-4 ring-blue-500' : ''
              }`}
            >
              {plan.highlighted && (
                <div className="bg-blue-500 text-white text-center py-2 text-sm font-semibold">
                  MAIS POPULAR
                </div>
              )}

              <div className="p-8">
                <h3 className="text-2xl font-bold text-gray-900 mb-2">{plan.name}</h3>
                <div className="mb-2">
                  <span className="text-4xl font-bold text-gray-900">{plan.price}</span>
                  {plan.period && <span className="text-gray-600">{plan.period}</span>}
                </div>
                <p className="text-sm text-gray-500 mb-6">{plan.paymentMethods}</p>

                <ul className="space-y-4 mb-8">
                  {plan.features.map((feature, idx) => (
                    <li key={idx} className="flex items-start">
                      <svg className="w-5 h-5 text-green-500 mr-2 mt-0.5 flex-shrink-0" fill="currentColor" viewBox="0 0 20 20">
                        <path fillRule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clipRule="evenodd" />
                      </svg>
                      <span className="text-gray-700">{feature}</span>
                    </li>
                  ))}
                </ul>

                <button
                  onClick={() => handleSelectPlan(plan.id)}
                  disabled={loading === plan.id}
                  className={`w-full py-3 px-6 rounded-lg font-semibold transition-colors ${
                    plan.highlighted
                      ? 'bg-blue-600 text-white hover:bg-blue-700'
                      : 'bg-gray-100 text-gray-900 hover:bg-gray-200'
                  } disabled:opacity-50 disabled:cursor-not-allowed`}
                >
                  {loading === plan.id ? (
                    <span className="flex items-center justify-center">
                      <svg className="animate-spin -ml-1 mr-3 h-5 w-5 text-current" fill="none" viewBox="0 0 24 24">
                        <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
                        <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                      </svg>
                      Processando...
                    </span>
                  ) : plan.id === 'enterprise' ? (
                    'Fale conosco'
                  ) : (
                    'Assinar agora'
                  )}
                </button>
              </div>
            </div>
          ))}
        </div>

        {/* Back to Dashboard */}
        <div className="text-center mt-12">
          <button
            onClick={() => router.push('/dashboard')}
            className="text-blue-600 hover:text-blue-700 font-medium"
          >
            ← Voltar ao Dashboard
          </button>
        </div>
      </div>
    </div>
  )
}
