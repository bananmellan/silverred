#!/usr/bin/env bash

# Exit on error.
set -ouex pipefail

# Enable extended globs.
shopt -s extglob

# Install quickemu
pushd `mktemp -d`
wget https://github.com/quickemu-project/quickemu/archive/refs/tags/4.9.4.tar.gz
tar --no-overwrite-dir -mzxvf *.tar.gz
mv -v quickemu-*/ /usr/share/quickemu
ln -vs /usr/share/quickemu/quickemu    /usr/bin/
ln -vs /usr/share/quickemu/quickget    /usr/bin/
ln -vs /usr/share/quickemu/quickreport /usr/bin/
popd

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

# Replace ls with eza, if it exists
# EZA_LOC=`whereis -b eza | awk '{print $2}'`
# LS_LOC=`whereis -b ls | awk '{print $2}'`
# if [ -x "$LS_LOC" ] && [ -x "$EZA_LOC" ]; then
#   rm -v $LS_LOC
#   ln -vs $EZA_LOC $LS_LOC
# fi

# Ensure emacs is in path
if ! [ -x /usr/bin/emacs ]; then
    EMACS_BIN_PATH=$(echo -n /usr/bin/emacs-*.* | awk '{print $1}')
    if [ -x "$EMACS_BIN_PATH" ]; then
        ln -vs $EMACS_BIN_PATH /usr/bin/emacs
    fi
fi

# Install protonvpn
PROTONVPN_VERSION=1.0.1-2
pushd `mktemp -d`
wget "https://repo.protonvpn.com/fedora-$(cat /etc/fedora-release | cut -d\  -f 3)-stable/protonvpn-stable-release/protonvpn-stable-release-$PROTONVPN_VERSION.noarch.rpm"
rpm-ostree install ./protonvpn-stable-release-$PROTONVPN_VERSION.noarch.rpm
rpm-ostree install proton-vpn-gnome-desktop
popd
