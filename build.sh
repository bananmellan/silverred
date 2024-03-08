#!/usr/bin/env bash
set -oue pipefail

cp /usr/share/silverred/cosign.pub /usr/etc/pki/containers/silverred.pub

rpm-ostree install \
		   fish \
		   darkman \
		   stow \
		   android-tools \
		   libtree-sitter \
		   evolution \
		   gnome-tweaks \
		   gnome-boxes \
		   gpm-libs \
		   inotify-tools \
		   libadwaita \
		   piper \
		   libtree-sitter \
		   libotf
