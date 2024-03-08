#!/usr/bin/env bash

# Exit on error.
set -oue pipefail

# History expansion and extended globs on.
shopt -s extglob
set -H

# Remove unnecessary repos and keys.
pushd /usr/etc/yum.repos.d && rm -f !(fedora*.repo) && popd
rm -rf /usr/share/distribution-gpg-keys/rpmfusion

# Install packages.
rpm-ostree install \
		   fish \
		   distrobox \
		   wireshark \
		   darkman \
		   stow \
		   android-tools \
		   libtree-sitter \
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
		   podman-compose \
		   pavucontrol

# Remove (override) packages.
rpm-ostree override remove \
		   firefox \
		   firefox-langpacks \
		   gnome-tour \
		   nvidia-gpu-firmware

# Ensure scripts are executable.
find /usr/share/silverred/scripts -type f -exec bash -c 'chmod +x {}' \;

# Add public key.
mkdir -p /usr/etc/pki/containers
cp /usr/share/silverred/cosign.pub /usr/etc/pki/containers/silverred.pub

# Enable update timers for ostree and flatpaks.
systemctl enable rpm-ostreed-automatic.timer
systemctl enable flatpak-system-update.timer
systemctl --global enable flatpak-user-update.timer
