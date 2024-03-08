ARG FEDORA_MAJOR_VERSION=38

FROM quay.io/fedora-ostree-desktops/silverblue:${FEDORA_MAJOR_VERSION}

COPY cosign.pub /usr/share/silverred/cosign.pub

ADD build.sh /tmp/build.sh

RUN chmod +x /tmp/build.sh && \
	/tmp/build.sh && \
	rm -rf /tmp/* /var/* && \
	ostree container commit
