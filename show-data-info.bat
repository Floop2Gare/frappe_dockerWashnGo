@echo off
echo ========================================
echo    📊 INFORMATIONS DONNÉES ERPNext
echo ========================================
echo.

echo 🗄️ VOLUMES DOCKER :
echo.
docker volume ls | findstr frappe_dockerwashngo

echo.
echo 📁 TAILLE DES VOLUMES :
echo.
for %%v in (frappe_dockerwashngo_sites frappe_dockerwashngo_db-data frappe_dockerwashngo_logs frappe_dockerwashngo_redis-queue-data) do (
    echo Volume: %%v
    docker system df -v | findstr %%v
    echo.
)

echo 🗄️ INFORMATIONS BASE DE DONNÉES :
echo.
docker compose -f pwd.yml exec backend bash -lc "cd /home/frappe/frappe-bench && bench --site frontend mariadb"
echo.

echo 📊 STATISTIQUES DU SITE :
echo.
docker compose -f pwd.yml exec backend bash -lc "cd /home/frappe/frappe-bench && bench --site frontend show-config"
echo.

echo 📁 STRUCTURE DES FICHIERS :
echo.
docker compose -f pwd.yml exec backend bash -lc "ls -la /home/frappe/frappe-bench/sites/frontend/ | head -20"
echo.

echo 💾 ESPACE DISQUE DISPONIBLE :
echo.
docker compose -f pwd.yml exec backend bash -lc "df -h /home/frappe/frappe-bench/sites/"
echo.

echo 🎯 RÉSUMÉ :
echo.
echo ✅ Données stockées dans 4 volumes Docker persistants
echo ✅ Base de données : MariaDB avec toutes vos données ERPNext
echo ✅ Fichiers : Configuration, assets, logs, uploads
echo ✅ Sauvegarde : Scripts backup et restore disponibles
echo.
echo 💡 Pour sauvegarder : utilisez backup-erpnext.bat
echo 💡 Pour restaurer : utilisez restore-erpnext.bat
echo.
pause
