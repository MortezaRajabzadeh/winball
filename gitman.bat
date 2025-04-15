@echo off
:: gitman.bat - Git multi-repo manager for backend, app, admin_panel

setlocal enabledelayedexpansion

:: Project folders list
set projects=backend app admin_panel

:: Get operation argument (push/pull/status)
if "%~1"=="" (
    echo ❌ Lotfan yeki az operation ha ro bezar: push, pull, ya status
    goto end
)
set operation=%~1
set commit_message=%~2

:: Loop through each project folder
for %%P in (%projects%) do (
    echo ------------------------------------------
    echo 📂 Daram miram tuye folder %%P ...
    cd %%P

    if "%operation%"=="status" (
        echo 🔍 Git Status:
        git status
    ) else if "%operation%"=="pull" (
        echo ⬇️ Daram mikesham (pull) az remote...
        git pull
    ) else if "%operation%"=="push" (
        echo ⬆️ Daram push mikonam...
        git add .
        if "!commit_message!"=="" (
            set commit_message=Auto commit
        )
        git commit -m "!commit_message!"
        git push
    ) else (
        echo 🚫 Operation eshtebah: %operation%
        cd ..
        goto end
    )

    cd ..
)

:end
echo ------------------------------------------
echo ✅ Operation %operation% baraye hameye project ha anjam shod.
pause
