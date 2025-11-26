'use client'

import { useState } from 'react'

export default function FAQSection() {
  const [openIndex, setOpenIndex] = useState<number | null>(0)

  const faqs = [
    {
      question: 'Como funciona o OCR? Ele realmente lê qualquer documento?',
      answer: 'Usamos o Google Vision API, que tem 95-98% de precisão. Ele consegue ler documentos escaneados, fotos de celular, PDFs escaneados e até documentos antigos ou com qualidade ruim. O texto extraído fica pesquisável e pode ser copiado/colado.',
    },
    {
      question: 'Quanto tempo leva para organizar um processo completo?',
      answer: 'Em média, 3-5 minutos para um processo com 50-100 páginas. Você faz upload de todos os arquivos de uma vez, o sistema processa automaticamente e entrega tudo organizado, renomeado e pesquisável. O que antes levava horas agora leva minutos.',
    },
    {
      question: 'Meus dados estão seguros? E o sigilo profissional?',
      answer: 'Sim! Todos os dados são criptografados (SSL/TLS), armazenados em servidores seguros com backup diário. Cada escritório tem seu ambiente isolado (multi-tenant). Cumprimos LGPD e boas práticas de segurança. Seus documentos nunca são compartilhados ou usados para outros fins.',
    },
    {
      question: 'Posso testar antes de contratar?',
      answer: 'Sim! Oferecemos demonstração personalizada para seu escritório. Entre em contato pelo formulário acima e agendaremos uma apresentação ao vivo, onde você pode testar com seus próprios documentos.',
    },
    {
      question: 'Aceita quais formatos de arquivo?',
      answer: 'Praticamente todos: PDF, DOCX, DOC, JPG, PNG, TIFF, BMP, e mais. Até fotos tiradas com celular funcionam. O sistema converte tudo automaticamente para PDF pesquisável e organizado.',
    },
    {
      question: 'Funciona para escritórios pequenos ou só para grandes?',
      answer: 'Funciona para qualquer tamanho! Desde advogados autônomos até escritórios com dezenas de profissionais. O plano é personalizado conforme o tamanho e necessidades do seu escritório.',
    },
    {
      question: 'Como é o suporte? Tem treinamento?',
      answer: 'Suporte técnico prioritário via email/WhatsApp. O sistema é intuitivo e não precisa de treinamento complexo, mas oferecemos onboarding inicial e materiais de apoio. Respondemos dúvidas em até 24 horas.',
    },
    {
      question: 'Posso cancelar se não gostar?',
      answer: 'Sim! Oferecemos garantia de 30 dias. Se não ficar satisfeito, devolvemos 100% do valor pago, sem perguntas e sem burocracia. Nosso objetivo é que você economize tempo, não que fique preso a algo que não funciona para você.',
    },
    {
      question: 'Tem limite de armazenamento ou de documentos?',
      answer: 'Não há limite de documentos. O armazenamento é dimensionado conforme o uso do escritório. Para escritórios pequenos/médios, dificilmente haverá problema. Para grandes volumes, conversamos sobre a melhor configuração na proposta personalizada.',
    },
    {
      question: 'Como é o pagamento? Aceita parcelamento?',
      answer: 'Pagamento único anual via boleto, PIX ou cartão de crédito. Emitimos nota fiscal. Para pagamento no cartão, é possível parcelar conforme bandeira e limite. Entre em contato para mais detalhes.',
    },
  ]

  return (
    <section className="bg-gradient-to-br from-gray-50 to-blue-50 py-16 sm:py-24">
      <div className="max-w-4xl mx-auto px-6 lg:px-8">
        {/* Header */}
        <div className="text-center mb-16">
          <h2 className="text-3xl font-bold tracking-tight text-gray-900 sm:text-4xl">
            Perguntas Frequentes
          </h2>
          <p className="mt-4 text-lg text-gray-600">
            Tudo o que você precisa saber sobre o ADV DocMaster
          </p>
        </div>

        {/* FAQ Accordion */}
        <div className="space-y-4">
          {faqs.map((faq, index) => (
            <div
              key={index}
              className="bg-white rounded-xl shadow-md border border-gray-100 overflow-hidden transition-all hover:shadow-lg"
            >
              <button
                onClick={() => setOpenIndex(openIndex === index ? null : index)}
                className="w-full flex items-center justify-between p-6 text-left hover:bg-gray-50 transition-colors"
              >
                <span className="text-lg font-semibold text-gray-900 pr-8">
                  {faq.question}
                </span>
                <svg
                  className={`w-6 h-6 text-blue-600 flex-shrink-0 transition-transform ${
                    openIndex === index ? 'transform rotate-180' : ''
                  }`}
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 9l-7 7-7-7" />
                </svg>
              </button>

              <div
                className={`overflow-hidden transition-all duration-300 ${
                  openIndex === index ? 'max-h-96' : 'max-h-0'
                }`}
              >
                <div className="px-6 pb-6 pt-2">
                  <p className="text-gray-600 leading-relaxed">{faq.answer}</p>
                </div>
              </div>
            </div>
          ))}
        </div>

        {/* CTA Final */}
        <div className="mt-16 text-center bg-white rounded-2xl shadow-xl p-8 border border-gray-100">
          <h3 className="text-2xl font-bold text-gray-900 mb-4">
            Ainda tem dúvidas?
          </h3>
          <p className="text-gray-600 mb-6">
            Entre em contato conosco. Teremos prazer em responder todas as suas perguntas.
          </p>
          <div className="flex flex-col sm:flex-row gap-4 justify-center">
            <a
              href="#lead"
              className="inline-flex items-center justify-center rounded-lg bg-blue-600 px-8 py-3 text-base font-semibold text-white shadow-lg hover:bg-blue-700 transition-all hover:scale-105"
            >
              Falar com a equipe
            </a>
            <a
              href="mailto:contato@advdocmaster.com.br"
              className="inline-flex items-center justify-center rounded-lg bg-white px-8 py-3 text-base font-semibold text-gray-900 shadow-md border border-gray-200 hover:shadow-lg transition-all hover:scale-105"
            >
              Enviar email
            </a>
          </div>
        </div>
      </div>
    </section>
  )
}