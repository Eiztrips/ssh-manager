/**
* Copyright (c) 2024 Eiztrips
 *
 * This software is released under the MIT License.
 * https://opensource.org/licenses/MIT
 */

#include "ssh_manager.h"
#include <vector>
#include <string>
#include <fstream>
#include <iostream>
#include <regex>
#include <cstdlib>
#include <locale.h>

#ifdef WIN32
    #include <windows.h>
    #include <Shlobj.h> // Для SHGetFolderPath
    #include <curses.h>
#else
    #include <ncurses.h>
#endif

std::string get_home_directory() {
#ifdef WIN32
    char path[MAX_PATH];
    if (SUCCEEDED(SHGetFolderPathA(NULL, CSIDL_PROFILE, NULL, 0, path))) {
        return std::string(path);
    } else {
        return "C:\\Users\\Default";
    }
#else
    const char* home_dir = getenv("HOME");
    if (home_dir) {
        return std::string(home_dir);
    } else {
        return "";
    }
#endif
}

std::vector<std::string> get_ssh_keys() {
    std::vector<std::string> keys;

    std::string home_dir = get_home_directory();
    if (home_dir.empty()) {
        std::cerr << "Не удалось получить домашнюю директорию" << std::endl;
        keys.push_back("myserver");
        return keys;
    }

#ifdef WIN32
    std::string config_path = home_dir + "\\.ssh\\config";
#else
    std::string config_path = home_dir + "/.ssh/config";
#endif

    std::ifstream config(config_path);

    if (config.is_open()) {
        std::string line;
        std::regex host_regex("^Host\\s+([^*\\s]+)", std::regex::icase);
        std::smatch matches;

        while (std::getline(config, line)) {
            if (line.empty() || line[0] == '#') {
                continue;
            }

            if (std::regex_search(line, matches, host_regex)) {
                keys.push_back(matches[1].str());
            }
        }
        config.close();
    } else {
        std::cerr << "Не удалось открыть файл " << config_path << std::endl;
    }

    if (keys.empty()) {
        keys.push_back("myserver");
    }

    return keys;
}

void execute_ssh_command(const std::string& server) {
#ifdef WIN32
    std::string command = "start cmd.exe /K ssh " + server;
    system(command.c_str());
#else
    std::string command = "ssh " + server;
    system(command.c_str());
#endif
}

void show_menu() {
#ifdef WIN32
    setlocale(LC_CTYPE, "");
#else
    setlocale(LC_ALL, "");
#endif

    if(initscr() == NULL) {
        std::cerr << "Ошибка инициализации ncurses" << std::endl;
        return;
    }
    
    start_color();
    cbreak();
    noecho();
    keypad(stdscr, TRUE);
    curs_set(0);

    int rows, cols;
    getmaxyx(stdscr, rows, cols);

    std::vector<std::string> keys = get_ssh_keys();
    int choice;
    int highlight = 0;

    while (true) {
        clear();

        attron(A_BOLD);
        mvprintw(0, 0, "SSH Manager - Выберите сервер для подключения");
        attroff(A_BOLD);
        
        mvprintw(1, 0, "Используйте стрелки для навигации, Enter для подключения");

        for (int i = 0; i < keys.size(); ++i) {
            if (i == highlight)
                attron(A_REVERSE);
            mvprintw(i + 3, 2, "%s", keys[i].c_str());
            if (i == highlight)
                attroff(A_REVERSE);
        }
        
        refresh();
        choice = getch();
        
        switch (choice) {
            case KEY_UP:
                highlight = (highlight == 0) ? keys.size() - 1 : highlight - 1;
                break;
            case KEY_DOWN:
                highlight = (highlight == keys.size() - 1) ? 0 : highlight + 1;
                break;
            case 10:
            {
                std::string selected_server = keys[highlight];
                endwin();
                
                execute_ssh_command(selected_server);
                return;
            }
            case 27:
                endwin();
                return;
        }
    }
    endwin();
}

