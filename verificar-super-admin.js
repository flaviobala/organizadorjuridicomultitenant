// Script de Diagnóstico - Verificar Super Admin
// Execute com: node verificar-super-admin.js

const { PrismaClient } = require('@prisma/client')
const prisma = new PrismaClient()

async function verificarSuperAdmin() {
  console.log('\n🔍 VERIFICANDO CONFIGURAÇÃO DE SUPER ADMIN...\n')

  try {
    // 1. Verificar se existem usuários
    const totalUsers = await prisma.user.count()
    console.log(`✅ Total de usuários no banco: ${totalUsers}`)

    if (totalUsers === 0) {
      console.log('\n⚠️  PROBLEMA: Não há usuários cadastrados!')
      console.log('   SOLUÇÃO: Acesse /login e crie uma conta primeiro\n')
      return
    }

    // 2. Listar todos os usuários e suas roles
    const users = await prisma.user.findMany({
      select: {
        id: true,
        name: true,
        email: true,
        role: true,
        organizationId: true
      }
    })

    console.log('\n📋 USUÁRIOS CADASTRADOS:')
    console.log('=' .repeat(80))
    users.forEach(user => {
      const roleEmoji = user.role === 'super_admin' ? '👑' :
                        user.role === 'admin' ? '🔑' : '👤'
      console.log(`${roleEmoji} ID: ${user.id} | Email: ${user.email}`)
      console.log(`   Nome: ${user.name}`)
      console.log(`   Role: ${user.role}`)
      console.log(`   Org ID: ${user.organizationId}`)
      console.log('-'.repeat(80))
    })

    // 3. Verificar se existe algum super_admin
    const superAdmins = users.filter(u => u.role === 'super_admin')

    if (superAdmins.length === 0) {
      console.log('\n❌ PROBLEMA: Nenhum usuário é super_admin!')
      console.log('\n📝 SOLUÇÃO:')
      console.log('   1. Escolha o email do usuário que deve ser super_admin (da lista acima)')
      console.log('   2. Vá em Supabase SQL Editor')
      console.log('   3. Execute:')
      console.log('\n   ALTER TYPE "UserRole" ADD VALUE IF NOT EXISTS \'super_admin\';')
      console.log('   UPDATE users SET role = \'super_admin\' WHERE email = \'seu@email.com\';')
      console.log('\n   4. Faça logout e login novamente no sistema\n')
    } else {
      console.log(`\n✅ SUPER ADMINS ENCONTRADOS: ${superAdmins.length}`)
      superAdmins.forEach(admin => {
        console.log(`   👑 ${admin.email}`)
      })
    }

    // 4. Verificar organizações
    const orgs = await prisma.organization.count()
    console.log(`\n✅ Total de organizações: ${orgs}`)

  } catch (error) {
    console.error('\n❌ ERRO:', error.message)

    if (error.message.includes('invalid input value for enum UserRole')) {
      console.log('\n⚠️  O enum UserRole ainda não tem super_admin!')
      console.log('\n📝 EXECUTE NO SUPABASE SQL EDITOR:')
      console.log('   ALTER TYPE "UserRole" ADD VALUE IF NOT EXISTS \'super_admin\';')
    }
  } finally {
    await prisma.$disconnect()
  }
}

verificarSuperAdmin()
