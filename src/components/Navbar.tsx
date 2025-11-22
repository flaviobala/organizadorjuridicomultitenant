import Image from 'next/image'
import Link from 'next/link'

export default function Navbar() {
  return (
    <nav className="w-full sticky top-0 bg-white shadow-sm z-50">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex justify-between items-center py-4">
          {/* Logo */}
          <Link href="/" className="flex items-center gap-2">
            <Image src="/logo.png" alt="Logo" width={40} height={40} />
            <span className="font-bold text-xl text-blue-700">
              ADV DocMaster
            </span>
          </Link>

          {/* Navigation Links - Center */}
          <div className="hidden md:flex gap-6 text-sm font-medium text-gray-600">
            <Link href="#features" className="hover:text-blue-700">
              Funcionalidades
            </Link>
            <Link href="#audience" className="hover:text-blue-700">
              Para quem é?
            </Link>
            <Link href="#pricing" className="hover:text-blue-700">
              Planos
            </Link>
          </div>

          {/* Actions - Right */}
          <div className="flex items-center gap-4">
            <Link
              href="/login"
              className="text-sm font-medium text-gray-600 hover:text-blue-700"
            >
              Já é cliente? Entrar
            </Link>
            <Link
              href="#pricing"
              className="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md shadow-sm text-white bg-blue-600 hover:bg-blue-700"
            >
              Começar agora
            </Link>
          </div>
        </div>
      </div>
    </nav>
  )
}