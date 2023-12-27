#!/bin/sh
if ! [ $DISTROBOX_ENTER_PATH ]; then
    distrobox create -Y -i registry.fedoraproject.org/fedora-toolbox:39 \
              --name emacs-build

    wget http://ftp.acc.umu.se/mirror/gnu.org/gnu/emacs/emacs-29.1.tar.xz \
         -O /tmp/emacs.tar.xz
    cd /tmp
    tar xvf emacs.tar.xz
    distrobox enter -Y emacs-build -- sh /tmp/build-emacs.sh
    cd /tmp/emacs-*/
    sudo make install
else
    cd /tmp/emacs-*/
    yum builddep -y emacs
    ./configure --with-native-compilation --with-tree-sitter --with-pgtk
    make -j$(nproc)
fi
