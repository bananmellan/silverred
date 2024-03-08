#!/usr/bin/env bash
wget http://ftp.acc.umu.se/mirror/gnu.org/gnu/emacs/emacs-29.2.tar.xz \
     -O /tmp/emacs.tar.xz

cd /tmp
tar xvf emacs.tar.xz
cd /tmp/emacs-*/

mkdir -p /usr/local
./configure --with-native-compilation --with-tree-sitter --with-pgtk \
            --prefix=/usr/local

make -j$(nproc) install
