import Link from 'next/link'

export default function Hero() {
  return (
    <section className="bg-gradient-to-br from-blue-50 via-white to-indigo-50 py-20 sm:py-32">
      <div className="max-w-7xl mx-auto px-6 lg:px-8">
        <div className="grid lg:grid-cols-2 gap-12 items-center">
          {/* Texto Principal */}
          <div>
            <h1 className="text-5xl font-extrabold tracking-tight text-gray-900 sm:text-6xl lg:text-7xl">
              Seus documentos prontos para o protocolo
              <span className="text-blue-600">.</span>
            </h1>
            <p className="mt-6 text-xl leading-8 text-gray-600">
              Seus documentos prontos para o protocolo… e para o futuro da advocacia com inteligência artificial.
            </p>
            <p className="mt-4 text-lg leading-7 text-gray-500">
              Converte, organiza e entrega a história do caso pronta para uso. Sem esforço, sem enrolação.
            </p>

            <div className="mt-10 flex flex-col sm:flex-row gap-4">
              <Link
                href="/login"
                className="inline-flex items-center justify-center rounded-lg bg-blue-600 px-8 py-4 text-lg font-semibold text-white shadow-lg hover:bg-blue-700 transition-all hover:scale-105"
              >
                Começar Agora
                <svg className="ml-2 w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13 7l5 5m0 0l-5 5m5-5H6" />
                </svg>
              </Link>
              <Link
                href="#video"
                className="inline-flex items-center justify-center rounded-lg bg-white px-8 py-4 text-lg font-semibold text-gray-900 shadow-md hover:shadow-xl border border-gray-200 transition-all hover:scale-105"
              >
                Ver Como Funciona
              </Link>
            </div>

            {/* Aviso Destaque */}
            <div className="mt-8 inline-flex items-start gap-3 bg-gradient-to-r from-blue-50 to-indigo-50 border-l-4 border-blue-600 px-6 py-4 rounded-r-xl shadow-sm">
              <svg className="w-6 h-6 text-blue-600 flex-shrink-0 mt-0.5" fill="currentColor" viewBox="0 0 20 20">
                <path fillRule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7-4a1 1 0 11-2 0 1 1 0 012 0zM9 9a1 1 0 000 2v3a1 1 0 001 1h1a1 1 0 100-2v-3a1 1 0 00-1-1H9z" clipRule="evenodd" />
              </svg>
              <div>
                <p className="text-base font-semibold text-gray-900">
                  Livre-se da sacola de documentos
                </p>
                <p className="text-sm text-gray-600 mt-1">
                  Organize tudo em minutos e tenha o caso pronto para protocolo
                </p>
              </div>
            </div>
          </div>

          {/* Imagem/Visual */}
          <div className="relative">
            <div className="absolute -inset-4 bg-gradient-to-r from-blue-400 to-indigo-400 rounded-3xl blur-2xl opacity-20"></div>
            <div className="relative rounded-2xl shadow-2xl bg-white p-2 border border-gray-100">
              <img
                src="/dashboard.png"
                alt="Dashboard do ADV DocMaster"
                className="w-full h-auto rounded-xl"
              />
            </div>

            {/* Badge flutuante */}
            <div className="absolute -bottom-4 -left-4 bg-white rounded-xl shadow-xl px-6 py-3 border border-gray-100">
              <p className="text-sm font-medium text-gray-500">Confiado por</p>
              <p className="text-2xl font-bold text-blue-600">500+ Advogados</p>
            </div>
          </div>
        </div>
      </div>
    </section>
  )
}