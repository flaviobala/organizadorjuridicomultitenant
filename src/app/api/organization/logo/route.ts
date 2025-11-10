// src/app/api/organization/logo/route.ts
import { NextResponse } from 'next/server';
import { requireAuth } from '@/lib/auth';
import { prisma } from '@/lib/prisma';
import { uploadFile, deleteFile } from '@/lib/storage-service';
import path from 'path';
import { v4 as uuidv4 } from 'uuid';

export async function POST(req: Request) {
  try {
    const { user } = await requireAuth(req);
    if (!user || !user.organizationId) {
      return NextResponse.json({ error: 'Não autorizado' }, { status: 401 });
    }

    const formData = await req.formData();
    const file = formData.get('logo') as File;

    if (!file) {
      return NextResponse.json({ error: 'Nenhum arquivo de logo enviado' }, { status: 400 });
    }

    const organization = await prisma.organization.findUnique({
      where: { id: user.organizationId },
    });

    if (!organization) {
      return NextResponse.json({ error: 'Organização não encontrada' }, { status: 404 });
    }

    // Se já existir uma logo, deleta a antiga
    if (organization.logo_url) {
      try {
        // Extrai o caminho do arquivo da URL completa (Supabase ou Local)
        let oldStoragePath = ''

        // URL Supabase: https://xxx.supabase.co/storage/v1/object/public/documents/logos/1/file.png
        if (organization.logo_url.includes('/storage/v1/object/public/')) {
          const parts = organization.logo_url.split('/storage/v1/object/public/')
          if (parts.length > 1) {
            oldStoragePath = parts[1].replace(/^[^\/]+\//, '') // Remove bucket name
          }
        }
        // URL Local: http://localhost:3000/uploads/logos/1/file.png
        else if (organization.logo_url.includes('/uploads/')) {
          const parts = organization.logo_url.split('/uploads/')
          if (parts.length > 1) {
            oldStoragePath = parts[1]
          }
        }

        if (oldStoragePath) {
          await deleteFile(oldStoragePath);
        }
      } catch (error) {
        console.error("Erro ao deletar a logo antiga:", error);
        // Continua mesmo se a deleção falhar para não bloquear o upload da nova
      }
    }

    const fileExtension = path.extname(file.name);
    const uniqueFilename = `${uuidv4()}${fileExtension}`;
    const storagePath = `logos/${organization.id}/${uniqueFilename}`;

    // Faz o upload do novo arquivo
    await uploadFile(file, storagePath);

    // Monta a URL pública da nova logo (Local ou Supabase)
    let publicUrl: string

    if (process.env.UPLOAD_DIR && process.env.NEXT_PUBLIC_UPLOAD_URL) {
      // Storage Local
      publicUrl = `${process.env.NEXT_PUBLIC_UPLOAD_URL}/${storagePath}`;
    } else if (process.env.NEXT_PUBLIC_SUPABASE_URL && process.env.SUPABASE_BUCKET_NAME) {
      // Storage Supabase (fallback)
      publicUrl = `${process.env.NEXT_PUBLIC_SUPABASE_URL}/storage/v1/object/public/${process.env.SUPABASE_BUCKET_NAME}/${storagePath}`;
    } else {
      throw new Error('Configuração de storage não encontrada (nem UPLOAD_DIR nem SUPABASE)');
    }

    // Atualiza o campo no banco de dados
    const updatedOrganization = await prisma.organization.update({
      where: { id: organization.id },
      data: { logo_url: publicUrl },
    });

    return NextResponse.json({ logo_url: updatedOrganization.logo_url });
  } catch (error) {
    console.error('Erro no upload da logo:', error);
    return NextResponse.json({ error: 'Erro interno do servidor' }, { status: 500 });
  }
}