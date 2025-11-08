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
        // Extrai o caminho do arquivo da URL completa
        const oldStoragePath = organization.logo_url.split('/storage/v1/object/public/')[1];
        await deleteFile(oldStoragePath);
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

    // Monta a URL pública da nova logo
    const publicUrl = `${process.env.NEXT_PUBLIC_SUPABASE_URL}/storage/v1/object/public/${process.env.SUPABASE_BUCKET_NAME}/${storagePath}`;

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