export default function TestimonialsSection() {
  const testimonials = [
    {
      quote: "Ganhei mais tempo, mais controle e meus clientes perceberam a diferença.",
      author: "Dr. Felipe Souza"
    },
    {
      quote: "Tudo fica pronto em minutos. Não sei como conseguir trabalhar antes sem isso.",
      author: "Dra. Camila Oliveira"
    }
  ]

  return (
    <section className="bg-white py-16 sm:py-24">
      <div className="max-w-7xl mx-auto px-6 lg:px-8">
        {/* Título */}
        <div className="text-center mb-12">
          <h2 className="text-4xl font-bold tracking-tight text-gray-900">
            3 Comprovados
          </h2>
        </div>

        {/* Estatística Destaque */}
        <div className="max-w-4xl mx-auto mb-12">
          <div className="bg-gradient-to-r from-indigo-50 to-purple-50 border-l-4 border-indigo-600 rounded-r-2xl p-8">
            <p className="text-lg text-gray-900 flex items-start gap-3">
              <span className="text-2xl">📊</span>
              <span>
                <strong>Escritórios que utilizam o ADV DocMaster relatam aumento de até 90% na velocidade de preparação documental, com organização total e redução de erros técnicos.</strong>
              </span>
            </p>
          </div>
        </div>

        {/* Depoimentos */}
        <div className="grid md:grid-cols-2 gap-8 max-w-5xl mx-auto">
          {testimonials.map((testimonial, index) => (
            <div
              key={index}
              className="bg-white rounded-2xl shadow-lg border border-gray-200 p-8 hover:shadow-xl transition-shadow"
            >
              <div className="mb-6">
                <svg className="w-10 h-10 text-indigo-200" fill="currentColor" viewBox="0 0 24 24">
                  <path d="M14.017 21v-7.391c0-5.704 3.731-9.57 8.983-10.609l.995 2.151c-2.432.917-3.995 3.638-3.995 5.849h4v10h-9.983zm-14.017 0v-7.391c0-5.704 3.748-9.57 9-10.609l.996 2.151c-2.433.917-3.996 3.638-3.996 5.849h3.983v10h-9.983z" />
                </svg>
              </div>
              <p className="text-gray-700 text-lg italic mb-6">
                "{testimonial.quote}"
              </p>
              <p className="text-gray-900 font-semibold">
                — {testimonial.author}
              </p>
            </div>
          ))}
        </div>
      </div>
    </section>
  )
}