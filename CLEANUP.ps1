# ============================================
# 🧹 ROBLOX CLICKER - CODE CLEANUP SCRIPT
# ============================================
# This script removes obsolete files that have been replaced
# by the new RNG weapon clicker architecture.
#
# Files to be deleted:
# - src/ServerScriptService/ClickCurrencyHandler.server.lua (replaced by CurrencyManager)
# - src/server/WorldBuilder.server.lua (replaced by main.server.lua)
# - src/server/ItemSpawner.server.lua (old item drop system)
# - src/server/LightingSetup.server.lua (legacy lighting)
# - src/client/main.client.lua (documentation-only file)
# - src/shared/Hello.lua (unused test file)
# ============================================

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "🧹 Roblox Clicker Code Cleanup" -ForegroundColor Green
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

# Define files to delete
$filesToDelete = @(
    "src\ServerScriptService\ClickCurrencyHandler.server.lua",
    "src\server\WorldBuilder.server.lua",
    "src\server\ItemSpawner.server.lua",
    "src\server\LightingSetup.server.lua",
    "src\client\main.client.lua",
    "src\shared\Hello.lua"
)

$deleted = 0
$failed = 0

foreach ($file in $filesToDelete) {
    $fullPath = Join-Path -Path (Get-Location) -ChildPath $file
    
    if (Test-Path -Path $fullPath) {
        try {
            Remove-Item -Path $fullPath -Force
            Write-Host "✅ Deleted: $file" -ForegroundColor Green
            $deleted++
        } catch {
            Write-Host "❌ Failed to delete: $file" -ForegroundColor Red
            Write-Host "   Error: $_" -ForegroundColor Red
            $failed++
        }
    } else {
        Write-Host "⚠️  Not found: $file (may already be deleted)" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "======================================" -ForegroundColor Cyan
Write-Host "Summary:" -ForegroundColor Cyan
Write-Host "✅ Successfully deleted: $deleted file(s)" -ForegroundColor Green
if ($failed -gt 0) {
    Write-Host "❌ Failed: $failed file(s)" -ForegroundColor Red
}
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

# Git status check
Write-Host "Checking git status..." -ForegroundColor Cyan
Write-Host ""
git status --short | Where-Object { $_ -match "^ D " }

Write-Host ""
Write-Host "✨ Cleanup completed! You can now commit the changes:" -ForegroundColor Green
Write-Host "   git add . && git commit -m 'Remove obsolete code from old architecture'" -ForegroundColor Cyan
Write-Host ""
