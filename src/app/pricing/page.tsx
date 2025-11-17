'use client'

import PricingSection from '@/components/PricingSection'
import Link from 'next/link'
import { ArrowLeft } from 'lucide-react'

export default function PricingPage() {
  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100">
      {/* Header */}
      <header className="bg-white shadow-sm border-b border-gray-200">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4">
          <div className="flex items-center justify-between">
            <Link
              href="/"
              className="flex items-center text-gray-600 hover:text-gray-900 transition-colors"
            >
              <ArrowLeft className="w-5 h-5 mr-2" />
              Voltar para início
            </Link>
          </div>
        </div>
      </header>

      {/* Pricing Section */}
      <div className="py-12">
        <PricingSection />
      </div>
    </div>
  )
}
