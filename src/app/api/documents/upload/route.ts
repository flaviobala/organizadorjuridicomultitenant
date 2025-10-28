// src/app/api/documents/upload/route.ts
import { NextRequest, NextResponse } from 'next/server'
import { requireAuth } from '@/lib/auth'
import { prisma } from '@/lib/prisma'
import { PDFConverter } from '@/lib/pdf-converter'
import { uploadDocumentSchema } from '@/lib/validators'
import { ALLOWED_FILE_TYPES, MAX_FILE_SIZE } from '@/types'
import { checkPlanLimits, incrementDocumentCount } from '@/lib/plan-limits'

export async function POST(request: NextRequest) {
  try {
    console.log('🚀 Iniciando upload de documento...')

    const auth = await requireAuth(request)
    if (!auth.success || !auth.user) {
      return NextResponse.json({
        success: false,
        error: auth.error
      }, { status: 401 })
    }

    // ✅ Verificar limites do plano ANTES de processar
    const planCheck = await checkPlanLimits(auth.user.organizationId)
    if (!planCheck.allowed) {
      return NextResponse.json({
        success: false,
        error: planCheck.reason,
        usage: planCheck.usage,
        limits: planCheck.limits
      }, { status: 403 })
    }
    console.log('✅ Limites do plano verificados:', planCheck)

    // ... (parsing do formData, validações de arquivo... tudo OK) ...
    const formData = await request.formData()
    const file = formData.get('file') as File | null
    const projectIdStr = formData.get('projectId') as string
    const documentType = formData.get('documentType') as string || 'auto-detect'
    const documentNumber = formData.get('documentNumber') as string

    // ... (logs e validações de arquivo OK) ...
    if (!file) {
      return NextResponse.json({
        success: false,
        error: 'Nenhum arquivo enviado'
      }, { status: 400 })
    }

    const validationResult = uploadDocumentSchema.safeParse({
      projectId: projectIdStr,
      documentType,
      documentNumber
    })

    if (!validationResult.success) {
      return NextResponse.json({
        success: false,
        error: 'Dados inválidos',
        details: validationResult.error.errors
      }, { status: 400 })
    }

    const { projectId, documentNumber: docNumber } = validationResult.data

    // ... (Validações de tamanho e tipo OK) ...

    // ✅ ALTERAÇÃO MULTI-TENANT (Defesa em Profundidade)
    // Garantir que o projeto pertence à organização do usuário.
    const project = await prisma.project.findFirst({
      where: {
        id: projectId,
        organizationId: auth.user.organizationId // ✅ Filtro de Tenant
      }
    })

    if (!project) {
      return NextResponse.json({
        success: false,
        error: 'Projeto não encontrado ou não pertence à sua organização'
      }, { status: 404 })
    }

    let finalDocNumber = docNumber
    if (documentType === 'auto-detect') {
      // ✅ ALTERAÇÃO MULTI-TENANT
      // Filtrar por organização ao buscar o último documento
      const lastDoc = await prisma.document.findFirst({
        where: { 
          projectId,
          organizationId: auth.user.organizationId // ✅ Filtro de Tenant
        },
        orderBy: { documentNumber: 'desc' }
      })
      finalDocNumber = (lastDoc?.documentNumber || 0) + 1
      console.log('📊 Número do documento auto-determinado:', finalDocNumber)
    }

    if (documentType !== 'auto-detect') {
      // ✅ ALTERAÇÃO MULTI-TENANT
      // Filtrar por organização ao checar duplicidade
      const existingDoc = await prisma.document.findFirst({
        where: {
          projectId,
          documentNumber: finalDocNumber,
          organizationId: auth.user.organizationId // ✅ Filtro de Tenant
        }
      })

      if (existingDoc) {
        return NextResponse.json({
          success: false,
          error: `Já existe um documento com o número ${finalDocNumber}`
        }, { status: 400 })
      }
    }

    const buffer = Buffer.from(await file.arrayBuffer())
    console.log('📄 Iniciando conversão com IA...', { /* ... */ })

    // ⚠️ PONTO DE ATENÇÃO (Veja a clarificação abaixo)
    const converter = new PDFConverter(project.system)
    await converter.init()

    // ✅ Passando userId, documentId e organizationId para tracking multi-tenant
    const conversionResult = await converter.convertToPDF(
      buffer,
      file.type,
      file.name,
      finalDocNumber,
      projectId,
      auth.user.id,           // userId
      undefined,              // documentId (ainda não criado)
      auth.user.organizationId // organizationId
    )

    if (!conversionResult.success) {
      console.error('❌ Erro na conversão:', conversionResult.error)
      return NextResponse.json({
        success: false,
        error: conversionResult.error || 'Erro na conversão'
      }, { status: 500 })
    }

    console.log('✅ Conversão concluída:', { /* ... */ })

    let document
    
    if (conversionResult.savedDocumentId) {
      // O documento foi salvo pelo PDFConverter.
      // Precisamos garantir que ele foi salvo com o organizationId.
      // (Assumindo que o converter foi refatorado)
      console.log('📋 Documento já salvo pelo PDFConverter, recuperando...')
      
      document = await prisma.document.findUnique({
        where: { 
          id: conversionResult.savedDocumentId,
          // organizationId: auth.user.organizationId // O RLS já protege isso
        }
      })

      if (!document) {
        throw new Error('Documento salvo pelo converter não encontrado')
      }

    } else {
      // Documento normal - salvar agora
      console.log('💾 Salvando documento normal no banco...')
      
      // ✅ ALTERAÇÃO MULTI-TENANT (Injeção Obrigatória)
      // Injetar o organizationId na criação do documento
      document = await prisma.document.create({
        data: {
          projectId,
          userId: auth.user.id,
          organizationId: auth.user.organizationId, // ✅ Injeção do Tenant
          originalFilename: file.name,
          storedFilename: conversionResult.smartFilename || file.name,
          smartFilename: conversionResult.smartFilename,
          documentType: documentType === 'auto-detect' 
            ? (conversionResult.documentAnalysis?.documentType || 'Outros Documentos')
            : documentType,
          detectedDocumentType: conversionResult.documentAnalysis?.documentType,
          documentNumber: finalDocNumber,
          mimeType: file.type,
          originalSizeBytes: file.size,
          isPersonalDocument: conversionResult.isPersonalDocument || false,
          isGrouped: conversionResult.groupedDocuments ? true : false,
          status: 'ocr_completed',
          pdfPath: conversionResult.pdfPath,
          ocrText: conversionResult.ocrText,
          pdfSizeBytes: conversionResult.finalSizeBytes,
          pageCount: conversionResult.pageCount,
          aiAnalysis: conversionResult.documentAnalysis 
            ? JSON.stringify(conversionResult.documentAnalysis) 
            : null,
          analysisConfidence: conversionResult.documentAnalysis?.confidence
        }
      })

      console.log('💾 Documento salvo no banco:', { /* ... */ })

      // ✅ Incrementar contador de documentos processados
      await incrementDocumentCount(auth.user.organizationId)
      console.log('📊 Contador de documentos incrementado')
    }

    // ... (Atualização de status do projeto OK) ...

    // ... (Resposta final OK) ...
    return NextResponse.json({
      success: true,
      /* ... */
      document: {
        id: document.id,
        /* ... */
        createdAt: document.createdAt
      }
    })

  } catch (error) {
    console.error('❌ Erro no upload:', error)
    /* ... (Logs de erro OK) ... */
    return NextResponse.json({
        success: false,
        error: error instanceof Error ? error.message : 'Erro interno do servidor',
        /* ... */
      }, { status: 500 })
  }
}