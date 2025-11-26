export default function StorySection() {
  return (
    <section className="bg-white py-16 sm:py-24">
      <div className="max-w-7xl mx-auto px-6 lg:px-8">
        {/* Header */}
        <div className="text-center mb-16">
          <h2 className="text-3xl font-bold tracking-tight text-gray-900 sm:text-4xl">
            Você reconhece essa situação?
          </h2>
          <p className="mt-4 text-lg text-gray-600 max-w-2xl mx-auto">
            A história de todo advogado que lida com processos físicos...
          </p>
        </div>

        {/* Timeline de Problemas */}
        <div className="relative max-w-4xl mx-auto">
          {/* Linha central */}
          <div className="absolute left-1/2 transform -translate-x-1/2 w-1 h-full bg-gradient-to-b from-red-200 via-yellow-200 to-green-200"></div>

          {/* Problema 1 */}
          <div className="relative mb-12">
            <div className="flex items-center justify-between gap-8">
              <div className="flex-1 text-right">
                <div className="bg-red-50 border-l-4 border-red-500 rounded-r-xl p-6 inline-block">
                  <h3 className="text-xl font-bold text-gray-900 mb-2">
                    📦 A sacola chega no escritório
                  </h3>
                  <p className="text-gray-600">
                    Centenas de páginas desordenadas, documentos em formatos diferentes, fotos borradas,
                    papéis amassados. O cliente esperando uma resposta rápida.
                  </p>
                </div>
              </div>
              <div className="absolute left-1/2 transform -translate-x-1/2 w-12 h-12 bg-red-500 rounded-full flex items-center justify-center text-white font-bold text-lg z-10 shadow-lg">
                1
              </div>
              <div className="flex-1"></div>
            </div>
          </div>

          {/* Problema 2 */}
          <div className="relative mb-12">
            <div className="flex items-center justify-between gap-8">
              <div className="flex-1"></div>
              <div className="absolute left-1/2 transform -translate-x-1/2 w-12 h-12 bg-orange-500 rounded-full flex items-center justify-center text-white font-bold text-lg z-10 shadow-lg">
                2
              </div>
              <div className="flex-1 text-left">
                <div className="bg-orange-50 border-r-4 border-orange-500 rounded-l-xl p-6 inline-block">
                  <h3 className="text-xl font-bold text-gray-900 mb-2">
                    ⏱️ Horas desperdiçadas
                  </h3>
                  <p className="text-gray-600">
                    Seu estagiário passa horas escaneando, renomeando arquivos, tentando organizar,
                    reescrevendo trechos que o scanner não conseguiu ler direito.
                  </p>
                </div>
              </div>
            </div>
          </div>

          {/* Problema 3 */}
          <div className="relative mb-12">
            <div className="flex items-center justify-between gap-8">
              <div className="flex-1 text-right">
                <div className="bg-yellow-50 border-l-4 border-yellow-500 rounded-r-xl p-6 inline-block">
                  <h3 className="text-xl font-bold text-gray-900 mb-2">
                    😓 Trabalho manual repetitivo
                  </h3>
                  <p className="text-gray-600">
                    Revisar documento por documento, criar índice, montar o timeline do caso,
                    formatar para o padrão do escritório. E ainda tem que fazer relatório para o sócio.
                  </p>
                </div>
              </div>
              <div className="absolute left-1/2 transform -translate-x-1/2 w-12 h-12 bg-yellow-500 rounded-full flex items-center justify-center text-white font-bold text-lg z-10 shadow-lg">
                3
              </div>
              <div className="flex-1"></div>
            </div>
          </div>

          {/* Solução */}
          <div className="relative">
            <div className="flex items-center justify-between gap-8">
              <div className="flex-1"></div>
              <div className="absolute left-1/2 transform -translate-x-1/2 w-16 h-16 bg-gradient-to-br from-green-500 to-emerald-600 rounded-full flex items-center justify-center text-white font-bold text-2xl z-10 shadow-xl">
                ✓
              </div>
              <div className="flex-1 text-left">
                <div className="bg-gradient-to-br from-green-50 to-emerald-50 border-r-4 border-green-500 rounded-l-xl p-6 inline-block shadow-lg">
                  <h3 className="text-2xl font-bold text-gray-900 mb-3">
                    🚀 ADV DocMaster resolve tudo isso
                  </h3>
                  <p className="text-gray-700 mb-4">
                    Upload de múltiplos arquivos em qualquer formato. OCR inteligente.
                    Organização automática. Documentos pesquisáveis. Timeline gerada.
                    Relatório pronto.
                  </p>
                  <p className="text-green-700 font-semibold text-lg">
                    Em 3 minutos, não 3 horas.
                  </p>
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* CTA */}
        <div className="mt-16 text-center">
          <div className="inline-flex flex-col items-center gap-4 bg-gradient-to-r from-blue-50 to-indigo-50 rounded-2xl p-8 border border-blue-100">
            <p className="text-2xl font-bold text-gray-900">
              Pare de perder tempo com trabalho manual
            </p>
            <p className="text-gray-600 text-lg">
              Deixe a tecnologia fazer o trabalho pesado enquanto você foca no que realmente importa: o Direito.
            </p>
            <a
              href="#offer"
              className="inline-flex items-center justify-center rounded-lg bg-blue-600 px-8 py-4 text-lg font-semibold text-white shadow-lg hover:bg-blue-700 transition-all hover:scale-105 mt-2"
            >
              Ver planos e começar agora
              <svg className="ml-2 w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13 7l5 5m0 0l-5 5m5-5H6" />
              </svg>
            </a>
          </div>
        </div>
      </div>
    </section>
  )
}