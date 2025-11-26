import Link from 'next/link'

export default function Hero() {
  return (
    <section className="bg-gradient-to-br from-[#1e1b4b] via-[#2d2667] to-[#3730a3] py-20 sm:py-32">
      <div className="max-w-7xl mx-auto px-6 lg:px-8">
        <div className="text-center">
          {/* Logo */}
          <div className="mb-12 flex justify-center">
            <img
              src="/logo-white.png"
              alt="ADV DocMaster"
              className="h-16"
              style={{ background: 'transparent' }}
            />
          </div>

          {/* Título Principal */}
          <h1 className="text-5xl font-extrabold tracking-tight text-white sm:text-6xl lg:text-7xl max-w-4xl mx-auto">
            O organizador que todo advogado precisa.
          </h1>

          {/* CTA Button */}
          <div className="mt-12">
            <Link
              href="/register"
              className="inline-flex items-center justify-center rounded-lg bg-gradient-to-r from-indigo-500 to-purple-600 px-10 py-4 text-lg font-semibold text-white shadow-2xl hover:from-indigo-600 hover:to-purple-700 transition-all hover:scale-105"
            >
              Quero Experimentar Agora →
            </Link>
          </div>
        </div>
      </div>
    </section>
  )
}
