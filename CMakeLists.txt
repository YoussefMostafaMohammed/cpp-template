cmake_minimum_required(VERSION 3.22)

# ============================================================
# Project Configuration
# ============================================================
project(cpp_template VERSION 1.0 LANGUAGES CXX)

# Option to enable AddressSanitizer
option(ENABLE_ASAN "Enable AddressSanitizer" OFF)

# ============================================================
# Compiler Setup
# ============================================================
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
add_compile_options(-Wall -Wextra -Wpedantic -Werror)

# ============================================================
# Optional Conan detection
# ============================================================
if(EXISTS "${CMAKE_BINARY_DIR}/conan_toolchain.cmake")
    set(CONAN_TOOLCHAIN_FOUND TRUE)
    message(STATUS "Using Conan toolchain: ${CMAKE_BINARY_DIR}/conan_toolchain.cmake")
    include(${CMAKE_BINARY_DIR}/conan_toolchain.cmake)
else()
    set(CONAN_TOOLCHAIN_FOUND FALSE)
    message(STATUS "Conan toolchain not found, building without Conan")
endif()

# ============================================================
# Source Files
# ============================================================
file(GLOB SOURCES CONFIGURE_DEPENDS "src/*.cpp")
add_executable(${PROJECT_NAME} ${SOURCES})
target_include_directories(${PROJECT_NAME} PRIVATE ${PROJECT_SOURCE_DIR}/inc)

# ============================================================
# AddressSanitizer
# ============================================================
if(ENABLE_ASAN)
    target_compile_options(${PROJECT_NAME} PRIVATE -fsanitize=address -fno-omit-frame-pointer)
    target_link_options(${PROJECT_NAME} PRIVATE -fsanitize=address)
endif()

# ============================================================
# Build Summary
# ============================================================
message(STATUS "")
message(STATUS "================ Build Configuration ================")
message(STATUS "Project Name      : ${PROJECT_NAME}")
message(STATUS "Project Version   : ${PROJECT_VERSION}")
message(STATUS "Compiler          : ${CMAKE_CXX_COMPILER}")
message(STATUS "Build Type        : ${CMAKE_BUILD_TYPE}")
message(STATUS "AddressSanitizer  : ${ENABLE_ASAN}")
message(STATUS "Conan Toolchain   : ${CONAN_TOOLCHAIN_FOUND}")
message(STATUS "=====================================================")
message(STATUS "")
