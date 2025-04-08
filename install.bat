@echo off
setlocal EnableDelayedExpansion

echo [92mУстановка SSH Manager для Windows...[0m

where cmake >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo [91mОшибка: cmake не найден. Установите cmake для продолжения.[0m
    echo Скачать CMake можно с сайта: https://cmake.org/download/
    exit /b 1
)

where cl >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo [91mОшибка: компилятор MSVC не найден. Установите Visual Studio с инструментами C++.[0m
    exit /b 1
)

if not exist "C:\Program Files\PDCurses\include\curses.h" (
    echo [91mОшибка: библиотека PDCurses не найдена.[0m
    echo Скачайте PDCurses с сайта: https://pdcurses.org/
    echo Установите в C:\Program Files\PDCurses\
    exit /b 1
)

if not exist build (
    mkdir build
)

cd build

cmake .. -DCMAKE_PREFIX_PATH="C:/Program Files/PDCurses" -G "Visual Studio 16 2019" -A x64
if %ERRORLEVEL% neq 0 (
    echo [91mОшибка генерации проекта Visual Studio.[0m
    exit /b 1
)

cmake --build . --config Release
if %ERRORLEVEL% neq 0 (
    echo [91mОшибка компиляции.[0m
    exit /b 1
)

echo [92mУстановка программы...[0m

if not exist "%PROGRAMFILES%\SSH Manager" (
    mkdir "%PROGRAMFILES%\SSH Manager"
)

copy Release\ssh_manager.exe "%PROGRAMFILES%\SSH Manager\" >nul
if %ERRORLEVEL% neq 0 (
    echo [91mНе удалось скопировать файлы. Запустите командную строку от имени администратора.[0m
    exit /b 1
)

setx PATH "%PATH%;%PROGRAMFILES%\SSH Manager" /M
if %ERRORLEVEL% neq 0 (
    echo [91mНе удалось обновить переменную PATH. Запустите командную строку от имени администратора.[0m
)

cd ..

powershell -Command "$WshShell = New-Object -ComObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut('%APPDATA%\Microsoft\Windows\Start Menu\Programs\SSH Manager.lnk'); $Shortcut.TargetPath = '%PROGRAMFILES%\SSH Manager\ssh_manager.exe'; $Shortcut.Save()"

echo [92mSSH Manager успешно установлен![0m
echo Вы можете запустить программу из меню Пуск или выполнив команду [92mssh_manager[0m в командной строке.
echo.
echo Для SSH подключений в Windows убедитесь, что установлен OpenSSH.
echo Для установки OpenSSH выполните в PowerShell с правами администратора:
echo [96mAdd-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0[0m

pause
