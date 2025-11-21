/**
 * Script para popular sistemas padrão para organizações
 * Cria os sistemas jurídicos mais comuns para cada organização
 */

import { prisma } from '../src/lib/prisma'

const DEFAULT_SYSTEMS = [
  {
    systemName: 'e-SAJ',
    maxFileSize: 30 * 1024 * 1024, // 30 MB
    maxPageSize: 300, // 300 KB
    allowedFormats: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
    pdfRequirements: {
      maxSizeMB: 30,
      maxPageSizeKB: 300,
      resolution: 150,
      colorMode: 'RGB',
      compression: true
    }
  },
  {
    systemName: 'PJe - 1o Grau',
    maxFileSize: 5 * 1024 * 1024, // 5 MB
    maxPageSize: 500, // 500 KB
    allowedFormats: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
    pdfRequirements: {
      maxSizeMB: 5,
      maxPageSizeKB: 500,
      resolution: 150,
      colorMode: 'RGB',
      compression: true
    }
  },
  {
    systemName: 'PJe - 2o Grau',
    maxFileSize: 10 * 1024 * 1024, // 10 MB
    maxPageSize: 500, // 500 KB
    allowedFormats: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
    pdfRequirements: {
      maxSizeMB: 10,
      maxPageSizeKB: 500,
      resolution: 150,
      colorMode: 'RGB',
      compression: true
    }
  },
  {
    systemName: 'PJe 2x',
    maxFileSize: 3 * 1024 * 1024, // 3 MB
    maxPageSize: 300, // 300 KB
    allowedFormats: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
    pdfRequirements: {
      maxSizeMB: 3,
      maxPageSizeKB: 300,
      resolution: 150,
      colorMode: 'RGB',
      compression: true
    }
  },
  {
    systemName: 'PJe - TRT 1o Grau',
    maxFileSize: 3 * 1024 * 1024, // 3 MB
    maxPageSize: 500, // 500 KB
    allowedFormats: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
    pdfRequirements: {
      maxSizeMB: 3,
      maxPageSizeKB: 500,
      resolution: 150,
      colorMode: 'RGB',
      compression: true
    }
  }
]

async function seedDefaultSystems() {
  try {
    console.log('🌱 Iniciando seed de sistemas padrão...')

    // Buscar todas as organizações
    const organizations = await prisma.organization.findMany()
    console.log(`📊 Encontradas ${organizations.length} organizações`)

    if (organizations.length === 0) {
      console.log('⚠️  Nenhuma organização encontrada. Execute o seed de organizações primeiro.')
      return
    }

    let totalCreated = 0
    let totalSkipped = 0

    // Para cada organização, criar os sistemas padrão
    for (const org of organizations) {
      console.log(`\n🏢 Processando organização: ${org.name} (ID: ${org.id})`)

      for (const system of DEFAULT_SYSTEMS) {
        // Verificar se o sistema já existe para esta organização
        const existing = await prisma.systemConfiguration.findFirst({
          where: {
            organizationId: org.id,
            systemName: system.systemName
          }
        })

        if (existing) {
          console.log(`   ⏭️  ${system.systemName} - já existe`)
          totalSkipped++
          continue
        }

        // Criar o sistema
        await prisma.systemConfiguration.create({
          data: {
            organizationId: org.id,
            systemName: system.systemName,
            maxFileSize: system.maxFileSize,
            maxPageSize: system.maxPageSize,
            allowedFormats: JSON.stringify(system.allowedFormats),
            pdfRequirements: JSON.stringify(system.pdfRequirements)
          }
        })

        console.log(`   ✅ ${system.systemName} - criado`)
        totalCreated++
      }
    }

    console.log('\n' + '='.repeat(60))
    console.log(`✨ Seed concluído!`)
    console.log(`   📦 Sistemas criados: ${totalCreated}`)
    console.log(`   ⏭️  Sistemas já existentes: ${totalSkipped}`)
    console.log('='.repeat(60))

  } catch (error) {
    console.error('❌ Erro ao criar sistemas padrão:', error)
    throw error
  } finally {
    await prisma.$disconnect()
  }
}

// Executar seed
seedDefaultSystems()
