@echo off
echo ========================================
echo    🚀 LANCEMENT DE ERPNEXT WASH&GO
echo ========================================
echo.

:: Vérifier si Docker Desktop est en cours d'exécution
echo 📋 Vérification de Docker Desktop...
docker version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Docker Desktop n'est pas démarré !
    echo.
    echo 🔧 Veuillez démarrer Docker Desktop puis relancer ce script.
    echo.
    pause
    exit /b 1
)
echo ✅ Docker Desktop est actif
echo.

:: Se déplacer dans le répertoire du projet
echo 📁 Déplacement vers le répertoire du projet...
cd /d "C:\Users\Floop\Desktop\frappe_dockerWashnGo"
echo ✅ Répertoire : %CD%
echo.

:: Vérifier si les conteneurs sont déjà en cours d'exécution
echo 🔍 Vérification de l'état des conteneurs...
docker compose -f pwd.yml ps --format "table {{.Name}}\t{{.Status}}" | findstr "Up" >nul
if %errorlevel% equ 0 (
    echo ✅ Les conteneurs ERPNext sont déjà en cours d'exécution
    echo.
    echo 🌐 Ouverture de l'application dans le navigateur...
    start http://localhost:8080/app/home
    echo.
    echo ✅ ERPNext Wash&Go est accessible sur : http://localhost:8080/app/home
    echo 👤 Identifiants : Administrator / admin
    echo.
    pause
    exit /b 0
)

:: Démarrer les conteneurs
echo 🚀 Démarrage des conteneurs ERPNext...
docker compose -f pwd.yml up -d

:: Attendre que les services soient prêts
echo ⏳ Attente du démarrage des services (30 secondes)...
timeout /t 30 /nobreak >nul

:: Vérifier l'état final
echo 🔍 Vérification de l'état final...
docker compose -f pwd.yml ps --format "table {{.Name}}\t{{.Status}}" | findstr "Up" >nul
if %errorlevel% equ 0 (
    echo ✅ ERPNext Wash&Go démarré avec succès !
    echo.
    echo 🌐 Ouverture de l'application dans le navigateur...
    start http://localhost:8080/app/home
    echo.
    echo ✅ ERPNext Wash&Go est accessible sur : http://localhost:8080/app/home
    echo 👤 Identifiants : Administrator / admin
    echo.
    echo 📝 Pour arrêter l'application, utilisez le script "stop-erpnext.bat"
) else (
    echo ❌ Erreur lors du démarrage d'ERPNext
    echo.
    echo 🔧 Vérifiez les logs avec : docker compose -f pwd.yml logs
)

echo.
pause
