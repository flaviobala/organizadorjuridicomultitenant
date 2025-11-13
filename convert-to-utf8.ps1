# Script para converter backup para UTF-8 sem BOM

$inputFile = "backup_supabase.sql"
$outputFile = "backup_utf8.sql"

Write-Host "Lendo arquivo original..."
$content = Get-Content $inputFile -Raw -Encoding Default

Write-Host "Convertendo para UTF-8 sem BOM..."
$utf8NoBom = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText((Join-Path $PSScriptRoot $outputFile), $content, $utf8NoBom)

Write-Host "✅ Conversão concluída: $outputFile"
Write-Host ""
Write-Host "Agora execute:"
Write-Host "psql -U postgres -d organizador_juridico < backup_utf8.sql"
