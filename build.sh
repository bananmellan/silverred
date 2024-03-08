#!/usr/bin/env bash

# Exit on error.
set -oue pipefail

# Enable extended globs.
shopt -s extglob

# Remove unnecessary (non-free) repos and keys.
REPODIR=/usr/etc/yum.repos.d
if [ -d $REPODIR ]; then
	pushd /usr/etc/yum.repos.d
	echo Contents of /usr/etc:
	ls -l /usr/etc
	echo Contents of /etc:
	ls -l /etc
	echo Removing nonfree repos:
	rm -vf !(fedora*.repo)
	popd
else
	echo Repo directory not found! Skipping removal of non-free repos.
fi

FUSIONKEYDIR=/usr/share/distribution-gpg-keys/rpmfusion
if [ -d $FUSIONKEYDIR ]; then
	echo Removing RPMfusion keys.
	rm -rvf $FUSIONKEYDIR
else
	echo RPMfusion key directory not found, skipping removal of these keys.
fi

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
