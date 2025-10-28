# Instruções para Agentes de IA - Sistema Jurídico

Este é um sistema Next.js/TypeScript para gerenciamento e automação de processos jurídicos, com foco em processamento inteligente de documentos usando IA.

## 🏗️ Arquitetura

### Estrutura Principal
- `src/app/` - Rotas e páginas Next.js (App Router)
- `src/components/` - Componentes React reutilizáveis
- `src/lib/` - Serviços e utilitários core
- `prisma/` - Schema e migrações do banco de dados

### Padrões Importantes
1. **API Routes**: Todas as rotas API estão em `src/app/api/` usando o pattern de pastas do Next.js App Router
2. **Autenticação**: JWT implementado em `src/lib/auth.ts`
3. **Banco de Dados**: Prisma ORM com PostgreSQL, singleton pattern em `src/lib/prisma.ts`
4. **Processamento IA**: Serviço OpenAI centralizado em `src/lib/openai.ts`

## 🔑 Conceitos Chave

### Fluxo de Documentos
1. Upload → OCR → Análise IA → Categorização → Agrupamento → Validação
2. Documentos são agrupados automaticamente por tipo e titular
3. Sistema mantém rastreamento de tokens OpenAI por requisição

### Padrões de Código
- Use `zod` para validação de schemas (ver `src/lib/validators.ts`)
- Serviços externos são abstraídos em classes em `src/lib/`
- Componentes de UI seguem padrão de composição do Tailwind

## 🛠️ Desenvolvimento

### Ambiente Local
```bash
npm install
npx prisma generate
npx prisma migrate dev
npm run dev
```

### Variáveis de Ambiente Necessárias
- `DATABASE_URL` - PostgreSQL connection string
- `OPENAI_API_KEY` - Chave da API OpenAI
- `JWT_SECRET` - Segredo para tokens JWT
- `SUPABASE_URL` e `SUPABASE_KEY` - Armazenamento de arquivos

### Padrões de Nomenclatura
- APIs: Kebab-case para endpoints (`/api/document-types`)
- Componentes: PascalCase (`TokenUsageBadge.tsx`)
- Utilitários: camelCase (`pdfConverter.ts`)

## 🔍 Pontos de Atenção

### Integrações Críticas
1. **OpenAI**: Limite de uso monitorado em `src/lib/token-tracker.ts`
2. **Supabase Storage**: Para arquivos grandes
3. **API Elysium**: OCR de documentos

### Otimizações
- Cache de resultados OCR
- Processamento em lote para múltiplos documentos
- Compressão de imagens antes do upload

## 🚫 Anti-patterns a Evitar
- Não use fetch direto para OpenAI - use o serviço `OpenAIService`
- Evite manipulação direta de arquivos - use as abstrações em `src/lib/pdf-*`
- Não faça queries Prisma fora de API routes