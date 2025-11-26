import Link from 'next/link'

export default function OfferSection() {
  return (
    <section id="offer" className="bg-white py-16 sm:py-24">
      <div className="max-w-7xl mx-auto px-6 lg:px-8">
        {/* Header */}
        <div className="text-center mb-16">
          <h2 className="text-3xl font-bold tracking-tight text-gray-900 sm:text-4xl">
            Comece hoje mesmo
          </h2>
          <p className="mt-4 text-lg text-gray-600 max-w-2xl mx-auto">
            Plano simples, transparente e personalizado para o tamanho do seu escritório
          </p>
        </div>

        {/* Offer Box */}
        <div className="max-w-4xl mx-auto">
          <div className="relative">
            {/* Badge de destaque */}
            <div className="absolute -top-6 left-1/2 transform -translate-x-1/2 z-10">
              <div className="bg-gradient-to-r from-green-500 to-emerald-600 text-white px-8 py-2 rounded-full shadow-lg text-sm font-semibold">
                🎉 Oferta Especial
              </div>
            </div>

            <div className="bg-gradient-to-br from-blue-600 to-indigo-700 rounded-3xl shadow-2xl overflow-hidden">
              <div className="p-12">
                <div className="grid lg:grid-cols-2 gap-12 items-center">
                  {/* Lado esquerdo - Oferta */}
                  <div className="text-white">
                    <h3 className="text-4xl font-bold mb-4">
                      Plano Personalizado
                    </h3>
                    <p className="text-2xl text-blue-100 mb-8">
                      Pagamento único anual
                    </p>

                    {/* Lista de benefícios */}
                    <div className="space-y-4 mb-8">
                      {[
                        'Upload ilimitado de documentos',
                        'OCR com Google Vision API (95-98% precisão)',
                        'Organização automática inteligente',
                        'Busca instantânea em todos os documentos',
                        'Export em PDF pesquisável',
                        'Armazenamento seguro em nuvem',
                        'Suporte técnico prioritário',
                        'Atualizações e melhorias contínuas',
                      ].map((benefit, index) => (
                        <div key={index} className="flex items-start gap-3">
                          <svg className="w-6 h-6 text-green-400 flex-shrink-0 mt-0.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2.5} d="M5 13l4 4L19 7" />
                          </svg>
                          <span className="text-blue-50">{benefit}</span>
                        </div>
                      ))}
                    </div>

                    {/* Garantia */}
                    <div className="bg-white/10 backdrop-blur-sm rounded-xl p-4 border border-white/20">
                      <div className="flex items-center gap-3">
                        <svg className="w-8 h-8 text-green-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z" />
                        </svg>
                        <div>
                          <p className="font-semibold text-white">Garantia de 30 dias</p>
                          <p className="text-sm text-blue-100">Se não gostar, devolvemos 100% do valor</p>
                        </div>
                      </div>
                    </div>
                  </div>

                  {/* Lado direito - CTA */}
                  <div className="bg-white rounded-2xl p-8 shadow-2xl">
                    <div className="text-center mb-6">
                      <p className="text-sm font-medium text-gray-600 mb-2">Valor personalizado para</p>
                      <p className="text-5xl font-bold text-gray-900 mb-2">Seu Escritório</p>
                      <p className="text-gray-600">Pagamento único anual</p>
                    </div>

                    <div className="space-y-4 mb-6">
                      <div className="flex items-center justify-between p-3 bg-blue-50 rounded-lg">
                        <span className="text-gray-700">Usuários simultâneos</span>
                        <span className="font-semibold text-gray-900">Ilimitados</span>
                      </div>
                      <div className="flex items-center justify-between p-3 bg-blue-50 rounded-lg">
                        <span className="text-gray-700">Armazenamento</span>
                        <span className="font-semibold text-gray-900">Conforme uso</span>
                      </div>
                      <div className="flex items-center justify-between p-3 bg-blue-50 rounded-lg">
                        <span className="text-gray-700">Suporte</span>
                        <span className="font-semibold text-gray-900">Prioritário</span>
                      </div>
                    </div>

                    <Link
                      href="/login"
                      className="block w-full text-center rounded-lg bg-gradient-to-r from-blue-600 to-indigo-600 px-8 py-4 text-lg font-bold text-white shadow-lg hover:from-blue-700 hover:to-indigo-700 transition-all hover:scale-105 mb-4"
                    >
                      Solicitar Proposta Personalizada
                    </Link>

                    <p className="text-center text-sm text-gray-500">
                      Entre em contato para receber uma proposta sob medida
                    </p>
                  </div>
                </div>
              </div>

              {/* Footer do box */}
              <div className="bg-blue-800/50 backdrop-blur-sm px-12 py-6">
                <div className="flex flex-wrap items-center justify-center gap-8 text-blue-100">
                  <div className="flex items-center gap-2">
                    <svg className="w-5 h-5" fill="currentColor" viewBox="0 0 20 20">
                      <path fillRule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clipRule="evenodd" />
                    </svg>
                    <span className="text-sm">Pagamento seguro</span>
                  </div>
                  <div className="flex items-center gap-2">
                    <svg className="w-5 h-5" fill="currentColor" viewBox="0 0 20 20">
                      <path fillRule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clipRule="evenodd" />
                    </svg>
                    <span className="text-sm">Dados criptografados</span>
                  </div>
                  <div className="flex items-center gap-2">
                    <svg className="w-5 h-5" fill="currentColor" viewBox="0 0 20 20">
                      <path fillRule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clipRule="evenodd" />
                    </svg>
                    <span className="text-sm">Suporte 24/7</span>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Urgência */}
        <div className="mt-12 text-center">
          <div className="inline-flex items-center gap-2 bg-yellow-50 border-l-4 border-yellow-500 px-6 py-4 rounded-r-xl">
            <svg className="w-6 h-6 text-yellow-600" fill="currentColor" viewBox="0 0 20 20">
              <path fillRule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm1-12a1 1 0 10-2 0v4a1 1 0 00.293.707l2.828 2.829a1 1 0 101.415-1.415L11 9.586V6z" clipRule="evenodd" />
            </svg>
            <p className="text-gray-800">
              <span className="font-semibold">Vagas limitadas</span> - Estamos aceitando novos escritórios por ordem de chegada
            </p>
          </div>
        </div>
      </div>
    </section>
  )
}