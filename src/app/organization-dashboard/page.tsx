'use client'

import { useEffect, useState } from 'react'
import { useRouter } from 'next/navigation'

interface User {
  id: number
  name: string
  email: string
  role: string
  createdAt: string
}

interface Project {
  id: number
  name: string
  client: string
  status: string
  actionType: string
  createdAt: string
  user: {
    id: number
    name: string
    email: string
  }
  _count: {
    documents: number
  }
}

interface OrganizationStats {
  name: string
  planType: string
  subscriptionStatus: string
  aiTokenCount: number
  documentProcessedCount: number
  limits: {
    maxTokens: number
    maxDocuments: number
    maxUsers: number
  }
  stats: {
    totalUsers: number
    totalProjects: number
    totalDocuments: number
  }
}

export default function OrganizationDashboard() {
  const router = useRouter()
  const [stats, setStats] = useState<OrganizationStats | null>(null)
  const [users, setUsers] = useState<User[]>([])
  const [projects, setProjects] = useState<Project[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState('')
  const [successMessage, setSuccessMessage] = useState<string | null>(null)
  const [activeTab, setActiveTab] = useState<'overview' | 'users' | 'projects'>('overview')

  // Filtros
  const [filterUser, setFilterUser] = useState<string>('all')
  const [filterStatus, setFilterStatus] = useState<string>('all')
  const [searchTerm, setSearchTerm] = useState('')

  useEffect(() => {
    const token = localStorage.getItem('token')
    if (!token) {
      router.push('/login')
      return
    }

    // Verificar se é admin ou super_admin
    try {
      const payload = JSON.parse(atob(token.split('.')[1]))
      if (payload.role !== 'admin' && payload.role !== 'super_admin') {
        setError('Acesso negado: você precisa ser administrador da organização')
        setLoading(false)
        return
      }
    } catch (err) {
      router.push('/login')
      return
    }

    // Verificar se há mensagem de sucesso na URL
    const urlParams = new URLSearchParams(window.location.search)
    const tab = urlParams.get('tab')
    const success = urlParams.get('success')

    if (tab) {
      setActiveTab(tab as 'overview' | 'users' | 'projects')
    }

    if (success === 'user-created') {
      setSuccessMessage('✅ Usuário criado com sucesso!')
      setTimeout(() => setSuccessMessage(null), 5000)
      // Limpar URL
      window.history.replaceState({}, '', '/organization-dashboard')
    }

    fetchDashboardData()
  }, [])

  const fetchDashboardData = async () => {
    try {
      const token = localStorage.getItem('token')
      if (!token) return

      // Buscar estatísticas da organização
      const statsResponse = await fetch('/api/organization/stats', {
        headers: { 'Authorization': `Bearer ${token}` }
      })

      // Buscar usuários
      const usersResponse = await fetch('/api/organization/users', {
        headers: { 'Authorization': `Bearer ${token}` }
      })

      // Buscar projetos
      const projectsResponse = await fetch('/api/organization/projects', {
        headers: { 'Authorization': `Bearer ${token}` }
      })

      if (!statsResponse.ok || !usersResponse.ok || !projectsResponse.ok) {
        throw new Error('Erro ao carregar dados')
      }

      const statsData = await statsResponse.json()
      const usersData = await usersResponse.json()
      const projectsData = await projectsResponse.json()

      setStats(statsData.data)
      setUsers(usersData.users)
      setProjects(projectsData.projects)
    } catch (err) {
      setError('Erro ao conectar com o servidor')
    } finally {
      setLoading(false)
    }
  }

  const getTokenUsagePercentage = () => {
    if (!stats) return 0
    if (stats.limits.maxTokens === -1) return 0 // ilimitado
    return Math.min((stats.aiTokenCount / stats.limits.maxTokens) * 100, 100)
  }

  const getDocumentUsagePercentage = () => {
    if (!stats) return 0
    if (stats.limits.maxDocuments === -1) return 0 // ilimitado
    return Math.min((stats.documentProcessedCount / stats.limits.maxDocuments) * 100, 100)
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
      draft: 'bg-gray-100 text-gray-700',
      processing: 'bg-blue-100 text-blue-700',
      completed: 'bg-green-100 text-green-700',
      validated: 'bg-purple-100 text-purple-700',
    }
    return colors[status] || 'bg-gray-100 text-gray-700'
  }

  // Filtrar projetos
  const filteredProjects = projects.filter(project => {
    const matchesUser = filterUser === 'all' || project.user.id.toString() === filterUser
    const matchesStatus = filterStatus === 'all' || project.status === filterStatus
    const matchesSearch = project.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
                          project.client.toLowerCase().includes(searchTerm.toLowerCase()) ||
                          project.user.name.toLowerCase().includes(searchTerm.toLowerCase())
    return matchesUser && matchesStatus && matchesSearch
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
            <h2 className="text-xl font-bold mb-2">Erro</h2>
            <p>{error}</p>
            <button
              onClick={() => router.push('/dashboard')}
              className="mt-4 px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700"
            >
              Voltar
            </button>
          </div>
        </div>
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 via-indigo-50 to-purple-50">
      {/* Mensagem de Sucesso */}
      {successMessage && (
        <div className="fixed top-4 right-4 z-50 bg-green-500 text-white px-6 py-4 rounded-lg shadow-lg flex items-center gap-3 animate-slide-in">
          <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
          </svg>
          <span className="font-medium">{successMessage}</span>
          <button
            onClick={() => setSuccessMessage(null)}
            className="ml-2 hover:bg-green-600 rounded-full p-1"
          >
            <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
            </svg>
          </button>
        </div>
      )}

      {/* Header */}
      <div className="bg-gradient-to-r from-blue-600 via-indigo-600 to-purple-600 shadow-lg">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
          <div className="flex justify-between items-center">
            <div>
              <div className="flex items-center gap-3 mb-2">
                <span className="text-4xl">🏢</span>
                <h1 className="text-3xl font-bold text-white">{stats?.name || 'Organização'}</h1>
              </div>
              <div className="flex items-center gap-3 ml-14">
                <span className={`px-3 py-1 text-xs font-semibold rounded-full ${getPlanBadgeColor(stats?.planType || 'basic')}`}>
                  📦 Plano {stats?.planType?.toUpperCase()}
                </span>
                <span className="text-sm text-blue-100">
                  Status: <span className="font-semibold text-white">{stats?.subscriptionStatus}</span>
                </span>
              </div>
            </div>
            <button
              onClick={() => router.push('/dashboard')}
              className="px-6 py-3 bg-white text-blue-700 rounded-lg hover:bg-blue-50 font-semibold shadow-lg transition-all hover:scale-105"
            >
              ← Voltar ao Dashboard
            </button>
          </div>
        </div>
      </div>

      {/* Tabs */}
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 pt-6">
        <div className="border-b-2 border-blue-200">
          <nav className="-mb-0.5 flex gap-8">
            <button
              onClick={() => setActiveTab('overview')}
              className={`py-4 px-6 border-b-2 font-semibold text-sm transition-all ${
                activeTab === 'overview'
                  ? 'border-blue-600 text-blue-700 bg-white rounded-t-lg'
                  : 'border-transparent text-gray-600 hover:text-blue-600 hover:bg-white/50 rounded-t-lg'
              }`}
            >
              📊 Visão Geral
            </button>
            <button
              onClick={() => setActiveTab('users')}
              className={`py-4 px-6 border-b-2 font-semibold text-sm transition-all ${
                activeTab === 'users'
                  ? 'border-blue-600 text-blue-700 bg-white rounded-t-lg'
                  : 'border-transparent text-gray-600 hover:text-blue-600 hover:bg-white/50 rounded-t-lg'
              }`}
            >
              👥 Usuários ({users.length})
            </button>
            <button
              onClick={() => setActiveTab('projects')}
              className={`py-4 px-6 border-b-2 font-semibold text-sm transition-all ${
                activeTab === 'projects'
                  ? 'border-blue-600 text-blue-700 bg-white rounded-t-lg'
                  : 'border-transparent text-gray-600 hover:text-blue-600 hover:bg-white/50 rounded-t-lg'
              }`}
            >
              📁 Projetos ({projects.length})
            </button>
          </nav>
        </div>
      </div>

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {/* Tab: Visão Geral */}
        {activeTab === 'overview' && stats && (
          <div className="space-y-6">
            {/* Stats Cards */}
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
              <div className="bg-gradient-to-br from-blue-500 to-blue-700 rounded-xl shadow-lg p-6 text-white transform hover:scale-105 transition-transform">
                <div className="text-sm text-blue-100 mb-1 font-medium">👥 Total de Usuários</div>
                <div className="text-4xl font-bold">{stats.stats.totalUsers}</div>
                <div className="text-xs text-blue-200 mt-2">
                  Limite: {stats.limits.maxUsers === -1 ? 'Ilimitado' : stats.limits.maxUsers}
                </div>
              </div>

              <div className="bg-gradient-to-br from-purple-500 to-purple-700 rounded-xl shadow-lg p-6 text-white transform hover:scale-105 transition-transform">
                <div className="text-sm text-purple-100 mb-1 font-medium">📁 Total de Projetos</div>
                <div className="text-4xl font-bold">{stats.stats.totalProjects}</div>
              </div>

              <div className="bg-gradient-to-br from-green-500 to-green-700 rounded-xl shadow-lg p-6 text-white transform hover:scale-105 transition-transform">
                <div className="text-sm text-green-100 mb-1 font-medium">📄 Documentos Processados</div>
                <div className="text-4xl font-bold">{stats.documentProcessedCount.toLocaleString()}</div>
                <div className="text-xs text-green-200 mt-2">
                  Limite: {stats.limits.maxDocuments === -1 ? 'Ilimitado' : stats.limits.maxDocuments.toLocaleString()}
                </div>
              </div>

              <div className="bg-gradient-to-br from-orange-500 to-orange-700 rounded-xl shadow-lg p-6 text-white transform hover:scale-105 transition-transform">
                <div className="text-sm text-orange-100 mb-1 font-medium">🤖 Tokens IA Consumidos</div>
                <div className="text-4xl font-bold">{stats.aiTokenCount.toLocaleString()}</div>
                <div className="text-xs text-orange-200 mt-2">
                  Limite: {stats.limits.maxTokens === -1 ? 'Ilimitado' : stats.limits.maxTokens.toLocaleString()}
                </div>
              </div>
            </div>

            {/* Usage Bars */}
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              {/* Tokens Usage */}
              <div className="bg-white rounded-xl shadow-lg p-6 border-2 border-blue-200">
                <h3 className="text-lg font-bold text-gray-900 mb-4">📊 Uso de Tokens IA</h3>
                <div className="space-y-2">
                  <div className="flex justify-between text-sm">
                    <span className="text-gray-600">Consumido</span>
                    <span className="font-semibold">{stats.aiTokenCount.toLocaleString()} tokens</span>
                  </div>
                  <div className="w-full bg-gray-200 rounded-full h-4 overflow-hidden">
                    <div
                      className={`h-full rounded-full transition-all ${
                        getTokenUsagePercentage() > 90 ? 'bg-red-500' :
                        getTokenUsagePercentage() > 70 ? 'bg-yellow-500' : 'bg-green-500'
                      }`}
                      style={{ width: `${getTokenUsagePercentage()}%` }}
                    ></div>
                  </div>
                  <div className="flex justify-between text-xs text-gray-500">
                    <span>0</span>
                    <span>{stats.limits.maxTokens === -1 ? 'Ilimitado' : `${stats.limits.maxTokens.toLocaleString()} tokens`}</span>
                  </div>
                </div>
              </div>

              {/* Documents Usage */}
              <div className="bg-white rounded-xl shadow-lg p-6 border-2 border-purple-200">
                <h3 className="text-lg font-bold text-gray-900 mb-4">📄 Documentos Processados</h3>
                <div className="space-y-2">
                  <div className="flex justify-between text-sm">
                    <span className="text-gray-600">Processados</span>
                    <span className="font-semibold">{stats.documentProcessedCount.toLocaleString()} docs</span>
                  </div>
                  <div className="w-full bg-gray-200 rounded-full h-4 overflow-hidden">
                    <div
                      className={`h-full rounded-full transition-all ${
                        getDocumentUsagePercentage() > 90 ? 'bg-red-500' :
                        getDocumentUsagePercentage() > 70 ? 'bg-yellow-500' : 'bg-green-500'
                      }`}
                      style={{ width: `${getDocumentUsagePercentage()}%` }}
                    ></div>
                  </div>
                  <div className="flex justify-between text-xs text-gray-500">
                    <span>0</span>
                    <span>{stats.limits.maxDocuments === -1 ? 'Ilimitado' : `${stats.limits.maxDocuments.toLocaleString()} docs`}</span>
                  </div>
                </div>
              </div>
            </div>
          </div>
        )}

        {/* Tab: Usuários */}
        {activeTab === 'users' && (
          <div className="space-y-6">
            <div className="flex justify-between items-center">
              <h2 className="text-2xl font-bold text-gray-900">Gerenciar Usuários</h2>
              <button
                onClick={() => router.push('/organization-dashboard/new-user')}
                className="px-6 py-3 bg-gradient-to-r from-blue-600 to-indigo-600 text-white rounded-lg hover:from-blue-700 hover:to-indigo-700 font-semibold shadow-lg transition-all hover:scale-105"
              >
                + Adicionar Usuário
              </button>
            </div>

            <div className="bg-white rounded-xl shadow-lg overflow-hidden border-2 border-blue-200">
              <table className="min-w-full divide-y divide-gray-200">
                <thead className="bg-gradient-to-r from-blue-50 to-indigo-50">
                  <tr>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-700 uppercase tracking-wider">Usuário</th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-700 uppercase tracking-wider">Email</th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-700 uppercase tracking-wider">Função</th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-700 uppercase tracking-wider">Criado em</th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-700 uppercase tracking-wider">Ações</th>
                  </tr>
                </thead>
                <tbody className="bg-white divide-y divide-gray-200">
                  {users.map((user, index) => (
                    <tr key={user.id} className={index % 2 === 0 ? 'bg-white' : 'bg-gray-50'}>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="flex items-center">
                          <div className="flex-shrink-0 h-10 w-10 bg-blue-100 rounded-full flex items-center justify-center">
                            <span className="text-lg">{user.role === 'admin' ? '👑' : '👤'}</span>
                          </div>
                          <div className="ml-4">
                            <div className="text-sm font-medium text-gray-900">{user.name}</div>
                          </div>
                        </div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="text-sm text-gray-900">{user.email}</div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <span className={`px-3 py-1 inline-flex text-xs leading-5 font-semibold rounded-full ${
                          user.role === 'admin' ? 'bg-purple-100 text-purple-800' : 'bg-gray-100 text-gray-800'
                        }`}>
                          {user.role === 'admin' ? 'Administrador' : 'Membro'}
                        </span>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                        {new Date(user.createdAt).toLocaleDateString('pt-BR')}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm font-medium">
                        <button className="text-blue-600 hover:text-blue-900 mr-4">Editar</button>
                        <button className="text-red-600 hover:text-red-900">Desativar</button>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        )}

        {/* Tab: Projetos */}
        {activeTab === 'projects' && (
          <div className="space-y-6">
            <h2 className="text-2xl font-bold text-gray-900">Todos os Projetos da Organização</h2>

            {/* Filtros */}
            <div className="bg-white rounded-xl shadow-lg p-6 border-2 border-blue-200">
              <h3 className="text-lg font-bold text-gray-900 mb-4">🔍 Filtros</h3>
              <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">Buscar</label>
                  <input
                    type="text"
                    value={searchTerm}
                    onChange={(e) => setSearchTerm(e.target.value)}
                    placeholder="Nome, cliente ou usuário..."
                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">Usuário</label>
                  <select
                    value={filterUser}
                    onChange={(e) => setFilterUser(e.target.value)}
                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                  >
                    <option value="all">Todos os usuários</option>
                    {users.map(user => (
                      <option key={user.id} value={user.id.toString()}>{user.name}</option>
                    ))}
                  </select>
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">Status</label>
                  <select
                    value={filterStatus}
                    onChange={(e) => setFilterStatus(e.target.value)}
                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                  >
                    <option value="all">Todos os status</option>
                    <option value="draft">Rascunho</option>
                    <option value="processing">Processando</option>
                    <option value="completed">Concluído</option>
                    <option value="validated">Validado</option>
                  </select>
                </div>
              </div>
            </div>

            {/* Lista de Projetos */}
            <div className="space-y-4">
              {filteredProjects.map((project, index) => (
                <div key={project.id} className={`bg-white rounded-xl shadow-lg p-6 border-2 ${
                  index % 2 === 0 ? 'border-blue-200' : 'border-purple-200'
                }`}>
                  <div className="flex justify-between items-start">
                    <div className="flex-1">
                      <div className="flex items-center gap-3 mb-2">
                        <h3 className="text-xl font-bold text-gray-900">{project.name}</h3>
                        <span className={`px-3 py-1 text-xs font-semibold rounded-full ${getStatusBadgeColor(project.status)}`}>
                          {project.status}
                        </span>
                      </div>
                      <div className="grid grid-cols-1 md:grid-cols-3 gap-4 text-sm text-gray-600">
                        <div>
                          <span className="font-medium">Cliente:</span> {project.client}
                        </div>
                        <div>
                          <span className="font-medium">Tipo de Ação:</span> {project.actionType}
                        </div>
                        <div>
                          <span className="font-medium">Documentos:</span> {project._count.documents}
                        </div>
                      </div>
                      <div className="mt-2 flex items-center gap-2 text-sm">
                        <span className="inline-flex items-center gap-1 text-blue-600">
                          <span className="text-lg">👤</span>
                          <span className="font-medium">{project.user.name}</span>
                        </span>
                        <span className="text-gray-400">•</span>
                        <span className="text-gray-500">
                          Criado em {new Date(project.createdAt).toLocaleDateString('pt-BR')}
                        </span>
                      </div>
                    </div>
                    <button
                      onClick={() => router.push(`/projects/${project.id}`)}
                      className="ml-4 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 font-medium transition-all hover:scale-105"
                    >
                      Ver Detalhes →
                    </button>
                  </div>
                </div>
              ))}

              {filteredProjects.length === 0 && (
                <div className="bg-white rounded-xl shadow-lg p-12 text-center border-2 border-gray-200">
                  <div className="text-6xl mb-4">📁</div>
                  <h3 className="text-xl font-bold text-gray-900 mb-2">Nenhum projeto encontrado</h3>
                  <p className="text-gray-600">Tente ajustar os filtros de busca</p>
                </div>
              )}
            </div>
          </div>
        )}
      </div>
    </div>
  )
}
