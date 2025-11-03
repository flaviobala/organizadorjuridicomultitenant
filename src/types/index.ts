// src/types/index.ts

// ==================== USUÁRIO ====================
export interface User {
  id: number
  email: string
  name: string
  createdAt: Date
  updatedAt: Date
}

export interface AuthResult {
  success: boolean
  user?: User
  token?: string
  message?: string
}

// ==================== PROJETO ====================
export interface Project {
  id: number
  name: string
  client: string
  system: string
  actionType: string
  narrative?: string
  processedNarrative?: string
  status: ProjectStatus
  createdAt: Date
  updatedAt: Date
  documents: Document[]
}

export type ProjectStatus = 'draft' | 'processing' | 'completed' | 'validated'

export interface CreateProjectData {
  name: string
  client: string
  system: string
  actionType: string
  narrative?: string
}

// ==================== DOCUMENTO ====================
export interface Document {
  id: number
  originalFilename: string
  smartFilename?: string
  documentType: string
  detectedDocumentType?: string
  documentNumber: number
  mimeType: string
  status: DocumentStatus
  pdfPath?: string
  ocrText?: string
  pageCount?: number
  originalSizeBytes: number
  pdfSizeBytes?: number
  isPersonalDocument?: boolean
  aiAnalysis?: DocumentAnalysis
  createdAt: Date
  updatedAt: Date
}

export type DocumentStatus = 'uploaded' | 'converting' | 'converted' | 'ocr_completed' | 'validated' | 'grouped'

// ==================== ANÁLISE IA ====================//

export interface DocumentAnalysis {
  documentType: string
  confidence: number
  detectedInfo: {
    name?: string
    cpf?: string
    rg?: string
    cnh?: string
    organizacaoExpedidora?: string
    ocrExtractedText?: string  // ✅ ADICIONADO
    documentTitle?: string     // ✅ ADICIONADO
    estimatedContent?: string  // ✅ ADICIONADO
    orgao?: string            // ✅ ADICIONADO
    [key: string]: unknown
  }
  suggestedFilename: string
  ocrUsed: boolean
  chatGPTAnalysis?: string    // ✅ ADICIONADO - propriedade que estava faltando
}

export interface NarrativeProcessResult {
  success: boolean
  processedNarrative?: string
  suggestions?: string[]
  tokensUsed?: number
  error?: string
}

// ==================== UPLOAD ====================
export interface UploadResult {
  success: boolean
  document?: Document
  error?: string
}

export interface ProcessingProgress {
  [fileKey: string]: number
}

// ==================== SISTEMA ====================
export interface SystemConfig {
  systemName: string
  maxFileSize: number
  maxPageSize: number
  allowedFormats: string[]
  pdfRequirements: PdfRequirements
}

export interface PdfRequirements {
  maxSizeMB: number
  maxPageSizeKB: number
  resolution: number
  colorMode: 'RGB' | 'CMYK' | 'Grayscale'
  compression: boolean
}

// ==================== API RESPONSES ====================
export interface ApiResponse<T = unknown> {
  success: boolean
  data?: T
  error?: string
  message?: string
}

export interface PaginatedResponse<T> extends ApiResponse<T[]> {
  pagination: {
    page: number
    limit: number
    total: number
    totalPages: number
  }
}

// ==================== MENSAGENS ====================
export interface MessageState {
  type: 'error' | 'success' | 'info' | 'warning'
  text: string
}

// ==================== FORMS ====================
export interface LoginForm {
  email: string
  password: string
}

export interface RegisterForm extends LoginForm {
  name: string
  confirmPassword: string
}

export interface ProjectForm {
  name: string
  client: string
  system: string
  actionType: string
  narrative?: string
}

// ==================== UTILITÁRIOS ====================
export interface FileWithProgress {
  file: File
  progress: number
  status: 'pending' | 'uploading' | 'completed' | 'error'
  result?: UploadResult
}

// ==================== CONSTANTES ====================
export const ALLOWED_FILE_TYPES = [
  'application/pdf',
  'image/jpeg',
  'image/jpg', 
  'image/png',
  'image/gif',
  'text/plain',
  'application/msword',
  'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
] as const

export const MAX_FILE_SIZE = 30 * 1024 * 1024 // 30MB

export const DOCUMENT_CATEGORIES = {
  NARRATIVA: 'narrativa-fatica',
  DOCUMENTOS_PESSOAIS: 'documentos-pessoais', 
  COMPROVANTE_RESIDENCIA: 'comprovante-residencia',
  PROCURACAO: 'procuracao',
  HIPOSSUFICIENCIA: 'declaracao-hipossuficiencia',
  CONTRATO: 'contrato',
  OUTROS: 'outros-documentos'
} as const

export const COMMON_ACTION_TYPES = [
  'Ação de Indenização',
  'Ação Trabalhista', 
  'Ação de Cobrança',
  'Ação de Despejo',
  'Ação Declaratória',
  'Ação Cautelar',
  'Mandado de Segurança',
  'Habeas Corpus',
  'Ação Penal',
  'Ação Civil Pública',
  'Execução',
  'Embargos',
  'Recurso',
  'Flávio',
  'Outro'
] as const