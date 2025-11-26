interface FeatureCardProps {
  title: string
  description: string
  icon: React.ReactNode
}

function FeatureCard({ title, description, icon }: FeatureCardProps) {
  return (
    <div className="bg-white p-8 rounded-xl shadow-md border border-gray-200 hover:shadow-lg transition-shadow">
      <div className="text-indigo-600 w-12 h-12 mb-4 flex items-center justify-center">
        {icon}
      </div>
      <h3 className="text-xl font-semibold text-gray-900 mb-3">{title}</h3>
      <p className="text-gray-600">{description}</p>
    </div>
  )
}

export default function FeaturesSection() {
  const features = [
    {
      title: "Conversão automática para PDF-A",
      description: "Com um clique, qualquer arquivo vira PDF no padrão dos tribunais",
      icon: (
        <svg className="w-10 h-10" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
        </svg>
      )
    },
    {
      title: "Compressão e divisão inteligente",
      description: "Ajusta automaticamente conforme os limites de cada tribunal",
      icon: (
        <svg className="w-10 h-10" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13 10V3L4 14h7v7l9-11h-7z" />
        </svg>
      )
    },
    {
      title: "OCR avançado",
      description: "Torna todos os PDFs pesquisáveis e indexáveis",
      icon: (
        <svg className="w-10 h-10" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />
        </svg>
      )
    },
    {
      title: "Identificação automática",
      description: "Classificar documentos automaticamente (contratos, procurações, RGs)",
      icon: (
        <svg className="w-10 h-10" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2m-6 9l2 2 4-4" />
        </svg>
      )
    },
    {
      title: "Listas de verificação automatizadas",
      description: "Validação completa para e-SAJ, PJe e e-proc",
      icon: (
        <svg className="w-10 h-10" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
        </svg>
      )
    },
    {
      title: "Seguro",
      description: "Nuvem com controle de versões e conformidade LGPD",
      icon: (
        <svg className="w-10 h-10" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z" />
        </svg>
      )
    }
  ]

  return (
    <section id="features" className="py-24 sm:py-32 bg-gray-50">
      <div className="max-w-7xl mx-auto px-6 lg:px-8">
        {/* Cabeçalho da Seção */}
        <div className="text-center max-w-3xl mx-auto mb-16">
          <h2 className="text-4xl font-bold tracking-tight text-gray-900 mb-4">
            O ADV DocMaster
          </h2>
          <p className="text-xl text-gray-600">
            A plataforma de inteligência artificial que transforma sua rotina documental
          </p>
        </div>

        {/* Grid de Features */}
        <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-8 mb-12">
          {features.map((feature, index) => (
            <FeatureCard
              key={index}
              title={feature.title}
              description={feature.description}
              icon={feature.icon}
            />
          ))}
        </div>

        {/* Box Preparado para o futuro */}
        <div className="max-w-5xl mx-auto mt-16">
          <div className="bg-gradient-to-r from-indigo-50 to-purple-50 border-l-4 border-indigo-600 rounded-r-2xl p-8">
            <h3 className="text-2xl font-bold text-gray-900 mb-3">
              Preparado para o futuro da advocacia
            </h3>
            <p className="text-gray-700 text-lg">
              Exportação com arquivos prontos para uso com IA generativa — copilotos jurídicos, resumos automáticos, buscas inteligentes e envio direto para os sistemas de protocolo.
            </p>
          </div>
        </div>
      </div>
    </section>
  )
}