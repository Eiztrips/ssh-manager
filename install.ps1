#Requires -RunAsAdministrator

function Write-Green {
    param([string]$Text)
    Write-Host $Text -ForegroundColor Green
}

function Write-Red {
    param([string]$Text)
    Write-Host $Text -ForegroundColor Red
    exit 1
}

Write-Green "Установка SSH Manager для Windows..."

if (-not (Get-Command cmake -ErrorAction SilentlyContinue)) {
    Write-Red "Ошибка: cmake не найден. Установите cmake для продолжения.`nСкачать CMake можно с сайта: https://cmake.org/download/"
}

$vsPath = &"${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe" -latest -property installationPath
if (-not $vsPath) {
    Write-Red "Ошибка: Visual Studio не найдена. Установите Visual Studio с поддержкой C++."
}

$opensshState = Get-WindowsCapability -Online | Where-Object Name -like "OpenSSH.Client*"
if ($opensshState.State -ne "Installed") {
    Write-Host "Установка OpenSSH клиента..." -ForegroundColor Yellow
    Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0
    if ($LASTEXITCODE -ne 0) {
        Write-Red "Ошибка установки OpenSSH клиента."
    }
}

$pdcursesPath = "${env:ProgramFiles}\PDCurses"
if (-not (Test-Path "$pdcursesPath\include\curses.h")) {
    Write-Host "PDCurses не найден. Автоматическая загрузка и установка..." -ForegroundColor Yellow

    $tempDir = Join-Path $env:TEMP "pdcurses-install"
    New-Item -ItemType Directory -Path $tempDir -Force | Out-Null

    $url = "https://github.com/wmcbrine/PDCurses/archive/refs/heads/master.zip"
    $zipPath = Join-Path $tempDir "pdcurses.zip"
    Invoke-WebRequest -Uri $url -OutFile $zipPath

    Expand-Archive -Path $zipPath -DestinationPath $tempDir -Force

    New-Item -ItemType Directory -Path $pdcursesPath -Force | Out-Null
    New-Item -ItemType Directory -Path "$pdcursesPath\include" -Force | Out-Null
    New-Item -ItemType Directory -Path "$pdcursesPath\lib" -Force | Out-Null

    $sourceDir = Join-Path $tempDir "PDCurses-master"
    Copy-Item -Path "$sourceDir\curses.h" -Destination "$pdcursesPath\include\" -Force
    Copy-Item -Path "$sourceDir\panel.h" -Destination "$pdcursesPath\include\" -Force

    Remove-Item -Path $tempDir -Recurse -Force
}

if (-not (Test-Path "build")) {
    New-Item -ItemType Directory -Path "build" | Out-Null
}

Set-Location -Path "build"

& cmake .. -DCMAKE_PREFIX_PATH="$pdcursesPath" -G "Visual Studio 16 2019" -A x64
if ($LASTEXITCODE -ne 0) {
    Write-Red "Ошибка генерации проекта Visual Studio."
}

& cmake --build . --config Release
if ($LASTEXITCODE -ne 0) {
    Write-Red "Ошибка компиляции."
}

Write-Green "Установка программы..."

$installDir = "${env:ProgramFiles}\SSH Manager"
if (-not (Test-Path $installDir)) {
    New-Item -ItemType Directory -Path $installDir -Force | Out-Null
}

Copy-Item -Path ".\Release\ssh_manager.exe" -Destination "$installDir\" -Force

$currentPath = [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::Machine)
if (-not $currentPath.Contains($installDir)) {
    [Environment]::SetEnvironmentVariable("Path", "$currentPath;$installDir", [EnvironmentVariableTarget]::Machine)
}

$WshShell = New-Object -ComObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("$env:APPDATA\Microsoft\Windows\Start Menu\Programs\SSH Manager.lnk")
$Shortcut.TargetPath = "$installDir\ssh_manager.exe"
$Shortcut.Save()

Set-Location -Path ".."

Write-Green "SSH Manager успешно установлен!"
Write-Host "Вы можете запустить программу из меню Пуск или выполнив команду" -NoNewline
Write-Host " ssh_manager " -ForegroundColor Green -NoNewline
Write-Host "в командной строке."

Write-Host "`nДля использования подключений SSH убедитесь, что у вас настроен файл конфигурации SSH:"
Write-Host "  $env:USERPROFILE\.ssh\config"

Write-Host "`nПример файла конфигурации:"
Write-Host "Host myserver`n    HostName example.com`n    User username`n    Port 22" -ForegroundColor Cyan
