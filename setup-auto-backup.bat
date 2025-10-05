@echo off
echo ========================================
echo    ⏰ CONFIGURATION SAUVEGARDE AUTO
echo ========================================
echo.

set SCRIPT_DIR=%~dp0
set BACKUP_SCRIPT=%SCRIPT_DIR%auto-backup-erpnext.bat
set TASK_NAME=ERPNext_AutoBackup

echo 🔧 Configuration de la sauvegarde automatique...
echo.

:: Vérifier si la tâche existe déjà
schtasks /query /tn "%TASK_NAME%" >nul 2>&1
if %errorlevel% equ 0 (
    echo ⚠️  Une tâche de sauvegarde automatique existe déjà
    echo.
    echo Que souhaitez-vous faire ?
    echo 1. Supprimer l'ancienne tâche et en créer une nouvelle
    echo 2. Modifier la tâche existante
    echo 3. Annuler
    echo.
    set /p CHOICE="Votre choix (1/2/3) : "
    
    if "%CHOICE%"=="1" (
        echo.
        echo 🗑️ Suppression de l'ancienne tâche...
        schtasks /delete /tn "%TASK_NAME%" /f >nul
        echo ✅ Ancienne tâche supprimée
    ) else if "%CHOICE%"=="2" (
        echo.
        echo 🔧 Ouverture du planificateur de tâches...
        schtasks /change /tn "%TASK_NAME%"
        echo ✅ Tâche modifiée
        pause
        exit /b 0
    ) else (
        echo ❌ Configuration annulée
        pause
        exit /b 0
    )
)

echo.
echo 📅 Planification de la sauvegarde automatique...
echo.
echo Choisissez la fréquence de sauvegarde :
echo 1. Tous les jours à 2h00
echo 2. Tous les jours à 22h00  
echo 3. Toutes les 6 heures
echo 4. Toutes les 12 heures
echo 5. Personnaliser
echo.
set /p FREQUENCY="Votre choix (1/2/3/4/5) : "

:: Configuration selon le choix
if "%FREQUENCY%"=="1" (
    set SCHEDULE=daily
    set TIME=02:00
    set DESCRIPTION=Sauvegarde quotidienne à 2h00
) else if "%FREQUENCY%"=="2" (
    set SCHEDULE=daily
    set TIME=22:00
    set DESCRIPTION=Sauvegarde quotidienne à 22h00
) else if "%FREQUENCY%"=="3" (
    set SCHEDULE=minute
    set INTERVAL=360
    set DESCRIPTION=Sauvegarde toutes les 6 heures
) else if "%FREQUENCY%"=="4" (
    set SCHEDULE=minute
    set INTERVAL=720
    set DESCRIPTION=Sauvegarde toutes les 12 heures
) else if "%FREQUENCY%"=="5" (
    echo.
    echo ⚙️ Configuration personnalisée :
    echo.
    echo Types de planification disponibles :
    echo - daily (quotidien)
    echo - hourly (horaire)
    echo - minute (par minute)
    echo.
    set /p SCHEDULE="Type de planification : "
    
    if "%SCHEDULE%"=="daily" (
        set /p TIME="Heure (format HH:MM) : "
        set DESCRIPTION=Sauvegarde quotidienne à %TIME%
    ) else if "%SCHEDULE%"=="hourly" (
        set /p INTERVAL="Intervalle en heures : "
        set DESCRIPTION=Sauvegarde toutes les %INTERVAL% heures
    ) else if "%SCHEDULE%"=="minute" (
        set /p INTERVAL="Intervalle en minutes : "
        set DESCRIPTION=Sauvegarde toutes les %INTERVAL% minutes
    ) else (
        echo ❌ Type de planification invalide
        pause
        exit /b 1
    )
) else (
    echo ❌ Choix invalide
    pause
    exit /b 1
)

echo.
echo 🔧 Création de la tâche planifiée...

:: Créer la tâche selon le type de planification
if "%SCHEDULE%"=="daily" (
    schtasks /create /tn "%TASK_NAME%" /tr "\"%BACKUP_SCRIPT%\"" /sc daily /st %TIME% /ru "SYSTEM" /f >nul
) else (
    schtasks /create /tn "%TASK_NAME%" /tr "\"%BACKUP_SCRIPT%\"" /sc %SCHEDULE% /mo %INTERVAL% /ru "SYSTEM" /f >nul
)

if %errorlevel% equ 0 (
    echo ✅ Tâche planifiée créée avec succès !
    echo.
    echo 📋 Détails de la tâche :
    echo    Nom : %TASK_NAME%
    echo    Description : %DESCRIPTION%
    echo    Script : %BACKUP_SCRIPT%
    echo    Utilisateur : SYSTEM
    echo.
    
    echo 📁 Dossier de sauvegarde : C:\Users\Floop\Desktop\backups-erpnext
    echo 📊 Nombre maximum de sauvegardes : 7
    echo 📋 Logs : C:\Users\Floop\Desktop\backups-erpnext\backup.log
    echo.
    
    echo 🎉 Sauvegarde automatique configurée !
    echo.
    echo 💡 Pour gérer la tâche :
    echo    - Ouvrir le Planificateur de tâches Windows
    echo    - Chercher "ERPNext_AutoBackup"
    echo    - Clic droit pour modifier/supprimer
    echo.
    
    echo 🔧 Commandes utiles :
    echo    - Test manuel : %BACKUP_SCRIPT%
    echo    - Nettoyage : %SCRIPT_DIR%cleanup-backups.bat
    echo    - Voir les logs : notepad C:\Users\Floop\Desktop\backups-erpnext\backup.log
    echo.
    
) else (
    echo ❌ Erreur lors de la création de la tâche planifiée
    echo.
    echo 💡 Solutions possibles :
    echo    1. Exécuter en tant qu'administrateur
    echo    2. Vérifier les permissions du planificateur de tâches
    echo    3. Désactiver temporairement l'antivirus
)

echo.
pause
