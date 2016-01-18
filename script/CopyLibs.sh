#!/bin/bash

#
# Copy all library files that specified in TARGETS, then rpath-ize for utilize in the project
#

# FIXME: paths are needed to be general
SRC_HOME="/Users/eirny/Developer/gstreamer-osx"
LIB_HOME="/Users/eirny/Work/GNOME"

# Libraries
TARGETS=" \
	libglib-2.0.0.dylib \
	libgobject-2.0.0.dylib \
	libgio-2.0.0.dylib \
	libgmodule-2.0.0.dylib \
	libgthread-2.0.0.dylib \
	libgstreamer-1.0.0.dylib \
	libgstbadbase-1.0.0.dylib \
	libgstcodecparsers-1.0.0.dylib \
	liborc-0.4.0.dylib \
	gstreamer-1.0/libgstapetag.so \
	gstreamer-1.0/libgstapplemedia.so \
	gstreamer-1.0/libgstalaw.so \
	gstreamer-1.0/libgstaudioconvert.so \
	gstreamer-1.0/libgstaudiofx.so \
	gstreamer-1.0/libgstaudioparsers.so \
	gstreamer-1.0/libgstaudiorate.so \
	gstreamer-1.0/libgstaudioresample.so \
	gstreamer-1.0/libgstautoconvert.so \
	gstreamer-1.0/libgstautodetect.so \
	gstreamer-1.0/libgstdebug.so \
	gstreamer-1.0/libgstdtsdec.so \
	gstreamer-1.0/libgstequalizer.so \
	gstreamer-1.0/libgstfaad.so \
	gstreamer-1.0/libgstinterleave.so \
	gstreamer-1.0/libgstid3demux.so \
	gstreamer-1.0/libgstisomp4.so \
	gstreamer-1.0/libgstlibav.so \
	gstreamer-1.0/libgstmatroska.so \
	gstreamer-1.0/libgstmpg123.so \
	gstreamer-1.0/libgstmpeg2dec.so \
	gstreamer-1.0/libgstmulaw.so \
	gstreamer-1.0/libgstopus.so \
	gstreamer-1.0/libgstosxaudio.so \
	gstreamer-1.0/libgstplayback.so \
	gstreamer-1.0/libgsttaglib.so \
	gstreamer-1.0/libgsttypefindfunctions.so \
	gstreamer-1.0/libgstvolume.so \
	gstreamer-1.0/libgstvorbis.so \
	gstreamer-1.0/libgstwavpack.so \
	gstreamer-1.0/libgstwavparse.so \
    gstreamer-1.0/libgstflac.so \
    gstreamer-1.0/libgstdeinterlace.so \
    gstreamer-1.0/libgstcoreelements.so \
"

mkdir -p "$SRC_HOME/usr/lib"
mkdir -p "$SRC_HOME/usr/lib/gstreamer-1.0"
mkdir -p "$SRC_HOME/usr/include"

cp -Rf "$LIB_HOME/include/glib-2.0" "$SRC_HOME/usr/include/"
cp -Rf "$LIB_HOME/include/gstreamer-1.0" "$SRC_HOME/usr/include/"

cp -f "$LIB_HOME/lib/glib-2.0/include/glibconfig.h" "$SRC_HOME/usr/include/glib-2.0/"
cp -f "$LIB_HOME/lib/gstreamer-1.0/include/gst/gstconfig.h" "$SRC_HOME/usr/include/gstreamer-1.0/gst/"
cp -f "$LIB_HOME/lib/gstreamer-1.0/include/gst/gl/gstglconfig.h" "$SRC_HOME/usr/include/gstreamer-1.0/gst/gl/"

#
# copy all TARGETS
#
# @rpath/gstreamer.framework/Versions/A/
"$SRC_HOME/Build/rpathize.js" --force --prefix @rpath/gstreamer.framework/lib/ --from "$LIB_HOME/lib/" --to "$SRC_HOME/usr/lib/" $TARGETS

#
# copy only single file
#
#"$SRC_HOME/Build/rpathize.js" --prefix @rpath/gstreamer.framework/lib/ --from "$LIB_HOME/lib/" --to "$SRC_HOME/usr/lib/" gstreamer-1.0/libgstflac.so


#
# rpathize example
#
#./rpathize.js --prefix @rpath/Libs/ --from /opt/X11/lib/ --to ../Libs libfontconfig.1.dylib