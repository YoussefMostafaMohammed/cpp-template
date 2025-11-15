# cpp_template

A **C++ project template** supporting multiple build systems and workflows: **CMake**, **Bazel**, **Docker**, and **Conan**.
Designed for a clean **C++17 setup** with strict compiler warnings, optional **AddressSanitizer**, and optional dependency management via **Conan**.

---

## Table of Contents

1. [Project Overview](#project-overview)
2. [Project Structure](#project-structure)
3. [Build Systems](#build-systems)
   * [CMake](#building-with-cmake)
   * [Bazel](#building-with-bazel)
4. [Conan Integration](#conan-integration)
5. [Docker Workflow](#docker-workflow)
6. [AddressSanitizer](#addresssanitizer)

---

## Project Overview

This template provides:

* **C++17 setup** with strict compiler warnings.
* Optional **AddressSanitizer** for memory debugging.
* Optional dependency management via **Conan**.
* Build options: **CMake** or **Bazel**, optionally using Conan.
* A ready-to-use **Dockerfile** for controlled, reproducible builds.

---

## Project Structure

```
cpp_template/
├── src/              # C++ source files
├── inc/              # Header files
├── CMakeLists.txt    # CMake project file
├── MODULE.bazel      # Bazel module file
├── Dockerfile        # Docker build setup
├── conanfile.py      # Conan dependency manager
├── README.md
```

---

## Build Systems

### Building with CMake

**Without Conan:**

```bash
mkdir -p build
cmake -B build -S . -DCMAKE_BUILD_TYPE=Debug
cmake --build build
./build/cpp_template
```

**With Conan:**

```bash
conan install . -of=.conan -g CMakeToolchain -g CMakeDeps
cmake -B build -S . -DCMAKE_BUILD_TYPE=Debug -DCMAKE_TOOLCHAIN_FILE=.conan/conan_toolchain.cmake
cmake --build build
./build/cpp_template
```

---

### Building with Bazel

**Without Conan:**

```bash
bazel build //src:main --check_direct_dependencies=off
./bazel-bin/src/main
```

**With Conan:**

```bash
conan install . -of=.conan -g BazelToolchain -g BazelDeps
bazel --bazelrc=.conan/conan_bzl.rc build --config=conan-config //src:main
./bazel-bin/src/main
```

---

## Conan Integration

* Conan is optional and can manage dependencies if needed.
* Generators per build system:

| Build System | Generators                    |
| ------------ | ----------------------------- |
| CMake        | `CMakeToolchain`, `CMakeDeps` |
| Bazel        | `BazelToolchain`, `BazelDeps` |

* If Conan is not used, the project builds using system libraries only.

---

## Docker Workflow

With the provided **Dockerfile**, building and running your project is simple. The container automatically detects:

* Build system: **CMake** or **Bazel** (`$BUILD_SYSTEM`)
* Conan usage: enabled or disabled (`$USE_CONAN`)

**Default usage (CMake + Conan):**

```bash
docker build -t cpp_template:latest .
docker run --rm cpp_template:latest

```

**Customize build system or Conan usage:**

```bash
# Example: Bazel build without Conan
docker build --build-arg BUILD_SYSTEM=bazel --build-arg USE_CONAN=false -t cpp_template:latest .
docker run --rm cpp_template:latest

```

> The Dockerfile handles Conan installation, toolchain configuration, and building automatically.

---

## AddressSanitizer

Enable AddressSanitizer in CMake:

```bash
cmake -B build -S . -DENABLE_ASAN=ON
cmake --build build
```

* Detects memory leaks, invalid reads/writes, and buffer overflows.
* Works with both **CMake** and **Docker workflows**.

---

This README now **matches your Dockerfile and CMakeLists.txt** and clearly documents the workflow for both local and containerized builds.
