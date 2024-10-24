#!/usr/bin/env bash

# Exit on error.
set -ouex pipefail

# Enable extended globs.
shopt -s extglob

# Remove unnecessary (non-free) repos and keys.
REPO_DIR=/etc/yum.repos.d
if [ -d $REPO_DIR ]; then
    pushd $REPO_DIR
    echo Removing nonfree repos:
    rm -vf !(fedora*.repo)
    popd
else
    echo Repo directory not found! Skipping removal of non-free repos.
fi

FUSION_KEY_DIR=/usr/share/distribution-gpg-keys/rpmfusion
if [ -d $FUSION_KEY_DIR ]; then
    echo Removing RPMfusion keys.
    rm -rf $FUSION_KEY_DIR
else
    echo RPMfusion key directory not found, skipping removal of these keys.
fi

INCLUDED_PKGS=$(cat /tmp/pkgs.yaml | shyaml get-values include | uniq)
EXCLUDED_PKGS=$(cat /tmp/pkgs.yaml | shyaml get-values exclude | uniq)

# Remove only packages that are actually installed.
if [[ "${#EXCLUDED_PKGS}" -gt 0 ]]; then
    EXCLUDED_PKGS=$(rpm -qa --queryformat='%{NAME} ' ${EXCLUDED_PKGS})
fi

# If there are packages to install AND remove, run it all in one go.
if [[ "${#INCLUDED_PKGS}" -gt 0 && "${#EXCLUDED_PKGS}" -gt 0 ]]; then
    rpm-ostree override \
               remove $EXCLUDED_PKGS \
               $(printf -- "--install=%s " $INCLUDED_PKGS)

# If there are only packages to install.
elif [[ "${#INCLUDED_PKGS}" -gt 0 && "${#EXCLUDED_PKGS}" -eq 0 ]]; then
    rpm-ostree install $INCLUDED_PKGS

# If there are only packages to remove (override).
elif [[ "${#INCLUDED_PKGS}" -eq 0 && "${#EXCLUDED_PKGS}" -gt 0 ]]; then
    rpm-ostree override remove $EXCLUDED_PKGS

# If there are no intended package actions.
else
    echo No packages to install.
fi

# Add public key.
mkdir -p /usr/etc/pki/containers
cp /usr/share/silverred/cosign.pub /usr/etc/pki/containers/silverred.pub

# Enable update timers for ostree and flatpaks.
systemctl enable rpm-ostreed-automatic.timer
systemctl enable flatpak-system-update.timer
systemctl --global enable flatpak-user-update.timer

# Ensure ld is in path
ln -sf /usr/bin/ld.bfd /etc/alternatives/ld && \
    ln -sf /etc/alternatives/ld /usr/bin/ld

# Install quickemu
pushd `mktemp -d`
wget https://github.com/quickemu-project/quickemu/archive/refs/tags/4.9.6.tar.gz
bsdtar xvf *.tar.gz
mv -v quickemu-*/ /usr/share/quickemu
ln -vs /usr/share/quickemu/quickemu    /usr/bin/
ln -vs /usr/share/quickemu/quickget    /usr/bin/
ln -vs /usr/share/quickemu/quickreport /usr/bin/
popd

# Install protonvpn
PROTONVPN_VERSION=1.0.1-2
FEDORA_VERSION=$(cat /etc/fedora-release | cut -d\  -f 3)
pushd `mktemp -d`
wget "https://repo.protonvpn.com/fedora-$FEDORA_VERSION-stable/protonvpn-stable-release/protonvpn-stable-release-$PROTONVPN_VERSION.noarch.rpm"
rpm-ostree install ./protonvpn-stable-release-$PROTONVPN_VERSION.noarch.rpm || true
rpm-ostree install proton-vpn-gnome-desktop || true
popd
