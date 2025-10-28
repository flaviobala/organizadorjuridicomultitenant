declare module 'pdf-parse' {
  interface PDFData {
    text: string;
    numpages: number;
  }

  function pdfParse(buffer: Buffer, options?: Record<string, unknown>): Promise<PDFData>;
  export = pdfParse;
}