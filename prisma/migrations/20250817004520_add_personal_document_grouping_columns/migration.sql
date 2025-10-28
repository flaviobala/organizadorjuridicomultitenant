-- AlterTable
ALTER TABLE "documents" ADD COLUMN     "ai_analysis" TEXT,
ADD COLUMN     "analysis_confidence" DOUBLE PRECISION,
ADD COLUMN     "detected_document_type" TEXT,
ADD COLUMN     "grouped_at" TIMESTAMP(3),
ADD COLUMN     "is_grouped" BOOLEAN NOT NULL DEFAULT false,
ADD COLUMN     "is_personal_document" BOOLEAN NOT NULL DEFAULT false,
ADD COLUMN     "smart_filename" TEXT;
