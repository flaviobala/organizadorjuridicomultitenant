'use client'

import { FaCheck } from 'react-icons/fa'
import Link from 'next/link'
import { useState } from 'react'
import { useRouter } from 'next/navigation'

export default function PricingSection() {
  const router = useRouter()
  const [loading, setLoading] = useState<string | null>(null)
  const plans = [
    {
      id: 'basic',
      name: 'Plano Básico',
      price: 'R$ 34,90',
      period: '/mês',
      paymentMethods: 'Pix ou Cartão',
      features: [
        '300 documentos por mês',
        'Narrativas ilimitadas',
        'Agrupamento automático',
        'Exportação automática com arquivos prontos para protocolo',
        'Renomeação inteligente dos arquivos',
        'ZIP automático dentro dos limites de cada tribunal (PJe, PJe2x, e-SAJ, PROJUDI etc.)',
        'OCR otimizado',
        'Checklist inteligente de documentos',
        '1 usuário',
        'Suporte interno pelo sistema (chat + tickets + base de conhecimento)',
      ],
      highlighted: false,
    },
    {
      id: 'advanced',
      name: 'Plano Avançado',
      price: 'R$ 69,90',
      period: '/mês',
      paymentMethods: 'Pix ou Cartão',
      features: [
        '600 documentos por mês',
        'Narrativas ilimitadas',
        'Agrupamento automático',
        'Exportação automática com arquivos prontos para protocolo',
        'Renomeação inteligente dos arquivos',
        'Geração de ZIP conforme limites de cada tribunal (PJe, PJe2x, e-SAJ, PROJUDI etc.)',
        'OCR otimizado',
        'Painel de uso detalhado',
        'Checklist inteligente',
        'Validação de pertinência temática em até 300 documentos por mês',
        '3 usuários',
        'Suporte interno dentro do sistema (chat, tickets e central de ajuda)',
      ],
      highlighted: true,
    },
    {
      id: 'complete',
      name: 'Plano Completo',
      price: 'R$ 99,90',
      period: '/mês',
      paymentMethods: 'Pix ou Cartão',
      features: [
        '1.200 documentos por mês',
        'Narrativas ilimitadas',
        'Agrupamento automático',
        'Exportação automática com arquivos prontos para protocolo',
        'Renomeação inteligente dos arquivos',
        'Geração de ZIP conforme limites de cada tribunal (PJe, PJe2x, e-SAJ, PROJUDI etc.)',
        'OCR otimizado',
        'Painel de uso detalhado',
        'Checklist inteligente',
        'Validação de pertinência temática em TODOS os documentos enviados',
        '5 usuários',
        'Suporte interno dentro do sistema (chat, tickets e central de ajuda)',
      ],
      highlighted: false,
    }
  ]

  const handleSubscribe = async (planId: string) => {
    // Se não estiver logado, vai para registro
    const token = localStorage.getItem('token')
    if (!token) {
      router.push(`/register?plan=${planId}`)
      return
    }

    setLoading(planId)

    try {
      // Criar assinatura no Asaas
      const response = await fetch('/api/billing/asaas/create-subscription', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${token}`
        },
        body: JSON.stringify({ planType: planId })
      })

      const data = await response.json()

      if (!response.ok) {
        throw new Error(data.error || 'Erro ao criar assinatura')
      }

      // Redirecionar para checkout do Asaas
      if (data.checkoutUrl) {
        window.location.href = data.checkoutUrl
      } else {
        throw new Error('URL de checkout não recebida')
      }

    } catch (error) {
      console.error('Erro ao criar assinatura:', error)
      alert(error instanceof Error ? error.message : 'Erro ao criar assinatura')
      setLoading(null)
    }
  }

  return (
    <section id="pricing" className="py-24 sm:py-32 bg-white">
      <div className="max-w-7xl mx-auto px-6 lg:px-8">
        {/* Cabeçalho da Seção */}
        <div className="text-center max-w-2xl mx-auto mb-16">
          <h2 className="text-3xl font-bold tracking-tight text-gray-900 sm:text-4xl">
            Escolha o plano ideal para seu escritório
          </h2>
          <p className="mt-6 text-lg leading-8 text-gray-600">
            Gerencie documentos jurídicos com inteligência artificial
          </p>
        </div>

        {/* Plans Grid */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
          {plans.map((plan) => (
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
                      <FaCheck className="w-5 h-5 text-green-500 mr-2 mt-0.5 flex-shrink-0" />
                      <span className="text-gray-700">{feature}</span>
                    </li>
                  ))}
                </ul>

                <button
                  onClick={() => handleSubscribe(plan.id)}
                  disabled={loading === plan.id}
                  className={`w-full py-3 px-6 rounded-lg font-semibold transition-colors text-center ${
                    plan.highlighted
                      ? 'bg-blue-600 text-white hover:bg-blue-700 disabled:bg-blue-400'
                      : 'bg-gray-900 text-white hover:bg-gray-800 disabled:bg-gray-400'
                  }`}
                >
                  {loading === plan.id ? (
                    <span className="flex items-center justify-center">
                      <svg className="animate-spin -ml-1 mr-2 h-5 w-5 text-white" fill="none" viewBox="0 0 24 24">
                        <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
                        <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                      </svg>
                      Processando...
                    </span>
                  ) : (
                    'Assinar agora'
                  )}
                </button>
              </div>
            </div>
          ))}
        </div>
      </div>
    </section>
  )
}