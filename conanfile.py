from conan import ConanFile
import os

class CppTemplateConan(ConanFile):
    # ---------------------------
    # Package metadata
    # ---------------------------
    name = "cpp_template"     # Name of the Conan package
    version = "1.0.0"         # Version of the package

    # ---------------------------
    # Build settings
    # ---------------------------
    settings = "os", "compiler", "build_type", "arch"  # Standard settings for OS, compiler, build type, architecture

    # ---------------------------
    # Dependencies
    # ---------------------------
    # Empty list for template — users can add dependencies here
    requires = []

    # ---------------------------
    # Auto-select generators based on build system
    # ---------------------------
    # Default build system is CMake, can switch to Bazel via environment variable
    build_system = os.getenv("BUILD_SYSTEM", "cmake")  # "cmake" or "bazel"

    if build_system == "bazel":
        # Use Bazel-specific Conan generators
        generators = ["BazelToolchain", "BazelDeps"]
    else:
        # Use CMake-specific Conan generators
        generators = ["CMakeToolchain", "CMakeDeps"]

    # ---------------------------
    # Default options (empty for template)
    # ---------------------------
    default_options = {}

    # ---------------------------
    # Project layout
    # ---------------------------
    def layout(self):
        # Define source and build folders
        self.folders.source = "."          # Source code is in the root
        self.folders.build = "build"      # Build outputs go into build/

    # ---------------------------
    # Optional build requirements
    # ---------------------------
    def build_requirements(self):
        # No special build requirements by default
        # Users can override this to add tools like clang-format, cppcheck, etc.
        pass

    # ---------------------------
    # Build logic
    # ---------------------------
    def build(self):
        # Intentionally empty — template users choose their build system manually
        # CMake or Bazel builds should be triggered outside Conan
        pass
