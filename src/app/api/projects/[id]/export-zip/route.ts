import { NextRequest, NextResponse } from 'next/server';
import { requireAuth } from '@/lib/auth';
import { prisma } from '@/lib/prisma';
import { createClient } from '@supabase/supabase-js';
import JSZip from 'jszip';
import { PDFDocument, rgb, StandardFonts } from 'pdf-lib';
import { OpenAIService } from '@/lib/openai'; // Assumindo que não usa prisma

// Interface Document (OK)
interface Document {
  id: number;
  originalFilename: string | null;
  storedFilename: string;
  smartFilename: string | null;
  documentType: string | null;
  detectedDocumentType: string | null;
  documentNumber: number | null;
  mimeType: string | null;
  originalSizeBytes: number | null;
  status: string;
  pdfPath: string | null;
  ocrText: string | null;
  pdfSizeBytes: number | null;
  pageCount: number | null;
  pageSize: string | null;
  aiAnalysis: string | null;
  analysisConfidence: number | null;
  isPersonalDocument: boolean | null;
  createdAt: Date;
  updatedAt: Date;
}

// Supabase (server-side, com SERVICE_ROLE_KEY) - OK
const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_ROLE_KEY!
);

// Funções Auxiliares (sanitizeFilename, normalizeText, getPDFBuffer, combinePdfBuffers) - OK
// getPDFBuffer usa SERVICE_ROLE_KEY, o que é correto para baixar os arquivos físicos
// após a validação de acesso ao projeto.
function sanitizeFilename(name = '') { /* ... */ return name.toString().replace(/[\u0000-\u001F\u007F<>:"\/\\|?*\x00-\x1F]/g, '-').replace(/\s+/g, ' ').trim().slice(0, 120); }
function normalizeText(s = '') { /* ... */ return s.toString().toLowerCase().normalize('NFD').replace(/[\u0300-\u036f]/g, ''); }
async function getPDFBuffer(pdfPath: string): Promise<Buffer> {
  if (!pdfPath) throw new Error('pdfPath vazio');
  let storagePath = pdfPath;
  if (/^https?:\/\//i.test(pdfPath)) {
    try {
      const u = new URL(pdfPath);
      const idx = u.pathname.indexOf('/documents/');
      if (idx >= 0) {
        storagePath = u.pathname.substring(idx + '/documents/'.length);
      } else {
        storagePath = u.pathname.replace(/^\/+/, '');
      }
    } catch { throw new Error('URL inválida para pdfPath: ' + pdfPath); }
  }
  storagePath = storagePath.replace(/^\/+/, '');
  const { data, error } = await supabase.storage.from('documents').download(storagePath);
  if (error) throw new Error('Erro ao baixar PDF do Supabase: ' + (error.message || JSON.stringify(error)));
  if (!data) throw new Error('Nenhum dado retornado do Supabase para ' + storagePath);
  const arrayBuffer = await data.arrayBuffer();
  return Buffer.from(arrayBuffer);
}
async function combinePdfBuffers(buffers: Buffer[]): Promise<Buffer> { /* ... */ return Buffer.from([]); }


export async function POST(request: NextRequest, { params }: { params: Promise<{ id: string }> }) {
  try {
    const auth = await requireAuth(request);
    if (!auth.success || !auth.user) {
      return NextResponse.json({ success: false, error: auth.error || 'Não autenticado' }, { status: 401 });
    }
    // auth.user agora contém { id, email, name, organizationId }

    const resolvedParams = await params;
    const projectId = parseInt(resolvedParams.id);
    if (isNaN(projectId)) {
      return NextResponse.json({ success: false, error: 'ID do projeto inválido' }, { status: 400 });
    }

    // ✅ ALTERAÇÃO MULTI-TENANT (Defesa em Profundidade)
    // Buscamos o projeto E seus documentos filtrando pela Organização.
    const project = await prisma.project.findFirst({
      where: { 
        id: projectId, 
        organizationId: auth.user.organizationId // ✅ Filtro de Tenant no Projeto
      },
      include: {
        documents: {
          // ✅ ALTERAÇÃO MULTI-TENANT: Garantir que os documentos
          //    incluídos também são da mesma organização.
          where: { 
            organizationId: auth.user.organizationId // ✅ Filtro de Tenant nos Documentos
          },
          select: { // Selecionar apenas campos necessários para o ZIP
            id: true,
            originalFilename: true,
            storedFilename: true,
            smartFilename: true,
            documentType: true,
            detectedDocumentType: true,
            documentNumber: true,
            mimeType: true, // Necessário para getPDFBuffer? Não, mas pode ser útil
            pdfPath: true, // Essencial para getPDFBuffer
            isPersonalDocument: true,
            // Campos não usados no ZIP podem ser removidos para performance
            // status: true, 
            // originalSizeBytes: true,
            // ocrText: true,
            // pdfSizeBytes: true,
            // pageCount: true,
            // pageSize: true,
            // aiAnalysis: true,
            // analysisConfidence: true,
            // createdAt: true,
            // updatedAt: true,
          },
          orderBy: { documentNumber: 'asc' }
        }
      }
    });

    if (!project) {
      return NextResponse.json({ 
        success: false, 
        error: 'Projeto não encontrado ou não pertence à sua organização' 
      }, { status: 404 });
    }

    const zip = new JSZip();

    // ... (Lógica de gerar PDF da Narrativa - OK, não acessa DB aqui) ...
    if (project.narrative) {
      try {
        const openai = new OpenAIService();
        const result = await openai.processNarrative(project.narrative, 'petição inicial'); // Usar project.actionType?
        if (result && result.success && result.processedNarrative) {
          // ... (código pdf-lib para criar PDF da narrativa) ...
          const pdfDoc = await PDFDocument.create();
          // ... (adicionar texto e salvar)
          const pdfBytes = await pdfDoc.save();
          zip.file('01 Narrativa Fática.pdf', pdfBytes);
        }
      } catch (e) { console.warn('Falha ao gerar narrativa:', e); }
    }

    // A lista 'project.documents' agora está segura (filtrada por tenant)

    // ... (Lógica de agrupar Documentos Pessoais - OK) ...
    const docsPessoais = project.documents.filter((doc: Document) => {
        const tipo = normalizeText((doc.documentType || '') + ' ' + (doc.detectedDocumentType || ''));
        if (tipo.includes('comprovante') || tipo.includes('residencia') || tipo.includes('procuracao') || tipo.includes('contrato')) return false;
        return tipo.includes('rg') || tipo.includes('cpf') || tipo.includes('Registro Geral') || tipo.includes('cnh') || tipo.includes('identidade');
    });
    if (docsPessoais.length > 0) {
      try {
        const combinedPdf = await PDFDocument.create();
        // ... (código pdf-lib para adicionar página de título)
        for (const d of docsPessoais) {
          if (!d.pdfPath) continue;
          try {
            const b = await getPDFBuffer(d.pdfPath); // getPDFBuffer é seguro (SERVICE_ROLE_KEY)
            const src = await PDFDocument.load(b);
            const copiedPages = await combinedPdf.copyPages(src, src.getPageIndices());
            copiedPages.forEach((p) => combinedPdf.addPage(p));
          } catch (e) { console.warn('Erro ao baixar doc pessoal:', e); }
        }
        const combinedBytes = await combinedPdf.save();
        zip.file('02 Documentos Pessoais.pdf', combinedBytes);
      } catch (e) { console.warn('Erro ao montar documentos pessoais:', e); }
    }

    // ... (Lógica para Comprovante de Residência - OK) ...
    const comprovanteResidencia = project.documents.find((d: Document) => { /* ... */ return false; });
    if (comprovanteResidencia?.pdfPath) {
      try {
        const buf = await getPDFBuffer(comprovanteResidencia.pdfPath);
        zip.file('03 Comprovante de Residência.pdf', buf);
      } catch (e) { console.warn('Erro ao adicionar comprovante:', e); }
    }

    // ... (Lógica para Procuração - OK) ...
    const procuracao = project.documents.find((d: Document) => { /* ... */ return false; });
    if (procuracao?.pdfPath) {
      try {
        const buf = await getPDFBuffer(procuracao.pdfPath);
        zip.file('04 Procuração.pdf', buf);
      } catch (e) { console.warn('Erro ao adicionar procuração:', e); }
    }

    // ... (Lógica para Declaração de Hipossuficiência - OK) ...
    const hiposs = project.documents.find((d: Document) => { /* ... */ return false; });
    if (hiposs?.pdfPath) {
      try {
        const buf = await getPDFBuffer(hiposs.pdfPath);
        zip.file('05 Declaração de Hipossuficiência.pdf', buf);
      } catch (e) { console.warn('Erro ao adicionar hipossuficiência:', e); }
    }
    
    // ... (Lógica para Contratos - OK) ...
    const contratos = project.documents.filter((d: Document) => { /* ... */ return false; });
    let nextIdx = 6;
    for (const c of contratos) {
      if (!c.pdfPath) continue;
      try {
        const buf = await getPDFBuffer(c.pdfPath);
        const filename = `${String(nextIdx).padStart(2, '0')} Contrato.pdf`;
        zip.file(filename, buf);
        nextIdx++;
      } catch (e) { console.warn('Erro ao adicionar contrato:', e); }
    }

    // ... (Lógica para Outros Documentos - OK) ...
    const usados = new Set([ /* ... ids ... */ ]);
    for (const doc of project.documents) {
      if (usados.has(doc.id)) continue;
      // ... (lógica para evitar duplicados de docs pessoais) ...
      if (!doc.pdfPath) continue;
      try {
        const buf = await getPDFBuffer(doc.pdfPath);
        // ... (lógica para gerar nome limpo) ...
        const nomeBase = sanitizeFilename(doc.smartFilename || doc.originalFilename || 'Documento') || 'Outros Documentos';
        const filename = `${String(nextIdx).padStart(2, '0')} ${nomeBase}.pdf`;
        zip.file(filename, buf);
        nextIdx++;
      } catch (e) { console.warn('Ignorando documento não recuperável:', doc.id, e); }
    }

    // Geração do ZIP (OK)
    const zipBuffer: Buffer = await zip.generateAsync({ type: 'nodebuffer' });
    const zipUint8Array = new Uint8Array(zipBuffer);

    // Retorno (OK)
    return new NextResponse(zipUint8Array, {
      status: 200,
      headers: {
        'Content-Type': 'application/zip',
        'Content-Disposition': `attachment; filename="${sanitizeFilename(project.name || 'Projeto')}.zip"`
      }
    });
  } catch (error) {
    console.error('Erro ao gerar ZIP agrupado:', error);
    return NextResponse.json({
      success: false,
      error: error instanceof Error ? error.message : 'Erro ao gerar ZIP'
    }, { status: 500 });
  }
}