export default function VideoSection() {
  return (
    <section id="video" className="bg-white py-16 sm:py-24">
      <div className="max-w-7xl mx-auto px-6 lg:px-8">
        <div className="text-center mb-12">
          <h2 className="text-3xl font-bold tracking-tight text-gray-900 sm:text-4xl">
            Veja como é simples
          </h2>
          <p className="mt-4 text-lg text-gray-600">
            Em menos de 5 minutos você entende como o ADV DocMaster vai revolucionar seu escritório
          </p>
        </div>

        <div className="max-w-4xl mx-auto">
          {/* Container do vídeo com aspect ratio 16:9 */}
          <div className="relative rounded-2xl overflow-hidden shadow-2xl bg-gray-900">
            <div className="aspect-video">
              <video
                className="w-full h-full object-cover"
                controls
                preload="metadata"
              >
                <source src="/videoIntrodutorio.mp4" type="video/mp4" />
                Seu navegador não suporta o elemento de vídeo.
              </video>
            </div>
          </div>
        </div>
      </div>
    </section>
  )
}