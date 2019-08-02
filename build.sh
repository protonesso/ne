#!/bin/sh

VER="0.1"

die() {
	echo -e "ERROR: $@"
	exit 1
}

build_src() {
	echo "Compiling 'ne' package manager version $VERSION"

	rm -rf kagami vercmp

	echo "Compiling scripts"
	for scripts in ne; do
		cp $scripts.in $scripts
		sed -i $scripts -e "s|@VER[@]|$VER|g"
	done

	echo "Compiling helpers"
	${CROSS_COMPILE}cc $CFLAGS -static helpers/strlcpy.c helpers/vercmp.c helpers/dewey.c -o vercmp >&2

	echo "Done!"
}

install_src() {
	install -Dvm775 ne "${DESTDIR}"${PREFIX}/bin/ne
	install -Dvm775 vercmp "${DESTDIR}"${PREFIX}/bin/vercmp
	install -Dvm644 config "${DESTDIR}"/etc/ne/config
}

DESTDIR=
PREFIX=/usr/local

while getopts :IBP:D: options; do
	case $options in
		B)
			mode=build
			;;
		I)
			mode=install
			;;
		P)
			PREFIX="${OPTARG}"
			;;
		D)
			DESTDIR="${OPTARG}"
			;;
		:)
			die "Option '-${OPTARG}' needs an argument"
			;;
		\?)
			die "Option '-${OPTARG}' is illegal"
			;;
	esac
done
if [ "$#" -eq 0 ]; then
	die "Specify options. To list available options use: kagami -h"
fi
shift $((OPTIND - 1))

case $mode in
	build)
		build_src
		;;
	install)
		install_src
		;;
esac

exit 0

