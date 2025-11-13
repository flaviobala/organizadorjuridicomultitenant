# 🖼️ Guia de Migração e Troubleshooting - Logos

## ✅ Status da Migração

O código foi atualizado para suportar **storage local** para logos. O sistema agora funciona assim:

### Como funciona:

1. **Upload de Logo**: `/api/organization/logo` (POST)
   - Salva no diretório: `uploads/logos/{organizationId}/{uuid}.{ext}`
   - Gera URL pública: `http://localhost:3000/uploads/logos/{organizationId}/{uuid}.{ext}`
   - Salva URL no banco: `Organization.logo_url`

2. **Servir Logo**: `/uploads/[...path]` (GET)
   - Lê arquivo de: `C:/Barros-Alves/organizadormulti-tenant/uploads/`
   - Retorna com Content-Type correto

3. **Exibir Logo**: Componentes React usam `logo_url` diretamente

---

## 🔧 Problemas Comuns e Soluções

### 1. ❌ Logo não aparece após upload

**Sintomas:**
- Upload funciona sem erro
- Mas a imagem não aparece na tela

**Causas possíveis:**

#### A) Diretório de uploads não existe
```bash
# Verificar se existe:
dir "C:\Barros-Alves\organizadormulti-tenant\uploads"

# Se não existir, criar:
mkdir "C:\Barros-Alves\organizadormulti-tenant\uploads\logos"
```

#### B) Variáveis de ambiente não configuradas
Verifique no `.env`:
```env
UPLOAD_DIR="C:/Barros-Alves/organizadormulti-tenant/uploads"
NEXT_PUBLIC_UPLOAD_URL="http://localhost:3000/uploads"
```

**Importante:** Use `/` (forward slash) mesmo no Windows!

#### C) Servidor não foi reiniciado
```bash
# Pare o servidor (Ctrl+C) e inicie novamente:
npm run dev
```

---

### 2. ❌ Erro "UPLOAD_DIR não configurado"

**Solução:**
Edite o arquivo `.env` e adicione:
```env
UPLOAD_DIR="C:/Barros-Alves/organizadormulti-tenant/uploads"
NEXT_PUBLIC_UPLOAD_URL="http://localhost:3000/uploads"
```

Reinicie o servidor.

---

### 3. ❌ Logo antiga do Supabase não aparece mais

**Causa:** URLs antigas no banco de dados ainda apontam para o Supabase.

**Exemplo de URL antiga:**
```
https://yrzlxuefbxbpfndcpfqz.supabase.co/storage/v1/object/public/documents/logos/1/abc-123.png
```

**Soluções:**

#### Opção A: Fazer novo upload
Simplesmente faça upload da logo novamente pelo dashboard.

#### Opção B: Migrar URLs manualmente (SQL)
Execute este script SQL no seu PostgreSQL:

```sql
-- Ver organizações com logos do Supabase:
SELECT id, name, logo_url
FROM "Organization"
WHERE logo_url LIKE '%supabase%';

-- Remover logos antigas (forçar re-upload):
UPDATE "Organization"
SET logo_url = NULL
WHERE logo_url LIKE '%supabase%';
```

#### Opção C: Baixar logos do Supabase
Se você tem arquivos no Supabase que quer manter:

1. Acesse o Supabase Dashboard
2. Vá em Storage → documents → logos
3. Baixe as imagens manualmente
4. Faça upload novamente pelo sistema

---

### 4. ❌ Erro 404 ao acessar logo

**Sintomas:**
```
GET http://localhost:3000/uploads/logos/1/abc-123.png -> 404 Not Found
```

**Causas:**

#### A) Arquivo não existe fisicamente
```bash
# Verificar se arquivo existe:
dir "C:\Barros-Alves\organizadormulti-tenant\uploads\logos\1\"

# Se não existir, fazer upload novamente
```

#### B) Caminho errado no banco
```sql
-- Verificar URLs no banco:
SELECT id, name, logo_url FROM "Organization" WHERE logo_url IS NOT NULL;
```

Se a URL estiver errada, atualize:
```sql
UPDATE "Organization"
SET logo_url = 'http://localhost:3000/uploads/logos/1/novo-nome.png'
WHERE id = 1;
```

---

### 5. ❌ Imagem não carrega no navegador (erro CORS)

**Causa:** Problema de CORS (raramente acontece com storage local).

**Solução:**
O Next.js já está configurado para servir arquivos corretamente via `/uploads/[...path]`.

Se mesmo assim tiver erro, verifique o console do navegador (F12).

---

## 📂 Estrutura de Diretórios Esperada

```
organizadormulti-tenant/
├── uploads/                          # Diretório raiz de uploads
│   ├── logos/                        # Logos das organizações
│   │   ├── 1/                        # Organization ID 1
│   │   │   └── abc-123.png
│   │   ├── 2/                        # Organization ID 2
│   │   │   └── def-456.jpg
│   │   └── ...
│   ├── original/                     # Arquivos originais de documentos
│   └── processed/                    # PDFs processados
├── src/
│   └── app/
│       └── uploads/
│           └── [...path]/
│               └── route.ts          # Rota que serve os arquivos
└── .env                              # Configurações
```

---

## 🧪 Como Testar se está Funcionando

### 1. Teste de Upload
1. Acesse: `http://localhost:3000/organization-dashboard`
2. Clique em "Trocar Imagem"
3. Selecione uma imagem PNG/JPG (máx 2MB)
4. Clique em "Salvar"
5. Aguarde a mensagem "✅ Logo atualizado com sucesso!"

### 2. Verificar arquivo no disco
```bash
# Listar arquivos salvos:
dir "C:\Barros-Alves\organizadormulti-tenant\uploads\logos" /s
```

### 3. Verificar URL no banco
```sql
-- Conectar ao PostgreSQL:
psql -U postgres -d organizador_juridico

-- Ver logo salva:
SELECT id, name, logo_url FROM "Organization";
```

Deve retornar algo como:
```
 id |     name      |                          logo_url
----+---------------+------------------------------------------------------------
  1 | Minha Empresa | http://localhost:3000/uploads/logos/1/abc-123-def.png
```

### 4. Testar acesso direto
Copie a URL do banco e cole no navegador:
```
http://localhost:3000/uploads/logos/1/abc-123-def.png
```

Deve exibir a imagem.

---

## 🚨 Problemas Críticos

### Logo do sistema (`/logo.png`) não aparece

O logo do sistema é diferente do logo da organização:

```tsx
// Logo do sistema (navbar):
<Image src="/logo.png" alt="Logo" width={40} height={40} />
```

Este arquivo deve estar em:
```
organizadormulti-tenant/
└── public/
    └── logo.png       # Logo fixo do sistema
```

**Solução:**
Coloque um arquivo `logo.png` na pasta `public/`.

---

## 📊 Logs Úteis para Debug

### Ver logs do upload:
No console do navegador (F12 → Console), procure por:
```
📤 Salvando PDF: ...
✅ Logo atualizado com sucesso!
```

### Ver logs do servidor:
No terminal onde roda `npm run dev`, procure por:
```
📁 Caminho extraído...
✅ Arquivo excluído do storage: logos/...
```

### Habilitar mais logs (se precisar):
Edite `src/app/api/organization/logo/route.ts` e adicione:
```typescript
console.log('📥 Upload recebido:', file.name, file.size)
console.log('📂 Storage path:', storagePath)
console.log('🌐 Public URL:', publicUrl)
```

---

## 🔄 Migração de Dados do Supabase

Se você tinha logos no Supabase e quer migrá-las:

### Script SQL para limpar URLs antigas:
```sql
-- Backup antes de executar!
-- Cria tabela de backup:
CREATE TABLE "Organization_backup" AS SELECT * FROM "Organization";

-- Remove URLs do Supabase (forçar re-upload):
UPDATE "Organization"
SET logo_url = NULL
WHERE logo_url LIKE '%supabase%';

-- Verificar resultado:
SELECT id, name, logo_url FROM "Organization";
```

### Baixar logos do Supabase manualmente:
1. Acesse: https://supabase.com/dashboard/project/yrzlxuefbxbpfndcpfqz/storage/buckets/documents
2. Navegue até: `logos/`
3. Baixe cada imagem
4. Faça upload novamente pelo sistema local

---

## ✅ Checklist Final

Antes de usar o sistema, verifique:

- [ ] PostgreSQL está instalado e rodando
- [ ] Banco `organizador_juridico` foi criado
- [ ] Arquivo `.env` está configurado com `UPLOAD_DIR` e `NEXT_PUBLIC_UPLOAD_URL`
- [ ] Diretório `uploads/logos/` existe
- [ ] Servidor foi reiniciado após mudanças no `.env`
- [ ] Você consegue fazer upload de uma logo pelo dashboard
- [ ] A logo aparece corretamente após o upload
- [ ] A URL no banco está correta (http://localhost:3000/uploads/...)

---

## 🆘 Ainda com problemas?

Se nada funcionou:

1. **Reinicie tudo:**
   ```bash
   # Parar servidor
   Ctrl+C

   # Limpar cache do Next.js
   rm -rf .next

   # Reinstalar dependências
   npm install

   # Iniciar novamente
   npm run dev
   ```

2. **Verifique permissões do diretório:**
   ```bash
   # Windows: dar controle total ao usuário
   icacls "C:\Barros-Alves\organizadormulti-tenant\uploads" /grant Users:F /T
   ```

3. **Teste com uma imagem simples:**
   - Crie uma imagem pequena de teste (10x10 pixels)
   - Tente fazer upload
   - Verifique o console do navegador e terminal

4. **Verifique se o Next.js está servindo a rota:**
   Teste direto no navegador:
   ```
   http://localhost:3000/uploads/test.txt
   ```

   Crie um arquivo de teste:
   ```bash
   echo "teste" > C:\Barros-Alves\organizadormulti-tenant\uploads\test.txt
   ```

Se o arquivo `test.txt` não aparecer, há problema na rota `/uploads/[...path]`.

---

**Última atualização:** 2025-01-10
