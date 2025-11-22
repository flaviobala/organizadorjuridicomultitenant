//src/app/layout.tsx
import type { Metadata } from "next";
import { Inter } from "next/font/google";
import "./globals.css";

const inter = Inter({ subsets: ["latin"] });

export const metadata: Metadata = {
  title: "ADV DocMaster",
  description: "Sistema completo para gestão de processos e documentos jurídicos",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="pt-BR">
      <body 
        className={inter.className}
        suppressHydrationWarning={true}
      >
        {children}
      </body>
    </html>
  );
}