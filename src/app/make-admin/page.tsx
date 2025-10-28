'use client'

import { useState, useEffect } from 'react'
import { useRouter } from 'next/navigation'

export default function MakeAdminPage() {
  const router = useRouter()
  const [loading, setLoading] = useState(false)
  const [message, setMessage] = useState('')
  const [error, setError] = useState('')
  const [userInfo, setUserInfo] = useState<any>(null)

  useEffect(() => {
    // Verificar se está logado e pegar info do token
    const token = localStorage.getItem('token')
    if (!token) {
      router.push('/login')
      return
    }

    try {
      const payload = JSON.parse(atob(token.split('.')[1]))
      setUserInfo(payload)
    } catch (err) {
      router.push('/login')
    }
  }, [router])

  const handleMakeAdmin = async () => {
    setLoading(true)
    setError('')
    setMessage('')

    try {
      const token = localStorage.getItem('token')
      if (!token) {
        router.push('/login')
        return
      }

      const response = await fetch('/api/auth/make-admin', {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${token}`
        }
      })

      const data = await response.json()

      if (!response.ok) {
        setError(data.error || 'Erro ao tornar admin')
        return
      }

      setMessage(data.message)

      // Aguardar 2 segundos e fazer logout
      setTimeout(() => {
        localStorage.removeItem('token')
        alert('Você agora é admin! Faça login novamente.')
        router.push('/login')
      }, 2000)

    } catch (err) {
      console.error('Erro:', err)
      setError('Erro ao conectar com o servidor')
    } finally {
      setLoading(false)
    }
  }

  if (!userInfo) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100 flex items-center justify-center p-4">
      <div className="bg-white rounded-lg shadow-xl p-8 max-w-md w-full">
        <div className="text-center mb-6">
          <div className="mx-auto w-16 h-16 bg-yellow-100 rounded-full flex items-center justify-center mb-4">
            <svg className="w-10 h-10 text-yellow-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
            </svg>
          </div>
          <h1 className="text-2xl font-bold text-gray-900 mb-2">
            Tornar-se Admin
          </h1>
          <p className="text-gray-600 text-sm">
            ⚠️ Página apenas para desenvolvimento
          </p>
        </div>

        <div className="bg-gray-50 rounded-lg p-4 mb-6">
          <h3 className="text-sm font-semibold text-gray-700 mb-2">Informações Atuais:</h3>
          <div className="space-y-1 text-sm">
            <div className="flex justify-between">
              <span className="text-gray-600">Email:</span>
              <span className="font-medium text-gray-900">{userInfo.email}</span>
            </div>
            <div className="flex justify-between">
              <span className="text-gray-600">User ID:</span>
              <span className="font-medium text-gray-900">{userInfo.userId}</span>
            </div>
            <div className="flex justify-between">
              <span className="text-gray-600">Org ID:</span>
              <span className="font-medium text-gray-900">{userInfo.organizationId}</span>
            </div>
            <div className="flex justify-between">
              <span className="text-gray-600">Role Atual:</span>
              <span className={`font-medium ${userInfo.role === 'admin' ? 'text-green-600' : 'text-yellow-600'}`}>
                {userInfo.role}
              </span>
            </div>
          </div>
        </div>

        {message && (
          <div className="bg-green-50 border border-green-200 text-green-800 rounded-lg p-4 mb-4">
            <div className="flex items-start">
              <svg className="w-5 h-5 text-green-600 mr-2 mt-0.5" fill="currentColor" viewBox="0 0 20 20">
                <path fillRule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clipRule="evenodd" />
              </svg>
              <p className="text-sm">{message}</p>
            </div>
          </div>
        )}

        {error && (
          <div className="bg-red-50 border border-red-200 text-red-800 rounded-lg p-4 mb-4">
            <div className="flex items-start">
              <svg className="w-5 h-5 text-red-600 mr-2 mt-0.5" fill="currentColor" viewBox="0 0 20 20">
                <path fillRule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clipRule="evenodd" />
              </svg>
              <p className="text-sm">{error}</p>
            </div>
          </div>
        )}

        {userInfo.role === 'admin' ? (
          <div className="text-center">
            <div className="bg-green-50 border border-green-200 text-green-800 rounded-lg p-4 mb-4">
              <p className="font-semibold">Você já é admin! 🎉</p>
            </div>
            <button
              onClick={() => router.push('/admin')}
              className="w-full bg-blue-600 text-white py-3 rounded-lg font-semibold hover:bg-blue-700 transition-colors"
            >
              Ir para Dashboard Admin
            </button>
          </div>
        ) : (
          <button
            onClick={handleMakeAdmin}
            disabled={loading}
            className="w-full bg-yellow-600 text-white py-3 rounded-lg font-semibold hover:bg-yellow-700 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
          >
            {loading ? (
              <span className="flex items-center justify-center">
                <svg className="animate-spin -ml-1 mr-3 h-5 w-5 text-white" fill="none" viewBox="0 0 24 24">
                  <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
                  <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                </svg>
                Processando...
              </span>
            ) : (
              '🔑 Tornar-me Admin'
            )}
          </button>
        )}

        <div className="mt-6 text-center">
          <button
            onClick={() => router.push('/dashboard')}
            className="text-gray-600 hover:text-gray-800 text-sm"
          >
            ← Voltar ao Dashboard
          </button>
        </div>
      </div>
    </div>
  )
}
