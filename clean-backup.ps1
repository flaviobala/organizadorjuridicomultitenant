# Script para limpar backup do Supabase e deixar compatível com PostgreSQL local

$inputFile = "backup_utf8.sql"
$outputFile = "backup_clean.sql"

Write-Host "Lendo backup UTF-8..."
$content = Get-Content $inputFile -Raw

Write-Host "Removendo comandos específicos do Supabase..."

# Remover comando \restrict
$content = $content -replace '\\restrict\s+[^\n]+\n', ''

# Remover event triggers do Supabase
$content = $content -replace 'DROP EVENT TRIGGER IF EXISTS[^\n]+\n', ''
$content = $content -replace 'CREATE EVENT TRIGGER[^;]+;', ''

# Remover publications do Supabase Realtime
$content = $content -replace 'DROP PUBLICATION IF EXISTS supabase_realtime[^\n]+\n', ''
$content = $content -replace 'CREATE PUBLICATION supabase_realtime[^;]+;', ''

# Remover schemas do Supabase que não precisamos
$content = $content -replace 'CREATE SCHEMA IF NOT EXISTS (auth|storage|realtime|supabase_functions|graphql_public|pgsodium|vault|extensions)[^\n]+\n', ''
$content = $content -replace 'DROP SCHEMA IF EXISTS (auth|storage|realtime|supabase_functions|graphql_public|pgsodium|vault|extensions)[^\n]+\n', ''

# Remover extensões do Supabase que podem não existir localmente
$content = $content -replace 'CREATE EXTENSION IF NOT EXISTS (pg_graphql|pg_stat_statements|pgcrypto|pgjwt|supabase_vault|pg_net|pgsodium|pg_cron)[^\n]+\n', ''
$content = $content -replace 'DROP EXTENSION IF EXISTS (pg_graphql|pg_stat_statements|pgcrypto|pgjwt|supabase_vault|pg_net|pgsodium|pg_cron)[^\n]+\n', ''

# Remover ALTER para extensões
$content = $content -replace 'ALTER EXTENSION (pg_graphql|pg_stat_statements|pgcrypto|pgjwt|supabase_vault|pg_net|pgsodium|pg_cron)[^;]+;', ''

# Remover schemas temporários do pg_temp
$content = $content -replace 'CREATE SCHEMA pg_temp[^\n]+\n', ''

Write-Host "Salvando backup limpo..."
$utf8NoBom = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText((Join-Path $PSScriptRoot $outputFile), $content, $utf8NoBom)

Write-Host "✅ Backup limpo criado: $outputFile"
Write-Host ""
Write-Host "Estatísticas:"
$originalSize = (Get-Item $inputFile).Length / 1KB
$cleanSize = (Get-Item $outputFile).Length / 1KB
Write-Host "  Original: $([math]::Round($originalSize, 2)) KB"
Write-Host "  Limpo: $([math]::Round($cleanSize, 2)) KB"
Write-Host ""
Write-Host "Próximo passo:"
Write-Host "psql -U postgres -d organizador_juridico < backup_clean.sql"
