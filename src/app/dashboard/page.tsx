'use client'
import { useState, useEffect } from 'react'
import { useRouter } from 'next/navigation'
import {
  Search,
  FileText,
  User,
  LogOut,
  Eye,
  Edit3,
  Trash2,
  CheckCircle,
  Clock,
  AlertCircle,
  Scale,
  FilePlus
} from 'lucide-react'
import TokenUsageCard from '@/components/TokenUsageCard'
import TokenUsageBadge from '@/components/TokenUsageBadge'
import SubscriptionCard from '@/components/SubscriptionCard'

interface Project {
  id: number
  name: string
  client: string
  system: string
  actionType: string
  status: string
  createdAt: string
  documentsCount: number
  processedNarrative?: string
}

interface User {
  id: number
  name: string
  email: string
}

export default function DashboardPage() {
  const router = useRouter()
  const [user, setUser] = useState<User | null>(null)
  const [userRole, setUserRole] = useState<string>('')
  const [projects, setProjects] = useState<Project[]>([])
  const [isLoading, setIsLoading] = useState(true)
  const [searchTerm, setSearchTerm] = useState('')
  const [statusFilter, setStatusFilter] = useState('all')
  const [deleteConfirmModal, setDeleteConfirmModal] = useState<{ message: string, onConfirm: () => void } | null>(null)
  const [successMessage, setSuccessMessage] = useState<string | null>(null)

  useEffect(() => {
    // Verificar autenticação
    const token = localStorage.getItem('token')
    const userData = localStorage.getItem('user')

    if (!token || !userData) {
      router.push('/login')
      return
    }

    // Decodificar token para pegar o role
    try {
      const payload = JSON.parse(atob(token.split('.')[1]))
      setUserRole(payload.role || '')
    } catch (err) {
      console.error('Erro ao decodificar token:', err)
    }

    setUser(JSON.parse(userData))
    loadProjects()

    // Verificar se voltou do pagamento
    const urlParams = new URLSearchParams(window.location.search)
    if (urlParams.get('payment') === 'success') {
      const plan = urlParams.get('plan')
      const subscriptionId = urlParams.get('subscriptionId')

      setSuccessMessage(`✅ Assinatura do plano ${plan?.toUpperCase()} realizada com sucesso! Atualizando...`)

      // Atualizar banco via API
      fetch(`/api/billing/mercadopago/process-return?organizationId=${subscriptionId}&plan=${plan}`, {
        headers: {
          'Authorization': `Bearer ${token}`
        }
      }).then(() => {
        // Redirecionar após processar
        setTimeout(() => {
          window.location.href = '/dashboard'
        }, 2000)
      }).catch(err => {
        console.error('Erro ao processar retorno:', err)
        setTimeout(() => {
          window.location.href = '/dashboard'
        }, 2000)
      })
    }
  }, [router])

  const loadProjects = async () => {
    try {
      const token = localStorage.getItem('token')
      const response = await fetch('/api/projects', {
        headers: {
          'Authorization': `Bearer ${token}`
        }
      })

      const data = await response.json()

      if (data.success) {
        setProjects(data.projects)
      } else {
        console.error('Erro ao carregar projetos:', data.error)
      }
    } catch (error) {
      console.error('Erro ao carregar projetos:', error)
    } finally {
      setIsLoading(false)
    }
  }

  const handleLogout = () => {
    localStorage.removeItem('token')
    localStorage.removeItem('user')
    router.push('/login')
  }

  const getStatusInfo = (status: string) => {
    switch (status) {
      case 'draft':
        return { label: 'Rascunho', color: 'text-gray-600 bg-gray-100', icon: Edit3 }
      case 'processing':
        return { label: 'Processando', color: 'text-blue-600 bg-blue-100', icon: Clock }
      case 'completed':
        return { label: 'Concluído', color: 'text-green-600 bg-green-100', icon: CheckCircle }
      case 'validated':
        return { label: 'Validado', color: 'text-purple-600 bg-purple-100', icon: CheckCircle }
      default:
        return { label: 'Desconhecido', color: 'text-gray-600 bg-gray-100', icon: AlertCircle }
    }
  }

  const filteredProjects = projects.filter(project => {
    const matchesSearch = project.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         project.client.toLowerCase().includes(searchTerm.toLowerCase())
    const matchesStatus = statusFilter === 'all' || project.status === statusFilter
    return matchesSearch && matchesStatus
  })

  const stats = {
    total: projects.length,
    draft: projects.filter(p => p.status === 'draft').length,
    processing: projects.filter(p => p.status === 'processing').length,
    completed: projects.filter(p => p.status === 'completed').length,
    validated: projects.filter(p => p.status === 'validated').length,
  }

  if (isLoading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto mb-4"></div>
          <p className="text-gray-600">Carregando...</p>
        </div>
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <header className="bg-white shadow-sm border-b border-gray-200">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center h-16">
            <div className="flex items-center">
              <Scale className="w-8 h-8 text-blue-600 mr-3" />
              <h1 className="text-xl font-semibold text-gray-900">Sistema Jurídico</h1>
            </div>

            <div className="flex items-center space-x-4">
              {/* Token Badge - Apenas para Administradores */}
              {(userRole === 'admin' || userRole === 'super_admin') && <TokenUsageBadge />}

              {/* Botão de Painel de Administração - apenas para admins */}
              {(userRole === 'admin' || userRole === 'super_admin') && (
                <button
                  onClick={() => router.push('/organization-dashboard')}
                  className="flex items-center space-x-2 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
                >
                  <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" />
                  </svg>
                  <span className="text-sm font-medium">Painel Admin</span>
                </button>
              )}

              <div className="flex items-center space-x-2 text-gray-700">
                <User className="w-5 h-5" />
                <span className="text-sm">{user?.name}</span>
              </div>

              <button
                onClick={handleLogout}
                className="flex items-center space-x-2 text-gray-600 hover:text-red-600 transition-colors cursor-pointer"
              >
                <LogOut className="w-5 h-5" />
                <span className="text-sm">Sair</span>
              </button>
            </div>
          </div>
        </div>
      </header>

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {/* Welcome Section */}
        <div className="mb-8">
          <h2 className="text-2xl font-bold text-gray-900 mb-2">
            Bem-vindo, {user?.name}!
          </h2>
          <p className="text-gray-600">Gerencie seus processos e documentos jurídicos de forma eficiente.</p>
        </div>

        {/* Stats Cards */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-5 gap-6 mb-8">
          <div className="bg-white rounded-lg shadow p-6">
            <div className="flex items-center">
              <div className="flex-shrink-0">
                <FileText className="w-6 h-6 text-blue-600" />
              </div>
              <div className="ml-4">
                <p className="text-sm font-medium text-gray-500">Total</p>
                <p className="text-2xl font-semibold text-gray-900">{stats.total}</p>
              </div>
            </div>
          </div>

          <div className="bg-white rounded-lg shadow p-6">
            <div className="flex items-center">
              <div className="flex-shrink-0">
                <Edit3 className="w-6 h-6 text-gray-600" />
              </div>
              <div className="ml-4">
                <p className="text-sm font-medium text-gray-500">Rascunhos</p>
                <p className="text-2xl font-semibold text-gray-900">{stats.draft}</p>
              </div>
            </div>
          </div>

          <div className="bg-white rounded-lg shadow p-6">
            <div className="flex items-center">
              <div className="flex-shrink-0">
                <Clock className="w-6 h-6 text-blue-600" />
              </div>
              <div className="ml-4">
                <p className="text-sm font-medium text-gray-500">Processando</p>
                <p className="text-2xl font-semibold text-gray-900">{stats.processing}</p>
              </div>
            </div>
          </div>

          <div className="bg-white rounded-lg shadow p-6">
            <div className="flex items-center">
              <div className="flex-shrink-0">
                <CheckCircle className="w-6 h-6 text-green-600" />
              </div>
              <div className="ml-4">
                <p className="text-sm font-medium text-gray-500">Concluídos</p>
                <p className="text-2xl font-semibold text-gray-900">{stats.completed}</p>
              </div>
            </div>
          </div>

          <div className="bg-white rounded-lg shadow p-6">
            <div className="flex items-center">
              <div className="flex-shrink-0">
                <CheckCircle className="w-6 h-6 text-purple-600" />
              </div>
              <div className="ml-4">
                <p className="text-sm font-medium text-gray-500">Validados</p>
                <p className="text-2xl font-semibold text-gray-900">{stats.validated}</p>
              </div>
            </div>
          </div>
        </div>

        {/* Subscription and Token Usage Cards - Apenas para Administradores */}
        {(userRole === 'admin' || userRole === 'super_admin') && (
          <div className="grid grid-cols-1 lg:grid-cols-3 gap-6 mb-8">
            <SubscriptionCard />
            <TokenUsageCard />
          </div>
        )}

        {/* Actions Bar */}
        <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4 mb-6">
          <div className="flex flex-col sm:flex-row gap-4 flex-1">
            {/* Search */}
            <div className="relative flex-1 max-w-md">
              <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 w-5 h-5" />
              <input
                type="text"
                placeholder="Buscar projetos..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent text-gray-800"
              />
            </div>

            {/* Status Filter */}
            <select
              value={statusFilter}
              onChange={(e) => setStatusFilter(e.target.value)}
              className="px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent text-gray-800 bg-white"
            >
              <option value="all">Todos os status</option>
              <option value="draft">Rascunho</option>
              <option value="processing">Processando</option>
              <option value="completed">Concluído</option>
              <option value="validated">Validado</option>
            </select>
          </div>

          {/* New Project Button */}
          <button
            onClick={() => router.push('/projects/new')}
            className="flex items-center space-x-3 px-4 py-3 text-gray-700 bg-white hover:bg-gray-50 rounded-lg border border-gray-300 transition-colors cursor-pointer shadow-sm"
          >
            <FilePlus className="w-5 h-5 text-blue-600" />
            <span>Novo Projeto</span>
          </button>
        </div>

        {/* Success Message */}
        {successMessage && (
          <div className="mb-6 p-4 rounded-lg bg-green-50 text-green-700 border border-green-200 flex items-center">
            <CheckCircle className="w-5 h-5 mr-3" />
            {successMessage}
          </div>
        )}

        {/* Projects List */}
        <div className="bg-white rounded-lg shadow overflow-hidden">
          {filteredProjects.length === 0 ? (
            <div className="text-center py-12">
              <FileText className="w-12 h-12 text-gray-300 mx-auto mb-4" />
              <h3 className="text-lg font-medium text-gray-900 mb-2">
                {searchTerm || statusFilter !== 'all' ? 'Nenhum projeto encontrado' : 'Nenhum projeto ainda'}
              </h3>
              <p className="text-gray-500 mb-6">
                {searchTerm || statusFilter !== 'all' 
                  ? 'Tente ajustar os filtros de busca' 
                  : 'Comece criando seu primeiro projeto jurídico'}
              </p>
              {!searchTerm && statusFilter === 'all' && (
                <button
                  onClick={() => router.push('/projects/new')}
                  className="inline-flex items-center space-x-3 px-4 py-3 text-gray-700 bg-white hover:bg-gray-50 rounded-lg border border-gray-300 transition-colors cursor-pointer shadow-sm"
                >
                  <FilePlus className="w-5 h-5 text-blue-600" />
                  <span>Criar Primeiro Projeto</span>
                </button>
              )}
            </div>
          ) : (
            <div className="overflow-x-auto">
              <table className="min-w-full divide-y divide-gray-200">
                <thead className="bg-gray-50">
                  <tr>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Projeto
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Cliente
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Sistema
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Status
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Documentos
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Criado em
                    </th>
                    <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Ações
                    </th>
                  </tr>
                </thead>
                <tbody className="bg-white divide-y divide-gray-200">
                  {filteredProjects.map((project) => {
                    const statusInfo = getStatusInfo(project.status)
                    const StatusIcon = statusInfo.icon

                    return (
                      <tr key={project.id} className="hover:bg-gray-50">
                        <td className="px-6 py-4 whitespace-nowrap">
                          <div>
                            <div className="text-sm font-medium text-gray-900">
                              {project.name}
                            </div>
                            <div className="text-sm text-gray-500">
                              {project.actionType}
                            </div>
                          </div>
                        </td>
                        <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                          {project.client}
                        </td>
                        <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                          {project.system}
                        </td>
                        <td className="px-6 py-4 whitespace-nowrap">
                          <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${statusInfo.color}`}>
                            <StatusIcon className="w-3 h-3 mr-1" />
                            {statusInfo.label}
                          </span>
                        </td>
                        <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                          {project.documentsCount} documento{project.documentsCount !== 1 ? 's' : ''}
                        </td>
                        <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                          {new Date(project.createdAt).toLocaleDateString('pt-BR')}
                        </td>
                        <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                          <div className="flex items-center justify-end space-x-3">
                            <button
                              onClick={() => {
                                if (project.processedNarrative) {
                                  router.push(`/projects/${project.id}/upload`)
                                }
                              }}
                              disabled={!project.processedNarrative}
                              className={`font-medium ${
                                project.processedNarrative
                                  ? 'text-green-600 hover:text-green-900 cursor-pointer'
                                  : 'text-gray-400 cursor-not-allowed'
                              }`}
                              title={
                                project.processedNarrative
                                  ? 'Gerenciar documentos'
                                  : 'Processe a narrativa antes de gerenciar documentos'
                              }
                            >
                              Documentos
                            </button>

                            <button
                              onClick={() => router.push(`/projects/${project.id}`)}
                              className="text-blue-600 hover:text-blue-900 font-medium cursor-pointer"
                              title="Editar projeto"
                            >
                              Editar
                            </button>

                            <button
                              onClick={() => {
                                setDeleteConfirmModal({
                                  message: `Deseja realmente excluir o projeto "${project.name}"? Todos os documentos associados também serão excluídos. Esta ação não pode ser desfeita.`,
                                  onConfirm: async () => {
                                    try {
                                      const token = localStorage.getItem('token')
                                      const res = await fetch(`/api/projects/${project.id}`, {
                                        method: 'DELETE',
                                        headers: {
                                          'Authorization': `Bearer ${token}`,
                                        },
                                      })
                                      if (res.ok) {
                                        setSuccessMessage('Projeto excluído com sucesso!')
                                        setProjects((prev: Project[]) => prev.filter((p: Project) => p.id !== project.id))
                                        setTimeout(() => setSuccessMessage(null), 3000)
                                      } else {
                                        alert('Erro ao excluir projeto.')
                                      }
                                    } catch {
                                      alert('Erro ao excluir projeto.')
                                    }
                                  }
                                })
                              }}
                              className="text-red-600 hover:text-red-900 font-medium cursor-pointer"
                              title="Excluir projeto"
                            >
                              Excluir
                            </button>
                          </div>
                        </td>
                      </tr>
                    )
                  })}
                </tbody>
              </table>
            </div>
          )}
        </div>
      </div>

      {/* Delete Confirmation Modal */}
      {deleteConfirmModal && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4 overflow-y-auto">
          <div className="bg-white rounded-lg shadow-xl max-w-md w-full my-8">
            {/* Modal Header */}
            <div className="px-6 py-4 border-b border-gray-200">
              <div className="flex items-center space-x-3">
                <div className="w-12 h-12 bg-red-100 rounded-full flex items-center justify-center flex-shrink-0">
                  <AlertCircle className="w-6 h-6 text-red-600" />
                </div>
                <div>
                  <h3 className="text-lg font-semibold text-gray-900">Confirmar Exclusão</h3>
                  <p className="text-sm text-gray-500">Esta ação não pode ser desfeita</p>
                </div>
              </div>
            </div>

            {/* Modal Body */}
            <div className="px-6 py-4">
              <p className="text-gray-700">
                {deleteConfirmModal.message}
              </p>
            </div>

            {/* Modal Footer */}
            <div className="px-6 py-4 bg-gray-50 flex justify-end gap-3 rounded-b-lg">
              <button
                onClick={() => setDeleteConfirmModal(null)}
                className="px-4 py-2 text-sm bg-white border border-gray-300 text-gray-700 rounded-md hover:bg-gray-50 transition-colors cursor-pointer"
              >
                Cancelar
              </button>
              <button
                onClick={() => {
                  deleteConfirmModal.onConfirm()
                  setDeleteConfirmModal(null)
                }}
                className="px-4 py-2 text-sm bg-red-600 text-white rounded-md hover:bg-red-700 transition-colors cursor-pointer"
              >
                Sim, Excluir
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}