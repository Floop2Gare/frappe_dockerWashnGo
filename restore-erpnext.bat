@echo off
echo ========================================
echo    🔄 RESTAURATION ERPNext WASH&GO
echo ========================================
echo.

:: Demander le dossier de sauvegarde
echo 📁 Veuillez entrer le chemin du dossier de sauvegarde :
echo    Exemple : C:\Users\Floop\Desktop\backup-erpnext-2025-10-05_21-30-45
echo.
set /p BACKUP_DIR="Dossier de sauvegarde : "

:: Vérifier que le dossier existe
if not exist "%BACKUP_DIR%" (
    echo ❌ Le dossier de sauvegarde n'existe pas !
    pause
    exit /b 1
)

echo.
echo ⚠️  ATTENTION : Cette opération va remplacer toutes les données actuelles !
echo    Êtes-vous sûr de vouloir continuer ? (O/N)
set /p CONFIRM="Confirmer : "
if /i not "%CONFIRM%"=="O" (
    echo ❌ Restauration annulée
    pause
    exit /b 0
)

echo.
echo 🛑 Arrêt des services ERPNext...
docker compose -f pwd.yml down

echo.
echo 🗄️ Restauration de la base de données...
docker compose -f pwd.yml up -d db
timeout /t 10 /nobreak >nul

docker compose -f pwd.yml exec -T db mysql -u root -padmin < "%BACKUP_DIR%\database_backup.sql"
if %errorlevel% equ 0 (
    echo ✅ Base de données restaurée
) else (
    echo ❌ Erreur lors de la restauration de la base de données
)

echo.
echo 📁 Restauration des fichiers du site...
docker compose -f pwd.yml up -d backend
timeout /t 15 /nobreak >nul

docker compose -f pwd.yml cp "%BACKUP_DIR%\sites_backup.tar.gz" backend:/tmp/sites_backup.tar.gz
docker compose -f pwd.yml exec backend bash -lc "cd /home/frappe/frappe-bench && tar -xzf /tmp/sites_backup.tar.gz"
if %errorlevel% equ 0 (
    echo ✅ Fichiers du site restaurés
) else (
    echo ❌ Erreur lors de la restauration des fichiers
)

echo.
echo 📋 Restauration des logs...
docker compose -f pwd.yml cp "%BACKUP_DIR%\logs_backup.tar.gz" backend:/tmp/logs_backup.tar.gz
docker compose -f pwd.yml exec backend bash -lc "cd /home/frappe/frappe-bench && tar -xzf /tmp/logs_backup.tar.gz"
if %errorlevel% equ 0 (
    echo ✅ Logs restaurés
) else (
    echo ❌ Erreur lors de la restauration des logs
)

echo.
echo 🚀 Redémarrage des services...
docker compose -f pwd.yml up -d

echo.
echo ⏳ Attente du redémarrage complet (30 secondes)...
timeout /t 30 /nobreak >nul

echo.
echo 🎉 Restauration terminée avec succès !
echo 🌐 ERPNext est accessible sur : http://localhost:8080
echo.
pause
