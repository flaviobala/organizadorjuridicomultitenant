'use client'

import { useEffect } from 'react'
import { useRouter } from 'next/navigation'

export default function ForceLogoutPage() {
  const router = useRouter()

  useEffect(() => {
    // Limpar TUDO do localStorage
    localStorage.clear()

    // Aguardar um momento e redirecionar
    setTimeout(() => {
      router.push('/login')
    }, 1000)
  }, [router])

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-950 via-blue-900 to-slate-900 flex items-center justify-center">
      <div className="bg-white rounded-lg shadow-xl p-8 max-w-md text-center">
        <div className="animate-spin rounded-full h-16 w-16 border-b-4 border-blue-600 mx-auto mb-4"></div>
        <h1 className="text-2xl font-bold text-gray-900 mb-2">Fazendo Logout...</h1>
        <p className="text-gray-600">Limpando sessão e redirecionando para login</p>
      </div>
    </div>
  )
}
