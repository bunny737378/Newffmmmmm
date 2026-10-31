# FFmpeg Android Maker (Ultimate Universal Edition)

[![Compilability check](https://github.com/Javernaut/ffmpeg-android-maker/actions/workflows/build.yml/badge.svg)](https://github.com/Javernaut/ffmpeg-android-maker/actions/workflows/build.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE.txt)

A powerful, high-performance toolchain script that compiles **FFmpeg** for **Android** with **maximum decoder and codec power** (having every single capability of MX Player's engine—Dolby AC3, E-AC3, TrueHD, DTS, DCA, libass subtitles, AV1, HEVC 10-bit, VP9, MediaCodec HW acceleration) built for use in **any Android application**!

---

## 🚀 What Makes This Build "Ultimate"?

Unlike stripped-down builds, this toolchain compiles FFmpeg with **100% complete decoder coverage**:
- **Use in ANY Android app**: Works seamlessly with Android Studio, NDK / CMake, Java/Kotlin JNI, ExoPlayer FFmpeg extension, ijkplayer, custom video editors, or terminal/CLI tools.
- **Both Modular & Unified Libraries Produced**:
  - **Modular shared libraries** (`libavcodec.so`, `libavformat.so`, `libavutil.so`, `libswresample.so`, `libswscale.so`, `libavfilter.so`, `libavdevice.so`) for fine-grained NDK linking.
  - **Unified single shared library** (`libffmpeg.so`) so you can load the entire engine with a single `System.loadLibrary("ffmpeg")` without dependency order headaches!
- **Full C/C++ Headers**: Complete `include/` directory generated for every target ABI.
- **Standalone Android CLI Executables**: `bin/ffmpeg` and `bin/ffprobe` for running commands directly.
- **Hardware Acceleration**: Android **MediaCodec** hardware decoding enabled for H.264, HEVC, MPEG-4, VP8, VP9, and AV1.
- **Styled Subtitles**: **`libass`** + **`libfreetype`** + **`libfribidi`** built-in for rendering stylized SSA/ASS anime subtitles with custom fonts and positioning.

---

## ⚡ Quick Start: Compile the Ultimate Profile

To compile FFmpeg with all decoders, hardware acceleration, and universal libraries for Android:

```bash
./ffmpeg-android-maker.sh --profile=ultimate -abis=arm64-v8a,armeabi-v7a
```
*or using the convenience shortcut:*
```bash
./tools/build-ultimate.sh -abis=arm64-v8a,armeabi-v7a
```

### Build Outputs
Once compilation completes, files are organized in the `output/` directory:
- `output/lib/<abi>/` – Modular shared libraries (`libavcodec.so`, `libavformat.so`, etc.)
- `output/unified/<abi>/libffmpeg.so` – Unified single shared library for simple drop-in JNI
- `output/include/<abi>/` – Complete C/C++ API header tree
- `output/bin/<abi>/` – Standalone `ffmpeg` and `ffprobe` executables

---

## 📱 How to Use in YOUR Android Apps

### Method 1: In Android Studio with CMake (NDK)

1. Copy headers from `output/include/<abi>/` into your Android project at `app/src/main/cpp/include/`.
2. Copy the `.so` files from `output/lib/<abi>/` into `app/src/main/jniLibs/<abi>/`.
3. In your `app/src/main/cpp/CMakeLists.txt`:

```cmake
cmake_minimum_required(VERSION 3.22.1)
project("my_player_app")

# Include FFmpeg headers
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/include)

# Configure imported FFmpeg libraries
set(FFMPEG_LIBS_DIR ${CMAKE_CURRENT_SOURCE_DIR}/../jniLibs/${ANDROID_ABI})

add_library(avformat SHARED IMPORTED)
set_target_properties(avformat PROPERTIES IMPORTED_LOCATION ${FFMPEG_LIBS_DIR}/libavformat.so)

add_library(avcodec SHARED IMPORTED)
set_target_properties(avcodec PROPERTIES IMPORTED_LOCATION ${FFMPEG_LIBS_DIR}/libavcodec.so)

add_library(avutil SHARED IMPORTED)
set_target_properties(avutil PROPERTIES IMPORTED_LOCATION ${FFMPEG_LIBS_DIR}/libavutil.so)

add_library(swresample SHARED IMPORTED)
set_target_properties(swresample PROPERTIES IMPORTED_LOCATION ${FFMPEG_LIBS_DIR}/libswresample.so)

add_library(swscale SHARED IMPORTED)
set_target_properties(swscale PROPERTIES IMPORTED_LOCATION ${FFMPEG_LIBS_DIR}/libswscale.so)

# Link to your native library
target_link_libraries(
    my_native_lib
    avformat
    avcodec
    avutil
    swresample
    swscale
    android
    log
)
```

---

### Method 2: Single-Library Drop-in (`libffmpeg.so`)

If you don't want to manage 7 different `.so` files and their dependencies in Java/Kotlin:
1. Copy `output/unified/<abi>/libffmpeg.so` into `app/src/main/jniLibs/<abi>/`.
2. In your Kotlin or Java code, load it with one line:

```kotlin
class VideoPlayer {
    companion object {
        init {
            System.loadLibrary("ffmpeg")
        }
    }

    // Your native JNI methods can now call any FFmpeg function!
}
```

---

### Method 3: ExoPlayer FFmpeg Extension

Drop the compiled `.so` files into ExoPlayer's `extension-ffmpeg` directory:
- Place `libavcodec.so`, `libavformat.so`, `libavutil.so`, `libswresample.so` into the extension's `jniLibs` folder.
- Rebuild ExoPlayer to get instant playback support for AC-3, E-AC-3, TrueHD, DTS, and FLAC audio in your ExoPlayer app!

---

### Method 4: CLI Executable in Android App

To run FFmpeg commands (transcoding, trimming, filter graphs, extracting audio) from your Android app via `ProcessBuilder`:
1. Include `output/bin/<abi>/ffmpeg` in your app's native assets or executable directory.
2. Grant execution permissions (`chmod 755`) and invoke:

```kotlin
val process = ProcessBuilder(
    context.applicationInfo.nativeLibraryDir + "/ffmpeg",
    "-i", inputVideoPath,
    "-c:v", "copy",
    "-c:a", "aac",
    outputVideoPath
).start()
```

---

## 🎧 Complete Codec & Decoder Matrix

### 1. Audio Decoders
| Format | Decoders / Parsers | Notes |
| :--- | :--- | :--- |
| **Dolby Digital** | `ac3`, `ac3_fixed` | 5.1 / 2.0 channel surround audio |
| **Dolby Digital Plus** | `eac3` | EAC3 / E-AC-3 / Dolby Atmos core |
| **Dolby TrueHD** | `truehd` | Lossless Blu-ray master audio |
| **MLP** | `mlp` | Meridian Lossless Packing / DVD-Audio |
| **DTS / DTS-HD** | `dca` | DTS, DTS-HD MA, DTS:X core, DTS-ES, DTS 96/24 |
| **AAC** | `aac`, `aac_latm`, `aac_fixed` | AAC-LC, HE-AAC v1/v2, AAC-LD |
| **Opus** | `opus`, `libopus` | Modern low-latency streaming |
| **MP3** | `mp3`, `mp3float`, `libmp3lame` | MPEG-1/2 Audio Layer III |
| **FLAC & ALAC** | `flac`, `alac` | Free Lossless Audio & Apple Lossless |
| **Monkey's Audio** | `ape` | High-compression lossless format |
| **WavPack** | `wavpack` | Hybrid lossless/lossy format |
| **Windows Media** | `wmapro`, `wmav1`, `wmav2`, `wmalossless` | WMA standard, professional, and lossless |
| **RealAudio** | `cook`, `ra_144`, `ra_288`, `atrac1`, `atrac3` | RealMedia / ATRAC audio codecs |
| **AMR** | `amrnb`, `amrwb` | Cellular voice audio (Narrowband & Wideband) |
| **DSD / SACD** | `dsd_lsbf`, `dsd_msbf`, `dsd_planar` | Super Audio CD bitstreams |
| **PCM** | `pcm_s16le`, `pcm_s24le`, `pcm_s32le`, `pcm_bluray` | Uncompressed studio audio |

### 2. Video Decoders
| Format | Decoders / Hardware | Notes |
| :--- | :--- | :--- |
| **HEVC / H.265** | `hevc`, `hevc_mediacodec` | Main, Main10 (10-bit HDR), HW accelerated |
| **AVC / H.264** | `h264`, `h264_mediacodec` | Baseline, Main, High, Hi10P |
| **AV1** | `libdav1d`, `av1_mediacodec` | Ultra-fast AV1 software & HW playback |
| **VP9 & VP8** | `libvpx`, `vp9_mediacodec`, `vp8_mediacodec` | YouTube and WebM video formats |
| **MPEG-4 Part 2** | `mpeg4`, `mpeg4_mediacodec`, `msmpeg4` | DivX, XviD, MS-MPEG4 |
| **MPEG-1 & MPEG-2** | `mpeg1video`, `mpeg2video` | DVD Video, VOB, DVB broadcasts |
| **VC-1 & WMV** | `vc1`, `wmv1`, `wmv2`, `wmv3` | Windows Media Video & Blu-ray VC-1 |
| **RealVideo** | `rv10`, `rv20`, `rv30`, `rv40` | RMVB video streams |
| **Apple ProRes** | `prores` | ProRes 422, 4444, HQ, Proxy |
| **Legacy Formats** | `mjpeg`, `theora`, `flv1`, `vp6`, `binkvideo`, `cinepak` | Classic video formats |

### 3. Subtitle Decoders & Renderers
| Format | Component | Notes |
| :--- | :--- | :--- |
| **Advanced SSA / ASS** | `libass` + `libfreetype` + `libfribidi` | Anime styled subtitles, positioning, fonts, colors, and karaoke |
| **SubRip (.srt)** | `subrip` | Standard SRT text subtitles |
| **WebVTT (.vtt)** | `webvtt` | HTML5 / HLS streaming text subtitles |
| **HDMV PGS** | `pgssub` | High-definition Blu-ray image subtitles |
| **DVD VobSub** | `dvdsub` | Standard DVD `.sub` / `.idx` image subtitles |
| **DVB Subtitles** | `dvbsub` | European digital TV broadcast subtitles |
| **DVB Teletext** | `teletext` | Broadcast teletext closed captions |
| **MP4 / 3GPP Text** | `mov_text` | QuickTime / MP4 timed text |
| **Others** | `microdvd`, `sami`, `jacosub`, `realtext`, `cc_dec` | Closed captions (EIA-608 / CEA-708) & text |

---

## 🛠️ Command-Line Arguments

| Flag | Description |
| :--- | :--- |
| `--profile=ultimate` or `-u` | **Universal Ultimate Profile**: Enables all audio/video/subtitle decoders, MediaCodec HW acceleration, GPL, all free/gpl external libraries, and builds modular `.so` + unified `libffmpeg.so`. |
| `-abis=<list>` | Comma-separated list of ABIs (`arm64-v8a`, `armeabi-v7a`, `x86`, `x86_64`). Default: all 4. |
| `--build-single-so` or `-single-so` | Links the single unified `libffmpeg.so` for easy drop-in JNI integration. |
| `--enable-libass` or `-ass` | Enables `libass` SSA/ASS subtitle engine (auto-includes FreeType and FriBidi). |
| `--enable-mediacodec` or `-mediacodec` | Enables Android MediaCodec hardware video acceleration. |
| `--enable-all-free` or `-all-free` | Enables all non-GPL external libraries (`libdav1d`, `libopus`, `libvpx`, `libass`, etc.). |
| `--enable-all-gpl` or `-all-gpl` | Enables GPL external libraries (`libx264`, `libx265`). |
| `--android-api-level=<num>` | Minimum Android API level (Default: `21`). |

---

## 💻 Requirements & Environment

1. **Android NDK**: Version **r23** or higher (r25c / r26 recommended).
2. **Environment Variables**:
   - `ANDROID_NDK_HOME` – Path to your Android NDK.
   - `ANDROID_SDK_HOME` (or `ANDROID_HOME` / `ANDROID_SDK_ROOT`) – Path to your Android SDK.
3. **Host Tools**:
   `make`, `cmake`, `curl`, `tar`, `zip`, `unzip`, `nasm`, `ninja`, `meson`, `pkg-config`, `clang`, `yasm`.

---

## 🚀 Automated Cloud Builds (GitHub Actions)

This repository includes a ready-to-run GitHub Actions workflow in `.github/workflows/build.yml`.

Whenever you push to `master` or `main` (or click **Run workflow** under the Actions tab):
1. Runs on Ubuntu 22.04 with Android NDK r25c.
2. Compiles FFmpeg with the complete `--profile=ultimate` profile for `arm64-v8a` and `armeabi-v7a`.
3. Packages `ffmpeg-android-ultimate.zip` (modular `.so`, headers, CLI tools) and `ffmpeg-android-single-so.zip` (`libffmpeg.so`).
4. Automatically publishes the packages to **GitHub Releases** for direct download!

---

## 📄 License

- **ffmpeg-android-maker** scripts are licensed under the [MIT License](LICENSE.txt).
- FFmpeg itself is licensed under **LGPL 2.1** (or **GPL 2.0+** when GPL features/libraries like `libx264`/`libx265` are enabled).
