#!/usr/bin/env bash
set -euo pipefail

# Portable Linux build script for cmdbox (Qt 6 + CMake)
# Usage examples:
#   ./build.sh                 # Debug build (auto-detect Ninja/Make), build dir under build/
#   ./build.sh -t Release -r   # Release build and run after build
#   ./build.sh -q /software/local/QT/6.10.1/gcc_64 -t Release
#   ./build.sh -B build/custom  # Use custom build directory
#   ./build.sh -c               # Clean build directory before configure
#   ./build.sh -G "Unix Makefiles"  # Force generator

BUILD_TYPE="Debug"
QT_PREFIX_DEFAULT="/software/local/QT/6.10.1/gcc_64"
QT_PREFIX=""
BUILD_DIR=""
GENERATOR=""
RUN_AFTER=false
CLEAN_FIRST=false
JOBS="$(command -v nproc >/dev/null 2>&1 && nproc || echo 4)"

while getopts ":t:q:B:G:j:rc" opt; do
  case $opt in
    t) BUILD_TYPE="$OPTARG" ;;
    q) QT_PREFIX="$OPTARG" ;;
    B) BUILD_DIR="$OPTARG" ;;
    G) GENERATOR="$OPTARG" ;;
    j) JOBS="$OPTARG" ;;
    r) RUN_AFTER=true ;;
    c) CLEAN_FIRST=true ;;
    *) echo "Usage: $0 [-t Debug|Release] [-q <qt_prefix>] [-B <build_dir>] [-G <generator>] [-j <jobs>] [-r] [-c]"; exit 2 ;;
  esac
done

if [[ -z "$QT_PREFIX" ]]; then
  if [[ -d "$QT_PREFIX_DEFAULT" ]]; then
    QT_PREFIX="$QT_PREFIX_DEFAULT"
  fi
fi

# Export minimal env so CMake can find Qt6
if [[ -n "$QT_PREFIX" ]]; then
  export PATH="$QT_PREFIX/bin:$PATH"
  # Hint CMake to find Qt6
  export CMAKE_PREFIX_PATH="${CMAKE_PREFIX_PATH:-}$([[ -n "${CMAKE_PREFIX_PATH:-}" ]] && echo ";")$QT_PREFIX"
fi

# Choose generator if not provided
if [[ -z "$GENERATOR" ]]; then
  if command -v ninja >/dev/null 2>&1; then
    GENERATOR="Ninja"
  else
    GENERATOR="Unix Makefiles"
  fi
fi

# Default build dir if not provided
if [[ -z "$BUILD_DIR" ]]; then
  GEN_TAG=$(echo "$GENERATOR" | tr ' ' '-' | tr '[:upper:]' '[:lower:]')
  BUILD_DIR="build/${GEN_TAG}-${BUILD_TYPE}"
fi

if $CLEAN_FIRST && [[ -d "$BUILD_DIR" ]]; then
  echo "[clean] Removing $BUILD_DIR"
  rm -rf "$BUILD_DIR"
fi

mkdir -p "$BUILD_DIR"

echo "[config] Generator: $GENERATOR"
if [[ -n "$QT_PREFIX" ]]; then
  echo "[config] Qt prefix: $QT_PREFIX"
fi
echo "[config] Build type: $BUILD_TYPE"
echo "[config] Build dir : $BUILD_DIR"

# Configure
cmake -S . -B "$BUILD_DIR" \
  -G "$GENERATOR" \
  -DCMAKE_BUILD_TYPE="$BUILD_TYPE"

# Build
cmake --build "$BUILD_DIR" -j "$JOBS"

# Show where the binary is
BIN_PATH="$BUILD_DIR/cmdbox"
if [[ -x "$BIN_PATH" ]]; then
  echo "[done] Built: $BIN_PATH"
else
  echo "[warn] Binary not found at $BIN_PATH (check target name in CMakeLists)" >&2
fi

# Run (optionally)
if $RUN_AFTER && [[ -x "$BIN_PATH" ]]; then
  echo "[run] $BIN_PATH"
  exec "$BIN_PATH"
fi
