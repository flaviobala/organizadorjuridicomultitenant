# import os
# import pytesseract
# from pdf2image import convert_from_path
# from PyPDF2 import PdfReader
# import subprocess

# # === CONFIGURAÇÕES ===
# pdf_path = r"C:\SistemaADV+\sistema-juridico\contratosocialBakanas.pdf"
# output_pdf = pdf_path.replace(".pdf", "_OCR.pdf")
# lang = "por"  # idioma do OCR
# dpi = 400     # resolução (ajuste se o PDF for leve/pesado)

# def tem_texto(pdf):
#     """Verifica se o PDF contém texto digital."""
#     reader = PdfReader(pdf)
#     texto_total = ""
#     for i, page in enumerate(reader.pages[:3]):  # checa até 3 páginas
#         texto_total += page.extract_text() or ""
#     return len(texto_total.strip()) > 100  # tem texto suficiente?

# def aplicar_ocr(pdf, saida):
#     """Aplica OCR em todas as páginas do PDF."""
#     print("🔍 Convertendo páginas em imagens...")
#     pages = convert_from_path(pdf, dpi=dpi)
#     texto_total = ""
#     for i, img in enumerate(pages, start=1):
#         print(f"📄 Processando página {i}...")
#         texto = pytesseract.image_to_string(img, lang=lang, config="--psm 1")
#         texto_total += f"\n\n=== Página {i} ===\n{texto}"
#         with open(f"pagina_{i}.txt", "w", encoding="utf-8") as f:
#             f.write(texto)

#     print("\n🧠 Gerando PDF pesquisável (usando OCRmyPDF)...")
#     subprocess.run([
#         "ocrmypdf",
#         "--deskew", "--redo-ocr", "--language", lang,
#         pdf, saida
#     ])
#     print(f"\n✅ OCR concluído! Arquivo salvo em:\n{saida}")
#     return texto_total

# # === EXECUÇÃO PRINCIPAL ===
# print(f"📂 Analisando: {pdf_path}")

# if tem_texto(pdf_path):
#     print("✅ O PDF já possui texto digital. OCR não é necessário.")
# else:
#     print("⚠️ Nenhum texto digital detectado — aplicando OCR completo...")
#     texto = aplicar_ocr(pdf_path, output_pdf)
#     print("\n📜 Trecho do texto reconhecido:")
#     print(texto[:500])
import ocrmypdf
import sys
import os

def aplicar_ocr(pdf_path, output_pdf):
    """
    Aplica OCR completo no PDF, criando um PDF pesquisável.
    """
    try:
        ocrmypdf.ocr(
            pdf_path,
            output_pdf,
            language='por',      # Português
            deskew=True,         # Corrige pequenas inclinações
            force_ocr=True       # Força OCR mesmo que já haja texto
        )
        print(f"✅ OCR aplicado com sucesso! Arquivo gerado: {output_pdf}")
    except Exception as e:
        print(f"❌ Erro ao aplicar OCR: {e}")

if __name__ == "__main__":
    # Caminho do PDF original
    pdf_path = "C:\\SistemaADV+\\sistema-juridico\\contratosocialBakanas.pdf"
    # Nome do PDF de saída
    output_pdf = "C:\\SistemaADV+\\sistema-juridico\\contratosocialBakanas_OCR.pdf"

    print("⚠️ Forçando OCR completo em todas as páginas...")
    aplicar_ocr(pdf_path, output_pdf)
