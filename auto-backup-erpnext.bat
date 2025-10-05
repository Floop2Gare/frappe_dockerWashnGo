@echo off
setlocal enabledelayedexpansion

:: Configuration
set SCRIPT_DIR=%~dp0
set BACKUP_ROOT=C:\Users\Floop\Desktop\backups-erpnext
set LOG_FILE=%BACKUP_ROOT%\backup.log
set MAX_BACKUPS=7

:: Créer le dossier de sauvegarde s'il n'existe pas
if not exist "%BACKUP_ROOT%" (
    mkdir "%BACKUP_ROOT%"
    echo ✅ Dossier de sauvegarde créé : %BACKUP_ROOT%
)

:: Fonction de logging
:log
echo [%date% %time%] %~1 >> "%LOG_FILE%"
echo [%date% %time%] %~1
goto :eof

:: Début de la sauvegarde
call :log "=== DÉBUT SAUVEGARDE AUTOMATIQUE ERPNext ==="

:: Vérifier que Docker est en cours d'exécution
call :log "Vérification de Docker Desktop..."
docker version >nul 2>&1
if %errorlevel% neq 0 (
    call :log "❌ Docker Desktop n'est pas démarré - Sauvegarde annulée"
    exit /b 1
)
call :log "✅ Docker Desktop est actif"

:: Vérifier que les conteneurs ERPNext sont en cours d'exécution
call :log "Vérification des conteneurs ERPNext..."
docker compose -f "%SCRIPT_DIR%pwd.yml" ps --format "table {{.Name}}\t{{.Status}}" | findstr "Up" >nul
if %errorlevel% neq 0 (
    call :log "❌ Les conteneurs ERPNext ne sont pas en cours d'exécution - Sauvegarde annulée"
    exit /b 1
)
call :log "✅ Les conteneurs ERPNext sont actifs"

:: Créer le dossier de sauvegarde avec date/heure
set BACKUP_DATE=%date:~-4,4%-%date:~-10,2%-%date:~-7,2%_%time:~0,2%-%time:~3,2%-%time:~6,2%
set BACKUP_DATE=%BACKUP_DATE: =0%
set BACKUP_DIR=%BACKUP_ROOT%\backup-%BACKUP_DATE%

call :log "📁 Création du dossier de sauvegarde : %BACKUP_DIR%"
mkdir "%BACKUP_DIR%"

:: Sauvegarder la base de données
call :log "🗄️ Sauvegarde de la base de données..."
docker compose -f "%SCRIPT_DIR%pwd.yml" exec -T db mysqldump -u root -padmin --all-databases > "%BACKUP_DIR%\database_backup.sql" 2>nul
if %errorlevel% equ 0 (
    call :log "✅ Base de données sauvegardée avec succès"
) else (
    call :log "❌ Erreur lors de la sauvegarde de la base de données"
    rmdir /s /q "%BACKUP_DIR%"
    exit /b 1
)

:: Sauvegarder les fichiers du site
call :log "📁 Sauvegarde des fichiers du site..."
docker compose -f "%SCRIPT_DIR%pwd.yml" exec backend bash -lc "cd /home/frappe/frappe-bench && tar -czf /tmp/sites_backup.tar.gz sites/" 2>/dev/null
docker compose -f "%SCRIPT_DIR%pwd.yml" cp backend:/tmp/sites_backup.tar.gz "%BACKUP_DIR%\sites_backup.tar.gz" 2>nul
if %errorlevel% equ 0 (
    call :log "✅ Fichiers du site sauvegardés avec succès"
) else (
    call :log "❌ Erreur lors de la sauvegarde des fichiers du site"
)

:: Sauvegarder les logs
call :log "📋 Sauvegarde des logs..."
docker compose -f "%SCRIPT_DIR%pwd.yml" exec backend bash -lc "cd /home/frappe/frappe-bench && tar -czf /tmp/logs_backup.tar.gz logs/" 2>/dev/null
docker compose -f "%SCRIPT_DIR%pwd.yml" cp backend:/tmp/logs_backup.tar.gz "%BACKUP_DIR%\logs_backup.tar.gz" 2>nul
if %errorlevel% equ 0 (
    call :log "✅ Logs sauvegardés avec succès"
) else (
    call :log "❌ Erreur lors de la sauvegarde des logs"
)

:: Créer un fichier d'information
call :log "📄 Création du fichier d'information..."
echo Sauvegarde automatique ERPNext Wash&Go > "%BACKUP_DIR%\backup_info.txt"
echo Date: %date% %time% >> "%BACKUP_DIR%\backup_info.txt"
echo Version: ERPNext v15.81.1 >> "%BACKUP_DIR%\backup_info.txt"
echo Site: frontend >> "%BACKUP_DIR%\backup_info.txt"
echo Type: Sauvegarde automatique >> "%BACKUP_DIR%\backup_info.txt"

:: Nettoyer les anciennes sauvegardes
call :log "🧹 Nettoyage des anciennes sauvegardes..."
cd /d "%BACKUP_ROOT%"
for /f "skip=%MAX_BACKUPS% delims=" %%i in ('dir /b /ad /od backup-* 2^>nul') do (
    call :log "🗑️ Suppression de l'ancienne sauvegarde : %%i"
    rmdir /s /q "%%i"
)

:: Calculer la taille de la sauvegarde
for /f %%i in ('dir "%BACKUP_DIR%" /s /-c ^| find "bytes"') do set BACKUP_SIZE=%%i
call :log "📊 Taille de la sauvegarde : %BACKUP_SIZE% bytes"

call :log "🎉 Sauvegarde automatique terminée avec succès !"
call :log "📁 Sauvegarde disponible dans : %BACKUP_DIR%"
call :log "=== FIN SAUVEGARDE AUTOMATIQUE ==="

exit /b 0
