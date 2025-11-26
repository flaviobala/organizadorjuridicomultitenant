export default function ProblemSection() {
  return (
    <section className="bg-gray-50 py-16 sm:py-24">
      <div className="max-w-4xl mx-auto px-6 lg:px-8">
        <div className="bg-white rounded-2xl shadow-lg border border-gray-200 p-8 sm:p-12">
          <div className="flex items-start gap-4">
            <div className="flex-shrink-0">
              <div className="w-12 h-12 rounded-full bg-indigo-100 flex items-center justify-center">
                <svg className="w-6 h-6 text-indigo-600" fill="currentColor" viewBox="0 0 20 20">
                  <path fillRule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7 4a1 1 0 11-2 0 1 1 0 012 0zm-1-9a1 1 0 00-1 1v4a1 1 0 102 0V6a1 1 0 00-1-1z" clipRule="evenodd" />
                </svg>
              </div>
            </div>
            <div className="flex-1">
              <h2 className="text-2xl font-bold text-gray-900 mb-4">
                Você é um advogado e sente que a tecnologia mais atrapalha do que ajuda?
              </h2>
              <p className="text-gray-600 mb-3">
                Perde horas tentando digitalizar, converter e enviar documentos para sistemas como e-SAJ, PJe e e-proc...
              </p>
              <p className="text-gray-600 mb-4">
                E ainda assim vive com medo de que algo esteja fora do padrão?
              </p>
              <p className="text-lg font-semibold text-gray-900">
                Você não está sozinho — e a culpa não é sua.
              </p>
            </div>
          </div>
        </div>
      </div>
    </section>
  )
}