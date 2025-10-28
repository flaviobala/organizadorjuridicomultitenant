// src/lib/utils.ts

import type { DocumentStatus, ProjectStatus, MessageState } from '@/types'

// ==================== FORMATAÇÃO ====================

/**
 * Formata tamanho de arquivo em bytes para formato legível
 */
export function formatFileSize(bytes: number): string {
  if (bytes === 0) return '0 B'
  
  const k = 1024
  const sizes = ['B', 'KB', 'MB', 'GB']
  const i = Math.floor(Math.log(bytes) / Math.log(k))
  
  return `${parseFloat((bytes / Math.pow(k, i)).toFixed(2))} ${sizes[i]}`
}

/**
 * Sanitiza nome de arquivo removendo caracteres especiais
 */
export function sanitizeFilename(filename: string): string {
  return filename
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '') // Remove acentos
    .replace(/[^a-zA-Z0-9.-]/g, '_') // Substitui caracteres especiais por _
    .replace(/_+/g, '_') // Remove underscores consecutivos
    .replace(/^_+|_+$/g, '') // Remove underscores do início/fim
    .toLowerCase()
    .slice(0, 100) // Limita tamanho
}

/**
 * Formata data para exibição no formato brasileiro
 */
export function formatDate(date: Date | string): string {
  const d = new Date(date)
  return d.toLocaleDateString('pt-BR', {
    day: '2-digit',
    month: '2-digit', 
    year: 'numeric'
  })
}

/**
 * Formata data e hora completa
 */
export function formatDateTime(date: Date | string): string {
  const d = new Date(date)
  return d.toLocaleString('pt-BR', {
    day: '2-digit',
    month: '2-digit',
    year: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  })
}

// ==================== VALIDAÇÕES ====================

/**
 * Valida se arquivo é de tipo permitido
 */
export function isValidFileType(mimeType: string): boolean {
  const allowedTypes = [
    'application/pdf',
    'image/jpeg',
    'image/jpg',
    'image/png', 
    'image/gif',
    'text/plain',
    'application/msword',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
  ]
  
  return allowedTypes.includes(mimeType)
}

/**
 * Valida tamanho do arquivo
 */
export function isValidFileSize(sizeBytes: number, maxSizeMB = 30): boolean {
  const maxBytes = maxSizeMB * 1024 * 1024
  return sizeBytes <= maxBytes
}

/**
 * Valida email básico
 */
export function isValidEmail(email: string): boolean {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
  return emailRegex.test(email)
}

// ==================== STATUS E LABELS ====================

/**
 * Retorna informações de exibição para status do projeto
 */
export function getProjectStatusInfo(status: ProjectStatus) {
  const statusMap = {
    draft: { 
      label: 'Rascunho', 
      color: 'text-gray-600 bg-gray-100',
      description: 'Projeto em elaboração'
    },
    processing: { 
      label: 'Processando', 
      color: 'text-blue-600 bg-blue-100',
      description: 'IA processando documentos'
    },
    completed: { 
      label: 'Concluído', 
      color: 'text-green-600 bg-green-100',
      description: 'Pronto para revisão'
    },
    validated: { 
      label: 'Validado', 
      color: 'text-purple-600 bg-purple-100',
      description: 'Revisado e aprovado'
    }
  }
  
  return statusMap[status] || statusMap.draft
}

/**
 * Retorna informações de exibição para status do documento
 */
export function getDocumentStatusInfo(status: DocumentStatus) {
  const statusMap = {
    uploaded: {
      label: 'Enviado',
      color: 'text-blue-600 bg-blue-100',
      description: 'Upload concluído'
    },
    converting: {
      label: 'Convertendo', 
      color: 'text-yellow-600 bg-yellow-100',
      description: 'Processando arquivo'
    },
    converted: {
      label: 'Convertido',
      color: 'text-green-600 bg-green-100', 
      description: 'PDF gerado'
    },
    ocr_completed: {
      label: 'OCR Concluído',
      color: 'text-purple-600 bg-purple-100',
      description: 'Texto extraído'
    },
    validated: {
      label: 'Validado',
      color: 'text-emerald-600 bg-emerald-100',
      description: 'Analisado pela IA'
    },
    grouped: {
      label: 'Agrupado',
      color: 'text-indigo-600 bg-indigo-100', 
      description: 'Incluído em grupo'
    }
  }
  
  return statusMap[status] || statusMap.uploaded
}

// ==================== EXTRAÇÃO DE DADOS ====================

/**
 * Extrai CPF de texto usando regex
 */
export function extractCPF(text: string): string | null {
  const cpfMatch = text.match(/(?:CPF[:\s]*)?(\d{3}\.?\d{3}\.?\d{3}-?\d{2})/i)
  return cpfMatch ? cpfMatch[1].replace(/\D/g, '').replace(/(\d{3})(\d{3})(\d{3})(\d{2})/, '$1.$2.$3-$4') : null
}

/**
 * Extrai RG de texto usando regex
 */
export function extractRG(text: string): string | null {
  const rgMatch = text.match(/(?:RG[:\s]*)?(\d{1,2}\.?\d{3}\.?\d{3}-?\d{1})/i)
  return rgMatch ? rgMatch[1] : null
}

// ==================== HELPERS DE UI ====================

/**
 * Cria mensagem de estado para exibição
 */
export function createMessage(type: MessageState['type'], text: string): MessageState {
  return { type, text }
}

/**
 * Gera cor de texto baseada no hash da string
 */
export function generateTextColor(str: string): string {
  let hash = 0
  for (let i = 0; i < str.length; i++) {
    hash = str.charCodeAt(i) + ((hash << 5) - hash)
  }
  
  const colors = [
    'text-blue-600',
    'text-green-600', 
    'text-purple-600',
    'text-indigo-600',
    'text-pink-600',
    'text-red-600'
  ]
  
  return colors[Math.abs(hash) % colors.length]
}

// ==================== TIMEOUTS E DELAYS ====================

/**
 * Cria delay assíncrono
 */
export function sleep(ms: number): Promise<void> {
  return new Promise(resolve => setTimeout(resolve, ms))
}

// ==================== URL HELPERS ====================

/**
 * Extrai path do Supabase Storage de uma URL completa
 */
export function extractStoragePath(url: string): string | null {
  try {
    const urlObj = new URL(url)
    const pathParts = urlObj.pathname.split('/')
    const documentsIndex = pathParts.indexOf('documents')
    
    if (documentsIndex !== -1 && documentsIndex < pathParts.length - 1) {
      return pathParts.slice(documentsIndex + 1).join('/')
    }
    
    return null
  } catch {
    return null
  }
}

// ==================== CLASSIFICAÇÃO DE DOCUMENTOS ====================

/**
 * Identifica se documento é pessoal (RG, CPF, CNH)
 */
export function isPersonalDocument(documentType: string, detectedType?: string): boolean {
  const personalKeywords = ['rg', 'cpf', 'cnh', 'identidade', 'registro geral', 'habilitacao']
  const fullText = `${documentType} ${detectedType || ''}`.toLowerCase()
  
  return personalKeywords.some(keyword => fullText.includes(keyword))
}

/**
 * Determina categoria do documento baseado no tipo
 */
export function getDocumentCategory(documentType: string, detectedType?: string): string {
  const type = `${documentType} ${detectedType || ''}`.toLowerCase()
  
  if (type.includes('narrativa') || type.includes('relato')) {
    return 'narrativa-fatica'
  }
  
  if (type.includes('rg') || type.includes('identidade')) {
    return 'documentos-pessoais'
  }
  
  if (type.includes('cpf')) {
    return 'documentos-pessoais' 
  }
  
  if (type.includes('cnh') || type.includes('habilitacao')) {
    return 'documentos-pessoais'
  }
  
  if (type.includes('comprovante') || type.includes('residencia')) {
    return 'comprovante-residencia'
  }
  
  if (type.includes('procuracao')) {
    return 'procuracao'
  }
  
  if (type.includes('hipossuficiencia')) {
    return 'declaracao-hipossuficiencia'
  }
  
  if (type.includes('contrato')) {
    return 'contrato'
  }
  
  return 'outros-documentos'
}