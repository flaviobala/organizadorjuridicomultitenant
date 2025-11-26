/**
 * Sistemas jurídicos padrão - visíveis para todas as organizações
 * Cada organização pode adicionar seus próprios sistemas além destes
 */

export interface DefaultSystem {
  id: string // ID negativo para diferenciar dos sistemas do banco
  systemName: string
  maxFileSize: number // em bytes
  maxPageSize: number // em bytes
  allowedFormats: string
  pdfRequirements: string
  isDefault: true // Flag para identificar sistemas padrão
}

export const DEFAULT_SYSTEMS: DefaultSystem[] = [
  {
    id: 'default-esaj',
    systemName: 'e-SAJ',
    maxFileSize: 31457280, // 30MB
    maxPageSize: 31457280, // 30MB
    allowedFormats: 'pdf,jpg,jpeg,png',
    pdfRequirements: 'PDF/A compatível com e-SAJ. Máximo 30MB por arquivo.',
    isDefault: true
  },
  {
    id: 'default-pje',
    systemName: 'PJe',
    maxFileSize: 5242880, // 5MB
    maxPageSize: 5242880, // 5MB
    allowedFormats: 'pdf',
    pdfRequirements: 'PDF/A compatível com PJe. Máximo 5MB por arquivo.',
    isDefault: true
  },
  {
    id: 'default-trt19',
    systemName: 'TRT19',
    maxFileSize: 10485760, // 10MB
    maxPageSize: 10485760, // 10MB
    allowedFormats: 'pdf,doc,docx',
    pdfRequirements: 'Documentos para TRT19. Máximo 10MB por arquivo.',
    isDefault: true
  },
  {
    id: 'default-tre',
    systemName: 'TRE',
    maxFileSize: 10485760, // 10MB
    maxPageSize: 10485760, // 10MB
    allowedFormats: 'pdf',
    pdfRequirements: 'PDF para Tribunal Regional Eleitoral. Máximo 10MB por arquivo.',
    isDefault: true
  }
]

/**
 * Helper para converter bytes em formato legível
 */
export function formatBytes(bytes: number): string {
  if (bytes === 0) return '0 Bytes'
  const k = 1024
  const sizes = ['Bytes', 'KB', 'MB', 'GB']
  const i = Math.floor(Math.log(bytes) / Math.log(k))
  return Math.round(bytes / Math.pow(k, i)) + ' ' + sizes[i]
}