#!/usr/bin/env bash
set -oue pipefail

wget https://github.com/mullvad/mullvadvpn-app/releases/download/2023.4/MullvadVPN-2023.4_x86_64.rpm -O /tmp/mullvad.rpm
rpm-ostree install /tmp/mullvad.rpm

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
		   libratbag-ratbagd \
		   piper \
		   libtree-sitter \
		   libotf \
		   openssl \
		   podman-compose

rpm-ostree override remove \
		   firefox \
		   firefox-langpacks

mkdir -p /usr/etc/pki/containers
cp /usr/share/silverred/cosign.pub /usr/etc/pki/containers/silverred.pub
