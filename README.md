# wireguard
[![Build Status](https://img.shields.io/travis/demyxco/wireguard?style=flat)](https://travis-ci.org/demyxco/wireguard)
[![Docker Pulls](https://img.shields.io/docker/pulls/demyx/wireguard?style=flat&color=blue)](https://hub.docker.com/r/demyx/wireguard)
[![Architecture](https://img.shields.io/badge/linux-amd64-important?style=flat&color=blue)](https://hub.docker.com/r/demyx/wireguard)
[![Alpine](https://img.shields.io/badge/alpine-3.11.6-informational?style=flat&color=blue)](https://hub.docker.com/r/demyx/wireguard)
[![WireGuard](https://img.shields.io/badge/wireguard-wireguard--tools--1.0.20200102--r0-informational?style=flat&color=blue)](https://hub.docker.com/r/demyx/wireguard)
[![Buy Me A Coffee](https://img.shields.io/badge/buy_me_coffee-$5-informational?style=flat&color=blue)](https://www.buymeacoffee.com/VXqkQK5tb)
[![Become a Patron!](https://img.shields.io/badge/become%20a%20patron-$5-informational?style=flat&color=blue)](https://www.patreon.com/bePatron?u=23406156)

Non-root Docker image running Alpine Linux and WireGuard. WireGuard® is an extremely simple yet fast and modern VPN that utilizes state-of-the-art cryptography.

DEMYX | wireguard
--- | ---
USER | demyx
ENTRYPOINT | ["demyx-entrypoint"]
PORT | 51820

## Requirements
- Kernel 5.4+ for Alpine Linux
- Kernel 5.6+ for Debian/Ubuntu and others or build the WireGuard module

## Usage
- To add more peers, change DEMYX_PEER, then restart the container
- To view the interface: `docker exec demyx_wireguard demyx-wg`
- To view all the keys: `docker exec demyx_wireguard demyx-wg keys`

```
# Demyx
# https://demyx.sh
#
# This docker-compose.yml is designed for VPS use with SSL/TLS first.
# Be sure to change all the domain.tld domains and credentials before running docker-compose up -d.
#
version: "3.7"
services:
  demyx_socket:
    container_name: demyx_socket
    environment:
      - CONTAINERS=1
    image: demyx/docker-socket-proxy
    networks:
      - demyx_socket
    # Uncomment below if your host OS is CentOS/RHEL/Fedora
    #privileged: true
    restart: unless-stopped
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
  demyx_traefik:
    container_name: demyx_traefik
    depends_on: 
      - demyx_socket
    environment:
      - DEMYX_ACME_EMAIL=info@domain.tld
    image: demyx/traefik
    networks:
      - demyx
      - demyx_socket
    ports:
      - 80:8081
      - 443:8082
    restart: unless-stopped
    volumes:
      - demyx_log:/var/log/demyx
      - demyx_traefik:/demyx
  demyx_pihole:
    container_name: demyx_pihole
    depends_on: 
      - demyx_traefik
    environment:
      DNS1: "1.1.1.1"
      DNS2: "1.0.0.1"
      TZ: America/Los_Angeles
      WEBPASSWORD: demyx
    image: pihole/pihole
    labels:
      - "traefik.enable=true"
      - "traefik.http.middlewares.pihole-redirect.redirectscheme.scheme=https"
      - "traefik.http.routers.pihole-http.entrypoints=http"
      - "traefik.http.routers.pihole-http.middlewares=pihole-redirect"
      - "traefik.http.routers.pihole-http.rule=Host(`domain.tld`)"
      - "traefik.http.routers.pihole-https.entrypoints=https"
      - "traefik.http.routers.pihole-https.rule=Host(`domain.tld`)"
      - "traefik.http.routers.pihole-https.service=vpn"
      - "traefik.http.routers.pihole-https.tls.certresolver=demyx"
      - "traefik.http.services.vpn.loadbalancer.server.port=80"
    networks:
      demyx:
        ipv4_address: 10.0.0.255
    restart: unless-stopped
    volumes:
      - demyx_pihole:/etc/pihole
      - demyx_pihole_dnsmasq:/etc/dnsmasq.d
  demyx_wireguard:
    cap_add:
      - NET_ADMIN
    container_name: demyx_wireguard
    depends_on: 
      - demyx_pihole
    environment:
      - DEMYX_ADDRESS=10.0.0.100
      - DEMYX_INTERFACE=eth0
      - DEMYX_PEER=1
      - DEMYX_PORT=51820
    image: demyx/wireguard
    networks:
      demyx:
        ipv4_address: 10.0.0.100
    ports:
      - 51820:51820/udp
    restart: unless-stopped
    volumes:
      - demyx_wireguard:/demyx
networks:
  demyx_socket:
    name: demyx_socket
  demyx:
    name: demyx
    ipam:
      driver: default
      config:
        - subnet: 10.0.0.0/16
volumes:
  demyx_log:
    name: demyx_log
  demyx_pihole:
    name: demyx_pihole
  demyx_pihole_dnsmasq:
    name: demyx_pihole_dnsmasq
  demyx_traefik:
    name: demyx_traefik
  demyx_wireguard:
    name: demyx_wireguard
```

## Updates & Support
[![Code Size](https://img.shields.io/github/languages/code-size/demyxco/wireguard?style=flat&color=blue)](https://github.com/demyxco/wireguard)
[![Repository Size](https://img.shields.io/github/repo-size/demyxco/wireguard?style=flat&color=blue)](https://github.com/demyxco/wireguard)
[![Watches](https://img.shields.io/github/watchers/demyxco/wireguard?style=flat&color=blue)](https://github.com/demyxco/wireguard)
[![Stars](https://img.shields.io/github/stars/demyxco/wireguard?style=flat&color=blue)](https://github.com/demyxco/wireguard)
[![Forks](https://img.shields.io/github/forks/demyxco/wireguard?style=flat&color=blue)](https://github.com/demyxco/wireguard)

* Auto built weekly on Saturdays (America/Los_Angeles)
* Rolling release updates
* For support: [#demyx](https://webchat.freenode.net/?channel=#demyx)
