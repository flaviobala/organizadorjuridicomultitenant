// 'use client'

// import { useState, useEffect, use } from 'react'
// import { useRouter } from 'next/navigation'
// import {
//   ArrowLeft,
//   Upload,
//   FileText,
//   Trash2,
//   Eye,
//   CheckCircle,
//   Clock,
//   AlertTriangle,
//   Brain,
//   FileCheck,
//   X,
//   Sparkles,
//   RefreshCw,
//   FileSearch,
//   RotateCw
// } from 'lucide-react'

// interface AIAnalysisData {
//   confidence?: number
//   detectedDocumentType?: string
//   documentType?: string
//   detectedInfo?: {
//     name?: string
//     cpf?: string
//     rg?: string
//     [key: string]: unknown
//   }
//   [key: string]: unknown
// }

// interface DocumentValidation {
//   isRelevant: boolean
//   relevanceScore: number
//   analysis: string
//   suggestions?: string
//   status: string
// }

// interface Document {
//   id: number
//   originalFilename: string
//   storedFilename?: string
//   smartFilename?: string
//   documentType: string
//   detectedDocumentType?: string
//   documentNumber: number
//   mimeType: string
//   status: string
//   pdfPath?: string
//   ocrText?: string
//   pageCount?: number
//   originalSizeBytes: number
//   pdfSizeBytes?: number
//   hasOcrText?: boolean
//   aiAnalysis?: AIAnalysisData
//   validation?: DocumentValidation
//   createdAt: string
//   updatedAt?: string
// }

// interface Project {
//   id: number
//   name: string
//   client: string
//   system: string
//   processedNarrative?: string
// }

// export default function UploadDocumentsPage({
//   params
// }: {
//   params: Promise<{ id: string }>
// }) {
//   const router = useRouter()
//   const resolvedParams = use(params)
//   const projectId = parseInt(resolvedParams.id)

//   const [project, setProject] = useState<Project | null>(null)
//   const [documents, setDocuments] = useState<Document[]>([])
//   const [isLoading, setIsLoading] = useState(true)
//   const [isUploading, setIsUploading] = useState(false)
//   const [isValidating, setIsValidating] = useState(false)
//   const [selectedFiles, setSelectedFiles] = useState<FileList | null>(null)
//   const [uploadProgress, setUploadProgress] = useState<{ [key: string]: number }>({})
//   const [message, setMessage] = useState<{ type: 'error' | 'success' | 'info', text: string } | null>(null)
//   const [ocrModalOpen, setOcrModalOpen] = useState(false)
//   const [selectedDocumentOcr, setSelectedDocumentOcr] = useState<{ filename: string, text: string } | null>(null)
//   const [selectedDocuments, setSelectedDocuments] = useState<number[]>([])
//   const [deleteConfirmModal, setDeleteConfirmModal] = useState<{ message: string, onConfirm: () => void } | null>(null)
//   const [rotatingDocuments, setRotatingDocuments] = useState<Set<number>>(new Set())

//   useEffect(() => {
//     const token = localStorage.getItem('token')
//     if (!token) {
//       router.push('/login')
//       return
//     }

//     if (isNaN(projectId)) {
//       router.push('/dashboard')
//       return
//     }

//     loadProjectAndDocuments()
//   }, [projectId, router])

//   const loadProjectAndDocuments = async () => {
//     try {
//       const token = localStorage.getItem('token')
//       const response = await fetch(`/api/projects/${projectId}`, {
//         headers: {
//           'Authorization': `Bearer ${token}`
//         }
//       })

//       const data = await response.json()

//       if (data.success) {
//         setProject({
//           id: data.project.id,
//           name: data.project.name,
//           client: data.project.client,
//           system: data.project.system,
//           processedNarrative: data.project.processedNarrative
//         })
//         setDocuments(data.project.documents || [])
//       } else {
//         setMessage({ type: 'error', text: data.error || 'Projeto não encontrado' })
//       }
//     } catch {
//       setMessage({ type: 'error', text: 'Erro ao carregar projeto' })
//     } finally {
//       setIsLoading(false)
//     }
//   }

//   const handleUploadDocuments = async () => {
//     if (!selectedFiles || selectedFiles.length === 0) {
//       setMessage({ type: 'error', text: 'Selecione pelo menos um arquivo' })
//       return
//     }

//     setIsUploading(true)
//     setMessage({ type: 'info', text: '🤖 Iniciando análise inteligente dos documentos...' })

//     try {
//       const token = localStorage.getItem('token')
//       let successCount = 0

//       for (let i = 0; i < selectedFiles.length; i++) {
//         const file = selectedFiles[i]
//         const fileKey = `file_${i}`

//         setUploadProgress(prev => ({ ...prev, [fileKey]: 0 }))
//         setMessage({
//           type: 'info',
//           text: `🧠 Analisando documento ${i + 1}/${selectedFiles.length}: ${file.name}...`
//         })

//         const formData = new FormData()
//         formData.append('file', file)
//         formData.append('projectId', projectId.toString())

//         const nextDocNumber = documents.length + i + 1
//         formData.append('documentNumber', nextDocNumber.toString())
//         formData.append('documentType', 'auto-detect')

//         setUploadProgress(prev => ({ ...prev, [fileKey]: 25 }))

//         const response = await fetch('/api/documents/upload', {
//           method: 'POST',
//           headers: {
//             'Authorization': `Bearer ${token}`
//           },
//           body: formData,
//         })

//         setUploadProgress(prev => ({ ...prev, [fileKey]: 75 }))

//         const result = await response.json()

//         if (result.success) {
//           setUploadProgress(prev => ({ ...prev, [fileKey]: 100 }))
//           successCount++
//         } else {
//           setUploadProgress(prev => ({ ...prev, [fileKey]: 0 }))
//           throw new Error(`Erro no arquivo ${file.name}: ${result.error}`)
//         }
//       }

//       setMessage({
//         type: 'success',
//         text: `🎯 ${successCount} documento(s) processado(s) com sucesso!`
//       })

//       setSelectedFiles(null)
//       loadProjectAndDocuments()

//     } catch (error) {
//       setMessage({ type: 'error', text: error instanceof Error ? error.message : 'Erro no upload' })
//     } finally {
//       setIsUploading(false)
//       setUploadProgress({})
//     }
//   }

//   const handleSelectDocument = (docId: number) => {
//     setSelectedDocuments(prev =>
//       prev.includes(docId)
//         ? prev.filter(id => id !== docId)
//         : [...prev, docId]
//     )
//   }

//   const handleSelectAll = () => {
//     if (selectedDocuments.length === documents.length) {
//       setSelectedDocuments([])
//     } else {
//       setSelectedDocuments(documents.map(d => d.id))
//     }
//   }

//   const handleDeleteDocument = async (doc: Document) => {
//     setDeleteConfirmModal({
//       message: `Deseja realmente excluir o documento "${doc.originalFilename}"? Esta ação não pode ser desfeita.`,
//       onConfirm: async () => {
//         try {
//           const token = localStorage.getItem('token')
//           const response = await fetch(`/api/documents/${doc.id}`, {
//             method: 'DELETE',
//             headers: {
//               'Authorization': `Bearer ${token}`
//             }
//           })

//           const result = await response.json()

//           if (result.success) {
//             setMessage({ type: 'success', text: 'Documento excluído com sucesso!' })
//             setSelectedDocuments(prev => prev.filter(id => id !== doc.id))
//             loadProjectAndDocuments()
//           } else {
//             setMessage({ type: 'error', text: result.error || 'Erro ao excluir documento' })
//           }
//         } catch {
//           setMessage({ type: 'error', text: 'Erro de conexão' })
//         }
//       }
//     })
//   }

//   const handleDeleteSelected = async () => {
//     if (selectedDocuments.length === 0) return

//     setDeleteConfirmModal({
//       message: `Deseja realmente excluir ${selectedDocuments.length} documento(s) selecionado(s)? Esta ação não pode ser desfeita.`,
//       onConfirm: async () => {
//         try {
//           const token = localStorage.getItem('token')
//           let successCount = 0

//           for (const docId of selectedDocuments) {
//             const response = await fetch(`/api/documents/${docId}`, {
//               method: 'DELETE',
//               headers: {
//                 'Authorization': `Bearer ${token}`
//               }
//             })

//             const result = await response.json()
//             if (result.success) {
//               successCount++
//             }
//           }

//           setMessage({
//             type: 'success',
//             text: `${successCount} documento(s) excluído(s) com sucesso!`
//           })
//           setSelectedDocuments([])
//           loadProjectAndDocuments()
//         } catch {
//           setMessage({ type: 'error', text: 'Erro ao excluir documentos' })
//         }
//       }
//     })
//   }

//   const handleValidateDocuments = async () => {
//     if (!documents || documents.length === 0) {
//       setMessage({ type: 'error', text: 'Adicione documentos antes de validar' })
//       return
//     }

//     if (!project?.processedNarrative) {
//       setMessage({ type: 'error', text: 'Processe a narrativa antes de validar os documentos' })
//       return
//     }

//     setIsValidating(true)
//     setMessage({ type: 'info', text: 'Validando documentos com IA...' })

//     try {
//       const token = localStorage.getItem('token')
//       const response = await fetch('/api/ai/validate-documents', {
//         method: 'POST',
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': `Bearer ${token}`
//         },
//         body: JSON.stringify({
//           projectId: project.id
//         }),
//       })

//       const result = await response.json()

//       if (result.success) {
//         setMessage({ type: 'success', text: 'Documentos validados pela IA com sucesso!' })
//         loadProjectAndDocuments()
//       } else {
//         setMessage({ type: 'error', text: result.error || 'Erro na validação dos documentos' })
//       }
//     } catch {
//       setMessage({ type: 'error', text: 'Erro de conexão' })
//     } finally {
//       setIsValidating(false)
//     }
//   }

//   const handleRotateDocument = async (docId: number) => {
//     setRotatingDocuments(prev => new Set(prev).add(docId))
//     setMessage({ type: 'info', text: 'Rotacionando documento...' })

//     try {
//       const token = localStorage.getItem('token')
//       const response = await fetch(`/api/documents/${docId}/rotate`, {
//         method: 'POST',
//         headers: {
//           'Authorization': `Bearer ${token}`,
//           'Content-Type': 'application/json'
//         },
//         body: JSON.stringify({ degrees: 90 })
//       })

//       const result = await response.json()

//       if (result.success) {
//         setMessage({ type: 'success', text: 'Documento rotacionado com sucesso!' })
//         loadProjectAndDocuments()
//       } else {
//         setMessage({ type: 'error', text: result.error || 'Erro ao rotacionar documento' })
//       }
//     } catch (error) {
//       console.error('Erro ao rotacionar documento:', error)
//       setMessage({ type: 'error', text: 'Erro de conexão ao rotacionar' })
//     } finally {
//       setRotatingDocuments(prev => {
//         const next = new Set(prev)
//         next.delete(docId)
//         return next
//       })
//     }
//   }

//   const handleViewOcrText = (doc: Document) => {
//     if (!doc.ocrText) {
//       alert('⚠️ Sistema não conseguiu aplicar OCR\n\nO texto não pôde ser extraído deste documento.\nVerifique a qualidade do arquivo ou tente fazer upload novamente com melhor resolução.')
//       return
//     }

//     setSelectedDocumentOcr({
//       filename: doc.smartFilename || doc.originalFilename,
//       text: doc.ocrText
//     })
//     setOcrModalOpen(true)
//   }

//   const formatFileSize = (bytes: number) => {
//     if (bytes === 0) return '0 Bytes'
//     const k = 1024
//     const sizes = ['Bytes', 'KB', 'MB', 'GB']
//     const i = Math.floor(Math.log(bytes) / Math.log(k))
//     return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i]
//   }

//   const getDocumentStatusInfo = (status: string) => {
//     switch (status) {
//       case 'uploaded':
//         return { label: 'Enviado', color: 'text-blue-600 bg-blue-100', icon: Upload }
//       case 'converting':
//         return { label: 'Convertendo', color: 'text-yellow-600 bg-yellow-100', icon: Clock }
//       case 'converted':
//         return { label: 'Convertido', color: 'text-green-600 bg-green-100', icon: FileText }
//       case 'ocr_completed':
//         return { label: 'OCR Concluído', color: 'text-purple-600 bg-purple-100', icon: FileCheck }
//       default:
//         return { label: status, color: 'text-gray-600 bg-gray-100', icon: FileText }
//     }
//   }

//   if (isLoading) {
//     return (
//       <div className="min-h-screen bg-gray-50 flex items-center justify-center">
//         <div className="text-center">
//           <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto mb-4"></div>
//           <p className="text-gray-600">Carregando...</p>
//         </div>
//       </div>
//     )
//   }

//   if (!project) {
//     return (
//       <div className="min-h-screen bg-gray-50 flex items-center justify-center">
//         <div className="text-center">
//           <FileText className="w-16 h-16 text-gray-300 mx-auto mb-4" />
//           <h2 className="text-xl font-semibold text-gray-900 mb-2">Projeto não encontrado</h2>
//           <button
//             onClick={() => router.push('/dashboard')}
//             className="text-blue-600 hover:text-blue-800"
//           >
//             Voltar ao Dashboard
//           </button>
//         </div>
//       </div>
//     )
//   }

//   return (
//     <div className="min-h-screen bg-gray-50">
//       {/* Header */}
//       <header className="bg-white shadow-sm border-b border-gray-200">
//         <div className="max-w-[1600px] mx-auto px-6 lg:px-8">
//           <div className="flex justify-between items-center h-16">
//             <div className="flex items-center">
//               <button
//                 onClick={() => router.push(`/projects/${projectId}`)}
//                 className="mr-4 p-2 text-gray-600 hover:text-gray-900 transition-colors cursor-pointer"
//               >
//                 <ArrowLeft className="w-5 h-5" />
//               </button>
//               <div>
//                 <h1 className="text-xl font-semibold text-gray-900">Upload de Documentos</h1>
//                 <p className="text-sm text-gray-500">{project.name}</p>
//               </div>
//             </div>
//           </div>
//         </div>
//       </header>

//       <div className="max-w-[1600px] mx-auto px-6 lg:px-8 py-8">
//         {/* Breadcrumb */}
//         <nav className="flex mb-8" aria-label="Breadcrumb">
//           <ol className="inline-flex items-center space-x-1 md:space-x-3">
//             <li className="inline-flex items-center">
//               <button
//                 onClick={() => router.push('/dashboard')}
//                 className="text-gray-700 hover:text-blue-600"
//               >
//                 Dashboard
//               </button>
//             </li>
//             <li>
//               <div className="flex items-center">
//                 <span className="text-gray-400 mx-2">/</span>
//                 <button
//                   onClick={() => router.push(`/projects/${projectId}`)}
//                   className="text-gray-700 hover:text-blue-600"
//                 >
//                   {project.name}
//                 </button>
//               </div>
//             </li>
//             <li>
//               <div className="flex items-center">
//                 <span className="text-gray-400 mx-2">/</span>
//                 <span className="text-gray-500">Upload</span>
//               </div>
//             </li>
//           </ol>
//         </nav>

//         {/* Message */}
//         {message && (
//           <div className={`p-4 rounded-lg mb-6 flex items-center ${
//             message.type === 'error'
//               ? 'bg-red-50 text-red-700 border border-red-200'
//               : message.type === 'success'
//               ? 'bg-green-50 text-green-700 border border-green-200'
//               : 'bg-blue-50 text-blue-700 border border-blue-200'
//           }`}>
//             <div className="flex-shrink-0 mr-3">
//               {message.type === 'error' && <AlertTriangle className="w-5 h-5" />}
//               {message.type === 'success' && <CheckCircle className="w-5 h-5" />}
//               {message.type === 'info' && <Clock className="w-5 h-5" />}
//             </div>
//             {message.text}
//           </div>
//         )}

//         <div className="grid grid-cols-1 xl:grid-cols-[580px_1fr] gap-8">
//           {/* Upload Section */}
//           <div className="bg-white rounded-lg shadow h-fit">
//             <div className="px-6 py-4 border-b border-gray-200">
//               <h2 className="text-lg font-medium text-gray-900 flex items-center">
//                 <Upload className="w-5 h-5 mr-2 text-blue-600" />
//                 Adicionar Novos Documentos
//               </h2>
//             </div>

//             <div className="p-6 space-y-6">
//               {/* Drag & Drop Zone */}
//               <div>
//                 <label className="block text-sm font-medium text-gray-700 mb-3">
//                   Selecione os arquivos
//                 </label>

//                 <div
//                   className={`border-2 border-dashed rounded-lg p-8 text-center transition-colors relative ${
//                     selectedFiles && selectedFiles.length > 0
//                       ? 'border-green-300 bg-green-50'
//                       : 'border-gray-300 hover:border-blue-400 hover:bg-blue-50'
//                   }`}
//                 >
//                   <Upload className="w-12 h-12 text-gray-400 mx-auto mb-4" />

//                   {selectedFiles && selectedFiles.length > 0 ? (
//                     <div>
//                       <p className="text-green-600 font-medium mb-2">
//                         ✅ {selectedFiles.length} arquivo(s) selecionado(s)
//                       </p>
//                       <div className="text-sm text-gray-600 space-y-1 max-h-40 overflow-y-auto">
//                         {Array.from(selectedFiles).map((file, index) => (
//                           <div key={index} className="flex items-center justify-center">
//                             <FileText className="w-4 h-4 mr-2" />
//                             {file.name} ({formatFileSize(file.size)})
//                           </div>
//                         ))}
//                       </div>
//                     </div>
//                   ) : (
//                     <div>
//                       <p className="text-gray-600 mb-2">
//                         Arraste arquivos aqui ou clique para selecionar
//                       </p>
//                       <p className="text-xs text-gray-500">
//                         RG, CNH, CPF, Comprovantes, Procurações, etc.
//                       </p>
//                     </div>
//                   )}

//                   <input
//                     type="file"
//                     multiple
//                     accept=".pdf,.doc,.docx,.txt,.jpg,.jpeg,.png,.gif"
//                     onChange={(e) => setSelectedFiles(e.target.files)}
//                     className="absolute inset-0 w-full h-full opacity-0 cursor-pointer"
//                   />
//                 </div>

//                 <p className="text-xs text-gray-500 mt-2">
//                   Formatos aceitos: PDF, DOC, DOCX, TXT, JPG, PNG, GIF (máx. 30MB cada)
//                 </p>
//               </div>

//               {/* Progress Bars */}
//               {isUploading && Object.keys(uploadProgress).length > 0 && (
//                 <div className="bg-gray-50 rounded-lg p-4">
//                   <h4 className="text-sm font-medium text-gray-700 mb-3">Analizando Documentos:</h4>
//                   <div className="space-y-2">
//                     {Object.entries(uploadProgress).map(([fileKey, progress]) => (
//                       <div key={fileKey}>
//                         <div className="flex justify-between text-xs text-gray-600 mb-1">
//                           <span>Arquivo {parseInt(fileKey.split('_')[1]) + 1}</span>
//                           <span>{progress}%</span>
//                         </div>
//                         <div className="w-full bg-gray-200 rounded-full h-2">
//                           <div
//                             className="bg-blue-600 h-2 rounded-full transition-all duration-300"
//                             style={{ width: `${progress}%` }}
//                           />
//                         </div>
//                       </div>
//                     ))}
//                   </div>
//                 </div>
//               )}

//               {/* AI Info */}
//               <div className="bg-purple-50 border border-purple-200 rounded-lg p-4">
//                 <div className="flex items-start">
//                   <Brain className="w-5 h-5 text-amber-700 mr-3 mt-0.5" />
//                   <div>
//                     <h4 className="text-sm font-medium text-amber-700 mb-1">
//                        Análise com Inteligência Artificial
//                     </h4>
//                     <p className="text-sm text-amber-700">
//                       Cada documento será processado automaticamente:
//                     </p>
//                     <ul className="text-xs text-amber-700 mt-2 space-y-1">
//                       <li>• Detecção automática do tipo</li>
//                       <li>• Extração de dados (CPF, RG, nomes)</li>
//                       <li>• Conversão para PDF</li>
//                       <li>• OCR (reconhecimento de texto)</li>
//                       <li>• Nomenclatura inteligente</li>
//                     </ul>
//                   </div>
//                 </div>
//               </div>

//               {/* Action Buttons */}
//               <div className="flex gap-2">
//                 <button
//                   onClick={() => setSelectedFiles(null)}
//                   disabled={!selectedFiles || isUploading}
//                   className="flex-1 px-3 py-1.5 text-sm text-gray-700 bg-white border border-gray-300 rounded-md hover:bg-gray-50 transition-colors disabled:opacity-50"
//                 >
//                   Limpar
//                 </button>

//                 <button
//                   onClick={handleUploadDocuments}
//                   disabled={isUploading || !selectedFiles }
//                   className="flex-1 flex items-center justify-center space-x-1 px-3 py-1.5 text-sm bg-amber-600 text-white rounded-md hover:bg-amber-700 disabled:opacity-50 transition-colors cursor-pointer"
//                 >
//                   <Brain className="w-3.5 h-3.5" />
//                   <span>
//                     {isUploading
//                       ? 'Analisando...'
//                       : 'Analisar'
//                     }
//                   </span>
//                 </button>
//               </div>
//             </div>
//           </div>

//           {/* Documents List */}
//           <div className="bg-white rounded-lg shadow">
//             <div className="px-4 sm:px-6 py-4 border-b border-gray-200">
//               <div className="flex flex-col sm:flex-row sm:justify-between sm:items-center gap-3">
//                 <div className="flex items-center space-x-3">
//                   <h2 className="text-lg font-medium text-gray-900">
//                     Documentos ({documents.length})
//                   </h2>
//                   {documents.length > 0 && (
//                     <div className="flex items-center space-x-2">
//                       <input
//                         type="checkbox"
//                         checked={selectedDocuments.length === documents.length && documents.length > 0}
//                         onChange={handleSelectAll}
//                         className="w-4 h-4 text-blue-600 rounded cursor-pointer"
//                         title="Selecionar todos"
//                       />
//                       {selectedDocuments.length > 0 && (
//                         <span className="text-xs sm:text-sm text-gray-600">
//                           {selectedDocuments.length} sel.
//                         </span>
//                       )}
//                     </div>
//                   )}
//                 </div>
//                 <div className="flex items-center gap-2 flex-wrap">
//                   {selectedDocuments.length > 0 && (
//                     <button
//                       onClick={handleDeleteSelected}
//                       className="flex items-center space-x-1 px-3 py-1.5 text-sm bg-red-600 text-white rounded-md hover:bg-red-700 transition-colors cursor-pointer"
//                     >
//                       <Trash2 className="w-3.5 h-3.5" />
//                       <span className="hidden sm:inline">Deletar</span>
//                     </button>
//                   )}
//                   {documents.length > 0 && (
//                     <button
//                       onClick={handleValidateDocuments}
//                       disabled={isValidating || !project?.processedNarrative}
//                       className="flex items-center space-x-1 px-3 py-1.5 text-sm bg-amber-600 text-white rounded-md hover:bg-amber-700 disabled:opacity-50 disabled:cursor-not-allowed transition-colors cursor-pointer"
//                       title={!project?.processedNarrative ? 'Processe a narrativa primeiro' : 'Validar relevância'}
//                     >
//                       <FileCheck className="w-3.5 h-3.5" />
//                       <span className="hidden sm:inline">{isValidating ? 'Validando...' : 'Validar'}</span>
//                     </button>
//                   )}
//                   <button
//                     onClick={loadProjectAndDocuments}
//                     className="p-1.5 text-gray-600 hover:text-gray-900 transition-colors cursor-pointer"
//                     title="Atualizar lista"
//                   >
//                     <RefreshCw className="w-3.5 h-3.5" />
//                   </button>
//                 </div>
//               </div>
//             </div>

//             <div className="p-6">
//               {documents.length > 0 ? (
//                 <div className="space-y-5">
//                   {documents.map((doc) => {
//                     const docStatusInfo = getDocumentStatusInfo(doc.status)
//                     const DocStatusIcon = docStatusInfo.icon

//                     return (
//                       <div key={doc.id} className="border border-gray-200 rounded-lg p-5 hover:shadow-md transition-shadow">
//                         <div className="flex items-start justify-between gap-4">
//                           <div className="flex items-start space-x-4 flex-1">
//                             <input
//                               type="checkbox"
//                               checked={selectedDocuments.includes(doc.id)}
//                               onChange={() => handleSelectDocument(doc.id)}
//                               className="mt-1 w-4 h-4 text-blue-600 rounded cursor-pointer flex-shrink-0"
//                             />

//                             {/* Preview/Thumbnail da imagem */}
//                             {doc.pdfPath && (
//                               <div className="flex-shrink-0">
//                                 <div className="relative w-24 h-32 border-2 border-gray-300 rounded-lg overflow-hidden bg-gray-100 shadow-sm">
//                                   <iframe
//                                     src={`${doc.pdfPath}?t=${doc.updatedAt || Date.now()}`}
//                                     className="w-full h-full pointer-events-none"
//                                     title={`Preview de ${doc.originalFilename}`}
//                                   />
//                                   <div className="absolute inset-0 bg-transparent pointer-events-none" />
//                                 </div>
//                               </div>
//                             )}

//                             <div className="flex-1">
//                             <div className="flex items-center space-x-2 mb-2">
//                               <span className="bg-blue-100 text-blue-800 text-xs font-medium px-2 py-1 rounded">
//                                 Doc {doc.documentNumber.toString().padStart(2, '0')}
//                               </span>
//                               <span className={`inline-flex items-center px-2 py-1 rounded-full text-xs font-medium ${docStatusInfo.color}`}>
//                                 <DocStatusIcon className="w-3 h-3 mr-1" />
//                                 {docStatusInfo.label}
//                               </span>

//                               {doc.detectedDocumentType && (
//                                 <span className="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium bg-purple-100 text-purple-800">
//                                   <Brain className="w-3 h-3 mr-1" />
//                                   {doc.detectedDocumentType}
//                                 </span>
//                               )}
//                             </div>

//                             <h4 className="font-medium text-gray-900 mb-1 break-words">{doc.originalFilename}</h4>

//                             {doc.smartFilename && doc.smartFilename !== doc.originalFilename && (
//                               <div className="mb-2">
//                                 <span className="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium bg-green-100 text-green-800 break-words max-w-full">
//                                   <Sparkles className="w-3 h-3 mr-1 flex-shrink-0" />
//                                   <span className="break-words">{doc.smartFilename.slice(0, 50)}</span>
//                                 </span>
//                               </div>
//                             )}

//                             <div className="text-sm text-gray-500 space-y-1">
//                               <p>Tipo: {doc.hasOcrText}</p>
//                               <p>Tamanho: {formatFileSize(doc.originalSizeBytes)}</p>
//                               {doc.pageCount && <p>Páginas: {doc.pageCount}</p>}
//                             </div>

//                             {doc.aiAnalysis && (
//                               <div className="mt-2 p-2 bg-blue-50 border border-blue-200 rounded text-xs">
//                                 <div className="flex items-center">
//                                   <Brain className="w-3 h-3 text-blue-600 mr-1" />
//                                   <span className="font-medium text-blue-900">Confiança IA: {Math.round((doc.aiAnalysis.confidence || 0) * 100)}%</span>
//                                 </div>
//                               </div>
//                             )}

//                             {doc.validation && (
//                               <div className={`mt-2 p-3 rounded-lg border ${
//                                 doc.validation.isRelevant
//                                   ? 'bg-green-50 border-green-200'
//                                   : 'bg-red-50 border-red-200'
//                               }`}>
//                                 <div className="flex items-center mb-2">
//                                   <FileCheck className={`w-4 h-4 mr-2 ${
//                                     doc.validation.isRelevant ? 'text-amber-700' : 'text-red-600'
//                                   }`} />
//                                   <span className="text-sm font-medium text-gray-900">Validação IA:</span>
//                                   <span className={`ml-2 text-xs px-2 py-1 rounded-full ${
//                                     doc.validation.isRelevant
//                                       ? 'bg-green-100 text-green-800'
//                                       : 'bg-red-100 text-red-800'
//                                   }`}>
//                                     {doc.validation.isRelevant ? '✓ Relevante' : '✗ Não Relevante'}
//                                   </span>
//                                   <span className="ml-2 text-xs text-gray-500">
//                                     ({Math.round(doc.validation.relevanceScore * 100)}%)
//                                   </span>
//                                 </div>
//                                 <p className="text-sm text-gray-700">{doc.validation.analysis}</p>
//                                 {doc.validation.suggestions && (
//                                   <div className="mt-2 pt-2 border-t border-gray-200">
//                                     <p className="text-xs font-medium text-gray-700">Sugestões:</p>
//                                     <p className="text-xs text-gray-600 mt-1">{doc.validation.suggestions}</p>
//                                   </div>
//                                 )}
//                               </div>
//                             )}
//                             </div>
//                           </div>

//                           <div className="flex items-center gap-2 ml-2">
//                             {/* Botão de Rotação */}
//                             <button
//                               onClick={() => handleRotateDocument(doc.id)}
//                               disabled={rotatingDocuments.has(doc.id)}
//                               className="p-2 text-green-600 hover:bg-green-50 rounded-lg transition-colors cursor-pointer disabled:opacity-50 disabled:cursor-not-allowed"
//                               title="Girar 90° (sentido horário)"
//                             >
//                               {rotatingDocuments.has(doc.id) ? (
//                                 <RefreshCw className="w-4 h-4 animate-spin" />
//                               ) : (
//                                 <RotateCw className="w-4 h-4" />
//                               )}
//                             </button>

//                             {doc.pdfPath && (
//                               <button
//                                 onClick={() => {
//                                   const urlWithTimestamp = `${doc.pdfPath}?t=${doc.updatedAt || Date.now()}`
//                                   window.open(urlWithTimestamp, '_blank')
//                                 }}
//                                 className="p-2 text-blue-600 hover:bg-blue-50 rounded-lg transition-colors cursor-pointer"
//                                 title="Visualizar"
//                               >
//                                 <Eye className="w-4 h-4" />
//                               </button>
//                             )}

//                             <button
//                               onClick={() => handleViewOcrText(doc)}
//                               className="p-2 text-purple-600 hover:bg-purple-50 rounded-lg transition-colors cursor-pointer"
//                               title="Ver OCR"
//                             >
//                               <FileSearch className="w-4 h-4" />
//                             </button>

//                             <button
//                               onClick={() => handleDeleteDocument(doc)}
//                               className="p-2 text-red-600 hover:bg-red-50 rounded-lg transition-colors cursor-pointer"
//                               title="Excluir"
//                             >
//                               <Trash2 className="w-4 h-4" />
//                             </button>
//                           </div>
//                         </div>
//                       </div>
//                     )
//                   })}
//                 </div>
//               ) : (
//                 <div className="text-center py-8">
//                   <FileText className="w-12 h-12 text-gray-300 mx-auto mb-4" />
//                   <p className="text-gray-500">Nenhum documento processado ainda.</p>
//                   <p className="text-sm text-gray-400 mt-2">
//                     Use o painel ao lado para fazer upload.
//                   </p>
//                 </div>
//               )}
//             </div>
//           </div>
//         </div>

//         {/* Action Buttons */}
//         <div className="mt-8 flex flex-col sm:flex-row justify-between gap-3">
//           <button
//             onClick={() => router.push(`/projects/${projectId}`)}
//             className="flex items-center justify-center space-x-1 px-4 py-2 text-sm bg-gray-600 text-white rounded-md hover:bg-gray-700 transition-colors cursor-pointer"
//           >
//             <ArrowLeft className="w-3.5 h-3.5" />
//             <span>Voltar</span>
//           </button>

//           {documents.length > 0 && (
//             <button
//               onClick={() => router.push(`/projects/${projectId}`)}
//               className="flex items-center justify-center space-x-1 px-4 py-2 text-sm bg-amber-600 text-white rounded-md hover:bg-amber-700 transition-colors cursor-pointer"
//             >
//               <CheckCircle className="w-3.5 h-3.5" />
//               <span>Concluir e Exportar</span>
//             </button>
//           )}
//         </div>
//       </div>

//       {/* Delete Confirmation Modal */}
//       {deleteConfirmModal && (
//         <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4 overflow-y-auto">
//           <div className="bg-white rounded-lg shadow-xl max-w-md w-full my-8">
//             {/* Modal Header */}
//             <div className="px-6 py-4 border-b border-gray-200">
//               <div className="flex items-center space-x-3">
//                 <div className="w-12 h-12 bg-red-100 rounded-full flex items-center justify-center flex-shrink-0">
//                   <AlertTriangle className="w-6 h-6 text-red-600" />
//                 </div>
//                 <div>
//                   <h3 className="text-lg font-semibold text-gray-900">Confirmar Exclusão</h3>
//                   <p className="text-sm text-gray-500">Esta ação não pode ser desfeita</p>
//                 </div>
//               </div>
//             </div>

//             {/* Modal Body */}
//             <div className="px-6 py-4">
//               <p className="text-gray-700">
//                 {deleteConfirmModal.message}
//               </p>
//             </div>

//             {/* Modal Footer */}
//             <div className="px-6 py-4 bg-gray-50 flex justify-end gap-3 rounded-b-lg">
//               <button
//                 onClick={() => setDeleteConfirmModal(null)}
//                 className="px-4 py-2 text-sm bg-white border border-gray-300 text-gray-700 rounded-md hover:bg-gray-50 transition-colors cursor-pointer"
//               >
//                 Cancelar
//               </button>
//               <button
//                 onClick={() => {
//                   deleteConfirmModal.onConfirm()
//                   setDeleteConfirmModal(null)
//                 }}
//                 className="px-4 py-2 text-sm bg-red-600 text-white rounded-md hover:bg-red-700 transition-colors cursor-pointer"
//               >
//                 Sim, Excluir
//               </button>
//             </div>
//           </div>
//         </div>
//       )}

//       {/* OCR Text Modal */}
//       {ocrModalOpen && selectedDocumentOcr && (
//         <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
//           <div className="bg-white rounded-lg shadow-xl max-w-4xl w-full max-h-[90vh] flex flex-col">
//             {/* Modal Header */}
//             <div className="px-6 py-4 border-b border-gray-200 flex justify-between items-center">
//               <div className="flex items-center">
//                 <FileSearch className="w-5 h-5 text-amber-700 mr-2" />
//                 <h3 className="text-lg font-semibold text-gray-900">Texto Extraído (OCR)</h3>
//               </div>
//               <button
//                 onClick={() => setOcrModalOpen(false)}
//                 className="p-2 text-gray-400 hover:text-gray-600 transition-colors cursor-pointer"
//               >
//                 <X className="w-5 h-5" />
//               </button>
//             </div>

//             {/* Modal Body */}
//             <div className="px-6 py-4 overflow-y-auto flex-1">
//               <div className="mb-4">
//                 <span className="text-sm font-medium text-gray-700">Arquivo:</span>
//                 <span className="ml-2 text-sm text-gray-600">{selectedDocumentOcr.filename}</span>
//               </div>

//               <div className="bg-gray-50 border border-gray-200 rounded-lg p-4">
//                 <pre className="whitespace-pre-wrap text-sm text-gray-800 font-mono">
//                   {selectedDocumentOcr.text}
//                 </pre>
//               </div>
//             </div>

//             {/* Modal Footer */}
//             <div className="px-6 py-4 border-t border-gray-200 flex justify-end gap-2">
//               <button
//                 onClick={() => {
//                   try {
//                     // Método fallback que funciona em todos os navegadores
//                     const textArea = document.createElement('textarea')
//                     textArea.value = selectedDocumentOcr.text
//                     textArea.style.position = 'fixed'
//                     textArea.style.left = '-999999px'
//                     textArea.style.top = '-999999px'
//                     document.body.appendChild(textArea)
//                     textArea.focus()
//                     textArea.select()

//                     try {
//                       const successful = document.execCommand('copy')
//                       if (successful) {
//                         setMessage({ type: 'success', text: 'Texto copiado para a área de transferência!' })
//                       } else {
//                         throw new Error('execCommand falhou')
//                       }
//                     } catch (err) {
//                       // Tenta usar o Clipboard API moderno se disponível
//                       if (navigator.clipboard && navigator.clipboard.writeText) {
//                         navigator.clipboard.writeText(selectedDocumentOcr.text)
//                           .then(() => {
//                             setMessage({ type: 'success', text: 'Texto copiado para a área de transferência!' })
//                           })
//                           .catch(() => {
//                             setMessage({ type: 'error', text: 'Erro ao copiar. Tente selecionar e copiar manualmente (Ctrl+C).' })
//                           })
//                       } else {
//                         setMessage({ type: 'error', text: 'Erro ao copiar. Tente selecionar e copiar manualmente (Ctrl+C).' })
//                       }
//                     } finally {
//                       document.body.removeChild(textArea)
//                     }
//                   } catch (error) {
//                     console.error('Erro ao copiar:', error)
//                     setMessage({ type: 'error', text: 'Erro ao copiar texto. Tente selecionar e copiar manualmente.' })
//                   }
//                 }}
//                 className="px-3 py-1.5 text-sm bg-purple-600 text-white rounded-md hover:bg-purple-700 transition-colors cursor-pointer"
//               >
//                 Copiar
//               </button>
//               <button
//                 onClick={() => setOcrModalOpen(false)}
//                 className="px-3 py-1.5 text-sm bg-gray-200 text-gray-700 rounded-md hover:bg-gray-300 transition-colors cursor-pointer"
//               >
//                 Fechar
//               </button>
//             </div>
//           </div>
//         </div>
//       )}
//     </div>
//   )
// }

'use client'

import { useState, useEffect, use, useCallback, useRef } from 'react'
import { useRouter } from 'next/navigation'
import {
  ArrowLeft,
  Upload,
  FileText,
  Trash2,
  Eye,
  CheckCircle,
  Clock,
  AlertTriangle,
  Brain,
  FileCheck,
  X,
  Sparkles,
  RefreshCw,
  FileSearch,
  RotateCw,
  ChevronLeft,
  ChevronRight,
  RotateCcw
} from 'lucide-react'

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

interface DocumentValidation {
  isRelevant: boolean
  relevanceScore: number
  analysis: string
  suggestions?: string
  status: string
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
  ocrText?: string
  pageCount?: number
  originalSizeBytes: number
  pdfSizeBytes?: number
  hasOcrText?: boolean
  aiAnalysis?: AIAnalysisData
  validation?: DocumentValidation
  createdAt: string
  updatedAt?: string
}

interface Project {
  id: number
  name: string
  client: string
  system: string
  processedNarrative?: string
}

export default function UploadDocumentsPage({
  params
}: {
  params: Promise<{ id: string }>
}) {
  const router = useRouter()
  const resolvedParams = use(params)
  const projectId = parseInt(resolvedParams.id)

  const [project, setProject] = useState<Project | null>(null)
  const [documents, setDocuments] = useState<Document[]>([])
  const [isLoading, setIsLoading] = useState(true)
  const [isUploading, setIsUploading] = useState(false)
  const [isValidating, setIsValidating] = useState(false)
  const [selectedFiles, setSelectedFiles] = useState<FileList | null>(null)
  const [uploadProgress, setUploadProgress] = useState<{ [key: string]: number }>({})
  const [message, setMessage] = useState<{ type: 'error' | 'success' | 'info', text: string } | null>(null)
  const [ocrModalOpen, setOcrModalOpen] = useState(false)
  const [selectedDocumentOcr, setSelectedDocumentOcr] = useState<{ filename: string, text: string } | null>(null)
  const [selectedDocuments, setSelectedDocuments] = useState<number[]>([])
  const [deleteConfirmModal, setDeleteConfirmModal] = useState<{ message: string, onConfirm: () => void } | null>(null)
  const [rotatingDocuments, setRotatingDocuments] = useState<Set<number>>(new Set())

  // ✅ NOVO: Estado para modal de preview com rotação
  const [previewModalOpen, setPreviewModalOpen] = useState(false)
  const [previewFiles, setPreviewFiles] = useState<Array<{
    file: File
    preview: string
    rotation: number
    isPDF?: boolean
  }>>([])
  const [currentPreviewIndex, setCurrentPreviewIndex] = useState(0)
  const [previewKey, setPreviewKey] = useState(0) // Força remount completo

  // ✅ NOVO: Ref para o input file
  const fileInputRef = useRef<HTMLInputElement>(null)

  // Cleanup de preview URLs quando componente desmonta
  useEffect(() => {
    return () => {
      previewFiles.forEach(pf => {
        try {
          URL.revokeObjectURL(pf.preview)
        } catch (e) {
          // Ignorar erros ao revogar URLs
        }
      })
    }
  }, [])

  // ✅ Handler para abrir modal de preview ao selecionar arquivos
  const handleFilesSelected = async (files: FileList | null) => {
    if (!files || files.length === 0) return

    // Criar preview URLs para cada arquivo
    const previews = Array.from(files).map((file) => {
      const isPDF = file.type === 'application/pdf'
      const preview = URL.createObjectURL(file)

      return {
        file,
        preview,
        rotation: 0,
        isPDF
      }
    })

    setPreviewFiles(previews)
    setCurrentPreviewIndex(0)
    setPreviewModalOpen(true)
  }

  // ✅ Rotacionar imagem no preview
  const handleRotatePreview = (direction: 'left' | 'right') => {
    setPreviewFiles(prev => {
      const updated = [...prev]
      const currentRotation = updated[currentPreviewIndex].rotation
      updated[currentPreviewIndex] = {
        ...updated[currentPreviewIndex],
        rotation: direction === 'right'
          ? (currentRotation + 90) % 360
          : (currentRotation - 90 + 360) % 360
      }
      return updated
    })
    // Forçar re-render do preview
    setPreviewKey(prev => prev + 1)
  }

  // ✅ Navegar entre arquivos no preview
  const handlePreviewNavigation = (direction: 'prev' | 'next') => {
    if (direction === 'next' && currentPreviewIndex < previewFiles.length - 1) {
      setCurrentPreviewIndex(prev => prev + 1)
      setPreviewKey(prev => prev + 1) // Força remount
    } else if (direction === 'prev' && currentPreviewIndex > 0) {
      setCurrentPreviewIndex(prev => prev - 1)
      setPreviewKey(prev => prev + 1) // Força remount
    }
  }

  // ✅ Aplicar rotação ao buffer da imagem/PDF antes do upload
  const applyRotationToFile = async (file: File, rotation: number): Promise<File> => {
    // Se rotação for 0, retornar arquivo original
    if (rotation === 0) return file

    const isPDF = file.type === 'application/pdf'

    if (isPDF) {
      // Rotacionar PDF usando pdf-lib
      try {
        const { PDFDocument, degrees } = await import('pdf-lib')

        const arrayBuffer = await file.arrayBuffer()
        const pdfDoc = await PDFDocument.load(arrayBuffer, { ignoreEncryption: true })

        const pages = pdfDoc.getPages()
        pages.forEach(page => {
          const currentRotation = page.getRotation().angle
          const newRotation = (currentRotation + rotation) % 360
          page.setRotation(degrees(newRotation))
        })

        const pdfBytes = await pdfDoc.save()
        // Criar File a partir do Uint8Array (cast para BlobPart para resolver warning TypeScript)
        return new File([new Blob([pdfBytes as BlobPart])], file.name, {
          type: 'application/pdf',
          lastModified: Date.now()
        })
      } catch (error) {
        console.error('Erro ao rotacionar PDF:', error)
        throw error
      }
    } else {
      // Rotacionar imagem usando canvas
      return new Promise((resolve, reject) => {
        const img = new Image()
        const canvas = document.createElement('canvas')
        const ctx = canvas.getContext('2d')

        if (!ctx) {
          reject(new Error('Não foi possível criar contexto do canvas'))
          return
        }

        img.onload = () => {
          // Calcular dimensões rotacionadas
          if (rotation === 90 || rotation === 270) {
            canvas.width = img.height
            canvas.height = img.width
          } else {
            canvas.width = img.width
            canvas.height = img.height
          }

          // Aplicar rotação
          ctx.translate(canvas.width / 2, canvas.height / 2)
          ctx.rotate((rotation * Math.PI) / 180)
          ctx.drawImage(img, -img.width / 2, -img.height / 2)

          // Converter canvas para blob e criar novo File
          canvas.toBlob((blob) => {
            if (blob) {
              const rotatedFile = new File([blob], file.name, {
                type: file.type,
                lastModified: Date.now()
              })
              resolve(rotatedFile)
            } else {
              reject(new Error('Falha ao converter canvas para blob'))
            }
          }, file.type)
        }

        img.onerror = () => reject(new Error('Falha ao carregar imagem'))
        img.src = URL.createObjectURL(file)
      })
    }
  }

  // ✅ Confirmar preview e processar upload com rotações aplicadas
  const handleConfirmPreviewAndUpload = async () => {
    setPreviewModalOpen(false)
    setIsUploading(true)
    setMessage({ type: 'info', text: '🔄 Aplicando rotações e preparando arquivos...' })

    try {
      const token = localStorage.getItem('token')
      let successCount = 0

      // Processar cada arquivo com sua rotação
      for (let i = 0; i < previewFiles.length; i++) {
        const { file, rotation } = previewFiles[i]
        const fileKey = `file_${i}`

        setUploadProgress(prev => ({ ...prev, [fileKey]: 0 }))
        setMessage({
          type: 'info',
          text: `🧠 Analisando documento ${i + 1}/${previewFiles.length}: ${file.name}...`
        })

        // Aplicar rotação se necessário
        let processedFile = file
        if (rotation !== 0) {
          setMessage({
            type: 'info',
            text: `🔄 Aplicando rotação de ${rotation}° ao documento ${i + 1}...`
          })
          processedFile = await applyRotationToFile(file, rotation)
        }

        const formData = new FormData()
        formData.append('file', processedFile)
        formData.append('projectId', projectId.toString())

        const nextDocNumber = documents.length + i + 1
        formData.append('documentNumber', nextDocNumber.toString())
        formData.append('documentType', 'auto-detect')

        setUploadProgress(prev => ({ ...prev, [fileKey]: 25 }))

        const response = await fetch('/api/documents/upload', {
          method: 'POST',
          headers: {
            'Authorization': `Bearer ${token}`
          },
          body: formData,
        })

        setUploadProgress(prev => ({ ...prev, [fileKey]: 75 }))

        const result = await response.json()

        if (result.success) {
          setUploadProgress(prev => ({ ...prev, [fileKey]: 100 }))
          successCount++
        } else {
          setUploadProgress(prev => ({ ...prev, [fileKey]: 0 }))
          throw new Error(`Erro no arquivo ${file.name}: ${result.error}`)
        }
      }

      setMessage({
        type: 'success',
        text: `🎯 ${successCount} documento(s) processado(s) com sucesso!`
      })

      // Limpar preview files
      previewFiles.forEach(pf => {
        try {
          URL.revokeObjectURL(pf.preview)
        } catch (e) {
          // Ignorar erros ao revogar URLs
        }
      })
      setPreviewFiles([])
      setSelectedFiles(null)

      // ✅ CORRIGIDO: Resetar input file para permitir novo upload
      if (fileInputRef.current) {
        fileInputRef.current.value = ''
      }

      loadProjectAndDocuments()

    } catch (error) {
      setMessage({ type: 'error', text: error instanceof Error ? error.message : 'Erro no upload' })
    } finally {
      setIsUploading(false)
      setUploadProgress({})
    }
  }

  // ✅ Cancelar preview
  const handleCancelPreview = () => {
    previewFiles.forEach(pf => {
      try {
        URL.revokeObjectURL(pf.preview)
      } catch (e) {
        // Ignorar erros ao revogar URLs
      }
    })
    setPreviewFiles([])
    setPreviewModalOpen(false)
    setSelectedFiles(null)

    // ✅ CORRIGIDO: Resetar input file para permitir novo upload
    if (fileInputRef.current) {
      fileInputRef.current.value = ''
    }
  }

  const loadProjectAndDocuments = useCallback(async () => {
    try {
      const token = localStorage.getItem('token')
      const response = await fetch(`/api/projects/${projectId}`, {
        headers: {
          'Authorization': `Bearer ${token}`
        }
      })

      const data = await response.json()

      if (data.success) {
        setProject({
          id: data.project.id,
          name: data.project.name,
          client: data.project.client,
          system: data.project.system,
          processedNarrative: data.project.processedNarrative
        })
        setDocuments(data.project.documents || [])
      } else {
        setMessage({ type: 'error', text: data.error || 'Projeto não encontrado' })
      }
    } catch {
      setMessage({ type: 'error', text: 'Erro ao carregar projeto' })
    } finally {
      setIsLoading(false)
    }
  }, [projectId])

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

    loadProjectAndDocuments()
  }, [projectId, router, loadProjectAndDocuments])

  // ✅ Função antiga mantida como fallback (não usada no fluxo principal)
  // const handleUploadDocuments = async () => { ... }

  const handleSelectDocument = (docId: number) => {
    setSelectedDocuments(prev =>
      prev.includes(docId)
        ? prev.filter(id => id !== docId)
        : [...prev, docId]
    )
  }

  const handleSelectAll = () => {
    if (selectedDocuments.length === documents.length) {
      setSelectedDocuments([])
    } else {
      setSelectedDocuments(documents.map(d => d.id))
    }
  }

  const handleDeleteDocument = async (doc: Document) => {
    setDeleteConfirmModal({
      message: `Deseja realmente excluir o documento "${doc.originalFilename}"? Esta ação não pode ser desfeita.`,
      onConfirm: async () => {
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
            setSelectedDocuments(prev => prev.filter(id => id !== doc.id))
            loadProjectAndDocuments()
          } else {
            setMessage({ type: 'error', text: result.error || 'Erro ao excluir documento' })
          }
        } catch {
          setMessage({ type: 'error', text: 'Erro de conexão' })
        }
      }
    })
  }

  const handleDeleteSelected = async () => {
    if (selectedDocuments.length === 0) return

    setDeleteConfirmModal({
      message: `Deseja realmente excluir ${selectedDocuments.length} documento(s) selecionado(s)? Esta ação não pode ser desfeita.`,
      onConfirm: async () => {
        try {
          const token = localStorage.getItem('token')
          let successCount = 0

          for (const docId of selectedDocuments) {
            const response = await fetch(`/api/documents/${docId}`, {
              method: 'DELETE',
              headers: {
                'Authorization': `Bearer ${token}`
              }
            })

            const result = await response.json()
            if (result.success) {
              successCount++
            }
          }

          setMessage({
            type: 'success',
            text: `${successCount} documento(s) excluído(s) com sucesso!`
          })
          setSelectedDocuments([])
          loadProjectAndDocuments()
        } catch {
          setMessage({ type: 'error', text: 'Erro ao excluir documentos' })
        }
      }
    })
  }

  const handleValidateDocuments = async () => {
    if (!documents || documents.length === 0) {
      setMessage({ type: 'error', text: 'Adicione documentos antes de validar' })
      return
    }

    if (!project?.processedNarrative) {
      setMessage({ type: 'error', text: 'Processe a narrativa antes de validar os documentos' })
      return
    }

    setIsValidating(true)
    setMessage({ type: 'info', text: 'Validando documentos com IA...' })

    try {
      const token = localStorage.getItem('token')
      const response = await fetch('/api/ai/validate-documents', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${token}`
        },
        body: JSON.stringify({
          projectId: project.id
        }),
      })

      const result = await response.json()

      if (result.success) {
        setMessage({ type: 'success', text: 'Documentos validados pela IA com sucesso!' })
        loadProjectAndDocuments()
      } else {
        setMessage({ type: 'error', text: result.error || 'Erro na validação dos documentos' })
      }
    } catch {
      setMessage({ type: 'error', text: 'Erro de conexão' })
    } finally {
      setIsValidating(false)
    }
  }

  const handleRotateDocument = async (docId: number) => {
    setRotatingDocuments(prev => new Set(prev).add(docId))
    setMessage({ type: 'info', text: 'Rotacionando documento...' })

    try {
      const token = localStorage.getItem('token')
      const response = await fetch(`/api/documents/${docId}/rotate`, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({ degrees: 90 })
      })

      const result = await response.json()

      if (result.success) {
        setMessage({ type: 'success', text: 'Documento rotacionado com sucesso!' })
        loadProjectAndDocuments()
      } else {
        setMessage({ type: 'error', text: result.error || 'Erro ao rotacionar documento' })
      }
    } catch (error) {
      console.error('Erro ao rotacionar documento:', error)
      setMessage({ type: 'error', text: 'Erro de conexão ao rotacionar' })
    } finally {
      setRotatingDocuments(prev => {
        const next = new Set(prev)
        next.delete(docId)
        return next
      })
    }
  }

  const handleViewOcrText = (doc: Document) => {
    if (!doc.ocrText) {
      alert('⚠️ Sistema não conseguiu aplicar OCR\n\nO texto não pôde ser extraído deste documento.\nVerifique a qualidade do arquivo ou tente fazer upload novamente com melhor resolução.')
      return
    }

    setSelectedDocumentOcr({
      filename: doc.smartFilename || doc.originalFilename,
      text: doc.ocrText
    })
    setOcrModalOpen(true)
  }

  const formatFileSize = (bytes: number) => {
    if (bytes === 0) return '0 Bytes'
    const k = 1024
    const sizes = ['Bytes', 'KB', 'MB', 'GB']
    const i = Math.floor(Math.log(bytes) / Math.log(k))
    return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i]
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
          <p className="text-gray-600">Carregando...</p>
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
            className="text-blue-600 hover:text-blue-800"
          >
            Voltar ao Dashboard
          </button>
        </div>
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <header className="bg-white shadow-sm border-b border-gray-200">
        <div className="max-w-[1600px] mx-auto px-6 lg:px-8">
          <div className="flex justify-between items-center h-16">
            <div className="flex items-center">
              <button
                onClick={() => router.push(`/projects/${projectId}`)}
                className="mr-4 p-2 text-gray-600 hover:text-gray-900 transition-colors cursor-pointer"
              >
                <ArrowLeft className="w-5 h-5" />
              </button>
              <div>
                <h1 className="text-xl font-semibold text-gray-900">Upload de Documentos</h1>
                <p className="text-sm text-gray-500">{project.name}</p>
              </div>
            </div>
          </div>
        </div>
      </header>

      <div className="max-w-[1600px] mx-auto px-6 lg:px-8 py-8">
        {/* Breadcrumb */}
        <nav className="flex mb-8" aria-label="Breadcrumb">
          <ol className="inline-flex items-center space-x-1 md:space-x-3">
            <li className="inline-flex items-center">
              <button
                onClick={() => router.push('/dashboard')}
                className="text-gray-700 hover:text-blue-600"
              >
                Dashboard
              </button>
            </li>
            <li>
              <div className="flex items-center">
                <span className="text-gray-400 mx-2">/</span>
                <button
                  onClick={() => router.push(`/projects/${projectId}`)}
                  className="text-gray-700 hover:text-blue-600"
                >
                  {project.name}
                </button>
              </div>
            </li>
            <li>
              <div className="flex items-center">
                <span className="text-gray-400 mx-2">/</span>
                <span className="text-gray-500">Upload</span>
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

        <div className="grid grid-cols-1 xl:grid-cols-[580px_1fr] gap-8">
          {/* Upload Section */}
          <div className="bg-white rounded-lg shadow h-fit">
            <div className="px-6 py-4 border-b border-gray-200">
              <h2 className="text-lg font-medium text-gray-900 flex items-center">
                <Upload className="w-5 h-5 mr-2 text-blue-600" />
                Adicionar Novos Documentos
              </h2>
            </div>

            <div className="p-6 space-y-6">
              {/* Drag & Drop Zone */}
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-3">
                  Selecione os arquivos
                </label>

                <div
                  className={`border-2 border-dashed rounded-lg p-8 text-center transition-colors relative ${
                    selectedFiles && selectedFiles.length > 0
                      ? 'border-green-300 bg-green-50'
                      : 'border-gray-300 hover:border-blue-400 hover:bg-blue-50'
                  }`}
                >
                  <Upload className="w-12 h-12 text-gray-400 mx-auto mb-4" />

                  {selectedFiles && selectedFiles.length > 0 ? (
                    <div>
                      <p className="text-green-600 font-medium mb-2">
                        ✅ {selectedFiles.length} arquivo(s) selecionado(s)
                      </p>
                      <div className="text-sm text-gray-600 space-y-1 max-h-40 overflow-y-auto">
                        {Array.from(selectedFiles).map((file, index) => (
                          <div key={index} className="flex items-center justify-center">
                            <FileText className="w-4 h-4 mr-2" />
                            {file.name} ({formatFileSize(file.size)})
                          </div>
                        ))}
                      </div>
                    </div>
                  ) : (
                    <div>
                      <p className="text-gray-600 mb-2">
                        Arraste arquivos aqui ou clique para selecionar
                      </p>
                      <p className="text-xs text-gray-500">
                        RG, CNH, CPF, Comprovantes, Procurações, etc.
                      </p>
                    </div>
                  )}

                  <input
                    ref={fileInputRef}
                    type="file"
                    multiple
                    accept=".pdf,.doc,.docx,.txt,.jpg,.jpeg,.png,.gif"
                    onChange={(e) => {
                      setSelectedFiles(e.target.files)
                      handleFilesSelected(e.target.files)
                    }}
                    className="absolute inset-0 w-full h-full opacity-0 cursor-pointer"
                  />
                </div>

                <p className="text-xs text-gray-500 mt-2">
                  Formatos aceitos: PDF, DOC, DOCX, TXT, JPG, PNG, GIF (máx. 30MB cada)
                </p>
              </div>

              {/* Progress Bars */}
              {isUploading && Object.keys(uploadProgress).length > 0 && (
                <div className="bg-gray-50 rounded-lg p-4">
                  <h4 className="text-sm font-medium text-gray-700 mb-3">Analizando Documentos:</h4>
                  <div className="space-y-2">
                    {Object.entries(uploadProgress).map(([fileKey, progress]) => (
                      <div key={fileKey}>
                        <div className="flex justify-between text-xs text-gray-600 mb-1">
                          <span>Arquivo {parseInt(fileKey.split('_')[1]) + 1}</span>
                          <span>{progress}%</span>
                        </div>
                        <div className="w-full bg-gray-200 rounded-full h-2">
                          <div
                            className="bg-blue-600 h-2 rounded-full transition-all duration-300"
                            style={{ width: `${progress}%` }}
                          />
                        </div>
                      </div>
                    ))}
                  </div>
                </div>
              )}

              {/* AI Info */}
              <div className="bg-purple-50 border border-purple-200 rounded-lg p-4">
                <div className="flex items-start">
                  <Brain className="w-5 h-5 text-amber-700 mr-3 mt-0.5" />
                  <div>
                    <h4 className="text-sm font-medium text-amber-700 mb-1">
                       Análise com Inteligência Artificial
                    </h4>
                    <p className="text-sm text-amber-700">
                      Cada documento será processado automaticamente:
                    </p>
                    <ul className="text-xs text-amber-700 mt-2 space-y-1">
                      <li>• Detecção automática do tipo</li>
                      <li>• Extração de dados (CPF, RG, nomes)</li>
                      <li>• Conversão para PDF</li>
                      <li>• OCR (reconhecimento de texto)</li>
                      <li>• Nomenclatura inteligente</li>
                    </ul>
                  </div>
                </div>
              </div>

              {/* Action Buttons - Agora apenas mostra info, upload via preview modal */}
              <div className="bg-blue-50 border border-blue-200 rounded-lg p-3">
                <div className="flex items-center text-sm text-blue-700">
                  <Eye className="w-4 h-4 mr-2" />
                  <span>
                    {selectedFiles && selectedFiles.length > 0
                      ? `✓ ${selectedFiles.length} arquivo(s) selecionado(s). Ajuste a orientação no preview e confirme para processar.`
                      : 'Selecione arquivos acima para visualizar e ajustar orientação antes do processamento.'
                    }
                  </span>
                </div>
              </div>
            </div>
          </div>

          {/* Documents List */}
          <div className="bg-white rounded-lg shadow">
            <div className="px-4 sm:px-6 py-4 border-b border-gray-200">
              <div className="flex flex-col sm:flex-row sm:justify-between sm:items-center gap-3">
                <div className="flex items-center space-x-3">
                  <h2 className="text-lg font-medium text-gray-900">
                    Documentos ({documents.length})
                  </h2>
                  {documents.length > 0 && (
                    <div className="flex items-center space-x-2">
                      <input
                        type="checkbox"
                        checked={selectedDocuments.length === documents.length && documents.length > 0}
                        onChange={handleSelectAll}
                        className="w-4 h-4 text-blue-600 rounded cursor-pointer"
                        title="Selecionar todos"
                      />
                      {selectedDocuments.length > 0 && (
                        <span className="text-xs sm:text-sm text-gray-600">
                          {selectedDocuments.length} sel.
                        </span>
                      )}
                    </div>
                  )}
                </div>
                <div className="flex items-center gap-2 flex-wrap">
                  {selectedDocuments.length > 0 && (
                    <button
                      onClick={handleDeleteSelected}
                      className="flex items-center space-x-1 px-3 py-1.5 text-sm bg-red-600 text-white rounded-md hover:bg-red-700 transition-colors cursor-pointer"
                    >
                      <Trash2 className="w-3.5 h-3.5" />
                      <span className="hidden sm:inline">Deletar</span>
                    </button>
                  )}
                  {documents.length > 0 && (
                    <button
                      onClick={handleValidateDocuments}
                      disabled={isValidating || !project?.processedNarrative}
                      className="flex items-center space-x-1 px-3 py-1.5 text-sm bg-amber-600 text-white rounded-md hover:bg-amber-700 disabled:opacity-50 disabled:cursor-not-allowed transition-colors cursor-pointer"
                      title={!project?.processedNarrative ? 'Processe a narrativa primeiro' : 'Validar relevância'}
                    >
                      <FileCheck className="w-3.5 h-3.5" />
                      <span className="hidden sm:inline">{isValidating ? 'Validando...' : 'Validar'}</span>
                    </button>
                  )}
                  <button
                    onClick={loadProjectAndDocuments}
                    className="p-1.5 text-gray-600 hover:text-gray-900 transition-colors cursor-pointer"
                    title="Atualizar lista"
                  >
                    <RefreshCw className="w-3.5 h-3.5" />
                  </button>
                </div>
              </div>
            </div>

            <div className="p-6">
              {documents.length > 0 ? (
                <div className="space-y-5">
                  {documents.map((doc) => {
                    const docStatusInfo = getDocumentStatusInfo(doc.status)
                    const DocStatusIcon = docStatusInfo.icon

                    return (
                      <div key={doc.id} className="border border-gray-200 rounded-lg p-5 hover:shadow-md transition-shadow">
                        <div className="flex items-start justify-between gap-4">
                          <div className="flex items-start space-x-4 flex-1">
                            <input
                              type="checkbox"
                              checked={selectedDocuments.includes(doc.id)}
                              onChange={() => handleSelectDocument(doc.id)}
                              className="mt-1 w-4 h-4 text-blue-600 rounded cursor-pointer flex-shrink-0"
                            />

                            <div className="flex-1">
                            <div className="flex items-center space-x-2 mb-2">
                              <span className="bg-blue-100 text-blue-800 text-xs font-medium px-2 py-1 rounded">
                                Doc {doc.documentNumber.toString().padStart(2, '0')}
                              </span>
                              <span className={`inline-flex items-center px-2 py-1 rounded-full text-xs font-medium ${docStatusInfo.color}`}>
                                <DocStatusIcon className="w-3 h-3 mr-1" />
                                {docStatusInfo.label}
                              </span>

                              {doc.detectedDocumentType && (
                                <span className="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium bg-purple-100 text-purple-800">
                                  <Brain className="w-3 h-3 mr-1" />
                                  {doc.detectedDocumentType}
                                </span>
                              )}
                            </div>

                            <h4 className="font-medium text-gray-900 mb-1 break-words">{doc.originalFilename}</h4>

                            {doc.smartFilename && doc.smartFilename !== doc.originalFilename && (
                              <div className="mb-2">
                                <span className="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium bg-green-100 text-green-800 break-words max-w-full">
                                  <Sparkles className="w-3 h-3 mr-1 flex-shrink-0" />
                                  <span className="break-words">{doc.smartFilename.slice(0, 50)}</span>
                                </span>
                              </div>
                            )}

                            <div className="text-sm text-gray-500 space-y-1">
                              <p>Tipo: {doc.hasOcrText}</p>
                              <p>Tamanho: {formatFileSize(doc.originalSizeBytes)}</p>
                              {doc.pageCount && <p>Páginas: {doc.pageCount}</p>}
                            </div>

                            {doc.aiAnalysis && (
                              <div className="mt-2 p-2 bg-blue-50 border border-blue-200 rounded text-xs">
                                <div className="flex items-center">
                                  <Brain className="w-3 h-3 text-blue-600 mr-1" />
                                  <span className="font-medium text-blue-900">Confiança IA: {Math.round((doc.aiAnalysis.confidence || 0) * 100)}%</span>
                                </div>
                              </div>
                            )}

                            {doc.validation && (
                              <div className={`mt-2 p-3 rounded-lg border ${
                                doc.validation.isRelevant
                                  ? 'bg-green-50 border-green-200'
                                  : 'bg-red-50 border-red-200'
                              }`}>
                                <div className="flex items-center mb-2">
                                  <FileCheck className={`w-4 h-4 mr-2 ${
                                    doc.validation.isRelevant ? 'text-amber-700' : 'text-red-600'
                                  }`} />
                                  <span className="text-sm font-medium text-gray-900">Validação IA:</span>
                                  <span className={`ml-2 text-xs px-2 py-1 rounded-full ${
                                    doc.validation.isRelevant
                                      ? 'bg-green-100 text-green-800'
                                      : 'bg-red-100 text-red-800'
                                  }`}>
                                    {doc.validation.isRelevant ? '✓ Relevante' : '✗ Não Relevante'}
                                  </span>
                                  <span className="ml-2 text-xs text-gray-500">
                                    ({Math.round(doc.validation.relevanceScore * 100)}%)
                                  </span>
                                </div>
                                <p className="text-sm text-gray-700">{doc.validation.analysis}</p>
                                {doc.validation.suggestions && (
                                  <div className="mt-2 pt-2 border-t border-gray-200">
                                    <p className="text-xs font-medium text-gray-700">Sugestões:</p>
                                    <p className="text-xs text-gray-600 mt-1">{doc.validation.suggestions}</p>
                                  </div>
                                )}
                              </div>
                            )}
                            </div>
                          </div>

                          <div className="flex items-center gap-2 ml-2">
                            {doc.pdfPath && (
                              <button
                                onClick={() => {
                                  const urlWithTimestamp = `${doc.pdfPath}?t=${doc.updatedAt || Date.now()}`
                                  window.open(urlWithTimestamp, '_blank')
                                }}
                                className="p-2 text-blue-600 hover:bg-blue-50 rounded-lg transition-colors cursor-pointer"
                                title="Visualizar"
                              >
                                
                                <Eye className="w-4 h-4" />
                              </button>
                            )}

                            <button
                              onClick={() => handleViewOcrText(doc)}
                              className="p-2 text-purple-600 hover:bg-purple-50 rounded-lg transition-colors cursor-pointer"
                              title="Ver OCR"
                            >
                              <FileSearch className="w-4 h-4" />
                            </button>

                            <button
                              onClick={() => handleDeleteDocument(doc)}
                              className="p-2 text-red-600 hover:bg-red-50 rounded-lg transition-colors cursor-pointer"
                              title="Excluir"
                            >
                              <Trash2 className="w-4 h-4" />
                            </button>
                          </div>
                        </div>
                      </div>
                    )
                  })}
                </div>
              ) : (
                <div className="text-center py-8">
                  <FileText className="w-12 h-12 text-gray-300 mx-auto mb-4" />
                  <p className="text-gray-500">Nenhum documento processado ainda.</p>
                  <p className="text-sm text-gray-400 mt-2">
                    Use o painel ao lado para fazer upload.
                  </p>
                </div>
              )}
            </div>
          </div>
        </div>

        {/* Action Buttons */}
        <div className="mt-8 flex flex-col sm:flex-row justify-between gap-3">
          <button
            onClick={() => router.push(`/projects/${projectId}`)}
            className="flex items-center justify-center space-x-1 px-4 py-2 text-sm bg-gray-600 text-white rounded-md hover:bg-gray-700 transition-colors cursor-pointer"
          >
            <ArrowLeft className="w-3.5 h-3.5" />
            <span>Voltar</span>
          </button>

          {documents.length > 0 && (
            <button
              onClick={() => router.push(`/projects/${projectId}`)}
              className="flex items-center justify-center space-x-1 px-4 py-2 text-sm bg-amber-600 text-white rounded-md hover:bg-amber-700 transition-colors cursor-pointer"
            >
              <CheckCircle className="w-3.5 h-3.5" />
              <span>Concluir e Exportar</span>
            </button>
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
                  <AlertTriangle className="w-6 h-6 text-red-600" />
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

      {/* Preview Modal com Rotação */}
      {previewModalOpen && previewFiles.length > 0 && (
        <div className="fixed inset-0 bg-black bg-opacity-75 flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-lg shadow-xl max-w-6xl w-full h-[90vh] flex flex-col">
            {/* Modal Header */}
            <div className="px-4 py-3 border-b border-gray-200 flex justify-between items-center flex-shrink-0">
              <div className="flex items-center gap-3">
                <Eye className="w-5 h-5 text-blue-600 flex-shrink-0" />
                <div className="min-w-0">
                  <h3 className="text-base font-semibold text-gray-900">
                    Documento {currentPreviewIndex + 1} de {previewFiles.length}
                  </h3>
                  <p className="text-xs text-gray-500 truncate">
                    {previewFiles[currentPreviewIndex].file.name}
                  </p>
                </div>
              </div>
              <button
                onClick={handleCancelPreview}
                className="p-2 text-gray-400 hover:text-gray-600 transition-colors cursor-pointer flex-shrink-0"
                title="Fechar"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            {/* Modal Body - Preview Area */}
            <div className="flex-1 overflow-hidden flex flex-col items-center justify-center bg-gray-100 p-4 min-h-0">
              <div className="relative w-full h-full flex items-center justify-center" key={previewKey}>
                {previewFiles[currentPreviewIndex].isPDF ? (
                  // Preview de PDF usando iframe
                  <div
                    style={{
                      transform: `rotate(${previewFiles[currentPreviewIndex].rotation}deg)`,
                      transition: 'transform 0.3s ease',
                      width: '100%',
                      maxWidth: '700px',
                      height: '100%',
                      maxHeight: '500px'
                    }}
                    className="shadow-lg bg-white"
                  >
                    <iframe
                      src={`${previewFiles[currentPreviewIndex].preview}#toolbar=0&navpanes=0&scrollbar=0`}
                      className="w-full h-full border-0"
                      title={previewFiles[currentPreviewIndex].file.name}
                    />
                  </div>
                ) : (
                  // Preview de imagem
                  /* eslint-disable-next-line @next/next/no-img-element */
                  <img
                    src={previewFiles[currentPreviewIndex].preview}
                    alt={previewFiles[currentPreviewIndex].file.name}
                    style={{
                      transform: `rotate(${previewFiles[currentPreviewIndex].rotation}deg)`,
                      transition: 'transform 0.3s ease',
                      maxWidth: '100%',
                      maxHeight: '100%',
                      objectFit: 'contain'
                    }}
                    className="shadow-lg"
                  />
                )}
              </div>
            </div>

            {/* Rotation Controls */}
            <div className="px-4 py-3 bg-white border-t border-gray-200 flex justify-center items-center gap-3 flex-shrink-0">
              <button
                onClick={() => handleRotatePreview('left')}
                className="flex items-center gap-2 px-3 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 transition-colors cursor-pointer text-sm"
                title="Rotacionar 90° anti-horário"
              >
                <RotateCcw className="w-4 h-4" />
                <span>Esquerda</span>
              </button>

              <div className="px-3 py-2 bg-gray-100 rounded-md text-sm font-medium text-gray-700">
                {previewFiles[currentPreviewIndex].rotation}°
              </div>

              <button
                onClick={() => handleRotatePreview('right')}
                className="flex items-center gap-2 px-3 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 transition-colors cursor-pointer text-sm"
                title="Rotacionar 90° horário"
              >
                <RotateCw className="w-4 h-4" />
                <span>Direita</span>
              </button>
            </div>

            {/* Modal Footer - Navigation & Actions */}
            <div className="px-4 py-3 bg-gray-50 border-t border-gray-200 flex justify-between items-center flex-shrink-0">
              {/* Navigation */}
              <div className="flex items-center gap-2">
                <button
                  onClick={() => handlePreviewNavigation('prev')}
                  disabled={currentPreviewIndex === 0}
                  className="p-2 text-gray-600 hover:bg-gray-200 rounded-lg transition-colors cursor-pointer disabled:opacity-30 disabled:cursor-not-allowed"
                  title="Documento anterior"
                >
                  <ChevronLeft className="w-5 h-5" />
                </button>

                <span className="text-sm text-gray-600 px-2">
                  {currentPreviewIndex + 1} / {previewFiles.length}
                </span>

                <button
                  onClick={() => handlePreviewNavigation('next')}
                  disabled={currentPreviewIndex === previewFiles.length - 1}
                  className="p-2 text-gray-600 hover:bg-gray-200 rounded-lg transition-colors cursor-pointer disabled:opacity-30 disabled:cursor-not-allowed"
                  title="Próximo documento"
                >
                  <ChevronRight className="w-5 h-5" />
                </button>
              </div>

              {/* Action Buttons */}
              <div className="flex items-center gap-2">
                <button
                  onClick={handleCancelPreview}
                  className="px-4 py-2 text-sm bg-white border border-gray-300 text-gray-700 rounded-md hover:bg-gray-50 transition-colors cursor-pointer"
                >
                  Cancelar
                </button>
                <button
                  onClick={handleConfirmPreviewAndUpload}
                  disabled={isUploading}
                  className="flex items-center gap-2 px-5 py-2 text-sm bg-amber-600 text-white rounded-md hover:bg-amber-700 disabled:opacity-50 transition-colors cursor-pointer"
                >
                  <Brain className="w-4 h-4" />
                  <span>{isUploading ? 'Processando...' : 'Confirmar e Analisar'}</span>
                </button>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* OCR Text Modal */}
      {ocrModalOpen && selectedDocumentOcr && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-lg shadow-xl max-w-4xl w-full max-h-[90vh] flex flex-col">
            {/* Modal Header */}
            <div className="px-6 py-4 border-b border-gray-200 flex justify-between items-center">
              <div className="flex items-center">
                <FileSearch className="w-5 h-5 text-amber-700 mr-2" />
                <h3 className="text-lg font-semibold text-gray-900">Texto Extraído (OCR)</h3>
              </div>
              <button
                onClick={() => setOcrModalOpen(false)}
                className="p-2 text-gray-400 hover:text-gray-600 transition-colors cursor-pointer"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            {/* Modal Body */}
            <div className="px-6 py-4 overflow-y-auto flex-1">
              <div className="mb-4">
                <span className="text-sm font-medium text-gray-700">Arquivo:</span>
                <span className="ml-2 text-sm text-gray-600">{selectedDocumentOcr.filename}</span>
              </div>

              <div className="bg-gray-50 border border-gray-200 rounded-lg p-4">
                <pre className="whitespace-pre-wrap text-sm text-gray-800 font-mono">
                  {selectedDocumentOcr.text}
                </pre>
              </div>
            </div>

            {/* Modal Footer */}
            <div className="px-6 py-4 border-t border-gray-200 flex justify-end gap-2">
              <button
                onClick={() => {
                  try {
                    // Método fallback que funciona em todos os navegadores
                    const textArea = document.createElement('textarea')
                    textArea.value = selectedDocumentOcr.text
                    textArea.style.position = 'fixed'
                    textArea.style.left = '-999999px'
                    textArea.style.top = '-999999px'
                    document.body.appendChild(textArea)
                    textArea.focus()
                    textArea.select()

                    try {
                      const successful = document.execCommand('copy')
                      if (successful) {
                        setMessage({ type: 'success', text: 'Texto copiado para a área de transferência!' })
                      } else {
                        throw new Error('execCommand falhou')
                      }
                    } catch {
                      // Tenta usar o Clipboard API moderno se disponível
                      if (navigator.clipboard && navigator.clipboard.writeText) {
                        navigator.clipboard.writeText(selectedDocumentOcr.text)
                          .then(() => {
                            setMessage({ type: 'success', text: 'Texto copiado para a área de transferência!' })
                          })
                          .catch(() => {
                            setMessage({ type: 'error', text: 'Erro ao copiar. Tente selecionar e copiar manualmente (Ctrl+C).' })
                          })
                      } else {
                        setMessage({ type: 'error', text: 'Erro ao copiar. Tente selecionar e copiar manualmente (Ctrl+C).' })
                      }
                    } finally {
                      document.body.removeChild(textArea)
                    }
                  } catch (error) {
                    console.error('Erro ao copiar:', error)
                    setMessage({ type: 'error', text: 'Erro ao copiar texto. Tente selecionar e copiar manualmente.' })
                  }
                }}
                className="px-3 py-1.5 text-sm bg-purple-600 text-white rounded-md hover:bg-purple-700 transition-colors cursor-pointer"
              >
                Copiar
              </button>
              <button
                onClick={() => setOcrModalOpen(false)}
                className="px-3 py-1.5 text-sm bg-gray-200 text-gray-700 rounded-md hover:bg-gray-300 transition-colors cursor-pointer"
              >
                Fechar
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}