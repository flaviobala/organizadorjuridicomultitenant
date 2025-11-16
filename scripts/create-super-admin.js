// Script para criar super administrador do sistema
const { PrismaClient } = require('@prisma/client')
const bcrypt = require('bcryptjs')

const prisma = new PrismaClient()

async function main() {
  console.log('🚀 Criando super administrador...\n')

  // Dados do super admin
  const email = 'flavioha@gmail.com'
  const password = 'Dir0e79@000'
  const name = 'Flavio - Super Admin'

  try {
    // 1. Verificar se já existe
    const existingUser = await prisma.user.findUnique({
      where: { email }
    })

    if (existingUser) {
      console.log('⚠️  Usuário já existe:', email)
      console.log('   Use este email para fazer login.\n')
      return
    }

    // 2. Criar organização administrativa (se não existir)
    let systemOrg = await prisma.organization.findFirst({
      where: { name: 'Sistema - Administração' }
    })

    if (!systemOrg) {
      console.log('📦 Criando organização administrativa...')
      systemOrg = await prisma.organization.create({
        data: {
          name: 'Sistema - Administração',
          planType: 'pro', // Super admin usa plano PRO sem limitações
          subscriptionStatus: 'active',
          freeTrialEndsAt: null // Sem expiração para super admin
        }
      })
      console.log('✅ Organização criada: ID', systemOrg.id, '\n')
    } else {
      console.log('📦 Organização administrativa já existe: ID', systemOrg.id, '\n')
    }

    // 3. Hash da senha
    console.log('🔐 Gerando hash da senha...')
    const hashedPassword = await bcrypt.hash(password, 10)

    // 4. Criar usuário super_admin
    console.log('👤 Criando usuário super_admin...')
    const user = await prisma.user.create({
      data: {
        email,
        password: hashedPassword,
        name,
        role: 'super_admin',
        organizationId: systemOrg.id
      }
    })

    console.log('✅ Super administrador criado com sucesso!\n')
    console.log('📋 Detalhes:')
    console.log('   ID:', user.id)
    console.log('   Email:', user.email)
    console.log('   Nome:', user.name)
    console.log('   Role:', user.role)
    console.log('   Organização ID:', user.organizationId)
    console.log('\n🎉 Pronto! Você já pode fazer login com essas credenciais.\n')

  } catch (error) {
    console.error('❌ Erro ao criar super admin:', error.message)
    throw error
  } finally {
    await prisma.$disconnect()
  }
}

main()
  .catch((error) => {
    console.error(error)
    process.exit(1)
  })