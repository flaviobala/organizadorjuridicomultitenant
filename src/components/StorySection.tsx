export default function StorySection() {
  return (
    <section className="bg-white py-16 sm:py-24">
      <div className="max-w-7xl mx-auto px-6 lg:px-8">
        {/* Título */}
        <div className="text-center mb-12">
          <h2 className="text-4xl font-bold tracking-tight text-gray-900">
            Nossa História
          </h2>
        </div>

        {/* Conteúdo */}
        <div className="max-w-4xl mx-auto">
          <div className="bg-white rounded-2xl shadow-lg border border-gray-200 p-8 sm:p-12">
            <div className="prose prose-lg max-w-none text-gray-700">
              <p className="mb-4">
                Meu nome é <strong>Anderson Barros</strong>. Sou advogado especialista em inteligência artificial pela PUC Campinas e Paraná, e atuo com informática desde 1990, na época do MS-DOS.
              </p>

              <p className="mb-4">
                Durante anos, enfrentei o caos das tarefas manuais: digitalização, conversão, organização… tudo isso consumindo tempo e energia que deveriam estar voltados para o trabalho jurídico.
              </p>

              <p className="mb-6">
                Foi então que eu e meu amigo <strong>Flávio Henrique</strong>, programador e estudante de engenharia de software, decidimos criar uma solução prática, acessível e altamente técnica para esse problema.
              </p>

              <div className="bg-gradient-to-r from-indigo-50 to-purple-50 border-l-4 border-indigo-600 rounded-r-xl p-6 my-8">
                <p className="text-lg font-semibold text-gray-900 mb-2">
                  O resultado é o ADV DocMaster: uma plataforma pensada com profundidade, construída com base em experiência real e desenvolvida para eliminar o caos documental do dia a dia jurídico.
                </p>
              </div>

              <p className="text-gray-700">
                Hoje, essa ferramenta já transformou a rotina de centenas de profissionais e pode transformar a sua também.
              </p>
            </div>
          </div>
        </div>
      </div>
    </section>
  )
}