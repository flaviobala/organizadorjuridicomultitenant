'use client'
import { useEffect, useState } from 'react'
import { CreditCard, CheckCircle, AlertCircle, XCircle, Clock } from 'lucide-react'
import Link from 'next/link'

interface SubscriptionData {
  planType: string
  subscriptionStatus: string
}

export default function SubscriptionCard() {
  const [subscription, setSubscription] = useState<SubscriptionData | null>(null)
  const [isLoading, setIsLoading] = useState(true)

  useEffect(() => {
    loadSubscription()
  }, [])

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

  const getPlanName = (planType: string) => {
    const plans: Record<string, string> = {
      trialing: 'Trial',
      basic: 'Basic',
      pro: 'Pro',
      enterprise: 'Enterprise'
    }
    return plans[planType] || planType
  }

  const getStatusInfo = (status: string) => {
    const statuses: Record<string, { label: string, color: string, icon: any, bg: string }> = {
      active: {
        label: 'Ativa',
        color: 'text-green-600',
        icon: CheckCircle,
        bg: 'bg-green-50'
      },
      trialing: {
        label: 'Período de Teste',
        color: 'text-blue-600',
        icon: Clock,
        bg: 'bg-blue-50'
      },
      past_due: {
        label: 'Pagamento Atrasado',
        color: 'text-yellow-600',
        icon: AlertCircle,
        bg: 'bg-yellow-50'
      },
      canceled: {
        label: 'Cancelada',
        color: 'text-red-600',
        icon: XCircle,
        bg: 'bg-red-50'
      }
    }
    return statuses[status] || {
      label: status,
      color: 'text-gray-600',
      icon: CreditCard,
      bg: 'bg-gray-50'
    }
  }

  if (isLoading) {
    return (
      <div className="bg-white rounded-lg shadow p-6 animate-pulse">
        <div className="h-4 bg-gray-200 rounded w-1/4 mb-4"></div>
        <div className="h-8 bg-gray-200 rounded w-1/2"></div>
      </div>
    )
  }

  if (!subscription) {
    return null
  }

  const statusInfo = getStatusInfo(subscription.subscriptionStatus)
  const StatusIcon = statusInfo.icon

  return (
    <div className="bg-white rounded-lg shadow p-6">
      <div className="flex items-start justify-between mb-4">
        <div className="flex items-center">
          <div className="flex-shrink-0">
            <CreditCard className="w-6 h-6 text-blue-600" />
          </div>
          <div className="ml-3">
            <h3 className="text-sm font-medium text-gray-500">Plano Atual</h3>
            <p className="text-2xl font-bold text-gray-900">{getPlanName(subscription.planType)}</p>
          </div>
        </div>
      </div>

      <div className={`flex items-center ${statusInfo.bg} rounded-lg px-3 py-2 mb-4`}>
        <StatusIcon className={`w-4 h-4 ${statusInfo.color} mr-2`} />
        <span className={`text-sm font-medium ${statusInfo.color}`}>
          {statusInfo.label}
        </span>
      </div>

      {subscription.subscriptionStatus === 'past_due' && (
        <div className="bg-yellow-50 border border-yellow-200 rounded-lg p-3 mb-4">
          <p className="text-sm text-yellow-800">
            Seu pagamento está atrasado. Atualize sua forma de pagamento para continuar usando o sistema.
          </p>
        </div>
      )}

      {subscription.subscriptionStatus === 'canceled' && (
        <div className="bg-red-50 border border-red-200 rounded-lg p-3 mb-4">
          <p className="text-sm text-red-800">
            Sua assinatura foi cancelada. Reative para continuar usando o sistema.
          </p>
        </div>
      )}

      <div className="mt-4">
        <Link
          href="/pricing"
          className="block w-full text-center bg-blue-600 hover:bg-blue-700 text-white font-medium py-2 px-4 rounded-lg transition-colors"
        >
          Gerenciar Assinatura
        </Link>
      </div>
    </div>
  )
}
