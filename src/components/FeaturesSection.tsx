import { 
  FaFolder, 
  FaCloud,
  FaChartBar,
  FaRobot,
  FaCheck,
  FaFileAlt
} from 'react-icons/fa'

interface FeatureCardProps {
  title: string
  description: string
  icon: React.ReactNode
}

function FeatureCard({ title, description, icon }: FeatureCardProps) {
  return (
    <div className="bg-white p-8 rounded-xl shadow-lg">
      <div className="text-blue-600 w-12 h-12 mb-4 flex items-center justify-center text-2xl">
        {icon}
      </div>
      <h3 className="text-xl font-semibold text-gray-900 mb-2">{title}</h3>
      <p className="text-gray-600">{description}</p>
    </div>
  )
}

export default function FeaturesSection() {
  const features = [
    {
      title: "Upload Inteligente",
      description: "Suporte para PDF, imagens e documentos do Word com OCR local usando Tesseract (processamento 100% no servidor).",
      icon: <FaCloud />
    },
    {
      title: "Categorização por IA",
      description: "Identificação automática de tipos de documentos usando OpenAI (RG, CPF, procurações, contratos e mais).",
      icon: <FaRobot />
    },
    {
      title: "Agrupamento Automático",
      description: "Documentos pessoais do mesmo titular são agrupados automaticamente para melhor organização.",
      icon: <FaFolder />
    },
    {
      title: "Validação Inteligente",
      description: "A IA analisa a relevância dos documentos com base na narrativa do caso.",
      icon: <FaCheck />
    },
    {
      title: "Exportação Profissional",
      description: "PDFs organizados, pesquisáveis e com índice automático para envio ao judiciário.",
      icon: <FaFileAlt />
    },
    {
      title: "Monitoramento de Custos",
      description: "Dashboard em tempo real do uso de tokens OpenAI e custos de processamento.",
      icon: <FaChartBar />
    }
  ]

  return (
    <section id="features" className="py-24 sm:py-32 bg-gray-50">
      <div className="max-w-7xl mx-auto px-6 lg:px-8">
        {/* Cabeçalho da Seção */}
        <div className="text-center max-w-2xl mx-auto mb-16">
          <h2 className="text-3xl font-bold tracking-tight text-gray-900 sm:text-4xl">
            Tudo o que seu escritório precisa para decolar
          </h2>
          <p className="mt-6 text-lg leading-8 text-gray-600">
            Pare de perder tempo em planilhas. Foque no que realmente importa: seus clientes.
          </p>
        </div>

        {/* Grid de Features */}
        <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-8">
          {features.map((feature, index) => (
            <FeatureCard
              key={index}
              title={feature.title}
              description={feature.description}
              icon={feature.icon}
            />
          ))}
        </div>
      </div>
    </section>
  )
}