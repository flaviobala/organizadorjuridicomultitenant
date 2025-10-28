// src/lib/auth.ts
import jwt from 'jsonwebtoken'
import bcrypt from 'bcryptjs'
import { prisma } from './prisma'

const JWT_SECRET = process.env.JWT_SECRET || 'fallback-secret-key'

export interface TokenPayload {
  userId: number
  email: string
  organizationId: number
  role: string
}

export interface AuthResult {
  success: boolean
  user?: {
    id: number
    email: string
    name: string
    organizationId: number
    role: string
  }
  token?: string
  message?: string
}

// Gerar token JWT
export function generateToken(payload: TokenPayload): string {
  return jwt.sign(payload, JWT_SECRET, { expiresIn: '24h' })
}

// Verificar token JWT
export function verifyToken(token: string): TokenPayload | null {
  try {
    const decoded = jwt.verify(token, JWT_SECRET) as TokenPayload
    return decoded
  } catch (error) {
    console.error('Erro ao verificar token:', error)
    return null
  }
}

// Hash da senha
export async function hashPassword(password: string): Promise<string> {
  return bcrypt.hash(password, 12)
}

// Verificar senha
export async function verifyPassword(password: string, hashedPassword: string): Promise<boolean> {
  return bcrypt.compare(password, hashedPassword)
}

// Registrar usuário
export async function registerUser(email: string, password: string, name: string): Promise<AuthResult> {
  try {
    // Verificar se o usuário já existe
    const existingUser = await prisma.user.findUnique({
      where: { email }
    })

    if (existingUser) {
      return {
        success: false,
        message: 'Email já cadastrado'
      }
    }

    // Criar organização automaticamente para o novo usuário
    const organization = await prisma.organization.create({
      data: {
        name: `${name}'s Organization`,
        planType: 'trialing',
        subscriptionStatus: 'trialing',
        documentProcessedCount: 0,
        aiTokenCount: 0
      }
    })

    // Criar usuário vinculado à organização (primeiro usuário = admin)
    const hashedPassword = await hashPassword(password)
    const user = await prisma.user.create({
      data: {
        email,
        password: hashedPassword,
        name,
        organizationId: organization.id,
        role: 'admin' // Primeiro usuário da org é sempre admin
      }
    })

    // Gerar token com organizationId e role
    const token = generateToken({
      userId: user.id,
      email: user.email,
      organizationId: user.organizationId,
      role: user.role
    })

    return {
      success: true,
      user: {
        id: user.id,
        email: user.email,
        name: user.name,
        organizationId: user.organizationId,
        role: user.role
      },
      token,
      message: 'Usuário criado com sucesso'
    }
  } catch (error) {
    console.error('Erro ao registrar usuário:', error)
    return {
      success: false,
      message: 'Erro interno do servidor'
    }
  }
}

// Login do usuário
export async function loginUser(email: string, password: string): Promise<AuthResult> {
  try {
    // Buscar usuário com organização
    const user = await prisma.user.findUnique({
      where: { email },
      include: { organization: true }
    })

    if (!user) {
      return {
        success: false,
        message: 'Email ou senha incorretos'
      }
    }

    // Verificar senha
    const isPasswordValid = await verifyPassword(password, user.password)
    if (!isPasswordValid) {
      return {
        success: false,
        message: 'Email ou senha incorretos'
      }
    }

    // Gerar token com organizationId e role
    const token = generateToken({
      userId: user.id,
      email: user.email,
      organizationId: user.organizationId,
      role: user.role
    })

    return {
      success: true,
      user: {
        id: user.id,
        email: user.email,
        name: user.name,
        organizationId: user.organizationId,
        role: user.role
      },
      token,
      message: 'Login realizado com sucesso'
    }
  } catch (error) {
    console.error('Erro ao fazer login:', error)
    return {
      success: false,
      message: 'Erro interno do servidor'
    }
  }
}

// Middleware de autenticação para APIs
export async function requireAuth(request: Request): Promise<{
  success: boolean,
  user?: { id: number, email: string, name: string, organizationId: number, role: string },
  error?: string
}> {
  try {
    const authHeader = request.headers.get('authorization')

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return {
        success: false,
        error: 'Token de autorização não fornecido'
      }
    }

    const token = authHeader.substring(7) // Remove "Bearer "
    const payload = verifyToken(token)

    if (!payload) {
      return {
        success: false,
        error: 'Token inválido ou expirado'
      }
    }

    // Buscar dados atualizados do usuário com organizationId e role
    const user = await prisma.user.findUnique({
      where: { id: payload.userId },
      select: { id: true, email: true, name: true, organizationId: true, role: true }
    })

    if (!user) {
      return {
        success: false,
        error: 'Usuário não encontrado'
      }
    }

    return {
      success: true,
      user
    }
  } catch (error) {
    console.error('Erro na autenticação:', error)
    return {
      success: false,
      error: 'Erro interno de autenticação'
    }
  }
}

// Middleware de autenticação para Admin (Super Admin)
export async function requireAdmin(request: Request): Promise<{
  success: boolean,
  user?: { id: number, email: string, name: string, organizationId: number, role: string },
  error?: string
}> {
  const auth = await requireAuth(request)

  if (!auth.success || !auth.user) {
    return auth
  }

  // Verificar se é admin
  if (auth.user.role !== 'admin') {
    return {
      success: false,
      error: 'Acesso negado: apenas administradores'
    }
  }

  return auth
}