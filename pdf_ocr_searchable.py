import pytesseract
from pdf2image import convert_from_path
from reportlab.pdfgen import canvas
from reportlab.lib.pagesizes import letter
from PIL import Image
import io
import os

def pdf_to_searchable(input_pdf_path, output_pdf_path):
    # Converter PDF para imagens
    images = convert_from_path(input_pdf_path)
    packet = io.BytesIO()
    can = canvas.Canvas(packet, pagesize=letter)

    for img in images:
        # OCR na imagem
        text = pytesseract.image_to_string(img, lang='por')
        # Adicionar imagem ao PDF
        img_buffer = io.BytesIO()
        img.save(img_buffer, format='PNG')
        img_buffer.seek(0)
        can.drawImage(img_buffer, 0, 0, width=letter[0], height=letter[1])
        # Adicionar texto OCR como camada
        can.setFillColorRGB(1, 1, 1, alpha=0)
        can.setFont('Helvetica', 10)
        can.drawString(10, 10, text)
        can.showPage()
    can.save()
    packet.seek(0)
    with open(output_pdf_path, 'wb') as f:
        f.write(packet.getvalue())

if __name__ == '__main__':
    import sys
    if len(sys.argv) != 3:
        print('Uso: python pdf_ocr_searchable.py <input.pdf> <output.pdf>')
        sys.exit(1)
    pdf_to_searchable(sys.argv[1], sys.argv[2])
