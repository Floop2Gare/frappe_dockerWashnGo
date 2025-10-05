@echo off
setlocal enabledelayedexpansion

:: Configuration
set BACKUP_ROOT=C:\Users\Floop\Desktop\backups-erpnext
set LOG_FILE=%BACKUP_ROOT%\backup.log
set MAX_BACKUPS=7

echo ========================================
echo    🧹 NETTOYAGE SAUVEGARDES ERPNext
echo ========================================
echo.

if not exist "%BACKUP_ROOT%" (
    echo ❌ Aucun dossier de sauvegarde trouvé
    pause
    exit /b 1
)

echo 📁 Dossier de sauvegarde : %BACKUP_ROOT%
echo 📊 Nombre maximum de sauvegardes à conserver : %MAX_BACKUPS%
echo.

cd /d "%BACKUP_ROOT%"

:: Compter le nombre de sauvegardes actuelles
set COUNT=0
for /d %%i in (backup-*) do set /a COUNT+=1

echo 📋 Nombre de sauvegardes actuelles : %COUNT%

if %COUNT% leq %MAX_BACKUPS% (
    echo ✅ Aucun nettoyage nécessaire
    echo.
    pause
    exit /b 0
)

:: Calculer le nombre de sauvegardes à supprimer
set /a TO_DELETE=%COUNT%-%MAX_BACKUPS%
echo 🗑️ Nombre de sauvegardes à supprimer : %TO_DELETE%
echo.

echo 📋 Sauvegardes qui seront supprimées :
for /f "skip=%MAX_BACKUPS% delims=" %%i in ('dir /b /ad /od backup-* 2^>nul') do (
    echo    - %%i
)

echo.
echo ⚠️  Confirmer la suppression ? (O/N)
set /p CONFIRM="Confirmer : "
if /i not "%CONFIRM%"=="O" (
    echo ❌ Nettoyage annulé
    pause
    exit /b 0
)

echo.
echo 🗑️ Suppression des anciennes sauvegardes...

set DELETED=0
for /f "skip=%MAX_BACKUPS% delims=" %%i in ('dir /b /ad /od backup-* 2^>nul') do (
    echo    Suppression de : %%i
    rmdir /s /q "%%i"
    set /a DELETED+=1
)

echo.
echo ✅ Nettoyage terminé !
echo 🗑️ Sauvegardes supprimées : %DELETED%
echo 📊 Sauvegardes restantes : %MAX_BACKUPS%
echo.

:: Afficher l'espace disque libéré
echo 💾 Espace disque du dossier de sauvegarde :
dir "%BACKUP_ROOT%" /s /-c | find "bytes"

echo.
pause
