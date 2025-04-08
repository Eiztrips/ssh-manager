# SSH Manager

Удобный менеджер SSH-подключений с интерфейсом на ncurses.

## Требования

### Для Linux
- CMake 3.30 или выше
- Компилятор с поддержкой C++20
- Библиотека ncurses

### Для Windows
- CMake 3.30 или выше
- Visual Studio с поддержкой C++20
- PDCurses
- OpenSSH для Windows

## Установка

### Linux

#### Автоматическая установка

```bash
# Скачайте репозиторий
git clone https://github.com/username/ssh-manager.git
cd ssh-manager

# Запустите установщик
chmod +x install.sh
./install.sh
```

После установки вы можете запустить программу, выполнив команду `ssh-manager` в терминале.

#### Ручная установка

```bash
# Скачайте репозиторий
git clone https://github.com/username/ssh-manager.git
cd ssh-manager

# Сборка и установка
mkdir build && cd build
cmake ..
make
sudo make install
```

### Windows

#### Предварительные требования

1. Установите [CMake](https://cmake.org/download/)
2. Установите [Visual Studio](https://visualstudio.microsoft.com/) с поддержкой C++
3. Установите [PDCurses](https://pdcurses.org/)
4. Установите OpenSSH для Windows:
   ```powershell
   # Выполните в PowerShell с правами администратора
   Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0
   ```

#### Автоматическая установка

1. Скачайте репозиторий
   ```
   git clone https://github.com/username/ssh-manager.git
   cd ssh-manager
   ```

2. Запустите установщик от имени администратора
   ```
   install.bat
   ```

#### Ручная установка

```powershell
# Скачайте репозиторий
git clone https://github.com/username/ssh-manager.git
cd ssh-manager

# Сборка
mkdir build
cd build
cmake .. -DCMAKE_PREFIX_PATH="C:/Program Files/PDCurses" -G "Visual Studio 16 2019" -A x64
cmake --build . --config Release

# Установка
copy Release\ssh_manager.exe C:\Windows\System32\
```

## Использование

Запустите программу командой:

```
ssh-manager
```

Используйте стрелки вверх и вниз для навигации по списку серверов, Enter для подключения к выбранному серверу, и Esc для выхода.

## Настройка

Программа использует стандартный конфигурационный файл SSH:
- Linux: `~/.ssh/config`
- Windows: `C:\Users\<имя_пользователя>\.ssh\config`

Создайте этот файл, если он отсутствует, и добавьте в него конфигурацию SSH серверов:

```
Host myserver
    HostName example.com
    User username
    Port 22

Host anotherserver
    HostName 192.168.1.100
    User admin
    Port 2222
```
