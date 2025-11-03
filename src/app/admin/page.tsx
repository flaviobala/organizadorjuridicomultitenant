'use client'

import { useEffect, useState } from 'react'
import { useRouter } from 'next/navigation'

interface Organization {
  id: number
  name: string
  planType: string
  subscriptionStatus: string
  documentProcessedCount: number
  aiTokenCount: number
  stripeCustomerId: string | null
  contactName?: string | null
  contactPhone?: string | null
  cnpj?: string | null
  address?: string | null
  city?: string | null
  state?: string | null
  zipCode?: string | null
  createdAt: string
  updatedAt: string
  stats: {
    usersCount: number
    projectsCount: number
    documentsCount: number
  }
  users?: Array<{
    id: number
    name: string
    email: string
    role: string
    createdAt?: string
  }>
}

export default function AdminDashboard() {
  const router = useRouter()
  const [organizations, setOrganizations] = useState<Organization[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState('')
  const [expandedOrgs, setExpandedOrgs] = useState<Set<number>>(new Set())

  // Tab state
  const [activeTab, setActiveTab] = useState<'organizations' | 'users'>('organizations')

  // Filter states
  const [searchTerm, setSearchTerm] = useState('')
  const [filterPlan, setFilterPlan] = useState<string>('all')
  const [filterStatus, setFilterStatus] = useState<string>('all')


  useEffect(() => {
    // Verificar se está logado
    const token = localStorage.getItem('token')
    if (!token) {
      router.push('/login')
      return
    }

    // Verificar role (decodificar JWT básico)
    try {
      const payload = JSON.parse(atob(token.split('.')[1]))
      if (payload.role !== 'super_admin') {
        setError('Acesso negado: você não tem permissão de super administrador')
        setLoading(false)
        return
      }
    } catch (err) {
      router.push('/login')
      return
    }

    fetchOrganizations()
  }, [])

  const fetchOrganizations = async () => {
    try {
      const token = localStorage.getItem('token')
      if (!token) {
        router.push('/login')
        return
      }

      const response = await fetch('/api/admin/organizations', {
        headers: {
          'Authorization': `Bearer ${token}`
        }
      })

      const data = await response.json()

      if (!response.ok) {
        if (response.status === 403) {
          setError('Acesso negado: você não tem permissão de administrador')
        } else {
          setError(data.error || 'Erro ao carregar organizações')
        }
        return
      }

      setOrganizations(data.organizations)
    } catch (err) {
      setError('Erro ao conectar com o servidor')
    } finally {
      setLoading(false)
    }
  }

  const getPlanBadgeColor = (plan: string) => {
    const colors: Record<string, string> = {
      basic: 'bg-gray-100 text-gray-800',
      pro: 'bg-blue-100 text-blue-800',
      enterprise: 'bg-purple-100 text-purple-800',
      trialing: 'bg-yellow-100 text-yellow-800',
    }
    return colors[plan] || 'bg-gray-100 text-gray-800'
  }

  const getStatusBadgeColor = (status: string) => {
    const colors: Record<string, string> = {
      active: 'bg-green-100 text-green-800',
      trialing: 'bg-yellow-100 text-yellow-800',
      past_due: 'bg-red-100 text-red-800',
      canceled: 'bg-gray-100 text-gray-800',
    }
    return colors[status] || 'bg-gray-100 text-gray-800'
  }

  const toggleOrg = (orgId: number) => {
    const newExpanded = new Set(expandedOrgs)
    if (newExpanded.has(orgId)) {
      newExpanded.delete(orgId)
    } else {
      newExpanded.add(orgId)
    }
    setExpandedOrgs(newExpanded)
  }

  const getRoleIcon = (role: string) => {
    if (role === 'super_admin') return '👑'
    if (role === 'admin') return '🔑'
    return '👤'
  }

  // Filtrar organizações
  const filteredOrganizations = organizations.filter(org => {
    // Filtro de busca por nome
    const matchesSearch = org.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
                          org.contactName?.toLowerCase().includes(searchTerm.toLowerCase()) ||
                          org.cnpj?.includes(searchTerm)

    // Filtro de plano
    const matchesPlan = filterPlan === 'all' || org.planType === filterPlan

    // Filtro de status
    const matchesStatus = filterStatus === 'all' || org.subscriptionStatus === filterStatus

    return matchesSearch && matchesPlan && matchesStatus
  })

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto"></div>
          <p className="mt-4 text-gray-600">Carregando...</p>
        </div>
      </div>
    )
  }

  if (error) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="bg-white p-8 rounded-lg shadow-md max-w-md">
          <div className="text-red-600 text-center">
            <svg className="w-16 h-16 mx-auto mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
            </svg>
            <h2 className="text-xl font-bold mb-2">Erro</h2>
            <p>{error}</p>
            <button
              onClick={() => router.push('/dashboard')}
              className="mt-4 px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700"
            >
              Voltar ao Dashboard
            </button>
          </div>
        </div>
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-purple-50 via-indigo-50 to-blue-50">
      {/* Header com gradiente premium */}
      <div className="bg-gradient-to-r from-purple-600 via-purple-700 to-indigo-700 shadow-lg">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
          <div className="flex justify-between items-center">
            <div>
              <div className="flex items-center gap-3 mb-2">
                <span className="text-4xl">👑</span>
                <h1 className="text-3xl font-bold text-white">Super Admin Dashboard</h1>
              </div>
              <p className="text-purple-100 mt-1 ml-14">Gerenciamento Central do Sistema</p>
            </div>
            <button
              onClick={() => router.push('/admin/new-organization')}
              className="px-6 py-3 bg-white text-purple-700 rounded-lg hover:bg-purple-50 flex items-center font-semibold shadow-lg transition-all hover:scale-105"
            >
              <svg className="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 4v16m8-8H4" />
              </svg>
              Nova Organização
            </button>
          </div>
        </div>
      </div>

      {/* Tabs com estilo premium */}
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 pt-6">
        <div className="border-b-2 border-purple-200">
          <nav className="-mb-0.5 flex gap-8">
            <button
              onClick={() => setActiveTab('organizations')}
              className={`py-4 px-6 border-b-2 font-semibold text-sm transition-all ${
                activeTab === 'organizations'
                  ? 'border-purple-600 text-purple-700 bg-white rounded-t-lg'
                  : 'border-transparent text-gray-600 hover:text-purple-600 hover:bg-white/50 rounded-t-lg'
              }`}
            >
              📊 Organizações ({filteredOrganizations.length}/{organizations.length})
            </button>
            <button
              onClick={() => setActiveTab('users')}
              className={`py-4 px-6 border-b-2 font-semibold text-sm transition-all ${
                activeTab === 'users'
                  ? 'border-purple-600 text-purple-700 bg-white rounded-t-lg'
                  : 'border-transparent text-gray-600 hover:text-purple-600 hover:bg-white/50 rounded-t-lg'
              }`}
            >
              👥 Todos os Usuários
            </button>
          </nav>
        </div>
      </div>

      {/* Filtros de Pesquisa */}
      {activeTab === 'organizations' && (
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 pt-6">
          <div className="bg-white rounded-xl shadow-lg p-6 border-2 border-purple-200 mb-6">
            <h3 className="text-lg font-bold text-purple-900 mb-4">🔍 Filtros de Pesquisa</h3>
            <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
              {/* Campo de busca */}
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Buscar por Nome, Responsável ou CNPJ
                </label>
                <input
                  type="text"
                  value={searchTerm}
                  onChange={(e) => setSearchTerm(e.target.value)}
                  placeholder="Digite para buscar..."
                  className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-transparent"
                />
              </div>

              {/* Filtro por plano */}
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Tipo de Plano
                </label>
                <select
                  value={filterPlan}
                  onChange={(e) => setFilterPlan(e.target.value)}
                  className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-transparent"
                >
                  <option value="all">Todos os Planos</option>
                  <option value="trialing">Trialing</option>
                  <option value="basic">Basic</option>
                  <option value="pro">Pro</option>
                  <option value="enterprise">Enterprise</option>
                </select>
              </div>

              {/* Filtro por status */}
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Status da Assinatura
                </label>
                <select
                  value={filterStatus}
                  onChange={(e) => setFilterStatus(e.target.value)}
                  className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-transparent"
                >
                  <option value="all">Todos os Status</option>
                  <option value="trialing">Trialing</option>
                  <option value="active">Active</option>
                  <option value="past_due">Past Due</option>
                  <option value="canceled">Canceled</option>
                </select>
              </div>
            </div>

            {/* Botão de limpar filtros */}
            {(searchTerm || filterPlan !== 'all' || filterStatus !== 'all') && (
              <div className="mt-4 flex justify-end">
                <button
                  onClick={() => {
                    setSearchTerm('')
                    setFilterPlan('all')
                    setFilterStatus('all')
                  }}
                  className="px-4 py-2 text-sm bg-gray-200 text-gray-700 rounded-lg hover:bg-gray-300 font-medium"
                >
                  🗑️ Limpar Filtros
                </button>
              </div>
            )}
          </div>
        </div>
      )}

      {/* Stats Cards com gradiente premium */}
      {activeTab === 'organizations' && (
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div className="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8">
          <div className="bg-gradient-to-br from-purple-500 to-purple-700 rounded-xl shadow-lg p-6 text-white transform hover:scale-105 transition-transform">
            <div className="text-sm text-purple-100 mb-1 font-medium">Total de Organizações</div>
            <div className="text-4xl font-bold">{organizations.length}</div>
          </div>
          <div className="bg-gradient-to-br from-green-500 to-emerald-600 rounded-xl shadow-lg p-6 text-white transform hover:scale-105 transition-transform">
            <div className="text-sm text-green-100 mb-1 font-medium">Assinaturas Ativas</div>
            <div className="text-4xl font-bold">
              {organizations.filter(o => o.subscriptionStatus === 'active').length}
            </div>
          </div>
          <div className="bg-gradient-to-br from-amber-500 to-orange-600 rounded-xl shadow-lg p-6 text-white transform hover:scale-105 transition-transform">
            <div className="text-sm text-amber-100 mb-1 font-medium">Em Trial</div>
            <div className="text-4xl font-bold">
              {organizations.filter(o => o.subscriptionStatus === 'trialing').length}
            </div>
          </div>
          <div className="bg-gradient-to-br from-blue-500 to-indigo-600 rounded-xl shadow-lg p-6 text-white transform hover:scale-105 transition-transform">
            <div className="text-sm text-blue-100 mb-1 font-medium">Total de Documentos</div>
            <div className="text-4xl font-bold">
              {organizations.reduce((sum, o) => sum + o.stats.documentsCount, 0)}
            </div>
          </div>
        </div>

        {/* Organizations Cards com cores alternadas */}
        <div className="space-y-4">
          {filteredOrganizations.length === 0 ? (
            <div className="bg-white rounded-xl shadow-lg p-12 text-center border-2 border-purple-200">
              <div className="text-6xl mb-4">🔍</div>
              <h3 className="text-xl font-bold text-gray-900 mb-2">Nenhuma organização encontrada</h3>
              <p className="text-gray-600">Tente ajustar os filtros de pesquisa</p>
            </div>
          ) : (
            filteredOrganizations.map((org, index) => {
            const isExpanded = expandedOrgs.has(org.id)
            const isEven = index % 2 === 0
            return (
              <div key={org.id} className={`rounded-xl shadow-lg overflow-hidden border-2 ${
                isEven
                  ? 'bg-white border-purple-200'
                  : 'bg-gradient-to-r from-purple-50 to-indigo-50 border-indigo-200'
              }`}>
                {/* Card Header - Clicável para expandir */}
                <div
                  onClick={() => toggleOrg(org.id)}
                  className={`p-6 cursor-pointer transition-all ${
                    isEven
                      ? 'hover:bg-purple-50'
                      : 'hover:bg-gradient-to-r hover:from-purple-100 hover:to-indigo-100'
                  }`}
                >
                  <div className="flex items-center justify-between">
                    <div className="flex-1">
                      <div className="flex items-center gap-3">
                        <h3 className="text-xl font-bold text-gray-900">{org.name}</h3>
                        <span className={`px-3 py-1 text-xs font-semibold rounded-full ${getPlanBadgeColor(org.planType)}`}>
                          {org.planType}
                        </span>
                        <span className={`px-3 py-1 text-xs font-semibold rounded-full ${getStatusBadgeColor(org.subscriptionStatus)}`}>
                          {org.subscriptionStatus}
                        </span>
                      </div>
                      <div className="mt-3 flex gap-6 text-sm font-medium text-gray-700">
                        <span>👥 {org.stats.usersCount} usuários</span>
                        <span>📁 {org.stats.projectsCount} projetos</span>
                        <span>📄 {org.stats.documentsCount} documentos</span>
                        <span>🤖 {org.aiTokenCount.toLocaleString()} tokens</span>
                      </div>
                    </div>
                    <button className="ml-4 p-3 hover:bg-purple-200 rounded-full transition-all">
                      <svg
                        className={`w-6 h-6 text-purple-600 transform transition-transform ${isExpanded ? 'rotate-180' : ''}`}
                        fill="none"
                        stroke="currentColor"
                        viewBox="0 0 24 24"
                      >
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 9l-7 7-7-7" />
                      </svg>
                    </button>
                  </div>
                </div>

                {/* Card Body - Expandível com informações e usuários */}
                {isExpanded && (
                  <div className="border-t-2 border-purple-200 bg-gradient-to-br from-gray-50 to-purple-50 p-6">
                    <div className="flex justify-between items-center mb-6">
                      <h4 className="text-lg font-bold text-purple-900">Detalhes da Organização</h4>
                      <button
                        onClick={(e) => {
                          e.stopPropagation()
                          router.push(`/admin/edit-organization/${org.id}`)
                        }}
                        className="px-5 py-2 text-sm bg-gradient-to-r from-purple-600 to-indigo-600 text-white rounded-lg hover:from-purple-700 hover:to-indigo-700 font-semibold shadow-md transition-all hover:scale-105"
                      >
                        ✏️ Editar
                      </button>
                    </div>

                    {/* Informações de Contato */}
                    {(org.contactName || org.contactPhone || org.cnpj || org.address) && (
                      <div className="bg-white rounded-lg p-4 mb-6 border border-purple-200">
                        <h5 className="text-sm font-bold text-gray-700 mb-3">📞 Informações de Contato</h5>
                        <div className="grid grid-cols-1 md:grid-cols-2 gap-3 text-sm">
                          {org.contactName && (
                            <div>
                              <span className="text-gray-600 font-medium">Responsável:</span>
                              <span className="ml-2 text-gray-900">{org.contactName}</span>
                            </div>
                          )}
                          {org.contactPhone && (
                            <div>
                              <span className="text-gray-600 font-medium">Telefone:</span>
                              <span className="ml-2 text-gray-900">{org.contactPhone}</span>
                            </div>
                          )}
                          {org.cnpj && (
                            <div>
                              <span className="text-gray-600 font-medium">CNPJ:</span>
                              <span className="ml-2 text-gray-900">{org.cnpj}</span>
                            </div>
                          )}
                          {org.address && (
                            <div className="md:col-span-2">
                              <span className="text-gray-600 font-medium">Endereço:</span>
                              <span className="ml-2 text-gray-900">
                                {org.address}
                                {org.city && `, ${org.city}`}
                                {org.state && ` - ${org.state}`}
                                {org.zipCode && ` - CEP: ${org.zipCode}`}
                              </span>
                            </div>
                          )}
                        </div>
                      </div>
                    )}

                    <h5 className="text-sm font-bold text-purple-900 mb-3">👥 Usuários da Organização:</h5>
                    {org.users && org.users.length > 0 ? (
                      <div className="space-y-2">
                        {org.users.map((user, userIndex) => (
                          <div key={user.id} className={`rounded-lg p-4 flex items-center justify-between border ${
                            userIndex % 2 === 0
                              ? 'bg-white border-purple-100'
                              : 'bg-purple-50 border-purple-200'
                          }`}>
                            <div className="flex items-center gap-3">
                              <span className="text-2xl">{getRoleIcon(user.role)}</span>
                              <div>
                                <div className="font-semibold text-gray-900">{user.name}</div>
                                <div className="text-sm text-gray-600">{user.email}</div>
                              </div>
                            </div>
                            <span className={`px-3 py-1 text-xs font-semibold rounded-full ${
                              user.role === 'admin' ? 'bg-blue-100 text-blue-800' : 'bg-gray-100 text-gray-800'
                            }`}>
                              {user.role}
                            </span>
                          </div>
                        ))}
                      </div>
                    ) : (
                      <p className="text-gray-500 text-sm italic">Nenhum usuário cadastrado</p>
                    )}
                  </div>
                )}
              </div>
            )
          })
          )}
        </div>
      </div>
      )}

      {/* Users Tab com zebra striping */}
      {activeTab === 'users' && (
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
          <div className="bg-white rounded-xl shadow-xl overflow-hidden border-2 border-purple-200">
            <table className="min-w-full">
              <thead className="bg-gradient-to-r from-purple-600 to-indigo-700">
                <tr>
                  <th className="px-6 py-4 text-left text-xs font-bold text-white uppercase tracking-wider">Usuário</th>
                  <th className="px-6 py-4 text-left text-xs font-bold text-white uppercase tracking-wider">Email</th>
                  <th className="px-6 py-4 text-left text-xs font-bold text-white uppercase tracking-wider">Role</th>
                  <th className="px-6 py-4 text-left text-xs font-bold text-white uppercase tracking-wider">Organização</th>
                  <th className="px-6 py-4 text-left text-xs font-bold text-white uppercase tracking-wider">Cadastro</th>
                </tr>
              </thead>
              <tbody>
                {organizations.flatMap((org, orgIndex) =>
                  (org.users || [])
                    .filter(user => user.role !== 'super_admin') // Filtrar super_admin
                    .map((user, userIndex) => {
                      const globalIndex = organizations.slice(0, orgIndex).reduce((sum, o) =>
                        sum + (o.users?.filter(u => u.role !== 'super_admin').length || 0), 0
                      ) + userIndex
                      const isEven = globalIndex % 2 === 0
                      return (
                        <tr key={user.id} className={`transition-colors ${
                          isEven
                            ? 'bg-white hover:bg-purple-50'
                            : 'bg-purple-50 hover:bg-purple-100'
                        }`}>
                          <td className="px-6 py-4 whitespace-nowrap">
                            <div className="flex items-center">
                              <span className="text-xl mr-3">{getRoleIcon(user.role)}</span>
                              <span className="font-semibold text-gray-900">{user.name}</span>
                            </div>
                          </td>
                          <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-700 font-medium">
                            {user.email}
                          </td>
                          <td className="px-6 py-4 whitespace-nowrap">
                            <span className={`px-3 py-1 text-xs font-bold rounded-full ${
                              user.role === 'admin' ? 'bg-blue-200 text-blue-900' : 'bg-gray-200 text-gray-900'
                            }`}>
                              {user.role}
                            </span>
                          </td>
                          <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900 font-medium">
                            {org.name}
                          </td>
                          <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-600">
                            {user.createdAt ? new Date(user.createdAt).toLocaleDateString('pt-BR') : '-'}
                          </td>
                        </tr>
                      )
                    })
                )}
              </tbody>
            </table>
          </div>
        </div>
      )}

    </div>
  )
}
