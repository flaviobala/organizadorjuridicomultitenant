'use client'

import { useState } from 'react'
import { useRouter } from 'next/navigation'
import { useForm } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import { z } from 'zod'
import Image from 'next/image'
import { Eye, EyeOff, Scale, ArrowLeft } from 'lucide-react'
import Link from 'next/link'

const loginSchema = z.object({
  email: z.string().email('Email inválido'),
  password: z.string().min(1, 'Senha é obrigatória'),
})

type LoginFormData = z.infer<typeof loginSchema>

export default function LoginPage() {
  const router = useRouter()
  const [showPassword, setShowPassword] = useState(false)
  const [isLoading, setIsLoading] = useState(false)
  const [rememberMe, setRememberMe] = useState(false)
  const [message, setMessage] = useState<{ type: 'error' | 'success', text: string } | null>(null)

  const loginForm = useForm<LoginFormData>({
    resolver: zodResolver(loginSchema),
  })

  const onLogin = async (data: LoginFormData) => {
    setIsLoading(true)
    setMessage(null)

    try {
      const response = await fetch('/api/auth/login', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ ...data, rememberMe }),
      })

      const result = await response.json()

      if (result.success) {
        localStorage.setItem('token', result.token)
        localStorage.setItem('user', JSON.stringify(result.user))
        setMessage({ type: 'success', text: 'Login realizado com sucesso!' })

        // Redirecionar (middleware vai mandar para app.advconecta.com.br se necessário)
        const path = result.user.role === 'super_admin' ? '/admin' : '/dashboard'

        setTimeout(() => {
          router.push(path)
        }, 1000)
      } else {
        setMessage({ type: 'error', text: result.message || 'Erro no login' })
      }
    } catch {
      setMessage({ type: 'error', text: 'Erro de conexão' })
    } finally {
      setIsLoading(false)
    }
  }

  return (
    <div className="min-h-screen bg-white">
      <div className="grid lg:grid-cols-2 min-h-screen">
        {/* Coluna de Branding - Esquerda */}
        <div className="relative hidden lg:block">
          <div className="absolute inset-0 bg-gradient-to-br from-blue-900 to-blue-950 opacity-90"></div>
          <div className="relative z-10 flex flex-col justify-center items-center h-full p-12 text-white">
            <Image
              src="/logo.png"
              alt="Logo Principal"
              width={200}
              height={200}
              className="rounded-lg"
            />
            <h2 className="mt-6 text-3xl font-bold text-center">
              Gestão jurídica completa para escritórios modernos
            </h2>
            <p className="mt-4 text-lg text-blue-100 text-center opacity-90">
              Segurança, eficiência e controle total para o seu escritório
            </p>
          </div>
        </div>

        {/* Coluna do Formulário - Direita */}
        <div className="flex flex-col justify-center items-center py-12 px-4 sm:px-6 lg:px-8">
          <div className="w-full max-w-md space-y-8">
            {/* Cabeçalho do Formulário */}
            <div>
              <Image
                src="/logo.png"
                alt="Logo"
                width={150}
                height={150}
                className="mx-auto"
              />
              <h2 className="mt-6 text-center text-3xl font-bold tracking-tight text-gray-900">
                Acesso ao Sistema
              </h2>
              <p className="mt-2 text-center text-sm text-gray-600">
                Bem-vindo de volta. Entre com suas credenciais.
              </p>
            </div>

            {/* Message */}
            {message && (
              <div className={`p-3 rounded-lg text-sm ${
                message.type === 'error'
                  ? 'bg-red-50 text-red-700 border border-red-200'
                  : 'bg-green-50 text-green-700 border border-green-200'
              }`}>
                {message.text}
              </div>
            )}

            {/* Login Form */}
            <form onSubmit={loginForm.handleSubmit(onLogin)} className="space-y-6">
              <div>
                <label className="block text-sm font-medium text-gray-700">
                  Email
                </label>
                <input
                  type="email"
                  {...loginForm.register('email')}
                  className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
                  placeholder="seu@email.com"
                />
                {loginForm.formState.errors.email && (
                  <p className="mt-1 text-sm text-red-600">
                    {loginForm.formState.errors.email.message}
                  </p>
                )}
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700">
                  Senha
                </label>
                <div className="relative mt-1">
                  <input
                    type={showPassword ? 'text' : 'password'}
                    {...loginForm.register('password')}
                    className="block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 pr-10"
                    placeholder="Sua senha"
                  />
                  <button
                    type="button"
                    onClick={() => setShowPassword(!showPassword)}
                    className="absolute inset-y-0 right-0 flex items-center pr-3"
                  >
                    {showPassword ? (
                      <EyeOff className="h-5 w-5 text-gray-400" />
                    ) : (
                      <Eye className="h-5 w-5 text-gray-400" />
                    )}
                  </button>
                </div>
                {loginForm.formState.errors.password && (
                  <p className="mt-1 text-sm text-red-600">
                    {loginForm.formState.errors.password.message}
                  </p>
                )}
              </div>

              <div className="flex items-center justify-between">
                <div className="flex items-center">
                  <input
                    id="remember-me"
                    name="remember-me"
                    type="checkbox"
                    checked={rememberMe}
                    onChange={(e) => setRememberMe(e.target.checked)}
                    className="h-4 w-4 rounded border-gray-300 text-blue-600 focus:ring-blue-500"
                  />
                  <label htmlFor="remember-me" className="ml-2 block text-sm text-gray-700">
                    Lembrar de mim
                  </label>
                </div>

                <div className="text-sm">
                  <Link
                    href="/forgot-password"
                    className="font-medium text-blue-700 hover:text-blue-600"
                  >
                    Esqueceu sua senha?
                  </Link>
                </div>
              </div>

              <button
                type="submit"
                disabled={isLoading}
                className="w-full flex justify-center py-3 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-blue-700 hover:bg-blue-800 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 disabled:opacity-50 disabled:cursor-not-allowed"
              >
                {isLoading ? 'Entrando...' : 'Entrar'}
              </button>
            </form>

            {/* Link para voltar e Footer */}
            <div className="space-y-6">
              <div className="text-center">
                <Link
                  href="/"
                  className="inline-flex items-center text-blue-600 hover:text-blue-700 transition-colors"
                >
                  <ArrowLeft className="w-4 h-4 mr-2" />
                  <span className="text-sm font-medium">Voltar para a página inicial</span>
                </Link>
              </div>
              
              <div className="pt-4 border-t border-gray-200">
                <p className="text-center text-xs text-gray-500">
                  Sistema desenvolvido para gestão jurídica profissional
                </p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}