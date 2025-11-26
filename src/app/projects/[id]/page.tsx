//src/app/projects/[id]/page.tsx
'use client'
import { useForm } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import { z } from 'zod'
import { useState, useEffect, use, useCallback } from 'react'
import { useRouter } from 'next/navigation'
import {
  ArrowLeft,
  Edit3,
  Save,
  Upload,
  FileText,
  Download,
  CheckCircle,
  Clock,
  AlertTriangle,
  FileCheck,
  Scale,
  User,
  Building,
  Calendar,
  Plus,
  X,
  Sparkles,
  Brain,
  Info,
  FolderPlus,
  ListPlus,
  Check
} from 'lucide-react'
import jsPDF from 'jspdf'

// ✅ INTERFACES TIPADAS CORRETAMENTE
interface AIAnalysisData {
  confidence?: number
  detectedDocumentType?: string
  documentType?: string
  detectedInfo?: {
    name?: string
    cpf?: string
    rg?: string
    [key: string]: unknown
  }
  [key: string]: unknown
}

interface Project {
  id: number
  name: string
  client: string
  system: string
  actionType: string
  narrative?: string
  processedNarrative?: string
  status: string
  createdAt: string
  updatedAt: string
  documents: Document[]
}

interface Document {
  id: number
  originalFilename: string
  storedFilename?: string
  smartFilename?: string
  documentType: string
  detectedDocumentType?: string
  documentNumber: number
  mimeType: string
  status: string
  pdfPath?: string
  pageCount?: number
  originalSizeBytes: number
  pdfSizeBytes?: number
  hasOcrText?: boolean
  aiAnalysis?: AIAnalysisData  // ✅ CORRIGIDO: tipo específico em vez de any
  createdAt: string
  validation?: DocumentValidation
}

interface DocumentValidation {
  isRelevant: boolean
  relevanceScore: number
  analysis: string
  suggestions?: string
  status: string
}

interface DocumentType {
  code: string
  name: string
  description?: string
  order: number
}

const editProjectSchema = z.object({
  name: z.string().min(2, 'Nome do projeto deve ter pelo menos 2 caracteres'),
  client: z.string().min(2, 'Nome do cliente deve ter pelo menos 2 caracteres'),
  system: z.string().min(1, 'Sistema é obrigatório'),
  actionType: z.string().min(1, 'Tipo de ação é obrigatório'),
  narrative: z.string().optional(),
  processedNarrative: z.string().optional(),
})

type EditProjectFormData = z.infer<typeof editProjectSchema>;

interface SystemConfig {
  systemName: string
  maxFileSize: number
  maxPageSize: number
}

export default function ProjectDetailPage({ 
  params 
}: { 
  params: Promise<{ id: string }> 
}) {
  const router = useRouter()
  const resolvedParams = use(params)
  const projectId = parseInt(resolvedParams.id)

  const [project, setProject] = useState<Project | null>(null)
  const [documentTypes, setDocumentTypes] = useState<DocumentType[]>([])
  const [isLoading, setIsLoading] = useState(true)
  const [isEditing, setIsEditing] = useState(false)
  const [isProcessingNarrative, setIsProcessingNarrative] = useState(false)

  const [isExportingSeparate, setIsExportingSeparate] = useState(false)
  const [isExportingZip, setIsExportingZip] = useState(false)
  const [isExportingOcrPdf, setIsExportingOcrPdf] = useState(false)
  const [systems, setSystems] = useState<SystemConfig[]>([])
  const [selectedSystem, setSelectedSystem] = useState<SystemConfig | null>(null)
  const [message, setMessage] = useState<{ type: 'error' | 'success' | 'info', text: string } | null>(null)

  // Estados para modais de adicionar
  const [showAddSystemModal, setShowAddSystemModal] = useState(false)
  const [newSystem, setNewSystem] = useState({
    systemName: '',
    maxFileSize: 30,
    maxPageSize: 500
  })
  const [showAddActionTypeModal, setShowAddActionTypeModal] = useState(false)
  const [newActionType, setNewActionType] = useState('')
  const [actionTypes, setActionTypes] = useState<Array<{id: string | number, name: string, description?: string, isDefault?: boolean}>>([
    { id: '1', name: 'Acao de Indenizacao' },
    { id: '2', name: 'Acao Trabalhista' },
    { id: '3', name: 'Acao de Cobranca' },
    { id: '4', name: 'Acao de Despejo' },
    { id: '5', name: 'Acao Declaratoria' },
    { id: '6', name: 'Acao Cautelar' },
    { id: '7', name: 'Mandado de Seguranca' },
    { id: '8', name: 'Habeas Corpus' },
    { id: '9', name: 'Acao Penal' },
    { id: '10', name: 'Acao Civil Publica' },
    { id: '11', name: 'Execucao' },
    { id: '12', name: 'Embargos' },
    { id: '13', name: 'Recurso' }
  ])

  const form = useForm<EditProjectFormData>({
    resolver: zodResolver(editProjectSchema),
    defaultValues: {
      name: '',
      client: '',
      system: '',
      actionType: '',
      narrative: '',
      processedNarrative: '',
    }
  })

  const handleExportZip = async () => {
  if (!project) return;

  setIsExportingZip(true);
  setMessage({ type: 'info', text: 'Preparando arquivos para download...' });

  try {
    const token = localStorage.getItem('token');
    const response = await fetch(`/api/projects/${project.id}/export-zip`, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${token}`
      }
    });

    if (response.ok) {
      const blob = await response.blob();
      const url = window.URL.createObjectURL(blob);
      const a = document.createElement('a');
      a.style.display = 'none';
      a.href = url;
      a.download = `${project.name}.zip`;
      document.body.appendChild(a);
      a.click();
      window.URL.revokeObjectURL(url);
      document.body.removeChild(a);

      setMessage({ type: 'success', text: 'Arquivos exportados para ZIP com sucesso!' });
    } else {
      const errorData = await response.json();
      setMessage({ type: 'error', text: errorData.error || 'Erro ao exportar arquivos' });
    }
  } catch (error) {
    setMessage({ type: 'error', text: 'Erro de conexão ao exportar ZIP.' });
  } finally {
    setIsExportingZip(false);
  }
};

  const handleExportOcrPdf = async () => {
    if (!project || !project.documents || project.documents.length === 0) {
      setMessage({ type: 'error', text: 'Nenhum documento para exportar' });
      return;
    }

    setIsExportingOcrPdf(true);
    setMessage({ type: 'info', text: 'Gerando PDF consolidado com textos OCR...' });

    try {
      const token = localStorage.getItem('token');

      // Buscar detalhes completos dos documentos incluindo OCR
      const response = await fetch(`/api/projects/${project.id}`, {
        method: 'GET',
        headers: {
          'Authorization': `Bearer ${token}`
        }
      });

      if (!response.ok) {
        const errorData = await response.json();
        setMessage({ type: 'error', text: errorData.error || 'Erro ao buscar dados do projeto' });
        return;
      }

      const data = await response.json();

      if (!data.success || !data.project || !data.project.documents || data.project.documents.length === 0) {
        setMessage({ type: 'error', text: 'Nenhum documento encontrado para exportar' });
        return;
      }

      const documents = data.project.documents;

      // Criar PDF com jsPDF
      const doc = new jsPDF();
      const pageWidth = doc.internal.pageSize.width;
      const pageHeight = doc.internal.pageSize.height;
      const margin = 20;
      const maxWidth = pageWidth - 2 * margin;
      let yPos = 30;

      // Título do documento
      doc.setFontSize(18);
      doc.text('TEXTOS EXTRAÍDOS POR OCR', pageWidth / 2, yPos, { align: 'center' });
      yPos += 15;

      // Informações do projeto
      doc.setFontSize(12);
      doc.text(`Projeto: ${project.name}`, margin, yPos);
      yPos += 8;
      doc.text(`Cliente: ${project.client}`, margin, yPos);
      yPos += 8;
      doc.text(`Sistema: ${project.system}`, margin, yPos);
      yPos += 15;

      // Narrativa Fática Processada (se existir)
      if (project.processedNarrative && project.processedNarrative.trim() !== '') {
        // Verificar se precisa de nova página
        if (yPos > pageHeight - 60) {
          doc.addPage();
          yPos = 30;
        }

        doc.setFontSize(14);
        doc.setFont('helvetica', 'bold');
        doc.text('NARRATIVA FÁTICA PROCESSADA POR IA', margin, yPos);
        yPos += 10;

        doc.setFontSize(10);
        doc.setFont('helvetica', 'normal');
        const narrativeLines = doc.splitTextToSize(project.processedNarrative, maxWidth);

        for (const line of narrativeLines) {
          if (yPos > pageHeight - 20) {
            doc.addPage();
            yPos = 30;
          }
          doc.text(line, margin, yPos);
          yPos += 5;
        }

        // Separador após narrativa
        yPos += 10;
        doc.setDrawColor(200, 200, 200);
        doc.line(margin, yPos, pageWidth - margin, yPos);
        yPos += 15;

        // Verificar se precisa de nova página antes dos documentos
        if (yPos > pageHeight - 60) {
          doc.addPage();
          yPos = 30;
        }

        // Título para seção de documentos
        doc.setFontSize(14);
        doc.setFont('helvetica', 'bold');
        doc.text('DOCUMENTOS E TEXTOS OCR', margin, yPos);
        yPos += 15;
      }

      // Adicionar texto de cada documento
      doc.setFontSize(10);

      for (let i = 0; i < documents.length; i++) {
        const document = documents[i];

        // Verificar se precisa de nova página
        if (yPos > pageHeight - 40) {
          doc.addPage();
          yPos = 30;
        }

        // Título do documento
        doc.setFontSize(12);
        doc.setFont('helvetica', 'bold');
        doc.text(`Documento ${i + 1}: ${document.originalFilename}`, margin, yPos);
        yPos += 8;

        doc.setFontSize(9);
        doc.setFont('helvetica', 'normal');
        doc.text(`Tipo: ${document.documentType || 'N/A'}`, margin, yPos);
        yPos += 6;
        doc.text(`Páginas: ${document.pageCount || 'N/A'}`, margin, yPos);
        yPos += 10;

        // Texto OCR
        if (document.ocrText && document.ocrText.trim() !== '') {
          doc.setFontSize(10);
          const lines = doc.splitTextToSize(document.ocrText, maxWidth);

          for (const line of lines) {
            if (yPos > pageHeight - 20) {
              doc.addPage();
              yPos = 30;
            }
            doc.text(line, margin, yPos);
            yPos += 5;
          }
        } else {
          doc.setFontSize(10);
          doc.setTextColor(150, 150, 150);
          doc.text('(Sem texto OCR extraído)', margin, yPos);
          doc.setTextColor(0, 0, 0);
          yPos += 8;
        }

        // Separador entre documentos
        yPos += 10;
        if (i < documents.length - 1) {
          doc.setDrawColor(200, 200, 200);
          doc.line(margin, yPos, pageWidth - margin, yPos);
          yPos += 15;
        }
      }

      // Rodapé
      const totalPages = doc.getNumberOfPages();
      for (let i = 1; i <= totalPages; i++) {
        doc.setPage(i);
        doc.setFontSize(8);
        doc.setTextColor(128, 128, 128);
        doc.text(
          `Gerado em ${new Date().toLocaleDateString('pt-BR')} às ${new Date().toLocaleTimeString('pt-BR')} - Página ${i} de ${totalPages}`,
          pageWidth / 2,
          pageHeight - 10,
          { align: 'center' }
        );
      }

      // Download do PDF
      doc.save(`${project.name}_Textos_OCR.pdf`);
      setMessage({ type: 'success', text: 'PDF consolidado gerado com sucesso!' });

    } catch (error) {
      console.error('Erro ao exportar PDF consolidado:', error);
      setMessage({ type: 'error', text: 'Erro ao gerar PDF consolidado' });
    } finally {
      setIsExportingOcrPdf(false);
    }
  };
  
  const setDefaultSystems = useCallback(() => {
    const defaults: SystemConfig[] = [
      { systemName: 'e-SAJ', maxFileSize: 30 * 1024 * 1024, maxPageSize: 300 },
      { systemName: 'PJe - 1o Grau', maxFileSize: 5 * 1024 * 1024, maxPageSize: 500 },
      { systemName: 'PJe - 2o Grau', maxFileSize: 10 * 1024 * 1024, maxPageSize: 500 },
      { systemName: 'PJe 2x', maxFileSize: 3 * 1024 * 1024, maxPageSize: 300 },
      { systemName: 'PJe - TRT 1o Grau', maxFileSize: 3 * 1024 * 1024, maxPageSize: 500 },
    ]
    setSystems(defaults)
  }, [])

  const loadSystems = useCallback(async () => {
    try {
      const token = localStorage.getItem('token')
      if (!token) {
        setDefaultSystems()
        return
      }

      const response = await fetch('/api/systems', {
        headers: {
          'Authorization': `Bearer ${token}`
        }
      })

      if (response.ok) {
        const data = await response.json()
        if (data.success && Array.isArray(data.systems)) {
          setSystems(data.systems)
          return
        }
      }

      setDefaultSystems()
    } catch {
      setDefaultSystems()
    }
  }, [setDefaultSystems])

  const formatFileSize = (bytes: number) => {
    if (bytes === 0) return '0 Bytes'
    const k = 1024
    const sizes = ['Bytes', 'KB', 'MB', 'GB']
    const i = Math.floor(Math.log(bytes) / Math.log(k))
    return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i]
  }

  const handleSystemChange = (systemName: string) => {
    form.setValue('system', systemName)
    const system = systems.find((item) => item.systemName === systemName) || null
    setSelectedSystem(system)
  }

  const handleAddSystem = async () => {
    if (!newSystem.systemName.trim()) {
      setMessage({ type: 'error', text: 'Nome do sistema é obrigatório' })
      return
    }

    if (systems.some(s => s.systemName === newSystem.systemName)) {
      setMessage({ type: 'error', text: 'Sistema já existe na lista' })
      return
    }

    try {
      const token = localStorage.getItem('token')
      const response = await fetch('/api/systems', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${token}`
        },
        body: JSON.stringify({
          systemName: newSystem.systemName,
          maxFileSize: newSystem.maxFileSize * 1024 * 1024,
          maxPageSize: newSystem.maxPageSize
        })
      })

      const result = await response.json()

      if (result.success) {
        const newSystemConfig: SystemConfig = {
          systemName: newSystem.systemName,
          maxFileSize: newSystem.maxFileSize * 1024 * 1024,
          maxPageSize: newSystem.maxPageSize
        }
        setSystems([...systems, newSystemConfig])
        handleSystemChange(newSystem.systemName)
        setMessage({ type: 'success', text: 'Sistema adicionado com sucesso!' })
        setShowAddSystemModal(false)
        setNewSystem({ systemName: '', maxFileSize: 30, maxPageSize: 500 })
      } else {
        setMessage({ type: 'error', text: result.error || 'Erro ao adicionar sistema' })
      }
    } catch (error) {
      console.error('Erro ao adicionar sistema:', error)
      setMessage({ type: 'error', text: 'Erro de conexão ao adicionar sistema' })
    }
  }

  const loadActionTypes = useCallback(async () => {
    try {
      const token = localStorage.getItem('token')
      const response = await fetch('/api/action-types', {
        headers: {
          'Authorization': `Bearer ${token}`
        }
      })

      if (response.ok) {
        const data = await response.json()
        if (data.success && data.actionTypes && data.actionTypes.length > 0) {
          setActionTypes(data.actionTypes)
        } else {
          setDefaultActionTypes()
        }
      } else {
        setDefaultActionTypes()
      }
    } catch {
      setDefaultActionTypes()
    }
  }, [])

  const setDefaultActionTypes = () => {
    setActionTypes([
      { id: '1', name: 'Acao de Indenizacao' },
      { id: '2', name: 'Acao Trabalhista' },
      { id: '3', name: 'Acao de Cobranca' },
      { id: '4', name: 'Acao de Despejo' },
      { id: '5', name: 'Acao Declaratoria' },
      { id: '6', name: 'Acao Cautelar' },
      { id: '7', name: 'Mandado de Seguranca' },
      { id: '8', name: 'Habeas Corpus' },
      { id: '9', name: 'Acao Penal' },
      { id: '10', name: 'Acao Civil Publica' },
      { id: '11', name: 'Execucao' },
      { id: '12', name: 'Embargos' },
      { id: '13', name: 'Recurso' },
      { id: '14', name: 'Outro' }
    ])
  }

  const handleAddActionType = async () => {
    if (!newActionType.trim()) {
      setMessage({ type: 'error', text: 'Nome do tipo de ação é obrigatório' })
      return
    }

    if (actionTypes.some(a => a.name.toLowerCase() === newActionType.toLowerCase())) {
      setMessage({ type: 'error', text: 'Tipo de ação já existe na lista' })
      return
    }

    try {
      const token = localStorage.getItem('token')
      const response = await fetch('/api/action-types', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${token}`
        },
        body: JSON.stringify({
          name: newActionType.trim()
        })
      })

      const result = await response.json()

      if (result.success) {
        const newActionTypeObj = result.actionType || { id: Date.now().toString(), name: newActionType.trim() }
        const updatedActionTypes = [...actionTypes, newActionTypeObj]
        setActionTypes(updatedActionTypes)
        form.setValue('actionType', newActionType.trim())
        setMessage({ type: 'success', text: 'Tipo de ação adicionado com sucesso!' })
        setShowAddActionTypeModal(false)
        setNewActionType('')
      } else {
        setMessage({ type: 'error', text: result.error || 'Erro ao adicionar tipo de ação' })
      }
    } catch (error) {
      console.error('Erro ao adicionar tipo de ação:', error)
      setMessage({ type: 'error', text: 'Erro de conexão ao adicionar tipo de ação' })
    }
  }

  const loadProject = useCallback(async () => {
    try {
      const token = localStorage.getItem('token')
      const response = await fetch(`/api/projects/${projectId}`, {
        headers: {
          'Authorization': `Bearer ${token}`
        }
      })

      const data = await response.json()

      if (data.success) {
        setProject(data.project)
        form.reset({
          name: data.project.name,
          client: data.project.client,
          system: data.project.system,
          actionType: data.project.actionType,
          narrative: data.project.narrative || '',
          processedNarrative: data.project.processedNarrative || ''
        })
      } else {
        setMessage({ type: 'error', text: data.error || 'Projeto não encontrado' })
      }
    } catch {
      setMessage({ type: 'error', text: 'Erro ao carregar projeto' })
    } finally {
      setIsLoading(false)
    }
  }, [projectId, form])

  const loadDocumentTypes = useCallback(async () => {
    try {
      const token = localStorage.getItem('token')
      const response = await fetch('/api/document-types', {
        headers: {
          'Authorization': `Bearer ${token}`
        }
      })

      if (response.ok) {
        const data = await response.json()
        setDocumentTypes(data.documentTypes || [])
      }
    } catch {
      // Usar dados padrão
      setDocumentTypes([
        { code: '01-identidade', name: 'Documento de Identidade', order: 1 },
        { code: '02-cnh', name: 'CNH', order: 2 },
        { code: '03-cpf', name: 'CPF', order: 3 },
        { code: '04-comprovante-residencia', name: 'Comprovante de Residência', order: 4 },
        { code: '05-procuracao', name: 'Procuração', order: 5 },
        { code: '06-declaracao-hipossuficiencia', name: 'Declaração de Hipossuficiência', order: 6 }
      ])
    }
  }, [])

  const systemValue = form.watch('system')
  useEffect(() => {
    if (systemValue) {
      const system = systems.find((item) => item.systemName === systemValue) || null
      setSelectedSystem(system)
    } else {
      setSelectedSystem(null)
    }
  }, [systems, systemValue])

  useEffect(() => {
    const token = localStorage.getItem('token')
    if (!token) {
      router.push('/login')
      return
    }

    if (isNaN(projectId)) {
      router.push('/dashboard')
      return
    }

    loadProject()
    loadDocumentTypes()
    loadSystems()
    loadActionTypes()
  }, [projectId, router, loadProject, loadDocumentTypes, loadSystems, loadActionTypes])


  const handleSaveProject = async (data: EditProjectFormData) => {
    setMessage({ type: 'info', text: 'Salvando alterações...' })

    try {
      const token = localStorage.getItem('token')
      const response = await fetch(`/api/projects/${project?.id}`,
       {
        method: 'PUT',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${token}`
        },
        body: JSON.stringify(data),
      })

      const result = await response.json()

      if (result.success) {
        setIsEditing(false)
        setMessage({ type: 'success', text: 'Projeto atualizado com sucesso!' })
        loadProject()
      } else {
        setMessage({ type: 'error', text: result.error || 'Erro ao atualizar projeto' })
      }
    } catch {
      setMessage({ type: 'error', text: 'Erro de conexão' })
    }
  }


  const handleCancelEdit = () => {
    if (project) {
      form.reset({
        name: project.name,
        client: project.client,
        system: project.system,
        actionType: project.actionType,
        narrative: project.narrative || '',
        processedNarrative: project.processedNarrative || ''
      })
    }
    setIsEditing(false)
  }


  const handleProcessNarrative = async () => {
    // Pegar narrativa do textarea - verifica ambos os IDs (modo edição e visualização)
    const narrativeTextareaView = document.getElementById('narrative-view') as HTMLTextAreaElement
    const narrativeTextareaEdit = document.getElementById('narrative') as HTMLTextAreaElement

    // Tentar pegar o valor do textarea ativo ou do form ou do projeto
    const narrativeToProcess =
      narrativeTextareaEdit?.value ||
      narrativeTextareaView?.value ||
      form.getValues('narrative') ||
      project?.narrative

    if (!narrativeToProcess || narrativeToProcess.trim() === '') {
      setMessage({ type: 'error', text: 'Adicione uma narrativa antes de processar' })
      return
    }

    setIsProcessingNarrative(true)
    setMessage({ type: 'info', text: 'Processando narrativa com IA...' })

    try {
      const token = localStorage.getItem('token')
      const response = await fetch('/api/ai/process-narrative', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${token}`
        },
        body: JSON.stringify({
          projectId: project?.id,
          narrative: narrativeToProcess
        }),
      })

      const result = await response.json()

      if (result.success) {
        setMessage({ type: 'success', text: 'Narrativa processada pela IA com sucesso!' })
        loadProject()
      } else {
        setMessage({ type: 'error', text: result.error || 'Erro no processamento da narrativa' })
      }
    } catch {
      setMessage({ type: 'error', text: 'Erro de conexão' })
    } finally {
      setIsProcessingNarrative(false)
    }
  }



  const handleDownloadDocument = async (doc: Document) => {
    try {
      const token = localStorage.getItem('token')
      const response = await fetch(`/api/documents/${doc.id}/download`, {
        headers: {
          'Authorization': `Bearer ${token}`
        }
      })

      if (response.ok) {
        const blob = await response.blob()
        const url = window.URL.createObjectURL(blob)
        const a = document.createElement('a')
        a.style.display = 'none'
        a.href = url
        a.download = doc.originalFilename
        document.body.appendChild(a)
        a.click()
        window.URL.revokeObjectURL(url)
        document.body.removeChild(a)
        
        setMessage({ type: 'success', text: 'Documento baixado com sucesso!' })
      } else {
        const errorData = await response.json()
        setMessage({ type: 'error', text: errorData.error || 'Erro ao baixar documento' })
      }
    } catch {
      setMessage({ type: 'error', text: 'Erro de conexão' })
    }
  }

  const handleDeleteDocument = async (doc: Document) => {
    if (!confirm(`Tem certeza que deseja excluir o documento "${doc.originalFilename}"?`)) {
      return
    }

    try {
      const token = localStorage.getItem('token')
      const response = await fetch(`/api/documents/${doc.id}`, {
        method: 'DELETE',
        headers: {
          'Authorization': `Bearer ${token}`
        }
      })

      const result = await response.json()

      if (result.success) {
        setMessage({ type: 'success', text: 'Documento excluído com sucesso!' })
        loadProject() // Recarrega o projeto para atualizar a lista
      } else {
        setMessage({ type: 'error', text: result.error || 'Erro ao excluir documento' })
      }
    } catch {
      setMessage({ type: 'error', text: 'Erro de conexão' })
    }
  }

  const handleExportSeparatePDFs = async () => {
  if (!project?.documents || project.documents.length === 0) {
    setMessage({ type: 'error', text: 'Nenhum documento para exportar' })
    return
  }

  setIsExportingSeparate(true)
  setMessage({ type: 'info', text: 'Baixando PDFs separadamente...' })

  try {
    const token = localStorage.getItem('token')
    let downloadedCount = 0
    let errorCount = 0

    const documentTypeNames: { [key: string]: string } = {
      '01-identidade': 'RG_CPF',
      '02-cnh': 'CNH', 
      '03-cpf': 'CPF',
      '04-comprovante-residencia': 'Comprovante_Residencia',
      '05-procuracao': 'Procuracao',
      '06-declaracao-hipossuficiencia': 'Declaracao_Hipossuficiencia',
      '07-contrato': 'Contrato_Prestacao_Servicos',
    }

    for (const doc of project.documents) {
      try {
        if (!doc.pdfPath) {
          console.error(`Documento ${doc.originalFilename} não possui PDF convertido`)
          errorCount++
          continue
        }

        const response = await fetch(`/api/documents/${doc.id}/download`, {
          headers: {
            'Authorization': `Bearer ${token}`
          }
        })

        if (response.ok) {
          const blob = await response.blob()
          const url = window.URL.createObjectURL(blob)
          const a = document.createElement('a')
          a.style.display = 'none'
          a.href = url
          
          let fileName: string
          
          if (doc.smartFilename) {
            fileName = doc.smartFilename
          } else {
            const documentTypeName = documentTypeNames[doc.documentType] || doc.documentType.replace(/-/g, '_')
            fileName = `${project.name}_${documentTypeName}_Doc${doc.documentNumber.toString().padStart(2, '0')}.pdf`
          }
          
          a.download = fileName
          
          document.body.appendChild(a)
          a.click()
          window.URL.revokeObjectURL(url)
          document.body.removeChild(a)
          
          downloadedCount++
          
          await new Promise(resolve => setTimeout(resolve, 500))
        } else {
          console.error(`Erro HTTP ${response.status} ao baixar PDF do documento ${doc.originalFilename}`)
          errorCount++
        }
      } catch (error) {
        console.error(`Erro no download de ${doc.originalFilename}:`, error)
        errorCount++
      }
    }

    if (project.processedNarrative) {
      try {
        const doc = new jsPDF()
        
        const pageWidth = doc.internal.pageSize.width
        const margin = 20
        const maxWidth = pageWidth - 2 * margin
        
        doc.setFontSize(16)
        doc.text('NARRATIVA DOS FATOS - PROCESSADA POR IA', pageWidth / 2, 30, { align: 'center' })
        
        let yPos = 50
        
        doc.setFontSize(12)
        doc.text(`Projeto: ${project.name}`, margin, yPos)
        yPos += 8
        doc.text(`Cliente: ${project.client}`, margin, yPos)
        yPos += 8
        doc.text(`Tipo de Ação: ${project.actionType}`, margin, yPos)
        yPos += 8
        doc.text(`Sistema: ${project.system}`, margin, yPos)
        yPos += 15

        doc.setFontSize(12)
        doc.text('NARRATIVA PROCESSADA PELA INTELIGÊNCIA ARTIFICIAL:', margin, yPos)
        yPos += 10
        
        doc.setFontSize(10)
        const processedLines = doc.splitTextToSize(project.processedNarrative, maxWidth)
        doc.text(processedLines, margin, yPos)
        yPos += processedLines.length * 5 + 15
        
        if (yPos > 250) {
          doc.addPage()
          yPos = 30
        }
        
        doc.setFontSize(8)
        const footerText = `Documento gerado automaticamente em ${new Date().toLocaleDateString('pt-BR')} às ${new Date().toLocaleTimeString('pt-BR')}`
        doc.text(footerText, pageWidth / 2, yPos, { align: 'center' })
        
        doc.save(`01 Narrativa Fática.pdf`)
        downloadedCount++
        
      } catch (error) {
        console.error('Erro ao gerar PDF da narrativa:', error)
        errorCount++
      }
    }

if (downloadedCount > 0) {
  try {
    const updateResponse = await fetch(`/api/projects/${project.id}`, {
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${token}`
      },
      body: JSON.stringify({
        ...project,
        status: 'completed'
      })
    })

    if (updateResponse.ok) {
      console.log('Status atualizado para concluído')
      loadProject()
    }
  } catch (error) {
    console.warn('Erro ao atualizar status:', error)
  }

  setMessage({ 
    type: 'success', 
    text: `${downloadedCount} PDF(s) baixado(s) com sucesso! Projeto marcado como concluído.${errorCount > 0 ? ` (${errorCount} com erro)` : ''}` 
  })
} else {
  setMessage({ type: 'error', text: 'Nenhum PDF pôde ser baixado. Verifique se os documentos foram convertidos corretamente.' })
}

  } catch (error) {
    console.error('Erro geral no export:', error)
    setMessage({ type: 'error', text: 'Erro de conexão ao exportar PDFs' })
  } finally {
    setIsExportingSeparate(false)
  }
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
        return { label: 'Desconhecido', color: 'text-gray-600 bg-gray-100', icon: AlertTriangle }
    }
  }

  const getDocumentStatusInfo = (status: string) => {
    switch (status) {
      case 'uploaded':
        return { label: 'Enviado', color: 'text-blue-600 bg-blue-100', icon: Upload }
      case 'converting':
        return { label: 'Convertendo', color: 'text-yellow-600 bg-yellow-100', icon: Clock }
      case 'converted':
        return { label: 'Convertido', color: 'text-green-600 bg-green-100', icon: FileText }
      case 'ocr_completed':
        return { label: 'OCR Concluído', color: 'text-purple-600 bg-purple-100', icon: FileCheck }
      default:
        return { label: status, color: 'text-gray-600 bg-gray-100', icon: FileText }
    }
  }

  if (isLoading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto mb-4"></div>
          <p className="text-gray-600">Carregando projeto...</p>
        </div>
      </div>
    )
  }

  if (!project) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <FileText className="w-16 h-16 text-gray-300 mx-auto mb-4" />
          <h2 className="text-xl font-semibold text-gray-900 mb-2">Projeto não encontrado</h2>
          <button
            onClick={() => router.push('/dashboard')}
            className="text-blue-600 hover:text-blue-800 cursor-pointer"
          >
            Voltar ao Dashboard
          </button>
        </div>
      </div>
    )
  }
  
  const statusInfo = getStatusInfo(project.status)
  const StatusIcon = statusInfo.icon

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <header className="bg-white shadow-sm border-b border-gray-200">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center h-16">
            <div className="flex items-center">
              <button
                onClick={() => router.push('/dashboard')}
                className="mr-4 p-2 text-gray-600 hover:text-gray-900 transition-colors cursor-pointer"
              >
                <ArrowLeft className="w-5 h-5" />
              </button>
              <Scale className="w-8 h-8 text-blue-600 mr-3" />
              <div>
                <h1 className="text-xl font-semibold text-gray-900">{project.name}</h1>
                <div className="flex items-center mt-1">
                  <StatusIcon className={`w-4 h-4 mr-1.5 ${statusInfo.color}`} />
                  <span className={`text-sm font-medium px-2.5 py-0.5 rounded-full ${statusInfo.color}`}>
                    {statusInfo.label}
                  </span>
                </div>
              </div>
            </div>

            <div className="flex items-center space-x-3">
              {!isEditing && (
                <button
                  onClick={() => setIsEditing(true)}
                  className="flex items-center space-x-2 px-3 py-2 text-sm text-gray-700 bg-white border border-gray-300 rounded-lg hover:bg-gray-300  transition-colors cursor-pointer"
                >
                  <Edit3 className="w-4 h-4" />
                  <span>Editar</span>
                </button>
              )}
            </div>
          </div>
        </div>
      </header>

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {/* Breadcrumb */}
        <nav className="flex mb-8" aria-label="Breadcrumb">
          <ol className="inline-flex items-center space-x-1 md:space-x-3">
            <li className="inline-flex items-center">
              <button
                onClick={() => router.push('/dashboard')}
                className="text-gray-700 hover:text-blue-600 cursor-pointer"
              >
                Dashboard
              </button>
            </li>
            <li>
              <div className="flex items-center">
                <span className="text-gray-400 mx-2">/</span>
                <span className="text-gray-500">{project.name}</span>
              </div>
            </li>
          </ol>
        </nav>

        {/* Message */}
        {message && (
          <div className={`p-4 rounded-lg mb-6 flex items-center ${
            message.type === 'error' 
              ? 'bg-red-50 text-red-700 border border-red-200'
              : message.type === 'success'
              ? 'bg-green-50 text-green-700 border border-green-200'
              : 'bg-blue-50 text-blue-700 border border-blue-200'
          }`}>
            <div className="flex-shrink-0 mr-3">
              {message.type === 'error' && <AlertTriangle className="w-5 h-5" />}
              {message.type === 'success' && <CheckCircle className="w-5 h-5" />}
              {message.type === 'info' && <Clock className="w-5 h-5" />}
            </div>
            {message.text}
          </div>
        )}

        <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
          {/* Main Content */}
          <div className="lg:col-span-2 space-y-8">
            {/* Project Info */}
            <div className="bg-white rounded-lg shadow">
              <div className="px-6 py-4 border-b border-gray-200 flex justify-between items-center">
                <h2 className="text-lg font-medium text-gray-900">Informações do Projeto</h2>
              </div>

              {isEditing ? (
                <form onSubmit={form.handleSubmit(handleSaveProject)} className="p-6 space-y-6">
                  {/* Nome do Projeto */}
                  <div>
                    <label htmlFor="name" className="block text-sm font-medium text-gray-700 mb-2">
                      Nome do Projeto *
                    </label>
                    <div className="relative">
                      <FileText className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 w-5 h-5" />
                      <input
                        id="name"
                        type="text"
                        {...form.register('name')}
                        className="w-full pl-10 pr-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent bg-white text-gray-900"
                        placeholder="Ex: Ação Trabalhista - João Silva"
                      />
                    </div>
                    {form.formState.errors.name && (
                      <p className="text-red-500 text-sm mt-1">{form.formState.errors.name.message}</p>
                    )}
                  </div>

                  {/* Nome do Cliente */}
                  <div>
                    <label htmlFor="client" className="block text-sm font-medium text-gray-700 mb-2">
                      Nome do Cliente *
                    </label>
                    <div className="relative">
                      <User className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 w-5 h-5" />
                      <input
                        id="client"
                        type="text"
                        {...form.register('client')}
                        className="w-full pl-10 pr-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent bg-white text-gray-900"
                        placeholder="Nome completo do cliente"
                      />
                    </div>
                    {form.formState.errors.client && (
                      <p className="text-red-500 text-sm mt-1">{form.formState.errors.client.message}</p>
                    )}
                  </div>

                  {/* Sistema Judicial */}
                  <div>
                    <label htmlFor="system" className="block text-sm font-medium text-gray-700 mb-2">
                      Sistema Judicial *
                    </label>
                    <div className="flex gap-2">
                      <div className="relative flex-1">
                        <Building className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 w-5 h-5" />
                        <select
                          id="system"
                          value={form.watch('system')}
                          onChange={(e) => handleSystemChange(e.target.value)}
                          className="w-full pl-10 pr-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent bg-white text-gray-900"
                        >
                          <option value="">Selecione o sistema</option>
                          {systems.map((system) => (
                            <option key={system.systemName} value={system.systemName}>
                              {system.systemName}
                            </option>
                          ))}
                        </select>
                      </div>
                      <button
                        type="button"
                        onClick={() => setShowAddSystemModal(true)}
                        className="px-4 py-2 text-gray-700 bg-white hover:bg-gray-50 rounded-lg border border-gray-300 transition-colors flex items-center gap-2 shadow-sm cursor-pointer"
                        title="Adicionar novo sistema"
                      >
                        <FolderPlus className="w-5 h-5 text-green-600" />
                        <span className="hidden sm:inline">Adicionar</span>
                      </button>
                    </div>
                    {form.formState.errors.system && (
                      <p className="text-red-500 text-sm mt-1">{form.formState.errors.system.message}</p>
                    )}
                    
                    {selectedSystem && (
                      <div className="mt-3 p-3 bg-blue-50 border border-blue-200 rounded-lg">
                        <div className="flex items-start">
                          <Info className="w-5 h-5 text-blue-600 mr-2 flex-shrink-0 mt-0.5" />
                          <div className="text-sm">
                            <p className="text-blue-800 font-medium mb-1">Requisitos do Sistema:</p>
                            <ul className="text-blue-700 space-y-1">
                              <li>• Tamanho máximo: {formatFileSize(selectedSystem.maxFileSize)}</li>
                              <li>• Máximo por página: {selectedSystem.maxPageSize} KB</li>
                            </ul>
                          </div>
                        </div>
                      </div>
                    )}
                  </div>

                  {/* Tipo de Ação */}
                  <div>
                    <label htmlFor="actionType" className="block text-sm font-medium text-gray-700 mb-2">
                      Tipo de Ação *
                    </label>
                    <div className="flex gap-2">
                      <select
                        id="actionType"
                        {...form.register('actionType')}
                        className="flex-1 px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent bg-white text-gray-900"
                      >
                        <option value="">Selecione o tipo de ação</option>
                        {actionTypes.map((action) => (
                          <option key={action.id} value={action.name}>
                            {action.name}
                          </option>
                        ))}
                      </select>
                      <button
                        type="button"
                        onClick={() => setShowAddActionTypeModal(true)}
                        className="px-4 py-2 text-gray-700 bg-white hover:bg-gray-50 rounded-lg border border-gray-300 transition-colors flex items-center gap-2 shadow-sm cursor-pointer"
                        title="Adicionar novo tipo de ação"
                      >
                        <ListPlus className="w-5 h-5 text-green-600" />
                        <span className="hidden sm:inline">Adicionar</span>
                      </button>
                    </div>
                    {form.formState.errors.actionType && (
                      <p className="text-red-500 text-sm mt-1">{form.formState.errors.actionType.message}</p>
                    )}
                  </div>

                  {/* Narrative Section */}
                  <div>
                    <label htmlFor="narrative" className="block text-sm font-medium text-gray-700 mb-2">
                      Narrativa dos Fatos (Opcional)
                    </label>
                    <textarea
                      id="narrative"
                      {...form.register('narrative')}
                      rows={8}
                      className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent bg-white text-gray-900"
                      placeholder="Descreva os fatos relevantes do caso..."
                    />
                  </div>

                  {/* Processed Narrative Section */}
                  <div>
                    <label htmlFor="processedNarrative" className="flex items-center text-sm font-medium text-gray-700 mb-2">
                      <Sparkles className="w-4 h-4 mr-2 text-purple-500" />
                      <span>Narrativa Processada por IA (Editável)</span>
                    </label>
                    <textarea
                      id="processedNarrative"
                      {...form.register('processedNarrative')}
                      rows={12}
                      className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-transparent bg-gray-50 text-gray-900 font-mono"
                      placeholder="A narrativa processada pela IA aparecerá aqui. Você pode editá-la antes de salvar."
                    />
                  </div>

                  {/* Buttons */}
                  <div className="flex justify-end space-x-4 pt-6 border-t border-gray-200">
                    <button
                      type="button"
                      onClick={handleCancelEdit}
                      className="px-4 py-2 text-gray-700 bg-white border border-gray-300 rounded-lg hover:bg-gray-50 transition-colors cursor-pointer"
                    >
                      Cancelar
                    </button>
                    <button
                      type="submit"
                      disabled={form.formState.isSubmitting}
                      className="flex items-center space-x-2 px-6 py-2 text-gray-700 bg-white hover:bg-gray-50 rounded-lg border border-gray-300 transition-colors disabled:opacity-50 disabled:cursor-not-allowed shadow-sm cursor-pointer"
                    >
                      <Check className="w-5 h-5 text-green-600" />
                      <span>{form.formState.isSubmitting ? 'Salvando...' : 'Salvar Alterações'}</span>
                    </button>
                  </div>
                </form>
              ) : (
                <div className="p-6 space-y-6">
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                    <div className="flex items-start">
                      <User className="w-5 h-5 text-gray-400 mr-3 mt-1 flex-shrink-0" />
                      <div>
                        <p className="text-sm text-gray-500">Cliente</p>
                        <p className="font-medium text-gray-900">{project.client}</p>
                      </div>
                    </div>
                    <div className="flex items-start">
                      <Building className="w-5 h-5 text-gray-400 mr-3 mt-1 flex-shrink-0" />
                      <div>
                        <p className="text-sm text-gray-500">Sistema</p>
                        <p className="font-medium text-gray-900">{project.system}</p>
                      </div>
                    </div>
                    <div className="flex items-start">
                      <FileText className="w-5 h-5 text-gray-400 mr-3 mt-1 flex-shrink-0" />
                      <div>
                        <p className="text-sm text-gray-500">Tipo de Ação</p>
                        <p className="font-medium text-gray-900">{project.actionType}</p>
                      </div>
                    </div>
                    <div className="flex items-start">
                      <Calendar className="w-5 h-5 text-gray-400 mr-3 mt-1 flex-shrink-0" />
                      <div>
                        <p className="text-sm text-gray-500">Criado em</p>
                        <p className="font-medium text-gray-900">
                          {new Date(project.createdAt).toLocaleDateString('pt-BR')}
                        </p>
                      </div>
                    </div>
                  </div>

                  {/* Narrativa Fática - Só mostra se NÃO tiver narrativa processada */}
                  {!project.processedNarrative && (
                    <div className="pt-6 border-t border-gray-200">
                      <label htmlFor="narrative-view" className="block text-sm font-medium text-gray-700 mb-2">
                        Narrativa dos Fatos (Opcional)
                      </label>
                      <textarea
                        id="narrative-view"
                        defaultValue={project.narrative || ''}
                        onBlur={async (e) => {
                          const newNarrative = e.target.value
                          if (newNarrative !== project.narrative) {
                            try {
                              const token = localStorage.getItem('token')
                              await fetch(`/api/projects/${project.id}`, {
                                method: 'PUT',
                                headers: {
                                  'Content-Type': 'application/json',
                                  'Authorization': `Bearer ${token}`
                                },
                                body: JSON.stringify({
                                  narrative: newNarrative
                                })
                              })
                              loadProject()
                            } catch (error) {
                              console.error('Erro ao salvar narrativa:', error)
                            }
                          }
                        }}
                        rows={8}
                        className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent bg-white text-gray-900"
                        placeholder="Conte de forma resumida o que aconteceu, com data, local, como foi e o motivo, incluindo o máximo de detalhes que puder."
                      />
                    </div>
                  )}

                  {/* Narrativa Processada - Mostra quando existir */}
                  {project.processedNarrative && (
                    <div className="pt-6 border-t border-gray-200">
                      <h3 className="flex items-center text-sm font-medium text-gray-500 mb-2">
                        <Sparkles className="w-4 h-4 mr-2 text-purple-500" />
                        <span>Narrativa Processada por IA</span>
                      </h3>
                      <div className="prose prose-sm max-w-none text-gray-800 whitespace-pre-wrap bg-purple-50 p-4 rounded-lg">
                        {project.processedNarrative}
                      </div>
                    </div>
                  )}
                </div>
              )}
            </div>
          </div>

          {/* Sidebar */}
          <div className="space-y-6">
            {/* Quick Actions */}
            <div className="bg-white rounded-lg shadow p-6">
              <h3 className="text-lg font-medium text-gray-900 mb-4">Ações do Projeto</h3>
              <div className="space-y-3">
                <button
                  onClick={() => {
                    if (project.processedNarrative) {
                      router.push(`/projects/${projectId}/upload`)
                    }
                  }}
                  disabled={!project.processedNarrative}
                  className="w-full flex items-center space-x-3 px-4 py-3 text-left text-gray-700 hover:bg-gray-100 rounded-lg border border-gray-200 transition-colors disabled:opacity-50 disabled:cursor-not-allowed disabled:hover:bg-white"
                  title={!project.processedNarrative ? 'Processe a narrativa antes de gerenciar documentos' : 'Gerenciar documentos do projeto'}
                >
                  <Upload className="w-5 h-5 text-indigo-600" />
                  <span>Gerenciar Documentos</span>
                </button>
                {!project.processedNarrative && (
                  <p className="text-xs text-amber-600 px-4 -mt-2 flex items-center">
                    <Info className="w-3 h-3 mr-1" />
                    Processe a narrativa primeiro
                  </p>
                )}

                <button
                  onClick={handleProcessNarrative}
                  disabled={isProcessingNarrative}
                  className="w-full flex items-center space-x-3 px-4 py-3 text-left text-gray-700 hover:bg-gray-100 rounded-lg border border-gray-200 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
                >
                  <Brain className="w-5 h-5 text-amber-600" />
                  <span>{isProcessingNarrative ? 'Processando...' : 'Processar Narrativa'}</span>
                </button>



                {project.documents && project.documents.length > 0 && (
                  <>
                    <button
                      onClick={handleExportZip}
                      disabled={isExportingZip}
                      className="w-full flex items-center space-x-3 px-4 py-3 text-left text-gray-700 hover:bg-gray-100 rounded-lg border border-gray-200 transition-colors disabled:opacity-50 cursor-pointer"
                    >
                      <Download className="w-5 h-5 text-indigo-600" />
                      <span>{isExportingZip ? 'Exportando ZIP...' : 'Exportar ZIP'}</span>
                    </button>

                    <button
                      onClick={handleExportOcrPdf}
                      disabled={isExportingOcrPdf}
                      className="w-full flex items-center space-x-3 px-4 py-3 text-left text-gray-700 hover:bg-gray-100 rounded-lg border border-gray-200 transition-colors disabled:opacity-50 cursor-pointer"
                    >
                      <FileText className="w-5 h-5 text-green-600" />
                      <span>{isExportingOcrPdf ? 'Gerando PDF...' : 'Exportar PDF OCR'}</span>
                    </button>
                  </>
                )}
              </div>
            </div>

            {/* Progress */}
            <div className="bg-white rounded-lg shadow p-6">
              <h3 className="text-lg font-medium text-gray-900 mb-4">Progresso</h3>
              <ul className="space-y-4">
                <li className="flex items-center justify-between">
                  <span className="text-sm text-gray-600">Projeto criado</span>
                  <CheckCircle className="w-5 h-5 text-green-500" />
                </li>
                <li className="flex items-center justify-between">
                  <span className="text-sm text-gray-600">Narrativa adicionada</span>
                  {project.narrative ? (
                    <CheckCircle className="w-5 h-5 text-green-500" />
                  ) : (
                    <div className="w-5 h-5 rounded-full border-2 border-gray-300"></div>
                  )}
                </li>
                <li className="flex items-center justify-between">
                  <span className="text-sm text-gray-600">Narrativa processada</span>
                  {project.processedNarrative ? (
                    <CheckCircle className="w-5 h-5 text-green-500" />
                  ) : (
                    <div className="w-5 h-5 rounded-full border-2 border-gray-300"></div>
                  )}
                </li>
                <li className="flex items-center justify-between">
                  <span className="text-sm text-gray-600">Documentos anexados</span>
                  {project.documents && project.documents.length > 0 ? (
                    <CheckCircle className="w-5 h-5 text-green-500" />
                  ) : (
                    <div className="w-5 h-5 rounded-full border-2 border-gray-300"></div>
                  )}
                </li>
                <li className="flex items-center justify-between">
                  <span className="text-sm text-gray-600">Documentos validados</span>
                  {project.documents && project.documents.length > 0 &&
                   project.documents.some(doc => doc.validation) ? (
                    <CheckCircle className="w-5 h-5 text-green-500" />
                  ) : (
                    <div className="w-5 h-5 rounded-full border-2 border-gray-300"></div>
                  )}
                </li>
              </ul>
            </div>

            {selectedSystem && (
              <div className="bg-white rounded-lg shadow p-6">
                <h3 className="text-lg font-medium text-gray-900 mb-4">Requisitos do Sistema</h3>
                <div className="text-sm text-gray-600 space-y-2">
                  <p>• Tamanho máximo por PDF: <strong>{formatFileSize(selectedSystem.maxFileSize)}</strong></p>
                  <p>• Limite de páginas por PDF: <strong>{selectedSystem.maxPageSize}</strong></p>
                  <p>• Formatos aceitos:PDF</p>
                </div>
              </div>
            )}
          </div>
        </div>
      </div>

      {/* Modal - Adicionar Sistema */}
      {showAddSystemModal && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-lg shadow-xl max-w-md w-full">
            {/* Modal Header */}
            <div className="flex items-center justify-between p-6 border-b border-gray-200">
              <h3 className="text-lg font-semibold text-gray-900">Adicionar Novo Sistema</h3>
              <button
                onClick={() => setShowAddSystemModal(false)}
                className="text-gray-400 hover:text-gray-600 transition-colors"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            {/* Modal Body */}
            <div className="p-6 space-y-4">
              {/* Nome do Sistema */}
              <div>
                <label htmlFor="newSystemName" className="block text-sm font-medium text-gray-700 mb-2">
                  Nome do Sistema *
                </label>
                <input
                  id="newSystemName"
                  type="text"
                  value={newSystem.systemName}
                  onChange={(e) => setNewSystem({ ...newSystem, systemName: e.target.value })}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent bg-white text-gray-900"
                  placeholder="Ex: PJe - TST"
                />
              </div>

              {/* Tamanho Máximo (MB) */}
              <div>
                <label htmlFor="maxFileSize" className="block text-sm font-medium text-gray-700 mb-2">
                  Tamanho Máximo do Arquivo (MB) *
                </label>
                <input
                  id="maxFileSize"
                  type="number"
                  min="1"
                  max="100"
                  value={newSystem.maxFileSize}
                  onChange={(e) => setNewSystem({ ...newSystem, maxFileSize: parseInt(e.target.value) || 30 })}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent bg-white text-gray-900"
                  placeholder="30"
                />
                <p className="text-xs text-gray-500 mt-1">Tamanho máximo permitido para upload de documentos</p>
              </div>

              {/* Tamanho Máximo por Página (KB) */}
              <div>
                <label htmlFor="maxPageSize" className="block text-sm font-medium text-gray-700 mb-2">
                  Tamanho Máximo por Página (KB) *
                </label>
                <input
                  id="maxPageSize"
                  type="number"
                  min="100"
                  max="1000"
                  value={newSystem.maxPageSize}
                  onChange={(e) => setNewSystem({ ...newSystem, maxPageSize: parseInt(e.target.value) || 500 })}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent bg-white text-gray-900"
                  placeholder="500"
                />
                <p className="text-xs text-gray-500 mt-1">Tamanho máximo permitido por página do PDF</p>
              </div>
            </div>

            {/* Modal Footer */}
            <div className="flex justify-end gap-3 p-6 border-t border-gray-200">
              <button
                onClick={() => setShowAddSystemModal(false)}
                className="px-4 py-2 text-gray-700 bg-white border border-gray-300 rounded-lg hover:bg-gray-50 transition-colors"
              >
                Cancelar
              </button>
              <button
                onClick={handleAddSystem}
                className="px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 transition-colors flex items-center gap-2"
              >
                <Plus className="w-4 h-4" />
                Adicionar Sistema
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Modal - Adicionar Tipo de Ação */}
      {showAddActionTypeModal && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-lg shadow-xl max-w-md w-full">
            {/* Modal Header */}
            <div className="flex items-center justify-between p-6 border-b border-gray-200">
              <h3 className="text-lg font-semibold text-gray-900">Adicionar Novo Tipo de Ação</h3>
              <button
                onClick={() => setShowAddActionTypeModal(false)}
                className="text-gray-400 hover:text-gray-600 transition-colors"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            {/* Modal Body */}
            <div className="p-6">
              <div>
                <label htmlFor="newActionType" className="block text-sm font-medium text-gray-700 mb-2">
                  Nome do Tipo de Ação *
                </label>
                <input
                  id="newActionType"
                  type="text"
                  value={newActionType}
                  onChange={(e) => setNewActionType(e.target.value)}
                  onKeyDown={(e) => e.key === 'Enter' && handleAddActionType()}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent bg-white text-gray-900"
                  placeholder="Ex: Ação de Usucapião"
                  autoFocus
                />
                <p className="text-xs text-gray-500 mt-2">
                  Digite o nome do tipo de ação que deseja adicionar à lista
                </p>
              </div>
            </div>

            {/* Modal Footer */}
            <div className="flex justify-end gap-3 p-6 border-t border-gray-200">
              <button
                onClick={() => setShowAddActionTypeModal(false)}
                className="px-4 py-2 text-gray-700 bg-white border border-gray-300 rounded-lg hover:bg-gray-50 transition-colors"
              >
                Cancelar
              </button>
              <button
                onClick={handleAddActionType}
                className="px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 transition-colors flex items-center gap-2"
              >
                <Plus className="w-4 h-4" />
                Adicionar Tipo
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}
