'use client'

import { useRouter } from 'next/navigation'
import { X, TrendingUp, AlertTriangle } from 'lucide-react'

interface UpgradeRequiredModalProps {
  isOpen: boolean
  onClose: () => void
  error: {
    error: string
    upgradeRequired?: boolean
    usage?: {
      documents: number
      tokens: number
    }
    limits?: {
      documents: number
      tokens: number
    }
  }
}

export default function UpgradeRequiredModal({ isOpen, onClose, error }: UpgradeRequiredModalProps) {
  const router = useRouter()

  if (!isOpen) return null

  const handleUpgrade = () => {
    onClose()
    router.push('/pricing')
  }

  const getProgressPercentage = (current: number, limit: number) => {
    if (limit === -1) return 0 // ilimitado
    return Math.min((current / limit) * 100, 100)
  }

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 z-50 flex items-center justify-center p-4">
      <div className="bg-white rounded-lg shadow-xl max-w-md w-full">
        {/* Header */}
        <div className="flex items-center justify-between p-6 border-b border-gray-200">
          <div className="flex items-center">
            <div className="w-10 h-10 bg-orange-100 rounded-full flex items-center justify-center mr-3">
              <AlertTriangle className="w-5 h-5 text-orange-600" />
            </div>
            <h2 className="text-xl font-semibold text-gray-900">
              Limite Atingido
            </h2>
          </div>
          <button
            onClick={onClose}
            className="text-gray-400 hover:text-gray-600 transition-colors"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* Body */}
        <div className="p-6">
          {/* Mensagem de erro */}
          <p className="text-gray-700 mb-6">
            {error.error}
          </p>

          {/* Informações de uso (se disponíveis) */}
          {error.usage && error.limits && (
            <div className="bg-gray-50 rounded-lg p-4 mb-6">
              <h3 className="text-sm font-medium text-gray-900 mb-4">Seu Uso Atual</h3>

              {/* Documentos */}
              {error.limits.documents !== -1 && (
                <div className="mb-4">
                  <div className="flex justify-between text-sm mb-1">
                    <span className="text-gray-600">Documentos</span>
                    <span className="font-medium text-gray-900">
                      {error.usage.documents} / {error.limits.documents}
                    </span>
                  </div>
                  <div className="w-full bg-gray-200 rounded-full h-2">
                    <div
                      className="bg-orange-500 h-2 rounded-full transition-all"
                      style={{
                        width: `${getProgressPercentage(error.usage.documents, error.limits.documents)}%`
                      }}
                    />
                  </div>
                </div>
              )}

              {/* Tokens */}
              {error.limits.tokens !== -1 && (
                <div>
                  <div className="flex justify-between text-sm mb-1">
                    <span className="text-gray-600">Tokens IA</span>
                    <span className="font-medium text-gray-900">
                      {error.usage.tokens.toLocaleString()} / {error.limits.tokens.toLocaleString()}
                    </span>
                  </div>
                  <div className="w-full bg-gray-200 rounded-full h-2">
                    <div
                      className="bg-orange-500 h-2 rounded-full transition-all"
                      style={{
                        width: `${getProgressPercentage(error.usage.tokens, error.limits.tokens)}%`
                      }}
                    />
                  </div>
                </div>
              )}
            </div>
          )}

          {/* Mensagem de incentivo */}
          <div className="bg-blue-50 border border-blue-200 rounded-lg p-4 mb-6">
            <p className="text-sm text-blue-800">
              <strong>Boas notícias!</strong> Faça upgrade do seu plano para continuar usando o sistema
              sem limites e com recursos avançados.
            </p>
          </div>
        </div>

        {/* Footer */}
        <div className="flex gap-3 p-6 bg-gray-50 rounded-b-lg">
          <button
            onClick={onClose}
            className="flex-1 px-4 py-2 border border-gray-300 text-gray-700 rounded-lg hover:bg-gray-100 transition-colors"
          >
            Fechar
          </button>
          <button
            onClick={handleUpgrade}
            className="flex-1 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors flex items-center justify-center gap-2"
          >
            <TrendingUp className="w-4 h-4" />
            Ver Planos
          </button>
        </div>
      </div>
    </div>
  )
}
