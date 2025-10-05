@echo off
echo ========================================
echo    💾 SAUVEGARDE ERPNext WASH&GO
echo ========================================
echo.

:: Créer le dossier de sauvegarde avec date/heure
set BACKUP_DATE=%date:~-4,4%-%date:~-10,2%-%date:~-7,2%_%time:~0,2%-%time:~3,2%-%time:~6,2%
set BACKUP_DATE=%BACKUP_DATE: =0%
set BACKUP_DIR=C:\Users\Floop\Desktop\backup-erpnext-%BACKUP_DATE%

echo 📁 Création du dossier de sauvegarde...
mkdir "%BACKUP_DIR%"
echo ✅ Dossier créé : %BACKUP_DIR%
echo.

:: Sauvegarder la base de données
echo 🗄️ Sauvegarde de la base de données...
docker compose -f pwd.yml exec -T db mysqldump -u root -padmin --all-databases > "%BACKUP_DIR%\database_backup.sql"
if %errorlevel% equ 0 (
    echo ✅ Base de données sauvegardée
) else (
    echo ❌ Erreur lors de la sauvegarde de la base de données
)
echo.

:: Sauvegarder les fichiers du site
echo 📁 Sauvegarde des fichiers du site...
docker compose -f pwd.yml exec backend bash -lc "cd /home/frappe/frappe-bench && tar -czf /tmp/sites_backup.tar.gz sites/"
docker compose -f pwd.yml cp backend:/tmp/sites_backup.tar.gz "%BACKUP_DIR%\sites_backup.tar.gz"
if %errorlevel% equ 0 (
    echo ✅ Fichiers du site sauvegardés
) else (
    echo ❌ Erreur lors de la sauvegarde des fichiers
)
echo.

:: Sauvegarder les logs
echo 📋 Sauvegarde des logs...
docker compose -f pwd.yml exec backend bash -lc "cd /home/frappe/frappe-bench && tar -czf /tmp/logs_backup.tar.gz logs/"
docker compose -f pwd.yml cp backend:/tmp/logs_backup.tar.gz "%BACKUP_DIR%\logs_backup.tar.gz"
if %errorlevel% equ 0 (
    echo ✅ Logs sauvegardés
) else (
    echo ❌ Erreur lors de la sauvegarde des logs
)
echo.

:: Créer un fichier d'information
echo 📄 Création du fichier d'information...
echo Sauvegarde ERPNext Wash&Go > "%BACKUP_DIR%\backup_info.txt"
echo Date: %date% %time% >> "%BACKUP_DIR%\backup_info.txt"
echo Version: ERPNext v15.81.1 >> "%BACKUP_DIR%\backup_info.txt"
echo Site: frontend >> "%BACKUP_DIR%\backup_info.txt"
echo.
echo ✅ Fichier d'information créé

echo.
echo 🎉 Sauvegarde terminée avec succès !
echo 📁 Sauvegarde disponible dans : %BACKUP_DIR%
echo.
echo 💡 Pour restaurer, utilisez le script "restore-erpnext.bat"
echo.
pause
