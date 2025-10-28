'use client'
import { useEffect, useState } from 'react'
import { Brain } from 'lucide-react'

interface TokenUsage {
  tokensTotal: number
  tokensLimit: number
  percentage: number
  status: 'ok' | 'warning' | 'critical' | 'exceeded'
}

export default function TokenUsageBadge() {
  const [usage, setUsage] = useState<TokenUsage | null>(null)

  useEffect(() => {
    loadUsage()
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
      console.error('Erro ao carregar uso:', error)
    }
  }

  if (!usage) return null

  // Cores baseadas no status
  const statusColors = {
    ok: 'text-green-600 bg-green-50',
    warning: 'text-yellow-600 bg-yellow-50',
    critical: 'text-orange-600 bg-orange-50',
    exceeded: 'text-red-600 bg-red-50',
  }

  const dotColor = {
    ok: 'bg-green-500',
    warning: 'bg-yellow-500',
    critical: 'bg-orange-500',
    exceeded: 'bg-red-500',
  }

  const kTotal = (usage.tokensTotal / 1000).toFixed(0)
  const kLimit = (usage.tokensLimit / 1000).toFixed(0)
  const progressBars = Math.round((usage.percentage / 100) * 10)

  return (
    <div className={`flex items-center space-x-2 px-3 py-1.5 rounded-full ${statusColors[usage.status]} text-xs font-medium`}>
      <Brain className="w-3.5 h-3.5" />
      {usage.status === 'exceeded' ? (
        <span className="font-bold">TOKENS ESGOTADOS</span>
      ) : (
        <>
          <span>{kTotal}k/{kLimit}k</span>
          <div className="flex space-x-0.5">
            {Array.from({ length: 10 }).map((_, i) => (
              <div
                key={i}
                className={`w-1 h-3 rounded-sm ${i < progressBars ? dotColor[usage.status] : 'bg-gray-300'}`}
              />
            ))}
          </div>
        </>
      )}
    </div>
  )
}
