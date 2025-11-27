# 🛠️ Modo de Manutenção - ADV DocMaster

## Como Ativar/Desativar o Modo de Manutenção

### 📋 O que acontece no modo de manutenção?

✅ **Continua funcionando:**
- Sistema completo (`/dashboard`, `/projects`, etc.)
- Página de login (`/login`)
- Todas as rotas autenticadas

❌ **Fica em manutenção:**
- Apenas a homepage (`/`)
- Página de cadastro (`/register`) - redirecionada para homepage

---

## 🚀 Ativar Manutenção

### **Local (desenvolvimento):**

1. Abra o arquivo `.env.local`
2. Adicione ou altere a linha:
   ```env
   NEXT_PUBLIC_MAINTENANCE_MODE=true
   ```
3. Reinicie o servidor Next.js:
   ```bash
   npm run dev
   ```

### **Produção (servidor):**

1. SSH no servidor
2. Edite o arquivo `.env.local`:
   ```bash
   cd /var/www/organizadorjuridicomultitenant
   nano .env.local
   ```
3. Adicione ou altere:
   ```env
   NEXT_PUBLIC_MAINTENANCE_MODE=true
   ```
4. Rebuild e restart:
   ```bash
   npm run build
   pm2 restart organizador-dev
   ```

---

## ✅ Desativar Manutenção

### **Local:**

1. Abra `.env.local`
2. Altere para:
   ```env
   NEXT_PUBLIC_MAINTENANCE_MODE=false
   ```
3. Reinicie o servidor

### **Produção:**

1. SSH no servidor
2. Edite `.env.local`:
   ```bash
   nano .env.local
   ```
3. Altere para:
   ```env
   NEXT_PUBLIC_MAINTENANCE_MODE=false
   ```
4. Rebuild e restart:
   ```bash
   npm run build
   pm2 restart organizador-dev
   ```

---

## 📝 Customizar Página de Manutenção

Para alterar textos, cores ou design da página de manutenção:

**Arquivo:** `src/components/MaintenancePage.tsx`

Você pode modificar:
- Título e descrição
- Cores e estilos
- Email de contato
- Botões e links

Após modificar, faça commit e deploy normalmente.

---

## ⚠️ Importante

- A variável **DEVE** começar com `NEXT_PUBLIC_` para funcionar no cliente
- Sempre faça **rebuild** após alterar `.env.local` em produção
- Clientes já logados **continuarão usando o sistema normalmente**
- Apenas visitantes da homepage verão a tela de manutenção

---

## 🧪 Testar

### Local:
1. Ative a manutenção
2. Acesse `http://localhost:3000` → Deve mostrar página de manutenção
3. Acesse `http://localhost:3000/login` → Deve funcionar normalmente

### Produção:
1. Ative a manutenção
2. Acesse `https://seudominio.com` → Página de manutenção
3. Acesse `https://seudominio.com/login` → Sistema funcionando