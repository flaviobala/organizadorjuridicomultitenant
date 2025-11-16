import Navbar from '@/components/Navbar'
import FeaturesSection from '@/components/FeaturesSection'
import PricingSection from '@/components/PricingSection'
import Footer from '@/components/Footer'
import Link from 'next/link'

export default function LandingPage() {
  return (
    <main className="min-h-screen bg-white">
      <Navbar />
      
      {/* Hero Section */}
      <section className="bg-white py-24 sm:py-32">
        <div className="max-w-7xl mx-auto px-6 lg:px-8">
          <div className="grid lg:grid-cols-2 gap-16 items-center">
            {/* Texto Principal */}
            <div>
              <h1 className="text-4xl font-extrabold tracking-tight text-gray-900 sm:text-6xl">
                Menos burocracia, mais advocacia.
              </h1>
              <p className="mt-6 text-lg leading-8 text-gray-600">
                Organize seus processos, documentos, clientes e prazos em uma plataforma única, 
                segura e fácil de usar.
              </p>
              <div className="mt-10">
                <Link
                  href="#pricing"
                  className="inline-block rounded-md bg-blue-600 px-8 py-3 text-base font-semibold text-white shadow-sm hover:bg-blue-700"
                >
                  Plano Personalizado
                </Link>

                {/* Aviso chamativo */}
                <div className="mt-6 inline-flex items-center gap-2 bg-gradient-to-r from-blue-50 to-indigo-50 border-l-4 border-blue-600 px-4 py-3 rounded-r-lg shadow-sm">
                  <svg className="w-5 h-5 text-blue-600 flex-shrink-0" fill="currentColor" viewBox="0 0 20 20">
                    <path fillRule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7-4a1 1 0 11-2 0 1 1 0 012 0zM9 9a1 1 0 000 2v3a1 1 0 001 1h1a1 1 0 100-2v-3a1 1 0 00-1-1H9z" clipRule="evenodd" />
                  </svg>
                  <p className="text-sm font-medium text-gray-800">
                    Livre-se da sacola de documentos que chega até você em minutos.
                  </p>
                </div>
              </div>
            </div>

            {/* Imagem/Visual */}
            <div className="relative">
              <div className="rounded-xl shadow-2xl bg-gradient-to-br from-gray-50 to-gray-100 p-4 border border-gray-200">
               <img
                  src="/dashboard.png"
                  alt="Imagem ilustrativa do sistema jurídico"
                  className="w-full h-auto rounded-lg"
                />
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Features Section */}
      <FeaturesSection />

      {/* Pricing Section */}
      <PricingSection />

      {/* Footer */}
      <Footer />
    </main>
  )
}