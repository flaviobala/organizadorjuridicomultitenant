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

    // ✅ CORRIGIDO: Usar processedNarrative (já processada) ao invés de chamar API novamente
    if (project.processedNarrative) {
      try {
        console.log('📄 Gerando PDF da Narrativa Fática processada...')

        const pdfDoc = await PDFDocument.create();
        const font = await pdfDoc.embedFont(StandardFonts.Helvetica);
        const boldFont = await pdfDoc.embedFont(StandardFonts.HelveticaBold);

        // Adicionar páginas com o texto da narrativa processada
        const maxWidth = 500;
        const margin = 50;
        const lineHeight = 14;
        let page = pdfDoc.addPage([595, 842]); // A4
        let y = 792; // Começar do topo

        // Título
        page.drawText('NARRATIVA FÁTICA', {
          x: margin,
          y: y,
          size: 16,
          font: boldFont,
          color: rgb(0, 0, 0)
        });
        y -= 30;

        // Texto da narrativa processada
        const lines = project.processedNarrative.split('\n');
        for (const line of lines) {
          // Quebrar linhas longas
          const words = line.split(' ');
          let currentLine = '';

          for (const word of words) {
            const testLine = currentLine ? `${currentLine} ${word}` : word;
            const width = font.widthOfTextAtSize(testLine, 11);

            if (width > maxWidth && currentLine) {
              // Desenhar linha atual
              if (y < margin) {
                page = pdfDoc.addPage([595, 842]);
                y = 792;
              }
              page.drawText(currentLine, {
                x: margin,
                y: y,
                size: 11,
                font: font,
                color: rgb(0, 0, 0)
              });
              y -= lineHeight;
              currentLine = word;
            } else {
              currentLine = testLine;
            }
          }

          // Desenhar última linha do parágrafo
          if (currentLine) {
            if (y < margin) {
              page = pdfDoc.addPage([595, 842]);
              y = 792;
            }
            page.drawText(currentLine, {
              x: margin,
              y: y,
              size: 11,
              font: font,
              color: rgb(0, 0, 0)
            });
            y -= lineHeight;
          }

          // Espaço extra entre parágrafos
          y -= 5;
        }

        const pdfBytes = await pdfDoc.save();
        zip.file('01 Narrativa Fática.pdf', pdfBytes);
        console.log('✅ Narrativa Fática adicionada ao ZIP')
      } catch (e) {
        console.error('❌ Falha ao gerar narrativa:', e);
      }
    } else {
      console.warn('⚠️ Projeto não possui narrativa processada')
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

    // ✅ CORRIGIDO: Implementar filtros corretos e rastrear IDs usados
    const usados = new Set<number>();

    // Marcar documentos pessoais como usados
    docsPessoais.forEach(d => usados.add(d.id));

    // Comprovante de Residência
    const comprovanteResidencia = project.documents.find((d: Document) => {
      const tipo = normalizeText((d.documentType || '') + ' ' + (d.detectedDocumentType || ''));
      return tipo.includes('comprovante') && (tipo.includes('residencia') || tipo.includes('endereco'));
    });
    if (comprovanteResidencia?.pdfPath) {
      try {
        const buf = await getPDFBuffer(comprovanteResidencia.pdfPath);
        zip.file('03 Comprovante de Residência.pdf', buf);
        usados.add(comprovanteResidencia.id);
        console.log('✅ Comprovante de Residência adicionado ao ZIP');
      } catch (e) { console.warn('❌ Erro ao adicionar comprovante:', e); }
    }

    // Procuração
    const procuracao = project.documents.find((d: Document) => {
      const tipo = normalizeText((d.documentType || '') + ' ' + (d.detectedDocumentType || ''));
      return tipo.includes('procuracao') || tipo.includes('outorga') || tipo.includes('mandato');
    });
    if (procuracao?.pdfPath) {
      try {
        const buf = await getPDFBuffer(procuracao.pdfPath);
        zip.file('04 Procuração.pdf', buf);
        usados.add(procuracao.id);
        console.log('✅ Procuração adicionada ao ZIP');
      } catch (e) { console.warn('❌ Erro ao adicionar procuração:', e); }
    }

    // Declaração de Hipossuficiência
    const hiposs = project.documents.find((d: Document) => {
      const tipo = normalizeText((d.documentType || '') + ' ' + (d.detectedDocumentType || ''));
      return tipo.includes('hipossuficiencia') || tipo.includes('declaracao');
    });
    if (hiposs?.pdfPath) {
      try {
        const buf = await getPDFBuffer(hiposs.pdfPath);
        zip.file('05 Declaração de Hipossuficiência.pdf', buf);
        usados.add(hiposs.id);
        console.log('✅ Declaração de Hipossuficiência adicionada ao ZIP');
      } catch (e) { console.warn('❌ Erro ao adicionar hipossuficiência:', e); }
    }

    // Contratos
    const contratos = project.documents.filter((d: Document) => {
      const tipo = normalizeText((d.documentType || '') + ' ' + (d.detectedDocumentType || ''));
      return tipo.includes('contrato') || tipo.includes('prestacao') || tipo.includes('servico');
    });

    let nextIdx = 6;
    for (const c of contratos) {
      if (!c.pdfPath) continue;
      try {
        const buf = await getPDFBuffer(c.pdfPath);
        const filename = `${String(nextIdx).padStart(2, '0')} Contrato.pdf`;
        zip.file(filename, buf);
        usados.add(c.id);
        nextIdx++;
        console.log(`✅ ${filename} adicionado ao ZIP`);
      } catch (e) { console.warn('❌ Erro ao adicionar contrato:', e); }
    }

    // ✅ CORRIGIDO: Outros Documentos - processar documentos restantes na ordem correta
    console.log(`📋 Processando outros documentos... Total de documentos: ${project.documents.length}, Já usados: ${usados.size}`);

    for (const doc of project.documents) {
      // Pular documentos já adicionados
      if (usados.has(doc.id)) continue;

      // Pular documentos sem PDF
      if (!doc.pdfPath) {
        console.warn(`⚠️ Documento ${doc.id} sem pdfPath, pulando...`);
        continue;
      }

      try {
        const buf = await getPDFBuffer(doc.pdfPath);

        // ✅ CORRIGIDO: Usar smartFilename ou gerar nome inteligente baseado no tipo detectado
        let nomeBase = '';

        if (doc.smartFilename) {
          // Remover numeração se já existir (ex: "02 Documentos Pessoais.pdf" -> "Documentos Pessoais")
          nomeBase = doc.smartFilename.replace(/^\d+\s+/, '').replace(/\.pdf$/i, '');
        } else if (doc.detectedDocumentType) {
          nomeBase = doc.detectedDocumentType;
        } else if (doc.documentType) {
          // Remover o código numérico do tipo (ex: "07 ASO" -> "ASO")
          nomeBase = doc.documentType.replace(/^\d+\s+/, '');
        } else {
          nomeBase = sanitizeFilename(doc.originalFilename || 'Documento').replace(/\.pdf$/i, '');
        }

        nomeBase = sanitizeFilename(nomeBase) || 'Outros Documentos';

        // ✅ CORRIGIDO: Gerar filename com numeração sequencial correta
        const filename = `${String(nextIdx).padStart(2, '0')} ${nomeBase}.pdf`;
        zip.file(filename, buf);
        usados.add(doc.id);
        nextIdx++;
        console.log(`✅ ${filename} adicionado ao ZIP`);
      } catch (e) {
        console.warn(`❌ Ignorando documento ${doc.id} não recuperável:`, e);
      }
    }

    console.log(`✅ ZIP montado com sucesso! Total de arquivos: ${Object.keys(zip.files).length}`);

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