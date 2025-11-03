'use client'

import { useState, useEffect } from 'react'
import { useRouter, useParams } from 'next/navigation'

export default function EditOrganizationPage() {
  const router = useRouter()
  const params = useParams()
  const orgId = params.id as string

  const [loading, setLoading] = useState(true)
  const [saving, setSaving] = useState(false)
  const [error, setError] = useState('')
  const [formData, setFormData] = useState({
    name: '',
    planType: 'trialing',
    contactName: '',
    contactPhone: '',
    cnpj: '',
    address: '',
    city: '',
    state: '',
    zipCode: ''
  })

  useEffect(() => {
    // Verificar se está logado e é super_admin
    const token = localStorage.getItem('token')
    if (!token) {
      router.push('/login')
      return
    }

    try {
      const payload = JSON.parse(atob(token.split('.')[1]))
      if (payload.role !== 'super_admin') {
        alert('Acesso negado: apenas super administradores podem editar organizações')
        router.push('/dashboard')
        return
      }
    } catch (err) {
      router.push('/login')
      return
    }

    fetchOrganization()
  }, [orgId, router])

  const fetchOrganization = async () => {
    try {
      const token = localStorage.getItem('token')
      const response = await fetch('/api/admin/organizations', {
        headers: {
          'Authorization': `Bearer ${token}`
        }
      })

      const data = await response.json()

      if (!response.ok) {
        setError(data.error || 'Erro ao carregar organização')
        return
      }

      // Encontrar a organização específica
      const org = data.organizations.find((o: any) => o.id === parseInt(orgId))

      if (!org) {
        setError('Organização não encontrada')
        return
      }

      // Preencher formulário com dados existentes
      setFormData({
        name: org.name || '',
        planType: org.planType || 'trialing',
        contactName: org.contactName || '',
        contactPhone: org.contactPhone || '',
        cnpj: org.cnpj || '',
        address: org.address || '',
        city: org.city || '',
        state: org.state || '',
        zipCode: org.zipCode || ''
      })
    } catch (err) {
      setError('Erro ao conectar com o servidor')
    } finally {
      setLoading(false)
    }
  }

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setSaving(true)
    setError('')

    try {
      const token = localStorage.getItem('token')
      const response = await fetch(`/api/admin/organizations/${orgId}`, {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${token}`
        },
        body: JSON.stringify(formData)
      })

      const data = await response.json()

      if (!response.ok) {
        setError(data.error || 'Erro ao atualizar organização')
        return
      }

      alert('Organização atualizada com sucesso!')
      router.push('/admin')

    } catch (err) {
      setError('Erro ao conectar com o servidor')
    } finally {
      setSaving(false)
    }
  }

  const formatCNPJ = (value: string) => {
    const numbers = value.replace(/\D/g, '')
    const limited = numbers.substring(0, 14)

    if (limited.length <= 2) {
      return limited
    } else if (limited.length <= 5) {
      return `${limited.substring(0, 2)}.${limited.substring(2)}`
    } else if (limited.length <= 8) {
      return `${limited.substring(0, 2)}.${limited.substring(2, 5)}.${limited.substring(5)}`
    } else if (limited.length <= 12) {
      return `${limited.substring(0, 2)}.${limited.substring(2, 5)}.${limited.substring(5, 8)}/${limited.substring(8)}`
    } else {
      return `${limited.substring(0, 2)}.${limited.substring(2, 5)}.${limited.substring(5, 8)}/${limited.substring(8, 12)}-${limited.substring(12)}`
    }
  }

  const formatPhone = (value: string) => {
    const numbers = value.replace(/\D/g, '')
    const limited = numbers.substring(0, 11)

    if (limited.length <= 2) {
      return limited
    } else if (limited.length <= 6) {
      return `(${limited.substring(0, 2)}) ${limited.substring(2)}`
    } else if (limited.length <= 10) {
      return `(${limited.substring(0, 2)}) ${limited.substring(2, 6)}-${limited.substring(6)}`
    } else {
      return `(${limited.substring(0, 2)}) ${limited.substring(2, 7)}-${limited.substring(7)}`
    }
  }

  const formatCEP = (value: string) => {
    const numbers = value.replace(/\D/g, '')
    const limited = numbers.substring(0, 8)

    if (limited.length <= 5) {
      return limited
    } else {
      return `${limited.substring(0, 5)}-${limited.substring(5)}`
    }
  }

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>) => {
    setFormData(prev => ({
      ...prev,
      [e.target.name]: e.target.value
    }))
  }

  const handleFormattedChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const { name, value } = e.target

    let formattedValue = value
    if (name === 'cnpj') {
      formattedValue = formatCNPJ(value)
    } else if (name === 'contactPhone') {
      formattedValue = formatPhone(value)
    } else if (name === 'zipCode') {
      formattedValue = formatCEP(value)
    }

    setFormData(prev => ({
      ...prev,
      [name]: formattedValue
    }))
  }

  if (loading) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-purple-50 via-indigo-50 to-blue-50 flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-purple-600 mx-auto"></div>
          <p className="mt-4 text-gray-600">Carregando...</p>
        </div>
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-purple-50 via-indigo-50 to-blue-50 py-12 px-4">
      <div className="max-w-2xl mx-auto">
        {/* Header */}
        <div className="mb-8">
          <button
            onClick={() => router.push('/admin')}
            className="text-purple-600 hover:text-purple-700 font-medium mb-4 flex items-center"
          >
            <svg className="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M10 19l-7-7m0 0l7-7m-7 7h18" />
            </svg>
            Voltar
          </button>
          <h1 className="text-3xl font-bold text-purple-900">Editar Organização</h1>
          <p className="text-gray-600 mt-2">Atualize as informações do escritório</p>
        </div>

        {/* Form */}
        <div className="bg-white rounded-lg shadow-xl p-8 border-2 border-purple-200">
          {error && (
            <div className="bg-red-50 border border-red-200 text-red-800 rounded-lg p-4 mb-6">
              {error}
            </div>
          )}

          <form onSubmit={handleSubmit} className="space-y-6">
            {/* Nome da Organização */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Nome do Escritório *
              </label>
              <input
                type="text"
                name="name"
                required
                value={formData.name}
                onChange={handleChange}
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-transparent"
                placeholder="Ex: Advocacia Silva & Santos"
              />
            </div>

            {/* Plano */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Plano
              </label>
              <select
                name="planType"
                value={formData.planType}
                onChange={handleChange}
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-transparent"
              >
                <option value="trialing">Trialing (50 docs, 100K tokens)</option>
                <option value="basic">Basic (500 docs, 1M tokens)</option>
                <option value="pro">Pro (5K docs, 10M tokens)</option>
                <option value="enterprise">Enterprise (Ilimitado)</option>
              </select>
            </div>

            {/* Informações de Contato */}
            <div className="border-t pt-6">
              <h3 className="text-lg font-semibold text-gray-900 mb-4">
                Informações de Contato
              </h3>

              <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mb-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Nome do Responsável
                  </label>
                  <input
                    type="text"
                    name="contactName"
                    value={formData.contactName}
                    onChange={handleChange}
                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-transparent"
                    placeholder="Ex: João Silva"
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Telefone
                  </label>
                  <input
                    type="tel"
                    name="contactPhone"
                    value={formData.contactPhone}
                    onChange={handleFormattedChange}
                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-transparent"
                    placeholder="(11) 98765-4321"
                  />
                </div>
              </div>

              <div className="mb-4">
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  CNPJ
                </label>
                <input
                  type="text"
                  name="cnpj"
                  value={formData.cnpj}
                  onChange={handleFormattedChange}
                  className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-transparent"
                  placeholder="00.000.000/0000-00"
                />
              </div>

              <div className="mb-4">
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Endereço
                </label>
                <input
                  type="text"
                  name="address"
                  value={formData.address}
                  onChange={handleChange}
                  className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-transparent"
                  placeholder="Rua, número, complemento"
                />
              </div>

              <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Cidade
                  </label>
                  <input
                    type="text"
                    name="city"
                    value={formData.city}
                    onChange={handleChange}
                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-transparent"
                    placeholder="São Paulo"
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Estado
                  </label>
                  <input
                    type="text"
                    name="state"
                    value={formData.state}
                    onChange={handleChange}
                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-transparent"
                    placeholder="SP"
                    maxLength={2}
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    CEP
                  </label>
                  <input
                    type="text"
                    name="zipCode"
                    value={formData.zipCode}
                    onChange={handleFormattedChange}
                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-transparent"
                    placeholder="00000-000"
                  />
                </div>
              </div>
            </div>

            {/* Botões */}
            <div className="flex gap-4 pt-6">
              <button
                type="button"
                onClick={() => router.push('/admin')}
                className="flex-1 px-6 py-3 border border-gray-300 text-gray-700 rounded-lg hover:bg-gray-50 font-medium"
              >
                Cancelar
              </button>
              <button
                type="submit"
                disabled={saving}
                className="flex-1 px-6 py-3 bg-gradient-to-r from-purple-600 to-indigo-600 text-white rounded-lg hover:from-purple-700 hover:to-indigo-700 font-medium disabled:opacity-50 disabled:cursor-not-allowed shadow-lg transition-all hover:scale-105"
              >
                {saving ? (
                  <span className="flex items-center justify-center">
                    <svg className="animate-spin -ml-1 mr-3 h-5 w-5 text-white" fill="none" viewBox="0 0 24 24">
                      <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
                      <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                    </svg>
                    Salvando...
                  </span>
                ) : (
                  '✓ Salvar Alterações'
                )}
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
  )
}
