@echo off
echo ========================================
echo    🛑 ARRÊT DE ERPNEXT WASH&GO
echo ========================================
echo.

:: Se déplacer dans le répertoire du projet
echo 📁 Déplacement vers le répertoire du projet...
cd /d "C:\Users\Floop\Desktop\frappe_dockerWashnGo"
echo ✅ Répertoire : %CD%
echo.

:: Arrêter les conteneurs
echo 🛑 Arrêt des conteneurs ERPNext...
docker compose -f pwd.yml down

echo.
echo ✅ ERPNext Wash&Go a été arrêté avec succès !
echo.
echo 💡 Pour redémarrer, utilisez le raccourci "Wash&Go ERPNext" sur votre bureau
echo.
pause
