#!/bin/sh
# Shell script to install libdvdcss under Debian GNU Linux
# Many DVDs use css for encryption.  To play these discs, a special library 
# is needed to decode them, libdvdcss.  Due to legal problems, Debian and most
# Linux distibutions cannot distribute libdvdcss
# Use this shell script to install the libdvdcss under DEBIAN GNU/Linux
# --------------------------------------------------------------------------
# Refer url for more info:
# Copyright info -  http://www.dtek.chalmers.se/~dvd/
# -------------------------------------------------------------------------
# This script is part of nixCraft shell script collection (NSSC)
# Visit http://bash.cyberciti.biz/ for more information.
# -------------------------------------------------------------------------
# Addition of checking for current version.  Gene Cumm <gene.cumm@gmail.com>
# -------------------------------------------------------------------------

set -e

if [ ! -w /etc/passwd ]; then
    echo "Super-user privileges are required.  Please run this with 'sudo'." >&2
    exit 1
fi

sitert=http://download.videolan.org/
site=${sitert}pub/debian/stable/
arch=$(dpkg --print-architecture)

soname=2
uversion=1.2.13
available="i386 amd64"
version=${uversion}-0

do_dyn=T
dist=$(lsb_release -cs)

if ! type wget > /dev/null ; then
    echo "Install wget and run this script again" >&2
    exit 1
fi

CSSTMP=$(mktemp -t -d dvdcss-XXXXXX)

# Attempt to dymanically fetch the current version
# dep: grep sed
if [ "$do_dyn" = "T" ];then
    for a in grep sed head; do
	if ! type "$a" > /dev/null ; then
	    echo "Can not find ${a}; Needed for dymanic fetch"
	    do_dyn=F
	fi
    done
fi
if [ "$do_dyn" = "T" ];then
    set +e	# prevent this from stopping everything
    wget "${site}/Packages" -O "$CSSTMP"/Packages && \
	url=${site}$(grep "Filename: .*libdvdcss${soname}.*${arch}.*\.deb" "$CSSTMP"/Packages|sed  's/Filename: //'|head -n 1) && \
	wget "${url}" -O "$CSSTMP"/libdvdcss.deb && \
	dpkg -i "$CSSTMP"/libdvdcss.deb && \
	exit 0
    echo "Dynamic fetch failed; Falling back to static fetch"
    set -e	# undo
else
	echo "Skipping dynamic fetch"
fi

for a in $available; do
    if [  "$a" = "$arch" ]; then
	wget ${site}libdvdcss${soname}_${version}_${arch}.deb -O "$CSSTMP"/libdvdcss.deb
	dpkg -i "$CSSTMP"/libdvdcss.deb
	exit $?
    fi
done

echo "No prebuilt binary available.  Will try to build and install it."
echo "You need to have build-essential, debhelper and fakeroot installed."
echo "If not, interrupt now, install them and rerun this script."
echo ""
echo "This is higly experimental, look out for what happens below."
echo "If you want to stop, interrupt now (control-c), else press"
echo "return to proceed"
read dum

if ! type dh_testdir > /dev/null || ! type fakeroot > /dev/null; then
    echo "Attempting to install build-essential, debhelper and fakeroot..." >&2
    apt-get update && apt-get install build-essential debhelper fakeroot
fi

if ! type dh_testdir > /dev/null || ! type fakeroot > /dev/null || 
! type make > /dev/null ; then
    echo "Failed to install build-essential, debhelper and fakeroot, exiting now." >&2
    exit 1
fi

cd "$CSSTMP"
wget ${site}libdvdcss_${uversion}.orig.tar.gz
wget ${site}libdvdcss_${version}.debian.tar.gz
wget ${site}libdvdcss_${version}.dsc
dpkg-source -x libdvdcss_${version}.dsc
cd libdvdcss-${uversion}
fakeroot ./debian/rules binary
dpkg -i ../libdvdcss${soname}_${version}_${arch}.deb
