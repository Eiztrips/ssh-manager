#!/bin/bash

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}Установка SSH Manager...${NC}"

if ! command -v cmake &> /dev/null; then
    echo -e "${RED}Ошибка: cmake не найден. Установите cmake для продолжения.${NC}"
    exit 1
fi

if [ -f /etc/os-release ]; then
    . /etc/os-release
    case $ID in
        debian|ubuntu)
            if ! dpkg -l | grep -q libncurses-dev; then
                echo -e "${RED}Библиотека ncurses не найдена. Установите ее командой:${NC}"
                echo -e "sudo apt-get install libncurses-dev"
                exit 1
            fi
            ;;
        fedora|centos|rhel)
            if ! rpm -qa | grep -q ncurses-devel; then
                echo -e "${RED}Библиотека ncurses не найдена. Установите ее командой:${NC}"
                echo -e "sudo dnf install ncurses-devel"
                exit 1
            fi
            ;;
    esac
else
    if ! pkg-config --exists ncurses; then
        echo -e "${RED}Ошибка: библиотека ncurses не найдена. Установите libncurses-dev для продолжения.${NC}"
        exit 1
    fi
fi

mkdir -p build
cd build || exit 1

cmake ..
if [ $? -ne 0 ]; then
    echo -e "${RED}Ошибка генерации Makefile.${NC}"
    exit 1
fi

make
if [ $? -ne 0 ]; then
    echo -e "${RED}Ошибка компиляции.${NC}"
    exit 1
fi

echo -e "${GREEN}Установка программы в систему...${NC}"
if command -v sudo &> /dev/null; then
    sudo make install
    if [ $? -ne 0 ]; then
        echo -e "${RED}Ошибка при установке. Попробуйте запустить установку с sudo.${NC}"
        exit 1
    fi
else
    make install
    if [ $? -ne 0 ]; then
        echo -e "${RED}Ошибка при установке. Запустите скрипт с правами суперпользователя.${NC}"
        exit 1
    fi
fi

cd ..
echo -e "${GREEN}SSH Manager успешно установлен!${NC}"
echo -e "Теперь вы можете запустить программу, выполнив команду ${GREEN}ssh_manager${NC} или ${GREEN}ssh-manager${NC}"
