@echo off
echo ========================================
echo    🖥️ CRÉATION DES RACCOURCIS BUREAU
echo ========================================
echo.

:: Créer le raccourci pour démarrer ERPNext
echo 📝 Création du raccourci "Wash&Go ERPNext"...

powershell -Command "$WshShell = New-Object -comObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut('%USERPROFILE%\Desktop\Wash&Go ERPNext.lnk'); $Shortcut.TargetPath = 'C:\Users\Floop\Desktop\frappe_dockerWashnGo\start-erpnext.bat'; $Shortcut.WorkingDirectory = 'C:\Users\Floop\Desktop\frappe_dockerWashnGo'; $Shortcut.Description = 'Lancer ERPNext Wash&Go'; $Shortcut.IconLocation = 'shell32.dll,21'; $Shortcut.Save()"

echo ✅ Raccourci "Wash&Go ERPNext" créé sur le bureau

:: Créer le raccourci pour arrêter ERPNext
echo 📝 Création du raccourci "Arrêter ERPNext"...

powershell -Command "$WshShell = New-Object -comObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut('%USERPROFILE%\Desktop\Arrêter ERPNext.lnk'); $Shortcut.TargetPath = 'C:\Users\Floop\Desktop\frappe_dockerWashnGo\stop-erpnext.bat'; $Shortcut.WorkingDirectory = 'C:\Users\Floop\Desktop\frappe_dockerWashnGo'; $Shortcut.Description = 'Arrêter ERPNext Wash&Go'; $Shortcut.IconLocation = 'shell32.dll,28'; $Shortcut.Save()"

echo ✅ Raccourci "Arrêter ERPNext" créé sur le bureau

:: Créer le raccourci pour accéder directement à l'application
echo 📝 Création du raccourci "Accéder à ERPNext"...

powershell -Command "$WshShell = New-Object -comObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut('%USERPROFILE%\Desktop\Accéder à ERPNext.lnk'); $Shortcut.TargetPath = 'http://localhost:8080/app/home'; $Shortcut.Description = 'Accéder à ERPNext Wash&Go'; $Shortcut.IconLocation = 'shell32.dll,13'; $Shortcut.Save()"

echo ✅ Raccourci "Accéder à ERPNext" créé sur le bureau

echo.
echo 🎉 Tous les raccourcis ont été créés avec succès !
echo.
echo 📋 Raccourcis créés :
echo    🚀 "Wash&Go ERPNext" - Démarrer l'application
echo    🛑 "Arrêter ERPNext" - Arrêter l'application  
echo    🌐 "Accéder à ERPNext" - Ouvrir l'interface web
echo.
echo 💡 Double-cliquez sur "Wash&Go ERPNext" pour lancer l'application !
echo.
pause
