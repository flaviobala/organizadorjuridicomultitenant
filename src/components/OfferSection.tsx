import Link from 'next/link'

export default function OfferSection() {
  const benefits = [
    "100% online, acessível de qualquer lugar",
    "Funciona com scanner comum ou celular",
    "Compatível com todos os tribunais",
    "Não precisa de equipamentos caros",
    "Atualizações automáticas",
    "Suporte técnico rápido e humano"
  ]

  return (
    <section id="offer" className="bg-gradient-to-br from-[#1e1b4b] via-[#2d2667] to-[#3730a3] py-16 sm:py-24">
      <div className="max-w-7xl mx-auto px-6 lg:px-8">
        <div className="max-w-5xl mx-auto">
          {/* Conteúdo Principal */}
          <div className="text-center text-white mb-12">
            <h2 className="text-4xl sm:text-5xl font-bold mb-6">
              Teste Grátis por 3 Dias ou até 15 Documentos
            </h2>
            <p className="text-xl text-indigo-100 mb-4">
              Tempo suficiente para ver, na prática, como a plataforma transforma sua rotina jurídica.
            </p>
            <p className="text-lg text-indigo-200">
              Se não perceber melhorias claras, é só cancelar — sem cobranças, sem burocracia.
            </p>
          </div>

          {/* Botão CTA */}
          <div className="text-center mb-12">
            <Link
              href="/register"
              className="inline-flex items-center justify-center rounded-lg bg-gradient-to-r from-indigo-500 to-purple-600 px-12 py-5 text-xl font-bold text-white shadow-2xl hover:from-indigo-600 hover:to-purple-700 transition-all hover:scale-105"
            >
              QUERO EXPERIMENTAR O ADV DOCMASTER AGORA →
            </Link>
          </div>

          {/* Grid de Benefícios */}
          <div className="grid md:grid-cols-2 gap-6 mt-12">
            {benefits.map((benefit, index) => (
              <div key={index} className="flex items-center gap-3 text-white">
                <svg className="w-6 h-6 text-green-400 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
                <span className="text-lg">{benefit}</span>
              </div>
            ))}
          </div>
        </div>
      </div>
    </section>
  )
}