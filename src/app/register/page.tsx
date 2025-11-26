'use client'

import { useState, Suspense } from 'react'
import { useRouter, useSearchParams } from 'next/navigation'
import Link from 'next/link'

function RegisterForm() {
  const router = useRouter()
  const searchParams = useSearchParams()
  const selectedPlan = searchParams.get('plan') || 'basic'

  const [formData, setFormData] = useState({
    name: '',
    email: '',
    password: '',
    confirmPassword: ''
  })
  const [error, setError] = useState('')
  const [loading, setLoading] = useState(false)

  // Informações dos planos
  const PLAN_INFO = {
    basic: {
      name: 'BÁSICO',
      price: 'R$ 34,90/mês',
      description: 'Plano Básico - Ideal para começar',
      features: [
        '300 documentos por mês',
        'Narrativas ilimitadas',
        'Agrupamento automático',
        'OCR otimizado',
        '1 usuário',
        'Suporte interno'
      ],
      requiresCard: false
    },
    advanced: {
      name: 'AVANÇADO',
      price: 'R$ 69,90/mês',
      description: 'Plano Avançado - Mais recursos e usuários',
      features: [
        '600 documentos por mês',
        'Validação de pertinência (300 docs/mês)',
        'Painel de uso detalhado',
        'OCR otimizado',
        '3 usuários',
        'Suporte prioritário'
      ],
      requiresCard: false
    },
    complete: {
      name: 'COMPLETO',
      price: 'R$ 99,90/mês',
      description: 'Plano Completo - Máximo desempenho',
      features: [
        '1.200 documentos por mês',
        'Validação de pertinência ilimitada',
        'Painel de uso detalhado',
        'OCR otimizado',
        '5 usuários',
        'Suporte completo'
      ],
      requiresCard: false
    }
  }

  const currentPlan = PLAN_INFO[selectedPlan as keyof typeof PLAN_INFO] || PLAN_INFO.basic

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setError('')

    // Validações
    if (!formData.name || !formData.email || !formData.password) {
      setError('Preencha todos os campos obrigatórios')
      return
    }

    if (formData.password !== formData.confirmPassword) {
      setError('As senhas não coincidem')
      return
    }

    if (formData.password.length < 6) {
      setError('A senha deve ter pelo menos 6 caracteres')
      return
    }

    setLoading(true)
    try {
      // PASSO 1: Criar assinatura no MercadoPago PRIMEIRO (antes de criar conta)
      const subscriptionResponse = await fetch('/api/billing/mercadopago/create-subscription', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          planType: selectedPlan,
          email: formData.email
        })
      })

      const subscriptionData = await subscriptionResponse.json()

      if (!subscriptionResponse.ok || !subscriptionData.success) {
        setError(subscriptionData.error || 'Erro ao criar assinatura no MercadoPago')
        setLoading(false)
        return
      }

      // PASSO 2: Só criar conta se a assinatura foi criada com sucesso
      const response = await fetch('/api/auth/register', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          name: formData.name,
          email: formData.email,
          password: formData.password,
          mercadoPagoSubscriptionId: subscriptionData.subscriptionId // Salvar ID da assinatura
        })
      })

      const data = await response.json()

      if (!response.ok) {
        setError(data.message || 'Erro ao criar conta')
        setLoading(false)
        return
      }

      // Salvar token no localStorage
      if (data.token) {
        localStorage.setItem('token', data.token)
      }

      // PASSO 3: Redirecionar para checkout do MercadoPago
      if (subscriptionData.checkoutUrl) {
        window.location.href = subscriptionData.checkoutUrl
      } else {
        setError('Erro: URL de checkout não encontrada')
        setLoading(false)
      }

    } catch (err: any) {
      console.error('Erro:', err)
      setError(err.message || 'Erro ao conectar com o servidor')
      setLoading(false)
    }
  }

  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const { name, value } = e.target
    setFormData({ ...formData, [name]: value })
  }

  return (
    <>
      <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100 flex items-center justify-center py-12 px-4 sm:px-6 lg:px-8">
        <div className="max-w-md w-full space-y-8">
          {/* Header */}
          <div className="text-center">
            <h2 className="text-3xl font-bold text-gray-900">
              Assinar Plano {currentPlan.name}
            </h2>
            <p className="mt-2 text-sm text-gray-600">
              {currentPlan.description}
            </p>
          </div>

          {/* Plan Badge */}
          <div className={`${selectedPlan === 'advanced' ? 'bg-blue-50 border-2 border-blue-200' : 'bg-gray-50 border-2 border-gray-200'} rounded-lg p-4`}>
            <div className="flex items-center justify-between">
              <div>
                <h3 className={`text-lg font-semibold ${selectedPlan === 'advanced' ? 'text-blue-900' : 'text-gray-900'}`}>
                  Plano {currentPlan.name}
                </h3>
                <p className={`text-sm ${selectedPlan === 'advanced' ? 'text-blue-700' : 'text-gray-700'} mt-1`}>
                  O que está incluído:
                </p>
              </div>
              <div className={`text-2xl font-bold ${selectedPlan === 'advanced' ? 'text-blue-600' : 'text-gray-600'}`}>
                {currentPlan.price}
              </div>
            </div>
            <ul className={`mt-3 space-y-2 text-sm ${selectedPlan === 'advanced' ? 'text-blue-800' : 'text-gray-800'}`}>
              {currentPlan.features.map((feature, index) => (
                <li key={index} className="flex items-center">
                  <svg className={`w-4 h-4 mr-2 ${selectedPlan === 'advanced' ? 'text-blue-600' : 'text-gray-600'}`} fill="currentColor" viewBox="0 0 20 20">
                    <path fillRule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clipRule="evenodd" />
                  </svg>
                  {feature}
                </li>
              ))}
            </ul>
          </div>

          {/* Payment Notice */}
          <div className="bg-blue-50 border border-blue-200 rounded-lg p-4">
            <div className="flex">
              <svg className="w-5 h-5 text-blue-600 mr-2 flex-shrink-0" fill="currentColor" viewBox="0 0 20 20">
                <path fillRule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7-4a1 1 0 11-2 0 1 1 0 012 0zM9 9a1 1 0 000 2v3a1 1 0 001 1h1a1 1 0 100-2v-3a1 1 0 00-1-1H9z" clipRule="evenodd" />
              </svg>
              <div className="text-sm text-blue-800">
                <strong>Como funciona?</strong>
                <p className="mt-1">Após criar sua conta, você será redirecionado para o checkout do MercadoPago para completar o pagamento.
                Você poderá pagar com cartão de crédito e PIX.</p>
              </div>
            </div>
          </div>

          {/* Form */}
          <div className="bg-white rounded-lg shadow-xl p-8">
            <form onSubmit={handleSubmit} className="space-y-6">
              {error && (
                <div className="bg-red-50 border border-red-200 text-red-800 rounded-lg p-4 text-sm">
                  {error}
                </div>
              )}

              {/* Dados Pessoais */}
              <div>
                <label htmlFor="name" className="block text-sm font-medium text-gray-700">
                  Nome completo *
                </label>
                <input
                  id="name"
                  name="name"
                  type="text"
                  required
                  value={formData.name}
                  onChange={handleChange}
                  className="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-lg shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
                  placeholder="Seu nome"
                />
              </div>

              <div>
                <label htmlFor="email" className="block text-sm font-medium text-gray-700">
                  Email *
                </label>
                <input
                  id="email"
                  name="email"
                  type="email"
                  required
                  value={formData.email}
                  onChange={handleChange}
                  className="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-lg shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
                  placeholder="seu@email.com"
                />
              </div>

              <div>
                <label htmlFor="password" className="block text-sm font-medium text-gray-700">
                  Senha *
                </label>
                <input
                  id="password"
                  name="password"
                  type="password"
                  required
                  value={formData.password}
                  onChange={handleChange}
                  className="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-lg shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
                  placeholder="Mínimo 6 caracteres"
                />
              </div>

              <div>
                <label htmlFor="confirmPassword" className="block text-sm font-medium text-gray-700">
                  Confirmar senha *
                </label>
                <input
                  id="confirmPassword"
                  name="confirmPassword"
                  type="password"
                  required
                  value={formData.confirmPassword}
                  onChange={handleChange}
                  className="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-lg shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
                  placeholder="Digite a senha novamente"
                />
              </div>

              {/* Botão */}
              <button
                type="submit"
                disabled={loading}
                className="w-full flex justify-center py-3 px-4 border border-transparent rounded-lg shadow-sm text-sm font-medium text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
              >
                {loading ? (
                  <span className="flex items-center">
                    <svg className="animate-spin -ml-1 mr-3 h-5 w-5 text-white" fill="none" viewBox="0 0 24 24">
                      <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
                      <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                    </svg>
                    Criando conta e assinatura...
                  </span>
                ) : (
                  'Ir para pagamento'
                )}
              </button>
            </form>

            <div className="mt-6 text-center">
              <p className="text-sm text-gray-600">
                Já tem uma conta?{' '}
                <Link href="/login" className="font-medium text-blue-600 hover:text-blue-500">
                  Fazer login
                </Link>
              </p>
            </div>
          </div>

          {/* Security Badge */}
          <div className="flex items-center justify-center text-sm text-gray-500 space-x-2">
            <svg className="w-5 h-5" fill="currentColor" viewBox="0 0 20 20">
              <path fillRule="evenodd" d="M2.166 4.999A11.954 11.954 0 0010 1.944 11.954 11.954 0 0017.834 5c.11.65.166 1.32.166 2.001 0 5.225-3.34 9.67-8 11.317C5.34 16.67 2 12.225 2 7c0-.682.057-1.35.166-2.001zm11.541 3.708a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clipRule="evenodd" />
            </svg>
            <span>Seus dados estão protegidos e criptografados</span>
          </div>

          {/* Footer */}
          <div className="text-center">
            <Link href="https://advconecta.com.br" className="text-sm text-gray-600 hover:text-gray-900">
              ← Voltar para a página inicial
            </Link>
          </div>
        </div>
      </div>
    </>
  )
}

// Loading fallback
function RegisterLoading() {
  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100 flex items-center justify-center">
      <div className="text-center">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto mb-4"></div>
        <p className="text-gray-600">Carregando...</p>
      </div>
    </div>
  )
}

// Main component with Suspense boundary
export default function RegisterPage() {
  return (
    <Suspense fallback={<RegisterLoading />}>
      <RegisterForm />
    </Suspense>
  )
}
