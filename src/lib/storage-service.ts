// Caminho: src/lib/storage-service.ts

import { createClient, SupabaseClient } from '@supabase/supabase-js';
import fs from 'fs';
import path from 'path';
import { v4 as uuidv4 } from 'uuid';

// --- Configuração ---

// 1. Detecta qual ambiente estamos usando
const useSupabase = !!process.env.NEXT_PUBLIC_SUPABASE_URL && !!process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY;
const useLocalStorage = !!process.env.UPLOAD_DIR;

// 2. Define o nome do Bucket (Flavio, ajuste se for diferente)
export const BUCKET_NAME = process.env.SUPABASE_BUCKET_NAME || 'documents';

// 3. Inicializa o Supabase SÓ SE as chaves existirem
let supabase: SupabaseClient | null = null;
if (useSupabase) {
    supabase = createClient(
        process.env.NEXT_PUBLIC_SUPABASE_URL!,
        process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
    );
}

// --- Funções do Serviço ---

/**
 * Faz upload de um arquivo para o storage (Supabase ou Local)
 * @param file Objeto File vindo do FormData
 * @param projectId (Opcional) Para organizar em subpastas
 * @returns { storagePath: string, originalFilename: string }
 */
export async function uploadFile(file: File, storagePath: string): Promise<{ storagePath: string, originalFilename: string }> {
    const originalFilename = file.name;
    
    // Converte o arquivo para Buffer
    const buffer = Buffer.from(await file.arrayBuffer());

    if (useSupabase && supabase) {
        // --- LÓGICA VERCEL (SUPABASE) ---
        const { error } = await supabase.storage
            .from(BUCKET_NAME)
            .upload(storagePath, buffer, {
                contentType: file.type,
            });
        
        if (error) {
            console.error('Erro Supabase Upload:', error);
            throw new Error(`Falha no upload (Supabase): ${error.message}`);
        }

    } else if (useLocalStorage) {
        // --- LÓGICA HETZNER (LOCAL FS) ---
        try {
            const uploadDir = process.env.UPLOAD_DIR!;
            const fullLocalPath = path.join(uploadDir, storagePath);

            // Garante que o diretório (ex: /var/www/uploads/logos/123) exista
            fs.mkdirSync(path.dirname(fullLocalPath), { recursive: true });

            // Escreve o arquivo no disco
            fs.writeFileSync(fullLocalPath, buffer);
        } catch (error: any) {
            console.error('Erro Local Storage Upload:', error);
            throw new Error(`Falha no upload (Local FS): ${error.message}`);
        }
    } else {
        throw new Error('Nenhuma configuração de Storage (Supabase ou Local FS) encontrada.');
    }

    return { storagePath, originalFilename };
}

/**
 * Baixa um arquivo do storage (Supabase ou Local)
 * @param storagePath O caminho salvo no banco (ex: 'project-123/abc-xyz.pdf')
 * @returns Buffer do arquivo
 */
export async function downloadFile(storagePath: string): Promise<Uint8Array> {
    if (useSupabase && supabase) {
        // --- LÓGICA VERCEL (SUPABASE) ---
        const { data, error } = await supabase.storage
            .from(BUCKET_NAME)
            .download(storagePath);
        
        if (error) throw new Error(`Falha no download (Supabase): ${error.message}`);
        return Buffer.from(await data.arrayBuffer());

    } else if (useLocalStorage) {
        // --- LÓGICA HETZNER (LOCAL FS) ---
        const filePath = path.join(process.env.UPLOAD_DIR!, storagePath);
        
        if (!fs.existsSync(filePath)) {
            throw new Error('Arquivo não encontrado no disco (Local FS)');
        }
        return fs.readFileSync(filePath);

    } else {
        throw new Error('Nenhuma configuração de Storage (Supabase ou Local FS) encontrada.');
    }
}

/**
 * Deleta um arquivo do storage (Supabase ou Local)
 * @param storagePath O caminho salvo no banco (ex: 'project-123/abc-xyz.pdf')
 */
export async function deleteFile(storagePath: string): Promise<void> {
    if (useSupabase && supabase) {
        // --- LÓGICA VERCEL (SUPABASE) ---
        const { error } = await supabase.storage
            .from(BUCKET_NAME)
            .remove([storagePath]);
        
        if (error) console.error(`Falha ao deletar (Supabase): ${error.message}`);

    } else if (useLocalStorage) {
        // --- LÓGICA HETZNER (LOCAL FS) ---
        try {
            const filePath = path.join(process.env.UPLOAD_DIR!, storagePath);
            if (fs.existsSync(filePath)) {
                fs.unlinkSync(filePath);
            }
        } catch (error: any) {
            console.error(`Falha ao deletar (Local FS): ${error.message}`);
        }
    } else {
        // Se não houver storage, não faz nada
        return;
    }
}