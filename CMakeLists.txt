cmake_minimum_required(VERSION 3.30)
project(ssh_manager VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

include_directories(src)

set(SOURCES
        src/main.cpp
        src/ssh_manager.cpp
)

if(WIN32)
    find_path(PDCURSES_INCLUDE_DIR NAMES curses.h)
    find_library(PDCURSES_LIBRARY NAMES pdcurses)
    
    if(NOT PDCURSES_INCLUDE_DIR OR NOT PDCURSES_LIBRARY)
        message(FATAL_ERROR "PDCurses не найден. Установите PDCurses или укажите путь через -DCMAKE_PREFIX_PATH")
    endif()
    
    include_directories(${PDCURSES_INCLUDE_DIR})
    add_executable(${PROJECT_NAME} ${SOURCES})
    target_link_libraries(${PROJECT_NAME} ${PDCURSES_LIBRARY})

    target_compile_definitions(${PROJECT_NAME} PRIVATE WIN32)
else()
    find_package(Curses REQUIRED)
    include_directories(${CURSES_INCLUDE_DIR})
    
    add_executable(${PROJECT_NAME} ${SOURCES})
    target_link_libraries(${PROJECT_NAME} ${CURSES_LIBRARIES})

    find_library(TINFO_LIBRARY tinfo)
    if(TINFO_LIBRARY)
        target_link_libraries(${PROJECT_NAME} ${TINFO_LIBRARY})
    endif()
endif()

if(UNIX)
    add_custom_command(
        TARGET ${PROJECT_NAME} POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E create_symlink $<TARGET_FILE_NAME:${PROJECT_NAME}> ssh-manager
        WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
        COMMENT "Creating symlink ssh-manager -> ${PROJECT_NAME}"
    )
endif()

if(WIN32)
    install(TARGETS ${PROJECT_NAME} DESTINATION .)
else()
    install(TARGETS ${PROJECT_NAME} DESTINATION bin)
    install(FILES ${CMAKE_BINARY_DIR}/ssh-manager DESTINATION bin)
endif()
