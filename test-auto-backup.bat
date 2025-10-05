@echo off
echo ========================================
echo    🧪 TEST SAUVEGARDE AUTOMATIQUE
echo ========================================
echo.

set SCRIPT_DIR=%~dp0
set BACKUP_SCRIPT=%SCRIPT_DIR%auto-backup-erpnext.bat

echo 🧪 Test de la sauvegarde automatique ERPNext...
echo.

:: Vérifier que Docker est en cours d'exécution
echo 📋 Vérification des prérequis...
docker version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Docker Desktop n'est pas démarré
    echo 💡 Veuillez démarrer Docker Desktop puis relancer ce test
    pause
    exit /b 1
)
echo ✅ Docker Desktop est actif

:: Vérifier que les conteneurs ERPNext sont en cours d'exécution
docker compose -f "%SCRIPT_DIR%pwd.yml" ps --format "table {{.Name}}\t{{.Status}}" | findstr "Up" >nul
if %errorlevel% neq 0 (
    echo ❌ Les conteneurs ERPNext ne sont pas en cours d'exécution
    echo 💡 Veuillez démarrer ERPNext puis relancer ce test
    pause
    exit /b 1
)
echo ✅ Les conteneurs ERPNext sont actifs

echo.
echo 🚀 Lancement du test de sauvegarde...
echo.

:: Exécuter le script de sauvegarde automatique
call "%BACKUP_SCRIPT%"

if %errorlevel% equ 0 (
    echo.
    echo ✅ Test de sauvegarde réussi !
    echo.
    echo 📁 Vérification des fichiers de sauvegarde :
    echo.
    
    :: Vérifier que les fichiers ont été créés
    set BACKUP_ROOT=C:\Users\Floop\Desktop\backups-erpnext
    for /f "delims=" %%i in ('dir "%BACKUP_ROOT%" /b /ad /od backup-* 2^>nul ^| tail -1') do (
        set LATEST_BACKUP=%%i
        echo 📁 Dernière sauvegarde : %%i
        echo.
        
        echo 📋 Contenu de la sauvegarde :
        dir "%BACKUP_ROOT%\%%i" /b
        echo.
        
        echo 📊 Taille de la sauvegarde :
        for /f %%j in ('dir "%BACKUP_ROOT%\%%i" /s /-c ^| find "bytes"') do echo    %%j
        echo.
        
        echo ✅ Fichiers de sauvegarde créés avec succès
    )
    
    echo.
    echo 🎉 Test terminé avec succès !
    echo.
    echo 💡 Prochaines étapes :
    echo    1. Configurez la sauvegarde automatique : setup-auto-backup.bat
    echo    2. Vérifiez les logs : notepad %BACKUP_ROOT%\backup.log
    echo    3. Testez la restauration avec : restore-erpnext.bat
    echo.
    
) else (
    echo.
    echo ❌ Test de sauvegarde échoué !
    echo.
    echo 🔧 Vérifiez les logs pour plus de détails :
    echo    notepad %BACKUP_ROOT%\backup.log
    echo.
)

echo.
pause
