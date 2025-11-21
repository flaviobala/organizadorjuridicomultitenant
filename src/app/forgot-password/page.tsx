"use client"

import { useState } from "react"
import { useForm } from "react-hook-form"
import { z } from "zod"
import { zodResolver } from "@hookform/resolvers/zod"
import Image from "next/image"
import Link from "next/link"
import { ArrowLeft } from "lucide-react"

const forgotSchema = z.object({
  email: z.string().email("Email inválido"),
})

type ForgotFormData = z.infer<typeof forgotSchema>

export default function ForgotPasswordPage() {
  const [isLoading, setIsLoading] = useState(false)
  const [message, setMessage] = useState<{ type: "error" | "success"; text: string } | null>(null)

  const form = useForm<ForgotFormData>({
    resolver: zodResolver(forgotSchema),
  })

  const onSubmit = async (data: ForgotFormData) => {
    setIsLoading(true)
    setMessage(null)

    try {
      const res = await fetch("/api/auth/forgot-password", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(data),
      })

      const result = await res.json()

      if (result.success) {
        setMessage({
          type: "success",
          text: "Se o email existir no sistema, enviamos um link de recuperação.",
        })
      } else {
        setMessage({
          type: "error",
          text: result.message || "Erro ao solicitar recuperação.",
        })
      }
    } catch {
      setMessage({ type: "error", text: "Erro de conexão" })
    } finally {
      setIsLoading(false)
    }
  }

  return (
    <div className="min-h-screen bg-white">
      <div className="grid lg:grid-cols-2 min-h-screen">

        {/* Coluna Esquerda — Branding */}
        <div className="relative hidden lg:block">
          <div className="absolute inset-0 bg-gradient-to-br from-blue-900 to-blue-950 opacity-90"></div>
          <div className="relative z-10 flex flex-col justify-center items-center h-full p-12 text-white">
            <Image src="/logo.png" alt="Logo Principal" width={200} height={200} className="rounded-lg" />
            <h2 className="mt-6 text-3xl font-bold text-center">
              Recuperação de acesso ao sistema jurídico
            </h2>
            <p className="mt-4 text-lg text-blue-100 text-center opacity-90">
              Enviaremos um link seguro para redefinir sua senha.
            </p>
          </div>
        </div>

        {/* Coluna Direita — Formulário */}
        <div className="flex flex-col justify-center items-center py-12 px-4 sm:px-6 lg:px-8">
          <div className="w-full max-w-md space-y-8">
            
            {/* Cabeçalho */}
            <div>
              <Image src="/logo.png" alt="Logo" width={150} height={150} className="mx-auto" />
              <h2 className="mt-6 text-center text-3xl font-bold tracking-tight text-gray-900">
                Recuperar Senha
              </h2>
              <p className="mt-2 text-center text-sm text-gray-600">
                Digite seu e-mail para receber o link de redefinição.
              </p>
            </div>

            {/* Mensagem */}
            {message && (
              <div
                className={`p-3 rounded-lg text-sm ${
                  message.type === "error"
                    ? "bg-red-50 text-red-700 border border-red-200"
                    : "bg-green-50 text-green-700 border border-green-200"
                }`}
              >
                {message.text}
              </div>
            )}

            {/* Form */}
            <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-6">
              <div>
                <label className="block text-sm font-medium text-gray-700">Email</label>
                <input
                  type="email"
                  {...form.register("email")}
                  className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
                  placeholder="seu@email.com"
                />
                {form.formState.errors.email && (
                  <p className="mt-1 text-sm text-red-600">{form.formState.errors.email.message}</p>
                )}
              </div>

              <button
                type="submit"
                disabled={isLoading}
                className="w-full flex justify-center py-3 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-blue-700 hover:bg-blue-800 disabled:opacity-50"
              >
                {isLoading ? "Enviando..." : "Enviar link de recuperação"}
              </button>
            </form>

            {/* Voltar */}
            <div className="space-y-6">
              <div className="text-center">
                <Link href="/login" className="inline-flex items-center text-blue-600 hover:text-blue-700">
                  <ArrowLeft className="w-4 h-4 mr-2" />
                  <span className="text-sm font-medium">Voltar para o login</span>
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
