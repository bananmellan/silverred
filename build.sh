#!/usr/bin/env bash
set -oue pipefail

rpm-ostree install \
		   fish \
		   distrobox \
		   wireshark \
		   darkman \
		   stow \
		   android-tools \
		   libtree-sitter \
		   evolution \
		   gnome-tweaks \
		   gnome-boxes \
		   gnome-shell-extension-dash-to-dock \
		   gnome-shell-extension-caffeine \
		   gnome-shell-extension-system-monitor-applet \
		   gpm-libs \
		   inotify-tools \
		   libadwaita \
		   libratbag-ratbagd \
		   piper \
		   libotf \
		   openssl \
		   podman-compose

rpm-ostree override remove \
		   firefox \
		   firefox-langpacks \
		   gnome-tour

mkdir -p /usr/etc/pki/containers
cp /usr/share/silverred/cosign.pub /usr/etc/pki/containers/silverred.pub

systemctl enable rpm-ostreed-automatic.timer
systemctl enable flatpak-system-update.timer
systemctl --global enable flatpak-user-update.timer
