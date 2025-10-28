-- CreateTable
CREATE TABLE "public"."api_usage" (
    "id" SERIAL NOT NULL,
    "user_id" INTEGER,
    "service" TEXT NOT NULL,
    "operation" TEXT NOT NULL,
    "model" TEXT,
    "tokens_input" INTEGER NOT NULL DEFAULT 0,
    "tokens_output" INTEGER NOT NULL DEFAULT 0,
    "tokens_total" INTEGER NOT NULL DEFAULT 0,
    "cost_brl" DOUBLE PRECISION NOT NULL DEFAULT 0,
    "method" TEXT NOT NULL DEFAULT 'ai',
    "success" BOOLEAN NOT NULL DEFAULT true,
    "error_message" TEXT,
    "document_id" INTEGER,
    "project_id" INTEGER,
    "date" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "api_usage_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "api_usage_user_id_idx" ON "public"."api_usage"("user_id");

-- CreateIndex
CREATE INDEX "api_usage_service_idx" ON "public"."api_usage"("service");

-- CreateIndex
CREATE INDEX "api_usage_date_idx" ON "public"."api_usage"("date");

-- CreateIndex
CREATE INDEX "api_usage_method_idx" ON "public"."api_usage"("method");
