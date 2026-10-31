#!/usr/bin/env bash

case $ANDROID_ABI in
  x86)
    EXTRA_BUILD_CONFIGURATION_FLAGS="$EXTRA_BUILD_CONFIGURATION_FLAGS --disable-asm"
    ;;
  x86_64)
    EXTRA_BUILD_CONFIGURATION_FLAGS="$EXTRA_BUILD_CONFIGURATION_FLAGS --x86asmexe=${NASM_EXECUTABLE}"
    ;;
esac

if [ "$FFMPEG_GPL_ENABLED" = true ] ; then
    EXTRA_BUILD_CONFIGURATION_FLAGS="$EXTRA_BUILD_CONFIGURATION_FLAGS --enable-gpl --enable-version3"
fi

if [ "$ENABLE_MEDIACODEC" = true ] || [ "$ULTIMATE_PROFILE" = true ] || [ "$MX_PROFILE" = true ]; then
  EXTRA_BUILD_CONFIGURATION_FLAGS="$EXTRA_BUILD_CONFIGURATION_FLAGS --enable-jni --enable-mediacodec"
  EXTRA_BUILD_CONFIGURATION_FLAGS="$EXTRA_BUILD_CONFIGURATION_FLAGS --enable-decoder=h264_mediacodec --enable-decoder=hevc_mediacodec --enable-decoder=mpeg4_mediacodec --enable-decoder=vp8_mediacodec --enable-decoder=vp9_mediacodec --enable-decoder=av1_mediacodec"
  EXTRA_BUILD_CONFIGURATION_FLAGS="$EXTRA_BUILD_CONFIGURATION_FLAGS --enable-hwaccel=h264_mediacodec --enable-hwaccel=hevc_mediacodec --enable-hwaccel=mpeg4_mediacodec --enable-hwaccel=vp8_mediacodec --enable-hwaccel=vp9_mediacodec --enable-hwaccel=av1_mediacodec"
fi

if [ "$ULTIMATE_PROFILE" = true ] || [ "$MX_PROFILE" = true ]; then
  ALL_AUDIO_DECODERS="--enable-decoder=ac3,ac3_fixed,eac3,truehd,mlp,dca,aac,aac_latm,aac_fixed,opus,vorbis,flac,alac,ape,wavpack,wma,wmav1,wmav2,wmapro,wmalossless,wma_voice,amrnb,amrwb,cook,ra_144,ra_288,atrac1,atrac3,atrac3plus,atrac9,dsd_lsbf,dsd_msbf,dsd_lsbf_planar,dsd_msbf_planar,mp3,mp3float,mp3on4,tak,shorten,mpc7,mpc8,binkaudio_rdft,binkaudio_dct,truespeech,twinvq,pcm_s16le,pcm_s24le,pcm_s32le,pcm_f32le,pcm_bluray,pcm_dvd,adpcm_ima_wav,adpcm_ms,adpcm_ea,adpcm_adx"
  ALL_AUDIO_PARSERS="--enable-parser=ac3,eac3,dca,mlp,aac,flac,opus,vorbis,mpegaudio,cook,tak"
  ALL_AUDIO_DEMUXERS="--enable-demuxer=ac3,eac3,dts,dtshd,truehd,mlp,aac,flac,ogg,wav,ape,wv,amr,rm,mpc,mpc8,tak,shn"

  ALL_VIDEO_DECODERS="--enable-decoder=hevc,h264,av1,vp9,vp8,mpeg4,msmpeg4v1,msmpeg4v2,msmpeg4v3,mpeg1video,mpeg2video,vc1,wmv1,wmv2,wmv3,wmv3image,rv10,rv20,rv30,rv40,prores,theora,flv1,vp6,vp6a,vp6f,mjpeg,mjpegb,binkvideo,cinepak,h263,h263p,indeo2,indeo3,indeo4,indeo5,dirac,svq1,svq3"
  ALL_VIDEO_PARSERS="--enable-parser=hevc,h264,av1,vp9,vp8,mpeg4video,mpegvideo,vc1,mjpeg,rv30,rv40,h263,dirac"
  ALL_VIDEO_DEMUXERS="--enable-demuxer=matroska,mov,avi,mpegts,mpegps,flv,asf,rm,mjpeg,h264,hevc,dirac,vc1"

  ALL_SUBTITLE_DECODERS="--enable-decoder=ass,ssa,subrip,webvtt,pgssub,dvdsub,dvbsub,teletext,mov_text,microdvd,sami,jacosub,realtext,cc_dec,xsub,mpl2,subviewer,text"
  ALL_SUBTITLE_PARSERS="--enable-parser=dvdsub,dvbsub"
  ALL_SUBTITLE_DEMUXERS="--enable-demuxer=srt,webvtt,ass,microdvd,sami,vobsub,subviewer,realtext"

  ALL_PROTOCOLS="--enable-protocol=file,pipe,http,https,tls,tcp,udp,rtp,rtsp,rtmp,rtmpe,rtmps,crypto,hls,dash,concat,data,subfile"
  ALL_FILTERS="--enable-filter=aresample,aformat,volume,pan,equalizer,bass,treble,loudnorm,scale,crop,format,fps,transpose,rotate,vflip,hflip,yadif,w3fdif,bwdif,null"

  EXTRA_BUILD_CONFIGURATION_FLAGS="$EXTRA_BUILD_CONFIGURATION_FLAGS $ALL_AUDIO_DECODERS $ALL_AUDIO_PARSERS $ALL_AUDIO_DEMUXERS $ALL_VIDEO_DECODERS $ALL_VIDEO_PARSERS $ALL_VIDEO_DEMUXERS $ALL_SUBTITLE_DECODERS $ALL_SUBTITLE_PARSERS $ALL_SUBTITLE_DEMUXERS $ALL_PROTOCOLS $ALL_FILTERS"
fi

ADDITIONAL_COMPONENTS=
for LIBRARY_NAME in ${FFMPEG_EXTERNAL_LIBRARIES[@]}
do
  ADDITIONAL_COMPONENTS+=" --enable-$LIBRARY_NAME"
done

DEP_CFLAGS="-I${BUILD_DIR_EXTERNAL}/${ANDROID_ABI}/include"
DEP_LD_FLAGS="-L${BUILD_DIR_EXTERNAL}/${ANDROID_ABI}/lib $FFMPEG_EXTRA_LD_FLAGS"

EXTRA_LDFLAGS="-Wl,-z,max-page-size=16384 $DEP_LD_FLAGS"

STATIC_SHARED_FLAGS="--enable-shared --disable-static"

./configure \
  --prefix=${BUILD_DIR_FFMPEG}/${ANDROID_ABI} \
  --enable-cross-compile \
  --enable-pic \
  --target-os=android \
  --arch=${TARGET_TRIPLE_MACHINE_ARCH} \
  --sysroot=${SYSROOT_PATH} \
  --cc=${FAM_CC} \
  --cxx=${FAM_CXX} \
  --ld=${FAM_LD} \
  --ar=${FAM_AR} \
  --as=${FAM_CC} \
  --nm=${FAM_NM} \
  --ranlib=${FAM_RANLIB} \
  --strip=${FAM_STRIP} \
  --extra-cflags="-O3 -fPIC $DEP_CFLAGS" \
  --extra-ldflags="$EXTRA_LDFLAGS" \
  ${STATIC_SHARED_FLAGS} \
  --disable-vulkan \
  --pkg-config=${PKG_CONFIG_EXECUTABLE} \
  ${EXTRA_BUILD_CONFIGURATION_FLAGS} \
  $ADDITIONAL_COMPONENTS || exit 1

${MAKE_EXECUTABLE} clean
${MAKE_EXECUTABLE} -j${HOST_NPROC}
${MAKE_EXECUTABLE} install

