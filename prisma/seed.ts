// prisma/seed.ts
import { PrismaClient } from '@prisma/client'

const prisma = new PrismaClient()

async function main() {
  console.log('🌱 Populando banco de dados...')

  // Configurações dos sistemas judiciais
  const systems = [
    {
      systemName: 'e-SAJ',
      maxFileSize: 30 * 1024 * 1024, // 30 MB
      maxPageSize: 300, // 300 KB/página
      allowedFormats: JSON.stringify(['pdf', 'doc', 'docx', 'txt', 'jpg', 'jpeg', 'png']),
      pdfRequirements: JSON.stringify({
        maxSizeMB: 30,
        maxPageSizeKB: 300,
        resolution: 150,
        colorMode: 'RGB',
        compression: true
      })
    },
    {
      systemName: 'PJe - 1º Grau',
      maxFileSize: 5 * 1024 * 1024, // 5 MB
      maxPageSize: 500, // 500 KB/página
      allowedFormats: JSON.stringify(['pdf', 'doc', 'docx', 'txt', 'jpg', 'jpeg', 'png']),
      pdfRequirements: JSON.stringify({
        maxSizeMB: 5,
        maxPageSizeKB: 500,
        resolution: 150,
        colorMode: 'RGB',
        compression: true
      })
    },
    {
      systemName: 'PJe - 2º Grau',
      maxFileSize: 10 * 1024 * 1024, // 10 MB
      maxPageSize: 500, // 500 KB/página
      allowedFormats: JSON.stringify(['pdf', 'doc', 'docx', 'txt', 'jpg', 'jpeg', 'png']),
      pdfRequirements: JSON.stringify({
        maxSizeMB: 10,
        maxPageSizeKB: 500,
        resolution: 150,
        colorMode: 'RGB',
        compression: true
      })
    },
    {
      systemName: 'PJe 2x',
      maxFileSize: 3 * 1024 * 1024, // 3 MB
      maxPageSize: 300, // 300 KB/página
      allowedFormats: JSON.stringify(['pdf', 'doc', 'docx', 'txt', 'jpg', 'jpeg', 'png']),
      pdfRequirements: JSON.stringify({
        maxSizeMB: 3,
        maxPageSizeKB: 300,
        resolution: 150,
        colorMode: 'RGB',
        compression: true
      })
    },
    {
      systemName: 'PJe - TRT 1º Grau',
      maxFileSize: 3 * 1024 * 1024, // 3 MB
      maxPageSize: 500, // 500 KB/página
      allowedFormats: JSON.stringify(['pdf', 'doc', 'docx', 'txt', 'jpg', 'jpeg', 'png']),
      pdfRequirements: JSON.stringify({
        maxSizeMB: 3,
        maxPageSizeKB: 500,
        resolution: 150,
        colorMode: 'RGB',
        compression: true
      })
    }
  ]

  // Tipos de documentos
  const documentTypes = [
    {
      code: '01-identidade',
      name: 'Documento de Identidade',
      description: 'RG, CNH ou documento oficial com foto',
      isRequired: true,
      order: 1
    },
    {
      code: '02-cnh',
      name: 'Carteira Nacional de Habilitação',
      description: 'CNH válida',
      isRequired: false,
      order: 2
    },
    {
      code: '03-cpf',
      name: 'CPF',
      description: 'Comprovante de CPF',
      isRequired: true,
      order: 3
    },
    {
      code: '04-comprovante-residencia',
      name: 'Comprovante de Residência',
      description: 'Conta de luz, água, telefone ou contrato de locação',
      isRequired: false,
      order: 4
    },
    {
      code: '05-procuracao',
      name: 'Procuração',
      description: 'Procuração específica ou geral',
      isRequired: false,
      order: 5
    },
    {
      code: '06-declaracao-hipossuficiencia',
      name: 'Declaração de Hipossuficiência',
      description: 'Para assistência jurídica gratuita',
      isRequired: false,
      order: 6
    },
    {
      code: '07-contrato',
      name: 'Contrato de Prestação de Serviços',
      description: 'Contrato com o advogado ou escritório',
      isRequired: false,
      order: 7
    },
    {
      code: '08-certidao-nascimento-casamento',
      name: 'Certidão de Nascimento/Casamento',
      description: 'Certidão atualizada',
      isRequired: false,
      order: 8
    },
    {
      code: '09-outros-documentos',
      name: 'Outros Documentos Relevantes',
      description: 'Documentos adicionais conforme o caso',
      isRequired: false,
      order: 9
    }
  ]

  // Inserir configurações dos sistemas
  for (const system of systems) {
    await prisma.systemConfiguration.upsert({
      where: { systemName: system.systemName },
      update: system,
      create: system
    })
  }

  // Inserir tipos de documentos
  for (const docType of documentTypes) {
    await prisma.documentType.upsert({
      where: { code: docType.code },
      update: docType,
      create: docType
    })
  }

  console.log('✅ Banco populado com sucesso!')
  console.log(`📋 ${systems.length} sistemas configurados`)
  console.log(`📄 ${documentTypes.length} tipos de documentos criados`)
}

main()
  .catch((e) => {
    console.error('❌ Erro ao popular banco:', e)
    process.exit(1)
  })
  .finally(async () => {
    await prisma.$disconnect()
  })