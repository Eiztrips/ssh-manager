/**
* Copyright (c) 2024 Eiztrips
 *
 * This software is released under the MIT License.
 * https://opensource.org/licenses/MIT
 */

#include <iostream>
#include <stdexcept>
#include "ssh_manager.h"

int main() {
    try {
        show_menu();
    } catch(const std::exception& e) {
        std::cerr << "Ошибка: " << e.what() << std::endl;
        return 1;
    } catch(...) {
        std::cerr << "Произошла неизвестная ошибка" << std::endl;
        return 1;
    }
    return 0;
}
