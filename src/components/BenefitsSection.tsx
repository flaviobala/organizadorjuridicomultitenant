export default function BenefitsSection() {
  const benefits = [
    "Processamento de centenas a milhares de documentos por mês",
    "Narrativas ilimitadas para organizar casos",
    "Agrupamento automático por processo",
    "Exportação pronta para e-SAJ, PJe, PJe2x, PROJUDI e outros",
    "Renomeação inteligente baseada em conteúdo",
    "Geração de ZIP conforme limites dos tribunais",
    "OCR otimizado para pesquisa",
    "Checklist inteligente com validação",
    "Validação de pertinência temática (planos superiores)",
    "Painel detalhado de uso e auditoria",
    "Acesso para múltiplos usuários (planos superiores)",
    "Suporte completo via chat, tickets e base de conhecimento"
  ]

  const bonuses = [
    "Mini Curso \"Produtividade Digital para Advogados\"",
    "Assistente de Petição Inicial com IA"
  ]

  return (
    <section className="bg-gray-50 py-16 sm:py-24">
      <div className="max-w-7xl mx-auto px-6 lg:px-8">
        {/* Título */}
        <div className="text-center mb-12">
          <h2 className="text-4xl font-bold tracking-tight text-gray-900">
            O Que Você
          </h2>
        </div>

        {/* Conteúdo */}
        <div className="max-w-4xl mx-auto">
          <div className="bg-white rounded-2xl shadow-lg border border-gray-200 p-8 sm:p-12">
            <h3 className="text-2xl font-bold text-gray-900 mb-8">
              Ao assinar o ADV DocMaster:
            </h3>

            {/* Lista de Benefícios */}
            <div className="space-y-4 mb-8">
              {benefits.map((benefit, index) => (
                <div key={index} className="flex items-start gap-3">
                  <svg className="w-6 h-6 text-indigo-600 flex-shrink-0 mt-0.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                  </svg>
                  <span className="text-gray-700">{benefit}</span>
                </div>
              ))}
            </div>

            {/* Bônus Exclusivos */}
            <div className="bg-gradient-to-r from-indigo-50 to-purple-50 rounded-xl p-6 border border-indigo-100">
              <h4 className="text-lg font-bold text-gray-900 mb-4 flex items-center gap-2">
                <span className="text-xl">🎁</span>
                Bônus Exclusivos:
              </h4>
              <div className="space-y-3">
                {bonuses.map((bonus, index) => (
                  <div key={index} className="flex items-start gap-2">
                    <span className="text-lg">🎁</span>
                    <span className="text-gray-800 font-medium">{bonus}</span>
                  </div>
                ))}
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  )
}