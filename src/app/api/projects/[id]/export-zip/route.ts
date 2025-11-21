import { NextRequest, NextResponse } from 'next/server';
import { requireAuth } from '@/lib/auth';
import { prisma } from '@/lib/prisma';
import { downloadFile } from '@/lib/storage-service';
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

// Funções Auxiliares
function sanitizeFilename(name = '') {
  return name.toString().replace(/[\u0000-\u001F\u007F<>:"\/\\|?*\x00-\x1F]/g, '-').replace(/\s+/g, ' ').trim().slice(0, 120);
}
function normalizeText(s = '') {
  return s.toString().toLowerCase().normalize('NFD').replace(/[\u0300-\u036f]/g, '');
}

/**
 * Normaliza tipo de documento para agrupamento
 */
function normalizeDocumentType(documentType: string): string {
  if (!documentType) return ''
  return documentType
    .toLowerCase()
    .normalize('NFD').replace(/[\u0300-\u036f]/g, '')
    .replace(/^\d+\s*/, '')
    .replace(/\b(de|da|do|dos|das)\b/g, '')
    .replace(/\b(individual|pessoal|completo|geral)\b/g, '')
    .replace(/[^\w\s]/g, '')
    .replace(/\s+/g, ' ')
    .trim()
}

/**
 * Verifica se dois tipos de documento são similares
 */
function areDocumentTypesSimilar(type1: string, type2: string): boolean {
  const normalized1 = normalizeDocumentType(type1)
  const normalized2 = normalizeDocumentType(type2)
  if (normalized1 === normalized2) return true
  const words1 = normalized1.split(' ').filter(w => w.length > 3)
  const words2 = normalized2.split(' ').filter(w => w.length > 3)
  const commonWords = words1.filter(w => words2.includes(w))
  return commonWords.length > 0 && words1[0] === words2[0]
}

/**
 * Baixa um PDF do storage (local ou Supabase)
 * Extrai o caminho correto de URLs Supabase ou locais
 */
async function getPDFBuffer(pdfPath: string): Promise<Buffer> {
  if (!pdfPath) throw new Error('pdfPath vazio');
  let storagePath = pdfPath;

  // Se for URL, extrair o caminho do storage
  if (/^https?:\/\//i.test(pdfPath)) {
    try {
      const u = new URL(pdfPath);

      // Tentar extrair de URL Supabase
      const supabaseIdx = u.pathname.indexOf('/documents/');
      if (supabaseIdx >= 0) {
        storagePath = u.pathname.substring(supabaseIdx + '/documents/'.length);
      } else {
        // Tentar extrair de URL local
        const uploadsIdx = u.pathname.indexOf('/uploads/');
        if (uploadsIdx >= 0) {
          storagePath = u.pathname.substring(uploadsIdx + '/uploads/'.length);
        } else {
          // ✅ CORREÇÃO: Pegar apenas a última parte do path (ex: /payment-success/processed/file.pdf → processed/file.pdf)
          // Assumir que o caminho real começa com 'processed/' ou similar
          const pathParts = u.pathname.split('/').filter(p => p.length > 0);

          // Se tiver pelo menos 2 partes (ex: ['payment-success', 'processed', 'file.pdf'])
          // Pegar as últimas 2 partes (processed/file.pdf)
          if (pathParts.length >= 2) {
            storagePath = pathParts.slice(-2).join('/');
          } else {
            storagePath = u.pathname.replace(/^\/+/, '');
          }
        }
      }
    } catch {
      throw new Error('URL inválida para pdfPath: ' + pdfPath);
    }
  }

  storagePath = storagePath.replace(/^\/+/, '');

  // Usar storage-service para baixar
  try {
    const data = await downloadFile(storagePath);
    return Buffer.from(data);
  } catch (error) {
    throw new Error('Erro ao baixar PDF: ' + (error instanceof Error ? error.message : 'Erro desconhecido'));
  }
}

async function combinePdfBuffers(buffers: Buffer[]): Promise<Buffer> {
  return Buffer.from([]);
}


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

    // ✅ NOVO: Agrupar documentos restantes por tipo similar
    console.log(`📋 Processando outros documentos... Total de documentos: ${project.documents.length}, Já usados: ${usados.size}`);

    // Filtrar documentos restantes (não usados)
    const documentosRestantes = project.documents.filter((d: any) => !usados.has(d.id) && d.pdfPath);

    // Agrupar por tipo similar
    const grupos = new Map<string, typeof documentosRestantes>();
    for (const doc of documentosRestantes) {
      const docType = doc.detectedDocumentType || doc.documentType || 'Outros Documentos';
      let foundGroup = false;

      // Procurar grupo similar existente
      for (const [groupKey, groupDocs] of grupos.entries()) {
        if (areDocumentTypesSimilar(groupKey, docType)) {
          groupDocs.push(doc);
          foundGroup = true;
          break;
        }
      }

      // Criar novo grupo se não encontrou similar
      if (!foundGroup) {
        grupos.set(docType, [doc]);
      }
    }

    console.log(`🔗 ${grupos.size} grupos de documentos identificados`);

    // Processar cada grupo
    for (const [tipoGrupo, docs] of grupos.entries()) {
      try {
        // Extrair nome base limpo
        let nomeBase = tipoGrupo.replace(/^\d+\s+/, '').replace(/\.pdf$/i, '') || 'Outros Documentos';
        nomeBase = sanitizeFilename(nomeBase);

        // Se houver 2+ documentos do mesmo tipo, agrupar
        if (docs.length >= 2) {
          console.log(`📦 Agrupando "${nomeBase}" (${docs.length} documentos):`);

          try {
            // Combinar PDFs usando pdf-lib
            const mergedPdf = await PDFDocument.create();

            for (const doc of docs) {
              try {
                const buf = await getPDFBuffer(doc.pdfPath!);
                const pdf = await PDFDocument.load(buf);
                const pages = await mergedPdf.copyPages(pdf, pdf.getPageIndices());
                pages.forEach(page => mergedPdf.addPage(page));
                usados.add(doc.id);
                console.log(`   ✅ ${doc.smartFilename || doc.storedFilename}`);
              } catch (e) {
                console.warn(`   ⚠️ Erro ao processar ${doc.storedFilename}:`, e);
              }
            }

            const mergedBytes = await mergedPdf.save();
            const filename = `${String(nextIdx).padStart(2, '0')} ${nomeBase}.pdf`;
            zip.file(filename, mergedBytes);
            nextIdx++;
            console.log(`   ✅ Arquivo agrupado criado: ${filename} (${docs.length} páginas)`);

          } catch (e) {
            console.error(`   ❌ Erro ao agrupar "${nomeBase}":`, e);
            // Se falhar agrupamento, adicionar individualmente
            for (const doc of docs) {
              try {
                const buf = await getPDFBuffer(doc.pdfPath!);
                const filename = `${String(nextIdx).padStart(2, '0')} ${nomeBase}.pdf`;
                zip.file(filename, buf);
                usados.add(doc.id);
                nextIdx++;
                console.log(`✅ ${filename} adicionado individualmente`);
              } catch (e2) {
                console.warn(`❌ Erro ao adicionar ${doc.storedFilename}:`, e2);
              }
            }
          }

        } else {
          // Documento único - adicionar individualmente
          const doc = docs[0];
          try {
            const buf = await getPDFBuffer(doc.pdfPath!);
            const filename = `${String(nextIdx).padStart(2, '0')} ${nomeBase}.pdf`;
            zip.file(filename, buf);
            usados.add(doc.id);
            nextIdx++;
            console.log(`✅ ${filename} adicionado ao ZIP`);
          } catch (e) {
            console.warn(`❌ Erro ao adicionar ${doc.storedFilename}:`, e);
          }
        }
      } catch (e) {
        console.error(`❌ Erro ao processar grupo "${tipoGrupo}":`, e);
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