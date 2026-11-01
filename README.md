# Snora Native Media Engine & FFmpeg Android Toolchain

A high-performance automated toolchain engineered to build **FFmpeg** and the **Snora Native Media Engine** (`libsnora.so`) for **Android**. Produces production-ready native libraries (`.so`), C/C++ header trees, and standalone executables optimized for Android audio/video playback, streaming, and editing pipelines.

---

## 🌟 Key Capabilities

- **Snora Core Engine (`libsnora.so`)**: High-performance native playback engine compiled with GPU rendering and hardware decoding integration.
- **Full Modular FFmpeg Suite**:
  - `libavcodec.so` – Codec engine with hardware acceleration (MediaCodec) and comprehensive software decoders.
  - `libavformat.so` – Demuxers and muxers for all multimedia container formats and streaming protocols.
  - `libavutil.so` – Core utilities, memory management, and math routines.
  - `libswresample.so` – High-precision audio resampling, format conversion, and channel mixing.
  - `libswscale.so` – Color space conversion, pixel format translation, and image scaling.
  - `libavfilter.so` – Audio and video filter graphs (loudnorm, equalizers, deinterlacing, rotation, scaling).
  - `libavdevice.so` – Hardware capture and input devices.
  - `libplacebo.so` – Next-generation GPU video rendering and color management.
- **Full Codec & Format Coverage**:
  - **Audio**: Dolby Digital (AC3), Dolby Digital Plus / Atmos (E-AC3), Dolby TrueHD, MLP, DTS / DTS-HD Master Audio (DCA), AAC, Opus, MP3, FLAC, ALAC, Monkey's Audio (APE), WavPack, WMA, AMR, RealAudio, ATRAC, DSD.
  - **Video**: HEVC / H.265 (Main10 10-bit HDR), AVC / H.264 (Hi10P), AV1 (via `libdav1d`), VP9 (Profile 2), VP8, MPEG-4, MPEG-1/2, VC-1, RealVideo, Apple ProRes, Theora.
  - **Hardware Acceleration**: Android MediaCodec HW decoding enabled for H.264, HEVC, MPEG-4, VP8, VP9, and AV1.
  - **Stylized Subtitles**: Full ASS / SSA subtitle rendering pipeline powered by `libass`, `libfreetype`, and `libfribidi`.
  - **Network & Protocols**: HLS, DASH, HTTP, HTTPS, TLS (`mbedtls`), RTMP, RTSP, UDP, TCP.
- **Standalone CLI Tools**: Android native `ffmpeg` and `ffprobe` binaries ready for command-line execution or `ProcessBuilder` integration.
- **Clean NDK Distribution**: Automatic cleanup of build-time artifacts (`pkgconfig`, temporary static artifacts) so only runtime libraries and headers are packaged.

---

## ⚡ Quick Start

### 1. Build Everything (Snora + Complete Codec Suite)

```bash
./ffmpeg-android-maker.sh --profile=ultimate -abis=arm64-v8a,armeabi-v7a
```
*or using the convenience script:*
```bash
./tools/build-snora.sh -abis=arm64-v8a,armeabi-v7a
```

### 2. Custom ABI Targeting

Specify only the ABIs your application targets:
```bash
./ffmpeg-android-maker.sh --profile=snora -abis=arm64-v8a
```
Supported ABIs: `arm64-v8a`, `armeabi-v7a`, `x86`, `x86_64`.

---

## 📁 Output Structure

After compilation completes, files are structured under `output/`:

```
output/
├── lib/
│   ├── arm64-v8a/
│   │   ├── libsnora.so
│   │   ├── libplacebo.so
│   │   ├── libavcodec.so
│   │   ├── libavformat.so
│   │   ├── libavutil.so
│   │   ├── libswresample.so
│   │   ├── libswscale.so
│   │   ├── libavfilter.so
│   │   └── libavdevice.so
│   └── armeabi-v7a/
│       └── ...
├── include/
│   ├── arm64-v8a/
│   │   ├── libavcodec/
│   │   ├── libavformat/
│   │   └── ...
│   └── armeabi-v7a/
│       └── ...
└── bin/
    ├── arm64-v8a/
    │   ├── ffmpeg
    │   └── ffprobe
    └── armeabi-v7a/
        └── ...
```

---

## 📱 Android Studio Integration

### 1. Place Shared Libraries

Copy the `.so` files into your Android app module:
```
app/src/main/jniLibs/
├── arm64-v8a/
│   ├── libsnora.so
│   ├── libavcodec.so
│   ├── libavformat.so
│   ├── libavutil.so
│   ├── libswresample.so
│   ├── libswscale.so
│   ├── libavfilter.so
│   └── libplacebo.so
└── armeabi-v7a/
    └── ...
```

### 2. Include Headers (NDK / CMake)

Copy `output/include/<abi>/` to `app/src/main/cpp/include/` and link in your `CMakeLists.txt`:

```cmake
cmake_minimum_required(VERSION 3.22.1)
project("snora_player")

include_directories(${CMAKE_CURRENT_SOURCE_DIR}/include)
set(NATIVE_LIBS_DIR ${CMAKE_CURRENT_SOURCE_DIR}/../jniLibs/${ANDROID_ABI})

add_library(snora SHARED IMPORTED)
set_target_properties(snora PROPERTIES IMPORTED_LOCATION ${NATIVE_LIBS_DIR}/libsnora.so)

target_link_libraries(
    your_app_native_lib
    snora
    android
    log
)
```

### 3. Load Native Libraries in Kotlin

```kotlin
package com.example.player

class SnoraEngine {
    companion object {
        init {
            System.loadLibrary("avutil")
            System.loadLibrary("swresample")
            System.loadLibrary("avcodec")
            System.loadLibrary("avformat")
            System.loadLibrary("swscale")
            System.loadLibrary("avfilter")
            System.loadLibrary("snora")
        }
    }

    external fun initializePlayer(): Boolean
}
```

---

## ⚙️ Configuration & Options

| Option | Description |
| :--- | :--- |
| `--profile=ultimate` or `--profile=snora` | Enables all decoders, parsers, demuxers, MediaCodec, and external libraries including `libsnora.so`. |
| `-abis=<list>` | Target ABIs (comma-separated, e.g., `arm64-v8a,armeabi-v7a`). |
| `--enable-snora` | Compiles the Snora native shared library (`libsnora.so`). |
| `--enable-mediacodec` | Enables Android MediaCodec hardware decoding. |
| `--enable-libass` | Enables ASS subtitle rendering via FreeType and FriBidi. |
| `--enable-libplacebo` | Enables GPU rendering primitives via `libplacebo`. |
| `--android-api-level=<num>` | Target minimum Android API level (Default: `21`). |

---

## 🛠️ Build Environment Prerequisites

- **Linux / macOS Host**
- **Android NDK**: r25c recommended (r23+ supported)
- **Host Tools**: `curl`, `tar`, `python3`, `ninja`, `meson`, `pkg-config`, `nasm`, `yasm`, `make`, `cmake`, `clang`
- **Environment Variables**:
  ```bash
  export ANDROID_NDK_HOME=/path/to/android-ndk
  export ANDROID_SDK_HOME=/path/to/android-sdk
  ```
