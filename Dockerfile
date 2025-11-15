# ============================================================
# Base Image
# ============================================================
FROM ubuntu:22.04

# ------------------------------------------------------------
# Install essential tools: CMake, Python, Bazel, system libs
# ------------------------------------------------------------
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    git \
    python3-pip \
    curl \
    unzip \
    zip \
    openjdk-11-jdk \
    libspdlog-dev \
    libfmt-dev \
    && pip3 install --upgrade pip \
    && pip3 install conan \
    && rm -rf /var/lib/apt/lists/*

# ------------------------------------------------------------
# Install Bazel
# ------------------------------------------------------------
RUN curl -fsSL https://bazel.build/bazel-release.pub.gpg | gpg --dearmor \
        > /usr/share/keyrings/bazel-archive-keyring.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/bazel-archive-keyring.gpg] \
        https://storage.googleapis.com/bazel-apt stable jdk1.8" \
        > /etc/apt/sources.list.d/bazel.list \
    && apt-get update \
    && apt-get install -y bazel

# ============================================================
# Workspace Setup
# ============================================================
WORKDIR /app
ENV IN_DOCKER=1

# Build configuration
ARG BUILD_SYSTEM=cmake       # Options: cmake | bazel
ARG USE_CONAN=true           # Options: true | false
ENV BUILD_SYSTEM=${BUILD_SYSTEM}
ENV USE_CONAN=${USE_CONAN}

# ============================================================
# Copy project files
# ============================================================
COPY . .

# ============================================================
# Install Conan dependencies if enabled
# ============================================================
RUN if [ "$USE_CONAN" = "true" ]; then \
        echo "Installing dependencies via Conan..."; \
        conan profile detect; \
        if [ "$BUILD_SYSTEM" = "cmake" ]; then \
            conan install . --output-folder=.conan --build=missing -g CMakeToolchain -g CMakeDeps; \
        elif [ "$BUILD_SYSTEM" = "bazel" ]; then \
            conan install . --output-folder=.conan --build=missing -g BazelDeps -g BazelToolchain; \
        else \
            echo "Unknown BUILD_SYSTEM=$BUILD_SYSTEM"; exit 1; \
        fi; \
    else \
        echo "Conan disabled → using system packages only"; \
    fi

# ============================================================
# Build Phase
# ============================================================
RUN if [ "$BUILD_SYSTEM" = "cmake" ]; then \
        mkdir -p build && cd build && \
        if [ "$USE_CONAN" = "true" ]; then \
            cmake .. -DCMAKE_BUILD_TYPE=Debug -DCMAKE_TOOLCHAIN_FILE=../.conan/conan_toolchain.cmake; \
        else \
            cmake .. -DCMAKE_BUILD_TYPE=Debug; \
        fi && \
        cmake --build . -- -j$(nproc); \
    elif [ "$BUILD_SYSTEM" = "bazel" ]; then \
        if [ "$USE_CONAN" = "true" ]; then \
            bazel --bazelrc=.conan/conan_bzl.rc build --config=conan-config //src:main; \
        else \
            bazel build //src:main --check_direct_dependencies=off; \
        fi; \
    else \
        echo "Unknown BUILD_SYSTEM=$BUILD_SYSTEM"; exit 1; \
    fi

# ============================================================
# Default run command
# ============================================================
CMD ["sh", "-c", "if [ \"$BUILD_SYSTEM\" = \"cmake\" ]; then ./build/cpp_template; else ./bazel-bin/src/main; fi"]
