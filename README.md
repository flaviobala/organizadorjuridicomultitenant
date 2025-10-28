# ⚖️ Sistema Jurídico

Sistema completo de organização e automação de processos documentais para escritórios de advocacia e departamentos jurídicos, com inteligência artificial para análise e categorização automática de documentos.

---

## 📋 Índice

- [Funcionalidades](#-funcionalidades)
- [Tecnologias](#-tecnologias-utilizadas)
- [Pré-requisitos](#-pré-requisitos)
- [Instalação](#️-instalação)
- [Configuração](#-configuração)
- [Como Usar](#-como-usar)
- [Estrutura do Projeto](#-estrutura-do-projeto)
- [API Endpoints](#-api-endpoints)
- [Testes](#-testes)
- [Deploy](#-deploy)
- [Contribuindo](#-contribuindo)
- [Licença](#-licença)

---

## ✨ Funcionalidades

### 🔐 Autenticação
- Sistema completo de login e registro de usuários
- Autenticação JWT com tokens seguros
- Proteção de rotas com middleware

### 📂 Gestão de Projetos
- Criação e gerenciamento de projetos/casos jurídicos
- Dashboard com visão geral de todos os projetos
- Filtros por status (Rascunho, Processando, Concluído, Validado)
- Busca de projetos por nome ou cliente

### 📄 Processamento de Documentos
- **Upload inteligente**: Suporte para PDF, imagens (JPG, PNG), DOCX
- **OCR automático**: Extração de texto via API Elysium
- **Categorização por IA**: OpenAI identifica automaticamente o tipo de documento
  - Documentos pessoais (RG, CPF, CNH)
  - Comprovantes de residência
  - Procurações
  - Contratos
  - Narrativas fáticas
  - E mais...
- **Agrupamento automático**: Documentos pessoais do mesmo titular são agrupados
- **Renomeação inteligente**: Nomes padronizados baseados no conteúdo

### 🤖 Inteligência Artificial
- **Análise de narrativas**: Transforma relatos em narrativas fáticas profissionais
- **Validação de documentos**: Verifica relevância de documentos para o caso
- **Detecção de inconsistências**: Identifica contradições entre documentos e narrativas
- **Sugestões automáticas**: IA sugere melhorias e documentos adicionais

### 📦 Exportação
- Geração de ZIP com todos os documentos organizados
- PDFs renomeados e ordenados conforme padrão dos sistemas judiciais
- Documentos pessoais agrupados em um único PDF

---

## 🚀 Tecnologias Utilizadas

### Frontend
- **Next.js 15** - Framework React com SSR
- **React 19** - Biblioteca UI
- **TypeScript** - Tipagem estática
- **Tailwind CSS 4** - Estilização
- **Lucide React** - Ícones
- **React Hook Form** - Gerenciamento de formulários
- **Zod** - Validação de schemas

### Backend
- **Next.js API Routes** - API RESTful
- **Prisma** - ORM para banco de dados
- **PostgreSQL** - Banco de dados (Supabase)
- **JWT** - Autenticação
- **Bcrypt** - Hash de senhas

### Integrações Externas
- **OpenAI API (GPT-4)** - Análise de documentos e narrativas
- **Supabase Storage** - Armazenamento de arquivos
- **API Elysium OCR** - Extração de texto de documentos

### Processamento de Documentos
- **pdf-lib** - Manipulação de PDFs
- **sharp** - Processamento de imagens
- **mammoth** - Conversão de DOCX
- **jszip** - Compressão de arquivos

---

## 📋 Pré-requisitos

- **Node.js** 18+ (recomendado 20+)
- **npm** ou **yarn**
- **PostgreSQL** (ou conta Supabase)
- **Conta OpenAI** (API Key)
- **Conta Supabase** (para storage)

---

## 🛠️ Instalação

### 1. Clone o repositório

```bash
git clone https://github.com/flaviobala/orgnizadorjuridico.git
cd sistema-juridico
```

### 2. Instale as dependências

```bash
npm install
```

### 3. Configure as variáveis de ambiente

Copie o arquivo de exemplo e preencha com suas credenciais:

```bash
cp .env.example .env.local
```

Edite o arquivo `.env.local` com suas credenciais (veja seção [Configuração](#-configuração)).

### 4. Configure o banco de dados

```bash
# Aplicar migrações
npx prisma db push

# (Opcional) Popular com dados de teste
npm run db:seed
```

### 5. Inicie o servidor de desenvolvimento

```bash
npm run dev
```

O sistema estará disponível em: **http://localhost:3000**

---

## ⚙️ Configuração

### Variáveis de Ambiente

Edite o arquivo `.env.local` com suas credenciais:

```env
# ==================== DATABASE ====================
DATABASE_URL="postgresql://usuario:senha@host:5432/database"

# ==================== JWT AUTHENTICATION ====================
# Gere uma chave forte com: openssl rand -base64 64
JWT_SECRET="sua-chave-secreta-jwt-aqui-minimo-32-caracteres"

# ==================== OPENAI API ====================
# Obtenha em: https://platform.openai.com/api-keys
OPENAI_API_KEY="sk-proj-..."

# ==================== SUPABASE ====================
# Obtenha em: https://supabase.com/dashboard/project/_/settings/api
NEXT_PUBLIC_SUPABASE_URL="https://seu-projeto.supabase.co"
NEXT_PUBLIC_SUPABASE_ANON_KEY="eyJhbGci..."
SUPABASE_SERVICE_ROLE_KEY="eyJhbGci..."

# ==================== APP CONFIGURATION ====================
NEXT_PUBLIC_APP_URL="http://localhost:3000"
NODE_ENV="development"
```

### Como obter as credenciais:

#### PostgreSQL (Supabase)
1. Acesse [supabase.com](https://supabase.com)
2. Crie um novo projeto
3. Vá em **Settings** → **Database**
4. Copie a **Connection String** no formato URI

#### OpenAI
1. Acesse [platform.openai.com](https://platform.openai.com)
2. Crie uma conta e adicione créditos
3. Vá em **API Keys** e crie uma nova chave

#### Supabase Storage
1. No projeto Supabase, vá em **Storage**
2. Crie um bucket chamado `documents`
3. Configure como **público** ou **privado** conforme necessidade
4. As chaves API estão em **Settings** → **API**

---

## 💻 Como Usar

### 1. Primeiro Acesso

1. Acesse http://localhost:3000
2. Clique em **"Criar conta"**
3. Preencha nome, email e senha
4. Faça login com suas credenciais

### 2. Criar um Projeto

1. No dashboard, clique em **"Novo Projeto"**
2. Preencha:
   - Nome do projeto
   - Nome do cliente
   - Sistema judicial (e-SAJ, PJe, etc.)
   - Tipo de ação (Ação Civil, Trabalhista, etc.)
   - Narrativa dos fatos (opcional)
3. Clique em **"Criar Projeto"**

### 3. Processar Narrativa (Opcional)

Se você inseriu uma narrativa:
1. Clique em **"Processar com IA"**
2. A IA transformará o texto em narrativa fática profissional
3. Revise e edite se necessário

### 4. Upload de Documentos

1. Clique em **"Fazer Upload de Documentos"**
2. Arraste e solte arquivos ou clique para selecionar
3. A IA analisará e categorizará automaticamente
4. Revise os documentos processados

### 5. Validar Documentos (Opcional)

1. Clique em **"Validar Documentos com IA"**
2. A IA verificará:
   - Relevância dos documentos para o caso
   - Inconsistências entre documentos e narrativa
   - Sugestões de documentos adicionais

### 6. Exportar Projeto

1. Clique em **"Exportar ZIP"**
2. O sistema gerará um arquivo ZIP com:
   - Documentos renomeados e organizados
   - Numeração sequencial conforme padrão
   - Documentos pessoais agrupados

---

## 📁 Estrutura do Projeto

```
sistema-juridico/
├── prisma/
│   ├── schema.prisma          # Schema do banco de dados
│   ├── migrations/            # Migrações do banco
│   └── seed.ts               # Dados de seed
├── public/
│   ├── uploads/              # Uploads temporários (gitignored)
│   └── temp/                 # Arquivos temporários (gitignored)
├── src/
│   ├── app/
│   │   ├── api/              # API Routes
│   │   │   ├── auth/         # Autenticação (login, register)
│   │   │   ├── projects/     # CRUD de projetos
│   │   │   ├── documents/    # Upload e gerenciamento de docs
│   │   │   └── ai/           # Endpoints de IA
│   │   ├── dashboard/        # Dashboard principal
│   │   ├── projects/         # Páginas de projetos
│   │   ├── login/            # Página de login
│   │   ├── layout.tsx        # Layout global
│   │   └── page.tsx          # Página inicial
│   ├── lib/
│   │   ├── auth.ts           # Lógica de autenticação
│   │   ├── prisma.ts         # Cliente Prisma
│   │   ├── openai.ts         # Serviço OpenAI
│   │   ├── pdf-converter.ts  # Conversão de documentos
│   │   ├── validators.ts     # Schemas Zod
│   │   └── utils.ts          # Funções utilitárias
│   └── types/
│       └── index.ts          # Tipos TypeScript
├── .env.local                # Variáveis de ambiente (gitignored)
├── .env.example              # Template de variáveis
├── .gitignore                # Arquivos ignorados
├── package.json              # Dependências
├── tsconfig.json             # Config TypeScript
├── tailwind.config.ts        # Config Tailwind
└── README.md                 # Este arquivo
```

---

## 🔌 API Endpoints

### Autenticação

```
POST /api/auth/register   # Registrar novo usuário
POST /api/auth/login      # Fazer login
```

### Projetos

```
GET    /api/projects           # Listar projetos do usuário
POST   /api/projects           # Criar novo projeto
GET    /api/projects/:id       # Obter projeto específico
PUT    /api/projects/:id       # Atualizar projeto
DELETE /api/projects/:id       # Deletar projeto
GET    /api/projects/:id/export-zip  # Exportar ZIP
```

### Documentos

```
POST   /api/documents/upload   # Upload de documento
GET    /api/documents/:id      # Obter documento
DELETE /api/documents/:id      # Deletar documento
GET    /api/documents/:id/download  # Download de documento
```

### IA

```
POST /api/ai/process-narrative    # Processar narrativa com IA
POST /api/ai/validate-documents   # Validar documentos com IA
```

### Outros

```
GET /api/systems         # Listar sistemas judiciais
GET /api/document-types  # Listar tipos de documentos
```

---

## 🧪 Testes

```bash
# Rodar testes (quando implementados)
npm test

# Rodar com cobertura
npm run test:coverage

# Rodar em modo watch
npm run test:watch
```

> ⚠️ **Nota**: Testes ainda não foram implementados. Contribuições são bem-vindas!

---

## 🚀 Deploy

### Vercel (Recomendado)

1. Faça push do código para GitHub
2. Acesse [vercel.com](https://vercel.com)
3. Importe o repositório
4. Configure as variáveis de ambiente
5. Deploy automático!

### Outras plataformas

O projeto pode ser deployado em qualquer plataforma que suporte Next.js:
- **Railway**
- **Render**
- **AWS**
- **Digital Ocean**

---

## 🐛 Problemas Conhecidos

- [ ] Sem testes automatizados
- [ ] Falta tratamento de erro em alguns uploads grandes
- [ ] API Elysium OCR pode falhar ocasionalmente

---

## 🗺️ Roadmap

- [ ] Implementar testes unitários e E2E
- [ ] Adicionar suporte a mais tipos de documentos
- [ ] Dashboard com gráficos e estatísticas
- [ ] Sistema de notificações
- [ ] Versionamento de documentos
- [ ] Múltiplos usuários por projeto
- [ ] Assinatura digital de documentos
- [ ] App mobile (React Native)

---

## 🤝 Contribuindo

Contribuições são bem-vindas! Por favor:

1. Fork o projeto
2. Crie uma branch para sua feature (`git checkout -b feature/MinhaFeature`)
3. Commit suas mudanças (`git commit -m 'Adiciona MinhaFeature'`)
4. Push para a branch (`git push origin feature/MinhaFeature`)
5. Abra um Pull Request

---

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo `LICENSE` para mais detalhes.

---

## 👨‍💻 Autor

**Flavio Bala**

- GitHub: [@flaviobala](https://github.com/flaviobala)

---

## 🙏 Agradecimentos

- [Next.js](https://nextjs.org/)
- [OpenAI](https://openai.com/)
- [Supabase](https://supabase.com/)
- [Prisma](https://www.prisma.io/)
- Comunidade open source

---

## 📞 Suporte

Se tiver problemas ou dúvidas:

1. Verifique a [documentação](#)
2. Abra uma [issue](https://github.com/flaviobala/orgnizadorjuridico/issues)
3. Entre em contato pelo email (adicione seu email)

---

<p align="center">
  Feito com ❤️ para facilitar o trabalho jurídico
</p>
