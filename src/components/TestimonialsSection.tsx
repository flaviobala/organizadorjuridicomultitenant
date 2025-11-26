export default function TestimonialsSection() {
  const testimonials = [
    {
      name: 'Dr. Carlos Mendes',
      role: 'Advogado Trabalhista',
      location: 'São Paulo, SP',
      image: '👨‍💼',
      text: 'Antes eu gastava 2-3 horas organizando os documentos de cada processo novo. Agora leva 5 minutos. Meu escritório triplicou a capacidade de atendimento.',
      rating: 5,
    },
    {
      name: 'Dra. Mariana Costa',
      role: 'Sócia em Escritório de Família',
      location: 'Rio de Janeiro, RJ',
      image: '👩‍⚖️',
      text: 'A função de busca nos documentos me salvou inúmeras vezes. Acho informações em segundos que antes levaria horas procurando em pilhas de papel.',
      rating: 5,
    },
    {
      name: 'Dr. Rafael Silva',
      role: 'Advogado Criminalista',
      location: 'Brasília, DF',
      image: '👨‍⚖️',
      text: 'O OCR é impressionante. Até documentos antigos e mal escaneados ficam totalmente pesquisáveis. Já virou ferramenta essencial no escritório.',
      rating: 5,
    },
    {
      name: 'Dra. Patrícia Oliveira',
      role: 'Advogada Cível',
      location: 'Belo Horizonte, MG',
      image: '👩‍💼',
      text: 'Meus estagiários agradecem todos os dias. Antes passavam o dia inteiro escaneando e organizando. Agora focam em tarefas que realmente importam.',
      rating: 5,
    },
    {
      name: 'Dr. Fernando Almeida',
      role: 'Advogado Empresarial',
      location: 'Porto Alegre, RS',
      image: '👔',
      text: 'ROI foi imediato. No primeiro mês já tinha economizado o valor da assinatura anual só em horas de trabalho. Recomendo para qualquer escritório.',
      rating: 5,
    },
    {
      name: 'Dra. Juliana Santos',
      role: 'Advogada Previdenciária',
      location: 'Recife, PE',
      image: '👩‍💻',
      text: 'Trabalho com muitos processos administrativos. Conseguir organizar tudo de forma padronizada e rápida mudou completamente minha rotina. Indispensável!',
      rating: 5,
    },
  ]

  return (
    <section className="bg-gradient-to-br from-gray-50 to-blue-50 py-16 sm:py-24">
      <div className="max-w-7xl mx-auto px-6 lg:px-8">
        {/* Header */}
        <div className="text-center mb-16">
          <h2 className="text-3xl font-bold tracking-tight text-gray-900 sm:text-4xl">
            O que advogados dizem sobre o ADV DocMaster
          </h2>
          <p className="mt-4 text-lg text-gray-600 max-w-2xl mx-auto">
            Junte-se a centenas de profissionais que já transformaram suas rotinas
          </p>

          {/* Rating geral */}
          <div className="mt-8 inline-flex items-center gap-2 bg-white rounded-full px-6 py-3 shadow-lg border border-gray-100">
            <div className="flex gap-1">
              {[1, 2, 3, 4, 5].map((star) => (
                <svg key={star} className="w-5 h-5 text-yellow-400" fill="currentColor" viewBox="0 0 20 20">
                  <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z" />
                </svg>
              ))}
            </div>
            <span className="text-lg font-semibold text-gray-900">4.9/5</span>
            <span className="text-sm text-gray-500">(500+ avaliações)</span>
          </div>
        </div>

        {/* Grid de Depoimentos */}
        <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-8">
          {testimonials.map((testimonial, index) => (
            <div
              key={index}
              className="bg-white rounded-xl shadow-lg p-6 border border-gray-100 hover:shadow-xl transition-shadow"
            >
              {/* Rating */}
              <div className="flex gap-1 mb-4">
                {[1, 2, 3, 4, 5].map((star) => (
                  <svg
                    key={star}
                    className={`w-5 h-5 ${
                      star <= testimonial.rating ? 'text-yellow-400' : 'text-gray-300'
                    }`}
                    fill="currentColor"
                    viewBox="0 0 20 20"
                  >
                    <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z" />
                  </svg>
                ))}
              </div>

              {/* Texto do depoimento */}
              <p className="text-gray-700 mb-6 leading-relaxed">
                "{testimonial.text}"
              </p>

              {/* Autor */}
              <div className="flex items-center gap-3 pt-4 border-t border-gray-100">
                <div className="text-4xl">{testimonial.image}</div>
                <div>
                  <p className="font-semibold text-gray-900">{testimonial.name}</p>
                  <p className="text-sm text-gray-600">{testimonial.role}</p>
                  <p className="text-xs text-gray-500">{testimonial.location}</p>
                </div>
              </div>
            </div>
          ))}
        </div>

        {/* Social Proof */}
        <div className="mt-16 text-center">
          <div className="inline-flex flex-col items-center gap-4 bg-white rounded-2xl p-8 shadow-lg border border-gray-100">
            <div className="flex items-center gap-8">
              <div className="text-center">
                <p className="text-4xl font-bold text-blue-600">500+</p>
                <p className="text-sm text-gray-600 mt-1">Advogados ativos</p>
              </div>
              <div className="h-12 w-px bg-gray-200"></div>
              <div className="text-center">
                <p className="text-4xl font-bold text-blue-600">50k+</p>
                <p className="text-sm text-gray-600 mt-1">Documentos organizados</p>
              </div>
              <div className="h-12 w-px bg-gray-200"></div>
              <div className="text-center">
                <p className="text-4xl font-bold text-blue-600">1000+</p>
                <p className="text-sm text-gray-600 mt-1">Horas economizadas</p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  )
}