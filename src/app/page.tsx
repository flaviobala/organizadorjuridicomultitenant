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
              <div className="mt-10 flex items-center gap-x-6">
                <Link
                  href="#pricing"
                  className="rounded-md bg-blue-600 px-6 py-3 text-base font-semibold text-white shadow-sm hover:bg-blue-700"
                >
                  Assine por R$99/mês
                </Link>
                <Link
                  href="#demo"
                  className="text-base font-semibold leading-6 text-gray-900 hover:text-blue-600"
                >
                  Agendar uma demonstração <span aria-hidden="true">→</span>
                </Link>
              </div>
            </div>

            {/* Imagem/Visual */}
            <div className="relative">
              <div className="aspect-[4/3] overflow-hidden rounded-lg shadow-xl bg-gray-100 flex items-center justify-center">
               <img
                  src="/dashboard.png"
                  alt="Imagem ilustrativa do sistema jurídico"
                  className="object-cover object-center max-w-full max-h-full object-contain"
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