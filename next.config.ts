import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  // ✅ CORREÇÃO NEXT.JS 15: serverExternalPackages (não é mais experimental)
  serverExternalPackages: ['sharp', 'pdf-parse'],

  // ✅ CORREÇÃO VERCEL: Permitir processamento de imagens
  images: {
    remotePatterns: [
      {
        protocol: 'https',
        hostname: '**.supabase.co',
      },
    ],
  },
};

export default nextConfig;
