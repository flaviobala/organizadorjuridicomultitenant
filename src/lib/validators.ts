// src/lib/validators.ts

import { z } from 'zod'
import { MAX_FILE_SIZE } from '@/types'

// ==================== SCHEMAS BÁSICOS ====================

// Schema para email
export const emailSchema = z
  .string()
  .email('Email inválido')
  .min(5, 'Email muito curto')
  .max(100, 'Email muito longo')

// Schema para senha
export const passwordSchema = z
  .string()
  .min(6, 'Senha deve ter pelo menos 6 caracteres')
  .max(100, 'Senha muito longa')

// Schema para nome
export const nameSchema = z
  .string()
  .min(2, 'Nome deve ter pelo menos 2 caracteres')
  .max(100, 'Nome muito longo')
  .regex(/^[a-zA-ZÀ-ÿ\s]+$/, 'Nome deve conter apenas letras e espaços')

// ==================== SCHEMAS DE AUTENTICAÇÃO ====================

export const loginSchema = z.object({
  email: emailSchema,
  password: passwordSchema
})

export const registerSchema = z.object({
  name: nameSchema,
  email: emailSchema,
  password: passwordSchema,
  confirmPassword: passwordSchema
}).refine((data) => data.password === data.confirmPassword, {
  message: "Senhas não coincidem",
  path: ["confirmPassword"]
})

// ==================== SCHEMAS DE PROJETO ====================

export const createProjectSchema = z.object({
  name: z
    .string()
    .min(2, 'Nome do projeto deve ter pelo menos 2 caracteres')
    .max(200, 'Nome muito longo')
    .regex(/^[a-zA-ZÀ-ÿ0-9\s\-_.()]+$/, 'Nome contém caracteres inválidos'),
  
  client: z
    .string()
    .min(2, 'Nome do cliente deve ter pelo menos 2 caracteres')
    .max(200, 'Nome do cliente muito longo')
    .regex(/^[a-zA-ZÀ-ÿ\s\-.()]+$/, 'Nome do cliente contém caracteres inválidos'),
  
  system: z
    .string()
    .min(1, 'Sistema é obrigatório')
    .max(50, 'Nome do sistema muito longo'),
  
  actionType: z
    .string()
    .min(1, 'Tipo de ação é obrigatório')
    .max(100, 'Tipo de ação muito longo'),
  
  narrative: z
    .string()
    .max(5000, 'Narrativa muito longa')
    .optional()
    .or(z.literal(''))
})

export const updateProjectSchema = createProjectSchema.partial().extend({
  status: z.enum(['draft', 'processing', 'completed', 'validated']).optional()
})

// ==================== SCHEMAS DE DOCUMENTO ====================

export const uploadDocumentSchema = z.object({
  projectId: z.coerce.number().int().positive('ID do projeto inválido'),
  documentType: z.string().min(1, 'Tipo de documento é obrigatório'),
  documentNumber: z.coerce.number().int().positive('Número do documento inválido')
})

// Validação de arquivo no cliente
export const fileValidationSchema = z.object({
  name: z.string().min(1, 'Nome do arquivo é obrigatório'),
  size: z.number().max(MAX_FILE_SIZE, `Arquivo muito grande (máx. ${MAX_FILE_SIZE / (1024 * 1024)}MB)`),
  type: z.string().refine((type) => {
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
    return allowedTypes.includes(type)
  }, 'Tipo de arquivo não suportado')
})

// ==================== SCHEMAS DE IA ====================

export const processNarrativeSchema = z.object({
  projectId: z.number().int().positive('ID do projeto inválido'),
  narrative: z
    .string()
    .min(10, 'Narrativa deve ter pelo menos 10 caracteres')
    .max(5000, 'Narrativa muito longa')
})

// ==================== VALIDAÇÕES PERSONALIZADAS ====================

/**
 * Valida múltiplos arquivos
 */
export function validateFiles(files: File[]): { valid: boolean; errors: string[] } {
  const errors: string[] = []
  
  if (files.length === 0) {
    errors.push('Nenhum arquivo selecionado')
    return { valid: false, errors }
  }
  
  if (files.length > 10) {
    errors.push('Máximo de 10 arquivos por upload')
  }
  
  files.forEach((file, index) => {
    const result = fileValidationSchema.safeParse(file)
    if (!result.success) {
      result.error.errors.forEach(error => {
        errors.push(`Arquivo ${index + 1} (${file.name}): ${error.message}`)
      })
    }
  })
  
  return {
    valid: errors.length === 0,
    errors
  }
}

/**
 * Valida token JWT básico (apenas estrutura)
 */
export function validateJWTStructure(token: string): boolean {
  const parts = token.split('.')
  return parts.length === 3 && parts.every(part => part.length > 0)
}

/**
 * Valida extensão de arquivo
 */
export function validateFileExtension(filename: string, allowedExtensions: string[]): boolean {
  const extension = filename.toLowerCase().split('.').pop()
  return extension ? allowedExtensions.includes(extension) : false
}

// ==================== SANITIZAÇÃO ====================

/**
 * Sanitiza string removendo caracteres perigosos
 */
export function sanitizeString(input: string): string {
  return input
    .replace(/[<>]/g, '') // Remove < e >
    .replace(/javascript:/gi, '') // Remove javascript:
    .replace(/on\w+=/gi, '') // Remove event handlers
    .trim()
}

/**
 * Sanitiza nome de arquivo
 */
export function sanitizeFilename(filename: string): string {
  return filename
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '') // Remove acentos
    .replace(/[^a-zA-Z0-9.-]/g, '_') // Substitui caracteres especiais
    .replace(/_+/g, '_') // Remove underscores consecutivos
    .replace(/^_+|_+$/g, '') // Remove underscores das pontas
    .toLowerCase()
    .slice(0, 100) // Limita tamanho
}

// ==================== VALIDAÇÕES DE SEGURANÇA ====================

/**
 * Valida se o usuário pode acessar o projeto
 */
export function validateProjectAccess(projectUserId: number, currentUserId: number): boolean {
  return projectUserId === currentUserId
}

/**
 * Valida headers de segurança
 */
export function validateSecurityHeaders(request: Request): { valid: boolean; errors: string[] } {
  const errors: string[] = []
  
  const contentType = request.headers.get('content-type')
  const authorization = request.headers.get('authorization')
  
  if (request.method === 'POST' && !contentType) {
    errors.push('Content-Type header obrigatório para POST')
  }
  
  if (!authorization || !authorization.startsWith('Bearer ')) {
    errors.push('Token de autorização obrigatório')
  }
  
  return {
    valid: errors.length === 0,
    errors
  }
}

// ==================== TIPOS PARA EXPORT ====================

export type LoginData = z.infer<typeof loginSchema>
export type RegisterData = z.infer<typeof registerSchema>
export type CreateProjectData = z.infer<typeof createProjectSchema>
export type UpdateProjectData = z.infer<typeof updateProjectSchema>
export type UploadDocumentData = z.infer<typeof uploadDocumentSchema>
export type ProcessNarrativeData = z.infer<typeof processNarrativeSchema>