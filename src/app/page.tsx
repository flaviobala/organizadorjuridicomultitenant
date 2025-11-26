import Navbar from '@/components/Navbar'
import Hero from '@/components/Hero'
import VideoSection from '@/components/VideoSection'
import LeadSection from '@/components/LeadSection'
import StorySection from '@/components/StorySection'
import FeaturesSection from '@/components/FeaturesSection'
import TestimonialsSection from '@/components/TestimonialsSection'
import PricingSection from '@/components/PricingSection'
import OfferSection from '@/components/OfferSection'
import FAQSection from '@/components/FAQSection'
import Footer from '@/components/Footer'

export default function LandingPage() {
  return (
    <main className="min-h-screen">
      <Navbar />
      <Hero />
      <VideoSection />
      <LeadSection />
      <StorySection />
      <FeaturesSection />
      <TestimonialsSection />
      <PricingSection />
      <OfferSection />
      <FAQSection />
      <Footer />
    </main>
  )
}