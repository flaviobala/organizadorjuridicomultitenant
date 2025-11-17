// src/middleware.ts
import { NextResponse } from 'next/server'
import type { NextRequest } from 'next/server'
import { jwtVerify } from 'jose'

const JWT_SECRET = process.env.JWT_SECRET || 'fallback-secret-key'

export async function middleware(request: NextRequest) {
  const { pathname } = request.nextUrl
  const hostname = request.headers.get('host') || ''

  // Se acessar app.advconecta.com.br na raiz, redirecionar para /login
  if (hostname.startsWith('app.') && pathname === '/') {
    return NextResponse.redirect(new URL('/login', request.url))
  }

  // Se acessar advconecta.com.br em rotas do sistema, redirecionar para app.advconecta.com.br
  if (!hostname.startsWith('app.') && !hostname.includes('duckdns')) {
    const systemPaths = ['/dashboard', '/organization-dashboard', '/admin']
    if (systemPaths.some(path => pathname.startsWith(path))) {
      const appUrl = new URL(request.url)
      appUrl.hostname = 'app.advconecta.com.br'
      return NextResponse.redirect(appUrl)
    }
  }

  // Rotas públicas que não precisam de autenticação
  const publicPaths = ['/login', '/register', '/api/auth/login', '/api/auth/register']
  if (publicPaths.some(path => pathname.startsWith(path))) {
    return NextResponse.next()
  }

  // Rotas de API webhook (não precisam de token JWT)
  if (pathname.startsWith('/api/webhooks/')) {
    return NextResponse.next()
  }

  // Rotas de cron jobs (usam CRON_SECRET em vez de JWT)
  if (pathname.startsWith('/api/cron/')) {
    return NextResponse.next()
  }

  // ✅ Para páginas do cliente (/dashboard, /admin, /pricing, etc.),
  // deixar passar e validar no lado do cliente (useEffect)
  // O middleware só valida APIs
  if (!pathname.startsWith('/api/')) {
    return NextResponse.next()
  }

  // Para APIs, verificar token no header Authorization
  const authHeader = request.headers.get('authorization')
  const token = authHeader?.replace('Bearer ', '')

  if (!token) {
    return NextResponse.json(
      { error: 'Token de autorização não fornecido' },
      { status: 401 }
    )
  }

  try {
    // Verificar token JWT
    const secret = new TextEncoder().encode(JWT_SECRET)
    const { payload } = await jwtVerify(token, secret)

    // Verificar se é rota admin API (SUPER ADMIN apenas)
    if (pathname.startsWith('/api/admin')) {
      if (payload.role !== 'super_admin') {
        return NextResponse.json(
          { error: 'Acesso negado: apenas super administradores do sistema' },
          { status: 403 }
        )
      }
    }

    // ✅ Verificação de limites foi movida para as rotas individuais
    // para evitar uso de Prisma no Edge Runtime

    return NextResponse.next()
  } catch (error) {
    console.error('Erro ao verificar token:', error)
    return NextResponse.json(
      { error: 'Token inválido ou expirado' },
      { status: 401 }
    )
  }
}

export const config = {
  matcher: [
    /*
     * Match all request paths except for the ones starting with:
     * - _next/static (static files)
     * - _next/image (image optimization files)
     * - favicon.ico (favicon file)
     * - public folder
     */
    '/((?!_next/static|_next/image|favicon.ico|public).*)',
  ],
}
