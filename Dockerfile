FROM alpine

LABEL sh.demyx.image        demyx/wireguard
LABEL sh.demyx.maintainer   Demyx <info@demyx.sh>
LABEL sh.demyx.url          https://demyx.sh
LABEL sh.demyx.github       https://github.com/demyxco
LABEL sh.demyx.registry     https://hub.docker.com/u/demyx

# Set default environment variables
ENV DEMYX                   /demyx
ENV DEMYX_CONFIG            /etc/demyx
ENV DEMYX_LOG               /var/log/demyx
ENV DEMYX_ADDRESS           10.0.0.0
ENV DEMYX_PEER              1
ENV DEMYX_PORT              51820
ENV DEMYX_INTERFACE         eth0
ENV TZ                      America/Los_Angeles

# Configure Demyx
RUN set -ex; \
    addgroup -g 1000 -S demyx; \
    adduser -u 1000 -D -S -G demyx demyx; \
    \
    install -d -m 0755 -o demyx -g demyx "$DEMYX"; \
    install -d -m 0755 -o demyx -g demyx "$DEMYX_CONFIG"; \
    install -d -m 0755 -o demyx -g demyx "$DEMYX_LOG"

# Packages
RUN set -ex; \
    apk add --no-cache --update bash dumb-init sudo wireguard-tools tzdata

# Configure sudo
RUN set -ex; \
    echo "demyx ALL=(ALL) NOPASSWD: /etc/demyx/entrypoint.sh, /etc/demyx/wg.sh" > /etc/sudoers.d/demyx; \
    echo 'Defaults env_keep +="DEMYX"' >> /etc/sudoers.d/demyx; \
    echo 'Defaults env_keep +="DEMYX_CONFIG"' >> /etc/sudoers.d/demyx; \
    echo 'Defaults env_keep +="DEMYX_LOG"' >> /etc/sudoers.d/demyx; \
    echo 'Defaults env_keep +="DEMYX_ADDRESS"' >> /etc/sudoers.d/demyx; \
    echo 'Defaults env_keep +="DEMYX_PEER"' >> /etc/sudoers.d/demyx; \
    echo 'Defaults env_keep +="DEMYX_PORT"' >> /etc/sudoers.d/demyx; \
    echo 'Defaults env_keep +="DEMYX_INTERFACE"' >> /etc/sudoers.d/demyx; \
    echo 'Defaults env_keep +="TZ"' >> /etc/sudoers.d/demyx; \
    \
    # Supresses the sudo warning for now
    echo "Set disable_coredump false" > /etc/sudo.conf

# Copy source
COPY src "$DEMYX_CONFIG"

# Finalize
RUN set -ex; \
    # demyx-wg
    echo '#!/bin/bash' >> /usr/local/bin/demyx-wg; \
    echo 'sudo "$DEMYX_CONFIG"/wg.sh "$@"' >> /usr/local/bin/demyx-wg; \
    chmod +x "$DEMYX_CONFIG"/wg.sh; \
    chmod +x /usr/local/bin/demyx-wg; \
    \
    # demyx-entrypoint
    echo '#!/bin/bash' >> /usr/local/bin/demyx-entrypoint; \
    echo 'sudo "$DEMYX_CONFIG"/entrypoint.sh "$@"' >> /usr/local/bin/demyx-entrypoint; \
    chmod +x "$DEMYX_CONFIG"/entrypoint.sh; \
    chmod +x /usr/local/bin/demyx-entrypoint

USER demyx

ENTRYPOINT ["demyx-entrypoint"]
