import Link from 'next/link'

export default function MaintenancePage() {
  return (
    <div className="min-h-screen bg-gradient-to-br from-[#1e1b4b] via-[#2d2667] to-[#3730a3] flex items-center justify-center px-6">
      <div className="max-w-2xl w-full text-center">
        {/* Logo */}
        <div className="mb-12 flex justify-center">
          <img
            src="/logo-white.png"
            alt="ADV DocMaster"
            className="h-20"
            style={{ background: 'transparent' }}
          />
        </div>

        {/* Ícone de Manutenção */}
        <div className="mb-8">
          <svg className="w-24 h-24 mx-auto text-indigo-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5} d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z" />
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5} d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
          </svg>
        </div>

        {/* Título */}
        <h1 className="text-5xl font-extrabold text-white mb-6">
          Estamos em Manutenção
        </h1>

        {/* Descrição */}
        <p className="text-xl text-indigo-100 mb-4">
          Nossa equipe está implementando melhorias na plataforma para oferecer uma experiência ainda melhor.
        </p>

        <p className="text-lg text-indigo-200 mb-8">
          O sistema voltará ao ar em breve. Agradecemos a compreensão!
        </p>

        {/* Info Box */}
        <div className="bg-white/10 backdrop-blur-sm rounded-2xl p-6 border border-white/20 mb-8">
          <p className="text-white text-lg mb-2">
            <strong>Já é cliente?</strong>
          </p>
          <p className="text-indigo-100">
            O sistema continua funcionando normalmente. Faça login para acessar.
          </p>
        </div>

        {/* Botão Login */}
        <Link
          href="/login"
          className="inline-flex items-center justify-center rounded-lg bg-white px-8 py-4 text-lg font-semibold text-indigo-900 shadow-xl hover:bg-indigo-50 transition-all hover:scale-105"
        >
          Acessar o Sistema
          <svg className="ml-2 w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13 7l5 5m0 0l-5 5m5-5H6" />
          </svg>
        </Link>

        {/* Rodapé */}
        <div className="mt-12 text-indigo-300 text-sm">
          <p>Dúvidas? Entre em contato: suporte@advdocmaster.com.br</p>
        </div>
      </div>
    </div>
  )
}