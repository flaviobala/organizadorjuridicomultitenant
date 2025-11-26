export default function VideoSection() {
  return (
    <section id="video" className="bg-white py-16 sm:py-24">
      <div className="max-w-7xl mx-auto px-6 lg:px-8">
        <div className="text-center mb-12">
          <h2 className="text-3xl font-bold tracking-tight text-gray-900 sm:text-4xl">
            Veja como é simples
          </h2>
          <p className="mt-4 text-lg text-gray-600">
            Em menos de 3 minutos você entende como o ADV DocMaster vai revolucionar seu escritório
          </p>
        </div>

        <div className="max-w-4xl mx-auto">
          {/* Container do vídeo com aspect ratio 16:9 */}
          <div className="relative rounded-2xl overflow-hidden shadow-2xl bg-gray-900">
            <div className="aspect-video">
              {/* Substitua o src abaixo pelo link do seu vídeo do YouTube/Vimeo */}
              <iframe
                className="w-full h-full"
                src="https://www.youtube.com/embed/dQw4w9WgXcQ"
                title="Vídeo demonstrativo ADV DocMaster"
                allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
                allowFullScreen
              ></iframe>

              {/* Alternativa: Placeholder se não tiver vídeo ainda */}
              {/* <div className="w-full h-full flex items-center justify-center bg-gradient-to-br from-blue-900 to-indigo-900">
                <div className="text-center">
                  <svg className="mx-auto h-20 w-20 text-white opacity-75 mb-4" fill="currentColor" viewBox="0 0 20 20">
                    <path d="M10 18a8 8 0 100-16 8 8 0 000 16zM9.555 7.168A1 1 0 008 8v4a1 1 0 001.555.832l3-2a1 1 0 000-1.664l-3-2z" />
                  </svg>
                  <p className="text-white text-xl font-semibold">Vídeo em breve</p>
                  <p className="text-blue-200 mt-2">Estamos preparando um conteúdo incrível para você</p>
                </div>
              </div> */}
            </div>
          </div>

          {/* Stats abaixo do vídeo */}
          <div className="mt-12 grid grid-cols-3 gap-8 text-center">
            <div className="bg-gradient-to-br from-blue-50 to-indigo-50 rounded-xl p-6 border border-blue-100">
              <p className="text-3xl font-bold text-blue-600">3 min</p>
              <p className="text-sm text-gray-600 mt-1">Para organizar um processo completo</p>
            </div>
            <div className="bg-gradient-to-br from-blue-50 to-indigo-50 rounded-xl p-6 border border-blue-100">
              <p className="text-3xl font-bold text-blue-600">95%</p>
              <p className="text-sm text-gray-600 mt-1">De precisão no OCR</p>
            </div>
            <div className="bg-gradient-to-br from-blue-50 to-indigo-50 rounded-xl p-6 border border-blue-100">
              <p className="text-3xl font-bold text-blue-600">24/7</p>
              <p className="text-sm text-gray-600 mt-1">Disponível sempre que precisar</p>
            </div>
          </div>
        </div>
      </div>
    </section>
  )
}