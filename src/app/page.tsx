import Navbar from '@/components/Navbar'
import Hero from '@/components/Hero'
import VideoSection from '@/components/VideoSection'
import ProblemSection from '@/components/ProblemSection'
import StorySection from '@/components/StorySection'
import FeaturesSection from '@/components/FeaturesSection'
import TestimonialsSection from '@/components/TestimonialsSection'
import BenefitsSection from '@/components/BenefitsSection'
import OfferSection from '@/components/OfferSection'
import FAQSection from '@/components/FAQSection'
import Footer from '@/components/Footer'

export default function LandingPage() {
  return (
    <main className="min-h-screen">
      <Navbar />
      <Hero />
      <VideoSection />
      <ProblemSection />
      <StorySection />
      <FeaturesSection />
      <TestimonialsSection />
      <BenefitsSection />
      <OfferSection />
      <FAQSection />
      <Footer />
    </main>
  )
}