import Link from 'next/link'
import Image from 'next/image'

export default function Footer() {
  const currentYear = new Date().getFullYear()

  const navigation = {
    produto: [
      { name: 'Funcionalidades', href: '#features' },
      { name: 'Para quem é?', href: '#audience' },
      { name: 'Planos', href: '#pricing' },
    ],
    legal: [
      { name: 'Termos de Uso', href: '/termos' },
      { name: 'Política de Privacidade', href: '/privacidade' },
    ],
    social: [
      { name: 'LinkedIn', href: '#' },
      { name: 'Instagram', href: '#' },
    ]
  }

  return (
    <footer className="bg-gray-900" aria-labelledby="footer-heading">
      <h2 id="footer-heading" className="sr-only">Footer</h2>
      
      <div className="mx-auto max-w-7xl px-6 pb-8 pt-16 sm:pt-20 lg:px-8">
        <div className="xl:grid xl:grid-cols-3 xl:gap-8">
          {/* Coluna 1 - Logo e Descrição */}
          <div className="space-y-8">
            <Link href="/" className="flex items-center gap-2 text-white">
              <Image src="/logo-footer.png" alt="ADV DocMaster" width={30} height={30} />
              <span className="font-bold text-xl">ADV DOCMASTER</span>
            </Link>
            <p className="text-sm leading-6 text-gray-300">
              Transformando a gestão jurídica em uma experiência simples e eficiente.
            </p>
            <p className="text-sm leading-6 text-gray-300">
              © {currentYear} ADV DOCMASTER. Todos os direitos reservados.
            </p>
          </div>

          {/* Colunas de Links */}
          <div className="mt-16 grid grid-cols-2 gap-8 xl:col-span-2 xl:mt-0">
            <div className="md:grid md:grid-cols-2 md:gap-8">
              {/* Coluna 2 - Navegação */}
              <div>
                <h3 className="text-sm font-semibold leading-6 text-white">Produto</h3>
                <ul role="list" className="mt-6 space-y-4">
                  {navigation.produto.map((item) => (
                    <li key={item.name}>
                      <Link href={item.href} className="text-sm leading-6 text-gray-300 hover:text-white">
                        {item.name}
                      </Link>
                    </li>
                  ))}
                </ul>
              </div>

              {/* Coluna 3 - Legal */}
              <div className="mt-10 md:mt-0">
                <h3 className="text-sm font-semibold leading-6 text-white">Legal</h3>
                <ul role="list" className="mt-6 space-y-4">
                  {navigation.legal.map((item) => (
                    <li key={item.name}>
                      <Link href={item.href} className="text-sm leading-6 text-gray-300 hover:text-white">
                        {item.name}
                      </Link>
                    </li>
                  ))}
                </ul>
              </div>
            </div>

            {/* Coluna 4 - Contato */}
            <div>
              <h3 className="text-sm font-semibold leading-6 text-white">Contato</h3>
              <ul role="list" className="mt-6 space-y-4">
                <li>
                  <a href="mailto:suporte@advconecta.com.br" className="text-sm leading-6 text-gray-300 hover:text-white">
                    suporte@advconecta.com.br
                  </a>
                </li>
                {navigation.social.map((item) => (
                  <li key={item.name}>
                    <Link href={item.href} className="text-sm leading-6 text-gray-300 hover:text-white">
                      {item.name}
                    </Link>
                  </li>
                ))}
              </ul>
            </div>
          </div>
        </div>
      </div>
    </footer>
  )
}