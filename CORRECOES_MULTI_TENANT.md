# Correções Multi-Tenant - Sistemas

## ✅ Arquivos Corrigidos

### 1. [src/app/api/projects/route.ts](src/app/api/projects/route.ts) (Linha 112)
**Antes:**
```typescript
const systemConfig = await prisma.systemConfiguration.findUnique({
  where: { systemName: system }
})
```

**Depois:**
```typescript
const systemConfig = await prisma.systemConfiguration.findFirst({
  where: {
    organizationId: auth.user.organizationId,
    systemName: system
  }
})
```

**Motivo**: `systemName` não é mais único globalmente. Agora é único **por organização**.

---

### 2. [src/lib/pdf-converter.ts](src/lib/pdf-converter.ts) (Linha 112)

**Método `init()` atualizado:**
```typescript
async init(organizationId?: number): Promise<void> {
  console.log('🔧 Inicializando PDFConverter para:', this.systemName)

  // Carregar configurações do sistema se disponível e organizationId fornecido
  if (organizationId) {
    try {
      const config = await prisma.systemConfiguration.findFirst({
        where: {
          organizationId: organizationId,
          systemName: this.systemName
        }
      })

      if (config?.pdfRequirements) {
        this.systemRequirements = JSON.parse(config.pdfRequirements)
        console.log('✅ Configurações carregadas:', this.systemRequirements)
      }
    } catch (error) {
      console.warn('⚠️ Usando configurações padrão:', error)
    }
  } else {
    console.log('ℹ️ Usando configurações padrão (organizationId não fornecido)')
  }
}
```

**Método `create()` atualizado (Linha 2189):**
```typescript
static async create(systemName: string, organizationId?: number): Promise<PDFConverter> {
  const converter = new PDFConverter(systemName)
  await converter.init(organizationId)
  return converter
}
```

---

### 3. [src/app/api/documents/upload/route.ts](src/app/api/documents/upload/route.ts) (Linha 122)

**Antes:**
```typescript
await converter.init()
```

**Depois:**
```typescript
await converter.init(auth.user.organizationId) // Passar organizationId para carregar configs
```

---

### 4. [src/app/api/systems/route.ts](src/app/api/systems/route.ts)

**GET** - Filtrar sistemas por organização (Linha 107-112):
```typescript
const systems = await prisma.systemConfiguration.findMany({
  where: {
    organizationId: auth.user.organizationId
  },
  orderBy: { systemName: 'asc' }
})
```

**POST** - Criar sistema vinculado à organização (Linha 59-74):
```typescript
const newSystem = await prisma.systemConfiguration.create({
  data: {
    organizationId: auth.user.organizationId,
    systemName: systemName.trim(),
    maxFileSize: maxFileSize,
    maxPageSize: maxPageSize,
    // ...
  }
})
```

---

## 📝 Mudanças no Schema Prisma

### [prisma/schema.prisma](prisma/schema.prisma)

**Adicionado:**
```prisma
model SystemConfiguration {
  id              Int          @id @default(autoincrement())
  systemName      String       @map("system_name")
  // ... outros campos ...

  // Multi-tenant: cada organização tem seus próprios sistemas
  organizationId  Int          @map("organization_id")
  organization    Organization @relation(fields: [organizationId], references: [id], onDelete: Cascade)

  // Sistema único por organização (permite mesmo nome em orgs diferentes)
  @@unique([organizationId, systemName])
  @@map("system_configurations")
}
```

**Adicionado em Organization:**
```prisma
model Organization {
  // ... outros campos ...
  systems        SystemConfiguration[]
}
```

---

## 🔄 Próximos Passos

Agora você **DEVE** executar a migration SQL no banco de dados:

### Opção 1: Via psql
```bash
psql -U postgres -d organizador_juridico -f prisma/migrations/add_organization_to_systems.sql
```

### Opção 2: Via pgAdmin/DBeaver
Execute o SQL do arquivo: `prisma/migrations/add_organization_to_systems.sql`

### Opção 3: Gerar Prisma Client
```bash
npx prisma generate
```

---

## ✅ Checklist

- [ ] Executar migration SQL
- [ ] Executar `npx prisma generate`
- [ ] Reiniciar servidor (`npm run dev`)
- [ ] Testar criação de projeto
- [ ] Testar upload de documento
- [ ] Verificar isolamento multi-tenant

---

## 🐛 Erros que Foram Corrigidos

### Erro 1: `organization_id does not exist`
**Causa**: Migration SQL não foi executada
**Solução**: Executar migration SQL

### Erro 2: `systemName needs at least one of id or organizationId_systemName`
**Causa**: Código usando `findUnique({ where: { systemName } })` mas `systemName` não é mais unique global
**Solução**: Mudado para `findFirst({ where: { organizationId, systemName } })`

---

**Data**: 2025-01-19
**Status**: ✅ Código corrigido - Aguardando migration SQL no banco
