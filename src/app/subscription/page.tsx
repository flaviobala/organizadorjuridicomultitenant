'use client'
import { useEffect, useState } from 'react'
import { useRouter } from 'next/navigation'
import {
  CreditCard,
  CheckCircle,
  AlertCircle,
  XCircle,
  Clock,
  ArrowLeft,
  ExternalLink
} from 'lucide-react'
import Link from 'next/link'

interface SubscriptionData {
  planType: string
  subscriptionStatus: string
  documentProcessedCount: number
  aiTokenCount: number
}

interface PlanLimits {
  maxDocuments: number
  maxTokens: number
  maxUsers: number
  features: string[]
}

const PLAN_INFO: Record<string, { name: string, price: string, limits: PlanLimits }> = {
  trialing: {
    name: 'Trial',
    price: 'Grátis',
    limits: {
      maxDocuments: 50,
      maxTokens: 100000,
      maxUsers: 2,
      features: ['Processamento básico', 'Categorização IA']
    }
  },
  basic: {
    name: 'Basic',
    price: 'R$ 1/mês',
    limits: {
      maxDocuments: 500,
      maxTokens: 1000000,
      maxUsers: 5,
      features: ['Processamento básico', 'Categorização IA', 'Upload em lote']
    }
  },
  pro: {
    name: 'Pro',
    price: 'R$ 2/mês',
    limits: {
      maxDocuments: 5000,
      maxTokens: 10000000,
      maxUsers: 20,
      features: ['Processamento básico', 'Categorização IA', 'Upload em lote', 'IA Avançada', 'Suporte prioritário']
    }
  },
  enterprise: {
    name: 'Enterprise',
    price: 'R$ 3/mês',
    limits: {
      maxDocuments: -1,
      maxTokens: -1,
      maxUsers: -1,
      features: ['Tudo do Pro', 'Recursos ilimitados', 'Integração customizada', 'Suporte dedicado']
    }
  }
}

export default function SubscriptionPage() {
  const router = useRouter()
  const [subscription, setSubscription] = useState<SubscriptionData | null>(null)
  const [isLoading, setIsLoading] = useState(true)

  useEffect(() => {
    const token = localStorage.getItem('token')
    if (!token) {
      router.push('/login')
      return
    }

    loadSubscription()
  }, [router])

  const loadSubscription = async () => {
    try {
      const token = localStorage.getItem('token')
      const response = await fetch('/api/subscription', {
        headers: {
          'Authorization': `Bearer ${token}`
        }
      })

      const data = await response.json()

      if (data.success) {
        setSubscription(data.subscription)
      }
    } catch (error) {
      console.error('Erro ao carregar assinatura:', error)
    } finally {
      setIsLoading(false)
    }
  }

  const getStatusInfo = (status: string) => {
    const statuses: Record<string, { label: string, color: string, icon: any, bg: string, borderColor: string }> = {
      active: {
        label: 'Ativa',
        color: 'text-green-600',
        icon: CheckCircle,
        bg: 'bg-green-50',
        borderColor: 'border-green-200'
      },
      trialing: {
        label: 'Período de Teste',
        color: 'text-blue-600',
        icon: Clock,
        bg: 'bg-blue-50',
        borderColor: 'border-blue-200'
      },
      past_due: {
        label: 'Pagamento Atrasado',
        color: 'text-yellow-600',
        icon: AlertCircle,
        bg: 'bg-yellow-50',
        borderColor: 'border-yellow-200'
      },
      canceled: {
        label: 'Cancelada',
        color: 'text-red-600',
        icon: XCircle,
        bg: 'bg-red-50',
        borderColor: 'border-red-200'
      }
    }
    return statuses[status] || {
      label: status,
      color: 'text-gray-600',
      icon: CreditCard,
      bg: 'bg-gray-50',
      borderColor: 'border-gray-200'
    }
  }

  if (isLoading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
      </div>
    )
  }

  if (!subscription) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <p className="text-gray-600 mb-4">Erro ao carregar assinatura</p>
          <Link href="/dashboard" className="text-blue-600 hover:underline">
            Voltar ao Dashboard
          </Link>
        </div>
      </div>
    )
  }

  const planInfo = PLAN_INFO[subscription.planType]
  const statusInfo = getStatusInfo(subscription.subscriptionStatus)
  const StatusIcon = statusInfo.icon

  const documentUsagePercent = planInfo.limits.maxDocuments > 0
    ? (subscription.documentProcessedCount / planInfo.limits.maxDocuments) * 100
    : 0

  const tokenUsagePercent = planInfo.limits.maxTokens > 0
    ? (subscription.aiTokenCount / planInfo.limits.maxTokens) * 100
    : 0

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <header className="bg-white shadow-sm border-b border-gray-200">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4">
          <div className="flex items-center justify-between">
            <Link
              href="/dashboard"
              className="flex items-center text-gray-600 hover:text-gray-900 transition-colors"
            >
              <ArrowLeft className="w-5 h-5 mr-2" />
              Voltar ao Dashboard
            </Link>
          </div>
        </div>
      </header>

      <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
        <h1 className="text-3xl font-bold text-gray-900 mb-8">Gerenciar Assinatura</h1>

        {/* Current Plan Card */}
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6 mb-8">
          <div className="flex items-center justify-between mb-6">
            <div>
              <h2 className="text-xl font-semibold text-gray-900 mb-2">Plano Atual</h2>
              <p className="text-3xl font-bold text-blue-600">{planInfo.name}</p>
              <p className="text-gray-600 mt-1">{planInfo.price}</p>
            </div>

            <div className={`flex items-center ${statusInfo.bg} border ${statusInfo.borderColor} rounded-lg px-4 py-2`}>
              <StatusIcon className={`w-5 h-5 ${statusInfo.color} mr-2`} />
              <span className={`font-medium ${statusInfo.color}`}>
                {statusInfo.label}
              </span>
            </div>
          </div>

          {/* Alerts */}
          {subscription.subscriptionStatus === 'past_due' && (
            <div className="bg-yellow-50 border border-yellow-200 rounded-lg p-4 mb-6">
              <div className="flex">
                <AlertCircle className="w-5 h-5 text-yellow-600 mr-3 flex-shrink-0" />
                <div>
                  <h3 className="text-sm font-medium text-yellow-800 mb-1">Pagamento Atrasado</h3>
                  <p className="text-sm text-yellow-700">
                    Seu último pagamento não foi processado. Atualize sua forma de pagamento para continuar usando o sistema.
                  </p>
                </div>
              </div>
            </div>
          )}

          {subscription.subscriptionStatus === 'canceled' && (
            <div className="bg-red-50 border border-red-200 rounded-lg p-4 mb-6">
              <div className="flex">
                <XCircle className="w-5 h-5 text-red-600 mr-3 flex-shrink-0" />
                <div>
                  <h3 className="text-sm font-medium text-red-800 mb-1">Assinatura Cancelada</h3>
                  <p className="text-sm text-red-700">
                    Sua assinatura foi cancelada. Escolha um plano para reativar o acesso.
                  </p>
                </div>
              </div>
            </div>
          )}

          {/* Usage Stats */}
          <div className="space-y-4">
            <div>
              <div className="flex justify-between text-sm mb-2">
                <span className="text-gray-600">Documentos Processados</span>
                <span className="font-medium text-gray-900">
                  {subscription.documentProcessedCount} / {planInfo.limits.maxDocuments > 0 ? planInfo.limits.maxDocuments : '∞'}
                </span>
              </div>
              {planInfo.limits.maxDocuments > 0 && (
                <div className="w-full bg-gray-200 rounded-full h-2">
                  <div
                    className="bg-blue-600 h-2 rounded-full"
                    style={{ width: `${Math.min(documentUsagePercent, 100)}%` }}
                  ></div>
                </div>
              )}
            </div>

            <div>
              <div className="flex justify-between text-sm mb-2">
                <span className="text-gray-600">Tokens IA Utilizados</span>
                <span className="font-medium text-gray-900">
                  {subscription.aiTokenCount.toLocaleString()} / {planInfo.limits.maxTokens > 0 ? planInfo.limits.maxTokens.toLocaleString() : '∞'}
                </span>
              </div>
              {planInfo.limits.maxTokens > 0 && (
                <div className="w-full bg-gray-200 rounded-full h-2">
                  <div
                    className="bg-blue-600 h-2 rounded-full"
                    style={{ width: `${Math.min(tokenUsagePercent, 100)}%` }}
                  ></div>
                </div>
              )}
            </div>
          </div>

          {/* Features */}
          <div className="mt-6 pt-6 border-t border-gray-200">
            <h3 className="text-sm font-medium text-gray-900 mb-3">Recursos incluídos:</h3>
            <ul className="space-y-2">
              {planInfo.limits.features.map((feature, index) => (
                <li key={index} className="flex items-center text-sm text-gray-600">
                  <CheckCircle className="w-4 h-4 text-green-500 mr-2" />
                  {feature}
                </li>
              ))}
            </ul>
          </div>
        </div>

        {/* Actions */}
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
          <h2 className="text-lg font-semibold text-gray-900 mb-4">Ações</h2>

          <div className="space-y-3">
            <Link
              href="/pricing"
              className="flex items-center justify-between w-full bg-blue-600 hover:bg-blue-700 text-white font-medium py-3 px-4 rounded-lg transition-colors"
            >
              <span>Fazer Upgrade ou Trocar de Plano</span>
              <ExternalLink className="w-5 h-5" />
            </Link>

            {subscription.subscriptionStatus === 'active' && (
              <button
                onClick={() => alert('Funcionalidade de cancelamento será implementada em breve')}
                className="w-full text-left text-red-600 hover:text-red-700 font-medium py-3 px-4 border border-red-200 hover:bg-red-50 rounded-lg transition-colors"
              >
                Cancelar Assinatura
              </button>
            )}
          </div>
        </div>
      </div>
    </div>
  )
}
