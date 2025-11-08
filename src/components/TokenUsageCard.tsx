'use client'
import { useEffect, useState } from 'react'
import { Brain, TrendingUp, AlertTriangle, CheckCircle2, XCircle } from 'lucide-react'

interface TokenUsage {
  tokensTotal: number
  tokensLimit: number
  tokensRemaining: number
  percentage: number
  costBRL: number
  documentsProcessed: number
  avgTokensPerDoc: number
  aiCount: number
  keywordsCount: number
  status: 'ok' | 'warning' | 'critical' | 'exceeded'
  primaryMethod: 'ai' | 'keywords'
}

export default function TokenUsageCard() {
  const [usage, setUsage] = useState<TokenUsage | null>(null)
  const [isLoading, setIsLoading] = useState(true)

  useEffect(() => {
    loadUsage()
    // Atualizar a cada 30 segundos
    const interval = setInterval(loadUsage, 30000)
    return () => clearInterval(interval)
  }, [])

  const loadUsage = async () => {
    try {
      const token = localStorage.getItem('token')
      const response = await fetch('/api/usage', {
        headers: { 'Authorization': `Bearer ${token}` }
      })
      const data = await response.json()
      if (data.success) {
        setUsage(data.usage)
      }
    } catch (error) {
      console.error('Erro ao carregar uso de tokens:', error)
    } finally {
      setIsLoading(false)
    }
  }

  if (isLoading) {
    return (
      <div className="bg-white rounded-lg shadow p-6">
        <div className="animate-pulse">
          <div className="h-4 bg-gray-200 rounded w-1/2 mb-4"></div>
          <div className="h-8 bg-gray-200 rounded mb-2"></div>
          <div className="h-2 bg-gray-200 rounded"></div>
        </div>
      </div>
    )
  }

  if (!usage) {
    return null
  }

  // Cores baseadas no status
  const statusColors = {
    ok: { bg: 'bg-green-100', bar: 'bg-green-500', text: 'text-green-700', icon: CheckCircle2 },
    warning: { bg: 'bg-yellow-100', bar: 'bg-yellow-500', text: 'text-yellow-700', icon: AlertTriangle },
    critical: { bg: 'bg-orange-100', bar: 'bg-orange-500', text: 'text-orange-700', icon: AlertTriangle },
    exceeded: { bg: 'bg-red-100', bar: 'bg-red-500', text: 'text-red-700', icon: XCircle },
  }

  const colors = statusColors[usage.status]
  const StatusIcon = colors.icon
  const progressWidth = Math.min(100, usage.percentage)

  return (
    <div className="bg-white rounded-lg shadow p-6 col-span-1 lg:col-span-2">
      {/* Header */}
      <div className="flex items-center justify-between mb-4">
        <div className="flex items-center space-x-2">
          <Brain className="w-5 h-5 text-blue-600" />
          <h3 className="text-sm font-medium text-gray-700">Uso de IA (OpenAI)</h3>
        </div>
        <StatusIcon className={`w-5 h-5 ${colors.text}`} />
      </div>

      {/* Tokens */}
      <div className="mb-3">
        <div className="flex items-baseline justify-between mb-1">
          <span className="text-2xl font-bold text-gray-900">
            {(usage.tokensTotal / 1000).toFixed(1)}k
          </span>
          <span className="text-sm text-gray-500">/ {(usage.tokensLimit / 1000)}k tokens</span>
        </div>

        {/* Progress Bar */}
        <div className="w-full bg-gray-200 rounded-full h-2 overflow-hidden">
          <div
            className={`h-full ${colors.bar} transition-all duration-500`}
            style={{ width: `${progressWidth}%` }}
          ></div>
        </div>

        <div className="flex justify-between items-center mt-1">
          <span className="text-xs text-gray-500">
            {usage.tokensRemaining > 0 ? `${(usage.tokensRemaining / 1000).toFixed(1)}k restantes` : 'Limite atingido'}
          </span>
          <span className={`text-xs font-medium ${colors.text}`}>
            {usage.percentage.toFixed(1)}%
          </span>
        </div>
      </div>

      {/* Stats Grid */}
      <div className="grid grid-cols-2 gap-3 pt-3 border-t border-gray-100">
        <div>
          <p className="text-xs text-gray-500">Documentos</p>
          <p className="text-sm font-semibold text-gray-900">{usage.documentsProcessed} docs</p>
        </div>

        <div>
          <p className="text-xs text-gray-500">Média/doc</p>
          <p className="text-sm font-semibold text-gray-900">{usage.avgTokensPerDoc} tokens</p>
        </div>

        <div>
          <p className="text-xs text-gray-500">Método</p>
          <p className="text-sm font-semibold text-gray-900">
            {usage.primaryMethod === 'ai' ? (
              <span className="text-blue-600">✨ IA ({usage.aiCount})</span>
            ) : (
              <span className="text-green-600">🔑 Keywords ({usage.keywordsCount})</span>
            )}
          </p>
        </div>
      </div>

      {/* Alert Banner */}
      {usage.status !== 'ok' && (
        <div className={`mt-4 p-3 rounded-lg ${colors.bg} ${colors.text} text-xs`}>
          {usage.status === 'exceeded' && (
            <div>
              <p className="font-semibold mb-1">🚫 TOKENS ESGOTADOS!</p>
              <p>Seus créditos OpenAI acabaram. O sistema está usando categorização por palavras-chave (método gratuito e funcional).</p>
              <p className="mt-1 text-xs opacity-80">💡 Adicione mais créditos na sua conta OpenAI para reativar a IA.</p>
            </div>
          )}
          {usage.status === 'critical' && (
            <p>🔴 Atenção! Você está usando {usage.percentage.toFixed(0)}% do limite mensal.</p>
          )}
          {usage.status === 'warning' && (
            <p>🟡 Aviso: Você ultrapassou 80% do limite mensal de tokens.</p>
          )}
        </div>
      )}
    </div>
  )
}
