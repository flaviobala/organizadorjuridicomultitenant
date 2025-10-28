'use client'

import { useState, useEffect, useCallback } from 'react'

interface AIAnalysisData {
  confidence?: number
  detectedDocumentType?: string
  documentType?: string
  detectedInfo?: { [key: string]: unknown }
  [key: string]: unknown
}

interface DocumentValidation {
  isRelevant: boolean
  relevanceScore: number
  analysis: string
  suggestions?: string
  status: string
}

export interface Document {
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
}

export interface Project {
  id: number
  name: string
  client: string
  system: string
  processedNarrative?: string
  documents: Document[]
}

export function useProject(projectId: number) {
  const [project, setProject] = useState<Project | null>(null)
  const [isLoading, setIsLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  const loadProject = useCallback(async () => {
    if (isNaN(projectId)) {
      setError('ID do projeto inválido.')
      setIsLoading(false)
      return
    }
    setIsLoading(true)
    try {
      const token = localStorage.getItem('token')
      if (!token) {
        // Idealmente, o router.push estaria em um nível superior (página)
        // ou gerenciado por um contexto de autenticação.
        throw new Error('Usuário não autenticado.')
      }
      const response = await fetch(`/api/projects/${projectId}`, {
        headers: { 'Authorization': `Bearer ${token}` },
      })
      const data = await response.json()
      if (data.success) {
        setProject(data.project)
      } else {
        setError(data.error || 'Projeto não encontrado')
      }
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Erro ao carregar projeto')
    } finally {
      setIsLoading(false)
    }
  }, [projectId])

  useEffect(() => {
    loadProject()
  }, [loadProject])

  return { project, documents: project?.documents ?? [], isLoading, error, reload: loadProject }
}
